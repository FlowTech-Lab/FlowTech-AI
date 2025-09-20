#!/bin/bash
set -euo pipefail

# ---- logging complet ----
mkdir -p logs
LOGFILE="logs/init-$(date +%Y%m%d-%H%M%S).log"
{
  echo "===== FlowTech-AI init $(date -Is) ====="
  echo "PWD: $(pwd)"
  echo "User: $(id -u):$(id -g)"
} >>"$LOGFILE"

exec > >(stdbuf -oL tee -a "$LOGFILE") 2>&1

if [ "${INIT_DEBUG:-0}" = "1" ]; then
  exec 9>>"$LOGFILE"
  BASH_XTRACEFD=9
  set -x
fi

trap 'ec=$?; echo; echo "[INFO ] init finished with exit code: $ec"; echo "Full log: $LOGFILE"; exit $ec' EXIT

# -------- Helpers -----------------------------------------------------------
need() {
  command -v "$1" >/dev/null 2>&1 || {
    printf '[ERROR] Missing dependency: %s\n' "$1" >&2
    exit 1
  }
}

getenv_value() {
  grep -E "^$1=" .env 2>/dev/null | tail -n1 | cut -d= -f2-
}

enforce_env() {
  local key="$1" value="$2"
  if grep -qE "^${key}=" .env 2>/dev/null; then
    sed -i "s|^${key}=.*|${key}=${value}|" .env
  else
    echo "${key}=${value}" >> .env
  fi
}

ensure_env() {
  local key="$1" value="$2"
  grep -qE "^${key}=" .env 2>/dev/null || echo "${key}=${value}" >> .env
}

putenv_if_missing() {
  local key="$1" value="$2"
  grep -qE "^${key}=" .env 2>/dev/null || echo "${key}=${value}" >> .env
}

wait_for_service() {
  local service="$1"
  local command="$2"
  local timeout="${3:-60}"
  log_info "Waiting for ${service} to be ready (timeout: ${timeout}s)"
  for i in $(seq 1 "$timeout"); do
    if eval "$command" >/dev/null 2>&1; then
      log_ok "${service} is ready"
      return 0
    fi
    sleep 1
  done
  log_warn "${service} not ready after ${timeout}s"
  return 1
}

run() {
  local secs="${1:-20}"; shift
  local cmd="$*"
  log_info "RUN (timeout ${secs}s): $cmd"
  if timeout "${secs}" bash -lc "$cmd"; then
    log_ok "DONE: $cmd"
  else
    local rc=$?
    log_warn "FAILED/timeout rc=$rc: $cmd"
    return $rc
  fi
}

# -------- Styling ----------------------------------------------------------
BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"
RESET="\033[0m"

log_info() { printf "%b[INFO ]%b %s\n" "$CYAN" "$RESET" "$*"; }
log_ok()   { printf "%b[ OK  ]%b %s\n" "$GREEN" "$RESET" "$*"; }
log_warn() { printf "%b[WARN ]%b %s\n" "$YELLOW" "$RESET" "$*"; }

TOTAL_STEPS=9
STEP=0
next_step() {
  STEP=$((STEP + 1))
  printf "\n%b>>> Step %d/%d:%b %s\n" "$BOLD" "$STEP" "$TOTAL_STEPS" "$RESET" "$*"
}

log_info "Starting FlowTech-AI bootstrap"

# Step 1: prerequisites
next_step "Validating prerequisites"
need openssl && log_ok "openssl available"
need curl    && log_ok "curl available"
need docker  && log_ok "docker available"
if docker compose version >/dev/null 2>&1; then
  log_ok "docker compose plugin detected"
else
  printf '[ERROR] docker compose plugin is required\n' >&2
  exit 1
fi

umask 077
log_info "Ensuring .env exists"
touch .env

if ! docker info >/dev/null 2>&1; then
  log_warn "Current user cannot access Docker. Add to docker group and re-login:"
  log_warn "  sudo usermod -aG docker $USER && newgrp docker"
  exit 1
fi

if [ "${INIT_PULL:-yes}" != "no" ]; then
  log_info "Pulling latest container images (set INIT_PULL=no to skip)"
  docker compose pull
fi

# Step 2: directories & permissions
next_step "Preparing data directories"
uid="$(id -u)"
gid="$(id -g)"

# Application data directories (exclude pgdata which is owned by postgres)
mkdir -p ./AI_Data/{openwebui,n8n,searxng,qdrant,clickhouse}
chown -R "$uid:$gid" ./AI_Data/{openwebui,n8n,searxng,qdrant,clickhouse} 2>/dev/null || true
find ./AI_Data/{openwebui,n8n,qdrant,clickhouse} -type d -exec chmod 700 {} + 2>/dev/null || true
find ./AI_Data/{openwebui,n8n,qdrant,clickhouse} -type f -exec chmod 600 {} + 2>/dev/null || true
# SearxNG must stay readable by the container entrypoint
find ./AI_Data/searxng -type d -exec chmod 755 {} + 2>/dev/null || true
find ./AI_Data/searxng -type f -exec chmod 644 {} + 2>/dev/null || true

# PostgreSQL init scripts directory – readable by postgres (UID 70)
INIT_DIR="./AI_Data/postgres-init"
mkdir -p "$INIT_DIR"
if command -v sudo >/dev/null 2>&1; then
  sudo chown root:root "$INIT_DIR" || true
  sudo chmod 755 "$INIT_DIR" || true
  sudo find "$INIT_DIR" -type f -name '*.sh' -exec chmod 755 {} \; || true
  sudo find "$INIT_DIR" -type f -name '*.sql*' -exec chmod 644 {} \; || true
  sudo chown -R root:root "$INIT_DIR" || true
else
  log_warn "sudo not available: ensure init scripts are readable by Postgres"
  chmod 755 "$INIT_DIR" 2>/dev/null || true
  find "$INIT_DIR" -type f -name '*.sh' -exec chmod 755 {} \; >/dev/null 2>&1 || true
  find "$INIT_DIR" -type f -name '*.sql*' -exec chmod 644 {} \; >/dev/null 2>&1 || true
fi

# PostgreSQL data directory – let postgres own files on first start
PGDATA_DIR="./AI_Data/pgdata"
mkdir -p "$PGDATA_DIR"
chmod 700 "$PGDATA_DIR" 2>/dev/null || true

# Seed init script for PostgreSQL (executed only on first cluster init)
INIT_SQL="$INIT_DIR/01-create-langfuse.sql"
if [ ! -f "$INIT_SQL" ]; then
  log_info "Writing PostgreSQL init script for langfuse database"
  TMP="$(mktemp)"
  cat > "$TMP" <<'EOSQL'
SELECT 'CREATE DATABASE langfuse'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'langfuse')\gexec
EOSQL
  if command -v sudo >/dev/null 2>&1; then
    sudo install -o root -g root -m 0644 "$TMP" "$INIT_SQL"
    sudo chown root:root "$INIT_DIR"
    sudo chmod 755 "$INIT_DIR"
  else
    mv "$TMP" "$INIT_SQL"
    chmod 644 "$INIT_SQL"
    chmod 755 "$INIT_DIR"
  fi
  rm -f "$TMP"
fi

log_ok "AI_Data folders ready with secure permissions"

available_space=$(df -Pk . | tail -1 | awk '{print $4}')
if [ "${available_space:-0}" -lt 2097152 ]; then
  log_warn "Less than 2GB of free disk space detected; at least 5GB is recommended"
fi

# Step 3: SearxNG configuration
next_step "Syncing SearxNG configuration"
mkdir -p searxng
if [ -f settings.yml ] && [ ! -f searxng/settings.yml ]; then
  cp settings.yml searxng/settings.yml
  log_info "Copied settings.yml into searxng/"
fi
for f in searxng/settings.yml searxng/limiter.toml; do
  [ -f "$f" ] && chmod 644 "$f"
done
if [ -d searxng ]; then
  mkdir -p AI_Data/searxng
  cp -a searxng/. AI_Data/searxng/
  chown -R "$uid:$gid" AI_Data/searxng 2>/dev/null || true
  find AI_Data/searxng -type d -exec chmod 755 {} +
  find AI_Data/searxng -type f -exec chmod 644 {} +
fi
log_ok "SearxNG templates copied into AI_Data/searxng"

# Step 4: base environment defaults
next_step "Seeding base environment variables"
ensure_env OLLAMA_BASE_URL "http://192.168.0.2:11434"
ensure_env OPENWEBUI_PORT "8081"
ensure_env SEARXNG_PORT "8082"
ensure_env N8N_PORT "5678"
ensure_env POSTGRES_USER "n8n"
ensure_env POSTGRES_DB "n8n"
if ! grep -qE '^POSTGRES_PASSWORD=' .env 2>/dev/null; then
  enforce_env POSTGRES_PASSWORD "$(openssl rand -base64 24)"
  log_info "Generated POSTGRES_PASSWORD"
fi
ensure_env LANGFUSE_PORT "3300"
ensure_env LANGFUSE_EXTERNAL_URL "http://localhost:3300"
enforce_env LANGFUSE_HOST "http://langfuse:3000"
ensure_env LANGFUSE_TRACING_ENVIRONMENT "dev"
ensure_env LANGFUSE_INIT_PROJECT_RETENTION "30"
ensure_env TZ "Europe/Paris"
log_ok "Core environment variables present"

# Step 5: Langfuse core secrets & DB URL
next_step "Configuring Langfuse credentials"
if ! grep -qE '^LANGFUSE_NEXTAUTH_SECRET=' .env 2>/dev/null; then
  enforce_env LANGFUSE_NEXTAUTH_SECRET "$(openssl rand -hex 32)"
  log_info "Generated LANGFUSE_NEXTAUTH_SECRET"
fi
if ! grep -qE '^LANGFUSE_SALT=' .env 2>/dev/null; then
  enforce_env LANGFUSE_SALT "$(openssl rand -hex 16)"
  log_info "Generated LANGFUSE_SALT"
fi
if ! grep -qE '^LANGFUSE_ENCRYPTION_KEY=' .env 2>/dev/null; then
  enforce_env LANGFUSE_ENCRYPTION_KEY "$(openssl rand -hex 32)"
  log_info "Generated LANGFUSE_ENCRYPTION_KEY"
fi
ensure_env LANGFUSE_PUBLIC_KEY ""
ensure_env LANGFUSE_SECRET_KEY ""
if ! grep -qE '^LANGFUSE_DATABASE_URL=' .env 2>/dev/null; then
  if command -v python3 >/dev/null 2>&1; then
    export __LF_USER="$(grep -E '^POSTGRES_USER=' .env | tail -n1 | cut -d= -f2)"
    export __LF_PASS="$(grep -E '^POSTGRES_PASSWORD=' .env | tail -n1 | cut -d= -f2)"
    LANGFUSE_DATABASE_URL=$(python3 - <<'PY'
import os, urllib.parse
user = os.environ.get("__LF_USER", "n8n") or "n8n"
password = os.environ.get("__LF_PASS", "")
encoded = urllib.parse.quote(password, safe="")
print(f"postgresql://{user}:{encoded}@postgres:5432/langfuse")
PY
    )
    unset __LF_USER __LF_PASS
    enforce_env LANGFUSE_DATABASE_URL "${LANGFUSE_DATABASE_URL}"
    log_ok "LANGFUSE_DATABASE_URL generated"
  else
    log_warn "python3 missing: please set LANGFUSE_DATABASE_URL manually if needed"
  fi
else
  log_ok "LANGFUSE_DATABASE_URL already set"
fi

# Step 6: Langfuse headless defaults
next_step "Preparing Langfuse headless defaults"
ORG_ID="${LANGFUSE_INIT_ORG_ID:-FlowTech-LAB}"
PROJ_ID="${LANGFUSE_INIT_PROJECT_ID:-default}"
USER_MAIL="${LANGFUSE_INIT_USER_EMAIL:-admin@local}"
USER_NAME="${LANGFUSE_INIT_USER_NAME:-Admin}"
if ! grep -qE '^LANGFUSE_INIT_USER_PASSWORD=' .env 2>/dev/null; then
  enforce_env LANGFUSE_INIT_USER_PASSWORD "$(openssl rand -base64 18)"
  log_info "Generated Langfuse headless user password"
fi
if ! grep -qE '^LANGFUSE_INIT_PROJECT_PUBLIC_KEY=' .env 2>/dev/null; then
  enforce_env LANGFUSE_INIT_PROJECT_PUBLIC_KEY "lf_pk_$(openssl rand -hex 24)"
  log_info "Generated Langfuse public API key"
fi
if ! grep -qE '^LANGFUSE_INIT_PROJECT_SECRET_KEY=' .env 2>/dev/null; then
  enforce_env LANGFUSE_INIT_PROJECT_SECRET_KEY "lf_sk_$(openssl rand -hex 32)"
  log_info "Generated Langfuse secret API key"
fi
putenv_if_missing LANGFUSE_INIT_ORG_ID "$ORG_ID"
putenv_if_missing LANGFUSE_INIT_ORG_NAME FlowTech-LAB
putenv_if_missing LANGFUSE_INIT_PROJECT_ID "$PROJ_ID"
putenv_if_missing LANGFUSE_INIT_PROJECT_NAME Default
putenv_if_missing LANGFUSE_INIT_USER_EMAIL "$USER_MAIL"
putenv_if_missing LANGFUSE_INIT_USER_NAME "$USER_NAME"
putenv_if_missing LANGFUSE_INIT_PROJECT_RETENTION 30
if [ -z "$(getenv_value LANGFUSE_PUBLIC_KEY)" ]; then
  enforce_env LANGFUSE_PUBLIC_KEY "$(getenv_value LANGFUSE_INIT_PROJECT_PUBLIC_KEY)"
fi
if [ -z "$(getenv_value LANGFUSE_SECRET_KEY)" ]; then
  enforce_env LANGFUSE_SECRET_KEY "$(getenv_value LANGFUSE_INIT_PROJECT_SECRET_KEY)"
fi
log_ok "Langfuse headless defaults ensured"

# Step 7: ClickHouse credentials
next_step "Generating ClickHouse credentials"
ensure_env CLICKHOUSE_USER "langfuse"
ensure_env CLICKHOUSE_URL "http://clickhouse:8123"
ensure_env CLICKHOUSE_MIGRATION_URL "clickhouse://clickhouse:9000"
ensure_env CLICKHOUSE_DB "langfuse"
if ! grep -qE '^CLICKHOUSE_PASSWORD=' .env; then
  enforce_env CLICKHOUSE_PASSWORD "$(openssl rand -base64 18)"
  log_info "Generated CLICKHOUSE_PASSWORD"
fi
chmod 600 .env
log_ok "CLICKHOUSE_* variables ensured"

# Step 8: Provision ClickHouse and PostgreSQL
next_step "Provisioning ClickHouse and PostgreSQL"
log_info "Starting ClickHouse and PostgreSQL containers"
mkdir -p logs
if docker compose up -d --wait clickhouse postgres 2>/dev/null; then
  log_ok "Containers reported healthy via docker compose --wait"
else
  log_warn "docker compose --wait unsupported or failed; falling back to manual readiness checks"
  docker compose up -d clickhouse postgres
fi

log_info "Capturing PostgreSQL init logs"
docker compose logs --since 30s postgres | tee logs/postgres-init.log

wait_for_service "ClickHouse" "docker compose exec -T clickhouse clickhouse-client -q 'SELECT 1'" 60 || true
wait_for_service "PostgreSQL" "docker compose exec -T postgres pg_isready -U '$(getenv_value POSTGRES_USER)'" 60 || true

if docker compose exec -T clickhouse clickhouse-client -q "SELECT 1" >/dev/null 2>&1; then
  PW="$(getenv_value CLICKHOUSE_PASSWORD)"
  docker compose exec -T clickhouse clickhouse-client -q "CREATE DATABASE IF NOT EXISTS langfuse"
  docker compose exec -T clickhouse clickhouse-client -q "CREATE USER IF NOT EXISTS langfuse IDENTIFIED BY '${PW}'"
  docker compose exec -T clickhouse clickhouse-client -q "GRANT ALL ON langfuse.* TO langfuse"
  log_ok "Langfuse schema and user configured in ClickHouse"
else
  log_warn "Skipping ClickHouse schema provisioning (service unavailable)"
fi

PGU="$(getenv_value POSTGRES_USER)"
[ -z "$PGU" ] && PGU="n8n"
if docker compose exec -T postgres psql -U "$PGU" -tc "SELECT 1 FROM pg_database WHERE datname='langfuse'" | grep -q 1; then
  log_ok "PostgreSQL database 'langfuse' already exists"
else
  log_warn "PostgreSQL database 'langfuse' missing; executing init script"
  if docker compose exec -T postgres psql -U "$PGU" -d postgres -a -e -f /docker-entrypoint-initdb.d/01-create-langfuse.sql >/dev/null 2>&1; then
    log_ok "Init script executed"
  else
    log_warn "Failed to run PostgreSQL init script"
  fi
  if docker compose exec -T postgres psql -U "$PGU" -tc "SELECT 1 FROM pg_database WHERE datname='langfuse'" | grep -q 1; then
    log_ok "PostgreSQL database 'langfuse' confirmed"
  else
    log_warn "Database 'langfuse' still missing; inspect PostgreSQL logs"
  fi
fi

log_info "Tearing down temporary DB services"
set +e

run 10 "docker compose ps clickhouse postgres || true"
run 15 "docker compose stop -t 5 clickhouse postgres || true"
run 10 "docker compose ps clickhouse postgres || true"

if docker ps --format '{{.Names}}' | grep -E '(clickhouse|postgres)(-[0-9]+)?$' >/dev/null; then
  log_warn "Force killing lingering DB containers"
  run 10 "docker compose kill clickhouse postgres || true"
fi

run 20 "docker compose rm -fsv clickhouse postgres || true"

for c in clickhouse postgres; do
  name="$(docker ps -a --format '{{.Names}}' | grep -E "${c}(-[0-9]+)?$" || true)"
  if [ -n "$name" ]; then
    run 10 "docker rm -f $name || true"
  fi
done

run 10 "docker ps -a | grep -E 'clickhouse|postgres' || true"
set -e

# Step 9: final validation
next_step "Validating environment configuration"
required_vars="POSTGRES_PASSWORD LANGFUSE_NEXTAUTH_SECRET LANGFUSE_SALT LANGFUSE_ENCRYPTION_KEY CLICKHOUSE_PASSWORD"
for var in $required_vars; do
  value=$(getenv_value "$var")
  if [ -z "$value" ]; then
    log_warn "Missing required variable: $var"
    exit 1
  fi
done
log_ok "All required critical environment variables are set"

log_ok "Environment prepared"
log_info "Next steps: run 'docker compose up -d' then './checklog.sh' to verify the stack"

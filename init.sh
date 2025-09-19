#!/bin/bash
set -euo pipefail

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

# -------- Styling ----------------------------------------------------------
BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"
RESET="\033[0m"

log_info() { printf "%b[INFO ]%b %s\n" "$CYAN" "$RESET" "$*"; }
log_ok()   { printf "%b[ OK  ]%b %s\n" "$GREEN" "$RESET" "$*"; }
log_warn() { printf "%b[WARN ]%b %s\n" "$YELLOW" "$RESET" "$*"; }

TOTAL_STEPS=8
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

if [ "${INIT_PULL:-yes}" != "no" ]; then
  log_info "Pulling latest container images (set INIT_PULL=no to skip)"
  docker compose pull
fi

# Step 2: directories & permissions
next_step "Preparing data directories"
uid="$(id -u)"
gid="$(id -g)"
mkdir -p ./AI_Data/{openwebui,pgdata,n8n,searxng,qdrant,clickhouse}
chown -R "$uid:$gid" ./AI_Data 2>/dev/null || true
find ./AI_Data -type d -exec chmod 700 {} + 2>/dev/null || true
find ./AI_Data -type f -exec chmod 600 {} + 2>/dev/null || true
log_ok "AI_Data folders ready with secure permissions"

# Step 3: SearxNG configuration
next_step "Syncing SearxNG configuration"
mkdir -p searxng
if [ -f settings.yml ] && [ ! -f searxng/settings.yml ]; then
  cp settings.yml searxng/settings.yml
  log_info "Copied settings.yml into searxng/"
fi
for f in searxng/settings.yml searxng/limiter.toml; do
  [ -f "$f" ] && chmod 600 "$f"
done
if [ -d searxng ]; then
  mkdir -p AI_Data/searxng
  cp -a searxng/. AI_Data/searxng/
  chown -R "$uid:$gid" AI_Data/searxng 2>/dev/null || true
  find AI_Data/searxng -type d -exec chmod 700 {} +
  find AI_Data/searxng -type f -exec chmod 600 {} +
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
sed -i '/^CLICKHOUSE_/d' .env
CH_PASS="$(openssl rand -base64 18)"
cat >> .env <<CHENV
CLICKHOUSE_USER=langfuse
CLICKHOUSE_PASSWORD=${CH_PASS}
CLICKHOUSE_URL=http://clickhouse:8123
CLICKHOUSE_MIGRATION_URL=clickhouse://clickhouse:9000
CLICKHOUSE_DB=langfuse
CHENV
chmod 600 .env
log_ok "CLICKHOUSE_* variables refreshed"

# Step 8: Provision ClickHouse schema
next_step "Provisioning ClickHouse"
log_info "Starting ClickHouse container"
docker compose up -d clickhouse
ready=false
for i in {1..60}; do
  if docker compose exec -T clickhouse clickhouse-client -q "SELECT 1" >/dev/null 2>&1; then
    ready=true
    break
  fi
  sleep 10
done
if ! $ready; then
  log_warn "Unable to reach ClickHouse client within 60s"
else
  log_ok "ClickHouse responded"
  PW="$(getenv_value CLICKHOUSE_PASSWORD)"
  docker compose exec -T clickhouse clickhouse-client -q "CREATE DATABASE IF NOT EXISTS langfuse"
  docker compose exec -T clickhouse clickhouse-client -q "CREATE USER IF NOT EXISTS langfuse IDENTIFIED BY '${PW}'"
  docker compose exec -T clickhouse clickhouse-client -q "GRANT ALL ON langfuse.* TO langfuse"
  log_ok "Langfuse schema and user configured in ClickHouse"
fi
 sleep 5
log_info "Stopping ClickHouse container"
docker compose stop clickhouse >/dev/null 2>&1 || true
docker compose rm -f clickhouse >/dev/null 2>&1 || true

log_ok "Environment prepared"
log_info "Next steps: run 'docker compose up -d' then './checklog.sh' to verify the stack"

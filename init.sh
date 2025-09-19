#!/bin/bash
set -euo pipefail

need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing dependency: $1" >&2
    exit 1
  }
}

getenv_value() {
  grep -E "^$1=" .env 2>/dev/null | tail -n1 | cut -d= -f2-
}

ensure_env() {
  local key="$1" value="$2"
  if ! grep -qE "^${key}=" .env 2>/dev/null; then
    echo "${key}=${value}" >> .env
  fi
}

update_env() {
  local key="$1" value="$2"
  if grep -qE "^${key}=" .env 2>/dev/null; then
    sed -i "s|^${key}=.*|${key}=${value}|" .env
  else
    echo "${key}=${value}" >> .env
  fi
}

need openssl
umask 077
touch .env

uid="$(id -u)"
gid="$(id -g)"

mkdir -p ./AI_Data/{openwebui,pgdata,n8n,searxng,qdrant,clickhouse}
chmod -R 700 ./AI_Data
chown -R "$uid:$gid" ./AI_Data 2>/dev/null || true

mkdir -p searxng
if [ -f settings.yml ] && [ ! -f searxng/settings.yml ]; then
  cp settings.yml searxng/settings.yml
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

ensure_env OLLAMA_BASE_URL "http://192.168.0.2:11434"
ensure_env OPENWEBUI_PORT "8081"
ensure_env SEARXNG_PORT "8082"
ensure_env N8N_PORT "5678"
ensure_env POSTGRES_USER "n8n"
ensure_env POSTGRES_DB "n8n"

if ! grep -qE '^POSTGRES_PASSWORD=' .env 2>/dev/null; then
  update_env POSTGRES_PASSWORD "$(openssl rand -base64 24)"
fi

ensure_env LANGFUSE_PORT "3300"
ensure_env LANGFUSE_EXTERNAL_URL "http://localhost:3300"
update_env LANGFUSE_HOST "http://langfuse:3000"
ensure_env LANGFUSE_TRACING_ENVIRONMENT "dev"

if ! grep -qE '^LANGFUSE_NEXTAUTH_SECRET=' .env 2>/dev/null; then
  update_env LANGFUSE_NEXTAUTH_SECRET "$(openssl rand -hex 32)"
fi
if ! grep -qE '^LANGFUSE_SALT=' .env 2>/dev/null; then
  update_env LANGFUSE_SALT "$(openssl rand -hex 16)"
fi
if ! grep -qE '^LANGFUSE_ENCRYPTION_KEY=' .env 2>/dev/null; then
  update_env LANGFUSE_ENCRYPTION_KEY "$(openssl rand -hex 32)"
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
    update_env LANGFUSE_DATABASE_URL "${LANGFUSE_DATABASE_URL}"
  else
    echo "WARN: python3 missing; set LANGFUSE_DATABASE_URL manually if needed." >&2
  fi
fi

# --- Headless init Langfuse: crée org/projet/utilisateur + clés si absents ---
putenv_if_missing() {
  local key="$1" value="$2"
  grep -qE "^${key}=" .env 2>/dev/null || echo "${key}=${value}" >> .env
}

ORG_ID="${LANGFUSE_INIT_ORG_ID:-FlowTech-LAB}"
PROJ_ID="${LANGFUSE_INIT_PROJECT_ID:-default}"
USER_MAIL="${LANGFUSE_INIT_USER_EMAIL:-admin@local}"
USER_NAME="${LANGFUSE_INIT_USER_NAME:-Admin}"

if ! grep -qE '^LANGFUSE_INIT_USER_PASSWORD=' .env 2>/dev/null; then
  update_env LANGFUSE_INIT_USER_PASSWORD "$(openssl rand -base64 18)"
fi
if ! grep -qE '^LANGFUSE_INIT_PROJECT_PUBLIC_KEY=' .env 2>/dev/null; then
  update_env LANGFUSE_INIT_PROJECT_PUBLIC_KEY "lf_pk_$(openssl rand -hex 24)"
fi
if ! grep -qE '^LANGFUSE_INIT_PROJECT_SECRET_KEY=' .env 2>/dev/null; then
  update_env LANGFUSE_INIT_PROJECT_SECRET_KEY "lf_sk_$(openssl rand -hex 32)"
fi

putenv_if_missing LANGFUSE_INIT_ORG_ID "$ORG_ID"
putenv_if_missing LANGFUSE_INIT_ORG_NAME FlowTech-LAB
putenv_if_missing LANGFUSE_INIT_PROJECT_ID "$PROJ_ID"
putenv_if_missing LANGFUSE_INIT_PROJECT_NAME Default
putenv_if_missing LANGFUSE_INIT_USER_EMAIL "$USER_MAIL"
putenv_if_missing LANGFUSE_INIT_USER_NAME "$USER_NAME"
putenv_if_missing LANGFUSE_INIT_PROJECT_RETENTION 30

if [ -z "$(getenv_value LANGFUSE_PUBLIC_KEY)" ]; then
  update_env LANGFUSE_PUBLIC_KEY "$(getenv_value LANGFUSE_INIT_PROJECT_PUBLIC_KEY)"
fi
if [ -z "$(getenv_value LANGFUSE_SECRET_KEY)" ]; then
  update_env LANGFUSE_SECRET_KEY "$(getenv_value LANGFUSE_INIT_PROJECT_SECRET_KEY)"
fi

putenv_if_missing CLICKHOUSE_URL ""
putenv_if_missing CLICKHOUSE_MIGRATION_URL ""
putenv_if_missing CLICKHOUSE_USER ""
putenv_if_missing CLICKHOUSE_PASSWORD ""
putenv_if_missing CLICKHOUSE_DB ""

chmod 600 .env

echo "Environment prepared. Run 'docker compose up -d' to launch the stack."

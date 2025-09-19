#!/bin/bash
set -euo pipefail

need() {
  command -v "$1" >/dev/null 2>&1 || { printf '[ERROR] Missing dependency: %s\n' "$1" >&2; exit 1; }
}

need docker
need curl
need jq
if ! docker compose version >/dev/null 2>&1; then
  echo "[ERROR] docker compose plugin is required" >&2
  exit 1
fi

BOLD="\033[1m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
CYAN="\033[36m"
RESET="\033[0m"

log_info()  { printf "%b[INFO ]%b %s\n"    "$CYAN"  "$RESET" "$*"; }
log_ok()    { printf "%b[ OK  ]%b %s\n"    "$GREEN" "$RESET" "$*"; }
log_warn()  { printf "%b[WARN ]%b %s\n"    "$YELLOW" "$RESET" "$*"; }
log_error() { printf "%b[FAIL ]%b %s\n"    "$RED"   "$RESET" "$*"; }

TOTAL_STEPS=14
STEP=0
next_step() {
  STEP=$((STEP + 1))
  printf "\n%b>>> Step %d/%d:%b %s\n" "$BOLD" "$STEP" "$TOTAL_STEPS" "$RESET" "$*"
}

mkdir -p logs
timestamp="$(date +%Y%m%d-%H%M%S)"
log_file="logs/checklog-${timestamp}.log"
log_info "Log output will be archived to $log_file"
exec > >(tee -a "$log_file")
exec 2>&1

next_step "Starting Compose services"
log_info "Running 'docker compose up -d'"
docker compose up -d
log_ok "docker compose up -d triggered"

next_step "Waiting for Postgres health"
CID_PG=$(docker compose ps -q postgres)
postgres_status="unknown"
for i in {1..60}; do
  postgres_status=$(docker inspect -f '{{.State.Health.Status}}' "$CID_PG" 2>/dev/null || true)
  if [ "$postgres_status" = "healthy" ]; then
    log_ok "Postgres is healthy"
    break
  fi
  sleep 1
done
if [ "$postgres_status" != "healthy" ]; then
  log_error "Postgres healthcheck never reached 'healthy' within 60s"
  exit 1
fi

next_step "Ensuring Langfuse database exists"
PGU=$(grep -E '^POSTGRES_USER=' .env | cut -d= -f2)
if docker compose exec -T postgres psql -U "$PGU" -tc "SELECT 1 FROM pg_database WHERE datname='langfuse'" | grep -q 1; then
  log_ok "Database 'langfuse' already present"
else
  log_warn "Database 'langfuse' missing; creating"
  docker compose exec -T postgres psql -U "$PGU" -c 'CREATE DATABASE langfuse;'
  log_ok "Database 'langfuse' created"
fi

next_step "Listing container status"
docker compose ps

next_step "Checking published ports"
for entry in \
  "qdrant 6333" \
  "openwebui 8080" \
  "searxng 8080" \
  "n8n 5678" \
  "langfuse-web 3000"; do
  set -- $entry
  svc="$1"
  port="$2"
  map=""
  for attempt in {1..5}; do
    map=$(docker compose port "$svc" "$port" 2>/dev/null || true)
    [ -n "$map" ] && break
    sleep 1
  done
  if [ -n "$map" ]; then
    log_ok "$svc exposed on $map"
  else
    log_warn "Port mapping unavailable for $svc"
  fi
done

next_step "HTTP probes"
http_probe() {
  local url="$1" label="$2"
  local status
  status=$(curl -sI "$url" 2>/dev/null | head -n1 || true)
  if [ -n "$status" ] && echo "$status" | grep -q "HTTP/"; then
    log_ok "$label reachable ($status)"
  else
    log_warn "$label unreachable ($url)"
  fi
}
http_probe "http://localhost:6333" "Qdrant"
http_probe "http://localhost:8081" "OpenWebUI"
http_probe "http://localhost:8082" "SearxNG"
http_probe "http://localhost:5678" "n8n"
LF_PORT=$(grep -E '^LANGFUSE_PORT=' .env | cut -d= -f2)
http_probe "http://localhost:${LF_PORT:-3300}" "Langfuse"

next_step "Validating container environment"
CID_OWUI=$(docker compose ps -q openwebui)
if [ -n "$CID_OWUI" ] && docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' "$CID_OWUI" | egrep '^(VECTOR_DB|RAG_VECTOR_DB|QDRANT_URI)=' >/dev/null; then
  log_ok "OpenWebUI RAG variables detected"
else
  log_warn "OpenWebUI RAG variables missing"
fi
CID_LF_WEB=$(docker compose ps -q langfuse-web)
if [ -n "$CID_LF_WEB" ] && docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' "$CID_LF_WEB" | egrep '^(DATABASE_URL|NEXTAUTH_URL|NEXTAUTH_SECRET|SALT|ENCRYPTION_KEY)=' >/dev/null; then
  log_ok "Langfuse web configuration present"
else
  log_warn "Langfuse web configuration incomplete"
fi

next_step "Capturing recent logs"
for svc in postgres qdrant openwebui searxng n8n langfuse-web langfuse-worker; do
  printf "\n%b--- Logs :: %s ---%b\n" "$BOLD" "$svc" "$RESET"
  docker compose logs --since=2m "$svc" | tail -n +1 || true
done

next_step "Monitoring Langfuse migrations"
if command -v timeout >/dev/null; then
  if ! timeout 5 docker compose logs -f --since=2m langfuse-worker | egrep -i "migration|ready|listening"; then
    log_warn "No migration/ready messages captured in last 5s"
  fi
else
  docker compose logs -f --since=2m langfuse-worker | egrep -i "migration|ready|listening" &
  watcher=$!
  sleep 5
  kill "$watcher" 2>/dev/null || true
fi
http_probe "http://localhost:3300" "Langfuse login page"
log_info "Langfuse UI credentials"
log_info " user: admin@local"
log_info " pass: $(grep '^LANGFUSE_INIT_USER_PASSWORD=' .env | cut -d= -f2)"

next_step "Checking ClickHouse"
docker compose exec -T clickhouse clickhouse-client -q "SHOW DATABASES"
docker compose exec -T clickhouse clickhouse-client -q "SHOW TABLES FROM langfuse"

next_step "Checking Postgres Langfuse database"
docker compose exec -T postgres psql -U "$PGU" -lqt | grep -w langfuse || log_warn "Langfuse DB missing"

next_step "Inspecting OpenWebUI keys"
CID=$(docker compose ps -q openwebui)
if [ -n "$CID" ]; then
  docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' "$CID" | egrep '^(VECTOR_DB|RAG_VECTOR_DB|QDRANT_URI|LANGFUSE_(HOST|PUBLIC_KEY|SECRET_KEY))='
else
  log_warn "OpenWebUI container not running"
fi

next_step "Listing Qdrant collections"
curl -s http://localhost:6333/collections | jq .

next_step "Reviewing SearxNG hints"
docker compose logs --since=2m searxng | grep -i 'settings.yml.new' || log_info "No new SearxNG warnings"

log_ok "Diagnostics complete"
log_info "Full log saved to $log_file"

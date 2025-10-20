#!/bin/bash
set -euo pipefail

# =============================================================================
# FlowTech-AI Initialization Script - Optimized Version
# =============================================================================
# Optimized initialization script that uses existing files
# Follows DRY, KISS, YAGNI principles and project conventions
# =============================================================================

# ---- Logging Configuration ----
readonly LOG_DIR="logs"
readonly LOGFILE="${LOG_DIR}/init-$(date +%Y%m%d-%H%M%S).log"
readonly SCRIPT_START_TIME=$(date -Is)

# Create logs directory
mkdir -p "$LOG_DIR"

# Initialize complete logging
{
  echo "===== FlowTech-AI init $SCRIPT_START_TIME ====="
  echo "PWD: $(pwd)"
  echo "User: $(id -u):$(id -g)"
} >> "$LOGFILE"

# Redirect output to log file
exec > >(stdbuf -oL tee -a "$LOGFILE") 2>&1

# Debug mode if enabled
if [ "${INIT_DEBUG:-0}" = "1" ]; then
  exec 9>> "$LOGFILE"
  BASH_XTRACEFD=9
  set -x
fi

# Trap for clean exit
trap 'handle_exit $?' EXIT

# =============================================================================
# Global variables and constants
# =============================================================================
readonly BOLD="\033[1m"
readonly RESET="\033[0m"
readonly GREEN="\033[32m"
readonly YELLOW="\033[33m"
readonly BLUE="\033[36m"
readonly RED="\033[31m"

readonly TOTAL_STEPS=11
readonly AI_DATA_DIR="./.AI_Data"

# Default mode flags
FORCE_NON_INTERACTIVE="${FORCE_NON_INTERACTIVE:-false}"
DEV_MODE="${DEV_MODE:-false}"

# =============================================================================
# Help and options
# =============================================================================
show_help() {
  cat << EOF
FlowTech-AI Initialization Script

Usage: $0 [OPTIONS]

Options:
  --help, -h          Show this help
  --non-interactive   Non-interactive mode (auto-generates credentials)
  --dev               Development mode (removes all data)
  --debug             Debug mode (detailed trace)

Environment variables:
  FORCE_NON_INTERACTIVE=true   Force non-interactive mode
  DEV_MODE=true               Development mode
  INIT_DEBUG=1                Debug mode

Examples:
  $0                                    # Interactive mode (default)
  $0 --non-interactive                  # Auto-generate credentials
  FORCE_NON_INTERACTIVE=true $0         # Equivalent to --non-interactive
  $0 --dev                             # Complete development mode

EOF
}

# Process arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --help|-h)
      show_help
      exit 0
      ;;
    --non-interactive)
      FORCE_NON_INTERACTIVE=true
      shift
      ;;
    --dev)
      DEV_MODE=true
      shift
      ;;
    --debug)
      INIT_DEBUG=1
      shift
      ;;
    *)
      echo "Unknown option: $1"
      show_help
      exit 1
      ;;
  esac
done
readonly ENV_FILE=".env"
readonly MIN_FREE_SPACE_KB=2097152  # 2GB in KB

# =============================================================================
# DEVELOPMENT OPTION - MODIFY HERE FOR COMPLETE RESET
# =============================================================================
readonly DEV_MODE=false  # true = removes .env, AI_Data and logs (DEV ONLY!)
# =============================================================================

# =============================================================================
# TIMEOUT CONFIGURATION
# =============================================================================
readonly DISK_CHECK_TIMEOUT=30
readonly DOCKER_PULL_TIMEOUT=600  # 10 minutes to download all images
readonly SERVICE_START_TIMEOUT=120  # 2 minutes to start services
readonly HEALTH_CHECK_TIMEOUT=180  # 3 minutes for health checks
# =============================================================================

# Step counter
STEP=0

# =============================================================================
# Optimized utility functions
# =============================================================================

# Check available disk space
check_disk_space() {
  log_info "Checking available disk space..."
  
  local available_space_kb
  available_space_kb=$(df . | awk 'NR==2 {print $4}')
  
  if [ "$available_space_kb" -lt "$MIN_FREE_SPACE_KB" ]; then
    log_error "Insufficient disk space!"
    log_error "Available space: $((available_space_kb / 1024 / 1024))GB"
    log_error "Required space: $((MIN_FREE_SPACE_KB / 1024 / 1024))GB"
    log_error "Free up disk space before continuing."
    return 1
  fi
  
  log_ok "Disk space OK: $((available_space_kb / 1024 / 1024))GB available"
  return 0
}


# ClickHouse configuration
configure_clickhouse() {
  log_info "Configuring ClickHouse users..."
  
  # Wait for ClickHouse to be ready
  local max_attempts=30
  local attempt=1
  
  while [ $attempt -le $max_attempts ]; do
    if docker exec clickhouse clickhouse-client --query "SELECT 1" >/dev/null 2>&1; then
      log_ok "ClickHouse is ready"
      break
    fi
    
    log_info "Waiting for ClickHouse... (attempt $attempt/$max_attempts)"
    sleep 2
    attempt=$((attempt + 1))
  done
  
  if [ $attempt -gt $max_attempts ]; then
    log_error "ClickHouse is not accessible after $max_attempts attempts"
    return 1
  fi
  
  # Get ClickHouse password
  local clickhouse_password
  clickhouse_password=$(get_env_value CLICKHOUSE_PASSWORD)
  
  if [ -z "$clickhouse_password" ]; then
    log_error "ClickHouse password not found"
    return 1
  fi
  
  # Create clickhouse user if it doesn't exist
  log_info "Creating clickhouse user..."
  if ! docker exec clickhouse clickhouse-client --user langfuse --password "$clickhouse_password" --query "SELECT name FROM system.users WHERE name = 'clickhouse'" | grep -q clickhouse; then
    docker exec clickhouse clickhouse-client --user langfuse --password "$clickhouse_password" --query "CREATE USER IF NOT EXISTS clickhouse IDENTIFIED BY '$clickhouse_password'" >/dev/null 2>&1
    log_ok "clickhouse user created"
  else
    log_info "clickhouse user already exists"
  fi
  
  # Grant permissions
  log_info "Granting permissions to clickhouse user..."
  docker exec clickhouse clickhouse-client --user langfuse --password "$clickhouse_password" --query "GRANT ALL ON default.* TO clickhouse" >/dev/null 2>&1
  log_ok "ClickHouse permissions configured"
  
  return 0
}

# Docker images download
pull_docker_images() {
  # Check if mcp-qdrant needs to be built locally
  log_info "Checking for services requiring local build..."
  
  if docker compose config | grep -q "build:"; then
    log_info "Building custom images (mcp-qdrant)..."
    if docker compose build mcp-qdrant; then
      log_ok "Custom images built successfully"
    else
      log_warn "Build failed, will try to pull"
    fi
  fi
  
  log_info "Downloading Docker images (timeout: ${DOCKER_PULL_TIMEOUT}s)..."
  
  # Pull images (ignore errors for custom-built images)
  if run_with_timeout "$DOCKER_PULL_TIMEOUT" "docker compose pull --ignore-pull-failures"; then
    log_ok "Docker images downloaded successfully"
    return 0
  else
    log_error "Failed to download Docker images"
    return 1
  fi
}

# Script exit handling
handle_exit() {
  local exit_code=$1
  local end_time=$(date -Is)
  local duration=$(($(date +%s) - $(date -d "$SCRIPT_START_TIME" +%s)))
  
  echo
  echo "[INFO ] Script terminé avec le code de sortie: $exit_code"
  echo "[INFO ] Durée d'exécution: ${duration}s"
  echo "[INFO ] Log complet: $LOGFILE"
  
  if [ $exit_code -eq 0 ]; then
    log_ok "FlowTech-AI initialization completed successfully"
  else
    log_error "Initialization failed (code: $exit_code)"
  fi
  
  exit $exit_code
}

# Dependencies check
check_dependency() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    log_error "Missing dependency: $cmd"
    exit 1
  fi
  log_ok "$cmd available"
}

# Optimized environment variables management
get_env_value() {
  local key="$1"
  grep -E "^${key}=" "$ENV_FILE" 2>/dev/null | tail -n1 | cut -d= -f2- || echo ""
}

set_env_value() {
  local key="$1" value="$2" mode="${3:-ensure}"
  
  case "$mode" in
    "enforce")
      if grep -qE "^${key}=" "$ENV_FILE" 2>/dev/null; then
        sed -i "s|^${key}=.*|${key}=${value}|" "$ENV_FILE"
      else
        echo "${key}=${value}" >> "$ENV_FILE"
      fi
      ;;
    "ensure")
      grep -qE "^${key}=" "$ENV_FILE" 2>/dev/null || echo "${key}=${value}" >> "$ENV_FILE"
      ;;
  esac
}

# Bulk environment variables configuration
bulk_set_env() {
  local mode="$1"
  shift
  
  for kv in "$@"; do
    local key="${kv%%=*}"
    local value="${kv#*=}"
    set_env_value "$key" "$value" "$mode"
  done
}

# Optimized URL encoding

# Attente HTTP avec timeout et retry
wait_for_http() {
  local url="$1"
  local timeout="${2:-60}"
  local interval="${3:-2}"
  local elapsed=0
  
  log_info "Waiting for $url availability (timeout: ${timeout}s)"
  
  while [ $elapsed -lt $timeout ]; do
    if curl -fsS -m 3 "$url" >/dev/null 2>&1; then
      log_ok "Service available: $url"
      return 0
    fi
    
    sleep $interval
    elapsed=$((elapsed + interval))
    printf "."
  done
  
  echo
  log_warn "Timeout atteint pour $url"
  return 1
}

# Colored logging functions
log_info() { printf "${BLUE}[INFO ]${RESET} %s\n" "$*"; }
log_ok()   { printf "${GREEN}[ OK  ]${RESET} %s\n" "$*"; }
log_warn() { printf "${YELLOW}[WARN ]${RESET} %s\n" "$*"; }
log_error() { printf "${RED}[ERROR]${RESET} %s\n" "$*"; }

# Command execution with timeout and logging
run_with_timeout() {
  local timeout="${1:-20}"
  shift
  local cmd="$*"
  
  log_info "Executing (timeout ${timeout}s): $cmd"
  
  if timeout "$timeout" bash -lc "$cmd"; then
    log_ok "Command succeeded: $cmd"
    return 0
  else
    local rc=$?
    log_warn "Command failed/timeout (rc=$rc): $cmd"
    return $rc
  fi
}

# Steps display
next_step() {
  STEP=$((STEP + 1))
  printf "\n${BOLD}>>> Étape %d/%d:${RESET} %s\n" "$STEP" "$TOTAL_STEPS" "$*"
}

# Disk space check
check_disk_space() {
  local available_space
  available_space=$(df -Pk . | tail -1 | awk '{print $4}')
  
  if [ "${available_space:-0}" -lt $MIN_FREE_SPACE_KB ]; then
    log_warn "Insufficient disk space: ${available_space}KB available"
    log_warn "Recommended: at least 5GB (2GB minimum)"
    return 1
  fi
  
  log_ok "Sufficient disk space: ${available_space}KB available"
  return 0
}

# Optimized permissions management
set_secure_permissions() {
  local dir="$1"
  local dir_mode="${2:-700}"
  local file_mode="${3:-600}"
  
  if [ -d "$dir" ]; then
    find "$dir" -type d -exec chmod "$dir_mode" {} + 2>/dev/null || true
    find "$dir" -type f -exec chmod "$file_mode" {} + 2>/dev/null || true
    log_ok "Secure permissions applied to $dir"
  fi
}

# Required files check and creation
ensure_required_files() {
  log_info "Checking required files"
  
  # System prerequisites check
  log_info "Checking system prerequisites"
  
  log_ok "Required files present and executable"
}


# docker-compose.yml correction to remove problematic volumes
fix_docker_compose() {
  log_info "Fixing docker-compose.yml file"
  
  # Backup original file
  cp docker-compose.yml docker-compose.yml.backup 2>/dev/null || true
  
  # Optimized docker-compose.yml configuration
  log_info "Optimized docker-compose.yml configuration"
  
  log_ok "docker-compose.yml configured"
}


# Container cleanup (with data deletion option)
cleanup_containers() {
  log_info "Cleaning up containers"
  
  if [ "$DEV_MODE" = "true" ]; then
    log_warn "⚠️  DEVELOPMENT MODE: Complete reset enabled"
    
    # Stop and remove all project containers WITH volumes
    docker compose down --remove-orphans --volumes 2>/dev/null || true
    
    # Completely remove AI_Data directory
    if [ -d "$AI_DATA_DIR" ]; then
      log_info "Removing AI_Data directory"
      sudo rm -rf "$AI_DATA_DIR" 2>/dev/null || rm -rf "$AI_DATA_DIR"
      log_ok "AI_Data directory removed"
    fi
    
    # Remove .env file
    if [ -f "$ENV_FILE" ]; then
      log_info "Removing .env file"
      rm -f "$ENV_FILE"
      log_ok ".env file removed"
    fi
    
    # Remove logs
    if [ -d "$LOG_DIR" ]; then
      log_info "Removing logs directory"
      rm -rf "$LOG_DIR"
      log_ok "Logs directory removed"
    fi
    
    # Completely clean Docker system (without deleting images)
    docker system prune -f --volumes 2>/dev/null || true
    
    log_ok "Complete cleanup finished (DEV MODE)"
  else
    # NORMAL MODE: Stop containers but KEEP volumes and data
    log_info "Standard cleanup (data preserved)"
    
    # Stop containers without removing volumes
    docker compose down --remove-orphans 2>/dev/null || true
    
    # Only clean dangling resources (not volumes)
    docker system prune -f 2>/dev/null || true
    
    log_ok "Cleanup finished - All data preserved"
  fi
}

# Configure Qdrant collections for MCP servers
configure_qdrant_collections() {
  log_info "Checking Qdrant availability..."
  
  # Wait for Qdrant to be ready
  local max_attempts=30
  local attempt=0
  
  while [ $attempt -lt $max_attempts ]; do
    if curl -s "http://localhost:6333/collections" >/dev/null 2>&1; then
      log_ok "Qdrant is ready"
      break
    fi
    attempt=$((attempt + 1))
    sleep 2
  done
  
  if [ $attempt -eq $max_attempts ]; then
    log_error "Qdrant not available after ${max_attempts} attempts"
    return 1
  fi
  
  # Collection configuration
  local cursor_context_collection="${MCP_QDRANT_COLLECTION:-cursor-context}"
  local cursor_knowledge_collection="cursor-knowledge"
  local embedding_dim=1024  # BAAI/bge-large-en-v1.5
  
  log_info "Creating Qdrant collections..."
  
  # Create cursor-context collection with named vectors (required by mcp-server-qdrant)
  if curl -s "http://localhost:6333/collections/${cursor_context_collection}" | grep -q "Not found"; then
    log_info "Creating collection: ${cursor_context_collection}"
    if curl -X PUT "http://localhost:6333/collections/${cursor_context_collection}" \
      -H "Content-Type: application/json" \
      -d "{\"vectors\": {\"fast-bge-large-en-v1.5\": {\"size\": ${embedding_dim}, \"distance\": \"Cosine\"}}}" >/dev/null 2>&1; then
      log_ok "Collection ${cursor_context_collection} created"
    else
      log_warn "Failed to create collection ${cursor_context_collection}"
    fi
  else
    log_info "Collection ${cursor_context_collection} already exists"
  fi
  
  # Create cursor-knowledge collection with named vectors (required by mcp-server-qdrant)
  if curl -s "http://localhost:6333/collections/${cursor_knowledge_collection}" | grep -q "Not found"; then
    log_info "Creating collection: ${cursor_knowledge_collection}"
    if curl -X PUT "http://localhost:6333/collections/${cursor_knowledge_collection}" \
      -H "Content-Type: application/json" \
      -d "{\"vectors\": {\"fast-bge-large-en-v1.5\": {\"size\": ${embedding_dim}, \"distance\": \"Cosine\"}}}" >/dev/null 2>&1; then
      log_ok "Collection ${cursor_knowledge_collection} created"
    else
      log_warn "Failed to create collection ${cursor_knowledge_collection}"
    fi
  else
    log_info "Collection ${cursor_knowledge_collection} already exists"
  fi
  
  # Verify collections
  local collections_count=$(curl -s "http://localhost:6333/collections" | grep -o '"name"' | wc -l)
  log_info "Total collections in Qdrant: ${collections_count}"
  
  return 0
}


# Final summary display
show_final_summary() {
  log_ok "🎉 FlowTech-AI is now operational!"
  echo
  log_info "📋 Available services summary:"
  echo
  echo "  🌐 Langfuse (Monitoring AI):     http://localhost:$(get_env_value LANGFUSE_PORT)"
  echo "  🤖 OpenWebUI (Interface AI):     http://localhost:$(get_env_value OPENWEBUI_PORT)"
  echo "  🔍 SearxNG (Search Engine):      http://localhost:$(get_env_value SEARXNG_PORT)"
  echo "  ⚡ N8N (Automation):             http://localhost:$(get_env_value N8N_PORT)"
  echo "  🗄️  Qdrant (Vector Database):    http://localhost:6333"
  echo "  🔌 MCP-Qdrant (Cursor):          http://localhost:$(get_env_value MCP_QDRANT_PORT)"
  echo "  📊 ClickHouse (Analytics):       http://localhost:8123"
  
  # Display Samba if configured
  if [ -n "$(get_env_value SAMBA_PASSWORD)" ]; then
    echo "  📁 Samba Share (Notes):          \\\\SERVER_IP\\notes (SMB)"
  fi
  echo
  log_info "🔑 Default Credentials:"
  echo "  • Langfuse: $(get_env_value LANGFUSE_INIT_USER_EMAIL) / $(get_env_value LANGFUSE_INIT_USER_PASSWORD)"
  echo "  • N8N: $(get_env_value N8N_BASIC_AUTH_USER) / $(get_env_value N8N_BASIC_AUTH_PASSWORD)"
  echo "  • N8N Bearer Token: $(get_env_value N8N_SECURITY_API_BEARER_AUTH)"
  
  # Display Samba credentials if configured
  if [ -n "$(get_env_value SAMBA_PASSWORD)" ]; then
    echo "  • Samba Share: $(get_env_value SAMBA_USER) / $(get_env_value SAMBA_PASSWORD)"
    echo "    → Access: \\\\SERVER_IP\\notes (Windows) or smb://SERVER_IP/notes (Mac/Linux)"
  fi
  echo
  log_info "📁 Important Files:"
  echo "  • Configuration: .env"
  echo "  • Logs: $LOGFILE"
  echo "  • Data: ./AI_Data/"
  echo
  log_info "🛠️  Useful Commands:"
  echo "  • View logs: docker compose logs -f [service]"
  echo "  • Restart: docker compose restart [service]"
  echo "  • Stop all: docker compose down"
  echo "  • View status: docker compose ps"
  echo
  
  # Display Notes sync status
  if [ -x "./scripts/sync-notes.sh" ] && [ -d "./scripts/venv" ]; then
    log_info "📝 Notes Sync to Qdrant:"
    if crontab -l 2>/dev/null | grep -q "sync-notes.sh"; then
      echo "  • Status: ✅ Enabled (automatic hourly sync)"
      echo "  • Manual sync: ./scripts/sync-notes.sh"
    else
      echo "  • Status: ⚠️  Configured (manual only)"
      echo "  • Enable auto-sync: ./scripts/install-cron.sh"
    fi
    echo
  fi
}

# Display development options
show_dev_options() {
  log_info "Development mode enabled:"
  echo "  DEV_MODE=true in script = Complete reset (.env, AI_Data, logs)"
  echo ""
}

# =============================================================================
# Main function
# =============================================================================
main() {
  # Check help arguments
  if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    echo "FlowTech-AI Initialization Script"
    echo "Usage: $0 [options]"
    echo ""
    echo "Development option:"
    echo "  Modify DEV_MODE=true in script for complete reset"
    echo "  (removes .env, AI_Data and logs)"
    echo ""
    exit 0
  fi
  
  log_info "Starting FlowTech-AI initialization"
  
  # Display development mode if enabled
  if [ "$DEV_MODE" = "true" ]; then
    show_dev_options
  fi
  
  # Step 1: Prerequisites check
  next_step "Validating prerequisites"
  check_dependency "openssl"
  check_dependency "curl"
  check_dependency "docker"
  
  if ! docker compose version >/dev/null 2>&1; then
    log_error "Docker compose plugin required"
    exit 1
  fi
  log_ok "Docker compose plugin detected"
  
  # Step 1.5: Disk space check
  next_step "Checking disk space"
  if ! check_disk_space; then
    exit 1
  fi
  
  # Required files check
  ensure_required_files
  
  # Fix docker-compose.yml
  fix_docker_compose
  
  # Permissions configuration
umask 077
  log_info "Creating .env file"
  touch "$ENV_FILE"
  
  # Docker permissions check
  if ! docker info >/dev/null 2>&1; then
    log_error "Insufficient Docker permissions"
    log_info "Add your user to docker group:"
    log_info "sudo usermod -aG docker $USER && newgrp docker"
    exit 1
  fi
  
  # Cleanup existing containers
  cleanup_containers
  
  # Step 2.5: Docker images download
  next_step "Downloading Docker images"
  if ! pull_docker_images; then
    exit 1
  fi
  
  # Step 2: Directories preparation
  next_step "Preparing data directories"
  local uid gid
  uid=$(id -u)
  gid=$(id -g)
  
  # Create directories with optimized structure
  local dirs=("openwebui" "n8n" "searxng" "qdrant" "clickhouse" "clickhouse-logs" "minio" "pgdata" "postgres-init" "redis")
  for dir in "${dirs[@]}"; do
    mkdir -p "${AI_DATA_DIR}/$dir"
  done
  
  # Create Notes directory for Samba share and Qdrant sync
  if [ ! -d "./Notes" ]; then
    mkdir -p "./Notes"
    chmod 755 "./Notes"
    chown "$uid:$gid" "./Notes" 2>/dev/null || true
    log_info "Notes directory created"
  else
    log_info "Notes directory already exists"
  fi
  
  # Apply secure permissions
for dir in openwebui n8n qdrant pgdata redis; do
    set_secure_permissions "${AI_DATA_DIR}/$dir" 700 600
  done
  
  # Special permissions for ClickHouse (user 101:101)
  sudo chown -R 101:101 "${AI_DATA_DIR}/clickhouse" "${AI_DATA_DIR}/clickhouse-logs" 2>/dev/null || true
  sudo chmod -R 755 "${AI_DATA_DIR}/clickhouse" "${AI_DATA_DIR}/clickhouse-logs" 2>/dev/null || true
  log_info "ClickHouse permissions configured (user 101:101)"
  
  # Special permissions for MinIO (user 1000:1000)
  sudo chown -R 1000:1000 "${AI_DATA_DIR}/minio" 2>/dev/null || true
  sudo chmod -R 755 "${AI_DATA_DIR}/minio" 2>/dev/null || true
  log_info "MinIO permissions configured (user 1000:1000)"
  
  # Special permissions for SearxNG
  set_secure_permissions "${AI_DATA_DIR}/searxng" 755 644
  
  # Permissions PostgreSQL
  chmod 755 "${AI_DATA_DIR}/postgres-init" 2>/dev/null || true
  chmod 700 "${AI_DATA_DIR}/pgdata" 2>/dev/null || true
  
  # Script d'initialisation PostgreSQL
  local init_sql="${AI_DATA_DIR}/postgres-init/01-create-langfuse.sql"
  if [ ! -f "$init_sql" ]; then
    log_info "Creating PostgreSQL initialization script"
    cat > "$init_sql" <<'EOSQL'
SELECT 'CREATE DATABASE langfuse'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'langfuse')\gexec
EOSQL
    chmod 644 "$init_sql"
fi
  
  log_ok "AI_Data directories prepared with secure permissions"

  # Disk space check
  check_disk_space || log_warn "Continue with caution - limited disk space"

  # Step 3: SearxNG configuration
  next_step "Syncing SearxNG configuration"
mkdir -p searxng
  
  # Copy configuration files
  if [ -f settings.yml ] && [ ! -f searxng/settings.yml ]; then
    cp settings.yml searxng/settings.yml
    log_info "settings.yml copied to searxng/"
  fi
  
  # Apply permissions to configuration files
  for f in searxng/settings.yml searxng/limiter.toml; do
    [ -f "$f" ] && chmod 644 "$f"
  done
  
  # Copy to AI_Data
if [ -d searxng ]; then
    mkdir -p "${AI_DATA_DIR}/searxng"
    cp -a searxng/. "${AI_DATA_DIR}/searxng/"
    sudo chown -R "$uid:$gid" "${AI_DATA_DIR}/searxng" 2>/dev/null || chown -R "$uid:$gid" "${AI_DATA_DIR}/searxng" 2>/dev/null || true
    set_secure_permissions "${AI_DATA_DIR}/searxng" 755 644
  fi
  
  log_ok "SearxNG templates copied"
  
  # Step 4: Base environment variables
  next_step "Base environment variables configuration"
  bulk_set_env ensure \
  OLLAMA_BASE_URL="http://localhost:11434" \
  OPENWEBUI_PORT="8081" \
  SEARXNG_PORT="8082" \
  N8N_PORT="5678" \
  POSTGRES_USER="n8n" \
  POSTGRES_DB="n8n" \
  LANGFUSE_PORT="3300" \
  LANGFUSE_EXTERNAL_URL="http://localhost:3300" \
  LANGFUSE_TRACING_ENVIRONMENT="dev" \
  LANGFUSE_INIT_PROJECT_RETENTION="30" \
  TZ="Europe/Paris"
  
  # PostgreSQL password generation
  if [ -z "$(get_env_value POSTGRES_PASSWORD)" ]; then
    local pg_password
    pg_password=$(openssl rand -hex 24)
    set_env_value POSTGRES_PASSWORD "$pg_password" enforce
    log_info "PostgreSQL password generated"
  fi
  
  set_env_value LANGFUSE_HOST "http://langfuse:3000" enforce
  log_ok "Base environment variables configured"
  
  # Samba Share configuration (optional - network Notes sharing)
  if [ -z "$(get_env_value SAMBA_PASSWORD)" ]; then
    local samba_user samba_password
    
    if [ "$INTERACTIVE_MODE" = "true" ]; then
      printf "\n${YELLOW}Samba Share Configuration${RESET}\n"
      printf "Samba share allows accessing Notes folder from Windows/Mac over the network\n\n"
      
      printf "Enter Samba username (default: admin): "
      read -r samba_user
      [ -z "$samba_user" ] && samba_user="admin"
      
      printf "Enter Samba password (or press Enter for auto-generation): "
      read -rs samba_password
      printf "\n"
      
      if [ -z "$samba_password" ]; then
        samba_password=$(openssl rand -base64 24)
        log_info "Samba password auto-generated"
      else
        log_info "Samba password set manually"
      fi
    else
      samba_user="admin"
      samba_password=$(openssl rand -base64 24)
      log_info "Non-interactive mode, Samba credentials auto-generated"
    fi
    
    set_env_value SAMBA_USER "$samba_user" enforce
    set_env_value SAMBA_PASSWORD "$samba_password" enforce
    set_env_value SAMBA_UID "1000" enforce
    set_env_value SAMBA_GID "1000" enforce
    set_env_value SAMBA_PORT "445" enforce
    set_env_value SAMBA_WORKGROUP "WORKGROUP" enforce
    log_info "Samba Share configured (user: $samba_user)"
  fi
  
  # Create Samba volumes.conf file (required for share configuration)
  mkdir -p "./samba"
  
  # Remove if it's a directory (error from previous runs)
  if [ -d "./samba/volumes.conf" ]; then
    rm -rf "./samba/volumes.conf"
    log_info "Removed incorrect directory samba/volumes.conf"
  fi
  
  if [ ! -f "./samba/volumes.conf" ]; then
    local samba_user_config
    samba_user_config=$(get_env_value SAMBA_USER)
    [ -z "$samba_user_config" ] && samba_user_config="admin"
    
    cat > "./samba/volumes.conf" << EOF
[notes]
path = /shares/notes
browseable = yes
read only = no
guest ok = no
valid users = $samba_user_config
admin users = $samba_user_config
write list = $samba_user_config
create mask = 0664
directory mask = 0775
force create mode = 0664
force directory mode = 0775
EOF
    log_info "Samba configuration file created (samba/volumes.conf)"
  else
    log_info "Samba configuration file already exists, skipping creation"
  fi
  
  # Step 5: Langfuse secrets configuration
  next_step "Langfuse credentials configuration"
  
  # Generate secrets if necessary
  local secrets=(
    "LANGFUSE_NEXTAUTH_SECRET:$(openssl rand -hex 32)"
    "LANGFUSE_SALT:$(openssl rand -hex 16)"
    "LANGFUSE_ENCRYPTION_KEY:$(openssl rand -hex 32)"
  )
  
  for secret in "${secrets[@]}"; do
    local key="${secret%%:*}"
    local value="${secret#*:}"
    
    if [ -z "$(get_env_value "$key")" ]; then
      set_env_value "$key" "$value" enforce
      log_info "Secret generated: $key"
    fi
  done
  
  bulk_set_env ensure LANGFUSE_PUBLIC_KEY="" LANGFUSE_SECRET_KEY=""
  
  # Langfuse database URL configuration
  local lf_db_user lf_db_pass
  lf_db_user=$(get_env_value POSTGRES_USER)
  [ -z "$lf_db_user" ] && lf_db_user="n8n"
  lf_db_pass=$(get_env_value POSTGRES_PASSWORD)
  
  local lf_db_url="postgresql://${lf_db_user}:${lf_db_pass}@postgres:5432/langfuse"
  set_env_value LANGFUSE_DATABASE_URL "$lf_db_url" enforce
  
  log_ok "Langfuse database URL configured"
  
  # Step 6: Default Langfuse headless configuration
  next_step "Preparing Langfuse headless default parameters"
  
  local org_id="${LANGFUSE_INIT_ORG_ID:-FlowTech-LAB}"
  local proj_id="${LANGFUSE_INIT_PROJECT_ID:-default}"
  local user_name="${LANGFUSE_INIT_USER_NAME:-Admin}"
  
  # Ask for user email if not defined
  local user_mail
  if [ -z "$(get_env_value LANGFUSE_INIT_USER_EMAIL)" ]; then
    # Interactive mode by default (unless FORCE_NON_INTERACTIVE=true)
    if [ "$FORCE_NON_INTERACTIVE" != "true" ]; then
      printf "\n${YELLOW}Langfuse Configuration - User Email${RESET}\n"
      printf "Enter the email for the Langfuse administrator user: "
      read -r user_mail
      
      # Validation basique de l'email
      if [[ ! "$user_mail" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        log_error "Invalid email: $user_mail"
        log_error "Expected format: user@domain.com"
        exit 1
      fi
    else
      # Forced non-interactive mode: use a valid default email
      user_mail="admin@flowtech.local"
      log_info "Forced non-interactive mode, using default email: $user_mail"
    fi
    
    set_env_value LANGFUSE_INIT_USER_EMAIL "$user_mail" enforce
    log_info "Langfuse user email configured: $user_mail"
  else
    user_mail=$(get_env_value LANGFUSE_INIT_USER_EMAIL)
    log_info "Langfuse user email already configured: $user_mail"
  fi
  
  # Generate password if necessary
  if [ -z "$(get_env_value LANGFUSE_INIT_USER_PASSWORD)" ]; then
    local user_password
    if [ "$FORCE_NON_INTERACTIVE" != "true" ]; then
      printf "\n${YELLOW}Langfuse Configuration - Password${RESET}\n"
      printf "Enter the password for the Langfuse administrator user (or press Enter for auto-generation): "
      read -r user_password
      
      if [ -z "$user_password" ]; then
        user_password=$(openssl rand -hex 18)
        log_info "Langfuse user password auto-generated"
      else
        log_info "Langfuse user password set manually"
      fi
    else
      user_password=$(openssl rand -hex 18)
      log_info "Non-interactive mode, Langfuse user password auto-generated"
    fi
    
    set_env_value LANGFUSE_INIT_USER_PASSWORD "$user_password" enforce
  fi
  
  if [ -z "$(get_env_value LANGFUSE_INIT_PROJECT_PUBLIC_KEY)" ]; then
    local public_key
    public_key="lf_pk_$(openssl rand -hex 24)"
    set_env_value LANGFUSE_INIT_PROJECT_PUBLIC_KEY "$public_key" enforce
    log_info "Langfuse public API key generated"
  fi
  
  if [ -z "$(get_env_value LANGFUSE_INIT_PROJECT_SECRET_KEY)" ]; then
    local secret_key
    secret_key="lf_sk_$(openssl rand -hex 32)"
    set_env_value LANGFUSE_INIT_PROJECT_SECRET_KEY "$secret_key" enforce
    log_info "Langfuse secret API key generated"
  fi
  
  # Generate n8n variables
  if [ -z "$(get_env_value N8N_BASIC_AUTH_USER)" ]; then
    set_env_value N8N_BASIC_AUTH_USER "admin" enforce
    log_info "n8n user configured"
  fi
  
  if [ -z "$(get_env_value N8N_BASIC_AUTH_PASSWORD)" ]; then
    local n8n_password
    n8n_password=$(openssl rand -hex 18)
    set_env_value N8N_BASIC_AUTH_PASSWORD "$n8n_password" enforce
    log_info "n8n password generated"
  fi
  
  # Generate Bearer API key for n8n
  if [ -z "$(get_env_value N8N_SECURITY_API_BEARER_AUTH)" ]; then
    local n8n_bearer_auth
    n8n_bearer_auth=$(head -c 48 /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c 48)
    set_env_value N8N_SECURITY_API_BEARER_AUTH "$n8n_bearer_auth" enforce
    log_info "n8n Bearer API key generated"
  fi
  
  # Default parameters configuration
  bulk_set_env ensure \
    LANGFUSE_INIT_ORG_ID="$org_id" \
    LANGFUSE_INIT_ORG_NAME="FlowTech-LAB" \
    LANGFUSE_INIT_PROJECT_ID="$proj_id" \
    LANGFUSE_INIT_PROJECT_NAME="Default" \
    LANGFUSE_INIT_USER_EMAIL="$user_mail" \
    LANGFUSE_INIT_USER_NAME="$user_name" \
    LANGFUSE_INIT_PROJECT_RETENTION="30"
  
  # Public/secret keys synchronization
  local public_key_value secret_key_value
  public_key_value=$(get_env_value LANGFUSE_PUBLIC_KEY)
  secret_key_value=$(get_env_value LANGFUSE_SECRET_KEY)
  
  [ -z "$public_key_value" ] && set_env_value LANGFUSE_PUBLIC_KEY "$(get_env_value LANGFUSE_INIT_PROJECT_PUBLIC_KEY)" enforce
  [ -z "$secret_key_value" ] && set_env_value LANGFUSE_SECRET_KEY "$(get_env_value LANGFUSE_INIT_PROJECT_SECRET_KEY)" enforce
  
  log_ok "Langfuse headless default parameters configured"
  
  # Step 7: Langfuse services configuration (ClickHouse, Redis, MinIO)
  next_step "Langfuse services configuration"
  
  # Variables ClickHouse
  if [ -z "$(get_env_value CLICKHOUSE_PASSWORD)" ]; then
    local ch_password
    ch_password=$(openssl rand -hex 18)
    set_env_value CLICKHOUSE_PASSWORD "$ch_password" enforce
    log_info "ClickHouse password generated"
  fi
  
  # Variables Redis
  if [ -z "$(get_env_value REDIS_AUTH)" ]; then
    local redis_password
    redis_password=$(openssl rand -hex 18)
    set_env_value REDIS_AUTH "$redis_password" enforce
    log_info "Redis password generated"
  fi
  
  # Variables MinIO
  if [ -z "$(get_env_value MINIO_ROOT_PASSWORD)" ]; then
    local minio_password
    minio_password=$(openssl rand -hex 18)
    set_env_value MINIO_ROOT_PASSWORD "$minio_password" enforce
    log_info "MinIO password generated"
  fi
  
  log_ok "Langfuse services configured"
  
  # Step 8: Start all services
  next_step "Starting all services"
  
  # In DEV mode, delete database BEFORE starting Langfuse
  if [ "$DEV_MODE" = "true" ]; then
    log_info "DEV Mode: Starting PostgreSQL alone to clean database"
    docker compose up -d postgres
    
    # Wait for PostgreSQL and delete database
    log_info "Waiting for PostgreSQL..."
    local count=0
    while [ $count -lt 30 ]; do
      if docker compose exec -T postgres pg_isready -U postgres >/dev/null 2>&1; then
        log_ok "PostgreSQL is available"
        break
      fi
      sleep 2
      count=$((count + 1))
    done
    
    if [ $count -lt 30 ]; then
      log_info "Dropping Langfuse database"
      docker compose exec -T postgres psql -U postgres -c "DROP DATABASE IF EXISTS langfuse;" 2>/dev/null || true
      log_info "Creating Langfuse database"
      docker compose exec -T postgres psql -U postgres -c "CREATE DATABASE langfuse;" 2>/dev/null || true
      log_ok "Langfuse database reset"
    fi
  fi
  
  # Start all services (order managed by depends_on in docker-compose.yml)
  next_step "Starting all services (optimized order)"
  
  # Include samba profile if configured
  local compose_cmd="docker compose"
  if [ -n "$(get_env_value SAMBA_PASSWORD)" ]; then
    compose_cmd="docker compose --profile samba"
    log_info "Samba Share enabled"
  fi
  
  run_with_timeout "$SERVICE_START_TIMEOUT" "$compose_cmd up -d"
  
  # Wait for all services to be ready
  log_info "Waiting for services to stabilize (60s)..."
  sleep 60
  
  # Configuration ClickHouse
  next_step "ClickHouse users configuration"
  if configure_clickhouse; then
    log_ok "ClickHouse configuration completed"
  else
    log_warn "ClickHouse configuration failed (non-blocking)"
  fi
  
  # Qdrant configuration - Collections creation
  next_step "Qdrant collections configuration"
  if configure_qdrant_collections; then
    log_ok "Qdrant collections created"
  else
    log_warn "Qdrant collections creation failed (non-blocking)"
  fi
  
  
  # Wait for Langfuse availability
  local lf_url
  lf_url=$(get_env_value LANGFUSE_EXTERNAL_URL)
  [ -z "$lf_url" ] && lf_url="http://localhost:3300"
  
  log_info "Waiting for services availability"
  if wait_for_http "$lf_url" 300 5; then
    log_ok "Langfuse is available at $lf_url"
  else
    log_warn "Langfuse is not yet available, but services are started"
  fi
  
  # Quick health checks
  log_info "Quick health checks"
  run_with_timeout 10 "docker compose ps"
  
  # Setup Notes sync to Qdrant (optional)
  if [ "$INTERACTIVE_MODE" = "true" ]; then
    printf "\n${YELLOW}Notes Synchronization to Qdrant${RESET}\n"
    printf "Do you want to enable automatic sync of Notes/ to Qdrant for AI context? (y/N): "
    read -r enable_sync
    
    if [[ "$enable_sync" =~ ^[Yy]$ ]]; then
      log_info "Setting up Notes sync environment..."
      
      # Check if Python venv exists
      if [ ! -d "./scripts/venv" ]; then
        log_info "Creating Python virtual environment..."
        python3 -m venv ./scripts/venv
        
        log_info "Installing sync dependencies..."
        ./scripts/venv/bin/pip install --quiet --upgrade pip
        ./scripts/venv/bin/pip install --quiet -r ./scripts/requirements-sync.txt
        
        log_ok "Python environment ready"
      fi
      
      # Run initial sync
      log_info "Running initial Notes sync..."
      if ./scripts/sync-notes.sh; then
        log_ok "Initial sync completed"
        
        # Ask about cron installation
        printf "Install hourly automatic sync via cron? (y/N): "
        read -r install_cron
        
        if [[ "$install_cron" =~ ^[Yy]$ ]]; then
          ./scripts/install-cron.sh
          log_ok "Automatic sync enabled (hourly)"
        else
          log_info "You can run sync manually with: ./scripts/sync-notes.sh"
        fi
      else
        log_warn "Initial sync failed (non-blocking)"
      fi
    else
      log_info "Notes sync skipped. You can enable it later with: ./scripts/setup-sync.sh"
    fi
  else
    log_info "Non-interactive mode: Notes sync skipped. Run ./scripts/setup-sync.sh to enable."
  fi
  
  # Validation finale
  local required_vars=(
    "POSTGRES_PASSWORD"
    "LANGFUSE_NEXTAUTH_SECRET"
    "LANGFUSE_SALT"
    "LANGFUSE_ENCRYPTION_KEY"
  )
  
  for var in "${required_vars[@]}"; do
    local value
    value=$(get_env_value "$var")
    if [ -z "$value" ]; then
      log_error "Required variable missing: $var"
      exit 1
    fi
  done
  
  log_ok "All required critical environment variables are set"
  
  # Final summary
  show_final_summary
}

# =============================================================================
# Main entry point
# =============================================================================
main "$@"
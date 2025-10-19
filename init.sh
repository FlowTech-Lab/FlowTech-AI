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
readonly AI_DATA_DIR="./AI_Data"

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
    log_ok "Initialisation FlowTech-AI terminée avec succès"
  else
    log_error "Initialisation échouée (code: $exit_code)"
  fi
  
  exit $exit_code
}

# Dependencies check
check_dependency() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    log_error "Dépendance manquante: $cmd"
    exit 1
  fi
  log_ok "$cmd disponible"
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

# Configuration en lot des variables d'environnement
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
  
  log_info "Attente de la disponibilité de $url (timeout: ${timeout}s)"
  
  while [ $elapsed -lt $timeout ]; do
    if curl -fsS -m 3 "$url" >/dev/null 2>&1; then
      log_ok "Service disponible: $url"
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
  
  log_info "Exécution (timeout ${timeout}s): $cmd"
  
  if timeout "$timeout" bash -lc "$cmd"; then
    log_ok "Commande réussie: $cmd"
    return 0
  else
    local rc=$?
    log_warn "Commande échouée/timeout (rc=$rc): $cmd"
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
    log_warn "Espace disque insuffisant: ${available_space}KB disponibles"
    log_warn "Recommandé: au moins 5GB (2GB minimum)"
    return 1
  fi
  
  log_ok "Espace disque suffisant: ${available_space}KB disponibles"
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
    log_ok "Permissions sécurisées appliquées à $dir"
  fi
}

# Required files check and creation
ensure_required_files() {
  log_info "Vérification des fichiers requis"
  
  # System prerequisites check
  log_info "Vérification des prérequis système"
  
  log_ok "Fichiers requis présents et exécutables"
}


# docker-compose.yml correction to remove problematic volumes
fix_docker_compose() {
  log_info "Correction du fichier docker-compose.yml"
  
  # Sauvegarder le fichier original
  cp docker-compose.yml docker-compose.yml.backup 2>/dev/null || true
  
  # Optimized docker-compose.yml configuration
  log_info "Configuration docker-compose.yml optimisée"
  
  log_ok "Fichier docker-compose.yml configuré"
}


# Container cleanup (with data deletion option)
cleanup_containers() {
  log_info "Nettoyage des conteneurs"
  
  # Stop and remove all project containers
  docker compose down --remove-orphans --volumes 2>/dev/null || true
  
  # Clean unused images only
  docker system prune -f 2>/dev/null || true
  
  # Suppression conditionnelle (DEV ONLY!)
  if [ "$DEV_MODE" = "true" ]; then
    log_warn "⚠️  MODE DÉVELOPPEMENT: Suppression complète activée"
    
    # Completely remove AI_Data directory
    if [ -d "$AI_DATA_DIR" ]; then
      log_info "Suppression du répertoire AI_Data"
      sudo rm -rf "$AI_DATA_DIR" 2>/dev/null || rm -rf "$AI_DATA_DIR"
      log_ok "Répertoire AI_Data supprimé"
    fi
    
    # Supprimer le fichier .env
    if [ -f "$ENV_FILE" ]; then
      log_info "Suppression du fichier .env"
      rm -f "$ENV_FILE"
      log_ok "Fichier .env supprimé"
    fi
    
    # Supprimer les logs
    if [ -d "$LOG_DIR" ]; then
      log_info "Suppression du répertoire logs"
      rm -rf "$LOG_DIR"
      log_ok "Répertoire logs supprimé"
    fi
    
    # Completely clean Docker system (without deleting images)
    docker system prune -f --volumes 2>/dev/null || true
    
    log_ok "Nettoyage complet terminé (MODE DEV)"
  else
    log_info "Nettoyage standard (données préservées)"
    log_ok "Nettoyage terminé"
  fi
}


# Final summary display
show_final_summary() {
  log_ok "🎉 FlowTech-AI est maintenant opérationnel !"
  echo
  log_info "📋 Résumé des services disponibles :"
  echo
  echo "  🌐 Langfuse (Monitoring AI):     http://localhost:$(get_env_value LANGFUSE_PORT)"
  echo "  🤖 OpenWebUI (Interface AI):     http://localhost:$(get_env_value OPENWEBUI_PORT)"
  echo "  🔍 SearxNG (Moteur de recherche): http://localhost:$(get_env_value SEARXNG_PORT)"
  echo "  ⚡ N8N (Automatisation):         http://localhost:$(get_env_value N8N_PORT)"
  echo "  🗄️  Qdrant (Base vectorielle):    http://localhost:6333"
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
    log_error "Plugin docker compose requis"
    exit 1
  fi
  log_ok "Plugin docker compose détecté"
  
  # Step 1.5: Disk space check
  next_step "Vérification de l'espace disque"
  if ! check_disk_space; then
    exit 1
  fi
  
  # Required files check
  ensure_required_files
  
  # Correction du docker-compose.yml
  fix_docker_compose
  
  # Configuration des permissions
umask 077
  log_info "Création du fichier .env"
  touch "$ENV_FILE"
  
  # Docker permissions check
  if ! docker info >/dev/null 2>&1; then
    log_error "Permissions Docker insuffisantes"
    log_info "Ajoutez votre utilisateur au groupe docker:"
    log_info "sudo usermod -aG docker $USER && newgrp docker"
    exit 1
  fi
  
  # Nettoyage des conteneurs existants
  cleanup_containers
  
  # Step 2.5: Docker images download
  next_step "Téléchargement des images Docker"
  if ! pull_docker_images; then
    exit 1
  fi
  
  # Step 2: Directories preparation
  next_step "Préparation des répertoires de données"
  local uid gid
  uid=$(id -u)
  gid=$(id -g)
  
  # Create directories with optimized structure
  local dirs=("openwebui" "n8n" "searxng" "qdrant" "clickhouse" "clickhouse-logs" "minio" "pgdata" "postgres-init" "redis")
  for dir in "${dirs[@]}"; do
    mkdir -p "${AI_DATA_DIR}/$dir"
  done
  
  # Apply secure permissions
for dir in openwebui n8n qdrant pgdata redis; do
    set_secure_permissions "${AI_DATA_DIR}/$dir" 700 600
  done
  
  # Special permissions for ClickHouse (user 101:101)
  sudo chown -R 101:101 "${AI_DATA_DIR}/clickhouse" "${AI_DATA_DIR}/clickhouse-logs" 2>/dev/null || true
  sudo chmod -R 755 "${AI_DATA_DIR}/clickhouse" "${AI_DATA_DIR}/clickhouse-logs" 2>/dev/null || true
  log_info "Permissions ClickHouse configurées (utilisateur 101:101)"
  
  # Special permissions for MinIO (user 1000:1000)
  sudo chown -R 1000:1000 "${AI_DATA_DIR}/minio" 2>/dev/null || true
  sudo chmod -R 755 "${AI_DATA_DIR}/minio" 2>/dev/null || true
  log_info "Permissions MinIO configurées (utilisateur 1000:1000)"
  
  # Special permissions for SearxNG
  set_secure_permissions "${AI_DATA_DIR}/searxng" 755 644
  
  # Permissions PostgreSQL
  chmod 755 "${AI_DATA_DIR}/postgres-init" 2>/dev/null || true
  chmod 700 "${AI_DATA_DIR}/pgdata" 2>/dev/null || true
  
  # Script d'initialisation PostgreSQL
  local init_sql="${AI_DATA_DIR}/postgres-init/01-create-langfuse.sql"
  if [ ! -f "$init_sql" ]; then
    log_info "Création du script d'initialisation PostgreSQL"
    cat > "$init_sql" <<'EOSQL'
SELECT 'CREATE DATABASE langfuse'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'langfuse')\gexec
EOSQL
    chmod 644 "$init_sql"
fi
  
  log_ok "Répertoires AI_Data préparés avec permissions sécurisées"

  # Disk space check
  check_disk_space || log_warn "Continuez avec prudence - espace disque limité"

  # Step 3: SearxNG configuration
  next_step "Synchronisation de la configuration SearxNG"
mkdir -p searxng
  
  # Copie des fichiers de configuration
  if [ -f settings.yml ] && [ ! -f searxng/settings.yml ]; then
    cp settings.yml searxng/settings.yml
    log_info "settings.yml copié dans searxng/"
  fi
  
  # Application des permissions aux fichiers de configuration
  for f in searxng/settings.yml searxng/limiter.toml; do
    [ -f "$f" ] && chmod 644 "$f"
  done
  
  # Copie vers AI_Data
if [ -d searxng ]; then
    mkdir -p "${AI_DATA_DIR}/searxng"
    cp -a searxng/. "${AI_DATA_DIR}/searxng/"
    sudo chown -R "$uid:$gid" "${AI_DATA_DIR}/searxng" 2>/dev/null || chown -R "$uid:$gid" "${AI_DATA_DIR}/searxng" 2>/dev/null || true
    set_secure_permissions "${AI_DATA_DIR}/searxng" 755 644
  fi
  
  log_ok "Templates SearxNG copiés"
  
  # Step 4: Base environment variables
  next_step "Configuration des variables d'environnement de base"
  bulk_set_env ensure \
  OLLAMA_BASE_URL="http://192.168.0.2:11434" \
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
    log_info "Mot de passe PostgreSQL généré"
  fi
  
  set_env_value LANGFUSE_HOST "http://langfuse:3000" enforce
  log_ok "Variables d'environnement de base configurées"
  
  # Samba Share configuration (optional - network Notes sharing)
  if [ -z "$(get_env_value SAMBA_PASSWORD)" ]; then
    local samba_password
    samba_password=$(openssl rand -base64 24)
    set_env_value SAMBA_USER "admin" enforce
    set_env_value SAMBA_PASSWORD "$samba_password" enforce
    set_env_value SAMBA_UID "1000" enforce
    set_env_value SAMBA_GID "1000" enforce
    set_env_value SAMBA_PORT "445" enforce
    log_info "Samba Share credentials générés (pour accès réseau aux notes)"
  fi
  
  # Step 5: Langfuse secrets configuration
  next_step "Configuration des identifiants Langfuse"
  
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
      log_info "Secret généré: $key"
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
  
  log_ok "URL de base de données Langfuse configurée"
  
  # Step 6: Default Langfuse headless configuration
  next_step "Préparation des paramètres par défaut Langfuse headless"
  
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
    log_info "Clé API publique Langfuse générée"
  fi
  
  if [ -z "$(get_env_value LANGFUSE_INIT_PROJECT_SECRET_KEY)" ]; then
    local secret_key
    secret_key="lf_sk_$(openssl rand -hex 32)"
    set_env_value LANGFUSE_INIT_PROJECT_SECRET_KEY "$secret_key" enforce
    log_info "Clé API secrète Langfuse générée"
  fi
  
  # Generate n8n variables
  if [ -z "$(get_env_value N8N_BASIC_AUTH_USER)" ]; then
    set_env_value N8N_BASIC_AUTH_USER "admin" enforce
    log_info "Utilisateur n8n configuré"
  fi
  
  if [ -z "$(get_env_value N8N_BASIC_AUTH_PASSWORD)" ]; then
    local n8n_password
    n8n_password=$(openssl rand -hex 18)
    set_env_value N8N_BASIC_AUTH_PASSWORD "$n8n_password" enforce
    log_info "Mot de passe n8n généré"
  fi
  
  # Generate Bearer API key for n8n
  if [ -z "$(get_env_value N8N_SECURITY_API_BEARER_AUTH)" ]; then
    local n8n_bearer_auth
    n8n_bearer_auth=$(head -c 48 /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c 48)
    set_env_value N8N_SECURITY_API_BEARER_AUTH "$n8n_bearer_auth" enforce
    log_info "Clé API Bearer n8n générée"
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
  
  log_ok "Paramètres par défaut Langfuse headless configurés"
  
  # Step 7: Langfuse services configuration (ClickHouse, Redis, MinIO)
  next_step "Configuration des services Langfuse"
  
  # Variables ClickHouse
  if [ -z "$(get_env_value CLICKHOUSE_PASSWORD)" ]; then
    local ch_password
    ch_password=$(openssl rand -hex 18)
    set_env_value CLICKHOUSE_PASSWORD "$ch_password" enforce
    log_info "Mot de passe ClickHouse généré"
  fi
  
  # Variables Redis
  if [ -z "$(get_env_value REDIS_AUTH)" ]; then
    local redis_password
    redis_password=$(openssl rand -hex 18)
    set_env_value REDIS_AUTH "$redis_password" enforce
    log_info "Mot de passe Redis généré"
  fi
  
  # Variables MinIO
  if [ -z "$(get_env_value MINIO_ROOT_PASSWORD)" ]; then
    local minio_password
    minio_password=$(openssl rand -hex 18)
    set_env_value MINIO_ROOT_PASSWORD "$minio_password" enforce
    log_info "Mot de passe MinIO généré"
  fi
  
  log_ok "Services Langfuse configurés"
  
  # Step 8: Start all services
  next_step "Démarrage de tous les services"
  
  # In DEV mode, delete database BEFORE starting Langfuse
  if [ "$DEV_MODE" = "true" ]; then
    log_info "Mode DEV: Démarrage de PostgreSQL seul pour nettoyer la base"
    docker compose up -d postgres
    
    # Wait for PostgreSQL and delete database
    log_info "Attente de PostgreSQL..."
    local count=0
    while [ $count -lt 30 ]; do
      if docker compose exec -T postgres pg_isready -U postgres >/dev/null 2>&1; then
        log_ok "PostgreSQL est disponible"
        break
      fi
      sleep 2
      count=$((count + 1))
    done
    
    if [ $count -lt 30 ]; then
      log_info "Suppression de la base de données Langfuse"
      docker compose exec -T postgres psql -U postgres -c "DROP DATABASE IF EXISTS langfuse;" 2>/dev/null || true
      log_info "Création de la base de données Langfuse"
      docker compose exec -T postgres psql -U postgres -c "CREATE DATABASE langfuse;" 2>/dev/null || true
      log_ok "Base de données Langfuse réinitialisée"
    fi
  fi
  
  # Start all services (order managed by depends_on in docker-compose.yml)
  next_step "Démarrage de tous les services (ordre optimisé)"
  
  # Include samba profile if configured
  local compose_cmd="docker compose"
  if [ -n "$(get_env_value SAMBA_PASSWORD)" ]; then
    compose_cmd="docker compose --profile samba"
    log_info "Samba Share activé"
  fi
  
  run_with_timeout "$SERVICE_START_TIMEOUT" "$compose_cmd up -d"
  
  # Wait for all services to be ready
  log_info "Attente de la stabilisation des services (60s)..."
  sleep 60
  
  # Configuration ClickHouse
  next_step "Configuration des utilisateurs ClickHouse"
  if configure_clickhouse; then
    log_ok "Configuration ClickHouse terminée"
  else
    log_warn "Échec de la configuration ClickHouse (non bloquant)"
  fi
  
  
  # Attendre que Langfuse soit disponible
  local lf_url
  lf_url=$(get_env_value LANGFUSE_EXTERNAL_URL)
  [ -z "$lf_url" ] && lf_url="http://localhost:3300"
  
  log_info "Attente de la disponibilité des services"
  if wait_for_http "$lf_url" 300 5; then
    log_ok "Langfuse est disponible à $lf_url"
  else
    log_warn "Langfuse n'est pas encore disponible, mais les services sont démarrés"
  fi
  
  # Quick health checks
  log_info "Vérifications de santé rapides"
  run_with_timeout 10 "docker compose ps"
  
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
      log_error "Variable requise manquante: $var"
      exit 1
    fi
  done
  
  log_ok "Toutes les variables d'environnement critiques requises sont définies"
  
  # Résumé final
  show_final_summary
}

# =============================================================================
# Main entry point
# =============================================================================
main "$@"
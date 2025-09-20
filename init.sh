#!/bin/bash
set -euo pipefail

# =============================================================================
# FlowTech-AI Initialization Script - Optimized Version
# =============================================================================
# Script d'initialisation optimisé qui utilise les fichiers existants
# Suit les principes DRY, KISS, YAGNI et les conventions du projet
# =============================================================================

# ---- Configuration du logging ----
readonly LOG_DIR="logs"
readonly LOGFILE="${LOG_DIR}/init-$(date +%Y%m%d-%H%M%S).log"
readonly SCRIPT_START_TIME=$(date -Is)

# Création du répertoire de logs
mkdir -p "$LOG_DIR"

# Initialisation du logging complet
{
  echo "===== FlowTech-AI init $SCRIPT_START_TIME ====="
  echo "PWD: $(pwd)"
  echo "User: $(id -u):$(id -g)"
} >> "$LOGFILE"

# Redirection de la sortie vers le fichier de log
exec > >(stdbuf -oL tee -a "$LOGFILE") 2>&1

# Mode debug si activé
if [ "${INIT_DEBUG:-0}" = "1" ]; then
  exec 9>> "$LOGFILE"
  BASH_XTRACEFD=9
  set -x
fi

# Trap pour la sortie propre
trap 'handle_exit $?' EXIT

# =============================================================================
# Variables globales et constantes
# =============================================================================
readonly BOLD="\033[1m"
readonly RESET="\033[0m"
readonly GREEN="\033[32m"
readonly YELLOW="\033[33m"
readonly BLUE="\033[36m"
readonly RED="\033[31m"

readonly TOTAL_STEPS=10
readonly AI_DATA_DIR="./AI_Data"
readonly ENV_FILE=".env"
readonly MIN_FREE_SPACE_KB=2097152  # 2GB en KB

# =============================================================================
# OPTION DE DÉVELOPPEMENT - MODIFIER ICI POUR LE RESET COMPLET
# =============================================================================
readonly DEV_MODE=true  # true = supprime .env, AI_Data et logs (DEV ONLY!)
# =============================================================================

# =============================================================================
# CONFIGURATION DES TIMEOUTS
# =============================================================================
readonly DISK_CHECK_TIMEOUT=30
readonly DOCKER_PULL_TIMEOUT=600  # 10 minutes pour télécharger toutes les images
readonly SERVICE_START_TIMEOUT=120  # 2 minutes pour démarrer les services
readonly HEALTH_CHECK_TIMEOUT=180  # 3 minutes pour les health checks
# =============================================================================

# Compteur d'étapes
STEP=0

# =============================================================================
# Fonctions utilitaires optimisées
# =============================================================================

# Vérification de l'espace disque disponible
check_disk_space() {
  log_info "Vérification de l'espace disque disponible..."
  
  local available_space_kb
  available_space_kb=$(df . | awk 'NR==2 {print $4}')
  
  if [ "$available_space_kb" -lt "$MIN_FREE_SPACE_KB" ]; then
    log_error "Espace disque insuffisant !"
    log_error "Espace disponible: $((available_space_kb / 1024 / 1024))GB"
    log_error "Espace requis: $((MIN_FREE_SPACE_KB / 1024 / 1024))GB"
    log_error "Libérez de l'espace disque avant de continuer."
    return 1
  fi
  
  log_success "Espace disque OK: $((available_space_kb / 1024 / 1024))GB disponible"
  return 0
}

# Téléchargement des images Docker
pull_docker_images() {
  log_info "Téléchargement des images Docker (timeout: ${DOCKER_PULL_TIMEOUT}s)..."
  
  if run_with_timeout "$DOCKER_PULL_TIMEOUT" "docker compose pull"; then
    log_success "Images Docker téléchargées avec succès"
    return 0
  else
    log_error "Échec du téléchargement des images Docker"
    return 1
  fi
}

# Gestion de la sortie du script
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

# Vérification des dépendances
check_dependency() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    log_error "Dépendance manquante: $cmd"
    exit 1
  fi
  log_ok "$cmd disponible"
}

# Gestion des variables d'environnement optimisée
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

# Encodage URL optimisé

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

# Fonctions de logging colorées
log_info() { printf "${BLUE}[INFO ]${RESET} %s\n" "$*"; }
log_ok()   { printf "${GREEN}[ OK  ]${RESET} %s\n" "$*"; }
log_warn() { printf "${YELLOW}[WARN ]${RESET} %s\n" "$*"; }
log_error() { printf "${RED}[ERROR]${RESET} %s\n" "$*"; }

# Exécution de commandes avec timeout et logging
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

# Affichage des étapes
next_step() {
  STEP=$((STEP + 1))
  printf "\n${BOLD}>>> Étape %d/%d:${RESET} %s\n" "$STEP" "$TOTAL_STEPS" "$*"
}

# Vérification de l'espace disque
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

# Gestion des permissions optimisée
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

# Vérification et création des fichiers requis
ensure_required_files() {
  log_info "Vérification des fichiers requis"
  
  # Vérifier que les fichiers existent et sont exécutables
  if [ ! -f "wait-for-it.sh" ] || [ ! -x "wait-for-it.sh" ]; then
    log_error "Fichier wait-for-it.sh manquant ou non exécutable"
    log_info "Veuillez créer ce fichier avant de continuer"
    exit 1
  fi
  
  if [ ! -f "langfuse-entrypoint.sh" ] || [ ! -x "langfuse-entrypoint.sh" ]; then
    log_error "Fichier langfuse-entrypoint.sh manquant ou non exécutable"
    log_info "Veuillez créer ce fichier avant de continuer"
    exit 1
  fi
  
  log_ok "Fichiers requis présents et exécutables"
}


# Correction du docker-compose.yml pour supprimer les volumes problématiques
fix_docker_compose() {
  log_info "Correction du fichier docker-compose.yml"
  
  # Sauvegarder le fichier original
  cp docker-compose.yml docker-compose.yml.backup 2>/dev/null || true
  
  # Supprimer les volumes problématiques pour langfuse-web et langfuse-worker
  sed -i '/- \.\/wait-for-it.sh:\/wait-for-it.sh:ro/d' docker-compose.yml
  sed -i '/- \.\/langfuse-entrypoint.sh:\/langfuse-entrypoint.sh:ro/d' docker-compose.yml
  
  # Supprimer les entrypoints personnalisés
  sed -i '/entrypoint: \["\/langfuse-entrypoint.sh"\]/d' docker-compose.yml
  
  log_ok "Fichier docker-compose.yml corrigé (volumes et entrypoints supprimés)"
}


# Nettoyage des conteneurs (avec option de suppression des données)
cleanup_containers() {
  log_info "Nettoyage des conteneurs"
  
  # Arrêter et supprimer tous les conteneurs du projet
  docker compose down --remove-orphans --volumes 2>/dev/null || true
  
  # Nettoyer les images non utilisées seulement
  docker system prune -f 2>/dev/null || true
  
  # Suppression conditionnelle (DEV ONLY!)
  if [ "$DEV_MODE" = "true" ]; then
    log_warn "⚠️  MODE DÉVELOPPEMENT: Suppression complète activée"
    
    # Supprimer complètement le répertoire AI_Data
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
    
    # Nettoyer complètement le système Docker (sans supprimer les images)
    docker system prune -f --volumes 2>/dev/null || true
    
    log_ok "Nettoyage complet terminé (MODE DEV)"
  else
    log_info "Nettoyage standard (données préservées)"
    log_ok "Nettoyage terminé"
  fi
}


# Affichage du résumé final
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
  echo "  📊 ClickHouse (Analytics):       http://localhost:8123"
  echo
  log_info "🔑 Identifiants par défaut :"
  echo "  • Langfuse: admin@local / $(get_env_value LANGFUSE_INIT_USER_PASSWORD)"
  echo "  • N8N: Utilisez l'authentification de base configurée"
  echo
  log_info "📁 Fichiers importants :"
  echo "  • Configuration: .env"
  echo "  • Logs: $LOGFILE"
  echo "  • Données: ./AI_Data/"
  echo
  log_info "🛠️  Commandes utiles :"
  echo "  • Voir les logs: docker compose logs -f [service]"
  echo "  • Redémarrer: docker compose restart [service]"
  echo "  • Arrêter tout: docker compose down"
  echo "  • Voir l'état: docker compose ps"
  echo
}

# Affichage des options de développement
show_dev_options() {
  log_info "Mode développement activé:"
  echo "  DEV_MODE=true dans le script = Reset complet (.env, AI_Data, logs)"
  echo ""
}

# =============================================================================
# Fonction principale
# =============================================================================
main() {
  # Vérification des arguments d'aide
  if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    echo "FlowTech-AI Initialization Script"
    echo "Usage: $0 [options]"
    echo ""
    echo "Option de développement:"
    echo "  Modifier DEV_MODE=true dans le script pour reset complet"
    echo "  (supprime .env, AI_Data et logs)"
    echo ""
    exit 0
  fi
  
  log_info "Démarrage de l'initialisation FlowTech-AI"
  
  # Affichage du mode développement si activé
  if [ "$DEV_MODE" = "true" ]; then
    show_dev_options
  fi
  
  # Étape 1: Vérification des prérequis
  next_step "Validation des prérequis"
  check_dependency "openssl"
  check_dependency "curl"
  check_dependency "docker"
  
  if ! docker compose version >/dev/null 2>&1; then
    log_error "Plugin docker compose requis"
    exit 1
  fi
  log_ok "Plugin docker compose détecté"
  
  # Étape 1.5: Vérification de l'espace disque
  next_step "Vérification de l'espace disque"
  if ! check_disk_space; then
    exit 1
  fi
  
  # Vérification des fichiers requis
  ensure_required_files
  
  # Correction du docker-compose.yml
  fix_docker_compose
  
  # Configuration des permissions
umask 077
  log_info "Création du fichier .env"
  touch "$ENV_FILE"
  
  # Vérification des permissions Docker
  if ! docker info >/dev/null 2>&1; then
    log_error "Permissions Docker insuffisantes"
    log_info "Ajoutez votre utilisateur au groupe docker:"
    log_info "sudo usermod -aG docker $USER && newgrp docker"
    exit 1
  fi
  
  # Nettoyage des conteneurs existants
  cleanup_containers
  
  # Étape 2.5: Téléchargement des images Docker
  next_step "Téléchargement des images Docker"
  if ! pull_docker_images; then
    exit 1
  fi
  
  # Étape 2: Préparation des répertoires
  next_step "Préparation des répertoires de données"
  local uid gid
  uid=$(id -u)
  gid=$(id -g)
  
  # Création des répertoires avec structure optimisée
  local dirs=("openwebui" "n8n" "searxng" "qdrant" "clickhouse" "clickhouse-logs" "minio" "pgdata" "postgres-init")
  for dir in "${dirs[@]}"; do
    mkdir -p "${AI_DATA_DIR}/$dir"
  done
  
  # Application des permissions sécurisées
for dir in openwebui n8n qdrant pgdata; do
    set_secure_permissions "${AI_DATA_DIR}/$dir" 700 600
  done
  
  # Permissions spéciales pour ClickHouse (utilisateur 101:101)
  sudo chown -R 101:101 "${AI_DATA_DIR}/clickhouse" "${AI_DATA_DIR}/clickhouse-logs" 2>/dev/null || true
  sudo chmod -R 755 "${AI_DATA_DIR}/clickhouse" "${AI_DATA_DIR}/clickhouse-logs" 2>/dev/null || true
  log_info "Permissions ClickHouse configurées (utilisateur 101:101)"
  
  # Permissions spéciales pour MinIO (utilisateur 1000:1000)
  sudo chown -R 1000:1000 "${AI_DATA_DIR}/minio" 2>/dev/null || true
  sudo chmod -R 755 "${AI_DATA_DIR}/minio" 2>/dev/null || true
  log_info "Permissions MinIO configurées (utilisateur 1000:1000)"
  
  # Permissions spéciales pour SearxNG
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

  # Vérification de l'espace disque
  check_disk_space || log_warn "Continuez avec prudence - espace disque limité"

  # Étape 3: Configuration SearxNG
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
    chown -R "$uid:$gid" "${AI_DATA_DIR}/searxng" 2>/dev/null || true
    set_secure_permissions "${AI_DATA_DIR}/searxng" 755 644
  fi
  
  log_ok "Templates SearxNG copiés"
  
  # Étape 4: Variables d'environnement de base
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
  
  # Génération du mot de passe PostgreSQL
  if [ -z "$(get_env_value POSTGRES_PASSWORD)" ]; then
    local pg_password
    pg_password=$(openssl rand -hex 24)
    set_env_value POSTGRES_PASSWORD "$pg_password" enforce
    log_info "Mot de passe PostgreSQL généré"
  fi
  
  set_env_value LANGFUSE_HOST "http://langfuse:3000" enforce
  log_ok "Variables d'environnement de base configurées"
  
  # Étape 5: Configuration des secrets Langfuse
  next_step "Configuration des identifiants Langfuse"
  
  # Génération des secrets si nécessaire
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
  
  # Configuration de l'URL de base de données Langfuse
  local lf_db_user lf_db_pass
  lf_db_user=$(get_env_value POSTGRES_USER)
  [ -z "$lf_db_user" ] && lf_db_user="n8n"
  lf_db_pass=$(get_env_value POSTGRES_PASSWORD)
  
  local lf_db_url="postgresql://${lf_db_user}:${lf_db_pass}@postgres:5432/langfuse"
  set_env_value LANGFUSE_DATABASE_URL "$lf_db_url" enforce
  
  log_ok "URL de base de données Langfuse configurée"
  
  # Étape 6: Configuration par défaut Langfuse headless
  next_step "Préparation des paramètres par défaut Langfuse headless"
  
  local org_id="${LANGFUSE_INIT_ORG_ID:-FlowTech-LAB}"
  local proj_id="${LANGFUSE_INIT_PROJECT_ID:-default}"
  local user_mail="${LANGFUSE_INIT_USER_EMAIL:-admin@local}"
  local user_name="${LANGFUSE_INIT_USER_NAME:-Admin}"
  
  # Génération des clés API si nécessaire
  if [ -z "$(get_env_value LANGFUSE_INIT_USER_PASSWORD)" ]; then
    local user_password
    user_password=$(openssl rand -hex 18)
    set_env_value LANGFUSE_INIT_USER_PASSWORD "$user_password" enforce
    log_info "Mot de passe utilisateur Langfuse généré"
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
  
  # Configuration des paramètres par défaut
  bulk_set_env ensure \
    LANGFUSE_INIT_ORG_ID="$org_id" \
    LANGFUSE_INIT_ORG_NAME="FlowTech-LAB" \
    LANGFUSE_INIT_PROJECT_ID="$proj_id" \
    LANGFUSE_INIT_PROJECT_NAME="Default" \
    LANGFUSE_INIT_USER_EMAIL="$user_mail" \
    LANGFUSE_INIT_USER_NAME="$user_name" \
    LANGFUSE_INIT_PROJECT_RETENTION="30"
  
  # Synchronisation des clés publiques/secrètes
  local public_key_value secret_key_value
  public_key_value=$(get_env_value LANGFUSE_PUBLIC_KEY)
  secret_key_value=$(get_env_value LANGFUSE_SECRET_KEY)
  
  [ -z "$public_key_value" ] && set_env_value LANGFUSE_PUBLIC_KEY "$(get_env_value LANGFUSE_INIT_PROJECT_PUBLIC_KEY)" enforce
  [ -z "$secret_key_value" ] && set_env_value LANGFUSE_SECRET_KEY "$(get_env_value LANGFUSE_INIT_PROJECT_SECRET_KEY)" enforce
  
  log_ok "Paramètres par défaut Langfuse headless configurés"
  
  # Étape 7: Configuration des services Langfuse (ClickHouse, Redis, MinIO)
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
  
  # Étape 8: Démarrage de tous les services
  next_step "Démarrage de tous les services"
  
  # En mode DEV, supprimer la base de données AVANT de démarrer Langfuse
  if [ "$DEV_MODE" = "true" ]; then
    log_info "Mode DEV: Démarrage de PostgreSQL seul pour nettoyer la base"
    docker compose up -d postgres
    
    # Attendre PostgreSQL et supprimer la base de données
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
  
  # Démarrage de tous les services (ordre géré par depends_on dans docker-compose.yml)
  next_step "Démarrage de tous les services (ordre optimisé)"
  run_with_timeout "$SERVICE_START_TIMEOUT" "docker compose up -d"
  
  # Attendre que tous les services soient prêts
  log_info "Attente de la stabilisation des services (60s)..."
  sleep 60
  
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
  
  # Vérifications de santé rapides
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
# Point d'entrée principal
# =============================================================================
main "$@"
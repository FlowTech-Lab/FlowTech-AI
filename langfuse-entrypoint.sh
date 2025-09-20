#!/bin/bash
set -euo pipefail

# =============================================================================
# Langfuse Entrypoint Script
# =============================================================================
# Script d'entrée pour les conteneurs Langfuse (web et worker)
# Gère l'attente des dépendances et le démarrage approprié
# =============================================================================

# Configuration des couleurs pour les logs
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Fonctions de logging
log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_ok() { echo -e "${GREEN}[OK]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

# Fonction d'attente pour les services
wait_for_service() {
    local host="$1"
    local port="$2"
    local service_name="$3"
    local timeout="${4:-60}"
    
    log_info "Attente de $service_name sur $host:$port (timeout: ${timeout}s)"
    
    if [ -f "/wait-for-it.sh" ]; then
        /wait-for-it.sh "$host:$port" -t "$timeout" -- echo "$service_name est disponible"
    else
        # Fallback si wait-for-it.sh n'est pas disponible
        local count=0
        while [ $count -lt $timeout ]; do
            if nc -z "$host" "$port" 2>/dev/null; then
                log_ok "$service_name est disponible"
                return 0
            fi
            sleep 1
            count=$((count + 1))
        done
        log_error "Timeout: $service_name n'est pas disponible après ${timeout}s"
        return 1
    fi
}

# Fonction pour exécuter les migrations de base de données
run_migrations() {
    log_info "Exécution des migrations de base de données"
    
    if [ -n "${DATABASE_URL:-}" ]; then
        # Attendre que PostgreSQL soit disponible
        wait_for_service "postgres" "5432" "PostgreSQL" 120
        
        # Exécuter les migrations
        if npx prisma migrate deploy; then
            log_ok "Migrations de base de données terminées"
        else
            log_error "Échec des migrations de base de données"
            return 1
        fi
    else
        log_warn "DATABASE_URL non définie, migrations ignorées"
    fi
}

# Fonction pour exécuter les migrations ClickHouse
run_clickhouse_migrations() {
    log_info "Exécution des migrations ClickHouse"
    
    if [ -n "${CLICKHOUSE_URL:-}" ]; then
        # Attendre que ClickHouse soit disponible
        wait_for_service "clickhouse" "8123" "ClickHouse" 120
        
        # Exécuter les migrations ClickHouse
        if npx prisma migrate clickhouse; then
            log_ok "Migrations ClickHouse terminées"
        else
            log_error "Échec des migrations ClickHouse"
            return 1
        fi
    else
        log_warn "CLICKHOUSE_URL non définie, migrations ClickHouse ignorées"
    fi
}

# Fonction pour initialiser Langfuse en mode headless
init_langfuse_headless() {
    log_info "Initialisation de Langfuse en mode headless"
    
    # Vérifier que toutes les variables requises sont présentes
    local required_vars=(
        "LANGFUSE_INIT_ORG_ID"
        "LANGFUSE_INIT_PROJECT_ID"
        "LANGFUSE_INIT_USER_EMAIL"
        "LANGFUSE_INIT_USER_PASSWORD"
        "LANGFUSE_INIT_PROJECT_PUBLIC_KEY"
        "LANGFUSE_INIT_PROJECT_SECRET_KEY"
    )
    
    for var in "${required_vars[@]}"; do
        if [ -z "${!var:-}" ]; then
            log_warn "Variable $var non définie, initialisation headless ignorée"
            return 0
        fi
    done
    
    # Exécuter l'initialisation headless
    if npx langfuse init; then
        log_ok "Initialisation headless de Langfuse terminée"
    else
        log_warn "Échec de l'initialisation headless (peut-être déjà initialisé)"
    fi
}

# Fonction principale pour langfuse-web
start_langfuse_web() {
    log_info "Démarrage de Langfuse Web"
    
    # Exécuter les migrations
    run_migrations
    run_clickhouse_migrations
    
    # Initialisation headless si configurée
    init_langfuse_headless
    
    # Démarrer le serveur web
    log_info "Démarrage du serveur web Langfuse"
    exec npm run start
}

# Fonction principale pour langfuse-worker
start_langfuse_worker() {
    log_info "Démarrage de Langfuse Worker"
    
    # Attendre que les bases de données soient disponibles
    wait_for_service "postgres" "5432" "PostgreSQL" 120
    wait_for_service "clickhouse" "8123" "ClickHouse" 120
    
    # Démarrer le worker
    log_info "Démarrage du worker Langfuse"
    exec npm run worker
}

# =============================================================================
# Point d'entrée principal
# =============================================================================

main() {
    log_info "Démarrage du conteneur Langfuse"
    log_info "Variables d'environnement:"
    log_info "  - DATABASE_URL: ${DATABASE_URL:-non définie}"
    log_info "  - CLICKHOUSE_URL: ${CLICKHOUSE_URL:-non définie}"
    log_info "  - NEXTAUTH_URL: ${NEXTAUTH_URL:-non définie}"
    
    # Déterminer le type de conteneur basé sur le nom ou les arguments
    local container_type="web"
    
    # Vérifier si c'est un worker basé sur le nom du conteneur ou des arguments
    if [[ "${HOSTNAME:-}" == *"worker"* ]] || [[ "${1:-}" == "worker" ]]; then
        container_type="worker"
    fi
    
    log_info "Type de conteneur détecté: $container_type"
    
    case "$container_type" in
        "worker")
            start_langfuse_worker
            ;;
        "web"|*)
            start_langfuse_web
            ;;
    esac
}

# Exécuter la fonction principale
main "$@"

#!/bin/bash

# Script de test pour le webhook n8n
# Usage: ./test_webhook.sh

set -e

# Configuration
N8N_URL="http://localhost:5678"
WEBHOOK_PATH="/webhook/invoke_n8n_agent"
BEARER_TOKEN="8dAqtTFIEuSQ9ORqtmknP5WmNjoppLHV518f85on1NvhK3Po"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction d'affichage
print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Test 1: Vérification de l'accessibilité de n8n
print_header "Test 1: Vérification n8n"
if curl -s -o /dev/null -w "%{http_code}" "$N8N_URL" | grep -q "200"; then
    print_success "n8n est accessible"
else
    print_error "n8n n'est pas accessible"
    exit 1
fi

# Test 2: Vérification d'Ollama
print_header "Test 2: Vérification Ollama"
if curl -s http://192.168.0.2:11434/api/tags > /dev/null; then
    print_success "Ollama est accessible"
    echo "Modèles disponibles:"
    curl -s http://192.168.0.2:11434/api/tags | jq -r '.models[].name' | head -5
else
    print_error "Ollama n'est pas accessible"
fi

# Test 3: Webhook simple
print_header "Test 3: Webhook simple"
response=$(curl -s -X POST "$N8N_URL$WEBHOOK_PATH" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $BEARER_TOKEN" \
  -d '{
    "chatInput": "Bonjour, comment ça va ?",
    "sessionId": "test-session-001"
  }' \
  -w "\n%{http_code}")

http_code=$(echo "$response" | tail -n1)
response_body=$(echo "$response" | head -n -1)

if [ "$http_code" = "200" ]; then
    print_success "Webhook répond avec status 200"
    echo "Réponse: $response_body"
else
    print_error "Webhook a échoué avec status $http_code"
    echo "Réponse: $response_body"
fi

# Test 4: Webhook sans authentification
print_header "Test 4: Webhook sans authentification"
response=$(curl -s -X POST "$N8N_URL$WEBHOOK_PATH" \
  -H "Content-Type: application/json" \
  -d '{
    "chatInput": "Test sans auth",
    "sessionId": "test-session-002"
  }' \
  -w "\n%{http_code}")

http_code=$(echo "$response" | tail -n1)
response_body=$(echo "$response" | head -n -1)

if [ "$http_code" = "200" ]; then
    print_warning "Webhook fonctionne sans authentification (sécurité ?)"
    echo "Réponse: $response_body"
else
    print_success "Webhook refuse les requêtes non authentifiées (sécurisé)"
fi

# Test 5: Webhook avec message complexe
print_header "Test 5: Webhook avec message complexe"
response=$(curl -s -X POST "$N8N_URL$WEBHOOK_PATH" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $BEARER_TOKEN" \
  -d '{
    "chatInput": "Peux-tu m'\''expliquer ce qu'\''est l'\''intelligence artificielle en 3 phrases ?",
    "sessionId": "test-session-003"
  }' \
  -w "\n%{http_code}")

http_code=$(echo "$response" | tail -n1)
response_body=$(echo "$response" | head -n -1)

if [ "$http_code" = "200" ]; then
    print_success "Webhook complexe répond avec status 200"
    echo "Réponse: $response_body"
else
    print_error "Webhook complexe a échoué avec status $http_code"
    echo "Réponse: $response_body"
fi

# Test 6: Vérification des logs n8n
print_header "Test 6: Vérification des logs n8n"
echo "Derniers logs n8n:"
docker compose logs --tail=5 n8n

# Résumé
print_header "Résumé des tests"
echo "URL du webhook: $N8N_URL$WEBHOOK_PATH"
echo "Bearer Token: $BEARER_TOKEN"
echo ""
echo "Pour tester manuellement:"
echo "curl -X POST $N8N_URL$WEBHOOK_PATH \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -H 'Authorization: Bearer $BEARER_TOKEN' \\"
echo "  -d '{\"chatInput\": \"Votre message\", \"sessionId\": \"session-123\"}'"
echo ""
echo "Pour accéder à l'interface n8n:"
echo "http://localhost:5678"

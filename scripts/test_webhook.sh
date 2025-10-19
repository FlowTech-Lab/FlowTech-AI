#!/bin/bash

# Test script for n8n webhook
# Usage: ./test_webhook.sh

set -e

# Configuration
N8N_URL="http://localhost:5678"
WEBHOOK_PATH="/webhook/invoke_n8n_agent"
BEARER_TOKEN="8dAqtTFIEuSQ9ORqtmknP5WmNjoppLHV518f85on1NvhK3Po"

# Colors for display
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Display function
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

# Test 1: Check n8n accessibility
print_header "Test 1: n8n check"
if curl -s -o /dev/null -w "%{http_code}" "$N8N_URL" | grep -q "200"; then
    print_success "n8n is accessible"
else
    print_error "n8n is not accessible"
    exit 1
fi

# Test 2: Ollama check
print_header "Test 2: Ollama check"
if curl -s http://192.168.0.2:11434/api/tags > /dev/null; then
    print_success "Ollama is accessible"
    echo "Available models:"
    curl -s http://192.168.0.2:11434/api/tags | jq -r '.models[].name' | head -5
else
    print_error "Ollama is not accessible"
fi

# Test 3: Simple webhook
print_header "Test 3: Simple webhook"
response=$(curl -s -X POST "$N8N_URL$WEBHOOK_PATH" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $BEARER_TOKEN" \
  -d '{
    "chatInput": "Hello, how are you?",
    "sessionId": "test-session-001"
  }' \
  -w "\n%{http_code}")

http_code=$(echo "$response" | tail -n1)
response_body=$(echo "$response" | head -n -1)

if [ "$http_code" = "200" ]; then
    print_success "Webhook responds with status 200"
    echo "Response: $response_body"
else
    print_error "Webhook failed with status $http_code"
    echo "Response: $response_body"
fi

# Test 4: Webhook without authentication
print_header "Test 4: Webhook without authentication"
response=$(curl -s -X POST "$N8N_URL$WEBHOOK_PATH" \
  -H "Content-Type: application/json" \
  -d '{
    "chatInput": "Test without auth",
    "sessionId": "test-session-002"
  }' \
  -w "\n%{http_code}")

http_code=$(echo "$response" | tail -n1)
response_body=$(echo "$response" | head -n -1)

if [ "$http_code" = "200" ]; then
    print_warning "Webhook works without authentication (security?)"
    echo "Response: $response_body"
else
    print_success "Webhook refuses unauthenticated requests (secure)"
fi

# Test 5: Webhook with complex message
print_header "Test 5: Webhook with complex message"
response=$(curl -s -X POST "$N8N_URL$WEBHOOK_PATH" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $BEARER_TOKEN" \
  -d '{
    "chatInput": "Can you explain what artificial intelligence is in 3 sentences?",
    "sessionId": "test-session-003"
  }' \
  -w "\n%{http_code}")

http_code=$(echo "$response" | tail -n1)
response_body=$(echo "$response" | head -n -1)

if [ "$http_code" = "200" ]; then
    print_success "Complex webhook responds with status 200"
    echo "Response: $response_body"
else
    print_error "Complex webhook failed with status $http_code"
    echo "Response: $response_body"
fi

# Test 6: n8n logs check
print_header "Test 6: n8n logs check"
echo "Latest n8n logs:"
docker compose logs --tail=5 n8n

# Summary
print_header "Test summary"
echo "Webhook URL: $N8N_URL$WEBHOOK_PATH"
echo "Bearer Token: $BEARER_TOKEN"
echo ""
echo "To test manually:"
echo "curl -X POST $N8N_URL$WEBHOOK_PATH \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -H 'Authorization: Bearer $BEARER_TOKEN' \\"
echo "  -d '{\"chatInput\": \"Your message\", \"sessionId\": \"session-123\"}'"
echo ""
echo "To access n8n interface:"
echo "http://localhost:5678"

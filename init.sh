#!/bin/bash

# Création des dossiers de données
sudo mkdir -p AI_Data/openwebui AI_Data/pgdata AI_Data/n8n AI_Data/searxng /AI_Data/qdrant
sudo cp settings.yml searxng/settings.yml
sudo chown -R 1000:1000 AI_Data/
sudo chmod -R 700 AI_Data/
sudo chown 1000:1000 searxng/settings.yml searxng/limiter.toml
sudo chmod 600 searxng/settings.yml searxng/limiter.toml

# Génération d'un mot de passe PostgreSQL sécurisé (32 caractères alphanumériques + symboles)
PG_PASS=$(openssl rand -base64 24)

# Création du fichier .env
cat > .env <<EOF
OLLAMA_BASE_URL=http://192.168.0.2:11434
OPENWEBUI_PORT=8081
SEARXNG_PORT=8082
N8N_PORT=5678

POSTGRES_USER=n8n
POSTGRES_PASSWORD=${PG_PASS}
POSTGRES_DB=n8n
EOF

echo "Fichier .env créé avec mot de passe PostgreSQL généré."
echo "Dossiers de data créés. Pense à adapter les volumes dans docker-compose.yml si tu ajoutes d'autres services."

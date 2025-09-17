#!/bin/bash
sudo mkdir -p AI_Data/openwebui AI_Data/pgdata AI_Data/n8n AI_Data/searxng
sudo cp settings.yml searxng/settings.yml
sudo chown -R 1000:1000 AI_Data/
sudo chmod -R 700 AI_Data/
sudo chown 1000:1000 searxng/settings.yml searxng/limiter.toml
sudo chmod 600 searxng/settings.yml searxng/limiter.toml
echo "Dossiers de data créés. Pense à adapter les volumes dans docker-compose.yml si tu ajoutes d'autres services."
# FlowTech-AI

## Stack IA Personnelle Multi-Agents

### Architecture actuelle
- **Ollama** (hors stack) : Moteur LLM local sur 192.168.0.2:11434
- **Qdrant** : Mémoire vectorielle centrale pour RAG et agents
- **Postgres** : Base de données pour n8n + états des agents
- **OpenWebUI** : Interface principale + pipelines
- **n8n** : Orchestrateur multi-agents central
- **SearxNG** : Recherche web pour agents
- **Langfuse** : Traçabilité 
## Démarrage rapide

### Premier démarrage
```bash
chmod +x init.sh
./init.sh
```

Le script `init.sh` optimisé gère automatiquement :
- ✅ Démarrage séquentiel des services
- ✅ Mode DEV avec reset complet optionnel
- ✅ Gestion des erreurs et logs
- ✅ Permissions automatiques (chmod)
- ✅ Configuration des variables d'environnement

### Configuration OpenWebUI
Dans Panneau administrateur > Réglages > Recherche Web : `http://searxng:8080/search`

### Troubleshooting
- **Reset complet** : Modifier `DEV_MODE=true` dans `init.sh` puis relancer
- **Problème Langfuse** : Voir `error.txt` pour diagnostic complet
- **Logs détaillés** : `docker compose logs -f [service]`



## Configuration Langfuse

### Activer le pipeline Langfuse dans OpenWebUI

**Option 1 - Interface** : OpenWebUI → Settings → Pipelines → Add Filter → "Langfuse" → renseigner LANGFUSE_HOST, LANGFUSE_PUBLIC_KEY, LANGFUSE_SECRET_KEY

**Option 2 - Variables d'environnement** : Les variables LANGFUSE_* sont déjà configurées dans le script init.sh

### Générer les clés API
1. Ouvrir Langfuse : http://localhost:3300
2. Créer le premier compte, l'organisation, puis un projet
3. Project → Settings → API Keys → Create API Key
4. Récupérer Public et Secret keys

### ⚠️ Problème actuel
Langfuse 3.98.0 a un bug avec ClickHouse (tables répliquées sans Zookeeper). Voir `error.txt` pour diagnostic complet.

## Documentation

- **`docs/spec.md`** : Spécifications techniques et stack priorisée
- **`docs/ROADMAP.md`** : Roadmap de déploiement et priorités
- **`docs/Agents.md`** : Architecture multi-agents
- **`docs/TECHNICAL_CHANGES.md`** : Modifications techniques récentes
- **`error.txt`** : Diagnostic complet Langfuse/ClickHouse









Bonnus : Instrallation de ollama et modèles de bases


# (re)start Ollama GPU en propre
docker rm -f ollama >/dev/null 2>&1 || true
docker run --gpus all -d --restart unless-stopped \
  -p 11434:11434 -v /opt/ollama:/root/.ollama \
  --name ollama ollama/ollama:latest

# 2) Tirer un modèle sûr pour 6 Go VRAM (petit, rapide)
#docker exec -it ollama ollama pull llama3.2:3b

# Option: tenter un 7B quantisé (peut passer sur 6 Go selon contexte)
docker exec -it ollama ollama pull qwen2.5:7b
docker exec -it ollama ollama pull huihui_ai/qwen2.5-1m-abliterated:7b
# docker exec -it ollama ollama pull mistral:7b

# smoke test API locale
echo '[TEST] generate'
curl -s http://127.0.0.1:11434/api/generate \
  -d '{"model":"llama3.2:3b","prompt":"Donne exactement 5 parfums de glace, une puce par ligne, en français.","stream":false}'

# IP hôte à utiliser depuis le client
echo -e "\n[HOST_IP]"
hostname -I | awk '{print $1}'




utilisation de https://github.com/langfuse/langfuse
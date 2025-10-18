# MCP-Qdrant Service - Production-Ready

Service MCP (Model Context Protocol) optimisé pour Cursor IDE avec Qdrant vector database.

## Caractéristiques

- **Image multi-stage** : Build optimisé sans overhead de compilation
- **Non-root user** : Sécurité renforcée
- **Health check** : Monitoring intégré
- **Ressources configurables** : 2 CPU / 4GB RAM (limites), 0.5 CPU / 512MB (réservation)
- **Persistance** : Volume dédié pour les données

## Modèles d'embeddings supportés

### FastEmbed (par défaut)
- `BAAI/bge-m3` (recommandé) - 1024 dimensions, ~2.2GB, **multilingue 100+ langues**
  - ✅ Dense + Lexical + Multi-vector retrieval
  - ✅ Parfait pour FR + multilangue
  - ✅ Gère jusqu'à 8192 tokens
- `BAAI/bge-base-en-v1.5` - 768 dimensions, ~250MB (anglais uniquement)
- `BAAI/bge-small-en-v1.5` - 384 dimensions, ~130MB (anglais léger)
- `sentence-transformers/all-MiniLM-L6-v2` - 384 dimensions, ~80MB (ultra-léger)

### Configuration

Variables d'environnement dans `.env` ou `docker-compose.yml`:

```bash
# Collection Qdrant (IMPORTANT: nouvelle collection pour bge-m3)
MCP_QDRANT_COLLECTION=cursor-context-m3

# Port d'exposition
MCP_QDRANT_PORT=8000

# Modèle FastEmbed (bge-m3 = multilingue 1024 dims)
FASTEMBED_MODEL=BAAI/bge-m3

# Ollama (pour référence future si support ajouté)
OLLAMA_BASE_URL=http://192.168.0.2:11434
```

### ⚠️ Important: Migration vers bge-m3

**Les embeddings bge-m3 sont incompatibles avec les anciens modèles** (dimensions différentes):
- `bge-m3`: 1024 dimensions
- `bge-base-en-v1.5`: 768 dimensions
- `bge-small-en-v1.5`: 384 dimensions

**Action requise**: Créez une **nouvelle collection** `cursor-context-m3` et ré-indexez vos documents.

## Build et déploiement

### 1. Build de l'image

```bash
cd /home/flowtech/FlowTech-LAB/FlowTech-AI
docker compose build mcp-qdrant
```

### 2. Démarrage du service

```bash
docker compose up -d mcp-qdrant
```

### 3. Vérification

```bash
# Logs
docker compose logs -f mcp-qdrant

# Health check
curl http://localhost:8000/health

# Collection Qdrant (bge-m3)
curl http://localhost:6333/collections/cursor-context-m3
```

## Performance

### Ressources actuelles
- **Limits**: 2 CPU, 4GB RAM
- **Reservations**: 0.5 CPU, 512MB RAM

### Recommandations par usage

| Usage | CPU | RAM | Collection Size |
|-------|-----|-----|-----------------|
| Dev/Test | 0.5-1 | 1-2GB | < 10K vecteurs |
| Staging | 1-2 | 2-4GB | 10K-100K vecteurs |
| Production | 2-4 | 4-8GB | 100K-1M vecteurs |

## Optimisations futures

### Support Ollama
Pour utiliser Ollama (bge-m3:567m) au lieu de FastEmbed:
1. Fork `mcp-server-qdrant` 
2. Ajouter `ollama` à l'enum `EmbeddingProvider`
3. Implémenter le client Ollama dans `/embeddings/ollama.py`

### Cache Redis
Ajouter un cache pour les embeddings fréquents:
```yaml
environment:
  - REDIS_URL=redis://redis:6379
  - CACHE_TTL=3600
```

### GPU Support
Pour accélérer les embeddings:
```yaml
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          count: 1
          capabilities: [gpu]
```

## Troubleshooting

### Le service redémarre en boucle
```bash
# Vérifier les logs
docker compose logs mcp-qdrant --tail 50

# Problèmes courants:
# - ValidationError EMBEDDING_PROVIDER: utiliser 'fastembed' uniquement
# - Model not found: vérifier EMBEDDING_MODEL est compatible FastEmbed
# - OOM: augmenter memory limits
```

### Latence élevée
```bash
# Monitorer les ressources
docker stats mcp-qdrant

# Solutions:
# - Augmenter CPU limits
# - Utiliser un modèle plus léger (all-MiniLM-L6-v2)
# - Pré-charger les embeddings en batch
```

### Collection vide
```bash
# Vérifier Qdrant
curl http://localhost:6333/collections/cursor-context-m3

# Créer manuellement si besoin (bge-m3 = 1024 dims)
curl -X PUT "http://localhost:6333/collections/cursor-context-m3" \
  -H "Content-Type: application/json" \
  -d '{
    "vectors": {
      "size": 1024,
      "distance": "Cosine"
    }
  }'
```

## Structure du projet

```
mcp-qdrant/
├── Dockerfile          # Image multi-stage optimisée
├── .dockerignore       # Exclusions de build
└── README.md           # Cette documentation
```

## Références

- [mcp-server-qdrant](https://github.com/qdrant/mcp-server-qdrant)
- [FastEmbed](https://qdrant.github.io/fastembed/)
- [Qdrant](https://qdrant.tech/)
- [Model Context Protocol](https://modelcontextprotocol.io/)


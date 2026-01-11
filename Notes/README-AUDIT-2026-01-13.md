# /Notes/README-AUDIT-2026-01-13.md

## État des lieux audit

### Qdrant Collections actuelles
- [x] **RÉSULTAT** : Collection `flowtech-notes` **N'EXISTE PAS** ❌
- [x] **RÉSULTAT** : Collections existantes :
  - `cursor-context` : **335 points** (code context)
  - `cursor-knowledge` : **1 point** (knowledge base)
  - `open-webui_files` : **232 points** (documents uploadés)
  - `open-webui_knowledge` : **0 points** (vide)
  - `open-webui_web-search` : existe (points non vérifiés)
  - `documents` : **0 points** (vide)
  - `loa-hf` : **350 points** (collection LOA-HF)
  - `Conversation` : existe (points non vérifiés)
- [x] **RÉSULTAT** : Qdrant API accessible sur port 6333
- [ ] **À FAIRE** : Créer collection `flowtech-notes` si nécessaire
- [ ] **À FAIRE** : Indexer Notes/ dans `cursor-knowledge` ou nouvelle collection

### MCP-Qdrant instances
- [x] **RÉSULTAT** : **4 instances MCP-Qdrant actives** (pas 1 seule) :
  - `mcp-qdrant` : Port **8000** → Collection `cursor-context` (335 points)
  - `mcp-qdrant-knowledge` : Port **8001** → Collection `cursor-knowledge` (1 point)
  - `mcp-qdrant-generic` : Port **8002** → Pas de collection prédéfinie (flexible)
  - `mcp-qdrant-loa-hf` : Port **8003** → Collection `loa-hf` (350 points)
- [x] **RÉSULTAT** : Toutes accessibles depuis VM 252 (healthy)
- [x] **RÉSULTAT** : Containers actifs depuis 6 semaines, uptime 3 jours
- [x] **RÉSULTAT** : FastMCP 2.12.5, MCP SDK 1.16.0
- [x] **RÉSULTAT** : Transport SSE sur `/sse` (connexions actives depuis 192.168.0.246 et 192.168.0.252)
- [x] **RÉSULTAT** : Configuration correcte :
  - `mcp-qdrant` : `COLLECTION_NAME=cursor-context`, `EMBEDDING_MODEL=BAAI/bge-large-en-v1.5`
  - `mcp-qdrant-knowledge` : `COLLECTION_NAME=cursor-knowledge`, `EMBEDDING_MODEL=BAAI/bge-large-en-v1.5`
- [x] **RÉSULTAT** : Healthcheck Docker génère 404 sur `/health` (normal, endpoint SSE sur `/sse`)
- [ ] **À FAIRE** : Vérifier si `mcp-qdrant-knowledge` peut indexer Notes/
- [ ] **À FAIRE** : Tester queries sur collection `cursor-knowledge`

### Nextcloud integration
- [x] **RÉSULTAT** : Pas de montage `/mnt/notes/` sur l'hôte (non configuré)
- [x] **RÉSULTAT** : Notes/ accessible localement : `/home/flowtech/FlowTech-AI/Notes/`
- [x] **RÉSULTAT** : 9 fichiers .md présents dans Notes/
- [x] **RÉSULTAT** : Container Samba peut accéder via volume `/shares/notes` (monté depuis `./Notes`)
- [x] **RÉSULTAT** : Permissions OK (775, flowtech:flowtech)
- [ ] **À FAIRE** : Configurer montage Nextcloud si nécessaire (VM 249 → VM 252)

### Cursor MCP config
- [x] **RÉSULTAT** : Fichier `~/.cursor/mcp.json` existe ✅
- [x] **RÉSULTAT** : **2 serveurs MCP configurés** :
  - `qdrant` : `http://192.168.0.252:8000/sse` → Port 8000 (cursor-context)
  - `qdrant-knowledge` : `http://192.168.0.252:8001/sse` → Port 8001 (cursor-knowledge)
- [x] **RÉSULTAT** : URLs pointent vers VM 252 (192.168.0.252) ✅
- [x] **RÉSULTAT** : Timeout = 30000 ms (correct) ✅
- [x] **RÉSULTAT** : Transport SSE configuré ✅
- [x] **RÉSULTAT** : Endpoints répondent (HTTP 200) ✅
- [x] **RÉSULTAT** : Permissions `alwaysAllow` configurées :
  - `qdrant` : `qdrant-find`, `qdrant-store`
  - `qdrant-knowledge` : `qdrant-find`
- [ ] **À FAIRE** : Tester depuis Cursor que `qdrant-knowledge` peut être interrogé
- [ ] **À FAIRE** : Vérifier fonctionnalité `search_notes` si elle existe

### Indexeur Notes (sync-notes-to-qdrant.py)
- [x] **RÉSULTAT** : Script trouvé : `/home/flowtech/FlowTech-AI/scripts/sync-notes-to-qdrant.py` ✅
- [x] **RÉSULTAT** : Script wrapper : `scripts/sync-notes.sh` ✅
- [x] **RÉSULTAT** : Configuration par défaut :
  - `NOTES_PATH` : `./Notes` (pas `/mnt/notes/`) ⚠️
  - `QDRANT_URL` : `http://localhost:6333` ✅
  - `COLLECTION_NAME` : `cursor-knowledge` ✅
  - `EMBEDDING_MODEL` : `BAAI/bge-large-en-v1.5` ✅
- [x] **RÉSULTAT** : Script de setup : `scripts/setup-sync.sh` existe ✅
- [x] **RÉSULTAT** : Requirements : `qdrant-client`, `fastembed`, `PyYAML` ✅
- [x] **RÉSULTAT** : venv n'existe pas encore ❌
- [x] **RÉSULTAT** : Dépendances non installées dans Python système ❌
- [x] **RÉSULTAT** : Cache `AI_Data/notes-sync-cache.json` n'existe pas (jamais exécuté) ❌
- [ ] **À FAIRE** : Exécuter `./scripts/setup-sync.sh` pour créer venv et installer dépendances
- [ ] **À FAIRE** : Modifier `NOTES_PATH` si besoin de pointer vers `/mnt/notes/` au lieu de `./Notes`
- [ ] **À FAIRE** : Tester exécution : `./scripts/sync-notes.sh`

### n8n workflows
- [x] **RÉSULTAT** : n8n accessible sur port 5678 ✅
- [x] **RÉSULTAT** : **2 workflows existants** dans PostgreSQL :
  - `My workflow` : **Actif** (dernière MAJ: 2025-10-21)
  - `My workflow 2` : **Inactif** (dernière MAJ: 2025-10-22)
- [x] **RÉSULTAT** : **Aucun workflow d'indexation trouvé** ❌
  - Recherche : `%index%`, `%note%`, `%sync%` → 0 résultat
- [x] **RÉSULTAT** : **0 exécutions** enregistrées dans la base
- [x] **RÉSULTAT** : Credentials n8n disponibles :
  - User: `admin`
  - API Key: `ti5oEus77gZSScivYJJQeHQzMvDm0kLiRm8IPQB75xC9SmHN`
- [x] **RÉSULTAT** : Workflows exemple dans `SRC/` :
  - `FlowTech-AI-Complete-Workflow.json` (agent AI complet)
  - `README-Workflows.md` (documentation)
- [ ] **À FAIRE** : Créer workflow "Index FlowTech Notes" dans n8n
- [ ] **À FAIRE** : Configurer trigger manuel (button) ou cron
- [ ] **À FAIRE** : Ajouter node SSH/Docker exec pour exécuter `sync-notes.sh`
- [ ] **À FAIRE** : Tester exécution manuelle et vérifier points dans Qdrant

### Docker services health
- [x] **RÉSULTAT** : qdrant : Up 3 days
- [x] **RÉSULTAT** : mcp-qdrant : Up 3 days (healthy) - Port 8000
- [x] **RÉSULTAT** : mcp-qdrant-knowledge : Up 3 days (healthy) - Port 8001
- [x] **RÉSULTAT** : mcp-qdrant-generic : Up 3 days (healthy) - Port 8002
- [x] **RÉSULTAT** : mcp-qdrant-loa-hf : Up 3 days (healthy) - Port 8003
- [x] **RÉSULTAT** : openwebui : Up 3 days (healthy)
- [x] **RÉSULTAT** : n8n : Up 3 days
- [x] **RÉSULTAT** : postgres : Up 3 days (healthy)
- [x] **RÉSULTAT** : samba : Up 3 days (healthy) - Accès Notes/ OK

### OpenWebUI RAG
- [x] **RÉSULTAT** : OpenWebUI accessible sur port 8081 ✅
- [x] **RÉSULTAT** : Health check OK (`/health` → `{"status":true}`) ✅
- [x] **RÉSULTAT** : Configuration Qdrant :
  - `VECTOR_DB=qdrant` ✅
  - `QDRANT_URI=http://qdrant:6333` ✅
  - `RAG_VECTOR_DB=qdrant` ✅
- [x] **RÉSULTAT** : Configuration RAG :
  - `RAG_EMBEDDING_MODEL=bge-m3:567m` (384 dimensions) ⚠️
  - `RAG_EMBEDDING_ENGINE=ollama` ✅
  - `RAG_TOP_K=5` ✅
  - `CHUNK_SIZE=800` ✅
  - `CHUNK_OVERLAP=100` ✅
- [x] **RÉSULTAT** : Collections Qdrant disponibles :
  - `open-webui_files` : 232 points (384 dims) ✅
  - `open-webui_knowledge` : 0 points (384 dims) ✅
  - `open-webui_web-search` : existe (384 dims) ✅
  - `cursor-knowledge` : 1 point (1024 dims) ⚠️ **INCOMPATIBLE**
  - `cursor-context` : 335 points (1024 dims) ⚠️ **INCOMPATIBLE**
  - `flowtech-notes` : **N'EXISTE PAS** ❌
- [x] **RÉSULTAT** : **PROBLÈME CRITIQUE** : Incompatibilité de dimensions ⚠️
  - OpenWebUI utilise `bge-m3:567m` → **384 dimensions**
  - Collections MCP-Qdrant utilisent `BAAI/bge-large-en-v1.5` → **1024 dimensions**
  - Erreurs dans logs : `"expected dim: 384, got 1024"` ❌
- [x] **RÉSULTAT** : OpenWebUI ne peut **PAS** interroger `cursor-knowledge` ou `flowtech-notes` (si créée avec 1024 dims)
- [ ] **À FAIRE** : Créer collection `flowtech-notes` avec **384 dimensions** pour OpenWebUI
- [ ] **À FAIRE** : OU modifier OpenWebUI pour utiliser `BAAI/bge-large-en-v1.5` (1024 dims)
- [ ] **À FAIRE** : Indexer Notes/ dans collection compatible avec OpenWebUI
- [ ] **À FAIRE** : Tester RAG dans OpenWebUI avec collection `flowtech-notes`

### Références doc
- [x] **RÉSULTAT** : Audit documentation effectué ✅
- [x] **RÉSULTAT** : **16 corrections identifiées** dans 4 fichiers :
  - README.md : 4 corrections (instances MCP, workflow Notes, flowtech-notes)
  - ARCHITECTURE-FINAL.md : 3 corrections (workflow Notes, instances MCP, structure)
  - docs/MCP-QDRANT.md : 7 corrections (4 instances, collections, exemples)
  - docs/NOTES-SYNC.md : 2 corrections (flowtech-notes)
- [x] **RÉSULTAT** : Checklist créée : `CHECKLIST-DOC-CORRECTIONS.md` ✅
- [ ] **À FAIRE** : Appliquer les corrections selon la checklist
- [ ] **À FAIRE** : Vérifier chemins absolus (pas de /flowtech-memory/)
- [ ] **À FAIRE** : Vérifier ADR-001 + ADR-002 existent et à jour

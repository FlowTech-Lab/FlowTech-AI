# 📝 Notes Sync Service - Obsidian → Qdrant RAG

Service de synchronisation automatique des notes Obsidian vers Qdrant pour RAG.

## 🎯 Fonctionnalités

- ✅ **Détection intelligente** : Hash MD5 pour détecter les changements
- ✅ **Chunking par sections** : Découpe par titres `##` niveau 2
- ✅ **Metadata riches** : Frontmatter YAML complet
- ✅ **Updates propres** : Supprime anciens chunks avant upsert
- ✅ **Génération d'index** : VMs, Servers, Domains automatiques
- ✅ **Compatible** : OpenWebUI + Cursor (collections séparées)

## 📦 Installation

```bash
cd services/notes-sync
pip install -r requirements.txt
```

## 🚀 Utilisation

### Sync manuelle

```bash
# Sync toutes les notes
python sync-obsidian.py

# Avec variables d'env custom
NOTES_PATH=/path/to/notes \
QDRANT_URL=http://localhost:6333 \
python sync-obsidian.py
```

### Génération d'index

```bash
python generate-indexes.py
```

### Via Docker

```bash
docker compose exec notes-sync python sync-obsidian.py
```

## ⚙️ Configuration

Variables d'environnement :

| Variable | Défaut | Description |
|----------|--------|-------------|
| `QDRANT_URL` | `http://localhost:6333` | URL Qdrant |
| `NOTES_COLLECTION` | `notes-flowtech` | Collection Qdrant |
| `EMBEDDING_MODEL` | `BAAI/bge-large-en-v1.5` | Modèle FastEmbed |
| `NOTES_PATH` | `/app/notes` | Chemin des notes |
| `CACHE_PATH` | `/app/data/cache` | Cache hash MD5 |

## 📊 Structure des notes

### Frontmatter requis

```yaml
---
type: vm | server | domain | project | note
name: VM-001-Example
ip: 192.168.1.100
status: active | hold | done
created: 2025-01-01
updated: 2025-01-01
tags: [example, docker, production]
---
```

### Chunking

- Découpe par sections `##` (niveau 2)
- Conserve le contexte du titre parent
- Metadata complète sur chaque chunk

### ID stable

- Format : `sha256(file_path::chunk_index)`
- Permet updates sans doublons

## 📋 Index générés

### VMs-Index.md

Table automatique avec :
- Nom VM
- IP
- RAM/CPU
- Services
- Status
- Lien vers note

### Servers-Index.md

Liste des serveurs physiques

### Domains-Index.md

Liste des domaines gérés

## 🔄 Workflow recommandé

### 1. Manuel (cron)

```bash
# Crontab - toutes les 10 min
*/10 * * * * cd /path/to/services/notes-sync && python sync-obsidian.py >> sync.log 2>&1
```

### 2. Via n8n (recommandé)

```
[Schedule Trigger: 10 min]
     ↓
[Execute Command]
  - sync-obsidian.py
     ↓
[Parse Output]
     ↓
[Discord Notification] (optionnel)
```

### 3. Webhook temps réel

```
[Webhook Nextcloud]
     ↓
[Redis Cooldown Check] (5 min)
     ↓
[Execute]
  - sync-obsidian.py
  - generate-indexes.py
     ↓
[Discord Alert]
```

## 📊 Rapport de sync

Exemple de sortie :

```
================================================================================
🔄 FlowTech-AI Notes Sync - Obsidian → Qdrant RAG
================================================================================

📡 Connexion à Qdrant...
✅ Collection 'notes-flowtech' existe déjà
🤖 Chargement du modèle BAAI/bge-large-en-v1.5...
✅ Modèle chargé

📂 Scan du répertoire : /app/notes
✅ 25 fichiers markdown trouvés

🔄 Traitement des fichiers...

📝 VMs/VM-001-Example.md
  📄 4 chunks créés
  🗑️  Supprimé 3 anciens chunks
  ✅ 4 nouveaux chunks insérés

📝 VMs/VM-002-Database.md
  📄 5 chunks créés
  ✅ 5 nouveaux chunks insérés

================================================================================
📊 RAPPORT FINAL
================================================================================
📁 Fichiers scannés    : 25
✅ Fichiers mis à jour : 3
⏭️  Fichiers skippés    : 22
📦 Chunks créés        : 24
🗑️  Chunks supprimés    : 12
❌ Erreurs             : 0
================================================================================
```

## 🎯 Collections Qdrant

### Séparation des usages

| Collection | Usage | Modèle | Dimensions |
|------------|-------|--------|------------|
| `cursor-context` | Cursor MCP (snippets code) | bge-large-en-v1.5 | 1024 |
| `notes-flowtech` | Notes Obsidian (RAG) | bge-large-en-v1.5 | 1024 |

**Avantage** : Isolation complète, pas de pollution entre code et notes

## 📚 Exemples

### Requête OpenWebUI

```
User: "What is the IP of the example VM?"

RAG finds in notes-flowtech:
- VMs/VM-001-Example.md → ip: 192.168.1.100

Response: "The example VM (VM-001) is at IP 192.168.1.100"
```

### Requête Cursor MCP

```
@qdrant find: "How to configure MCP-Qdrant?"

Trouve dans cursor-context:
- Code snippets, config examples

N'interfère PAS avec vos notes personnelles!
```

## 🛠️ Troubleshooting

### Le script ne trouve pas les notes

```bash
# Vérifier le chemin
ls -la $NOTES_PATH

# Vérifier les permissions
```

### Hash cache corrompu

```bash
# Supprimer le cache
rm /app/data/cache/notes_hashes.json

# Re-sync complet
python sync-obsidian.py
```

### Collection Qdrant vide

```bash
# Vérifier la collection
curl http://localhost:6333/collections/notes-flowtech

# Forcer re-création
curl -X DELETE http://localhost:6333/collections/notes-flowtech
python sync-obsidian.py
```

## 📝 Notes

- **Ne modifie jamais** les fichiers markdown sources
- **Chunking virtuel** : découpe en mémoire uniquement
- **ID stables** : permet updates sans doublons
- **Cache performant** : skip fichiers non modifiés

---

**Version** : 1.0.0  
**Dernière mise à jour** : 2025-10-18


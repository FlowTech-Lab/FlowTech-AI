# Checklist : Corrections Documentation FlowTech-AI

**Date**: 2026-01-13  
**Audit**: README-AUDIT-2026-01-13.md

## 📋 Résumé des problèmes identifiés

1. ❌ **README.md** : Mentionne seulement 2 instances MCP (8000, 8001) au lieu de 4 (8000-8003)
2. ❌ **README.md** : Pas de workflow "Notes indexing" dans Data Flow
3. ❌ **README.md** : Collection `flowtech-notes` non mentionnée
4. ❌ **ARCHITECTURE-FINAL.md** : Pas de workflow Notes → Indexer → Qdrant
5. ❌ **ARCHITECTURE-FINAL.md** : Mentionne seulement port 8000 pour MCP
6. ❌ **docs/MCP-QDRANT.md** : Ne mentionne que cursor-context, pas cursor-knowledge ni flowtech-notes
7. ❌ **docs/MCP-QDRANT.md** : Ne documente pas les 4 instances MCP

---

## ✅ Fichier 1 : README.md

### Correction 1.1 : Tableau Core Services

**AVANT** (lignes 55-68) :
```markdown
| **MCP-Qdrant** | 8000 | Cursor code context (cursor-context) | ✅ Production |
| **MCP-Knowledge** | 8001 | Cursor notes search (cursor-knowledge) | ✅ Production |
```

**APRÈS** :
```markdown
| **MCP-Qdrant** | 8000 | Cursor code context (cursor-context) | ✅ Production |
| **MCP-Qdrant-Knowledge** | 8001 | Cursor notes search (cursor-knowledge) | ✅ Production |
| **MCP-Qdrant-Generic** | 8002 | Flexible collections (dynamic) | ✅ Production |
| **MCP-Qdrant-LOA-HF** | 8003 | LOA-HF collection | ✅ Production |
```

### Correction 1.2 : Section Architecture - Data Flow

**AVANT** (lignes 186-190) :
```markdown
**Data Flow:**
1. **Cursor**: Store/retrieve code context via MCP → Qdrant
2. **OpenWebUI**: Upload docs → RAG → Qdrant → AI answers
3. **n8n**: Automate workflows, integrate external APIs
```

**APRÈS** :
```markdown
**Data Flow:**
1. **Cursor**: Store/retrieve code context via MCP → Qdrant
2. **OpenWebUI**: Upload docs → RAG → Qdrant → AI answers
3. **Notes Indexing**: Notes/ folder → sync-notes-to-qdrant.py → Qdrant (cursor-knowledge/flowtech-notes)
4. **n8n**: Automate workflows, integrate external APIs
```

### Correction 1.3 : Section Internal Network URLs

**AVANT** (lignes 209-210) :
```markdown
| **MCP-Qdrant** | `http://mcp-qdrant:8000` | 8000 | ❌ No (Internal only) | - |
| **MCP-Knowledge** | `http://mcp-qdrant-knowledge:8001` | 8001 | ❌ No (Internal only) | - |
```

**APRÈS** :
```markdown
| **MCP-Qdrant** | `http://mcp-qdrant:8000` | 8000 | ❌ No (Internal only) | - |
| **MCP-Qdrant-Knowledge** | `http://mcp-qdrant-knowledge:8001` | 8001 | ❌ No (Internal only) | - |
| **MCP-Qdrant-Generic** | `http://mcp-qdrant-generic:8002` | 8002 | ❌ No (Internal only) | - |
| **MCP-Qdrant-LOA-HF** | `http://mcp-qdrant-loa-hf:8003` | 8003 | ❌ No (Internal only) | - |
```

### Correction 1.4 : Section Cursor Integration - Ajouter mention flowtech-notes

**AVANT** (ligne 107) :
```markdown
Your `Notes/` folder will be automatically synced to Qdrant and searchable in Cursor!
```

**APRÈS** :
```markdown
Your `Notes/` folder will be automatically synced to Qdrant collection `cursor-knowledge` (or `flowtech-notes`) and searchable in Cursor via MCP-Qdrant-Knowledge (port 8001)!
```

---

## ✅ Fichier 2 : ARCHITECTURE-FINAL.md

### Correction 2.1 : Ajouter workflow Notes Indexing

**AVANT** (après ligne 103) :
```markdown
**Use case**: Automated workflows, integrations
```

**APRÈS** :
```markdown
**Use case**: Automated workflows, integrations

### 4. Notes → Indexer → Qdrant

```
Notes/ folder (Markdown files)
  ↓
sync-notes-to-qdrant.py (hourly cron or manual)
  ↓
Parse, chunk, embed (BAAI/bge-large-en-v1.5)
  ↓
Qdrant collection: cursor-knowledge (or flowtech-notes)
  ↓
MCP-Qdrant-Knowledge (port 8001)
  ↓
Cursor IDE: @qdrant-knowledge find "query"
```

**Use case**: Automatic indexing of Markdown notes for semantic search in Cursor
```

### Correction 2.2 : Tableau Core Services

**AVANT** (ligne 28) :
```markdown
| **MCP-Qdrant** | 8000 | Cursor integration | ✅ Production |
```

**APRÈS** :
```markdown
| **MCP-Qdrant** | 8000 | Cursor code context | ✅ Production |
| **MCP-Qdrant-Knowledge** | 8001 | Cursor notes search | ✅ Production |
| **MCP-Qdrant-Generic** | 8002 | Flexible collections | ✅ Production |
| **MCP-Qdrant-LOA-HF** | 8003 | LOA-HF collection | ✅ Production |
```

### Correction 2.3 : Section Directory Structure

**AVANT** (lignes 146-148) :
```markdown
├── Notes/
│   ├── _Templates/              # Generic Obsidian templates
│   └── README-NOTES.md          # Templates guide
```

**APRÈS** :
```markdown
├── Notes/
│   ├── _Templates/              # Generic Obsidian templates
│   ├── Domains/                 # Domain documentation
│   ├── Servers/                  # Server documentation
│   ├── VMs/                      # VM documentation
│   └── README-NOTES.md          # Templates guide
│
├── scripts/
│   ├── sync-notes-to-qdrant.py # Notes indexing script
│   ├── sync-notes.sh            # Wrapper script
│   └── setup-sync.sh            # Setup script
```

---

## ✅ Fichier 3 : docs/MCP-QDRANT.md

### Correction 3.1 : Section Overview - Mentionner les 4 instances

**AVANT** (lignes 5-10) :
```markdown
The MCP-Qdrant server enables **Cursor AI** to directly interact with your Qdrant vector database through the **Model Context Protocol (MCP)**. This allows Cursor to:

- 📚 **Store code snippets** in Qdrant for contextual retrieval
- 🔍 **Search vector database** for relevant code examples
- 🧠 **Enhance AI responses** with your codebase context
- 💾 **Persist knowledge** across Cursor sessions
```

**APRÈS** :
```markdown
The MCP-Qdrant servers enable **Cursor AI** to directly interact with your Qdrant vector database through the **Model Context Protocol (MCP)**. FlowTech-AI includes **4 MCP-Qdrant instances**:

- **MCP-Qdrant** (port 8000): Code context storage (`cursor-context`)
- **MCP-Qdrant-Knowledge** (port 8001): Notes search (`cursor-knowledge` or `flowtech-notes`)
- **MCP-Qdrant-Generic** (port 8002): Flexible collections (dynamic)
- **MCP-Qdrant-LOA-HF** (port 8003): LOA-HF collection

This allows Cursor to:

- 📚 **Store code snippets** in Qdrant for contextual retrieval
- 🔍 **Search vector database** for relevant code examples and notes
- 🧠 **Enhance AI responses** with your codebase context
- 💾 **Persist knowledge** across Cursor sessions
- 📝 **Search notes** from `Notes/` folder via `cursor-knowledge` collection
```

### Correction 3.2 : Section Architecture - Mettre à jour le schéma

**AVANT** (lignes 14-18) :
```markdown
```
Cursor IDE → MCP-Qdrant Server → Qdrant Vector Database
     ↓              ↓                       ↓
   User     SSE Transport            cursor-context collection
```
```

**APRÈS** :
```markdown
```
Cursor IDE → MCP-Qdrant Servers → Qdrant Vector Database
     ↓              ↓                       ↓
   User     SSE Transport            Collections:
                                     - cursor-context (port 8000)
                                     - cursor-knowledge (port 8001)
                                     - flowtech-notes (port 8001)
                                     - loa-hf (port 8003)
```
```

### Correction 3.3 : Section Key Features - Mentionner collections

**AVANT** (lignes 22-26) :
```markdown
- **🔒 Isolated Collection**: Uses `cursor-context` collection (separate from OpenWebUI/n8n)
- **⚡ Fast Embeddings**: sentence-transformers/all-MiniLM-L6-v2 model
- **🌐 SSE Transport**: Server-Sent Events for real-time communication
- **🔄 Auto-sync**: Automatic synchronization with Qdrant
- **📊 Resource Controlled**: Limited to 0.5 CPU and 1GB RAM
```

**APRÈS** :
```markdown
- **🔒 Multiple Collections**: 
  - `cursor-context` (port 8000) - Code snippets
  - `cursor-knowledge` (port 8001) - Notes and documentation
  - `flowtech-notes` (port 8001) - FlowTech infrastructure notes
  - `loa-hf` (port 8003) - LOA-HF specific collection
- **⚡ Fast Embeddings**: BAAI/bge-large-en-v1.5 (1024 dimensions) via FastEmbed
- **🌐 SSE Transport**: Server-Sent Events for real-time communication
- **🔄 Auto-sync**: Automatic synchronization with Qdrant
- **📊 Resource Controlled**: Limited resources per instance
```

### Correction 3.4 : Ajouter section sur les 4 instances

**AVANT** (après ligne 60) :
```markdown
**Note**: The official `qdrant/mcp-server-qdrant` image doesn't exist yet. We use Python image with runtime installation for maximum flexibility and auto-updates.
```

**APRÈS** :
```markdown
**Note**: The official `qdrant/mcp-server-qdrant` image doesn't exist yet. We use custom Docker image (`flowtech/mcp-qdrant:latest`) built from `mcp-qdrant/Dockerfile`.

### Multiple MCP-Qdrant Instances

FlowTech-AI runs **4 separate MCP-Qdrant instances** for different use cases:

1. **mcp-qdrant** (port 8000)
   - Collection: `cursor-context`
   - Purpose: Code context storage
   - Embedding: BAAI/bge-large-en-v1.5 (1024 dims)

2. **mcp-qdrant-knowledge** (port 8001)
   - Collection: `cursor-knowledge` or `flowtech-notes`
   - Purpose: Notes and documentation search
   - Embedding: BAAI/bge-large-en-v1.5 (1024 dims)

3. **mcp-qdrant-generic** (port 8002)
   - Collection: Dynamic (flexible)
   - Purpose: Ad-hoc collections
   - Embedding: BAAI/bge-large-en-v1.5 (1024 dims)

4. **mcp-qdrant-loa-hf** (port 8003)
   - Collection: `loa-hf`
   - Purpose: LOA-HF specific data
   - Embedding: BAAI/bge-large-en-v1.5 (1024 dims)
```

### Correction 3.5 : Section Cursor Configuration - Mentionner les 2 serveurs

**AVANT** (lignes 130-146) :
```json
{
  "mcpServers": {
    "qdrant": {
      "command": "node",
      "args": [],
      "env": {},
      "disabled": false,
      "alwaysAllow": [],
      "timeout": 30000,
      "transport": {
        "type": "sse",
        "url": "http://YOUR_SERVER_IP:8000/sse"
      }
    }
  }
}
```

**APRÈS** :
```json
{
  "mcpServers": {
    "qdrant": {
      "transport": "sse",
      "url": "http://YOUR_SERVER_IP:8000/sse",
      "timeout": 30000,
      "alwaysAllow": ["qdrant-find", "qdrant-store"]
    },
    "qdrant-knowledge": {
      "transport": "sse",
      "url": "http://YOUR_SERVER_IP:8001/sse",
      "timeout": 30000,
      "alwaysAllow": ["qdrant-find"]
    }
  }
}
```

### Correction 3.6 : Section Usage in Cursor - Ajouter exemples pour notes

**AVANT** (lignes 186-190) :
```markdown
### Retrieve Context

```
@qdrant search for: authentication implementation
```
```

**APRÈS** :
```markdown
### Retrieve Context

```
@qdrant search for: authentication implementation
```

### Search Notes (via qdrant-knowledge)

```
@qdrant-knowledge find: server configuration
@qdrant-knowledge find: ADR decisions
@qdrant-knowledge find: VM specifications
```
```

### Correction 3.7 : Section Integration - Mentionner flowtech-notes

**AVANT** (lignes 324-328) :
```markdown
### Coexistence with OpenWebUI

- **OpenWebUI**: Uses Qdrant for RAG (documents collection)
- **MCP-Qdrant**: Uses dedicated `cursor-context` collection
- **No conflict**: Collections are isolated
```

**APRÈS** :
```markdown
### Coexistence with OpenWebUI

- **OpenWebUI**: Uses Qdrant for RAG (`open-webui_files`, `open-webui_knowledge` collections)
  - Embedding: `bge-m3:567m` (384 dimensions)
- **MCP-Qdrant**: Uses dedicated collections (`cursor-context`, `cursor-knowledge`, `flowtech-notes`)
  - Embedding: `BAAI/bge-large-en-v1.5` (1024 dimensions)
- **⚠️ Incompatibility**: Different embedding dimensions mean collections are not directly queryable across services
- **Note**: `flowtech-notes` collection can be created with 384 dimensions for OpenWebUI compatibility if needed
```

---

## ✅ Fichier 4 : docs/NOTES-SYNC.md

### Correction 4.1 : Mentionner flowtech-notes comme option

**AVANT** (ligne 9) :
```markdown
This system automatically syncs your Markdown notes from `Notes/` folder to Qdrant's `cursor-knowledge` collection, making them searchable via Cursor's MCP integration.
```

**APRÈS** :
```markdown
This system automatically syncs your Markdown notes from `Notes/` folder to Qdrant's `cursor-knowledge` collection (or `flowtech-notes` if configured), making them searchable via Cursor's MCP integration.
```

### Correction 4.2 : Section Architecture - Mentionner flowtech-notes

**AVANT** (ligne 18) :
```markdown
Qdrant (cursor-knowledge)      → Vector storage
```

**APRÈS** :
```markdown
Qdrant (cursor-knowledge or flowtech-notes) → Vector storage
```

---

## 📊 Résumé des corrections

| Fichier | Corrections | Statut |
|---------|-------------|--------|
| README.md | 4 corrections | ⏳ À faire |
| ARCHITECTURE-FINAL.md | 3 corrections | ⏳ À faire |
| docs/MCP-QDRANT.md | 7 corrections | ⏳ À faire |
| docs/NOTES-SYNC.md | 2 corrections | ⏳ À faire |

**Total**: 16 corrections à appliquer

---

## 🎯 Priorités

1. **Haute priorité** : README.md (fichier principal, première impression)
2. **Haute priorité** : ARCHITECTURE-FINAL.md (documentation technique principale)
3. **Moyenne priorité** : docs/MCP-QDRANT.md (détails techniques)
4. **Basse priorité** : docs/NOTES-SYNC.md (références mineures)

---

## ✅ Validation après corrections

- [ ] README.md mentionne les 4 instances MCP
- [ ] README.md inclut workflow Notes indexing
- [ ] README.md mentionne collection flowtech-notes
- [ ] ARCHITECTURE-FINAL.md inclut workflow Notes → Indexer → Qdrant
- [ ] ARCHITECTURE-FINAL.md mentionne les 4 instances MCP
- [ ] docs/MCP-QDRANT.md documente les 4 instances
- [ ] docs/MCP-QDRANT.md mentionne cursor-knowledge et flowtech-notes
- [ ] Tous les ports sont corrects (8000-8003)
- [ ] Aucune référence à "1 seule instance MCP"

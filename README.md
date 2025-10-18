# 🚀 FlowTech-AI: Complete Developer Knowledge Stack

> **All-in-one AI infrastructure** for developers: Code assistant (Cursor) + Conversational AI (OpenWebUI) + Personal Knowledge Management (Obsidian) + Intelligent Automation (n8n)

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Docker](https://img.shields.io/badge/docker-compose-blue)](docker-compose.yml)
[![Python](https://img.shields.io/badge/python-3.11-blue)](https://python.org)

---

## 🎯 What is FlowTech-AI?

A **production-ready, self-hosted AI stack** that combines:

- 🤖 **AI Services**: n8n automation, OpenWebUI interface, Qdrant vector DB, Ollama LLM
- 💻 **Cursor Integration**: MCP-Qdrant for AI-enhanced coding with context awareness
- 📝 **Knowledge Management**: Automated Obsidian notes synchronization → RAG
- 🔄 **Intelligent Workflows**: n8n automation for notes processing
- 🚀 **One-command deployment**: `./init.sh` and everything works

### ✨ Key Features

✅ **Cursor AI Enhancement** via Model Context Protocol (MCP)  
✅ **OpenWebUI** with RAG over your personal notes  
✅ **Obsidian Sync** with automatic indexing and embedding  
✅ **Vector Search** with Qdrant (1024-dim embeddings)  
✅ **Production-ready** Docker Compose stack  
✅ **Automated Workflows** with n8n orchestration  
✅ **Fork-friendly** - Clone once, everything works  

---

## 🚀 Quick Start (5 minutes)

```bash
# 1. Clone repository
git clone https://github.com/FlowTech-Lab/FlowTech-AI.git
cd FlowTech-AI

# 2. Initialize stack (optional: edit .env first)
./init.sh

# ✅ Stack ready! Services available at:
# - OpenWebUI: http://localhost:8081
# - Cursor MCP: http://localhost:8000
# - n8n: http://localhost:5678
# - Qdrant: http://localhost:6333
```

**Full guide**: See [QUICKSTART.md](QUICKSTART.md)

---

## 📦 What's Included?

### Core Services

| Service | Port | Description | Status |
|---------|------|-------------|--------|
| **OpenWebUI** | 8081 | AI chat interface with RAG | ✅ Production |
| **MCP-Qdrant** | 8000 | Cursor IDE integration | ✅ Production |
| **n8n** | 5678 | Workflow automation | ✅ Production |
| **Qdrant** | 6333 | Vector database | ✅ Production |
| **PostgreSQL** | 5432 | Logs & metadata | ✅ Production |
| **Redis** | 6379 | Cache & queues | ✅ Production |
| **SearxNG** | 8082 | Web search engine | ✅ Production |

### Python Scripts

| Script | Purpose |
|--------|---------|
| `services/notes-sync/sync-obsidian.py` | Sync Obsidian → Qdrant RAG |
| `services/notes-sync/generate-indexes.py` | Auto-generate indexes (VMs, Servers) |

### Workflows (n8n)

| Workflow | Purpose | Status |
|----------|---------|--------|
| `obsidian-sync` | Notes sync automation | ⏳ To create in n8n |

---

## 💻 Cursor Integration

### Setup (2 minutes)

```bash
# 1. Copy MCP config
cp config/mcp-config.json ~/.cursor/mcp.json

# 2. Edit IP (change to your server IP)
nano ~/.cursor/mcp.json

# 3. Restart Cursor

# 4. Test
@qdrant store "FlowTech-AI is awesome!"
@qdrant find awesome
```

**Full guide**: `docs/setup/02-cursor-setup.md`

---

## 📝 Obsidian Integration

### Setup Knowledge Management

```bash
# 1. Point Obsidian vault to Notes/
# 2. Use templates from Notes/_Templates/
# 3. Enable sync (optional: via Nextcloud)

# 4. Auto-sync to RAG
python3 services/notes-sync/sync-obsidian.py

# Or via n8n (every 10 min)
```

**Features**:
- ✅ Auto-generated indexes (VMs, Servers, Domains)
- ✅ Semantic search in OpenWebUI
- ✅ Change detection (MD5 hash)
- ✅ Smart chunking by sections `##`

**Full guide**: `docs/setup/03-obsidian-setup.md`

---

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                     🖥️  YOUR MACHINE                          │
│  ├─ Cursor IDE (with MCP-Qdrant)                             │
│  └─ Obsidian (optional, for notes)                           │
└────────────────────────┬─────────────────────────────────────┘
                         │
                         ↓ MCP / Sync
┌──────────────────────────────────────────────────────────────┐
│                   🐳 FLOWTECH-AI STACK                        │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐            │
│  │ MCP-Qdrant │  │  OpenWebUI │  │    n8n     │            │
│  │  :8000     │  │   :8081    │  │   :5678    │            │
│  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘            │
│        │                │                │                    │
│        └────────────────┴────────────────┘                   │
│                         │                                     │
│                    ┌────▼────┐                               │
│                    │ Qdrant  │                               │
│                    │  :6333  │                               │
│                    └────┬────┘                               │
│                         │                                     │
│         ┌───────────────┼───────────────┐                   │
│         │               │               │                    │
│    ┌────▼────┐    ┌────▼────┐    ┌────▼────┐              │
│    │PostgreSQL│    │  Redis  │    │ Ollama  │              │
│    │  :5432   │    │  :6379  │    │ (ext)   │              │
│    └──────────┘    └──────────┘    └──────────┘              │
│                                                               │
│  Collections:                                                 │
│  ├─ cursor-context    → Cursor MCP (code snippets)          │
│  └─ notes-flowtech    → Obsidian notes (RAG)                │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

---

## 📚 Documentation

| Guide | Description |
|-------|-------------|
| [QUICKSTART.md](QUICKSTART.md) | ⚡ Start in 5 minutes |
| [MIGRATION-V2-PLAN.md](MIGRATION-V2-PLAN.md) | 🔄 V2 migration plan |
| [docs/setup/](docs/setup/) | 📖 Complete installation |
| [docs/architecture/](docs/architecture/) | 🏗️ Technical architecture |
| [docs/services/](docs/services/) | 🔧 Service documentation |
| [Notes/README-NOTES.md](Notes/README-NOTES.md) | 📝 Notes management guide |

---

## 🛠️ Advanced Usage

### Manual sync notes to RAG

```bash
cd services/notes-sync
python sync-obsidian.py
```

### Generate indexes

```bash
python generate-indexes.py
# Creates VMs-Index.md, Servers-Index.md, etc.
```

### Monitor Qdrant collections

```bash
# cursor-context (Cursor MCP)
curl http://localhost:6333/collections/cursor-context

# notes-flowtech (Obsidian RAG)
curl http://localhost:6333/collections/notes-flowtech
```

### View logs

```bash
docker compose logs -f mcp-qdrant
docker compose logs -f n8n
```

---

## 💡 Use Cases

### 1. AI-Enhanced Development (Cursor)

```
- Code in Cursor with AI assistance
- @qdrant store to save useful snippets
- @qdrant find to retrieve context
- RAG enriched with your technical notes
```

### 2. Personal Knowledge Base (Obsidian + OpenWebUI)

```
- Manage notes in Obsidian (VMs, servers, projects)
- Auto-sync to Qdrant every 10 min
- Ask questions in OpenWebUI
- Get answers from your own notes
```

### 3. Team Knowledge Sharing (Fork)

```
- Clone repo
- Team members contribute notes
- Shared knowledge base via RAG
- Everyone benefits from collective knowledge
```

---

## 📊 Requirements

### Minimum (Dev/Test)

- CPU: 4 cores
- RAM: 8GB
- Disk: 50GB
- OS: Linux (Ubuntu 20.04+)

### Recommended (Production)

- CPU: 8+ cores
- RAM: 32GB (64GB recommended)
- Disk: 100GB NVMe
- OS: Linux (Ubuntu 22.04+)
- Network: 1Gbps

### External Dependencies (optional)

- **Ollama**: External LLM server (if not using cloud APIs)
- **Nextcloud**: For multi-device note sync

---

## 🤝 Contributing

Contributions welcome! See [CONTRIBUTING.md](CONTRIBUTING.md)

---

## 📜 License

MIT License - See [LICENSE](LICENSE)

---

## 🔗 Links

- **Documentation**: [docs/](docs/)
- **Quick Start**: [QUICKSTART.md](QUICKSTART.md)
- **Architecture**: [docs/architecture/](docs/architecture/)
- **Changelog**: [CHANGELOG.md](CHANGELOG.md)

---

## 🆘 Support

- **Issues**: GitHub Issues
- **Discussions**: GitHub Discussions
- **Documentation**: [docs/](docs/)

---

**Version**: 2.0.0  
**Status**: 🟢 Production Ready  
**Last Updated**: 2025-10-18

---

## ⭐ Star this repo if you find it useful!


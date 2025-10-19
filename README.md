# 🚀 FlowTech-AI: Production AI Stack for Developers

> **Self-hosted AI infrastructure**: Cursor AI assistant + Conversational AI (OpenWebUI) + RAG + Intelligent Automation (n8n)

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Docker](https://img.shields.io/badge/docker-compose-blue)](docker-compose.yml)
[![Python](https://img.shields.io/badge/python-3.11-blue)](https://python.org)

---

## 🎯 What is FlowTech-AI?

A **production-ready, self-hosted AI stack** that combines:

- 🤖 **AI Services**: OpenWebUI interface, Qdrant vector DB, n8n automation, Ollama LLM
- 💻 **Cursor Integration**: MCP-Qdrant for AI-enhanced coding with context awareness
- 📚 **Knowledge Base**: RAG with document upload in OpenWebUI
- 🔄 **Intelligent Workflows**: n8n automation platform
- 🚀 **One-command deployment**: `./init.sh` and everything works

### ✨ Key Features

✅ **Cursor AI Enhancement** via Model Context Protocol (MCP)  
✅ **OpenWebUI** with RAG for document Q&A  
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

# 2. Initialize stack
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
| **PostgreSQL** | 5432 | Metadata storage | ✅ Production |
| **Redis** | 6379 | Cache & queues | ✅ Production |
| **SearxNG** | 8082 | Web search engine | ✅ Production |
| **Langfuse** | 3300 | LLM observability | ✅ Production |

---

## 💻 Cursor Integration

### Setup (2 minutes)

```bash
# 1. Copy MCP config template
cp cursor-mcp-config.json ~/.cursor/mcp.json

# 2. Edit IP (change to your server IP)
nano ~/.cursor/mcp.json
# Replace 192.168.0.246 with your actual IP

# 3. Restart Cursor

# 4. Test
@qdrant store "FlowTech-AI is awesome!"
@qdrant find awesome
```

**What you get:**
- Store code snippets, notes, and context in Qdrant
- Retrieve information semantically during coding
- AI-enhanced development with persistent memory

---

## 📚 OpenWebUI RAG

### Upload Documents

1. Open http://localhost:8081
2. Create a new chat
3. Click **"Knowledge"** button
4. Upload your documents (PDF, MD, TXT, DOCX, etc.)
5. Ask questions about your documents!

**Example:**
```
User: What does the API documentation say about authentication?
AI: Based on the uploaded API docs, authentication uses JWT tokens...
```

### Supported Formats
- 📄 PDF, DOCX, TXT, MD
- 💻 Code files (PY, JS, TS, etc.)
- 🌐 Websites (via URL)

---

## 🔧 Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   FlowTech-AI Stack                     │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────┐ │
│  │  Cursor IDE  │───▶│ MCP-Qdrant   │───▶│  Qdrant  │ │
│  │  (Dev Tool)  │    │  (Port 8000) │    │  Vector  │ │
│  └──────────────┘    └──────────────┘    │    DB    │ │
│                                           └────┬─────┘ │
│  ┌──────────────┐    ┌──────────────┐         │       │
│  │   Browser    │───▶│  OpenWebUI   │────────▶│       │
│  │              │    │  (Port 8081) │         │       │
│  └──────────────┘    └──────────────┘         │       │
│                                                │       │
│  ┌──────────────┐    ┌──────────────┐         │       │
│  │   n8n Web    │───▶│     n8n      │────────▶│       │
│  │  Interface   │    │  (Port 5678) │         │       │
│  └──────────────┘    └──────────────┘         │       │
│                                                │       │
│  ┌────────────────────────────────────────────┘       │
│  │                                                     │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐        │
│  └─▶│  Redis   │  │ Postgres │  │ SearxNG  │        │
│     └──────────┘  └──────────┘  └──────────┘        │
│                                                       │
└───────────────────────────────────────────────────────┘
```

**Data Flow:**
1. **Cursor**: Store/retrieve code context via MCP → Qdrant
2. **OpenWebUI**: Upload docs → RAG → Qdrant → AI answers
3. **n8n**: Automate workflows, integrate external APIs

---

## 🛠️ Advanced Usage

### Custom Workflows (n8n)

1. Open http://localhost:5678
2. Login with credentials from `.env` file
3. Import workflow from `SRC/FlowTech-AI-Complete-Workflow.json`
4. Customize for your needs

### Embedding Models

**Default**: `bge-m3:567m` (Ollama) - Multilingual, 1024 dimensions

**Change model**:
```bash
# Edit .env
RAG_EMBEDDING_MODEL=bge-large:latest  # or another model

# Restart
docker compose restart openwebui
```

### Extend with Obsidian

Want to sync personal notes? Check the **Notes Templates** in `Notes/_Templates/`:
- `vm-template.md` - For virtual machines
- `server-template.md` - For servers
- `domain-template.md` - For domains

**For automated sync**, see companion repo: [Flow-Notes-AI](https://github.com/FlowTech-Lab/Flow-Notes-AI)

---

## 📖 Documentation

- **[QUICKSTART.md](QUICKSTART.md)** - Complete setup guide
- **[Notes/_Templates/](Notes/_Templates/)** - Obsidian note templates
- **[docs/](docs/)** - Architecture & advanced topics

---

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repo
2. Create a feature branch
3. Test your changes with `./init.sh`
4. Submit a pull request

---

## 📄 License

MIT License - See [LICENSE](LICENSE) for details

---

## 🙏 Acknowledgments

- **OpenWebUI** - Amazing AI interface
- **Cursor** - Best AI-powered IDE
- **n8n** - Powerful automation platform
- **Qdrant** - High-performance vector database
- **Ollama** - Local LLM inference

---

## 🔗 Links

- **GitHub**: https://github.com/FlowTech-Lab/FlowTech-AI
- **Documentation**: [docs/](docs/)
- **Issues**: https://github.com/FlowTech-Lab/FlowTech-AI/issues

---

**Made with ❤️ by the FlowTech-Lab community**

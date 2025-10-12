# FlowTech-AI

A comprehensive, locally-deployed AI infrastructure designed for FPV, infrastructure, automation, and documentation needs.

## 💻 Prerequisites

### Minimum Requirements
- **CPU**: 4 cores (Intel/AMD x64)
- **RAM**: 8GB
- **Storage**: 50GB SSD free space
- **OS**: Linux (Ubuntu 20.04+ recommended)
- **Software**: Docker 24.0+ with Compose plugin, Git, curl
- **GPU**: Optional, CPU-only mode supported

### Recommended Configuration
- **CPU**: 8 cores (Intel/AMD x64)
- **RAM**: 32GB (recommended 64GB)
- **Storage**: 100GB NVMe SSD
- **GPU**: NVIDIA RTX 4070 or equivalent
- **Network**: 1Gbps connection

### Ollama Models by GPU
- **RTX 4060 (8GB)**: qwen3:8b + bge-m3:567m
- **CPU only**: qwen3:4b (very slow)

## 🚀 Quick Start

```bash
git clone https://github.com/FlowTech-Lab/FlowTech-AI.git
cd FlowTech-AI
chmod +x init.sh
./init.sh
```

The initialization script will automatically:
- ✅ Verify system prerequisites
- ✅ Download Docker images
- ✅ Configure services
- ✅ Start the complete stack

## 🎯 What's Next?

After successful installation:

### 1. Verify Installation
```bash
# Check all services are running
docker compose ps

# Test service endpoints
curl -s http://localhost:8081  # OpenWebUI
curl -s http://localhost:5678  # n8n
curl -s http://localhost:3300  # Langfuse
```

### 2. Access Services
- **OpenWebUI** (Main Interface): http://localhost:8081
- **n8n** (Workflows): http://localhost:5678
- **Langfuse** (Monitoring): http://localhost:3300

### 3. Get Credentials
```bash
# View your login credentials
cat .env | grep -E "(USER|PASSWORD|EMAIL)"
```

### 4. Install Ollama (Required)
```bash
# Install Ollama
curl -fsSL https://ollama.ai/install.sh | sh
ollama serve

# Pull recommended models (in another terminal)
ollama pull qwen3:4b    # For low VRAM
ollama pull qwen3:8b    # For 8GB+ VRAM
ollama pull bge-m3:567m # Embedding model
```

### 5. Configure OpenWebUI
1. **Access OpenWebUI**: http://localhost:8081
2. **Go to Admin Panel** → Settings → Web Search
3. **Configure SearxNG**: Set URL to `http://searxng:8080`
4. **Enable Web Search**: Toggle "Web search engine" to ON

### 6. Configure Ollama Connection (CRITICAL)
1. **Go to Admin Panel** → Settings → Connections
2. **Enable Ollama API**: Toggle "API Ollama" to ON
3. **Add Ollama Connection**: Click the green "+" button
4. **Configure Connection**:
   - Type: Local
   - URL: `http://localhost:11434` (for local installation) or your Ollama server IP
   - Auth: None (unless you have API key configured)
5. **Test Connection**: Verify models are detected and available
6. **Save Settings**: Click "Enregistrer" to save configuration

**⚠️ Without Ollama connection, no LLM models will be available!**

### 7. Configure Langfuse Integration
1. **Access Langfuse**: http://localhost:3300
2. **Login**: Use credentials from `.env` file
3. **Create Project**: Get API keys for monitoring
4. **Configure OpenWebUI**: Add Langfuse API keys in Settings

### 8. Configure RAG System (CRITICAL)
1. **Access OpenWebUI**: http://localhost:8081
2. **Go to Admin Panel** → Settings → Documents
3. **Configure Embedding Model**:
   - **Moteur de modèle d'embedding**: Ollama (`http://localhost:11434`)
   - **Modèle d'embedding**: `bge-m3:567m` (recommandé) ou `qwen3-embedding:0.6b`
   - **Taille du lot d'embedding**: 1 (par défaut)
4. **Configure Retrieval**:
   - **Mode avec injection complète**: ON
   - **Recherche hybride**: ON  
   - **Top K**: 3 (nombre de chunks à récupérer)
5. **Test RAG Function**: Upload a document and verify it's vectorized
6. **Manage Vector Storage**: Use "Réindexer les vecteurs" if needed

**📝 Note**: 
- **Qdrant** = Base de données vectorielle (auto-configurée dans docker-compose.yml)
- **Embedding models** = Configuration dans Settings → Documents
- **Chat models** = Modèles pour conversation (Settings → Models)
- **RAG System** = Configuration complète dans Settings → Documents

**Alternative verification**:
```bash
# Check Qdrant health
curl http://localhost:6333/health
# Expected: {"title":"qdrant - vector search engine","version":"..."}

# List collections (should be empty initially)
curl http://localhost:6333/collections
# Expected: {"result":{"collections":[]},"status":"ok",...}

# Check OpenWebUI environment
docker compose exec openwebui env | grep -E "(VECTOR_DB|QDRANT_URI)"
# Expected: VECTOR_DB=qdrant, QDRANT_URI=http://qdrant:6333
```

### 10. Configure n8n Internal Connections (CRITICAL)
1. **Access n8n**: http://localhost:5678
2. **Login**: Use credentials from `.env` file
3. **Get Connection Info**: 
   ```bash
   # View all connection details
   cat .env | grep -E "(POSTGRES|REDIS|MINIO|CLICKHOUSE)"
   ```
4. **Go to Settings** → Connections → Add New Connection

**Configure Internal Services**:
5. **PostgreSQL Connection**:
   - Type: PostgreSQL
   - Host: `postgres` (internal Docker name)
   - Port: `5432`
   - Database: `n8n` (or your POSTGRES_DB value)
   - User: `n8n` (or your POSTGRES_USER value)
   - Password: From `.env` file

6. **Qdrant Connection**:
   - Type: Qdrant
   - URL: `http://qdrant:6333` (internal Docker name)
   - API Key: Leave empty (no auth required)

7. **Redis Connection**:
   - Type: Redis
   - Host: `redis` (internal Docker name)
   - Port: `6379`
   - Password: From `.env` file (REDIS_AUTH)

8. **MinIO Connection**:
   - Type: S3
   - Endpoint: `http://minio:9000`
   - Access Key: `minio`
   - Secret Key: From `.env` file (MINIO_ROOT_PASSWORD)

### 11. Import and Configure Workflows
1. **Import Workflows**: Use pre-built automation templates
2. **Configure Agent Workflows**: Set up multi-agent orchestration
3. **Test Internal Connections**: Verify all services are accessible

### 12. First Steps
1. **Test AI Chat**: OpenWebUI with web search enabled
2. **Verify Langfuse**: Check AI request monitoring
3. **Run n8n Workflow**: Test automation pipeline
4. **Read documentation**: See [USER_GUIDE.md](docs/USER_GUIDE.md)

## 📋 Complete Services Overview

| Service | Purpose | URL | Port | Configuration |
|---------|---------|-----|------|---------------|
| **OpenWebUI** | Main AI Interface | http://localhost:8081 | 8081 | ✅ SQLite + Qdrant + SearxNG |
| **n8n** | Workflow Automation | http://localhost:5678 | 5678 | ✅ PostgreSQL + Redis |
| **Langfuse** | AI Monitoring | http://localhost:3300 | 3300 | ✅ PostgreSQL + ClickHouse + MinIO |
| **SearxNG** | Web Search | http://localhost:8082 | 8082 | ✅ Auto-configured |
| **PostgreSQL** | Main Database | `postgres:5432` | 5432 | ✅ Auto-configured |
| **Redis** | Cache & Queues | `redis:6379` | 6379 | ✅ Auto-configured |
| **Qdrant** | Vector Database | `qdrant:6333` | 6333 | ✅ Auto-configured |
| **ClickHouse** | Analytics DB | `clickhouse:8123` | 8123 | ✅ Auto-configured |
| **MinIO** | S3 Storage | `minio:9000` | 9092 | ✅ Auto-configured |

### 🔗 Service Interconnections

```
User → OpenWebUI → Ollama (external)
  ↓
OpenWebUI → SQLite (local data) + Qdrant (vectors) + SearxNG (search)
  ↓
n8n → PostgreSQL (workflows + agent state) + Redis (queues)
  ↓
Langfuse → PostgreSQL (metadata) + ClickHouse (analytics) + MinIO (storage)
```

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   OpenWebUI     │    │      n8n        │    │    SearxNG      │
│  (Main UI)      │◄──►│ (Orchestrator)  │◄──►│  (Web Search)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     Qdrant      │    │   PostgreSQL    │    │     Redis       │
│ (Vector Store)  │    │   (Database)    │    │   (Cache)       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 📚 Documentation

### User Documentation
- **[Setup Guide](docs/SETUP.md)** - Complete installation instructions
- **[User Guide](docs/USER_GUIDE.md)** - How to use the system
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues and solutions

### Developer Documentation
- **[Developer Guide](docs/DEVELOPER_GUIDE.md)** - Development and customization
- **[Architecture](docs/ARCHITECTURE.md)** - Technical specifications
- **[API Reference](docs/API_REFERENCE.md)** - API documentation

### Internal Documentation
- **[Deployment](docs/internal/DEPLOYMENT.md)** - Production deployment
- **[Monitoring](docs/internal/MONITORING.md)** - System monitoring
- **[Security](docs/internal/SECURITY.md)** - Security guidelines

## 🎯 Key Features

- **Multi-Agent Orchestration**: n8n-based agent coordination
- **Vector RAG**: Qdrant-powered document retrieval
- **AI Observability**: Langfuse tracing and monitoring
- **Local LLM**: Ollama integration for privacy
- **Web Search**: SearxNG for real-time information
- **Persistent Storage**: PostgreSQL + ClickHouse + MinIO

## 🔧 Configuration

### External Dependencies
- **Ollama**: Local LLM engine (install separately)

### Environment Variables
Key configuration is in `.env` file:
```bash
POSTGRES_PASSWORD=<auto-generated>
LANGFUSE_INIT_USER_PASSWORD=<auto-generated>
N8N_BASIC_AUTH_PASSWORD=<auto-generated>
```

## 🛠️ Development

### Prerequisites
- Docker 24.0+ with Compose plugin
- Git
- 8GB+ RAM, 20GB+ storage

### Quick Development Setup
```bash
# Clone and start
git clone https://github.com/FlowTech-Lab/FlowTech-AI.git
cd FlowTech-AI
./init.sh

# Development mode
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d
```

## 🔒 Security

- **Local-First**: All services run locally by default
- **Network Isolation**: Services communicate via internal Docker network
- **Authentication**: Built-in auth for all web interfaces
- **Data Persistence**: All data stored in `./AI_Data/` directory

## 📊 Monitoring

- **Health Checks**: Built-in service monitoring
- **Logging**: Comprehensive logging system
- **Metrics**: Performance and usage tracking
- **Observability**: Langfuse integration for AI monitoring

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **OpenWebUI**: Main AI interface
- **n8n**: Workflow orchestration
- **Langfuse**: AI observability
- **Qdrant**: Vector database
- **Ollama**: Local LLM engine

---

**FlowTech-AI** - Personal AI infrastructure for automation and documentation
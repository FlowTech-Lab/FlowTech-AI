# FlowTech-AI

## Personal Multi-Agent AI Stack

A comprehensive, locally-deployed AI infrastructure designed for FlowTech's FPV, infrastructure, automation, and documentation needs.

### 🚀 Quick Start

```bash
chmod +x init.sh
./init.sh
```

The optimized `init.sh` script automatically handles:
- ✅ Sequential service startup with proper dependencies
- ✅ DEV mode with optional complete reset
- ✅ Error handling and comprehensive logging
- ✅ Automatic permissions (chmod)
- ✅ Environment variable configuration
- ✅ Disk space verification
- ✅ Docker image pre-pulling

### 📋 Current Stack Status

#### ✅ Operational Services
- **OpenWebUI** : Main interface + pipelines (http://localhost:8081)
- **n8n** : Multi-agent orchestrator (http://localhost:5678)
- **SearxNG** : Web search for agents (http://localhost:8082)
- **Langfuse** : AI observability and tracing (http://localhost:3300)
- **Qdrant** : Vector memory for RAG and agents (http://localhost:6333)
- **PostgreSQL** : Database for n8n + agent states
- **Redis** : Cache and queue management
- **ClickHouse** : Analytics database
- **MinIO** : S3-compatible storage

#### 🔧 External Dependencies
- **Ollama** : Local LLM engine (192.168.0.2:11434) - **CRITICAL**

### 🏗️ Architecture

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
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   ClickHouse    │    │     MinIO       │    │    Langfuse     │
│  (Analytics)    │    │   (Storage)     │    │ (Observability) │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### 🔧 Configuration

#### OpenWebUI Setup
In Admin Panel > Settings > Web Search: `http://searxng:8080/search`

#### Langfuse Integration
1. Access Langfuse: http://localhost:3300
2. Create account, organization, and project
3. Generate API keys in Project > Settings > API Keys
4. Configure OpenWebUI pipeline with Langfuse credentials

### 🛠️ Troubleshooting

#### Complete Reset
```bash
# Edit init.sh and set DEV_MODE=true
# Then run:
./init.sh
```

#### Service Logs
```bash
docker compose logs -f [service-name]
```

#### Health Checks
```bash
# Check all services
curl -s http://localhost:8081  # OpenWebUI
curl -s http://localhost:5678  # n8n
curl -s http://localhost:8082  # SearxNG
curl -s http://localhost:3300  # Langfuse
curl -s http://localhost:6333  # Qdrant
```

### 📚 Documentation

- **`docs/spec.md`** : Technical specifications and prioritized stack
- **`docs/ROADMAP.md`** : Deployment roadmap and priorities
- **`docs/Agents.md`** : Multi-agent architecture
- **`docs/TECHNICAL_CHANGES.md`** : Recent technical modifications

### 🔗 External References

This implementation is based on the official Langfuse Docker Compose configuration:
- **Source**: [Langfuse Official Docker Compose](https://github.com/langfuse/langfuse/blob/main/docker-compose.yml)
- **Version**: Langfuse 3.x with ClickHouse, Redis, and MinIO integration

### 🎯 Key Features

- **Multi-Agent Orchestration**: n8n-based agent coordination
- **Vector RAG**: Qdrant-powered document retrieval
- **AI Observability**: Langfuse tracing and monitoring
- **Local LLM**: Ollama integration for privacy
- **Web Search**: SearxNG for real-time information
- **Persistent Storage**: PostgreSQL + ClickHouse + MinIO

### 🔒 Security

- **Local-First**: All services run locally by default
- **Network Isolation**: Services communicate via internal Docker network
- **Authentication**: Built-in auth for all web interfaces
- **Data Persistence**: All data stored in `./AI_Data/` directory

---

**FlowTech-AI** - Personal AI infrastructure, automation, and documentation
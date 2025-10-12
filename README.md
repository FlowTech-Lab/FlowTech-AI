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
- **Ollama** : Local LLM engine - **CRITICAL**

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

#### Network Configuration
- **External Access**: Use `192.168.0.246` for LAN access
- **Internal Docker**: Services use container names (e.g., `http://qdrant:6333`)
- **Local Access**: Use `localhost` when accessing from the same machine

#### Important Environment Variables
- **N8N_SECURITY_API_BEARER_AUTH**: Bearer token for n8n webhook authentication
- **LANGFUSE_INIT_USER_EMAIL**: Admin email for Langfuse
- **LANGFUSE_INIT_USER_PASSWORD**: Admin password for Langfuse
- **N8N_BASIC_AUTH_USER**: n8n admin username
- **N8N_BASIC_AUTH_PASSWORD**: n8n admin password

#### OpenWebUI Setup
In Admin Panel > Settings > Web Search: `http://searxng:8080/search`

#### Langfuse Integration
1. Access Langfuse: http://localhost:3300
2. Create account, organization, and project
3. Generate API keys in Project > Settings > API Keys
4. Configure OpenWebUI pipeline with Langfuse credentials

#### n8n Workflow Setup
1. **Import the main workflow**:
   - Access n8n: http://localhost:5678 or IP
   - Go to Workflows > Import from File
   - Import `SRC/N8N-openwebui-workflow.json`

2. **Import the N8N Pipe function**:
   - Go to Settings > Functions
   - Import `SRC/function-N8N Pipe.json`

3. **Configure OpenWebUI function**:
   - Access OpenWebUI: http://localhost:8081
   - Go to Admin Panel > Functions
   - Add new function with webhook URL: `http://n8n:5678/webhook/invoke_n8n_agent`

### 🛠️ Troubleshooting

#### Complete Reset
```bash
# Edit init.sh and set DEV_MODE=true
# Then run:
chmod +x init.sh
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
### 🌐 Network URLs

#### Internal Docker Communication
| Service | Container Name | Internal URL | Port | Usage |
|---------|----------------|--------------|------|-------|
| **PostgreSQL** | `flowtech-ai-postgres-1` | `postgres:5432` | 5432 | n8n database |
| **Redis** | `redis` | `redis:6379` | 6379 | cache and queues |
| **MinIO** | `minio` | `minio:9000` | 9000 | S3-compatible storage |
| **ClickHouse** | `clickhouse` | `clickhouse:8123` | 8123 | analytics database |
| **Qdrant** | `qdrant` | `http://qdrant:6333` | 6333 | vector storage |
| **Langfuse Worker** | `langfuse-worker` | `langfuse-worker:3030` | 3030 | background processing |
| **Langfuse Web** | `langfuse-web` | `langfuse-web:3000` | 3000 | web interface |
| **n8n** | `flowtech-ai-n8n-1` | `n8n:5678` | 5678 | workflow orchestrator |
| **OpenWebUI** | `flowtech-ai-openwebui-1` | `openwebui:8080` | 8080 | main AI interface |
| **SearxNG** | `flowtech-ai-searxng-1` | `http://searxng:8080` | 8080 | web search engine |

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
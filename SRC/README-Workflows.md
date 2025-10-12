# FlowTech-AI N8N Workflows

This directory contains N8N workflows for the FlowTech-AI stack configuration and usage.

## 📁 Workflow Files

### 1. **FlowTech-AI-Setup-Workflow.json**
**Purpose**: Configuration and testing workflow for all FlowTech-AI services.

**Features**:
- Tests all service connections
- Provides visual configuration guide
- Validates credentials setup
- Generates status reports

**Usage**:
1. Import into N8N
2. Configure credentials in Settings → Connections
3. Call webhook: `GET /webhook/setup`
4. Review configuration status

### 2. **FlowTech-AI-Complete-Workflow.json**
**Purpose**: Full-featured AI agent with access to all FlowTech-AI services.

**Features**:
- Multi-modal AI agent (chat, search, RAG, tools)
- Web search via SearxNG
- Vector database access via Qdrant
- Mathematical calculations
- Wikipedia knowledge access
- Time services
- Database operations (PostgreSQL, Redis, ClickHouse)
- File storage (MinIO)
- AI monitoring (Langfuse)
- **Optimized ClickHouse**: Single `ClickHouse Analytics Tool` (simplified architecture)

**Usage**:
1. Import into N8N
2. Configure all credentials (use Setup workflow first)
3. Call webhook: `POST /webhook/flowtech-agent`
4. Send requests with `chatInput`, `message`, or `query` fields

**ClickHouse Integration**:
- **Tool**: `ClickHouse Analytics Tool` (HTTP Request with query parameter)
- **Endpoint**: `http://clickhouse:8123/`
- **Usage**: Agent can query analytics data directly
- **Features**: Latency tracking, error monitoring, token usage analytics

### 3. **N8N-openwebui-workflow.json** (Legacy)
**Purpose**: Original OpenWebUI integration workflow.

## 🔧 Required Credentials

Configure these credentials in N8N Settings → Connections:

> **Note**: MinIO doesn't have a dedicated N8N node, so we use the AWS S3 node with S3-compatible configuration.

### **Ollama Connections**
- **Name**: `Ollama Chat Connection`
- **Type**: Ollama API
- **URL**: `http://localhost:11434` (or your Ollama server IP)
- **Models**: `qwen3:8b`, `qwen3:4b`

- **Name**: `Ollama Embedding Connection`  
- **Type**: Ollama API
- **URL**: `http://localhost:11434`
- **Models**: `bge-m3:567m`, `qwen3-embedding:0.6b`

### **Qdrant Connection**
- **Name**: `Qdrant Connection`
- **Type**: Qdrant API
- **URL**: `http://qdrant:6333` (internal Docker)
- **API Key**: Leave empty (no auth required)

### **SearxNG Connection**
- **Name**: `SearxNG Connection`
- **Type**: SearxNG API
- **URL**: `http://searxng:8080` (internal Docker)
- **API Key**: Leave empty (no auth required)

### **PostgreSQL Connection**
- **Name**: `PostgreSQL Connection`
- **Type**: PostgreSQL
- **Host**: `postgres` (internal Docker)
- **Port**: `5432`
- **Database**: `n8n` (or your POSTGRES_DB)
- **User**: `n8n` (or your POSTGRES_USER)
- **Password**: From `.env` file

### **Redis Connection**
- **Name**: `Redis Connection`
- **Type**: Redis
- **Host**: `redis` (internal Docker)
- **Port**: `6379`
- **Password**: From `.env` file (REDIS_AUTH)

### **MinIO S3 Connection**
- **Name**: `MinIO S3 Connection`
- **Type**: AWS (S3 Compatible)
- **Configuration**:
  - **Access Key ID**: `minio`
  - **Secret Access Key**: From `.env` file (MINIO_ROOT_PASSWORD)
  - **Region**: `auto` (or leave empty)
  - **Custom Endpoint**: `http://minio:9000`
  - **Force Path Style**: `true` (important for MinIO)
  - **Disable SSL**: `true` (for HTTP)

### **ClickHouse Connection**
- **Name**: `ClickHouse Connection`
- **Type**: ClickHouse
- **Host**: `clickhouse` (internal Docker)
- **Port**: `8123`
- **Database**: `default`
- **User**: `clickhouse` (or `langfuse`)
- **Password**: From `.env` file (CLICKHOUSE_PASSWORD)

### **Langfuse Connection**
- **Name**: `Langfuse Connection`
- **Type**: HTTP Header Auth
- **Header Name**: `Authorization`
- **Header Value**: `Bearer [YOUR_LANGFUSE_API_KEY]`
- **Base URL**: `http://langfuse:3000`

## 🚀 Quick Start

### Step 1: Import Setup Workflow
```bash
# In N8N, go to Workflows → Import from File
# Select: FlowTech-AI-Setup-Workflow.json
```

### Step 2: Configure Credentials
1. Go to Settings → Connections
2. Add each connection type listed above
3. Use the internal Docker URLs provided

### Step 3: Test Setup
```bash
# Call the setup webhook
curl -X GET "http://localhost:5678/webhook/setup"
```

### Step 4: Import Complete Workflow
```bash
# Import the full agent workflow
# Select: FlowTech-AI-Complete-Workflow.json
```

### Step 5: Use the AI Agent
```bash
# Send a message to the AI agent
curl -X POST "http://localhost:5678/webhook/flowtech-agent" \
  -H "Content-Type: application/json" \
  -d '{"chatInput": "Hello, can you search for information about AI?"}'
```

## 🔍 Testing Individual Services

### Test Qdrant
```bash
curl http://localhost:6333/health
curl http://localhost:6333/collections
```

### Test SearxNG
```bash
curl "http://localhost:8082/search?q=test&format=json"
```

### Test PostgreSQL
```bash
docker compose exec postgres psql -U n8n -d n8n -c "SELECT 1;"
```

### Test Redis
```bash
docker compose exec redis redis-cli ping
```

### Test MinIO
```bash
# Health check
curl http://localhost:9092/minio/health/live

# List buckets (requires credentials)
curl -X GET "http://localhost:9092/" \
  -H "Authorization: AWS4-HMAC-SHA256 ..."
```

### MinIO S3 Configuration Details
Since MinIO doesn't have a dedicated N8N node, use the AWS S3 node with these settings:

**🎯 MinIO Utility in FlowTech-AI Stack**:
- **📄 Document Storage**: PDF, images, text files for RAG systems
- **🧠 Embedding Cache**: Vector storage for faster retrieval
- **💾 Backup Storage**: Conversation backups and data exports
- **📊 Langfuse Media**: Stores images, files, and event data
- **🔧 n8n Assets**: Binary files and workflow exports
- **🌐 Static Assets**: Images, configurations, and shared resources

**In N8N AWS Credentials**:
1. **Access Key ID**: `minio`
2. **Secret Access Key**: Your `MINIO_ROOT_PASSWORD` from `.env`
3. **Region**: Leave empty or use `auto`
4. **Custom Endpoint**: `http://minio:9000`
5. **Force Path Style**: `true` (crucial for MinIO)
6. **Disable SSL**: `true` (since we use HTTP internally)

**Available Operations**:
- `listBuckets` - List all buckets (✅ **Setup/Test**)
- `listObjects` - List files in a bucket (✅ **Usage**)
- `upload` - Upload files to storage
- `download` - Download files from storage
- `delete` - Delete files from storage

**Recommended Usage**:
- **Setup Workflow**: Use `listBuckets` to verify MinIO is working
- **Complete Workflow**: Use `listObjects` to check files in specific buckets
- **Bucket to check**: `langfuse` (contains Langfuse media and events)

### Test ClickHouse
```bash
# Health check
curl http://localhost:8123/ping

# Test query (if credentials available)
curl -X POST "http://localhost:8123/" \
  -u "clickhouse:your_password" \
  -d "SELECT 1 as test"
```

### ClickHouse Analytics Utility
ClickHouse serves as the analytics backend for **Langfuse AI observability**:

**🎯 Primary Functions**:
- **📊 Langfuse Analytics**: Stores all AI interaction traces and metrics
- **🔍 Performance Monitoring**: Query latency, token usage, costs per request
- **📈 Usage Analytics**: Model usage patterns, peak hours, request types
- **🐛 Error Tracking**: Failed requests, error patterns, debugging data
- **💾 Historical Data**: Complete conversation history for analysis

**📋 Data Stored**:
- **AI Traces**: Every LLM interaction with timing and tokens
- **Agent Performance**: n8n workflow execution metrics
- **RAG Analytics**: Vector search performance and relevance
- **User Behavior**: Usage patterns and preferences
- **System Metrics**: Resource utilization and health

**🔧 Integration**:
- **Langfuse**: Primary consumer for AI observability dashboards
- **n8n**: Can send custom analytics events and query analytics data
- **Future**: Prometheus/Grafana for system monitoring

**🏗️ Why ClickHouse vs PostgreSQL?**:
- **ClickHouse**: Optimized for analytics (time-series, aggregations, large datasets)
- **PostgreSQL**: Optimized for transactional data (workflows, states, relations)
- **Separation**: Each database optimized for its specific use case
- **Performance**: ClickHouse 10-100x faster for analytical queries

**📊 n8n ClickHouse Usage Examples**:
```sql
-- Analytics queries in n8n workflows
SELECT model_name, avg(latency_ms), count(*) 
FROM traces 
WHERE timestamp > now() - INTERVAL 1 HOUR
GROUP BY model_name;

-- Performance monitoring
SELECT date, count(*) as requests, avg(latency_ms) as avg_latency
FROM traces 
WHERE timestamp > now() - INTERVAL 7 DAY
GROUP BY date
ORDER BY date;
```

**🔧 Optimized ClickHouse Architecture**:
The Complete Workflow uses a simplified ClickHouse integration:

**Old Architecture** (Setup Workflow):
```
BuildSafeSQL → CH_Select → ToolOutput → Agent
```

**New Architecture** (Complete Workflow):
```
ClickHouse Analytics Tool → Agent
```

**Benefits**:
- ✅ **Simpler**: Single tool instead of 3-node chain
- ✅ **Direct**: HTTP Request tool with query parameter
- ✅ **Efficient**: Less overhead, faster execution
- ✅ **Maintainable**: Easier to configure and debug

### Test Langfuse
```bash
curl http://localhost:3300/api/public/health
```

## 📊 Monitoring

### View Logs
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f openwebui
docker compose logs -f n8n
docker compose logs -f qdrant
```

### Check Status
```bash
# Service status
docker compose ps

# Resource usage
docker stats
```

## 🛠️ Troubleshooting

### Common Issues

1. **Connection Refused**: Check if services are running
2. **Authentication Failed**: Verify credentials in `.env`
3. **Timeout Errors**: Check network connectivity
4. **Permission Denied**: Verify Docker permissions

### Reset Everything
```bash
# Complete reset (development only)
DEV_MODE=true ./init.sh
```

## 📚 Integration with OpenWebUI

The workflows can be integrated with OpenWebUI pipelines:

1. Configure OpenWebUI webhook endpoints
2. Use n8n webhooks as pipeline steps
3. Enable RAG with Qdrant in OpenWebUI
4. Monitor with Langfuse

## 🔐 Security Notes

- All internal Docker URLs use the `flow-ai-network`
- External access is limited to specific ports
- Credentials are stored securely in N8N
- Use HTTPS in production environments

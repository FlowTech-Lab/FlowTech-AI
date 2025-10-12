# 🛠️ FlowTech-AI Developer Guide

## Architecture Overview

### System Components
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

### Technology Stack
- **Containerization**: Docker + Docker Compose
- **AI Framework**: OpenWebUI + Ollama
- **Orchestration**: n8n
- **Vector Database**: Qdrant
- **Relational DB**: PostgreSQL
- **Cache**: Redis
- **Analytics**: ClickHouse
- **Storage**: MinIO (S3-compatible)
- **Observability**: Langfuse

## Development Environment

### Prerequisites
```bash
# Required tools
docker --version  # 24.0+
docker compose version
git --version
curl --version

# Optional development tools
code  # VS Code
docker-compose  # Alternative to docker compose
```

### Local Development Setup
```bash
# Clone repository
git clone https://github.com/FlowTech-Lab/FlowTech-AI.git
cd FlowTech-AI

# Create development environment
cp .env.example .env.dev
# Edit .env.dev with development settings

# Start development stack
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d
```

### Development Configuration
```yaml
# docker-compose.dev.yml
version: '3.8'
services:
  openwebui:
    volumes:
      - ./src:/app/src  # Mount source code
    environment:
      - DEBUG=true
      - LOG_LEVEL=debug
```

## Service Configuration

### OpenWebUI Development
```python
# Custom pipeline example
def custom_pipeline(input_data):
    # Process input
    processed = process_input(input_data)
    
    # Call n8n webhook
    response = call_n8n_webhook(processed)
    
    # Return result
    return format_response(response)
```

### n8n Workflow Development
```javascript
// Custom function example
function processDocument(document) {
    // Extract text
    const text = extractText(document);
    
    // Process with AI
    const analysis = analyzeText(text);
    
    // Store in Qdrant
    storeInQdrant(analysis);
    
    return analysis;
}
```

### Qdrant Integration
```python
from qdrant_client import QdrantClient

# Initialize client
client = QdrantClient(host="qdrant", port=6333)

# Create collection
client.create_collection(
    collection_name="documents",
    vectors_config={"size": 384, "distance": "Cosine"}
)

# Insert vectors
client.upsert(
    collection_name="documents",
    points=[
        {
            "id": 1,
            "vector": [0.1, 0.2, 0.3, ...],
            "payload": {"text": "document content"}
        }
    ]
)
```

## API Development

### OpenWebUI API
```bash
# Authentication
curl -H "Authorization: Bearer $API_KEY" \
     http://localhost:8081/api/v1/chat

# Chat completion
curl -X POST http://localhost:8081/api/v1/chat \
     -H "Content-Type: application/json" \
     -d '{
       "model": "qwen2.5:7b",
       "messages": [{"role": "user", "content": "Hello"}]
     }'
```

### n8n Webhook API
```bash
# Trigger workflow
curl -X POST http://localhost:5678/webhook/trigger-name \
     -H "Content-Type: application/json" \
     -d '{"input": "data"}'

# Get workflow status
curl http://localhost:5678/api/v1/executions/{execution_id}
```

### Langfuse API
```python
from langfuse import Langfuse

# Initialize client
langfuse = Langfuse(
    public_key="lf_pk_...",
    secret_key="lf_sk_...",
    host="http://localhost:3300"
)

# Create trace
trace = langfuse.trace(
    name="chat-completion",
    input={"user_input": "Hello world"}
)

# Create generation
generation = trace.generation(
    name="openai-chat-completion",
    model="qwen2.5:7b",
    input={"messages": [...]},
    output={"content": "AI response"}
)
```

## Database Schema

### PostgreSQL (n8n)
```sql
-- Main tables created by n8n
CREATE TABLE workflow_entity (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    active BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE execution_entity (
    id SERIAL PRIMARY KEY,
    workflow_id INTEGER REFERENCES workflow_entity(id),
    mode VARCHAR(50),
    started_at TIMESTAMP DEFAULT NOW()
);
```

### ClickHouse (Analytics)
```sql
-- Langfuse analytics tables
CREATE TABLE traces (
    id String,
    timestamp DateTime64(3),
    name String,
    input String,
    output String,
    user_id String
) ENGINE = MergeTree()
ORDER BY (timestamp, id);
```

## Custom Development

### Adding New Services
1. **Define service** in `docker-compose.yml`
2. **Configure networking** in `flow-ai-network`
3. **Add environment variables** to `.env`
4. **Update init.sh** for service initialization
5. **Add health checks** and monitoring

### Custom Pipelines
```python
# Pipeline structure
class CustomPipeline:
    def __init__(self, config):
        self.config = config
        self.qdrant_client = QdrantClient()
    
    def process(self, input_data):
        # 1. Preprocess input
        processed = self.preprocess(input_data)
        
        # 2. Generate embeddings
        embeddings = self.generate_embeddings(processed)
        
        # 3. Search vector database
        results = self.search_vectors(embeddings)
        
        # 4. Generate response
        response = self.generate_response(results)
        
        return response
```

### Plugin Development
```javascript
// n8n custom node
export class CustomNode implements INodeType {
    description: INodeTypeDescription = {
        displayName: 'Custom Node',
        name: 'customNode',
        icon: 'file:custom.svg',
        group: ['transform'],
        version: 1,
        description: 'Custom processing node',
        defaults: {
            name: 'Custom Node',
        },
        inputs: ['main'],
        outputs: ['main'],
        properties: [
            {
                displayName: 'Input Field',
                name: 'inputField',
                type: 'string',
                default: '',
                description: 'Input field description',
            },
        ],
    };

    async execute(this: IExecuteFunctions): Promise<INodeExecutionData[][]> {
        // Node execution logic
        return [items];
    }
}
```

## Testing

### Unit Tests
```bash
# Run service tests
docker compose exec openwebui python -m pytest tests/
docker compose exec n8n npm test

# Integration tests
./scripts/test-integration.sh
```

### Load Testing
```bash
# Test API endpoints
./scripts/load-test.sh

# Monitor performance
docker stats
```

### Health Monitoring
```bash
# Service health checks
./scripts/health-check.sh

# Performance metrics
curl http://localhost:3300/api/public/health  # Langfuse
curl http://localhost:6333/health             # Qdrant
```

## Deployment

### Production Build
```bash
# Build production images
docker compose -f docker-compose.prod.yml build

# Deploy to production
docker compose -f docker-compose.prod.yml up -d
```

### Environment Management
```bash
# Development
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# Staging
docker compose -f docker-compose.yml -f docker-compose.staging.yml up -d

# Production
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

## Monitoring and Debugging

### Logging
```bash
# Service logs
docker compose logs -f [service-name]

# Application logs
tail -f logs/init-*.log

# System logs
journalctl -u docker.service -f
```

### Performance Monitoring
```bash
# Resource usage
docker stats

# Network monitoring
docker compose exec [service] netstat -tuln

# Database performance
docker compose exec postgres psql -c "SELECT * FROM pg_stat_activity;"
```

### Debugging Tools
```bash
# Container shell access
docker compose exec [service] /bin/bash

# Database access
docker compose exec postgres psql -U n8n -d n8n

# Redis CLI
docker compose exec redis redis-cli

# Qdrant admin
curl http://localhost:6333/dashboard
```

## Contributing

### Code Style
- **Python**: Follow PEP 8
- **JavaScript**: Use ESLint configuration
- **Docker**: Multi-stage builds, minimal images
- **Documentation**: Markdown with clear examples

### Git Workflow
```bash
# Feature development
git checkout -b feature/new-feature
git commit -m "Add: New feature implementation"
git push origin feature/new-feature

# Create pull request
# After review and approval, merge to main
```

### Release Process
1. **Version bump** in `docker-compose.yml`
2. **Update changelog** in `CHANGELOG.md`
3. **Create release tag**
4. **Deploy to production**

---

**Next Steps**: See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed technical specifications.

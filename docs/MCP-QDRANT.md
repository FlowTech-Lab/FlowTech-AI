# 🔌 MCP-Qdrant Integration Guide

## Overview

The MCP-Qdrant server enables **Cursor AI** to directly interact with your Qdrant vector database through the **Model Context Protocol (MCP)**. This allows Cursor to:

- 📚 **Store code snippets** in Qdrant for contextual retrieval
- 🔍 **Search vector database** for relevant code examples
- 🧠 **Enhance AI responses** with your codebase context
- 💾 **Persist knowledge** across Cursor sessions

## Architecture

```
Cursor IDE → MCP-Qdrant Server → Qdrant Vector Database
     ↓              ↓                       ↓
   User     SSE Transport            cursor-context collection
```

### Key Features

- **🔒 Isolated Collection**: Uses `cursor-context` collection (separate from OpenWebUI/n8n)
- **⚡ Fast Embeddings**: sentence-transformers/all-MiniLM-L6-v2 model
- **🌐 SSE Transport**: Server-Sent Events for real-time communication
- **🔄 Auto-sync**: Automatic synchronization with Qdrant
- **📊 Resource Controlled**: Limited to 0.5 CPU and 1GB RAM

## Service Configuration

### Docker Compose Service

**Implementation**: Uses Python 3.11 slim image with `mcp-server-qdrant` installed via pip/uvx

```yaml
mcp-qdrant:
  image: python:3.11-slim
  container_name: mcp-qdrant
  restart: unless-stopped
  networks:
    - flow-ai-network
  ports:
    - "${MCP_QDRANT_PORT:-8000}:8000"
  environment:
    - QDRANT_URL=http://qdrant:6333
    - COLLECTION_NAME=${MCP_QDRANT_COLLECTION:-cursor-context}
    - EMBEDDING_MODEL=${FASTEMBED_MODEL:-sentence-transformers/all-MiniLM-L6-v2}
    - FASTMCP_PORT=8000
    - FASTMCP_HOST=0.0.0.0
  command: >
    sh -c "pip install --no-cache-dir mcp-server-qdrant &&
           uvx mcp-server-qdrant --transport sse"
  deploy:
    resources:
      limits:
        cpus: '0.5'
        memory: 1G
  depends_on:
    qdrant:
      condition: service_started
```

**Note**: The official `qdrant/mcp-server-qdrant` image doesn't exist yet. We use Python image with runtime installation for maximum flexibility and auto-updates.

### Environment Variables

Add to your `.env` file:

```bash
# MCP-Qdrant Configuration
MCP_QDRANT_COLLECTION=cursor-context
MCP_QDRANT_PORT=8000

# Embedding Model (Ollama)
MCP_EMBEDDING_MODEL=bge-m3:567m
OLLAMA_BASE_URL=http://192.168.0.2:11434

# Alternative models: nomic-embed-text, all-minilm, mxbai-embed-large
```

### Embedding Model: bge-m3:567m (Ollama)

**Default Configuration**: This stack uses **`bge-m3:567m`** via Ollama for high-quality multilingual embeddings.

**Why bge-m3:567m?**
- 🎯 **High Quality**: State-of-the-art multilingual embeddings
- 🌍 **Multilingual**: Supports 100+ languages
- ⚡ **Balanced**: Good performance/quality tradeoff at 567M parameters
- 🔧 **Flexible**: Works seamlessly with the rest of the Ollama stack

**Alternative Ollama Models**:
- `nomic-embed-text`: Lightweight, English-focused
- `all-minilm`: Fast, good for general use
- `mxbai-embed-large`: Higher quality, more resources

## Installation

### Step 1: Update Docker Compose

The service is already included in `docker-compose.yml` after the `qdrant` service.

### Step 2: Validate Configuration

```bash
# Validate docker-compose.yml syntax
docker compose config

# Start the MCP-Qdrant service
docker compose up -d mcp-qdrant

# Check logs
docker logs -f mcp-qdrant
```

### Step 3: Verify Service Health

```bash
# Health check
curl http://localhost:8000/health

# Check Qdrant collection
curl http://localhost:6333/collections/cursor-context
```

## Cursor Configuration

### Client-Side Setup

Create or modify `~/.cursor/mcp.json` on your development machine:

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

**Replace `YOUR_SERVER_IP` with**:
- **Development**: `192.168.0.246` (or your dev VM IP)
- **Production**: Your production VM IP
- **Local**: `localhost` (if Cursor runs on the same machine)

### Network Access

**For LAN Access**:
```yaml
# docker-compose.yml
ports:
  - "8000:8000"  # Accessible from LAN
```

**For Local Access Only** (more secure):
```yaml
# docker-compose.yml
ports:
  - "127.0.0.1:8000:8000"  # Local only
```

## Usage in Cursor

### Store Code Snippets

```
@qdrant store this function:
def process_data(data):
    return data.strip().lower()
```

### Search for Code

```
@qdrant find functions related to: data processing
```

### Retrieve Context

```
@qdrant search for: authentication implementation
```

## Testing

### Test 1: Service Health

```bash
# Check MCP server is running
curl http://localhost:8000/health
# Expected: {"status": "healthy"}
```

### Test 2: Qdrant Collection

```bash
# Verify collection exists
curl http://localhost:6333/collections/cursor-context
# Expected: Collection info with vectors count
```

### Test 3: Store & Retrieve

In Cursor:
```
@qdrant store: "Example code snippet for testing"
@qdrant search: "example code"
```

## Monitoring

### Resource Usage

```bash
# Monitor container resources
docker stats mcp-qdrant

# View logs
docker logs -f mcp-qdrant

# Request count
docker logs mcp-qdrant | grep -E "POST|GET" | wc -l
```

### Qdrant Collections Status

```bash
# List all collections
curl http://localhost:6333/collections

# Check cursor-context collection
curl http://localhost:6333/collections/cursor-context
```

## Troubleshooting

### Common Issues

#### Connection Refused
**Symptom**: Cursor cannot connect to MCP server

**Solution**:
```bash
# Check service is running
docker compose ps mcp-qdrant

# Verify port is accessible
curl http://localhost:8000/health

# Check firewall rules
sudo ufw status
```

#### Collection Not Found
**Symptom**: `cursor-context` collection doesn't exist

**Solution**:
```bash
# MCP server creates collection automatically on first use
# Try storing something in Cursor first

# Manual collection creation (if needed)
curl -X PUT "http://localhost:6333/collections/cursor-context" \
  -H "Content-Type: application/json" \
  -d '{
    "vectors": {
      "size": 384,
      "distance": "Cosine"
    }
  }'
```

#### Performance Issues
**Symptom**: Slow responses or high resource usage

**Solution**:
```bash
# Increase resource limits in docker-compose.yml
deploy:
  resources:
    limits:
      cpus: '1.0'
      memory: 2G

# Restart service
docker compose restart mcp-qdrant
```

## Security Considerations

### Network Isolation

- **Internal Access**: Use internal Docker network
- **External Access**: Secure with firewall rules
- **API Authentication**: Consider adding authentication layer

### Firewall Configuration

```bash
# Allow access only from specific IP (development machine)
sudo ufw allow from 192.168.0.X to any port 8000

# Or restrict to LAN subnet
sudo ufw allow from 192.168.0.0/24 to any port 8000
```

### Production Recommendations

1. **Use HTTPS**: Add reverse proxy with SSL
2. **Add Authentication**: API keys or OAuth
3. **Rate Limiting**: Prevent abuse
4. **Monitoring**: Track usage and errors

## Integration with Existing Services

### Coexistence with OpenWebUI

- **OpenWebUI**: Uses Qdrant for RAG (documents collection)
- **MCP-Qdrant**: Uses dedicated `cursor-context` collection
- **No conflict**: Collections are isolated

### Coexistence with n8n

- **n8n**: Can access Qdrant for agent workflows
- **MCP-Qdrant**: Dedicated for Cursor IDE integration
- **Shared database**: Both use same Qdrant instance

### Embedding Models

**MCP-Qdrant**:
- Model: `sentence-transformers/all-MiniLM-L6-v2`
- Dimensions: 384

**OpenWebUI**:
- Model: `bge-m3:567m` or `qwen3-embedding:0.6b`
- Dimensions: Different from MCP

**Note**: Different embedding models mean vectors are not directly comparable between collections.

## Maintenance

### Backup

```bash
# Qdrant data is in ./AI_Data/qdrant
# Backup includes all collections (cursor-context + others)
tar -czf qdrant-backup-$(date +%Y%m%d).tar.gz AI_Data/qdrant/
```

### Reset Collection

```bash
# Delete cursor-context collection
curl -X DELETE "http://localhost:6333/collections/cursor-context"

# Restart MCP server (will recreate collection)
docker compose restart mcp-qdrant
```

### Update Service

```bash
# Pull latest image
docker compose pull mcp-qdrant

# Restart with new image
docker compose up -d mcp-qdrant
```

## Advanced Configuration

### Custom Embedding Model

Modify `docker-compose.yml`:
```yaml
environment:
  - FASTEMBED_MODEL=sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2
```

### Multiple Collections

Create separate MCP servers for different contexts:
```yaml
mcp-qdrant-code:
  environment:
    - COLLECTION_NAME=cursor-code

mcp-qdrant-docs:
  environment:
    - COLLECTION_NAME=cursor-docs
```

### Resource Optimization

```yaml
# Minimal resources
deploy:
  resources:
    limits:
      cpus: '0.25'
      memory: 512M

# High performance
deploy:
  resources:
    limits:
      cpus: '2.0'
      memory: 4G
```

## References

- **MCP Protocol**: https://modelcontextprotocol.io
- **Qdrant Docs**: https://qdrant.tech/documentation
- **Cursor MCP**: https://docs.cursor.com/mcp

---

**Next Steps**: After setup, see [USER_GUIDE.md](USER_GUIDE.md) for usage examples and best practices.

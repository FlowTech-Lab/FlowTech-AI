# 👤 FlowTech-AI User Guide

## Overview

FlowTech-AI is a comprehensive local AI stack designed for FPV, infrastructure, automation, and documentation tasks. This guide covers how to use the system effectively.

## Getting Started

### Accessing Services

| Service | URL | Purpose | Credentials |
|---------|-----|---------|-------------|
| **OpenWebUI** | http://localhost:8081 | Main AI Interface | Auto-configured |
| **n8n** | http://localhost:5678 | Workflow Orchestrator | Check `.env` file |
| **Langfuse** | http://localhost:3300 | AI Observability | Check `.env` file |
| **SearxNG** | http://localhost:8082 | Web Search | Public access |
| **Qdrant** | http://localhost:6333 | Vector Database | Internal only |

### Default Credentials
Check your `.env` file for current credentials:
```bash
cat .env | grep -E "(USER|PASSWORD|EMAIL)"
```

## OpenWebUI - Main Interface

### Basic Usage
1. **Access**: http://localhost:8081
2. **Start Chat**: Click "New Chat" to begin conversation
3. **Model Selection**: Choose from available Ollama models
4. **Web Search**: Enabled by default via SearxNG

### Advanced Features

#### RAG (Retrieval Augmented Generation)
- **Document Upload**: Upload PDFs, text files, images
- **Auto-Vectorization**: Documents are automatically processed
- **Context Retrieval**: AI uses uploaded documents for responses

#### Pipelines
- **OCR Pipeline**: Extract text from images/PDFs
- **Ingestion Pipeline**: Process and store documents
- **Custom Functions**: Connect to n8n workflows

### Configuration

#### Web Search Setup
1. Go to Admin Panel > Settings > Web Search
2. Configure: `http://searxng:8080/search`
3. Enable "Use web search"

#### Model Management
1. Admin Panel > Models
2. Add Ollama models: `http://192.168.0.2:11434`
3. Recommended models:
   - `qwen2.5:7b` (primary)
   - `llama3.2:3b` (fallback)

## n8n - Workflow Orchestration

### Main Workflows

#### N8N-OpenWebUI Integration
1. **Import Workflow**: `SRC/N8N-openwebui-workflow.json`
2. **Import Function**: `SRC/function-N8N Pipe.json`
3. **Configure Webhook**: `http://n8n:5678/webhook/invoke_n8n_agent`

#### Available Workflows
- **PDF Processing**: OCR and summarization
- **Infrastructure Analysis**: Log analysis and recommendations
- **FPV Documentation**: Technical sheet generation
- **Automation Proposals**: Workflow suggestions

### Using Workflows
1. Access n8n interface
2. Select workflow
3. Configure input parameters
4. Execute manually or via webhook
5. Monitor execution in real-time

## Langfuse - AI Observability

### Key Features
- **Trace Monitoring**: Track AI interactions
- **Performance Metrics**: Latency and error rates
- **Cost Tracking**: Token usage and costs
- **Feedback Collection**: User ratings and improvements

### Setting Up Projects
1. Access Langfuse dashboard
2. Create organization
3. Create project
4. Generate API keys
5. Configure OpenWebUI integration

### Monitoring
- **Dashboard**: Real-time metrics
- **Traces**: Individual AI interactions
- **Analytics**: Usage patterns and performance
- **Alerts**: Error notifications

## Document Management

### Document Types
- **docs_public**: Public documents, auto-vectorized
- **docs_prive**: Private documents, manual approval
- **convos_long**: Long conversation storage

### Upload Process
1. **Via OpenWebUI**: Direct upload in chat
2. **Via n8n**: Automated processing workflows
3. **Manual**: Copy to `AI_Data/docs_*/` directories

### Search and Retrieval
- **Vector Search**: Semantic document search
- **Keyword Search**: Traditional text search
- **Context-Aware**: AI uses relevant documents

## Multi-Agent Workflows

### Agent Types
- **Master Agent**: Coordinates other agents
- **Specialist Agents**: Domain-specific tasks
- **Document Agent**: Handles document processing
- **Search Agent**: Web search and information gathering

### Workflow Examples

#### PDF Analysis Workflow
1. Upload PDF via OpenWebUI
2. OCR pipeline extracts text
3. n8n processes content
4. Specialist agent analyzes
5. Results returned to UI

#### Infrastructure Monitoring
1. Log files uploaded
2. Analysis agent processes logs
3. Recommendations generated
4. Report exported to Nextcloud

## Best Practices

### Performance Optimization
- **Model Selection**: Use appropriate model size
- **Context Management**: Limit conversation history
- **Resource Monitoring**: Watch RAM and CPU usage
- **Regular Cleanup**: Archive old conversations

### Security
- **Local Processing**: All data stays local
- **Access Control**: Use authentication features
- **Backup Strategy**: Regular data backups
- **Network Security**: Limit external access

### Troubleshooting

#### Common Issues
- **Slow Responses**: Check Ollama service
- **Memory Issues**: Restart services
- **Search Failures**: Verify SearxNG status
- **Workflow Errors**: Check n8n logs

#### Getting Help
1. Check service logs: `docker compose logs [service]`
2. Verify service status: `docker compose ps`
3. Review configuration files
4. Check system resources

## Advanced Usage

### Custom Pipelines
1. Define pipeline in OpenWebUI
2. Connect to n8n webhooks
3. Configure processing steps
4. Test and deploy

### API Integration
- **OpenWebUI API**: REST API for automation
- **n8n Webhooks**: Custom integrations
- **Langfuse API**: Monitoring integration
- **Qdrant API**: Vector operations

### Export and Sharing
- **Markdown Export**: Conversation summaries
- **PDF Reports**: Generated documents
- **JSON Data**: Structured data export
- **Nextcloud Sync**: Automated backups

## Tips and Tricks

### Productivity
- **Use Templates**: Save common prompts
- **Batch Processing**: Process multiple documents
- **Scheduled Tasks**: Automate regular workflows
- **Custom Functions**: Create reusable components

### Integration
- **Discord Bot**: Connect via n8n
- **Telegram Integration**: Mobile access
- **Webhook Endpoints**: External system integration
- **Database Connections**: Direct data access

---

**Need Help?** Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) or review [SETUP.md](SETUP.md) for technical details.

# FlowTech-AI Multi-Agent Architecture

## Current Stack and Priorities

### ✅ Operational Services
- **Ollama** (external): Local LLM engine on 192.168.0.2:11434
- **Qdrant**: Central vector memory for RAG and agents
- **PostgreSQL**: Database for n8n + agent states
- **OpenWebUI**: Main interface + pipelines
- **n8n**: Central multi-agent orchestrator
- **SearxNG**: Web search for agents
- **Langfuse**: AI observability and tracing
- **Redis**: Cache and queue management
- **ClickHouse**: Analytics database
- **MinIO**: S3-compatible storage

### 🔄 Services to Deploy
- **Loki**: Centralized logging
- **Prometheus + Grafana**: Monitoring and metrics

---

## Multi-Agent Roles in n8n + Qwen3 System

### 1. Master Agent (Central Agent / Brain)
**Primary Role**: Coordinates and orchestrates requests.

**Functions**:
- Distributes and delegates tasks to specialized agents
- Manages global memory or shared context (vectorDB integration)
- Synthesizes and compiles responses from junior agents
- Applies business logic and priorities

**Ideal Model**: Qwen3 8B (better comprehension, synthesis, extended context management)

**Example**: Receive a composite request, analyze intent, demultiplex to specialists, and aggregate returns.

### 2. Documentation Agent (Doc Agent)
**Primary Role**: Access and manipulation of vectorized documentation.

**Functions**:
- Direct interface with vector database (Qdrant, Chroma, Supabase)
- Search, extraction, summary, and contextualization on business documents (PDF, markdown, handbook, logs)
- Can pre-filter documentation for the master agent

**Ideal Model**: DeepSeek R1 (compact, specialized in text/document processing)

**Example**: Quickly find technical procedures, extract client data, qualify support examples.

### 3. Research Agent (Internet Search)
**Primary Role**: Real-time Internet search.

**Functions**:
- Query Search APIs (SearxNG, Bing, Wikipedia, forums)
- Aggregate and synthesize fresh information
- Validate or complete information on novelty or trends

**Ideal Model**: Qwen3 4B, or OpenAI GPT-4 (faster on short queries)

**Example**: Find latest regulatory updates or product novelties.

### 4. Code/Automation Agent
**Primary Role**: Script generation and execution, playbooks, snippets, infra configurations.

**Functions**:
- Write Bash scripts, YAML Ansible, Terraform Playbooks, Proxmox commands
- Control syntax, logic, and automation best practices
- Technical validation before application

**Ideal Model**: Qwen3 4B (sufficiently performant for code, lightweight)

**Example**: Automatically generate VLAN deployment playbook, monitoring script, or alerts.

### 5. Specialist / Expert Agents (optional)
**Role**: Specialized agents by domain (ex: Security, Support, Home Automation).

**Functions**:
- Receive specialized prompt, respond with sharp expertise
- Can be used by master for complex task delegation

## Best Practices Summary
- **Clear responsibility separation**: Each agent has precise scope and its tools
- **Communication via n8n nodes/sub-workflows**: Master agent creates task, waits for response
- **Shared vector memory**: Promotes consistency and shared histories, especially for documentation
- **Model choice adapted to task**: Qwen3:8B for master/doc, Qwen3:4B or lightweight models for short searches and scripting
- **Human supervision and control possible**: Via n8n hooks or notifications before critical execution

## Implementation Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    OpenWebUI (Main UI)                     │
│              - User Interface                              │
│              - Pipeline Management                         │
│              - RLHF Feedback                               │
└─────────────────────┬───────────────────────────────────────┘
                      │ Webhook
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                    n8n Orchestrator                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │Master Agent │  │ Doc Agent   │  │Research Agent│        │
│  │(Qwen3 8B)   │  │(DeepSeek R1)│  │(Qwen3 4B)   │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │Code Agent   │  │Specialist   │  │Merge Node   │        │
│  │(Qwen3 4B)   │  │Agents       │  │(Response    │        │
│  └─────────────┘  └─────────────┘  │ Aggregation)│        │
└─────────────────────┬───────────────┴─────────────┘        │
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│                    Data Layer                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │   Qdrant    │  │ PostgreSQL  │  │    Redis    │        │
│  │(Vector DB)  │  │(Agent State)│  │   (Cache)   │        │
│  └─────────────┘  └─────────────┘  └─────────────┘        │
└─────────────────────────────────────────────────────────────┘
```

## Agent Communication Flow

1. **User Request** → OpenWebUI
2. **Request Analysis** → Master Agent (Qwen3 8B)
3. **Task Distribution** → Specialized Agents
4. **Parallel Execution** → Doc, Research, Code Agents
5. **Response Aggregation** → Merge Node
6. **Final Response** → OpenWebUI → User

## Data Flow

- **Short-term Memory**: OpenWebUI (20 messages)
- **Long-term Memory**: Qdrant (vectorized conversations, documents)
- **Agent State**: PostgreSQL (workflow persistence)
- **Cache**: Redis (embedding cache, queue management)
- **Observability**: Langfuse (prompt tracing, latency monitoring)

## Configuration Requirements

### OpenWebUI
- Enable RAG pipeline with Qdrant
- Configure webhook endpoints for n8n
- Set up RLHF feedback collection

### n8n
- Configure webhook triggers
- Set up agent workflows
- Enable PostgreSQL for state persistence
- Configure HMAC webhook security

### Qdrant
- Create collections: `docs_public`, `docs_prive`, `convos_long`
- Configure vector dimensions for chosen embedding model
- Set up proper indexing and filtering

### PostgreSQL
- Create tables for agent state management
- Configure connection pooling
- Set up backup and recovery procedures

## Monitoring and Observability

### Langfuse Integration
- Track all agent interactions
- Monitor response latencies
- Log errors and performance metrics
- Generate usage reports

### Health Checks
- Agent availability monitoring
- Database connection status
- Vector database health
- Cache performance metrics

## Security Considerations

- **Webhook Security**: HMAC signatures for all n8n webhooks
- **Rate Limiting**: 20 requests/minute per IP
- **Access Control**: RBAC for OpenWebUI
- **Data Privacy**: Local processing by default
- **Audit Trail**: Complete logging via Langfuse

---

*This architecture provides a robust foundation for multi-agent AI workflows while maintaining security, observability, and scalability.*
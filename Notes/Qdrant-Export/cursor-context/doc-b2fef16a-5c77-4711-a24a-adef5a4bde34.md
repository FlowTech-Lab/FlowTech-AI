---
collection: cursor-context
exported_at: '2026-01-11T22:30:22.025214'
id: b2fef16a-5c77-4711-a24a-adef5a4bde34
meta_type: integration
title: doc-b2fef16a-5c77-4711-a24a-adef5a4bde34
---

FlowTech-AI n8n Integration Examples:
- n8n to Ollama: POST to http://ollama:11434/api/generate
- n8n to Qdrant: POST to http://qdrant:6333/collections/my-collection/points/search
- n8n to SearxNG: GET to http://searxng:8080/search
- OpenWebUI to Ollama: Set OLLAMA_BASE_URL in .env (default: http://ollama:11434, configurable for remote servers)
- n8n authentication: Uses N8N_BASIC_AUTH_USER and N8N_BASIC_AUTH_PASSWORD from .env
- n8n database: PostgreSQL connection via DB_POSTGRESDB_* environment variables
- n8n workflow import: SRC/FlowTech-AI-Complete-Workflow.json
- Access n8n: http://localhost:5678 (external) or http://n8n:5678 (internal)
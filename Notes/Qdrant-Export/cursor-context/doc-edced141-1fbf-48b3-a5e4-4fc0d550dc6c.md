---
collection: cursor-context
exported_at: '2026-01-11T22:30:22.093192'
id: edced141-1fbf-48b3-a5e4-4fc0d550dc6c
meta_type: configuration
title: doc-edced141-1fbf-48b3-a5e4-4fc0d550dc6c
---

FlowTech-AI Service URLs (Docker Internal Network):
- Ollama: http://ollama:11434 (No auth, LLM inference API)
- OpenWebUI: http://openwebui:8080 (Web UI auth, AI chat interface)
- Qdrant: http://qdrant:6333 (No auth, vector database)
- PostgreSQL: postgresql://postgres:5432/n8n (Auth: POSTGRES_USER/POSTGRES_PASSWORD)
- Redis: redis://redis:6379 (No auth, internal only)
- SearxNG: http://searxng:8080 (No auth, web search)
- Langfuse: http://langfuse:3000 (Web UI auth: LANGFUSE_INIT_USER_EMAIL/LANGFUSE_INIT_USER_PASSWORD)
- n8n: http://n8n:5678 (Web UI auth: N8N_BASIC_AUTH_USER/N8N_BASIC_AUTH_PASSWORD)
- MCP-Qdrant: http://mcp-qdrant:8000 (No auth, Cursor context)
- MCP-Knowledge: http://mcp-qdrant-knowledge:8001 (No auth, Cursor knowledge)
- Samba: smb://YOUR_IP/notes (Auth: admin/SAMBA_PASSWORD)
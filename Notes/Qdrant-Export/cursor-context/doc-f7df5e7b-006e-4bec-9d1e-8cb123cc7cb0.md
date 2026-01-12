---
collection: cursor-context
exported_at: '2026-01-11T22:30:22.097033'
id: f7df5e7b-006e-4bec-9d1e-8cb123cc7cb0
title: doc-f7df5e7b-006e-4bec-9d1e-8cb123cc7cb0
---

COMPLETE CONSOLIDATION OF QDRANT, VECTOR DATABASES, AND MCP KNOWLEDGE

=== QDRANT VECTOR DATABASE ARCHITECTURE ===
Core Infrastructure:
- Server: 192.168.0.252:6333 (VM prod FlowTech-AI)
- Collections: cursor-knowledge (permanent), cursor-context (session)
- Embedding Model: BAAI/bge-large-en-v1.5 (1024 dimensions)
- Performance: <100k vectors <50ms, <300k vectors <100ms, <1M vectors <200ms

=== MCP (MODEL CONTEXT PROTOCOL) CONFIGURATION ===
Two MCP Servers Architecture:
- mcp-qdrant-context (port 8000): Session data, read-write, TTL 7 days
- mcp-qdrant-knowledge (port 8001): Permanent base, read-only, documentation

Working Syntax (CRITICAL):
✅ CORRECT: mcp_qdrant-context_qdrant-store with information only (NO metadata)
❌ FAILS: Any metadata parameter causes "got string" serialization error

=== MEMORY MANAGEMENT STRATEGY ===
Dual Memory Architecture:
- cursor-knowledge: Permanent base, French/English, score ≥0.75, manual updates
- cursor-context: Session data, ENGLISH ONLY, score ≥0.70, TTL 24h, auto-cleanup

TTL Implementation (NO NATIVE QDRANT TTL):
- Metadata approach: expires_at in payload + cron job purge
- Python script: daily DELETE with filter expires_at<now()
- Promotion criteria: access_count ≥3 OR tags #important/#decision

=== FLOWTECH-AI STACK COMPONENTS ===
Production Stack (VM 252):
- OpenWebUI: 8081 (AI chat interface)
- MCP-Qdrant: 8000 (Cursor context)
- MCP-Knowledge: 8001 (Cursor knowledge)
- n8n: 5678 (Workflow automation)
- Qdrant: 6333 (Vector database)
- Langfuse: 3300 (LLM observability)
- SearxNG: 8082 (Web search)
- PostgreSQL: 5432 (Database)
- Redis: 6379 (Cache)
- MinIO: 9092 (S3 storage)
- ClickHouse: 8123 (Analytics)

=== CRITICAL RULES VALIDATED ===
1. Context storage MUST be in ENGLISH only
2. NO metadata parameter for context (serialization bug)
3. Knowledge base supports full metadata
4. Search strategy: Knowledge first (≥0.75), then Context (≥0.70)
5. TTL requires custom implementation (no native Qdrant TTL)

=== PRODUCTION RECOMMENDATIONS ===
For 50K files/day pipeline:
- PostgreSQL: Business metadata and complex queries
- Qdrant: Vector search with payload filtering
- Redis: LRU cache (TTL 24h)
- MCP Context: Session state (text-only workaround)
- MCP Knowledge: Documentation with full metadata

This consolidation represents the complete validated knowledge base for Qdrant, MCP, and FlowTech-AI architecture.
---
collection: cursor-context
exported_at: '2026-01-11T22:30:22.024976'
id: b1c48dea-28ba-4b26-b4fb-fab6f537eabf
title: doc-b1c48dea-28ba-4b26-b4fb-fab6f537eabf
---

PERPLEXITY PROMPT OPTIMIZATION - MCP QDRANT FIRST-TIME SUCCESS

=== CRITICAL MCP QDRANT CONFIGURATION REQUIREMENTS ===
Based on extensive testing and community validation, the following configuration ensures first-time success:

1. MCP SERVER CONFIGURATION (CRITICAL):
- Two separate MCP servers: mcp-qdrant-context (port 8000) and mcp-qdrant-knowledge (port 8001)
- Context server: Session data, read-write, TTL 7 days, ENGLISH ONLY
- Knowledge server: Permanent base, read-only, documentation, French/English
- Qdrant URL: http://192.168.0.252:6333 (VM prod FlowTech-AI)
- Collections: cursor-context and cursor-knowledge with named vectors

2. SYNTAX REQUIREMENTS (VALIDATED):
✅ CORRECT: mcp_qdrant-context_qdrant-store with information only (NO metadata)
❌ FAILS: Any metadata parameter causes "got string" serialization error
✅ KNOWLEDGE: mcp_qdrant-knowledge_qdrant-store with full metadata support

3. LANGUAGE REQUIREMENTS:
- Context storage: ENGLISH ONLY (better embedding quality)
- Knowledge storage: French/English supported
- Documentation: French in .md files, English in Qdrant

4. PERFORMANCE OPTIMIZATION:
- Score thresholds: Knowledge ≥0.75, Context ≥0.70
- Search strategy: Knowledge first, then Context fallback
- Batch processing: 50-100 vectors per batch
- Cache: Redis LRU 24h for frequent queries

5. PRODUCTION ARCHITECTURE:
- PostgreSQL: Business metadata and complex queries
- Qdrant: Vector search with payload filtering
- Redis: LRU cache (TTL 24h)
- MCP Context: Session state (text-only workaround)
- MCP Knowledge: Documentation with full metadata

This configuration has been tested and validated for first-time success in production environments.
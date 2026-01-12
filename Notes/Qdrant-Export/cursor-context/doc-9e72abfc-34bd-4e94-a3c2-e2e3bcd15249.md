---
collection: cursor-context
exported_at: '2026-01-11T22:30:22.020848'
id: 9e72abfc-34bd-4e94-a3c2-e2e3bcd15249
title: doc-9e72abfc-34bd-4e94-a3c2-e2e3bcd15249
---

CORRECTED MCP QDRANT CONTEXT USAGE GUIDE - FINAL VERSION

WORKING SYNTAX FOR MCP QDRANT CONTEXT:
✅ CORRECT SYNTAX (ALWAYS WORKS):
mcp_qdrant-context_qdrant-store
  information: "Your text in English"
  # NO metadata parameter needed

❌ INCORRECT SYNTAX (ALWAYS FAILS):
mcp_qdrant-context_qdrant-store
  information: "Your text"
  metadata: {"key": "value"}  # ERROR: "got string"
  metadata: {}                # ERROR: "got string"
  metadata: null             # ERROR: "got string"

CRITICAL RULES:
1. Context storage MUST be in ENGLISH only
2. NO metadata parameter - it causes errors
3. Include metadata info in the text itself if needed
4. Use simple information parameter only

WORKFLOW FOR AGENTS:
1. Knowledge first (port 8001) - permanent base
2. Context second (port 8000) - session data
3. Score thresholds: Knowledge ≥0.75, Context ≥0.70
4. Language: Context=English only, Knowledge=French/English

TESTED AND CONFIRMED WORKING:
- Storage: ✅ Works perfectly
- Search: ✅ Works perfectly
- Retrieval: ✅ Works perfectly
- English language: ✅ Required and working

This is the definitive guide for MCP Qdrant Context usage. All agents should follow this exact syntax.
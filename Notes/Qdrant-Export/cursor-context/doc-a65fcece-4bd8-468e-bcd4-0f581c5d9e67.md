---
collection: cursor-context
exported_at: '2026-01-11T22:30:22.022427'
id: a65fcece-4bd8-468e-bcd4-0f581c5d9e67
meta_date: '2025-01-20'
meta_source: community-recommendations
meta_type: strategy-update
title: doc-a65fcece-4bd8-468e-bcd4-0f581c5d9e67
---

New TTL and retention strategy for cursor-context: 7 days optimal for DevOps solo. Differentiated TTL by content type: code snippets 7d, conversation history 3d, technical decisions (ADR) 30d, project intermediate states 14d, debug logs 7d. Automatic promotion to cursor-knowledge when accessed ≥3 times in 7 days or tagged #important/#decision. n8n workflow handles promotion and cleanup. Qdrant performance thresholds on Proxmox VM (4 vCPU, 8GB RAM): <100k vectors <50ms, <300k vectors <100ms, <1M vectors <200ms. Weekly/monthly review for cleanup and optimization.
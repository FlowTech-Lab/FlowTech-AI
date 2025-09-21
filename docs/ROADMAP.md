# FlowTech-AI Deployment Roadmap

## Main Recommendation
Strengthen foundations first (native RAG, pipelines, traceability) before industrializing multi-agent orchestration then opening specializations. This sequence offers quick returns, stable foundation, and progressive scaling.

## Step 1 – Foundations & Quick Wins (Days 0–30)
- ✅ **Optimized init.sh script** - Sequential startup, DEV mode, error handling
- ✅ **Operational core stack** - Qdrant, PostgreSQL, OpenWebUI, n8n, SearxNG functional
- ✅ **Langfuse integration** - AI observability and tracing operational
- ✅ **Redis, ClickHouse, MinIO** - Support services operational
- ✅ **Enable native RAG + OpenWebUI Pipelines** (OCR, ingestion, RLHF); configure `VECTOR_DB`/`RAG_VECTOR_DB`
- ⬜ **Create data directories aligned with Qdrant**
  - `/AI_Data/docs_public/` → auto-vectorized content (guides, technical docs, general logs) → Qdrant `docs_public`
  - `/AI_Data/docs_prive/` → sensitive files, vectorization only with manual approval → Qdrant `docs_prive`
  - `/AI_Data/convos_long/` → raw storage of long conversations (logging), relayed to Qdrant `convos_long` by n8n
- ⬜ **Deploy Loki** for collecting n8n/OpenWebUI logs (current stack limited to Prometheus/Grafana on external VM, not connected)
- ⬜ **Implement HMAC-signed n8n webhooks + OpenWebUI RBAC** (n8n Basic Auth already enabled, but HMAC/Rate-limit/RBAC not documented)
- ✅ **Validate "PDF/log summary" pipeline**: OpenWebUI → OCR pipeline → n8n summary agent webhook → UI return

## Step 2 – Orchestration & Security (Month 2)
- ⬜ **Configure n8n in pipe mode** Qwen3:8B for everything (master, specialist, doc, code, search) DeepSeek-R1 for vector ingestion executed in parallel then merged
- ✅ **Add agent state persistence in PostgreSQL** (`docker-compose.yml` already configures n8n on PostgreSQL via `DB_POSTGRESDB_*`)
- ⬜ **Automate semiannual secret rotation** via n8n reminder + `.env` updates
- ⬜ **Enable rate-limit (20 req/min/IP) on webhooks** in addition to HMAC
- ⬜ **Implement nightly OCR ingestion** (heavy PDFs) with `qdrant-snapshot`/`pg_dump` before PBS/Proxmox
- ⬜ **Produce first monthly Langfuse reports** (latency, errors, feedback) exported to Nextcloud

## Step 3 – Ops & Knowledge (Month 3)
- ⬜ **Auto-generate infra wiki** (Markdown) via n8n → Nextcloud/GitHub publication
- ⬜ **Extend Qdrant segmentation** by project/sensitivity + default settings `top_k=5`, `min_score=0.78`, `max_context_tokens=3000`
- ⬜ **Deploy Prometheus + Grafana + Loki** with unified dashboards (n8n, OpenWebUI, Ollama) and alerts connected to n8n
- ⬜ **Record AI feedback** and prepare RLHF dataset usable for future fine-tuning

## Step 4 – Specialization (3–6 months)
- ⬜ **Deliver complete Flow Tuning FPV pipeline** (Blackbox upload → AI analysis → Markdown report)
- ⬜ **Transition from 1 to 3–5 specialized n8n agents** (PDF summary, SearxNG summary, log summary, tuning, monitoring)
- ⬜ **Connect Prometheus/Grafana to n8n** for enriched alerts (Discord/Telegram) and validations in security pipeline
- ⬜ **Validate semi-autonomous agents** capable of chaining multiple actions with safeguards

## Step 5 – Advanced (>6 months)
- ⬜ **Integrate Trading-LAB (Freqtrade)** for backtests and AI-orchestrated analyses
- ⬜ **Extend to multi-interface** (Telegram, WhatsApp) via n8n pipelines
- ⬜ **Experiment with Flowise, Neo4j, Vault** and other optional services once Langfuse + RBAC + HMAC stabilized
- ⬜ **Evaluate k3s/GitOps** if multi-user load requires evolution beyond Docker Compose

---

### Current Quick Status
- ✅ **Operational core stack**: Qdrant, OpenWebUI, n8n, PostgreSQL, SearxNG functional
- ✅ **Optimized init.sh script**: Sequential startup, DEV mode, error handling, automatic chmod
- ✅ **Langfuse 3.x**: Installed and operational with ClickHouse, Redis, MinIO integration
- ✅ **Ollama**: Installed external to stack (192.168.0.2:11434) - CRITICAL for system
- ✅ **Native RAG**: Enabled in OpenWebUI (VECTOR_DB/Qdrant)
- ⬜ **Loki**: To deploy for centralized logging
- ⬜ **HMAC/RBAC**: To implement (n8n Basic Auth already enabled)
- ❌ **Removed services**: ClickHouse, ComfyUI, Piper, Vault, Neo4j, Flowise, Supabase, RabbitMQ/Kafka
- 📋 **Documentation**: Updated with prioritized stack and technical modifications

### Implementation Notes
- **Official Langfuse Configuration**: Based on [Langfuse Official Docker Compose](https://github.com/langfuse/langfuse/blob/main/docker-compose.yml)
- **Service Dependencies**: Proper startup order with health checks implemented
- **Data Persistence**: All data stored in `./AI_Data/` directory structure
- **Network Security**: Services communicate via internal Docker network
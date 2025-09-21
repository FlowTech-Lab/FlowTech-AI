# 📌 Technical Specifications - FlowTech-AI

## 1. Vision & Objectives
- **Primary Goal**: Deploy a local AI system capable of assisting FlowTech with FPV, infrastructure, automation, and documentation tasks
- **Usage**: Strictly private, local execution by default; occasional cloud access (RTX 4070 Super) only after validation
- **Master Interface**: OpenWebUI for conversation (pipeline enabled); n8n operates as multi-interface hub (Discord, Telegram, website) and orchestrates long-running tasks
- **Expected Capabilities**: Action plans, summaries (PDF, logs, incidents), technical sheets, automation proposals, exportable Markdown generation (Nextcloud, GitHub)
- **Feedback Loop**: Native OpenWebUI RLHF (👍/👎) with JSON exports to create training datasets
- **Traceability**: n8n journal of read/write operations, Langfuse for tracing prompts/latencies/errors from Quick Wins phase, unlimited retention via periodic summaries and manual purging

## 2. Architecture & Deployment

### 2.1 Target Infrastructure
- **Proxmox**: Two distinct VMs (Dev/Prod) for AI stack, extensible resources
- **Nextcloud**: Remains hosted on OpenMediaVault
- **GPU**: NVIDIA Container Toolkit operational; GTX 1660 Ti dedicated to Ollama (prod), RTX 4070 Super mobilized occasionally (manual routing)
- **Backups**: Proxmox Backup Server covers `./AI_Data/openwebui`, `./AI_Data/n8n`, `./AI_Data/qdrant`, `./AI_Data/pgdata`

### 2.2 Services & Interconnections
- **Orchestration**: Stack maintained on Docker Compose (Kubernetes/k3s not retained at this stage)
- **OpenWebUI**: Main UI, native pipelines and RAG enabled (`VECTOR_DB=qdrant`, `RAG_VECTOR_DB=qdrant`, `CHAT_HISTORY_LIMIT=20`). OpenWebUI doesn't write chat history to Qdrant and only uses document collections (`docs_public`, `docs_prive`). Long-term conversation memory is managed by n8n in the `convos_long` collection. Custom Python pipelines for OCR, ingestion, specialized agents
- **Ollama**: Local models (`Qwen2.5-7B-Instruct` default, `Llama-3-3B` fallback); simple routing, option to force 7B and external GPU delegation. Tests of quantizations (`Q4_K_M`, `Q8`) planned for Qwen2.5-7B with P95/P99 latency measurement via Langfuse; Triton/FasterTransformers not retained at this stage (GPU 1660 Ti)
- **n8n**: Main orchestrator, internal webhooks (`/webhook/owui-router`), runners enabled, agent state storage in Postgres for long-running workflows
- **Qdrant**: Vector memory (public/safe/private spaces); not exposed, accessible from OpenWebUI and n8n via internal network. Possibility to add Redis or Memcached if embedding latency becomes a friction point
- **PostgreSQL**: n8n database + agent/pipe state persistence, LAN-only
- **SearxNG**: Search engine; exposable via Cloudflare if needed
- **Prometheus/Grafana**: Existing VM, OpenWebUI metrics export (HTTP exporter), n8n and Ollama; alerts routed by n8n to Discord/Telegram
- **Network**: Minimal exposure via pfSense/Cloudflare Zero Trust (if remote access); IP allowlist between VMs for OWUI ⇄ n8n ⇄ Qdrant/Postgres. Keycloak or Authelia can be introduced later if MFA/SSO need appears, without immediate priority

### 2.3 Volumes & Environments
- Dynamic volumes co-located with `docker-compose.yml` (`./AI_Data/...`)
- Distinct `.env` files for Dev/Prod (Ollama URL, secrets, ports, webhook keys) with semiannual rotation
- `settings.yml` managed for SearxNG (limiter disabled locally, OCR and DOI configured)
- OpenWebUI Pipeline activation to connect automations to n8n workflows

### 2.4 Multi-Agents & Pipelines
- OpenWebUI handles short ingestion (high top_k) and delegates to n8n for multi-agent workflows
- n8n `Webhook Trigger` + `Merge` nodes to aggregate responses (PDF, infra, FPV) and return unified result to UI
- Agent context storage in Postgres (Database node) for conversation resumption and deferred tasks

### 2.5 Compliance Controls
- OpenWebUI: Native RAG + pipeline enabled, history limited to 20 messages, RBAC enabled to limit pipeline actions
- Qdrant: Non-exposed ports, public/safe/private segmentation, tags by project (FPV, infra, dev, etc.)
- n8n: LAN access, Basic Auth + `WEBHOOK_SECRET`, HMAC-signed webhooks and rate-limited
- PBS: Critical volume backup + quarterly restoration tests

### 2.6 Observability
- Langfuse deployed from Quick Wins phase to trace prompts, latencies (P95/P99) and errors
- Prometheus + Grafana + Loki to unify metrics and logs (n8n, OpenWebUI, Ollama) and feed dashboards
- Monthly automated report via n8n (Markdown/PDF) exported to Nextcloud to track performance and incidents

## 3. File & Data Management

### 3.1 Vectorization Priorities
- **In**: Markdown, PDF, JSON/YAML (Betaflight, infra configs), text logs (Blackbox, FPV systems)
- **Out**: Complete source code, videos, firmware binaries (storage without vectorization)

### 3.2 Ingestion & OCR
- **OpenWebUI Pipeline**: Direct ingestion (OCR + embeddings) of documents dropped in monitored folders, high top_k for fast responses
- **Scheduled n8n Task**: Nightly scan of new files → heavy pre-embeddings (large PDFs) to relieve runtime queries
- **OCR**: Tesseract/OCRmyPDF triggered via OpenWebUI pipeline or n8n agent depending on scenario, ingestion report returned to UI

### 3.3 Organization & Editing
- Hybrid mode:
  - "Safe" folders → direct writing (OpenWebUI pipeline or n8n)
  - Sensitive folders → diff flow → Discord/OpenWebUI approval → writing
- Automatic organization (tagging/renaming) handled by n8n pipeline during Knowledge & Memory phase
- Nextcloud spaces: `/FPV_Public/` (auto-vectorization), `/FPV_Privé/` (manual vectorization, explicit exclusions)

### 3.4 Reporting & Monitoring
- n8n generates monthly report (Markdown/PDF) summarizing new documents, created embeddings and ingestion errors → Nextcloud export

## 4. AI Intelligence & Workflows

### 4.1 Memory & RAG
- **OpenWebUI**: Short memory (20 messages) + native RAG (adaptable top_k) with pipeline heuristics; integrated RLHF to refine responses
- **Qdrant**: Long memory, segmentation by project and sensitivity; tags to retrieve conversations and sources. Weaviate multimodal can be evaluated if vision+text need appears
- **n8n**: Triggers long RAG (reduced top_k, tag filters) when pipeline heuristic indicates extended context need

### 4.2 Multi-Agent Orchestration
- n8n pipeline orchestration:
  1. Main agent (router) receives OpenWebUI request via webhook
  2. Specialized agents (PDF/log summary, infra monitoring, FPV tuning, SearxNG search) execute in parallel
  3. `Merge` node assembles responses, adds used sources, returns to OpenWebUI
- Agent state persistence in Postgres for long-running workflows (ex: Freqtrade backtest, heavy log analysis)
- Possibility to embed MCP if future need, but pipeline priority for isolated context flexibility

### 4.3 Feedback & Improvement
- OpenWebUI RLHF feeds exportable dataset; n8n records feedback in Qdrant (tag "feedback") without automatic score modification
- Automatic test pipeline (n8n) to replay critical prompts and validate agents after update

### 4.4 Traceability & Monitoring
- Langfuse deployed from Quick Wins: collects prompts, latencies, errors, RAG sources
- n8n produces monthly report (Markdown + PDF export) with response time, errors, RAG sources, feedback
- n8n alerts → Discord/Telegram: latency exceeded, pipeline failure, unavailable sources

## 5. Security & Access

### 5.1 Exposure & Authentication
- No SSO (Traefik/Authelia removed); native auth + OpenWebUI RBAC enabled mandatory from deployment (Admin/Editor/User roles)
- OpenWebUI & n8n behind Cloudflare Zero Trust only if remote access; otherwise LAN-only
- SearxNG: exposed via Cloudflare if external usage, otherwise LAN
- Grafana/Prometheus: LAN by default; restricted access by firewall
- Discord: approval channel (role `Approver`) + incident notifications

### 5.2 Secret Management
- Secrets in encrypted `.env`, backed up in PBS; semiannual rotation automated by n8n reminder
- Automatic masking (n8n Code nodes) before logging or storage for any PII/key/secret; prohibition of inserting secrets in prompts

### 5.3 Validation & Hardening
- Critical flow: OpenWebUI → pipeline → n8n → Discord Approve/Reject → execution
- Covered actions: sensitive file modifications, snapshots/reboots, deployments, destructive automations
- n8n webhooks: mandatory LAN-only, HMAC-signed and protected by 20 req/min/IP rate-limit, with automatic conversation history purge beyond 20 exchanges
- Community Leaderboard: enabled only for admins to verify response quality before diffusion
- Updates: monthly container patches, quarterly dependency and custom pipeline review

### 5.4 Logging
- n8n: logs who/what/when + minimal payload (90-day retention)
- OpenWebUI: short-term prompts/outputs; summaries sent to Qdrant (cleaned text)
- Langfuse: complete prompt audit, latencies, RAG sources

## 6. FlowTech Integrations

### 6.1 Nextcloud
- `/FPV_Public/` and `/FPV_Privé/` directories with webhooks to OpenWebUI pipeline and n8n
- Selective vectorization (auto vs manual) + monthly ingestion reporting

### 6.2 Proxmox
- n8n reads VM state (CPU/RAM/disk) and schedules snapshots; execution after Discord approval
- Incident pipeline: Prometheus alerts → n8n → AI summary → Discord

### 6.3 Docker & Services
- n8n provides container/logs view, restarts on approval
- Grafana/Prometheus export: unified dashboards, incident summaries via n8n

### 6.4 FPV & Specific Projects
- **Flow Tuning FPV**: Complete pipeline (Blackbox upload → OpenWebUI OCR/RAG pipeline → n8n tuning agent → Markdown report)
- **Trading-LAB (Freqtrade)**: Triggered after stabilization (agents to launch backtests, analyze results, recommendations)
- **Other projects (EUC, archery, ARK, etc.)**: Documentation + simple alerts via dedicated pipelines
- **Infra journal**: n8n generates wiki Markdown of changes (VM, Docker, services) stored Nextcloud/GitHub

## 7. Deployment Plan & Roadmap

### Step 1 – Quick Wins (Days 0–30)
- Enable native RAG & OpenWebUI pipelines (OCR, ingestion, RLHF)
- Connect Langfuse, OpenWebUI ⇄ n8n pipeline (PDF, mail, log agents)
- Configure n8n multi-agent (Webhook → Merge → UI return) and validate document summary flow
- Set up Nextcloud directories (`/FPV_Public/`, `/FPV_Privé/`) + basic vectorization

### Step 2 – Ops & Infra (Month 2)
- Automate Proxmox snapshots & infra reporting (n8n → Discord)
- Nightly OCR ingestion + heavy embeddings via n8n agents
- System alerts (Proxmox/Docker) summarized by AI pipeline; critical action validation Discord operational

### Step 3 – Knowledge & Memory (Month 3)
- Auto-generated infra wiki (Markdown) fed by n8n + GitHub/Nextcloud publication
- Automated tagging/renaming of new docs; fine Qdrant segmentation by project/sensitivity
- AI feedback logged and exploitable for future fine-tuning; monthly Langfuse report → Nextcloud

### Step 4 – Specializations (>3 months)
- Complete Flow Tuning FPV pipeline (PID analysis, recommendations)
- Complete monitoring: Prometheus/Grafana connected, alerts enriched via n8n
- Transition from 1 n8n agent to 3–5 specialized agents (summary, search, analysis, tuning, monitoring)
- Semi-autonomous agents capable of chaining multiple validated actions

### Step 5 – Advanced Experimentation
- Trading-LAB integration (backtests, AI analysis)
- Multi-interface extension (Telegram, WhatsApp) via n8n pipelines
- Continuous optimization via RLHF + Langfuse (training dataset, heuristic adjustment)

## 8. Services & Prioritization

### Recommended and Prioritized Stack

#### Phase 1 - Core Stack (Immediate Deployment)
| Priority | Service | Justification | Status |
|----------|---------|---------------|--------|
| 1 | **Ollama** (external) | CRITICAL - Local LLM engine required for entire system | ✅ Installed |
| 2 | **Qdrant** | Central vector memory for RAG and agents | ✅ Operational |
| 3 | **PostgreSQL** | Database for n8n + agent states | ✅ Operational |
| 4 | **OpenWebUI** | Main interface + pipelines | ✅ Operational |
| 5 | **n8n** | Central multi-agent orchestrator | ✅ Operational |
| 6 | **Langfuse** | Mandatory traceability from start (Quick Wins) | ✅ Operational |

#### Phase 2 - Support Services (Weeks 2-4)
| Priority | Service | Usage | Status |
|----------|---------|-------|--------|
| 7 | **Redis** | Embedding cache + n8n queues | ✅ Operational |
| 8 | **ClickHouse** | Analytics database | ✅ Operational |
| 9 | **MinIO** | S3-compatible storage | ✅ Operational |
| 10 | **SearxNG** | Web search for agents | ✅ Operational |

#### Phase 3 - Specializations (Months 2-3)
| Priority | Service | Specialized Usage | Status |
|----------|---------|------------------|--------|
| 11 | **Whisper** | Audio transcription for workflows | 🔄 To implement |
| 12 | **Tesseract/OCR** | Document pipeline (via n8n) | 🔄 To implement |
| 13 | **Prometheus + Grafana** | Existing infra monitoring | 🔄 To implement |

### Recent Technical Modifications
- **Langfuse 3.x**: Version compatible with ClickHouse, Redis, and MinIO
- **Official Configuration**: Based on [Langfuse Official Docker Compose](https://github.com/langfuse/langfuse/blob/main/docker-compose.yml)
- **Sequential Startup**: Optimized service startup order with health checks
- **DEV Mode**: Optional complete reset (.env, AI_Data, logs) for development

---

This technical specification reflects the current architecture, operational priorities, and roadmap of the FlowTech personal AI system. Any major evolution (new services, external exposure, critical automations) must be validated then documented in the infra wiki.
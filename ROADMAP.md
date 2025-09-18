# Ordre optimisé de déploiement de la stack IA FlowTech

## Recommandation principale
Commencer par renforcer les fondations (RAG natif, pipelines, traçabilité) avant d’étendre l’orchestration multi-agents puis les services spécialisés. Cette progression offre des retours rapides, stabilise le socle et permet une montée en charge maîtrisée.

## Étape 1 – Fondations & Quick Wins (Jours 0–7)
- ⬜ **Activer OpenWebUI Pipelines**
  - ⬜ Configurer `VECTOR_DB=qdrant`, `RAG_VECTOR_DB=qdrant`, `CHAT_HISTORY_LIMIT=20` (variables commentées dans `docker-compose.yml`).
  - ⬜ Déployer les pipelines Python pour l’OCR et l’ingestion embarquée.
  - ⬜ Déclarer les collections Qdrant `docs_public`, `docs_prive`, `convos_long`, `feedback` et activer RBAC OpenWebUI dès J0.
- ⬜ **Brancher Langfuse dès le premier jour** (aucune configuration Langfuse trouvée dans le dépôt).
- ⬜ **Mettre en place les répertoires Nextcloud `/FPV_Public/` et `/FPV_Privé/`**.
- ⬜ **Créer les webhooks Nextcloud → n8n → Qdrant** pour l’ingestion automatique des documents techniques.
- ⬜ **Valider le flux « résumé document »** : OpenWebUI → pipeline OCR/ingestion → webhook n8n agent PDF summary → retour UI.

## Étape 2 – Orchestration multi-agents & conformité (Jours 8–30)
- ⬜ **Configurer n8n en mode pipe (Webhook Trigger + Merge)** et agents spécialisés parallélisés.
- ✅ **Implémenter la persistance d’état dans Postgres**
  - ✅ `n8n` s’appuie déjà sur Postgres via `docker-compose.yml` (`DB_POSTGRESDB_*`).
- ⬜ **Durcissement et sécurité**
  - ⬜ Activer RBAC OpenWebUI (non documenté).
  - ✅ Basic Auth n8n activée (`N8N_BASIC_AUTH_ACTIVE=true`) mais ⬜ HMAC webhooks non configuré (webhooks n8n obligatoirement LAN-only + HMAC + rate-limit 20 req/min/IP).
  - ⬜ Mettre en place la rotation semestrielle des `.env`.
  - ⬜ Restreindre tous les services au LAN / Cloudflare Zero Trust (ports exposés sur l’hôte aujourd’hui).

## Étape 3 – Automatisation Ops & Infra (Mois 2)
- ⬜ **Automatiser les snapshots Qdrant (`qdrant-snapshot`) et `pg_dump` via n8n avant déclenchement PBS/Proxmox.**
- ⬜ **Déployer les agents d’infrastructure** (snapshots/monitoring Proxmox & Docker avec approbation Discord).
- ⬜ **Lancer l’ingestion nocturne des documents lourds** (tâche planifiée n8n pour OCRmyPDF + pré-embeddings).
- ⬜ **Première revue de performances** via Langfuse (pas de collecte disponible).

## Étape 4 – Knowledge Base & mémoire longue (Mois 3)
- ⬜ **Génération automatique de wiki infra** (Markdown via n8n → Nextcloud/GitHub).
- ⬜ **Fine-tuning du RAG** (segmentation avancée Qdrant, réglages par défaut `top_k=5`, `min_score=0.78`, `max_context_tokens=3000`, ajustements par pipeline).
- ⬜ **Organisation automatique des documents** (tagging/renommage, préparation dataset RLHF).

## Étape 5 – Spécialisations & montée en puissance (>3 mois)
- ⬜ **Pipeline complet Flow Tuning FPV** (Blackbox → OCR/RAG → tuning PID → rapport Markdown).
- ⬜ **Expansion multi-agents** (premier lot = agents PDF résumé, SearxNG résumé, Logs summary ; évoluer ensuite vers 3–5 agents n8n spécialisés).
- ⬜ **Monitoring avancé** (Prometheus/Grafana intégrés avec dashboards unifiés et alertes enrichies).

## Étape 6 – Expérimentations avancées
- ⬜ **Intégration Trading-LAB (Freqtrade)** pour backtests et analyses IA.
- ⬜ **Extension multi-interfaces** (Telegram, WhatsApp).
- ⬜ **Optimisation continue** via RLHF OpenWebUI et analyses Langfuse.
- ⬜ **Validation de la stabilité** avant activation des services secondaires (Flowise, Neo4j, Vault, etc.) ; les maintenir désactivés tant que Langfuse + RBAC + HMAC ne sont pas stabilisés.

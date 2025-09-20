# Ordre optimisé de déploiement de la stack IA FlowTech

## Recommandation principale
Renforcer d’abord les fondations (RAG natif, pipelines, traçabilité) avant d’industrialiser l’orchestration multi-agents puis d’ouvrir les spécialisations. Cette séquence offre des retours rapides, un socle stable et une montée en charge progressive.

## Étape 1 – Fondations & Quick Wins (Jours 0–30)
- ⬜ **Brancher Langfuse immédiatement** pour suivre prompts, latences P95/P99 et erreurs (aucune config Langfuse présente dans le dépôt).
- ⬜ **Activer RAG natif + Pipelines OpenWebUI** (OCR, ingestion, RLHF) ; aujourd’hui `VECTOR_DB`/`RAG_VECTOR_DB` sont encore commentés dans `docker-compose.yml`.
- ⬜ **Créer les répertoires Nextcloud alignés avec Qdrant**  
  - `/docs_public/` → contenu auto-vectorisé (guides, docs techniques, logs généraux) → Qdrant `docs_public`.  
  - `/docs_prive/` → fichiers sensibles, vectorisation uniquement si approbation manuelle → Qdrant `docs_prive`.  
  - `/convos_long/` → stockage brut des conversations longues (journalisation), relayé vers Qdrant `convos_long` par n8n.
- ⬜ **Déployer Loki** pour collecter les logs n8n/OpenWebUI (stack actuelle limitée à Prometheus/Grafana sur VM externe, non raccordés).
- ⬜ **Mettre en place webhooks n8n signés HMAC + RBAC OpenWebUI** (Basic Auth n8n déjà activée, mais HMAC/Rate-limit/RBAC non documentés).
- ⬜ **Valider le pipeline “résumé PDF/logs”** : OpenWebUI → pipeline OCR → webhook n8n agent summary → retour UI.

## Étape 2 – Orchestration & Sécurité (Mois 2)
- ⬜ **Configurer n8n en mode pipe** Qwen3:8B pour tout (master, specialist, doc, code, recherche) DeepSeek-R1 pour ingestion vectorielle  exécutés en parallèle puis fusionnés.
- ✅ **Ajouter la persistance des états d’agents dans Postgres** (`docker-compose.yml` configure déjà n8n sur Postgres via `DB_POSTGRESDB_*`).
- ⬜ **Automatiser la rotation semestrielle des secrets** via rappel n8n + mise à jour des `.env`.
- ⬜ **Activer le rate-limit (20 req/min/IP) sur les webhooks** en complément du HMAC.
- ⬜ **Mettre en place l’ingestion OCR nocturne** (PDF lourds) avec `qdrant-snapshot`/`pg_dump` avant PBS/Proxmox.
- ⬜ **Produire les premiers rapports mensuels Langfuse** (latence, erreurs, feedback) exportés vers Nextcloud.

## Étape 3 – Ops & Knowledge (Mois 3)
- ⬜ **Générer automatiquement le wiki infra** (Markdown) via n8n → publication Nextcloud/GitHub.
- ⬜ **Étendre la segmentation Qdrant** par projet/sensibilité + réglages par défaut `top_k=5`, `min_score=0.78`, `max_context_tokens=3000`.
- ⬜ **Déployer Prometheus + Grafana + Loki** avec dashboards unifiés (n8n, OpenWebUI, Ollama) et alertes reliées à n8n.
- ⬜ **Consigner le feedback IA** et préparer un dataset RLHF utilisable pour futurs fine-tunings.

## Étape 4 – Spécialisation (3–6 mois)
- ⬜ **Livrer le pipeline Flow Tuning FPV** (upload Blackbox → analyse IA → rapport Markdown).
- ⬜ **Passer de 1 à 3–5 agents n8n spécialisés** (PDF résumé, SearxNG résumé, logs summary, tuning, monitoring).
- ⬜ **Brancher Prometheus/Grafana à n8n** pour des alertes enrichies (Discord/Telegram) et validations dans le pipeline sécurité.
- ⬜ **Valider des agents semi-autonomes** capables d’enchaîner plusieurs actions avec garde-fous.

## Étape 5 – Avancé (>6 mois)
- ⬜ **Intégrer Trading-LAB (Freqtrade)** pour backtests et analyses IA orchestrés.
- ⬜ **Étendre vers le multi-interface** (Telegram, WhatsApp) via pipelines n8n.
- ⬜ **Expérimenter Flowise, Neo4j, Vault** et autres services optionnels une fois Langfuse + RBAC + HMAC stabilisés.
- ⬜ **Évaluer k3s/GitOps** si la charge multi-utilisateurs impose une évolution au-delà de Docker Compose.

---

### État actuel rapide
- `docker-compose.yml` fournit Qdrant, OpenWebUI, n8n, Postgres, SearxNG mais sans RAG activé ni Loki/Langfuse.
- n8n tourne déjà sur Postgres avec Basic Auth ; aucune configuration HMAC ou rate-limit dans le dépôt.
- Aucune automatisation (snapshots, workflows pipe, ingestion nocturne) n’est encore versionnée.
- Les services d’expérimentation (Flowise, Neo4j, Vault, etc.) restent volontairement en attente tant que les fondations ne sont pas stabilisées.

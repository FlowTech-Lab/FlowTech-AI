# Ordre optimisé de déploiement de la stack IA FlowTech

## Recommandation principale
Renforcer d’abord les fondations (RAG natif, pipelines, traçabilité) avant d’industrialiser l’orchestration multi-agents puis d’ouvrir les spécialisations. Cette séquence offre des retours rapides, un socle stable et une montée en charge progressive.

## Étape 1 – Fondations & Quick Wins (Jours 0–30)
- ✅ **Script init.sh optimisé** - Démarrage séquentiel, mode DEV, gestion des erreurs
- ✅ **Stack core opérationnelle** - Qdrant, Postgres, OpenWebUI, n8n, SearxNG fonctionnels
- ⬜ **Activer RAG natif + Pipelines OpenWebUI** (OCR, ingestion, RLHF) ; `VECTOR_DB`/`RAG_VECTOR_DB` à configurer
- ⬜ **Créer les répertoires de données alignés avec Qdrant**  
  - `/AI_Data/docs_public/` → contenu auto-vectorisé (guides, docs techniques, logs généraux) → Qdrant `docs_public`.  
  - `/AI_Data/docs_prive/` → fichiers sensibles, vectorisation uniquement si approbation manuelle → Qdrant `docs_prive`.  
  - `/AI_Data/convos_long/` → stockage brut des conversations longues (journalisation), relayé vers Qdrant `convos_long` par n8n.
- ⬜ **Déployer Redis** pour cache embeddings + files d'attente n8n (priorité Phase 2)
- ⬜ **Déployer Loki** pour collecter les logs n8n/OpenWebUI (stack actuelle limitée à Prometheus/Grafana sur VM externe, non raccordés).
- ⬜ **Mettre en place webhooks n8n signés HMAC + RBAC OpenWebUI** (Basic Auth n8n déjà activée, mais HMAC/Rate-limit/RBAC non documentés).
- ⬜ **Valider le pipeline "résumé PDF/logs"** : OpenWebUI → pipeline OCR → webhook n8n agent summary → retour UI.

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
- ✅ **Stack core opérationnelle** : Qdrant, OpenWebUI, n8n, Postgres, SearxNG fonctionnels
- ✅ **Script init.sh optimisé** : Démarrage séquentiel, mode DEV, gestion des erreurs, chmod automatique
- ⚠️ **Langfuse 3.98.0** : Installé mais problème ClickHouse (bug de réplication, voir error.txt)
- ✅ **Ollama** : Installé hors stack (192.168.0.2:11434) - CRITIQUE pour le système
- ⬜ **RAG natif** : À activer dans OpenWebUI (VECTOR_DB/Qdrant)
- ⬜ **Redis** : À déployer pour cache embeddings + files d'attente n8n
- ⬜ **Loki** : À déployer pour logs centralisés
- ⬜ **HMAC/RBAC** : À implémenter (Basic Auth n8n déjà activée)
- ❌ **Services retirés** : ClickHouse, ComfyUI, Piper, Vault, Neo4j, Flowise, Supabase, RabbitMQ/Kafka
- 📋 **Documentation** : Mise à jour avec stack priorisée et modifications techniques

# 📌 Cahier des charges – IA personnelle FlowTech

## 1. Vision & finalité
- **Objectif principal** : disposer d’une IA locale capable d’assister FlowTech sur les sujets FPV, infrastructure, automatisation et documentation.
- **Usage** : strictement privé, exécution locale par défaut ; recours ponctuel au cloud (RTX 4070 Super) uniquement après validation.
- **Interface maître** : OpenWebUI pour la conversation (pipeline activé) ; n8n opère en hub multi-interfaces (Discord, Telegram, site) et orchestre les tâches longues.
- **Capacités attendues** : plans d’action, résumés (PDF, logs, incidents), fiches techniques, propositions d’automatisation, génération Markdown exportable (Nextcloud, GitHub).
- **Boucle de feedback** : utilisation native du RLHF OpenWebUI (👍/👎) avec exports JSON pour créer des jeux d’entraînement.
- **Traçabilité** : journal n8n des lectures/écritures, Langfuse pour tracer prompts/latences/erreurs dès la phase Quick Wins, rétention illimitée via résumés périodiques et purge manuelle.

## 2. Architecture & déploiement
### 2.1 Infrastructure cible
- **Proxmox** : deux VMs distinctes (Dev/Prod) pour la stack IA, ressources extensibles.
- **Nextcloud** : reste hébergé sur OpenMediaVault.
- **GPU** : NVIDIA Container Toolkit opérationnel ; GTX 1660 Ti dédiée à Ollama (prod), RTX 4070 Super mobilisée ponctuellement (routage manuel).
- **Sauvegardes** : Proxmox Backup Server couvre `./AI_Data/openwebui`, `./AI_Data/n8n`, `./AI_Data/qdrant`, `./AI_Data/pgdata`.

### 2.2 Services & interconnexions
- **Orchestration** : stack maintenue sur Docker Compose (Kubernetes/k3s non retenu à ce stade).
- **OpenWebUI** : UI principale, pipelines et RAG natifs activés (`VECTOR_DB=qdrant`, `RAG_VECTOR_DB=qdrant`, `CHAT_HISTORY_LIMIT=20`). OpenWebUI n'écrit pas l'historique de chat dans Qdrant et n'utilise que les collections documents (`docs_public`, `docs_prive`). La mémoire longue des conversations est gérée par n8n dans la collection `convos_long`. Pipelines Python personnalisés pour OCR, ingestion, agents spécialisés.
- **Ollama** : modèles locaux (`Qwen2.5-7B-Instruct` en défaut, `Llama-3-3B` fallback) ; routage simple, option forcer 7B et délégation GPU externe. Tests des quantifications (`Q4_K_M`, `Q8`) prévus pour Qwen2.5-7B avec mesure des latences P95/P99 via Langfuse ; Triton/FasterTransformers non retenus à ce stade (GPU 1660 Ti).
- **n8n** : orchestrateur principal, webhooks internes (`/webhook/owui-router`), runners activés, stockage d’état agents dans Postgres pour workflows longue durée.
- **Qdrant** : mémoire vectorielle (espaces public/safe/privé) ; non exposé, accessible depuis OpenWebUI et n8n via réseau interne. Possibilité d'ajouter Redis ou Memcached si la latence des embeddings devient un point de friction.
- **Postgres** : base n8n + persistance des états d’agents/pipe, LAN-only.
- **SearxNG** : moteur de recherche ; exposable via Cloudflare si besoin.
- **Prometheus/Grafana** : VM existante, export métriques OpenWebUI (HTTP exporter), n8n et Ollama ; alertes routées par n8n vers Discord/Telegram.
- **Réseau** : exposition minimale via pfSense/Cloudflare Zero Trust (si accès distant) ; allowlist IP entre VMs pour OWUI ⇄ n8n ⇄ Qdrant/Postgres. Keycloak ou Authelia pourront être introduits plus tard si un besoin MFA/SSO apparaît, sans priorité immédiate.

### 2.3 Volumes & environnements
- Volumes dynamiques co-localisés avec `docker-compose.yml` (`./AI_Data/...`).
- `.env` distincts Dev/Prod (URL Ollama, secrets, ports, clés webhooks) avec rotation semestrielle.
- `settings.yml` géré pour SearxNG (limiteur désactivé en local, OCR et DOI configurés).
- Activation des Pipelines OpenWebUI pour connecter les automatisations aux workflows n8n.

### 2.4 Multi-agents & pipelines
- OpenWebUI gère l’ingestion courte (top_k élevé) et délègue à n8n les workflows multi-agents.
- n8n `Webhook Trigger` + nœuds `Merge` pour agréger les réponses (PDF, infra, FPV) et renvoyer un résultat unifié à l’UI.
- Stockage des contextes d’agents dans Postgres (nœud Database) pour reprise de conversation et tâches différées.

### 2.5 Contrôles de conformité
- OpenWebUI : RAG natif + pipeline activés, historique limité à 20 messages, RBAC activé pour limiter les actions pipelines.
- Qdrant : ports non exposés, segmentation public/safe/privé, tags par projet (FPV, infra, dev, etc.).
- n8n : accès LAN, Basic Auth + `WEBHOOK_SECRET`, webhooks signés HMAC et rate-limités.
- PBS : sauvegarde volumes critiques + tests de restauration trimestriels.

### 2.6 Observabilité
- Langfuse déployé dès la phase Quick Wins pour tracer prompts, latences (P95/P99) et erreurs.
- Prometheus + Grafana + Loki pour unifier métriques et logs (n8n, OpenWebUI, Ollama) et alimenter les dashboards.
- Rapport mensuel automatisé via n8n (Markdown/PDF) exporté vers Nextcloud pour suivre performances et incidents.

## 3. Gestion des fichiers & données
### 3.1 Priorités de vectorisation
- **In** : Markdown, PDF, JSON/YAML (Betaflight, configs infra), logs texte (Blackbox, systèmes FPV).
- **Out** : code source complet, vidéos, binaires firmware (stockage sans vectorisation).

### 3.2 Ingestion & OCR
- **Pipeline OpenWebUI** : ingestion directe (OCR + embeddings) des documents déposés dans les dossiers surveillés, top_k élevé pour réponses rapides.
- **Tâche n8n planifiée** : scan nocturne des nouveaux fichiers → pré-embeddings lourds (PDF volumineux) pour soulager les requêtes runtime.
- **OCR** : Tesseract/OCRmyPDF déclenchés via pipeline OpenWebUI ou agent n8n selon le scénario, rapport d’ingestion renvoyé à l’UI.

### 3.3 Organisation & édition
- Mode hybride :
  - Dossiers « safe » → écriture directe (OpenWebUI pipeline ou n8n).
  - Dossiers sensibles → flux diff → approbation Discord/OpenWebUI → écriture.
- Organisation automatique (tagging/renommage) prise en charge par pipeline n8n lors de la phase Knowledge & Mémoire.
- Espaces Nextcloud : `/FPV_Public/` (vectorisation auto), `/FPV_Privé/` (vectorisation manuelle, exclusions explicites).

### 3.4 Reporting & suivi
- n8n génère un rapport mensuel (Markdown/PDF) récapitulant nouveaux documents, embeddings créés et erreurs d’ingestion → export Nextcloud.

## 4. Intelligence & workflows IA
### 4.1 Mémoire & RAG
- **OpenWebUI** : mémoire courte (20 messages) + RAG natif (top_k adaptable) avec heuristiques pipelines ; RLHF intégré pour affiner les réponses.
- **Qdrant** : mémoire longue, segmentation par projet et sensibilité ; tags pour retrouver les conversations et sources. Weaviate multimodal pourra être évalué si un besoin vision+texte apparaît.
- **n8n** : déclenche le RAG long (top_k réduit, filtres par tags) lorsque l’heuristique pipeline indique un besoin contexte étendu.

### 4.2 Orchestration multi-agents
- Orchestration pipe n8n :
  1. Agent principal (router) reçoit la requête OpenWebUI via webhook.
  2. Agents spécialisés (PDF/log summary, monitoring infra, tuning FPV, recherche SearxNG) exécutent en parallèle.
  3. Nœud `Merge` assemble les réponses, ajoute les sources utilisées, renvoie à OpenWebUI.
- Persistance de l’état agent dans Postgres pour workflows longue durée (ex : backtest Freqtrade, analyse logs lourds).
- Possibilité d’imbriquer MCP si besoin futur, mais pipe prioritaire pour flexibilité de contexte isolé.

### 4.3 Feedback & amélioration
- RLHF OpenWebUI alimente un dataset exportable ; n8n consigne le feedback dans Qdrant (tag « feedback ») sans modification automatique des scores.
- Pipeline de test automatique (n8n) pour rejouer des prompts critiques et valider les agents après mise à jour.

### 4.4 Traçabilité & monitoring
- Langfuse déployé dès Quick Wins : collecte prompts, latences, erreurs, sources RAG.
- n8n produit un rapport mensuel (Markdown + export PDF) avec temps de réponse, erreurs, sources RAG, feedbacks.
- Alertes n8n → Discord/Telegram : dépassement de latence, échec pipelines, sources indisponibles.

## 5. Sécurité & accès
### 5.1 Exposition & authentification
- Pas de SSO (Traefik/Authelia retirés) ; auth native + RBAC OpenWebUI activé obligatoirement dès le déploiement (rôles Admin/Editor/User).
- OpenWebUI & n8n derrière Cloudflare Zero Trust uniquement si accès distant ; sinon LAN-only.
- SearxNG : exposé via Cloudflare si usage externe, sinon LAN.
- Grafana/Prometheus : LAN par défaut ; accès restreint par firewall.
- Discord : canal d’approbation (rôle `Approver`) + notifications incidents.

### 5.2 Gestion des secrets
- Secrets dans `.env` chiffrés, sauvegardés dans PBS ; rotation semestrielle automatisée par rappel n8n.
- Masquage automatique (nœuds Code n8n) avant log ou stockage pour toute PII/clé/secret ; interdiction d’insérer secrets dans prompts.

### 5.3 Validation & durcissement
- Flux critique : OpenWebUI → pipeline → n8n → Discord Approve/Reject → exécution.
- Actions couvertes : modifications fichiers sensibles, snapshots/reboots, déploiements, automatisations destructrices.
- Webhooks n8n : obligatoirement LAN-only, signés HMAC et protégés par un rate-limit de 20 req/min/IP, avec purge automatique de l’historique conversationnel au-delà de 20 échanges.
- Community Leaderboard : activée uniquement pour admins afin de vérifier la qualité des réponses avant diffusion.
- Mises à jour : patch mensuel conteneurs, revue trimestrielle dépendances et pipelines personnalisés.

### 5.4 Journalisation
- n8n : log qui/quoi/quand + payload minimal (rétention 90 jours).
- OpenWebUI : prompts/outputs court terme ; résumés envoyés dans Qdrant (texte nettoyé).
- Langfuse : audit complet des prompts, latences, sources RAG.

## 6. Intégrations FlowTech
### 6.1 Nextcloud
- Répertoires `/FPV_Public/` et `/FPV_Privé/` avec webhooks vers OpenWebUI pipeline et n8n.
- Vectorisation sélective (auto vs manuel) + reporting ingestion mensuel.

### 6.2 Proxmox
- n8n lit l’état VM (CPU/RAM/disk) et planifie snapshots ; exécution après approbation Discord.
- Pipeline incidents : alertes Prometheus → n8n → résumé IA → Discord.

### 6.3 Docker & services
- n8n fournit la vue conteneurs/logs, redémarrages sur approbation.
- Export Grafana/Prometheus : dashboards unifiés, résumés incidents via n8n.

### 6.4 FPV & projets spécifiques
- **Flow Tuning FPV** : pipeline complet (upload Blackbox → pipeline OpenWebUI OCR/RAG → agent n8n tuning → rapport Markdown).
- **Trading-LAB (Freqtrade)** : déclenché après stabilisation (agents pour lancer backtests, analyser résultats, recommandations).
- **Autres projets (EUC, archery, ARK, etc.)** : documentation + alertes simples via pipelines dédiés.
- **Journal infra** : n8n génère un wiki Markdown des changements (VM, Docker, services) stocké Nextcloud/GitHub.

## 7. Plan de déploiement & roadmap
### Étape 1 – Quick Wins (Jours 0–30)
- Activer le RAG natif & les pipelines OpenWebUI (OCR, ingestion, RLHF).
- Brancher Langfuse, pipe OpenWebUI ⇄ n8n (agents PDF, mail, logs).
- Configurer le multi-agent n8n (Webhook → Merge → retour UI) et valider le flux résumé doc.
- Mettre en place les répertoires Nextcloud (`/FPV_Public/`, `/FPV_Privé/`) + vectorisation de base.

### Étape 2 – Ops & Infra (Mois 2)
- Automatiser snapshots Proxmox & reporting infra (n8n → Discord).
- Ingestion nocturne OCR + embeddings lourds via agents n8n.
- Alertes systèmes (Proxmox/Docker) résumées par pipeline IA ; validation d’actions critiques Discord opérationnelle.

### Étape 3 – Knowledge & Mémoire (Mois 3)
- Wiki infra auto-généré (Markdown) alimenté par n8n + publication GitHub/Nextcloud.
- Tagging/renommage automatisé des nouveaux docs ; segmentation fine Qdrant par projet/sensibilité.
- Feedback IA logué et exploitable pour futurs fine-tuning ; rapport mensuel Langfuse → Nextcloud.

### Étape 4 – Spécialisations (>3 mois)
- Pipeline complet Flow Tuning FPV (analyse PID, recommandations).
- Monitoring complet : Prometheus/Grafana raccordés, alertes enrichies via n8n.
- Passage de 1 agent n8n à 3–5 agents spécialisés (résumé, recherche, analyse, tuning, monitoring).
- Agents semi-autonomes capables d’enchaîner plusieurs actions validées.

### Étape 5 – Expérimentation avancée
- Intégration Trading-LAB (backtests, analyse IA).
- Extension multi-interfaces (Telegram, WhatsApp) via pipelines n8n.
- Optimisation continue via RLHF + Langfuse (dataset d’entraînement, ajustement heuristiques).

## 8. Services & priorisation

### Stack recommandée et priorisée

#### Phase 1 - Core Stack (Déploiement immédiat)
| Priorité | Service | Justification | Status |
|----------|---------|---------------|--------|
| 1 | **Ollama** (hors stack) | CRITIQUE - Moteur LLM local obligatoire pour tout le système | ✅ Installé |
| 2 | **Qdrant** | Mémoire vectorielle centrale pour RAG et agents | ✅ Opérationnel |
| 3 | **Postgres** | Base de données pour n8n + états des agents | ✅ Opérationnel |
| 4 | **OpenWebUI** | Interface principale + pipelines | ✅ Opérationnel |
| 5 | **n8n** | Orchestrateur multi-agents central | ✅ Opérationnel |
| 6 | **Langfuse** | Traçabilité obligatoire dès le début (Quick Wins) | ⚠️ Problème ClickHouse |

#### Phase 2 - Services de support (Semaines 2-4)
| Priorité | Service | Usage | Status |
|----------|---------|-------|--------|
| 7 | **Redis** | Cache embeddings + files d'attente n8n | 🔄 À implémenter |
| 8 | **Loki** | Logs centralisés | 🔄 À implémenter |
| 9 | **SearxNG** | Recherche web pour agents | ✅ Opérationnel |
| 10 | **Traefik/NGINX** | Reverse proxy + sécurité | 🔄 À implémenter |

#### Phase 3 - Spécialisations (Mois 2-3)
| Priorité | Service | Usage spécialisé | Status |
|----------|---------|------------------|--------|
| 11 | **Whisper** | Transcription audio pour workflows | 🔄 À implémenter |
| 12 | **Tesseract/OCR** | Pipeline documents (via n8n) | 🔄 À implémenter |
| 13 | **Prometheus + Grafana** | Monitoring infra existant | 🔄 À implémenter |

### Modifications techniques récentes
- **Langfuse 3.98.0** : Version compatible ClickHouse mais avec bug de réplication
- **Configuration ClickHouse** : Désactivée temporairement (problème Zookeeper)
- **Démarrage séquentiel** : langfuse-web avant langfuse-worker pour éviter les deadlocks
- **Mode DEV** : Option de reset complet (.env, AI_Data, logs) pour le développement

---

Ce cahier des charges reflète l’architecture actuelle, les priorités opérationnelles et la roadmap de l’IA personnelle FlowTech. Toute évolution majeure (nouveaux services, exposition externe, automatisations critiques) doit être validée puis consignée dans le wiki infra.

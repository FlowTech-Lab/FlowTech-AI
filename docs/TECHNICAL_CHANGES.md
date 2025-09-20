# Modifications Techniques Récentes - FlowTech-AI

## Résumé des changements majeurs

### 1. Optimisation du script init.sh
- **Démarrage séquentiel** : langfuse-web démarre avant langfuse-worker pour éviter les deadlocks PostgreSQL
- **Mode DEV** : Option `DEV_MODE=true/false` pour reset complet (.env, AI_Data, logs) en développement
- **Gestion des erreurs** : Amélioration de la robustesse et des logs
- **Chmod automatique** : Permissions automatiques pour tous les fichiers nécessaires
- **Suppression du téléchargement d'images** : Les images Docker sont préservées

### 2. Mise à jour Langfuse
- **Version 3.98.0** : Passage de `latest` à version spécifique avec support ClickHouse
- **Problème identifié** : Bug de réplication ClickHouse (tables ReplicatedMergeTree sans Zookeeper)
- **Solution temporaire** : ClickHouse désactivé, Langfuse fonctionne avec PostgreSQL seul

### 3. Configuration ClickHouse
- **Utilisateur créé** : `langfuse` avec permissions appropriées
- **Configuration personnalisée** : `clickhouse-config/config.xml` pour tables non-répliquées
- **Problème persistant** : Langfuse force l'utilisation de tables répliquées

### 4. Stack priorisée
- **Services retirés** : ClickHouse, ComfyUI, Piper, Vault, Neo4j, Flowise, Supabase, RabbitMQ/Kafka
- **Services prioritaires** : Ollama (hors stack), Qdrant, Postgres, OpenWebUI, n8n, SearxNG
- **Services à déployer** : Redis, Loki, Traefik/NGINX

## Diagnostic complet

### Fichier error.txt
Documentation complète du diagnostic Langfuse/ClickHouse avec :
- 12 tests différents
- Toutes les commandes exécutées
- Résultats et conclusions à chaque étape
- Solutions testées et recommandations finales

### Problèmes résolus ✅
1. **Migrations Prisma** : Deadlock PostgreSQL résolu
2. **Driver ClickHouse** : Version 3.98.0 reconnaît ClickHouse
3. **Permissions ClickHouse** : Utilisateur `langfuse` créé avec bonnes permissions
4. **Script init.sh** : Optimisé pour démarrage robuste

### Problèmes persistants ❌
1. **Tables répliquées** : Langfuse force ReplicatedMergeTree sans Zookeeper
2. **Bug Langfuse** : Essaie de se connecter à ClickHouse même quand désactivé

## Recommandations

### Solution immédiate
- Utiliser Langfuse sans ClickHouse (PostgreSQL seul)
- Supprimer le service ClickHouse du docker-compose.yml
- Attendre une version Langfuse qui corrige le bug de réplication

### Solutions alternatives
1. **Version antérieure** : Utiliser une version Langfuse qui ne force pas ClickHouse
2. **Version plus récente** : Attendre une version qui corrige le problème
3. **Configuration Zookeeper** : Configurer Zookeeper pour ClickHouse (complexe)

## Fichiers modifiés

### Scripts
- `init.sh` : Optimisé avec démarrage séquentiel et mode DEV
- `docker-compose.yml` : Version Langfuse 3.98.0, configuration ClickHouse

### Configuration
- `.env` : Variables ClickHouse ajoutées/supprimées selon les tests
- `clickhouse-config/config.xml` : Configuration personnalisée ClickHouse

### Documentation
- `docs/spec.md` : Stack priorisée et modifications techniques
- `docs/ROADMAP.md` : État actuel et priorités mises à jour
- `docs/Agents.md` : Architecture multi-agents avec stack actuelle
- `error.txt` : Diagnostic complet Langfuse/ClickHouse

## Prochaines étapes

1. **Résoudre Langfuse** : Tester version antérieure ou attendre correction
2. **Déployer Redis** : Cache embeddings + files d'attente n8n
3. **Déployer Loki** : Logs centralisés
4. **Activer RAG** : Configuration OpenWebUI + Qdrant
5. **Implémenter HMAC/RBAC** : Sécurité webhooks n8n

---

*Documentation mise à jour le 20/09/2025 - Reflète l'état actuel de la stack FlowTech-AI*

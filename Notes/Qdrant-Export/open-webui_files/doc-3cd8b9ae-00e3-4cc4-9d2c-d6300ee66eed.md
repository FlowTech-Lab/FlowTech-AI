---
collection: open-webui_files
exported_at: '2026-01-11T20:52:33.818616'
id: 3cd8b9ae-00e3-4cc4-9d2c-d6300ee66eed
title: doc-3cd8b9ae-00e3-4cc4-9d2c-d6300ee66eed
---

### ✅ Checklist express
1. Migrations `cache` et `queue` créées et migrées.
2. `config.cache_store` positionné en prod.
3. `config/cable.yml` pointe vers `sqlite3` ou DB cible.
4. `job:work` lancé et supervisé.
5. Tests de lecture cache, enqueue job, broadcast Cable passés.

### 📚 Glossaire mini
- **Solid Cache**: Backend cache sur DB via ActiveRecord.
- **Solid Queue**: File de jobs ActiveJob persistée en DB.
- **Solid Cable**: Transport Action Cable sans Redis.
- **ActiveJob**: API unifiée pour enqueuer des jobs.
- **Channel**: Unité de souscription WebSocket.
- **Worker**: Processus qui consomme et exécute des jobs.
- **Broadcast**: Diffusion d'un message à des abonnés.
- **Adapter**: Connecteur entre service Rails et backend.
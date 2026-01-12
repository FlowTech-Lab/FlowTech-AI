---
collection: open-webui_files
exported_at: '2026-01-11T20:52:33.824734'
id: 6d7895b7-a22d-44be-a37a-f4e3debc26eb
title: doc-6d7895b7-a22d-44be-a37a-f4e3debc26eb
---

### 🚫 Pièges & bonnes pratiques
- Éviter les écritures concurrentes intensives sans verrouillage logique applicatif.
- Surveiller la taille du fichier `.sqlite3` et planifier la compaction (VACUUM).
- Utiliser des index appropriés et la FTS quand pertinent.
- Ne pas mélanger adaptateurs DB hétérogènes sans besoin avéré.

### ✅ Checklist express
1. `--database=sqlite3` défini et gems par défaut.
2. Migrations Solid Cache et Solid Queue appliquées.
3. `config/cable.yml` sur `adapter: database`.
4. Backups et VACUUM programmés.
5. Health checks: jobs en file, cache lisible, cable connecté.
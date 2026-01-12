---
collection: open-webui_files
exported_at: '2026-01-11T20:52:33.824465'
id: 6bebb66a-c6e2-4e0f-a4f0-48d55d8cb240
title: doc-6bebb66a-c6e2-4e0f-a4f0-48d55d8cb240
---

### 📦 Commandes clés
- Créer app: 
```bash
rails new app_name --minimal
```
- Générer modèle + migration: 
```bash
bin/rails g model Entity name:string status:string
```
- Migrer / rollback: 
```bash
bin/rails db:migrate && bin/rails db:rollback STEP=1
```
- Ouvrir console / serveur: 
```bash
bin/rails console
bin/rails server
```
- Seed BDD: 
```bash
bin/rails db:seed
```

### 🧩 Structures & Nommage canoniques
- Entités: [[Entity]], [[Item]], [[Collection]], [[Service]], [[Component]], [[Module]], [[Page]], [[Config]].
- Données: `id, name, status, created_at, updated_at`.
- États: `draft | active | archived | error`.
- Fichiers génériques: `lib/app_arrays.rb`, `lib/app_hashes.rb`, `lib/utils.rb`.
- Conventions Rails: classes *SingulierCamelCase*, tables *pluriel_snake_case* (`Entity` → `entities`).
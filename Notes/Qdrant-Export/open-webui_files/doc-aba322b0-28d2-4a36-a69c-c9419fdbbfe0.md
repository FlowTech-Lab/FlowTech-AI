---
collection: open-webui_files
exported_at: '2026-01-11T20:52:33.831220'
id: aba322b0-28d2-4a36-a69c-c9419fdbbfe0
title: doc-aba322b0-28d2-4a36-a69c-c9419fdbbfe0
---

### 📦 Commandes clés
- Générer un model et une migration.
```bash
rails g model Entity name:string status:string
```
- Lancer la console pour tester les règles.
```bash
rails console
```
- Lister erreurs d'un objet après tentative de save.
```rb
item = Entity.create; item.errors.full_messages
```

### 🧩 Structures & Nommage canoniques
- Entités: `User`, `Session`, `Course`, `Entity`, `Item`, `Service`.
- Données usuelles: `id`, `name`, `email`, `status`, `created_at`, `updated_at`.
- États recommandés: `draft | active | archived | error`.
- Fichiers utiles: `app/models/entity.rb`, `lib/utils.rb`, `script_A.rb`.
- Relations: `belongs_to`, `has_many`, `has_one`, `has_many :through`.
- Rester générique et DRY. Centraliser la logique métier côté Model.
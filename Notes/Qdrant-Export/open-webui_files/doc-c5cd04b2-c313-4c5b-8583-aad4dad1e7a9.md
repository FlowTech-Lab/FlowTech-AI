---
collection: open-webui_files
exported_at: '2026-01-11T20:52:33.840618'
id: c5cd04b2-c313-4c5b-8583-aad4dad1e7a9
title: doc-c5cd04b2-c313-4c5b-8583-aad4dad1e7a9
---

### ✅ Checklist express
1. Environnement correct chargé (`RAILS_ENV`).
2. `rails c --sandbox` pour les essais destructifs.
3. `reload!` après changement de code.
4. Requêtes bornées (`limit`, `select`, `order`).
5. Valider puis `save` et vérifier `errors`.

### 📚 Glossaire mini
- **Console Rails**: REPL Ruby connecté à la BDD de l'app.
- **ActiveRecord**: ORM qui mappe les tables en classes Ruby.
- **CRUD**: Create, Read, Update, Destroy.
- **Scope**: chaîne de conditions réutilisables sur un [[Model]].
- **Sandbox**: session console avec rollback automatique à la sortie.
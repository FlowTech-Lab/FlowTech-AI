---
collection: open-webui_files
exported_at: '2026-01-11T20:52:33.813155'
id: 0be6032d-db8f-4da3-be2b-4adaef95e2a8
title: doc-0be6032d-db8f-4da3-be2b-4adaef95e2a8
---

### 🧪 Test / Validation
```bash
# Vérifier les validations et callbacks en console
rails c --sandbox
```
```rb
u = User.new(first_name: "INPUT", email: "INPUT")
u.valid?        # => true/false selon validations
u.errors.full_messages
```

### ⚙️ Build / Run / Deploy
- En dev: utiliser `rails c` relié à l'environnement `development`.
- En prod: privilégier `rails runner` pour scripts idempotents et auditables.
- Toujours journaliser les opérations massives et prévoir un rollback.

### 🚫 Pièges & bonnes pratiques
- Ne pas manipuler la prod hors `--sandbox` ou sans sauvegarde.
- Différencier retour **objet** vs **array** selon `find`/`find_by`/`where`.
- Préférer `update` et validations plutôt que `update_all` sauf cas maîtrisé.
- Ajouter des `limit`/`select` pour éviter des chargements inutiles.
- Utiliser des **transactions** pour les opérations groupées.
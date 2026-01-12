---
collection: open-webui_files
exported_at: '2026-01-11T20:52:33.841287'
id: cd0d0776-f6fd-404a-91fe-aba307d4ff88
title: doc-cd0d0776-f6fd-404a-91fe-aba307d4ff88
---

### 📦 Commandes clés
- Lancer tous les tests.
```bash
rspec
```
- Lancer un fichier de tests précis.
```bash
rspec spec/hello_spec.rb
```
- Voir la documentation détaillée.
```bash
rspec --format documentation
```
- Filtrer par description.
```bash
rspec -e "says hello"
```

### 🧩 Structures & Nommage canoniques
- Dossiers: `lib/` pour l'app, `spec/` pour les tests.
- Fichiers de test suffixés: `*_spec.rb`.
- Entités génériques: [[Entity]], [[Service]], [[Module]], [[Component]], [[Config]].
- Données types: `id`, `name`, `status`, `created_at`, `updated_at`.
- États: `draft | active | archived | error`.
- Fichiers génériques: `lib/app_arrays.rb`, `lib/app_hashes.rb`, `lib/utils.rb`.

### ✍️ Snippets essentiels
```rb
# Objectif: fonction simple à tester
def hello
  "Hello world!"
end
```
```rb
# Objectif: test RSpec minimal pour hello
require_relative "../lib/hello"
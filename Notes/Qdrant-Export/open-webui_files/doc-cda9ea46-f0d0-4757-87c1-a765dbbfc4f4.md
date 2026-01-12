---
collection: open-webui_files
exported_at: '2026-01-11T20:52:33.841643'
id: cda9ea46-f0d0-4757-87c1-a765dbbfc4f4
title: doc-cda9ea46-f0d0-4757-87c1-a765dbbfc4f4
---

### 📦 Commandes clés
- Installer les gems:
```bash
bundle install
```
- Lancer un script:
```bash
ruby lib/app.rb
```
- Initialiser RSpec (optionnel):
```bash
rspec --init
```
- Lancer Rubocop si utilisé:
```bash
rubocop -A
```

### 🧩 Structures & Nommage canoniques
- Dossiers: `lib/`, `spec/`, `bin/` (CLI), `config/` (si besoin).
- Fichiers génériques: `lib/app_arrays.rb`, `lib/app_hashes.rb`, `lib/utils.rb`.
- Entités: [[Service]] OpenAI, [[Config]] Dotenv, [[Component]] CLI, [[Module]] ChatSession.
- Données communes: `id, name, status, created_at, updated_at`.
- États: `draft | active | archived | error`.

### ✍️ Snippets essentiels
```rb
# Objectif: charger les secrets depuis .env
require "dotenv"; Dotenv.load
---
collection: open-webui_files
exported_at: '2026-01-11T20:52:33.842435'
id: d56cf1da-d5c6-430e-b7a9-9a5d069f0f1b
title: doc-d56cf1da-d5c6-430e-b7a9-9a5d069f0f1b
---

---
type: resource
area: ""
status: active
owner: flow
created: 2025-10-03
tags: [memo, cheatsheet]
topic: "Ruby"
keywords: [ruby, variables, types, boucles, conditions, commentaires, puts-vs-print, integers, floats, booleens, times, installation]
doc_id: "decouverte-programmation-ruby-20251003-01"
source_path: "notes/Resources/decouverte-programmation-ruby-20251003-01.md"
---

# Fiche Mémo — Ruby

### 🚀 Setup rapide
- Installer [[Service]] Ruby via rbenv/rvm ou package manager.
- Vérifier la version : `ruby -v` et `irb`.
- Créer un dossier `app/` et un premier fichier `my_first_program.rb`.
- Exécuter un script : `ruby my_first_program.rb`.
- Lancer REPL : `irb` pour tester des expressions.

### 📦 Commandes clés
```bash
ruby script.rb           # exécuter un fichier Ruby
irb                      # console interactive
ruby -c script.rb        # check syntaxe rapide
rubocop -A               # linter/auto-fix si installé
rspec                    # tests si présents
```
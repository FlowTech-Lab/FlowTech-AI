---
collection: open-webui_files
exported_at: '2026-01-11T20:52:33.825231'
id: 70de656f-1c4b-4bca-9071-a0cdbef346f8
title: doc-70de656f-1c4b-4bca-9071-a0cdbef346f8
---

---
type: resource
area: ""
status: active
owner: flow
created: 2025-10-03
tags: [memo, cheatsheet]
topic: "Ruby — exercices de base"
keywords: [ruby, exercices, boucles, io, chaînes, entiers, arrays, hash, contrôle, interpolation, fichiers]
doc_id: "ruby-exercices-de-base-20251003-01"
source_path: "notes/Resources/ruby-exercices-de-base-20251003-01.md"
---

# Fiche Mémo — Ruby — exercices de base

### 🚀 Setup rapide
- Installer Ruby et bundler. Vérifier la version.
```bash
ruby -v
bundle -v
```
- Créer un dossier `ruby_exos/` et init Git.
```bash
mkdir ruby_exos && cd ruby_exos
git init
```
- Un fichier par exo dans `lib/` et exécution via `ruby lib/exo_XX.rb`.

### 📦 Commandes clés
```bash
ruby lib/exo_01.rb        # lancer un script
irb                       # console interactive
rubocop -A                # linter auto-correct
rspec                     # tests si présents
git add . && git commit -m "exo" && git push
```
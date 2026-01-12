---
collection: open-webui_files
exported_at: '2026-01-11T20:52:33.839108'
id: bbdaa6fa-1764-44bf-8f9e-3b3227e2acd1
title: doc-bbdaa6fa-1764-44bf-8f9e-3b3227e2acd1
---

---
type: resource
area: ""
status: active
owner: flow
created: 2025-10-03
tags: [memo, cheatsheet]
topic: "Ruby — exercices de base"
keywords: [ruby, variables, puts, print, interpolation, gets.chomp, boucles, entrées-sorties, commentaires, chaînes]
doc_id: "ruby-exercices-20251003-01"
source_path: "notes/Resources/ruby-exercices-20251003-01.md"
---

# Fiche Mémo — Ruby — exercices de base

### 🚀 Setup rapide
- Installer [[Ruby]] ≥ 3.x et [[Bundler]].
- Créer un dossier `ruby_basics/` avec `lib/`, `spec/`, `README.md`.
- Initialiser Git et un dépôt distant générique.
```bash
mkdir -p ruby_basics/lib && cd ruby_basics
git init && echo "# Ruby Basics" > README.md
```

### 📦 Commandes clés
- Exécuter un script:  
```bash
ruby lib/script_A.rb
```
- Lancer un fichier d'exo interactif:  
```bash
ruby lib/exo_01.rb
```
- Vérifier la version Ruby:  
```bash
ruby -v
```
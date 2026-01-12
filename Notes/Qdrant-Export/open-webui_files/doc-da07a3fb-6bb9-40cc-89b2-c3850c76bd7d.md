---
collection: open-webui_files
exported_at: '2026-01-11T20:52:33.843176'
id: da07a3fb-6bb9-40cc-89b2-c3850c76bd7d
title: doc-da07a3fb-6bb9-40cc-89b2-c3850c76bd7d
---

### 📦 Commandes clés
```bash
ruby app.rb                     # démarrer une partie
RSPEC_COLOR=1 bundle exec rspec # lancer les tests
rubocop -A                     # lint & auto-correct
rake                          # cible par défaut si définie
```
- Ajout gem ponctuelle: `bundle add <gem>`.

### 🧩 Structures & Nommage canoniques
- Classes: `Application`, `Game`, `Player`, `Board`, `BoardCase`, `Show`.
- Noms d'attributs: `id`, `name`, `symbol`, `status`, `created_at`, `updated_at`.
- États de partie: `:in_progress | :win | :draw | :error`.
- Contenu d'une case: `" "` | `"X"` | `"O"`.
- Stockage plateau: `Array` de 9 `BoardCase` ou `Hash` `{ "A1" => BoardCase }`.
- Fichiers génériques: `lib/app_arrays.rb`, `lib/app_hashes.rb`, `lib/utils.rb`.
- Modules auxiliaires possibles: `Input`, `Rules`, `Renderer` dans [[Module]].
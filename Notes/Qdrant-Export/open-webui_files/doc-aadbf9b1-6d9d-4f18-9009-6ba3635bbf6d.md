---
collection: open-webui_files
exported_at: '2026-01-11T20:52:33.831104'
id: aadbf9b1-6d9d-4f18-9009-6ba3635bbf6d
title: doc-aadbf9b1-6d9d-4f18-9009-6ba3635bbf6d
---

### 🧪 Test / Validation
```bash
rubocop .            # Linting rapide
ruby -c script_A.rb  # Vérifier la syntaxe
```
```rb
# Assertion simple
raise "invalid" unless (11.0 / 6) > 1.8
```

### ⚙️ Build / Run / Deploy
- Exécuter local: `ruby script_A.rb`.
- Scripts idempotents pour seeds/outils.
- Activer logs verbeux et `exit 1` sur erreur pour CI.

### 🚫 Pièges & bonnes pratiques
- Mélange Integer/Float: forcer `.to_f` pour divisions précises.
- `puts` ne retourne rien utile (`nil`); ne pas le chaîner pour calculs.
- Toujours vérifier `.class` lors de conversions.
- Ne pas taper des commandes shell dans IRB ; sortir avec `quit`.

### ✅ Checklist express
1. Ruby et IRB installés et testés.
2. Fichiers `.rb` rangés dans `lib/` si besoin.
3. Entrées utilisateur validées et converties.
4. Lint OK, syntaxe OK, tests élémentaires OK.
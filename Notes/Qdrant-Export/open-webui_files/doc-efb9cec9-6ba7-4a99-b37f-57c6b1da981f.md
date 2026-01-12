---
collection: open-webui_files
exported_at: '2026-01-11T20:52:33.845615'
id: efb9cec9-6ba7-4a99-b37f-57c6b1da981f
title: doc-efb9cec9-6ba7-4a99-b37f-57c6b1da981f
---

# Boucle de comptage
n = gets.chomp.to_i
(1..n).each { |i| puts i }
```

### 🔗 Relations / Composition
- [[Script]] importe [[Module]] utilitaires depuis `lib/utils.rb`.
- [[Script]] lit l'INPUT utilisateur puis affiche via `puts`.
- [[Method]] combine variables + interpolation pour produire la sortie.

### 🧪 Test / Validation
```bash
# Linter ou exécution sèche
ruby -c lib/script_A.rb        # vérifie la syntaxe
```
- Cas de test minimal: fournir un INPUT et vérifier la sortie attendue.

### ⚙️ Build / Run / Deploy
- Run local direct avec `ruby <fichier>`.
- Aucun build requis pour ces exos.
- Conserver une exécution non interactive pour l'automatisation (arguments ou INPUT simulé).

### 🚫 Pièges & bonnes pratiques
- Toujours fermer les chaînes: `"..."` sinon `unterminated string`.
- Utiliser `#{}` uniquement à l'intérieur de chaînes `"..."`.
- Nommer les variables en anglais, `snake_case`.
- Convertir les entrées: `to_i`, `to_f` avant calculs.
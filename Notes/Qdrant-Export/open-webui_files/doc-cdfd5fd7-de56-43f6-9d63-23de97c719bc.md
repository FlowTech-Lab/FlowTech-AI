---
collection: open-webui_files
exported_at: '2026-01-11T20:52:33.841749'
id: cdfd5fd7-de56-43f6-9d63-23de97c719bc
title: doc-cdfd5fd7-de56-43f6-9d63-23de97c719bc
---

### 🧩 Structures & Nommage canoniques
- Entités: [[Module]], [[Class]], [[Method]], [[Script]].
- Données: id, name, status, created_at, updated_at.
- États: draft | active | archived | error.
- Fichiers génériques: `lib/app_arrays.rb`, `lib/app_hashes.rb`, `lib/utils.rb`, `lib/script_A.rb`.

### ✍️ Snippets essentiels
```rb
# Affichage simple
puts "Bonjour, monde !"        # ajoute un retour ligne
print "Bonjour"                # sans retour ligne

# Interpolation (évalue l'expression)
puts "Total: #{10 * 5 * 11}"

# Variables
hours_per_day = 10
puts hours_per_day * 5

# Entrée utilisateur
print "> "
user_name = gets.chomp         # lit une ligne et supprime le \n
puts "Bonjour, #{user_name} !"

# Boucle de comptage
n = gets.chomp.to_i
(1..n).each { |i| puts i }
```
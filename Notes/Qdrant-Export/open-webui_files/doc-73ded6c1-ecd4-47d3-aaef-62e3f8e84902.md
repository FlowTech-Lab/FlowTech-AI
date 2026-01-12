---
collection: open-webui_files
exported_at: '2026-01-11T20:52:33.825629'
id: 73ded6c1-ecd4-47d3-aaef-62e3f8e84902
title: doc-73ded6c1-ecd4-47d3-aaef-62e3f8e84902
---

### 🧩 Structures & Nommage canoniques
- Entités: [[Entity]], [[Item]], [[Collection]], [[Service]], [[Component]], [[Module]], [[Page]], [[Hook/Util]], [[Config]].
- Données: id, name, status, created_at, updated_at.
- États: draft | active | archived | error.
- Fichiers génériques: `lib/app_arrays.rb`, `lib/app_hashes.rb`, `lib/utils.rb` (adapter au sujet).

### ✍️ Snippets essentiels
```rb
# Objectif: compter, trier, filtrer, agréger des INPUT

# Compte éléments
count = items.size

# Tri
alpha = items.sort
by_len = items.sort_by(&:length)

# Filtre sur motif
clean = items.map { |s| s.gsub(/^INPUT_/, "") }
exact5 = clean.count { |s| s.length == 5 }

# Histogramme de tailles
sizes = items.map(&:length).tally  # => {2=>3, 3=>5, ...}

# Associer deux listes en hash
currencies = %w[INPUT_A INPUT_B INPUT_C]
prices     = [1.23, 4.56, 7.89]
market = currencies.zip(prices).to_h

# Min/Max et égalités
min_val   = market.values.min
cheapest  = market.select { |_k, v| v == min_val }.keys
```
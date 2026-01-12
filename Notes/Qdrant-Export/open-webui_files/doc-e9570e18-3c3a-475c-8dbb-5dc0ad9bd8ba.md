---
collection: open-webui_files
exported_at: '2026-01-11T20:52:33.845009'
id: e9570e18-3c3a-475c-8dbb-5dc0ad9bd8ba
title: doc-e9570e18-3c3a-475c-8dbb-5dc0ad9bd8ba
---

### 🧩 Structures & Nommage canoniques
- Entités: [[Entity]], [[Item]], [[Collection]], [[Service]], [[Component]], [[Module]], [[Page]], [[Hook/Util]], [[Config]].
- Données: id, name, status, created_at, updated_at.
- États: draft | active | archived | error.
- Fichiers génériques: `lib/app_arrays.rb`, `lib/app_hashes.rb`, `lib/utils.rb`.
- Schéma: tables `cache_entries`, `solid_queue_*`, objets Active Record standards.

### ✍️ Snippets essentiels
```rb
# Objectif: écrire/lire un cache en DB
Rails.cache.fetch("KEY_INPUT", expires_in: 5.minutes) { "VALUE_INPUT" }
```
```rb
# Objectif: planifier un job avec Solid Queue
class ExampleJob < ApplicationJob
  queue_as :default
  def perform(payload = "INPUT")
    # traiter items / data ici
  end
end
ExampleJob.perform_later({ data: "INPUT" })
```
```yml
# Objectif: configurer Action Cable en base (config/cable.yml)
production:
  adapter: database
```
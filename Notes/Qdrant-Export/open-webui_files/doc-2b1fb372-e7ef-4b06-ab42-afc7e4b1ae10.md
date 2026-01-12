---
collection: open-webui_files
exported_at: '2026-01-11T20:52:33.816944'
id: 2b1fb372-e7ef-4b06-ab42-afc7e4b1ae10
title: doc-2b1fb372-e7ef-4b06-ab42-afc7e4b1ae10
---

def index_entities
    items = Entity.all
    @view.index(items)
  end
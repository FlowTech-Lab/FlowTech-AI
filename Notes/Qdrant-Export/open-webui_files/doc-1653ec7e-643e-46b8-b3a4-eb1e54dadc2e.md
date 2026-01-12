---
collection: open-webui_files
exported_at: '2026-01-11T20:52:33.815432'
id: 1653ec7e-643e-46b8-b3a4-eb1e54dadc2e
title: doc-1653ec7e-643e-46b8-b3a4-eb1e54dadc2e
---

end
end
```
```rb
# Objectif: route dynamique "show"
get '/gossips/:id/' do
  erb :show, locals: { gossip: Gossip.find(params['id']), id: params['id'] }
end
```
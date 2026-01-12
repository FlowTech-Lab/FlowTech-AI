---
collection: open-webui_files
exported_at: '2026-01-11T20:52:33.817164'
id: 2dbaaca7-f228-4b41-afc0-bff2bf50816c
title: doc-2dbaaca7-f228-4b41-afc0-bff2bf50816c
---

### 🔗 Relations / Composition
- `Game` contient `HumanPlayer` et une collection `enemies_in_sight` de `Player`.
- `HumanPlayer` hérite de `Player` et redéfinit `compute_damage`.
- Boucle principale orchestre `menu → action → riposte`.
- `kill_player` retire une référence de la collection.

### 🧪 Test / Validation
```bash
ruby -c lib/player.rb && ruby -c lib/game.rb
ruby app.rb    # vérifier fin anticipée si cible morte (break)
ruby app_2.rb  # tester menu et saisies non valides
ruby app_3.rb  # vérifier apparition progressive et victoire/défaite
```

### ⚙️ Build / Run / Deploy
- Local seul. Aucune dépendance réseau.
- Paramètres ajustables dans `[[Config]]` (PV init, tailles de packs, seuils).
- Scripts run simples via `ruby <fichier>`.
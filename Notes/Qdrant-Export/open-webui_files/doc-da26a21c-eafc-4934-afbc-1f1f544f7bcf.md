---
collection: open-webui_files
exported_at: '2026-01-11T20:52:33.843305'
id: da26a21c-eafc-4934-afbc-1f1f544f7bcf
title: doc-da26a21c-eafc-4934-afbc-1f1f544f7bcf
---

### 🧪 Test / Validation
```bash
# Audit basique accessibilité/perf (ex: Lighthouse local)
# 1) Ouvrir http://localhost:8080
# 2) Lancer Lighthouse et vérifier: contrastes, tailles, meta viewport
```

### ⚙️ Build / Run / Deploy
- Dev: servir via `python -m http.server` ou extension Live Server.
- Prod: minifier CSS/JS, compresser images, activer cache headers.
- Hébergement statique: GitHub Pages, Netlify, ou équivalent. Dossier `dist/`.

### 🚫 Pièges & bonnes pratiques
- Éviter CSS inutile: privilégier classes Bootstrap avant d'ajouter `styles.css`.
- Toujours container `.container` ou `.container-fluid` pour la mise en page.
- Vérifier lisibilité: tailles, interlignes, contrastes, hiérarchie titres.
- Charger polices/JS en CDN avec fallback local si critique.
- Optimiser images: formats modernes, dimensions adaptées.
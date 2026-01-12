---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:31.860342'
id: 3ce2f16e-c6f7-4b7c-a689-90dd7a01faa1
title: doc-3ce2f16e-c6f7-4b7c-a689-90dd7a01faa1
---

on change un microservice l’autre casse les tests d’integration sont lent, instable et demande des grosses machines ou des environnements remote de dev mock / unit tests ne sont pas vraiment le code de l’autre équipe D’où Contract test qui vit entre les end to end et les unit tests. Peut partir d’un test mock et rempalcer avec pact cote consommateur en faisait tourner, un pack listener enregistre la declaration (le DSL) et le retours attendus / generés par l’appel du test copier ce fichier vers le producteur copier a la main, dans le repo, via a broker ajoute un test pact cote producteur qui va exercer le JSON et verifier que cela marche tests de pack sont plus profonds qu’un test OPENAPI consommateur utilise pact comme mock et verifie le provider wrt le contract du mock  Pourquoi Maven n’a pas de fichier lock ?  https://www.reddit.com/r/Maven/comments/vkcmys/why_maven_doesnt_have_a_lock_file_like/?utm_source=share&utm_medium=ios_app&utm_name=ioscss&utm_content=1&utm_term=9
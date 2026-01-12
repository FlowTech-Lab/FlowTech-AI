---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:33.483329'
id: e7cac1f3-c359-4b6d-bb1b-0cca81ffa413
title: doc-e7cac1f3-c359-4b6d-bb1b-0cca81ffa413
---

sur un site Web. Une étape d’auto-réflexion utilise Gemini pour sélectionner la meilleure image pour chaque chapitre. L’agent utilise un workflow explicite, drivé par le code Java, où les étapes sont prédéfinies dans le code, plutôt que de s’appuyer sur une planification basée sur LLM. Le code est disponible sur GitHub et l’application est déployée sur Google Cloud. L’article oppose les agents de workflow explicites aux agents autonomes, en soulignant les compromis de chaque approche. Car parfois, les Agent IA autonomes qui gèrent leur propre planning hallucinent un peu trop et n’établissent pas un plan correctement, ou ne le suive pas comme il faut, voire hallucine des “function call”. Le projet utilise Cloud Build, le Cloud Run jobs, Cloud Scheduler, Firestore comme base de données, et Firebase pour le déploiement et l’automatisation du frontend. Dans le deuxième article, L’approche est différente, Guillaume utilise un outil de Workflow, plutôt que de diriger le planning avec du
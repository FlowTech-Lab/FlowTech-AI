---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:33.278416'
id: d0af4943-bb1a-4fd5-a50b-fcea812988b8
title: doc-d0af4943-bb1a-4fd5-a50b-fcea812988b8
---

: Un attaquant peut concevoir un repo local qui exécute du code arbitraire lors du clonage. CVE-2024-32465 (Important, toutes les configurations) : Le clonage à partir de fichiers .zip contenant des repos Git peut contourner les protections, et potentiellement exécuter des hooks malveillants. CVE-2024-32020 (Faible, machines multi-utilisateurs) : Les clones locaux sur le même disque peuvent permettre à des utilisateurs non approuvés de modifier des fichiers liés physiquement (hard link) dans la base de données des objets du repo cloné. CVE-2024-32021 (Faible, machines multi-utilisateurs) : Le clonage d’un repo local avec des liens symboliques (symlinks) peut entraîner la création de liens physiques vers des fichiers arbitraires dans le répertoire objects/.  Architecture Visualisation des algorithmes de rate limitation https://smudge.ai/blog/ratelimit-algorithms Méthodologies Le problème de l’implémentation alternative
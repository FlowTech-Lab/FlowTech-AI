---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:31.779875'
id: 377ef21f-c0ba-484d-b0bf-c975dca2445c
title: doc-377ef21f-c0ba-484d-b0bf-c975dca2445c
---

Initialiser la documentation : Utilisez la commande suivante pour générer
les fichiers de documentation de base :
Terminal windowantsibull-docs sphinx-init --use-current --dest-dir dest my_namespace.my_collection

--use-current : Cela permet d’utiliser la version actuelle de votre
collection pour la documentation.
--dest-dir dest : Définit le répertoire où la documentation sera générée.
Dans cet exemple, les fichiers sont placés dans le répertoire dest. Je
vous conseille dans le mettre dans un autre dossier que dans le répertoire,
pour éviter les problèmes de dépendances python.
my_namespace.my_collection : Remplacez cela par le namespace et le nom de
votre collection.
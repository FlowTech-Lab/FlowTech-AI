---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:33.642831'
id: f53fbfed-18ab-4eaf-b75d-ffbdbc0533df
title: doc-f53fbfed-18ab-4eaf-b75d-ffbdbc0533df
---

Installer les dépendances : Accédez au répertoire dest créé et
installez les dépendances nécessaires à la génération de la documentation via
Sphinx :
Terminal windowpip install -r requirements.txt
Je vous recommandé de le faire dans un environnement virtuel Python (venv)
pour éviter d’affecter les installations globales.


Construire la documentation : Une fois les dépendances installées,
exécutez le script build.sh (ou toute autre commande de construction si
personnalisée) pour générer la documentation en HTML :
Terminal window./build.sh


Visualiser la documentation : Ouvrez ensuite le fichier
build/html/index.html dans un navigateur pour visualiser la documentation
générée.
---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:33.673117'
id: fd0f5581-21fd-42af-a6d4-3bbaa943ffae
title: doc-fd0f5581-21fd-42af-a6d4-3bbaa943ffae
---

plugins/ : Ce répertoire contient divers plugins Ansible développés pour la
collection :

action/ : Contient les plugins d’action, utilisés pour modifier ou
personnaliser le comportement des tâches Ansible.
cache/ : Plugins de mise en cache, par exemple pour les faits.
filter/ : Plugins de filtres jinja, comme hello_world.py.
inventory/ : Plugins d’inventaire dynamique.
module_utils/ : Des utilitaires pour les modules, généralement des
bibliothèques de code partagées entre plusieurs modules.
modules/ : Contient les modules Ansible développés pour la
collection.
plugin_utils/ : Utilitaires partagés entre les plugins.
sub_plugins/ : Sous-plugins utilisés par d’autres plugins.
test/ : Plugins de test.


pyproject.toml : Fichier de configuration pour les outils Python comme
Poetry, Flake8, ou Black, gérant les dépendances et la
configuration du projet Python.
requirements.txt : Contient la liste des dépendances Python nécessaires au
bon fonctionnement du projet.
roles/
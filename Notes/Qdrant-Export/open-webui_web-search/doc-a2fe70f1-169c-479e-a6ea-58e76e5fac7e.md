---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:32.873926'
id: a2fe70f1-169c-479e-a6ea-58e76e5fac7e
title: doc-a2fe70f1-169c-479e-a6ea-58e76e5fac7e
---

Terminal windowpip install ansible-creatormkdir -p my_namespace/my_collectionansible-creator init collection my_namespace.mycollection $PWD/my_namespace/my_collection    Note: collection my_namespace.mycollection created at /Users/srt20/Projets/perso/ansible/ansible_collections/my_namespace/my_collection
NoteLes noms de collections sont constitués d’un espace de noms et d’un nom,
séparés par un point (.). L’espace de noms et le nom doivent tous deux être des
identifiants Python valides. Cela signifie qu’ils doivent être composés de
lettres ASCII, de chiffres et de traits de soulignement.
Cette commande génère automatiquement la structure de fichiers et de répertoires
dont vous avez besoin pour commencer à développer votre collection. Cela inclut
le fichier galaxy.yml, un fichier README.md, ainsi que les répertoires
roles/, plugins/, tests/ et autres, qui sont vides à l’initialisation.
Répertoire.devcontainer/
devcontainer.jsonRépertoiredocker/
devcontainer.jsonRépertoirepodman/
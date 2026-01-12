---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:31.675620'
id: 2c8e1459-5ffc-40f7-bcf5-e1ac70fa1a58
title: doc-2c8e1459-5ffc-40f7-bcf5-e1ac70fa1a58
---

Utiliser des noms explicites : Les clés utilisées dans vos Customs Facts
doivent être claires et explicites. Par exemple, utilisez environment au
lieu de env pour indiquer l’environnement (production, staging, etc.), ou
is_database_server pour indiquer le rôle du serveur.


Regrouper les Facts par fonction : Si vous avez plusieurs Customs Facts
liés à une même fonctionnalité, regroupez-les sous une même clé principale.
Par exemple, vous pourriez avoir un fichier JSON avec des clés comme
database, webserver, ou reverse_proxy pour regrouper des facts
spécifiques à ces rôles.


Éviter les redondances : Ne dupliquez pas les informations dans vos
Customs Facts. Si une donnée est déjà disponible via les Facts par défaut
d’Ansible, il est préférable de l’utiliser directement plutôt que de la
recréer dans un Custom Fact.
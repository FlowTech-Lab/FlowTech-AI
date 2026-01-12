---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:31.560197'
id: 202aa35a-76fa-4da7-acdc-29ddbbdbdf40
title: doc-202aa35a-76fa-4da7-acdc-29ddbbdbdf40
---

les packages volent les identifiants utilisateur, récupèrent un payload chiffré depuis des serveurs contrôlés par les pirates, puis remplacent le fichier main.js de Cursor. Persistance assurée en désactivant les mises à jour automatiques de Cursor et en redémarrant l’application avec le code malveillant intégré. Nouvelle méthode de compromission : au lieu d’injecter directement du malware, les attaquants publient des packages qui modifient des logiciels légitimes déjà installés sur le système. Persistance même après suppression : le malware reste actif même si les packages npm malveillants sont supprimés, nécessitant une réinstallation complète de Cursor. Exploitation de la confiance : en s’exécutant dans le contexte d’une application légitime (IDE), le code malveillant hérite de tous ses privilèges et accès. Package “rand-user-agent” compromis : un package légitime populaire a été infiltré pour déployer un cheval de Troie d’accès distant (RAT) dans certaines versions. Recommandations
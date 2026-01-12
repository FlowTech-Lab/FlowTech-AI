---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:33.069836'
id: b97256ac-0afd-43d4-847e-ac9f84efba02
title: doc-b97256ac-0afd-43d4-847e-ac9f84efba02
---

une gestion plus efficace du contexte asynchrone. URLPattern disponible globalement : plus besoin d’importer explicitement cette API pour effectuer des correspondances d’URL. Améliorations du modèle de permissions : le flag expérimental --experimental-permission devient --permission, signalant une stabilité accrue de cette fonctionnalité. Améliorations du test runner : les sous-tests sont désormais attendus automatiquement, simplifiant l’écriture des tests et réduisant les erreurs liées aux promesses non gérées. Intégration d’Undici 7 : amélioration des capacités du client HTTP avec de meilleures performances et un support étendu des fonctionnalités HTTP modernes. Dépréciations et suppressions :  Dépréciation de url.parse() au profit de l’API WHATWG URL. Suppression de tls.createSecurePair. Dépréciation de SlowBuffer. Dépréciation de l’instanciation de REPL sans new. Dépréciation de l’utilisation des classes Zlib sans new. Dépréciation du passage de args à spawn et execFile dans
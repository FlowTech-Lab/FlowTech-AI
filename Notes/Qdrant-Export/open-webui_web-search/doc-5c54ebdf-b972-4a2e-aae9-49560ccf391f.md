---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:32.158948'
id: 5c54ebdf-b972-4a2e-aae9-49560ccf391f
title: doc-5c54ebdf-b972-4a2e-aae9-49560ccf391f
---

Mettez à jour votre installation CUPS pour appliquer les mises à jour de sécurité lorsqu’elles sont disponibles. Envisagez de bloquer l’accès au port UDP 631 et également de désactiver le DNS-SD. Cela concerne la plupart des distributions Linux, certaines BSD, possiblement Google ChromeOS, Solaris d’Oracle et potentiellement d’autres systèmes, car CUPS est intégré à diverses distributions pour fournir la fonctionnalité d’impression. Pour exploiter cette vulnérabilité via internet ou le réseau local (LAN), un attaquant doit pouvoir accéder à votre service CUPS sur le port UDP 631. Idéalement, aucun de vous ne devrait exposer ce port sur l’internet public. L’attaquant doit également attendre que vous lanciez une tâche d’impression. Si le port 631 n’est pas directement accessible, un attaquant pourrait être en mesure de falsifier des annonces zeroconf, mDNS ou DNS-SD pour exploiter cette vulnérabilité sur un LAN.  Loi, société et organisation La version 1.0 de la definition de l’IA
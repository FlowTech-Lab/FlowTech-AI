---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:32.152705'
id: 5b083acc-2f33-44fa-af0b-fddd07e41a76
title: doc-5b083acc-2f33-44fa-af0b-fddd07e41a76
---

dollars valorisant l’entreprise à 1 milliards de dollars Le feuilleton Log4J2 (9 Dec 2021)  Grosse faille de sécurité liée à l’utilisation des versions <2.15 de Log4J2 Découverte par un chercheur en sécurité d’Alibaba Cloud Détails publiés par LunaSec  Log4J2 permet de faire de l’interpollation de texte en remplaçant des parties variables d’un message à logguer Hors il est possible d’ajouter des appels à des informations JNDI provenant d’un serveur LDAP Un serveur LDAP peut retourner une classe compilée que JNDI va executer en local lorsque Log4J2 va vouloir insérer l’information JNDI Donc potentiellement, la classe distante executée localement pourra exfiltrer des données, avoir accès aux processus qui tournent, etc.   Log4J2 a été patché rapidement, mais d’autres  failles sont apparues Différentes stratégies de mitigations ont été publiées Snyk a publié une “cheat sheet” pour remédier à la faille  Langages Kotlin à l’assaut du K2 avec son nouveau compilo (11 Nov 2021)  Lors de sa
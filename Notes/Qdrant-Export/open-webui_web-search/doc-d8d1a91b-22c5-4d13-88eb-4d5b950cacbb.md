---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:33.364714'
id: d8d1a91b-22c5-4d13-88eb-4d5b950cacbb
title: doc-d8d1a91b-22c5-4d13-88eb-4d5b950cacbb
---

les développeurs Edge Computing : 48 % de tous les développeurs edge utilisent serverless, contre seulement 33 % de tous les développeurs backend.</li> <li>Parmi les outils serverless, AWS Lambda continue de jouer un rôle prépondérant. Cependant, Google Cloud Run a considérablement gagné du terrain au cours des 12 derniers mois.</li> </ul> <p><a href="https://queue.acm.org/detail.cfm?id=3096459">SLO et dependences de service</a></p> <ul> <li>99,99 en cible interne, au dessus, il y a tant de variables entre l&#8217;utilisateur et le service que c&#8217;est perdu dans le bruit (wifi, ISP etc)</li> <li>99,999 pour les infra globales</li> <li>disponibilité est fonction du MTTF et MTBR = MTTF/(MTTF+MTTR)</li> <li>si on veut offrir 99,99, toutes les dependances critiques doivent offrir beaucoup plus, regle du 9 supplementaire</li> <li>sinon il faut des mitigation, cache, fail open etc</li> <li>dispo depend du temps de detection et du temps de recuperation</li> <li>donc forcer les clients
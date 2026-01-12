---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:33.142621'
id: bdad5ec7-9092-4f14-a3cd-3cb44cb4463b
title: doc-bdad5ec7-9092-4f14-a3cd-3cb44cb4463b
---

Plus d'informations sur l'utilisation de l'API : https://github.com/ollama/ollama/blob/main/docs/api.md

Activité du système

Lors de la réponse, qui peut être générée plus ou moins vite suivant les ressources de notre serveur. Les calculs sont générés sur notre serveur lui même et le LLM est totalement autonome.

Lorsque le LLM traite la réponse à notre prompt, voici un aperçu sur le serveur avec htop de l'activité :


Faire écouter Ollama sur le réseau

Par défaut, Ollama écoute sur le port 11434 et uniquement en local :
Code BASH :ss -unplat | grep 11434
Code :
tcp   LISTEN 0      4096       127.0.0.1:11434       0.0.0.0:*


Pour permettre à Ollama d'accepter des requêtes depuis d'autres hôtes, on édite le service systemd créé précédemment.
Dans la section [Service] on ajoute une ligne Environment :
Code BASH :Environment="OLLAMA_HOST=0.0.0.0"

On recharge systemd :
Code BASH :systemctl daemon-reload

On redémarre Ollama via le service :
Code BASH :systemctl restart ollama.service
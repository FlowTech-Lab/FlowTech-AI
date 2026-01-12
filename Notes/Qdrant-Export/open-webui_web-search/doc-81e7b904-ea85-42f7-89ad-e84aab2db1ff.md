---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:32.565025'
id: 81e7b904-ea85-42f7-89ad-e84aab2db1ff
title: doc-81e7b904-ea85-42f7-89ad-e84aab2db1ff
---

pas très pratique Orchestration de container via Kubernetes (request = min, limit = max) Kube donne au minimum request mais peut donner plus si le noeud n’est pas occupé à 100% Attention, la partie libre n’est pas distribuée équitablement mais en proportion du ratio de request demandé vs les autres. Donc les containers avec des grosses request sont privilégiés. Donc mettre limit est important Donc jouer le jeu request et monitored pour ajuster à la baisse si nécessaire. Tous les workloads doivent jouer le jeu. Kubernetes QoS (best effort , burstable et guaranteed) utilisé lorsque on tourne bas en mémoire (pas en cpu !) Discussion de la sélection du noeud (selector, affinity, taints and tolerations ou isolation/ restriction) pour isoler des qualités de service ou prédictabilité, pour la sécurité etc ) besoins mémoire : si utilisation max, pod killed. Besoins CPU : si utilisation max, on est throttled -> slow Mettre mémoire request = limit sauf si le process peut rendre de la mémoire
---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:33.285859'
id: d2a72bdf-8c7e-446f-bef1-bb355a9d5c8a
title: doc-d2a72bdf-8c7e-446f-bef1-bb355a9d5c8a
---

du modèle à l'aide de la variable d'environnement OLLAMA_MODELS, que nous aborderons dans la section Configuration. Ceci est utile si votre lecteur principal manque d'espace et que vous souhaitez stocker de grands modèles sur un lecteur secondaire.Vos premières étapes avec Ollama : Exécution d'un LLMMaintenant qu'Ollama est installé et que le serveur est actif (en cours d'exécution via l'application de bureau, le service systemd ou le conteneur Docker), vous pouvez commencer à interagir avec les LLM à l'aide de la commande ollama simple dans votre terminal.Téléchargement des modèles Ollama : La commande pullAvant d'exécuter un LLM spécifique, vous devez d'abord télécharger ses poids et ses fichiers de configuration. Ollama fournit une bibliothèque organisée de modèles ouverts populaires, facilement accessible via la commande ollama pull. Vous pouvez parcourir les modèles disponibles sur la page de la bibliothèque du site Web d'Ollama.# Exemple 1 : Extraire le dernier modèle Llama 3.2
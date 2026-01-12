---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:32.159881'
id: 5c72a26a-4ea1-44a7-bbc3-8dbd9b2b82e0
title: doc-5c72a26a-4ea1-44a7-bbc3-8dbd9b2b82e0
---

Cette commande télécharge le script et l'exécute à l'aide de sh. Le script effectue les actions suivantes :Détecte l'architecture de votre système (x86_64, ARM64).Télécharge le binaire Ollama approprié.Installe le binaire dans /usr/local/bin/ollama.Recherche les pilotes GPU nécessaires (NVIDIA CUDA, AMD ROCm) et installe les dépendances si possible (cette partie peut varier selon la distribution).Crée un utilisateur et un groupe système ollama dédiés.Configure un fichier de service systemd (/etc/systemd/system/ollama.service) pour gérer le processus du serveur Ollama.Active et démarre le service ollama, de sorte qu'il s'exécute automatiquement au démarrage et en arrière-plan.Installation manuelle de Linux et configuration de Systemd pour Ollama :Si le script échoue, ou si vous préférez un contrôle manuel (par exemple, l'installation dans un autre emplacement, la gestion des utilisateurs différemment, la garantie de versions ROCm spécifiques), consultez le guide d'installation Linux
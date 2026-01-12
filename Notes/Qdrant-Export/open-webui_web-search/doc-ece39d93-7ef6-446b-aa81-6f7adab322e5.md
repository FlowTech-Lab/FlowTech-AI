---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:33.558897'
id: ece39d93-7ef6-446b-aa81-6f7adab322e5
title: doc-ece39d93-7ef6-446b-aa81-6f7adab322e5
---

Prompting et enregistrement des réponses dans des fichiers
Dans Ollama, vous pouvez demander au modèle d’effectuer des tâches à partir du contenu d’un fichier, comme résumer un texte ou analyser des informations. Cette fonction est particulièrement utile pour les documents longs, car elle évite de devoir copier et coller du texte pour donner des instructions au modèle.
Par exemple, si vous disposez d’un fichier nommé input.txt contenant les informations que vous souhaitez résumer, vous pouvez exécuter la commande suivante :
ollama run llama3.2 "Résume le contenu de ce fichier en 50 mots." < input.txt
Le modèle lit le contenu du fichier et génère un résumé :
---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:33.653435'
id: f735b2e4-aee8-4bea-ab26-8b22383ae29d
title: doc-f735b2e4-aee8-4bea-ab26-8b22383ae29d
---

existent). Dépendances spécifiques pour chaque transport (ex: a2a-java-sdk-reference-jsonrpc, a2a-java-sdk-reference-grpc). AgentCard : décrit les capacités de l’agent. Doit spécifier le point d’accès primaire et tous les transports supportés (additionalInterfaces).   Clients A2A :  Dépendance principale : a2a-java-sdk-client. Support gRPC ajouté (en plus de JSON-RPC). HTTP+JSON/REST à venir. Dépendance spécifique pour gRPC : a2a-java-sdk-client-transport-grpc. Création de client : via ClientBuilder. Sélectionne automatiquement le transport selon l’AgentCard et la configuration client. Permet de spécifier les transports supportés par le client (withTransport).    Comment générer et éditer des images en Java avec Nano Banana, le “photoshop killer” de Google  https://glaforge.dev/posts/2025/09/09/calling-nano-banana-from-java/  Objectif : Intégrer le modèle Nano Banana (Gemini 2.5 Flash Image preview) dans des applications Java. SDK utilisé : GenAI Java SDK de Google. Compatibilité :
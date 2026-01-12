---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:31.673837'
id: 2c0bf720-4bc0-43d4-bb58-f3ec4ee5ade8
title: doc-2c0bf720-4bc0-43d4-bb58-f3ec4ee5ade8
---

dans l’annotation @Client pour faciliter le partage d’interfaces entre client et serveur. Support de la fusion dans les Bean Mappers via l’annotation @Mapping. Nouvelle liveness probe détectant les threads bloqués (deadlocked) via ThreadMXBean. Intégration Kubernetes améliorée : Mise à jour du client Java Kubernetes vers la version 22.0.1. Ajout du module Micronaut Kubernetes Client OpenAPI, offrant une alternative au client officiel avec moins de dépendances, une configuration unifiée, le support des filtres et la compatibilité Native Image. Introduction d’un nouveau runtime serveur basé sur le serveur HTTP intégré de Java, permettant de créer des applications sans dépendances serveur externes. Ajout dans Micronaut Micrometer d’un module pour instrumenter les sources de données (traces et métriques). Ajout de la condition condition dans l’annotation @MetricOptions pour contrôler l’activation des métriques via une expression. Support des Consul watches dans Micronaut Discovery Client
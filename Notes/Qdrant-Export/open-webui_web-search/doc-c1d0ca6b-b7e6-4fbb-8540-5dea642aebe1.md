---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:33.162128'
id: c1d0ca6b-b7e6-4fbb-8540-5dea642aebe1
title: doc-c1d0ca6b-b7e6-4fbb-8540-5dea642aebe1
---

https://www.wimdeblauwe.com/blog/2025/07/30/how-i-test-production-ready-spring-boot-applications/  L’auteur (Wim Deblauwe) détaille comment il structure ses tests dans une application Spring Boot destinée à la production. Le projet inclut automatiquement la dépendance spring-boot-starter-test, qui regroupe JUnit 5, AssertJ, Mockito, Awaitility, JsonAssert, XmlUnit et les outils de testing Spring. Tests unitaires : ciblent les fonctions pures (record, utilitaire), testés simplement avec JUnit et AssertJ sans démarrage du contexte Spring. Tests de cas d’usage (use case) : orchestrent la logique métier, généralement via des use cases qui utilisent un ou plusieurs dépôts de données. Tests JPA/repository : vérifient les interactions avec la base via des tests realisant des opérations CRUD (avec un contexte Spring pour la couche persistance). Tests de contrôleur : permettent de tester les endpoints web (ex. @WebMvcTest), souvent avec MockBean pour simuler les dépendances. Tests
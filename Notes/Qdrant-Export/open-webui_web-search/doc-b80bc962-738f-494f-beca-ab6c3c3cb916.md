---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:33.064337'
id: b80bc962-738f-494f-beca-ab6c3c3cb916
title: doc-b80bc962-738f-494f-beca-ab6c3c3cb916
---

java.util.concurrent.Flow pour s’affranchir de Reactive Streams</li> <li>Version cible Java 11, mais recommendation d’utiliser Java 17</li> <li>les versions 3 seront en parallèle des versions 2 le temps que l&#8217;écosystème passe à la 3, notamment les dependences jakartaee</li> <li>peut essayer facilement depuis la CLI <code>quarkus create app --stream=3.0</code></li> <li>quelques casse de compatibilités attendues mais minimisées, spécialement dans le core</li> <li>garde java 11 car demande de la communauté</li> </ul> <p><strong>Spring 6.0 est sorti</strong> <a href="https://spring.io/blog/2022/11/16/spring-framework-6-0-goes-ga">https://spring.io/blog/2022/11/16/spring-framework&#8211;6&#8211;0-goes-ga</a></p> <ul> <li>Java 17+ de base</li> <li>Jakarta EE 9+</li> <li>Hibernate 6+</li> <li>foundations pour Ahead of Time transformations pour GraalVM</li> <li>Exploration des threads virtuels <a
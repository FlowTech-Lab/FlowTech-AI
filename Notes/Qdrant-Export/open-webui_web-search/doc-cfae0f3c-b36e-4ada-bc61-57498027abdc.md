---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:33.274987'
id: cfae0f3c-b36e-4ada-bc61-57498027abdc
title: doc-cfae0f3c-b36e-4ada-bc61-57498027abdc
---

Pour l’instant, MCP n’est pas sécurisé :  Pas de standard d’authentification Pas de chiffrement de contexte Pas de vérification d’intégrité des outils   Basé sur l’article de InvariantLabs  https://invariantlabs.ai/blog/mcp-security-notification-tool-poisoning-attacks  Sortie Infinispan 15.2 - pre rolling upgrades 16.0 https://infinispan.org/blog/2025/03/27/infinispan-15-2  Support de Redis JSON + scripts Lua Métriques JVM désactivables Nouvelle console (PatternFly 6) Docs améliorées (métriques + logs) JDK 17 min, support JDK 24 Fin du serveur natif (performances)  Guillaume montre comment développer un serveur MCP HTTP Server Sent Events avec l’implémentation de référence Java et LangChain4j  https://glaforge.dev/posts/2025/04/04/mcp-client-and-server-with-java-mcp-sdk-and-langchain4j/  Développé en Java, avec l’implémentation de référence qui est aussi à la base de l’implémentation dans Spring Boot (mais indépendant de Spring) Le serveur MCP est exposé sous forme de servlet dans
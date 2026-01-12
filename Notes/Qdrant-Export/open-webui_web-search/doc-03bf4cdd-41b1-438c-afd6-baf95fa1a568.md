---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:31.268159'
id: 03bf4cdd-41b1-438c-afd6-baf95fa1a568
title: doc-03bf4cdd-41b1-438c-afd6-baf95fa1a568
---

Sigstore: plus d’élément central comme le transparency log et l’autorité de certification pour le projet sigstore, ils n’ont pas utilisé cette architecture parce que la privacy des identités notamment en cas de renommage et sur le long terme n’est pas respecté la rotation de clés et la partie client side devient beaucoup plus complexe (OIDC quoi) et ouvre des risques de sécurité (bugs d’implémentation) la clé des OIDC providers est rotaté et ce n’est pas expliqué dans le flow OpenPubkey la complexité passe de server side a client side (vu que le nonce est la clé du système) le client notamment va devoir tracker les clés de signature des providers OIDC tout le temps (ou un system devra le faire) le id token typiquement a plus d’infos qui vont leaké en tant que certificat du truc signé (privacy)  Cloud Oracle Cloud rajoute GraalOS https://blogs.oracle.com/java/post/introducing-graalos  plateforme serverless sans container application native en fait des applis compilées avec GraalVM
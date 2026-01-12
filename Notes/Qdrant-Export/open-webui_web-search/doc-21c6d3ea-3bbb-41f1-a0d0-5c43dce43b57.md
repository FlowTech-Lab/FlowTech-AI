---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:31.568089'
id: 21c6d3ea-3bbb-41f1-a0d0-5c43dce43b57
title: doc-21c6d3ea-3bbb-41f1-a0d0-5c43dce43b57
---

des variables compatibles CI  Le Flatten Maven Plugin n’est plus requis. Prend en charge les variables comme ${revision} pour le versioning. Peut être défini via maven.config ou la ligne de commande (mvn verify -Drevision=4.0.1).   Améliorations et corrections du Reactor  Correction de bug : Gestion améliorée de --also-make lors de la reprise des builds. Nouvelle option --resume (-r) pour redémarrer à partir du dernier sous-projet en échec. Les sous-projets déjà construits avec succès sont ignorés lors de la reprise. Constructions sensibles aux sous-dossiers : Possibilité d’exécuter des outils sur des sous-projets sélectionnés uniquement. Recommandation : Utiliser mvn verify plutôt que mvn clean install.   Autres Améliorations  Timestamps cohérents pour tous les sous-projets dans les archives packagées. Déploiement amélioré : Le déploiement ne se produit que si tous les sous-projets sont construits avec succès.     Changements de workflow, cycle de vie et exécution  Java 17 requis
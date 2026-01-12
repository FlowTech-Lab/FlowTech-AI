---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:33.657685'
id: f89576fd-830b-4ba1-987d-bbf55bc69bbe
title: doc-f89576fd-830b-4ba1-987d-bbf55bc69bbe
---

.test_base.yml.test_base:  stage: test  script:    - echo "Exécution des pré-tests..."
Un job spécifique de test unitaire pourrait étendre cette base :
unit_test:  extends: .test_base  script:    - echo "Exécution des tests unitaires..."    - run-unit-tests.sh
Dans cet exemple, unit_test hérite du stage test et du script initial de
.test_base, tout en ajoutant ses propres étapes de script.
Les ancres YAML
Les ancres YAML sont une fonctionnalité du langage
YAML (YAML Ain’t Markup
Language) qui permet de réutiliser des parties d’un document YAML. Cette
fonctionnalité est particulièrement utile pour éviter la répétition de
structures de données similaires et pour maintenir des configurations cohérentes
dans de grands fichiers YAML, comme ceux souvent utilisés dans la configuration
des pipelines CI/CD, les fichiers Docker Compose, etc.
Comment Fonctionnent les Ancres YAML ?
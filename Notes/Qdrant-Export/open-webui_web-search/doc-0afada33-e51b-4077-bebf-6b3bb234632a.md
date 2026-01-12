---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:31.352986'
id: 0afada33-e51b-4077-bebf-6b3bb234632a
title: doc-0afada33-e51b-4077-bebf-6b3bb234632a
---

dont on se moque de la valeur quand on explique ce bout de code Possibilité de rajouter des liens hypertextes sur certains bouts de code, pour pointer par exemple vers la JavaDoc d’une méthode utilisée dans ce bout de code Pourvu qu’ils reprennent le plus possible la syntaxe asciidoctor qui a déjà résolu ce problème  Asciidoclet  Discussion sur le raisons du besoin derrière Loom  Article qui reste d.un premier niveau, il faut creuser,les bénéfices réels IO et synchro bloque un thread. Limite scalabilité. Le code asynchrone est plus dur à comprendre. Virtual threads don’t bien pour des taches qui passent beaucoup de temps à attendre Les API IO blocantes parkent le virtual thread quand elles sont en attente Un poller (boucle d’evenement) regarde les IO et leur état et unpark les virtualthread correspondant Mechanisme similaire aux frameworks non blocs to de type vert.x mais avec une API bloxante  Librairies Quarkus 2.0 alpha 1, 2 et 3 sont sortis  Quarkus 2 parce que vert.x 4 et
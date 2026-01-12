---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:31.366984'
id: 0ea86846-ee29-4b8d-b8e7-1bc21fdd8ea6
title: doc-0ea86846-ee29-4b8d-b8e7-1bc21fdd8ea6
---

a faire une puce intégré regroupant plusieurs fonctions  Twitter open source ses algorithmes de recommendation  https://blog.twitter.com/engineering/en_us/topics/open-source/2023/twitter-recommendation-algorithm  on retrouve le code source sur Github https://github.com/twitter/the-algorithm-ml et quelqu’un a déjà trouvé où il y a des clauses particulières pour le cas où un tweet vient d’Elon Musk, où un tweet vient d’un républicain ou d’un démocrate https://uwyn.net/@danluu@mastodon.social/110119479811452246 L’algorithme de Twitter  https://aakashgupta.substack.com/p/the-real-twitter-files-the-algorithm analyse sans sensation trois étapes: aggravation des données, construction des “features”, mixage Followers, nos tweets et nous Plus gros booster likes 30x, puis retweet 20x Features: SimCluster: groupe par categories/personnes le tweet Feature: TwHIN: vecteur de prediction d’engagement pour un tweet donné Features: RealGraph, prend le tweet, the tweeter et le tweeté et construit un
---
collection: open-webui_web-search
exported_at: '2026-01-11T20:52:33.675165'
id: fdc13d83-2c8d-4f6d-bff3-8a64cfa12104
title: doc-fdc13d83-2c8d-4f6d-bff3-8a64cfa12104
---

Personnalisation avec settings.cfg
Ce fichier permet d’ajuster le comportement de l’extraction, des
téléchargements, de la déduplication ou de la gestion des métadonnées.
[DEFAULT]# TéléchargementDOWNLOAD_TIMEOUT = 30SLEEP_TIME = 5MAX_REDIRECTS = 2USER_AGENTS = Mozilla/5.0 (compatible; TrafilaturaBot/1.0)
# ExtractionMIN_EXTRACTED_SIZE = 250MIN_OUTPUT_SIZE = 1EXTRACTION_TIMEOUT = 30FAVOR_PRECISION = FalseFAVOR_RECALL = True
# DéduplicationMIN_DUPLCHECK_SIZE = 100MAX_REPETITIONS = 2
# MétadonnéesEXTENSIVE_DATE_SEARCH = TrueAUTHOR_BLACKLIST = admin,webmaster,editor
# NavigationEXTERNAL_URLS = FalseMAX_FILE_SIZE = 20000000MIN_FILE_SIZE = 10
Développer des scripts Python avec Trafilatura
Utiliser Trafilatura en Python, c’est simple et puissant. Que vous vouliez
juste extraire le texte d’un article ou automatiser l’archivage de dizaines de
pages web, l’outil vous offre une API claire et personnalisable.
Premier script : extraire une page web
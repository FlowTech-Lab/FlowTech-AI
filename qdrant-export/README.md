# Qdrant Export Service

## Description
Service Docker autonome qui exporte périodiquement les collections Qdrant vers des fichiers Markdown dans `Notes/Qdrant-Export/`, accessible via Samba.

## Configuration

### Variables d'environnement

- `QDRANT_URL` : URL du serveur Qdrant (défaut: `http://qdrant:6333`)
- `EXPORT_DIR` : Répertoire de sortie (défaut: `/mnt/export`)
- `EXPORT_SCHEDULE` : Schedule cron (défaut: `0 2 * * *` = quotidien à 2h)
- `LOG_LEVEL` : Niveau de log (défaut: `INFO`)
- `EXPORT_MODE` : Mode d'export (défaut: `normal`, ou `dry-run`)
- `CLEANUP_ORPHANED` : Supprimer fichiers orphelins (défaut: `false`)

### Exemples de schedule

```bash
# Quotidien à 2h du matin (défaut)
EXPORT_SCHEDULE="0 2 * * *"

# Toutes les 6 heures
EXPORT_SCHEDULE="0 */6 * * *"

# Hebdomadaire (lundi à 3h)
EXPORT_SCHEDULE="0 3 * * 1"
```

## Usage

### Démarrer le service

```bash
docker compose up -d qdrant-export
```

### Consulter les logs

```bash
# Logs en temps réel
docker compose logs -f qdrant-export

# Dernières lignes
docker compose logs --tail 50 qdrant-export
```

### Exécution manuelle

```bash
# Export normal (avec bonnes permissions)
docker compose exec -u exporter qdrant-export python3 /app/export-script.py

# Alternative avec runuser
docker compose exec qdrant-export runuser -u exporter -- python3 /app/export-script.py

# Dry-run (validation sans écriture)
docker compose exec -e EXPORT_MODE=dry-run -u exporter qdrant-export python3 /app/export-script.py
```

**Note** : Utilisez `-u exporter` ou `runuser -u exporter` pour créer les fichiers avec les bonnes permissions. Sans cela, les fichiers seront créés en root (artefact de test, non-bug).

### Monitoring

```bash
# Vérifier les stats d'export
cat .AI_Data/qdrant-export/export-stats.json

# Vérifier les fichiers exportés
ls -la Notes/Qdrant-Export/

# Vérifier les logs applicatifs
cat .AI_Data/qdrant-export/export.log

# Vérifier les logs cron
cat .AI_Data/qdrant-export/cron.log
```

## Fonctionnalités

- ✅ **Idempotent** : Relancer l'export plusieurs fois produit le même résultat
- ✅ **Dry-run** : Mode validation sans écriture de fichiers
- ✅ **Cleanup** : Suppression optionnelle des fichiers orphelins
- ✅ **Robuste** : Continue même si une collection échoue
- ✅ **Monitoring** : Stats JSON pour suivi

## Troubleshooting

### Le service ne démarre pas

```bash
# Vérifier les logs de build
docker compose build qdrant-export

# Vérifier la configuration
docker compose config | grep qdrant-export
```

### L'export ne s'exécute pas

```bash
# Vérifier que cron tourne
docker compose exec qdrant-export ps aux | grep cron

# Vérifier le crontab
docker compose exec qdrant-export crontab -l

# Tester manuellement
docker compose exec qdrant-export python3 /app/export-script.py
```

### Fichiers non accessibles via Samba

Vérifier que le volume est bien monté et que les permissions sont correctes :

```bash
ls -la Notes/Qdrant-Export/
```

## Architecture

- **Script Python** : Export Qdrant → Markdown avec frontmatter
- **Cron intégré** : Scheduler dans le conteneur (configurable)
- **Logs centralisés** : Via Docker logs + fichiers dans `/app/data/`
- **Health check** : Vérifie que l'export récent existe

## Notes sur les Permissions

### Comportement Normal

Lors de l'**export automatique** via cron (schedule configuré), les fichiers sont créés avec l'utilisateur `exporter` (UID 1000) :

```bash
# Vérification après export automatique
ls -la Notes/Qdrant-Export/
# -rw-r--r-- 1 1000 1000  1234 Jan 12 02:00 doc.md
```

### Tests Manuels

Lors d'un test manuel avec `docker compose exec`, spécifiez l'utilisateur :

```bash
# ❌ Incorrect (crée en root)
docker compose exec qdrant-export python3 /app/export-script.py

# ✅ Correct (crée avec exporter)
docker compose exec qdrant-export runuser -u exporter -- python3 /app/export-script.py

# Alternative (via entrypoint)
docker compose exec -u exporter qdrant-export python3 /app/export-script.py
```

### Correction si fichiers créés en root

Si des fichiers ont été créés en root lors de tests :

```bash
# Supprimer les fichiers root
sudo rm -rf Notes/Qdrant-Export/*

# Relancer export avec bonnes permissions
docker compose exec -u exporter qdrant-export python3 /app/export-script.py
```

Le prochain export automatique (via cron) créera les fichiers avec les bonnes permissions automatiquement.

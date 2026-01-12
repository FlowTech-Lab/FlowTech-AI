#!/bin/bash
# Entrypoint pour configurer cron dynamiquement depuis variables d'environnement

set -e

# Configuration du schedule depuis variable d'environnement
SCHEDULE="${EXPORT_SCHEDULE:-0 2 * * *}"

# Créer le crontab dynamiquement (exécuter le script en tant qu'utilisateur exporter)
echo "SHELL=/bin/bash" > /tmp/crontab.tmp
echo "PATH=/usr/local/bin:/usr/bin:/bin" >> /tmp/crontab.tmp
echo "$SCHEDULE cd /app && runuser -u exporter -- python3 export-script.py >> /app/data/cron.log 2>&1" >> /tmp/crontab.tmp

# Installer le crontab
crontab /tmp/crontab.tmp
rm /tmp/crontab.tmp

echo "Cron configured with schedule: $SCHEDULE"

# Démarrer cron en foreground
exec cron -f

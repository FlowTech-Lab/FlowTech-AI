#!/bin/bash
# Install hourly cron job for notes synchronization

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SYNC_SCRIPT="$SCRIPT_DIR/sync-notes.sh"
LOG_DIR="$(dirname "$SCRIPT_DIR")/logs"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Create cron job entry
CRON_JOB="0 * * * * $SYNC_SCRIPT >> $LOG_DIR/notes-sync.log 2>&1"

# Check if cron job already exists
if crontab -l 2>/dev/null | grep -qF "$SYNC_SCRIPT"; then
    echo "⚠️  Cron job already exists"
    echo "Current crontab:"
    crontab -l | grep "$SYNC_SCRIPT"
else
    # Add cron job
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    echo "✅ Cron job installed: Notes sync every hour"
    echo "   Script: $SYNC_SCRIPT"
    echo "   Log: $LOG_DIR/notes-sync.log"
fi

echo ""
echo "📋 Current crontab:"
crontab -l | grep -v "^#" | grep -v "^$"



---
collection: cursor-context
exported_at: '2026-01-11T22:30:22.098467'
id: ffa3f28f-6f82-4695-a897-ddf1a3ceafeb
title: doc-ffa3f28f-6f82-4695-a897-ddf1a3ceafeb
---

Deployment Script Fix - Post-Migration Check with set -euo pipefail:

PROBLEM IDENTIFIED:
Script was stopping at "🔍 Vérification post-migration..." due to set -euo pipefail. When grep finds nothing, it returns exit code 1, causing script to stop even with 2>/dev/null redirection.

ROOT CAUSE:
- set -euo pipefail makes script exit on any non-zero return code
- grep returns 1 when no matches found (not an error, but script treats it as failure)
- Even with 2>/dev/null, the exit code still causes script termination

SOLUTION APPLIED:
Add || echo "0" after pipe to prevent crash:
```bash
POST_PENDING_COUNT=$(echo "$POST_MIGRATION_STATUS" | grep -E "^\s*down" 2>/dev/null | wc -l | tr -d ' \n\r' || echo "0")
```

This ensures that if grep finds nothing, the command returns "0" instead of failing, preventing script termination.

LOGGING VERIFICATION:
- All log functions (log(), log_error(), log_success(), log_warning(), log_info()) use tee -a "$LOG_FILE"
- Logs written to /home/flowtech/Grenoble-Roller-Project/logs/deploy-staging.log
- Important command outputs (migrations, docker exec) are logged with 2>&1 and tee -a

BEST PRACTICE:
When using set -euo pipefail with grep in scripts, always add || echo "0" or || true to handle "no matches found" case, as grep returns exit code 1 for no matches (which is not an error condition).
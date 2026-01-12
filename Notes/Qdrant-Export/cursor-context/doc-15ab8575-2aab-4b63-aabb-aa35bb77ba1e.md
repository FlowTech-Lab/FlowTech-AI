---
collection: cursor-context
exported_at: '2026-01-11T22:30:21.996924'
id: 15ab8575-2aab-4b63-aabb-aa35bb77ba1e
title: doc-15ab8575-2aab-4b63-aabb-aa35bb77ba1e
---

Deployment Script Fix - Migration Count with awk instead of grep/wc:

PROBLEM IDENTIFIED:
grep -c and wc -l were returning "0\n0" or "00" instead of "0", causing error: [: 0\n0: integer expression expected

ROOT CAUSE:
- grep -c and wc -l can return values with newlines or multiple zeros
- tr -d ' \n\r' doesn't always clean properly
- Results in invalid integer for comparison: [ "$POST_PENDING_COUNT" -gt 0 ]

SOLUTION APPLIED:
Use awk which always returns a clean number:
```bash
POST_PENDING_COUNT=$(echo "$POST_MIGRATION_STATUS" | awk '/^\s*down/ {count++} END {print count+0}' 2>/dev/null || echo "0")
```

Why awk works better:
- awk '/pattern/ {count++} END {print count+0}' always returns a clean integer
- count+0 ensures 0 is returned even if no matches (instead of empty string)
- No need for tr or additional cleaning
- More reliable than grep/wc combination

TESTING VERIFIED:
- Migration status retrieval: OK
- Counting with awk: returns "0" correctly
- Regex validation: OK
- Numeric comparison: OK
- Health check HTTP: OK

BEST PRACTICE:
When counting pattern matches in bash scripts with set -euo pipefail, use awk instead of grep/wc combination for reliable integer output. awk '/pattern/ {count++} END {print count+0}' is more robust than grep | wc -l | tr.
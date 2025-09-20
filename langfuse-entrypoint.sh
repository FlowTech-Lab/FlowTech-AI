#!/usr/bin/env sh
set -eu

WAIT_SCRIPT="/wait-for-it.sh"

if [ ! -x "$WAIT_SCRIPT" ]; then
  echo "[WARN] $WAIT_SCRIPT not executable in container; skipping waits" >&2
else
  echo "[INFO] Waiting for postgres:5432"
  "$WAIT_SCRIPT" postgres:5432 -t 120
  echo "[INFO] Waiting for clickhouse:8123"
  "$WAIT_SCRIPT" clickhouse:8123 -t 120
fi

exec "$@"

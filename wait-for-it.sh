#!/usr/bin/env bash

# Copyright (c) 2016 Gibby Wetherald
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

set -e

cmdname=${0##*/}

echoerr() {
  if [[ $WAITFORIT_QUIET -ne 1 ]]; then
    printf "%s\n" "$*" 1>&2
  fi
}

usage() {
  cat <<USAGE >&2
Usage:
    $cmdname host:port [-s] [-t timeout] [-- command args]
    -h HOST | --host=HOST       Host or IP under test
    -p PORT | --port=PORT       TCP port under test
                                Alternatively, you specify the host and port as host:port
    -s | --strict               Only execute subcommand if the test succeeds
    -q | --quiet                Do not output any status messages
    -t TIMEOUT | --timeout=TIMEOUT
                                Timeout in seconds, zero for no timeout
    -- COMMAND ARGS             Execute command with args after the test finishes
USAGE
  exit 1
}

wait_for() {
  if [[ $WAITFORIT_TIMEOUT -gt 0 ]]; then
    echoerr "$cmdname: waiting $WAITFORIT_TIMEOUT seconds for $WAITFORIT_HOST:$WAITFORIT_PORT"
  else
    echoerr "$cmdname: waiting for $WAITFORIT_HOST:$WAITFORIT_PORT without a timeout"
  fi
  local start_ts
  start_ts=$(date +%s)
  while :; do
    if (echo > /dev/tcp/$WAITFORIT_HOST/$WAITFORIT_PORT) >/dev/null 2>&1; then
      local end_ts
      end_ts=$(date +%s)
      echoerr "$cmdname: $WAITFORIT_HOST:$WAITFORIT_PORT is available after $((end_ts - start_ts)) seconds"
      break
    fi
    sleep 1
    if [[ $WAITFORIT_TIMEOUT -gt 0 ]]; then
      local now_ts
      now_ts=$(date +%s)
      if [[ $((now_ts - start_ts)) -ge $WAITFORIT_TIMEOUT ]]; then
        echoerr "$cmdname: timeout occurred after waiting $WAITFORIT_TIMEOUT seconds for $WAITFORIT_HOST:$WAITFORIT_PORT"
        return 1
      fi
    fi
  done
  return 0
}

wait_for_wrapper() {
  local rc=0
  wait_for || rc=$?
  if [[ $rc -ne 0 && $WAITFORIT_STRICT -eq 1 ]]; then
    echoerr "$cmdname: strict mode, refusing to execute subprocess"
    return $rc
  fi
  if [[ $rc -ne 0 ]]; then
    echoerr "$cmdname: timeout reached, but continuing"
  fi
  if [[ $# -gt 0 ]]; then
    echoerr "$cmdname: executing command: $*"
    exec "$@"
  else
    return $rc
  fi
}

WAITFORIT_HOST=""
WAITFORIT_PORT=""
WAITFORIT_TIMEOUT=0
WAITFORIT_STRICT=0
WAITFORIT_QUIET=0

while [[ $# -gt 0 ]]; do
  case "$1" in
  *:* )
    IFS=':' read -r WAITFORIT_HOST WAITFORIT_PORT <<<"$1"
    shift 1
    ;;
  -h | --host)
    WAITFORIT_HOST="$2"
    shift 2
    ;;
  --host=*)
    WAITFORIT_HOST="${1#*=}"
    shift 1
    ;;
  -p | --port)
    WAITFORIT_PORT="$2"
    shift 2
    ;;
  --port=*)
    WAITFORIT_PORT="${1#*=}"
    shift 1
    ;;
  -t | --timeout)
    WAITFORIT_TIMEOUT="$2"
    shift 2
    ;;
  --timeout=*)
    WAITFORIT_TIMEOUT="${1#*=}"
    shift 1
    ;;
  -s | --strict)
    WAITFORIT_STRICT=1
    shift 1
    ;;
  -q | --quiet)
    WAITFORIT_QUIET=1
    shift 1
    ;;
  --)
    shift
    break
    ;;
  -?*)
    echoerr "Unknown option: $1"
    usage
    ;;
  *)
    break
    ;;
  esac
done

if [[ -z "$WAITFORIT_HOST" || -z "$WAITFORIT_PORT" ]]; then
  echoerr "Error: you need to provide a host and port to test."
  usage
fi

WAITFORIT_TIMEOUT=${WAITFORIT_TIMEOUT:-0}
WAITFORIT_STRICT=${WAITFORIT_STRICT:-0}
WAITFORIT_QUIET=${WAITFORIT_QUIET:-0}

wait_for_wrapper "$@"

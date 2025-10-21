#!/usr/bin/env bash
set -euo pipefail
WD=$(dirname "$0")
ROOT=$(cd "$WD/.." && pwd)
# kill proxy if running
if [ -f "$ROOT/epic-geodashboard/proxy.pid" ]; then
  PID=$(cat "$ROOT/epic-geodashboard/proxy.pid" || true)
  if [ -n "$PID" ]; then
    echo "Stopping proxy pid $PID"
    kill -9 "$PID" || true
  fi
  rm -f "$ROOT/epic-geodashboard/proxy.pid"
fi
# kill http server
if [ -f "$ROOT/http.pid" ]; then
  PID=$(cat "$ROOT/http.pid" || true)
  if [ -n "$PID" ]; then
    echo "Stopping http server pid $PID"
    kill -9 "$PID" || true
  fi
  rm -f "$ROOT/http.pid"
fi

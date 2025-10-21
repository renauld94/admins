#!/usr/bin/env bash
set -euo pipefail
WD=$(dirname "$0")
ROOT=$(cd "$WD/.." && pwd)
PY=$WD/.venv/bin/python
if [ ! -x "$PY" ]; then
  echo "venv python not found at $PY"
  echo "Run: python3 -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt"
  exit 1
fi
# Stop any running instances
bash "$ROOT/epic-geodashboard/stop_services.sh" || true
# Start proxy (use 8002 to avoid local port conflicts)
echo "Starting proxy..."
nohup "$PY" "$ROOT/epic-geodashboard/proxy.py" --host 127.0.0.1 --port 8002 > "$ROOT/epic-geodashboard/proxy.log" 2>&1 &
echo $! > "$ROOT/epic-geodashboard/proxy.pid"
sleep 0.5
echo "proxy pid:" $(cat "$ROOT/epic-geodashboard/proxy.pid")
# Start static HTTP server
echo "Starting static HTTP server on port 8080..."
nohup python3 -m http.server 8080 --directory "$ROOT" > "$ROOT/http.log" 2>&1 &
echo $! > "$ROOT/http.pid"
sleep 0.5
echo "http pid:" $(cat "$ROOT/http.pid")

echo "Logs:"
echo "proxy.log -> $ROOT/epic-geodashboard/proxy.log"
echo "http.log -> $ROOT/http.log"

echo "Done. Open http://localhost:8080/epic-geodashboard/index.html"

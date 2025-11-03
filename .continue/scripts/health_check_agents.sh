#!/usr/bin/env bash
set -euo pipefail

# Quick health-check for the minimal FastAPI agent apps under agents_continue
# Looks for services on the localhost ports the example agents use and requests /health

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
AGENTS=("core_dev:5101" "data_science:5102" "geo_intel:5103" "web_lms:5104" "systemops:5105" "legal_advisor:5106" "portfolio:5110")

echo "Checking agent health endpoints:"
for a in "${AGENTS[@]}"; do
  name=${a%%:*}
  port=${a##*:}
  url="http://127.0.0.1:${port}/health"
  status="down"
  http_code=$(curl -sS -o /dev/null -w "%{http_code}" --max-time 3 "${url}" || true)
  if [ "${http_code}" = "200" ]; then
    status="ok"
  fi
  echo "- ${name} (${url}): ${status} (HTTP ${http_code:-NA})"
done

echo "Done. To run individual agent servers, start the corresponding script under .continue/agents/agents_continue/*.py"

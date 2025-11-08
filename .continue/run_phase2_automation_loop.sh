#!/usr/bin/env bash
# Looping runner for Phase 2 local simulator
# Usage:
#   RUN_INTERVAL=300 RUN_ITERATIONS=0 bash run_phase2_automation_loop.sh
#   RUN_INTERVAL - seconds between runs (default 300 = 5 minutes)
#   RUN_ITERATIONS - number of runs to perform (0 = infinite)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIMULATOR="$SCRIPT_DIR/run_phase2_automation_local.js"
LOGFILE="/tmp/phase2_automation.log"
LOOP_LOG="/tmp/phase2_loop_runner.log"

# Defaults
: ${RUN_INTERVAL:=300}
: ${RUN_ITERATIONS:=0}

echo "[run_phase2_automation_loop] Starting loop: interval=${RUN_INTERVAL}s iterations=${RUN_ITERATIONS}" | tee -a "$LOOP_LOG"

count=0
while true; do
  count=$((count + 1))
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  echo "[${timestamp}] [loop] Starting iteration ${count}" | tee -a "$LOOP_LOG" "$LOGFILE"

  if [ ! -f "$SIMULATOR" ]; then
    echo "[${timestamp}] ERROR: simulator not found at $SIMULATOR" | tee -a "$LOOP_LOG" "$LOGFILE"
    exit 2
  fi

  # Run the Node simulator (it writes to $LOGFILE)
  node "$SIMULATOR" >> "$LOOP_LOG" 2>&1 || echo "[${timestamp}] WARNING: simulator exited with non-zero code" | tee -a "$LOOP_LOG" "$LOGFILE"

  echo "[${timestamp}] [loop] Completed iteration ${count}" | tee -a "$LOOP_LOG" "$LOGFILE"

  # Check iterations limit
  if [ "$RUN_ITERATIONS" -ne 0 ] && [ "$count" -ge "$RUN_ITERATIONS" ]; then
    echo "[${timestamp}] Reached iteration limit ($RUN_ITERATIONS). Exiting." | tee -a "$LOOP_LOG" "$LOGFILE"
    break
  fi

  # Sleep
  sleep "$RUN_INTERVAL"
done

echo "[run_phase2_automation_loop] Loop finished." | tee -a "$LOOP_LOG" "$LOGFILE"

#!/bin/bash
# Run orchestrator and agents for 2 days, log output, and generate summary report
# Usage: bash deploy_epic_moodle_2days.sh

set -e
LOGDIR="/home/simon/Learning-Management-System-Academy/logs"
mkdir -p "$LOGDIR"
START=$(date '+%Y-%m-%d %H:%M:%S')
END=$(date -d "+2 days" '+%Y-%m-%d %H:%M:%S')

# Start orchestrator and agents in background
nohup /home/simon/Learning-Management-System-Academy/.venv/bin/python /home/simon/Learning-Management-System-Academy/src/master_orchestrator.py > "$LOGDIR/orchestrator_2days.log" 2>&1 &
nohup /home/simon/Learning-Management-System-Academy/.venv/bin/python /home/simon/Learning-Management-System-Academy/src/multimedia_service.py > "$LOGDIR/multimedia_2days.log" 2>&1 &

# Monitor health and stats every 10 minutes
for ((i=0; i<288; i++)); do
  echo "--- $(date '+%Y-%m-%d %H:%M:%S') ---" >> "$LOGDIR/epic_moodle_health.log"
  curl -sS http://localhost:5100/health >> "$LOGDIR/epic_moodle_health.log"
  curl -sS http://localhost:5105/stats >> "$LOGDIR/epic_moodle_health.log"
  sleep 600
  # If current time > END, break
  NOW=$(date '+%Y-%m-%d %H:%M:%S')
  [[ "$NOW" > "$END" ]] && break
done

# After 2 days, generate summary report
python3 /home/simon/Learning-Management-System-Academy/scripts/generate_epic_moodle_report.py "$LOGDIR/epic_moodle_health.log" "$LOGDIR/orchestrator_2days.log" "$LOGDIR/multimedia_2days.log"

echo "Deployment started: $START"
echo "Deployment ended: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Summary report generated."

#!/bin/bash
# Start Epic Cinematic Animation Agent
# Run for 48 hours to create perfect visualization

set -e

echo "[INFO] Starting Epic Cinematic Animation Agent"
echo "[INFO] Will run for up to 48 hours if needed"
echo ""

AGENT_PATH="/home/simon/Learning-Management-System-Academy/.continue/agents/epic_cinematic_agent.py"

# Make executable
chmod +x "$AGENT_PATH"

# Run agent
echo "[INFO] Launching agent..."
python3 "$AGENT_PATH"

echo ""
echo "[SUCCESS] Agent completed"
echo "[INFO] View animation at: http://localhost:8080"
echo "[INFO] Production URL: https://www.simondatalab.de/hero-visualization/"

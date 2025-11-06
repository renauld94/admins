#!/bin/bash
# Simple Grafana Dashboard Import - Direct File Method

set -e

DASHBOARD_DIR="/tmp/grafana-provisioning"
DASHBOARD_FILE="$HOME/Learning-Management-System-Academy/deploy/prometheus/grafana-agent-dashboard-v2.json"

echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║                 Grafana Dashboard - Simple Import Solution                   ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

# Create a simple import package
mkdir -p "$DASHBOARD_DIR"

echo "📦 Creating import package..."
cat > "$DASHBOARD_DIR/import-instructions.txt" << 'EOF'
╔══════════════════════════════════════════════════════════════════════════════╗
║                  SIMPLE COPY-PASTE IMPORT METHOD                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

STEP 1: Copy the Dashboard JSON
--------------------------------
The JSON content is in: dashboard.json (in this folder)

Open it with:
  cat /tmp/grafana-provisioning/dashboard.json

Select ALL text (Ctrl+A) and copy it (Ctrl+C)


STEP 2: Open Grafana
--------------------
Go to: https://grafana.simondatalab.de/dashboard/new


STEP 3: Access JSON Editor
---------------------------
1. Look for the gear icon (⚙) or settings icon in the top-right
2. Click it
3. Select "JSON Model" from the menu


STEP 4: Paste and Save
-----------------------
1. You'll see a JSON editor with some default JSON
2. Select ALL the existing JSON (Ctrl+A)
3. Delete it
4. Paste your copied JSON (Ctrl+V)
5. Click "Save" button at the top of the JSON editor
6. Click "Save dashboard" (disk icon) at the top
7. Give it a name if prompted: "Agent Monitoring Dashboard"
8. Click "Save"


DONE! Your dashboard is now imported!

═══════════════════════════════════════════════════════════════════════════════

ALTERNATIVE: If JSON Model is not available
--------------------------------------------

Try this URL directly:
https://grafana.simondatalab.de/api/dashboards/db

But you'll need to wrap the JSON first. See: wrapped-dashboard.json

═══════════════════════════════════════════════════════════════════════════════

Dashboard Details:
  • Name: Agent Monitoring Dashboard v2
  • UID: agent-monitoring-v2
  • Panels: 7 (Running Agents, Stopped Agents, Memory, Load, Graphs, Table)
  • Datasource: Prometheus

After Import, Access at:
  https://grafana.simondatalab.de/d/agent-monitoring-v2

═══════════════════════════════════════════════════════════════════════════════
EOF

# Copy dashboard
cp "$DASHBOARD_FILE" "$DASHBOARD_DIR/dashboard.json"

# Create wrapped version for API
jq -n --argfile dashboard "$DASHBOARD_FILE" \
  '{
    dashboard: $dashboard,
    overwrite: true,
    message: "Agent Monitoring Dashboard - Professional Style"
  }' > "$DASHBOARD_DIR/wrapped-dashboard.json" 2>/dev/null || \
  echo '{"error": "jq not available for wrapping"}' > "$DASHBOARD_DIR/wrapped-dashboard.json"

echo "✓ Import package created at: $DASHBOARD_DIR"
echo ""

# Open file manager to the directory
if command -v nautilus >/dev/null 2>&1; then
    nautilus "$DASHBOARD_DIR" 2>/dev/null &
    echo "✓ Opened file manager at: $DASHBOARD_DIR"
elif command -v dolphin >/dev/null 2>&1; then
    dolphin "$DASHBOARD_DIR" 2>/dev/null &
    echo "✓ Opened file manager at: $DASHBOARD_DIR"
elif command -v thunar >/dev/null 2>&1; then
    thunar "$DASHBOARD_DIR" 2>/dev/null &
    echo "✓ Opened file manager at: $DASHBOARD_DIR"
else
    echo "📁 Files are at: $DASHBOARD_DIR"
fi

echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║                           QUICK INSTRUCTIONS                                  ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""
echo "1. Open the dashboard JSON file:"
echo "   cat $DASHBOARD_DIR/dashboard.json"
echo ""
echo "2. Copy ALL the JSON content"
echo ""
echo "3. Go to Grafana and create new dashboard:"
echo "   https://grafana.simondatalab.de/dashboard/new"
echo ""
echo "4. Click gear icon (⚙) → 'JSON Model'"
echo ""
echo "5. Delete existing JSON, paste yours, and save"
echo ""
echo "OR... just use the standalone dashboard (already working!):"
echo "   http://localhost:8080/unified_agent_dashboard.html"
echo ""
echo "Full instructions: cat $DASHBOARD_DIR/import-instructions.txt"
echo ""

# Also open Grafana
echo "Opening Grafana in browser..."
xdg-open "https://grafana.simondatalab.de/dashboard/new" 2>/dev/null &

echo ""
echo "Built with precision | Simon Data Lab | Enterprise ML Systems"

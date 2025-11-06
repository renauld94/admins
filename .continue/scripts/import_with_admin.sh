#!/bin/bash
# Grafana Dashboard Import with Admin Access
# User: sn.renauld@gmail.com (Grafana Admin)

set -e

GRAFANA_URL="https://grafana.simondatalab.de"
DASHBOARD_FILE="$HOME/Learning-Management-System-Academy/deploy/prometheus/grafana-agent-dashboard.json"

echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║           Import Dashboard with Admin Access                                  ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""
echo "✓ Grafana Admin: sn.renauld@gmail.com"
echo "✓ Role: Admin in Main Org."
echo ""

# Method 1: Direct Browser Import (Recommended)
echo "════════════════════════════════════════════════════════════════════════════════"
echo " METHOD 1: Import via Browser (Recommended)"
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""
echo "Since you have Admin access, try these steps:"
echo ""
echo "1. Open a NEW incognito/private browser window"
echo "   (This clears any cached permissions)"
echo ""
echo "2. Login to Grafana:"
echo "   URL: $GRAFANA_URL"
echo "   Email: sn.renauld@gmail.com"
echo ""
echo "3. Go directly to import page:"
echo "   URL: $GRAFANA_URL/dashboard/import"
echo ""
echo "4. Upload the dashboard JSON:"
echo "   File: $DASHBOARD_FILE"
echo ""
echo "5. Select Prometheus datasource and click Import"
echo ""

# Method 2: Create API Key
echo "════════════════════════════════════════════════════════════════════════════════"
echo " METHOD 2: Import via API (For Automation)"
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""
echo "Create an API key with your admin account:"
echo ""
echo "1. Go to: $GRAFANA_URL/org/apikeys"
echo "2. Click 'Add API Key'"
echo "3. Settings:"
echo "   - Key name: 'Dashboard Import'"
echo "   - Role: 'Admin'"
echo "   - Time to live: '1h' (or longer)"
echo "4. Click 'Add'"
echo "5. Copy the API key"
echo ""
echo "Then run this command (replace YOUR_API_KEY):"
echo ""
cat << 'EOF'
GRAFANA_URL="https://grafana.simondatalab.de"
API_KEY="YOUR_API_KEY_HERE"

# Wrap dashboard in required format
jq -n \
  --argfile dashboard ~/Learning-Management-System-Academy/deploy/prometheus/grafana-agent-dashboard.json \
  '{
    dashboard: $dashboard,
    overwrite: true,
    message: "Agent Monitoring Dashboard - Professional Style"
  }' | \
curl -X POST "$GRAFANA_URL/api/dashboards/db" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d @- | jq
EOF
echo ""

# Method 3: Check for existing dashboard conflict
echo "════════════════════════════════════════════════════════════════════════════════"
echo " METHOD 3: Check for UID Conflict"
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""
echo "The 500 errors might be because a dashboard with UID 'agent-monitoring' exists."
echo ""
echo "Try this alternative dashboard with a unique UID:"
echo ""

# Create timestamped dashboard
TIMESTAMP=$(date +%s)
ALT_DASHBOARD="$HOME/Learning-Management-System-Academy/deploy/prometheus/grafana-agent-dashboard-alt-${TIMESTAMP}.json"

if command -v jq >/dev/null 2>&1; then
    jq --arg ts "$TIMESTAMP" \
       '.uid = "agent-mon-\($ts)" | .title = "Agent Monitoring Dashboard (Import \($ts))"' \
       "$DASHBOARD_FILE" > "$ALT_DASHBOARD"
    echo "✓ Created alternative dashboard:"
    echo "  $ALT_DASHBOARD"
    echo ""
    echo "Try importing this file instead - it has a unique UID."
else
    echo "⚠ jq not available. You can manually change the UID in the JSON:"
    echo "  1. Open: $DASHBOARD_FILE"
    echo "  2. Change: \"uid\": \"agent-monitoring\""
    echo "  3. To: \"uid\": \"agent-monitoring-$(date +%Y%m%d)\""
    echo "  4. Save and try importing again"
fi
echo ""

# Method 4: Manual Dashboard Creation
echo "════════════════════════════════════════════════════════════════════════════════"
echo " METHOD 4: Manual Dashboard Creation"
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""
echo "If import still fails, create manually:"
echo ""
echo "1. Create new dashboard:"
echo "   $GRAFANA_URL/dashboard/new"
echo ""
echo "2. Click the gear icon (⚙) in top right → 'JSON Model'"
echo ""
echo "3. Copy the JSON:"
if command -v xclip >/dev/null 2>&1; then
    cat "$DASHBOARD_FILE" | xclip -selection clipboard 2>/dev/null && \
        echo "   ✓ JSON copied to clipboard!" || \
        echo "   Copy manually: cat $DASHBOARD_FILE"
else
    echo "   Copy manually: cat $DASHBOARD_FILE"
fi
echo ""
echo "4. In Grafana JSON editor:"
echo "   - Select all existing JSON and delete it"
echo "   - Paste your dashboard JSON"
echo "   - Click 'Save' in the JSON editor"
echo ""
echo "5. Save the dashboard:"
echo "   - Click 'Save dashboard' (disk icon)"
echo "   - Add description if needed"
echo "   - Click 'Save'"
echo ""

# Open browser
echo "════════════════════════════════════════════════════════════════════════════════"
echo " Opening Browser..."
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""

# Open Grafana in new incognito window
if command -v google-chrome >/dev/null 2>&1; then
    google-chrome --incognito "$GRAFANA_URL/dashboard/import" 2>/dev/null &
    echo "✓ Opening Chrome in incognito mode"
elif command -v firefox >/dev/null 2>&1; then
    firefox --private-window "$GRAFANA_URL/dashboard/import" 2>/dev/null &
    echo "✓ Opening Firefox in private mode"
else
    xdg-open "$GRAFANA_URL/dashboard/import" 2>/dev/null &
    echo "✓ Opening browser"
fi

echo ""
echo "════════════════════════════════════════════════════════════════════════════════"
echo " Quick Diagnostics"
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""

# Check dashboard file
if [ -f "$DASHBOARD_FILE" ]; then
    echo "✓ Dashboard file exists: $DASHBOARD_FILE"
    SIZE=$(du -h "$DASHBOARD_FILE" | cut -f1)
    echo "  Size: $SIZE"
    
    # Validate JSON
    if command -v jq >/dev/null 2>&1; then
        if jq empty "$DASHBOARD_FILE" 2>/dev/null; then
            echo "✓ JSON is valid"
            TITLE=$(jq -r '.title' "$DASHBOARD_FILE" 2>/dev/null || echo "N/A")
            UID=$(jq -r '.uid' "$DASHBOARD_FILE" 2>/dev/null || echo "N/A")
            PANELS=$(jq '.panels | length' "$DASHBOARD_FILE" 2>/dev/null || echo "N/A")
            echo "  Title: $TITLE"
            echo "  UID: $UID"
            echo "  Panels: $PANELS"
        else
            echo "✗ JSON validation failed"
        fi
    fi
else
    echo "✗ Dashboard file not found"
fi
echo ""

# Check Prometheus
if curl -s http://localhost:9090/api/v1/query?query=agents_running_total >/dev/null 2>&1; then
    AGENTS=$(curl -s 'http://localhost:9090/api/v1/query?query=agents_running_total' | jq -r '.data.result[0].value[1]' 2>/dev/null || echo "N/A")
    echo "✓ Prometheus is collecting metrics"
    echo "  Running agents: $AGENTS"
else
    echo "✗ Cannot reach Prometheus"
fi
echo ""

echo "════════════════════════════════════════════════════════════════════════════════"
echo " Summary"
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""
echo "You have FULL ADMIN ACCESS to Grafana."
echo ""
echo "The 403/500 errors are likely due to:"
echo "  1. Browser cache/session issues → Try incognito mode"
echo "  2. Dashboard UID conflict → Try alternative dashboard"
echo "  3. API endpoint issue → Try manual JSON import"
echo ""
echo "Recommended approach:"
echo "  1. Use incognito browser window (opens automatically)"
echo "  2. Login fresh: sn.renauld@gmail.com"
echo "  3. Go to: $GRAFANA_URL/dashboard/import"
echo "  4. Upload: $DASHBOARD_FILE"
echo "  5. If fails: Try alternative dashboard (created above)"
echo "  6. If still fails: Use manual JSON method (Method 4)"
echo ""
echo "Built with precision | Simon Data Lab | Enterprise ML Systems"

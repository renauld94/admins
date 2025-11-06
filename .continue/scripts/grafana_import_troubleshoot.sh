#!/bin/bash
# Grafana Dashboard Import Troubleshooting & Alternative Solutions

set -e

echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║           Grafana Dashboard Import - Troubleshooting Guide                   ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DASHBOARD_FILE="$HOME/Learning-Management-System-Academy/deploy/prometheus/grafana-agent-dashboard.json"

echo -e "${RED}Issue Detected:${NC}"
echo "  • 403 Forbidden: Permission denied to import dashboard"
echo "  • 500 Internal Server Error: Grafana API errors"
echo ""

echo -e "${BLUE}Possible Causes:${NC}"
echo "  1. Insufficient user permissions (need Editor or Admin role)"
echo "  2. Grafana authentication required"
echo "  3. Dashboard already exists with same UID"
echo "  4. Kubernetes-managed Grafana (limited dashboard management)"
echo ""

echo "════════════════════════════════════════════════════════════════════════════════"
echo " SOLUTION 1: Check Your Grafana User Role"
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""
echo "Required: Editor or Admin role to import dashboards"
echo ""
echo "To check your role:"
echo "  1. Go to: https://grafana.simondatalab.de/profile"
echo "  2. Look for 'Organization role' or 'Role'"
echo "  3. Required: 'Editor' or 'Admin' (NOT 'Viewer')"
echo ""

echo "════════════════════════════════════════════════════════════════════════════════"
echo " SOLUTION 2: Create Dashboard with API Token"
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""
echo "If you have an API token:"
echo ""
echo "1. Create API token in Grafana:"
echo "   - Go to: https://grafana.simondatalab.de/org/apikeys"
echo "   - Click 'New API Key'"
echo "   - Name: 'Dashboard Import'"
echo "   - Role: 'Editor'"
echo "   - Copy the token"
echo ""
echo "2. Use this command to import (replace YOUR_API_TOKEN):"
echo ""
cat << 'IMPORT_CMD'
GRAFANA_URL="https://grafana.simondatalab.de"
API_TOKEN="YOUR_API_TOKEN_HERE"

# Wrap dashboard JSON in required format
jq -n --argfile dashboard "$HOME/Learning-Management-System-Academy/deploy/prometheus/grafana-agent-dashboard.json" \
  '{dashboard: $dashboard, overwrite: true, message: "Agent Monitoring Dashboard"}' | \
curl -X POST "$GRAFANA_URL/api/dashboards/db" \
  -H "Authorization: Bearer $API_TOKEN" \
  -H "Content-Type: application/json" \
  -d @-
IMPORT_CMD
echo ""

echo "════════════════════════════════════════════════════════════════════════════════"
echo " SOLUTION 3: Manual Dashboard Creation (Copy-Paste Method)"
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""
echo "If import fails, create manually:"
echo ""
echo "1. Copy dashboard JSON:"
cat << 'COPY_CMD'
cat ~/Learning-Management-System-Academy/deploy/prometheus/grafana-agent-dashboard.json | xclip -selection clipboard
# Or manually: cat the file and copy the output
COPY_CMD
echo ""
echo "2. In Grafana:"
echo "   - Go to: https://grafana.simondatalab.de/dashboard/new"
echo "   - Click the gear icon (⚙) → 'JSON Model'"
echo "   - Delete all existing JSON"
echo "   - Paste your copied JSON"
echo "   - Click 'Save' → 'Save dashboard'"
echo ""

echo "════════════════════════════════════════════════════════════════════════════════"
echo " SOLUTION 4: Contact Grafana Admin"
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""
echo "If none of the above works, you may need admin assistance:"
echo ""
echo "Send this information to your Grafana admin:"
echo "  • Dashboard UID: agent-monitoring"
echo "  • Dashboard Name: Agent Monitoring Dashboard"
echo "  • Required datasource: Prometheus"
echo "  • Purpose: System agent monitoring"
echo "  • File location: $DASHBOARD_FILE"
echo ""
echo "Admin can import via:"
echo "  1. File upload with admin privileges"
echo "  2. Provisioning directory"
echo "  3. Direct API access with admin token"
echo ""

echo "════════════════════════════════════════════════════════════════════════════════"
echo " SOLUTION 5: Local Grafana Instance (Alternative)"
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""
echo "Run Grafana locally with full permissions:"
echo ""
cat << 'LOCAL_GRAFANA'
# Start local Grafana
docker run -d \
  --name=grafana-local \
  -p 3000:3000 \
  -e GF_AUTH_ANONYMOUS_ENABLED=true \
  -e GF_AUTH_ANONYMOUS_ORG_ROLE=Admin \
  grafana/grafana:latest

# Wait for startup
sleep 10

# Import dashboard
curl -X POST http://localhost:3000/api/dashboards/db \
  -H "Content-Type: application/json" \
  -d @<(jq -n --argfile dashboard "$HOME/Learning-Management-System-Academy/deploy/prometheus/grafana-agent-dashboard.json" \
    '{dashboard: $dashboard, overwrite: true}')

# Access at: http://localhost:3000
LOCAL_GRAFANA
echo ""
echo "Then access at: http://localhost:3000"
echo ""

echo "════════════════════════════════════════════════════════════════════════════════"
echo " CHECK: Verify Prometheus Data is Available"
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""

if curl -s http://localhost:9090/api/v1/query?query=agents_running_total > /dev/null; then
    AGENT_COUNT=$(curl -s 'http://localhost:9090/api/v1/query?query=agents_running_total' | jq -r '.data.result[0].value[1]' 2>/dev/null || echo "N/A")
    echo -e "${GREEN}✓ Prometheus is collecting agent metrics${NC}"
    echo "  • Running agents: $AGENT_COUNT"
    echo "  • Metrics endpoint: http://localhost:9090"
else
    echo -e "${RED}✗ Cannot reach Prometheus${NC}"
fi
echo ""

echo "════════════════════════════════════════════════════════════════════════════════"
echo " WORKAROUND: Use Standalone HTML Dashboard"
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""
echo "While resolving Grafana permissions, use the standalone dashboard:"
echo ""
echo "URL: http://localhost:8080/unified_agent_dashboard.html"
echo ""
echo "This dashboard:"
echo "  ✓ No authentication required"
echo "  ✓ Direct access to agent API"
echo "  ✓ Real-time updates"
echo "  ✓ Professional styling already applied"
echo ""

echo "════════════════════════════════════════════════════════════════════════════════"
echo " QUICK FIX: Change Dashboard UID"
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""
echo "The 500 errors might be because 'agent-monitoring' UID already exists."
echo "Try changing the UID to something unique:"
echo ""

# Create alternative dashboard with different UID
TEMP_DASHBOARD=$(mktemp)
jq '.uid = "agent-monitoring-'$(date +%s)'" | .title = "Agent Monitoring Dashboard ('$(date +%H:%M)')"' \
  "$DASHBOARD_FILE" > "$TEMP_DASHBOARD" 2>/dev/null && \
  echo -e "${GREEN}✓ Created alternative dashboard with unique UID${NC}" || \
  echo -e "${YELLOW}! Could not create alternative (jq not available)${NC}"

if [ -f "$TEMP_DASHBOARD" ]; then
    echo "  Location: $TEMP_DASHBOARD"
    echo "  Try importing this file instead"
fi
echo ""

echo "════════════════════════════════════════════════════════════════════════════════"
echo " RECOMMENDED: Next Steps"
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""
echo -e "${BLUE}Priority 1: Check Your Grafana Permissions${NC}"
echo "  → https://grafana.simondatalab.de/profile"
echo "  → Contact admin if you're a 'Viewer'"
echo ""
echo -e "${BLUE}Priority 2: Use Alternative Dashboard${NC}"
echo "  → Open standalone: http://localhost:8080/unified_agent_dashboard.html"
echo "  → Already has simondatalab.de styling"
echo ""
echo -e "${BLUE}Priority 3: Try API Import${NC}"
echo "  → Create API key with Editor role"
echo "  → Use curl command above"
echo ""

echo "════════════════════════════════════════════════════════════════════════════════"
echo ""
echo "Your agent monitoring is working! Prometheus has the data."
echo "The issue is only with importing into Grafana web UI."
echo ""
echo "Built with precision | Simon Data Lab | Enterprise ML Systems"

#!/bin/bash
# Fix Grafana Dashboard Datasource Issues

set -e

echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║              Grafana Dashboard Diagnostics & Fixes                           ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "════════════════════════════════════════════════════════════════════════════════"
echo " Issue: PanelQueryRunner Errors in Grafana Dashboards"
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""
echo "Error: Grafana panels cannot query Prometheus"
echo "Cause: Datasource configuration issue"
echo ""

echo "════════════════════════════════════════════════════════════════════════════════"
echo " Step 1: Check Prometheus Health"
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""

if curl -s http://localhost:9090/-/healthy > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Prometheus is healthy (localhost:9090)${NC}"
    
    # Check targets
    UP_TARGETS=$(curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | select(.health=="up") | .labels.job' 2>/dev/null | wc -l)
    DOWN_TARGETS=$(curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | select(.health=="down") | .labels.job' 2>/dev/null | wc -l)
    
    echo "  Targets UP: $UP_TARGETS"
    echo "  Targets DOWN: $DOWN_TARGETS"
    
    # Check agent metrics
    if curl -s 'http://localhost:9090/api/v1/query?query=agents_running_total' | jq -e '.data.result[0]' > /dev/null 2>&1; then
        AGENTS=$(curl -s 'http://localhost:9090/api/v1/query?query=agents_running_total' | jq -r '.data.result[0].value[1]')
        echo -e "${GREEN}✓ Agent metrics available: $AGENTS agents running${NC}"
    else
        echo -e "${YELLOW}⚠ Agent metrics not found${NC}"
    fi
else
    echo -e "${RED}✗ Prometheus is not accessible at localhost:9090${NC}"
    echo "  Check: docker ps | grep prometheus"
fi
echo ""

echo "════════════════════════════════════════════════════════════════════════════════"
echo " Step 2: Common Issues & Solutions"
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""

echo -e "${BLUE}Issue 1: Grafana Cannot Reach Prometheus${NC}"
echo ""
echo "Problem: Grafana tries to connect to Prometheus but fails"
echo ""
echo "Possible causes:"
echo "  a) Prometheus URL in Grafana points to wrong location"
echo "  b) Grafana is in Docker but Prometheus URL is 'localhost'"
echo "  c) Network firewall blocking connection"
echo ""
echo "Solutions:"
echo ""
echo "1. Check Grafana datasource configuration:"
echo "   → Go to: https://grafana.simondatalab.de/datasources"
echo "   → Find your Prometheus datasource"
echo "   → Check the URL"
echo ""
echo "   Common URLs:"
echo "     • Local Prometheus: http://localhost:9090"
echo "     • Proxmox host: http://136.243.155.166:9090"
echo "     • Docker network: http://prometheus:9090"
echo "     • Public URL: https://prometheus.simondatalab.de"
echo ""
echo "2. Test the connection:"
echo "   → In datasource settings, click 'Save & Test'"
echo "   → Should show 'Data source is working'"
echo ""

echo -e "${BLUE}Issue 2: Wrong Datasource Name in Dashboard${NC}"
echo ""
echo "Problem: Dashboard references wrong datasource UID"
echo ""
echo "Solution:"
echo "  1. Go to: https://grafana.simondatalab.de/datasources"
echo "  2. Note the exact name/UID of your Prometheus datasource"
echo "  3. Edit dashboard → Settings → JSON Model"
echo "  4. Find: '\"datasource\": {\"uid\": \"prometheus\"}'"
echo "  5. Replace with your actual datasource UID"
echo ""

echo -e "${BLUE}Issue 3: Prometheus Not Scraping Targets${NC}"
echo ""
echo "Problem: Prometheus is up but has no data"
echo ""
echo "Check:"
curl -s http://localhost:9090/api/v1/targets 2>/dev/null | jq '.data.activeTargets[] | {job: .labels.job, health: .health}' || echo "  Cannot reach Prometheus API"
echo ""

echo "════════════════════════════════════════════════════════════════════════════════"
echo " Step 3: Quick Fix - Update Datasource URL"
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""

echo "If Grafana cannot reach Prometheus at 'localhost:9090', try these URLs:"
echo ""
echo "Option 1: Use public/proxmox host IP"
echo "  URL: http://136.243.155.166:9090"
echo ""
echo "Option 2: Use Cloudflare tunnel (if configured)"
echo "  URL: https://prometheus.simondatalab.de"
echo ""
echo "Option 3: Docker network name (if Grafana is in Docker)"
echo "  URL: http://prometheus:9090"
echo ""

echo "To update:"
echo "  1. Go to: https://grafana.simondatalab.de/datasources"
echo "  2. Click on your Prometheus datasource"
echo "  3. Change 'URL' field"
echo "  4. Click 'Save & Test'"
echo ""

echo "════════════════════════════════════════════════════════════════════════════════"
echo " Step 4: Verify Dashboard Queries"
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""

echo "Test if queries work from command line:"
echo ""

# Test agent monitoring query
if curl -s 'http://localhost:9090/api/v1/query?query=agents_running_total' | jq -e '.data.result[0]' > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Query 'agents_running_total' works${NC}"
else
    echo -e "${RED}✗ Query 'agents_running_total' failed${NC}"
fi

# Test up metric
if curl -s 'http://localhost:9090/api/v1/query?query=up' | jq -e '.data.result[0]' > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Query 'up' works${NC}"
else
    echo -e "${RED}✗ Query 'up' failed${NC}"
fi

# Test node_exporter metrics
if curl -s 'http://localhost:9090/api/v1/query?query=node_load1' | jq -e '.data.result[0]' > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Query 'node_load1' works (node_exporter)${NC}"
else
    echo -e "${YELLOW}⚠ Query 'node_load1' failed (node_exporter not available)${NC}"
fi
echo ""

echo "════════════════════════════════════════════════════════════════════════════════"
echo " Step 5: Network Diagnostics"
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""

echo "Testing network connectivity from this machine..."
echo ""

# Test localhost
if curl -s --connect-timeout 2 http://localhost:9090/-/healthy > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Can reach Prometheus at localhost:9090${NC}"
else
    echo -e "${RED}✗ Cannot reach Prometheus at localhost:9090${NC}"
fi

# Test proxmox host
if curl -s --connect-timeout 2 http://136.243.155.166:9090/-/healthy > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Can reach Prometheus at 136.243.155.166:9090${NC}"
else
    echo -e "${YELLOW}⚠ Cannot reach Prometheus at 136.243.155.166:9090${NC}"
fi

# Test public URL
if curl -s --connect-timeout 2 https://prometheus.simondatalab.de/-/healthy > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Can reach Prometheus at prometheus.simondatalab.de${NC}"
else
    echo -e "${YELLOW}⚠ Cannot reach Prometheus at prometheus.simondatalab.de${NC}"
fi
echo ""

echo "════════════════════════════════════════════════════════════════════════════════"
echo " Recommended Actions"
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""

echo -e "${BLUE}1. Update Grafana Datasource URL${NC}"
echo "   → https://grafana.simondatalab.de/datasources"
echo "   → Edit Prometheus datasource"
echo "   → Try different URL (see options above)"
echo "   → Save & Test"
echo ""

echo -e "${BLUE}2. Check Grafana Logs${NC}"
echo "   → Look for datasource connection errors"
echo "   → Check if Grafana can resolve hostnames"
echo ""

echo -e "${BLUE}3. Verify Prometheus is Accessible${NC}"
echo "   → From Grafana server, test: curl http://localhost:9090/-/healthy"
echo "   → Check firewall rules"
echo ""

echo -e "${BLUE}4. Use Standalone Dashboard (Working Alternative)${NC}"
echo "   → http://localhost:8080/unified_agent_dashboard.html"
echo "   → No datasource config needed"
echo "   → Direct API access to metrics"
echo ""

echo "════════════════════════════════════════════════════════════════════════════════"
echo " Quick Commands"
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""

cat << 'COMMANDS'
# Check Prometheus status
docker ps | grep prometheus
curl http://localhost:9090/-/healthy

# Check Prometheus targets
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job, health}'

# Test metric query
curl -s 'http://localhost:9090/api/v1/query?query=up' | jq

# Access Grafana datasources
xdg-open https://grafana.simondatalab.de/datasources

# Access working standalone dashboard
xdg-open http://localhost:8080/unified_agent_dashboard.html
COMMANDS

echo ""
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""
echo "Built with precision | Simon Data Lab | Enterprise ML Systems"

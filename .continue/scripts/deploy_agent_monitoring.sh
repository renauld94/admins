#!/bin/bash
# Deploy Agent Monitoring to Prometheus + Grafana
# Simon Data Lab - Professional Infrastructure

set -e

echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║          Agent Monitoring Deployment to Prometheus + Grafana                 ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

BASE_DIR="/home/simon/Learning-Management-System-Academy"
CONTINUE_DIR="$BASE_DIR/.continue"
PROMETHEUS_DIR="$BASE_DIR/deploy/prometheus"

echo -e "${BLUE}Step 1: Installing Agent Exporter Service${NC}"
echo "────────────────────────────────────────────────────────────────────────────────"

# Copy service file to user systemd
cp "$CONTINUE_DIR/systemd/agent-exporter.service" ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable agent-exporter.service
systemctl --user start agent-exporter.service

echo -e "${GREEN}✓ Agent exporter service installed and started${NC}"
echo ""

# Wait for exporter to start
sleep 2

echo -e "${BLUE}Step 2: Testing Agent Exporter${NC}"
echo "────────────────────────────────────────────────────────────────────────────────"

if curl -s http://localhost:9200/metrics > /dev/null; then
    echo -e "${GREEN}✓ Agent exporter is responding on port 9200${NC}"
    echo ""
    echo "Sample metrics:"
    curl -s http://localhost:9200/metrics | head -20
    echo "..."
else
    echo -e "${RED}✗ Agent exporter is not responding${NC}"
    echo "Check logs: journalctl --user -u agent-exporter.service -f"
    exit 1
fi
echo ""

echo -e "${BLUE}Step 3: Updating Prometheus Configuration${NC}"
echo "────────────────────────────────────────────────────────────────────────────────"

if [ -f "$PROMETHEUS_DIR/prometheus.yml" ]; then
    # Backup existing config
    cp "$PROMETHEUS_DIR/prometheus.yml" "$PROMETHEUS_DIR/prometheus.yml.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${GREEN}✓ Backed up existing prometheus.yml${NC}"
fi

# Copy new config
cp "$PROMETHEUS_DIR/prometheus.yml.new" "$PROMETHEUS_DIR/prometheus.yml"
echo -e "${GREEN}✓ Updated prometheus.yml with agent-monitoring job${NC}"
echo ""

echo -e "${BLUE}Step 4: Restarting Prometheus${NC}"
echo "────────────────────────────────────────────────────────────────────────────────"

cd "$PROMETHEUS_DIR"
docker-compose restart prometheus

echo -e "${GREEN}✓ Prometheus restarted${NC}"
echo ""

# Wait for Prometheus to start
sleep 5

echo -e "${BLUE}Step 5: Verifying Prometheus Target${NC}"
echo "────────────────────────────────────────────────────────────────────────────────"

if curl -s http://localhost:9090/api/v1/targets | grep -q "agent-monitoring"; then
    echo -e "${GREEN}✓ Prometheus is scraping agent-monitoring target${NC}"
else
    echo -e "${YELLOW}⚠ Agent-monitoring target not found yet (may take a moment)${NC}"
fi
echo ""

echo -e "${BLUE}Step 6: Grafana Dashboard Information${NC}"
echo "────────────────────────────────────────────────────────────────────────────────"
echo ""
echo "Dashboard JSON file created at:"
echo "  $PROMETHEUS_DIR/grafana-agent-dashboard.json"
echo ""
echo "To import the dashboard into Grafana:"
echo "  1. Go to: https://grafana.simondatalab.de"
echo "  2. Navigate to: Dashboards → Import"
echo "  3. Upload file: grafana-agent-dashboard.json"
echo "  4. Select Prometheus datasource"
echo "  5. Click Import"
echo ""

echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║                          DEPLOYMENT COMPLETE                                  ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""
echo "Access Points:"
echo "  • Agent Exporter:  http://localhost:9200/metrics"
echo "  • Prometheus:      https://prometheus.simondatalab.de"
echo "  • Grafana:         https://grafana.simondatalab.de"
echo ""
echo "Next Steps:"
echo "  1. Import the dashboard into Grafana (see instructions above)"
echo "  2. Configure alerting rules in Prometheus (optional)"
echo "  3. Set up Grafana notifications (optional)"
echo ""
echo "Monitoring:"
echo "  • Agent Exporter Status: systemctl --user status agent-exporter.service"
echo "  • Agent Exporter Logs:   journalctl --user -u agent-exporter.service -f"
echo "  • Prometheus Targets:     http://localhost:9090/targets"
echo ""
echo -e "${GREEN}All systems operational!${NC}"

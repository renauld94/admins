#!/bin/bash
# Deploy Legal Monitoring Agent to VM159
# Run this script on VM159 to set up the continuous legal monitoring service

set -e

echo "====== LEGAL MONITORING AGENT DEPLOYMENT ======"
echo "Target: VM159"
echo "Case: Digital Unicorn Services - Unauthorized Image Use"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Paths
WORKSPACE="/home/simon/Learning-Management-System-Academy"
AGENT_DIR="${WORKSPACE}/.continue/agents"
SYSTEMD_DIR="${WORKSPACE}/.continue/systemd"
LEGAL_DIR="${WORKSPACE}/legal-matters/digital-unicorn-icon-plc"
MONITORING_DIR="${LEGAL_DIR}/legal_agent_monitoring"

echo -e "${BLUE}Step 1: Installing dependencies${NC}"
pip3 install --upgrade playwright 2>&1 | tail -5
python3 -m playwright install chromium 2>&1 | tail -3
echo -e "${GREEN}✅ Dependencies installed${NC}\n"

echo -e "${BLUE}Step 2: Creating monitoring directories${NC}"
mkdir -p "${MONITORING_DIR}/{captures,reports,logs}"
chmod 750 "${MONITORING_DIR}"
echo -e "${GREEN}✅ Directories created: ${MONITORING_DIR}${NC}\n"

echo -e "${BLUE}Step 3: Verifying Legal Agent script${NC}"
if [ -f "${AGENT_DIR}/legal_monitoring_agent.py" ]; then
    echo -e "${GREEN}✅ Legal Agent found${NC}"
    chmod +x "${AGENT_DIR}/legal_monitoring_agent.py"
else
    echo -e "${RED}❌ Legal Agent not found at ${AGENT_DIR}/legal_monitoring_agent.py${NC}"
    exit 1
fi
echo ""

echo -e "${BLUE}Step 4: Installing systemd service${NC}"
SYSTEMD_SRC="${SYSTEMD_DIR}/legal-monitoring.service"
SYSTEMD_DST="/etc/systemd/system/legal-monitoring.service"

if [ -f "${SYSTEMD_SRC}" ]; then
    echo "Source: ${SYSTEMD_SRC}"
    echo "Destination: ${SYSTEMD_DST}"
    
    # Copy to systemd
    sudo cp "${SYSTEMD_SRC}" "${SYSTEMD_DST}"
    sudo chmod 644 "${SYSTEMD_DST}"
    
    # Reload systemd
    sudo systemctl daemon-reload
    echo -e "${GREEN}✅ Systemd service installed${NC}\n"
else
    echo -e "${RED}❌ Systemd file not found${NC}"
    exit 1
fi

echo -e "${BLUE}Step 5: Starting Legal Monitoring Service${NC}"
sudo systemctl start legal-monitoring.service

# Wait for service to start
sleep 3

# Check status
if sudo systemctl is-active --quiet legal-monitoring.service; then
    echo -e "${GREEN}✅ Service started successfully${NC}"
else
    echo -e "${RED}❌ Service failed to start${NC}"
    echo "View errors with: sudo journalctl -u legal-monitoring.service -n 50"
    exit 1
fi
echo ""

echo -e "${BLUE}Step 6: Enabling service to start on boot${NC}"
sudo systemctl enable legal-monitoring.service
echo -e "${GREEN}✅ Service enabled for auto-start on reboot${NC}\n"

echo -e "${BLUE}Step 7: Checking initial monitoring output${NC}"
echo "Waiting 10 seconds for first capture and report..."
sleep 10

if [ -f "${MONITORING_DIR}/monitoring_index.json" ]; then
    CAPTURES=$(grep -c '"timestamp"' "${MONITORING_DIR}/monitoring_index.json" || echo "0")
    echo -e "${GREEN}✅ Initial capture complete${NC}"
    echo "   Captures: $CAPTURES"
fi

if [ -n "$(ls -A ${MONITORING_DIR}/reports/ 2>/dev/null)" ]; then
    REPORT_COUNT=$(ls -1 ${MONITORING_DIR}/reports/ | wc -l)
    LATEST_REPORT=$(ls -1t ${MONITORING_DIR}/reports/ | head -1)
    echo -e "${GREEN}✅ Initial legal report generated${NC}"
    echo "   Report file: ${LATEST_REPORT}"
fi
echo ""

echo -e "${BLUE}Step 8: Service commands for future reference${NC}"
cat << EOF
${GREEN}=== LEGAL MONITORING SERVICE - Quick Reference ===${NC}

Check service status:
  sudo systemctl status legal-monitoring.service

View live logs:
  sudo journalctl -u legal-monitoring.service -f

View service errors:
  sudo journalctl -u legal-monitoring.service -n 100

Stop the service (if needed):
  sudo systemctl stop legal-monitoring.service

Restart the service:
  sudo systemctl restart legal-monitoring.service

View captured evidence:
  ls -lh ${MONITORING_DIR}/captures/

View legal reports:
  ls -lh ${MONITORING_DIR}/reports/
  cat ${MONITORING_DIR}/reports/LEGAL_REPORT_*.md

View monitoring index:
  cat ${MONITORING_DIR}/monitoring_index.json

View system logs:
  cat ${MONITORING_DIR}/logs/legal_agent_*.log

${YELLOW}Important: Monitoring will continue automatically every 6 hours.${NC}
${YELLOW}Daily legal reports are auto-generated and saved as evidence.${NC}

${GREEN}====== DEPLOYMENT COMPLETE ======${NC}
EOF

echo ""
echo -e "${GREEN}🚀 Legal Monitoring Agent is now running on VM159!${NC}"
echo -e "${YELLOW}⚠️  Evidence is being continuously captured and reports generated.${NC}"
echo ""

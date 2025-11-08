#!/bin/bash
# Quick Deploy Legal Monitoring Agent to VM159
# Usage: bash deploy_legal_agent_quick.sh

set -e

echo "🚀 LEGAL MONITORING AGENT - EXPRESS DEPLOYMENT"
echo "==============================================="
echo ""

WORKSPACE="/home/simon/Learning-Management-System-Academy"

# Check if running on VM159 or can SSH there
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 not found. Are you on VM159?"
    exit 1
fi

echo "📦 Installing Playwright..."
pip3 install --quiet playwright 2>/dev/null || pip install --quiet playwright
python3 -m playwright install chromium --with-deps 2>/dev/null || true

echo "📁 Creating monitoring directory structure..."
mkdir -p "${WORKSPACE}/legal-matters/digital-unicorn-icon-plc/legal_agent_monitoring"/{captures,reports,logs}

echo "⚙️  Setting up systemd service..."
sudo cp "${WORKSPACE}/.continue/systemd/legal-monitoring.service" /etc/systemd/system/
sudo chmod 644 /etc/systemd/system/legal-monitoring.service
sudo systemctl daemon-reload

echo "🎯 Starting service..."
sudo systemctl start legal-monitoring.service
sudo systemctl enable legal-monitoring.service

echo "⏳ Waiting for first capture (10 seconds)..."
sleep 10

echo ""
echo "✅ DEPLOYMENT COMPLETE!"
echo ""
echo "Service Status:"
sudo systemctl status legal-monitoring.service --no-pager

echo ""
echo "📊 View evidence:"
echo "  Captures: ls -lh ${WORKSPACE}/legal-matters/digital-unicorn-icon-plc/legal_agent_monitoring/captures/"
echo "  Reports:  ls -lh ${WORKSPACE}/legal-matters/digital-unicorn-icon-plc/legal_agent_monitoring/reports/"
echo "  Logs:     tail -f ${WORKSPACE}/legal-matters/digital-unicorn-icon-plc/legal_agent_monitoring/logs/legal_agent_*.log"
echo ""
echo "📋 Stop/start service:"
echo "  sudo systemctl stop legal-monitoring.service"
echo "  sudo systemctl start legal-monitoring.service"
echo ""

#!/bin/bash
# Setup script for Infrastructure Monitoring Agent
# NO EMOJIS - Professional deployment script

set -e

echo "[INFO] Setting up Infrastructure Monitoring Agent..."

# Configuration
WORKSPACE="/home/simon/Learning-Management-System-Academy"
AGENT_DIR="$WORKSPACE/.continue/agents"
SERVICE_FILE="$AGENT_DIR/infrastructure-monitor.service"
SYSTEMD_DIR="/etc/systemd/system"
OUTPUT_DIR="$AGENT_DIR/reports"
LOG_DIR="$AGENT_DIR/logs"

# Create directories
echo "[INFO] Creating directories..."
mkdir -p "$OUTPUT_DIR"
mkdir -p "$LOG_DIR"
chmod 755 "$OUTPUT_DIR"
chmod 755 "$LOG_DIR"

# Make agent executable
echo "[INFO] Setting permissions..."
chmod +x "$AGENT_DIR/infrastructure_monitor_agent.py"

# Copy systemd service file
echo "[INFO] Installing systemd service..."
sudo cp "$SERVICE_FILE" "$SYSTEMD_DIR/infrastructure-monitor.service"
sudo chmod 644 "$SYSTEMD_DIR/infrastructure-monitor.service"

# Reload systemd
echo "[INFO] Reloading systemd..."
sudo systemctl daemon-reload

# Enable service
echo "[INFO] Enabling service..."
sudo systemctl enable infrastructure-monitor.service

# Start service
echo "[INFO] Starting service..."
sudo systemctl start infrastructure-monitor.service

# Check status
echo "[INFO] Checking service status..."
sleep 2
sudo systemctl status infrastructure-monitor.service --no-pager || true

# Show logs
echo ""
echo "[INFO] Recent logs:"
sudo journalctl -u infrastructure-monitor.service -n 20 --no-pager

echo ""
echo "[SUCCESS] Infrastructure Monitoring Agent installed and running"
echo "[INFO] View logs: sudo journalctl -u infrastructure-monitor.service -f"
echo "[INFO] Check status: sudo systemctl status infrastructure-monitor.service"
echo "[INFO] Output location: $OUTPUT_DIR/infrastructure_data.json"
echo ""
echo "[SECURITY] If sensitive data is detected, authentication will be enforced"
echo "[SECURITY] Default credentials: admin / DataLab2025!"
echo "[SECURITY] CHANGE PASSWORD IMMEDIATELY!"

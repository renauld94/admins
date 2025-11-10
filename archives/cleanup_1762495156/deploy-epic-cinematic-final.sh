#!/bin/bash
# Epic Cinematic Agent - Complete VM 159 Setup & Deployment
# Includes HTTP server for serving the generated visualization

set -e

echo "=========================================="
echo "EPIC CINEMATIC - FINAL VM 159 DEPLOYMENT"
echo "=========================================="
echo "Target: VM 159 (ubuntuai-1000110)"
echo "IP: 10.0.0.110"
echo "Date: $(date)"
echo "=========================================="

# SSH Configuration
PROXMOX_HOST="136.243.155.166:2222"
PROXMOX_USER="root"
VM_IP="10.0.0.110"
VM_USER="simonadmin"
SSH_CMD="ssh -J ${PROXMOX_USER}@${PROXMOX_HOST} ${VM_USER}@${VM_IP}"

echo ""
echo "[1] Stopping previous Epic Cinematic service..."
timeout 10 $SSH_CMD "sudo systemctl stop epic-cinematic.service 2>/dev/null || true" || true

echo "[2] Disabling old service..."
timeout 10 $SSH_CMD "sudo systemctl disable epic-cinematic.service 2>/dev/null || true" || true

echo "[3] Creating HTTP server systemd service..."
timeout 30 $SSH_CMD "cat > /tmp/epic-cinematic-http.service << 'EOF'
[Unit]
Description=Epic Cinematic Animation HTTP Server
Documentation=https://www.simondatalab.de
After=network.target

[Service]
Type=simple
User=simonadmin
Group=simonadmin
WorkingDirectory=/home/simonadmin/epic-cinematic-output
Environment=\"PYTHONUNBUFFERED=1\"
ExecStart=/usr/bin/python3 -m http.server 8000 --bind 0.0.0.0
Restart=on-failure
RestartSec=10s
StartLimitBurst=5
StartLimitInterval=60s
StandardOutput=journal
StandardError=journal
SyslogIdentifier=epic-cinema-http

[Install]
WantedBy=multi-user.target
EOF
sudo cp /tmp/epic-cinematic-http.service /etc/systemd/system/
sudo systemctl daemon-reload" || echo "Warning: Could not create HTTP service"

echo "[4] Regenerating Epic Cinematic files on VM 159..."
timeout 30 $SSH_CMD "cd /home/simonadmin/epic-cinematic-agent && timeout 10 python3 epic_cinematic_agent.py 2>&1 | tail -20 || true" || true

echo "[5] Verifying generated files..."
timeout 10 $SSH_CMD "ls -lh /home/simonadmin/epic-cinematic-output/"

echo "[6] Starting HTTP server..."
timeout 10 $SSH_CMD "sudo systemctl start epic-cinematic-http.service" || echo "Note: Service may take a moment to start"

echo "[7] Checking HTTP server status..."
sleep 2
timeout 10 $SSH_CMD "sudo systemctl is-active epic-cinematic-http.service" || echo "Starting..."

echo "[8] Verifying HTTP server is accessible..."
timeout 10 $SSH_CMD "curl -s http://localhost:8000 | head -5 || echo 'Server warming up...'"

echo ""
echo "=========================================="
echo "DEPLOYMENT COMPLETE"
echo "=========================================="
echo ""
echo "Access the animation:"
echo "  Direct (VM 159): http://10.0.0.110:8000"
echo "  Via SSH Tunnel:"
echo "    ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.110 -L 8000:localhost:8000"
echo "    Then open: http://localhost:8000"
echo ""
echo "Service Management:"
echo "  Status: sudo systemctl status epic-cinematic-http.service"
echo "  Logs:   sudo journalctl -u epic-cinematic-http.service -f"
echo "  Stop:   sudo systemctl stop epic-cinematic-http.service"
echo "  Start:  sudo systemctl start epic-cinematic-http.service"
echo ""
echo "Regenerate Files:"
echo "  ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.110"
echo "  cd /home/simonadmin/epic-cinematic-agent"
echo "  python3 epic_cinematic_agent.py"
echo ""
echo "Files Location:"
echo "  Animation: /home/simonadmin/epic-cinematic-output/"
echo "  Agent:     /home/simonadmin/epic-cinematic-agent/"
echo "  Logs:      /tmp/epic_cinematic_vm159.log"
echo ""

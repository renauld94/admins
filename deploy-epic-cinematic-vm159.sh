#!/bin/bash
# Deploy Epic Cinematic Agent to VM 159 (ubuntuai-1000110)
# Proxmox Node: pve
# IP: 10.0.0.110

set -e

echo "=========================================="
echo "EPIC CINEMATIC AGENT - VM 159 DEPLOYMENT"
echo "=========================================="
echo "Target: VM 159 (ubuntuai-1000110) on node pve"
echo "IP: 10.0.0.110"
echo "Date: $(date)"
echo "=========================================="

# SSH Configuration
PROXMOX_HOST="136.243.155.166:2222"
PROXMOX_USER="root"
VM_IP="10.0.0.110"
VM_USER="simonadmin"
SSH_CMD="ssh -J ${PROXMOX_USER}@${PROXMOX_HOST} ${VM_USER}@${VM_IP}"

# Directories
LOCAL_SOURCE="/home/simon/Learning-Management-System-Academy/.continue/agents/epic_cinematic_agent_vm159.py"
VM_HOME="/home/simonadmin"
VM_APP_DIR="/home/simonadmin/epic-cinematic-agent"
VM_OUTPUT_DIR="/home/simonadmin/epic-cinematic-output"

echo ""
echo "[1] Verifying SSH connection to VM 159..."
$SSH_CMD "echo 'SSH connection successful'" || { echo "SSH failed"; exit 1; }

echo "[2] Creating directories on VM 159..."
$SSH_CMD "mkdir -p $VM_APP_DIR $VM_OUTPUT_DIR"

echo "[3] Uploading Epic Cinematic Agent script..."
scp -J ${PROXMOX_USER}@${PROXMOX_HOST} \
    "$LOCAL_SOURCE" \
    "${VM_USER}@${VM_IP}:${VM_APP_DIR}/epic_cinematic_agent.py"

echo "[4] Creating deployment wrapper script on VM 159..."
$SSH_CMD "cat > ${VM_APP_DIR}/deploy.sh << 'EOF'
#!/bin/bash
set -e

echo '=========================================='
echo 'EPIC CINEMATIC AGENT - STARTING ON VM 159'
echo '=========================================='
echo \"Timestamp: \$(date)\"
echo \"Hostname: \$(hostname)\"
echo \"IP: \$(hostname -I)\"
echo \"Python: \$(python3 --version)\"
echo \"Ollama: \$(curl -s http://localhost:11434/api/tags | jq '.models | length' || echo 'checking...')\"
echo '=========================================='
echo ''

# Export workspace path
export WORKSPACE_PATH=\"/home/simonadmin\"
export OUTPUT_DIR=\"${VM_OUTPUT_DIR}\"

# Run the agent
cd ${VM_APP_DIR}
python3 epic_cinematic_agent.py

echo ''
echo 'Agent completed!'
EOF
chmod +x ${VM_APP_DIR}/deploy.sh"

echo "[5] Creating systemd service for VM 159..."
$SSH_CMD "cat > /tmp/epic-cinematic.service << 'EOF'
[Unit]
Description=Epic Cinematic Animation Agent - VM 159
Documentation=https://www.simondatalab.de
After=network.target ollama.service
Wants=ollama.service

[Service]
Type=simple
User=simonadmin
Group=simonadmin
WorkingDirectory=/home/simonadmin/epic-cinematic-agent
Environment=\"PYTHONUNBUFFERED=1\"
Environment=\"WORKSPACE_PATH=/home/simonadmin\"
Environment=\"OUTPUT_DIR=/home/simonadmin/epic-cinematic-output\"
ExecStart=/home/simonadmin/epic-cinematic-agent/deploy.sh
Restart=on-failure
RestartSec=30s
StartLimitBurst=5
StartLimitInterval=300s
StandardOutput=journal
StandardError=journal
SyslogIdentifier=epic-cinematic

[Install]
WantedBy=multi-user.target
EOF
sudo cp /tmp/epic-cinematic.service /etc/systemd/system/epic-cinematic.service
sudo systemctl daemon-reload"

echo "[6] Checking Ollama on VM 159..."
OLLAMA_STATUS=$($SSH_CMD "curl -s http://localhost:11434/api/tags | jq -r '.models[0].name // \"none\"'" || echo "error")
echo "   Ollama Status: $OLLAMA_STATUS"

echo "[7] Creating Three.js visualization files..."
$SSH_CMD "cat > ${VM_OUTPUT_DIR}/index.html << 'EOF'
<!DOCTYPE html>
<html lang=\"en\">
<head>
    <meta charset=\"UTF-8\">
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
    <title>Neural to Cosmos - Simon Data Lab</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { overflow: hidden; background: #000000; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; }
        #canvas-container { position: fixed; top: 0; left: 0; width: 100vw; height: 100vh; z-index: 1; }
        #loading { position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); color: #00d4ff; font-size: 24px; z-index: 1000; }
        #info { position: fixed; bottom: 20px; left: 20px; color: #00d4ff; font-size: 12px; z-index: 999; }
        .dot { display: inline-block; width: 12px; height: 12px; background: #00d4ff; border-radius: 50%; margin: 0 4px; animation: pulse 1.5s infinite; }
        @keyframes pulse { 0%, 100% { opacity: 0.3; } 50% { opacity: 1; } }
    </style>
</head>
<body>
    <div id=\"loading\">
        <span class=\"dot\"></span>
        <span class=\"dot\" style=\"animation-delay: 0.2s\"></span>
        <span class=\"dot\" style=\"animation-delay: 0.4s\"></span>
        <p>Rendering Neural to Cosmic...</p>
    </div>
    <div id=\"canvas-container\"></div>
    <div id=\"info\">VM 159 - Epic Cinematic Animation Server</div>
    <script type=\"importmap\">
    {
        \"imports\": {
            \"three\": \"https://cdn.jsdelivr.net/npm/three@0.160.0/build/three.module.js\",
            \"three/addons/\": \"https://cdn.jsdelivr.net/npm/three@0.160.0/examples/jsm/\"
        }
    }
    </script>
    <script type=\"module\" src=\"./main.js\"></script>
</body>
</html>
EOF"

echo "[8] Starting Epic Cinematic Agent on VM 159..."
$SSH_CMD "sudo systemctl start epic-cinematic.service"

echo ""
echo "[9] Checking service status..."
sleep 2
SERVICE_STATUS=$($SSH_CMD "sudo systemctl is-active epic-cinematic.service" || echo "error")
echo "   Service Status: $SERVICE_STATUS"

echo ""
echo "[10] Agent logs..."
$SSH_CMD "sudo journalctl -u epic-cinematic.service -n 10 --no-pager || echo 'No logs yet'"

echo ""
echo "=========================================="
echo "DEPLOYMENT COMPLETE"
echo "=========================================="
echo ""
echo "Access the animation:"
echo "  Local (VM 159): http://10.0.0.110:8080"
echo "  Via SSH Tunnel: ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.110 -L 8080:localhost:8080"
echo "  Production: https://www.simondatalab.de/hero-visualization/"
echo ""
echo "Check logs:"
echo "  ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.110"
echo "  sudo journalctl -u epic-cinematic.service -f"
echo ""
echo "Start/Stop service:"
echo "  Start: sudo systemctl start epic-cinematic.service"
echo "  Stop: sudo systemctl stop epic-cinematic.service"
echo "  Status: sudo systemctl status epic-cinematic.service"
echo ""

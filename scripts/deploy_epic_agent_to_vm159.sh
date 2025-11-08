#!/bin/bash
# Deploy Epic Course Enhancement Agent to VM159
# Usage: ./deploy_epic_agent_to_vm159.sh [vm_user@vm_host_alias]

set -euo pipefail
TARGET=${1:-ai-services-vm159}
REMOTE_DIR="/home/simonadmin/vm159-agents/epic_course_enhancement"
LOCAL_DIR="$(pwd)"

echo "Deploying to $TARGET -> $REMOTE_DIR"

# Create remote directory
ssh $TARGET "mkdir -p $REMOTE_DIR"

# Copy required files
scp -r "$LOCAL_DIR/epic_course_enhancement_agent.py" "$LOCAL_DIR/epic_course_requirements.txt" "$LOCAL_DIR/enhanced_course_output" $TARGET:$REMOTE_DIR

# Install dependencies and start agent (run interactively or as service)
ssh $TARGET bash -lc "
cd $REMOTE_DIR
python3 -m venv .venv || true
. .venv/bin/activate
pip install --upgrade pip
pip install -r epic_course_requirements.txt
# Create logs dir
mkdir -p /tmp/epic_course_logs
# Install systemd service for robust long-running execution
echo 'Installing systemd service for epic_course_enhancement...'
cat > epic_course.service <<'SERVICE'
[Unit]
Description=EPIC Course Enhancement Agent
After=network.target

[Service]
Type=simple
User=simonadmin
WorkingDirectory=$REMOTE_DIR
Environment=PATH=$REMOTE_DIR/.venv/bin
ExecStart=$REMOTE_DIR/.venv/bin/python $REMOTE_DIR/epic_course_enhancement_agent.py
Restart=on-failure
RestartSec=10
StandardOutput=file:/var/log/epic_course_enhancement.log
StandardError=file:/var/log/epic_course_enhancement.err

[Install]
WantedBy=multi-user.target
SERVICE

sudo mv epic_course.service /etc/systemd/system/epic_course.service || { echo 'Failed to move service file with sudo'; exit 1; }
sudo systemctl daemon-reload
sudo systemctl enable --now epic_course.service
sudo systemctl status epic_course.service --no-pager || true
echo 'Service installed and started. Check sudo journalctl -u epic_course.service or /var/log/epic_course_enhancement.log for logs.'
"

echo "Deployment complete."

#!/bin/bash
# Deploy FastAPI backend as systemd service for EPIC Geodashboard
# Usage: sudo bash scripts/deploy_backend_systemd.sh

set -e

echo "🚀 Deploying EPIC Geodashboard Backend as Systemd Service"

if [ "$EUID" -ne 0 ]; then
    echo "❌ This script requires root (sudo)"
    exit 1
fi

# Configuration
BACKEND_USER="geodashboard"
BACKEND_GROUP="geodashboard"
DEPLOY_DIR="/opt/geodashboard"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ════════════════════════════════════════════════════════════════════════════
# Create user and group
# ════════════════════════════════════════════════════════════════════════════

echo "👤 Setting up user and group..."

if ! id "$BACKEND_USER" &>/dev/null; then
    useradd --system --no-create-home --shell /bin/false "$BACKEND_USER"
    echo "   Created user: $BACKEND_USER"
else
    echo "   User $BACKEND_USER already exists"
fi

# ════════════════════════════════════════════════════════════════════════════
# Copy application files
# ════════════════════════════════════════════════════════════════════════════

echo "📦 Deploying backend to $DEPLOY_DIR..."

mkdir -p "$DEPLOY_DIR"
cp "$REPO_ROOT/geospatial_data_agent.py" "$DEPLOY_DIR/"
cp "$REPO_ROOT/requirements-phase4.txt" "$DEPLOY_DIR/"

# ════════════════════════════════════════════════════════════════════════════
# Create Python virtual environment
# ════════════════════════════════════════════════════════════════════════════

echo "🐍 Creating Python virtual environment..."

if [ ! -d "$DEPLOY_DIR/.venv" ]; then
    cd "$DEPLOY_DIR"
    python3 -m venv .venv
    .venv/bin/pip install --upgrade pip setuptools wheel
    .venv/bin/pip install -r requirements-phase4.txt
    echo "   ✅ Virtual environment created and dependencies installed"
else
    echo "   Virtual environment already exists"
fi

# Set ownership
chown -R "$BACKEND_USER:$BACKEND_GROUP" "$DEPLOY_DIR"

# ════════════════════════════════════════════════════════════════════════════
# Create systemd service file
# ════════════════════════════════════════════════════════════════════════════

echo "🔧 Creating systemd service..."

cat > /etc/systemd/system/geospatial-data-agent.service <<'EOF'
[Unit]
Description=EPIC Geodashboard Backend (FastAPI)
Documentation=https://github.com/renauld94/admins#epic-geodashboard
After=network.target
Wants=geospatial-data-agent.socket

[Service]
Type=notify
User=geodashboard
Group=geodashboard
WorkingDirectory=/opt/geodashboard
Environment="PATH=/opt/geodashboard/.venv/bin"
EnvironmentFile=/etc/default/geospatial-data-agent

# Python uvicorn command
ExecStart=/opt/geodashboard/.venv/bin/uvicorn \
    geospatial_data_agent:app \
    --host 0.0.0.0 \
    --port 8000 \
    --log-level info \
    --workers 4

# Restart policy
Restart=always
RestartSec=10s

# Timeouts
TimeoutStartSec=30s
TimeoutStopSec=10s

# Security hardening
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=yes
ReadWritePaths=/var/log/geospatial-data-agent

# Resource limits
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOF

# ════════════════════════════════════════════════════════════════════════════
# Create environment file
# ════════════════════════════════════════════════════════════════════════════

echo "📝 Creating environment configuration..."

if [ ! -f /etc/default/geospatial-data-agent ]; then
    cat > /etc/default/geospatial-data-agent <<'EOF'
# EPIC Geodashboard Backend Environment Variables
# Edit this file to configure the backend

# USGS Earthquake Feed Configuration
EARTHQUAKE_MIN_MAG=4.0
USGS_POLL_INTERVAL=60

# AI Model Integration (optional)
# OLLAMA_URL=http://127.0.0.1:11434
# OLLAMA_MODEL=qwen2.5:7b
# ANALYSIS_ENABLED=false
# MODEL_RETRIES=2
# MODEL_TIMEOUT=15.0

# CORS Configuration
# Comma-separated list of allowed origins (default: *)
# CORS_ORIGINS="https://geodashboard.example.com,https://app.example.com"

# Logging
# Options: critical, error, warning, info, debug
# LOG_LEVEL=info
EOF
    chmod 600 /etc/default/geospatial-data-agent
    echo "   ✅ Created /etc/default/geospatial-data-agent"
else
    echo "   Environment file already exists"
fi

# ════════════════════════════════════════════════════════════════════════════
# Create logging directory
# ════════════════════════════════════════════════════════════════════════════

echo "📋 Setting up logging..."

mkdir -p /var/log/geospatial-data-agent
chown "$BACKEND_USER:$BACKEND_GROUP" /var/log/geospatial-data-agent
chmod 755 /var/log/geospatial-data-agent

# Create logrotate config
cat > /etc/logrotate.d/geospatial-data-agent <<EOF
/var/log/geospatial-data-agent/*.log {
    daily
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 $BACKEND_USER $BACKEND_GROUP
    sharedscripts
    postrotate
        systemctl reload geospatial-data-agent > /dev/null 2>&1 || true
    endscript
}
EOF

# ════════════════════════════════════════════════════════════════════════════
# Create systemd socket (optional, for socket activation)
# ════════════════════════════════════════════════════════════════════════════

cat > /etc/systemd/system/geospatial-data-agent.socket <<'EOF'
[Unit]
Description=EPIC Geodashboard Backend Socket

[Socket]
ListenStream=8000
Accept=no

[Install]
WantedBy=sockets.target
EOF

# ════════════════════════════════════════════════════════════════════════════
# Enable and start services
# ════════════════════════════════════════════════════════════════════════════

echo "🔄 Reloading systemd and starting service..."

systemctl daemon-reload
systemctl enable geospatial-data-agent

if systemctl is-active --quiet geospatial-data-agent; then
    echo "🔄 Restarting existing service..."
    systemctl restart geospatial-data-agent
else
    echo "🚀 Starting service..."
    systemctl start geospatial-data-agent
fi

# Verify service is running
sleep 2
echo ""
if systemctl is-active --quiet geospatial-data-agent; then
    echo "✅ Service is running!"
else
    echo "❌ Service failed to start. Check logs:"
    journalctl -u geospatial-data-agent -n 20
    exit 1
fi

# ════════════════════════════════════════════════════════════════════════════
# Print deployment summary
# ════════════════════════════════════════════════════════════════════════════

echo ""
echo "════════════════════════════════════════════════════════════════════════"
echo "✅ Backend Deployment Complete!"
echo "════════════════════════════════════════════════════════════════════════"
echo ""
echo "📊 Service Information:"
echo "  - Service:     geospatial-data-agent"
echo "  - Deploy Dir:  $DEPLOY_DIR"
echo "  - Config:      /etc/default/geospatial-data-agent"
echo "  - Logs:        /var/log/geospatial-data-agent/"
echo ""
echo "🚀 Common Commands:"
echo "  - Start:       sudo systemctl start geospatial-data-agent"
echo "  - Stop:        sudo systemctl stop geospatial-data-agent"
echo "  - Status:      sudo systemctl status geospatial-data-agent"
echo "  - Logs:        sudo journalctl -u geospatial-data-agent -f"
echo "  - Restart:     sudo systemctl restart geospatial-data-agent"
echo ""
echo "🔍 Verify Backend:"
echo "  - Health:      curl http://localhost:8000/health"
echo "  - Metrics:     curl http://localhost:8000/metrics"
echo "  - Earthquakes: curl http://localhost:8000/earthquakes"
echo ""
echo "📝 To configure:"
echo "  - Edit: sudo nano /etc/default/geospatial-data-agent"
echo "  - Reload: sudo systemctl daemon-reload"
echo "  - Restart: sudo systemctl restart geospatial-data-agent"
echo ""

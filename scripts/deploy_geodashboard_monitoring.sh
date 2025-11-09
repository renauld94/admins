#!/bin/bash
# Deploy Prometheus + Grafana for EPIC Geodashboard monitoring
# Usage: bash scripts/deploy_geodashboard_monitoring.sh [production|development]

set -e

MODE="${1:-development}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEPLOY_DIR="/opt/geodashboard-monitoring"
PROM_DIR="/etc/prometheus"

echo "🚀 Deploying EPIC Geodashboard Monitoring ($MODE mode)"

# ════════════════════════════════════════════════════════════════════════════
# Development Mode (Docker Compose)
# ════════════════════════════════════════════════════════════════════════════

if [ "$MODE" = "development" ]; then
    echo "📦 Starting Prometheus + Grafana via Docker Compose..."
    
    if ! command -v docker-compose &> /dev/null; then
        echo "❌ docker-compose not found. Install Docker Desktop or docker-compose."
        exit 1
    fi
    
    cd "$REPO_ROOT/deploy/prometheus"
    
    # Create provisioning directories
    mkdir -p grafana/provisioning/{dashboards,datasources}
    
    # Start services
    docker-compose -f docker-compose.monitoring.yml up -d
    
    echo "✅ Monitoring stack started!"
    echo ""
    echo "📊 Access:"
    echo "  - Prometheus:   http://localhost:9090"
    echo "  - Grafana:      http://localhost:3000 (admin/admin)"
    echo "  - Alertmanager: http://localhost:9093"
    echo ""
    echo "🔍 Verify Prometheus is scraping:"
    echo "  curl http://localhost:9090/api/v1/targets"
    echo ""
    exit 0
fi

# ════════════════════════════════════════════════════════════════════════════
# Production Mode (Systemd Services)
# ════════════════════════════════════════════════════════════════════════════

if [ "$MODE" != "production" ]; then
    echo "❌ Unknown mode: $MODE. Use 'development' or 'production'."
    exit 1
fi

echo "🏗️  Installing Prometheus + Grafana as systemd services..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Production deployment requires root. Run: sudo bash $0 production"
    exit 1
fi

# Create deployment directory
mkdir -p "$DEPLOY_DIR"
cp -r "$REPO_ROOT/deploy/prometheus"/* "$DEPLOY_DIR/"

# ════════════════════════════════════════════════════════════════════════════
# Install Prometheus
# ════════════════════════════════════════════════════════════════════════════

PROM_VERSION="2.48.0"
PROM_USER="prometheus"
PROM_GROUP="prometheus"

echo "📥 Installing Prometheus $PROM_VERSION..."

# Create user/group if needed
if ! id "$PROM_USER" &>/dev/null; then
    useradd --system --no-create-home --shell /bin/false "$PROM_USER"
    echo "   Created user: $PROM_USER"
fi

# Download and install
cd /tmp
wget -q "https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz"
tar xzf "prometheus-${PROM_VERSION}.linux-amd64.tar.gz"

install -m 0755 "prometheus-${PROM_VERSION}.linux-amd64/prometheus" /usr/local/bin/
install -m 0755 "prometheus-${PROM_VERSION}.linux-amd64/promtool" /usr/local/bin/

# Setup Prometheus directories
mkdir -p "$PROM_DIR" /var/lib/prometheus
chown "$PROM_USER:$PROM_GROUP" "$PROM_DIR" /var/lib/prometheus

# Copy config files
cp "$DEPLOY_DIR/prometheus.yml" "$PROM_DIR/"
cp "$DEPLOY_DIR/geodashboard_alerts.yml" "$PROM_DIR/"
chown "$PROM_USER:$PROM_GROUP" "$PROM_DIR"/*.yml

echo "✅ Prometheus installed"

# ════════════════════════════════════════════════════════════════════════════
# Create Prometheus Systemd Service
# ════════════════════════════════════════════════════════════════════════════

cat > /etc/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus monitoring system
Documentation=https://prometheus.io/docs/
After=network.target

[Service]
Type=simple
User=$PROM_USER
Group=$PROM_GROUP
ExecStart=/usr/local/bin/prometheus \\
  --config.file=$PROM_DIR/prometheus.yml \\
  --storage.tsdb.path=/var/lib/prometheus \\
  --web.console.libraries=/usr/share/prometheus/console_libraries \\
  --web.console.templates=/usr/share/prometheus/consoles \\
  --web.enable-lifecycle
ExecReload=/bin/kill -HUP \$MAINPID
Restart=on-failure
RestartSec=10s

# Security hardening
NoNewPrivileges=true
ProtectSystem=strict
ProtectHome=yes
ReadWritePaths=/var/lib/prometheus

[Install]
WantedBy=multi-user.target
EOF

echo "✅ Prometheus systemd service created"

# ════════════════════════════════════════════════════════════════════════════
# Install Grafana
# ════════════════════════════════════════════════════════════════════════════

GRAFANA_VERSION="10.2.0"

echo "📥 Installing Grafana $GRAFANA_VERSION..."

# Install from repository (Debian/Ubuntu) or binary
if command -v apt-get &> /dev/null; then
    apt-get update
    apt-get install -y software-properties-common
    add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
    apt-get update
    apt-get install -y grafana
else
    echo "⚠️  Skipping Grafana package installation (not Debian/Ubuntu)."
    echo "    Install manually: https://grafana.com/grafana/download"
fi

echo "✅ Grafana installed"

# ════════════════════════════════════════════════════════════════════════════
# Create Alertmanager Systemd Service
# ════════════════════════════════════════════════════════════════════════════

ALERTMANAGER_VERSION="0.26.0"
ALERTMANAGER_USER="alertmanager"
ALERTMANAGER_GROUP="alertmanager"

echo "📥 Installing Alertmanager $ALERTMANAGER_VERSION..."

if ! id "$ALERTMANAGER_USER" &>/dev/null; then
    useradd --system --no-create-home --shell /bin/false "$ALERTMANAGER_USER"
fi

cd /tmp
wget -q "https://github.com/prometheus/alertmanager/releases/download/v${ALERTMANAGER_VERSION}/alertmanager-${ALERTMANAGER_VERSION}.linux-amd64.tar.gz"
tar xzf "alertmanager-${ALERTMANAGER_VERSION}.linux-amd64.tar.gz"

install -m 0755 "alertmanager-${ALERTMANAGER_VERSION}.linux-amd64/alertmanager" /usr/local/bin/
install -m 0755 "alertmanager-${ALERTMANAGER_VERSION}.linux-amd64/amtool" /usr/local/bin/

mkdir -p /etc/alertmanager /var/lib/alertmanager
chown "$ALERTMANAGER_USER:$ALERTMANAGER_GROUP" /etc/alertmanager /var/lib/alertmanager

cp "$DEPLOY_DIR/alertmanager.yml" /etc/alertmanager/
chown "$ALERTMANAGER_USER:$ALERTMANAGER_GROUP" /etc/alertmanager/alertmanager.yml

cat > /etc/systemd/system/alertmanager.service <<EOF
[Unit]
Description=Prometheus Alertmanager
Documentation=https://prometheus.io/docs/alerting/latest/overview/
After=network.target

[Service]
Type=simple
User=$ALERTMANAGER_USER
Group=$ALERTMANAGER_GROUP
ExecStart=/usr/local/bin/alertmanager \\
  --config.file=/etc/alertmanager/alertmanager.yml \\
  --storage.path=/var/lib/alertmanager \\
  --web.external-url=http://localhost:9093
Restart=on-failure
RestartSec=10s

[Install]
WantedBy=multi-user.target
EOF

echo "✅ Alertmanager installed and configured"

# ════════════════════════════════════════════════════════════════════════════
# Enable and Start Services
# ════════════════════════════════════════════════════════════════════════════

echo "🔧 Enabling systemd services..."
systemctl daemon-reload
systemctl enable prometheus alertmanager grafana-server

echo "🚀 Starting services..."
systemctl start prometheus alertmanager grafana-server

# Verify services are running
sleep 2
echo ""
echo "✅ Services started. Checking status..."
systemctl status prometheus --no-pager | head -5
systemctl status alertmanager --no-pager | head -5
systemctl status grafana-server --no-pager | head -5

echo ""
echo "════════════════════════════════════════════════════════════════════════"
echo "✅ EPIC Geodashboard Monitoring Deployed!"
echo "════════════════════════════════════════════════════════════════════════"
echo ""
echo "📊 Access:"
echo "  - Prometheus:   http://$(hostname -I | awk '{print $1}'):9090"
echo "  - Grafana:      http://$(hostname -I | awk '{print $1}'):3000 (admin/admin)"
echo "  - Alertmanager: http://$(hostname -I | awk '{print $1}'):9093"
echo ""
echo "📝 Configuration files:"
echo "  - Prometheus:   $PROM_DIR/prometheus.yml"
echo "  - Alerts:       $PROM_DIR/geodashboard_alerts.yml"
echo "  - Alertmanager: /etc/alertmanager/alertmanager.yml"
echo ""
echo "📖 Next steps:"
echo "  1. Configure alert email/Slack in /etc/alertmanager/alertmanager.yml"
echo "  2. Import Grafana dashboards"
echo "  3. Verify backend metrics at: http://localhost:8000/metrics"
echo ""

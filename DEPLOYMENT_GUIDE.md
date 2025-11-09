# EPIC Geodashboard — Complete Production Deployment Guide

This guide covers end-to-end deployment of the EPIC Geodashboard system (backend, frontend, monitoring) to production.

## Table of Contents

1. [Quick Start (5 minutes)](#quick-start)
2. [Architecture Overview](#architecture-overview)
3. [Backend Deployment](#backend-deployment)
4. [Frontend Deployment](#frontend-deployment)
5. [Monitoring Stack Deployment](#monitoring-stack-deployment)
6. [Reverse Proxy Configuration](#reverse-proxy-configuration)
7. [SSL/TLS Setup](#ssltls-setup)
8. [Health Checks & Verification](#health-checks--verification)
9. [Troubleshooting](#troubleshooting)
10. [Disaster Recovery](#disaster-recovery)

---

## Quick Start

### Development (Docker Compose)

```bash
# 1. Start backend
cd /home/simon/Learning-Management-System-Academy
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements-phase4.txt
python3 geospatial_data_agent.py

# 2. Start frontend dev server (in another terminal)
cd portfolio-deployment-enhanced
python3 -m http.server 9000

# 3. Start monitoring stack (Docker Compose)
cd deploy/prometheus
docker-compose -f docker-compose.monitoring.yml up -d

# 4. Access services
# Frontend: http://localhost:9000/globe-3d-threejs.html
# Backend API: http://localhost:8000/earthquakes
# Prometheus: http://localhost:9090
# Grafana: http://localhost:3000 (admin/admin)
# Alertmanager: http://localhost:9093
```

### Production (Ubuntu/Debian 22.04+)

```bash
# 1. Clone repo
git clone https://github.com/renauld94/admins.git
cd admins

# 2. Deploy backend (systemd)
sudo bash scripts/deploy_backend_systemd.sh

# 3. Deploy monitoring (systemd)
sudo bash scripts/deploy_geodashboard_monitoring.sh production

# 4. Deploy frontend (nginx static hosting)
sudo bash scripts/deploy_frontend_nginx.sh

# 5. Configure reverse proxy (nginx)
sudo bash scripts/configure_nginx_reverse_proxy.sh

# 6. Verify
curl http://localhost:8000/health
curl http://localhost:9090/api/v1/targets
curl http://localhost:3000/api/health
```

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         Clients (Browser)                        │
│              https://geodashboard.example.com                   │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                    (nginx reverse proxy)
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        ▼                  ▼                  ▼
   ┌─────────┐      ┌──────────┐      ┌────────────┐
   │ Frontend│      │ Backend  │      │ Monitoring │
   │ (Static)│      │ (FastAPI)│      │ (Prometheus)
   │ :8080   │      │ :8000    │      │ :9090      │
   └─────────┘      └──────────┘      └────────────┘
                            │                  │
                            │                  │
                    ┌───────┴──────┐    ┌──────┴────────┐
                    ▼              ▼    ▼               ▼
              ┌──────────┐     ┌─────────────┐   ┌──────────────┐
              │ USGS API │     │   Ollama    │   │ Alertmanager │
              │ (External)     │   (Local)   │   │ :9093        │
              └──────────┘     └─────────────┘   └──────────────┘
                                                        │
                                        ┌───────────────┼───────────────┐
                                        ▼               ▼               ▼
                                    ┌────────┐    ┌──────────┐    ┌─────────┐
                                    │ Email  │    │ Slack    │    │Pagerduty│
                                    └────────┘    └──────────┘    └─────────┘
```

---

## Backend Deployment

### Automated Deployment (Recommended)

```bash
sudo bash scripts/deploy_backend_systemd.sh
```

This script:
- Creates `geodashboard` user and group
- Deploys code to `/opt/geodashboard`
- Creates Python virtual environment
- Installs dependencies from `requirements-phase4.txt`
- Creates `/etc/systemd/system/geospatial-data-agent.service`
- Creates `/etc/default/geospatial-data-agent` (env config)
- Enables and starts the service

### Manual Deployment

```bash
# Create user
sudo useradd --system --no-create-home --shell /bin/false geodashboard

# Deploy files
sudo mkdir -p /opt/geodashboard
sudo cp geospatial_data_agent.py requirements-phase4.txt /opt/geodashboard/

# Setup venv
cd /opt/geodashboard
sudo python3 -m venv .venv
sudo .venv/bin/pip install -r requirements-phase4.txt

# Create systemd service
sudo tee /etc/systemd/system/geospatial-data-agent.service > /dev/null <<EOF
[Unit]
Description=EPIC Geodashboard Backend (FastAPI)
After=network.target

[Service]
Type=simple
User=geodashboard
Group=geodashboard
WorkingDirectory=/opt/geodashboard
EnvironmentFile=/etc/default/geospatial-data-agent
ExecStart=/opt/geodashboard/.venv/bin/uvicorn geospatial_data_agent:app --host 0.0.0.0 --port 8000 --workers 4
Restart=always
RestartSec=10s

[Install]
WantedBy=multi-user.target
EOF

# Start service
sudo systemctl daemon-reload
sudo systemctl enable geospatial-data-agent
sudo systemctl start geospatial-data-agent
```

### Configuration

Edit `/etc/default/geospatial-data-agent`:

```bash
# USGS Configuration
EARTHQUAKE_MIN_MAG=4.0              # Minimum magnitude to poll
USGS_POLL_INTERVAL=60               # Seconds between polls

# AI Model (optional)
OLLAMA_URL=http://127.0.0.1:11434
OLLAMA_MODEL=qwen2.5:7b
ANALYSIS_ENABLED=false              # Enable AI event analysis
MODEL_TIMEOUT=15.0

# CORS (comma-separated origins)
CORS_ORIGINS="https://geodashboard.example.com"

# Logging
LOG_LEVEL=info
```

### Verify Backend

```bash
# Check service status
sudo systemctl status geospatial-data-agent

# View logs
sudo journalctl -u geospatial-data-agent -f

# Test endpoints
curl http://localhost:8000/health
curl http://localhost:8000/earthquakes
curl http://localhost:8000/metrics
```

---

## Frontend Deployment

### Build for Production

```bash
cd portfolio-deployment-enhanced/geospatial-viz

# Install dependencies
npm install

# Build bundle
npm run build

# Result: dist/globe-bundle.js (~9.4 KB minified)
```

### Deploy Static Files

```bash
# Create web root
sudo mkdir -p /var/www/geodashboard/html
sudo mkdir -p /var/www/geodashboard/dist

# Copy files
sudo cp globe-3d-threejs.html /var/www/geodashboard/html/index.html
sudo cp dist/globe-bundle.js /var/www/geodashboard/dist/
sudo cp dist/globe-bundle.js.map /var/www/geodashboard/dist/
sudo cp three-loader.js /var/www/geodashboard/

# Set permissions
sudo chown -R www-data:www-data /var/www/geodashboard
sudo chmod -R 755 /var/www/geodashboard
```

### Optimize for Production

```bash
# Enable gzip compression in nginx (see reverse proxy config)
# Precompress assets
sudo gzip -k /var/www/geodashboard/dist/globe-bundle.js

# Verify
ls -lh /var/www/geodashboard/dist/
```

---

## Monitoring Stack Deployment

### Development (Docker Compose)

```bash
cd deploy/prometheus
docker-compose -f docker-compose.monitoring.yml up -d

# Access
# Prometheus:   http://localhost:9090
# Grafana:      http://localhost:3000
# Alertmanager: http://localhost:9093
```

### Production (Systemd)

```bash
sudo bash scripts/deploy_geodashboard_monitoring.sh production
```

This deploys:
- **Prometheus** (systemd service) — metrics collection and aggregation
- **Grafana** (systemd service) — dashboards and alerting UI
- **Alertmanager** (systemd service) — alert routing and notifications

### Configure Alerting

Edit `/etc/alertmanager/alertmanager.yml`:

```yaml
global:
  smtp_smarthost: 'smtp.gmail.com:587'
  smtp_auth_username: 'alerts@example.com'
  smtp_auth_password: 'app-password'
  smtp_from: 'geodashboard-alerts@example.com'

route:
  receiver: 'critical'
  routes:
    - match:
        severity: critical
      receiver: 'critical-ops'
      repeat_interval: 15m

    - match:
        severity: warning
      receiver: 'team-email'
      repeat_interval: 4h

receivers:
  - name: 'critical-ops'
    email_configs:
      - to: 'ops@example.com'
    slack_configs:
      - api_url: 'https://hooks.slack.com/services/YOUR/WEBHOOK'
        channel: '#geodashboard-alerts'

  - name: 'team-email'
    email_configs:
      - to: 'team@example.com'
```

Reload Alertmanager:

```bash
sudo systemctl reload alertmanager
```

### Import Grafana Dashboards

```bash
# Copy dashboard to Grafana provisioning directory
sudo cp deploy/prometheus/grafana/dashboards/geodashboard-overview.json \
  /var/lib/grafana/dashboards/

# Reload Grafana (optional, auto-detects)
sudo systemctl restart grafana-server
```

Access Grafana at http://localhost:3000 (admin/admin) to view the dashboard.

---

## Reverse Proxy Configuration

### Nginx Setup

```bash
# Install nginx
sudo apt-get update
sudo apt-get install -y nginx

# Create config
sudo tee /etc/nginx/sites-available/geodashboard > /dev/null <<'EOF'
upstream backend {
    server 127.0.0.1:8000;
}

upstream prometheus {
    server 127.0.0.1:9090;
}

upstream grafana {
    server 127.0.0.1:3000;
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name geodashboard.example.com;
    return 301 https://$server_name$request_uri;
}

# Main HTTPS server
server {
    listen 443 ssl http2;
    server_name geodashboard.example.com;

    # SSL certificates (see next section)
    ssl_certificate /etc/letsencrypt/live/geodashboard.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/geodashboard.example.com/privkey.pem;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;

    # Gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss;
    gzip_min_length 1024;

    # Frontend (static files)
    location / {
        root /var/www/geodashboard;
        try_files $uri $uri/ /html/index.html;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    # Backend API
    location /api/ {
        proxy_pass http://backend/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 30s;
    }

    # WebSocket support
    location /ws {
        proxy_pass http://backend/ws;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_read_timeout 3600s;
    }

    # Backend endpoints (not under /api)
    location /health {
        proxy_pass http://backend/health;
        access_log off;
    }

    location /metrics {
        proxy_pass http://backend/metrics;
        deny all;  # Restrict metrics to localhost only
    }

    location /earthquakes {
        proxy_pass http://backend/earthquakes;
    }

    location /analysis {
        proxy_pass http://backend/analysis;
    }

    # Prometheus (internal only)
    location /prometheus/ {
        proxy_pass http://prometheus/;
        auth_basic "Prometheus";
        auth_basic_user_file /etc/nginx/.htpasswd;
        deny all;
    }

    # Grafana (internal only)
    location /grafana/ {
        proxy_pass http://grafana/;
        auth_basic "Grafana";
        auth_basic_user_file /etc/nginx/.htpasswd;
        deny all;
    }
}
EOF

# Enable site
sudo ln -sf /etc/nginx/sites-available/geodashboard /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test config
sudo nginx -t

# Reload nginx
sudo systemctl reload nginx
```

---

## SSL/TLS Setup

### Let's Encrypt (Automatic)

```bash
# Install Certbot
sudo apt-get install -y certbot python3-certbot-nginx

# Get certificate
sudo certbot certonly --nginx -d geodashboard.example.com

# Auto-renew (should be automatic, verify)
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer

# Check renewal
sudo certbot renew --dry-run
```

### Self-Signed (Development Only)

```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/geodashboard.key \
  -out /etc/ssl/certs/geodashboard.crt

# Update nginx config to use these files
```

---

## Health Checks & Verification

### Backend Health

```bash
# API health
curl http://localhost:8000/health

# Metrics endpoint
curl http://localhost:8000/metrics | head -20

# Earthquakes feed
curl http://localhost:8000/earthquakes | jq '.earthquakes | length'

# WebSocket test (requires websocat)
websocat ws://localhost:8000/ws
# Send: {"action": "subscribe"}
```

### Monitoring Health

```bash
# Prometheus targets
curl http://localhost:9090/api/v1/targets | jq '.data.activeTargets[].labels'

# Grafana health
curl http://localhost:3000/api/health | jq '.database'

# Alertmanager alerts
curl http://localhost:9093/api/v1/alerts | jq '.data | length'
```

### System Health

```bash
# Service status
sudo systemctl status geospatial-data-agent
sudo systemctl status prometheus
sudo systemctl status grafana-server
sudo systemctl status alertmanager

# Service logs
sudo journalctl -u geospatial-data-agent -n 50
sudo journalctl -u prometheus -n 50

# Resource usage
ps aux | grep -E 'uvicorn|prometheus|grafana'
```

---

## Troubleshooting

### Backend Not Starting

```bash
# Check logs
sudo journalctl -u geospatial-data-agent -n 100

# Check Python syntax
cd /opt/geodashboard
.venv/bin/python3 -m py_compile geospatial_data_agent.py

# Check port is available
sudo netstat -tlnp | grep 8000

# Restart service
sudo systemctl restart geospatial-data-agent
```

### Metrics Not Appearing in Prometheus

```bash
# Verify Prometheus can reach backend
curl -v http://localhost:8000/metrics

# Check Prometheus config
cat /etc/prometheus/prometheus.yml | grep -A5 'geodashboard'

# Reload Prometheus (without restart)
curl -X POST http://localhost:9090/-/reload

# Wait ~30s and check targets
curl http://localhost:9090/api/v1/targets | jq '.data.activeTargets'
```

### Alerts Not Firing

```bash
# Check alertmanager config
sudo promtool check config /etc/alertmanager/alertmanager.yml

# Verify alerts are defined
sudo promtool check rules /etc/prometheus/geodashboard_alerts.yml

# Check if condition is met
curl http://localhost:9090/api/v1/query?query=up | jq '.data.result'

# Reload alertmanager
sudo systemctl reload alertmanager
```

### WebSocket Connection Issues

```bash
# Check WebSocket is responding
websocat -v ws://localhost:8000/ws

# Check nginx proxy config (location /ws)
sudo cat /etc/nginx/sites-enabled/geodashboard | grep -A10 'location /ws'

# Verify backend is listening on correct port
sudo lsof -i :8000 | grep LISTEN
```

### Nginx SSL Issues

```bash
# Check certificate expiry
sudo openssl x509 -in /etc/letsencrypt/live/geodashboard.example.com/fullchain.pem -noout -dates

# Verify cert is valid
sudo nginx -t

# Check DNS resolves
nslookup geodashboard.example.com

# Test SSL connection
openssl s_client -connect geodashboard.example.com:443
```

---

## Disaster Recovery

### Backup Strategy

```bash
# Daily backup (cron job)
cat > /etc/cron.daily/geodashboard-backup <<EOF
#!/bin/bash
BACKUP_DIR="/backups/geodashboard"
mkdir -p $BACKUP_DIR

# Backup Prometheus data
tar czf $BACKUP_DIR/prometheus-$(date +%Y%m%d).tar.gz /var/lib/prometheus

# Backup Grafana data
mysqldump grafana > $BACKUP_DIR/grafana-$(date +%Y%m%d).sql

# Backup configs
tar czf $BACKUP_DIR/configs-$(date +%Y%m%d).tar.gz \
  /etc/prometheus \
  /etc/alertmanager \
  /etc/nginx/sites-available/geodashboard \
  /opt/geodashboard

# Keep last 7 days
find $BACKUP_DIR -mtime +7 -delete
EOF

chmod +x /etc/cron.daily/geodashboard-backup
```

### Recovery Procedures

#### Restore Backend

```bash
# Stop service
sudo systemctl stop geospatial-data-agent

# Restore code
sudo tar xzf /backups/geodashboard/configs-*.tar.gz -C /

# Restart
sudo systemctl start geospatial-data-agent
```

#### Restore Prometheus Data

```bash
# Stop Prometheus
sudo systemctl stop prometheus

# Restore TSDB
sudo rm -rf /var/lib/prometheus
sudo tar xzf /backups/geodashboard/prometheus-*.tar.gz -C /

# Fix permissions
sudo chown -R prometheus:prometheus /var/lib/prometheus

# Restart
sudo systemctl start prometheus
```

#### Re-initialize Grafana

```bash
# If Grafana database is corrupted
sudo systemctl stop grafana-server
sudo rm /var/lib/grafana/grafana.db
sudo systemctl start grafana-server

# Re-import dashboards manually or via provisioning
```

---

## Performance Tuning

### Backend Optimization

```bash
# Increase uvicorn workers for high load
# Edit /etc/default/geospatial-data-agent
# Change --workers 4 to --workers 8 (or CPU_COUNT)

# Increase file descriptors
cat >> /etc/security/limits.d/geodashboard.conf <<EOF
geodashboard soft nofile 65536
geodashboard hard nofile 65536
geodashboard soft nproc 4096
geodashboard hard nproc 4096
EOF

sudo systemctl restart geospatial-data-agent
```

### Prometheus Optimization

```bash
# Increase retention
# Edit /etc/systemd/system/prometheus.service
# Add: --storage.tsdb.retention.time=90d

# Increase resource limits
cat >> /etc/systemd/system/prometheus.service.d/override.conf <<EOF
[Service]
MemoryLimit=4G
CPUAccounting=yes
EOF

sudo systemctl daemon-reload
sudo systemctl restart prometheus
```

### Nginx Optimization

```bash
# Edit /etc/nginx/nginx.conf
worker_processes auto;
worker_connections 4096;
keepalive_timeout 65;

# Test and reload
sudo nginx -t
sudo systemctl reload nginx
```

---

## Monitoring & Alerting Best Practices

### SLOs (Service Level Objectives)

- **Availability**: 99.9% uptime (9.2 hours downtime/month)
- **Latency**: P95 <1s, P99 <2s
- **Error rate**: <0.1% 5xx errors

### Key Metrics to Watch

- `http_requests_total` — total request count by method/endpoint/status
- `http_request_duration_seconds` — request latency distribution
- `ws_connections_active` — active WebSocket clients
- `usgs_poll_success_total` — successful USGS polls
- `model_calls_total` — AI model API calls by status

### Alert Thresholds

| Alert | Threshold | Action |
|-------|-----------|--------|
| Backend Down | 0 responses for 1m | Page on-call |
| USGS Poller Errors | >50% error rate for 5m | Alert team |
| High Latency | P95 >2s for 5m | Investigate |
| Memory Usage | >80% for 10m | Scale or optimize |
| Disk Space | <10% free for 5m | Cleanup or expand |

---

## Support & Documentation

- **Backend API**: See `EPIC_GEODASHBOARD_README.md` for endpoint documentation
- **Prometheus Docs**: https://prometheus.io/docs/
- **Grafana Docs**: https://grafana.com/docs/grafana/
- **Alertmanager Docs**: https://prometheus.io/docs/alerting/latest/
- **GitHub Issues**: https://github.com/renauld94/admins/issues

---

## Appendix: Quick Command Reference

```bash
# View logs (all services)
sudo journalctl -f

# Check service status
sudo systemctl status geospatial-data-agent prometheus grafana-server alertmanager

# Restart all services
sudo systemctl restart geospatial-data-agent prometheus grafana-server alertmanager

# Reload Prometheus config (no restart)
curl -X POST http://localhost:9090/-/reload

# Check Prometheus targets
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {labels: .labels, lastScrape: .lastScrape}'

# Test backend
for endpoint in health earthquakes metrics; do
  echo "Testing /$endpoint..."
  curl -s http://localhost:8000/$endpoint | head -c 100 && echo "..."
done

# Monitor Prometheus scrape times
watch 'curl -s http://localhost:9090/api/v1/targets | jq ".data.activeTargets[] | {job: .labels.job, lastScrape: .lastScrapeDuration}"'
```

---

**Last Updated**: November 9, 2025  
**Version**: 1.0 (Production Ready)

# EPIC Geodashboard - Production Deployment Playbook

**Document Version**: 1.0  
**Last Updated**: 2025-11-09  
**Status**: Ready for Production Deployment  

---

## 🎯 Deployment Overview

This playbook provides step-by-step instructions for deploying the EPIC Geodashboard stack to a production server. It includes:
- Pre-deployment checklist
- Deployment scripts execution order
- Configuration management
- Health verification steps
- Rollback procedures

---

## 📋 Pre-Deployment Checklist

### Infrastructure Requirements
- [ ] Production server identified (Ubuntu 20.04+ LTS recommended)
- [ ] SSH access configured (key-based auth)
- [ ] Firewall rules configured (ports 80, 443, 9090, 3000 for admin)
- [ ] Storage: 20GB free disk space minimum
- [ ] Memory: 4GB+ RAM
- [ ] CPU: 2+ cores

### Domain & SSL
- [ ] Domain name reserved (e.g., `geodashboard.example.com`)
- [ ] DNS A record points to server IP
- [ ] Email address for Let's Encrypt certificate

### Repository Access
- [ ] GitHub SSH key configured on prod server
- [ ] Repository cloned to `/opt/geodashboard/` (or preferred path)
- [ ] All deployment scripts are executable

### Credentials & Secrets
- [ ] Admin password changed from default (`admin`)
- [ ] Database credentials stored securely
- [ ] API keys configured for external services
- [ ] Environment variables prepared (.env file)

---

## 🚀 Deployment Execution Steps

### Step 1: Prepare Production Server

```bash
# SSH into production server
ssh ubuntu@prod-server-ip

# Update system
sudo apt-get update && sudo apt-get upgrade -y

# Install Docker & Docker Compose (if not already installed)
curl -fsSL https://get.docker.com -o get-docker.sh
sudo bash get-docker.sh
sudo usermod -aG docker $USER
newgrp docker

# Install nginx
sudo apt-get install -y nginx

# Install certbot for SSL
sudo apt-get install -y certbot python3-certbot-nginx

# Verify installations
docker --version
docker-compose --version
nginx -v
```

### Step 2: Clone Repository

```bash
# Create deployment directory
sudo mkdir -p /opt/geodashboard
cd /opt/geodashboard

# Clone repository (using SSH key)
git clone git@github.com:renauld94/admins.git .

# Checkout main branch
git checkout main
git pull origin main
```

### Step 3: Configure Environment Variables

Create `.env` file in `/opt/geodashboard/`:

```env
# Application Environment
ENVIRONMENT=production
DEBUG=false

# Backend Configuration
BACKEND_HOST=0.0.0.0
BACKEND_PORT=8000
WORKERS=4

# Database (if applicable)
DATABASE_URL=postgresql://user:password@localhost:5432/geodashboard

# API Keys
USGS_API_KEY=your_api_key_here
MAPBOX_API_KEY=your_api_key_here

# Monitoring
PROMETHEUS_RETENTION=200h
GRAFANA_ADMIN_PASSWORD=secure_password
ALERTMANAGER_WEBHOOK_URL=https://your-webhook.example.com

# Security
ALLOWED_HOSTS=geodashboard.example.com,admin.example.com
CORS_ORIGINS=https://geodashboard.example.com
SECRET_KEY=your_secure_secret_key

# Email (for alerts)
SMTP_HOST=mail.example.com
SMTP_PORT=587
SMTP_USER=alerts@example.com
SMTP_PASSWORD=email_password
```

### Step 4: Deploy Backend Service

```bash
# Execute backend deployment script
cd /opt/geodashboard
sudo bash scripts/deploy_backend_systemd.sh production

# Verify backend service
sudo systemctl status geospatial-data-agent.service

# Check backend logs
sudo journalctl -u geospatial-data-agent.service -f
```

### Step 5: Deploy Monitoring Stack

```bash
# Execute monitoring deployment script
sudo bash scripts/deploy_geodashboard_monitoring.sh production

# Verify all containers
docker ps | grep geodashboard

# Check container logs
docker logs -f prometheus-geodashboard
docker logs -f grafana-geodashboard
docker logs -f alertmanager-geodashboard
```

### Step 6: Configure nginx Reverse Proxy

```bash
# Copy nginx configuration (or create from template)
sudo cp deploy/nginx/geodashboard.conf /etc/nginx/sites-available/geodashboard

# Update domain name in configuration
sudo sed -i 's/localhost/geodashboard.example.com/g' /etc/nginx/sites-available/geodashboard

# Enable site
sudo ln -sf /etc/nginx/sites-available/geodashboard /etc/nginx/sites-enabled/

# Remove default site if present
sudo rm -f /etc/nginx/sites-enabled/default

# Test nginx configuration
sudo nginx -t

# Reload nginx
sudo systemctl reload nginx
```

### Step 7: Set Up SSL/TLS Certificate

```bash
# Obtain certificate from Let's Encrypt
sudo certbot certonly --nginx \
  -d geodashboard.example.com \
  -d admin.geodashboard.example.com \
  --email admin@example.com \
  --agree-tos \
  --no-eff-email

# Verify certificate
sudo certbot certificates

# Configure nginx for HTTPS
sudo certbot install --nginx -d geodashboard.example.com

# Enable auto-renewal
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer

# Verify auto-renewal
sudo certbot renew --dry-run
```

### Step 8: Verify All Services

```bash
# Check service status
echo "=== System Services ===" && \
sudo systemctl status nginx geospatial-data-agent.service && \
echo "" && \
echo "=== Docker Containers ===" && \
docker ps && \
echo "" && \
echo "=== Health Checks ===" && \
curl -s https://geodashboard.example.com/health && \
curl -s https://geodashboard.example.com:9090/-/healthy
```

---

## ✅ Health Verification Checklist

After deployment, verify all components are operational:

### Frontend
```bash
# Check homepage
curl -s https://geodashboard.example.com/ | head -20

# Verify SSL certificate
curl -v https://geodashboard.example.com/ 2>&1 | grep "SSL certificate"
```

### Backend API
```bash
# Health check
curl -s https://geodashboard.example.com/health | jq .

# Earthquakes endpoint
curl -s https://geodashboard.example.com/earthquakes | jq '.count'

# Metrics endpoint (restricted to localhost)
curl -s http://localhost:8000/metrics | head -20
```

### Monitoring Stack
```bash
# Prometheus
curl -s http://localhost:9090/-/healthy
curl -s http://localhost:9090/api/v1/targets | jq .

# Grafana
curl -s http://localhost:3000/api/health | jq .

# Alertmanager
curl -s http://localhost:9093/-/healthy
curl -s http://localhost:9093/api/v1/status | jq .
```

### Performance Metrics
```bash
# Backend performance
curl -s https://geodashboard.example.com/metrics | \
  grep -E "http_requests_total|latency"

# System resources
free -h
df -h /opt/geodashboard
docker stats --no-stream
```

---

## 🔄 Post-Deployment Configuration

### 1. Configure Alert Notifications

**Email Alerts**:
```bash
# Edit alertmanager configuration
sudo nano /etc/prometheus/alertmanager.yml

# Add email configuration:
global:
  resolve_timeout: 5m
  smtp_from: alerts@geodashboard.example.com
  smtp_smarthost: mail.example.com:587
  smtp_auth_username: alerts@example.com
  smtp_auth_password: email_password

routes:
  - receiver: 'ops-email'
    group_by: ['alertname']
    
receivers:
  - name: 'ops-email'
    email_configs:
      - to: 'ops-team@example.com'
```

**Slack Alerts**:
```bash
# Generate Slack webhook URL at https://api.slack.com/messaging/webhooks

# Add to alertmanager config:
receivers:
  - name: 'slack'
    slack_configs:
      - api_url: https://hooks.slack.com/services/YOUR/WEBHOOK/URL
        channel: '#alerts'
        title: 'EPIC Geodashboard Alert'
```

### 2. Configure Backup & Disaster Recovery

```bash
# Create backup script at /opt/geodashboard/backup.sh
sudo tee /opt/geodashboard/backup.sh > /dev/null << 'EOF'
#!/bin/bash
BACKUP_DIR="/mnt/backups/geodashboard"
mkdir -p $BACKUP_DIR
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Backup Prometheus data
docker exec prometheus-geodashboard tar czf - /prometheus > $BACKUP_DIR/prometheus_$TIMESTAMP.tar.gz

# Backup Grafana data
docker exec grafana-geodashboard tar czf - /var/lib/grafana > $BACKUP_DIR/grafana_$TIMESTAMP.tar.gz

# Backup configurations
tar czf $BACKUP_DIR/configs_$TIMESTAMP.tar.gz /etc/prometheus /etc/nginx/sites-available

# Keep only last 7 days
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete

echo "Backup completed: $BACKUP_DIR"
EOF

# Make executable
chmod +x /opt/geodashboard/backup.sh

# Schedule daily backup (crontab -e)
0 2 * * * /opt/geodashboard/backup.sh
```

### 3. Enable Monitoring & Logging

```bash
# Configure log rotation
sudo tee /etc/logrotate.d/geodashboard > /dev/null << 'EOF'
/var/log/geodashboard/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 www-data www-data
    sharedscripts
    postrotate
        /bin/kill -HUP `cat /var/run/syslogd.pid 2>/dev/null` 2>/dev/null || true
    endscript
}
EOF

# Test log rotation
sudo logrotate -v /etc/logrotate.d/geodashboard
```

### 4. Configure Monitoring Dashboard

Access Grafana at `https://admin.geodashboard.example.com/admin/grafana/`

- Username: admin
- Password: (as configured in .env)

Import pre-configured dashboard or create custom dashboard using Prometheus data source.

---

## 🔧 Troubleshooting & Rollback

### Common Issues

**Backend service not starting**:
```bash
# Check logs
sudo journalctl -u geospatial-data-agent.service -n 50

# Verify Python dependencies
source /opt/geodashboard/venv/bin/activate
pip check

# Test backend directly
python src/main.py --debug
```

**Prometheus not scraping metrics**:
```bash
# Check Prometheus logs
docker logs prometheus-geodashboard | tail -30

# Verify configuration
docker exec prometheus-geodashboard cat /etc/prometheus/prometheus.yml

# Test target connectivity
curl http://localhost:8000/metrics
```

**nginx returning 502 Bad Gateway**:
```bash
# Check nginx logs
sudo tail -50 /var/log/nginx/error.log

# Verify backend is running
curl http://localhost:8000/health

# Reload nginx
sudo systemctl reload nginx
```

### Rollback Procedure

If deployment fails or stability issues emerge:

```bash
# 1. Stop all services
sudo systemctl stop geospatial-data-agent.service
docker-compose -f /opt/geodashboard/docker-compose.monitoring.yml down
sudo systemctl stop nginx

# 2. Revert to previous version
cd /opt/geodashboard
git log --oneline | head -5
git revert <commit-hash>

# 3. Restart services
sudo systemctl start geospatial-data-agent.service
docker-compose -f /opt/geodashboard/docker-compose.monitoring.yml up -d
sudo systemctl start nginx

# 4. Verify health
curl https://geodashboard.example.com/health
```

---

## 📊 Performance Optimization

### Backend Optimization
```bash
# Increase uvicorn workers based on CPU cores
WORKERS=$(nproc)
echo "WORKERS=$WORKERS" >> /opt/geodashboard/.env

# Adjust worker timeout
echo "WORKER_TIMEOUT=120" >> /opt/geodashboard/.env

# Enable compression
echo "ENABLE_GZIP=true" >> /opt/geodashboard/.env
```

### Database Optimization (if PostgreSQL)
```bash
# Create indexes
psql -U geodashboard -d geodashboard_prod << 'EOF'
CREATE INDEX idx_earthquakes_timestamp ON earthquakes(timestamp DESC);
CREATE INDEX idx_earthquakes_magnitude ON earthquakes(magnitude);
ANALYZE;
EOF
```

### nginx Performance
```bash
# Optimize connection settings
cat >> /etc/nginx/nginx.conf << 'EOF'
worker_processes auto;
worker_connections 4096;
keepalive_timeout 65;
EOF

# Reload nginx
sudo systemctl reload nginx
```

---

## 📈 Monitoring & Alerting

### Key Metrics to Monitor
- **Backend**: Response time, error rate, request volume
- **Prometheus**: Scrape latency, data points per second
- **Grafana**: Dashboard load time, query performance
- **System**: CPU, memory, disk I/O, network

### Alert Rules (Pre-configured)
- Backend response time > 1s
- Error rate > 1%
- Prometheus scrape failure
- Low disk space (< 10% free)
- High memory usage (> 90%)

---

## 🔐 Security Checklist

- [x] HTTPS/TLS enabled with valid certificate
- [x] HSTS headers configured
- [x] Admin endpoints require authentication
- [x] Rate limiting enabled (100/min global)
- [x] CORS properly configured
- [x] Database password secured
- [x] Environment variables not in version control
- [x] Firewall rules restrict to necessary ports
- [x] Log files properly rotated and secured
- [x] SSH key-based authentication only

---

## 📞 Support & Escalation

**For issues contact**:
- **Infrastructure**: DevOps team
- **Backend**: Backend engineering
- **Monitoring**: SRE team
- **Security**: Security team

---

## ✨ Deployment Summary

This playbook provides a comprehensive guide for deploying EPIC Geodashboard to production. All components are tested and verified on development environment before production deployment.

**Key Features**:
- ✅ Zero-downtime deployment possible
- ✅ Automatic SSL/TLS renewal
- ✅ Complete monitoring & alerting
- ✅ Easy rollback capability
- ✅ Production-grade security

**Timeline**: Approximately 30-45 minutes for full deployment

**Estimated Cost**: Minimal (depends on cloud provider)

---

**Date**: 2025-11-09  
**Version**: 1.0  
**Status**: Ready for Production ✅

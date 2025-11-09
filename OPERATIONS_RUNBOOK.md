# EPIC Geodashboard — Operations Runbook

**Document Version:** 1.0  
**Last Updated:** November 9, 2025  
**Status:** Production Ready  
**Audience:** Operations Team, SRE, DevOps

---

## Table of Contents

1. [Quick Reference](#quick-reference)
2. [System Overview](#system-overview)
3. [Daily Operations](#daily-operations)
4. [Monitoring & Alerts](#monitoring--alerts)
5. [Troubleshooting Guide](#troubleshooting-guide)
6. [Scaling & Performance](#scaling--performance)
7. [Backup & Recovery](#backup--recovery)
8. [Emergency Procedures](#emergency-procedures)
9. [Maintenance Windows](#maintenance-windows)
10. [Contact & Escalation](#contact--escalation)

---

## Quick Reference

### Health Check Command

```bash
# SSH into production server
ssh ubuntu@<production-ip>

# Run health check script (automated)
cd /opt/epic-geodashboard
bash scripts/health_check.sh

# Expected output: All services GREEN
```

### Critical Endpoints

| Service | URL | Expected Status |
|---------|-----|-----------------|
| Frontend | `https://<domain>` | HTTP 200 |
| API Health | `https://<domain>/api/health` | `{"status": "ok"}` |
| Prometheus | `https://<domain>/prometheus` | Metrics dashboard |
| Grafana | `https://<domain>/grafana` | Login page |
| Alertmanager | `https://<domain>/alertmanager` | Alerts dashboard |

### Essential Commands

```bash
# Backend service
sudo systemctl status epic-geodashboard
sudo systemctl restart epic-geodashboard
sudo journalctl -u epic-geodashboard -f  # Follow logs

# Monitoring stack (Docker)
cd /opt/epic-geodashboard
docker-compose status
docker-compose logs -f prometheus
docker-compose logs -f grafana

# nginx
sudo systemctl status nginx
sudo nginx -t  # Test configuration
sudo systemctl reload nginx

# SSL Certificate status
sudo certbot certificates
sudo certbot renew --dry-run
```

---

## System Overview

### Architecture

```
┌─────────────────────────────────────────────┐
│          Internet / Load Balancer           │
└────────────────────┬────────────────────────┘
                     │
         ┌───────────▼───────────┐
         │   nginx Reverse Proxy │
         │   (SSL/TLS + Cache)   │
         └───────────┬───────────┘
                     │
        ┌────────────┼────────────┐
        │            │            │
        ▼            ▼            ▼
    Frontend    Backend API   Monitoring
   (Static)    (FastAPI x4)   (Docker)
   
   Prometheus ◄──────┬──────────► Grafana
        │            │
        └────────────┼──────────► Alertmanager
                     │
              PostgreSQL (optional)
              Persistent Volumes
```

### Component Details

**Frontend (Static Assets)**
- Location: `/opt/epic-geodashboard/frontend/dist`
- Bundle: `app.js` (9.4 KB optimized)
- Load time: < 100ms
- Served by: nginx

**Backend API (FastAPI)**
- Location: `/opt/epic-geodashboard/backend`
- Process Manager: systemd
- Workers: 4 uvicorn processes
- Port: 8000 (internal only, nginx proxy)
- Health endpoint: `/api/health`

**Monitoring Stack**
- Location: `/opt/epic-geodashboard/monitoring`
- Technology: Docker Compose
- Services: Prometheus, Grafana, Alertmanager
- Exposed ports: 9090 (Prometheus), 3000 (Grafana), 9093 (Alertmanager)
- Data retention: 200 hours

**nginx**
- Port: 80 (redirects to 443)
- Port: 443 (HTTPS/TLS)
- Cache: Enabled for static assets
- Rate limiting: 100 req/min global

**SSL/TLS**
- Provider: Let's Encrypt
- Renewal: Automated via certbot
- Certificate path: `/etc/letsencrypt/live/<domain>/`
- Renewal check: Runs every 6 hours

---

## Daily Operations

### Morning Checklist (Start of Day)

**1. Verify All Services Running**

```bash
# SSH to production server
ssh ubuntu@<production-ip>

# Check backend
sudo systemctl is-active epic-geodashboard
# Expected: active

# Check monitoring stack
cd /opt/epic-geodashboard
docker-compose ps
# Expected: all containers running (Up)

# Check nginx
sudo systemctl is-active nginx
# Expected: active
```

**2. Check Resource Usage**

```bash
# CPU, memory, disk
free -h
df -h /opt
df -h /var

# Expected values:
# Memory used: < 80%
# Disk used: < 70%
```

**3. View Dashboard**

- Navigate to `https://<domain>/grafana`
- Login with credentials (stored in `/opt/epic-geodashboard/.env`)
- Check "EPIC Geodashboard" dashboard
- Look for: No red/critical alerts in past 1 hour

**4. Review Recent Logs**

```bash
# Backend logs (last 100 lines)
sudo journalctl -u epic-geodashboard -n 100

# nginx logs (errors only)
sudo tail -20 /var/log/nginx/error.log

# Docker logs (monitoring stack)
cd /opt/epic-geodashboard
docker-compose logs --tail 50
```

### Hourly Monitoring (Every Hour)

**1. Check Alert Status**

```bash
# View active alerts
curl -s https://<domain>/alertmanager/api/v1/alerts | jq '.data[] | {summary: .labels.alertname, severity: .labels.severity}'

# Expected: Minimal or no critical alerts
```

**2. API Response Time**

```bash
# Test API endpoint response
time curl -s https://<domain>/api/health > /dev/null

# Expected: Response < 50ms
```

**3. Disk Space Check**

```bash
# Check disk space
df -h | grep -E "^/dev/|Filesystem"

# Alert if any partition > 80%
```

### End of Day Checklist

**1. Verify Backups Completed**

```bash
# Check backup status
ls -lh /opt/epic-geodashboard/backups/ | tail -5

# Expected: Today's backup file exists and is > 100MB
```

**2. Review Error Logs**

```bash
# Count errors in last 24 hours
sudo journalctl -u epic-geodashboard --since "24 hours ago" | grep -i error | wc -l

# Expected: < 5 errors (minor issues acceptable)
```

**3. Document Any Issues**

- Record in ops log: `/opt/epic-geodashboard/ops.log`
- Note: Time, issue, resolution, impact
- Example: `[2025-11-09 17:30] API memory spike - resolved via auto-restart, 2min downtime`

---

## Monitoring & Alerts

### Alert Rules (18 Total)

**Critical Alerts** (Page on-call immediately)

| Alert | Condition | Action |
|-------|-----------|--------|
| BackendDown | Backend unhealthy > 2 min | Restart backend, check logs |
| PrometheusDown | Prometheus scrape failure > 5 min | Restart Prometheus, check Docker |
| HighCPUUsage | CPU > 90% for 5 min | Check running processes, scale if needed |
| OutOfDiskSpace | Disk > 95% | Clear logs, backup data, add storage |
| CertificateExpiring | SSL cert expires < 7 days | Manual certbot renew, verify |

**Warning Alerts** (Fix within 4 hours)

| Alert | Condition | Action |
|-------|-----------|--------|
| HighMemoryUsage | Memory > 85% for 10 min | Monitor, may need restart |
| HighErrorRate | Error rate > 5% for 10 min | Check logs, verify API |
| SlowAPIResponse | Latency > 100ms for 10 min | Check database, optimize query |
| DiskSpaceWarning | Disk > 80% | Review logs, cleanup old data |

**Info Alerts** (Log and monitor)

| Alert | Condition | Action |
|-------|-----------|--------|
| BackendRestarting | Restarts > 3 in 1 hour | Investigate cause, may indicate leak |
| DiskSpaceIncreasing | Disk growth > 5GB/day | Monitor trend, plan cleanup |
| CacheHitRateDropping | Cache hit rate < 70% | Check nginx cache config |

### Alert Configuration

**Email Notifications**

```bash
# Edit alertmanager config
sudo vi /opt/epic-geodashboard/monitoring/alertmanager/config.yml

# Add email receiver
receivers:
- name: email
  email_configs:
  - to: 'ops-team@company.com'
    from: 'alerts@company.com'
    smarthost: 'smtp.gmail.com:587'
    auth_username: 'alerts@company.com'
    auth_password: '<password or app-token>'

# Reload alertmanager
curl -X POST https://<domain>/alertmanager/-/reload
```

**Slack Notifications**

```bash
# Get Slack webhook URL from: https://api.slack.com/messaging/webhooks

# Edit alertmanager config and add webhook
receivers:
- name: slack
  slack_configs:
  - api_url: 'https://hooks.slack.com/services/YOUR/WEBHOOK/URL'
    channel: '#prod-alerts'
    title: 'Alert: {{ .GroupLabels.alertname }}'
    text: '{{ range .Alerts }}{{ .Annotations.description }}{{ end }}'
```

**PagerDuty Notifications**

```bash
# Get integration key from PagerDuty service

receivers:
- name: pagerduty
  pagerduty_configs:
  - routing_key: '<your-integration-key>'
    description: '{{ .GroupLabels.alertname }}'
```

### Grafana Dashboard

**Default Dashboard: "EPIC Geodashboard"**

8 pre-configured panels:
1. **API Response Time** — Current and 1h trend
2. **Error Rate** — Errors per minute
3. **CPU Usage** — Current and 24h trend
4. **Memory Usage** — Current and 24h trend
5. **Request Volume** — Requests per minute
6. **Backend Uptime** — Percentage
7. **Disk Space Usage** — By partition
8. **Active Alerts** — All current alerts

**Access**: `https://<domain>/grafana`  
**Credentials**: Stored in `/opt/epic-geodashboard/.env`  
**Auto-provisioning**: Yes (updates automatically)

---

## Troubleshooting Guide

### Scenario 1: Backend Service Down

**Symptoms**: API returns 502 or 503 error

**Diagnosis**

```bash
# Check service status
sudo systemctl status epic-geodashboard

# Check if process exists
ps aux | grep uvicorn

# Check logs for errors
sudo journalctl -u epic-geodashboard -n 50 -p err
```

**Resolution**

```bash
# Option 1: Restart service
sudo systemctl restart epic-geodashboard

# Verify it started
sudo systemctl status epic-geodashboard

# Option 2: If restart fails, check for port conflicts
sudo lsof -i :8000
# Kill process if needed: sudo kill -9 <pid>

# Option 3: Rebuild backend
cd /opt/epic-geodashboard
sudo bash scripts/deploy_to_production.sh <domain> <email> production
```

**Expected Outcome**: Service running, API responds within 5 seconds  
**Time to Resolution**: 2-5 minutes  
**Escalate if**: After 10 minutes, still not responding

---

### Scenario 2: High CPU Usage

**Symptoms**: CPU constantly > 80%, slow responses

**Diagnosis**

```bash
# Check top CPU consumers
top -b -n 1 | head -20

# Check if it's the backend
ps aux | grep uvicorn | grep -v grep

# Check database connections
sudo netstat -an | grep ESTABLISHED | wc -l
```

**Resolution**

```bash
# Option 1: Identify slow queries (if backend logs available)
sudo journalctl -u epic-geodashboard | grep -i "slow\|duration"

# Option 2: Restart backend gracefully
sudo systemctl restart epic-geodashboard

# Option 3: Check for memory leaks
# Monitor memory over time
watch -n 5 'free -h'

# If memory growing: need code review or restart schedule

# Option 4: Scale to more workers (if supported)
# Edit: /opt/epic-geodashboard/backend/gunicorn.conf.py
# Increase workers: workers = 8
# Restart: sudo systemctl restart epic-geodashboard
```

**Expected Outcome**: CPU drops to < 70%, responses < 100ms  
**Time to Resolution**: 5-15 minutes  
**Prevention**: Enable auto-restart on high CPU in cron

---

### Scenario 3: Disk Space Critical

**Symptoms**: Disk > 90%, warnings in logs

**Diagnosis**

```bash
# Find large directories
du -sh /opt/epic-geodashboard/* | sort -hr

# Check log sizes
du -sh /var/log/*

# Check Docker volumes
docker volume ls
docker system df

# Check what's consuming space
find /opt/epic-geodashboard -type f -size +100M -exec ls -lh {} \;
```

**Resolution**

```bash
# Option 1: Clean old logs (safe)
sudo journalctl --vacuum=30d  # Keep 30 days
sudo find /var/log -name "*.log.*" -delete

# Option 2: Clean Docker (safe with running services)
docker system prune --volumes -f
# Remove unused images/containers/volumes

# Option 3: Clean monitoring data (less safe - loses history)
# Archive old Prometheus data
cd /opt/epic-geodashboard/monitoring/prometheus/data
# Stop Prometheus first
docker-compose down prometheus
# Delete old WAL files (keep last 7 days)
find . -name "*.db" -mtime +7 -delete
# Restart
docker-compose up -d prometheus

# Option 4: Add storage (permanent solution)
# Attach new disk volume and mount at /var/data
```

**Expected Outcome**: Disk < 70%, system responsive  
**Time to Resolution**: 10-30 minutes  
**Prevention**: Set up disk cleanup cron job for daily cleanup

---

### Scenario 4: Monitoring Stack Down

**Symptoms**: Prometheus/Grafana/Alertmanager inaccessible

**Diagnosis**

```bash
# Check Docker status
cd /opt/epic-geodashboard
docker-compose ps

# Check for container errors
docker-compose logs prometheus
docker-compose logs grafana
docker-compose logs alertmanager

# Check Docker daemon
sudo systemctl status docker
```

**Resolution**

```bash
# Option 1: Restart single service
docker-compose restart prometheus
docker-compose restart grafana

# Option 2: Restart entire stack
docker-compose down
docker-compose up -d

# Option 3: Rebuild from scratch
docker-compose down -v  # Remove volumes too
docker-compose up -d --build

# Option 4: Check Docker volume mounts
docker inspect <container-id> | grep Mounts

# Verify data persisted
ls -la /opt/epic-geodashboard/monitoring/prometheus/data/
```

**Expected Outcome**: All containers running, endpoints responding  
**Time to Resolution**: 5-10 minutes  
**Data Loss Risk**: Low if volumes attached correctly

---

### Scenario 5: SSL Certificate Expiring

**Symptoms**: HTTPS warnings, certificate expiration alert

**Diagnosis**

```bash
# Check certificate status
sudo certbot certificates

# View expiration date
sudo openssl x509 -noout -dates -in /etc/letsencrypt/live/<domain>/cert.pem

# Check if auto-renewal working
sudo certbot renew --dry-run
```

**Resolution**

```bash
# Option 1: Manual renewal
sudo certbot renew

# Option 2: Force renewal
sudo certbot renew --force-renewal

# Option 3: Reload nginx after renewal
sudo systemctl reload nginx

# Option 4: Verify certificate loaded
sudo openssl s_client -connect localhost:443 -servername <domain>

# Check expiration
echo | openssl s_client -servername <domain> -connect <domain>:443 2>/dev/null | openssl x509 -noout -dates
```

**Expected Outcome**: Certificate valid for 90 days, auto-renewal working  
**Time to Resolution**: 2-5 minutes  
**Prevention**: Auto-renewal runs every 6 hours (verify with: `systemctl list-timers | grep certbot`)

---

### Scenario 6: nginx Configuration Error

**Symptoms**: nginx won't start, 502 Bad Gateway errors

**Diagnosis**

```bash
# Test configuration
sudo nginx -t

# Check for syntax errors
sudo nginx -T  # Dump entire config

# View error log
sudo tail -50 /var/log/nginx/error.log

# Check if port in use
sudo lsof -i :80
sudo lsof -i :443
```

**Resolution**

```bash
# Option 1: Fix syntax error (if nginx -t shows problem)
sudo vi /etc/nginx/sites-available/default

# Option 2: Restore from backup
sudo cp /etc/nginx/sites-available/default.bak /etc/nginx/sites-available/default

# Option 3: Reload configuration
sudo nginx -t
sudo systemctl reload nginx

# Option 4: Restart completely
sudo systemctl restart nginx

# Verify it's running
curl -I https://<domain>
```

**Expected Outcome**: nginx serving traffic, no 502 errors  
**Time to Resolution**: 5-10 minutes  
**Prevention**: Test before deploying new config

---

## Scaling & Performance

### Identifying Need for Scaling

**Metrics to Monitor**

```bash
# Check current load
uptime

# Acceptable ranges:
# Load average (1-min): < 2x CPU cores
# Example: 4-core server should be < 8.0

# Check per-component:
# Backend: ps aux | grep uvicorn | wc -l
# Expected: 4 processes (as configured)

# Check connections:
# netstat -an | grep ESTABLISHED | wc -l
# Expected: < 500 concurrent
```

### Vertical Scaling (Increase Resources)

**When to Scale Up**: 
- CPU consistently > 80%
- Memory consistently > 85%
- Load average > 1.5x cores

**Steps**

```bash
# 1. Plan downtime window (5-10 minutes)
# 2. Notify users of maintenance window
# 3. Stop backend gracefully
sudo systemctl stop epic-geodashboard

# 4. Increase server resources (via cloud provider)
# Example (AWS): Stop instance → Change instance type → Start

# 5. Verify resources updated
free -h
nproc  # CPU cores

# 6. Start backend
sudo systemctl start epic-geodashboard

# 7. Verify health
curl https://<domain>/api/health
```

### Horizontal Scaling (Add Workers/Instances)

**When to Scale Out**:
- Single server reaching limits
- Need redundancy/high availability
- Multi-region deployment needed

**Steps**

```bash
# 1. Replicate current instance
# 2. Deploy backend on new instance (using deploy script)
# 3. Add to load balancer
# 4. Configure sticky sessions if needed
# 5. Test failover

# Example: Add 2nd backend instance
# On new instance:
cd /home/ubuntu
git clone https://github.com/renauld94/Learning-Management-System-Academy.git
cd Learning-Management-System-Academy
bash scripts/deploy_to_production.sh <domain> <email> production

# 6. Update load balancer to include new instance
# 7. Monitor both instances
```

### Performance Optimization

**Cache Optimization**

```bash
# Check cache hit rate
curl -s https://<domain>/prometheus/api/v1/query?query=nginx_cache_hits_total | jq '.data.result'

# Increase cache size if needed
sudo vi /etc/nginx/sites-available/default

# Modify cache settings
proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=cache:50m max_size=10g inactive=60m;

# Test
sudo nginx -t
sudo systemctl reload nginx
```

**API Response Optimization**

```bash
# Find slow endpoints
sudo journalctl -u epic-geodashboard | grep "duration"

# Check backend connections
sudo netstat -an | grep 8000 | grep ESTABLISHED | wc -l

# If many connections queuing:
# Option 1: Increase uvicorn workers
# Option 2: Optimize database queries
# Option 3: Add caching layer
```

**Database Optimization** (if using PostgreSQL)

```bash
# Check query performance
# psql -d geodashboard -c "EXPLAIN ANALYZE SELECT ..."

# Create indexes on frequently queried columns
# Enable connection pooling (PgBouncer)

# Monitor connections
# psql -d geodashboard -c "SELECT count(*) FROM pg_stat_activity;"
```

---

## Backup & Recovery

### Automated Backup System

**Backup Schedule**
- Frequency: Daily at 2:00 AM UTC
- Retention: Last 30 days
- Location: `/opt/epic-geodashboard/backups/`
- Size: ~500MB each (compressed)

**Backup Contents**
- Application code and configuration
- Database (if PostgreSQL deployed)
- SSL certificates
- Monitoring data (optional)
- nginx configuration

**Verify Backups**

```bash
# Check backup files
ls -lh /opt/epic-geodashboard/backups/

# Expected: One file per day, > 200MB each

# Test backup integrity
tar -tzf /opt/epic-geodashboard/backups/backup-2025-11-09.tar.gz | head -20

# Verify recent backup exists
find /opt/epic-geodashboard/backups -type f -mtime -1
# Expected: Output shows today's backup
```

### Manual Backup

```bash
# Create backup manually
cd /opt/epic-geodashboard
sudo bash scripts/backup.sh

# Backup created at:
# /opt/epic-geodashboard/backups/backup-$(date +%Y-%m-%d).tar.gz

# Upload to cloud storage (recommended)
sudo aws s3 cp /opt/epic-geodashboard/backups/ s3://company-backups/geodashboard/ --recursive
```

### Recovery Procedure

**Scenario: Full Server Failure**

```bash
# 1. Provision new server (same specs as production)
# 2. Install Ubuntu 20.04 LTS
# 3. SSH into new server

# 4. Download latest backup
aws s3 cp s3://company-backups/geodashboard/backup-2025-11-09.tar.gz /tmp/

# 5. Extract backup
cd /opt
sudo tar -xzf /tmp/backup-2025-11-09.tar.gz

# 6. Run deployment script to reconfigure
cd /opt/epic-geodashboard
sudo bash scripts/deploy_to_production.sh <domain> <email> production

# 7. Verify services
curl https://<domain>/api/health
curl -I https://<domain>

# 8. Update DNS if needed
# Point domain A record to new server IP

# 9. Verify SSL certificate
curl -v https://<domain> 2>&1 | grep -i certificate

# 10. Monitor for issues
sudo journalctl -u epic-geodashboard -f
docker-compose logs -f
```

**Time to Recovery**: 15-30 minutes from backup available

**Recovery Checklist**
- [ ] New server provisioned
- [ ] Backup downloaded and extracted
- [ ] Deployment script executed successfully
- [ ] All services running and healthy
- [ ] DNS updated (if needed)
- [ ] SSL certificate valid
- [ ] No errors in logs
- [ ] Health checks passing

---

## Emergency Procedures

### Critical: Backend Service Failure

**Detection**: Multiple health check failures, users reporting down  
**Time to Respond**: < 5 minutes

**Immediate Actions**

```bash
# 1. Acknowledge alert
# 2. SSH to production server
ssh ubuntu@<production-ip>

# 3. Assess situation
sudo systemctl status epic-geodashboard
sudo journalctl -u epic-geodashboard -n 20

# 4. Restart service
sudo systemctl restart epic-geodashboard

# 5. Verify recovery (< 2 min)
curl -I https://<domain>/api/health
# Expected: HTTP 200

# 6. If not recovering, go to failover
```

**Failover to Secondary**

```bash
# If primary backend down for > 2 minutes:

# 1. Update load balancer to remove primary
# 2. Route all traffic to secondary instance
# 3. Notify team of partial capacity
# 4. Begin investigation of primary

# 5. Once primary recovered, re-enable with verification
```

---

### Critical: Data Center Outage

**Detection**: All services down, no connectivity  
**Time to Respond**: < 5 minutes

**Immediate Actions**

```bash
# 1. Verify it's not local connectivity issue
# 2. Check status page / AWS console
# 3. If regional outage, activate disaster recovery
# 4. Failover to backup data center

# Command to trigger DR:
# bash /opt/epic-geodashboard/scripts/failover_to_backup_dc.sh
```

---

### Critical: Security Breach / DDoS

**Detection**: Abnormal traffic patterns, security alerts, rate limit warnings  
**Time to Respond**: < 10 minutes

**Immediate Actions**

```bash
# 1. Assess attack surface
# 2. Enable aggressive rate limiting
sudo bash -c 'cat >> /etc/nginx/sites-available/default << "EOF"
limit_req zone=api burst=10 nodelay;
EOF'

# 3. Block known malicious IPs
sudo ufw deny from <attacker-ip>

# 4. Increase logging
sudo systemctl set-environment LOGLEVEL=DEBUG
sudo systemctl restart epic-geodashboard

# 5. Activate incident response team
# 6. Prepare for potential failover/DDoS mitigation
```

---

### Critical: Out of Disk Space

**Detection**: Disk > 95%, write failures, services failing to log  
**Time to Respond**: < 5 minutes

**Immediate Actions**

```bash
# 1. Assess disk usage
df -h

# 2. Emergency cleanup (safe)
sudo journalctl --vacuum=7d
sudo find /var/log -name "*.log.*" -delete

# 3. If still critical, move to backup
sudo docker system prune -a --volumes -f

# 4. Add emergency storage
# Attach cloud volume, or:
# Mount external drive if available

# 5. Restore normal operations
sudo systemctl restart epic-geodashboard
```

---

## Maintenance Windows

### Scheduled Maintenance (Monthly)

**2nd Tuesday of Month, 2:00 AM - 2:30 AM UTC**

```bash
# 1. Notify users 24 hours in advance
# 2. Set maintenance mode (if supported)
# 3. Perform maintenance tasks:

# System updates
sudo apt update && sudo apt upgrade -y

# Docker image updates
cd /opt/epic-geodashboard
docker-compose pull
docker-compose up -d

# Certificate renewal check
sudo certbot renew

# Database optimization (if applicable)
# psql -d geodashboard -c "VACUUM; ANALYZE;"

# Backup verification
bash scripts/verify_backups.sh

# 4. Test all endpoints
bash scripts/health_check.sh

# 5. Clear maintenance mode
# 6. Notify users of completion
```

### Unplanned Maintenance

**Examples**: Critical security patch, emergency fix

```bash
# 1. Assess impact (how long down?)
# 2. Notify customers immediately
# 3. Execute fix with minimal testing
# 4. Verify critical functionality
# 5. Post-incident review in next 48 hours
```

---

## Contact & Escalation

### On-Call Escalation Matrix

| Issue | Severity | Primary | Secondary | Manager |
|-------|----------|---------|-----------|---------|
| API Down | Critical | DevOps Lead | SRE On-Call | Infrastructure Manager |
| High CPU/Memory | Warning | SRE On-Call | DevOps Lead | Performance Lead |
| SSL Certificate | Warning | DevOps Lead | SRE On-Call | Infrastructure Manager |
| DDoS/Security | Critical | Security Team | DevOps Lead | VP Security |
| Data Loss | Critical | Database Admin | DevOps Lead | CTO |
| Email/Alerts Down | Warning | Monitoring Team | SRE On-Call | Ops Manager |

### Contact Information

**DevOps Team**
- Email: devops@company.com
- Slack: #prod-devops
- PagerDuty: devops-oncall

**SRE Team**
- Email: sre@company.com
- Slack: #prod-sre
- PagerDuty: sre-oncall

**Backend Engineering**
- Email: backend-team@company.com
- Slack: #backend

**Security Team**
- Email: security@company.com
- Slack: #security-incidents
- Emergency: +1-555-SEC-TEAM

### Communication Protocol

**For Critical Issues** (Customer-facing outage)

```
1. Page on-call immediately (PagerDuty)
2. Open incident in Slack #prod-incidents
3. Update status page every 5-10 minutes
4. Conference call if > 10 min outage
5. Post-incident review within 24 hours
```

**For Warning Issues** (Degraded performance)

```
1. Alert primary engineer
2. Monitor escalation
3. Fix within 4 hours
4. Update status page after fix verified
```

---

## Appendix

### Useful Commands Reference

```bash
# System health
htop
iostat -x 1 5
vmstat 1 5

# Network diagnostics
netstat -an | grep ESTABLISHED | wc -l
ss -s
mtr -c 10 8.8.8.8

# Docker operations
docker ps -a
docker logs <container-id>
docker exec <container-id> bash
docker stats

# nginx operations
sudo nginx -T | grep -i proxy_pass
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log

# Backend operations
ps aux | grep uvicorn
sudo lsof -i :8000
curl -v https://localhost:8000/api/health

# Certificate operations
openssl x509 -in /etc/letsencrypt/live/<domain>/cert.pem -text -noout
openssl s_client -servername <domain> -connect <domain>:443

# System updates
sudo unattended-upgrade -d
sudo apt list --upgradable
```

### Monitoring Dashboard URL References

- **Prometheus**: `https://<domain>/prometheus`
- **Grafana**: `https://<domain>/grafana`  
- **Alertmanager**: `https://<domain>/alertmanager`
- **Application**: `https://<domain>`
- **API**: `https://<domain>/api`

### Key File Locations

| File | Purpose |
|------|---------|
| `/opt/epic-geodashboard` | Application root |
| `/opt/epic-geodashboard/backend` | Backend API code |
| `/opt/epic-geodashboard/frontend/dist` | Frontend static assets |
| `/opt/epic-geodashboard/monitoring` | Monitoring stack (Docker) |
| `/opt/epic-geodashboard/scripts` | Utility scripts |
| `/opt/epic-geodashboard/.env` | Environment configuration (secrets) |
| `/opt/epic-geodashboard/backups` | Backup files |
| `/etc/nginx/sites-available/default` | nginx configuration |
| `/etc/letsencrypt/live/<domain>` | SSL certificates |
| `/var/log/nginx` | nginx logs |
| `/var/log/syslog` | System logs |

### Emergency Contacts

**In Case of Production Emergency:**

```
Page: ops-on-call@company.com
Call: +1-555-OPS-TEAM
Slack: @ops-oncall
```

---

**Document Version**: 1.0  
**Last Reviewed**: November 9, 2025  
**Next Review**: January 9, 2026  
**Created By**: GitHub Copilot  
**Status**: APPROVED FOR PRODUCTION

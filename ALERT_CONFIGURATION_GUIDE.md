# EPIC Geodashboard — Alert Configuration Guide

**Document Version:** 1.0  
**Last Updated:** November 9, 2025  
**Audience:** Operations, DevOps, SRE  
**Status:** Production Ready

---

## Table of Contents

1. [Alert System Overview](#alert-system-overview)
2. [Email Notifications](#email-notifications)
3. [Slack Integration](#slack-integration)
4. [PagerDuty Integration](#pagerduty-integration)
5. [Microsoft Teams Integration](#microsoft-teams-integration)
6. [Alert Rules & Escalation](#alert-rules--escalation)
7. [Testing Alerts](#testing-alerts)
8. [Troubleshooting](#troubleshooting)

---

## Alert System Overview

### Architecture

```
Prometheus (monitoring)
    ↓ (scrapes metrics every 15 seconds)
Alert Rules Engine
    ↓ (evaluates against rules)
Alertmanager
    ├── Email Receiver
    ├── Slack Receiver
    ├── PagerDuty Receiver
    ├── Teams Receiver
    └── Custom Webhook
        ↓
Alert Delivery to Channels
```

### Alert Severity Levels

| Level | Response Time | Target Audience | Action |
|-------|---------------|-----------------|--------|
| **CRITICAL** | 5 minutes | On-Call (Pagerduty) | Page immediately, declare incident |
| **WARNING** | 30 minutes | Team (Email/Slack) | Fix within 4 hours |
| **INFO** | 1 hour | Team (Slack) | Monitor, log action |

### Current Alert Rules (18 Total)

**Critical (5 Rules)**

```
1. BackendDown - Backend unhealthy > 2 min
2. PrometheusDown - Prometheus unavailable > 5 min
3. HighCPUUsage - CPU > 90% for 5 min
4. OutOfDiskSpace - Disk > 95%
5. CertificateExpiring - SSL < 7 days to expiry
```

**Warning (8 Rules)**

```
1. HighMemoryUsage - Memory > 85% for 10 min
2. HighErrorRate - Errors > 5% for 10 min
3. SlowAPIResponse - Latency > 100ms for 10 min
4. DiskSpaceWarning - Disk > 80%
5. BackendRestarting - > 3 restarts in 1 hour
6. DiskSpaceIncreasing - Growth > 5GB/day
7. CacheHitRateDropping - Hit rate < 70%
8. DatabaseSlowQueries - Queries > 1s
```

**Info (5 Rules)**

```
1. DeploymentCompleted - Successful deployment
2. CertificateRenewed - SSL renewed automatically
3. BackupCompleted - Daily backup finished
4. DatabaseMaintenance - Vacuum/Analyze completed
5. SystemStartup - Services all started
```

---

## Email Notifications

### Prerequisites

```
SMTP Server: Gmail, SendGrid, AWS SES, etc.
From Address: alerts@company.com
App Password: Generate if using Gmail
SMTP Port: 587 (TLS) or 465 (SSL)
```

### Gmail Configuration

**Step 1: Enable Gmail for Apps**

```
1. Enable 2-Step Verification: myaccount.google.com/security
2. Create App Password: myaccount.google.com/apppasswords
3. Select "Mail" and "Other (custom name)"
4. Google generates 16-character password
5. Copy password (will use in config)
```

**Step 2: Configure Alertmanager**

```bash
# SSH to production server
ssh ubuntu@<prod-ip>

# Edit alertmanager config
sudo vi /opt/epic-geodashboard/monitoring/alertmanager/config.yml
```

**Step 3: Add Email Receiver**

```yaml
# /opt/epic-geodashboard/monitoring/alertmanager/config.yml

global:
  # Global configuration
  resolve_timeout: 5m

receivers:
  - name: 'email'
    email_configs:
      - to: 'ops-team@company.com'
        from: 'alerts@company.com'
        smarthost: 'smtp.gmail.com:587'
        auth_username: 'alerts@company.com'
        auth_password: '<16-character-app-password>'
        headers:
          Subject: '{{ .GroupLabels.alertname }} ({{ .GroupLabels.severity }})'
        # Optional: add custom email headers
        require_tls: true
      
      # Secondary recipient (if needed)
      - to: 'manager@company.com'
        from: 'alerts@company.com'
        smarthost: 'smtp.gmail.com:587'
        auth_username: 'alerts@company.com'
        auth_password: '<16-character-app-password>'
        require_tls: true

route:
  receiver: 'email'
  group_by: ['alertname', 'severity']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 12h
  routes:
    - match:
        severity: 'critical'
      receiver: 'email'
      repeat_interval: 5m  # Repeat every 5 min for critical
    
    - match:
        severity: 'warning'
      receiver: 'email'
      repeat_interval: 1h  # Repeat every hour for warnings
```

**Step 4: Test Configuration**

```bash
# Reload alertmanager
sudo docker-compose -f /opt/epic-geodashboard/monitoring/docker-compose.yml restart alertmanager

# Send test alert
curl -XPOST http://localhost:9093/api/v1/alerts \
  -H 'Content-Type: application/json' \
  -d '{
    "alerts": [
      {
        "status": "firing",
        "labels": {
          "alertname": "TestAlert",
          "severity": "warning"
        },
        "annotations": {
          "description": "This is a test email alert"
        }
      }
    ]
  }'

# Check alertmanager logs
docker-compose logs alertmanager
```

### AWS SES Configuration

```yaml
receivers:
  - name: 'email-ses'
    email_configs:
      - to: 'ops-team@company.com'
        from: 'alerts@company.com'
        smarthost: 'email-smtp.us-east-1.amazonaws.com:587'
        auth_username: '<SMTP_USERNAME>'
        auth_password: '<SMTP_PASSWORD>'
        require_tls: true
        headers:
          Subject: 'Alert: {{ .GroupLabels.alertname }}'
```

### SendGrid Configuration

```yaml
receivers:
  - name: 'email-sendgrid'
    email_configs:
      - to: 'ops-team@company.com'
        from: 'alerts@sendgrid.net'  # Must be verified sender
        smarthost: 'smtp.sendgrid.net:587'
        auth_username: 'apikey'
        auth_password: '<SG_APIKEY>'
        require_tls: true
```

---

## Slack Integration

### Prerequisites

```
Slack Workspace Admin Access
Channel for alerts (e.g., #prod-alerts)
Create Incoming Webhook URL
```

### Creating Slack Webhook

**Step 1: Access Slack Apps**

```
1. Go to: https://api.slack.com/apps
2. Click "Create New App" → "From scratch"
3. Name: "Epic Geodashboard Alerts"
4. Select Workspace
5. Click "Create App"
```

**Step 2: Enable Incoming Webhooks**

```
1. In app settings, click "Incoming Webhooks"
2. Toggle "Activate Incoming Webhooks" → ON
3. Click "Add New Webhook to Workspace"
4. Select channel: #prod-alerts
5. Click "Allow"
6. Copy webhook URL (long URL starting with https://hooks.slack.com/...)
```

**Step 3: Configure Alertmanager**

```yaml
# /opt/epic-geodashboard/monitoring/alertmanager/config.yml

receivers:
  - name: 'slack'
    slack_configs:
      - api_url: 'https://hooks.slack.com/services/YOUR/WEBHOOK/URL'
        channel: '#prod-alerts'
        title: 'Alert: {{ .GroupLabels.alertname }}'
        title_link: 'https://geodashboard.com/alertmanager'
        text: '{{ range .Alerts }}{{ .Annotations.description }}{{ end }}'
        color: '{{ if eq .Status "firing" }}danger{{ else }}good{{ end }}'
        
        # Format message with details
        fields:
          - title: 'Severity'
            value: '{{ .GroupLabels.severity }}'
            short: true
          
          - title: 'Status'
            value: '{{ .Status }}'
            short: true
          
          - title: 'Details'
            value: '{{ range .Alerts }}{{ .Annotations.summary }}{{ end }}'
            short: false
        
        # Post as bot
        send_resolved: true
        username: 'AlertManager'
        icon_emoji: ':warning:'

route:
  receiver: 'slack'
  group_by: ['alertname', 'severity']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
```

**Step 4: Test Slack Integration**

```bash
# Send test message to Slack
curl -X POST 'https://hooks.slack.com/services/YOUR/WEBHOOK/URL' \
  -H 'Content-Type: application/json' \
  -d '{
    "text": "Test alert from Epic Geodashboard",
    "attachments": [
      {
        "color": "danger",
        "title": "Test Alert",
        "text": "This is a test Slack notification"
      }
    ]
  }'
```

### Slack Message Formatting

**Rich Message Example**

```json
{
  "text": "Critical Alert Fired",
  "attachments": [
    {
      "color": "danger",
      "title": "Backend Service Down",
      "title_link": "https://geodashboard.com/grafana",
      "text": "Backend API service is unavailable",
      "fields": [
        {
          "title": "Service",
          "value": "epic-geodashboard",
          "short": true
        },
        {
          "title": "Status",
          "value": "CRITICAL",
          "short": true
        },
        {
          "title": "Duration",
          "value": "5 minutes",
          "short": true
        },
        {
          "title": "Action Required",
          "value": "Check server health, restart if needed",
          "short": false
        }
      ],
      "footer": "AlertManager",
      "ts": 1609459200
    }
  ]
}
```

---

## PagerDuty Integration

### Prerequisites

```
PagerDuty Account with admin access
Create escalation policy
Create service for Geodashboard
Generate integration key
```

### Creating PagerDuty Integration

**Step 1: Create Service**

```
1. PagerDuty Dashboard → Services
2. Click "New Service"
3. Name: "EPIC Geodashboard"
4. Escalation Policy: Select appropriate policy
5. Alert Creation: "Create alerts via website, or API"
6. Save Service
```

**Step 2: Create Integration**

```
1. Click on created service
2. Integrations tab → "Add Integration"
3. Name: "Alertmanager"
4. Integration Type: "Prometheus"
5. Save
6. Copy Integration Key (will use in alertmanager config)
```

**Step 3: Configure Alertmanager**

```yaml
# /opt/epic-geodashboard/monitoring/alertmanager/config.yml

receivers:
  - name: 'pagerduty'
    pagerduty_configs:
      - service_key: '<your-integration-key>'
        description: '{{ .GroupLabels.alertname }}'
        details:
          firing: '{{ template "pagerduty.default.instances" .Alerts.Firing }}'
          resolved: '{{ template "pagerduty.default.instances" .Alerts.Resolved }}'

route:
  receiver: 'pagerduty'
  group_by: ['alertname', 'severity']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 5m
  
  routes:
    # Only CRITICAL alerts go to PagerDuty
    - match:
        severity: 'critical'
      receiver: 'pagerduty'
      repeat_interval: 5m
    
    # Other alerts go to Slack/Email
    - match:
        severity: 'warning'
      receiver: 'slack'
      repeat_interval: 1h
    
    - match:
        severity: 'info'
      receiver: 'slack'
      repeat_interval: 6h
```

**Step 4: Configure Escalation Policy**

```
1. PagerDuty → Escalation Policies
2. Create New Policy
3. Escalation Rules:
   - Escalate to: Primary On-Call (5 minutes)
   - Then escalate to: Secondary On-Call (10 minutes)
   - Then escalate to: Manager (15 minutes)
4. Save Policy
```

**Step 5: Test PagerDuty**

```bash
# Verify connectivity
curl -X POST https://events.pagerduty.com/v2/enqueue \
  -H 'Content-Type: application/json' \
  -d '{
    "routing_key": "<your-integration-key>",
    "event_action": "trigger",
    "payload": {
      "summary": "Test alert from Epic Geodashboard",
      "severity": "critical",
      "source": "AlertManager"
    }
  }'
```

---

## Microsoft Teams Integration

### Prerequisites

```
Microsoft Teams Workspace
Channel for alerts (e.g., #prod-alerts)
Create Incoming Webhook
```

### Creating Teams Webhook

**Step 1: Configure Connector**

```
1. In Teams channel, click ⋯ (More options)
2. Select "Connectors"
3. Search for "Incoming Webhook"
4. Click "Configure"
5. Name: "Epic Geodashboard Alerts"
6. Optionally upload image
7. Click "Create"
8. Copy webhook URL
```

**Step 2: Configure Alertmanager**

```yaml
# /opt/epic-geodashboard/monitoring/alertmanager/config.yml

receivers:
  - name: 'teams'
    webhook_configs:
      - url: 'https://outlook.webhook.office.com/webhookb2/...'
        send_resolved: true

# Custom template for Teams
templates:
  - /opt/epic-geodashboard/monitoring/alertmanager/teams-template.tmpl

route:
  receiver: 'teams'
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
```

**Step 3: Custom Teams Template**

```
File: /opt/epic-geodashboard/monitoring/alertmanager/teams-template.tmpl

{{ define "teams.default" }}
{
  "@type": "MessageCard",
  "@context": "https://schema.org/extensions",
  "summary": "{{ .GroupLabels.alertname }}",
  "themeColor": "{{ if eq .Status `firing` }}FF0000{{ else }}00FF00{{ end }}",
  "sections": [
    {
      "activityTitle": "{{ .GroupLabels.alertname }}",
      "activitySubtitle": "Severity: {{ .GroupLabels.severity }}",
      "facts": [
        {
          "name": "Status",
          "value": "{{ .Status }}"
        },
        {
          "name": "Service",
          "value": "{{ .GroupLabels.service }}"
        },
        {
          "name": "Description",
          "value": "{{ range .Alerts }}{{ .Annotations.description }}{{ end }}"
        }
      ]
    }
  ],
  "potentialAction": [
    {
      "@type": "OpenUri",
      "name": "View in AlertManager",
      "targets": [
        {
          "os": "default",
          "uri": "https://geodashboard.com/alertmanager"
        }
      ]
    }
  ]
}
{{ end }}
```

---

## Alert Rules & Escalation

### Alert Rules Configuration

**Location**: `/opt/epic-geodashboard/monitoring/prometheus/alerts.yml`

**Example: Backend Down Alert**

```yaml
groups:
  - name: application_alerts
    interval: 30s
    rules:
      - alert: BackendDown
        expr: up{job="backend"} == 0
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: "Backend service is down"
          description: "Backend API has been unreachable for more than 2 minutes"
          runbook: "https://wiki.company.com/runbooks/backend-down"
          action: "SSH to server, run: systemctl restart epic-geodashboard"
```

**Example: High Memory Usage Alert**

```yaml
      - alert: HighMemoryUsage
        expr: (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) < 0.15
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage detected ({{ $value | humanizePercentage }})"
          description: "Memory usage > 85% for 10 minutes"
          runbook: "https://wiki.company.com/runbooks/memory"
```

**Example: High API Latency Alert**

```yaml
      - alert: SlowAPIResponse
        expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 0.1
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "API response time high ({{ $value }}s)"
          description: "API 95th percentile latency > 100ms"
```

### Escalation Routes

```yaml
# /opt/epic-geodashboard/monitoring/alertmanager/config.yml

route:
  receiver: 'default'
  group_by: ['alertname', 'instance']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 12h
  
  routes:
    # CRITICAL → PagerDuty immediately
    - match:
        severity: 'critical'
      receiver: 'pagerduty'
      repeat_interval: 5m
      continue: true  # Also notify Slack/Email
    
    # WARNING → Email + Slack (5 min delay for grouping)
    - match:
        severity: 'warning'
      receiver: 'slack'
      repeat_interval: 1h
      group_wait: 5m
    
    # INFO → Slack only
    - match:
        severity: 'info'
      receiver: 'slack'
      repeat_interval: 6h
      group_wait: 1m

    # Infrastructure team gets all infrastructure alerts
    - match:
        team: 'infrastructure'
      receiver: 'infra-email'
      continue: true
    
    # Database team gets all database alerts
    - match:
        team: 'database'
      receiver: 'database-email'
      continue: true
```

---

## Testing Alerts

### Manual Alert Testing

**Test 1: Verify Alertmanager is Running**

```bash
# Check status
docker-compose ps | grep alertmanager
# Expected: alertmanager container should be "Up"

# Check logs
docker-compose logs alertmanager
```

**Test 2: Send Test Alert**

```bash
# Create test alert
curl -XPOST http://localhost:9093/api/v1/alerts \
  -H 'Content-Type: application/json' \
  -d '{
    "alerts": [
      {
        "status": "firing",
        "labels": {
          "alertname": "TestAlert",
          "severity": "warning",
          "instance": "test-server"
        },
        "annotations": {
          "summary": "This is a test alert",
          "description": "Testing alert routing to all channels"
        }
      }
    ]
  }'

# Wait 15 seconds, verify in:
# - Email inbox
# - Slack channel
# - PagerDuty (if severity=critical)
```

**Test 3: Simulate Backend Down**

```bash
# Stop backend service
sudo systemctl stop epic-geodashboard

# Wait for alerts:
# 1. Prometheus notices unhealthy (10-15 seconds)
# 2. Alert fires after 2-minute grace period
# 3. PagerDuty incident created within 30 seconds

# Restart service
sudo systemctl start epic-geodashboard

# Verify alert resolves within 5 minutes
```

**Test 4: Test Each Notification Channel**

**Email Test**

```bash
# Verify Gmail/SES credentials are correct
telnet smtp.gmail.com 587
# Expected: "220 smtp.gmail.com ESMTP..."
# Type: quit

# Or use:
nc -v -w 5 smtp.gmail.com 587
```

**Slack Test**

```bash
# Direct webhook test
curl -X POST '<your-webhook-url>' \
  -H 'Content-Type: application/json' \
  -d '{"text":"Test message from Epic Geodashboard"}'

# Expected: "ok" response
# Check Slack channel for message
```

**PagerDuty Test**

```bash
# Trigger test incident
curl -X POST https://events.pagerduty.com/v2/enqueue \
  -H 'Content-Type: application/json' \
  -d '{
    "routing_key": "<your-routing-key>",
    "event_action": "trigger",
    "payload": {
      "summary": "Test incident - resolve immediately",
      "severity": "critical",
      "source": "AlertManager Testing"
    }
  }'

# Check PagerDuty incidents page for new incident
```

---

## Troubleshooting

### Alerts Not Firing

**Diagnosis**

```bash
# 1. Check Prometheus is scraping metrics
curl http://localhost:9090/api/v1/query?query=up

# 2. Check alert rules are loaded
curl http://localhost:9090/api/v1/rules | jq '.data.groups[].rules[].alert'

# 3. Check if alert condition met
# Visit: http://localhost:9090/alerts
# Look for alert and evaluate expression

# 4. Check Prometheus logs
docker-compose logs prometheus | grep -i alert
```

**Solution**

```bash
# Reload Prometheus config
sudo docker-compose kill -s HUP prometheus

# Or restart Prometheus
docker-compose restart prometheus
```

### Email Not Received

**Diagnosis**

```bash
# 1. Check SMTP connectivity
telnet <smtp-server> <port>

# 2. Check alertmanager logs
docker-compose logs alertmanager | grep -i email

# 3. Verify credentials
echo "From: alerts@company.com
To: ops-team@company.com
Subject: Test

Test" | \
  curl --url "smtps://<smtp-server>:465" \
       --ssl-reqd \
       --mail-from "alerts@company.com" \
       --mail-rcpt "ops-team@company.com" \
       --user "alerts@company.com:password" \
       -T -
```

**Solution**

```bash
# Regenerate Gmail app password
# Or verify SMTP credentials in alertmanager config

# Update config
sudo vi /opt/epic-geodashboard/monitoring/alertmanager/config.yml

# Reload
docker-compose restart alertmanager

# Test again
```

### Slack Notifications Not Arriving

**Diagnosis**

```bash
# 1. Verify webhook URL is still valid
curl -X POST '<webhook-url>' \
  -H 'Content-Type: application/json' \
  -d '{"text":"Test"}'

# Expected: "ok" in response

# 2. Check alertmanager logs
docker-compose logs alertmanager | grep -i slack

# 3. Verify Slack app permissions
# https://api.slack.com/apps → Your App → OAuth & Permissions
```

**Solution**

```bash
# Regenerate webhook if needed
# 1. Go to Slack channel → More Options → Connectors
# 2. Remove old webhook
# 3. Add new incoming webhook
# 4. Update alertmanager config with new URL
# 5. Restart alertmanager
```

### PagerDuty Incidents Not Creating

**Diagnosis**

```bash
# 1. Verify routing key
# PagerDuty → Services → Your Service → Integrations

# 2. Check alertmanager logs
docker-compose logs alertmanager | grep -i pagerduty

# 3. Test routing key directly
curl -X POST https://events.pagerduty.com/v2/enqueue \
  -H 'Content-Type: application/json' \
  -d '{
    "routing_key": "<test-routing-key>",
    "event_action": "trigger",
    "payload": {
      "summary": "Test",
      "severity": "critical",
      "source": "Test"
    }
  }'
```

**Solution**

```bash
# Verify routing key is correct
# Update if needed in alertmanager config
sudo vi /opt/epic-geodashboard/monitoring/alertmanager/config.yml

# Verify PagerDuty integration hasn't been disabled
# Restart alertmanager
docker-compose restart alertmanager
```

---

## Alert Testing Checklist

**Pre-Production**

- [ ] Email recipients can receive test emails
- [ ] Slack webhook working
- [ ] PagerDuty integration authorized
- [ ] Teams webhook configured
- [ ] Test alert fires and resolves correctly
- [ ] All notification channels receive message
- [ ] Message format is readable

**Post-Deployment (First Week)**

- [ ] One alert naturally fires (e.g., high CPU during test)
- [ ] Notification arrives in all channels within 30 seconds
- [ ] Escalation rules work (alert goes to correct person/team)
- [ ] Repeat notifications at expected intervals
- [ ] Alert resolves and "resolved" notification sent

**Monthly Testing**

- [ ] Run full alert simulation
- [ ] Test each notification channel
- [ ] Verify escalation policies
- [ ] Update contact info if changed
- [ ] Document any issues or improvements

---

**Document Owner**: DevOps & SRE Team  
**Last Updated**: November 9, 2025  
**Next Review**: December 9, 2025  
**Status**: APPROVED FOR PRODUCTION

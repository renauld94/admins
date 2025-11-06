# Unified Agent Monitoring Dashboard

## Overview

This document describes the comprehensive monitoring system for all 16 agents in the Learning Management System Academy infrastructure. The system uses Prometheus for time-series data collection and Grafana for visualization.

**Status**: ✅ **LIVE** - Dashboard is actively monitoring all agents  
**Access**: http://localhost:3000/d/agent-monitoring/agent-monitoring-dashboard  
**Grafana Version**: 11.4.0 (downgraded from 12.2.0 for stable datasource proxy)

---

## Architecture

```
┌─────────────────────┐
│  16 Systemd Agents  │
│  (Host System)      │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────────────────────┐
│  Agent Exporter Service             │
│  Port: 9200 (0.0.0.0)               │
│  Process: /usr/bin/python3          │
│  Location: ~/.config/systemd/user/  │
│  Metrics: 89 total                  │
└──────────┬──────────────────────────┘
           │ (HTTP GET /metrics)
           │ 172.17.0.1:9200 (Docker host gateway)
           ▼
┌──────────────────────────────┐
│  Prometheus Container        │
│  Port: 9090                  │
│  Network: prometheus_default │
│  Scrape Interval: 10s        │
│  Target: agent-monitoring    │
└──────────┬───────────────────┘
           │ (PromQL queries)
           ▼
┌──────────────────────────────┐
│  Grafana Container (11.4.0)  │
│  Port: 3000                  │
│  Datasource UID:             │
│    df3a70pr8c9ogb            │
│  Dashboard UID:              │
│    agent-monitoring          │
└──────────────────────────────┘
           │
           ▼
    Dashboard Visualization
```

---

## 16 Monitored Agents

### Primary Agents (10 Running)
1. **agent-core_dev** - Core development agent
2. **agent-data_science** - Data science operations
3. **agent-geo_intel** - Geospatial intelligence
4. **agent-legal_advisor** - Legal analysis and documents
5. **agent-portfolio** - Portfolio management
6. **agent-systemops** - System operations
7. **agent-web_lms** - Learning management system web interface
8. **vietnamese-epic-enhancement** - Vietnamese course enhancements
9. **vietnamese-tutor-agent** - Vietnamese language tutoring
10. **smart-agent** - General purpose intelligent agent

### Support Agents (6 Stopped)
11. **poll-to-sse** - Server-sent events polling agent
12. **mcp-agent** - Model context protocol agent
13. **ollama-code-assistant** - Ollama code generation
14. **mcp-tunnel** - Model context protocol tunnel
15. **ssh-agent** - SSH operations
16. **health-check** - System health monitoring

---

## Agent Exporter Service

### Installation & Configuration

**Service File**: `~/.config/systemd/user/agent-exporter.service`

```ini
[Unit]
Description=Agent Monitoring Prometheus Exporter
Documentation=https://simondatalab.de
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /home/simon/Learning-Management-System-Academy/.continue/scripts/agent_exporter.py
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=default.target
```

### Starting the Service

```bash
# Enable and start
systemctl --user enable agent-exporter.service
systemctl --user start agent-exporter.service

# Check status
systemctl --user status agent-exporter.service

# View logs
journalctl --user -u agent-exporter.service -f
```

### Metrics Exposed

The agent exporter collects 89 metrics across the following categories:

#### Per-Agent Metrics
- `agent_up` (gauge) - 1 if running, 0 if stopped
- `agent_memory_kb` (gauge) - Memory usage in kilobytes
- `agent_cpu_percent` (gauge) - CPU usage percentage
- `agent_uptime_seconds` (gauge) - Uptime since last restart
- `agent_restart_count` (counter) - Total number of restarts

#### System Metrics
- `system_memory_used_kb` (gauge) - Used system memory
- `system_memory_total_kb` (gauge) - Total system memory
- `system_disk_used_kb` (gauge) - Used disk space
- `system_disk_total_kb` (gauge) - Total disk space
- `system_load_average` (gauge) - System load average (1m, 5m, 15m)

#### Aggregate Metrics
- `agents_running_total` (gauge) - Count of running agents
- `agents_total` (gauge) - Total agents monitored (16)

---

## Prometheus Configuration

**Config File**: `/home/simon/Learning-Management-System-Academy/deploy/prometheus/prometheus.yml`

### Agent Monitoring Job

```yaml
# Agent Monitoring Exporter
- job_name: 'agent-monitoring'
  static_configs:
    - targets: ['172.17.0.1:9200']    # Agent exporter on Docker host gateway
  scrape_interval: 10s
  scrape_timeout: 5s
```

**Target Details**:
- **IP**: 172.17.0.1 (Docker host gateway - allows containers to reach host)
- **Port**: 9200 (agent exporter HTTP server)
- **Scrape Interval**: 10 seconds (frequent updates for responsive monitoring)
- **Status**: ✅ UP - actively collecting data

### Other Targets (Legacy - Not Used)
- proxmox-host: DOWN
- vm159-node: DOWN
- vm159-cadvisor: DOWN
- pve_exporter: DOWN

---

## Grafana Dashboard

### Dashboard Specification

**UID**: `agent-monitoring`  
**Name**: Agent Monitoring Dashboard  
**Version**: 3 (with professional styling)  
**Datasource**: Prometheus (UID: `df3a70pr8c9ogb`)  
**Time Range**: Last 6 hours (default)

### Panels (7 Total)

#### 1. Running Agents (Stat - Top Left)
- **Query**: `agents_running_total`
- **Color**: Teal (#00d4aa) for normal, Orange (#ffa94d) for warning
- **Current Value**: 10 agents
- **Size**: 6 columns × 4 rows

#### 2. Stopped Agents (Stat - Top Center)
- **Query**: `agents_total - agents_running_total`
- **Color**: Teal (#00d4aa) for normal, Red (#ff6b6b) for stopped
- **Current Value**: 6 agents
- **Size**: 6 columns × 4 rows

#### 3. System Memory Usage (Stat - Top Right)
- **Query**: `(system_memory_used_kb / system_memory_total_kb) * 100`
- **Thresholds**: Green ≤60%, Yellow ≤85%, Red >85%
- **Unit**: Percentage
- **Size**: 6 columns × 4 rows

#### 4. System Load (1m) (Stat - Top Right-Most)
- **Query**: `system_load_average{period="1m"}`
- **Thresholds**: Green ≤2, Yellow ≤4, Red >4
- **Unit**: Load average
- **Size**: 6 columns × 4 rows

#### 5. Agent Status Over Time (Time Series - Middle Left)
- **Query**: `agent_up`
- **Legend Format**: `{{agent}}`
- **Display**: Line chart with legend on right
- **Legend Calculations**: Mean, Max
- **Size**: 12 columns × 8 rows

#### 6. Agent Memory Usage (Time Series - Middle Right)
- **Query**: `agent_memory_kb{agent_up="1"} * 1024`
- **Legend Format**: `{{agent}}`
- **Display**: Stacked area with legend on right
- **Unit**: Bytes
- **Size**: 12 columns × 8 rows

#### 7. Agent Details (Table - Bottom)
- **Queries**: 
  - Status: `agent_up`
  - CPU: `agent_cpu_percent`
  - Memory: `agent_memory_kb`
  - Uptime: `agent_uptime_seconds`
- **Columns**: Agent Name, Status, CPU %, Memory (KB), Uptime (s)
- **Transformations**: Merge, Organize by name
- **Status Colors**: Green for RUNNING, Red for STOPPED
- **Size**: 24 columns × 10 rows

---

## Professional Styling

### Color Scheme
Based on simondatalab.de infrastructure diagram:

| Element | Color | Hex | Usage |
|---------|-------|-----|-------|
| Background | Dark Navy | #0a0e27 | Dashboard background |
| Primary | Blue | #4e80fd | Charts, primary metrics |
| Accent | Teal | #00d4aa | Status indicators, healthy state |
| Warning | Orange | #ffa94d | Caution thresholds |
| Alert | Red | #ff6b6b | Critical state, failures |

### Panel Styling
- **Theme**: Dark mode (enabled)
- **Fill Opacity**: 15-20% for area charts
- **Line Width**: 2px for time series
- **Point Size**: 5px, shown on hover
- **Font**: System font stack (-apple-system, Inter, Segoe UI)
- **Borders**: Subtle dark theme styling

---

## Datasource Configuration

### Local Grafana Datasource

**Name**: Prometheus  
**UID**: `df3a70pr8c9ogb`  
**Type**: Prometheus  
**URL**: `http://prometheus:9090` (Docker DNS resolution)  
**Access**: Proxy  
**Scrape Interval**: 10s  
**Status**: ✅ Healthy

### Datasource Tests

#### Query Test - 10 Running Agents
```bash
curl -s -u "admin:PASSWORD" \
  "http://localhost:3000/api/datasources/proxy/1/api/v1/query?query=agents_running_total" | jq .
```

**Response**:
```json
{
  "status": "success",
  "data": {
    "resultType": "vector",
    "result": [
      {
        "metric": {
          "__name__": "agents_running_total",
          "instance": "172.17.0.1:9200",
          "job": "agent-monitoring"
        },
        "value": [1762413892.401, "10"]
      }
    ]
  }
}
```

---

## Deployment Notes

### Why Grafana 11.4.0?

**Version 12.2.0 Issue**: Datasource proxy broken - returned 400/404 errors despite correct configuration  
**Solution**: Downgraded to 11.4.0 (last stable version with working proxy)  
**Container**: `grafana_dashboard` running at localhost:3000

### Docker Networks

- **Prometheus Network**: `prometheus_default` (172.18.0.2)
- **Grafana Network**: `compose_toolbank-network` (172.22.0.3)
- **Connection**: Shared network allows Grafana → Prometheus communication via DNS (`prometheus:9090`)

### Firewall Configuration

```bash
# Open port 9200 for public agent exporter access
sudo ufw allow 9200/tcp

# Open port 9090 for Prometheus (if remote access needed)
sudo ufw allow 9090/tcp

# Verify rules
sudo ufw status numbered
```

---

## Troubleshooting Guide

### Issue: Dashboard Shows "No Data"

**Diagnosis**:
```bash
# Check if agent exporter is running
systemctl --user status agent-exporter.service

# Verify metrics are being collected
curl -s http://localhost:9200/metrics | grep agents_running_total

# Check Prometheus scrape target
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[]'
```

**Solutions**:
1. Restart agent exporter: `systemctl --user restart agent-exporter.service`
2. Verify Prometheus scraped data: `curl -s http://localhost:9090/api/v1/query?query=agents_running_total`
3. Reload dashboard in Grafana browser

### Issue: "Datasource UID Not Found" Error

**Cause**: Dashboard references wrong datasource UID  
**Solution**:
```bash
# Find correct datasource UID
curl -s -u "admin:PASSWORD" http://localhost:3000/api/datasources | jq '.[]'

# Update dashboard JSON
sed -i 's/OLD_UID/NEW_UID/g' grafana-agent-dashboard.json

# Redeploy dashboard
jq '{dashboard: ., overwrite: true}' grafana-agent-dashboard.json | \
  curl -s -X POST -H "Content-Type: application/json" \
  -u "admin:PASSWORD" -d @- http://localhost:3000/api/dashboards/db
```

### Issue: Agent Exporter Not Exposing Metrics

**Diagnosis**:
```bash
# Check port binding
ss -tlnp | grep 9200

# Check if process is running
ps aux | grep agent_exporter

# View service logs
journalctl --user -u agent-exporter.service -n 50
```

**Common Causes**:
- Service not started: `systemctl --user start agent-exporter.service`
- Wrong Python path: Update ExecStart in service file
- Port conflict: Change port in agent_exporter.py

---

## File Locations

### Configuration Files
- **Agent Exporter Service**: `~/.config/systemd/user/agent-exporter.service`
- **Agent Exporter Code**: `/home/simon/Learning-Management-System-Academy/.continue/scripts/agent_exporter.py`
- **Prometheus Config**: `/home/simon/Learning-Management-System-Academy/deploy/prometheus/prometheus.yml`
- **Dashboard JSON**: `/home/simon/Learning-Management-System-Academy/deploy/prometheus/grafana-agent-dashboard.json`

### Runtime Data
- **Prometheus Data**: Docker volume `prometheus_data`
- **Grafana Data**: Docker container `grafana_dashboard`
- **Service Logs**: `journalctl --user -u agent-exporter.service`

---

## Maintenance

### Regular Tasks

#### Daily
- Monitor dashboard for agent status changes
- Check for any alerts or anomalies

#### Weekly
- Review agent restart counts
- Check system resource trends

#### Monthly
- Validate all 16 agents are being monitored
- Archive old metrics (if needed)
- Review disk usage on Prometheus

### Backup

```bash
# Backup Prometheus data
docker exec prometheus tar -czf /prometheus/backup_$(date +%Y%m%d).tar.gz /prometheus

# Backup dashboard JSON
cp /home/simon/Learning-Management-System-Academy/deploy/prometheus/grafana-agent-dashboard.json \
   /home/simon/Learning-Management-System-Academy/deploy/prometheus/grafana-agent-dashboard.backup.json
```

---

## Performance Metrics

### Scrape Performance
- **Scrape Interval**: 10 seconds
- **Scrape Timeout**: 5 seconds  
- **Metrics per Agent**: ~5 per-agent metrics
- **Total Metrics**: ~89 across all agents + system metrics

### Dashboard Performance
- **Query Latency**: <500ms (local proxy)
- **Panel Load Time**: <1s per panel
- **Refresh Rate**: Auto-refresh available

### Resource Usage
- **Agent Exporter**: ~50-100MB memory
- **Prometheus**: ~200-300MB memory
- **Grafana**: ~400-500MB memory

---

## Version History

### v1.0 - Initial Release (Nov 6, 2025)
- ✅ Agent exporter created with 89 metrics
- ✅ Systemd service configured with auto-restart
- ✅ Prometheus job configured, scraping successfully
- ✅ Grafana 11.4.0 deployed with working datasource proxy
- ✅ 7-panel dashboard created with professional styling
- ✅ All 16 agents monitored (10 running, 6 stopped)
- ✅ Professional color scheme implemented
- ✅ Dashboard deployed and verified working
- ✅ Documentation completed

---

## Support & Contacts

**Dashboard Admin**: Simon Renauld  
**Documentation**: https://simondatalab.de  
**Repository**: /home/simon/Learning-Management-System-Academy

---

**Last Updated**: November 6, 2025  
**Status**: ✅ Production Ready

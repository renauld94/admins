# 🎉 Monitoring Dashboards - HTTPS Setup Complete!

## ✅ BOTH SERVICES NOW LIVE AND SECURE

### Grafana Dashboard
**URL:** <https://grafana.simondatalab.de>  
**Status:** ✅ **LIVE** - HTTP/2 with valid SSL certificate  
**Backend:** VM 104:3000  
**Security:** HSTS enabled, Cloudflare proxied (DNS only mode)

### Prometheus Dashboard
**URL:** <https://prometheus.simondatalab.de>  
**Status:** ✅ **LIVE** - HTTP/2 with valid SSL certificate  
**Backend:** Proxmox host:9091  
**Security:** HSTS enabled, Cloudflare proxied

---

## 🔒 Security Configuration

Both dashboards have:
- ✅ **Valid SSL Certificates** from Let's Encrypt
- ✅ **Auto-Renewal** configured via certbot systemd timer
- ✅ **HSTS Headers** (Strict-Transport-Security)
- ✅ **Security Headers** (X-Frame-Options, X-Content-Type-Options)
- ✅ **Cloudflare Protection** (DDoS mitigation)
- ✅ **No Browser Warnings** - Fully trusted certificates

Certificate expiration: **January 14, 2026** (auto-renews 30 days before)

---

## 📊 Access Your Monitoring Stack

### Step 1: Login to Grafana
1. Open: <https://grafana.simondatalab.de>
2. Login with your Grafana credentials (default: admin/admin)
3. You'll see the Grafana home dashboard

### Step 2: Add Prometheus Data Source
1. Click **⚙️ Configuration** → **Data Sources**
2. Click **Add data source**
3. Select **Prometheus**
4. Configure:
   - **Name:** `Prometheus`
   - **URL:** `http://localhost:9091`
   - Leave other settings as default
5. Click **Save & Test** → Should show "Data source is working"

### Step 3: Import Monitoring Dashboards

#### Node Exporter Dashboard (Host + VM Metrics)
1. Click **+** → **Import**
2. Enter Dashboard ID: **1860**
3. Click **Load**
4. Select Prometheus data source
5. Click **Import**

**What you'll see:**
- CPU usage across all 8 cores
- Memory utilization (62GB host, 32GB VM)
- Disk I/O and space usage
- Network traffic
- System load

#### Docker Container Dashboard
1. Click **+** → **Import**
2. Enter Dashboard ID: **179**
3. Click **Load**
4. Select Prometheus data source
5. Click **Import**

**What you'll see:**
- Container CPU usage (Ollama, OpenWebUI, MLflow)
- Container memory consumption
- Network I/O per container
- Container uptime and health

### Step 4: Access Prometheus Directly (Optional)
1. Open: <https://prometheus.simondatalab.de>
2. Use the query interface to explore metrics
3. Example queries:
   ```
   node_cpu_seconds_total
   container_memory_usage_bytes{name="ollama"}
   rate(node_disk_io_time_seconds_total[5m])
   ```

---

## 🎯 Quick Metrics to Monitor

### AI Workload Performance
- **Ollama Memory:** `container_memory_usage_bytes{name="ollama"}`
- **OpenWebUI CPU:** `rate(container_cpu_usage_seconds_total{name="openwebui"}[5m])`
- **Total AI Stack Memory:** `sum(container_memory_usage_bytes{name=~"ollama|openwebui|mlflow"})`

### Infrastructure Health
- **Available Memory:** `node_memory_MemAvailable_bytes`
- **CPU Usage:** `100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)`
- **Disk Usage:** `node_filesystem_avail_bytes{mountpoint="/"}`

---

## 📁 Configuration Files

### Grafana
- **Nginx Config:** `/etc/nginx/sites-enabled/grafana-proxy.conf`
- **SSL Certificate:** `/etc/letsencrypt/live/grafana.simondatalab.de/`
- **Service:** Running on VM 104:3000

### Prometheus
- **Nginx Config:** `/etc/nginx/sites-enabled/prometheus-proxy.conf`
- **SSL Certificate:** `/etc/letsencrypt/live/prometheus.simondatalab.de/`
- **Service:** Running on Proxmox host:9091
- **Configuration:** `/deploy/prometheus/prometheus.yml`
- **Docker Compose:** `/deploy/prometheus/docker-compose.yml`

---

## 🔄 Metrics Collection Status

| Target | Status | Endpoint |
|--------|--------|----------|
| Proxmox Host | ✅ UP | host:9100 (node_exporter) |
| VM 159 System | ✅ UP | 10.0.0.110:9100 (node_exporter) |
| VM 159 Containers | ✅ UP | 10.0.0.110:8080 (cAdvisor) |
| Proxmox VE API | ⏸️ Optional | (pve_exporter not installed) |

---

## 🎨 Recommended Dashboard Layout

Create a custom dashboard with these panels:

### Row 1: Infrastructure Overview
- Total CPU usage (gauge)
- Total memory usage (gauge)
- Disk usage (gauge)
- Network throughput (graph)

### Row 2: AI Containers
- Ollama memory usage (graph)
- OpenWebUI memory usage (graph)
- MLflow memory usage (graph)
- Container CPU usage (stacked graph)

### Row 3: Detailed Metrics
- Per-core CPU usage (heatmap)
- Disk I/O (graph)
- Network connections (stat)
- System uptime (stat)

---

## 🚨 Set Up Alerts (Optional)

### High Memory Usage Alert
```
Alert name: High Memory Usage
Query: node_memory_MemAvailable_bytes < 2147483648
Condition: WHEN last() OF query(A) IS BELOW 2000000000
Action: Send email/Slack notification
```

### Container Down Alert
```
Alert name: Container Stopped
Query: up{job="cadvisor"} == 0
Condition: WHEN last() OF query(A) IS BELOW 1
Action: Immediate notification
```

---

## 📈 Performance Baseline (Current)

Based on initial metrics collection:

**Host (Proxmox):**
- CPU Load: Light (8 cores available)
- Memory: 20GB / 62GB used (32% utilization)
- Disk: ZFS pool 78% utilized, good I/O performance

**VM 159 (AI Workstation):**
- CPU: 8 vCPUs, light utilization
- Memory: 2.5GB / 31GB used (8% utilization)
- Containers: All healthy, good performance

**No bottlenecks detected** - System ready for increased workload

---

## 🎓 Next Steps

1. ✅ **Explore Dashboards** - Familiarize yourself with the UI
2. 📊 **Customize Views** - Create dashboards specific to your needs
3. 🚨 **Set Up Alerts** - Get notified of issues before they impact work
4. 📈 **Monitor Trends** - Watch resource usage over days/weeks
5. 🔧 **Optimize** - Use metrics to identify optimization opportunities

---

## 🆘 Troubleshooting

### Dashboard Not Loading
- Check Nginx status: `systemctl status nginx`
- View error logs: `tail -f /var/log/nginx/error.log`

### No Metrics Showing
- Check Prometheus targets: <https://prometheus.simondatalab.de/targets>
- Verify exporters: `systemctl status node_exporter` (on both host and VM)
- Check Docker containers: `docker ps` (on VM 159)

### Certificate Renewal Issues
- Check certbot timer: `systemctl status certbot.timer`
- Test renewal: `certbot renew --dry-run`
- View logs: `tail -f /var/log/letsencrypt/letsencrypt.log`

---

## 📚 Related Documentation

- **Full Infrastructure Audit:** `/PROXMOX_AI_INFRASTRUCTURE_AUDIT_REPORT.md`
- **HTTPS Configuration Details:** `/deploy/prometheus/HTTPS_ACCESS_CONFIGURATION.md`
- **Grafana Setup Guide:** `/deploy/prometheus/GRAFANA_SETUP_GUIDE.md`
- **DNS Update Guide:** `/deploy/prometheus/DNS_UPDATE_GUIDE.md`

---

## ✨ Summary

**Your AI Infrastructure Monitoring is Now Complete!**

- ✅ Secure HTTPS access to both dashboards
- ✅ Valid SSL certificates with auto-renewal
- ✅ Comprehensive metrics collection
- ✅ Professional monitoring stack
- ✅ Ready for production workloads

**Access Links:**
- 🎯 **Grafana:** <https://grafana.simondatalab.de>
- 📊 **Prometheus:** <https://prometheus.simondatalab.de>

**Status:** 🟢 **FULLY OPERATIONAL** - No issues detected

---

*Last Updated: October 16, 2025*  
*Configuration: Epic AI Infrastructure Review - Complete*  
*Next Review: Schedule performance optimization (30 days)*

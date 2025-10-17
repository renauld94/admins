# 🎉 Grafana Dashboards Successfully Imported!

## ✅ Import Complete

All monitoring dashboards have been successfully imported into your Grafana instance!

### Imported Dashboards

1. **Node Exporter Full**
   - URL: https://grafana.simondatalab.de/d/rYdddlPWk/node-exporter-full
   - Shows: CPU, Memory, Disk, Network for Proxmox host and VM 159
   
2. **Docker and Host Monitoring**
   - URL: https://grafana.simondatalab.de/d/64nrElFmk/docker-and-host-monitoring-w-prometheus
   - Shows: Container metrics for Ollama, OpenWebUI, MLflow
   
3. **Docker and System Monitoring**
   - URL: https://grafana.simondatalab.de/d/8d00438c-2e15-4864-b343-4c2c428b6ba3/docker-and-system-monitoring
   - Shows: Comprehensive system and Docker metrics

## 🚀 Quick Access

**Main Dashboard Page:**
https://grafana.simondatalab.de/dashboards

**Prometheus Data Source:** ✅ Already configured at `http://localhost:9091`

## 📊 What You Can See Now

### System Metrics
- ✅ CPU usage across all 8 cores (Proxmox host)
- ✅ Memory utilization (62GB host, 32GB VM 159)
- ✅ Disk I/O and space usage
- ✅ Network traffic and throughput
- ✅ System load and uptime

### Container Metrics (AI Workloads)
- ✅ Ollama memory and CPU usage
- ✅ OpenWebUI memory and CPU usage
- ✅ MLflow memory and CPU usage
- ✅ Container network I/O
- ✅ Container health status

### Infrastructure Health
- ✅ ZFS pool usage and performance
- ✅ VM resource allocation
- ✅ Real-time performance monitoring

## 🎯 Recommended Next Steps

### 1. Set Your Home Dashboard
1. Click **⚙️ Preferences** (top right)
2. Under **Preferences** → **Home Dashboard**
3. Select: **Node Exporter Full**
4. Click **Save**

### 2. Create Alerts (Optional)
1. Open **Node Exporter Full** dashboard
2. Click on any panel (e.g., "Memory Available")
3. Click **Edit**
4. Go to **Alert** tab
5. Create alert rule:
   - **Condition:** `node_memory_MemAvailable_bytes < 2000000000`
   - **Action:** Email notification when memory < 2GB

### 3. Customize Panels
You can edit any panel to:
- Change time ranges
- Modify queries
- Add more metrics
- Change visualization types

### 4. Star Your Favorites
- Click the ⭐ icon on dashboards you use most
- They'll appear in your **Starred** list for quick access

## 📈 Key Metrics to Monitor

### For AI Workloads
```promql
# Ollama memory usage
container_memory_usage_bytes{name="ollama"}

# Total AI stack memory
sum(container_memory_usage_bytes{name=~"ollama|openwebui|mlflow"})

# Container CPU usage
rate(container_cpu_usage_seconds_total{name=~"ollama|openwebui|mlflow"}[5m])
```

### For Infrastructure
```promql
# Available memory
node_memory_MemAvailable_bytes

# CPU usage (%)
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Disk usage
node_filesystem_avail_bytes{mountpoint="/"}
```

## 🔍 Exploring Your Dashboards

### Node Exporter Full
**Best for:** Overall system health monitoring
- Top row: Quick stats (uptime, CPU, memory, disk)
- CPU section: Per-core usage, load average
- Memory section: Available, used, cached
- Disk section: I/O operations, space usage
- Network section: Traffic in/out

### Docker and Host Monitoring
**Best for:** Container-specific metrics
- Container CPU and memory per service
- Network I/O per container
- Container lifecycle (restarts, uptime)

### System Monitoring
**Best for:** Comprehensive overview
- Alternative views of system metrics
- Combined host + container views
- Storage and filesystem details

## 🎨 Customization Ideas

### Create a Custom AI Dashboard
1. Click **+ Create** → **Dashboard**
2. Add panels with these queries:
   - Ollama response time (if metrics available)
   - Model loading status
   - Request rate to OpenWebUI
   - MLflow experiment tracking

### Organize by Folders
1. Create folders: "Infrastructure", "AI Workloads", "Alerts"
2. Move dashboards into appropriate folders
3. Keep related dashboards together

## 📱 Mobile Access

Grafana is mobile-responsive!
- Access on phone: https://grafana.simondatalab.de
- Login with your credentials
- View dashboards on the go

## 🆘 Troubleshooting

### "No data" in panels
- **Wait:** Metrics collection needs 1-2 minutes
- **Check:** Prometheus targets at https://prometheus.simondatalab.de/targets
- **Verify:** All targets show "UP" status

### Panels showing errors
- **Check datasource:** Configuration → Data Sources → Prometheus
- **Test connection:** Click "Save & Test"
- **Verify URL:** Should be `http://localhost:9091`

### Can't see container metrics
- **Verify cAdvisor:** Running on VM 159 (docker ps)
- **Check Prometheus:** Scraping cAdvisor target
- **Wait:** Initial scrape interval is 30 seconds

## 🎓 Learning Resources

### Prometheus Query Language (PromQL)
- Basic syntax: `metric_name{label="value"}`
- Rate calculation: `rate(metric[5m])`
- Aggregation: `sum(metric) by (label)`

### Common Functions
- `rate()` - Calculate per-second rate
- `increase()` - Total increase over time range
- `sum()` - Sum across dimensions
- `avg()` - Average across dimensions

## 📊 Dashboard URLs Summary

| Dashboard | URL |
|-----------|-----|
| All Dashboards | https://grafana.simondatalab.de/dashboards |
| Node Exporter | https://grafana.simondatalab.de/d/rYdddlPWk/node-exporter-full |
| Docker Monitoring | https://grafana.simondatalab.de/d/64nrElFmk/docker-and-host-monitoring-w-prometheus |
| System Monitoring | https://grafana.simondatalab.de/d/8d00438c-2e15-4864-b343-4c2c428b6ba3/docker-and-system-monitoring |
| Prometheus | https://prometheus.simondatalab.de |

---

## 🎉 You're All Set!

Your complete AI infrastructure monitoring stack is now operational:

✅ **Prometheus** - Collecting metrics from all sources  
✅ **Grafana** - Visualizing with professional dashboards  
✅ **Node Exporter** - Host and VM system metrics  
✅ **cAdvisor** - Container resource metrics  
✅ **HTTPS** - Secure access with valid SSL certificates  
✅ **Dashboards** - 3 pre-built dashboards ready to use  

**Start exploring:** https://grafana.simondatalab.de/dashboards

Enjoy monitoring your AI infrastructure! 🚀

---

*Last Updated: October 16, 2025*  
*Status: Fully Operational*  
*Next: Explore dashboards and set up alerts*

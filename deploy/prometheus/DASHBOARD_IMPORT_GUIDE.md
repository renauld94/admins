# Grafana Dashboard Import - Quick Guide

## Automated Dashboard Import

I've created a script that will automatically:
1. ✅ Configure Prometheus data source in Grafana
2. ✅ Import Node Exporter Full dashboard (ID: 1860)
3. ✅ Import Docker Container dashboard (ID: 179)
4. ✅ Import System Monitoring dashboard (ID: 893)
5. ✅ Create custom AI Infrastructure dashboard

## How to Run

```bash
cd /home/simon/Learning-Management-System-Academy/deploy/prometheus

# Install required package if needed
pip install requests

# Run the import script
python3 import_grafana_dashboards.py
```

You'll be prompted for your Grafana admin password.

**Default credentials:**
- Username: `admin`
- Password: `admin` (or what you changed it to on first login)

## What the Script Does

### 1. Connects to Grafana
- Checks if Grafana is accessible at https://grafana.simondatalab.de
- Authenticates with admin credentials

### 2. Configures Prometheus Data Source
- Creates "Prometheus" datasource pointing to http://localhost:9091
- Sets it as default data source
- Tests the connection

### 3. Imports Pre-Built Dashboards

#### Node Exporter Full (ID: 1860)
**Shows:**
- CPU usage (all 8 cores)
- Memory utilization (host: 62GB, VM: 32GB)
- Disk I/O and space
- Network traffic
- System load and uptime

#### Docker Container Metrics (ID: 179)
**Shows:**
- Container CPU usage (Ollama, OpenWebUI, MLflow)
- Container memory consumption
- Network I/O per container
- Container health status

#### System Monitoring (ID: 893)
**Shows:**
- Comprehensive host metrics
- Docker container overview
- Resource allocation

### 4. Creates Custom AI Dashboard
**Shows:**
- Ollama memory usage graph
- OpenWebUI memory usage graph
- Total AI stack memory (stat panel)
- Container CPU usage (all AI services)

## Manual Import (Alternative)

If you prefer to import manually:

1. **Login to Grafana:** https://grafana.simondatalab.de
2. **Add Data Source:**
   - Click ⚙️ → Data Sources → Add data source
   - Select Prometheus
   - URL: `http://localhost:9091`
   - Click "Save & Test"

3. **Import Dashboards:**
   - Click + → Import
   - Enter dashboard ID (1860, 179, or 893)
   - Select "Prometheus" data source
   - Click Import

## Expected Output

```
🚀 Grafana Dashboard Auto-Import
============================================================

✅ Grafana is accessible

📊 Creating Prometheus datasource...
✅ Prometheus datasource created successfully
   Datasource UID: abc123...
   Datasource ID: 1

🧪 Testing Prometheus connection...
✅ Prometheus datasource is working

📥 Importing dashboard: Node Exporter Full (ID: 1860)
✅ Dashboard imported successfully
   URL: https://grafana.simondatalab.de/d/rYdddlPWk/node-exporter-full

📥 Importing dashboard: Docker Container & Host Metrics (ID: 179)
✅ Dashboard imported successfully
   URL: https://grafana.simondatalab.de/d/pMEd7m0Mz/docker-and-system-monitoring

📥 Importing dashboard: Docker and System Monitoring (ID: 893)
✅ Dashboard imported successfully
   URL: https://grafana.simondatalab.de/d/...

📊 Creating custom AI Infrastructure dashboard...
✅ Custom AI dashboard created
   URL: https://grafana.simondatalab.de/d/...

============================================================
🎉 Dashboard import complete!
   Successfully imported: 3/3 dashboards

📊 Access your dashboards at:
   https://grafana.simondatalab.de/dashboards
```

## After Import

1. **Browse Dashboards:**
   - Go to https://grafana.simondatalab.de/dashboards
   - You'll see all imported dashboards listed

2. **Set Default Dashboard:**
   - Click ⚙️ → Preferences
   - Set "Home Dashboard" to your preferred dashboard

3. **Customize:**
   - Edit panels to focus on your specific metrics
   - Create alerts for critical thresholds
   - Organize into folders

## Troubleshooting

### Authentication Failed
- Check your admin password
- Default is `admin` / `admin` (change on first login)
- Reset password: SSH to VM 104, run `grafana-cli admin reset-admin-password newpassword`

### Dashboard Import Failed
- Check Prometheus is running: `curl http://localhost:9091`
- Verify datasource connection in Grafana UI
- Try manual import as fallback

### No Data Showing
- Wait 1-2 minutes for metrics to collect
- Check Prometheus targets: https://prometheus.simondatalab.de/targets
- Verify exporters are running on host and VM 159

## Quick Start Command

```bash
cd /home/simon/Learning-Management-System-Academy/deploy/prometheus
python3 import_grafana_dashboards.py
```

Then open: https://grafana.simondatalab.de/dashboards

Enjoy your monitoring! 🎉

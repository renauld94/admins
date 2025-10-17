# Manual Dashboard Import Guide

Since your Grafana user account needs admin privileges to import dashboards via API, let's import them manually through the web interface. It's actually very easy!

## Step 1: Give Your Account Admin Permissions (Recommended)

You have two options:

### Option A: Use Your Current Account (Recommended)
1. Open Grafana: https://grafana.simondatalab.de
2. Login with: `sn.renauld@gmail.com` / your password
3. If you're already logged in, go to **⚙️ Administration** → **Users**
4. Find your user account and click **Edit**
5. Change **Role** to **Admin**
6. Click **Update**

### Option B: Reset Admin Password (if you have SSH access to VM 104)
If you need to reset the admin password, you would need SSH access to VM 104.

## Step 2: Add Prometheus Data Source

1. Click **⚙️ Configuration** (or **Connections**) → **Data Sources**
2. Click **Add data source**
3. Select **Prometheus**
4. Configure:
   - **Name:** `Prometheus`
   - **URL:** `http://localhost:9091`
   - **HTTP Method:** POST
   - Leave other settings as default
5. Click **Save & Test**
6. You should see: "Data source is working ✅"

## Step 3: Import Dashboard #1 - Node Exporter Full

1. Click **+** (Plus icon) → **Import dashboard** (or go to **Dashboards** → **Import**)
2. Enter dashboard ID: **1860**
3. Click **Load**
4. You'll see preview: "Node Exporter Full"
5. Configure:
   - **Name:** Keep as is (or rename if you want)
   - **Folder:** General (or create a new folder)
   - **Prometheus:** Select your Prometheus data source
6. Click **Import**

**What you'll see:**
- CPU usage across all cores
- Memory utilization
- Disk I/O and space
- Network traffic
- System load, uptime

## Step 4: Import Dashboard #2 - Docker Containers

1. Click **+** → **Import dashboard**
2. Enter dashboard ID: **179**
3. Click **Load**
4. Configure:
   - **Prometheus:** Select your Prometheus data source
5. Click **Import**

**What you'll see:**
- Container CPU and memory usage
- Network I/O per container
- Ollama, OpenWebUI, MLflow metrics

## Step 5: Import Dashboard #3 - System Monitoring (Optional)

1. Click **+** → **Import dashboard**
2. Enter dashboard ID: **893**
3. Click **Load**
4. Configure:
   - **Prometheus:** Select your Prometheus data source
5. Click **Import**

**What you'll see:**
- Comprehensive system and Docker metrics
- Alternative view to the other dashboards

## Step 6: Create Custom AI Dashboard (Optional)

If you want a custom dashboard focused on your AI workloads:

1. Click **+** → **Dashboard**
2. Click **Add visualization**
3. Select **Prometheus** data source
4. Add these queries one by one:

### Panel 1: Ollama Memory
- **Query:** `container_memory_usage_bytes{name="ollama"}`
- **Legend:** Ollama Memory
- **Type:** Time series (line graph)

### Panel 2: OpenWebUI Memory
- **Query:** `container_memory_usage_bytes{name="openwebui"}`
- **Legend:** OpenWebUI Memory

### Panel 3: Total AI Stack Memory
- **Query:** `sum(container_memory_usage_bytes{name=~"ollama|openwebui|mlflow"})`
- **Type:** Stat (single number)

### Panel 4: Container CPU
- **Query:** `rate(container_cpu_usage_seconds_total{name=~"ollama|openwebui|mlflow"}[5m])`
- **Legend:** {{name}}
- **Type:** Time series

5. Click **Save dashboard**
6. Name it: "AI Infrastructure Monitoring"

## Quick Reference - Dashboard IDs

| ID   | Dashboard Name | What It Shows |
|------|---------------|---------------|
| 1860 | Node Exporter Full | Host & VM CPU, memory, disk, network |
| 179  | Docker Containers | Container resource usage |
| 893  | System Monitoring | Comprehensive overview |

## Common Prometheus Queries

Once dashboards are imported, you can explore these queries:

```promql
# Available memory
node_memory_MemAvailable_bytes

# CPU usage (100% - idle)
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Container memory by name
container_memory_usage_bytes{name="ollama"}

# All AI containers memory
sum(container_memory_usage_bytes{name=~"ollama|openwebui|mlflow"})

# Disk usage
node_filesystem_avail_bytes{mountpoint="/"}
```

## Troubleshooting

### "No data" in panels
- Wait 1-2 minutes for Prometheus to scrape metrics
- Check Prometheus targets: https://prometheus.simondatalab.de/targets
- All should show "UP" status

### "Data source is not working"
- Verify Prometheus is running: `curl http://localhost:9091`
- Check the URL in data source settings: `http://localhost:9091`

### Can't see containers
- Make sure cAdvisor is running on VM 159
- Check Prometheus config includes cAdvisor target

## After Import

1. **Set Home Dashboard:**
   - Go to **⚙️ Preferences**
   - Set **Home Dashboard** to your most-used dashboard

2. **Create Alerts:**
   - Open any dashboard
   - Edit a panel
   - Go to **Alert** tab
   - Create alert rules (e.g., "High Memory Usage")

3. **Organize:**
   - Create folders for different categories
   - Move dashboards into folders
   - Star your favorite dashboards

---

**Time to complete:** ~5 minutes  
**Difficulty:** Easy - just copy/paste dashboard IDs!

Open Grafana now: https://grafana.simondatalab.de 🚀

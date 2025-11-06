# 📊 Import Agent Monitoring Dashboard to Grafana

## Quick Guide - 5 Minutes

Your dashboard JSON is ready at:
```
~/Learning-Management-System-Academy/deploy/prometheus/grafana-agent-dashboard.json
```

---

## Method 1: Web UI Import (Recommended)

### Step-by-Step:

1. **Open Grafana**
   - URL: https://grafana.simondatalab.de
   - Login with your credentials

2. **Navigate to Import**
   - Click the **"+"** button in the left sidebar
   - Select **"Import dashboard"**
   - OR go directly to: https://grafana.simondatalab.de/dashboard/import

3. **Upload JSON File**
   - Click **"Upload JSON file"** button
   - Select: `~/Learning-Management-System-Academy/deploy/prometheus/grafana-agent-dashboard.json`
   - OR drag and drop the file

4. **Configure Dashboard**
   The form will auto-fill with:
   - **Name:** Agent Monitoring
   - **UID:** agent-monitoring
   - **Folder:** General (or choose your folder)
   
   **Important:** Select the **Prometheus datasource**
   - Dropdown: "Select a Prometheus data source"
   - Choose: **Prometheus** (your existing datasource)

5. **Import**
   - Click the **"Import"** button
   - Dashboard will be created instantly!

6. **View Dashboard**
   - URL: https://grafana.simondatalab.de/d/agent-monitoring
   - You should see 7 panels with live data

---

## Method 2: Copy-Paste JSON (Alternative)

If file upload doesn't work:

1. **Copy JSON content**
   ```bash
   cat ~/Learning-Management-System-Academy/deploy/prometheus/grafana-agent-dashboard.json
   ```
   Copy the entire output

2. **Paste in Grafana**
   - Go to: https://grafana.simondatalab.de/dashboard/import
   - Paste JSON into the text box
   - Click **"Load"**
   - Select Prometheus datasource
   - Click **"Import"**

---

## Method 3: Command Line (Advanced)

If you have Grafana API access:

```bash
# Set your Grafana API key
GRAFANA_URL="https://grafana.simondatalab.de"
GRAFANA_API_KEY="your-api-key-here"

# Import dashboard via API
curl -X POST "$GRAFANA_URL/api/dashboards/db" \
  -H "Authorization: Bearer $GRAFANA_API_KEY" \
  -H "Content-Type: application/json" \
  -d @~/Learning-Management-System-Academy/deploy/prometheus/grafana-agent-dashboard.json
```

---

## Troubleshooting

### Issue: "Dashboard not found" after import

**Solution:** The dashboard imports with UID `agent-monitoring`. Access it at:
```
https://grafana.simondatalab.de/d/agent-monitoring
```

### Issue: "No data" in panels

**Check:**
1. Prometheus datasource is connected:
   ```bash
   curl 'http://localhost:9090/api/v1/query?query=agents_running_total'
   ```

2. Prometheus is scraping agent-monitoring target:
   ```bash
   curl http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | select(.labels.job=="agent-monitoring")'
   ```

3. Agent exporter is running:
   ```bash
   systemctl --user status agent-exporter.service
   curl http://localhost:9200/metrics | grep agent_up
   ```

### Issue: "Invalid datasource"

**Solution:** 
1. Go to: https://grafana.simondatalab.de/datasources
2. Find your Prometheus datasource
3. Note its exact name
4. During import, select that exact datasource name
5. Common names: "Prometheus", "prometheus", "Prometheus-1"

### Issue: Can't find Import option

**Navigation:**
- **Grafana 10.x:** Click **"+"** → **"Import dashboard"**
- **Grafana 9.x:** **Dashboards** → **"Import"**
- **Direct URL:** https://grafana.simondatalab.de/dashboard/import

---

## What You'll See After Import

### Dashboard Panels (7 total):

1. **Running Agents** (Stat)
   - Shows: Current count of running agents
   - Color: Green
   - Current: 10 agents

2. **Stopped Agents** (Stat)
   - Shows: Current count of stopped agents
   - Color: Red if > 0
   - Current: 6 agents

3. **System Memory Usage** (Stat)
   - Shows: Memory percentage
   - Thresholds: Green < 50%, Yellow < 80%, Red > 80%

4. **System Load (1m)** (Stat)
   - Shows: 1-minute load average
   - Thresholds: Green < 3, Yellow < 5, Red > 5

5. **Agent Status Over Time** (Time Series)
   - Shows: Line graph of agent_up for all 16 agents
   - Updates: Real-time

6. **Agent Memory Usage** (Time Series)
   - Shows: Stacked area graph of memory by agent
   - Units: KB

7. **Agent Details** (Table)
   - Columns: Agent | Status | CPU % | Memory (KB) | Uptime
   - Status: Color-coded (green=running, red=stopped)

---

## Dashboard Features

### Time Controls
- Default range: Last 6 hours
- Adjustable: Use time picker in top-right
- Refresh: Auto-refresh every 30s (configurable)

### Filters
- All panels use the same Prometheus datasource
- No template variables needed (showing all agents)

### Interactions
- Click panel titles to expand
- Hover over graphs for details
- Click legend items to toggle series

---

## Quick Verification

After importing, verify everything works:

1. **Check Panel Data**
   - All 7 panels should show data immediately
   - If "No data", wait 10 seconds (scrape interval)

2. **Test Real-Time Updates**
   - Stop an agent: `systemctl --user stop agent-portfolio.service`
   - Watch dashboard: Stopped count should increase
   - Start agent: `systemctl --user start agent-portfolio.service`
   - Watch dashboard: Running count should increase

3. **Check Metrics**
   - Panel 7 (table) should show all 16 agents
   - Status column should be color-coded
   - Memory and CPU values should be populated

---

## Access URLs Summary

| Component | URL |
|-----------|-----|
| **Grafana Home** | https://grafana.simondatalab.de |
| **Import Dashboard** | https://grafana.simondatalab.de/dashboard/import |
| **Agent Dashboard** | https://grafana.simondatalab.de/d/agent-monitoring |
| **Datasources** | https://grafana.simondatalab.de/datasources |
| **Prometheus UI** | http://localhost:9090 |
| **Agent Exporter** | http://localhost:9200/metrics |

---

## Alternative: Manual Dashboard Creation

If import fails completely, you can recreate manually:

### 1. Create New Dashboard
- Go to: https://grafana.simondatalab.de/dashboard/new

### 2. Add Stat Panel - Running Agents
- Query: `agents_running_total`
- Visualization: Stat
- Color: Green

### 3. Add Stat Panel - Stopped Agents
- Query: `agents_total - agents_running_total`
- Visualization: Stat
- Color: Red threshold > 0

### 4. Add Time Series - Agent Status
- Query: `agent_up`
- Legend: `{{agent}}`
- Visualization: Time series

(Repeat for all 7 panels - see dashboard JSON for exact config)

---

## Success Checklist

- [ ] Grafana opened at https://grafana.simondatalab.de
- [ ] Navigated to Import Dashboard
- [ ] Uploaded grafana-agent-dashboard.json
- [ ] Selected Prometheus datasource
- [ ] Clicked Import
- [ ] Dashboard created successfully
- [ ] Accessed at https://grafana.simondatalab.de/d/agent-monitoring
- [ ] All 7 panels showing data
- [ ] Real-time updates working

---

## Support

If you encounter issues:

1. **Check Prometheus Connection**
   ```bash
   curl 'http://localhost:9090/api/v1/query?query=agents_running_total'
   ```

2. **Check Agent Exporter**
   ```bash
   systemctl --user status agent-exporter.service
   ```

3. **View Full Dashboard JSON**
   ```bash
   cat ~/Learning-Management-System-Academy/deploy/prometheus/grafana-agent-dashboard.json | jq
   ```

4. **Check Grafana Logs** (if you have access)
   ```bash
   docker logs grafana
   # or
   journalctl -u grafana-server -f
   ```

---

**Built with precision | Simon Data Lab | Enterprise ML Systems**

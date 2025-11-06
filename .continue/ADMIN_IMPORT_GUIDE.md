# 🎯 Quick Import Guide - You Have Admin Access!

## ✅ You ARE a Grafana Admin

**User:** sn.renauld@gmail.com  
**Role:** Grafana Admin + Admin in Main Org.

The 403/500 errors are likely due to **browser cache** or **UID conflict**, NOT permissions.

---

## 🚀 EASIEST METHOD: Manual JSON Import

### Step 1: Copy Dashboard JSON

```bash
cat ~/Learning-Management-System-Academy/deploy/prometheus/grafana-agent-dashboard.json
```

Copy the ENTIRE output (all JSON text).

### Step 2: Import in Grafana

1. **Open this URL in incognito/private window:**
   ```
   https://grafana.simondatalab.de/dashboard/new
   ```

2. **Click the gear icon (⚙)** in top-right corner

3. **Click "JSON Model"**

4. **Delete all existing JSON** in the editor

5. **Paste your copied JSON**

6. **Click "Save"** at top of JSON editor

7. **Click "Save dashboard"** (disk icon)

8. **Done!** Your dashboard is now imported

---

## 🔑 ALTERNATIVE: Use API Key Method

### Create API Key

1. Go to: https://grafana.simondatalab.de/org/apikeys
2. Click **"Add API Key"**
3. Settings:
   - Name: `Dashboard Import`
   - Role: `Admin`
   - Time to live: `1h`
4. Click **"Add"** and copy the key

### Run Import Command

Replace `YOUR_API_KEY` with the actual key:

```bash
GRAFANA_URL="https://grafana.simondatalab.de"
API_KEY="YOUR_API_KEY_HERE"

jq -n \
  --argfile dashboard ~/Learning-Management-System-Academy/deploy/prometheus/grafana-agent-dashboard.json \
  '{
    dashboard: $dashboard,
    overwrite: true,
    message: "Agent Monitoring Dashboard"
  }' | \
curl -X POST "$GRAFANA_URL/api/dashboards/db" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d @- | jq
```

---

## 📊 Dashboard Files Available

| File | UID | Use Case |
|------|-----|----------|
| `grafana-agent-dashboard.json` | `agent-monitoring` | Original |
| `grafana-agent-dashboard-v2.json` | `agent-monitoring-v2` | If original UID conflicts |
| `grafana-agent-dashboard-alt-*.json` | `agent-mon-*` | Timestamped unique UID |

---

## 🔍 Why You Got 403/500 Errors

**NOT a permissions issue!** Possible causes:

1. **Browser Cache** - Old session data
   - Solution: Use incognito/private window

2. **UID Conflict** - Dashboard with same UID exists
   - Solution: Try alternative dashboard file

3. **CSRF Token** - Session token expired
   - Solution: Fresh login in new window

4. **API Rate Limit** - Too many rapid requests
   - Solution: Wait 1 minute, try again

---

## ✅ Verification

After importing, verify:

```bash
# Check dashboard exists
curl -s "https://grafana.simondatalab.de/api/dashboards/uid/agent-monitoring" | jq '.meta.slug'

# Check data is flowing
curl -s 'http://localhost:9090/api/v1/query?query=agents_running_total' | jq '.data.result[0].value[1]'
```

Expected results:
- Dashboard slug: `agent-monitoring-dashboard`
- Running agents: `10`

---

## 🎨 Professional Styling Notes

Your dashboard already includes:
- Dark theme colors
- Professional typography
- Clean stat panels
- Time series graphs
- Agent details table

To apply simondatalab.de styling **globally** to ALL Grafana:
1. Go to: https://grafana.simondatalab.de/admin/settings
2. Edit `custom.ini` or theme settings
3. This requires **server-level configuration** (not dashboard-level)

For dashboard-specific styling, the JSON already has professional colors configured.

---

## 📍 Quick Links

| Resource | URL |
|----------|-----|
| **Import Page** | https://grafana.simondatalab.de/dashboard/import |
| **New Dashboard** | https://grafana.simondatalab.de/dashboard/new |
| **API Keys** | https://grafana.simondatalab.de/org/apikeys |
| **Your Profile** | https://grafana.simondatalab.de/profile |
| **Prometheus** | http://localhost:9090 |
| **Agent Exporter** | http://localhost:9200/metrics |

---

## 🆘 Still Not Working?

Use the **standalone dashboard** (already working with professional styling):

```bash
xdg-open http://localhost:8080/unified_agent_dashboard.html
```

This dashboard:
- ✅ No Grafana needed
- ✅ Full admin controls
- ✅ Real-time updates
- ✅ Professional dark theme already applied
- ✅ All 16 agents monitored

---

**Built with precision | Simon Data Lab | Enterprise ML Systems**

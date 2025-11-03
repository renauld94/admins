# 🚀 Proxmox AI Homelab Integration: MCP + Skywork AI Recommendations

**Date:** November 3, 2025  
**Infrastructure:** Proxmox VE (136.243.155.166), VM 159 (ubuntuai), OpenWebUI, Ollama  
**Reference Projects:**  
- Your ProxmoxMCP: https://github.com/canvrno/ProxmoxMCP  
- Skywork AI Guide: https://skywork.ai/skypage/en/proxmox-ai-homelab/1980807848596254720

---

## 📋 Executive Summary

This document provides **actionable recommendations** for integrating **Model Context Protocol (MCP)** with your existing Proxmox infrastructure and implementing **AI-powered infrastructure management** based on Skywork AI's best practices.

### Current State
✅ **Working Infrastructure:**
- Proxmox Host: 136.243.155.166:2222 (vmbr0 public, vmbr1 10.0.0.0/24 internal)
- VM 159 (ubuntuai): 10.0.0.110 - Docker (OpenWebUI, Ollama), MCP Node.js (port 3002)
- Container 150 (portfolio): 10.0.0.150:80
- Cloudflare Tunnel: 9b0c5c71-3235-4725-a91c-c687605a9ae3 (h2mux protocol)
- OpenWebUI: https://openwebui.simondatalab.de ✅ ONLINE (HTTP 200)
- MCP Endpoint: https://mcp.simondatalab.de ⚠️ Error 1033 (route pending)

### Proposed Enhancement
🎯 **Goal:** Transform your infrastructure into an **AI-native, conversation-driven** homelab using ProxmoxMCP + Skywork AI architecture patterns.

---

## 🏗️ Architecture Overview

### Phase 1: ProxmoxMCP Server Deployment (Week 1)

```
┌─────────────────────────────────────────────────────────────────┐
│  AI Client Layer (VS Code / Cursor / Claude Desktop)           │
│  ├─ GitHub Copilot (current)                                   │
│  ├─ Continue Extension (proposed)                              │
│  └─ Claude Desktop (future)                                    │
└──────────────────┬──────────────────────────────────────────────┘
                   │ MCP Protocol (stdio)
┌──────────────────▼──────────────────────────────────────────────┐
│  ProxmoxMCP Server (New)                                        │
│  ├─ Location: VM 159 or new VM 161                             │
│  ├─ Port: 3003 (dedicated MCP server)                          │
│  ├─ Python 3.10+ with venv                                     │
│  └─ Tools: get_nodes, get_vms, execute_command, get_storage    │
└──────────────────┬──────────────────────────────────────────────┘
                   │ Proxmox API (HTTPS:8006)
┌──────────────────▼──────────────────────────────────────────────┐
│  Proxmox VE Host (136.243.155.166)                              │
│  ├─ API Token: mcp-token@pve (to be created)                   │
│  ├─ Permissions: PVEVMAdmin, PVEAuditor                        │
│  └─ SSL: Self-signed (verify_ssl: false in config)             │
└──────────────────┬──────────────────────────────────────────────┘
                   │ Manages
┌──────────────────▼──────────────────────────────────────────────┐
│  VMs & Containers                                               │
│  ├─ VM 159 (ubuntuai): Docker, OpenWebUI, Ollama, MLflow       │
│  ├─ Container 150 (portfolio): Nginx                           │
│  ├─ VM 200 (nextcloud): Nextcloud                              │
│  └─ Future: Auto-provisioned CI/CD, GPU training VMs           │
└─────────────────────────────────────────────────────────────────┘
```

### Phase 2: Skywork AI Pattern Integration (Week 2-3)

Based on Skywork's **3 Powerful Use Cases**, implement:

1. **AI-Powered Homelab Admin**
   - Natural language commands: "Check health of Proxmox cluster"
   - Auto-restart failed services
   - Proactive monitoring and alerts

2. **Automated CI/CD Environment Provisioning**
   - GitHub Actions triggers AI agent
   - AI clones template VM for each PR
   - Runs tests, reports results, destroys VM

3. **Dynamic AI/ML Workload Management**
   - Monitor job queue (Celery, RabbitMQ, or database)
   - Auto-start GPU VMs for training jobs
   - Shutdown when complete to save power

---

## 🔧 Step-by-Step Implementation

### Step 1: Create Proxmox API Token (10 minutes)

SSH to Proxmox and create dedicated API token:

```bash
# SSH to Proxmox
ssh -p 2222 root@136.243.155.166

# Create API token via CLI (alternative to web UI)
pveum user add mcp@pve --comment "MCP Server Account"
pveum role add MCPRole -privs "VM.Audit VM.Monitor VM.PowerMgmt VM.Console.Access Sys.Audit Sys.Console"
pveum aclmod / -user mcp@pve -role MCPRole

# Create token
pveum user token add mcp@pve mcp-token --privsep 0

# Save the output - YOU WILL ONLY SEE THIS ONCE!
# Example output:
# ┌──────────────┬──────────────────────────────────────┐
# │ key          │ value                                │
# ╞══════════════╪══════════════════════════════════════╡
# │ full-tokenid │ mcp@pve!mcp-token                    │
# ├──────────────┼──────────────────────────────────────┤
# │ info         │ {"privsep":0}                        │
# ├──────────────┼──────────────────────────────────────┤
# │ value        │ aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee │
# └──────────────┴──────────────────────────────────────┘
```

**Save these values:**
- Token ID: `mcp@pve!mcp-token`
- Token Secret: `aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee` (example - use YOUR actual value)

---

### Step 2: Deploy ProxmoxMCP Server on VM 159 (30 minutes)

```bash
# SSH to VM 159 (ubuntuai)
ssh -A -J root@136.243.155.166:2222 simonadmin@10.0.0.110

# Create MCP directory
mkdir -p ~/mcp-servers && cd ~/mcp-servers

# Clone your ProxmoxMCP repository
git clone https://github.com/canvrno/ProxmoxMCP.git
cd ProxmoxMCP

# Install uv package manager if not present
pip install uv

# Create virtual environment
uv venv
source .venv/bin/activate  # Linux/macOS

# Install dependencies
uv pip install -e ".[dev]"

# Create config directory
mkdir -p proxmox-config
cp config/config.example.json proxmox-config/config.json

# Edit configuration
nano proxmox-config/config.json
```

**Configuration File (`proxmox-config/config.json`):**

```json
{
  "proxmox": {
    "host": "136.243.155.166",
    "port": 8006,
    "verify_ssl": false,
    "service": "PVE"
  },
  "auth": {
    "user": "mcp@pve",
    "token_name": "mcp-token",
    "token_value": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
  },
  "logging": {
    "level": "INFO",
    "format": "%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    "file": "proxmox_mcp.log"
  }
}
```

**Test the server:**

```bash
# Activate virtual environment
source ~/mcp-servers/ProxmoxMCP/.venv/bin/activate

# Set config path and run
PROXMOX_MCP_CONFIG="proxmox-config/config.json" python -m proxmox_mcp.server

# You should see:
# INFO - Successfully connected to Proxmox API
# INFO - Starting MCP server...
```

Press `Ctrl+C` to stop for now.

---

### Step 3: Create Systemd Service for ProxmoxMCP (15 minutes)

Make ProxmoxMCP run as a persistent service:

```bash
# Create systemd service file
sudo nano /etc/systemd/system/proxmoxmcp.service
```

**Service file content:**

```ini
[Unit]
Description=Proxmox MCP Server
After=network.target docker.service
Wants=network-online.target

[Service]
Type=simple
User=simonadmin
WorkingDirectory=/home/simonadmin/mcp-servers/ProxmoxMCP
Environment="PROXMOX_MCP_CONFIG=/home/simonadmin/mcp-servers/ProxmoxMCP/proxmox-config/config.json"
Environment="PYTHONPATH=/home/simonadmin/mcp-servers/ProxmoxMCP/src"
ExecStart=/home/simonadmin/mcp-servers/ProxmoxMCP/.venv/bin/python -m proxmox_mcp.server
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

**Enable and start:**

```bash
# Reload systemd
sudo systemctl daemon-reload

# Enable on boot
sudo systemctl enable proxmoxmcp

# Start now
sudo systemctl start proxmoxmcp

# Check status
sudo systemctl status proxmoxmcp

# View logs
sudo journalctl -u proxmoxmcp -f
```

---

### Step 4: Integrate with VS Code (20 minutes)

Configure VS Code to use ProxmoxMCP server.

**Generate configuration:**

```bash
cd ~/mcp-servers/ProxmoxMCP

# Generate MCP settings JSON with absolute paths
python -c "import os; print(f'''{{
  \"mcpServers\": {{
    \"proxmox\": {{
      \"command\": \"{os.path.abspath('.venv/bin/python')}\",
      \"args\": [\"-m\", \"proxmox_mcp.server\"],
      \"cwd\": \"{os.getcwd()}\",
      \"env\": {{
        \"PYTHONPATH\": \"{os.path.abspath('src')}\",
        \"PROXMOX_MCP_CONFIG\": \"{os.path.abspath('proxmox-config/config.json')}\"
      }}
    }}
  }}
}}''')"
```

**Add to VS Code settings:**

1. Open VS Code on your local machine
2. Open Command Palette (`Ctrl+Shift+P`)
3. Search for "Preferences: Open User Settings (JSON)"
4. Add the MCP server configuration (paste output from above)
5. Restart VS Code

**Alternative: Configure in Continue Extension:**

If using Continue extension, edit `~/.continue/config.json`:

```json
{
  "mcpServers": {
    "proxmox": {
      "command": "/home/simonadmin/mcp-servers/ProxmoxMCP/.venv/bin/python",
      "args": ["-m", "proxmox_mcp.server"],
      "cwd": "/home/simonadmin/mcp-servers/ProxmoxMCP",
      "env": {
        "PYTHONPATH": "/home/simonadmin/mcp-servers/ProxmoxMCP/src",
        "PROXMOX_MCP_CONFIG": "/home/simonadmin/mcp-servers/ProxmoxMCP/proxmox-config/config.json"
      }
    }
  }
}
```

---

### Step 5: Test ProxmoxMCP Tools (15 minutes)

Now test the MCP tools via your AI client:

**Example Prompts to Test:**

1. **List all Proxmox nodes:**
   ```
   "Show me all Proxmox nodes in my cluster."
   ```
   Expected: AI calls `get_nodes` tool and displays node status

2. **Get VM details:**
   ```
   "List all virtual machines and containers."
   ```
   Expected: AI calls `get_vms` and `get_containers` tools

3. **Check specific node:**
   ```
   "What's the CPU and memory usage on the Proxmox host?"
   ```
   Expected: AI calls `get_node_status` with your node name

4. **Execute command in VM:**
   ```
   "In VM 159, run 'docker ps' and show me the output."
   ```
   Expected: AI calls `execute_vm_command` (requires QEMU Guest Agent)

5. **Check storage:**
   ```
   "How much storage is available on my Proxmox server?"
   ```
   Expected: AI calls `get_storage` tool

---

## 🎯 Skywork AI Pattern Implementation

### Use Case 1: AI-Powered Homelab Admin

**Goal:** Natural language infrastructure management

**Implementation:**

1. **Create monitoring script** (`~/mcp-servers/homelab_monitor.py`):

```python
#!/usr/bin/env python3
"""
AI-Powered Homelab Monitor
Checks health of services and notifies AI agent of issues
"""
import requests
import subprocess
import json
from datetime import datetime

def check_openwebui():
    try:
        r = requests.get("https://openwebui.simondatalab.de", timeout=5)
        return r.status_code == 200
    except:
        return False

def check_mcp_endpoint():
    try:
        r = requests.get("http://10.0.0.110:3002", timeout=5)
        return "MCP" in r.text
    except:
        return False

def check_docker_services():
    try:
        result = subprocess.run(
            ["docker", "ps", "--format", "{{.Names}}: {{.Status}}"],
            capture_output=True, text=True
        )
        return result.stdout
    except:
        return "ERROR: Cannot check Docker"

def generate_report():
    report = {
        "timestamp": datetime.now().isoformat(),
        "services": {
            "openwebui": "UP" if check_openwebui() else "DOWN",
            "mcp_endpoint": "UP" if check_mcp_endpoint() else "DOWN",
            "docker": check_docker_services()
        }
    }
    return report

if __name__ == "__main__":
    print(json.dumps(generate_report(), indent=2))
```

2. **Create cron job:**

```bash
# Add to crontab
crontab -e

# Add this line (runs every 5 minutes)
*/5 * * * * /home/simonadmin/mcp-servers/homelab_monitor.py >> /var/log/homelab_monitor.log 2>&1
```

3. **AI Agent Integration:**

Now you can ask your AI:
- "Check the health of my homelab services"
- "My OpenWebUI is down - can you restart it?"
- "What Docker containers are running?"

The AI will use ProxmoxMCP to execute commands and fix issues.

---

### Use Case 2: Automated CI/CD Environment Provisioning

**Goal:** Auto-create test VMs for each GitHub PR

**Implementation:**

1. **Create VM template** (one-time setup):

```bash
# SSH to Proxmox
ssh -p 2222 root@136.243.155.166

# Clone existing VM as template
qm clone 159 9000 --name ubuntu-test-template
qm template 9000

# Verify
qm list | grep template
```

2. **GitHub Actions workflow** (`.github/workflows/test-pr.yml`):

```yaml
name: Test PR in Proxmox VM

on:
  pull_request:
    branches: [ main, master ]

jobs:
  test-in-vm:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger AI Agent to provision VM
        env:
          MCP_ENDPOINT: ${{ secrets.MCP_ENDPOINT }}
          PR_NUMBER: ${{ github.event.pull_request.number }}
        run: |
          curl -X POST "$MCP_ENDPOINT/provision-vm" \
            -H "Content-Type: application/json" \
            -d "{\"pr_number\": \"$PR_NUMBER\", \"repo\": \"$GITHUB_REPOSITORY\"}"

      - name: Wait for AI to complete tests
        run: sleep 60

      - name: Get test results
        run: |
          curl "$MCP_ENDPOINT/test-results/$PR_NUMBER"
```

3. **AI Agent receives request** and:
   - Clones template VM 9000
   - Starts the VM
   - Installs code from PR
   - Runs tests
   - Reports results back to GitHub
   - Destroys VM

**Prompt to AI:**
```
"When a new PR is opened in my GitHub repo, clone VM template 9000, 
start it, run the test suite, and report results. Then destroy the VM."
```

---

### Use Case 3: Dynamic AI/ML Workload Management

**Goal:** Auto-start GPU VMs for training, shutdown when done

**Implementation:**

1. **Create job queue table** (PostgreSQL or SQLite):

```sql
CREATE TABLE ml_jobs (
    id SERIAL PRIMARY KEY,
    job_name VARCHAR(255),
    status VARCHAR(50),  -- 'pending', 'running', 'completed', 'failed'
    vm_id INTEGER,
    created_at TIMESTAMP DEFAULT NOW(),
    started_at TIMESTAMP,
    completed_at TIMESTAMP
);
```

2. **Job monitor script** (`~/mcp-servers/ml_job_monitor.py`):

```python
#!/usr/bin/env python3
"""
ML Job Monitor - Watches for new training jobs and provisions VMs
"""
import psycopg2
import time
import requests

def check_pending_jobs():
    conn = psycopg2.connect("dbname=mlflow user=postgres")
    cur = conn.cursor()
    cur.execute("SELECT id, job_name FROM ml_jobs WHERE status='pending'")
    return cur.fetchall()

def notify_ai_agent(job_id, job_name):
    # Call MCP endpoint to trigger AI
    requests.post("http://localhost:3003/start-training-vm", json={
        "job_id": job_id,
        "job_name": job_name
    })

while True:
    jobs = check_pending_jobs()
    for job_id, job_name in jobs:
        print(f"New job detected: {job_name}")
        notify_ai_agent(job_id, job_name)
    time.sleep(30)  # Check every 30 seconds
```

3. **AI Agent workflow:**
   - Receives notification of new job
   - Uses ProxmoxMCP to start GPU VM (e.g., VM 300)
   - Waits for VM to boot
   - Executes training script via `execute_vm_command`
   - Monitors progress
   - When training complete, shuts down VM
   - Updates job status to 'completed'

**Prompt to AI:**
```
"Monitor the ml_jobs table. When a new job appears, start VM 300 (GPU VM), 
run the training script inside it, and shut it down when complete to save power."
```

---

## 🔐 Security & Best Practices

### 1. API Token Permissions

**Principle of Least Privilege:**

Instead of full admin access, create limited role:

```bash
# Create custom role with minimal permissions
pveum role add MCPLimited -privs "VM.Audit VM.Monitor VM.PowerMgmt Sys.Audit"

# Assign to MCP user
pveum aclmod / -user mcp@pve -role MCPLimited
```

### 2. Network Segmentation

Create dedicated VLAN for AI/MCP services:

```bash
# On Proxmox, create VLAN 30 for AI services
# Edit /etc/network/interfaces
auto vmbr1.30
iface vmbr1.30 inet static
    address 10.0.30.1/24
    vlan-raw-device vmbr1
```

Move MCP server to this isolated network.

### 3. Logging & Audit Trail

Enable comprehensive logging:

```python
# In proxmox-config/config.json
{
  "logging": {
    "level": "DEBUG",  # Detailed logs
    "format": "%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    "file": "/var/log/proxmox_mcp.log"  # Centralized location
  }
}
```

### 4. Secrets Management

**DO NOT** store API tokens in Git. Use environment variables or secrets manager:

```bash
# Use systemd credentials instead of config file
sudo systemctl edit proxmoxmcp.service

# Add:
[Service]
Environment="PROXMOX_TOKEN=aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
```

Update config to read from environment:

```python
# In config loader
token_value = os.getenv("PROXMOX_TOKEN") or config["auth"]["token_value"]
```

---

## 📊 Monitoring & Observability

### Integrate with Existing Grafana

1. **Create Prometheus exporter for ProxmoxMCP:**

```python
# ~/mcp-servers/mcp_exporter.py
from prometheus_client import start_http_server, Summary, Counter
import time

# Metrics
mcp_requests = Counter('mcp_requests_total', 'Total MCP tool calls')
mcp_errors = Counter('mcp_errors_total', 'Total MCP errors')
mcp_latency = Summary('mcp_request_latency_seconds', 'MCP request latency')

def track_mcp_call(tool_name):
    mcp_requests.inc()
    with mcp_latency.time():
        # Your MCP call here
        pass

if __name__ == '__main__':
    start_http_server(8001)  # Expose metrics on port 8001
    while True:
        time.sleep(1)
```

2. **Add to Prometheus scrape config:**

```yaml
# /etc/prometheus/prometheus.yml
scrape_configs:
  - job_name: 'proxmox_mcp'
    static_configs:
      - targets: ['10.0.0.110:8001']
```

3. **Create Grafana dashboard:**

```json
{
  "dashboard": {
    "title": "ProxmoxMCP Metrics",
    "panels": [
      {
        "title": "MCP Requests per Minute",
        "targets": [
          {
            "expr": "rate(mcp_requests_total[1m])"
          }
        ]
      }
    ]
  }
}
```

---

## 🚀 Advanced Features (Future Phases)

### Phase 3: Multi-Model AI Orchestration (Week 4)

Combine different AI models for specialized tasks:

- **DeepSeek-Coder**: Code generation and fixes
- **Mixtral**: Complex reasoning and planning
- **Llama-3**: General conversation
- **ProxmoxMCP**: Infrastructure actions

**Example workflow:**
1. User asks: "My website is slow - diagnose and fix"
2. **Mixtral** analyzes problem, creates plan
3. **ProxmoxMCP** gathers metrics from Proxmox
4. **DeepSeek-Coder** suggests nginx config optimizations
5. **ProxmoxMCP** applies fixes
6. **Llama-3** explains what was done

### Phase 4: Predictive Infrastructure Management (Week 5-6)

Train ML model to predict resource needs:

```python
# Collect historical data
# - VM CPU/RAM usage
# - Network traffic
# - Storage IOPS
# - Time of day, day of week

# Train model (scikit-learn or TensorFlow)
# Predict future resource needs

# AI Agent proactively:
# - Scales up VMs before traffic spike
# - Pre-warms GPU VMs before training job
# - Schedules backups during low-usage periods
```

### Phase 5: Natural Language Infrastructure-as-Code (Week 7-8)

```
User: "Create a new VM for WordPress with 4GB RAM, 2 CPUs, 
       install Nginx, PHP, MySQL, and deploy my blog."

AI Agent:
1. Calls ProxmoxMCP to create VM
2. Generates Ansible playbook
3. Runs playbook to install software
4. Deploys WordPress
5. Configures DNS
6. Sets up SSL certificate
7. Reports back with URL
```

---

## 🎓 Learning Resources

### Recommended Reading Order

1. **MCP Fundamentals:**
   - Official MCP Docs: https://modelcontextprotocol.io/
   - Anthropic MCP Guide: https://www.anthropic.com/news/model-context-protocol

2. **Your ProxmoxMCP Code:**
   - Start with `README.md` in your repo
   - Study `src/proxmox_mcp/server.py` - main server logic
   - Examine `src/proxmox_mcp/tools/` - individual tool implementations

3. **Skywork AI Patterns:**
   - Full guide: https://skywork.ai/skypage/en/proxmox-ai-homelab/1980807848596254720
   - Focus on "Use Cases" section

4. **Proxmox API:**
   - Official Proxmox API Docs: https://pve.proxmox.com/pve-docs/api-viewer/
   - Proxmoxer Python Library: https://github.com/proxmoxer/proxmoxer

### Video Tutorials

1. **MCP Crash Course:** (mentioned in Skywork guide)
2. **Proxmox Automation with Python:** Search YouTube for "Proxmox API Python"
3. **AI Agents Tutorial:** https://www.youtube.com/results?search_query=ai+agents+tutorial

---

## 🛠️ Troubleshooting Guide

### Common Issues

#### Issue 1: "Failed to connect to Proxmox: SSL certificate verify failed"

**Solution:**
```json
// In proxmox-config/config.json
{
  "proxmox": {
    "verify_ssl": false  // ← Add this for self-signed certs
  }
}
```

#### Issue 2: "Authentication error" when calling Proxmox API

**Check:**
1. Token is not expired
2. User has correct permissions
3. Token format is `user@pve!token_name` not `user@pve`

```bash
# Test API token manually
curl -k -H "Authorization: PVEAPIToken=mcp@pve!mcp-token=YOUR_SECRET" \
  https://136.243.155.166:8006/api2/json/version
```

#### Issue 3: MCP server crashes with "ModuleNotFoundError"

**Solution:**
```bash
# Ensure virtual environment is activated
source ~/mcp-servers/ProxmoxMCP/.venv/bin/activate

# Reinstall dependencies
pip install -e ".[dev]"
```

#### Issue 4: VS Code doesn't recognize ProxmoxMCP tools

**Check:**
1. Restart VS Code after adding MCP config
2. Check VS Code Output panel → "MCP" for errors
3. Verify paths are absolute (not relative)
4. Ensure `PROXMOX_MCP_CONFIG` environment variable is set

---

## 📈 Success Metrics

Track these KPIs to measure success:

| Metric | Target | How to Measure |
|--------|--------|----------------|
| **Time to provision new VM** | < 2 minutes | Compare before/after MCP |
| **Infrastructure queries answered by AI** | > 80% | Track AI success rate |
| **Manual SSH sessions reduced** | -50% | Monitor SSH logs |
| **Incident response time** | < 5 minutes | Track from alert to resolution |
| **Cost savings** | -20% power | Measure kWh with auto-shutdown VMs |

---

## 🎯 Next Steps for Simon

### This Week (Nov 3-10, 2025)

- [ ] **Day 1**: Create Proxmox API token (Step 1)
- [ ] **Day 2**: Deploy ProxmoxMCP server on VM 159 (Step 2)
- [ ] **Day 3**: Create systemd service (Step 3)
- [ ] **Day 4**: Integrate with VS Code (Step 4)
- [ ] **Day 5**: Test all MCP tools (Step 5)
- [ ] **Day 6**: Implement Use Case 1 (Homelab Admin)
- [ ] **Day 7**: Document learnings, plan next phase

### Next Week (Nov 11-17, 2025)

- [ ] Implement Use Case 2 (CI/CD provisioning)
- [ ] Set up monitoring/observability
- [ ] Security hardening
- [ ] Create backup/restore procedures

### Month 2 (Nov 18 - Dec 3, 2025)

- [ ] Implement Use Case 3 (ML workload management)
- [ ] Advanced features from Phase 3
- [ ] Write blog post about your setup
- [ ] Contribute improvements back to ProxmoxMCP project

---

## 🤝 Community & Support

### Get Help

1. **Your ProxmoxMCP Issues:** https://github.com/canvrno/ProxmoxMCP/issues
2. **MCP Discord:** (check Anthropic's MCP documentation for link)
3. **Proxmox Forums:** https://forum.proxmox.com/
4. **Stack Overflow:** Tag `[proxmox] [mcp] [ai-agents]`

### Contribute Back

Once working, consider:
- Opening PRs to improve ProxmoxMCP documentation
- Writing blog posts about your use cases
- Creating video tutorials
- Sharing your automation scripts

---

## 📝 Conclusion

By integrating **ProxmoxMCP** with **Skywork AI patterns**, you're transforming your infrastructure from:

**Before:**
- Manual SSH sessions
- Copy-paste commands
- Reactive troubleshooting

**After:**
- Natural language: "Fix my slow website"
- AI handles planning, execution, verification
- Proactive monitoring and auto-remediation
- Infrastructure-as-Conversation

**This is the future of DevOps.**

---

## 📚 Appendix A: Full Configuration Files

### A.1 Complete `proxmox-config/config.json`

```json
{
  "proxmox": {
    "host": "136.243.155.166",
    "port": 8006,
    "verify_ssl": false,
    "service": "PVE"
  },
  "auth": {
    "user": "mcp@pve",
    "token_name": "mcp-token",
    "token_value": "YOUR_SECRET_HERE"
  },
  "logging": {
    "level": "INFO",
    "format": "%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    "file": "proxmox_mcp.log"
  }
}
```

### A.2 Complete systemd service file

```ini
[Unit]
Description=Proxmox MCP Server
After=network.target docker.service
Wants=network-online.target

[Service]
Type=simple
User=simonadmin
WorkingDirectory=/home/simonadmin/mcp-servers/ProxmoxMCP
Environment="PROXMOX_MCP_CONFIG=/home/simonadmin/mcp-servers/ProxmoxMCP/proxmox-config/config.json"
Environment="PYTHONPATH=/home/simonadmin/mcp-servers/ProxmoxMCP/src"
ExecStart=/home/simonadmin/mcp-servers/ProxmoxMCP/.venv/bin/python -m proxmox_mcp.server
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=proxmoxmcp

[Install]
WantedBy=multi-user.target
```

### A.3 VS Code MCP Settings

```json
{
  "mcpServers": {
    "proxmox": {
      "command": "/home/simonadmin/mcp-servers/ProxmoxMCP/.venv/bin/python",
      "args": ["-m", "proxmox_mcp.server"],
      "cwd": "/home/simonadmin/mcp-servers/ProxmoxMCP",
      "env": {
        "PYTHONPATH": "/home/simonadmin/mcp-servers/ProxmoxMCP/src",
        "PROXMOX_MCP_CONFIG": "/home/simonadmin/mcp-servers/ProxmoxMCP/proxmox-config/config.json"
      }
    }
  }
}
```

---

**Document Version:** 1.0  
**Author:** GitHub Copilot  
**Last Updated:** November 3, 2025  
**License:** MIT (for code snippets) / CC BY 4.0 (for documentation)

---

*Ready to make your infrastructure AI-native? Start with Step 1 and let me know if you hit any issues!* 🚀

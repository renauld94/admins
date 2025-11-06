# 🚀 Unified Agent Monitoring System - Complete Guide

## 📋 Overview

You have **13 primary agents** and **3 support services** running on your system:

### Primary Agents:
1. **agent-core_dev** - Core Development Agent
2. **agent-data_science** - Data Science Agent
3. **agent-geo_intel** - GeoIntelligence Agent
4. **agent-legal_advisor** - Legal Advisor Agent
5. **agent-portfolio** - Portfolio Management Agent
6. **agent-systemops** - System Operations Agent
7. **agent-web_lms** - Web/LMS Agent
8. **vietnamese-epic-enhancement** - Vietnamese Course Enhancement
9. **vietnamese-tutor-agent** - Vietnamese Tutor Agent
10. **smart-agent** - Smart Agent
11. **poll-to-sse** - SSE Polling Service
12. **mcp-agent** - MCP Agent
13. **ollama-code-assistant** - Ollama Code Assistant

### Support Services:
- **mcp-tunnel** - MCP SSH Tunnel
- **ssh-agent** - SSH Agent  
- **health-check** - Health Check Service

---

## 🎯 Three Monitoring Options

### 1. **Terminal Dashboard** (Recommended!)

**Location:** `/home/simon/Learning-Management-System-Academy/.continue/scripts/unified_agent_monitor.sh`

**Start:**
```bash
cd ~/.continue
./scripts/unified_agent_monitor.sh
```

**Features:**
- ✅ Real-time status of ALL agents
- ✅ CPU & Memory usage per agent
- ✅ System resource monitoring
- ✅ Uptime tracking
- ✅ Interactive controls
- ✅ Color-coded status (Green=Running, Red=Stopped)
- ✅ Individual agent management
- ✅ Aggregated log viewing

**Controls:**
- `1-9` - Select individual agent to manage
- `A` - Start all agents
- `S` - Stop all agents
- `R` - Restart all agents
- `L` - View aggregated logs
- `Q` - Quit (agents keep running)

**What you'll see:**
```
╔══════════════════════════════════════════════════════════════════════════════╗
║              🚀 UNIFIED AGENT MONITORING DASHBOARD 🚀                        ║
╠══════════════════════════════════════════════════════════════════════════════╣
║  Running: 10/13  |  Active Agents  |  2025-11-06 10:30:45                  ║
╚══════════════════════════════════════════════════════════════════════════════╝

📊 PRIMARY AGENTS
════════════════════════════════════════════════════════════════════════════════
Agent                          Status     Uptime     CPU%       Memory
────────────────────────────────────────────────────────────────────────────────
Core Development Agent         ✓ RUNNING  15h 30m    5.2%       245MB
Data Science Agent             ✓ RUNNING  12h 45m    12.8%      512MB
GeoIntelligence Agent          ✓ RUNNING  8h 20m     3.1%       128MB
Legal Advisor Agent            ✗ STOPPED  -          0%         0MB
Portfolio Management Agent     ✓ RUNNING  24h 15m    2.4%       98MB
System Operations Agent        ✓ RUNNING  48h 10m    8.7%       312MB
Web/LMS Agent                  ✓ RUNNING  6h 30m     4.5%       156MB
Vietnamese Course Enhancement  ✓ RUNNING  2h 15m     18.3%      487MB
Vietnamese Tutor Agent         ✓ RUNNING  24h 30m    6.2%       234MB
Smart Agent                    ✗ STOPPED  -          0%         0MB
SSE Polling Service            ✓ RUNNING  72h 5m     1.8%       45MB
MCP Agent                      ✓ RUNNING  48h 30m    3.9%       189MB
Ollama Code Assistant          ✗ STOPPED  -          0%         0MB
════════════════════════════════════════════════════════════════════════════════

⚙️ SUPPORT SERVICES
────────────────────────────────────────────────────────────────────────────────
• Health Check Service                     [✓ RUNNING]
• MCP SSH Tunnel                           [✓ RUNNING]
• SSH Agent                                [✓ RUNNING]
────────────────────────────────────────────────────────────────────────────────

🚀 SYSTEM RESOURCES
────────────────────────────────────────────────────────────────────────────────
CPU:     24.5% [█████░░░░░░░░░░░░░░░] Load: 2.1
Memory:  42.8% [█████████░░░░░░░░░░░] 6820 / 15930 MB
Disk:    67%   [████████████░░░░░░░░]
────────────────────────────────────────────────────────────────────────────────

⚙️ CONTROLS & COMMANDS
────────────────────────────────────────────────────────────────────────────────
[1-9] Select Agent   [A] Start All   [S] Stop All   [R] Restart All   [L] Logs   [Q] Quit
────────────────────────────────────────────────────────────────────────────────
```

---

### 2. **Web Dashboard** (Visual & Beautiful)

**Location:** `/home/simon/Learning-Management-System-Academy/.continue/unified_agent_dashboard.html`

**Start web server:**
```bash
cd ~/.continue
python3 -m http.server 8080
```

**Then open:** http://localhost:8080/unified_agent_dashboard.html

**Features:**
- ✅ Beautiful visual interface with gradients
- ✅ Real-time agent status cards
- ✅ System resource graphs
- ✅ Click buttons to control each agent
- ✅ Master controls (Start/Stop/Restart all)
- ✅ Overview statistics at top
- ✅ Mobile-responsive
- ✅ Auto-refreshes every 3 seconds

**Perfect for:**
- Remote monitoring from another device
- Showing management/stakeholders
- Non-technical users
- Taking screenshots for reports
- Multi-monitor setups

---

### 3. **Command-Line Quick Checks**

**Check all agents status:**
```bash
for service in agent-core_dev agent-data_science agent-geo_intel agent-legal_advisor agent-portfolio agent-systemops agent-web_lms vietnamese-epic-enhancement vietnamese-tutor-agent smart-agent poll-to-sse mcp-agent ollama-code-assistant; do
  echo -n "$service: "
  systemctl is-active $service.service
done
```

**Start all agents:**
```bash
sudo systemctl start agents.target
```

**Stop all agents:**
```bash
sudo systemctl stop agents.target
```

**View specific agent:**
```bash
sudo systemctl status agent-core_dev.service
```

**View logs for specific agent:**
```bash
sudo journalctl -u agent-core_dev.service -f
```

**View aggregated logs (all agents):**
```bash
sudo journalctl -u agents.target -f --since "1 hour ago"
```

**Check resource usage:**
```bash
# CPU usage by agent processes
ps aux | grep -E "agent|vietnamese|mcp" | grep -v grep | awk '{print $2, $3, $4, $11}'

# Memory usage
free -h
```

---

## 🎮 Management Commands

### Individual Agent Control

**Start an agent:**
```bash
sudo systemctl start agent-core_dev.service
```

**Stop an agent:**
```bash
sudo systemctl stop agent-portfolio.service
```

**Restart an agent:**
```bash
sudo systemctl restart agent-data_science.service
```

**Enable auto-start on boot:**
```bash
sudo systemctl enable agent-geo_intel.service
```

**Disable auto-start:**
```bash
sudo systemctl disable agent-legal_advisor.service
```

### Bulk Operations

**Start all primary agents:**
```bash
sudo systemctl start agents.target
```

**Stop all agents:**
```bash
for service in agent-{core_dev,data_science,geo_intel,legal_advisor,portfolio,systemops,web_lms} vietnamese-{epic-enhancement,tutor-agent} {smart,mcp,ollama-code-assistant}-agent poll-to-sse; do
  sudo systemctl stop $service.service 2>/dev/null
done
```

**Restart all running agents:**
```bash
for service in agent-{core_dev,data_science,geo_intel,legal_advisor,portfolio,systemops,web_lms} vietnamese-{epic-enhancement,tutor-agent} {smart,mcp,ollama-code-assistant}-agent poll-to-sse; do
  if systemctl is-active --quiet $service.service; then
    sudo systemctl restart $service.service
  fi
done
```

**Check which agents are running:**
```bash
systemctl list-units "agent-*.service" "vietnamese-*.service" "*-agent.service" "poll-to-sse.service" --state=running
```

---

## 📊 Monitoring Best Practices

### 1. **Regular Health Checks** (Every 4-6 hours)

Use the terminal dashboard:
```bash
~/.continue/scripts/unified_agent_monitor.sh
```

Check for:
- ✅ All critical agents running
- ✅ CPU usage < 80% per agent
- ✅ Memory usage stable (no leaks)
- ✅ No error logs

### 2. **Set Up Alerts** (Optional)

Create a monitoring script:
```bash
#!/bin/bash
# ~/.continue/scripts/agent_health_alert.sh

CRITICAL_AGENTS="agent-core_dev agent-systemops vietnamese-epic-enhancement"

for agent in $CRITICAL_AGENTS; do
  if ! systemctl is-active --quiet $agent.service; then
    echo "ALERT: $agent is DOWN!"
    # Send notification (email, Slack, etc.)
  fi
done
```

Add to crontab (check every 15 minutes):
```bash
crontab -e
*/15 * * * * /home/simon/.continue/scripts/agent_health_alert.sh
```

### 3. **Log Rotation**

Ensure logs don't fill disk:
```bash
# Check log sizes
sudo journalctl --disk-usage

# Clean old logs (keep last 7 days)
sudo journalctl --vacuum-time=7d
```

### 4. **Resource Monitoring**

**Install htop for better visualization:**
```bash
sudo apt install htop
htop
```

**Monitor specific agents:**
```bash
watch -n 2 'ps aux | grep -E "agent|vietnamese" | grep -v grep'
```

---

## 🔧 Troubleshooting

### Agent Won't Start

**Check why it failed:**
```bash
sudo journalctl -u agent-name.service -n 50
```

**Common issues:**
1. **Port already in use** → Check: `sudo netstat -tulpn | grep PORT`
2. **Missing dependencies** → Check service file requirements
3. **Permission issues** → Check: `ls -la /path/to/agent/`
4. **Config file error** → Validate JSON/YAML syntax

**Fix and restart:**
```bash
# Fix the issue, then:
sudo systemctl daemon-reload
sudo systemctl restart agent-name.service
```

### High CPU/Memory Usage

**Identify culprit:**
```bash
ps aux --sort=-%cpu | head -20
ps aux --sort=-%mem | head -20
```

**Restart heavy agent:**
```bash
sudo systemctl restart agent-name.service
```

**Check for memory leaks:**
```bash
# Monitor over time
watch -n 5 'ps aux | grep agent-name | grep -v grep | awk "{print \$6}"'
```

### Agent Keeps Crashing

**Check crash logs:**
```bash
sudo journalctl -u agent-name.service --since "1 hour ago" | grep -i "error\|fatal\|crash"
```

**Increase restart limits** (edit service file):
```bash
sudo nano /home/simon/.continue/systemd/agent-name.service

# Add/modify:
[Service]
Restart=always
RestartSec=10s
StartLimitInterval=0
```

**Apply changes:**
```bash
sudo systemctl daemon-reload
sudo systemctl restart agent-name.service
```

### All Agents Down

**Check system resources:**
```bash
df -h           # Disk space
free -h         # Memory
uptime          # Load average
```

**Check for system issues:**
```bash
dmesg | tail -50
```

**Restart all agents:**
```bash
sudo systemctl start agents.target
```

---

## 📈 Performance Optimization

### 1. **Prioritize Critical Agents**

Edit service files to set CPU priority:
```bash
sudo nano /home/simon/.continue/systemd/agent-core_dev.service

[Service]
CPUWeight=200      # Higher = more priority (default 100)
MemoryMax=2G       # Limit max memory
```

### 2. **Limit Resource Usage**

**Per-agent limits:**
```bash
# Edit service file
[Service]
CPUQuota=50%       # Max 50% of one CPU core
MemoryMax=512M     # Max 512MB RAM
```

### 3. **Schedule Heavy Agents**

Run data-intensive agents during off-hours:
```bash
# Use timer units for scheduled execution
sudo nano /home/simon/.continue/systemd/agent-data_science.timer
```

---

## 🎯 Recommended Monitoring Workflow

### Daily:
1. **Morning:** Quick status check
   ```bash
   ~/.continue/scripts/unified_agent_monitor.sh
   # Press Q after 30 seconds
   ```

2. **During work:** Web dashboard in browser tab
   - Open: http://localhost:8080/unified_agent_dashboard.html
   - Glance periodically

### Weekly:
1. **Review logs** for errors
   ```bash
   sudo journalctl -u agents.target --since "1 week ago" | grep ERROR
   ```

2. **Check resource trends**
   ```bash
   # System uptime and load
   uptime
   
   # Disk usage trend
   df -h
   ```

3. **Restart long-running agents** (if needed)
   ```bash
   sudo systemctl restart agents.target
   ```

### Monthly:
1. **Update agent code** from git
2. **Review and archive old logs**
   ```bash
   sudo journalctl --vacuum-time=30d
   ```
3. **Check for system updates**
   ```bash
   sudo apt update && sudo apt upgrade
   ```

---

## 🚀 Quick Reference Card

| Task | Command |
|------|---------|
| **Monitor all agents** | `~/.continue/scripts/unified_agent_monitor.sh` |
| **Web dashboard** | Open `~/.continue/unified_agent_dashboard.html` |
| **Start all** | `sudo systemctl start agents.target` |
| **Stop all** | `sudo systemctl stop agents.target` |
| **Restart all** | `sudo systemctl restart agents.target` |
| **Status of one** | `sudo systemctl status agent-name.service` |
| **Logs of one** | `sudo journalctl -u agent-name.service -f` |
| **All logs** | `sudo journalctl -u agents.target -f` |
| **Check running** | `systemctl list-units "*agent*.service" --state=running` |
| **Resource usage** | `htop` or `ps aux \| grep agent` |

---

## 📞 Support & Documentation

**Created Files:**
- `/home/simon/.continue/scripts/unified_agent_monitor.sh` - Terminal dashboard
- `/home/simon/.continue/unified_agent_dashboard.html` - Web dashboard  
- `/home/simon/.continue/UNIFIED_AGENT_MONITORING.md` - This guide

**Agent Service Files:**
- `/home/simon/.continue/systemd/*.service` - All service definitions
- `/home/simon/.continue/systemd/agents.target` - Group target for all agents

---

## 🎉 You're All Set!

**To start monitoring NOW:**

```bash
# Option 1: Terminal Dashboard (Best)
cd ~/.continue
./scripts/unified_agent_monitor.sh

# Option 2: Web Dashboard
cd ~/.continue
python3 -m http.server 8080
# Then open: http://localhost:8080/unified_agent_dashboard.html

# Option 3: Quick CLI check
systemctl list-units "*agent*.service" --state=running
```

**Your agents are working hard - now you can watch them work! 🚀**

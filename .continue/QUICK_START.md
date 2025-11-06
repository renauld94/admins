# ✅ UNIFIED AGENT MONITORING - QUICK START

## 🚀 Installation Complete!

All your agent services are now installed and ready to use with unified monitoring!

---

## 📊 **OPTION 1: Terminal Dashboard** (Working Now! ✅)

**Start:**
```bash
/home/simon/Learning-Management-System-Academy/.continue/scripts/unified_agent_monitor.sh
```

**Or create an alias:**
```bash
echo 'alias agents="/home/simon/Learning-Management-System-Academy/.continue/scripts/unified_agent_monitor.sh"' >> ~/.bashrc
source ~/.bashrc

# Now just type:
agents
```

**What you get:**
- Real-time status of ALL 13 agents
- CPU & Memory per agent
- System resources
- Interactive controls (A=Start All, S=Stop All, R=Restart All, Q=Quit)
- Auto-refresh every 3 seconds

---

## 🌐 **OPTION 2: Web Dashboard**

**Start web server:**
```bash
cd /home/simon/Learning-Management-System-Academy/.continue
python3 -m http.server 8080 &
```

**Open in browser:**
```
http://localhost:8080/unified_agent_dashboard.html
```

**Features:**
- Beautiful visual interface
- Click buttons to control agents
- Real-time graphs
- Mobile-responsive

---

## ⚡ **OPTION 3: Command-Line**

**Check all agents:**
```bash
systemctl --user list-units '*agent*.service' --state=running
```

**Start all agents:**
```bash
systemctl --user start agents.target
```

**Stop all agents:**
```bash
systemctl --user stop agents.target
```

**Restart specific agent:**
```bash
systemctl --user restart vietnamese-epic-enhancement.service
```

---

## 🎯 **Your 13 Monitored Agents:**

1. **agent-core_dev** - Core Development
2. **agent-data_science** - Data Science
3. **agent-geo_intel** - GeoIntelligence
4. **agent-legal_advisor** - Legal Advisor
5. **agent-portfolio** - Portfolio Management
6. **agent-systemops** - System Operations
7. **agent-web_lms** - Web/LMS
8. **vietnamese-epic-enhancement** - Vietnamese Course Enhancement
9. **vietnamese-tutor-agent** - Vietnamese Tutor (Currently Running!)
10. **smart-agent** - Smart Agent
11. **poll-to-sse** - SSE Polling
12. **mcp-agent** - MCP Agent
13. **ollama-code-assistant** - Ollama Code Assistant

Plus 3 support services: Health Check, MCP Tunnel, SSH Agent

---

## 🔧 **Common Tasks:**

### Start Vietnamese Course Enhancement Agent:
```bash
systemctl --user start vietnamese-epic-enhancement.service

# Monitor it:
systemctl --user status vietnamese-epic-enhancement.service -f
```

### View logs for specific agent:
```bash
journalctl --user -u vietnamese-epic-enhancement.service -f
```

### Start ALL agents at once:
```bash
systemctl --user start agents.target
```

### Check which are running:
```bash
systemctl --user list-units '*agent*.service' --state=running
```

---

## 📝 **Quick Reference:**

| Action | Command |
|--------|---------|
| **Monitor all** | `/path/to/unified_agent_monitor.sh` |
| **Web dashboard** | Open `unified_agent_dashboard.html` |
| **Start all** | `systemctl --user start agents.target` |
| **Stop all** | `systemctl --user stop agents.target` |
| **Status** | `systemctl --user status <agent>.service` |
| **Logs** | `journalctl --user -u <agent>.service -f` |

---

## 🎉 **Next Steps:**

1. **Create alias for easy access:**
   ```bash
   echo 'alias agents="/home/simon/Learning-Management-System-Academy/.continue/scripts/unified_agent_monitor.sh"' >> ~/.bashrc
   source ~/.bashrc
   ```

2. **Start Vietnamese enhancement:**
   ```bash
   systemctl --user start vietnamese-epic-enhancement.service
   ```

3. **Monitor progress:**
   ```bash
   agents  # or run the full path
   ```

4. **Access web dashboard** (optional):
   - Start web server: `cd ~/.continue && python3 -m http.server 8080 &`
   - Open: http://localhost:8080/unified_agent_dashboard.html

---

## 📚 **Documentation:**

- **Full monitoring guide:** `~/.continue/UNIFIED_AGENT_MONITORING.md`
- **Service files:** `~/.config/systemd/user/`
- **Scripts:** `/home/simon/Learning-Management-System-Academy/.continue/scripts/`

---

## ✅ **Status:**

- ✅ All systemd services installed
- ✅ Terminal dashboard working
- ✅ Web dashboard ready
- ✅ Agents.target configured
- ✅ 1 agent currently running (Vietnamese Tutor)
- ✅ Ready to start more agents!

**You're all set! Type `agents` (after creating alias) to start monitoring! 🚀**

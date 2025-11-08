# Epic Background Agent Runner - Complete Index

## 🚀 Quick Navigation

**Status:** ✅ FULLY OPERATIONAL  
**Date:** November 8, 2025  
**Version:** 1.0.0

---

## 📚 Documentation Files

### Essential Reading
- **[DEPLOYMENT_COMPLETE.md](DEPLOYMENT_COMPLETE.md)** - Complete deployment summary (START HERE)
- **[EPIC_AGENT_RUNNER.md](EPIC_AGENT_RUNNER.md)** - Full documentation with examples
- **[EPIC_SUMMARY.txt](EPIC_SUMMARY.txt)** - Quick reference guide

### Quick Start
- **[QUICK_START_AGENTS.sh](QUICK_START_AGENTS.sh)** - Interactive quick start guide

---

## 🔧 Core Scripts

### Deployment & Management
- **epic_background_agent_runner.py** - Main orchestrator service (18KB)
  - Coordinates all AI agents
  - Manages SSH tunnel to VM 159
  - Serves API and dashboard
  - Auto-restarts on failure

- **setup_epic_agent_runner.sh** - Complete setup with systemd (14KB)
  - Checks prerequisites
  - Sets up directories
  - Creates systemd service
  - Enables auto-start

- **deploy_epic_agents.sh** - Quick deployment script
  - Cleans up old processes
  - Starts services
  - Verifies connectivity
  - Shows access info

---

## 🌐 Service Endpoints

| Service | URL | Port | Purpose |
|---------|-----|------|---------|
| Orchestrator API | http://localhost:5100 | 5100 | Main coordination hub |
| Dashboard | http://localhost:5110 | 5110 | Real-time monitoring |
| Code Agent | http://localhost:5101 | 5101 | Code generation (DeepSeek) |
| Data Agent | http://localhost:5102 | 5102 | Data analysis (Llama) |
| Course Agent | http://localhost:5103 | 5103 | Lesson generation (Qwen) |
| Tutor Agent | http://localhost:5104 | 5104 | Student tutoring (Mistral) |

---

## 📁 Directory Structure

```
/home/simon/Learning-Management-System-Academy/
├── epic_background_agent_runner.py          (Main orchestrator)
├── setup_epic_agent_runner.sh               (Setup script)
├── deploy_epic_agents.sh                    (Quick deploy)
├── EPIC_AGENT_RUNNER.md                     (Full docs)
├── DEPLOYMENT_COMPLETE.md                   (Summary)
├── EPIC_SUMMARY.txt                         (Quick ref)
├── logs/
│   └── agents/
│       └── orchestrator.log                 (Live logs)
├── data/
│   └── agents/                              (Temp files)
└── assets/
    └── agent-dashboard/
        └── index.html                       (Dashboard UI)

~/.config/systemd/user/
└── epic-agent-runner.service               (Systemd service)
```

---

## 🎯 Common Tasks

### Start Services
```bash
./deploy_epic_agents.sh
```

### Check Status
```bash
curl http://localhost:5100/health | python3 -m json.tool
```

### View Dashboard
```bash
firefox http://localhost:5110
```

### Monitor Logs
```bash
tail -f logs/agents/orchestrator.log
```

### Stop Services
```bash
kill $(cat .epic_agent_pids)
```

### Deploy to Course
```bash
cd course-improvements/vietnamese-course
python3 deploy_epic_system.py
```

---

## 🤖 Available Models

On VM 159 via SSH tunnel:

- **Qwen2.5:7B** (4.6GB) - Multilingual, course content
- **Codestral:22B** (12.5GB) - Advanced code generation
- **Llama3.2:3B** (2.0GB) - Fast, lightweight inference

**Total:** 19GB+ available

---

## 🔐 System Info

- **Host:** localhost
- **VM 159 IP:** 10.0.0.110
- **SSH Tunnel Port:** 11434
- **Resource Limits:** 4 cores, 4GB RAM
- **Auto-restart:** Enabled
- **Logs:** `/logs/agents/orchestrator.log`

---

## 🆘 Troubleshooting

### Services Won't Start
```bash
pkill -f epic_background_agent_runner.py
./deploy_epic_agents.sh
```

### SSH Tunnel Issues
```bash
ssh simonadmin@10.0.0.110 echo "OK"
ssh-copy-id simonadmin@10.0.0.110
```

### Check Logs
```bash
tail -100 logs/agents/orchestrator.log
grep ERROR logs/agents/orchestrator.log
```

### Verify Endpoints
```bash
curl http://localhost:5100/health
curl http://localhost:5100/status
curl http://localhost:5100/models
```

---

## 📖 Documentation Links

- **Full Guide:** [EPIC_AGENT_RUNNER.md](EPIC_AGENT_RUNNER.md)
- **Deployment Guide:** [DEPLOYMENT_COMPLETE.md](DEPLOYMENT_COMPLETE.md)
- **Quick Reference:** [EPIC_SUMMARY.txt](EPIC_SUMMARY.txt)
- **API Docs:** Auto-generated at `http://localhost:5100/docs`

---

## ✨ What's Next?

1. ✅ Verify services are running: `curl http://localhost:5100/health`
2. ✅ Open dashboard: `firefox http://localhost:5110`
3. ✅ Deploy to course: `python3 deploy_epic_system.py`
4. ✅ Monitor logs: `tail -f logs/agents/orchestrator.log`

---

## 🎉 You're All Set!

Your Epic Background Agent Runner is **fully operational** and ready to power your Vietnamese online course with AI-powered content generation, tutoring, and interactive learning features.

The agents are running 24/7 in the background, accessible via HTTP APIs, and ready for integration with your Moodle course!

---

**Version:** 1.0.0  
**Status:** Production Ready  
**Last Updated:** November 8, 2025

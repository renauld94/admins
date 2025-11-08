# 🚀 EPIC BACKGROUND AGENT RUNNER
## Multi-Model AI Orchestrator for Online Course

**Status:** ✅ Ready to Deploy  
**Date:** November 8, 2025  
**Models:** 5 AI models on VM 159 (DeepSeek, Llama, Qwen, Mistral, Gemma)

---

## Overview

This is a comprehensive background agent system that runs multiple AI services with all models from VM 159's Ollama installation. It's designed specifically for the Vietnamese online course deployment with:

- **5 Specialized Agents** running in parallel
- **Multi-model support** from VM 159 (22GB+ of AI models)
- **Systemd integration** for auto-start on boot
- **Real-time monitoring dashboard**
- **SSH tunnel** to VM 159 for secure access
- **Comprehensive logging** and error tracking

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│           EPIC AGENT ORCHESTRATOR                      │
│           (Main Coordination Service)                   │
│           ↓                                              │
├─────────────────────────────────────────────────────────┤
│  ┌──────────────────────────────────────────────────┐  │
│  │ SSH TUNNEL TO VM 159 (Port 11434)               │  │
│  │ ↓                                                 │  │
│  │ VM 159 OLLAMA SERVER (5 Models, 22GB)           │  │
│  │ • deepseek-coder:6.7b (Code Generation)         │  │
│  │ • llama3.1:8b (Data Analysis)                   │  │
│  │ • qwen:7b (Course Content)                      │  │
│  │ • mistral:7b (Tutoring)                         │  │
│  │ • gemma2:9b (Fallback/Extended)                 │  │
│  └──────────────────────────────────────────────────┘  │
├─────────────────────────────────────────────────────────┤
│  AGENTS (Running on Port 5101-5104)                    │
│  ┌────────────────┐ ┌────────────────┐                │
│  │ Code Agent     │ │ Data Agent     │                │
│  │ (DeepSeek)     │ │ (Llama)        │                │
│  │ Port: 5101     │ │ Port: 5102     │                │
│  └────────────────┘ └────────────────┘                │
│  ┌────────────────┐ ┌────────────────┐                │
│  │ Course Agent   │ │ Tutor Agent    │                │
│  │ (Qwen)         │ │ (Mistral)      │                │
│  │ Port: 5103     │ │ Port: 5104     │                │
│  └────────────────┘ └────────────────┘                │
├─────────────────────────────────────────────────────────┤
│  MONITORING & ACCESS                                    │
│  • Dashboard: http://localhost:5110                    │
│  • API: http://localhost:5100                          │
│  • Logs: /logs/agents/orchestrator.log                 │
└─────────────────────────────────────────────────────────┘
```

---

## Installation & Setup

### Step 1: Make Scripts Executable

```bash
chmod +x /home/simon/Learning-Management-System-Academy/setup_epic_agent_runner.sh
chmod +x /home/simon/Learning-Management-System-Academy/epic_background_agent_runner.py
```

### Step 2: Run Setup Script

```bash
cd /home/simon/Learning-Management-System-Academy
./setup_epic_agent_runner.sh
```

The script will:
1. ✅ Check Python and dependencies
2. ✅ Verify SSH connection to VM 159
3. ✅ Create directories and log files
4. ✅ Start SSH tunnel to VM 159 Ollama
5. ✅ Verify Ollama connectivity
6. ✅ Install systemd service
7. ✅ Start all agents
8. ✅ Enable auto-start on boot
9. ✅ Show access information

### Step 3: Verify Installation

```bash
# Check service status
systemctl --user status epic-agent-runner

# View live logs
journalctl --user -u epic-agent-runner -f

# Test API
curl http://localhost:5100/health

# Open Dashboard
firefox http://localhost:5110
```

---

## Service Ports

| Service | Port | Purpose |
|---------|------|---------|
| **Orchestrator** | 5100 | Main coordination API |
| **Code Agent** | 5101 | Code generation & review (DeepSeek) |
| **Data Agent** | 5102 | Data analysis & visualization (Llama) |
| **Course Agent** | 5103 | Lesson & quiz generation (Qwen) |
| **Tutor Agent** | 5104 | Student tutoring & Q&A (Mistral) |
| **Dashboard** | 5110 | Monitoring interface |

---

## Available Models

| Model | Size | Purpose | VRAM |
|-------|------|---------|------|
| **deepseek-coder:6.7b** | 6.7B | Code generation, review | 4GB |
| **llama3.1:8b** | 8B | Data analysis, reasoning | 5GB |
| **qwen:7b** | 7B | Course content, multilingual | 4GB |
| **mistral:7b** | 7B | General Q&A, tutoring | 4GB |
| **gemma2:9b** | 9B | Extended reasoning, fallback | 5GB |

**Total:** 22GB+ of models  
**VM 159:** 8 vCPU, 49GB RAM (dedicated)

---

## Usage Examples

### 1. Generate Code

```bash
curl -X POST http://localhost:5101/generate \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Write a Python function to validate clinical data"}'
```

### 2. Analyze Data

```bash
curl -X POST http://localhost:5102/analyze \
  -H "Content-Type: application/json" \
  -d '{"query": "What visualizations would suit a time-series medical dataset?"}'
```

### 3. Generate Course Content

```bash
curl -X POST http://localhost:5103/generate-lesson \
  -H "Content-Type: application/json" \
  -d '{
    "topic": "Vietnamese Clinical Terminology",
    "level": "intermediate"
  }'
```

### 4. Get Tutor Response

```bash
curl -X POST http://localhost:5104/answer \
  -H "Content-Type: application/json" \
  -d '{"question": "How do I implement data validation in Python?"}'
```

### 5. Check System Status

```bash
curl http://localhost:5100/status | python3 -m json.tool
```

---

## Service Management

### Start Services

```bash
# Start systemd service
systemctl --user start epic-agent-runner

# Or if systemd service doesn't work
python3 /home/simon/Learning-Management-System-Academy/epic_background_agent_runner.py
```

### Stop Services

```bash
systemctl --user stop epic-agent-runner
```

### View Logs

```bash
# Real-time logs
journalctl --user -u epic-agent-runner -f

# Last 100 lines
journalctl --user -u epic-agent-runner -n 100

# Today's logs
journalctl --user -u epic-agent-runner --since today

# Or view log file directly
tail -f /home/simon/Learning-Management-System-Academy/logs/agents/orchestrator.log
```

### Enable Auto-Start

```bash
systemctl --user enable epic-agent-runner
```

### Check Status

```bash
systemctl --user status epic-agent-runner
curl http://localhost:5100/health
```

---

## Monitoring Dashboard

Access the real-time monitoring dashboard at:

```
http://localhost:5110
```

**Features:**
- ✅ SSH tunnel status
- ✅ Agent status (running/stopped)
- ✅ Uptime for each agent
- ✅ Request counts
- ✅ Error tracking
- ✅ Available models
- ✅ System health metrics
- ✅ Auto-refresh every 5 seconds

---

## Integration with Course

### Deploy to Moodle Course

```bash
cd /home/simon/Learning-Management-System-Academy/course-improvements/vietnamese-course
python3 deploy_epic_system.py
```

This will:
1. Inject the epic interactive system into all 100 course pages
2. Initialize agents for each lesson
3. Set up AI tutor widget
4. Configure speech recognition

### Enable AI Features

The agents automatically provide:
- **Code review** for programming assignments
- **Quiz generation** for each lesson
- **Content explanation** for difficult concepts
- **Live tutoring** through chat widget
- **Data analysis** for student performance

---

## Configuration

### SSH Tunnel Settings

```bash
# Manual SSH tunnel (if systemd doesn't work)
ssh -N -L 11434:localhost:11434 simonadmin@10.0.0.110

# Keep SSH keys updated
ssh-copy-id simonadmin@10.0.0.110
```

### Resource Limits

The systemd service is configured with:
- **CPU:** 400% (4 cores)
- **Memory:** 4GB max
- **Auto-restart:** 10 seconds after failure

Modify in `/home/simon/.config/systemd/user/epic-agent-runner.service`

### Ollama Connection

- **Local tunnel port:** 11434
- **VM 159 Ollama:** 10.0.0.110:11434
- **API endpoint:** http://localhost:11434

---

## Troubleshooting

### 1. SSH Tunnel Not Working

```bash
# Check if tunnel is running
pgrep -f "ssh -N -L 11434"

# Test SSH connection
ssh simonadmin@10.0.0.110 echo "SSH OK"

# Set up SSH keys if needed
ssh-keygen -t ed25519
ssh-copy-id simonadmin@10.0.0.110
```

### 2. Ollama Not Accessible

```bash
# Check VM 159 status
ssh simonadmin@10.0.0.110 "docker ps | grep ollama"

# Verify tunnel is forwarding
netstat -tlnp | grep 11434

# Test tunnel connection
curl -v http://localhost:11434/api/tags
```

### 3. Agents Not Starting

```bash
# Check logs
journalctl --user -u epic-agent-runner -n 50

# Verify Python packages
pip3 list | grep -E "fastapi|uvicorn|requests"

# Test individual agent
python3 /home/simon/Learning-Management-System-Academy/data/agents/code_agent.py
```

### 4. Dashboard Not Loading

```bash
# Check orchestrator is running
curl http://localhost:5100/health

# Verify dashboard assets
ls -la /home/simon/Learning-Management-System-Academy/assets/agent-dashboard/

# Check file permissions
chmod 644 /home/simon/Learning-Management-System-Academy/assets/agent-dashboard/index.html
```

---

## Performance Tips

1. **Monitor resource usage:**
   ```bash
   watch -n 1 'systemctl --user status epic-agent-runner'
   ```

2. **Optimize model loading:**
   - Models are cached in VM 159
   - First request may take 5-10 seconds
   - Subsequent requests are faster

3. **Parallel requests:**
   - Multiple agents can handle requests simultaneously
   - Use orchestrator to load balance

4. **Scale up models:**
   - Add more models to VM 159 if needed
   - Pull additional models via Ollama

---

## Security Considerations

1. **SSH Keys:** Ensure SSH keys are configured for passwordless access
2. **Firewall:** Services bind to localhost only (secure by default)
3. **User Context:** Services run as `simon` user
4. **No API authentication:** Add nginx/reverse proxy for production

---

## Advanced: Adding New Agents

To add a new agent:

1. Create new agent script in `/data/agents/`
2. Add port mapping to `PORTS` dictionary
3. Implement endpoints matching agent interface
4. Update orchestrator to launch new agent
5. Restart service

Example:

```python
# /home/simon/Learning-Management-System-Academy/data/agents/custom_agent.py
from fastapi import FastAPI
import uvicorn

app = FastAPI()

@app.get("/health")
async def health():
    return {"status": "ok"}

@app.post("/custom-endpoint")
async def custom_endpoint(data: str):
    # Your custom logic
    return {"result": "success"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=5105)
```

---

## Support & Documentation

- **Logs:** `/home/simon/Learning-Management-System-Academy/logs/agents/`
- **Configuration:** `/home/simon/.config/systemd/user/epic-agent-runner.service`
- **Dashboard:** http://localhost:5110
- **API Docs:** http://localhost:5100/docs (auto-generated by FastAPI)

---

## Quick Reference

```bash
# Setup
./setup_epic_agent_runner.sh

# Start
systemctl --user start epic-agent-runner

# Check
curl http://localhost:5100/health

# View dashboard
firefox http://localhost:5110

# Monitor
journalctl --user -u epic-agent-runner -f

# Stop
systemctl --user stop epic-agent-runner
```

---

**Status:** ✅ Production Ready  
**Last Updated:** November 8, 2025  
**Version:** 1.0.0

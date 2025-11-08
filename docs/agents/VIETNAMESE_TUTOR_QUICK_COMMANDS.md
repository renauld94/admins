# Vietnamese Tutor Agent - Quick Commands

## ✅ Status Commands

```bash
# Full status
systemctl --user status vietnamese-tutor-agent.service

# Quick check (Active?)
systemctl --user is-active vietnamese-tutor-agent.service

# Health endpoint
curl -s http://127.0.0.1:5001/health | jq .

# Process info
ps aux | grep vietnamese_tutor_agent | grep -v grep
```

## 📊 Monitoring

```bash
# View live logs (Ctrl+C to stop)
journalctl --user -u vietnamese-tutor-agent.service -f

# Last 20 lines
journalctl --user -u vietnamese-tutor-agent.service -n 20

# Errors only
journalctl --user -u vietnamese-tutor-agent.service --priority=err

# Today's logs
journalctl --user -u vietnamese-tutor-agent.service --since today
```

## 🔧 Control

```bash
# Start
systemctl --user start vietnamese-tutor-agent.service

# Stop
systemctl --user stop vietnamese-tutor-agent.service

# Restart
systemctl --user restart vietnamese-tutor-agent.service

# Enable on boot
systemctl --user enable vietnamese-tutor-agent.service

# Disable on boot
systemctl --user disable vietnamese-tutor-agent.service
```

## 🧪 Testing

```bash
# Health check
curl -s http://127.0.0.1:5001/health | jq .

# Send test question
curl -X POST http://127.0.0.1:5001/tutor \
  -H "Content-Type: application/json" \
  -d '{
    "student_id": "test-001",
    "question": "Làm sao để học tiếng Việt hiệu quả?",
    "language": "vietnamese"
  }' | jq .

# Check port is listening
lsof -i :5001

# Check Ollama connectivity
curl -s http://127.0.0.1:11434/api/tags | jq '.models[] | .name'
```

## 📁 Important Paths

```bash
# Agent context (where sessions are stored)
~/Learning-Management-System-Academy/workspace/agents/context/vietnamese-tutor/

# Service config
~/.config/systemd/user/vietnamese-tutor-agent.service

# Agent code
~/.continue/agents/agents_continue/vietnamese_tutor_agent.py

# Status document
~/Learning-Management-System-Academy/VIETNAMESE_AGENT_STATUS_STABLE.md
```

## 🚨 Troubleshooting

```bash
# Service failed to start?
systemctl --user reset-failed vietnamese-tutor-agent.service
systemctl --user start vietnamese-tutor-agent.service

# Port 5001 already in use?
lsof -i :5001  # Find what's using it
kill <PID>     # Kill the process if needed

# Ollama disconnected?
curl http://127.0.0.1:11434/api/tags  # Check if Ollama is running

# View last error
journalctl --user -u vietnamese-tutor-agent.service -n 50 | tail -20
```

## 📈 Performance

```bash
# Memory usage
ps aux | grep vietnamese_tutor_agent | awk '{print $6 " KB"}'

# Uptime
systemctl --user status vietnamese-tutor-agent.service | grep "since"

# Request latency (check logs for timing)
journalctl --user -u vietnamese-tutor-agent.service | grep -i "latency\|duration\|time"
```

---

**Status**: ✅ PRODUCTION STABLE (Nov 7, 2025)  
**Agent Running**: YES (1h 47min uptime)  
**Last Updated**: 10:00 AM +07

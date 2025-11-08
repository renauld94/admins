#!/usr/bin/env bash
# 🚀 EPIC BACKGROUND AGENT RUNNER - QUICK START
# Run this to get everything up and running in 60 seconds!

cat << 'EOF'
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║   🚀 EPIC BACKGROUND AGENT RUNNER                            ║
║   Quick Start Guide - Get Running in 60 Seconds              ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝

STEP 1: Navigate to Project
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  cd /home/simon/Learning-Management-System-Academy

STEP 2: Run Setup (One Command!)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ./setup_epic_agent_runner.sh

This will automatically:
  ✅ Check all prerequisites
  ✅ Create directories
  ✅ Start SSH tunnel to VM 159
  ✅ Verify Ollama connectivity
  ✅ Install systemd service
  ✅ Start all agents
  ✅ Show access info

STEP 3: Monitor (Optional)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  # View real-time logs
  journalctl --user -u epic-agent-runner -f

  # Or check via API
  curl http://localhost:5100/health

STEP 4: Access Services
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  📊 Dashboard:        http://localhost:5110
  🔧 API:              http://localhost:5100
  💻 Code Agent:       http://localhost:5101
  📊 Data Agent:       http://localhost:5102
  📚 Course Agent:     http://localhost:5103
  🎓 Tutor Agent:      http://localhost:5104

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

THAT'S IT! ✨

Your AI agents are now running 24/7 with all VM 159 models!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

USEFUL COMMANDS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Start service:
  systemctl --user start epic-agent-runner

Stop service:
  systemctl --user stop epic-agent-runner

Check status:
  systemctl --user status epic-agent-runner

View logs:
  journalctl --user -u epic-agent-runner -f

View detailed status:
  curl http://localhost:5100/status | python3 -m json.tool

List available models:
  curl http://localhost:5100/models | python3 -m json.tool

Query code agent:
  curl -X POST http://localhost:5101/generate \
    -H "Content-Type: application/json" \
    -d '{"prompt": "Write hello world in Python"}'

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

TROUBLESHOOTING
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Problem: SSH tunnel not connecting
Solution:
  ssh-copy-id simonadmin@10.0.0.110

Problem: Ollama not responding
Solution:
  # Check VM 159
  ssh simonadmin@10.0.0.110 "docker ps | grep ollama"
  
  # Verify tunnel
  netstat -tlnp | grep 11434

Problem: Agents not starting
Solution:
  journalctl --user -u epic-agent-runner -n 50

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📖 Full documentation: EPIC_AGENT_RUNNER.md

EOF

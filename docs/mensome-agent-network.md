# Neuro AI Ecosystem - Local Multi-Agent Network

This document summarizes the Multi-Agent Developer Network (Neuro AI Ecosystem)
we added to the workspace and describes how to run the example local agents
and the generated config files.

- `.continue/config.json` - Continue / Ollama local config + comm channels
- `deploy/ollama.service` - example systemd unit for Ollama (template)
- `scripts/start-agents.sh` - simple helper to create sentinel files for agents
- `workspace/agents/*.json` - example agent manifests (core-dev, data-science, geo-intel, web-lms, systemops)

Quick test (local-only)
- `.continue/config.json` - Continue / Ollama local config + comm channels
- `deploy/ollama.service` - example systemd unit for Ollama (template)
- `scripts/start-agents.sh` - simple helper to create sentinel files for agents
- `workspace/agents/*.json` - example agent manifests (core-dev, data-science, geo-intel, web-lms, systemops)

Quick test (local-only)

1. Ensure the `jq` utility is installed (optional used in scripts):

```bash
sudo apt update && sudo apt install -y jq
```

2. Make the start script executable and run it:

```bash
chmod +x scripts/start-agents.sh
./scripts/start-agents.sh
```

You should see sentinel files under `logs/agents/` for each agent.

Design notes & next steps

- Communication: prefer unix sockets and local HTTP loopback for privacy.
- Agent processes: the example manifests reference `scripts/agents/*.py` entrypoints — implement small HTTP/Unix socket listeners there for real behavior.
- VS Code: `.continue/config.json` includes `aiTriggerPrefixes` so editors can detect `# ai:` and `// ai:`.
- Security: this design keeps traffic local; if you expose anything via Nginx, add mTLS and restrict to internal networks.

Suggested follow-ups (implementations)

1. Write minimal agent runners (Python FastAPI or simple Flask) for each manifest that accept local commands and operate on context files.
2. Implement an agent registry (simple JSON file or tiny HTTP endpoint) to discover agents and their capabilities.
3. Integrate with the Ollama/Continue VS Code extension so inline hints and `# ai:` triggers map to the Core Dev agent.
4. Add systemd units or a supervisor (tmux/systemd/s6) to manage agent processes in production.

If you want, I can now:
- generate minimal Python agent runners (FastAPI) for each manifest and add unit tests,
- or wire up unix-socket communication examples.

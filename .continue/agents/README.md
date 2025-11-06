# Geodashboard EPIC Agent

This directory contains a lightweight autonomous agent to monitor the EPIC geodashboard.

Files:

- `geodashboard_epic_agent.py` — the agent script. Configurable via environment variables.
- `requirements.txt` — Python dependency (requests). Install with pip if needed.
- `geodashboard_agent.service` — sample systemd unit file (copy to `/etc/systemd/system/` and enable).
- `logs/` — runtime logs are written here; the script will create this directory automatically.

Quick usage (local test):

1. Install dependencies (optional, requests is recommended):

```bash
python3 -m pip install -r .continue/agents/requirements.txt
```

2. Run a short quick test for ~15 seconds:

```bash
# run from repo root
export DURATION_HOURS=0.004  # ~14.4 seconds
export INTERVAL_SECONDS=3
python3 .continue/agents/geodashboard_epic_agent.py

# then inspect the log file under .continue/agents/logs/
ls -l .continue/agents/logs/
tail -n +1 .continue/agents/logs/agent_*.log
```

3. To run as a systemd service on the VM (run as root):

```bash
# copy unit file
sudo cp .continue/agents/geodashboard_agent.service /etc/systemd/system/geodashboard_agent.service
sudo systemctl daemon-reload
sudo systemctl enable --now geodashboard_agent.service

# view logs
sudo journalctl -u geodashboard_agent.service -f
```

Security & safety notes:
- The agent performs non-destructive monitoring HTTP requests only.
- Default log folder is inside the repository `.continue/agents/logs/`. If you prefer system logs, use the systemd unit and journalctl.
- Set `DURATION_HOURS` and `INTERVAL_SECONDS` via environment variables when starting the service.

Next steps I can do for you:
- Install the service on the VM and start a 24–48 hour run for you (requires sudo on VM).
- Add optional telemetry (push to Prometheus or upload artifacts) if desired.

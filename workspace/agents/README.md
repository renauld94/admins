Neuro AI Agents
================

This directory contains example agent manifests and the local token used to authenticate requests to the agents.

Token auth
----------
Agents require a bearer token by default for all endpoints except `/health`.

- The token is read from the environment variable `NEURO_AGENT_TOKEN` or from `workspace/agents/.token`.
- The `scripts/start-agents.sh` script will generate `workspace/agents/.token` if it doesn't exist and export it for spawned agents.
- For systemd usage, see `deploy/neuro-agent@.service` which reads the token file and exports `NEURO_AGENT_TOKEN` for the agent process.

Starting locally
----------------
Run:

```bash
bash scripts/start-agents.sh
```

Then call agent endpoints using the token from `workspace/agents/.token`, e.g.:

```bash
TOKEN=$(cat workspace/agents/.token)
curl -H "Authorization: Bearer $TOKEN" -X POST http://127.0.0.1:5102/etl -d '{"limit":5, "source":"mock"}' -H 'Content-Type: application/json'
```

Systemd
-------
Install the template unit and start an agent as a service (example running as user `simon`):

```bash
sudo cp deploy/neuro-agent@.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now neuro-agent@core_dev
```

Adjust paths and the service name (`core_dev` -> `core_dev_server.py` base name without `.py`) as needed.

# Neuro AI Ecosystem - Local agents

This folder contains example agent manifests used by local tooling and the
`start-agents.sh` helper. Agents communicate via local files, unix sockets or
HTTP loopback. All data and messaging stay within the host.

Structure:

- `core-dev.json`       - Core development assistant metadata
- `data-science.json`   - Data engineering and ML agent metadata
- `geo-intel.json`      - Geospatial automation agent metadata
- `web-lms.json`        - Website & Moodle agent metadata
- `systemops.json`      - System operations agent metadata

The `start-agents.sh` script creates sentinel files under `logs/agents/` to
simulate starting agents. Replace with real agent runners (python/node) for
production.


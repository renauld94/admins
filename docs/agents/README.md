## Agents documentation - consolidated index

This folder contains the consolidated, curated documentation for the project's agents, monitoring, and model setup. The original, root-level documents have been archived under `/docs/archived` to keep the repository root tidy while preserving history.

What you'll find here
- `PHASE_1_2_3_COMPLETION_SUMMARY.md` — Phase 1–3 work summary (migration, config update, validation). (located at repo root)
- `WORKSPACE_AGENT_ANALYSIS_AND_RECOMMENDATIONS.md` — Full audit and recommendations for agent placement, models, and tuning. (located at repo root)
- `deploy/prometheus/` — Prometheus configuration and Grafana dashboard JSON (monitoring deployment artifacts).
- `.continue/config.json` — Continue extension configuration (model selection and temperatures). (in `.continue`)

Quick navigation
- Active monitoring & dashboard
  - Prometheus config: `deploy/prometheus/prometheus.yml`
  - Grafana dashboard JSON: `deploy/prometheus/grafana-agent-dashboard.json`
  - Agent exporter code: `.continue/scripts/agent_exporter.py`

- Models & Ollama (VM 159)
  - VM models live on VM 159 (see `AGENTS_Ai.md` archived copy). Use `openwebui` and Ollama at `http://10.0.0.110:11434` for model API access.

- Migration & scheduling performed
  - Agents moved to VM 159: `geodashboard_autonomous_agent.py`, `infrastructure_monitor_agent.py` (now in `/home/simonadmin/vm159-agents/` on VM 159) — scheduled via cron.

Notes & housekeeping
- The following root files were archived to `/docs/archived/`:
  - `AGENT_MONITORING.md` → `/docs/archived/AGENT_MONITORING.md`
  - `AGENT_MONITORING_SUMMARY.md` → (archived copy preserved in repo history, summary retained at root until further consolidation)
  - `AGENTS_Ai.md` → `/docs/archived/AGENTS_Ai.md`

- If you'd like, I can:
  1. Fully merge the archived content into a single long-form `docs/agents/AGENTS_REFERENCE.md` (includes full monitoring, model setup, and operational runbook). This will replace the archives and the root summaries.
  2. Add short runbooks for the VM 159 cron entries and the `systemd` service to `docs/agents/runbooks/`.

Contact
- Dashboard admin: Simon Renauld

Last updated: automated re-organization (today)

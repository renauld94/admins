# Deployment tokens & checklist

This file documents where to place required API tokens and the exact steps to run safe previews and real deployments for Moodle and Grafana.

Moodle
------
- Required token: Moodle Web Service token (user-specific)
- Save token to: `~/.moodle_token` (single line, token string only)
- How to create a token:
  1. In Moodle as an admin: Site administration -> Plugins -> Web services -> Manage tokens
  2. Create a dedicated service user and issue a token scoped to the required webservice functions.
  3. Copy the token and store it locally:

    ```bash
    # replace <TOKEN> with the token string
    echo -n "<TOKEN>" > ~/.moodle_token
    chmod 600 ~/.moodle_token
    ```

- Safe deploy workflow (recommended):
  1. Run preview (no token required):
     ```bash
     python3 moodle_deployer.py --deploy-all --preview
     ```
  2. When preview looks correct, save token to `~/.moodle_token`.
  3. Run staged deploys (quizzes first):
     ```bash
     python3 moodle_deployer.py --deploy-quizzes --course-id 10
     python3 moodle_deployer.py --deploy-lessons --course-id 10
     python3 moodle_deployer.py --deploy-resources --course-id 10
     python3 moodle_deployer.py --deploy-assignments --course-id 10
     ```

Grafana
-------
- Required token: Grafana API key (Org Admin or Editor) to import dashboards via API
- Save token: do NOT store in repo. For local one-off imports either pass `--api-token` to the import script or export an env var in your shell session:

  ```bash
  export GRAFANA_API_TOKEN="<TOKEN>"
  python3 deploy/prometheus/import_all_grafana.py --grafana-url http://localhost:3000 --api-token "$GRAFANA_API_TOKEN"
  ```

- If using Docker compose / containerized Grafana, import using the UI (Dashboards -> Import) or run the import script from host with network access to Grafana.

Security & safety
-----------------
- Keep tokens out of version control. Never commit `~/.moodle_token` or Grafana tokens.
- Use `chmod 600` for token files to restrict permissions.
- Use preview/dry-run flags before running destructive or large operations.

Paths referenced by the deployer
--------------------------------
- Generated content: `course-improvements/vietnamese-course/generated/professional/`
- Moodle deployer script: `course-improvements/vietnamese-course/moodle_deployer.py`
- Grafana dashboards: `deploy/prometheus/grafana-agent-dashboard*.json`
- Grafana import wrapper: `deploy/prometheus/import_all_grafana.py`

If you want, I can automate token injection from a secure vault (e.g., pass, AWS Secrets Manager) instead of local files — say the word and I'll draft it.

# Agents Usage & Troubleshooting

## Agent Manifests

- All agent manifests live in `.continue/agents/`.
- Long prompt texts are stored in `.continue/agents/prompts/` and referenced by manifest key `prompt_template_file`.

## Running Agents

- To run the Legal Advisor Agent, use the sample curl command in `legal-advisor.yaml` or run via Continue.dev in VS Code.
- Always review the output JSON for findings and actions.

## Excluding Sensitive Paths

- To prevent agent scans from crashing on protected folders, add them to `.git/info/exclude` or `.continueignore`:

  ```
  echo 'data/postgres-data/' >> .git/info/exclude
  ```

## Troubleshooting

- If you see `EACCES: permission denied, scandir ...`, check that the path is excluded as above.
- For manifest schema errors, keep YAML files minimal and move long prompt texts to `.continue/agents/prompts/`.
- For model errors, check model availability with:

  ```bash
  curl -sS https://ollama.simondatalab.de/api/tags
  ```

## Improving Agents

- Use external prompt files for maintainability.
- Add health checks and pre-commit hooks for legal/PII scans.
- Document agent usage and troubleshooting for all team members.

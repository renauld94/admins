# Continue Extension: Agents and Models Setup

This guide configures Continue for local development with:

- Chat/Edit models via Ollama (DeepSeek Coder 6.7B + Llama3.1:8B)
- Inline autocomplete model
- MCP server for Proxmox (ProxmoxMCP)

If you haven’t yet, populate Ollama with models first:

```bash
bash scripts/ollama_models_setup.sh
```

## 1) Create Continue config

Create or edit `~/.continue/config.json` like below. Replace placeholders such as `YOUR_OPENWEBUI_API_KEY` when applicable.

```json
{
  "models": {
    "chat": {
      "title": "DeepSeek Coder 6.7B (Ollama)",
      "provider": "ollama",
      "model": "deepseek-coder:6.7b",
      "temperature": 0.2
    },
    "edit": {
      "title": "DeepSeek Coder 6.7B (Edit)",
      "provider": "ollama",
      "model": "deepseek-coder:6.7b",
      "temperature": 0.15
    },
    "autocomplete": {
      "title": "Llama3.1:8B (Autocomplete)",
      "provider": "ollama",
      "model": "llama3.1:8b",
      "contextLength": 2048,
      "maxTokens": 64
    },
    "apply": {
      "title": "Llama3.1:8B (Apply)",
      "provider": "ollama",
      "model": "llama3.1:8b",
      "temperature": 0.2
    },
    "embed": {
      "title": "Nomic Embed (if installed)",
      "provider": "ollama",
      "model": "nomic-embed-text"
    },
    "rerank": {
      "title": "MiniCPM-LM-2 (rerank placeholder)",
      "provider": "ollama",
      "model": "minicpm-lm-2"
    }
  },
  "mcpServers": {
    "proxmox": {
      "command": "/home/simonadmin/mcp-servers/ProxmoxMCP/.venv/bin/python",
      "args": ["-m", "proxmox_mcp.server"],
      "cwd": "/home/simonadmin/mcp-servers/ProxmoxMCP",
      "env": {
        "PYTHONPATH": "/home/simonadmin/mcp-servers/ProxmoxMCP/src",
        "PROXMOX_MCP_CONFIG": "/home/simonadmin/mcp-servers/ProxmoxMCP/proxmox-config/config.json"
      }
    }
  },
  "rules": [
    {
      "name": "Infra actions need confirmation",
      "match": ["reboot", "shutdown", "destroy", "delete"],
      "instruction": "Before executing destructive infrastructure actions, propose a plan and wait for explicit user confirmation."
    }
  ]
}
```

Notes:

- Providers: `ollama` assumes your Continue can reach Ollama at `http://127.0.0.1:11434`. If it runs elsewhere, set the `baseUrl` (e.g., `"baseUrl": "http://10.0.0.110:11434"`).
- If you prefer routing chat via OpenWebUI’s OpenAI-compatible API, add another provider entry using `provider": "openai"` with `baseUrl` and `apiKey`.

## 2) Optional: OpenWebUI as an OpenAI provider

Add this model to `models` if using OpenWebUI’s OpenAI API (replace `YOUR_OPENWEBUI_API_KEY`):

```json
{
  "title": "OWUI-Llama3.1:8B",
  "provider": "openai",
  "model": "llama3.1:8b",
  "baseUrl": "https://openwebui.simondatalab.de/api/openai",
  "apiKey": "YOUR_OPENWEBUI_API_KEY",
  "temperature": 0.2
}
```

## 3) Map keyboard shortcuts (optional)

- Chat: Ctrl+L
- Edit: Ctrl+I
- You can change these in Continue Settings inside VS Code.

## 4) Quick sanity checks

- In VS Code, open Continue panel → select Chat model → ask: “What’s 2+2?”
- Use Edit model: select a code block → Ctrl+I → “Refactor into a small function.”
- Inline autocomplete: start typing in a code file and observe greyed suggestions.

## 5) Security and secrets

- Do not hardcode long‑lived API keys in your config.
- Prefer environment variables or VS Code Secret Storage where possible.
- If you ever paste tokens into chat or code, rotate them in the upstream service (OpenWebUI → Settings → API Keys) and reconfigure.

---

If you want, I can inline this config into your user profile (dotfiles) later; for now, review and apply on your local dev machine.

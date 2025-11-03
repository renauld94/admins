#!/usr/bin/env python3
"""
List models exposed by OpenWebUI via native and OpenAI-compatible APIs.

Usage:
  OPENWEBUI_URL=https://openwebui.simondatalab.de \
  OPENWEBUI_TOKEN=YOUR_JWT \
  python3 scripts/list_openwebui_models.py

Notes:
  - OPENWEBUI_TOKEN: a Bearer token (JWT/API key) with permission to list models
  - Prints a consolidated, de-duplicated list of model IDs/names
"""

import os
import sys
import json
import urllib.request
import urllib.error


def fetch(url: str, headers: dict) -> str:
    req = urllib.request.Request(url, headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            return resp.read().decode("utf-8", errors="replace")
    except urllib.error.HTTPError as e:
        return e.read().decode("utf-8", errors="replace")
    except Exception as e:
        return f"ERROR: {e}"


def main():
    base = os.getenv("OPENWEBUI_URL", "https://openwebui.simondatalab.de").rstrip("/")
    token = os.getenv("OPENWEBUI_TOKEN")
    if not token:
        print("ERROR: Set OPENWEBUI_TOKEN to a valid Bearer token", file=sys.stderr)
        sys.exit(2)

    headers = {"Authorization": f"Bearer {token}", "Accept": "application/json"}
    native_url = f"{base}/api/models"
    openai_url = f"{base}/api/openai/v1/models"

    native_raw = fetch(native_url, headers)
    openai_raw = fetch(openai_url, headers)

    models = set()

    # Try native format
    try:
        data = json.loads(native_raw)
        # Handle possible shapes
        # - list of objects with .name
        # - {"models": [{"name": ...}]}
        if isinstance(data, list):
            for item in data:
                name = item.get("name") if isinstance(item, dict) else None
                if name:
                    models.add(name)
        elif isinstance(data, dict):
            for item in data.get("models", []):
                name = item.get("name")
                if name:
                    models.add(name)
    except Exception:
        pass

    # Try OpenAI-compatible format
    try:
        data = json.loads(openai_raw)
        # Expected: {"data": [{"id": "model"}, ...]}
        for item in data.get("data", []):
            mid = item.get("id")
            if mid:
                models.add(mid)
    except Exception:
        pass

    if not models:
        print("No models found or insufficient permissions.")
        print("- Verify your token and provider settings in OpenWebUI.")
        print("- If using Ollama, ensure models are pulled and provider is configured.")
        sys.exit(1)

    print("Models detected:")
    for m in sorted(models):
        print(f"- {m}")


if __name__ == "__main__":
    main()

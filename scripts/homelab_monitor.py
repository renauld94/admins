#!/usr/bin/env python3
"""
AI-Powered Homelab Monitor (baseline)

Checks:
- OpenWebUI availability (HTTP 200)
- MCP endpoint health page/text
- Docker containers status (if docker available)

Usage:
  python3 scripts/homelab_monitor.py

Note:
- Designed to run on the VM hosting OpenWebUI/MCP (adjust URLs as needed).
"""

import os
import json
import subprocess
from datetime import datetime
import urllib.request
import urllib.error


OPENWEBUI_URL = os.getenv("OPENWEBUI_URL", "https://openwebui.simondatalab.de").rstrip("/")
MCP_URL = os.getenv("MCP_URL", "http://10.0.0.110:3002").rstrip("/")


def check_openwebui() -> bool:
    try:
        req = urllib.request.Request(OPENWEBUI_URL)
        with urllib.request.urlopen(req, timeout=5) as resp:
            return resp.status == 200
    except Exception:
        return False


def check_mcp_endpoint() -> bool:
    try:
        req = urllib.request.Request(MCP_URL)
        with urllib.request.urlopen(req, timeout=5) as resp:
            body = resp.read().decode("utf-8", errors="replace")
            return resp.status == 200 and ("MCP" in body or len(body) > 0)
    except Exception:
        return False


def check_docker_services() -> str:
    try:
        result = subprocess.run(
            ["docker", "ps", "--format", "{{.Names}}: {{.Status}}"],
            capture_output=True,
            text=True,
            timeout=5,
        )
        if result.returncode == 0:
            return result.stdout.strip()
        return f"docker ps failed: {result.stderr.strip()}"
    except FileNotFoundError:
        return "docker not installed"
    except Exception as e:
        return f"docker check error: {e}"


def generate_report():
    return {
        "timestamp": datetime.now().isoformat(),
        "services": {
            "openwebui": "UP" if check_openwebui() else "DOWN",
            "mcp_endpoint": "UP" if check_mcp_endpoint() else "DOWN",
            "docker": check_docker_services(),
        },
    }


if __name__ == "__main__":
    print(json.dumps(generate_report(), indent=2))

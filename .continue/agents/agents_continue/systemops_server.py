#!/usr/bin/env python3
"""
SystemOps Agent - minimal FastAPI app
"""
from fastapi import FastAPI, Depends, Header, HTTPException
import uvicorn
import psutil
import os
from pydantic import BaseModel

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
CONTEXT_DIR = os.path.join(ROOT, 'workspace', 'agents', 'context', 'systemops')
os.makedirs(CONTEXT_DIR, exist_ok=True)

class RestartRequest(BaseModel):
    service: str
    force: bool = False

app = FastAPI(title="SystemOps Agent")


def get_expected_token():
    token = os.environ.get('NEURO_AGENT_TOKEN')
    if token:
        return token
    token_file = os.path.join(ROOT, 'workspace', 'agents', '.token')
    try:
        with open(token_file, 'r', encoding='utf-8') as f:
            return f.read().strip()
    except Exception:
        return None


def require_token(authorization: str = Header(None)):
    expected = get_expected_token()
    if not expected:
        return True
    if not authorization:
        raise HTTPException(status_code=401, detail="Missing Authorization header")
    parts = authorization.split()
    if len(parts) != 2 or parts[0].lower() != 'bearer' or parts[1] != expected:
        raise HTTPException(status_code=403, detail="Invalid token")
    return True

@app.get("/health")
def health():
    return {"status": "ok", "agent": "systemops"}

@app.get("/metrics")
def metrics(_auth: bool = Depends(require_token)):
    return {
        "cpu_percent": psutil.cpu_percent(),
        "memory": psutil.virtual_memory()._asdict()
    }

@app.post("/run")
def run_task(payload: dict, _auth: bool = Depends(require_token)):
    # Minimal echo; implement restart/monitor commands carefully
    return {"received": payload, "agent": "systemops"}


@app.post('/restart_dryrun')
def restart_dryrun(req: RestartRequest, _auth: bool = Depends(require_token)):
    """Write a dry-run restart command into the context directory instead of executing it."""
    cmd = f"systemctl restart {req.service}"
    if req.force:
        cmd = f"{cmd} --force"

    out = os.path.join(CONTEXT_DIR, f"restart_{req.service}.cmd")
    with open(out, 'w') as f:
        f.write(cmd + '\n')

    return {"success": True, "dryrun_cmd": out, "cmd": cmd}

if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=5105)

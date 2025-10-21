#!/usr/bin/env python3
"""
Geo Intelligence Agent - minimal FastAPI app
"""
from fastapi import FastAPI, Depends, Header, HTTPException
import uvicorn
from pydantic import BaseModel
import os
import json
from datetime import datetime

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
CONTEXT_DIR = os.path.join(ROOT, 'workspace', 'agents', 'context', 'geo-intel')
os.makedirs(CONTEXT_DIR, exist_ok=True)

class PublishRequest(BaseModel):
    layer_name: str
    workspace: str = 'geoneural'
    store: str = 'postgis'
    srid: int = 4326

app = FastAPI(title="Geo Intelligence Agent")


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
    return {"status": "ok", "agent": "geo-intel"}

@app.post("/run")
def run_task(payload: dict, _auth: bool = Depends(require_token)):
    # Minimal echo implementation; replace with Geo tasks (publish layer etc.)
    return {"received": payload, "agent": "geo-intel"}

@app.post('/publish_dryrun')
def publish_dryrun(req: PublishRequest, _auth: bool = Depends(require_token)):
    body = {
        "publish": {
            "layer": req.layer_name,
            "workspace": req.workspace,
            "store": req.store,
            "srs": req.srid
        },
        "timestamp": datetime.utcnow().isoformat()
    }

    out_file = os.path.join(CONTEXT_DIR, f"publish_{req.layer_name}.json")
    with open(out_file, 'w') as f:
        json.dump(body, f, indent=2)

    return {"success": True, "dryrun_file": out_file, "body": body}
if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=5103)

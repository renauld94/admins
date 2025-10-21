#!/usr/bin/env python3
"""
Data Science Agent - minimal FastAPI app
"""
from fastapi import FastAPI, Depends, Header, HTTPException
import uvicorn
from pydantic import BaseModel
import os
import csv
from datetime import datetime

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
CONTEXT_DIR = os.path.join(ROOT, 'workspace', 'agents', 'context', 'data-science')
os.makedirs(CONTEXT_DIR, exist_ok=True)

class ETLRequest(BaseModel):
    source: str = 'mock'
    limit: int = 10

app = FastAPI(title="Data Science Agent")


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
    return {"status": "ok", "agent": "data-science"}

@app.post("/run")
def run_task(payload: dict, _auth: bool = Depends(require_token)):
    # Minimal echo implementation; replace with ETL/task handling
    return {"received": payload, "agent": "data-science"}

@app.post('/etl')
def run_etl(req: ETLRequest, _auth: bool = Depends(require_token)):
    """Mock ETL: generate sample CSV output to workspace/agents/context/data-science/etl_output.csv"""
    rows = []
    for i in range(req.limit):
        rows.append({'id': i, 'ts': datetime.utcnow().isoformat(), 'value': i * 1.1})

    out_path = os.path.join(CONTEXT_DIR, 'etl_output.csv')
    with open(out_path, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=['id', 'ts', 'value'])
        writer.writeheader()
        writer.writerows(rows)

    return {"success": True, "rows": len(rows), "output": out_path}

if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=5102)

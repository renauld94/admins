#!/usr/bin/env python3
"""
Core Dev Agent - minimal FastAPI app
"""
from fastapi import FastAPI, Depends, Header, HTTPException
import uvicorn
import os
import re
from pydantic import BaseModel

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
CONTEXT_DIR = os.path.join(ROOT, 'workspace', 'agents', 'context', 'core-dev')
os.makedirs(CONTEXT_DIR, exist_ok=True)

class PatchRequest(BaseModel):
    file: str
    pattern: str
    replacement: str

app = FastAPI(title="Core Dev Agent")


def get_expected_token():
    """Read token from env or workspace file."""
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
    """FastAPI dependency that validates Authorization: Bearer <token>."""
    expected = get_expected_token()
    if not expected:
        # No token configured; allow local access (developer mode)
        return True
    if not authorization:
        raise HTTPException(status_code=401, detail="Missing Authorization header")
    parts = authorization.split()
    if len(parts) != 2 or parts[0].lower() != 'bearer' or parts[1] != expected:
        raise HTTPException(status_code=403, detail="Invalid token")
    return True

@app.get("/health")
def health():
    return {"status": "ok", "agent": "core-dev"}

@app.post("/run")
def run_task(payload: dict, _auth: bool = Depends(require_token)):
    # Minimal echo implementation
    return {"received": payload, "agent": "core-dev"}


@app.post('/patch_dryrun')
def patch_dryrun(req: PatchRequest, _auth: bool = Depends(require_token)):
    target_file = os.path.abspath(req.file)
    if not os.path.isfile(target_file):
        return {"success": False, "error": "file not found", "file": target_file}

    with open(target_file, 'r', encoding='utf-8') as f:
        content = f.read()

    new_content = re.sub(req.pattern, req.replacement, content)
    patch_path = os.path.join(CONTEXT_DIR, f"patch_{os.path.basename(target_file)}.diff")
    with open(patch_path, 'w', encoding='utf-8') as pf:
        pf.write(f"--- {target_file}\n--- patched by core-dev (dryrun)\n")
        pf.write(new_content)

    return {"success": True, "patch_file": patch_path}

if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=5101)

#!/usr/bin/env python3
"""
Web & LMS Agent - minimal FastAPI app
"""
from fastapi import FastAPI, Depends, Header, HTTPException
import uvicorn
import os
from typing import List

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
COURSE_DIR = os.path.join(ROOT, 'learning-platform', 'jnj')

app = FastAPI(title="Web & LMS Agent")


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
    return {"status": "ok", "agent": "web-lms"}

@app.post("/run")
def run_task(payload: dict, _auth: bool = Depends(require_token)):
    # Minimal echo; replace with Moodle API calls or theme tasks
    return {"received": payload, "agent": "web-lms"}


@app.get('/courses')
def list_courses(_auth: bool = Depends(require_token)) -> List[str]:
    """List available JNJ course folders (local read-only)."""
    if not os.path.isdir(COURSE_DIR):
        return []
    items = [name for name in sorted(os.listdir(COURSE_DIR)) if os.path.isdir(os.path.join(COURSE_DIR, name))]
    return items

if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=5104)

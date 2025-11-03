#!/usr/bin/env python3
"""
Legal Advisor Agent - provides project-scoped legal guidance (dry-run, advisory only)
"""
from fastapi import FastAPI, Depends, Header, HTTPException
import uvicorn
import os
import re
import json
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
CONTEXT_DIR = os.path.join(ROOT, 'workspace', 'agents', 'context', 'legal-advisor')
os.makedirs(CONTEXT_DIR, exist_ok=True)

PROJECT_PATH = os.path.join(ROOT, 'digital_unicorn_outsource')

def find_license_files(project_path: str) -> list:
    """Return list of license-like files found in the project root (names and paths)."""
    candidates = ['LICENSE', 'LICENSE.txt', 'COPYING', 'NOTICE', 'LICENSE.md', 'LICENSE.rst']
    found = []
    for name in candidates:
        p = os.path.join(project_path, name)
        if os.path.isfile(p):
            try:
                with open(p, 'r', encoding='utf-8', errors='ignore') as f:
                    snippet = f.read(1024)
            except Exception:
                snippet = ''
            found.append({'name': name, 'path': p, 'snippet': snippet})
    return found

def parse_requirements(req_path: str) -> list:
    pkgs = []
    if not os.path.isfile(req_path):
        return pkgs
    try:
        with open(req_path, 'r', encoding='utf-8', errors='ignore') as f:
            for ln in f:
                ln = ln.strip()
                if not ln or ln.startswith('#'):
                    continue
                # simple split for package==version or package>=version etc.
                m = re.split('[<=>]', ln)[0].strip()
                if m:
                    pkgs.append(m)
    except Exception:
        pass
    return pkgs

def parse_package_json(pkg_path: str) -> dict:
    if not os.path.isfile(pkg_path):
        return {}
    try:
        with open(pkg_path, 'r', encoding='utf-8', errors='ignore') as f:
            j = json.load(f)
            deps = j.get('dependencies', {}) or {}
            dev = j.get('devDependencies', {}) or {}
            license_field = j.get('license')
            return {'dependencies': list(deps.keys()), 'devDependencies': list(dev.keys()), 'license': license_field}
    except Exception:
        return {}

def parse_pyproject_for_license(pyproject_path: str) -> Optional[str]:
    if not os.path.isfile(pyproject_path):
        return None
    try:
        with open(pyproject_path, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
            # naive search for license = "..." or license = '...'
            m = re.search(r"license\s*=\s*['\"]([^'\"]+)['\"]", content)
            if m:
                return m.group(1)
    except Exception:
        pass
    return None


def scan_lockfiles(project_path: str) -> dict:
    """Look for common lockfiles and summarize top-level deps."""
    results = {}
    # package-lock.json
    plock = os.path.join(project_path, 'package-lock.json')
    if os.path.isfile(plock):
        try:
            with open(plock, 'r', encoding='utf-8', errors='ignore') as f:
                j = json.load(f)
                deps = j.get('dependencies') or {}
                results['package-lock'] = {'count': len(deps), 'sample': list(deps.keys())[:20]}
        except Exception:
            results['package-lock'] = {'error': 'parse-failed'}

    # Pipfile.lock
    pipfile_lock = os.path.join(project_path, 'Pipfile.lock')
    if os.path.isfile(pipfile_lock):
        try:
            with open(pipfile_lock, 'r', encoding='utf-8', errors='ignore') as f:
                j = json.load(f)
                default = j.get('default', {}) or {}
                results['pipfile.lock'] = {'count': len(default), 'sample': list(default.keys())[:20]}
        except Exception:
            results['pipfile.lock'] = {'error': 'parse-failed'}

    # poetry.lock (TOML-like) - naive parse for 'name = "pkg"' occurrences
    poetry_lock = os.path.join(project_path, 'poetry.lock')
    if os.path.isfile(poetry_lock):
        try:
            with open(poetry_lock, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
                names = re.findall(r"^name\s*=\s*\"([^\"]+)\"", content, flags=re.M)
                results['poetry.lock'] = {'count': len(names), 'sample': names[:20]}
        except Exception:
            results['poetry.lock'] = {'error': 'parse-failed'}

    # yarn.lock - naive parse for package names (lines like "package@version:")
    yarn_lock = os.path.join(project_path, 'yarn.lock')
    if os.path.isfile(yarn_lock):
        try:
            with open(yarn_lock, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
                names = re.findall(r"^([\w\-@/\.]+)@", content, flags=re.M)
                results['yarn.lock'] = {'count': len(names), 'sample': list(dict.fromkeys(names))[:20]}
        except Exception:
            results['yarn.lock'] = {'error': 'parse-failed'}

    return results


def detect_spdx_identifiers(license_files: list) -> list:
    """Scan provided license file snippets for SPDX-like identifiers (e.g., MIT, Apache-2.0)."""
    hints = []
    spdx_pattern = re.compile(r"\b([A-Za-z0-9\-+.]+(-[0-9.]+)?)\b")
    common_spdx = set(['MIT', 'Apache-2.0', 'GPL-3.0', 'GPL-2.0', 'BSD-2-Clause', 'BSD-3-Clause', 'LGPL-3.0'])
    for lf in license_files:
        snippet = lf.get('snippet', '')
        for m in common_spdx:
            if m in snippet:
                hints.append({'file': lf.get('path'), 'spdx': m})
        # fallback: try to find 'MIT License' or 'Apache License' textual mentions
        if 'MIT License' in snippet and not any(h.get('spdx') == 'MIT' for h in hints):
            hints.append({'file': lf.get('path'), 'spdx': 'MIT'})
        if 'Apache License' in snippet and not any(h.get('spdx') == 'Apache-2.0' for h in hints):
            hints.append({'file': lf.get('path'), 'spdx': 'Apache-2.0'})
    return hints

class AdviceRequest(BaseModel):
    question: str
    files: List[str] = []


app = FastAPI(title="Legal Advisor Agent")


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
    return {"status": "ok", "agent": "legal-advisor"}


@app.post('/advise')
def advise(req: AdviceRequest, _auth: bool = Depends(require_token)):
    """Return a JSON advisory note (dry-run). Always include a legal-disclaimer in the response.

    This agent DOES NOT PROVIDE LEGAL ADVICE. It only produces informational guidance and
    pointers for further review by a qualified attorney. Use as a starting point only.
    """
    # Basic project-awareness: list files referenced if present, otherwise ignore
    found = []
    for f in req.files:
        p = os.path.join(PROJECT_PATH, f)
        found.append({"file": f, "exists": os.path.exists(p)})

    # Scan project for license and dependency manifests
    license_files = find_license_files(PROJECT_PATH)
    requirements = parse_requirements(os.path.join(PROJECT_PATH, 'requirements.txt'))
    package_json = parse_package_json(os.path.join(PROJECT_PATH, 'package.json'))
    pyproject_license = parse_pyproject_for_license(os.path.join(PROJECT_PATH, 'pyproject.toml'))

    deps_summary = {
        'requirements_count': len(requirements),
        'requirements_sample': requirements[:20],
        'npm_deps_count': len(package_json.get('dependencies', [])),
        'npm_deps_sample': package_json.get('dependencies', [])[:20]
    }

    license_hint = package_json.get('license') or pyproject_license

    advice_body = {
        "question": req.question,
        "project_path": PROJECT_PATH,
        "file_checks": found,
        "license_files": license_files,
        "dependencies": deps_summary,
        "detected_license_field": license_hint,
        "advice": (
            "(advisory) Review licensing and data-processing clauses for files referenced. "
            "Check third-party dependencies and any exported data flows. Consider GDPR/data-protection, "
            "export controls, and copyright licensing for external assets. If a license file is present, "
            "open it and verify whether it permits your intended use (copying, modification, distribution)."
        ),
        "disclaimer": "I am not a lawyer. This is informational only and not a substitute for professional legal advice.",
        "timestamp": datetime.utcnow().isoformat()
    }

    out = os.path.join(CONTEXT_DIR, f"advice_{int(datetime.utcnow().timestamp())}.json")
    with open(out, 'w', encoding='utf-8') as f:
        json.dump(advice_body, f, indent=2)

    return {"success": True, "advice_file": out, "advice": advice_body}


@app.get('/summary')
def summary(_auth: bool = Depends(require_token)):
    """Return a compact summary suitable for a quick health/check UI.

    Fields:
      - detected_license (from license file or package manifest)
      - top_python_deps (sample)
      - top_npm_deps (sample)
      - lockfiles_found (counts)
      - spdx_hints (if any)
    """
    license_files = find_license_files(PROJECT_PATH)
    plock = scan_lockfiles(PROJECT_PATH)
    requirements = parse_requirements(os.path.join(PROJECT_PATH, 'requirements.txt'))
    package_json = parse_package_json(os.path.join(PROJECT_PATH, 'package.json'))
    pyproject_license = parse_pyproject_for_license(os.path.join(PROJECT_PATH, 'pyproject.toml'))
    spdx = detect_spdx_identifiers(license_files)

    detected_license = package_json.get('license') or pyproject_license
    if not detected_license and license_files:
        # try to pull a simple hint from the first license snippet
        first = license_files[0].get('snippet','')
        if 'MIT' in first:
            detected_license = 'MIT'
        elif 'Apache' in first:
            detected_license = 'Apache-2.0'

    return {
        'project_path': PROJECT_PATH,
        'detected_license': detected_license,
        'top_python_deps': requirements[:10],
        'top_npm_deps': package_json.get('dependencies', [])[:10],
        'lockfiles_found': {k: v.get('count') if isinstance(v, dict) else None for k, v in plock.items()},
        'spdx_hints': spdx
    }


if __name__ == '__main__':
    uvicorn.run(app, host='127.0.0.1', port=5106)

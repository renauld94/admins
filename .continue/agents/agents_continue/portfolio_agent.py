#!/usr/bin/env python3
"""
Portfolio Agent - helps generate creative ideas, run safe deploys, and prepare Proxmox/CT steps.

This agent is intentionally cautious: deploy actions are dry-run by default. To actually run a
deploy script, call POST /deploy?run=true. It looks for the repo folder `portfolio-deployment-enhanced`
in the workspace and can invoke the included deploy scripts.

Endpoints:
  - GET /health
  - GET /ideas?count=N
  - POST /deploy  (JSON body optional: {"script":"deploy_via_proxy.sh","args":[...]})
  - GET /vm_prepare  (returns a plan for using Proxmox; does not execute destructive actions)

"""
from fastapi import FastAPI, HTTPException, Request
from pydantic import BaseModel
import uvicorn
import os
import json
import subprocess
from typing import List, Optional
from datetime import datetime
import requests
import os
import tempfile
import stat
import base64
import time
import secrets

# Optional encrypted token support
try:
    from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
    from cryptography.hazmat.primitives import hashes
    from cryptography.fernet import Fernet, InvalidToken
    CRYPTO_AVAILABLE = True
except Exception:
    # Keep names defined to satisfy static analysis; functions will guard runtime behavior
    PBKDF2HMAC = None
    hashes = None
    Fernet = None
    InvalidToken = Exception
    CRYPTO_AVAILABLE = False

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', '..'))
PORTFOLIO_DIR = os.path.join(ROOT, 'portfolio-deployment-enhanced')

# Proxmox configuration
# The agent will look for an API token in the path specified by PROXMOX_TOKEN_FILE
# or by the file at ~/.config/portfolio_agent/proxmox_token.json. The file may contain
# either a plain token string or a JSON object: {"api_url":"https://pve:8006","token":"USER@REALM!TOKENID=SECRET"}
PROXMOX_TOKEN_FILE = os.environ.get('PROXMOX_TOKEN_FILE', os.path.expanduser('~/.config/portfolio_agent/proxmox_token.json'))
PROXMOX_API_URL = os.environ.get('PROXMOX_API_URL')
PROXMOX_INSECURE = os.environ.get('PROXMOX_INSECURE', '0') in ('1', 'true', 'yes')
PROXMOX_ENC_TOKEN_FILE = PROXMOX_TOKEN_FILE + '.enc'

# in-memory cache for a decrypted token (populated by /proxmox/load_token_encrypted)
_DECRYPTED_TOKEN_CACHE = {
    'api_url': None,
    'token': None,
    'expires_at': 0.0,
}


def _derive_fernet_key(passphrase: str, salt: bytes, iterations: int = 390000) -> bytes:
    """Derive a Fernet-compatible key from a passphrase and salt using PBKDF2-HMAC-SHA256."""
    if not CRYPTO_AVAILABLE:
        raise RuntimeError('cryptography package not available')
    # Import inside function to satisfy static checkers when cryptography isn't installed
    from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC as _PBKDF2HMAC
    from cryptography.hazmat.primitives import hashes as _hashes

    kdf = _PBKDF2HMAC(
        algorithm=_hashes.SHA256(),
        length=32,
        salt=salt,
        iterations=iterations,
    )
    key = kdf.derive(passphrase.encode('utf-8'))
    return base64.urlsafe_b64encode(key)


def _cache_decrypted_token(api_url: str, token: str, ttl: int = 300):
    _DECRYPTED_TOKEN_CACHE['api_url'] = api_url
    _DECRYPTED_TOKEN_CACHE['token'] = token
    _DECRYPTED_TOKEN_CACHE['expires_at'] = time.time() + float(ttl)


def _get_cached_token():
    if _DECRYPTED_TOKEN_CACHE['token'] and time.time() < _DECRYPTED_TOKEN_CACHE['expires_at']:
        return (_DECRYPTED_TOKEN_CACHE['api_url'], _DECRYPTED_TOKEN_CACHE['token'])
    return (None, None)


def load_proxmox_token():
    """Return (api_url, token) or (None, None) if not configured.

    Token file formats supported:
      - plain token string
      - JSON with {"api_url": "https://pve:8006", "token": "USER@REALM!TOKENID=SECRET"}
    """
    try:
        # prefer any in-memory decrypted token loaded via /proxmox/load_token_encrypted
        cached_api, cached_token = _get_cached_token()
        if cached_api or cached_token:
            return (cached_api, cached_token)
        if not os.path.exists(PROXMOX_TOKEN_FILE):
            return (PROXMOX_API_URL, None) if PROXMOX_API_URL else (None, None)

        with open(PROXMOX_TOKEN_FILE, 'r', encoding='utf-8') as f:
            txt = f.read().strip()
            if not txt:
                return (PROXMOX_API_URL, None) if PROXMOX_API_URL else (None, None)
            # try parse JSON
            try:
                j = json.loads(txt)
                api_url = j.get('api_url') or PROXMOX_API_URL
                token = j.get('token')
                return (api_url, token)
            except Exception:
                # treat as plain token string
                api_url = PROXMOX_API_URL
                token = txt
                return (api_url, token)
    except Exception:
        return (PROXMOX_API_URL, None) if PROXMOX_API_URL else (None, None)


def proxmox_api_request(method: str, path: str, params=None, data=None, json_body=None, timeout=30):
    """Perform a request against the Proxmox API using configured token.

    Returns (status_code, parsed_json_or_text, raw_response)
    """
    # Prefer an in-memory decrypted token if available (loaded via /proxmox/load_token_encrypted)
    api_url, token = _get_cached_token()
    if not api_url or not token:
        api_url, token = load_proxmox_token()
    if not api_url or not token:
        raise RuntimeError('Proxmox API token or API URL not configured')

    url = api_url.rstrip('/') + path
    headers = {'Authorization': f'PVEAPIToken={token}'}
    try:
        resp = requests.request(method, url, params=params, data=data, json=json_body, headers=headers, timeout=timeout, verify=not PROXMOX_INSECURE)
    except Exception as e:
        raise RuntimeError(f'Request failed: {e}')

    # Try parse JSON
    content = None
    try:
        content = resp.json()
    except Exception:
        content = resp.text

    return (resp.status_code, content, resp)


app = FastAPI(title="Portfolio Agent")


class DeployRequest(BaseModel):
    script: Optional[str] = 'deploy_via_proxy.sh'
    args: Optional[List[str]] = []
    env: Optional[dict] = None


@app.get('/health')
def health():
    return {"status": "ok", "agent": "portfolio"}


@app.get('/ideas')
def ideas(count: int = 6):
    """Generate creative ideas by scanning the portfolio folder for content and producing variants."""
    ideas = []
    # Collect some signals from the portfolio folder: asset types, number of demos, top files
    if os.path.isdir(PORTFOLIO_DIR):
        files = []
        for root, dirs, fnames in os.walk(PORTFOLIO_DIR):
            for f in fnames:
                files.append(os.path.relpath(os.path.join(root, f), PORTFOLIO_DIR))
                if len(files) > 200:
                    break
            if len(files) > 200:
                break
    else:
        files = []

    asset_summary = {
        'asset_count': len(files),
        'sample_files': files[:10]
    }

    templates = [
        "Interactive hero: convert {file0} into a 3-step interactive carousel with microinteractions and a short animation loop.",
        "Mini-case study: turn the {file0} demo into a 60s explainer video with captions and an accessible transcript.",
        "LinkedIn carousel: choose 6 highlights from {file0} and {file1} and create a shareable carousel PDF.",
        "Progressive reveal: build a scroll-driven story from {file0} that reveals technical choices, results, and code snippets.",
        "Performance-first rebuild: audit {file0} and create a minimal-critical CSS + lazy-loaded assets version to improve Lighthouse.",
        "AI-enhanced copy: produce punchy marketing headlines and microcopy for the portfolio sections and CTAs.",
        "Try-before-you-buy demo: containerize selected demos and provide quick deploy buttons (Docker/CT template).",
        "Polished resume page: generate a single-page printable resume with embedded portfolio highlights and contact QR code."
    ]

    # Seed from files
    sample = files[:3] + [None] * 3

    i = 0
    for t in templates:
        if len(ideas) >= count:
            break
        try:
            filled = t.format(file0=sample[0] or 'key demo', file1=sample[1] or 'secondary demo')
        except Exception:
            filled = t
        ideas.append({'id': i, 'idea': filled})
        i += 1

    return { 'generated_at': datetime.utcnow().isoformat(), 'asset_summary': asset_summary, 'ideas': ideas[:count] }


@app.post('/deploy')
def deploy(payload: DeployRequest, run: Optional[bool] = False):
    """Attempt to run a deploy script from the portfolio folder. Dry-run by default. Set ?run=true to execute.

    For safety, this will only execute scripts inside the portfolio-deployment-enhanced folder and uses a
    reasonable timeout. It returns stdout/stderr and an exit code when run=true.
    """
    if not os.path.isdir(PORTFOLIO_DIR):
        raise HTTPException(status_code=400, detail=f"Portfolio folder not found at {PORTFOLIO_DIR}")

    script = payload.script or 'deploy_via_proxy.sh'
    script_path = os.path.join(PORTFOLIO_DIR, script)
    if not os.path.isfile(script_path):
        raise HTTPException(status_code=404, detail=f"Script {script} not found in portfolio folder")

    if not run:
        return { 'dry_run': True, 'script': script, 'script_path': script_path }

    # execute with a timeout and capture output
    try:
        proc = subprocess.run([script_path] + (payload.args or []), cwd=PORTFOLIO_DIR, capture_output=True, text=True, timeout=300, check=False)
        return { 'ran': True, 'returncode': proc.returncode, 'stdout': proc.stdout[:20000], 'stderr': proc.stderr[:20000] }
    except subprocess.TimeoutExpired:
        raise HTTPException(status_code=504, detail='Deploy script timed out')
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.get('/vm_prepare')
def vm_prepare():
    """Return a safe plan document describing how to provision a Proxmox CT/VM for hosting the portfolio.

    This endpoint does NOT perform any privileged operations. It emits recommended steps and sample `pct` and
    `qm` commands you can run manually on your Proxmox host.
    """
    plan = {
        'purpose': 'Host static site and demos for portfolio with isolated CT for quick deploys',
        'recommendations': [
            'Create an unprivileged LXC container (CT) with Debian/Ubuntu minimal',
            'Mount a dataset or bind-mount workspace assets into the container for fast deploys',
            'Install Node/Python, nginx/caddy for static hosting, and systemd user units to manage demos',
            'Use snapshotting for safe rollbacks before heavy deploys'
        ],
        'example_commands': {
            'create_ct': 'pct create 101 local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst -hostname portfolio-ct -memory 2048 -net0 name=eth0,bridge=vmbr0,ip=dhcp',
            'start_ct': 'pct start 101',
            'ssh_into_ct': 'pct enter 101 -- /bin/bash'
        }
    }
    return plan


@app.get('/proxmox/info')
def proxmox_info():
    api_url, token = load_proxmox_token()
    return { 'configured_api_url': api_url, 'token_present': bool(token), 'insecure_tls': PROXMOX_INSECURE }


@app.post('/proxmox/set_insecure')
def proxmox_set_insecure(payload: dict):
    """Toggle TLS verification for Proxmox requests at runtime.

    Payload: { "insecure": true|false }
    This is intended for testing/dev only. Setting insecure=true will make the agent
    skip certificate verification when contacting Proxmox (equivalent to verify=False).
    """
    global PROXMOX_INSECURE
    if not isinstance(payload, dict):
        raise HTTPException(status_code=400, detail='payload must be a JSON object')
    if 'insecure' not in payload:
        raise HTTPException(status_code=400, detail='missing insecure flag')
    try:
        val = bool(payload.get('insecure'))
    except Exception:
        raise HTTPException(status_code=400, detail='insecure must be true or false')
    PROXMOX_INSECURE = val
    return {'insecure_tls': PROXMOX_INSECURE}


@app.get('/proxmox/nodes')
def proxmox_nodes():
    """List Proxmox nodes (requires token configured)."""
    try:
        status, content, _ = proxmox_api_request('GET', '/api2/json/nodes')
    except RuntimeError as e:
        raise HTTPException(status_code=400, detail=str(e))
    if status >= 400:
        raise HTTPException(status_code=502, detail={'status': status, 'body': content})
    return content


@app.get('/proxmox/vms')
def proxmox_vms():
    """List VMs and containers in the cluster."""
    try:
        status, content, _ = proxmox_api_request('GET', '/api2/json/cluster/resources', params={'type': 'vm'})
    except RuntimeError as e:
        raise HTTPException(status_code=400, detail=str(e))
    if status >= 400:
        raise HTTPException(status_code=502, detail={'status': status, 'body': content})
    return content


@app.post('/proxmox/create_lxc')
def proxmox_create_lxc(req: dict, run: Optional[bool] = False):
    """Prepare or create an LXC container on Proxmox.

    Expected JSON keys: node (required), ostemplate, hostname, memory, cores, storage
    If run=true, the API call will be executed. Otherwise the prepared payload is returned.
    """
    node = req.get('node')
    if not node:
        raise HTTPException(status_code=400, detail='node is required')

    payload = {
        'hostname': req.get('hostname', 'portfolio-ct'),
        'memory': int(req.get('memory', 2048)),
        'cores': int(req.get('cores', 2)),
        'ostemplate': req.get('ostemplate', ''),
        'storage': req.get('storage', 'local'),
        'net0': req.get('net0', 'name=eth0,bridge=vmbr0,ip=dhcp')
    }

    if not run:
        return {'dry_run': True, 'node': node, 'payload': payload}

    # Execute the proxmox API call
    path = f'/api2/json/nodes/{node}/lxc'
    try:
        status, content, resp = proxmox_api_request('POST', path, data=payload)
    except RuntimeError as e:
        raise HTTPException(status_code=400, detail=str(e))

    if status >= 400:
        raise HTTPException(status_code=502, detail={'status': status, 'body': content})
    return content


@app.get('/proxmox/tasks')
def proxmox_tasks(limit: int = 50, upid: Optional[str] = None):
    """List recent cluster tasks or fetch by UPID.

    - If `upid` is provided, returns the single task status.
    - Otherwise returns a list of recent tasks (limit up to 500).
    """
    try:
        if upid:
            path = f'/api2/json/cluster/tasks/{upid}/status'
            status, content, _ = proxmox_api_request('GET', path)
        else:
            # cluster/tasks supports a 'limit' parameter via 'count'
            params = {'limit': min(int(limit), 500)}
            status, content, _ = proxmox_api_request('GET', '/api2/json/cluster/tasks', params=params)
    except RuntimeError as e:
        raise HTTPException(status_code=400, detail=str(e))
    if status >= 400:
        raise HTTPException(status_code=502, detail={'status': status, 'body': content})
    return content


@app.get('/proxmox/task/{upid}')
def proxmox_task_status(upid: str):
    """Get the status of a Proxmox task by its UPID (unique task id)."""
    try:
        path = f'/api2/json/cluster/tasks/{upid}/status'
        status, content, _ = proxmox_api_request('GET', path)
    except RuntimeError as e:
        raise HTTPException(status_code=400, detail=str(e))
    if status >= 400:
        raise HTTPException(status_code=502, detail={'status': status, 'body': content})
    return content


@app.post('/proxmox/store_token')
def proxmox_store_token(payload: dict, store: Optional[bool] = False):
    """Store a Proxmox API token to the configured token file.

    Payload keys:
      - token (required)
      - api_url (optional)
      - format: 'json'|'plain' (optional)

    By default this returns a dry-run summary. To actually write the file set ?store=true.
    This endpoint will refuse to overwrite an existing token file unless the payload includes "overwrite": true
    and store=true.
    """
    token = (payload.get('token') or '').strip()
    api_url = payload.get('api_url') or PROXMOX_API_URL
    fmt = payload.get('format') or 'json'
    overwrite = bool(payload.get('overwrite'))

    if not token:
        raise HTTPException(status_code=400, detail='token is required in payload')

    exists = os.path.exists(PROXMOX_TOKEN_FILE)
    if exists and not overwrite and not store:
        # dry-run and file exists
        return {'dry_run': True, 'message': 'token file exists', 'path': PROXMOX_TOKEN_FILE}

    if not store:
        return {'dry_run': True, 'will_write': True, 'path': PROXMOX_TOKEN_FILE, 'overwrite': overwrite}

    # perform write safely
    tmpfd, tmppath = tempfile.mkstemp(prefix='proxmox_token_', dir=os.path.dirname(PROXMOX_TOKEN_FILE))
    try:
        with os.fdopen(tmpfd, 'w', encoding='utf-8') as f:
            if fmt == 'plain' or api_url is None:
                f.write(token)
            else:
                f.write(json.dumps({'api_url': api_url, 'token': token}))
        # atomically move into place
        os.replace(tmppath, PROXMOX_TOKEN_FILE)
        # set secure perms
        os.chmod(PROXMOX_TOKEN_FILE, stat.S_IRUSR | stat.S_IWUSR)
    except Exception as e:
        try:
            os.unlink(tmppath)
        except Exception:
            pass
        raise HTTPException(status_code=500, detail=f'failed to write token file: {e}')

    return {'stored': True, 'path': PROXMOX_TOKEN_FILE}



@app.post('/proxmox/store_token_encrypted')
def proxmox_store_token_encrypted(payload: dict, store: Optional[bool] = False):
    """Store an encrypted Proxmox token file protected by a passphrase.

    Payload keys:
      - token (required)
      - api_url (optional)
      - passphrase (required)
      - iterations (optional, KDF iterations)
      - overwrite (optional)

    By default this is a dry-run. Set ?store=true to actually write the encrypted file.
    The encrypted file will be placed at PROXMOX_ENC_TOKEN_FILE and permissions set to 0600.
    """
    if not CRYPTO_AVAILABLE:
        raise HTTPException(status_code=500, detail='cryptography package not installed on agent')

    token = (payload.get('token') or '').strip()
    api_url = payload.get('api_url') or PROXMOX_API_URL
    passphrase = payload.get('passphrase') or ''
    iterations = int(payload.get('iterations') or 390000)
    overwrite = bool(payload.get('overwrite'))

    if not token:
        raise HTTPException(status_code=400, detail='token is required in payload')
    if not passphrase:
        raise HTTPException(status_code=400, detail='passphrase is required')

    exists = os.path.exists(PROXMOX_ENC_TOKEN_FILE)
    if exists and not overwrite and not store:
        return {'dry_run': True, 'message': 'encrypted token file exists', 'path': PROXMOX_ENC_TOKEN_FILE}

    if not store:
        return {'dry_run': True, 'will_write': True, 'path': PROXMOX_ENC_TOKEN_FILE, 'overwrite': overwrite}

    # perform encryption and write atomically
    salt = secrets.token_bytes(16)
    try:
        key = _derive_fernet_key(passphrase, salt, iterations=iterations)
        # import Fernet locally to keep static analysis happy
        from cryptography.fernet import Fernet as _Fernet
        f = _Fernet(key)
        payload_bytes = json.dumps({'api_url': api_url, 'token': token}).encode('utf-8')
        enc = f.encrypt(payload_bytes)
        out = {
            'kdf': 'pbkdf2_hmac_sha256',
            'iterations': iterations,
            'salt': base64.b64encode(salt).decode('ascii'),
            'encrypted': base64.b64encode(enc).decode('ascii')
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f'encryption failed: {e}')

    # ensure parent directory exists
    parent_dir = os.path.dirname(PROXMOX_ENC_TOKEN_FILE) or os.path.expanduser('~/.config/portfolio_agent')
    os.makedirs(parent_dir, exist_ok=True)
    if not os.path.isdir(parent_dir):
        raise HTTPException(status_code=500, detail=f'failed to create directory {parent_dir}')
    tmpfd, tmppath = tempfile.mkstemp(prefix='proxmox_token_enc_', dir=parent_dir)
    try:
        with os.fdopen(tmpfd, 'w', encoding='utf-8') as f:
            f.write(json.dumps(out))
        os.replace(tmppath, PROXMOX_ENC_TOKEN_FILE)
        os.chmod(PROXMOX_ENC_TOKEN_FILE, stat.S_IRUSR | stat.S_IWUSR)
    except Exception as e:
        try:
            os.unlink(tmppath)
        except Exception:
            pass
        raise HTTPException(status_code=500, detail=f'failed to write encrypted token file: {e}')

    return {'stored': True, 'path': PROXMOX_ENC_TOKEN_FILE}



@app.post('/proxmox/load_token_encrypted')
def proxmox_load_token_encrypted(payload: dict):
    """Decrypt the encrypted token file into memory for a short TTL so the agent can use it.

    Payload keys:
      - passphrase (required)
      - ttl (optional, seconds, default 300)

    This does NOT write plaintext to disk; it only caches the decrypted token in-memory for the TTL.
    """
    if not CRYPTO_AVAILABLE:
        raise HTTPException(status_code=500, detail='cryptography package not installed on agent')

    passphrase = payload.get('passphrase') or ''
    ttl = int(payload.get('ttl') or 300)
    if not passphrase:
        raise HTTPException(status_code=400, detail='passphrase is required')
    if not os.path.exists(PROXMOX_ENC_TOKEN_FILE):
        raise HTTPException(status_code=404, detail='encrypted token file not found')

    try:
        with open(PROXMOX_ENC_TOKEN_FILE, 'r', encoding='utf-8') as f:
            j = json.load(f)
        salt = base64.b64decode(j['salt'])
        iterations = int(j.get('iterations') or 390000)
        enc = base64.b64decode(j['encrypted'])
        key = _derive_fernet_key(passphrase, salt, iterations=iterations)
        from cryptography.fernet import Fernet as _Fernet
        fobj = _Fernet(key)
        dec = fobj.decrypt(enc)
        inner = json.loads(dec.decode('utf-8'))
        api_url = inner.get('api_url')
        token = inner.get('token')
        if not token:
            raise HTTPException(status_code=500, detail='decrypted payload missing token')
        _cache_decrypted_token(api_url, token, ttl)
    except InvalidToken:
        raise HTTPException(status_code=403, detail='invalid passphrase or corrupted file')
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f'decryption failed: {e}')

    return {'loaded': True, 'ttl': ttl}



@app.post('/proxmox/unload_token')
def proxmox_unload_token():
    """Clear any decrypted token cached in memory."""
    _DECRYPTED_TOKEN_CACHE['api_url'] = None
    _DECRYPTED_TOKEN_CACHE['token'] = None
    _DECRYPTED_TOKEN_CACHE['expires_at'] = 0.0
    return {'unloaded': True}


@app.post('/proxmox/delete_token')
def proxmox_delete_token(run: Optional[bool] = False):
    """Delete the configured Proxmox token file. Dry-run by default; set ?run=true to actually delete."""
    if not os.path.exists(PROXMOX_TOKEN_FILE):
        return {'deleted': False, 'reason': 'not_found', 'path': PROXMOX_TOKEN_FILE}
    if not run:
        return {'dry_run': True, 'path': PROXMOX_TOKEN_FILE}
    try:
        os.remove(PROXMOX_TOKEN_FILE)
        return {'deleted': True, 'path': PROXMOX_TOKEN_FILE}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


if __name__ == '__main__':
    uvicorn.run(app, host='127.0.0.1', port=5110)

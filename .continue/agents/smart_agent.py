#!/usr/bin/env python3
"""Smart agent: monitors the poll->SSE proxy, health endpoints, tunnel and suggests/fixes small issues.

Features:
- Reads `.continue/config.json` for `ollama_host` (falls back to http://127.0.0.1:11434)
- Checks SSE endpoint (/mcp/sse) and API tags (/api/tags)
- Runs the existing health-check script and parses results
- Checks status of `mcp-tunnel-autossh.service` and `poll-to-sse.gunicorn.service` (user systemd)
- Reports SSH agent state (ssh-add -l) and presence of key file
- Optional --fix mode attempts non-destructive fixes: restart services via `systemctl --user` and load key to ssh-agent if possible

Exit codes: 0=ok, 1=issues found, 2=error
"""
import argparse
import json
import os
import shutil
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2] / '.continue'
LOG_DIR = Path.home() / '.local' / 'state' / 'poll-to-sse'
LOG_DIR.mkdir(parents=True, exist_ok=True)
LOGFILE = LOG_DIR / 'smart_agent.log'


def log(msg):
    ts = time.strftime('%Y-%m-%d %H:%M:%S')
    line = f"{ts} {msg}"
    print(line)
    with open(LOGFILE, 'a') as fh:
        fh.write(line + '\n')


def load_config():
    cfg_path = ROOT / 'config.json'
    if cfg_path.exists():
        try:
            return json.loads(cfg_path.read_text())
        except Exception:
            return {}
    return {}


def http_get(url, timeout=10):
    try:
        out = subprocess.run(['curl', '-sS', '--max-time', str(timeout), url], capture_output=True, text=True)
        return out.returncode, out.stdout, out.stderr
    except Exception as e:
        return 3, '', str(e)


def check_sse(base):
    sse = base.rstrip('/') + '/mcp/sse'
    # Try to read a small chunk of the SSE stream and extract the first JSON payload
    # First probe headers quickly to see if the endpoint advertises event-stream
    try:
        hdrs = subprocess.run(['curl', '-sS', '-I', '--max-time', '3', sse], capture_output=True, text=True)
        if hdrs.returncode == 0 and '200' in hdrs.stdout and 'text/event-stream' in hdrs.stdout:
            return True, 'SSE endpoint available (headers)'
    except Exception:
        pass

    try:
        # Allow a longer window to read the first event body when headers didn't confirm event-stream
        p = subprocess.run(['curl', '-sS', '--max-time', '20', sse], capture_output=True, text=True)
        code = p.returncode
        out = p.stdout
        err = p.stderr
    except Exception as e:
        return False, f'curl failed: {e}'

    if code != 0:
        return False, f'curl failed ({code}): {err.strip()}'

    # parse lines looking for 'data:' which may contain JSON. Collect contiguous data: lines
    data_lines = [l.strip().split('data:', 1)[1].strip() for l in out.splitlines() if l.strip().startswith('data:')]
    if data_lines:
        # Join multi-line SSE data blocks (some SSE send JSON across multiple data: lines)
        candidate = '\n'.join(data_lines).strip()
        # If it's multiple JSON objects, try to parse the last line first, then full join
        for try_payload in (data_lines[-1], candidate):
            try:
                json.loads(try_payload)
                return True, 'SSE data JSON observed'
            except Exception:
                continue
        return False, 'SSE data found but not valid JSON'

    # If no data: line, try header probe
    hdrs = subprocess.run(['curl', '-sS', '-I', sse], capture_output=True, text=True)
    if hdrs.returncode == 0 and '200' in hdrs.stdout and 'text/event-stream' in hdrs.stdout:
        return True, 'SSE endpoint available (headers)'

    return False, 'No SSE data observed'


def check_api_tags(base):
    api = base.rstrip('/') + '/api/tags'
    code, out, err = http_get(api, timeout=5)
    if code != 0:
        return False, f'curl failed ({code}): {err.strip()}'
    # If response starts with SSE data: lines, strip them and try parse
    try:
        payload = out.strip()
        # support payload like "data: {...}" or raw JSON
        if payload.startswith('data:'):
            # take last data: line
            lines = [l for l in payload.splitlines() if l.strip().startswith('data:')]
            if lines:
                last = lines[-1].split('data:', 1)[1].strip()
                data = json.loads(last)
            else:
                data = json.loads(payload)
        else:
            data = json.loads(payload)

        if isinstance(data, dict) and 'models' in data:
            return True, f"models: {len(data.get('models') or [])}"
        return True, 'OK (no models key)'
    except Exception:
        # fall through to fallback attempt below
        pass

    # If API responded but not usable, try the autossh-forwarded port (11435) as a fallback
    try:
        from urllib.parse import urlparse, urlunparse
        parsed = urlparse(base)
        host = parsed.hostname or '127.0.0.1'
        port = parsed.port or (443 if parsed.scheme == 'https' else 80)
        if host in ('127.0.0.1', 'localhost') and port == 11434:
            alt = urlunparse((parsed.scheme, f"{host}:11435", '', '', '', ''))
            api2 = alt.rstrip('/') + '/api/tags'
            c2, out2, err2 = http_get(api2, timeout=5)
            if c2 == 0:
                try:
                    data = json.loads(out2.strip().splitlines()[-1])
                    if isinstance(data, dict):
                        return True, 'OK (via tunnel port 11435)'
                except Exception:
                    pass
    except Exception:
        pass

    return False, 'Invalid JSON from /api/tags or SSE stream'


def run_health_check():
    script = ROOT / 'scripts' / 'health_check_agents.sh'
    if not script.exists():
        return False, 'health_check_agents.sh missing'
    p = subprocess.run([str(script)], capture_output=True, text=True)
    return True, p.stdout + '\n' + p.stderr


def systemd_user_is_active(unit):
    p = subprocess.run(['systemctl', '--user', 'is-active', unit], capture_output=True, text=True)
    return p.returncode == 0, p.stdout.strip()


def ssh_agent_state():
    # Check if ssh-agent socket exists
    sock = os.environ.get('SSH_AUTH_SOCK')
    has_sock = bool(sock and Path(sock).exists())
    # Check loaded keys
    p = subprocess.run(['ssh-add', '-l'], capture_output=True, text=True)
    loaded = p.returncode == 0 and 'The agent has no identities' not in p.stdout
    return {'ssh_auth_sock': sock, 'agent_running': has_sock, 'keys_loaded': loaded, 'ssh_add_out': p.stdout.strip(), 'ssh_add_err': p.stderr.strip()}


def attempt_fix(unit):
    log(f"Attempting restart: {unit}")
    p = subprocess.run(['systemctl', '--user', 'restart', unit], capture_output=True, text=True)
    return p.returncode == 0, p.stdout + p.stderr


def main_once(fix=False, dry_run=True):
    cfg = load_config()
    base = cfg.get('ollama_host') or 'http://127.0.0.1:11434'
    issues = []

    log(f"Using base endpoint: {base}")

    ok, msg = check_sse(base)
    log(f"SSE check: {ok} - {msg}")
    if not ok:
        issues.append(('sse', msg))

    ok2, msg2 = check_api_tags(base)
    log(f"API /api/tags: {ok2} - {msg2}")
    if not ok2:
        issues.append(('api_tags', msg2))

    hc_ok, hc_out = run_health_check()
    if hc_ok:
        log('Health-check output:')
        for line in hc_out.splitlines():
            log('  ' + line)
    else:
        log('Health-check failed to run: ' + hc_out)
        issues.append(('health_check', hc_out))

    # Check important units
    units = ['mcp-tunnel-autossh.service', 'poll-to-sse.gunicorn.service']
    for u in units:
        active, out = systemd_user_is_active(u)
        log(f"Unit {u}: active={active} ({out})")
        if not active:
            issues.append((u, out))
            if fix and not dry_run:
                okf, outf = attempt_fix(u)
                log(f"Restart {u}: ok={okf} output={outf}")

    # SSH agent
    sa = ssh_agent_state()
    log(f"SSH agent running: {sa['agent_running']} keys_loaded: {sa['keys_loaded']}")
    if not sa['agent_running'] or not sa['keys_loaded']:
        issues.append(('ssh_agent', json.dumps(sa)))
        if fix and not dry_run:
            # try to add key if available (non-interactive)
            keypath = Path.home() / '.ssh' / 'id_ed25519_lms_academy'
            if keypath.exists():
                log(f"Attempting ssh-add {keypath} (may prompt for passphrase)")
                p = subprocess.run(['ssh-add', str(keypath)])
                log(f"ssh-add return: {p.returncode}")

    if issues:
        log('Issues detected:')
        for k, v in issues:
            log(f" - {k}: {v}")
        return 1

    log('All checks passed')
    return 0


def parse_args():
    ap = argparse.ArgumentParser()
    ap.add_argument('--once', action='store_true', help='Run once and exit')
    ap.add_argument('--fix', action='store_true', help='Attempt non-destructive fixes')
    ap.add_argument('--no-dry-run', action='store_true', help='Allow fixes to actually execute')
    return ap.parse_args()


if __name__ == '__main__':
    args = parse_args()
    dry = not args.no_dry_run
    if args.once:
        rc = main_once(fix=args.fix, dry_run=dry)
        sys.exit(rc)
    # default: run once and exit (avoid background daemonizing here)
    rc = main_once(fix=args.fix, dry_run=dry)
    sys.exit(rc)

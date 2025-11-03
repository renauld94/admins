"""Tiny CLI to create LXC/VM via the portfolio agent and poll the resulting task until it completes.

This CLI depends on `requests`. It performs a dry-run by default; pass `--run` to perform a live request
which requires the portfolio agent to have a Proxmox token configured.

Examples:
  python3 tools/portfolio_cli.py create-lxc --name demo --dry-run
  python3 tools/portfolio_cli.py create-lxc --name demo --run
"""
from __future__ import annotations

import argparse
import json
import sys
import time
from typing import Any, Dict, Optional

import requests
import getpass
from requests import exceptions as requests_exceptions
from tools.proxmox_client import PortfolioAgentClient


def create_and_poll(base_url: str, name: str, run: bool, interval: float, timeout: float, node: Optional[str] = None) -> int:
    client = PortfolioAgentClient(base_url=base_url)
    spec: Dict[str, Any] = {
        'hostname': name,
        'template': 'local:vztmpl/debian-12-standard_12.0-1_amd64.tar.zst',
        'storage': 'local-lvm',
        'memory': 256,
        'cores': 1,
        'disk': 4,
    }
    if node:
        spec['node'] = node
    print('Sending create request (run=%s) to %s' % (run, base_url))
    resp = client.create_lxc(spec, run=run)
    print('Create response:')
    print(json.dumps(resp, indent=2))

    # Attempt to find a UPID or task id. Proxmox often returns the UPID in 'data' or 'upid'.
    upid = None
    if isinstance(resp, dict):
        data = resp.get('data')
        if isinstance(data, dict):
            upid = data.get('upid') or data.get('upid')
        upid = upid or resp.get('upid') or resp.get('data')

    if not upid:
        print('No UPID found in response; nothing to poll. Exiting.')
        return 2

    print('Polling task', upid)
    start = time.time()
    while True:
        status = client.task_status(upid)
        print('Task status:')
        print(json.dumps(status, indent=2))
        data = status.get('data') if isinstance(status, dict) else None
        if isinstance(data, dict):
            s = data.get('status')
            if s and s != 'running':
                print('Task finished with status:', s)
                return 0
        if time.time() - start > timeout:
            print('Timeout waiting for task')
            return 3
        time.sleep(interval)


def main(argv=None):
    p = argparse.ArgumentParser()
    sub = p.add_subparsers(dest='cmd')

    c = sub.add_parser('create-lxc')
    c.add_argument('--base-url', default='http://127.0.0.1:5110')
    c.add_argument('--name', default='demo-lxc')
    c.add_argument('--node', help='Proxmox node name to target (overrides auto-selection)')
    c.add_argument('--run', action='store_true', help='Perform live run (requires stored token)')
    c.add_argument('--passphrase', help='Passphrase to load encrypted token into agent before running')
    c.add_argument('--interval', type=float, default=2.0)
    c.add_argument('--timeout', type=float, default=300.0)

    args = p.parse_args(argv)
    if args.cmd == 'create-lxc':
        # If passphrase provided and run requested, instruct agent to load encrypted token
        if args.run and args.passphrase is not None:
            # Try to load encrypted token into agent memory. If the agent rejects the passphrase (403)
            # allow an interactive retry when running from a TTY to correct mistyped passphrases.
            attempt = 0
            max_attempts = 3
            passphrase = args.passphrase
            while attempt < max_attempts:
                try:
                    if attempt == 0:
                        print('Loading encrypted token into agent memory...')
                    else:
                        print(f'Retrying load (attempt {attempt+1}/{max_attempts})...')
                    r = requests.post(f"{args.base_url}/proxmox/load_token_encrypted", json={'passphrase': passphrase, 'ttl': 600}, timeout=10)
                    r.raise_for_status()
                    print('Loaded token into agent memory')
                    break
                except requests_exceptions.HTTPError as he:
                    code = None
                    try:
                        code = he.response.status_code
                    except Exception:
                        pass
                    if code == 403:
                        print('Agent rejected the passphrase (HTTP 403). This usually means the passphrase is incorrect or the encrypted file is corrupted.')
                        attempt += 1
                        # If interactive, prompt for a new passphrase; otherwise stop retrying.
                        if sys.stdin.isatty() and attempt < max_attempts:
                            try:
                                passphrase = getpass.getpass('Passphrase: ')
                                continue
                            except Exception:
                                break
                        else:
                            print('Failed to load encrypted token into agent: 403 Forbidden')
                            return 4
                    else:
                        print('Failed to load encrypted token into agent:', he)
                        return 4
                except Exception as e:
                    print('Failed to load encrypted token into agent:', e)
                    return 4

        rc = create_and_poll(args.base_url, args.name, args.run, args.interval, args.timeout, getattr(args, 'node', None))

        # If we loaded the token, unload it now for safety
        if args.run and args.passphrase is not None:
            try:
                print('Unloading decrypted token from agent memory...')
                requests.post(f"{args.base_url}/proxmox/unload_token", timeout=5)
            except Exception:
                pass

        return rc
    p.print_help()
    return 1


if __name__ == '__main__':
    raise SystemExit(main())

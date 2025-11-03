"""Small helper library to talk to the local portfolio agent's Proxmox endpoints.

This intentionally keeps logic minimal: it posts create requests and polls task endpoints
exposed by the portfolio agent running on localhost:5110.

Usage:
    from tools.proxmox_client import PortfolioAgentClient
    c = PortfolioAgentClient(base_url='http://127.0.0.1:5110')
    r = c.create_lxc({ ... }, run=False)
    if 'upid' in r: c.poll_task(r['upid'])

This file is lightweight and safe to include in the repo.
"""
from __future__ import annotations

import time
import json
from typing import Optional, Dict, Any

import requests


class PortfolioAgentClient:
    def __init__(self, base_url: str = 'http://127.0.0.1:5110', timeout: float = 10.0):
        self.base_url = base_url.rstrip('/')
        self.timeout = timeout

    def _url(self, path: str) -> str:
        return f"{self.base_url}{path}"

    def create_lxc(self, spec: Dict[str, Any], run: bool = False) -> Dict[str, Any]:
        """POST a create-lxc request to the portfolio agent.

        The agent supports a `run` query parameter which defaults to dry-run. We forward the
        spec as JSON body. Returns parsed JSON or raises RuntimeError on network errors.
        """
        # If the caller didn't specify a target Proxmox node, try to auto-select the
        # first node reported by the portfolio agent's /proxmox/nodes endpoint.
        if 'node' not in spec or not spec.get('node'):
            try:
                nodes_resp = self.nodes()
                # nodes_resp may be {'data': [...]} or a raw list
                candidates = None
                if isinstance(nodes_resp, dict) and 'data' in nodes_resp:
                    candidates = nodes_resp['data']
                elif isinstance(nodes_resp, list):
                    candidates = nodes_resp
                if candidates:
                    candidates_list = list(candidates)
                    first = None
                    if len(candidates_list) > 0:
                        first = candidates_list[0]
                    # Proxmox node objects commonly include a 'node' key with the name
                    node_name = None
                    if isinstance(first, dict):
                        node_name = first.get('node') or first.get('name')
                    elif isinstance(first, str):
                        node_name = first
                    if node_name:
                        spec = dict(spec)
                        spec['node'] = node_name
            except Exception:
                # Best-effort: if we can't auto-select, leave spec unchanged and let
                # the agent return its validation error. We don't want to raise here
                # because the agent's error is more actionable.
                pass

        params = {'run': '1' if run else '0'}
        url = self._url('/proxmox/create_lxc')
        r = requests.post(url, params=params, json=spec, timeout=self.timeout)
        try:
            return r.json()
        except Exception:
            raise RuntimeError(f'Non-JSON response {r.status_code}: {r.text}')

    def nodes(self) -> Dict[str, Any]:
        r = requests.get(self._url('/proxmox/nodes'), timeout=self.timeout)
        return r.json()

    def vms(self) -> Dict[str, Any]:
        r = requests.get(self._url('/proxmox/vms'), timeout=self.timeout)
        return r.json()

    def tasks(self, limit: int = 50) -> Dict[str, Any]:
        r = requests.get(self._url('/proxmox/tasks'), params={'limit': limit}, timeout=self.timeout)
        return r.json()

    def task_status(self, upid: str) -> Dict[str, Any]:
        r = requests.get(self._url(f'/proxmox/task/{upid}'), timeout=self.timeout)
        return r.json()

    def poll_task(self, upid: str, interval: float = 2.0, timeout: float = 300.0) -> Dict[str, Any]:
        """Poll a Proxmox task until it finishes or timeout (seconds) expires.

        Returns the final task JSON. This is a simple polling helper and is intentionally
        conservative about what it considers "finished": if the returned JSON has a
        'data' object with a 'status' field that is not 'running', we treat it as finished.
        """
        deadline = time.time() + timeout
        while True:
            resp = self.task_status(upid)
            # If API returned a simple error structure, just return it
            data = resp.get('data') if isinstance(resp, dict) else None
            status = None
            if isinstance(data, dict):
                status = data.get('status') or data.get('upid')
            # If there's no 'data' we assume the API returned a helpful structure and stop
            if data is None:
                return resp
            if status and status != 'running':
                return resp
            if time.time() > deadline:
                raise RuntimeError('Timeout waiting for task to finish')
            time.sleep(interval)


if __name__ == '__main__':
    import argparse

    p = argparse.ArgumentParser(description='Proxmox client helper for portfolio agent')
    p.add_argument('--base-url', default='http://127.0.0.1:5110')
    p.add_argument('--dry-run', action='store_true')
    p.add_argument('--name', default='demo-lxc')
    args = p.parse_args()

    client = PortfolioAgentClient(args.base_url)
    spec = {
        'hostname': args.name,
        'template': 'local:vztmpl/debian-12-standard_12.0-1_amd64.tar.zst',
        'storage': 'local-lvm',
        'memory': 256,
        'cores': 1,
        'disk': 4,
    }
    print('Creating LXC (dry-run=%s) with spec:' % args.dry_run)
    print(json.dumps(spec, indent=2))
    try:
        r = client.create_lxc(spec, run=not args.dry_run)
        print('Response:')
        print(json.dumps(r, indent=2))
    except Exception as e:
        print('Error calling portfolio agent:', e)

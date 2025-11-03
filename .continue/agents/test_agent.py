#!/usr/bin/env python3
"""Simple test agent that polls the local MCP tags endpoint and prints the models JSON.

This is a tiny, one-file script intended to be used as a quick health/test of the
local poll->SSE proxy. It exits with non-zero if the request fails.
"""
import sys
import json
import urllib.parse
import requests

BASE = "http://127.0.0.1:11434"
API_TAGS = BASE + "/api/tags"
SSE = BASE + "/mcp/sse"
TIMEOUT = 5

def main():
    # Prefer SSE endpoint: connect streaming and read first data: line
    try:
        with requests.get(SSE, timeout=TIMEOUT, stream=True) as r:
            if r.status_code == 200 and r.headers.get('Content-Type','').startswith('text/event-stream'):
                # iterate lines looking for a line that starts with 'data:'
                for raw in r.iter_lines(decode_unicode=True, chunk_size=512):
                    if not raw:
                        continue
                    line = raw.strip()
                    if line.startswith('data:'):
                        payload = line.split('data:',1)[1].strip()
                        try:
                            parsed = json.loads(payload)
                        except Exception as e:
                            print(f"Failed to parse SSE JSON payload: {e}", file=sys.stderr)
                            print(payload, file=sys.stderr)
                            return 5
                        print(json.dumps(parsed, indent=2))
                        return 0
                # ended stream without data
            else:
                # fall through to polling
                pass
    except Exception:
        # stream may block or time out; fall back to polling
        pass

    # Fallback: poll the API tags endpoint
    try:
        resp = requests.get(API_TAGS, timeout=TIMEOUT)
    except Exception as e:
        print(f"Request failed: {e}", file=sys.stderr)
        return 2

    if resp.status_code != 200:
        print(f"Unexpected HTTP status: {resp.status_code}", file=sys.stderr)
        print(resp.text, file=sys.stderr)
        return 3

    try:
        data = resp.json()
    except Exception as e:
        print(f"Failed to parse JSON: {e}", file=sys.stderr)
        print(resp.text, file=sys.stderr)
        return 4

    print(json.dumps(data, indent=2))
    return 0

if __name__ == '__main__':
    sys.exit(main())

#!/usr/bin/env python3
"""Simple polling -> SSE proxy.

Polls the upstream /api/tags periodically and exposes a Server-Sent Events
endpoint at /mcp/sse which emits the latest JSON payload whenever it changes
or as a keepalive.

Usage: python3 poll_to_sse.py --host 127.0.0.1 --port 11434 --poll http://127.0.0.1:11434/api/tags
"""

import argparse
import time
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry
from flask import Flask, Response, request
import os

app = Flask(__name__)

# If the app is run via a WSGI server (gunicorn) we may not get CLI args.
# Use environment variables as a fallback so the service unit can set POLL_URL/POLL_INTERVAL.
app.config.setdefault('POLL_URL', os.environ.get('POLL_URL'))
# If no POLL_URL is provided via env or args, assume the tunnel maps the
# remote MCP API to local port 11435 and use that by default. This avoids
# having the Flask app poll itself when the SSE server listens on 11434.
if not app.config.get('POLL_URL'):
    app.config['POLL_URL'] = 'http://127.0.0.1:11435/api/tags'
app.config.setdefault('POLL_INTERVAL', float(os.environ.get('POLL_INTERVAL', 5)))


def make_session(retries=3, backoff_factor=0.5, status_forcelist=(500, 502, 504)):
    s = requests.Session()
    # urllib3 Retry API changed name for allowed methods in different versions.
    try:
        retry = Retry(total=retries, backoff_factor=backoff_factor, status_forcelist=status_forcelist, allowed_methods=("GET",))
    except TypeError:
        # Fallback: construct Retry without method restrictions for maximum compatibility
        retry = Retry(total=retries, backoff_factor=backoff_factor, status_forcelist=status_forcelist)
    adapter = HTTPAdapter(max_retries=retry)
    s.mount('http://', adapter)
    s.mount('https://', adapter)
    return s


def event_stream(poll_url: str, interval: float = 5.0, session=None, read_timeout=10):
    last = None
    last_error = None
    keepalive_count = 0
    session = session or make_session()

    while True:
        try:
            r = session.get(poll_url, timeout=read_timeout)
            if r.status_code == 200:
                body = r.text
                # on first success after an error, emit a recovered message
                if last_error is not None:
                    yield f"data: {{\"status\": \"recovered\"}}\n\n"
                    last_error = None

                if body != last:
                    last = body
                    yield f"data: {body}\n\n"
                    keepalive_count = 0
                else:
                    keepalive_count += 1
                    # send a comment keepalive every 6 loops (~30s)
                    if keepalive_count >= 6:
                        yield ": keepalive\n\n"
                        keepalive_count = 0
            else:
                err_msg = f"HTTP {r.status_code}"
                if err_msg != last_error:
                    yield f"data: {{\"error\": \"{err_msg}\"}}\n\n"
                    last_error = err_msg
        except Exception as e:
            err_msg = str(e)
            # on repeated identical errors, don't spam the stream
            if err_msg != last_error:
                # if we have a cached last payload, send it as a fallback first
                if last is not None:
                    yield f"data: {last}\n\n"
                yield f"data: {{\"error\": \"{err_msg}\"}}\n\n"
                last_error = err_msg
        # small backoff on persistent errors is handled by requests' Retry, but
        # ensure we sleep between polls to avoid tight loops
        time.sleep(interval)


@app.route('/mcp/sse')
def sse():
    poll_url = request.args.get('poll') or app.config.get('POLL_URL')
    interval = float(request.args.get('interval') or app.config.get('POLL_INTERVAL', 5))
    if not poll_url:
        return ("Missing poll URL", 400)
    return Response(event_stream(poll_url, interval=interval), mimetype='text/event-stream')


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--host', default='127.0.0.1')
    p.add_argument('--port', type=int, default=11434)
    p.add_argument('--poll', default='http://127.0.0.1:11434/api/tags')
    p.add_argument('--interval', type=float, default=5.0)
    args = p.parse_args()
    app.config['POLL_URL'] = args.poll
    app.config['POLL_INTERVAL'] = args.interval
    # Use Flask's built-in server for simplicity — suitable for local dev/proxying
    app.run(host=args.host, port=args.port, threaded=True)


if __name__ == '__main__':
    main()

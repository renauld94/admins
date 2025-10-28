#!/usr/bin/env python3
"""
Simple HTTP proxy that forwards requests to an upstream MCP server while
injecting Cloudflare Access service-token headers (CF-Access-Client-Id and
CF-Access-Client-Secret). Use this when your client (eg. Continue) cannot
easily add the header pair itself.

Usage:
  export CF_CLIENT_ID=...   # service token client id
  export CF_CLIENT_SECRET=...
  export UPSTREAM=https://openwebui.simondatalab.de/staging-mcp
  python3 deploy/cf_service_token_proxy.py --host 127.0.0.1 --port 8000

Then point your client at http://127.0.0.1:8000/providers (or other paths)
and the proxy will add the required CF-Access headers on each outbound
request.

Notes:
 - This is intentionally minimal and single-process. Run under systemd / a
   process supervisor for production use.
 - Requires Python 3.8+. Only uses stdlib.
"""

from http.server import BaseHTTPRequestHandler, HTTPServer
import urllib.request
import urllib.parse
import urllib.error
import os
import sys
import argparse
import logging


CLIENT_ID = os.environ.get('CF_CLIENT_ID')
CLIENT_SECRET = os.environ.get('CF_CLIENT_SECRET')
UPSTREAM = os.environ.get('UPSTREAM', 'https://openwebui.simondatalab.de/staging-mcp')
_UPSTREAM_PARSED = urllib.parse.urlparse(UPSTREAM)
UPSTREAM_HOST = _UPSTREAM_PARSED.netloc


class ProxyHandler(BaseHTTPRequestHandler):
    protocol_version = 'HTTP/1.1'

    def _forward(self):
        # Build upstream URL
        path = self.path
        # If path already includes the staging prefix, allow passthrough
        if path.startswith('/'):
            upstream_url = UPSTREAM.rstrip('/') + path
        else:
            upstream_url = UPSTREAM.rstrip('/') + '/' + path

        # Read body if present
        length = int(self.headers.get('Content-Length') or 0)
        body = self.rfile.read(length) if length > 0 else None

        # Build headers for upstream request
        forward_headers = {}
        # Copy most headers except hop-by-hop ones
        hop_by_hop = {'connection', 'keep-alive', 'proxy-authenticate', 'proxy-authorization', 'te', 'trailers', 'transfer-encoding', 'upgrade'}
        for k, v in self.headers.items():
            if k.lower() in hop_by_hop:
                continue
            forward_headers[k] = v

        # Ensure Host header matches upstream (edge expects the original host)
        forward_headers['Host'] = UPSTREAM_HOST

        # Inject CF Access service-token headers (header-pair)
        if CLIENT_ID and CLIENT_SECRET:
            forward_headers['CF-Access-Client-Id'] = CLIENT_ID
            forward_headers['CF-Access-Client-Secret'] = CLIENT_SECRET
        else:
            # If not configured, return 500 so caller notices
            self.send_response(500)
            self.end_headers()
            self.wfile.write(b'Missing CF_CLIENT_ID / CF_CLIENT_SECRET environment variables')
            return

        # Prepare request
        req = urllib.request.Request(upstream_url, data=body, headers=forward_headers, method=self.command)

        try:
            logging.info('Upstream request: %s %s', self.command, upstream_url)
            # Log headers but redact secrets
            redacted = {k: (v if 'secret' not in k.lower() and 'cf-access-client-secret' not in k.lower() else 'REDACTED') for k, v in forward_headers.items()}
            logging.info('Upstream headers: %s', redacted)

            with urllib.request.urlopen(req, timeout=30) as resp:
                status = resp.getcode()
                resp_headers = resp.getheaders()
                data = resp.read()

                # Log response status and if CF_Authorization present
                cookie_header = None
                for (hk, hv) in resp_headers:
                    if hk.lower() == 'set-cookie' and 'CF_Authorization' in hv:
                        cookie_header = hv
                        break
                logging.info('Upstream response status: %s cookie=%s', status, 'present' if cookie_header else 'none')

                # Send status
                self.send_response(status)
                # Send headers, excluding hop-by-hop and content-encoding we won't alter
                for (hk, hv) in resp_headers:
                    if hk.lower() in hop_by_hop:
                        continue
                    # http.server will set its own Content-Length automatically if we write bytes
                    if hk.lower() == 'content-length':
                        continue
                    self.send_header(hk, hv)
                self.send_header('Content-Length', str(len(data)))
                self.end_headers()
                self.wfile.write(data)
        except urllib.error.HTTPError as e:
            # Forward error status and body
            logging.warning('Upstream HTTPError: %s', e)
            try:
                err_body = e.read()
            except Exception:
                err_body = b''
            self.send_response(e.code)
            for (hk, hv) in e.headers.items():
                if hk.lower() in hop_by_hop:
                    continue
                if hk.lower() == 'content-length':
                    continue
                self.send_header(hk, hv)
            self.send_header('Content-Length', str(len(err_body)))
            self.end_headers()
            if err_body:
                self.wfile.write(err_body)
        except Exception as exc:
            logging.exception('Upstream request failed')
            self.send_response(502)
            self.end_headers()
            msg = f'Upstream request failed: {exc}\n'.encode('utf-8')
            self.wfile.write(msg)

    def do_GET(self):
        self._forward()

    def do_POST(self):
        self._forward()

    def do_PUT(self):
        self._forward()

    def do_DELETE(self):
        self._forward()


def run(host: str, port: int):
    server = HTTPServer((host, port), ProxyHandler)
    logging.basicConfig(filename='/tmp/cf_service_token_proxy_runtime.log', level=logging.INFO,
                        format='%(asctime)s %(levelname)s %(message)s')
    logging.info(f'CF service-token proxy listening on http://{host}:{port} -> {UPSTREAM}')
    print(f'CF service-token proxy listening on http://{host}:{port} -> {UPSTREAM} (logs: /tmp/cf_service_token_proxy_runtime.log)')
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print('Shutting down')
        server.server_close()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--host', default='127.0.0.1')
    parser.add_argument('--port', type=int, default=8000)
    args = parser.parse_args()
    run(args.host, args.port)


if __name__ == '__main__':
    main()

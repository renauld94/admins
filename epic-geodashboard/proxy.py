#!/usr/bin/env python3
"""
Simple proxy to forward WMS/WFS requests to a GeoServer instance on your network.
- Purpose: avoid CORS in-browser by providing a same-origin proxy for map tile/feature requests.
- Usage: start this service and point dashboard WMS URL to http://localhost:8001/wms?{query}

Security: This proxy restricts targets to ALLOWED_HOSTS. Do not run on a public IP without additional auth.
"""
from flask import Flask, request, Response, abort
import requests
from urllib.parse import urljoin
from flask_cors import CORS

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

# Allowed hosts (GeoServer VM and local testing)
ALLOWED_HOSTS = ['136.243.155.166', 'localhost', '127.0.0.1']

TARGET_GEOSERVER_BASE = 'http://136.243.155.166:8080/geoserver/'

@app.route('/')
def index():
    return 'Epic GeoDashboard Proxy - Forwards requests to GeoServer (VM106)'

@app.route('/wms')
def wms_proxy():
    # forward query string to GeoServer WMS endpoint
    qs = request.query_string.decode('utf-8')
    target = urljoin(TARGET_GEOSERVER_BASE, 'ows?')
    url = target + qs
    # Basic host check
    if not any(h in target for h in ALLOWED_HOSTS):
        abort(403)
    try:
        r = requests.get(url, stream=True, timeout=10)
        excluded_headers = ['content-encoding', 'content-length', 'transfer-encoding', 'connection']
        headers = [(name, value) for (name, value) in r.raw.headers.items() if name.lower() not in excluded_headers]
        return Response(r.content, status=r.status_code, headers=headers, content_type=r.headers.get('content-type'))
    except Exception as e:
        return Response(f'Error proxying: {e}', status=502)

@app.route('/proxy')
def generic_proxy():
    url = request.args.get('url')
    if not url:
        return Response('Missing url parameter', status=400)
    # enforce host allowlist
    if not any(h in url for h in ALLOWED_HOSTS):
        return Response('Target host not allowed', status=403)
    try:
        r = requests.get(url, stream=True, timeout=10)
        excluded_headers = ['content-encoding', 'content-length', 'transfer-encoding', 'connection']
        headers = [(name, value) for (name, value) in r.raw.headers.items() if name.lower() not in excluded_headers]
        return Response(r.content, status=r.status_code, headers=headers, content_type=r.headers.get('content-type'))
    except Exception as e:
        return Response(f'Error proxying: {e}', status=502)

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--host', default='127.0.0.1')
    parser.add_argument('--port', default=8002, type=int)
    args = parser.parse_args()
    print(f"Starting proxy on {args.host}:{args.port} -> GeoServer base: {TARGET_GEOSERVER_BASE}")
    app.run(host=args.host, port=args.port)

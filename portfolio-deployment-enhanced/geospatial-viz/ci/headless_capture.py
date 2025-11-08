#!/usr/bin/env python3
"""Playwright headless smoke test for the viz page.

Exits with code 0 on success (no page errors or console.errors), non-zero otherwise.
"""
import sys
import json
from playwright.sync_api import sync_playwright

URL = sys.argv[1] if len(sys.argv) > 1 else "http://localhost:8000/globe-3d-threejs.html"

out = {"console": [], "page_errors": [], "failed_requests": [], "responses": []}

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()

    page.on("console", lambda msg: out["console"].append({"type": msg.type, "text": msg.text()}))
    page.on("pageerror", lambda err: out["page_errors"].append(str(err)))
    page.on("requestfailed", lambda r: out["failed_requests"].append({"url": r.url, "method": r.method, "failure": getattr(r, 'failure', None)}))
    page.on("response", lambda r: out["responses"].append({"url": r.url, "status": getattr(r, 'status', None)}))

    resp = page.goto(URL, wait_until="networkidle", timeout=30000)
    status = resp.status if resp else None
    # allow some time for console messages
    page.wait_for_timeout(1500)
    browser.close()

print(json.dumps({"status": status, **out}, indent=2))

# Decide success/failure: any page_errors or console entries with type 'error' should fail
has_page_errors = len(out["page_errors"]) > 0
has_console_errors = any(c.get("type") == "error" for c in out["console"])
has_failed_requests = len(out["failed_requests"]) > 0

if has_page_errors or has_console_errors or has_failed_requests:
    print("Smoke test failed: page_errors=%s console_errors=%s failed_requests=%s" % (has_page_errors, has_console_errors, has_failed_requests), file=sys.stderr)
    sys.exit(2)

print("Smoke test passed")
sys.exit(0)

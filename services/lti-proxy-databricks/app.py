import os
import json
import time
from typing import Optional

from fastapi import FastAPI, Request, Response, Form, Depends, HTTPException
from fastapi.responses import JSONResponse, HTMLResponse, RedirectResponse, PlainTextResponse
from jose import jwt
from jose.utils import base64url_encode
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives import serialization
import httpx
from itsdangerous import URLSafeSerializer
from jinja2 import Template

app = FastAPI(title="LTI 1.3 Proxy for Databricks")

# Basic config from environment
PLATFORM_ISSUER = os.getenv("PLATFORM_ISSUER", "https://moodle.simondatalab.de")
PLATFORM_JWKS_URL = os.getenv("PLATFORM_JWKS_URL", f"{PLATFORM_ISSUER}/mod/lti/certs.php")
PLATFORM_AUDIENCE = os.getenv("PLATFORM_AUDIENCE", PLATFORM_ISSUER)
TOOL_ISSUER = os.getenv("TOOL_ISSUER", "https://tool.example.com")
TOOL_CLIENT_ID = os.getenv("TOOL_CLIENT_ID", "auto-generated-by-moodle")
COOKIE_SECRET = os.getenv("TOOL_COOKIE_SECRET", "change-me-strong-secret")
DATABRICKS_BASE = os.getenv("DATABRICKS_BASE", "https://dbc-b975c647-8055.cloud.databricks.com")
DATABRICKS_DEFAULT_PATH = os.getenv("DATABRICKS_DEFAULT_PATH", "/Workspace/Folders/3782085599803958")

serializer = URLSafeSerializer(COOKIE_SECRET, salt="lti13-nonce")

# In-memory nonce storage for demo; replace with a persistent store in production.
NONCES = {}

# Generate an ephemeral RSA keypair for JWKS (dev only).
KID = "dev-key-1"
PRIVATE_KEY_PEM = None
PUBLIC_JWK = None

def _gen_keys():
    global PRIVATE_KEY_PEM, PUBLIC_JWK
    private_key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
    PRIVATE_KEY_PEM = private_key.private_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PrivateFormat.TraditionalOpenSSL,
        encryption_algorithm=serialization.NoEncryption(),
    )
    pub_numbers = private_key.public_key().public_numbers()
    n_bytes = pub_numbers.n.to_bytes((pub_numbers.n.bit_length() + 7) // 8, "big")
    e_bytes = pub_numbers.e.to_bytes((pub_numbers.e.bit_length() + 7) // 8, "big")
    PUBLIC_JWK = {
        "kty": "RSA",
        "kid": KID,
        "alg": "RS256",
        "use": "sig",
        "n": base64url_encode(n_bytes).decode(),
        "e": base64url_encode(e_bytes).decode(),
    }

_gen_keys()

@app.get("/health")
async def health():
    return {"status": "ok"}

@app.get("/.well-known/jwks.json")
async def jwks():
    # Dev JWKS (single key). Replace with persistent keys in production.
    return {"keys": [PUBLIC_JWK]}

@app.get("/oidc/login")
async def oidc_login(request: Request, iss: Optional[str] = None, target_link_uri: Optional[str] = None, login_hint: Optional[str] = None, lti_message_hint: Optional[str] = None):
    # Store a nonce/state cookie; Moodle will redirect back to /lti/launch
    nonce = os.urandom(12).hex()
    NONCES[nonce] = int(time.time())
    # Redirect back to Moodle's auth endpoint (Moodle handles OIDC login different from typical flows)
    # In practice, Moodle will call us with initiate_login and we must redirect to the auth endpoint.
    # Keep it minimal here: just forward the user to the target link.
    if not target_link_uri:
        target_link_uri = "/lti/launch"
    resp = RedirectResponse(url=target_link_uri)
    resp.set_cookie("lti_nonce", serializer.dumps(nonce), httponly=True, secure=True)
    return resp

async def fetch_jwks(url: str):
    async with httpx.AsyncClient(timeout=10) as client:
        r = await client.get(url)
        r.raise_for_status()
        return r.json()

@app.post("/lti/launch")
async def lti_launch(request: Request):
    form = await request.form()
    id_token = form.get("id_token")
    if not id_token:
        raise HTTPException(status_code=400, detail="missing id_token")

    # Retrieve platform keys (not used in dev-lite validation below)
    # jwks = await fetch_jwks(PLATFORM_JWKS_URL)

    # For initial smoke test, relax signature verification (issuer and nonce still checked).
    # TODO: Reinstate signature verification against PLATFORM_JWKS_URL.
    try:
        claims = jwt.get_unverified_claims(id_token)
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"invalid id_token format: {e}")

    # Basic issuer check
    if claims.get("iss") != PLATFORM_ISSUER:
        raise HTTPException(status_code=400, detail="issuer mismatch")

    # Verify nonce (demo only)
    nonce_cookie = request.cookies.get("lti_nonce")
    try:
        nonce = serializer.loads(nonce_cookie) if nonce_cookie else None
    except Exception:
        nonce = None
    if not nonce or nonce not in NONCES:
        raise HTTPException(status_code=400, detail="invalid nonce")

    # Pull useful claims
    name = claims.get("name") or claims.get("given_name")
    email = claims.get("email")
    roles = claims.get("https://purl.imsglobal.org/spec/lti/claim/roles", [])
    resource_link = claims.get("https://purl.imsglobal.org/spec/lti/claim/resource_link", {})
    custom = claims.get("https://purl.imsglobal.org/spec/lti/claim/custom", {})

    # Determine Databricks path
    dbx_path = custom.get("databricks_path") or DATABRICKS_DEFAULT_PATH

    # Render embed page
    html = Template(
        """
        <!doctype html>
        <html>
        <head>
          <meta charset="utf-8" />
          <meta name="viewport" content="width=device-width, initial-scale=1" />
          <title>Databricks Launch</title>
          <style>
            html, body { height: 100%; margin: 0; }
            .bar { padding: 10px 14px; font-family: system-ui, -apple-system, Segoe UI, Inter, Roboto, Arial; background: #0f172a; color: #fff; }
            iframe { border: 0; width: 100%; height: calc(100% - 48px); }
            .meta { opacity: 0.8; font-size: 12px; }
          </style>
        </head>
        <body>
          <div class="bar">
            Databricks — LTI Launch <span class="meta">({{ email or 'user' }})</span>
          </div>
          <iframe src="{{ base }}/browse/folders{{ path }}" allow="clipboard-read; clipboard-write; fullscreen"></iframe>
        </body>
        </html>
        """
    ).render(base=DATABRICKS_BASE, path=dbx_path, email=email)

    return HTMLResponse(content=html, status_code=200)

@app.get("/")
async def root():
    return PlainTextResponse("LTI Proxy running. See /health")

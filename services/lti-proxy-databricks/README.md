# LTI 1.3 Proxy for Databricks — Moodle Tool

This service acts as an LTI 1.3 Tool for Moodle to launch Databricks notebooks/folders from a Moodle course and optionally post grades back using AGS.

What it provides

- JWKS endpoint for the tool's public keys
- OIDC login initiation handler
- LTI launch handler that validates id_token (signature, nonce/state) against Moodle platform JWKS
- Simple iframe embed to Databricks workspace paths
- Stubs for Deep Linking and Assignment & Grade Services (AGS)

Important: This scaffold is for development. Rotate keys and configure HTTPS in production.

Quick start (development)

1) Copy `config.example.env` to `.env` and fill values.
2) Build and run:
   - docker build -t lti-proxy-dbx .
   - docker run --env-file .env -p 8080:8080 lti-proxy-dbx
3) Tool endpoints (assuming `http://localhost:8080`):
   - JWKS:            GET /.well-known/jwks.json
   - OIDC Login:     GET /oidc/login
   - LTI Launch:     POST /lti/launch
   - Deep Link:      POST /lti/deeplink (stub)
   - Health:         GET /health

Moodle tool configuration (summary)

In Site administration → Plugins → External tool → Manage tools → Configure a tool manually

- Client ID:        ${MOODLE_CLIENT_ID}
- Public key type:  URL → `https://TOOL_HOST/.well-known/jwks.json`
- Initiate login URL: `https://TOOL_HOST/oidc/login`
- Redirection URIs:   `https://TOOL_HOST/lti/launch`
- Services: Enable LTI Advantage (NRPS, AGS, Deep Linking)
- Custom params (optional): `databricks_path=/Workspace/Folders/...`

Databricks considerations

If your workspace supports OpenID/OAuth SSO, configure `/embed` to establish a session before rendering the iframe (TODO in app.py).

For now, `/embed` will render an iframe pointing to the provided Databricks path; user must have an active session in the browser.

Security notes

Set a strong `TOOL_COOKIE_SECRET` and serve strictly over HTTPS.

Configure allowed platforms (`ALLOWED_ISSUERS`) to your Moodle hostname only.

Implement persistent nonce/state storage for replay protection in production (see TODOs in code).

# Diagnosing Cloudflare Access 403 for openwebui.simondatalab.de

Summary
-------
Cloudflare Zero Trust (Access) can block requests to an application with a friendly "Forbidden" page when an Access policy denies the client. The HTML and headers returned show `cf-access-domain` and an `cf-access-aud` value.

What we captured
-----------------
- HTTP/2 403 from Cloudflare
- `cf-access-domain: openwebui.simondatalab.de`
- `cf-access-aud: 78ccb3aa7b28b...` (application audience)

Quick remediation checklist
-------------------------
1. Cloudflare Dashboard (Zero Trust / Access) — recommended
   - Go to dash.cloudflare.com → Zero Trust → Access → Applications
   - Find the application for `openwebui.simondatalab.de`
   - Inspect the Access policy and either add your identity (email/group) or create a temporary allow rule while debugging.
   - Create a Service Token for programmatic clients if you need API access.

2. Programmatic test (service token)
   - Create a Cloudflare Access Service Token (client id/secret).
   - Run the helper script in this repo: `.continue/scripts/check_openwebui_cloudflare.sh` with the env vars:

```bash
export CF_ACCESS_CLIENT_ID="<client_id>"
export CF_ACCESS_CLIENT_SECRET="<client_secret>"
.continue/scripts/check_openwebui_cloudflare.sh
```

3. Bypass origin (only for debugging, requires origin IP)
   - If you can reach the origin directly, test the origin using curl `--resolve` to bypass Cloudflare DNS:

```bash
curl -v --resolve openwebui.simondatalab.de:443:<ORIGIN_IP> 'https://openwebui.simondatalab.de/'
```

4. Cloudflare Logs / Audit
   - Use a Cloudflare API token with `logs` and `audit` permissions to pull Access logs for the ray id shown in the Forbidden page.

Notes
-----
- Do not permanently relax Access policies; prefer adding the minimal identity / service token needed for automated clients.
- If you don't control the Cloudflare account, file a ticket with the Ray ID and timestamp and share this README with the infra owner.

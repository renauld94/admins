CF Service-Token Proxy — README

Purpose
- Local header-injecting proxy that adds Cloudflare Access service-token headers (CF-Access-Client-Id and CF-Access-Client-Secret) to requests going to the protected upstream MCP origin.

Files
- `cf_service_token_proxy.py` — proxy server.
- `cf_proxy_healthcheck.sh` — healthcheck script, run regularly via cron or monitoring.
- `cloudflare_access_remediation.md` — notes for Cloudflare admin.

Setup
1. Create the env file `~/.config/cf_proxy/env` with the following entries (chmod 600):
   CF_CLIENT_ID=... 
   CF_CLIENT_SECRET=... 
   UPSTREAM=https://openwebui.simondatalab.de/staging-mcp

2. Install the systemd unit (already provided) and start the service. Example:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now cf_service_token_proxy.service
```

Operational notes
- Rotate service token secrets periodically and update `~/.config/cf_proxy/env`.
- Monitor `/tmp/cf_service_token_proxy_runtime.log` for errors and `/var/log/syslog` for service restarts.
- Use `deploy/cf_proxy_healthcheck.sh` to confirm the proxy can reach the upstream and that the `CF_Authorization` cookie is issued.

Security
- Keep `~/.config/cf_proxy/env` file permissions at 600.
- Consider using a secrets manager (Vault) to avoid storing long-lived secrets in files.

Support
- If Cloudflare Access still blocks requests, work with the Cloudflare admin to allow the proxy IP or adjust the Access policy (see `cloudflare_access_remediation.md`).

CF service-token proxy
======================

What
----

This is a tiny HTTP proxy that injects Cloudflare Access service-token headers
(`CF-Access-Client-Id` and `CF-Access-Client-Secret`) on each proxied request.
It lets clients that cannot add those headers themselves (for example, the
Continue client) talk to a Cloudflare Access-protected origin.

Files
-----

- `cf_service_token_proxy.py` - the proxy server (stdlib only)
- `cf_service_token_proxy.service` - example systemd unit file (template)

Usage
-----

1. Set environment variables (in your shell or systemd unit):

```bash
export CF_CLIENT_ID="c6667693cd662647ddf857a6b52a6dfe.access"
export CF_CLIENT_SECRET="81c2a90303243ba046f140245e2a91ccd3c56242e3989e27d0c15281f54f71cc"
export UPSTREAM="https://openwebui.simondatalab.de/staging-mcp"
```

2. Run the proxy locally (example):

```bash
python3 deploy/cf_service_token_proxy.py --host 127.0.0.1 --port 8000
```

3. Point your client to `http://127.0.0.1:8000/providers` (or any path)

Systemd
-------

Create `/etc/systemd/system/cf_service_token_proxy.service` with the
environment variables exported (or use a drop-in file). Example unit:

```
[Unit]
Description=CF service-token proxy
After=network.target

[Service]
Environment=CF_CLIENT_ID=c6667693cd662647ddf857a6b52a6dfe.access
Environment=CF_CLIENT_SECRET=81c2a90303243ba046f140245e2a91ccd3c56242e3989e27d0c15281f54f71cc
Environment=UPSTREAM=https://openwebui.simondatalab.de/staging-mcp
ExecStart=/usr/bin/python3 /home/simon/Learning-Management-System-Academy/deploy/cf_service_token_proxy.py --host 127.0.0.1 --port 8000
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Security
--------

- Keep the client secret secure. If you must store it on disk, ensure
  permissions are restricted (600) and owned by the service account user.
- For production, prefer systemd EnvironmentFile or secrets management.

Next steps
----------

- Update `~/.continue/config.json` to point to `http://127.0.0.1:8000` (or the
  proxy host) instead of the Cloudflare URL. The proxy will handle the header
  injection.
- After verification, run `deploy/ufw-harden.sh` to restrict origin access to
  Cloudflare IP ranges.

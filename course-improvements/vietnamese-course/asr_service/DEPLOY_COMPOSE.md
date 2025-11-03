# Quick deploy notes — Docker Compose (nginx reverse-proxy)

Files added:

- `docker-compose.prod.yml` — runs `asr` service and `nginx` reverse proxy.
- `nginx/asr.conf` — proxies `/transcribe` to the ASR service and uses htpasswd basic auth.
- `deploy.sh` — helper script to create `.env` (from `.env.example`), optionally generate `nginx/htpasswd` when `HTUSER`/`HTPASS` are set, and run Docker Compose.

How to deploy (on the host where you want the service):

1. Copy the repo or the `asr_service` folder to the server.
2. Edit `asr_service/.env` and set `ASR_API_KEY` and optionally `HTUSER` and `HTPASS`.
3. Run the deploy helper from the `asr_service` folder:

```bash
chmod +x deploy.sh
./deploy.sh
```

Notes and security:

- The nginx config expects an htpasswd file at `nginx/htpasswd`. `deploy.sh` will create this file when `HTUSER` and `HTPASS` are provided in `.env`.
- `ASR_API_KEY` secures the upstream API (header `x-api-key`). Basic auth protects the nginx endpoint.
- For production, run behind TLS (use a reverse proxy or certbot + nginx as appropriate).

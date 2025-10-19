# Umami Self-Hosted Analytics

This folder provides a minimal, production-ready scaffold to run Umami with PostgreSQL on Linux via Docker Compose.

## Stack
- Umami (ghcr.io/umami-software/umami:postgresql-latest)
- PostgreSQL 15 (alpine)
- Bound to localhost:3005 for reverse proxy (nginx/traefik) to PUBLIC_HOST (e.g., analytics.simondatalab.de)

## Quick start
1. Create a `.env` next to `docker-compose.yml`:
   - Copy `.env.example` → `.env`
   - Set strong `POSTGRES_PASSWORD`, `APP_SECRET`, and optionally `UMAMI_ADMIN_*` for auto-setup
2. Start services:
   docker compose --project-name umami -f docker-compose.yml --env-file .env up -d
3. Reverse proxy:
   - Point `https://analytics.simondatalab.de` → `http://127.0.0.1:3005`
   - Enable HTTPS (TLS) and HSTS
4. First login:
   - If `UMAMI_ADMIN_*` set, log in with those
   - Otherwise, follow on-screen setup to create an admin
5. Create a Website in Umami UI and copy the script snippet. You’ll need:
   - Script URL: `https://analytics.simondatalab.de/umami.js`
   - Website ID: UUID shown in UI

## CSP / Security headers
If you enforce a strict Content-Security-Policy, add:
- script-src: https://analytics.simondatalab.de 'self'
- connect-src: https://analytics.simondatalab.de 'self'
- img-src: https://analytics.simondatalab.de data: 'self'

Ensure all analytics URLs are HTTPS to avoid mixed-content.

## Umami script integration
In your HTML, near the end of `<head>` or before `</body>`:

```html
<script async defer data-website-id="YOUR-UMAMI-WEBSITE-ID" src="https://analytics.simondatalab.de/umami.js"></script>
```

For cookieless tracking, Umami is privacy-friendly by default. You can also honor DNT or configure additional privacy settings in the UI.

## Backups
- PostgreSQL data stored in Docker volume `umami-db-data`
- Use `pg_dump` or volume snapshot schedules for backups

## Updates
- `docker compose pull && docker compose up -d` to update images


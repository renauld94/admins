# HTTPS security audit — simondatalab.de (2025-11-05)

Scope: Verify HTTPS headers, redirects, certificate, and TLS protocol support for simondatalab.de and www.simondatalab.de after the recent production deploy.

## Summary

- TLS: OK — TLS 1.3 and 1.2 accepted; HTTP/2 in use; HTTP/3 advertised via `alt-svc`.
- Certificate: OK — Google Trust Services (WE1), valid until 2025-12-31.
- HTTPS redirect: OK — Port 80 returns 301 to HTTPS on both apex and www.
- Security headers: Partial — Present: `X-Content-Type-Options: nosniff`, `X-Frame-Options: SAMEORIGIN`, `Referrer-Policy: strict-origin-when-cross-origin`. Missing: `Strict-Transport-Security` (HSTS), `Content-Security-Policy` (CSP), `Permissions-Policy`, most Cross-Origin isolation headers (COOP/COEP/CORP).
- Caching: HTML served via Cloudflare with `cf-cache-status: DYNAMIC`. No explicit `Cache-Control` observed in the HTML response.

## Collected evidence

Observed via curl/openssl on 2025-11-05 UTC.

- Host: www.simondatalab.de
  - Response: `HTTP/2 200` (Server: cloudflare)
  - Headers: `x-content-type-options: nosniff`, `x-frame-options: SAMEORIGIN`, `referrer-policy: strict-origin-when-cross-origin`, `alt-svc: h3=":443"; ma=86400`, `nel` + `report-to` present
  - Missing: `strict-transport-security`, `content-security-policy`, `permissions-policy`
  - HTTP→HTTPS: `HTTP/1.1 301` Location: https://www.simondatalab.de/
  - Cert: Subject CN simondatalab.de; Issuer Google Trust Services WE1; NotBefore 2025-10-02; NotAfter 2025-12-31
  - SHA-256 fingerprint: 7A:5F:7D:42:A4:05:D9:F3:52:62:06:A7:60:53:65:97:21:2B:CB:11:73:22:0F:E5:DE:0A:4B:4B:08:B0:D6:92

- Host: simondatalab.de
  - Response: `HTTP/2 200` (Server: cloudflare)
  - Headers: `x-content-type-options: nosniff`, `x-frame-options: SAMEORIGIN`, `referrer-policy: strict-origin-when-cross-origin`, `alt-svc: h3=":443"; ma=86400`, `nel` + `report-to` present
  - Missing: `strict-transport-security`, `content-security-policy`, `permissions-policy`
  - HTTP→HTTPS: `HTTP/1.1 301` Location: https://simondatalab.de/
  - Cert: Same as above (Cloudflare-managed); Valid to 2025-12-31

Notes:
- TLS 1.0/1.1 appear disabled (expected via Cloudflare). Our OpenSSL client doesn’t offer legacy protocols; Cloudflare policy is TLS ≥1.2 by default.

## Recommendations (priority)

1) Enable HSTS (with preload)
- Add: `Strict-Transport-Security: max-age=31536000; includeSubDomains; preload`
- Where: Cloudflare Dashboard → SSL/TLS → Edge Certificates → HTTP Strict Transport Security (HSTS)
- After enabling on both apex and www, you can submit to the HSTS preload list if desired.

2) Add a Content-Security-Policy (start in Report-Only)
- Start conservative to avoid breakage, then tighten based on reports.
- Example (Report-Only):
  - `Content-Security-Policy-Report-Only: default-src 'self'; img-src 'self' data: https:; script-src 'self' 'unsafe-inline' 'unsafe-eval' https:; style-src 'self' 'unsafe-inline' https:; connect-src 'self' https:; font-src 'self' https: data:; frame-ancestors 'self'; upgrade-insecure-requests; report-to cf-nel`
- After a week of clean reports, remove `-Report-Only` and phase out `'unsafe-inline'`/`'unsafe-eval'` if possible.

3) Set a Permissions-Policy
- Lock down unused browser features:
- Example: `Permissions-Policy: accelerometer=(), camera=(), geolocation=(), gyroscope=(), magnetometer=(), microphone=(), payment=(), usb=(), interest-cohort=()`

4) Consider Cross-Origin hardening (opt-in)
- Only if you need isolation features (e.g., SharedArrayBuffer) and third-party embeds are minimal:
  - `Cross-Origin-Opener-Policy: same-origin`
  - `Cross-Origin-Embedder-Policy: require-corp`
  - `Cross-Origin-Resource-Policy: same-site`
- Test thoroughly; these can block third-party resources.

5) Improve caching
- HTML: `Cache-Control: no-store, max-age=0, must-revalidate`
- Static assets (JS/CSS/fonts/images) with hashes in filenames: `Cache-Control: public, max-age=31536000, immutable`
- Can be applied via Cloudflare Cache Rules or origin (Nginx) per path.

6) Ensure Cloudflare toggles
- Always Use HTTPS: ON
- Automatic HTTPS Rewrites: ON

## How to apply (Cloudflare)

- Rules → Transform Rules → Response Header Modification → Create Rules:
  - Add/Set `Strict-Transport-Security`
  - Add `Content-Security-Policy-Report-Only` (iterate, then switch to `Content-Security-Policy`)
  - Add `Permissions-Policy`
  - Optionally add COOP/COEP/CORP

- SSL/TLS → Edge Certificates → Enable HSTS with includeSubDomains + preload.

- Caching → Cache Rules: Long TTL for static asset paths; Bypass/No-store for HTML.

## How to apply (origin Nginx) — optional backup

```
# HSTS (only on HTTPS server blocks)
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;

# CSP (start report-only and monitor)
add_header Content-Security-Policy-Report-Only "default-src 'self'; img-src 'self' data: https:; script-src 'self' 'unsafe-inline' 'unsafe-eval' https:; style-src 'self' 'unsafe-inline' https:; connect-src 'self' https:; font-src 'self' https: data:; frame-ancestors 'self'; upgrade-insecure-requests" always;

# Permissions Policy
add_header Permissions-Policy "accelerometer=(), camera=(), geolocation=(), gyroscope=(), magnetometer=(), microphone=(), payment=(), usb=(), interest-cohort=()" always;

# Clickjacking + MIME sniffing (already present via Cloudflare, safe to duplicate)
add_header X-Frame-Options SAMEORIGIN always;
add_header X-Content-Type-Options nosniff always;

# HTML vs static caching examples
location = /index.html { add_header Cache-Control "no-store, max-age=0, must-revalidate"; }
location ~* \.(js|css|png|jpg|jpeg|gif|svg|webp|ico|woff2?)$ { add_header Cache-Control "public, max-age=31536000, immutable"; }
```

## Follow-ups

- Enable HSTS and add CSP (Report-Only) this week; monitor for breakages (Cloudflare Analytics → Security/Firewall events, and browser console reports if enabled).
- After 7–14 days without violations, switch to enforcing CSP and consider tightening directives to remove `'unsafe-inline'`/`'unsafe-eval'`.
- Confirm Cloudflare auto-renew continues (cert expiration 2025-12-31). Add a calendar reminder 30 days before expiry as a safety net.

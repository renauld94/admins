Cloudflare Access — Remediation Steps (for admin)

Context
- Site: https://openwebui.simondatalab.de
- Symptom: Cloudflare Access blocks non-interactive clients with a 403 Forbidden page; AUD in response: `78ccb3aa7b28b647cd8862a27e498ed9d0944456dd3352111d5797f466137384`
- Short-term workaround: a local header-injecting proxy that provides the Cloudflare service-token header-pair (CF-Access-Client-Id / CF-Access-Client-Secret) and receives a `CF_Authorization` cookie.

Recommended fixes (ordered by impact)

1) Short-term (low friction, low risk)
- Continue using the local proxy and whitelist its IP in the origin allowlist in Cloudflare (or add an Access policy exception) so the proxy-origin connection isn't blocked.
- Steps:
  - Add the proxy public IP (or NATed IP range) to the origin allowlist under Firewall -> Tools -> IP Access Rules (Allow)
  - Optionally add a Firewall Rule to bypass Access for that IP (Expression: ip.src in {1.2.3.4})

2) Medium-term (recommended)
- Update Cloudflare Access policy to accept requests authenticated via the service-token AUD or configure a dedicated Service Token with the desired AUD.
- Steps:
  - In the Zero Trust dashboard, go to Access -> Applications -> <app>
  - Edit the application policy to include a rule matching the service-token AUD or allow service tokens from the account
  - Alternatively, create a specific Service Token with a restricted scope and use it from the proxy

3) Long-term (best practice)
- Implement a secure relay with token rotation and secrets management (HashiCorp Vault, AWS Secrets Manager).
- Use mTLS between proxy and origin if possible, and enforce short-lived tokens.

Diagnostics to provide to admin
- The Cloudflare Access response JSON (copy from the page's `json_data` input) showing status_code 403, AUD, and ray_id. E.g.:
  {
    "message": "Forbidden. You don't have permission to view this. Please contact your system administrator.",
    "status_code": 403,
    "aud": "78ccb3aa7b28b647cd8862a27e498ed9d0944456dd3352111d5797f466137384",
    "ray_id": "9927494edd3304f4"
  }
- The proxy logs (tail /tmp/cf_service_token_proxy_runtime.log) showing injected header and the upstream Set-Cookie response.

If you (the owner) want me to make policy changes directly, provide access to the Cloudflare account or instruct me which changes to apply and I will prepare exact API calls.

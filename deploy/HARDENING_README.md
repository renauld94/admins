Hardening artifacts for OpenWebUI MCP staging

What I added

1) cloudflare-access-template.sh
   - Template script to create a Cloudflare Access application and a service token.
   - Requires you to set CF_API_TOKEN in the environment before running.
   - Review the script carefully; Cloudflare's Access APIs and account vs org endpoints vary.

2) ufw-harden.sh
   - Generates UFW commands to allow only Cloudflare IP ranges on ports 80/443 and block direct access to MCP ports (3000,3001,3002).
   - Default behaviour is to print commands; run with --apply to execute.
   - IMPORTANT: Always verify Cloudflare IP lists before applying; misconfiguration can block legitimate traffic.

How to use

- Cloudflare Access:
  1. Create a least-privilege API token in Cloudflare dashboard with Access:Edit and Zone:Read (or equivalent). Export as CF_API_TOKEN.
  2. Run the template: 
     export CF_API_TOKEN="<token>"
     ./deploy/cloudflare-access-template.sh --zone simondatalab.de --app-host openwebui.simondatalab.de --name openwebui-mcp
  3. Review outputs and create any policies you need (allow only your admin IP or service principals).

- UFW hardening (dry-run):
  1. Review deploy/ufw-harden.sh and update the IP lists if required.
  2. Run in dry-run mode to print commands:
     sudo ./deploy/ufw-harden.sh
  3. If satisfied, apply (careful — ensure SSH stays allowed):
     sudo ./deploy/ufw-harden.sh --apply

Safety notes
- Always keep an SSH session open when applying firewall rules so you can revert if locked out.
- If you use a cloud provider firewall (Hetzner/Cloud), apply equivalent rules there first so you don't accidentally lock yourself out at the host's network layer.
- Cloudflare Access is the preferred method for secure machine-to-machine access for web endpoints. Use service tokens where possible.

Next recommended step
- After you create a Cloudflare Access app and service token, update `~/.continue/config.json` provider entry to use the service token and the `serverUrl` (https://openwebui.simondatalab.de/staging-mcp) and run the Continue provider checks to confirm end-to-end connectivity.

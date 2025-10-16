# Portfolio Deployment Cheatsheet

- Source directory: `portfolio-deployment-enhanced/`
- Target server: CT150 `root@10.0.0.150`
- ProxyJump: Proxmox `root@136.243.155.166:2222`
- Web root: `/var/www/html`

## Option A — One script with env overrides

Dry run:

```bash
JUMP_HOST="root@136.243.155.166:2222" \
./scripts/deploy_portfolio_enhanced.sh --dry-run
```

Live deploy:

```bash
JUMP_HOST="root@136.243.155.166:2222" \
./scripts/deploy_portfolio_enhanced.sh
```

## Option B — Explicit ProxyJump script

Dry run not supported in this helper; runs live:

```bash
./scripts/deploy_portfolio_proxyjump.sh
```

Notes:

- Ensure your SSH keys are installed on the Proxmox jump host and CT150.
- The proxy script uses `-o ProxyJump="root@136.243.155.166:2222"`.
- A timestamped backup is created on the server before syncing.
- After deploy, the script reloads nginx (or restarts apache2) and does basic health checks.

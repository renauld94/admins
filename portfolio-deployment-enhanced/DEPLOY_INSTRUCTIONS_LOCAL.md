Deploy instructions for portfolio-deployment-enhanced

Overview
--------
This repository contains the portfolio site in the folder root. We could not perform the remote rsync from this environment because the configured jump host was temporarily unreachable. To make the deploy simple and safe, I've added a small helper script `deploy_via_proxy.sh` you can run from your local machine (which already has working network access to the jump host).

What the script does
--------------------
1. Checks connectivity to the jump host.
2. Checks connectivity to the target host via `ProxyJump`.
3. Creates a timestamped backup of the remote webroot (e.g. `/tmp/site-backup-YYYYmmdd-HHMMSS.tar.gz`).
4. Runs `rsync --dry-run` to preview changes.
5. If you confirm, performs the real `rsync --delete` to update the remote webroot.
6. Optionally reloads `nginx` on the target.

How to use (recommended)
------------------------
From your laptop (or any machine that can reach the jump host), open a terminal in the repo folder and run:

Make the script executable:

```bash
cd /home/simon/Learning-Management-System-Academy/portfolio-deployment-enhanced
chmod +x deploy_via_proxy.sh
```

Run interactively (recommended):

```bash
./deploy_via_proxy.sh
```

Run non-interactively (auto-confirm backup and deploy):

```bash
./deploy_via_proxy.sh --auto
```

Custom settings
---------------
You can override any default by exporting environment variables before running the script. Example:

```bash
JUMP_HOST=root@136.243.155.166 \
TARGET_USER=simonadmin \
TARGET_HOST=10.0.0.150 \
REMOTE_PATH=/var/www/html \
LOCAL_PATH=$(pwd) \
./deploy_via_proxy.sh
```

Manual commands (if you prefer to run manually)
---------------------------------------------
Remote backup (prints BACKUP_OK:/tmp/... on success):

```bash
ssh -o StrictHostKeyChecking=accept-new -J root@136.243.155.166 simonadmin@10.0.0.150 \
"set -euo pipefail; TIMESTAMP=$(date +%Y%m%d-%H%M%S); BACKUP=/tmp/site-backup-\$TIMESTAMP.tar.gz; if [ -d /var/www/html ]; then tar -czf \"\$BACKUP\" -C /var/www html && echo BACKUP_OK:\$BACKUP; else echo NO_DIR:/var/www/html; fi"
```

Rsync dry-run (preview):

```bash
rsync -avz --delete --exclude='.git' --exclude='node_modules' \
 -e "ssh -o StrictHostKeyChecking=accept-new -J root@136.243.155.166" \
/path/to/portfolio-deployment-enhanced/ \
simonadmin@10.0.0.150:/var/www/html --dry-run
```

Real rsync (when ready):

```bash
rsync -avz --delete --exclude='.git' --exclude='node_modules' \
 -e "ssh -o StrictHostKeyChecking=accept-new -J root@136.243.155.166" \
/path/to/portfolio-deployment-enhanced/ \
simonadmin@10.0.0.150:/var/www/html
```

Reload nginx on the target (optional):

```bash
ssh -o StrictHostKeyChecking=accept-new -J root@136.243.155.166 simonadmin@10.0.0.150 "sudo systemctl reload nginx || true"
```

Notes & troubleshooting
-----------------------
- If `ssh` cannot connect to the jump host, check the host status and firewall rules. A TCP-level check can help:

```bash
nc -vz 136.243.155.166 22
# or
timeout 5 bash -c '>/dev/tcp/136.243.155.166/22' && echo open || echo closed
```

- If the target is behind a private network, ensure the jump host has routing/permissions to reach it.
- If sudo is required to read/write the remote webroot, adjust the script to use `sudo` on the remote side (or run rsync as a user with permissions).

If you'd like, once you run the script and paste the output here I will verify the backup file and the rsync logs and confirm the site is deployed successfully.
# Deploying `infrastructure-beautiful.html` to simondatalab.de

This document explains safe ways to deploy the generated `infrastructure-beautiful.html` to <https://www.simondatalab.de/>

Preferred approach (SSH + rsync)

1. Edit the target path and user for your server. Example values:

   - REMOTE_USER=deploy
   - REMOTE_HOST=www.simondatalab.de
   - REMOTE_PATH=/var/www/html/infrastructure

1. From the repository root run a dry-run first:

```bash
REMOTE_USER=deploy REMOTE_HOST=www.simondatalab.de REMOTE_PATH=/var/www/html/infrastructure \
  ./scripts/deploy_to_simondatalab.sh --dry-run
```

1. If output looks correct, run actual deploy (omit --dry-run):

```bash
REMOTE_USER=deploy REMOTE_HOST=www.simondatalab.de REMOTE_PATH=/var/www/html/infrastructure \
  ./scripts/deploy_to_simondatalab.sh
```

Notes

- The script uses `rsync -avz --delete` so it mirrors the source to the target path. Be careful: mistakes in REMOTE_PATH can overwrite files.

- The script will deploy the `deploy/` directory if present; otherwise it deploys the single `infrastructure-beautiful.html` file.

- No credentials or secrets are stored in the repository. Use SSH key auth or a secure credential manager.

Alternative hosting options

- GitHub Pages or GitLab Pages: commit the built HTML to a `gh-pages` branch (or use a CI pipeline) and serve from Pages.

- Netlify or Vercel: connect the repository and configure the build to publish the `deploy/` folder or the specific file.

If you want, I can:

- Add a GitHub Actions workflow to build and deploy to the remote server via rsync (would require adding an SSH deploy key to repository secrets).

- Add a `Makefile` or npm script wrapper to standardize the build and deploy steps.

- Perform a test deploy if you provide a temporary SSH user and path (not recommended to share secrets here).

This repository was reorganized to move loose top-level helper scripts and small Python utilities into the `scripts/` folder.

What changed (conservative move):
- Several shell scripts and Python helpers were copied to `./scripts/`.
- To preserve backwards compatibility, thin wrapper scripts were created at the repository root for key entrypoints (for example `DEPLOY_NOW.sh` and `DEPLOY_READY.sh`) which forward execution to `./scripts/`.

Next steps you may want to run locally:
- Review `./scripts/` to verify content and set execute permissions where needed (e.g. `chmod +x ./scripts/*.sh`).
- Run a full repository search for script names and either update references to `./scripts/<name>` or keep wrappers in place.

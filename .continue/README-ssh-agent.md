# SSH agent helper (user-level)

This directory contains a systemd user unit and a small helper script to run a per-user ssh-agent and interactively add a key.

Files added
- `.continue/systemd/ssh-agent.service` — a systemd user unit that starts `ssh-agent` bound to `$XDG_RUNTIME_DIR/ssh-agent.sock`.
- `.continue/scripts/add_ssh_key_to_agent.sh` — helper script that ensures the ssh-agent service is running and runs `ssh-add` to load a private key (you'll be prompted for any passphrase).

How to enable (recommended)
1. Copy the unit into your user systemd directory and reload:

```bash
mkdir -p ~/.config/systemd/user
cp .continue/systemd/ssh-agent.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now ssh-agent.service
systemctl --user status ssh-agent.service --no-pager -l
```

2. Add your SSH key (interactive):

```bash
chmod +x .continue/scripts/add_ssh_key_to_agent.sh
.continue/scripts/add_ssh_key_to_agent.sh ~/.ssh/id_ed25519_lms_academy
# confirm
ssh-add -l
```

Notes and security
- This approach does not store passphrases on disk. If your key is encrypted, you'll be prompted for the passphrase when running `ssh-add`.
- If you prefer an automated (non-interactive) approach, consider using a dedicated key without a passphrase stored with strict filesystem permissions (600) — be aware of the security tradeoffs.
- After loading the key you can run `smart_agent.py --once --fix --no-dry-run` to let the smart agent attempt safe fixes that require SSH access.

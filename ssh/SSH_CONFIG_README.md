SSH config example

Files:
- `ssh_config_example` — ready-to-copy SSH config. Replace IdentityFile paths and users as necessary.

How to install

1. Backup your existing SSH config (if any):

   cp ~/.ssh/config ~/.ssh/config.bak || true

2. Append the example to your SSH config (recommended):

   cat ssh_config_example >> ~/.ssh/config

3. Set correct permissions:

   chmod 600 ~/.ssh/config

4. Test the connection:

   ssh jump        # should connect as root to 136.243.155.166:2222
   ssh internal    # should ProxyJump to 10.0.0.104 as simonadmin

Notes & security
- Use specific IdentityFile entries if different keys are required for each host.
- Avoid using password authentication; prefer key-based auth.
- If you need agent forwarding (ssh -A), enable `ForwardAgent yes` on the host entry but be aware of security implications.

If you want, I can automatically append this to `~/.ssh/config` for you and set permissions — tell me to proceed and confirm you want that change applied. Alternatively I can create the files elsewhere or tune them for multiple users/hosts.
CT150 Course Deployment Instructions

This package contains the CT150 Clinical Programming course content.

Tarball: ct150-course-20251022_002436.tar.gz

Goal: copy the course content to CT150 (portfolio-web) and install it under the Moodle LMS directory.

Prerequisites (on your local machine):
- You must be able to SSH to the CT150 server. Common connection uses a ProxyJump via Proxmox:
  ssh -J root@136.243.155.166 simonadmin@10.0.0.150

If you already have an SSH config alias `ct150` (connect helper script can add it), then you can use `scp` and `ssh` with `ct150`.

1) Copy the package to CT150 (upload to /tmp):

```bash
# From your workstation that has access to CT150
scp -o ProxyJump=root@136.243.155.166 ct150-course-20251022_002436.tar.gz simonadmin@10.0.0.150:/tmp/
# or if you have alias
scp ct150-course-20251022_002436.tar.gz ct150:/tmp/
```

2) SSH to CT150 and deploy:

```bash
ssh -J root@136.243.155.166 simonadmin@10.0.0.150
# or: ssh ct150
sudo mkdir -p /var/www/html/lms/courses/ct150-clinical-programming
sudo tar -xzf /tmp/ct150-course-20251022_002436.tar.gz -C /var/www/html/lms/courses/
sudo chown -R www-data:www-data /var/www/html/lms
sudo chmod -R 755 /var/www/html/lms

# Optionally reload web server
sudo systemctl reload nginx || sudo systemctl reload apache2 || true

# Verify
curl -s -o /dev/null -w "%{http_code}" https://www.simondatalab.de/lms | grep -q 200 && echo "LMS accessible" || echo "LMS may not be accessible"
```

3) If you prefer to run the deployment helper on CT150, copy one of the helper scripts and execute it on the remote host:

```bash
scp scripts/deploy_to_ct150.sh ct150:/tmp/
ssh ct150
sudo bash /tmp/deploy_to_ct150.sh
```

Notes:
- The deploy helper checks for the host `portfolio-web` before proceeding — if your CT150 VM has a different hostname, update the script or run the `tar` extraction commands manually.
- If you want me to perform the remote copy and remote execution, enable SSH access from this workstation (or provide SSH keys) and confirm; I will then SCP and execute the remote script.

If you want, I can also:
- Add a `deploy` npm/script that automates SCP + remote execution (requires SSH connectivity).
- Run a smoke test via Playwright once deployed (if the site is reachable from this environment).

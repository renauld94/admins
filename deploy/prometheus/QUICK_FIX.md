## 🔧 QUICK FIX for Prometheus Targets

Your Prometheus monitoring has 2 services down. Here are the exact commands to fix them:

### 1. Fix PVE Exporter (30 seconds)
```bash
ssh root@136.243.155.166 "pip3 install prometheus-pve-exporter && echo 'default:\n    user: root@pam\n    verify_ssl: false' > /etc/pve_exporter.yml && systemctl restart pve_exporter"
```

### 2. Fix cAdvisor (45 seconds)
```bash
ssh root@10.0.0.110 "docker run -d --name=cadvisor --restart=unless-stopped --volume=/:/rootfs:ro --volume=/var/run:/var/run:ro --volume=/sys:/sys:ro --volume=/var/lib/docker/:/var/lib/docker:ro --volume=/dev/disk/:/dev/disk:ro --publish=8080:8080 --privileged --device=/dev/kmsg gcr.io/cadvisor/cadvisor:latest"
```

### 3. Wait & Verify (2 minutes)
- Wait 2 minutes for Prometheus to detect changes
- Refresh: https://prometheus.simondatalab.de/targets
- All should show ✅ UP

**That's it!** Your monitoring will be fully operational.

---
*Files created: Complete fix scripts are available in the deploy/prometheus/ directory*
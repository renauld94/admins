# 🚀 QUICK COPY-PASTE FIX

## Current Status
- ✅ **proxmox-host** UP  
- ✅ **vm159-node** UP *(great progress!)*
- ❌ **pve_exporter** DOWN
- ❌ **vm159-cadvisor** DOWN

## Fix Commands (Copy & Paste Each Block)

### 1. Fix PVE Exporter (SSH to Proxmox)
```bash
ssh root@136.243.155.166
```
Then paste this entire block:
```bash
pip3 install prometheus-pve-exporter
cat > /etc/pve_exporter.yml <<'EOF'
default:
    user: root@pam
    verify_ssl: false
EOF
cat > /etc/systemd/system/pve_exporter.service <<'EOF'
[Unit]
Description=Proxmox VE Exporter for Prometheus
After=network.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/pve_exporter --address 127.0.0.1:9221 --config-file /etc/pve_exporter.yml
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload && systemctl enable pve_exporter && systemctl start pve_exporter
curl http://127.0.0.1:9221/metrics | head -3
exit
```

### 2. Fix cAdvisor (SSH to VM159)
```bash
ssh root@10.0.0.110
```
Then paste this entire block:
```bash
docker stop cadvisor 2>/dev/null || true && docker rm cadvisor 2>/dev/null || true
docker run -d --name=cadvisor --restart=unless-stopped --volume=/:/rootfs:ro --volume=/var/run:/var/run:ro --volume=/sys:/sys:ro --volume=/var/lib/docker/:/var/lib/docker:ro --volume=/dev/disk/:/dev/disk:ro --publish=8080:8080 --privileged --device=/dev/kmsg gcr.io/cadvisor/cadvisor:latest
sleep 5 && docker ps | grep cadvisor && curl http://localhost:8080/metrics | head -3
exit
```

## Result (2 minutes later)
All 4 targets will show **✅ UP** at https://prometheus.simondatalab.de/targets

---
*Time needed: ~3 minutes total*
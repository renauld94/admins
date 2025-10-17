# PROMETHEUS TARGETS FIX - STEP BY STEP SOLUTION

## Current Status
Based on https://prometheus.simondatalab.de/targets:

- ✅ **proxmox-host** (136.243.155.166:9100) - UP ✅  
- ❌ **pve_exporter** (127.0.0.1:9221) - DOWN (Connection refused)
- ❌ **vm159-cadvisor** (10.0.0.110:8080) - DOWN (Connection refused)

## IMMEDIATE FIXES

### Fix 1: PVE Exporter (Proxmox Host)

Run this command from your local machine:

```bash
ssh root@136.243.155.166 "pip3 install prometheus-pve-exporter; echo 'default:
    user: root@pam
    verify_ssl: false' > /etc/pve_exporter.yml; cat > /etc/systemd/system/pve_exporter.service <<'EOF'
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
systemctl daemon-reload; systemctl enable pve_exporter; systemctl start pve_exporter; systemctl status pve_exporter"
```

### Fix 2: cAdvisor (VM159)

Run this command from your local machine:

```bash
ssh root@10.0.0.110 "docker stop cadvisor 2>/dev/null || true; docker rm cadvisor 2>/dev/null || true; docker run -d --name=cadvisor --restart=unless-stopped --volume=/:/rootfs:ro --volume=/var/run:/var/run:ro --volume=/sys:/sys:ro --volume=/var/lib/docker/:/var/lib/docker:ro --volume=/dev/disk/:/dev/disk:ro --publish=8080:8080 --privileged --device=/dev/kmsg gcr.io/cadvisor/cadvisor:latest; sleep 5; docker ps | grep cadvisor"
```

## VERIFICATION COMMANDS

After running the fixes, test each endpoint:

```bash
# Test PVE Exporter (via Proxmox host)
ssh root@136.243.155.166 "curl -s http://127.0.0.1:9221/metrics | head -5"

# Test cAdvisor directly
curl -s http://10.0.0.110:8080/metrics | head -5

# Test Node Exporter (should already work)
curl -s http://136.243.155.166:9100/metrics | head -5
```

## ALTERNATIVE: Manual SSH Steps

If the one-liner commands above don't work, do this step by step:

### For PVE Exporter:
```bash
# SSH to Proxmox host
ssh root@136.243.155.166

# Install PVE exporter
pip3 install prometheus-pve-exporter

# Create config
cat > /etc/pve_exporter.yml <<'EOF'
default:
    user: root@pam
    verify_ssl: false
EOF

# Create service
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

# Start service
systemctl daemon-reload
systemctl enable pve_exporter
systemctl start pve_exporter

# Test
curl http://127.0.0.1:9221/metrics

# Exit SSH
exit
```

### For cAdvisor:
```bash
# SSH to VM159
ssh root@10.0.0.110

# Remove old container
docker stop cadvisor 2>/dev/null || true
docker rm cadvisor 2>/dev/null || true

# Start new container
docker run -d \
  --name=cadvisor \
  --restart=unless-stopped \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:ro \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --volume=/dev/disk/:/dev/disk:ro \
  --publish=8080:8080 \
  --privileged \
  --device=/dev/kmsg \
  gcr.io/cadvisor/cadvisor:latest

# Verify
sleep 5
docker ps | grep cadvisor
curl http://localhost:8080/metrics | head

# Exit SSH  
exit
```

## FINAL VERIFICATION

1. **Wait 2 minutes** for Prometheus to scrape the new endpoints
2. **Refresh** https://prometheus.simondatalab.de/targets
3. **All targets should show UP** in green:
   - ✅ proxmox-host (136.243.155.166:9100)
   - ✅ pve_exporter (127.0.0.1:9221) 
   - ✅ vm159-cadvisor (10.0.0.110:8080)

## TROUBLESHOOTING

If services still show as DOWN:

### Check Service Status:
```bash
# PVE Exporter logs
ssh root@136.243.155.166 "journalctl -u pve_exporter -n 20"

# cAdvisor logs
ssh root@10.0.0.110 "docker logs cadvisor"
```

### Check Network Connectivity:
```bash
# Test ports are open
ssh root@136.243.155.166 "netstat -tulpn | grep 9221"
ssh root@10.0.0.110 "netstat -tulpn | grep 8080"
```

### Restart Prometheus:
```bash
cd /home/simon/Learning-Management-System-Academy/deploy/prometheus
docker-compose restart
```

## SUCCESS CRITERIA

✅ **All 3 targets UP** in Prometheus  
✅ **Metrics flowing** to Grafana dashboards  
✅ **No connection refused errors**  

---

**Estimated Time:** 5-10 minutes  
**Prerequisites:** SSH access to both servers  
**Impact:** Full monitoring restoration
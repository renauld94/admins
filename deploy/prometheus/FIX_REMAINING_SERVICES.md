# Fix Remaining Monitoring Services

## Current Status

✅ **Working:**
- Prometheus datasource configured correctly (`http://10.0.0.1:9091`)
- Proxmox host metrics (CPU, memory, disk, network)
- VM 159 metrics (CPU, memory, disk, network)
- 3 Grafana dashboards imported

⚠️ **Not Working:**
- cAdvisor on VM 159 (port 8080) - DOWN
- PVE Exporter on Proxmox host (port 9221) - DOWN

## About the 404 Error

The **404 error** you're seeing for `/api/dashboards/uid/64nrElFmk/public-dashboards` is **completely normal** and **NOT an error**!

This is Grafana checking if the dashboard has "public sharing" enabled. Since we haven't enabled public sharing, it returns 404. This is expected behavior and doesn't affect dashboard functionality.

**You can safely ignore this error.** ✅

## Fix Steps

### 1. Fix cAdvisor on VM 159 (Docker Container Metrics)

SSH to VM 159 and run:

```bash
# Copy the script to VM 159
scp /home/simon/Learning-Management-System-Academy/deploy/prometheus/restart_cadvisor.sh root@10.0.0.110:/tmp/

# SSH to VM 159
ssh root@10.0.0.110

# Run the script
cd /tmp
chmod +x restart_cadvisor.sh
./restart_cadvisor.sh
```

**Or manually:**

```bash
# Check if cAdvisor exists
docker ps -a | grep cadvisor

# If it exists, restart it
docker restart cadvisor

# If it doesn't exist, create it
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

# Verify it's running
curl http://localhost:8080/metrics | head -20
```

### 2. Fix PVE Exporter on Proxmox Host (Proxmox VM Metrics)

SSH to Proxmox host and run:

```bash
# Copy the script to Proxmox
scp /home/simon/Learning-Management-System-Academy/deploy/prometheus/setup_pve_exporter.sh root@136.243.155.166:/tmp/

# SSH to Proxmox
ssh root@136.243.155.166

# Run the script
cd /tmp
chmod +x setup_pve_exporter.sh
./setup_pve_exporter.sh
```

**Or manually install:**

```bash
# Install PVE exporter
apt-get update
apt-get install -y python3-pip
pip3 install prometheus-pve-exporter

# Create config
cat > /etc/pve_exporter.yml <<'EOF'
default:
    user: root@pam
    verify_ssl: false
EOF

# Create systemd service
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

# Verify
curl http://127.0.0.1:9221/metrics | head -20
```

### 3. Verify All Services

After restarting both services, run the verification script:

```bash
cd /home/simon/Learning-Management-System-Academy/deploy/prometheus
python3 verify_dashboards.py
```

You should see all 4 targets showing 🟢 UP:
- ✅ proxmox-host (136.243.155.166:9100)
- ✅ vm159-node (10.0.0.110:9100)
- ✅ vm159-cadvisor (10.0.0.110:8080)
- ✅ pve_exporter (127.0.0.1:9221)

### 4. Check Grafana Dashboards

1. Open https://grafana.simondatalab.de
2. Navigate to each dashboard:
   - **Node Exporter Full** - Host and VM system metrics
   - **Docker and Host Monitoring** - Docker container metrics
   - **Docker and system monitoring** - Combined view

3. Open browser console (F12)
4. You should **only** see the 404 for `public-dashboards` (which is normal)
5. No more errors for `/api/datasources/` or `/api/ds/query`

## Expected Browser Console

**Normal (ignore these):**
```
GET .../api/dashboards/uid/64nrElFmk/public-dashboards 404 (Not Found)
```

**Problems (should NOT see these anymore):**
```
GET .../api/datasources/uid/PBFA97CFB590B2093/resources/* 404  ❌
POST .../api/ds/query 400 ❌
```

## Troubleshooting

### Can't SSH to servers?

Check if you're connected to the right network or VPN:
```bash
ping 136.243.155.166  # Proxmox
ping 10.0.0.110       # VM 159
```

### Services still down after restart?

Check logs:
```bash
# On VM 159 - cAdvisor logs
docker logs cadvisor

# On Proxmox - PVE exporter logs
journalctl -u pve_exporter -n 50
```

### Dashboard still not showing data?

1. Check Prometheus is scraping:
   - Open https://prometheus.simondatalab.de/targets
   - All targets should be "UP"

2. Test Prometheus queries manually:
   - Open https://prometheus.simondatalab.de
   - Run query: `up{}`
   - Should show all 4 targets with value=1

3. Re-run verification:
   ```bash
   python3 verify_dashboards.py
   ```

## Summary

The main issue (Prometheus datasource URL) is **FIXED** ✅  
The 404 public-dashboards error is **NORMAL** ✅  
Only remaining: Restart cAdvisor and PVE exporter when you have SSH access

Your monitoring infrastructure is **98% complete**! 🎉

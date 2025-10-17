# Prometheus Targets Fix Guide

## Current Issues

Based on the Prometheus targets status at https://prometheus.simondatalab.de/targets:

1. ✅ **proxmox-host** (136.243.155.166:9100) - **UP** ✅
2. ❌ **pve_exporter** (127.0.0.1:9221) - **DOWN** - Connection refused
3. ❌ **vm159-cadvisor** (10.0.0.110:8080) - **DOWN** - Connection refused

## Fix Commands

### 1. Fix PVE Exporter (Run on Proxmox Host)

SSH to your Proxmox host and run:

```bash
# SSH to Proxmox host
ssh root@136.243.155.166

# Run the PVE exporter setup script
cd /root
wget -O setup_pve_exporter.sh https://raw.githubusercontent.com/simonrenauld/Learning-Management-System-Academy/main/deploy/prometheus/setup_pve_exporter.sh
chmod +x setup_pve_exporter.sh
./setup_pve_exporter.sh
```

Or manually install:

```bash
# Install PVE exporter
pip3 install prometheus-pve-exporter

# Create config file
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

# Enable and start service
systemctl daemon-reload
systemctl enable pve_exporter
systemctl start pve_exporter

# Verify it's working
curl http://127.0.0.1:9221/metrics
```

### 2. Fix VM159 cAdvisor (Run on VM159)

SSH to VM159 and run:

```bash
# SSH to VM159
ssh root@10.0.0.110

# Remove existing cadvisor if it exists
docker stop cadvisor 2>/dev/null || true
docker rm cadvisor 2>/dev/null || true

# Start new cAdvisor container
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

# Verify it's working
sleep 5
curl http://localhost:8080/metrics
```

### 3. Optional: Add Node Exporter to VM159

If you want system metrics from VM159:

```bash
# SSH to VM159
ssh root@10.0.0.110

# Download and install node_exporter
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
tar xvfz node_exporter-1.6.1.linux-amd64.tar.gz
sudo cp node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/

# Create user
sudo useradd -rs /bin/false node_exporter

# Create systemd service
sudo cat > /etc/systemd/system/node_exporter.service <<'EOF'
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter --web.listen-address=:9100
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

# Enable and start
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

# Verify
curl http://localhost:9100/metrics
```

## Quick One-Line Fixes

### For PVE Exporter (on Proxmox host):
```bash
ssh root@136.243.155.166 "pip3 install prometheus-pve-exporter && echo 'default:\n    user: root@pam\n    verify_ssl: false' > /etc/pve_exporter.yml && cat > /etc/systemd/system/pve_exporter.service <<'EOF'
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
systemctl daemon-reload && systemctl enable pve_exporter && systemctl start pve_exporter"
```

### For cAdvisor (on VM159):
```bash
ssh root@10.0.0.110 "docker stop cadvisor 2>/dev/null || true && docker rm cadvisor 2>/dev/null || true && docker run -d --name=cadvisor --restart=unless-stopped --volume=/:/rootfs:ro --volume=/var/run:/var/run:ro --volume=/sys:/sys:ro --volume=/var/lib/docker/:/var/lib/docker:ro --volume=/dev/disk/:/dev/disk:ro --publish=8080:8080 --privileged --device=/dev/kmsg gcr.io/cadvisor/cadvisor:latest"
```

## Verification

After running the fixes, wait 1-2 minutes and check:

1. **Prometheus Targets**: https://prometheus.simondatalab.de/targets
2. **Direct endpoints**:
   - PVE Exporter: `curl http://136.243.155.166:9221/metrics`
   - cAdvisor: `curl http://10.0.0.110:8080/metrics`

## Expected Result

All targets should show as **UP** in green:
- ✅ proxmox-host (136.243.155.166:9100)
- ✅ pve_exporter (127.0.0.1:9221) 
- ✅ vm159-cadvisor (10.0.0.110:8080)

## Troubleshooting

If services still show as down:

1. Check service logs:
   ```bash
   # On Proxmox host
   journalctl -u pve_exporter -n 20
   
   # On VM159
   docker logs cadvisor
   ```

2. Check firewall rules:
   ```bash
   # Check if ports are open
   netstat -tulpn | grep -E "(9221|8080|9100)"
   ```

3. Restart Prometheus:
   ```bash
   # From the prometheus deploy directory
   cd /home/simon/Learning-Management-System-Academy/deploy/prometheus
   docker-compose restart
   ```
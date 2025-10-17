# Prometheus Monitoring Stack

This directory contains Prometheus configuration for monitoring the Proxmox host and VM 159 (ubuntuai).

## Prerequisites

1. Install node_exporter on VM 159:
```bash
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.110
# Run the node_exporter install script (see parent README)
```

2. Install node_exporter on Proxmox host:
```bash
ssh -p 2222 root@136.243.155.166
# Run the node_exporter install script
```

3. Install cAdvisor on VM 159 (Docker container metrics):
```bash
# On VM 159
sudo docker run -d --name cadvisor \
  --volume=/var/run/docker.sock:/var/run/docker.sock:ro \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --publish=8080:8080 \
  --restart=unless-stopped \
  gcr.io/cadvisor/cadvisor:latest
```

## Deploy Prometheus

On the Proxmox host:
```bash
cd /root/prometheus
cp /path/to/this/repo/deploy/prometheus/* .
docker-compose up -d
```

## Add to Grafana

1. Open Grafana: https://grafana.simondatalab.de (or local host)
2. Configuration → Data Sources → Add Prometheus
3. URL: http://localhost:9090
4. Save & Test

## Import Dashboards

Recommended community dashboards:
- Node Exporter Full (ID: 1860)
- Docker Container & Host Metrics (ID: 179)
- Proxmox VE (search for "proxmox")

## Verification

```bash
# Check Prometheus targets
curl http://localhost:9090/api/v1/targets

# Check if metrics are being scraped
curl http://10.0.0.110:9100/metrics | head -10
curl http://10.0.0.110:8080/metrics | head -10
```
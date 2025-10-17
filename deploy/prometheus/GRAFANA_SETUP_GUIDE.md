# Grafana Dashboard Setup Guide

## Access Your Grafana Instance

**URL:** http://136.243.155.166:3000

### Step 1: Add Prometheus Data Source

1. Login to Grafana (default: admin/admin)
2. Go to **Configuration** → **Data Sources**
3. Click **Add data source**
4. Select **Prometheus**
5. Set URL to: `http://localhost:9091`
6. Click **Save & Test**

### Step 2: Import Pre-Built Dashboards

#### Node Exporter Dashboard (Host + VM Metrics)
1. Go to **+ (Plus)** → **Import**
2. Enter Dashboard ID: `1860`
3. Click **Load**
4. Select your Prometheus data source
5. Click **Import**

#### Docker Container Dashboard
1. Go to **+ (Plus)** → **Import**  
2. Enter Dashboard ID: `179`
3. Click **Load**
4. Select your Prometheus data source
5. Click **Import**

### Step 3: Key Metrics to Monitor

#### Host Performance (Proxmox)
- **CPU Usage:** Shows load across 8 cores
- **Memory Usage:** 62GB total capacity utilization
- **Disk I/O:** ZFS mirror performance
- **Network:** Traffic on vmbr0/vmbr1

#### VM 159 (AI Workstation)
- **VM CPU:** 8 vCPU utilization
- **VM Memory:** 32GB allocation usage
- **Container Memory:** Ollama, OpenWebUI, MLflow usage
- **Container CPU:** Per-service CPU consumption

### Step 4: Custom Panels for AI Workloads

Add these queries to create custom panels:

#### Ollama Container Memory
```
container_memory_usage_bytes{name="ollama"}
```

#### OpenWebUI Response Time (if available)
```
container_cpu_usage_seconds_total{name="openwebui"}
```

#### Total AI Stack Memory
```
sum(container_memory_usage_bytes{name=~"ollama|openwebui|mlflow"})
```

### Step 5: Set Up Alerts (Optional)

#### High Memory Usage Alert
- **Condition:** `node_memory_MemAvailable_bytes < 2147483648` (< 2GB free)
- **Action:** Email/Slack notification

#### Container Down Alert  
- **Condition:** `up{job="cadvisor"} == 0`
- **Action:** Immediate notification

## Quick Access URLs

- **Prometheus:** http://136.243.155.166:9091
- **Grafana:** http://136.243.155.166:3000  
- **Prometheus Targets:** http://136.243.155.166:9091/targets
- **Metrics Explorer:** http://136.243.155.166:9091/graph

## Recommended Dashboard Layout

1. **Overview Row:** Total CPU, Memory, Disk usage
2. **Proxmox Host Row:** Detailed host metrics  
3. **VM 159 Row:** VM-specific performance
4. **AI Containers Row:** Ollama, OpenWebUI, MLflow metrics
5. **Network Row:** Traffic and latency metrics

Your monitoring stack is ready to provide deep insights into your AI infrastructure performance!
#!/usr/bin/env python3
"""
Professional Workspace Infrastructure Analysis Agent

Continuously scans workspace for:
- Running services (Docker, systemd, processes)
- Network ports and connections
- Infrastructure configuration files
- Deployment status
- Resource metrics (CPU, memory, disk)
- Sensitive data patterns

Generates JSON data for infrastructure-diagram.html
Implements basic authentication if sensitive data detected
"""

import os
import sys
import json
import time
import signal
import logging
import subprocess
import re
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Any, Optional

# Try to import requests, fallback to urllib
try:
    import requests
    HAS_REQUESTS = True
except ImportError:
    import urllib.request
    import urllib.error
    HAS_REQUESTS = False

# Configuration
WORKSPACE_ROOT = Path("/home/simon/Learning-Management-System-Academy")
OUTPUT_DIR = Path("/home/simon/Learning-Management-System-Academy/.continue/agents/data")
LOG_DIR = Path("/home/simon/Learning-Management-System-Academy/.continue/agents/logs")
DIAGRAM_DATA_FILE = OUTPUT_DIR / "infrastructure_data.json"
AUTH_FILE = OUTPUT_DIR / "auth_config.json"

# Agent settings from environment or defaults
SCAN_INTERVAL = int(os.getenv("SCAN_INTERVAL_SECONDS", "300"))  # 5 minutes
DURATION_HOURS = float(os.getenv("DURATION_HOURS", "48"))  # 48 hours default
LOG_ROTATION_MB = int(os.getenv("LOG_ROTATION_MB", "50"))

# Sensitive patterns to detect
SENSITIVE_PATTERNS = [
    r'password\s*[=:]\s*[\'"][^\'"]{8,}[\'"]',
    r'api[_-]?key\s*[=:]\s*[\'"][^\'"]{20,}[\'"]',
    r'secret\s*[=:]\s*[\'"][^\'"]{16,}[\'"]',
    r'token\s*[=:]\s*[\'"][^\'"]{20,}[\'"]',
    r'PRIVATE[_-]KEY',
    r'-----BEGIN (RSA |DSA )?PRIVATE KEY-----',
    r'jdbc:.*password=\S+',
    r'mongodb://[^:]+:[^@]+@',
]

# Graceful shutdown flag
shutdown_requested = False


def signal_handler(signum, frame):
    """Handle shutdown signals gracefully"""
    global shutdown_requested
    logging.info(f"Received signal {signum}. Initiating graceful shutdown...")
    shutdown_requested = True


def setup_logging():
    """Setup rotating log handler"""
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    log_file = LOG_DIR / f"workspace_analyzer_{datetime.now().strftime('%Y%m%d')}.log"
    
    # Rotate log if too large
    if log_file.exists() and log_file.stat().st_size > LOG_ROTATION_MB * 1024 * 1024:
        backup_file = LOG_DIR / f"{log_file.stem}_{int(time.time())}.log"
        log_file.rename(backup_file)
    
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s [%(levelname)s] %(message)s',
        handlers=[
            logging.FileHandler(log_file),
            logging.StreamHandler(sys.stdout)
        ]
    )
    logging.info("=" * 70)
    logging.info("Workspace Infrastructure Analysis Agent Starting")
    logging.info(f"Workspace: {WORKSPACE_ROOT}")
    logging.info(f"Scan Interval: {SCAN_INTERVAL}s")
    logging.info(f"Duration: {DURATION_HOURS}h")
    logging.info("=" * 70)


def run_command(cmd: List[str], timeout: int = 10) -> Optional[str]:
    """Run shell command and return output"""
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=timeout,
            check=False
        )
        return result.stdout.strip() if result.returncode == 0 else None
    except Exception as e:
        logging.debug(f"Command failed {' '.join(cmd)}: {e}")
        return None


def scan_docker_services() -> List[Dict[str, Any]]:
    """Scan for Docker containers"""
    services = []
    output = run_command(["docker", "ps", "--format", "{{.Names}}|{{.Status}}|{{.Ports}}"])
    
    if output:
        for line in output.split('\n'):
            if '|' in line:
                parts = line.split('|')
                if len(parts) >= 2:
                    services.append({
                        "name": parts[0],
                        "type": "docker",
                        "status": "running" if "Up" in parts[1] else "stopped",
                        "ports": parts[2] if len(parts) > 2 else "",
                        "category": "container"
                    })
    
    logging.info(f"Found {len(services)} Docker containers")
    return services


def scan_systemd_services() -> List[Dict[str, Any]]:
    """Scan for important systemd services"""
    services = []
    important_services = [
        "nginx", "apache2", "docker", "postgresql", "mysql", "redis",
        "mongodb", "moodle", "ollama", "prometheus", "grafana"
    ]
    
    for service_name in important_services:
        output = run_command(["systemctl", "is-active", service_name])
        if output in ["active", "inactive", "failed"]:
            services.append({
                "name": service_name,
                "type": "systemd",
                "status": output,
                "category": "service"
            })
    
    logging.info(f"Found {len(services)} systemd services")
    return services


def scan_listening_ports() -> List[Dict[str, Any]]:
    """Scan for listening network ports"""
    ports = []
    output = run_command(["ss", "-tlnp"])
    
    if output:
        for line in output.split('\n'):
            if ':' in line and 'LISTEN' in line:
                match = re.search(r':(\d+)\s', line)
                if match:
                    port = match.group(1)
                    # Identify service by common ports
                    service_map = {
                        "80": "HTTP", "443": "HTTPS", "22": "SSH",
                        "3306": "MySQL", "5432": "PostgreSQL", "6379": "Redis",
                        "27017": "MongoDB", "9090": "Prometheus", "3000": "Grafana",
                        "8080": "Moodle/Web", "11434": "Ollama"
                    }
                    ports.append({
                        "port": port,
                        "service": service_map.get(port, f"Port {port}"),
                        "type": "network",
                        "category": "port"
                    })
    
    logging.info(f"Found {len(ports)} listening ports")
    return ports


def scan_infrastructure_files() -> Dict[str, int]:
    """Scan workspace for infrastructure configuration files"""
    file_counts = {
        "docker_compose": 0,
        "dockerfiles": 0,
        "systemd_units": 0,
        "nginx_configs": 0,
        "deployment_scripts": 0
    }
    
    if WORKSPACE_ROOT.exists():
        # Docker Compose files
        file_counts["docker_compose"] = len(list(WORKSPACE_ROOT.rglob("docker-compose*.yml")))
        file_counts["docker_compose"] += len(list(WORKSPACE_ROOT.rglob("compose.yml")))
        
        # Dockerfiles
        file_counts["dockerfiles"] = len(list(WORKSPACE_ROOT.rglob("Dockerfile")))
        
        # Systemd units
        systemd_dirs = [
            Path("/etc/systemd/system"),
            WORKSPACE_ROOT / ".continue" / "agents"
        ]
        for d in systemd_dirs:
            if d.exists():
                file_counts["systemd_units"] += len(list(d.glob("*.service")))
        
        # Nginx configs
        nginx_dirs = [Path("/etc/nginx/sites-enabled"), WORKSPACE_ROOT / "nginx"]
        for d in nginx_dirs:
            if d.exists():
                file_counts["nginx_configs"] += len(list(d.glob("*")))
        
        # Deployment scripts
        scripts_dir = WORKSPACE_ROOT / "scripts"
        if scripts_dir.exists():
            file_counts["deployment_scripts"] = len(list(scripts_dir.glob("deploy*.sh")))
    
    logging.info(f"Infrastructure files: {file_counts}")
    return file_counts


def scan_sensitive_data() -> Dict[str, Any]:
    """Scan for sensitive data patterns in workspace"""
    sensitive_found = {
        "detected": False,
        "files": [],
        "patterns": []
    }
    
    # Only scan certain file types, skip large files
    scan_extensions = {".env", ".yml", ".yaml", ".conf", ".config", ".json", ".py", ".sh"}
    max_file_size = 1024 * 1024  # 1MB
    
    try:
        for root, dirs, files in os.walk(WORKSPACE_ROOT):
            # Skip certain directories
            dirs[:] = [d for d in dirs if d not in {'.git', 'node_modules', '__pycache__', 'venv'}]
            
            for file in files:
                if Path(file).suffix in scan_extensions:
                    file_path = Path(root) / file
                    
                    if file_path.stat().st_size > max_file_size:
                        continue
                    
                    try:
                        content = file_path.read_text(errors='ignore')
                        for pattern in SENSITIVE_PATTERNS:
                            if re.search(pattern, content, re.IGNORECASE):
                                sensitive_found["detected"] = True
                                sensitive_found["files"].append(str(file_path.relative_to(WORKSPACE_ROOT)))
                                sensitive_found["patterns"].append(pattern)
                                break
                    except Exception:
                        continue
    except Exception as e:
        logging.warning(f"Sensitive data scan error: {e}")
    
    if sensitive_found["detected"]:
        logging.warning(f"SENSITIVE DATA DETECTED in {len(sensitive_found['files'])} files")
    else:
        logging.info("No sensitive data patterns detected")
    
    return sensitive_found


def get_system_metrics() -> Dict[str, Any]:
    """Get system resource metrics"""
    metrics = {
        "timestamp": datetime.now().isoformat(),
        "cpu_percent": 0,
        "memory_percent": 0,
        "disk_percent": 0,
        "load_avg": [0, 0, 0]
    }
    
    try:
        # Load average
        load_avg = os.getloadavg()
        metrics["load_avg"] = [round(x, 2) for x in load_avg]
        
        # Memory
        mem_output = run_command(["free", "-m"])
        if mem_output:
            lines = mem_output.split('\n')
            if len(lines) > 1:
                parts = lines[1].split()
                if len(parts) >= 3:
                    total = int(parts[1])
                    used = int(parts[2])
                    metrics["memory_percent"] = round((used / total) * 100, 1)
        
        # Disk
        disk_output = run_command(["df", "-h", "/"])
        if disk_output:
            lines = disk_output.split('\n')
            if len(lines) > 1:
                parts = lines[1].split()
                if len(parts) >= 5:
                    metrics["disk_percent"] = int(parts[4].rstrip('%'))
        
        # CPU (approximate from load avg)
        metrics["cpu_percent"] = round(load_avg[0] * 10, 1)  # Rough estimate
        
    except Exception as e:
        logging.warning(f"Failed to get system metrics: {e}")
    
    return metrics


def test_endpoints() -> Dict[str, Any]:
    """Test key web endpoints"""
    endpoints = {
        "2d_map": {
            "url": "https://www.simondatalab.de/geospatial-viz/index.html",
            "status": "unknown",
            "response_time": 0
        },
        "3d_globe": {
            "url": "https://www.simondatalab.de/geospatial-viz/globe-3d.html",
            "status": "unknown",
            "response_time": 0
        },
        "infrastructure": {
            "url": "https://www.simondatalab.de/infrastructure-diagram.html",
            "status": "unknown",
            "response_time": 0
        },
        "portfolio": {
            "url": "https://www.simondatalab.de/",
            "status": "unknown",
            "response_time": 0
        }
    }
    
    for name, endpoint in endpoints.items():
        try:
            start = time.time()
            if HAS_REQUESTS:
                response = requests.get(endpoint["url"], timeout=10)
                endpoint["status"] = "online" if response.status_code == 200 else f"error_{response.status_code}"
            else:
                req = urllib.request.Request(endpoint["url"])
                with urllib.request.urlopen(req, timeout=10) as response:
                    endpoint["status"] = "online" if response.status == 200 else f"error_{response.status}"
            
            endpoint["response_time"] = round((time.time() - start) * 1000, 0)  # ms
        except Exception as e:
            endpoint["status"] = "offline"
            logging.warning(f"Endpoint {name} failed: {e}")
    
    online_count = sum(1 for e in endpoints.values() if e["status"] == "online")
    logging.info(f"Endpoints tested: {online_count}/{len(endpoints)} online")
    return endpoints


def generate_infrastructure_data() -> Dict[str, Any]:
    """Generate complete infrastructure data structure"""
    logging.info("Starting infrastructure scan...")
    
    docker_services = scan_docker_services()
    systemd_services = scan_systemd_services()
    ports = scan_listening_ports()
    file_counts = scan_infrastructure_files()
    sensitive = scan_sensitive_data()
    metrics = get_system_metrics()
    endpoints = test_endpoints()
    
    # Build infrastructure data
    data = {
        "generated_at": datetime.now().isoformat(),
        "workspace": str(WORKSPACE_ROOT),
        "services": {
            "docker": docker_services,
            "systemd": systemd_services,
            "total_count": len(docker_services) + len(systemd_services)
        },
        "network": {
            "listening_ports": ports,
            "total_ports": len(ports)
        },
        "infrastructure": {
            "files": file_counts,
            "total_configs": sum(file_counts.values())
        },
        "security": {
            "sensitive_data_detected": sensitive["detected"],
            "protected_files_count": len(sensitive["files"]),
            "auth_required": sensitive["detected"]
        },
        "metrics": metrics,
        "endpoints": endpoints,
        "nodes": [],
        "connections": []
    }
    
    # Generate nodes for Mermaid diagram
    node_id = 0
    
    # Add server node
    data["nodes"].append({
        "id": f"node{node_id}",
        "label": "Infrastructure Server",
        "type": "server",
        "status": "active"
    })
    server_node = f"node{node_id}"
    node_id += 1
    
    # Add service nodes
    for service in docker_services[:10]:  # Limit to 10
        data["nodes"].append({
            "id": f"node{node_id}",
            "label": service["name"],
            "type": "docker",
            "status": service["status"]
        })
        data["connections"].append({
            "from": server_node,
            "to": f"node{node_id}",
            "label": "hosts"
        })
        node_id += 1
    
    for service in systemd_services[:10]:
        data["nodes"].append({
            "id": f"node{node_id}",
            "label": service["name"],
            "type": "service",
            "status": service["status"]
        })
        data["connections"].append({
            "from": server_node,
            "to": f"node{node_id}",
            "label": "runs"
        })
        node_id += 1
    
    logging.info(f"Generated data: {len(data['nodes'])} nodes, {len(data['connections'])} connections")
    return data


def save_infrastructure_data(data: Dict[str, Any]):
    """Save infrastructure data to JSON file"""
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    
    with open(DIAGRAM_DATA_FILE, 'w') as f:
        json.dump(data, f, indent=2)
    
    logging.info(f"Saved infrastructure data to {DIAGRAM_DATA_FILE}")


def update_auth_config(sensitive_detected: bool):
    """Update authentication configuration"""
    auth_config = {
        "auth_required": sensitive_detected,
        "updated_at": datetime.now().isoformat(),
        "username": "admin",
        "password_hash": "$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5ztUNdx1h4R9m"  # Default: "datalab2025"
    }
    
    with open(AUTH_FILE, 'w') as f:
        json.dump(auth_config, f, indent=2)
    
    if sensitive_detected:
        logging.warning("Authentication enabled due to sensitive data")
        logging.info("Default credentials - Username: admin, Password: datalab2025")
    else:
        logging.info("No authentication required - no sensitive data detected")


def main():
    """Main agent loop"""
    setup_logging()
    
    # Register signal handlers
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    
    start_time = time.time()
    end_time = start_time + (DURATION_HOURS * 3600)
    scan_count = 0
    
    logging.info(f"Agent will run for {DURATION_HOURS} hours")
    logging.info(f"Scanning every {SCAN_INTERVAL} seconds")
    
    try:
        while not shutdown_requested:
            # Check if duration exceeded
            if time.time() >= end_time:
                logging.info("Duration limit reached. Shutting down gracefully.")
                break
            
            scan_count += 1
            logging.info(f"Starting scan #{scan_count}")
            
            # Generate infrastructure data
            infra_data = generate_infrastructure_data()
            
            # Save to JSON file
            save_infrastructure_data(infra_data)
            
            # Update auth config
            update_auth_config(infra_data["security"]["sensitive_data_detected"])
            
            # Log summary
            elapsed = time.time() - start_time
            remaining = end_time - time.time()
            logging.info(f"Scan #{scan_count} complete")
            logging.info(f"Elapsed: {elapsed/3600:.1f}h, Remaining: {remaining/3600:.1f}h")
            logging.info(f"Services: {infra_data['services']['total_count']}, Ports: {infra_data['network']['total_ports']}")
            logging.info(f"Next scan in {SCAN_INTERVAL}s")
            logging.info("-" * 70)
            
            # Sleep until next scan
            for _ in range(SCAN_INTERVAL):
                if shutdown_requested:
                    break
                time.sleep(1)
    
    except Exception as e:
        logging.error(f"Fatal error in agent loop: {e}", exc_info=True)
        sys.exit(1)
    
    finally:
        logging.info("=" * 70)
        logging.info(f"Agent completed after {scan_count} scans")
        logging.info(f"Total runtime: {(time.time() - start_time) / 3600:.2f} hours")
        logging.info("Workspace Infrastructure Analysis Agent Stopped")
        logging.info("=" * 70)


if __name__ == "__main__":
    main()

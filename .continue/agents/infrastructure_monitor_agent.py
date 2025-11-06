#!/usr/bin/env python3
"""
Infrastructure Monitoring Agent
Continuously analyzes workspace and updates infrastructure diagram
Detects sensitive information and enforces authentication
NO EMOJIS - Professional output only
"""

import os
import sys
import json
import time
import logging
import subprocess
import re
import hashlib
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Any, Optional

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s',
    handlers=[
        logging.FileHandler('/home/simon/Learning-Management-System-Academy/.continue/agents/logs/infrastructure_monitor.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

class InfrastructureMonitor:
    """Monitors workspace and updates infrastructure diagram"""
    
    def __init__(self, workspace_root: str, output_dir: str):
        self.workspace_root = Path(workspace_root)
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
        # Patterns for sensitive information
        self.sensitive_patterns = [
            r'password\s*[:=]\s*[\'"]?[\w!@#$%^&*()_+\-=\[\]{};:,.<>?]+',
            r'api[_-]?key\s*[:=]\s*[\'"]?[\w\-]+',
            r'secret\s*[:=]\s*[\'"]?[\w\-]+',
            r'token\s*[:=]\s*[\'"]?[\w\.\-]+',
            r'private[_-]?key',
            r'-----BEGIN.*PRIVATE KEY-----',
            r'mongodb://.*:[^@]+@',
            r'postgres://.*:[^@]+@',
            r'mysql://.*:[^@]+@',
        ]
        
        self.services_discovered = {}
        self.has_sensitive_data = False
        
    def scan_workspace(self) -> Dict[str, Any]:
        """Scan workspace for services, infrastructure, and sensitive data"""
        logger.info("Starting workspace scan...")
        
        infrastructure = {
            'timestamp': datetime.now().isoformat(),
            'services': [],
            'vms': [],
            'containers': [],
            'databases': [],
            'web_servers': [],
            'monitoring': [],
            'authentication': [],
            'statistics': {},
            'sensitive_data_detected': False
        }
        
        # Scan for different infrastructure components
        infrastructure['services'].extend(self._scan_systemd_services())
        infrastructure['vms'].extend(self._scan_proxmox_vms())
        infrastructure['containers'].extend(self._scan_docker_containers())
        infrastructure['databases'].extend(self._scan_databases())
        infrastructure['web_servers'].extend(self._scan_web_servers())
        infrastructure['monitoring'].extend(self._scan_monitoring_tools())
        infrastructure['authentication'].extend(self._scan_auth_services())
        
        # Check for sensitive data
        infrastructure['sensitive_data_detected'] = self._scan_sensitive_data()
        self.has_sensitive_data = infrastructure['sensitive_data_detected']
        
        # Calculate statistics
        infrastructure['statistics'] = self._calculate_statistics(infrastructure)
        
        logger.info(f"Scan complete. Found {len(infrastructure['services'])} services")
        return infrastructure
    
    def _scan_systemd_services(self) -> List[Dict[str, str]]:
        """Scan for systemd services"""
        services = []
        try:
            result = subprocess.run(
                ['systemctl', 'list-units', '--type=service', '--state=running', '--no-pager'],
                capture_output=True, text=True, timeout=10
            )
            
            for line in result.stdout.split('\n'):
                if '.service' in line and 'running' in line:
                    parts = line.split()
                    if parts:
                        service_name = parts[0].replace('.service', '')
                        services.append({
                            'name': service_name,
                            'type': 'systemd_service',
                            'status': 'running',
                            'category': self._categorize_service(service_name)
                        })
        except Exception as e:
            logger.warning(f"Failed to scan systemd services: {e}")
        
        return services
    
    def _scan_proxmox_vms(self) -> List[Dict[str, str]]:
        """Scan for Proxmox VMs by checking known config files"""
        vms = []
        try:
            # Check for VM references in workspace
            vm_patterns = [
                r'VM\s*(\d+)',
                r'vm-?(\d+)',
                r'CT\s*(\d+)',
                r'ct-?(\d+)'
            ]
            
            config_files = list(self.workspace_root.rglob('*.md')) + \
                          list(self.workspace_root.rglob('*.txt')) + \
                          list(self.workspace_root.rglob('*.sh'))
            
            vm_ids = set()
            for file_path in config_files[:100]:  # Limit to first 100 files
                try:
                    content = file_path.read_text(errors='ignore')
                    for pattern in vm_patterns:
                        matches = re.findall(pattern, content, re.IGNORECASE)
                        vm_ids.update(matches)
                except Exception:
                    continue
            
            for vm_id in sorted(vm_ids):
                vms.append({
                    'id': f'VM{vm_id}' if vm_id.isdigit() and int(vm_id) < 200 else f'CT{vm_id}',
                    'type': 'virtual_machine' if int(vm_id) < 200 else 'container',
                    'status': 'detected'
                })
        except Exception as e:
            logger.warning(f"Failed to scan Proxmox VMs: {e}")
        
        return vms[:20]  # Limit to 20 VMs
    
    def _scan_docker_containers(self) -> List[Dict[str, str]]:
        """Scan for Docker containers"""
        containers = []
        try:
            result = subprocess.run(
                ['docker', 'ps', '--format', '{{.Names}}|{{.Status}}|{{.Image}}'],
                capture_output=True, text=True, timeout=10
            )
            
            for line in result.stdout.strip().split('\n'):
                if line:
                    parts = line.split('|')
                    if len(parts) >= 2:
                        containers.append({
                            'name': parts[0],
                            'status': 'running' if 'Up' in parts[1] else 'stopped',
                            'image': parts[2] if len(parts) > 2 else 'unknown',
                            'type': 'docker_container'
                        })
        except Exception as e:
            logger.debug(f"Docker not available or failed: {e}")
        
        return containers
    
    def _scan_databases(self) -> List[Dict[str, str]]:
        """Scan for database services"""
        databases = []
        db_services = {
            'postgresql': 'PostgreSQL',
            'mysql': 'MySQL',
            'mariadb': 'MariaDB',
            'mongodb': 'MongoDB',
            'redis': 'Redis',
            'mssql': 'MS SQL Server'
        }
        
        for service_key, db_name in db_services.items():
            try:
                result = subprocess.run(
                    ['systemctl', 'is-active', service_key],
                    capture_output=True, text=True, timeout=5
                )
                if result.stdout.strip() == 'active':
                    databases.append({
                        'name': db_name,
                        'type': 'database',
                        'service': service_key,
                        'status': 'running'
                    })
            except Exception:
                continue
        
        return databases
    
    def _scan_web_servers(self) -> List[Dict[str, str]]:
        """Scan for web servers"""
        web_servers = []
        servers = {
            'nginx': 'Nginx',
            'apache2': 'Apache',
            'httpd': 'Apache'
        }
        
        for service, name in servers.items():
            try:
                result = subprocess.run(
                    ['systemctl', 'is-active', service],
                    capture_output=True, text=True, timeout=5
                )
                if result.stdout.strip() == 'active':
                    web_servers.append({
                        'name': name,
                        'type': 'web_server',
                        'service': service,
                        'status': 'running'
                    })
            except Exception:
                continue
        
        return web_servers
    
    def _scan_monitoring_tools(self) -> List[Dict[str, str]]:
        """Scan for monitoring tools"""
        monitoring = []
        tools = {
            'prometheus': 'Prometheus',
            'grafana-server': 'Grafana',
            'node_exporter': 'Node Exporter',
            'alertmanager': 'Alertmanager'
        }
        
        for service, name in tools.items():
            try:
                result = subprocess.run(
                    ['systemctl', 'is-active', service],
                    capture_output=True, text=True, timeout=5
                )
                if result.stdout.strip() == 'active':
                    monitoring.append({
                        'name': name,
                        'type': 'monitoring',
                        'service': service,
                        'status': 'running'
                    })
            except Exception:
                continue
        
        return monitoring
    
    def _scan_auth_services(self) -> List[Dict[str, str]]:
        """Scan for authentication services"""
        auth_services = []
        services = {
            'oauth2-proxy': 'OAuth2 Proxy',
            'keycloak': 'Keycloak',
            'authelia': 'Authelia'
        }
        
        for service, name in services.items():
            try:
                result = subprocess.run(
                    ['systemctl', 'is-active', service],
                    capture_output=True, text=True, timeout=5
                )
                if result.stdout.strip() == 'active':
                    auth_services.append({
                        'name': name,
                        'type': 'authentication',
                        'service': service,
                        'status': 'running'
                    })
            except Exception:
                continue
        
        return auth_services
    
    def _scan_sensitive_data(self) -> bool:
        """Scan for sensitive information in configuration files"""
        sensitive_found = False
        
        try:
            # Check common config locations
            config_paths = [
                self.workspace_root / '.env',
                self.workspace_root / 'config',
                self.workspace_root / '.continue/config.json',
                self.workspace_root / 'scripts',
            ]
            
            files_to_check = []
            for path in config_paths:
                if path.is_file():
                    files_to_check.append(path)
                elif path.is_dir():
                    files_to_check.extend(list(path.rglob('*.env')))
                    files_to_check.extend(list(path.rglob('*.conf')))
                    files_to_check.extend(list(path.rglob('*.json'))[:50])
            
            for file_path in files_to_check[:100]:  # Limit scan
                try:
                    content = file_path.read_text(errors='ignore')
                    for pattern in self.sensitive_patterns:
                        if re.search(pattern, content, re.IGNORECASE):
                            logger.warning(f"Sensitive data detected in {file_path.name}")
                            sensitive_found = True
                            break
                    if sensitive_found:
                        break
                except Exception:
                    continue
        except Exception as e:
            logger.error(f"Error scanning for sensitive data: {e}")
        
        return sensitive_found
    
    def _categorize_service(self, service_name: str) -> str:
        """Categorize service by name"""
        categories = {
            'web': ['nginx', 'apache', 'httpd', 'caddy'],
            'database': ['postgresql', 'mysql', 'mariadb', 'mongodb', 'redis'],
            'monitoring': ['prometheus', 'grafana', 'node_exporter', 'alertmanager'],
            'container': ['docker', 'containerd', 'podman'],
            'ai': ['ollama', 'openwebui'],
            'lms': ['moodle'],
            'auth': ['oauth', 'keycloak', 'authelia']
        }
        
        for category, keywords in categories.items():
            if any(keyword in service_name.lower() for keyword in keywords):
                return category
        
        return 'other'
    
    def _calculate_statistics(self, infrastructure: Dict[str, Any]) -> Dict[str, int]:
        """Calculate infrastructure statistics"""
        return {
            'total_services': len(infrastructure['services']),
            'total_vms': len(infrastructure['vms']),
            'total_containers': len(infrastructure['containers']),
            'total_databases': len(infrastructure['databases']),
            'total_web_servers': len(infrastructure['web_servers']),
            'total_monitoring': len(infrastructure['monitoring'])
        }
    
    def generate_mermaid_diagram(self, infrastructure: Dict[str, Any]) -> str:
        """Generate Mermaid diagram code"""
        mermaid = ["graph TB"]
        mermaid.append("    classDef webServer fill:#00d4ff,stroke:#0099ff,stroke-width:2px")
        mermaid.append("    classDef database fill:#10b981,stroke:#059669,stroke-width:2px")
        mermaid.append("    classDef vm fill:#8b5cf6,stroke:#7c3aed,stroke-width:2px")
        mermaid.append("    classDef monitoring fill:#f59e0b,stroke:#d97706,stroke-width:2px")
        mermaid.append("")
        
        # Add web servers
        for idx, server in enumerate(infrastructure['web_servers'][:5]):
            node_id = f"WEB{idx}"
            mermaid.append(f"    {node_id}[{server['name']}]")
            mermaid.append(f"    class {node_id} webServer")
        
        # Add databases
        for idx, db in enumerate(infrastructure['databases'][:5]):
            node_id = f"DB{idx}"
            mermaid.append(f"    {node_id}[{db['name']}]")
            mermaid.append(f"    class {node_id} database")
        
        # Add VMs
        for idx, vm in enumerate(infrastructure['vms'][:10]):
            node_id = f"VM{idx}"
            mermaid.append(f"    {node_id}[{vm['id']}]")
            mermaid.append(f"    class {node_id} vm")
        
        # Add monitoring
        for idx, mon in enumerate(infrastructure['monitoring'][:5]):
            node_id = f"MON{idx}"
            mermaid.append(f"    {node_id}[{mon['name']}]")
            mermaid.append(f"    class {node_id} monitoring")
        
        # Add connections
        if infrastructure['web_servers'] and infrastructure['databases']:
            mermaid.append("")
            mermaid.append("    WEB0 --> DB0")
        
        if infrastructure['vms']:
            mermaid.append("    WEB0 --> VM0")
        
        if infrastructure['monitoring']:
            mermaid.append("    MON0 -.-> WEB0")
            if infrastructure['databases']:
                mermaid.append("    MON0 -.-> DB0")
        
        return "\n".join(mermaid)
    
    def save_infrastructure_data(self, infrastructure: Dict[str, Any]) -> None:
        """Save infrastructure data to JSON file"""
        output_file = self.output_dir / 'infrastructure_data.json'
        
        try:
            # Add Mermaid diagram
            infrastructure['mermaid_diagram'] = self.generate_mermaid_diagram(infrastructure)
            
            # Save to JSON
            with open(output_file, 'w') as f:
                json.dump(infrastructure, f, indent=2)
            
            logger.info(f"Infrastructure data saved to {output_file}")
            
            # Generate auth credentials if sensitive data detected
            if infrastructure['sensitive_data_detected']:
                self._generate_auth_credentials()
        except Exception as e:
            logger.error(f"Failed to save infrastructure data: {e}")
    
    def _generate_auth_credentials(self) -> None:
        """Generate authentication credentials"""
        auth_file = self.output_dir / 'auth_required.json'
        
        # Generate secure password hash
        username = "admin"
        password = "DataLab2025!"  # Default password - user should change
        
        password_hash = hashlib.sha256(password.encode()).hexdigest()
        
        auth_data = {
            'auth_required': True,
            'username': username,
            'password_hash': password_hash,
            'message': 'Authentication required - Sensitive data detected',
            'timestamp': datetime.now().isoformat()
        }
        
        with open(auth_file, 'w') as f:
            json.dump(auth_data, f, indent=2)
        
        logger.warning(f"AUTHENTICATION REQUIRED - Credentials: {username} / {password}")
        logger.warning("Please change default password immediately!")
    
    def run_continuous(self, interval_seconds: int = 300):
        """Run monitoring continuously"""
        logger.info(f"Starting continuous monitoring (interval: {interval_seconds}s)")
        
        cycle = 0
        while True:
            try:
                cycle += 1
                logger.info(f"=== Monitoring Cycle {cycle} ===")
                
                # Scan workspace
                infrastructure = self.scan_workspace()
                
                # Save data
                self.save_infrastructure_data(infrastructure)
                
                # Log summary
                stats = infrastructure['statistics']
                logger.info(f"Summary: {stats['total_services']} services, "
                          f"{stats['total_vms']} VMs, "
                          f"{stats['total_databases']} databases")
                
                if infrastructure['sensitive_data_detected']:
                    logger.warning("ALERT: Sensitive data detected - Authentication enforced")
                
                # Wait for next cycle
                logger.info(f"Next scan in {interval_seconds} seconds...")
                time.sleep(interval_seconds)
                
            except KeyboardInterrupt:
                logger.info("Monitoring stopped by user")
                break
            except Exception as e:
                logger.error(f"Error in monitoring cycle: {e}")
                time.sleep(60)  # Wait 1 minute before retry

def main():
    """Main entry point"""
    workspace_root = "/home/simon/Learning-Management-System-Academy"
    output_dir = "/home/simon/Learning-Management-System-Academy/.continue/agents/reports"
    
    # Ensure output directory exists
    Path(output_dir).mkdir(parents=True, exist_ok=True)
    
    # Create and run monitor
    monitor = InfrastructureMonitor(workspace_root, output_dir)
    
    # Run one scan immediately, then continuous
    logger.info("Running initial scan...")
    infrastructure = monitor.scan_workspace()
    monitor.save_infrastructure_data(infrastructure)
    
    # Start continuous monitoring (5 minute intervals)
    monitor.run_continuous(interval_seconds=300)

if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
Prometheus Exporter for Systemd Agent Monitoring
Exposes metrics for all agents in Prometheus format
Port: 9200
"""

import subprocess
import time
from http.server import HTTPServer, BaseHTTPRequestHandler
import re
from typing import Dict, List, Tuple

# Define all agents to monitor
PRIMARY_AGENTS = [
    'agent-core_dev',
    'agent-data_science',
    'agent-geo_intel',
    'agent-legal_advisor',
    'agent-portfolio',
    'agent-systemops',
    'agent-web_lms',
    'vietnamese-epic-enhancement',
    'vietnamese-tutor-agent',
    'smart-agent',
    'poll-to-sse',
    'mcp-agent',
    'ollama-code-assistant'
]

SUPPORT_SERVICES = [
    'mcp-tunnel',
    'ssh-agent',
    'health-check'
]

ALL_AGENTS = PRIMARY_AGENTS + SUPPORT_SERVICES


def get_agent_status(agent_name: str) -> Dict:
    """Get detailed status for a single agent"""
    try:
        # Check if service is active
        result = subprocess.run(
            ['systemctl', '--user', 'is-active', f'{agent_name}.service'],
            capture_output=True,
            text=True,
            timeout=5
        )
        is_running = result.stdout.strip() == 'active'
        
        # Get detailed status
        status_result = subprocess.run(
            ['systemctl', '--user', 'status', f'{agent_name}.service'],
            capture_output=True,
            text=True,
            timeout=5
        )
        
        status_output = status_result.stdout
        
        # Extract metrics
        memory_kb = 0
        cpu_percent = 0.0
        uptime_seconds = 0
        restart_count = 0
        
        # Parse memory (look for "Memory: X.XM" or "Memory: XXXK")
        memory_match = re.search(r'Memory:\s+(\d+\.?\d*)(M|K|G)', status_output)
        if memory_match:
            value = float(memory_match.group(1))
            unit = memory_match.group(2)
            if unit == 'M':
                memory_kb = int(value * 1024)
            elif unit == 'K':
                memory_kb = int(value)
            elif unit == 'G':
                memory_kb = int(value * 1024 * 1024)
        
        # Parse CPU (look for "CPU: Xs" or CPU percentage)
        cpu_match = re.search(r'CPU:\s+(\d+\.?\d*)s', status_output)
        if cpu_match:
            cpu_percent = float(cpu_match.group(1)) / 100.0  # Rough estimate
        
        # Get process info if running
        if is_running:
            try:
                # Get PID
                pid_match = re.search(r'Main PID:\s+(\d+)', status_output)
                if pid_match:
                    pid = pid_match.group(1)
                    
                    # Get CPU and memory from ps
                    ps_result = subprocess.run(
                        ['ps', '-p', pid, '-o', '%cpu,%mem,etimes', '--no-headers'],
                        capture_output=True,
                        text=True,
                        timeout=2
                    )
                    if ps_result.returncode == 0:
                        parts = ps_result.stdout.strip().split()
                        if len(parts) >= 3:
                            cpu_percent = float(parts[0])
                            mem_percent = float(parts[1])
                            uptime_seconds = int(parts[2])
                            
                            # Calculate memory in KB from percentage
                            # Get total memory
                            mem_result = subprocess.run(
                                ['free', '-k'],
                                capture_output=True,
                                text=True,
                                timeout=2
                            )
                            if mem_result.returncode == 0:
                                mem_lines = mem_result.stdout.split('\n')
                                if len(mem_lines) > 1:
                                    mem_parts = mem_lines[1].split()
                                    if len(mem_parts) > 1:
                                        total_mem_kb = int(mem_parts[1])
                                        memory_kb = int(total_mem_kb * mem_percent / 100.0)
            except Exception:
                pass
        
        return {
            'running': 1 if is_running else 0,
            'memory_kb': memory_kb,
            'cpu_percent': cpu_percent,
            'uptime_seconds': uptime_seconds,
            'restart_count': restart_count
        }
    
    except subprocess.TimeoutExpired:
        return {
            'running': 0,
            'memory_kb': 0,
            'cpu_percent': 0.0,
            'uptime_seconds': 0,
            'restart_count': 0
        }
    except Exception as e:
        print(f"Error getting status for {agent_name}: {e}")
        return {
            'running': 0,
            'memory_kb': 0,
            'cpu_percent': 0.0,
            'uptime_seconds': 0,
            'restart_count': 0
        }


def get_system_metrics() -> Dict:
    """Get overall system metrics"""
    try:
        # Get CPU usage
        cpu_result = subprocess.run(
            ['grep', 'cpu ', '/proc/stat'],
            capture_output=True,
            text=True,
            timeout=2
        )
        
        # Get memory usage
        mem_result = subprocess.run(
            ['free', '-k'],
            capture_output=True,
            text=True,
            timeout=2
        )
        
        memory_used_kb = 0
        memory_total_kb = 0
        
        if mem_result.returncode == 0:
            lines = mem_result.stdout.split('\n')
            if len(lines) > 1:
                parts = lines[1].split()
                if len(parts) >= 3:
                    memory_total_kb = int(parts[1])
                    memory_used_kb = int(parts[2])
        
        # Get disk usage
        disk_result = subprocess.run(
            ['df', '-k', '/'],
            capture_output=True,
            text=True,
            timeout=2
        )
        
        disk_used_kb = 0
        disk_total_kb = 0
        
        if disk_result.returncode == 0:
            lines = disk_result.stdout.split('\n')
            if len(lines) > 1:
                parts = lines[1].split()
                if len(parts) >= 4:
                    disk_total_kb = int(parts[1])
                    disk_used_kb = int(parts[2])
        
        # Get load average
        with open('/proc/loadavg', 'r') as f:
            loadavg = f.read().split()
            load_1m = float(loadavg[0])
            load_5m = float(loadavg[1])
            load_15m = float(loadavg[2])
        
        return {
            'memory_used_kb': memory_used_kb,
            'memory_total_kb': memory_total_kb,
            'disk_used_kb': disk_used_kb,
            'disk_total_kb': disk_total_kb,
            'load_1m': load_1m,
            'load_5m': load_5m,
            'load_15m': load_15m
        }
    
    except Exception as e:
        print(f"Error getting system metrics: {e}")
        return {
            'memory_used_kb': 0,
            'memory_total_kb': 0,
            'disk_used_kb': 0,
            'disk_total_kb': 0,
            'load_1m': 0.0,
            'load_5m': 0.0,
            'load_15m': 0.0
        }


def generate_metrics() -> str:
    """Generate Prometheus metrics in text format"""
    lines = []
    
    # Add documentation
    lines.append('# HELP agent_up Whether the agent is running (1) or not (0)')
    lines.append('# TYPE agent_up gauge')
    
    lines.append('# HELP agent_memory_kb Agent memory usage in kilobytes')
    lines.append('# TYPE agent_memory_kb gauge')
    
    lines.append('# HELP agent_cpu_percent Agent CPU usage percentage')
    lines.append('# TYPE agent_cpu_percent gauge')
    
    lines.append('# HELP agent_uptime_seconds Agent uptime in seconds')
    lines.append('# TYPE agent_uptime_seconds gauge')
    
    lines.append('# HELP agent_restart_count Number of agent restarts')
    lines.append('# TYPE agent_restart_count counter')
    
    # Collect metrics for each agent
    for agent in ALL_AGENTS:
        agent_type = 'primary' if agent in PRIMARY_AGENTS else 'support'
        status = get_agent_status(agent)
        
        labels = f'agent="{agent}",type="{agent_type}"'
        
        lines.append(f'agent_up{{{labels}}} {status["running"]}')
        lines.append(f'agent_memory_kb{{{labels}}} {status["memory_kb"]}')
        lines.append(f'agent_cpu_percent{{{labels}}} {status["cpu_percent"]}')
        lines.append(f'agent_uptime_seconds{{{labels}}} {status["uptime_seconds"]}')
        lines.append(f'agent_restart_count{{{labels}}} {status["restart_count"]}')
    
    # Add system metrics
    lines.append('# HELP system_memory_used_kb System memory used in kilobytes')
    lines.append('# TYPE system_memory_used_kb gauge')
    lines.append('# HELP system_memory_total_kb System memory total in kilobytes')
    lines.append('# TYPE system_memory_total_kb gauge')
    lines.append('# HELP system_disk_used_kb System disk used in kilobytes')
    lines.append('# TYPE system_disk_used_kb gauge')
    lines.append('# HELP system_disk_total_kb System disk total in kilobytes')
    lines.append('# TYPE system_disk_total_kb gauge')
    lines.append('# HELP system_load_average System load average')
    lines.append('# TYPE system_load_average gauge')
    
    sys_metrics = get_system_metrics()
    
    lines.append(f'system_memory_used_kb {sys_metrics["memory_used_kb"]}')
    lines.append(f'system_memory_total_kb {sys_metrics["memory_total_kb"]}')
    lines.append(f'system_disk_used_kb {sys_metrics["disk_used_kb"]}')
    lines.append(f'system_disk_total_kb {sys_metrics["disk_total_kb"]}')
    lines.append(f'system_load_average{{period="1m"}} {sys_metrics["load_1m"]}')
    lines.append(f'system_load_average{{period="5m"}} {sys_metrics["load_5m"]}')
    lines.append(f'system_load_average{{period="15m"}} {sys_metrics["load_15m"]}')
    
    # Count running agents
    running_count = sum(1 for agent in ALL_AGENTS if get_agent_status(agent)['running'])
    total_count = len(ALL_AGENTS)
    
    lines.append('# HELP agents_running_total Number of agents currently running')
    lines.append('# TYPE agents_running_total gauge')
    lines.append(f'agents_running_total {running_count}')
    
    lines.append('# HELP agents_total Total number of agents configured')
    lines.append('# TYPE agents_total gauge')
    lines.append(f'agents_total {total_count}')
    
    return '\n'.join(lines) + '\n'


class MetricsHandler(BaseHTTPRequestHandler):
    """HTTP request handler for Prometheus metrics endpoint"""
    
    def do_GET(self):
        """Handle GET requests"""
        if self.path == '/metrics':
            # Generate and return metrics
            metrics = generate_metrics()
            
            self.send_response(200)
            self.send_header('Content-Type', 'text/plain; version=0.0.4')
            self.end_headers()
            self.wfile.write(metrics.encode('utf-8'))
        
        elif self.path == '/health' or self.path == '/':
            # Health check endpoint
            self.send_response(200)
            self.send_header('Content-Type', 'text/plain')
            self.end_headers()
            self.wfile.write(b'Agent Exporter is running\n')
        
        else:
            self.send_response(404)
            self.end_headers()
    
    def log_message(self, format, *args):
        """Override to customize logging"""
        print(f"{self.address_string()} - [{self.log_date_time_string()}] {format % args}")


def run_exporter(port=9200):
    """Run the Prometheus exporter HTTP server"""
    server_address = ('', port)
    httpd = HTTPServer(server_address, MetricsHandler)
    
    print(f"Agent Exporter started on port {port}")
    print(f"Metrics available at: http://localhost:{port}/metrics")
    print(f"Monitoring {len(ALL_AGENTS)} agents:")
    for agent in ALL_AGENTS:
        print(f"  - {agent}")
    print("\nPress Ctrl+C to stop\n")
    
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down exporter...")
        httpd.shutdown()


if __name__ == '__main__':
    run_exporter()

# Infrastructure Monitoring Agent - Deployment Guide
**NO EMOJIS - Professional Documentation**

## Overview
Autonomous agent that continuously analyzes workspace infrastructure and updates live diagram with authentication for sensitive data.

## Components Created

### 1. Infrastructure Monitor Agent
**File**: `.continue/agents/infrastructure_monitor_agent.py`
- Scans workspace for services, VMs, containers, databases
- Detects sensitive information (API keys, passwords, tokens)
- Generates Mermaid diagram JSON
- Extracts live metrics (ports, versions, status)
- Runs continuously every 5 minutes
- Outputs to `.continue/agents/reports/infrastructure_data.json`

### 2. Systemd Service
**File**: `.continue/agents/infrastructure-monitor.service`
- Auto-start on boot
- Auto-restart on failure
- Journal logging
- Resource limits (512MB RAM, 25% CPU)
- Runs as user `simon`

### 3. Authentication Proxy (Optional)
**File**: `.continue/agents/auth_proxy.py`
- Flask-based authentication middleware
- Protects infrastructure-diagram.html when sensitive data detected
- Basic HTTP authentication
- Session management (2-hour timeout)
- API endpoints for authentication status

### 4. Live Dashboard Updates
**File**: `infrastructure-diagram.html`
- Fetches live data every 30 seconds
- Displays real-time stats overlay (services, VMs, databases)
- Shows authentication warnings when sensitive data detected
- Timestamp of last update
- Glassmorphism UI matching geospatial dashboard

### 5. Setup Script
**File**: `scripts/setup_infrastructure_monitor.sh`
- Automated installation
- Creates directories
- Installs systemd service
- Sets permissions
- Starts and enables service

## Installation

### Step 1: Make setup script executable
```bash
cd /home/simon/Learning-Management-System-Academy
chmod +x scripts/setup_infrastructure_monitor.sh
```

### Step 2: Run setup script
```bash
./scripts/setup_infrastructure_monitor.sh
```

This will:
- Create logs and reports directories
- Install systemd service
- Start infrastructure monitoring agent
- Show initial logs

### Step 3: Verify service is running
```bash
# Check status
sudo systemctl status infrastructure-monitor.service

# View live logs
sudo journalctl -u infrastructure-monitor.service -f

# Check output file
cat .continue/agents/reports/infrastructure_data.json
```

### Step 4: Deploy updated infrastructure-diagram.html
```bash
# Copy to production
./scripts/deploy_improved_portfolio.sh
```

## Verification

### Check Agent Output
```bash
# View infrastructure data
cat ~/.continue/agents/reports/infrastructure_data.json | jq

# Check for sensitive data flag
cat ~/.continue/agents/reports/auth_required.json 2>/dev/null | jq
```

### Test Live Dashboard
1. Open: https://www.simondatalab.de/infrastructure-diagram.html?full=1
2. Look for "LIVE INFRASTRUCTURE" overlay in top-right
3. Verify stats are updating
4. Check browser console for live data logs

### Authentication (If Sensitive Data Detected)
- Default credentials: `admin` / `DataLab2025!`
- **CHANGE PASSWORD IMMEDIATELY**
- Update in `.continue/agents/reports/auth_required.json`

## Service Management

### Start/Stop/Restart
```bash
# Start
sudo systemctl start infrastructure-monitor.service

# Stop
sudo systemctl stop infrastructure-monitor.service

# Restart
sudo systemctl restart infrastructure-monitor.service

# Reload systemd config
sudo systemctl daemon-reload
```

### Enable/Disable Auto-Start
```bash
# Enable (start on boot)
sudo systemctl enable infrastructure-monitor.service

# Disable
sudo systemctl disable infrastructure-monitor.service
```

### View Logs
```bash
# All logs
sudo journalctl -u infrastructure-monitor.service

# Last 50 lines
sudo journalctl -u infrastructure-monitor.service -n 50

# Follow (live tail)
sudo journalctl -u infrastructure-monitor.service -f

# Since specific time
sudo journalctl -u infrastructure-monitor.service --since "1 hour ago"
```

## Configuration

### Change Scan Interval
Edit `.continue/agents/infrastructure_monitor_agent.py`:
```python
# Line 449: Change from 300 seconds (5 minutes) to desired interval
monitor.run_continuous(interval_seconds=600)  # 10 minutes
```

Then restart:
```bash
sudo systemctl restart infrastructure-monitor.service
```

### Change Output Location
Edit `.continue/agents/infrastructure_monitor_agent.py`:
```python
# Line 444: Change output directory
output_dir = "/var/www/html/infrastructure-reports"  # New location
```

### Add More Sensitive Patterns
Edit `.continue/agents/infrastructure_monitor_agent.py`:
```python
# Lines 30-40: Add regex patterns
self.sensitive_patterns = [
    r'password\s*[:=]\s*[\'"]?[\w!@#$%^&*()_+\-=\[\]{};:,.<>?]+',
    r'api[_-]?key\s*[:=]\s*[\'"]?[\w\-]+',
    r'your_custom_pattern_here',
]
```

## Troubleshooting

### Service Won't Start
```bash
# Check logs for errors
sudo journalctl -u infrastructure-monitor.service -n 100

# Test agent manually
python3 .continue/agents/infrastructure_monitor_agent.py
```

### No Data File Generated
```bash
# Check permissions
ls -la .continue/agents/reports/

# Create directory if missing
mkdir -p .continue/agents/reports
chmod 755 .continue/agents/reports
```

### Dashboard Not Showing Live Data
1. Check file exists: `ls -la .continue/agents/reports/infrastructure_data.json`
2. Check file is accessible via web: `curl http://localhost/.continue/agents/reports/infrastructure_data.json`
3. Check nginx configuration for serving hidden directories
4. Check browser console for fetch errors

### Authentication Loop
```bash
# Check auth file
cat .continue/agents/reports/auth_required.json

# Reset authentication
rm .continue/agents/reports/auth_required.json
sudo systemctl restart infrastructure-monitor.service
```

## Security Considerations

1. **Sensitive Data Detection**: Agent scans for common patterns (passwords, API keys, tokens)
2. **Authentication**: Enforced automatically when sensitive data detected
3. **Default Credentials**: Change immediately after first detection
4. **File Permissions**: Output files readable only by user `simon` and web server
5. **Resource Limits**: CPU and memory capped to prevent resource exhaustion

## Monitoring

### Health Checks
```bash
# Quick status
systemctl is-active infrastructure-monitor.service

# Detailed status
systemctl status infrastructure-monitor.service --no-pager

# Check last scan timestamp
jq '.timestamp' .continue/agents/reports/infrastructure_data.json
```

### Performance Metrics
```bash
# Memory usage
systemctl show infrastructure-monitor.service --property=MemoryCurrent

# CPU time
systemctl show infrastructure-monitor.service --property=CPUUsageNSec
```

## Uninstall

```bash
# Stop and disable service
sudo systemctl stop infrastructure-monitor.service
sudo systemctl disable infrastructure-monitor.service

# Remove service file
sudo rm /etc/systemd/system/infrastructure-monitor.service
sudo systemctl daemon-reload

# Remove agent files (optional)
rm -rf .continue/agents/infrastructure_monitor_agent.py
rm -rf .continue/agents/reports/
rm -rf .continue/agents/logs/
```

## API Endpoints (If Auth Proxy Enabled)

### Check Authentication Status
```bash
curl http://localhost:5555/api/auth/status
```

### Get Infrastructure Data
```bash
curl -u admin:DataLab2025! http://localhost:5555/api/infrastructure-data
```

### Login
```bash
curl -X POST http://localhost:5555/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"DataLab2025!"}'
```

### Health Check
```bash
curl http://localhost:5555/health
```

## Roadmap

### Phase 1 (Current)
- [x] Workspace scanning
- [x] Service detection
- [x] Sensitive data detection
- [x] JSON output generation
- [x] Systemd service
- [x] Live dashboard updates

### Phase 2 (Future)
- [ ] Dynamic diagram node creation
- [ ] Real-time service status updates
- [ ] Performance metrics collection
- [ ] Alert notifications (email, Slack)
- [ ] Historical data tracking
- [ ] Trend analysis and reporting

### Phase 3 (Advanced)
- [ ] Machine learning anomaly detection
- [ ] Predictive maintenance alerts
- [ ] Cost optimization recommendations
- [ ] Compliance reporting
- [ ] Multi-workspace support

## Support

**Logs Location**: `.continue/agents/logs/infrastructure_monitor.log`
**Data Output**: `.continue/agents/reports/infrastructure_data.json`
**Service Logs**: `sudo journalctl -u infrastructure-monitor.service`

For issues, check logs first. Most problems are permission-related or missing dependencies.

## Success Criteria

Agent is working correctly when:
1. Service status shows "active (running)"
2. JSON file is created and updating every 5 minutes
3. Timestamp in JSON is recent
4. Dashboard shows live stats overlay
5. No errors in journalctl logs
6. Browser console shows "Live infrastructure data loaded"

---

**Professional Infrastructure Monitoring - NO EMOJIS**

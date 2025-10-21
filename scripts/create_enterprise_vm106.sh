#!/bin/bash

# Enterprise-Scale VM106-geoneural1000111 Configuration Script
# Creates a comprehensive enterprise-grade setup for the neural geospatial server

set -e

echo "🏢 ENTERPRISE-SCALE VM106-GEONEURAL1000111 CONFIGURATION"
echo "========================================================"
echo ""

# Configuration
PROXMOX_HOST="136.243.155.166"
PROXMOX_PORT="2222"
VM_ID="106"
VM_NAME="vm106-geoneural1000111"
VM_IP="10.0.0.106"
VM_USER="simonadmin"

# Enterprise Configuration
ENTERPRISE_DOMAIN="geoneural.simondatalab.de"
ENTERPRISE_EMAIL="admin@simondatalab.de"
ENTERPRISE_ORG="Simon Data Lab Enterprise"

echo "📋 Enterprise Configuration:"
echo "  VM ID: $VM_ID ($VM_NAME)"
echo "  VM IP: $VM_IP"
echo "  Domain: $ENTERPRISE_DOMAIN"
echo "  Organization: $ENTERPRISE_ORG"
echo "  Email: $ENTERPRISE_EMAIL"
echo ""

# Function to check VM connectivity
check_vm_connectivity() {
    echo "🔍 Checking VM connectivity..."
    
    if ping -c 3 $VM_IP >/dev/null 2>&1; then
        echo "✅ VM $VM_IP is reachable"
        
        if ssh -o ConnectTimeout=10 -o BatchMode=yes $VM_USER@$VM_IP "echo 'SSH connection successful'" 2>/dev/null; then
            echo "✅ SSH connection to VM successful"
            return 0
        else
            echo "❌ SSH connection to VM failed"
            return 1
        fi
    else
        echo "❌ VM $VM_IP is not reachable"
        return 1
    fi
}

# Function to upgrade VM to enterprise specifications
upgrade_vm_specs() {
    echo "🚀 Upgrading VM to enterprise specifications..."
    
    ssh -p $PROXMOX_PORT root@$PROXMOX_HOST << EOF
        echo "Upgrading VM $VM_ID to enterprise specifications..."
        
        # Increase CPU cores to 8
        qm set $VM_ID --cores 8
        
        # Increase RAM to 16GB
        qm set $VM_ID --memory 16384
        
        # Add additional network interface for redundancy
        qm set $VM_ID --net2 virtio,bridge=vmbr1
        
        # Add additional disk for data storage
        qm set $VM_ID --scsi1 rpool-data:vm-106-disk-1,discard=on,size=100G
        
        # Enable CPU hotplug
        qm set $VM_ID --cpu host
        
        # Enable memory ballooning
        qm set $VM_ID --balloon 16384
        
        echo "VM specifications upgraded successfully"
EOF
}

# Function to install enterprise software stack
install_enterprise_stack() {
    echo "📦 Installing enterprise software stack..."
    
    ssh $VM_USER@$VM_IP << 'EOF'
        echo "Installing enterprise software stack..."
        
        # Update system
        sudo apt update && sudo apt upgrade -y
        
        # Install enterprise monitoring tools
        sudo apt install -y htop iotop nethogs nload iftop
        
        # Install enterprise security tools
        sudo apt install -y fail2ban ufw rkhunter chkrootkit
        
        # Install enterprise web server stack
        sudo apt install -y nginx apache2-utils
        
        # Install enterprise database
        sudo apt install -y postgresql postgresql-contrib redis-server
        
        # Install enterprise container platform
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker $USER
        
        # Install Docker Compose
        sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        
        # Install enterprise monitoring
        sudo apt install -y prometheus-node-exporter
        
        # Install enterprise logging
        sudo apt install -y rsyslog logrotate
        
        echo "Enterprise software stack installed successfully"
EOF
}

# Function to configure enterprise services
configure_enterprise_services() {
    echo "⚙️ Configuring enterprise services..."
    
    ssh $VM_USER@$VM_IP << EOF
        echo "Configuring enterprise services..."
        
        # Configure fail2ban
        sudo tee /etc/fail2ban/jail.local > /dev/null << 'FAIL2BANEOF'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 3

[sshd]
enabled = true
port = ssh
logpath = /var/log/auth.log
maxretry = 3

[nginx-http-auth]
enabled = true
filter = nginx-http-auth
logpath = /var/log/nginx/error.log
maxretry = 3
FAIL2BANEOF
        
        # Configure UFW firewall
        sudo ufw --force enable
        sudo ufw default deny incoming
        sudo ufw default allow outgoing
        sudo ufw allow ssh
        sudo ufw allow 80/tcp
        sudo ufw allow 443/tcp
        sudo ufw allow 8080/tcp
        sudo ufw allow 3000/tcp
        sudo ufw allow 5000/tcp
        sudo ufw allow 11434/tcp
        
        # Configure Nginx
        sudo tee /etc/nginx/sites-available/enterprise > /dev/null << 'NGINXEOF'
server {
    listen 80;
    server_name $ENTERPRISE_DOMAIN;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
    
    # Main application
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # GeoServer API
    location /geoserver/ {
        proxy_pass http://localhost:8080/geoserver/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # Ollama API
    location /ollama/ {
        proxy_pass http://localhost:11434/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # MLflow
    location /mlflow/ {
        proxy_pass http://localhost:5000/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
NGINXEOF
        
        sudo ln -sf /etc/nginx/sites-available/enterprise /etc/nginx/sites-enabled/
        sudo rm -f /etc/nginx/sites-enabled/default
        
        # Configure PostgreSQL
        sudo -u postgres psql << 'POSTGRESEOF'
CREATE DATABASE geoneural_enterprise;
CREATE USER geoneural_user WITH ENCRYPTED PASSWORD 'enterprise_secure_password_2024';
GRANT ALL PRIVILEGES ON DATABASE geoneural_enterprise TO geoneural_user;
POSTGRESEOF
        
        # Configure Redis
        sudo tee -a /etc/redis/redis.conf > /dev/null << 'REDISEOF'
# Enterprise Redis Configuration
maxmemory 2gb
maxmemory-policy allkeys-lru
save 900 1
save 300 10
save 60 10000
REDISEOF
        
        # Restart services
        sudo systemctl restart fail2ban
        sudo systemctl restart nginx
        sudo systemctl restart postgresql
        sudo systemctl restart redis-server
        
        echo "Enterprise services configured successfully"
EOF
}

# Function to deploy enterprise Docker stack
deploy_enterprise_docker() {
    echo "🐳 Deploying enterprise Docker stack..."
    
    ssh $VM_USER@$VM_IP << 'EOF'
        echo "Deploying enterprise Docker stack..."
        
        # Create enterprise Docker Compose configuration
        cat > docker-compose.enterprise.yml << 'DOCKEREOF'
version: '3.8'

services:
  # OpenWebUI Enterprise
  openwebui:
    image: ghcr.io/open-webui/open-webui:v0.6.34
    container_name: openwebui-enterprise
    ports:
      - "3000:8080"
    environment:
      - OPENWEBUI_SECRET_KEY=enterprise_secret_key_2024
      - OPENWEBUI_DATABASE_URL=postgresql://geoneural_user:enterprise_secure_password_2024@localhost:5432/geoneural_enterprise
      - OPENWEBUI_APP_NAME=GeoNeural Enterprise
      - OPENWEBUI_APP_URL=https://geoneural.simondatalab.de
    volumes:
      - openwebui_data:/app/backend/data
    restart: unless-stopped
    networks:
      - enterprise_network

  # GeoServer Enterprise
  geoserver:
    image: kartoza/geoserver:latest
    container_name: geoserver-enterprise
    ports:
      - "8080:8080"
    environment:
      - GEOSERVER_ADMIN_USER=admin
      - GEOSERVER_ADMIN_PASSWORD=enterprise_geoserver_2024
      - GEOSERVER_ADMIN_EMAIL=$ENTERPRISE_EMAIL
      - GEOSERVER_DATA_DIR=/opt/geoserver/data_dir
    volumes:
      - geoserver_data:/opt/geoserver/data_dir
      - geoserver_logs:/opt/geoserver/logs
    restart: unless-stopped
    networks:
      - enterprise_network

  # Ollama Enterprise
  ollama:
    image: ollama/ollama:latest
    container_name: ollama-enterprise
    ports:
      - "11434:11434"
    environment:
      - OLLAMA_HOST=0.0.0.0
      - OLLAMA_ORIGINS=*
    volumes:
      - ollama_data:/root/.ollama
    restart: unless-stopped
    networks:
      - enterprise_network
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]

  # MLflow Enterprise
  mlflow:
    image: python:3.11-slim
    container_name: mlflow-enterprise
    ports:
      - "5000:5000"
    environment:
      - MLFLOW_BACKEND_STORE_URI=postgresql://geoneural_user:enterprise_secure_password_2024@localhost:5432/geoneural_enterprise
      - MLFLOW_DEFAULT_ARTIFACT_ROOT=/mlflow/artifacts
    volumes:
      - mlflow_data:/mlflow/artifacts
    command: >
      bash -c "
        pip install mlflow psycopg2-binary &&
        mlflow server 
        --backend-store-uri postgresql://geoneural_user:enterprise_secure_password_2024@localhost:5432/geoneural_enterprise
        --default-artifact-root /mlflow/artifacts
        --host 0.0.0.0
        --port 5000
      "
    restart: unless-stopped
    networks:
      - enterprise_network

  # Prometheus Monitoring
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus-enterprise
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--storage.tsdb.retention.time=200h'
      - '--web.enable-lifecycle'
    restart: unless-stopped
    networks:
      - enterprise_network

  # Grafana Enterprise
  grafana:
    image: grafana/grafana-enterprise:latest
    container_name: grafana-enterprise
    ports:
      - "3001:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=enterprise_grafana_2024
      - GF_INSTALL_PLUGINS=grafana-piechart-panel
    volumes:
      - grafana_data:/var/lib/grafana
    restart: unless-stopped
    networks:
      - enterprise_network

volumes:
  openwebui_data:
  geoserver_data:
  geoserver_logs:
  ollama_data:
  mlflow_data:
  prometheus_data:
  grafana_data:

networks:
  enterprise_network:
    driver: bridge
DOCKEREOF
        
        # Create Prometheus configuration
        cat > prometheus.yml << 'PROMETHEUSEOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['localhost:9100']

  - job_name: 'geoserver'
    static_configs:
      - targets: ['localhost:8080']

  - job_name: 'openwebui'
    static_configs:
      - targets: ['localhost:3000']

  - job_name: 'ollama'
    static_configs:
      - targets: ['localhost:11434']

  - job_name: 'mlflow'
    static_configs:
      - targets: ['localhost:5000']
PROMETHEUSEOF
        
        # Start enterprise stack
        docker-compose -f docker-compose.enterprise.yml up -d
        
        echo "Enterprise Docker stack deployed successfully"
EOF
}

# Function to configure enterprise monitoring
configure_enterprise_monitoring() {
    echo "📊 Configuring enterprise monitoring..."
    
    ssh $VM_USER@$VM_IP << 'EOF'
        echo "Configuring enterprise monitoring..."
        
        # Create monitoring dashboard
        cat > /home/$USER/enterprise_monitoring.sh << 'MONITOREOF'
#!/bin/bash

echo "🏢 GeoNeural Enterprise Monitoring Dashboard"
echo "============================================="
echo ""

# System Status
echo "📊 System Status:"
echo "  CPU Usage: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)%"
echo "  Memory Usage: $(free | grep Mem | awk '{printf("%.1f%%", $3/$2 * 100.0)}')"
echo "  Disk Usage: $(df -h / | awk 'NR==2{printf "%s", $5}')"
echo "  Load Average: $(uptime | awk -F'load average:' '{print $2}')"
echo ""

# Service Status
echo "🔧 Service Status:"
services=("nginx" "postgresql" "redis-server" "docker")
for service in "${services[@]}"; do
    if systemctl is-active --quiet $service; then
        echo "  ✅ $service: Running"
    else
        echo "  ❌ $service: Stopped"
    fi
done
echo ""

# Docker Status
echo "🐳 Docker Status:"
if command -v docker >/dev/null 2>&1; then
    echo "  Containers: $(docker ps -q | wc -l) running"
    echo "  Images: $(docker images -q | wc -l) available"
    echo "  Disk Usage: $(docker system df --format 'table {{.Size}}' | tail -n +2 | head -1)"
else
    echo "  ❌ Docker not installed"
fi
echo ""

# Network Status
echo "🌐 Network Status:"
echo "  External IP: $(curl -s ifconfig.me 2>/dev/null || echo 'Not available')"
echo "  Internal IP: $(hostname -I | awk '{print $1}')"
echo "  Port Status:"
ports=("80" "443" "8080" "3000" "5000" "11434")
for port in "${ports[@]}"; do
    if nc -z localhost $port 2>/dev/null; then
        echo "    ✅ Port $port: Open"
    else
        echo "    ❌ Port $port: Closed"
    fi
done
echo ""

# Enterprise URLs
echo "🔗 Enterprise URLs:"
echo "  Main Application: http://$VM_IP:3000"
echo "  GeoServer: http://$VM_IP:8080"
echo "  MLflow: http://$VM_IP:5000"
echo "  Grafana: http://$VM_IP:3001"
echo "  Prometheus: http://$VM_IP:9090"
echo ""

echo "📈 For detailed monitoring, visit:"
echo "  Grafana Dashboard: http://$VM_IP:3001 (admin/enterprise_grafana_2024)"
echo "  Prometheus Metrics: http://$VM_IP:9090"
MONITOREOF
        
        chmod +x /home/$USER/enterprise_monitoring.sh
        
        # Create systemd service for monitoring
        sudo tee /etc/systemd/system/enterprise-monitor.service > /dev/null << 'SERVICEEOF'
[Unit]
Description=GeoNeural Enterprise Monitoring
After=network.target

[Service]
Type=oneshot
ExecStart=/home/simonadmin/enterprise_monitoring.sh
User=simonadmin
Group=simonadmin

[Install]
WantedBy=multi-user.target
SERVICEEOF
        
        sudo systemctl daemon-reload
        sudo systemctl enable enterprise-monitor.service
        
        echo "Enterprise monitoring configured successfully"
EOF
}

# Function to create enterprise backup system
create_enterprise_backup() {
    echo "💾 Creating enterprise backup system..."
    
    ssh $VM_USER@$VM_IP << 'EOF'
        echo "Creating enterprise backup system..."
        
        # Create backup script
        cat > /home/$USER/enterprise_backup.sh << 'BACKUPEOF'
#!/bin/bash

BACKUP_DIR="/home/simonadmin/backups"
DATE=$(date +%Y%m%d_%H%M%S)

echo "🔄 Starting enterprise backup - $DATE"

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup Docker volumes
echo "📦 Backing up Docker volumes..."
docker run --rm -v openwebui_data:/data -v $BACKUP_DIR:/backup alpine tar czf /backup/openwebui_data_$DATE.tar.gz -C /data .
docker run --rm -v geoserver_data:/data -v $BACKUP_DIR:/backup alpine tar czf /backup/geoserver_data_$DATE.tar.gz -C /data .
docker run --rm -v ollama_data:/data -v $BACKUP_DIR:/backup alpine tar czf /backup/ollama_data_$DATE.tar.gz -C /data .
docker run --rm -v mlflow_data:/data -v $BACKUP_DIR:/backup alpine tar czf /backup/mlflow_data_$DATE.tar.gz -C /data .

# Backup PostgreSQL database
echo "🗄️ Backing up PostgreSQL database..."
sudo -u postgres pg_dump geoneural_enterprise > $BACKUP_DIR/geoneural_enterprise_$DATE.sql

# Backup configuration files
echo "⚙️ Backing up configuration files..."
tar czf $BACKUP_DIR/config_$DATE.tar.gz /etc/nginx /etc/postgresql /etc/redis /etc/fail2ban

# Cleanup old backups (keep last 7 days)
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete

echo "✅ Enterprise backup completed - $DATE"
BACKUPEOF
        
        chmod +x /home/$USER/enterprise_backup.sh
        
        # Create cron job for daily backups
        echo "0 2 * * * /home/simonadmin/enterprise_backup.sh" | crontab -
        
        echo "Enterprise backup system created successfully"
EOF
}

# Function to verify enterprise setup
verify_enterprise_setup() {
    echo "🔍 Verifying enterprise setup..."
    
    # Test connectivity
    if ! check_vm_connectivity; then
        echo "❌ VM connectivity test failed"
        return 1
    fi
    
    # Test services
    ssh $VM_USER@$VM_IP << 'EOF'
        echo "Testing enterprise services..."
        
        # Test web services
        services=("nginx" "postgresql" "redis-server" "docker")
        for service in "${services[@]}"; do
            if systemctl is-active --quiet $service; then
                echo "✅ $service: Running"
            else
                echo "❌ $service: Not running"
            fi
        done
        
        # Test Docker containers
        if command -v docker >/dev/null 2>&1; then
            echo "🐳 Docker containers:"
            docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        fi
        
        # Test ports
        echo "🌐 Testing ports:"
        ports=("80" "443" "8080" "3000" "5000" "11434" "9090" "3001")
        for port in "${ports[@]}"; do
            if nc -z localhost $port 2>/dev/null; then
                echo "✅ Port $port: Open"
            else
                echo "❌ Port $port: Closed"
            fi
        done
EOF
    
    echo ""
    echo "🎉 ENTERPRISE SETUP COMPLETED!"
    echo "=============================="
    echo ""
    echo "📋 Enterprise VM106-geoneural1000111 Summary:"
    echo "  🖥️  VM ID: $VM_ID"
    echo "  🌐 IP Address: $VM_IP"
    echo "  🏢 Domain: $ENTERPRISE_DOMAIN"
    echo "  👤 Organization: $ENTERPRISE_ORG"
    echo ""
    echo "🔗 Enterprise Services:"
    echo "  🌐 Main Application: http://$VM_IP:3000"
    echo "  🗺️  GeoServer: http://$VM_IP:8080"
    echo "  🤖 Ollama AI: http://$VM_IP:11434"
    echo "  📊 MLflow: http://$VM_IP:5000"
    echo "  📈 Grafana: http://$VM_IP:3001"
    echo "  🔍 Prometheus: http://$VM_IP:9090"
    echo ""
    echo "🔐 Enterprise Credentials:"
    echo "  GeoServer: admin / enterprise_geoserver_2024"
    echo "  Grafana: admin / enterprise_grafana_2024"
    echo "  PostgreSQL: geoneural_user / enterprise_secure_password_2024"
    echo ""
    echo "🛠️ Management Commands:"
    echo "  📊 Monitoring: ssh $VM_USER@$VM_IP './enterprise_monitoring.sh'"
    echo "  💾 Backup: ssh $VM_USER@$VM_IP './enterprise_backup.sh'"
    echo "  🐳 Docker: ssh $VM_USER@$VM_IP 'docker-compose -f docker-compose.enterprise.yml ps'"
    echo ""
    echo "✅ Enterprise VM106-geoneural1000111 is ready for production use!"
}

# Main execution
main() {
    echo "🚀 Starting enterprise-scale VM106-geoneural1000111 configuration..."
    echo ""
    
    # Step 1: Check VM connectivity
    if ! check_vm_connectivity; then
        echo "❌ Cannot proceed - VM is not accessible"
        echo "💡 Please ensure VM 106 is running and accessible"
        exit 1
    fi
    
    # Step 2: Upgrade VM specifications
    upgrade_vm_specs
    
    # Step 3: Install enterprise software stack
    install_enterprise_stack
    
    # Step 4: Configure enterprise services
    configure_enterprise_services
    
    # Step 5: Deploy enterprise Docker stack
    deploy_enterprise_docker
    
    # Step 6: Configure enterprise monitoring
    configure_enterprise_monitoring
    
    # Step 7: Create enterprise backup system
    create_enterprise_backup
    
    # Step 8: Verify enterprise setup
    verify_enterprise_setup
}

# Run main function
main "$@"

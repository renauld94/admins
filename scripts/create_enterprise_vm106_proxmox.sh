#!/bin/bash

# Enterprise-Scale VM106-geoneural1000111 Configuration Script (Proxmox Method)
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
        
        # Enable CPU hotplug
        qm set $VM_ID --cpu host
        
        # Enable memory ballooning
        qm set $VM_ID --balloon 16384
        
        echo "VM specifications upgraded successfully"
EOF
}

# Function to install enterprise software via Proxmox
install_enterprise_software() {
    echo "📦 Installing enterprise software stack..."
    
    ssh -p $PROXMOX_PORT root@$PROXMOX_HOST << EOF
        echo "Installing enterprise software on VM $VM_ID..."
        
        # Update system
        qm guest exec $VM_ID -- apt update
        qm guest exec $VM_ID -- apt upgrade -y
        
        # Install enterprise monitoring tools
        qm guest exec $VM_ID -- apt install -y htop iotop nethogs nload iftop
        
        # Install enterprise security tools
        qm guest exec $VM_ID -- apt install -y fail2ban ufw rkhunter chkrootkit
        
        # Install enterprise web server stack
        qm guest exec $VM_ID -- apt install -y nginx apache2-utils
        
        # Install enterprise database
        qm guest exec $VM_ID -- apt install -y postgresql postgresql-contrib redis-server
        
        # Install Docker
        qm guest exec $VM_ID -- curl -fsSL https://get.docker.com -o get-docker.sh
        qm guest exec $VM_ID -- sh get-docker.sh
        qm guest exec $VM_ID -- usermod -aG docker $VM_USER
        
        # Install Docker Compose
        qm guest exec $VM_ID -- curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-\$(uname -s)-\$(uname -m)" -o /usr/local/bin/docker-compose
        qm guest exec $VM_ID -- chmod +x /usr/local/bin/docker-compose
        
        echo "Enterprise software stack installed successfully"
EOF
}

# Function to configure enterprise services
configure_enterprise_services() {
    echo "⚙️ Configuring enterprise services..."
    
    ssh -p $PROXMOX_PORT root@$PROXMOX_HOST << EOF
        echo "Configuring enterprise services on VM $VM_ID..."
        
        # Configure UFW firewall
        qm guest exec $VM_ID -- ufw --force enable
        qm guest exec $VM_ID -- ufw default deny incoming
        qm guest exec $VM_ID -- ufw default allow outgoing
        qm guest exec $VM_ID -- ufw allow ssh
        qm guest exec $VM_ID -- ufw allow 80/tcp
        qm guest exec $VM_ID -- ufw allow 443/tcp
        qm guest exec $VM_ID -- ufw allow 8080/tcp
        qm guest exec $VM_ID -- ufw allow 3000/tcp
        qm guest exec $VM_ID -- ufw allow 5000/tcp
        qm guest exec $VM_ID -- ufw allow 11434/tcp
        
        # Configure PostgreSQL
        qm guest exec $VM_ID -- sudo -u postgres psql -c "CREATE DATABASE geoneural_enterprise;"
        qm guest exec $VM_ID -- sudo -u postgres psql -c "CREATE USER geoneural_user WITH ENCRYPTED PASSWORD 'enterprise_secure_password_2024';"
        qm guest exec $VM_ID -- sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE geoneural_enterprise TO geoneural_user;"
        
        # Restart services
        qm guest exec $VM_ID -- systemctl restart nginx
        qm guest exec $VM_ID -- systemctl restart postgresql
        qm guest exec $VM_ID -- systemctl restart redis-server
        
        echo "Enterprise services configured successfully"
EOF
}

# Function to create enterprise Docker stack
create_enterprise_docker_stack() {
    echo "🐳 Creating enterprise Docker stack..."
    
    ssh -p $PROXMOX_PORT root@$PROXMOX_HOST << EOF
        echo "Creating enterprise Docker stack on VM $VM_ID..."
        
        # Create Docker Compose configuration
        qm guest exec $VM_ID -- tee /home/$VM_USER/docker-compose.enterprise.yml > /dev/null << 'DOCKEREOF'
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
      - GEOSERVER_ADMIN_EMAIL=admin@simondatalab.de
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

volumes:
  openwebui_data:
  geoserver_data:
  geoserver_logs:
  ollama_data:
  mlflow_data:

networks:
  enterprise_network:
    driver: bridge
DOCKEREOF
        
        # Start enterprise stack
        qm guest exec $VM_ID -- docker-compose -f /home/$VM_USER/docker-compose.enterprise.yml up -d
        
        echo "Enterprise Docker stack created successfully"
EOF
}

# Function to create enterprise monitoring
create_enterprise_monitoring() {
    echo "📊 Creating enterprise monitoring..."
    
    ssh -p $PROXMOX_PORT root@$PROXMOX_HOST << EOF
        echo "Creating enterprise monitoring on VM $VM_ID..."
        
        # Create monitoring script
        qm guest exec $VM_ID -- tee /home/$VM_USER/enterprise_monitoring.sh > /dev/null << 'MONITOREOF'
#!/bin/bash

echo "🏢 GeoNeural Enterprise Monitoring Dashboard"
echo "============================================="
echo ""

# System Status
echo "📊 System Status:"
echo "  CPU Usage: \$(top -bn1 | grep "Cpu(s)" | awk '{print \$2}' | cut -d'%' -f1)%"
echo "  Memory Usage: \$(free | grep Mem | awk '{printf("%.1f%%", \$3/\$2 * 100.0)}')"
echo "  Disk Usage: \$(df -h / | awk 'NR==2{printf "%s", \$5}')"
echo "  Load Average: \$(uptime | awk -F'load average:' '{print \$2}')"
echo ""

# Service Status
echo "🔧 Service Status:"
services=("nginx" "postgresql" "redis-server" "docker")
for service in "\${services[@]}"; do
    if systemctl is-active --quiet \$service; then
        echo "  ✅ \$service: Running"
    else
        echo "  ❌ \$service: Stopped"
    fi
done
echo ""

# Docker Status
echo "🐳 Docker Status:"
if command -v docker >/dev/null 2>&1; then
    echo "  Containers: \$(docker ps -q | wc -l) running"
    echo "  Images: \$(docker images -q | wc -l) available"
    echo "  Disk Usage: \$(docker system df --format 'table {{.Size}}' | tail -n +2 | head -1)"
else
    echo "  ❌ Docker not installed"
fi
echo ""

# Network Status
echo "🌐 Network Status:"
echo "  External IP: \$(curl -s ifconfig.me 2>/dev/null || echo 'Not available')"
echo "  Internal IP: \$(hostname -I | awk '{print \$1}')"
echo "  Port Status:"
ports=("80" "443" "8080" "3000" "5000" "11434")
for port in "\${ports[@]}"; do
    if nc -z localhost \$port 2>/dev/null; then
        echo "    ✅ Port \$port: Open"
    else
        echo "    ❌ Port \$port: Closed"
    fi
done
echo ""

# Enterprise URLs
echo "🔗 Enterprise URLs:"
echo "  Main Application: http://10.0.0.106:3000"
echo "  GeoServer: http://10.0.0.106:8080"
echo "  MLflow: http://10.0.0.106:5000"
echo "  Ollama: http://10.0.0.106:11434"
echo ""
MONITOREOF
        
        # Make monitoring script executable
        qm guest exec $VM_ID -- chmod +x /home/$VM_USER/enterprise_monitoring.sh
        
        echo "Enterprise monitoring created successfully"
EOF
}

# Function to verify enterprise setup
verify_enterprise_setup() {
    echo "🔍 Verifying enterprise setup..."
    
    ssh -p $PROXMOX_PORT root@$PROXMOX_HOST << EOF
        echo "Verifying enterprise setup on VM $VM_ID..."
        
        # Test services
        echo "Testing enterprise services..."
        services=("nginx" "postgresql" "redis-server" "docker")
        for service in "\${services[@]}"; do
            if qm guest exec $VM_ID -- systemctl is-active --quiet \$service; then
                echo "✅ \$service: Running"
            else
                echo "❌ \$service: Not running"
            fi
        done
        
        # Test Docker containers
        echo "Testing Docker containers..."
        qm guest exec $VM_ID -- docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        
        # Test ports
        echo "Testing ports:"
        ports=("80" "443" "8080" "3000" "5000" "11434")
        for port in "\${ports[@]}"; do
            if qm guest exec $VM_ID -- nc -z localhost \$port; then
                echo "✅ Port \$port: Open"
            else
                echo "❌ Port \$port: Closed"
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
    echo ""
    echo "🔐 Enterprise Credentials:"
    echo "  GeoServer: admin / enterprise_geoserver_2024"
    echo "  PostgreSQL: geoneural_user / enterprise_secure_password_2024"
    echo ""
    echo "🛠️ Management Commands:"
    echo "  📊 Monitoring: ssh -p $PROXMOX_PORT root@$PROXMOX_HOST \"qm guest exec $VM_ID -- /home/$VM_USER/enterprise_monitoring.sh\""
    echo "  🐳 Docker: ssh -p $PROXMOX_PORT root@$PROXMOX_HOST \"qm guest exec $VM_ID -- docker-compose -f /home/$VM_USER/docker-compose.enterprise.yml ps\""
    echo ""
    echo "✅ Enterprise VM106-geoneural1000111 is ready for production use!"
}

# Main execution
main() {
    echo "🚀 Starting enterprise-scale VM106-geoneural1000111 configuration..."
    echo ""
    
    # Step 1: Upgrade VM specifications
    upgrade_vm_specs
    
    # Step 2: Install enterprise software stack
    install_enterprise_software
    
    # Step 3: Configure enterprise services
    configure_enterprise_services
    
    # Step 4: Create enterprise Docker stack
    create_enterprise_docker_stack
    
    # Step 5: Create enterprise monitoring
    create_enterprise_monitoring
    
    # Step 6: Verify enterprise setup
    verify_enterprise_setup
}

# Run main function
main "$@"

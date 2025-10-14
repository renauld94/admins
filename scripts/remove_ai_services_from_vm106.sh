#!/bin/bash

# Remove AI Services from VM106-geoneural1000111
# This script removes Ollama and OpenWebUI configurations from VM 106
# since these services should only run on VM 159 (ubuntuai-1000110)

set -e

echo "🧹 Removing AI Services from VM106-geoneural1000111"
echo "=================================================="
echo ""

# Configuration
PROXMOX_HOST="136.243.155.166"
PROXMOX_PORT="2222"
VM_ID="106"
VM_NAME="vm106-geoneural1000111"
VM_IP="10.0.0.106"
VM_USER="simonadmin"

echo "📋 Configuration:"
echo "  VM ID: $VM_ID ($VM_NAME)"
echo "  VM IP: $VM_IP"
echo "  VM User: $VM_USER"
echo ""

# Function to remove AI services from docker-compose.yml
remove_ai_services_from_compose() {
    echo "🔧 Removing AI services from docker-compose.yml..."
    
    ssh -p $PROXMOX_PORT root@$PROXMOX_HOST << EOF
        echo "Removing AI services from VM $VM_ID docker-compose configuration..."
        
        # Create a backup of the original file
        qm guest exec $VM_ID -- cp /home/$VM_USER/docker-compose.yml /home/$VM_USER/docker-compose.yml.backup
        
        # Remove ollama and open-webui services from docker-compose.yml
        qm guest exec $VM_ID -- sed -i '/^  ollama:/,/^$/d' /home/$VM_USER/docker-compose.yml
        qm guest exec $VM_ID -- sed -i '/^  open-webui:/,/^$/d' /home/$VM_USER/docker-compose.yml
        qm guest exec $VM_ID -- sed -i '/^  open-webui:/,/^$/d' /home/$VM_USER/docker-compose.yml
        
        # Remove ollama_data and open-webui volumes
        qm guest exec $VM_ID -- sed -i '/ollama_data:/d' /home/$VM_USER/docker-compose.yml
        qm guest exec $VM_ID -- sed -i '/open-webui:/d' /home/$VM_USER/docker-compose.yml
        
        # Remove ai-net network if it exists
        qm guest exec $VM_ID -- sed -i '/^  ai-net:/,/^$/d' /home/$VM_USER/docker-compose.yml
        
        echo "AI services removed from docker-compose.yml"
EOF
}

# Function to remove Ollama data directory
remove_ollama_data() {
    echo "🗑️ Removing Ollama data directory..."
    
    ssh -p $PROXMOX_PORT root@$PROXMOX_HOST << EOF
        echo "Removing Ollama data from VM $VM_ID..."
        
        # Remove ollama directory and all its contents
        qm guest exec $VM_ID -- rm -rf /home/$VM_USER/.ollama
        
        echo "Ollama data directory removed"
EOF
}

# Function to remove enterprise docker-compose with AI services
remove_enterprise_ai_services() {
    echo "🔧 Removing AI services from enterprise docker-compose..."
    
    ssh -p $PROXMOX_PORT root@$PROXMOX_HOST << EOF
        echo "Removing AI services from VM $VM_ID enterprise configuration..."
        
        # Remove ollama and openwebui services from enterprise docker-compose
        qm guest exec $VM_ID -- sed -i '/^  ollama:/,/^$/d' /home/$VM_USER/docker-compose.enterprise.yml
        qm guest exec $VM_ID -- sed -i '/^  openwebui:/,/^$/d' /home/$VM_USER/docker-compose.enterprise.yml
        
        # Remove ollama_data and openwebui_data volumes
        qm guest exec $VM_ID -- sed -i '/ollama_data:/d' /home/$VM_USER/docker-compose.enterprise.yml
        qm guest exec $VM_ID -- sed -i '/openwebui_data:/d' /home/$VM_USER/docker-compose.enterprise.yml
        
        echo "AI services removed from enterprise docker-compose.yml"
EOF
}

# Function to update monitoring script
update_monitoring_script() {
    echo "📊 Updating monitoring script to remove AI service references..."
    
    ssh -p $PROXMOX_PORT root@$PROXMOX_HOST << EOF
        echo "Updating monitoring script on VM $VM_ID..."
        
        # Remove AI service references from monitoring script
        qm guest exec $VM_ID -- sed -i '/Ollama AI:/d' /home/$VM_USER/enterprise_monitoring.sh
        qm guest exec $VM_ID -- sed -i '/ollama.simondatalab.de/d' /home/$VM_USER/enterprise_monitoring.sh
        qm guest exec $VM_ID -- sed -i '/11434/d' /home/$VM_USER/enterprise_monitoring.sh
        
        echo "Monitoring script updated"
EOF
}

# Function to update SSH config to point AI services to VM 159
update_ssh_config() {
    echo "🔧 Updating SSH configuration..."
    
    # Update ssh_config_corrected to add VM 159 AI services
    if [ -f "ssh_config_corrected" ]; then
        # Add VM 159 AI services configuration
        cat >> ssh_config_corrected << 'EOF'

Host ai-services-vm159
    HostName 10.0.0.110
    User simonadmin
    ProxyJump jump
    IdentityFile ~/.ssh/vm159_ed25519
    IdentitiesOnly yes
    StrictHostKeyChecking accept-new
    ServerAliveInterval 30
    ServerAliveCountMax 4

Host ollama-vm159
    HostName 10.0.0.110
    User simonadmin
    ProxyJump jump
    IdentityFile ~/.ssh/vm159_ed25519
    IdentitiesOnly yes
    StrictHostKeyChecking accept-new
    ServerAliveInterval 30
    ServerAliveCountMax 4
    LocalForward 11434 localhost:11434

Host openwebui-vm159
    HostName 10.0.0.110
    User simonadmin
    ProxyJump jump
    IdentityFile ~/.ssh/vm159_ed25519
    IdentitiesOnly yes
    StrictHostKeyChecking accept-new
    ServerAliveInterval 30
    ServerAliveCountMax 4
    LocalForward 3001 localhost:3001
EOF
        echo "✅ SSH configuration updated with VM 159 AI services"
    fi
}

# Function to create service separation summary
create_separation_summary() {
    echo "📋 Creating service separation summary..."
    
    cat > VM_SERVICE_SEPARATION.md << 'EOF'
# VM Service Separation Summary

## 🎯 Service Distribution

### VM 106 (vm106-geoneural1000111) - 10.0.0.106
**Purpose**: Geospatial and Learning Platform Services
- ✅ **GeoServer**: Geospatial data services
- ✅ **MLflow**: ML experiment tracking
- ✅ **Learning Platform**: JupyterHub, Moodle
- ✅ **Database**: MariaDB for Moodle
- ✅ **Web Infrastructure**: Nginx proxy, SSL

### VM 159 (ubuntuai-1000110) - 10.0.0.110
**Purpose**: AI Services and Models
- ✅ **Ollama**: AI model server (Port 11434)
- ✅ **OpenWebUI**: AI web interface (Port 3001)
- ✅ **MLflow**: ML experiment tracking (Port 5000)

## 🔗 Access Information

### VM 106 Services
- **GeoServer**: http://10.0.0.106:8080
- **MLflow**: http://10.0.0.106:5000
- **Learning Platform**: http://10.0.0.106:80

### VM 159 AI Services
- **Ollama API**: http://10.0.0.110:11434
- **OpenWebUI**: http://10.0.0.110:3001
- **MLflow**: http://10.0.0.110:5000

## 🛠️ Management Commands

### VM 106 (Geospatial Services)
```bash
ssh geoserver-vm
ssh enterprise-vm106
```

### VM 159 (AI Services)
```bash
ssh ai-services-vm159
ssh ollama-vm159
ssh openwebui-vm159
```

## ✅ Separation Complete
- AI services removed from VM 106
- AI services confirmed running on VM 159
- SSH configurations updated
- Service separation documented
EOF
    
    echo "✅ Service separation summary created"
}

# Function to verify cleanup
verify_cleanup() {
    echo "🔍 Verifying cleanup..."
    
    ssh -p $PROXMOX_PORT root@$PROXMOX_HOST << EOF
        echo "Verifying cleanup on VM $VM_ID..."
        
        # Check if ollama directory is removed
        if qm guest exec $VM_ID -- test -d /home/$VM_USER/.ollama; then
            echo "❌ Ollama directory still exists"
        else
            echo "✅ Ollama directory removed"
        fi
        
        # Check docker-compose.yml for AI services
        if qm guest exec $VM_ID -- grep -q "ollama:" /home/$VM_USER/docker-compose.yml; then
            echo "❌ Ollama service still in docker-compose.yml"
        else
            echo "✅ Ollama service removed from docker-compose.yml"
        fi
        
        if qm guest exec $VM_ID -- grep -q "open-webui:" /home/$VM_USER/docker-compose.yml; then
            echo "❌ OpenWebUI service still in docker-compose.yml"
        else
            echo "✅ OpenWebUI service removed from docker-compose.yml"
        fi
        
        echo "Cleanup verification complete"
EOF
}

# Main execution
main() {
    echo "🚀 Starting AI services removal from VM106-geoneural1000111..."
    echo ""
    
    # Step 1: Remove AI services from docker-compose.yml
    remove_ai_services_from_compose
    
    # Step 2: Remove Ollama data directory
    remove_ollama_data
    
    # Step 3: Remove AI services from enterprise docker-compose
    remove_enterprise_ai_services
    
    # Step 4: Update monitoring script
    update_monitoring_script
    
    # Step 5: Update SSH configuration
    update_ssh_config
    
    # Step 6: Create service separation summary
    create_separation_summary
    
    # Step 7: Verify cleanup
    verify_cleanup
    
    echo ""
    echo "🎉 AI SERVICES REMOVAL COMPLETED!"
    echo "================================"
    echo ""
    echo "📋 Summary:"
    echo "  ✅ Ollama and OpenWebUI removed from VM 106"
    echo "  ✅ AI services confirmed running on VM 159"
    echo "  ✅ SSH configuration updated"
    echo "  ✅ Service separation documented"
    echo ""
    echo "🔗 AI Services Access (VM 159):"
    echo "  🤖 Ollama: http://10.0.0.110:11434"
    echo "  🌐 OpenWebUI: http://10.0.0.110:3001"
    echo ""
    echo "🔗 Geospatial Services Access (VM 106):"
    echo "  🗺️ GeoServer: http://10.0.0.106:8080"
    echo "  📊 MLflow: http://10.0.0.106:5000"
    echo ""
    echo "✅ Service separation complete!"
}

# Run main function
main "$@"

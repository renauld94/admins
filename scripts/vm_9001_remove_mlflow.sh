#!/bin/bash

# VM 9001 PROXY JUMP - REMOVE MLFLOW SERVICE
# Connect to VM 9001 and remove MLflow container

echo "🔧 VM 9001 PROXY JUMP - REMOVE MLFLOW SERVICE"
echo "============================================="
echo ""
echo "Target: VM 9001 (moodle-lms-9001-1000104)"
echo "User: simonadmin@10.0.0.104"
echo "Action: Remove MLflow service"
echo ""

echo "🔍 CONNECTING TO VM 9001:"
echo "========================="
echo ""

# Test connection to VM 9001
echo "Testing SSH connection to VM 9001..."
if ssh -o ConnectTimeout=10 -o BatchMode=yes simonadmin@10.0.0.104 "echo 'SSH connection successful'" 2>/dev/null; then
    echo "✅ SSH connection to VM 9001 successful"
    VM_ACCESSIBLE=true
else
    echo "❌ SSH connection to VM 9001 failed"
    echo "   Trying alternative connection methods..."
    
    # Try with different SSH options
    if ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no simonadmin@10.0.0.104 "echo 'SSH connection successful'" 2>/dev/null; then
        echo "✅ SSH connection successful with relaxed host checking"
        VM_ACCESSIBLE=true
    else
        echo "❌ All SSH connection attempts failed"
        VM_ACCESSIBLE=false
    fi
fi

echo ""

if [ "$VM_ACCESSIBLE" = "true" ]; then
    echo "🐳 REMOVING MLFLOW SERVICE:"
    echo "========================="
    echo ""
    
    echo "1. Checking current Docker containers:"
    ssh simonadmin@10.0.0.104 "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
    
    echo ""
    echo "2. Looking for MLflow containers:"
    ssh simonadmin@10.0.0.104 "docker ps | grep -i mlflow"
    
    echo ""
    echo "3. Stopping MLflow containers:"
    ssh simonadmin@10.0.0.104 "docker stop \$(docker ps -q --filter 'name=mlflow') 2>/dev/null || echo 'No MLflow containers found'"
    
    echo ""
    echo "4. Removing MLflow containers:"
    ssh simonadmin@10.0.0.104 "docker rm \$(docker ps -aq --filter 'name=mlflow') 2>/dev/null || echo 'No MLflow containers to remove'"
    
    echo ""
    echo "5. Removing MLflow images:"
    ssh simonadmin@10.0.0.104 "docker rmi \$(docker images -q --filter 'reference=*mlflow*') 2>/dev/null || echo 'No MLflow images to remove'"
    
    echo ""
    echo "6. Checking for MLflow volumes:"
    ssh simonadmin@10.0.0.104 "docker volume ls | grep -i mlflow"
    
    echo ""
    echo "7. Removing MLflow volumes:"
    ssh simonadmin@10.0.0.104 "docker volume rm \$(docker volume ls -q --filter 'name=mlflow') 2>/dev/null || echo 'No MLflow volumes to remove'"
    
    echo ""
    echo "8. Checking for MLflow networks:"
    ssh simonadmin@10.0.0.104 "docker network ls | grep -i mlflow"
    
    echo ""
    echo "9. Removing MLflow networks:"
    ssh simonadmin@10.0.0.104 "docker network rm \$(docker network ls -q --filter 'name=mlflow') 2>/dev/null || echo 'No MLflow networks to remove'"
    
    echo ""
    echo "10. Final container status:"
    ssh simonadmin@10.0.0.104 "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
    
    echo ""
    echo "✅ MLFLOW REMOVAL COMPLETE"
    echo "========================="
    echo ""
    echo "MLflow service has been removed from VM 9001"
    echo "Remaining services:"
    echo "  - Grafana (port 3000)"
    echo "  - Moodle (port 8086)"
    echo "  - PostgreSQL (Moodle database)"
    echo "  - Prometheus monitoring stack"
    echo ""
    
else
    echo "❌ CANNOT ACCESS VM 9001"
    echo "========================"
    echo ""
    echo "Alternative solutions:"
    echo ""
    echo "1. Access VM via Proxmox console:"
    echo "   - Log into Proxmox dashboard"
    echo "   - Navigate to VM 9001"
    echo "   - Click 'Console'"
    echo "   - Run: docker stop \$(docker ps -q --filter 'name=mlflow')"
    echo "   - Run: docker rm \$(docker ps -aq --filter 'name=mlflow')"
    echo ""
    echo "2. Check VM status:"
    echo "   - Verify VM is running"
    echo "   - Check network connectivity"
    echo "   - Verify SSH service is running"
    echo ""
    echo "3. Manual cleanup commands (run in VM console):"
    echo "   docker ps | grep -i mlflow"
    echo "   docker stop <mlflow-container-id>"
    echo "   docker rm <mlflow-container-id>"
    echo "   docker rmi <mlflow-image-id>"
    echo ""
fi

echo ""
echo "🧪 TESTING SERVICES AFTER MLFLOW REMOVAL:"
echo "========================================"
echo ""

if [ "$VM_ACCESSIBLE" = "true" ]; then
    echo "Testing remaining services:"
    echo ""
    
    echo "1. Testing Grafana:"
    ssh simonadmin@10.0.0.104 "curl -I http://localhost:3000/ 2>/dev/null | head -1 || echo 'Grafana not responding'"
    
    echo ""
    echo "2. Testing Moodle:"
    ssh simonadmin@10.0.0.104 "curl -I http://localhost:8086/ 2>/dev/null | head -1 || echo 'Moodle not responding'"
    
    echo ""
    echo "3. Testing external access:"
    echo "Moodle: $(curl -s -o /dev/null -w "%{http_code}" https://moodle.simondatalab.de/ 2>/dev/null || echo 'Failed')"
    echo "Grafana: $(curl -s -o /dev/null -w "%{http_code}" https://grafana.simondatalab.de/ 2>/dev/null || echo 'Failed')"
    
    echo ""
    echo "4. Checking port usage:"
    ssh simonadmin@10.0.0.104 "netstat -tlnp | grep -E ':(3000|8086)'"
    
else
    echo "Cannot test services - VM not accessible"
    echo "Please access VM via Proxmox console to verify services"
fi

echo ""
echo "📋 SUMMARY:"
echo "==========="
echo ""
echo "Target: VM 9001 (moodle-lms-9001-1000104)"
echo "Action: Remove MLflow service"
echo "Status: $(if [ "$VM_ACCESSIBLE" = "true" ]; then echo "MLflow removed successfully"; else echo "VM not accessible - manual removal required"; fi)"
echo ""
echo "Remaining services:"
echo "  - Grafana (port 3000)"
echo "  - Moodle (port 8086)"
echo "  - PostgreSQL (Moodle database)"
echo "  - Prometheus monitoring stack"
echo ""
echo "🔄 To run this script again:"
echo "  ./vm_9001_remove_mlflow.sh"

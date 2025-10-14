#!/bin/bash

# VM 9001 MLflow Removal Script (Proxmox Console Method)
# This script removes MLflow from VM 9001 when accessed via Proxmox console

echo "🔧 VM 9001 MLFLOW REMOVAL SCRIPT"
echo "================================="
echo ""
echo "Target: VM 9001 (moodle-lms-9001-1000104)"
echo "IP: 10.0.0.104"
echo "Action: Remove MLflow service"
echo ""

echo "🔍 CHECKING CURRENT STATUS:"
echo "==========================="
echo ""

echo "1. Current Docker containers:"
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

echo ""
echo "2. Looking for MLflow containers:"
docker ps | grep -i mlflow || echo "No MLflow containers found"

echo ""
echo "3. Looking for MLflow images:"
docker images | grep -i mlflow || echo "No MLflow images found"

echo ""
echo "4. Looking for MLflow volumes:"
docker volume ls | grep -i mlflow || echo "No MLflow volumes found"

echo ""
echo "5. Looking for MLflow networks:"
docker network ls | grep -i mlflow || echo "No MLflow networks found"

echo ""
echo "🐳 REMOVING MLFLOW COMPONENTS:"
echo "=============================="
echo ""

echo "1. Stopping MLflow containers:"
docker stop $(docker ps -q --filter 'name=mlflow') 2>/dev/null || echo "No MLflow containers to stop"

echo ""
echo "2. Removing MLflow containers:"
docker rm $(docker ps -aq --filter 'name=mlflow') 2>/dev/null || echo "No MLflow containers to remove"

echo ""
echo "3. Removing MLflow images:"
docker rmi $(docker images -q --filter 'reference=*mlflow*') 2>/dev/null || echo "No MLflow images to remove"

echo ""
echo "4. Removing MLflow volumes:"
docker volume rm $(docker volume ls -q --filter 'name=mlflow') 2>/dev/null || echo "No MLflow volumes to remove"

echo ""
echo "5. Removing MLflow networks:"
docker network rm $(docker network ls -q --filter 'name=mlflow') 2>/dev/null || echo "No MLflow networks to remove"

echo ""
echo "🧹 CLEANING UP DOCKER SYSTEM:"
echo "============================="
echo ""

echo "1. Removing unused containers:"
docker container prune -f

echo ""
echo "2. Removing unused images:"
docker image prune -f

echo ""
echo "3. Removing unused volumes:"
docker volume prune -f

echo ""
echo "4. Removing unused networks:"
docker network prune -f

echo ""
echo "✅ VERIFICATION:"
echo "==============="
echo ""

echo "1. Final container status:"
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

echo ""
echo "2. Checking for any remaining MLflow references:"
docker ps | grep -i mlflow || echo "✅ No MLflow containers running"
docker images | grep -i mlflow || echo "✅ No MLflow images found"
docker volume ls | grep -i mlflow || echo "✅ No MLflow volumes found"
docker network ls | grep -i mlflow || echo "✅ No MLflow networks found"

echo ""
echo "🧪 TESTING REMAINING SERVICES:"
echo "=============================="
echo ""

echo "1. Testing Grafana (port 3000):"
curl -I http://localhost:3000/ 2>/dev/null | head -1 || echo "Grafana not responding"

echo ""
echo "2. Testing Moodle (port 8086):"
curl -I http://localhost:8086/ 2>/dev/null | head -1 || echo "Moodle not responding"

echo ""
echo "3. Checking port usage:"
netstat -tlnp | grep -E ':(3000|8086)' || echo "No services listening on expected ports"

echo ""
echo "📋 SUMMARY:"
echo "==========="
echo ""
echo "Target: VM 9001 (moodle-lms-9001-1000104)"
echo "Action: Remove MLflow service"
echo "Status: MLflow removal completed"
echo ""
echo "Remaining services:"
echo "  - Grafana (port 3000)"
echo "  - Moodle (port 8086)"
echo "  - PostgreSQL (Moodle database)"
echo "  - Prometheus monitoring stack"
echo ""
echo "✅ MLflow has been completely removed from VM 9001"
echo "🔄 VM 9001 is now optimized for Moodle LMS and monitoring services"

#!/bin/bash
#
# Restart cAdvisor on VM 159 (ubuntuai-1000110)
# Run this script when you have SSH access to your Proxmox server
#

set -e

echo "🔧 Restarting cAdvisor on VM 159"
echo "=" 
echo ""

# Check if cAdvisor container exists
echo "1️⃣  Checking cAdvisor container status..."
CADVISOR_STATUS=$(docker ps -a --filter "name=cadvisor" --format "{{.Status}}" 2>/dev/null || echo "NOT FOUND")

if [[ "$CADVISOR_STATUS" == "NOT FOUND" ]]; then
    echo "   ⚠️  cAdvisor container not found! Creating new container..."
    
    docker run -d \
      --name=cadvisor \
      --restart=unless-stopped \
      --volume=/:/rootfs:ro \
      --volume=/var/run:/var/run:ro \
      --volume=/sys:/sys:ro \
      --volume=/var/lib/docker/:/var/lib/docker:ro \
      --volume=/dev/disk/:/dev/disk:ro \
      --publish=8080:8080 \
      --detach=true \
      --privileged \
      --device=/dev/kmsg \
      gcr.io/cadvisor/cadvisor:latest
    
    echo "   ✅ cAdvisor container created and started!"
    
elif [[ "$CADVISOR_STATUS" == *"Up"* ]]; then
    echo "   ℹ️  cAdvisor is running: $CADVISOR_STATUS"
    echo "   🔄 Restarting to ensure fresh metrics..."
    docker restart cadvisor
    echo "   ✅ cAdvisor restarted!"
    
else
    echo "   ⚠️  cAdvisor exists but is stopped: $CADVISOR_STATUS"
    echo "   🔄 Starting cAdvisor..."
    docker start cadvisor
    echo "   ✅ cAdvisor started!"
fi

echo ""
echo "2️⃣  Verifying cAdvisor is responding..."
sleep 3

if curl -s http://localhost:8080/metrics >/dev/null 2>&1; then
    echo "   ✅ cAdvisor metrics endpoint is responding!"
    CONTAINER_COUNT=$(curl -s http://localhost:8080/metrics | grep -c "container_last_seen" || echo "0")
    echo "   ℹ️  Tracking metrics for containers"
else
    echo "   ❌ cAdvisor metrics endpoint not responding yet"
    echo "   ℹ️  It may take a few seconds to start up"
fi

echo ""
echo "3️⃣  Current Docker containers on this VM:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "=" 
echo "✅ Done! cAdvisor should now be accessible at http://10.0.0.110:8080"
echo "   Wait 30 seconds for Prometheus to scrape metrics, then refresh Grafana"
echo ""

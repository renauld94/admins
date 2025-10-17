#!/bin/bash
#
# Fix cAdvisor - Run this on VM159 (10.0.0.110)
#

set -e

echo "🔧 Fixing cAdvisor on VM159"
echo "==========================="

# Check if we're on the right host
CURRENT_IP=$(hostname -I | awk '{print $1}')
if [[ "$CURRENT_IP" != "10.0.0.110" ]]; then
    echo "❌ This script must be run on VM159 (10.0.0.110)"
    echo "   Current IP: $CURRENT_IP"
    echo ""
    echo "Run this command to fix from remote:"
    echo "ssh root@10.0.0.110 'bash -s' < $0"
    exit 1
fi

echo "✅ Running on correct host ($CURRENT_IP)"
echo ""

# Check Docker is available
if ! command -v docker >/dev/null 2>&1; then
    echo "❌ Docker not found! Please install Docker first."
    exit 1
fi

echo "✅ Docker is available"
echo ""

# Stop and remove existing cAdvisor if it exists
echo "1️⃣  Cleaning up existing cAdvisor..."
if docker ps -a --format '{{.Names}}' | grep -q "^cadvisor$"; then
    echo "   🗑️  Stopping and removing existing cAdvisor container..."
    docker stop cadvisor 2>/dev/null || true
    docker rm cadvisor 2>/dev/null || true
    echo "   ✅ Cleanup complete"
else
    echo "   ℹ️  No existing cAdvisor container found"
fi

# Pull latest cAdvisor image
echo ""
echo "2️⃣  Pulling cAdvisor image..."
docker pull gcr.io/cadvisor/cadvisor:latest
echo "   ✅ Image pulled successfully"

# Start cAdvisor container
echo ""
echo "3️⃣  Starting cAdvisor container..."
docker run -d \
  --name=cadvisor \
  --restart=unless-stopped \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:ro \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --volume=/dev/disk/:/dev/disk:ro \
  --publish=8080:8080 \
  --privileged \
  --device=/dev/kmsg \
  gcr.io/cadvisor/cadvisor:latest

echo "   ✅ cAdvisor container started"

# Wait for cAdvisor to initialize
echo ""
echo "4️⃣  Waiting for cAdvisor to initialize..."
sleep 10

# Check if cAdvisor is running
if docker ps --format '{{.Names}}' | grep -q "^cadvisor$"; then
    echo "   ✅ cAdvisor container is running"
else
    echo "   ❌ cAdvisor container failed to start"
    echo "   📋 Check logs: docker logs cadvisor"
    exit 1
fi

# Test endpoint
echo ""
echo "5️⃣  Testing endpoint..."
if curl -s -m 10 http://localhost:8080/metrics >/dev/null; then
    CONTAINER_METRICS=$(curl -s http://localhost:8080/metrics | grep -c "container_" || echo "0")
    echo "   ✅ Endpoint responding with $CONTAINER_METRICS container metrics"
else
    echo "   ❌ Endpoint not responding"
    echo "   📋 Check container: docker logs cadvisor"
    exit 1
fi

# Show current Docker containers
echo ""
echo "6️⃣  Current Docker containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "🎉 cAdvisor fixed successfully!"
echo "   📊 Metrics available at: http://10.0.0.110:8080/metrics"
echo "   🌐 Web UI available at: http://10.0.0.110:8080"
echo "   📈 Check Prometheus targets in 1-2 minutes"
echo ""
#!/bin/bash

# OpenWebUI Ollama Connection Verification Script

echo "🔍 OpenWebUI Ollama Connection Verification"
echo "=========================================="

# Configuration
JUMP_HOST="root@136.243.155.166:2222"
VM_USER="simonadmin"
VM_IP="10.0.0.111"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

echo "1. Checking Docker containers status..."
CONTAINERS=$(ssh -J $JUMP_HOST -o ConnectTimeout=10 -o BatchMode=yes $VM_USER@$VM_IP "docker ps --filter name=ollama --filter name=open-webui --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'" 2>/dev/null)

if [ $? -eq 0 ]; then
    echo "$CONTAINERS"
    print_status "Docker containers check completed"
else
    print_error "Cannot connect to server"
    exit 1
fi

echo ""
echo "2. Testing Ollama API directly..."
if curl -s --max-time 10 http://10.0.0.111:11434/api/tags > /dev/null; then
    print_status "Ollama API is responding"
    
    # Get available models
    echo "📋 Available models:"
    curl -s http://10.0.0.111:11434/api/tags | jq -r '.models[] | "   - \(.name) (\(.size/1024/1024/1024 | floor)GB)"' 2>/dev/null || echo "   (Unable to parse model list)"
else
    print_error "Ollama API is not responding"
fi

echo ""
echo "3. Testing OpenWebUI accessibility..."
if curl -s --max-time 10 https://openwebui.simondatalab.de > /dev/null; then
    print_status "OpenWebUI is accessible via HTTPS"
else
    print_error "OpenWebUI is not accessible"
fi

echo ""
echo "4. Checking Docker network configuration..."
NETWORK_INFO=$(ssh -J $JUMP_HOST -o ConnectTimeout=10 -o BatchMode=yes $VM_USER@$VM_IP "docker network inspect ai-net --format '{{range .Containers}}{{.Name}} {{end}}'" 2>/dev/null)

if [ $? -eq 0 ]; then
    echo "Containers on ai-net network: $NETWORK_INFO"
    if [[ "$NETWORK_INFO" == *"ollama"* ]] && [[ "$NETWORK_INFO" == *"open-webui"* ]]; then
        print_status "Both containers are on the same network"
    else
        print_warning "Containers may not be on the same network"
    fi
else
    print_error "Cannot check network configuration"
fi

echo ""
echo "5. Testing internal container communication..."
# Test if OpenWebUI can reach Ollama internally
INTERNAL_TEST=$(ssh -J $JUMP_HOST -o ConnectTimeout=10 -o BatchMode=yes $VM_USER@$VM_IP "docker exec open-webui curl -s --max-time 5 http://ollama:11434/api/tags" 2>/dev/null)

if [ $? -eq 0 ] && [ -n "$INTERNAL_TEST" ]; then
    print_status "OpenWebUI can communicate with Ollama internally"
else
    print_warning "Internal communication test failed"
fi

echo ""
echo "📋 Configuration Summary:"
echo "   - Ollama URL: http://ollama:11434"
echo "   - OpenWebUI URL: https://openwebui.simondatalab.de"
echo "   - Network: ai-net"
echo ""
echo "🔧 Next Steps:"
echo "   1. Go to: https://openwebui.simondatalab.de/admin/settings/connections"
echo "   2. Add Ollama connection with URL: http://ollama:11434"
echo "   3. Models should appear automatically"
echo ""
echo "💡 If models don't appear:"
echo "   - Check OpenWebUI logs: docker logs open-webui"
echo "   - Restart OpenWebUI: docker restart open-webui"


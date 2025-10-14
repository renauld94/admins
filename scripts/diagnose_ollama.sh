#!/bin/bash

# Ollama Service Diagnostic Script
# Quick check of Ollama service status

echo "🔍 Ollama Service Diagnostic"
echo "============================"

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

echo "1. Testing direct connection to Ollama service..."
if curl -s --max-time 5 http://10.0.0.111:11434/api/tags > /dev/null 2>&1; then
    print_status "Ollama service is responding on port 11434"
else
    print_error "Ollama service is not responding on port 11434"
fi

echo ""
echo "2. Checking Docker container status..."
CONTAINER_INFO=$(ssh -J $JUMP_HOST -o ConnectTimeout=10 -o BatchMode=yes $VM_USER@$VM_IP "docker ps -a --filter name=ollama --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'" 2>/dev/null)

if [ $? -eq 0 ]; then
    if [ -n "$CONTAINER_INFO" ]; then
        echo "$CONTAINER_INFO"
        print_status "Docker container found"
    else
        print_warning "No Ollama Docker container found"
    fi
else
    print_error "Cannot connect to server or Docker not available"
fi

echo ""
echo "3. Testing Cloudflare proxy..."
if curl -s --max-time 10 https://ollama.simondatalab.de/api/tags > /dev/null 2>&1; then
    print_status "Cloudflare proxy is working"
else
    print_error "Cloudflare proxy is not working (524 timeout)"
fi

echo ""
echo "4. Checking nginx proxy configuration..."
NGINX_STATUS=$(ssh -J $JUMP_HOST -o ConnectTimeout=10 -o BatchMode=yes $VM_USER@$VM_IP "nginx -t" 2>/dev/null)
if [ $? -eq 0 ]; then
    print_status "Nginx configuration is valid"
else
    print_error "Nginx configuration has errors"
fi

echo ""
echo "📋 Summary:"
echo "   - Direct service test: $(curl -s --max-time 3 http://10.0.0.111:11434/api/tags > /dev/null 2>&1 && echo "✅ Working" || echo "❌ Not working")"
echo "   - Cloudflare proxy: $(curl -s --max-time 5 https://ollama.simondatalab.de/api/tags > /dev/null 2>&1 && echo "✅ Working" || echo "❌ Not working")"
echo ""
echo "🔧 Next steps:"
echo "   - If direct service fails: Run ./restart_ollama.sh"
echo "   - If Cloudflare fails but direct works: Check nginx configuration"
echo "   - If both fail: Check server connectivity and Docker status"


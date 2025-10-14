#!/bin/bash

# AI Services Performance Monitor
# Comprehensive monitoring script for Ollama and OpenWebUI services

echo "🔍 AI Services Performance Monitor"
echo "=================================="
echo "Timestamp: $(date)"
echo ""

# Configuration
JUMP_HOST="root@136.243.155.166:2222"
VM_USER="simonadmin"
VM_IP="10.0.0.111"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

echo "1. 🌐 Testing External Access..."
echo "   Ollama (Cloudflare): $(curl -s --max-time 5 https://ollama.simondatalab.de/api/tags > /dev/null 2>&1 && print_status "Accessible" || print_error "Not accessible")"
echo "   OpenWebUI: $(curl -s --max-time 5 https://openwebui.simondatalab.de > /dev/null 2>&1 && print_status "Accessible" || print_error "Not accessible")"

echo ""
echo "2. 🐳 Docker Container Status..."
CONTAINER_STATUS=$(ssh -J $JUMP_HOST -o ConnectTimeout=10 -o BatchMode=yes $VM_USER@$VM_IP "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'" 2>/dev/null)

if [ $? -eq 0 ]; then
    echo "$CONTAINER_STATUS"
    print_status "Docker containers checked"
else
    print_error "Cannot connect to Docker"
fi

echo ""
echo "3. 💾 System Resources..."
RESOURCE_INFO=$(ssh -J $JUMP_HOST -o ConnectTimeout=10 -o BatchMode=yes $VM_USER@$VM_IP "free -h && echo '---' && df -h | head -5 && echo '---' && uptime" 2>/dev/null)

if [ $? -eq 0 ]; then
    echo "$RESOURCE_INFO"
    print_status "Resource information retrieved"
else
    print_error "Cannot retrieve resource information"
fi

echo ""
echo "4. 🧠 Available Models..."
MODEL_INFO=$(curl -s --max-time 10 https://ollama.simondatalab.de/api/tags 2>/dev/null)

if [ $? -eq 0 ] && [ -n "$MODEL_INFO" ]; then
    echo "$MODEL_INFO" | jq -r '.models[] | "   - \(.name) (\(.size/1024/1024/1024 | floor)GB)"' 2>/dev/null || echo "   (Unable to parse model list)"
    print_status "Model list retrieved"
else
    print_warning "Cannot retrieve model list"
fi

echo ""
echo "5. ⚡ Performance Metrics..."
PERF_INFO=$(ssh -J $JUMP_HOST -o ConnectTimeout=10 -o BatchMode=yes $VM_USER@$VM_IP "docker stats --no-stream --format 'table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}'" 2>/dev/null)

if [ $? -eq 0 ]; then
    echo "$PERF_INFO"
    print_status "Performance metrics retrieved"
else
    print_warning "Cannot retrieve performance metrics"
fi

echo ""
echo "6. 🔧 Service Health Check..."
HEALTH_CHECK=$(ssh -J $JUMP_HOST -o ConnectTimeout=10 -o BatchMode=yes $VM_USER@$VM_IP "curl -s --max-time 5 http://localhost:11434/api/tags > /dev/null 2>&1 && echo 'Ollama: Healthy' || echo 'Ollama: Unhealthy'" 2>/dev/null)

if [ $? -eq 0 ]; then
    echo "   $HEALTH_CHECK"
else
    print_error "Cannot perform health check"
fi

echo ""
echo "📊 Performance Summary:"
echo "   - External Access: $(curl -s --max-time 3 https://ollama.simondatalab.de/api/tags > /dev/null 2>&1 && echo "✅ Working" || echo "❌ Issues")"
echo "   - Docker Status: $(ssh -J $JUMP_HOST -o ConnectTimeout=5 -o BatchMode=yes $VM_USER@$VM_IP "docker ps | grep -q ollama && echo '✅ Running' || echo '❌ Not Running'" 2>/dev/null || echo "❌ Unknown")"
echo "   - Resource Usage: $(ssh -J $JUMP_HOST -o ConnectTimeout=5 -o BatchMode=yes $VM_USER@$VM_IP "free | awk 'NR==2{printf \"%.1f%%\", \$3/\$2*100}'" 2>/dev/null || echo "Unknown")"

echo ""
echo "🔧 Recommended Actions:"
echo "   1. If services are down: Run ./scripts/restart_ollama.sh"
echo "   2. If performance is slow: Check resource usage and optimize"
echo "   3. If models are missing: Pull additional models with ollama pull"
echo "   4. For monitoring: Run this script regularly"

echo ""
echo "📈 Next Steps:"
echo "   - Review AI_PERFORMANCE_ANALYSIS.md for detailed optimization guide"
echo "   - Implement recommended model configurations"
echo "   - Set up automated monitoring"
echo "   - Test coding assistant performance with sample prompts"

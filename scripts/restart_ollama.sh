#!/bin/bash

# Ollama Service Restart Script
# This script helps restart the Ollama Docker container on the server

echo "🔄 Ollama Service Restart Script"
echo "================================"

# Configuration
JUMP_HOST="root@136.243.155.166:2222"
VM_USER="simonadmin"
VM_IP="10.0.0.111"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

echo "🔍 Checking Ollama container status..."

# Check if Ollama container is running
CONTAINER_STATUS=$(ssh -J $JUMP_HOST -o ConnectTimeout=10 -o BatchMode=yes $VM_USER@$VM_IP "docker ps --filter name=ollama --format '{{.Status}}'" 2>/dev/null)

if [ $? -eq 0 ]; then
    if [ -n "$CONTAINER_STATUS" ]; then
        print_status "Ollama container is running: $CONTAINER_STATUS"
        echo "🔄 Restarting Ollama container..."
        
        # Restart the container
        ssh -J $JUMP_HOST -t $VM_USER@$VM_IP "docker restart ollama"
        
        if [ $? -eq 0 ]; then
            print_status "Ollama container restarted successfully!"
            
            # Wait a moment for the service to start
            echo "⏳ Waiting for Ollama to start..."
            sleep 10
            
            # Test the connection
            echo "🧪 Testing Ollama connection..."
            if curl -s --max-time 10 http://10.0.0.111:11434/api/tags > /dev/null; then
                print_status "Ollama is responding correctly!"
                echo "🌐 Try accessing: https://ollama.simondatalab.de"
            else
                print_warning "Ollama container restarted but may still be starting up"
                echo "⏳ Please wait a few more minutes and try again"
            fi
        else
            print_error "Failed to restart Ollama container"
        fi
    else
        print_warning "Ollama container is not running"
        echo "🚀 Starting Ollama container..."
        
        # Start the container
        ssh -J $JUMP_HOST -t $VM_USER@$VM_IP "docker start ollama"
        
        if [ $? -eq 0 ]; then
            print_status "Ollama container started successfully!"
            echo "⏳ Waiting for Ollama to initialize..."
            sleep 15
            
            # Test the connection
            echo "🧪 Testing Ollama connection..."
            if curl -s --max-time 10 http://10.0.0.111:11434/api/tags > /dev/null; then
                print_status "Ollama is responding correctly!"
                echo "🌐 Try accessing: https://ollama.simondatalab.de"
            else
                print_warning "Ollama container started but may still be initializing"
                echo "⏳ Please wait a few more minutes and try again"
            fi
        else
            print_error "Failed to start Ollama container"
            echo "💡 You may need to recreate the container with: docker run -d --name ollama -p 11434:11434 -v ollama_data:/root/.ollama ollama/ollama:latest"
        fi
    fi
else
    print_error "Cannot connect to server or Docker is not running"
    echo "🔧 Troubleshooting steps:"
    echo "   1. Check if the server is accessible"
    echo "   2. Verify Docker is installed and running"
    echo "   3. Check if the Ollama container exists: docker ps -a | grep ollama"
fi

echo ""
echo "📋 Additional Commands:"
echo "   Check container status: ssh -J $JUMP_HOST $VM_USER@$VM_IP 'docker ps | grep ollama'"
echo "   View container logs: ssh -J $JUMP_HOST $VM_USER@$VM_IP 'docker logs ollama'"
echo "   Stop container: ssh -J $JUMP_HOST $VM_USER@$VM_IP 'docker stop ollama'"
echo "   Remove container: ssh -J $JUMP_HOST $VM_USER@$VM_IP 'docker rm ollama'"


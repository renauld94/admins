#!/bin/bash
# Clean restart script for metrics proxy

# Load NVM if available
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Use Node 18
nvm use 18 >/dev/null 2>&1

# Kill anything on port 8088
echo "Stopping any process on port 8088..."
sudo lsof -ti:8088 | xargs -r sudo kill -9 >/dev/null 2>&1
sleep 2

# Kill any existing node processes in this directory
echo "Stopping existing proxy processes..."
pkill -f "node.*server.js" >/dev/null 2>&1
sleep 2

# Go to the proxy directory
cd ~/apps/metrics-proxy

# Check if we have the needed files
if [ ! -f "server.js" ]; then
    echo "ERROR: server.js not found in $(pwd)"
    exit 1
fi

if [ ! -f ".env" ]; then
    echo "ERROR: .env not found in $(pwd)"
    exit 1
fi

# Start the proxy
echo "Starting metrics proxy..."
NODE_BIN=$(which node)
export NODE_ENV=production

# Start with nohup and redirect output to a log file
nohup $NODE_BIN server.js > proxy.log 2>&1 &
PID=$!

echo "Started proxy with PID: $PID"

# Wait a moment for startup
sleep 3

# Check if it's running
if kill -0 $PID 2>/dev/null; then
    echo "Proxy is running (PID: $PID)"
    
    # Test local health endpoint
    if curl -s http://localhost:8088/health >/dev/null 2>&1; then
        echo "✓ Health endpoint responding"
    else
        echo "✗ Health endpoint not responding"
    fi
    
    # Show port status
    echo "Port 8088 status:"
    ss -tln | grep :8088
    
else
    echo "✗ Proxy failed to start"
    echo "Last few lines of log:"
    tail -5 proxy.log
    exit 1
fi

echo "Restart complete!"
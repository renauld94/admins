#!/bin/bash

# Learning Odyssey - One Command Deployment
# Deploy to Moodle course via proxy jump when connection is available

set -e

echo "🚀 Learning Odyssey - One Command Deployment"
echo "============================================="
echo "Target: https://moodle.simondatalab.de/course/view.php?id=2"
echo "Proxy: root@136.243.155.166"
echo "Target: simonadmin@10.0.0.104"
echo ""

# Test connection
echo "🔍 Testing connection..."
if ssh -o ConnectTimeout=10 -o BatchMode=yes -J root@136.243.155.166 simonadmin@10.0.0.104 "echo 'Connection successful'" 2>/dev/null; then
    echo "✅ Connection established! Proceeding with deployment..."
    
    # Deploy using the ready script
    ./deploy-when-ready.sh
    
else
    echo "❌ Connection not available. Please try again when servers are accessible."
    echo ""
    echo "📦 Alternative: Manual deployment package ready:"
    echo "   File: learning-odyssey-deployment.tar.gz (70KB)"
    echo ""
    echo "🔧 Manual deployment commands:"
    echo "   1. scp -J root@136.243.155.166 learning-odyssey-deployment.tar.gz simonadmin@10.0.0.104:~/"
    echo "   2. ssh -J root@136.243.155.166 simonadmin@10.0.0.104"
    echo "   3. tar -xzf learning-odyssey-deployment.tar.gz"
    echo "   4. cd odyssey-implementation && ../deploy-odyssey.sh"
    echo ""
    echo "🌐 Or use any of these deployment scripts:"
    echo "   - ./deploy-when-ready.sh (automated)"
    echo "   - ./deploy-proxy-jump.sh (proxy jump)"
    echo "   - ./deploy-full.sh (comprehensive)"
    echo ""
    echo "📋 Files ready for deployment:"
    ls -la *.sh *.tar.gz | grep -E "(deploy|learning-odyssey)" || true
fi

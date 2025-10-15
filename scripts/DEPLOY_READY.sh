#!/usr/bin/env bash
# Thin wrapper to preserve compatibility — forwards to ./scripts/DEPLOY_READY.sh
SCRIPT_DIR="$(dirname "$0")"
exec "$SCRIPT_DIR/scripts/DEPLOY_READY.sh" "$@"
#!/bin/bash

# Learning Odyssey - Ready for Deployment
# This script will deploy when the connection is available

set -e

echo "🚀 Learning Odyssey - Ready for Deployment"
echo "==========================================="
echo "Target: https://moodle.simondatalab.de/course/view.php?id=2"
echo "Proxy: root@136.243.155.166:2222"
echo "Target: simonadmin@10.0.0.104"
echo ""

# Test connections
echo "🔍 Testing connections..."

# Test proxy
if ssh -p 2222 -o ConnectTimeout=5 root@136.243.155.166 "echo 'Proxy OK'" 2>/dev/null; then
    echo "✅ Proxy connection: OK"
    PROXY_OK=true
else
    echo "❌ Proxy connection: FAILED"
    PROXY_OK=false
fi

# Test target via proxy
if [ "$PROXY_OK" = true ]; then
    if ssh -p 2222 -J root@136.243.155.166 -o ConnectTimeout=5 simonadmin@10.0.0.104 "echo 'Target via proxy OK'" 2>/dev/null; then
        echo "✅ Target via proxy: OK"
        TARGET_OK=true
    else
        echo "❌ Target via proxy: FAILED"
        TARGET_OK=false
    fi
else
    TARGET_OK=false
fi

# Test direct target
if ssh -o ConnectTimeout=5 simonadmin@10.0.0.104 "echo 'Direct target OK'" 2>/dev/null; then
    echo "✅ Direct target: OK"
    DIRECT_OK=true
else
    echo "❌ Direct target: FAILED"
    DIRECT_OK=false
fi

echo ""

if [ "$TARGET_OK" = true ] || [ "$DIRECT_OK" = true ]; then
    echo "🎉 Connection available! Proceeding with deployment..."
    
    if [ "$TARGET_OK" = true ]; then
        echo "Using proxy connection..."
        ./deploy-correct-port.sh
    else
        echo "Using direct connection..."
        # Create a direct deployment script
        cat > deploy-direct.sh << 'EOF'
#!/bin/bash
# Direct deployment without proxy
TARGET_HOST="simonadmin@10.0.0.104"
ODYSSEY_PATH="/var/www/html/moodle/course/2/odyssey"

echo "🚀 Deploying Learning Odyssey directly..."

# Create directory structure
ssh $TARGET_HOST "mkdir -p $ODYSSEY_PATH/{js,css,images,ai,analytics}"

# Copy files
scp odyssey-implementation/learning-universe.js $TARGET_HOST:$ODYSSEY_PATH/js/
scp odyssey-implementation/d3-dashboard.js $TARGET_HOST:$ODYSSEY_PATH/js/
scp odyssey-implementation/ai-oracle-system.py $TARGET_HOST:$ODYSSEY_PATH/ai/
scp odyssey-implementation/databricks-analytics.py $TARGET_HOST:$ODYSSEY_PATH/analytics/
scp odyssey-implementation/examples/basic-setup.html $TARGET_HOST:$ODYSSEY_PATH/odyssey-demo.html
scp odyssey-implementation/README.md $TARGET_HOST:$ODYSSEY_PATH/
scp ODYSSEY_IMPLEMENTATION_SUMMARY.md $TARGET_HOST:$ODYSSEY_PATH/

# Set permissions
ssh $TARGET_HOST "chown -R www-data:www-data $ODYSSEY_PATH && chmod -R 755 $ODYSSEY_PATH"

echo "✅ Deployment complete!"
EOF
        chmod +x deploy-direct.sh
        ./deploy-direct.sh
    fi
    
else
    echo "❌ No connection available. Please try again when servers are accessible."
    echo ""
    echo "📦 Deployment package ready:"
    echo "   File: learning-odyssey-deployment.tar.gz (70KB)"
    echo ""
    echo "🔧 Manual deployment commands:"
    echo "   1. scp -P 2222 -J root@136.243.155.166 learning-odyssey-deployment.tar.gz simonadmin@10.0.0.104:~/"
    echo "   2. ssh -p 2222 -J root@136.243.155.166 simonadmin@10.0.0.104"
    echo "   3. tar -xzf learning-odyssey-deployment.tar.gz"
    echo "   4. cd odyssey-implementation && ../deploy-odyssey.sh"
    echo ""
    echo "🌐 Or use any of these deployment scripts:"
    echo "   - ./deploy-correct-port.sh (proxy with port 2222)"
    echo "   - ./deploy-when-ready.sh (automated)"
    echo "   - ./deploy-full.sh (comprehensive)"
    echo ""
    echo "📋 Files ready for deployment:"
    ls -la *.sh *.tar.gz | grep -E "(deploy|learning-odyssey)"
fi


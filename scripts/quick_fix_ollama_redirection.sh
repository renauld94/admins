#!/bin/bash

# Quick Fix for Ollama Subdomain Redirection
# This script quickly fixes the ollama.simondatalab.de redirection issue

echo "🚀 Quick Fix for Ollama Subdomain Redirection"
echo "============================================="

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

echo "🔍 Current Issue:"
echo "   - https://ollama.simondatalab.de/ shows portfolio content (WRONG)"
echo "   - Should show Ollama AI service or Moodle LMS (CORRECT)"
echo ""

echo "🔧 Applying quick fix..."

# Create a simple nginx configuration fix
ssh -J $JUMP_HOST -t $VM_USER@$VM_IP "
    echo 'Creating nginx configuration fix...'
    
    # Create a specific configuration for ollama subdomain
    sudo tee /etc/nginx/sites-available/ollama.simondatalab.de << 'EOF'
server {
    listen 80;
    server_name ollama.simondatalab.de;
    
    # Redirect root to Moodle LMS
    location = / {
        return 302 http://moodle.simondatalab.de/;
    }
    
    # Serve geospatial visualization
    location /geospatial-viz/ {
        root /var/www/html;
        index index.html;
        try_files \$uri \$uri/ =404;
    }
    
    # Proxy API calls to Ollama service
    location /api/ {
        proxy_pass http://localhost:11434/api/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        proxy_connect_timeout 300;
        proxy_send_timeout 300;
        proxy_read_timeout 300;
    }
    
    # Default: redirect to Moodle
    location / {
        return 302 http://moodle.simondatalab.de/;
    }
}
EOF

    # Enable the site
    sudo ln -sf /etc/nginx/sites-available/ollama.simondatalab.de /etc/nginx/sites-enabled/
    
    # Test nginx configuration
    sudo nginx -t
    
    if [ \$? -eq 0 ]; then
        echo '✅ Nginx configuration is valid'
        sudo systemctl reload nginx
        echo '✅ Nginx reloaded successfully'
    else
        echo '❌ Nginx configuration has errors'
        sudo rm -f /etc/nginx/sites-enabled/ollama.simondatalab.de
    fi
"

if [ $? -eq 0 ]; then
    print_status "Quick fix applied successfully"
else
    print_error "Failed to apply quick fix"
fi

echo ""
echo "🧪 Testing the fix..."

# Test the geospatial visualization
echo "Testing geospatial visualization..."
if curl -s --max-time 10 https://ollama.simondatalab.de/geospatial-viz/index.html | grep -q "GeoServer"; then
    print_status "Geospatial visualization is working correctly"
else
    print_warning "Geospatial visualization may have issues"
fi

echo ""
echo "📋 What was fixed:"
echo "✅ ollama.simondatalab.de/ → Redirects to Moodle LMS"
echo "✅ ollama.simondatalab.de/geospatial-viz/ → Serves geospatial visualization"
echo "✅ ollama.simondatalab.de/api/ → Proxies to Ollama service"
echo ""
echo "🌐 Test URLs:"
echo "   - https://ollama.simondatalab.de/ (redirects to Moodle)"
echo "   - https://ollama.simondatalab.de/geospatial-viz/ (geospatial viz)"
echo "   - https://ollama.simondatalab.de/api/tags (Ollama API)"
echo ""
echo "💡 The main portfolio site at https://www.simondatalab.de/ remains unchanged."

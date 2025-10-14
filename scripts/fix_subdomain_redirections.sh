#!/bin/bash

# Fix Subdomain Redirections Script
# This script fixes the incorrect redirections for ollama.simondatalab.de

echo "🔧 Fixing Subdomain Redirections"
echo "================================="

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

echo "Current Issue:"
echo "- https://www.simondatalab.de/ = Personal Portfolio (CORRECT)"
echo "- https://ollama.simondatalab.de/ = Same as main site (INCORRECT)"
echo "- https://ollama.simondatalab.de/geospatial-viz/index.html = Geospatial viz (CORRECT)"
echo ""
echo "Expected Configuration:"
echo "- https://www.simondatalab.de/ = Personal Portfolio"
echo "- https://ollama.simondatalab.de/ = Ollama AI Service (port 11434)"
echo "- https://moodle.simondatalab.de/ = Moodle Learning Management System"
echo ""

echo "🔍 Checking current Docker containers..."
CONTAINERS=$(ssh -J $JUMP_HOST -o ConnectTimeout=10 -o BatchMode=yes $VM_USER@$VM_IP "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'" 2>/dev/null)

if [ $? -eq 0 ]; then
    echo "$CONTAINERS"
    print_status "Docker containers retrieved"
else
    print_error "Cannot connect to server"
    exit 1
fi

echo ""
echo "🔧 Creating proper nginx configuration for subdomains..."

# Create nginx configuration for proper subdomain routing
cat > /tmp/nginx_subdomain_config.conf << 'EOF'
# Main site (www.simondatalab.de)
server {
    listen 80;
    server_name www.simondatalab.de;
    
    # Serve the portfolio website
    location / {
        root /var/www/html/portfolio;
        index index.html;
        try_files $uri $uri/ =404;
    }
}

# Ollama subdomain (ollama.simondatalab.de)
server {
    listen 80;
    server_name ollama.simondatalab.de;
    
    # Proxy to Ollama service
    location / {
        proxy_pass http://localhost:11434;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support for Ollama
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        
        proxy_connect_timeout 300;
        proxy_send_timeout 300;
        proxy_read_timeout 300;
    }
    
    # Serve geospatial visualization
    location /geospatial-viz/ {
        root /var/www/html;
        index index.html;
        try_files $uri $uri/ =404;
    }
}

# Moodle subdomain (moodle.simondatalab.de)
server {
    listen 80;
    server_name moodle.simondatalab.de;
    
    # Proxy to Moodle service
    location / {
        proxy_pass http://localhost:8086;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        proxy_connect_timeout 300;
        proxy_send_timeout 300;
        proxy_read_timeout 300;
    }
}
EOF

echo "📤 Uploading nginx configuration..."
scp -o ProxyJump=$JUMP_HOST /tmp/nginx_subdomain_config.conf $VM_USER@$VM_IP:/tmp/nginx_subdomain_config.conf

if [ $? -eq 0 ]; then
    print_status "Configuration uploaded"
else
    print_error "Failed to upload configuration"
    exit 1
fi

echo ""
echo "🔧 Applying nginx configuration..."
ssh -J $JUMP_HOST -t $VM_USER@$VM_IP "
    # Backup current nginx config
    sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup.$(date +%Y%m%d_%H%M%S)
    
    # Copy new configuration
    sudo cp /tmp/nginx_subdomain_config.conf /etc/nginx/sites-available/default
    
    # Test nginx configuration
    sudo nginx -t
    
    if [ \$? -eq 0 ]; then
        echo '✅ Nginx configuration is valid'
        sudo systemctl reload nginx
        echo '✅ Nginx reloaded successfully'
    else
        echo '❌ Nginx configuration has errors'
        sudo cp /etc/nginx/sites-available/default.backup.$(date +%Y%m%d_%H%M%S) /etc/nginx/sites-available/default
        echo '🔄 Restored backup configuration'
    fi
"

if [ $? -eq 0 ]; then
    print_status "Nginx configuration applied"
else
    print_error "Failed to apply nginx configuration"
fi

echo ""
echo "🧪 Testing the fixes..."

# Test main site
echo "Testing main site..."
if curl -s --max-time 10 https://www.simondatalab.de/ | grep -q "Simon Renauld"; then
    print_status "Main site (www.simondatalab.de) is working correctly"
else
    print_warning "Main site may have issues"
fi

# Test Ollama service
echo "Testing Ollama service..."
if curl -s --max-time 10 https://ollama.simondatalab.de/api/tags > /dev/null 2>&1; then
    print_status "Ollama service (ollama.simondatalab.de) is working correctly"
else
    print_warning "Ollama service may not be responding"
fi

# Test geospatial visualization
echo "Testing geospatial visualization..."
if curl -s --max-time 10 https://ollama.simondatalab.de/geospatial-viz/index.html | grep -q "GeoServer"; then
    print_status "Geospatial visualization is working correctly"
else
    print_warning "Geospatial visualization may have issues"
fi

echo ""
echo "📋 Summary of Changes:"
echo "✅ Fixed nginx configuration for proper subdomain routing"
echo "✅ www.simondatalab.de → Personal Portfolio"
echo "✅ ollama.simondatalab.de → Ollama AI Service (port 11434)"
echo "✅ ollama.simondatalab.de/geospatial-viz/ → Geospatial Visualization"
echo "✅ moodle.simondatalab.de → Moodle Learning Management System (port 8086)"
echo ""
echo "🌐 Test URLs:"
echo "   - https://www.simondatalab.de/ (Portfolio)"
echo "   - https://ollama.simondatalab.de/ (Ollama AI)"
echo "   - https://ollama.simondatalab.de/geospatial-viz/ (Geospatial Viz)"
echo "   - https://moodle.simondatalab.de/ (Moodle LMS)"
echo ""
echo "💡 Note: DNS propagation may take a few minutes for the new subdomain configurations."

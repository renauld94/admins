#!/bin/bash
# Deploy Epic Cinematic Animation to Portfolio
# Copies generated animation files from VM 159 to portfolio website

set -e

echo "=========================================="
echo "DEPLOY TO PORTFOLIO - Epic Cinematic"
echo "=========================================="
echo "Date: $(date)"
echo "=========================================="

# Configuration
PROXMOX_HOST="136.243.155.166:2222"
PROXMOX_USER="root"
VM_IP="10.0.0.110"
VM_USER="simonadmin"

# Local workspace
WORKSPACE="/home/simon/Learning-Management-System-Academy"
PORTFOLIO_REPO="$WORKSPACE"

# Portfolio directories
PORTFOLIO_DIR="$PORTFOLIO_REPO/portfolio-deployment-enhanced/neural-hero"
TEMP_DIR="/tmp/epic-cinematic-portfolio"

echo ""
echo "[1] Creating portfolio directory structure..."
mkdir -p "$PORTFOLIO_DIR"

echo "[2] Retrieving animation files from VM 159..."
SSH_CMD="ssh -J ${PROXMOX_USER}@${PROXMOX_HOST} ${VM_USER}@${VM_IP}"

# Create temp directory
mkdir -p "$TEMP_DIR"

# Copy files from VM 159 via SSH
echo "   Downloading index.html..."
$SSH_CMD "cat /home/simonadmin/epic-cinematic-output/index.html" > "$TEMP_DIR/index.html"

echo "   Downloading main.js..."
$SSH_CMD "cat /home/simonadmin/epic-cinematic-output/main.js" > "$TEMP_DIR/main.js"

echo "   Downloading package.json..."
$SSH_CMD "cat /home/simonadmin/epic-cinematic-output/package.json" > "$TEMP_DIR/package.json"

echo "   Downloading README.md..."
$SSH_CMD "cat /home/simonadmin/epic-cinematic-output/README.md" > "$TEMP_DIR/README.md"

echo "[3] Copying to portfolio directory..."
cp "$TEMP_DIR"/* "$PORTFOLIO_DIR/"
chmod 644 "$PORTFOLIO_DIR"/*

echo "[4] Verifying portfolio files..."
ls -lh "$PORTFOLIO_DIR/"

echo "[5] Creating deployment summary..."
cat > "$PORTFOLIO_DIR/DEPLOYMENT.txt" << 'EOF'
Epic Cinematic Neural-to-Cosmic Animation
==========================================

Deployed: $(date)
Source: VM 159 (ubuntuai-1000110)
Technology: Three.js 0.160.0 (CDN)

Features:
- 105-second seamless cinematic loop
- Real-time FPS display
- Geographic infrastructure visualization
- Responsive design (desktop, tablet, mobile)
- WebGL 2.0 compatible
- 60 FPS target

Access:
- Direct: Open index.html in web browser
- Live: http://10.0.0.110:8000 (VM 159)
- Portfolio: /portfolio-deployment-enhanced/neural-hero/

Animation Loop:
- Neural network particles
- Geographic nodes (8 global, 4 regional)
- Orbital satellites (VM 159, VM 9001, ML Training, GeoServer, Network)
- Cinematic camera path

Size: ~12 KB total (highly optimized)
Performance: ~200 MB memory, <1% CPU idle

For more information, see:
- README.md (in this directory)
- EPIC_CINEMATIC_VM159_DEPLOYMENT.md (project root)
- EPIC_CINEMATIC_QUICK_REFERENCE.md (project root)
EOF

echo "[6] Creating .htaccess for HTTP server config..."
cat > "$PORTFOLIO_DIR/.htaccess" << 'EOF'
# Epic Cinematic Animation - HTTP Server Configuration
<IfModule mod_headers.c>
    # CORS headers
    Header set Access-Control-Allow-Origin "*"
    Header set Access-Control-Allow-Methods "GET, OPTIONS"
    Header set Access-Control-Allow-Headers "Content-Type"
    
    # Cache headers
    Header set Cache-Control "public, max-age=3600"
    
    # Content-Type headers
    AddType text/html .html
    AddType application/javascript .js
    AddType application/json .json
</IfModule>

# Default file
DirectoryIndex index.html

# Prevent directory listing
Options -Indexes
EOF

echo ""
echo "=========================================="
echo "DEPLOYMENT TO PORTFOLIO COMPLETE"
echo "=========================================="
echo ""
echo "Portfolio Location:"
echo "  $PORTFOLIO_DIR"
echo ""
echo "Files Deployed:"
ls -1 "$PORTFOLIO_DIR" | sed 's/^/  - /'
echo ""
echo "Access Portfolio:"
echo "  Local File: file://$PORTFOLIO_DIR/index.html"
echo "  Via HTTP: Copy directory to web server"
echo "  Portfolio URL: https://www.simondatalab.de/portfolio-deployment-enhanced/neural-hero/"
echo ""
echo "Next Steps:"
echo "  1. Commit changes to git"
echo "  2. Push to portfolio repository"
echo "  3. Configure web server to serve from $PORTFOLIO_DIR"
echo "  4. Test animation in browser"
echo ""

#!/bin/bash
# Deploy Epic Course Theme to Moodle VM (Docker Container)
# Date: October 15, 2025
# Author: Simon Renauld

set -e

echo "🚀 Epic Course Theme Deployment to Moodle Docker Container"
echo "============================================================"
echo ""

# Configuration
PROXMOX_HOST="136.243.155.166"
PROXMOX_PORT="2222"
VM_IP="10.0.0.104"
THEME_CSS="epic-course-theme.css"
THEME_JS="epic-course-interactive.js"
LOCAL_PATH="/home/simon/Learning-Management-System-Academy/learning-platform"

echo "📋 Deployment Plan:"
echo "  - Upload files to Proxmox"
echo "  - Access VM 9001 (Moodle Docker)"
echo "  - Copy files to Moodle theme directory"
echo "  - Update Moodle theme configuration"
echo ""

# Step 1: Upload files to Proxmox
echo "📤 Step 1: Uploading files to Proxmox..."
scp -P ${PROXMOX_PORT} \
    "${LOCAL_PATH}/${THEME_CSS}" \
    "${LOCAL_PATH}/${THEME_JS}" \
    root@${PROXMOX_HOST}:/tmp/
echo "✅ Files uploaded to Proxmox /tmp/"
echo ""

# Step 2: Instructions for manual VM access
echo "⚠️  MANUAL STEPS REQUIRED:"
echo ""
echo "The VM 9001 is running Docker containers. You need to:"
echo ""
echo "1. Access the VM console:"
echo "   ssh -p ${PROXMOX_PORT} root@${PROXMOX_HOST}"
echo "   qm terminal 9001"
echo "   (or use Proxmox web UI: https://${PROXMOX_HOST}:8006)"
echo ""
echo "2. Once in the VM, check Docker containers:"
echo "   docker ps"
echo ""
echo "3. Find the Moodle container (likely named 'moodle' or 'moodle-web'):"
echo "   MOODLE_CONTAINER=\$(docker ps --filter name=moodle --format '{{.Names}}' | head -1)"
echo "   echo \"Moodle container: \$MOODLE_CONTAINER\""
echo ""
echo "4. Copy files into the container:"
echo "   docker cp /tmp/${THEME_CSS} \$MOODLE_CONTAINER:/var/www/html/"
echo "   docker cp /tmp/${THEME_JS} \$MOODLE_CONTAINER:/var/www/html/"
echo ""
echo "5. Access the container to verify:"
echo "   docker exec -it \$MOODLE_CONTAINER bash"
echo "   ls -la /var/www/html/${THEME_CSS}"
echo "   ls -la /var/www/html/${THEME_JS}"
echo ""
echo "6. Add to Moodle theme (OPTION A - Manual in Moodle Admin):"
echo "   - Login to Moodle as admin"
echo "   - Go to: Site administration > Appearance > Additional HTML"
echo "   - Add to \"Within HEAD\":"
echo "     <link rel=\"stylesheet\" href=\"/${THEME_CSS}\">"
echo "     <script src=\"/${THEME_JS}\"></script>"
echo ""
echo "7. Or (OPTION B - Edit theme files directly):"
echo "   docker exec -it \$MOODLE_CONTAINER bash"
echo "   cd /var/www/html/theme/boost/layout"
echo "   # Edit columns2.php or header.php to add:"
echo "   # <link rel=\"stylesheet\" href=\"/<?php echo \$CFG->wwwroot ?>/${THEME_CSS}\">"
echo "   # <script src=\"/<?php echo \$CFG->wwwroot ?>/${THEME_JS}\"></script>"
echo ""

# Step 3: Create a helper script for VM
echo "📝 Creating helper script for VM..."

cat > /tmp/moodle-theme-install.sh << 'VMSCRIPT'
#!/bin/bash
# Run this script INSIDE VM 9001

echo "🔍 Finding Moodle Docker container..."
MOODLE_CONTAINER=$(docker ps --filter name=moodle --format '{{.Names}}' | head -1)

if [ -z "$MOODLE_CONTAINER" ]; then
    echo "❌ No Moodle container found!"
    echo "Available containers:"
    docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
    exit 1
fi

echo "✅ Found Moodle container: $MOODLE_CONTAINER"
echo ""

echo "📂 Copying theme files..."
docker cp /tmp/epic-course-theme.css $MOODLE_CONTAINER:/var/www/html/
docker cp /tmp/epic-course-interactive.js $MOODLE_CONTAINER:/var/www/html/

echo "✅ Files copied to container"
echo ""

echo "🔍 Verifying files..."
docker exec $MOODLE_CONTAINER ls -lh /var/www/html/epic-course-*

echo ""
echo "✅ Deployment to container complete!"
echo ""
echo "📝 Next steps:"
echo "1. Login to Moodle admin panel"
echo "2. Go to: Site administration > Appearance > Additional HTML"
echo "3. Add to 'Within HEAD' section:"
echo "   <link rel=\"stylesheet\" href=\"/epic-course-theme.css\">"
echo "   <script src=\"/epic-course-interactive.js\"></script>"
echo "4. Save changes and clear Moodle cache"
echo ""
echo "Or run this to add directly to theme:"
echo "docker exec -it $MOODLE_CONTAINER bash -c 'echo \"<link rel=\\\"stylesheet\\\" href=\\\"/epic-course-theme.css\\\">\" >> /var/www/html/theme/boost/layout/columns2.php'"
VMSCRIPT

scp -P ${PROXMOX_PORT} /tmp/moodle-theme-install.sh root@${PROXMOX_HOST}:/tmp/
echo "✅ Helper script uploaded to Proxmox /tmp/moodle-theme-install.sh"
echo ""

echo "🎯 Quick Access Commands:"
echo ""
echo "# Copy helper script to VM:"
echo "ssh -p ${PROXMOX_PORT} root@${PROXMOX_HOST} 'scp /tmp/moodle-theme-install.sh root@${VM_IP}:/tmp/ 2>/dev/null || echo \"Use qm terminal 9001 instead\"'"
echo ""
echo "# Or access VM via console:"
echo "ssh -p ${PROXMOX_PORT} root@${PROXMOX_HOST}"
echo "qm terminal 9001"
echo ""
echo "# Then in VM, run:"
echo "bash /tmp/moodle-theme-install.sh"
echo ""

echo "📚 For detailed documentation, see:"
echo "  - .github/instructions/infrastructure-configuration.md"
echo "  - .github/instructions/MOODLE_THEME_DEPLOYMENT.md"
echo ""
echo "✅ Deployment preparation complete!"
echo "⚠️  Manual VM access required to complete installation."

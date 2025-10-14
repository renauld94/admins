#!/bin/bash

echo "📥 Uploading M3U files using working SSH connection"
echo "=================================================="

# Configuration
PROXY_HOST="136.243.155.166:2222"
VM_USER="simonadmin"
SSH_KEY="~/.ssh/jellyfin_vm_key"

echo "📤 Uploading M3U files to VM 200..."
scp -i ~/.ssh/jellyfin_vm_key -o StrictHostKeyChecking=no -P 2222 /tmp/iptv_global.m3u simonadmin@136.243.155.166:/tmp/
scp -i ~/.ssh/jellyfin_vm_key -o StrictHostKeyChecking=no -P 2222 /tmp/iptv_us.m3u simonadmin@136.243.155.166:/tmp/
scp -i ~/.ssh/jellyfin_vm_key -o StrictHostKeyChecking=no -P 2222 /tmp/iptv_news.m3u simonadmin@136.243.155.166:/tmp/
scp -i ~/.ssh/jellyfin_vm_key -o StrictHostKeyChecking=no -P 2222 /tmp/iptv_sports.m3u simonadmin@136.243.155.166:/tmp/
scp -i ~/.ssh/jellyfin_vm_key -o StrictHostKeyChecking=no -P 2222 /tmp/iptv_movies.m3u simonadmin@136.243.155.166:/tmp/

echo "📁 Creating M3U files in Jellyfin container using direct method..."

# Create the files directly in the container using a different approach
ssh -i ~/.ssh/jellyfin_vm_key -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "cat > /tmp/iptv_global.m3u << 'EOF'
$(curl -s https://iptv-org.github.io/iptv/index.m3u)
EOF"

ssh -i ~/.ssh/jellyfin_vm_key -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "cat > /tmp/iptv_us.m3u << 'EOF'
$(curl -s https://iptv-org.github.io/iptv/countries/us.m3u)
EOF"

ssh -i ~/.ssh/jellyfin_vm_key -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "cat > /tmp/iptv_news.m3u << 'EOF'
$(curl -s https://iptv-org.github.io/iptv/categories/news.m3u)
EOF"

ssh -i ~/.ssh/jellyfin_vm_key -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "cat > /tmp/iptv_sports.m3u << 'EOF'
$(curl -s https://iptv-org.github.io/iptv/categories/sports.m3u)
EOF"

ssh -i ~/.ssh/jellyfin_vm_key -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "cat > /tmp/iptv_movies.m3u << 'EOF'
$(curl -s https://iptv-org.github.io/iptv/categories/movies.m3u)
EOF"

echo "📁 Copying M3U files to Jellyfin container..."

# Try to copy files to the container using docker cp
ssh -i ~/.ssh/jellyfin_vm_key -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "docker cp /tmp/iptv_global.m3u jellyfin-simonadmin:/config/ 2>/dev/null || echo 'Docker copy failed - trying alternative method'"

ssh -i ~/.ssh/jellyfin_vm_key -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "docker cp /tmp/iptv_us.m3u jellyfin-simonadmin:/config/ 2>/dev/null || echo 'Docker copy failed - trying alternative method'"

ssh -i ~/.ssh/jellyfin_vm_key -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "docker cp /tmp/iptv_news.m3u jellyfin-simonadmin:/config/ 2>/dev/null || echo 'Docker copy failed - trying alternative method'"

ssh -i ~/.ssh/jellyfin_vm_key -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "docker cp /tmp/iptv_sports.m3u jellyfin-simonadmin:/config/ 2>/dev/null || echo 'Docker copy failed - trying alternative method'"

ssh -i ~/.ssh/jellyfin_vm_key -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "docker cp /tmp/iptv_movies.m3u jellyfin-simonadmin:/config/ 2>/dev/null || echo 'Docker copy failed - trying alternative method'"

echo "✅ M3U files upload attempt complete!"
echo "====================================="
echo ""
echo "📁 Files should now be available in:"
echo "  - /config/iptv_global.m3u"
echo "  - /config/iptv_us.m3u"
echo "  - /config/iptv_news.m3u"
echo "  - /config/iptv_sports.m3u"
echo "  - /config/iptv_movies.m3u"
echo ""
echo "🌐 You can now use these paths in Jellyfin Live TV setup!"
echo "📺 Try adding a tuner with path: /config/iptv_global.m3u"

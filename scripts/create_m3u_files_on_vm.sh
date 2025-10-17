#!/bin/bash

echo "📥 Creating M3U files directly on VM 200"
echo "======================================="

# Configuration
PROXY_HOST="136.243.155.166:2222"
VM_USER="simonadmin"
SSH_KEY="~/.ssh/jellyfin_vm_key"

echo "📁 Creating M3U files directly on VM 200..."

# Create a script on the VM that will download the M3U files
ssh -i ~/.ssh/jellyfin_vm_key -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "cat > /tmp/download_m3u.sh << 'EOF'
#!/bin/bash
echo 'Downloading iptv-org M3U files...'

# Download M3U files
curl -s -o /tmp/iptv_global.m3u 'https://iptv-org.github.io/iptv/index.m3u'
curl -s -o /tmp/iptv_us.m3u 'https://iptv-org.github.io/iptv/countries/us.m3u'
curl -s -o /tmp/iptv_news.m3u 'https://iptv-org.github.io/iptv/categories/news.m3u'
curl -s -o /tmp/iptv_sports.m3u 'https://iptv-org.github.io/iptv/categories/sports.m3u'
curl -s -o /tmp/iptv_movies.m3u 'https://iptv-org.github.io/iptv/categories/movies.m3u'

echo 'Files downloaded:'
ls -la /tmp/iptv_*.m3u

echo 'Copying to Jellyfin container...'
docker cp /tmp/iptv_global.m3u jellyfin-simonadmin:/config/ 2>/dev/null && echo 'iptv_global.m3u copied' || echo 'Failed to copy iptv_global.m3u'
docker cp /tmp/iptv_us.m3u jellyfin-simonadmin:/config/ 2>/dev/null && echo 'iptv_us.m3u copied' || echo 'Failed to copy iptv_us.m3u'
docker cp /tmp/iptv_news.m3u jellyfin-simonadmin:/config/ 2>/dev/null && echo 'iptv_news.m3u copied' || echo 'Failed to copy iptv_news.m3u'
docker cp /tmp/iptv_sports.m3u jellyfin-simonadmin:/config/ 2>/dev/null && echo 'iptv_sports.m3u copied' || echo 'Failed to copy iptv_sports.m3u'
docker cp /tmp/iptv_movies.m3u jellyfin-simonadmin:/config/ 2>/dev/null && echo 'iptv_movies.m3u copied' || echo 'Failed to copy iptv_movies.m3u'

echo 'Verifying files in container...'
docker exec jellyfin-simonadmin ls -la /config/iptv_*.m3u 2>/dev/null || echo 'Could not verify files in container'

echo 'Done!'
EOF"

echo "🚀 Executing M3U download script on VM 200..."
ssh -i ~/.ssh/jellyfin_vm_key -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "chmod +x /tmp/download_m3u.sh && /tmp/download_m3u.sh"

echo ""
echo "✅ M3U files creation complete!"
echo "=============================="
echo ""
echo "📁 Files should now be available in Jellyfin container:"
echo "  - /config/iptv_global.m3u"
echo "  - /config/iptv_us.m3u"
echo "  - /config/iptv_news.m3u"
echo "  - /config/iptv_sports.m3u"
echo "  - /config/iptv_movies.m3u"
echo ""
echo "🌐 You can now use these paths in Jellyfin Live TV setup!"
echo "📺 Try adding a tuner with path: /config/iptv_global.m3u"



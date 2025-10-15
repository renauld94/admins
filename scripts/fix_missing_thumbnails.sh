#!/bin/bash

#############################################################################
# Complete IPTV Logo Fix for Jellyfin
#############################################################################
# This script downloads playlists, adds logos, and uploads back to Jellyfin
#############################################################################

set -e

VM_IP="10.0.0.103"
PROXY_HOST="136.243.155.166:2222"
VM_USER="simonadmin"
CONTAINER="jellyfin-simonadmin"
WORK_DIR="/tmp/iptv_logo_fix"

echo "============================================================================"
echo "IPTV Channel Logo Fix for Jellyfin"
echo "============================================================================"
echo ""
echo "This will add channel logos/thumbnails to fix the 500 image errors."
echo ""

# Create working directory
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

echo "Step 1: Downloading playlists from Jellyfin..."
echo ""

# Download playlists from container
echo "📦 Creating playlist archive..."
ssh -J root@${PROXY_HOST} ${VM_USER}@${VM_IP} << 'ENDSSH'
    # Create tar in container
    echo "  Creating archive in container..."
    docker exec jellyfin-simonadmin sh -c 'cd /config/data/playlists && tar czf /config/playlists_backup.tar.gz *.m3u' 2>/dev/null
    
    # Copy to /tmp on VM
    echo "  Copying to VM..."
    docker cp jellyfin-simonadmin:/config/playlists_backup.tar.gz /tmp/playlists.tar.gz 2>/dev/null
    
    # Verify file was created
    if [ ! -f /tmp/playlists.tar.gz ]; then
        echo "❌ Failed to create playlist archive"
        exit 1
    fi
    
    FILE_SIZE=$(stat -c%s /tmp/playlists.tar.gz 2>/dev/null || echo "0")
    echo "  ✓ Archive created ($FILE_SIZE bytes)"
ENDSSH

echo "📥 Downloading archive..."
scp -o "ProxyJump root@${PROXY_HOST}" ${VM_USER}@${VM_IP}:/tmp/playlists.tar.gz ./ || {
    echo "❌ Failed to download playlists"
    echo ""
    echo "Troubleshooting:"
    echo "  1. Check if playlists exist:"
    echo "     ssh -J root@${PROXY_HOST} ${VM_USER}@${VM_IP} 'docker exec jellyfin-simonadmin ls -la /config/data/playlists/'"
    echo ""
    exit 1
}

tar xzf playlists.tar.gz 2>/dev/null
rm -f playlists.tar.gz

# Check if we got any files
M3U_COUNT=$(ls -1 *.m3u 2>/dev/null | wc -l)
if [ "$M3U_COUNT" -eq 0 ]; then
    echo "❌ No M3U files extracted from archive"
    echo ""
    echo "Checking playlists on server..."
    ssh -J root@${PROXY_HOST} ${VM_USER}@${VM_IP} 'docker exec jellyfin-simonadmin ls -la /config/data/playlists/'
    exit 1
fi

echo "✅ Downloaded playlists"
echo ""

# Count playlists
PLAYLIST_COUNT=$(ls -1 *.m3u 2>/dev/null | wc -l)
echo "📊 Found $PLAYLIST_COUNT playlists"
echo ""

echo "Step 2: Adding logos to channels..."
echo ""

# Download and run Python logo adder
cat > add_logos.py << 'PYTHON_SCRIPT'
#!/usr/bin/env python3
import re
import os

# Common channel logos
LOGOS = {
    'cnn': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b1/CNN.svg/200px-CNN.svg.png',
    'bbc': 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/41/BBC_Logo_2021.svg/200px-BBC_Logo_2021.svg.png',
    'espn': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2f/ESPN_wordmark.svg/200px-ESPN_wordmark.svg.png',
    'fox news': 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/67/Fox_News_Channel_logo.svg/200px-Fox_News_Channel_logo.svg.png',
    'nbc': 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/NBC_logo.svg/200px-NBC_logo.svg.png',
    'abc': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2f/ABC-2021-LOGO.svg/200px-ABC-2021-LOGO.svg.png',
    'cbs': 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/17/CBS_2020.svg/200px-CBS_2020.svg.png',
    'msnbc': 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d8/MSNBC_2015_logo.svg/200px-MSNBC_2015_logo.svg.png',
    'cnbc': 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e3/CNBC_logo.svg/200px-CNBC_logo.svg.png',
    'mtv': 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/68/MTV_2021_%28brand_version%29.svg/200px-MTV_2021_%28brand_version%29.svg.png',
    'discovery': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/27/Discovery_Channel_-_Logo_2019.svg/200px-Discovery_Channel_-_Logo_2019.svg.png',
    'disney': 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d2/2019_Disney_Channel_logo.svg/200px-2019_Disney_Channel_logo.svg.png',
    'nickelodeon': 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/7a/Nickelodeon_2009_logo.svg/200px-Nickelodeon_2009_logo.svg.png',
    'hbo': 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/de/HBO_logo.svg/200px-HBO_logo.svg.png',
    'sky news': 'https://upload.wikimedia.org/wikipedia/en/thumb/8/8f/Sky_News_logo_2020.svg/200px-Sky_News_logo_2020.svg.png',
    'national geographic': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fc/Natgeologo.svg/200px-Natgeologo.svg.png',
    'euronews': 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/39/Euronews_2022.svg/200px-Euronews_2022.svg.png',
    'bloomberg': 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/Bloomberg_Television_logo.svg/200px-Bloomberg_Television_logo.svg.png',
    'france 24': 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8a/France24.svg/200px-France24.svg.png',
    'al jazeera': 'https://upload.wikimedia.org/wikipedia/en/thumb/7/71/Aljazeera.svg/200px-Aljazeera.svg.png',
    'history': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f5/History_Logo.svg/200px-History_Logo.svg.png',
    'animal planet': 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/2018_Animal_Planet_logo.svg/200px-2018_Animal_Planet_logo.svg.png',
    'tlc': 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/74/TLC_Logo.svg/200px-TLC_Logo.svg.png',
    'food network': 'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d7/Food_Network_logo.svg/200px-Food_Network_logo.svg.png',
    'cartoon network': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/bb/Cartoon_Network_logo_2010.svg/200px-Cartoon_Network_logo_2010.svg.png',
}

def find_logo(channel_name):
    name_lower = channel_name.lower().strip()
    # Remove HD, SD, etc.
    clean_name = re.sub(r'\s+(hd|sd|4k|fhd|uhd|us|uk|ca|+)$', '', name_lower, flags=re.IGNORECASE)
    
    # Exact match
    if clean_name in LOGOS:
        return LOGOS[clean_name]
    
    # Partial match
    for key, logo in LOGOS.items():
        if key in clean_name or clean_name in key:
            return logo
    
    # Generic placeholder
    return 'https://via.placeholder.com/200x200/1a1a1a/ffffff?text=' + channel_name.replace(' ', '+')[:20]

total_logos = 0
for m3u_file in [f for f in os.listdir('.') if f.endswith('.m3u')]:
    print(f"Processing {m3u_file}...")
    logos_added = 0
    
    with open(m3u_file, 'r', encoding='utf-8', errors='ignore') as f_in:
        lines = f_in.readlines()
    
    with open(m3u_file, 'w', encoding='utf-8') as f_out:
        for line in lines:
            line = line.rstrip('\n')
            
            if line.startswith('#EXTINF:'):
                match = re.search(r',(.+)$', line)
                if match and 'tvg-logo=' not in line:
                    channel_name = match.group(1).strip()
                    logo_url = find_logo(channel_name)
                    line = line.replace('#EXTINF:-1', f'#EXTINF:-1 tvg-logo="{logo_url}"', 1)
                    logos_added += 1
            
            f_out.write(line + '\n')
    
    print(f"  ✓ Added {logos_added} logos")
    total_logos += logos_added

print(f"\n✅ Total logos added: {total_logos}")
PYTHON_SCRIPT

chmod +x add_logos.py
python3 add_logos.py

echo ""
echo "Step 3: Uploading updated playlists to Jellyfin..."
echo ""

# Create backup on VM
ssh -J root@${PROXY_HOST} ${VM_USER}@${VM_IP} << 'ENDSSH'
    docker exec jellyfin-simonadmin mkdir -p /config/data/playlists/backup_before_logos
    docker exec jellyfin-simonadmin sh -c 'cp /config/data/playlists/*.m3u /config/data/playlists/backup_before_logos/ 2>/dev/null || true'
ENDSSH

# Upload updated playlists
tar czf playlists_with_logos.tar.gz *.m3u
scp -o "ProxyJump root@${PROXY_HOST}" playlists_with_logos.tar.gz ${VM_USER}@${VM_IP}:/tmp/

# Install to container
ssh -J root@${PROXY_HOST} ${VM_USER}@${VM_IP} << 'ENDSSH'
    cd /tmp
    tar xzf playlists_with_logos.tar.gz
    docker exec jellyfin-simonadmin sh -c 'cd /tmp && cp *.m3u /config/data/playlists/ 2>/dev/null || true'
    docker exec jellyfin-simonadmin chown -R 1000:1000 /config/data/playlists 2>/dev/null || true
    rm -f /tmp/*.m3u /tmp/playlists_with_logos.tar.gz
ENDSSH

echo "✅ Playlists uploaded"
echo ""

echo "Step 4: Restarting Jellyfin..."
ssh -J root@${PROXY_HOST} ${VM_USER}@${VM_IP} 'docker restart jellyfin-simonadmin'

echo ""
echo "============================================================================"
echo "✅ Channel Logos Added Successfully!"
echo "============================================================================"
echo ""
echo "What was done:"
echo "  ✓ Downloaded all playlists from Jellyfin"
echo "  ✓ Added logos to channel metadata (tvg-logo tags)"
echo "  ✓ Backed up originals to /config/data/playlists/backup_before_logos/"
echo "  ✓ Uploaded updated playlists"
echo "  ✓ Restarted Jellyfin"
echo ""
echo "Next steps:"
echo "  1. Wait 30 seconds for Jellyfin to fully restart"
echo "  2. Access: http://136.243.155.166:8096/web/"
echo "  3. Go to Live TV"
echo "  4. Logos should now appear for major channels!"
echo ""
echo "Note: Popular channels (CNN, BBC, ESPN, etc.) will have real logos."
echo "      Less common channels will have placeholder images."
echo ""
echo "To disable logo fetching errors in console:"
echo "  Admin Dashboard → Live TV → TV Guide Data Providers"
echo "  Uncheck 'Download images'"
echo "  Save"
echo ""
echo "============================================================================"

# Cleanup
cd /
rm -rf "$WORK_DIR"

echo ""
echo "✅ Done!"
echo ""

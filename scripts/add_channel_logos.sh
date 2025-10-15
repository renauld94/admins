#!/bin/bash

#############################################################################
# IPTV Channel Logo Fetcher
#############################################################################
# This script adds channel logos/thumbnails to your IPTV playlists
# Uses iptv-org's channel logos repository
#############################################################################

set -e

# Configuration
VM_IP="10.0.0.103"
PROXY_HOST="136.243.155.166:2222"
VM_USER="simonadmin"
CONTAINER="jellyfin-simonadmin"
LOGO_REPO="https://raw.githubusercontent.com/iptv-org/iptv/master/streams"

echo "============================================================================"
echo "IPTV Channel Logo Fetcher"
echo "============================================================================"
echo ""
echo "This script will add channel logos to your M3U playlists."
echo "Logos are fetched from the iptv-org repository."
echo ""

# Create temp directory
TEMP_DIR="/tmp/iptv_logos"
mkdir -p "$TEMP_DIR"

echo "Step 1: Downloading channel logo database..."
echo ""

# Download the iptv-org streams database (has logo URLs)
curl -s "https://iptv-org.github.io/api/streams.json" > "$TEMP_DIR/streams.json" || {
    echo "❌ Failed to download streams database"
    echo "Trying alternative source..."
    
    # Alternative: Use channels database
    curl -s "https://iptv-org.github.io/api/channels.json" > "$TEMP_DIR/channels.json" || {
        echo "❌ Failed to download channels database"
        exit 1
    }
}

echo "✅ Downloaded logo database"
echo ""

# Function to add logos to M3U file
add_logos_to_m3u() {
    local input_file="$1"
    local output_file="$2"
    
    echo "Processing $(basename $input_file)..."
    
    # Python script to add logos
    python3 << 'PYTHON_EOF'
import re
import json
import sys

# Read logo database
try:
    with open('/tmp/iptv_logos/streams.json', 'r') as f:
        streams_data = json.load(f)
except:
    try:
        with open('/tmp/iptv_logos/channels.json', 'r') as f:
            streams_data = json.load(f)
    except:
        print("❌ No logo database found")
        sys.exit(1)

# Create logo lookup dictionary
logo_map = {}
for stream in streams_data:
    if 'name' in stream and 'logo' in stream:
        # Normalize channel name for matching
        name_key = stream['name'].lower().strip()
        logo_map[name_key] = stream['logo']
    elif 'channel' in stream and 'logo' in stream:
        name_key = stream['channel'].lower().strip()
        logo_map[name_key] = stream['logo']

print(f"📊 Loaded {len(logo_map)} channel logos")

# Process M3U file
input_file = sys.argv[1]
output_file = sys.argv[2]

with open(input_file, 'r', encoding='utf-8', errors='ignore') as f_in:
    with open(output_file, 'w', encoding='utf-8') as f_out:
        extinf_line = None
        logos_added = 0
        
        for line in f_in:
            line = line.rstrip('\n')
            
            if line.startswith('#EXTINF:'):
                extinf_line = line
                
                # Extract channel name
                # Format: #EXTINF:-1 tvg-id="..." tvg-name="..." tvg-logo="..." group-title="...",Channel Name
                match = re.search(r',(.+)$', line)
                if match:
                    channel_name = match.group(1).strip()
                    channel_key = channel_name.lower()
                    
                    # Check if logo already exists
                    if 'tvg-logo=' not in line:
                        # Try to find logo
                        logo_url = None
                        
                        # Exact match
                        if channel_key in logo_map:
                            logo_url = logo_map[channel_key]
                        else:
                            # Fuzzy match - check if channel name contains any key
                            for key, logo in logo_map.items():
                                if key in channel_key or channel_key in key:
                                    logo_url = logo
                                    break
                        
                        if logo_url:
                            # Add logo to EXTINF line
                            # Insert after #EXTINF:-1
                            extinf_line = extinf_line.replace(
                                '#EXTINF:-1',
                                f'#EXTINF:-1 tvg-logo="{logo_url}"',
                                1
                            )
                            logos_added += 1
                
                f_out.write(extinf_line + '\n')
                extinf_line = None
                
            elif line.startswith('http'):
                # URL line
                f_out.write(line + '\n')
            elif line.startswith('#EXTM3U'):
                # Header
                f_out.write(line + '\n')

print(f"✅ Added {logos_added} logos")

PYTHON_EOF

}

echo "Step 2: Adding logos to playlists on VM..."
echo ""

# Download playlists from VM
ssh -J root@${PROXY_HOST} ${VM_USER}@${VM_IP} << 'ENDSSH'
    docker exec jellyfin-simonadmin sh -c 'cd /config/data/playlists && tar czf /tmp/playlists_with_logos.tar.gz *.m3u 2>/dev/null || true'
ENDSSH

scp -o "ProxyJump root@${PROXY_HOST}" ${VM_USER}@${VM_IP}:/tmp/playlists_with_logos.tar.gz "$TEMP_DIR/" 2>/dev/null || {
    echo "❌ Failed to download playlists"
    exit 1
}

# Extract playlists
cd "$TEMP_DIR"
tar xzf playlists_with_logos.tar.gz 2>/dev/null || true

echo "✅ Downloaded playlists"
echo ""

# Process each playlist
echo "Step 3: Processing playlists..."
echo ""

mkdir -p "$TEMP_DIR/with_logos"

for m3u_file in *.m3u; do
    if [ -f "$m3u_file" ]; then
        add_logos_to_m3u "$m3u_file" "$TEMP_DIR/with_logos/$m3u_file" "$TEMP_DIR/streams.json"
    fi
done

echo ""
echo "Step 4: Uploading updated playlists to VM..."
echo ""

# Upload updated playlists
scp -o "ProxyJump root@${PROXY_HOST}" "$TEMP_DIR/with_logos"/*.m3u ${VM_USER}@${VM_IP}:/tmp/

# Install to container
ssh -J root@${PROXY_HOST} ${VM_USER}@${VM_IP} << 'ENDSSH'
    # Backup originals
    docker exec jellyfin-simonadmin mkdir -p /config/data/playlists/backup
    docker exec jellyfin-simonadmin sh -c 'cp /config/data/playlists/*.m3u /config/data/playlists/backup/ 2>/dev/null || true'
    
    # Install updated playlists with logos
    docker exec jellyfin-simonadmin sh -c 'cp /tmp/*.m3u /config/data/playlists/ 2>/dev/null || true'
    docker exec jellyfin-simonadmin chown -R 1000:1000 /config/data/playlists 2>/dev/null || true
ENDSSH

echo "✅ Updated playlists installed"
echo ""

# Restart Jellyfin to reload metadata
echo "Step 5: Restarting Jellyfin to load logos..."
ssh -J root@${PROXY_HOST} ${VM_USER}@${VM_IP} 'docker restart jellyfin-simonadmin'

echo ""
echo "============================================================================"
echo "✅ Channel Logos Added Successfully!"
echo "============================================================================"
echo ""
echo "Next steps:"
echo "1. Wait 30 seconds for Jellyfin to restart"
echo "2. Access: http://136.243.155.166:8096/web/"
echo "3. Go to: Live TV"
echo "4. You should now see channel logos/thumbnails!"
echo ""
echo "Note: Not all channels have logos in the database."
echo "      Popular channels (CNN, BBC, ESPN, etc.) should have logos."
echo ""
echo "Backup of original playlists: /config/data/playlists/backup/"
echo ""
echo "============================================================================"
echo ""

# Cleanup
rm -rf "$TEMP_DIR"

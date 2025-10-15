#!/usr/bin/env python3

"""
IPTV Logo Finder and Updater
Adds channel logos from multiple sources to M3U playlists
"""

import re
import json
import os
import sys
import subprocess
from urllib.request import urlopen, Request
from urllib.error import URLError

# Logo sources
LOGO_SOURCES = [
    "https://iptv-org.github.io/api/channels.json",
    "https://raw.githubusercontent.com/picons/picons/master/build-source/tv/index.json"
]

def download_logo_database():
    """Download channel logo databases from multiple sources"""
    logos = {}
    
    print("📥 Downloading logo databases...")
    
    # Source 1: iptv-org channels
    try:
        req = Request(LOGO_SOURCES[0], headers={'User-Agent': 'Mozilla/5.0'})
        with urlopen(req, timeout=30) as response:
            data = json.loads(response.read().decode())
            for channel in data:
                if 'name' in channel and 'logo' in channel and channel['logo']:
                    name_key = channel['name'].lower().strip()
                    logos[name_key] = channel['logo']
        print(f"  ✓ Loaded {len(logos)} logos from iptv-org")
    except Exception as e:
        print(f"  ⚠ Failed to load iptv-org: {e}")
    
    # Add common channel logos manually (fallback)
    common_logos = {
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
        'sky news': 'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b9/Sky_News_logo_2020.svg/200px-Sky_News_logo_2020.svg.png',
        'national geographic': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fc/Natgeologo.svg/200px-Natgeologo.svg.png',
        'euronews': 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/39/Euronews_2022.svg/200px-Euronews_2022.svg.png',
        'bloomberg': 'https://upload.wikimedia.org/wikipedia/commons/thumb/5/56/Bloomberg_Television_logo.svg/200px-Bloomberg_Television_logo.svg.png',
        'france 24': 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8a/France24.svg/200px-France24.svg.png',
        'al jazeera': 'https://upload.wikimedia.org/wikipedia/en/thumb/7/71/Aljazeera.svg/200px-Aljazeera.svg.png',
    }
    
    for name, logo in common_logos.items():
        if name not in logos:
            logos[name] = logo
    
    print(f"  ✓ Total logos available: {len(logos)}")
    
    return logos

def find_logo(channel_name, logo_db):
    """Find logo URL for a channel name"""
    channel_key = channel_name.lower().strip()
    
    # Exact match
    if channel_key in logo_db:
        return logo_db[channel_key]
    
    # Remove common suffixes
    clean_name = re.sub(r'\s+(hd|sd|4k|fhd|uhd|us|uk|ca)$', '', channel_key, flags=re.IGNORECASE)
    if clean_name in logo_db:
        return logo_db[clean_name]
    
    # Fuzzy match - check if channel name contains any key
    for key, logo in logo_db.items():
        if len(key) > 3:  # Avoid matching very short keys
            if key in channel_key or channel_key in key:
                return logo
    
    return None

def add_logos_to_m3u(input_file, output_file, logo_db):
    """Add logos to M3U file"""
    logos_added = 0
    total_channels = 0
    
    with open(input_file, 'r', encoding='utf-8', errors='ignore') as f_in:
        with open(output_file, 'w', encoding='utf-8') as f_out:
            for line in f_in:
                line = line.rstrip('\n')
                
                if line.startswith('#EXTINF:'):
                    total_channels += 1
                    
                    # Extract channel name
                    match = re.search(r',(.+)$', line)
                    if match:
                        channel_name = match.group(1).strip()
                        
                        # Check if logo already exists
                        if 'tvg-logo=' not in line:
                            logo_url = find_logo(channel_name, logo_db)
                            
                            if logo_url:
                                # Add logo after #EXTINF:-1
                                line = line.replace(
                                    '#EXTINF:-1',
                                    f'#EXTINF:-1 tvg-logo="{logo_url}"',
                                    1
                                )
                                logos_added += 1
                
                f_out.write(line + '\n')
    
    print(f"    ✓ Added {logos_added}/{total_channels} logos")
    return logos_added

def main():
    """Main function"""
    print("=" * 80)
    print("IPTV Channel Logo Updater")
    print("=" * 80)
    print()
    
    # Download logo database
    logo_db = download_logo_database()
    
    if not logo_db:
        print("❌ No logo database available")
        return 1
    
    print()
    print("📁 Looking for M3U playlists...")
    
    # Find M3U files in current directory
    m3u_files = [f for f in os.listdir('.') if f.endswith('.m3u')]
    
    if not m3u_files:
        print("❌ No M3U files found in current directory")
        return 1
    
    print(f"  ✓ Found {len(m3u_files)} playlists")
    print()
    
    # Process each file
    print("🔄 Processing playlists...")
    total_logos_added = 0
    
    for m3u_file in m3u_files:
        print(f"  Processing {m3u_file}...")
        output_file = f"{m3u_file}.tmp"
        
        logos_added = add_logos_to_m3u(m3u_file, output_file, logo_db)
        total_logos_added += logos_added
        
        # Replace original file
        os.rename(output_file, m3u_file)
    
    print()
    print("=" * 80)
    print(f"✅ Successfully added {total_logos_added} logos to {len(m3u_files)} playlists!")
    print("=" * 80)
    print()
    print("Next steps:")
    print("  1. Playlists have been updated with logos")
    print("  2. Restart Jellyfin to reload metadata")
    print("  3. Logos should now appear in Live TV")
    print()
    
    return 0

if __name__ == '__main__':
    sys.exit(main())

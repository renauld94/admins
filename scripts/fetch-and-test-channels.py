#!/usr/bin/env python3

"""
Jellyfin Channel Fetcher & Tester
Fetches free IPTV channels from reliable sources, tests them, and creates an organized M3U file.
"""

import requests
import json
import time
import subprocess
from collections import defaultdict
from urllib.parse import urlparse
import os
import sys

# Configuration
TIMEOUT = 5
MAX_CHANNELS_PER_CATEGORY = 50
TEST_BATCH_SIZE = 10

# ANSI colors
RED = '\033[0;31m'
GREEN = '\033[0;32m'
YELLOW = '\033[1;33m'
BLUE = '\033[0;34m'
CYAN = '\033[0;36m'
NC = '\033[0m'  # No Color

class ChannelFetcher:
    def __init__(self):
        self.channels = defaultdict(list)
        self.tested_channels = defaultdict(list)
        self.failed_channels = []
        self.session = requests.Session()
        self.session.timeout = TIMEOUT
        
    def print_status(self, status, message):
        """Print colored status messages"""
        if status == "info":
            print(f"{BLUE}[ℹ]{NC}  {message}")
        elif status == "success":
            print(f"{GREEN}[✓]{NC}  {message}")
        elif status == "warning":
            print(f"{YELLOW}[⚠]{NC}  {message}")
        elif status == "error":
            print(f"{RED}[✗]{NC}  {message}")
        elif status == "progress":
            print(f"{CYAN}[→]{NC}  {message}")
    
    def fetch_m3u(self, url):
        """Fetch M3U file from URL"""
        try:
            response = requests.get(url, timeout=TIMEOUT)
            response.raise_for_status()
            return response.text
        except Exception as e:
            self.print_status("error", f"Failed to fetch {url}: {str(e)}")
            return None
    
    def parse_m3u(self, content):
        """Parse M3U content and extract channels"""
        channels = []
        lines = content.split('\n')
        
        current_channel = {}
        for i, line in enumerate(lines):
            if line.startswith('#EXTINF:'):
                # Parse channel metadata
                parts = line.split(',', 1)
                if len(parts) == 2:
                    current_channel = {
                        'name': parts[1].strip(),
                        'metadata': parts[0],
                        'url': None
                    }
                    
                    # Extract tvg-id, tvg-logo, tvg-name, group-title
                    meta_parts = parts[0].split()
                    for part in meta_parts:
                        if 'tvg-id=' in part:
                            current_channel['tvg_id'] = part.split('"')[1] if '"' in part else ''
                        elif 'tvg-logo=' in part:
                            current_channel['tvg_logo'] = part.split('"')[1] if '"' in part else ''
                        elif 'tvg-name=' in part:
                            current_channel['tvg_name'] = part.split('"')[1] if '"' in part else ''
                        elif 'group-title=' in part:
                            current_channel['group_title'] = part.split('"')[1] if '"' in part else 'General'
            
            elif line.startswith('http') and current_channel:
                current_channel['url'] = line.strip()
                if current_channel.get('url'):
                    channels.append(current_channel)
                current_channel = {}
        
        return channels
    
    def test_stream(self, url, timeout=3):
        """Test if a stream URL is accessible"""
        try:
            response = requests.head(url, timeout=timeout, allow_redirects=True)
            return response.status_code == 200
        except:
            try:
                # Some streams only respond to GET
                response = requests.get(url, timeout=timeout, stream=True)
                return response.status_code == 200
            except:
                return False
    
    def fetch_from_sources(self):
        """Fetch channels from all IPTV-Org category sources"""
        sources = [
            "https://iptv-org.github.io/iptv/categories/news.m3u",
            "https://iptv-org.github.io/iptv/categories/sports.m3u",
            "https://iptv-org.github.io/iptv/categories/entertainment.m3u",
            "https://iptv-org.github.io/iptv/categories/movies.m3u",
            "https://iptv-org.github.io/iptv/categories/music.m3u",
            "https://iptv-org.github.io/iptv/categories/kids.m3u",
            "https://iptv-org.github.io/iptv/categories/documentary.m3u",
            "https://iptv-org.github.io/iptv/categories/religious.m3u",
            "https://iptv-org.github.io/iptv/categories/lifestyle.m3u",
            "https://iptv-org.github.io/iptv/categories/shop.m3u",
        ]
        
        print(f"\n{BLUE}{'='*60}{NC}")
        print(f"{BLUE}Fetching IPTV-Org Free Channels{NC}")
        print(f"{BLUE}{'='*60}{NC}\n")
        
        total_fetched = 0
        for i, source in enumerate(sources, 1):
            self.print_status("progress", f"[{i}/{len(sources)}] Fetching from {source.split('/')[-1].replace('.m3u', '')}")
            
            content = self.fetch_m3u(source)
            if content:
                channels = self.parse_m3u(content)
                category = source.split('/')[-1].replace('.m3u', '').title()
                self.channels[category].extend(channels[:MAX_CHANNELS_PER_CATEGORY])
                self.print_status("success", f"Got {len(channels[:MAX_CHANNELS_PER_CATEGORY])} channels from {category}")
                total_fetched += len(channels[:MAX_CHANNELS_PER_CATEGORY])
            
            time.sleep(0.5)  # Be nice to the server
        
        return total_fetched
    
    def test_channels(self):
        """Test all fetched channels for accessibility"""
        print(f"\n{BLUE}{'='*60}{NC}")
        print(f"{BLUE}Testing Channel Accessibility{NC}")
        print(f"{BLUE}{'='*60}{NC}\n")
        
        total_channels = sum(len(ch) for ch in self.channels.values())
        tested = 0
        working = 0
        
        for category, channels in self.channels.items():
            self.print_status("info", f"Testing {category} ({len(channels)} channels)")
            category_working = 0
            
            for channel in channels:
                tested += 1
                if tested % 10 == 0:
                    print(f"  {CYAN}[{tested}/{total_channels}]{NC} tested...", end='\r')
                
                if channel.get('url') and self.test_stream(channel['url']):
                    self.tested_channels[category].append(channel)
                    category_working += 1
                    working += 1
            
            self.print_status("success", f"{category}: {category_working}/{len(channels)} channels working")
        
        print(f"\n{BLUE}Total: {working}/{total_channels} channels working ({working*100//total_channels}%){NC}\n")
        return working, total_channels
    
    def generate_m3u(self, output_file):
        """Generate organized M3U file from tested channels"""
        print(f"\n{BLUE}{'='*60}{NC}")
        print(f"{BLUE}Generating M3U File{NC}")
        print(f"{BLUE}{'='*60}{NC}\n")
        
        category_emojis = {
            "News": "📰",
            "Sports": "⚽",
            "Entertainment": "🎭",
            "Movies": "🎬",
            "Music": "🎵",
            "Kids": "👶",
            "Documentary": "📚",
            "Religious": "✝️",
            "Lifestyle": "🌿",
            "Shop": "🛍️",
            "General": "🌍"
        }
        
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write('#EXTM3U\n')
            
            total_channels = 0
            for category in sorted(self.tested_channels.keys()):
                channels = self.tested_channels[category]
                if channels:
                    emoji = category_emojis.get(category, "🌍")
                    f.write(f'\n# {emoji} {category}\n')
                    
                    for channel in channels:
                        # Build EXTINF line
                        extinf = f'#EXTINF:-1'
                        
                        if channel.get('tvg_id'):
                            extinf += f' tvg-id="{channel["tvg_id"]}"'
                        if channel.get('tvg_logo'):
                            extinf += f' tvg-logo="{channel["tvg_logo"]}"'
                        if channel.get('tvg_name'):
                            extinf += f' tvg-name="{channel["tvg_name"]}"'
                        
                        extinf += f' group-title="{emoji} {category}"'
                        extinf += f',{channel["name"]}\n'
                        
                        f.write(extinf)
                        f.write(f'{channel["url"]}\n')
                        total_channels += 1
                    
                    self.print_status("success", f"Added {len(channels)} {category} channels")
        
        file_size = os.path.getsize(output_file) / 1024
        self.print_status("success", f"M3U file created: {output_file}")
        self.print_status("info", f"Total channels: {total_channels} | File size: {file_size:.1f} KB")
        
        return total_channels
    
    def run(self):
        """Main execution"""
        # Fetch channels
        fetched = self.fetch_from_sources()
        self.print_status("info", f"Total channels fetched: {fetched}")
        
        # Test channels
        working, total = self.test_channels()
        
        # Generate M3U
        output_file = '/home/simon/Learning-Management-System-Academy/alternative_m3u_sources/jellyfin-channels-enhanced.m3u'
        total_organized = self.generate_m3u(output_file)
        
        # Summary
        print(f"\n{BLUE}{'='*60}{NC}")
        print(f"{GREEN}Channel Collection Complete!{NC}")
        print(f"{BLUE}{'='*60}{NC}")
        print(f"{GREEN}✓{NC} Channels tested: {working}/{total}")
        print(f"{GREEN}✓{NC} Channels organized: {total_organized}")
        print(f"{GREEN}✓{NC} Output file: {output_file}")
        print(f"{BLUE}{'='*60}{NC}\n")

if __name__ == "__main__":
    fetcher = ChannelFetcher()
    fetcher.run()

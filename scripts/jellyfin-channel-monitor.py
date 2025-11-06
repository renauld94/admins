#!/usr/bin/env python3
"""
Jellyfin Live TV Channel Monitor Agent
=======================================
Automatically tests channels, removes dead ones, and maintains a healthy M3U playlist.

Features:
- Tests all channels for accessibility
- Removes dead/broken channels from M3U
- Maintains backup of original playlist
- Generates health report
- Can run as cron job or systemd service
- Notifies on significant channel loss

Author: Simon Renauld
Date: November 6, 2025
"""

import os
import sys
import time
import json
import logging
import argparse
import requests
import subprocess
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Tuple
from urllib.parse import urlparse
from concurrent.futures import ThreadPoolExecutor, as_completed

# Configuration
M3U_PATH = Path("/home/simon/Learning-Management-System-Academy/alternative_m3u_sources/jellyfin-channels-enhanced.m3u")
BACKUP_DIR = Path("/home/simon/Learning-Management-System-Academy/alternative_m3u_sources/backups")
LOG_DIR = Path("/var/log/jellyfin-monitor")
REPORT_DIR = Path("/home/simon/Learning-Management-System-Academy/reports/jellyfin")

# Testing parameters
TIMEOUT_SECONDS = 10
MAX_WORKERS = 20
RETRY_ATTEMPTS = 2
MIN_CHANNEL_THRESHOLD = 50  # Alert if channels drop below this

# Logging setup
try:
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    log_file = LOG_DIR / 'channel-monitor.log'
    handlers = [
        logging.FileHandler(log_file),
        logging.StreamHandler(sys.stdout)
    ]
except PermissionError:
    # Fallback to home directory if /var/log is not writable
    LOG_DIR = Path.home() / '.jellyfin-monitor'
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    log_file = LOG_DIR / 'channel-monitor.log'
    handlers = [
        logging.FileHandler(log_file),
        logging.StreamHandler(sys.stdout)
    ]

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s',
    handlers=handlers
)
logger = logging.getLogger(__name__)


class ChannelTester:
    """Tests individual channel URLs for accessibility"""
    
    def __init__(self, timeout: int = TIMEOUT_SECONDS):
        self.timeout = timeout
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        })
    
    def test_channel(self, url: str, retries: int = RETRY_ATTEMPTS) -> Tuple[bool, str]:
        """
        Test if a channel URL is accessible
        
        Returns:
            Tuple[bool, str]: (is_working, error_message)
        """
        for attempt in range(retries):
            try:
                # Try HEAD request first (faster)
                response = self.session.head(url, timeout=self.timeout, allow_redirects=True)
                
                # If HEAD fails, try GET with small range
                if response.status_code >= 400:
                    response = self.session.get(
                        url, 
                        timeout=self.timeout,
                        stream=True,
                        headers={'Range': 'bytes=0-1024'}
                    )
                
                if response.status_code in [200, 206, 301, 302, 307, 308]:
                    return True, "OK"
                else:
                    error_msg = f"HTTP {response.status_code}"
                    
            except requests.exceptions.Timeout:
                error_msg = "Timeout"
            except requests.exceptions.ConnectionError:
                error_msg = "Connection failed"
            except requests.exceptions.TooManyRedirects:
                error_msg = "Too many redirects"
            except Exception as e:
                error_msg = f"Error: {str(e)[:50]}"
            
            if attempt < retries - 1:
                time.sleep(1)  # Brief pause before retry
        
        return False, error_msg
    
    def close(self):
        """Close the session"""
        self.session.close()


class M3UParser:
    """Parse and manipulate M3U playlists"""
    
    def __init__(self, m3u_path: Path):
        self.m3u_path = m3u_path
        self.channels = []
    
    def parse(self) -> List[Dict]:
        """Parse M3U file into structured data"""
        if not self.m3u_path.exists():
            raise FileNotFoundError(f"M3U file not found: {self.m3u_path}")
        
        with open(self.m3u_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        channels = []
        current_channel = {}
        
        for line in lines:
            line = line.strip()
            
            if line.startswith('#EXTM3U'):
                continue
            
            elif line.startswith('#EXTINF:'):
                # Parse EXTINF line
                # Format: #EXTINF:-1 tvg-id="..." tvg-logo="..." group-title="...",Channel Name
                current_channel = {'extinf': line}
                
                # Extract channel name (after last comma)
                if ',' in line:
                    current_channel['name'] = line.split(',', 1)[1].strip()
                
                # Extract attributes
                for attr in ['tvg-id', 'tvg-logo', 'group-title']:
                    if f'{attr}="' in line:
                        start = line.find(f'{attr}="') + len(f'{attr}="')
                        end = line.find('"', start)
                        current_channel[attr] = line[start:end]
            
            elif line and not line.startswith('#'):
                # This is the URL
                current_channel['url'] = line
                channels.append(current_channel.copy())
                current_channel = {}
        
        self.channels = channels
        logger.info(f"Parsed {len(channels)} channels from M3U file")
        return channels
    
    def save(self, channels: List[Dict], output_path: Path = None):
        """Save channels to M3U file"""
        if output_path is None:
            output_path = self.m3u_path
        
        output_path.parent.mkdir(parents=True, exist_ok=True)
        
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write('#EXTM3U\n')
            
            for channel in channels:
                f.write(f"{channel['extinf']}\n")
                f.write(f"{channel['url']}\n")
        
        logger.info(f"Saved {len(channels)} channels to {output_path}")


class ChannelMonitor:
    """Main monitoring agent"""
    
    def __init__(self, m3u_path: Path):
        self.m3u_path = m3u_path
        self.parser = M3UParser(m3u_path)
        self.tester = ChannelTester()
        self.results = {
            'tested': 0,
            'working': 0,
            'failed': 0,
            'removed': 0,
            'kept': 0
        }
    
    def backup_m3u(self) -> Path:
        """Create timestamped backup of M3U file"""
        BACKUP_DIR.mkdir(parents=True, exist_ok=True)
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        backup_path = BACKUP_DIR / f"jellyfin-channels-{timestamp}.m3u"
        
        import shutil
        shutil.copy2(self.m3u_path, backup_path)
        logger.info(f"Created backup: {backup_path}")
        return backup_path
    
    def test_all_channels(self, channels: List[Dict]) -> List[Dict]:
        """Test all channels concurrently"""
        logger.info(f"Testing {len(channels)} channels with {MAX_WORKERS} workers...")
        
        working_channels = []
        failed_channels = []
        
        with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
            # Submit all tests
            future_to_channel = {
                executor.submit(self.tester.test_channel, ch['url']): ch 
                for ch in channels
            }
            
            # Process results as they complete
            for i, future in enumerate(as_completed(future_to_channel), 1):
                channel = future_to_channel[future]
                self.results['tested'] = i
                
                try:
                    is_working, error_msg = future.result()
                    
                    if is_working:
                        working_channels.append(channel)
                        self.results['working'] += 1
                        status = "✓"
                    else:
                        failed_channels.append({**channel, 'error': error_msg})
                        self.results['failed'] += 1
                        status = "✗"
                    
                    # Progress indicator
                    if i % 10 == 0 or i == len(channels):
                        logger.info(f"Progress: {i}/{len(channels)} | ✓ {self.results['working']} | ✗ {self.results['failed']}")
                
                except Exception as e:
                    logger.error(f"Error testing channel {channel.get('name', 'Unknown')}: {e}")
                    failed_channels.append({**channel, 'error': str(e)})
                    self.results['failed'] += 1
        
        return working_channels, failed_channels
    
    def generate_report(self, working_channels: List[Dict], failed_channels: List[Dict]) -> Path:
        """Generate detailed HTML report"""
        REPORT_DIR.mkdir(parents=True, exist_ok=True)
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        report_path = REPORT_DIR / f"channel-health-{datetime.now().strftime('%Y%m%d_%H%M%S')}.html"
        
        # Calculate statistics by category
        categories = {}
        for ch in working_channels:
            cat = ch.get('group-title', 'Unknown')
            if cat not in categories:
                categories[cat] = {'working': 0, 'failed': 0}
            categories[cat]['working'] += 1
        
        for ch in failed_channels:
            cat = ch.get('group-title', 'Unknown')
            if cat not in categories:
                categories[cat] = {'working': 0, 'failed': 0}
            categories[cat]['failed'] += 1
        
        html = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Jellyfin Channel Health Report - {timestamp}</title>
    <style>
        * {{ margin: 0; padding: 0; box-sizing: border-box; }}
        body {{
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #0A192F 0%, #0D223C 100%);
            color: #E2E8F0;
            padding: 20px;
        }}
        .container {{
            max-width: 1200px;
            margin: 0 auto;
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(10px);
            border-radius: 12px;
            padding: 30px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
        }}
        h1 {{
            color: #17BECF;
            margin-bottom: 10px;
            font-size: 32px;
        }}
        .timestamp {{
            color: #94A3B8;
            margin-bottom: 30px;
            font-size: 14px;
        }}
        .stats {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }}
        .stat-card {{
            background: rgba(255, 255, 255, 0.08);
            padding: 20px;
            border-radius: 8px;
            border-left: 4px solid;
        }}
        .stat-card.working {{ border-color: #10B981; }}
        .stat-card.failed {{ border-color: #EF4444; }}
        .stat-card.total {{ border-color: #17BECF; }}
        .stat-value {{
            font-size: 36px;
            font-weight: bold;
            margin-bottom: 5px;
        }}
        .stat-label {{
            color: #94A3B8;
            font-size: 14px;
        }}
        .category-section {{
            margin-top: 30px;
        }}
        .category-section h2 {{
            color: #17BECF;
            margin-bottom: 15px;
            font-size: 24px;
        }}
        table {{
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }}
        th, td {{
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }}
        th {{
            background: rgba(23, 190, 207, 0.2);
            color: #17BECF;
            font-weight: 600;
        }}
        tr:hover {{
            background: rgba(255, 255, 255, 0.05);
        }}
        .status-working {{ color: #10B981; }}
        .status-failed {{ color: #EF4444; }}
        .error {{
            color: #F59E0B;
            font-size: 12px;
        }}
        .alert {{
            background: rgba(239, 68, 68, 0.1);
            border-left: 4px solid #EF4444;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
        }}
        .success {{
            background: rgba(16, 185, 129, 0.1);
            border-left: 4px solid #10B981;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
        }}
    </style>
</head>
<body>
    <div class="container">
        <h1>🎬 Jellyfin Channel Health Report</h1>
        <div class="timestamp">Generated: {timestamp}</div>
        
        {'<div class="alert">⚠️ <strong>Warning:</strong> Channel count dropped below threshold! Only ' + str(len(working_channels)) + ' channels remaining (minimum: ' + str(MIN_CHANNEL_THRESHOLD) + ')</div>' if len(working_channels) < MIN_CHANNEL_THRESHOLD else ''}
        
        {'<div class="success">✅ <strong>Success:</strong> Removed ' + str(len(failed_channels)) + ' dead channels. M3U updated with ' + str(len(working_channels)) + ' working channels.</div>' if failed_channels else '<div class="success">✅ <strong>Excellent:</strong> All channels are working! No cleanup needed.</div>'}
        
        <div class="stats">
            <div class="stat-card total">
                <div class="stat-value">{len(working_channels) + len(failed_channels)}</div>
                <div class="stat-label">Total Tested</div>
            </div>
            <div class="stat-card working">
                <div class="stat-value">{len(working_channels)}</div>
                <div class="stat-label">Working Channels</div>
            </div>
            <div class="stat-card failed">
                <div class="stat-value">{len(failed_channels)}</div>
                <div class="stat-label">Failed Channels</div>
            </div>
            <div class="stat-card total">
                <div class="stat-value">{round(len(working_channels) / (len(working_channels) + len(failed_channels)) * 100, 1)}%</div>
                <div class="stat-label">Success Rate</div>
            </div>
        </div>
        
        <div class="category-section">
            <h2>📊 Statistics by Category</h2>
            <table>
                <thead>
                    <tr>
                        <th>Category</th>
                        <th>Working</th>
                        <th>Failed</th>
                        <th>Total</th>
                        <th>Success Rate</th>
                    </tr>
                </thead>
                <tbody>
"""
        
        for cat, stats in sorted(categories.items(), key=lambda x: x[1]['working'], reverse=True):
            total = stats['working'] + stats['failed']
            rate = round(stats['working'] / total * 100, 1) if total > 0 else 0
            html += f"""
                    <tr>
                        <td>{cat}</td>
                        <td class="status-working">{stats['working']}</td>
                        <td class="status-failed">{stats['failed']}</td>
                        <td>{total}</td>
                        <td>{rate}%</td>
                    </tr>
"""
        
        html += """
                </tbody>
            </table>
        </div>
"""
        
        if failed_channels:
            html += """
        <div class="category-section">
            <h2>❌ Failed Channels (Removed)</h2>
            <table>
                <thead>
                    <tr>
                        <th>Channel Name</th>
                        <th>Category</th>
                        <th>Error</th>
                    </tr>
                </thead>
                <tbody>
"""
            for ch in failed_channels:
                html += f"""
                    <tr>
                        <td>{ch.get('name', 'Unknown')}</td>
                        <td>{ch.get('group-title', 'Unknown')}</td>
                        <td class="error">{ch.get('error', 'Unknown error')}</td>
                    </tr>
"""
            html += """
                </tbody>
            </table>
        </div>
"""
        
        html += """
    </div>
</body>
</html>
"""
        
        with open(report_path, 'w', encoding='utf-8') as f:
            f.write(html)
        
        logger.info(f"Generated report: {report_path}")
        return report_path
    
    def run(self, dry_run: bool = False):
        """Execute the monitoring workflow"""
        logger.info("=" * 60)
        logger.info("Jellyfin Channel Monitor - Starting")
        logger.info("=" * 60)
        
        # Parse channels
        channels = self.parser.parse()
        original_count = len(channels)
        
        # Backup M3U
        if not dry_run:
            self.backup_m3u()
        
        # Test all channels
        working_channels, failed_channels = self.test_all_channels(channels)
        
        # Generate report
        report_path = self.generate_report(working_channels, failed_channels)
        
        # Update M3U if not dry run
        if not dry_run and failed_channels:
            self.parser.save(working_channels)
            self.results['removed'] = len(failed_channels)
            self.results['kept'] = len(working_channels)
            logger.info(f"✅ Updated M3U file: removed {len(failed_channels)} dead channels")
        elif dry_run:
            logger.info(f"🔍 DRY RUN: Would remove {len(failed_channels)} channels")
        else:
            logger.info("✅ All channels working - no changes needed")
        
        # Summary
        logger.info("=" * 60)
        logger.info("Summary:")
        logger.info(f"  Original channels: {original_count}")
        logger.info(f"  Working channels:  {len(working_channels)} ({round(len(working_channels)/original_count*100, 1)}%)")
        logger.info(f"  Failed channels:   {len(failed_channels)} ({round(len(failed_channels)/original_count*100, 1)}%)")
        logger.info(f"  Report: {report_path}")
        logger.info("=" * 60)
        
        # Alert if channels dropped significantly
        if len(working_channels) < MIN_CHANNEL_THRESHOLD:
            logger.warning(f"⚠️  ALERT: Only {len(working_channels)} channels remain (threshold: {MIN_CHANNEL_THRESHOLD})")
        
        self.tester.close()
        return self.results


def main():
    parser = argparse.ArgumentParser(description='Monitor and clean Jellyfin Live TV channels')
    parser.add_argument('--dry-run', action='store_true', help='Test channels but don\'t update M3U')
    parser.add_argument('--m3u', type=Path, default=M3U_PATH, help='Path to M3U file')
    parser.add_argument('--workers', type=int, default=20, help='Number of concurrent workers')
    parser.add_argument('--timeout', type=int, default=10, help='Timeout per channel (seconds)')
    
    args = parser.parse_args()
    
    # Run monitor with custom settings
    monitor = ChannelMonitor(args.m3u)
    monitor.tester.timeout = args.timeout
    results = monitor.run(dry_run=args.dry_run)
    
    # Exit code based on results
    if results['failed'] > 0 and results['working'] < MIN_CHANNEL_THRESHOLD:
        sys.exit(2)  # Critical - too many failures
    elif results['failed'] > results['working']:
        sys.exit(1)  # Warning - majority failed
    else:
        sys.exit(0)  # Success


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""
🚀 ENABLE LIVE MODE - Switch from sample mode to real job discovery
"""

import sqlite3
import json
import os
from pathlib import Path

def enable_live_mode():
    """Enable live job discovery"""
    
    config_file = "config/profile.json"
    
    print("\n" + "="*70)
    print("🔄 ENABLING LIVE JOB DISCOVERY MODE")
    print("="*70 + "\n")
    
    # Read current config
    with open(config_file, 'r') as f:
        config = json.load(f)
    
    # Check current mode
    current_mode = config.get('discovery_mode', 'sample')
    print(f"📋 Current mode: {current_mode}")
    
    # Enable live mode
    config['discovery_mode'] = 'live'
    config['sample_size'] = 0  # 0 = unlimited
    config['enable_scraping'] = True
    config['enable_linkedin_crawl'] = True
    
    # Save updated config
    with open(config_file, 'w') as f:
        json.dump(config, f, indent=2)
    
    print(f"✅ Updated config: {config_file}")
    print(f"   Discovery mode: sample → LIVE")
    print(f"   Job limits: Removed")
    print(f"   Scraping: ENABLED")
    print(f"   LinkedIn crawl: ENABLED")
    
    print("\n" + "="*70)
    print("✨ LIVE MODE ACTIVATED!")
    print("="*70 + "\n")
    
    return True

if __name__ == '__main__':
    enable_live_mode()

#!/usr/bin/env python3
"""
Cloudflare DNS Update Script
Updates prometheus.simondatalab.de from CNAME to A record
"""

import requests
import json
import os
import sys

# Cloudflare API configuration
CLOUDFLARE_API_TOKEN = os.getenv('CLOUDFLARE_API_TOKEN')
CLOUDFLARE_ZONE_ID = os.getenv('CLOUDFLARE_ZONE_ID')

if not CLOUDFLARE_API_TOKEN:
    print("❌ Error: CLOUDFLARE_API_TOKEN environment variable not set")
    print("Please set it with: export CLOUDFLARE_API_TOKEN='your_token_here'")
    sys.exit(1)

# Configuration
ZONE_NAME = "simondatalab.de"
RECORD_NAME = "prometheus.simondatalab.de"
NEW_IP = "136.243.155.166"
PROXIED = True  # Enable Cloudflare proxy for DDoS protection

headers = {
    "Authorization": f"Bearer {CLOUDFLARE_API_TOKEN}",
    "Content-Type": "application/json"
}

def get_zone_id():
    """Get zone ID for simondatalab.de"""
    if CLOUDFLARE_ZONE_ID:
        return CLOUDFLARE_ZONE_ID
    
    url = "https://api.cloudflare.com/v1/client/v4/zones"
    params = {"name": ZONE_NAME}
    
    response = requests.get(url, headers=headers, params=params)
    data = response.json()
    
    if not data.get('success'):
        print(f"❌ Error getting zone ID: {data.get('errors')}")
        sys.exit(1)
    
    if not data.get('result'):
        print(f"❌ Zone {ZONE_NAME} not found")
        sys.exit(1)
    
    zone_id = data['result'][0]['id']
    print(f"✅ Found zone ID: {zone_id}")
    return zone_id

def get_dns_record(zone_id):
    """Get existing DNS record for prometheus.simondatalab.de"""
    url = f"https://api.cloudflare.com/v1/client/v4/zones/{zone_id}/dns_records"
    params = {"name": RECORD_NAME}
    
    response = requests.get(url, headers=headers, params=params)
    data = response.json()
    
    if not data.get('success'):
        print(f"❌ Error getting DNS records: {data.get('errors')}")
        return None
    
    if data.get('result'):
        record = data['result'][0]
        print(f"\n📋 Current DNS Record:")
        print(f"   Type: {record['type']}")
        print(f"   Name: {record['name']}")
        print(f"   Content: {record['content']}")
        print(f"   Proxied: {record['proxied']}")
        print(f"   ID: {record['id']}")
        return record
    
    print(f"⚠️  No existing record found for {RECORD_NAME}")
    return None

def delete_dns_record(zone_id, record_id):
    """Delete existing DNS record"""
    url = f"https://api.cloudflare.com/v1/client/v4/zones/{zone_id}/dns_records/{record_id}"
    
    response = requests.delete(url, headers=headers)
    data = response.json()
    
    if data.get('success'):
        print(f"✅ Deleted old CNAME record")
        return True
    else:
        print(f"❌ Error deleting record: {data.get('errors')}")
        return False

def create_a_record(zone_id):
    """Create new A record"""
    url = f"https://api.cloudflare.com/v1/client/v4/zones/{zone_id}/dns_records"
    
    payload = {
        "type": "A",
        "name": "prometheus",
        "content": NEW_IP,
        "ttl": 1,  # Auto
        "proxied": PROXIED
    }
    
    response = requests.post(url, headers=headers, json=payload)
    data = response.json()
    
    if data.get('success'):
        record = data['result']
        print(f"\n✅ Created new A record:")
        print(f"   Type: {record['type']}")
        print(f"   Name: {record['name']}")
        print(f"   Content: {record['content']}")
        print(f"   Proxied: {record['proxied']}")
        print(f"   TTL: {'Auto' if record['ttl'] == 1 else record['ttl']}")
        return True
    else:
        print(f"❌ Error creating A record: {data.get('errors')}")
        return False

def main():
    print("🚀 Cloudflare DNS Update: prometheus.simondatalab.de")
    print("=" * 60)
    
    # Get zone ID
    zone_id = get_zone_id()
    
    # Get existing record
    existing_record = get_dns_record(zone_id)
    
    if existing_record:
        # Confirm before deletion
        print(f"\n⚠️  About to delete CNAME and create A record")
        print(f"   Old: CNAME → {existing_record['content']}")
        print(f"   New: A → {NEW_IP} (Proxied: {PROXIED})")
        
        confirm = input("\nProceed? (yes/no): ").strip().lower()
        if confirm != 'yes':
            print("❌ Cancelled by user")
            sys.exit(0)
        
        # Delete old record
        if not delete_dns_record(zone_id, existing_record['id']):
            sys.exit(1)
    
    # Create new A record
    if create_a_record(zone_id):
        print("\n🎉 DNS update complete!")
        print(f"\n📝 Next steps:")
        print(f"   1. Wait 2-5 minutes for DNS propagation")
        print(f"   2. Run: dig prometheus.simondatalab.de")
        print(f"   3. SSH to Proxmox and run:")
        print(f"      certbot certonly --nginx -d prometheus.simondatalab.de \\")
        print(f"          --non-interactive --agree-tos --email admin@simondatalab.de")
        print(f"   4. Enable Nginx: ln -sf /etc/nginx/sites-available/prometheus-proxy.conf \\")
        print(f"                         /etc/nginx/sites-enabled/prometheus-proxy.conf")
        print(f"   5. Reload: nginx -t && systemctl reload nginx")
    else:
        sys.exit(1)

if __name__ == "__main__":
    main()

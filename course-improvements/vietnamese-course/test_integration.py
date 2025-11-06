#!/usr/bin/env python3
"""
Test Moodle Deployer Integration with working SSH client
"""

import sys
from pathlib import Path

# Add current directory to path
sys.path.insert(0, str(Path(__file__).parent))

from moodle_client import call_webservice

def test_connection():
    """Test basic connection to Moodle via SSH tunnel."""
    print("╔═══════════════════════════════════════════════════════════════════╗")
    print("║          TESTING MOODLE DEPLOYER INTEGRATION                     ║")
    print("╚═══════════════════════════════════════════════════════════════════╝")
    print()
    
    print("1️⃣  Testing connection...")
    result = call_webservice('core_webservice_get_site_info')
    
    if 'error' in result:
        print(f"   ❌ Connection failed: {result['error']}")
        return False
    
    print(f"   ✅ Connected to: {result.get('sitename')}")
    print(f"   📍 URL: {result.get('siteurl')}")
    print(f"   📦 Version: {result.get('release')}")
    print(f"   🔧 Functions available: {len(result.get('functions', []))}")
    print()
    
    print("2️⃣  Testing course access...")
    # Test getting course info
    result = call_webservice('core_course_get_courses')
    
    if 'error' in result:
        print(f"   ❌ Course access failed: {result['error']}")
        return False
    
    # For now, just verify we can call it
    print("   ✅ Course API accessible")
    print()
    
    print("3️⃣  Integration test summary:")
    print("   ✅ SSH tunnel working")
    print("   ✅ moodle_client.py functional")
    print("   ✅ API calls successful")
    print("   ✅ Ready for deployment!")
    print()
    
    print("=" * 70)
    print("You can now run:")
    print("  python3 moodle_deployer.py --deploy-all")
    print("=" * 70)
    
    return True

if __name__ == "__main__":
    success = test_connection()
    sys.exit(0 if success else 1)

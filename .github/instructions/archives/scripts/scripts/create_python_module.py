import os
import requests
import sys
import json
import time

MOODLE_URL = os.getenv("MOODLE_URL", "http://localhost:8081/webservice/rest/server.php")
TOKEN = os.getenv("MOODLE_TOKEN", "")  # supply via env var; do not hardcode

if not TOKEN:
    raise RuntimeError("MOODLE_TOKEN environment variable is required; do not hardcode tokens.")

def wait_for_moodle(timeout=60):
    """Wait for Moodle to be fully operational"""
    print("Waiting for Moodle to initialize...")
    start_time = time.time()
    while time.time() - start_time < timeout:
        if test_connection():
            time.sleep(5)  # Give extra time for services to initialize
            return True
        time.sleep(2)
    return False

def test_connection():
    """Test if Moodle is responding"""
    try:
        response = requests.get("http://localhost:8081/")
        if response.status_code == 200:
            print("Moodle is running")
            return True
        return False
    except requests.exceptions.ConnectionError:
        print("Moodle is not responding yet. Waiting for service to start...")
        return False

def check_web_service():
    """Verify web service is enabled and working"""
    params = {
        'wstoken': TOKEN,
        'wsfunction': 'core_webservice_get_site_info',
        'moodlewsrestformat': 'json'
    }
    
    try:
        response = requests.get(MOODLE_URL, params=params, timeout=30)
        print("\nDEBUG: Testing web service configuration...")
        print(f"URL: {MOODLE_URL}")
        print(f"Token: {TOKEN[:5]}...{TOKEN[-5:]}")
        print(f"Response status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            if 'exception' in data:
                print("\n⚠️  Web service not properly configured")
                print("\nRequired steps in order:")
                print("\n1. Enable Web Services:")
                print("   ➜ Go to Site administration > Advanced features")
                print("   ➜ Check 'Enable web services'")
                print("   ➜ Check 'Enable mobile web service'")
                print("   ➜ Click 'Save changes'")
                
                print("\n2. Enable Authentication:")
                print("   ➜ Go to Site administration > Plugins > Authentication")
                print("   ➜ Enable 'Web services authentication'")
                print("   ➜ Click 'Save changes'")
                
                print("\n3. Enable REST Protocol:")
                print("   ➜ Go to Site administration > Server > Web services > Manage protocols")
                print("   ➜ Enable 'REST Protocol'")
                print("   ➜ Click 'Save changes'")
                
                print("\n4. Verify External Service:")
                print("   ➜ Go to Site administration > Server > Web services > External services")
                print("   ➜ Check that 'core_course_create_courses' is enabled")
                print("   ➜ Click on it and verify 'Enabled' is checked")
                
                print("\nAfter each step, run:")
                print("   $ docker-compose restart moodle")
                print("   $ python3 scripts/create_python_module.py")
                return False
                
            print("✓ Web service configuration verified")
            return True
            
    except Exception as e:
        print(f"\n❌ Web service check failed: {e}")
        return False

def check_capabilities():
    """Verify required capabilities are enabled"""
    params = {
        'wstoken': TOKEN,
        'wsfunction': 'core_webservice_get_site_info',
        'moodlewsrestformat': 'json'
    }
    
    try:
        response = requests.get(MOODLE_URL, params=params, timeout=30)
        if response.status_code == 200:
            data = response.json()
            # Check if we're authorized
            if data.get('username'):
                print(f"Authenticated as: {data.get('username')}")
                print("Service access verified")
                return True
        print("Authentication failed or insufficient permissions")
        print("\nPlease verify:")
        print("1. Your token is associated with the core_course_create_courses service")
        print("2. Your user is authorized to use the service")
        print("3. The service is enabled")
        return False
    except Exception as e:
        print(f"Capability check failed: {e}")
        return False

def create_python_module():
    course_params = {
        'wstoken': TOKEN,
        'wsfunction': 'core_course_create_courses',
        'moodlewsrestformat': 'json',
        'courses[0][fullname]': 'Module 1 - Core Python',
        'courses[0][shortname]': 'core_python',
        'courses[0][categoryid]': 1,
        'courses[0][summary]': """
# Module 1 - Core Python

This foundational module covers core Python programming concepts essential for data analysis and scientific computing.

## Topics Covered:
- Python basics and environment setup
- Data types and structures
- Control flow and functions
- Object-oriented programming
- Error handling and debugging
- Working with files and modules
- Best practices and PEP 8

## Learning Objectives:
- Understand Python fundamentals
- Write clean, efficient Python code
- Implement basic algorithms
- Debug and troubleshoot code issues
- Use Python's standard library effectively
""",
        'courses[0][summaryformat]': 4,  # 4 = Markdown format
        'courses[0][format]': 'topics',
        'courses[0][showgrades]': 1,
        'courses[0][newsitems]': 5,
        'courses[0][startdate]': 0,  # Start immediately
        'courses[0][enablecompletion]': 1
    }

    try:
        response = requests.post(MOODLE_URL, params=course_params, timeout=30)
        print(f"Status Code: {response.status_code}")
        print(f"Response Text: {response.text}")
        
        response.raise_for_status()
        
        if response.text:
            result = response.json()
            # Check for Moodle exceptions
            if isinstance(result, dict) and 'exception' in result:
                print(f"\nMoodle error: {result['message']}")
                print("\nTo fix this:")
                print("1. Go to Site administration > Users > Permissions > Define roles")
                print("2. Edit the 'Authenticated user' role")
                print("3. Enable these capabilities:")
                print("   - moodle/course:create")
                print("   - moodle/course:visibility")
                print("4. Or create a new role with these capabilities")
                return None
            
            # Check for successful course creation
            if isinstance(result, list) and result:
                print(f"Course created successfully with ID: {result[0]['id']}")
                return result[0]
            else:
                print("Error: Unexpected response format")
                return None
                
        else:
            print("Error: Empty response from server")
            return None
            
    except requests.exceptions.HTTPError as e:
        print(f"HTTP Error: {e}")
        if hasattr(e, 'response') and e.response is not None:
            try:
                print("Response content:", e.response.text)
            except Exception:
                pass
        sys.exit(1)
    except requests.exceptions.RequestException as e:
        print(f"Request failed: {e}")
        sys.exit(1)
    except (ValueError, KeyError) as e:
        print(f"Response parsing error: {e}")
        # Raw response may not be accessible here safely; skip printing
        sys.exit(1)

if __name__ == "__main__":
    if not wait_for_moodle():
        print("Moodle failed to initialize")
        sys.exit(1)
    if not test_connection():
        sys.exit(1)
    if not check_web_service():
        print("Please enable web services in Moodle:")
        print("1. Go to Site administration > Advanced features")
        print("2. Enable 'Web services'")
        print("3. Enable 'Mobile web services'")
        sys.exit(1)
    if not check_capabilities():
        sys.exit(1)
    create_python_module()
import requests
import sys
import time

MOODLE_URL = "http://localhost:8081"
ADMIN_PASSWORD = "StrongPass123"

def wait_for_moodle():
    """Wait for Moodle to be available"""
    print("Waiting for Moodle...")
    for _ in range(30):
        try:
            response = requests.get(MOODLE_URL)
            if response.status_code == 200:
                print("Moodle is ready")
                return True
        except requests.exceptions.ConnectionError:
            pass
        time.sleep(2)
    return False

def install_plugins():
    """Install CodeRunner and its dependencies"""
    session = requests.Session()
    
    # Login as admin
    login_data = {
        'username': 'admin',
        'password': ADMIN_PASSWORD
    }
    response = session.post(f"{MOODLE_URL}/login/index.php", data=login_data)
    
    # Trigger plugin installation
    install_url = f"{MOODLE_URL}/admin/tool/installaddon/index.php"
    session.get(install_url)
    
    print("Please complete installation through web interface:")
    print(f"1. Visit {MOODLE_URL}/admin")
    print("2. Look for notifications about new plugins")
    print("3. Follow the installation wizard")
    print("4. Verify CodeRunner is installed in Site administration > Plugins > Question types")

if __name__ == "__main__":
    if not wait_for_moodle():
        print("Error: Moodle is not responding")
        sys.exit(1)
    install_plugins()
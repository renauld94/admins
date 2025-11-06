#!/usr/bin/env python3
"""
Direct Moodle API Caller - Calls Moodle webservice PHP functions directly
This bypasses all HTTP layers and calls Moodle's core functions directly via CLI
"""

import os
import sys
import subprocess
import json
from typing import Dict, Any, Optional

SSH_HOST = "moodle-vm9001"
MOODLE_CONTAINER = "moodle-databricks-fresh"
TOKEN_FILE = os.path.expanduser("~/.moodle_token")

def call_moodle_webservice(wsfunction: str, params: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    """
    Call a Moodle webservice function directly via PHP CLI
    
    Args:
        wsfunction: The webservice function name (e.g., 'core_webservice_get_site_info')
        params: Additional parameters for the function
    
    Returns:
        Dictionary with the response data
    """
    # Read token
    with open(TOKEN_FILE, 'r') as f:
        token = f.read().strip()
    
    # Build PHP script to call webservice
    params_str = json.dumps(params or {})
    
    php_script = f"""
define('CLI_SCRIPT', true);
require('/bitnami/moodle/config.php');
require_once($CFG->libdir . '/externallib.php');

// Authenticate with token
$token = '{token}';
$tokenrecord = $DB->get_record('external_tokens', array('token' => $token));
if (!$tokenrecord) {{
    echo json_encode(array('error' => 'Invalid token'));
    exit(1);
}}

// Set user context
$USER = $DB->get_record('user', array('id' => $tokenrecord->userid));
if (!$USER) {{
    echo json_encode(array('error' => 'User not found'));
    exit(1);
}}

// Call the webservice function
try {{
    $params = json_decode('{params_str}', true);
    
    // Get the function info
    $function = external_api::external_function_info('{wsfunction}');
    
    // Call it
    $result = call_user_func(array($function->classname, $function->methodname), ...array_values($params));
    
    // Return result
    echo json_encode($result);
}} catch (Exception $e) {{
    echo json_encode(array('error' => $e->getMessage(), 'exception' => get_class($e)));
    exit(1);
}}
"""
    
    # Execute via SSH + Docker
    ssh_cmd = [
        "ssh", SSH_HOST,
        f"sudo docker exec {MOODLE_CONTAINER} php -r '{php_script}' 2>&1"
    ]
    
    output = ""
    try:
        result = subprocess.run(ssh_cmd, capture_output=True, text=True, timeout=30)
        output = result.stdout.strip()
        
        # Remove PHP warnings
        lines = output.split('\n')
        json_lines = [line for line in lines if line.strip().startswith('{') or line.strip().startswith('[')]
        
        if not json_lines:
            return {"error": "No JSON response", "raw_output": output}
        
        return json.loads(json_lines[-1])
        
    except subprocess.TimeoutExpired:
        return {"error": "Timeout calling Moodle"}
    except json.JSONDecodeError as e:
        return {"error": f"Invalid JSON response: {e}", "raw_output": output}
    except Exception as e:
        return {"error": str(e)}

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 moodle_direct_call.py <wsfunction> [param1=value1] [param2=value2] ...")
        print("\nExample:")
        print("  python3 moodle_direct_call.py core_webservice_get_site_info")
        print("  python3 moodle_direct_call.py core_course_get_courses")
        return 1
    
    wsfunction = sys.argv[1]
    params = {}
    
    # Parse parameters
    for arg in sys.argv[2:]:
        if '=' in arg:
            key, value = arg.split('=', 1)
            # Try to parse as JSON, otherwise treat as string
            try:
                params[key] = json.loads(value)
            except:
                params[key] = value
    
    print(f"🔧 Calling {wsfunction}...")
    if params:
        print(f"📝 Parameters: {json.dumps(params, indent=2)}")
    print()
    
    result = call_moodle_webservice(wsfunction, params)
    print(json.dumps(result, indent=2))
    
    return 0 if 'error' not in result else 1

if __name__ == "__main__":
    sys.exit(main())

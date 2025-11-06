#!/usr/bin/env python3
"""
Moodle API Proxy - Bypasses Cloudflare by using SSH tunnel to VM 9001
This script provides a local proxy that forwards Moodle API calls through SSH
"""

import os
import sys
import subprocess
import json
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import parse_qs, urlparse
import threading

SSH_HOST = "moodle-vm9001"
MOODLE_CONTAINER = "moodle-databricks-fresh"
TOKEN_FILE = os.path.expanduser("~/.moodle_token")

class MoodleProxyHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        """Handle POST requests to Moodle webservice"""
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length).decode('utf-8')
        params = parse_qs(post_data)
        
        # Extract parameters
        wstoken = params.get('wstoken', [''])[0]
        wsfunction = params.get('wsfunction', [''])[0]
        moodlewsrestformat = params.get('moodlewsrestformat', ['json'])[0]
        
        # Build the curl command for SSH execution
        cmd_params = f"wstoken={wstoken}&wsfunction={wsfunction}&moodlewsrestformat={moodlewsrestformat}"
        
        # Add any additional parameters
        for key, values in params.items():
            if key not in ['wstoken', 'wsfunction', 'moodlewsrestformat']:
                for value in values:
                    cmd_params += f"&{key}={value}"
        
        # Execute via SSH tunnel
        ssh_cmd = [
            "ssh", SSH_HOST,
            f"sudo docker exec {MOODLE_CONTAINER} php -r \"" +
            "$ch = curl_init('http://localhost:8080/webservice/rest/server.php');" +
            "curl_setopt($ch, CURLOPT_POST, 1);" +
            f"curl_setopt($ch, CURLOPT_POSTFIELDS, '{cmd_params}');" +
            "curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);" +
            "curl_setopt($ch, CURLOPT_FOLLOWLOCATION, false);" +  # Don't follow redirects
            "$response = curl_exec($ch);" +
            "$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);" +
            "curl_close($ch);" +
            "echo $response;" +
            "\""
        ]
        
        try:
            result = subprocess.run(ssh_cmd, capture_output=True, text=True, timeout=30)
            response_data = result.stdout.strip()
            
            # Check if it's a redirect HTML
            if '<title>Redirect</title>' in response_data:
                self.send_response(500)
                self.send_header('Content-type', 'application/json')
                self.end_headers()
                error_response = json.dumps({
                    "exception": "webservice_redirect_error",
                    "errorcode": "redirectdetected",
                    "message": "Moodle is forcing HTTPS redirect. Webservice must be accessed via HTTPS."
                })
                self.wfile.write(error_response.encode('utf-8'))
                return
            
            # Return the response
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            self.wfile.write(response_data.encode('utf-8'))
            
        except subprocess.TimeoutExpired:
            self.send_response(504)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            error_response = json.dumps({
                "exception": "webservice_timeout",
                "errorcode": "timeout",
                "message": "Request to Moodle timed out"
            })
            self.wfile.write(error_response.encode('utf-8'))
        except Exception as e:
            self.send_response(500)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            error_response = json.dumps({
                "exception": "webservice_proxy_error",
                "errorcode": "proxyerror",
                "message": str(e)
            })
            self.wfile.write(error_response.encode('utf-8'))
    
    def log_message(self, format, *args):
        """Custom log format"""
        sys.stderr.write(f"[{self.log_date_time_string()}] {format % args}\n")

def main():
    # Check if token file exists
    if not os.path.exists(TOKEN_FILE):
        print(f"❌ Token file not found: {TOKEN_FILE}")
        print("Please create a token first using create_token_cli.sh")
        return 1
    
    # Start the proxy server
    port = 9999
    server = HTTPServer(('127.0.0.1', port), MoodleProxyHandler)
    
    print(f"🚀 Moodle API Proxy started on http://127.0.0.1:{port}")
    print(f"📡 Forwarding requests to {SSH_HOST} -> {MOODLE_CONTAINER}")
    print(f"🔑 Using token from {TOKEN_FILE}")
    print(f"")
    print(f"Update your moodle_deployer.py to use:")
    print(f"  MOODLE_URL = 'http://127.0.0.1:{port}'")
    print(f"")
    print("Press Ctrl+C to stop")
    
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n👋 Shutting down proxy...")
        server.shutdown()
        return 0

if __name__ == "__main__":
    sys.exit(main())

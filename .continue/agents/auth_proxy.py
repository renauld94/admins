#!/usr/bin/env python3
"""
Authentication Proxy for Infrastructure Diagram
Protects infrastructure-diagram.html when sensitive data is detected
NO EMOJIS - Professional security implementation
"""

import json
import hashlib
import os
from pathlib import Path
from flask import Flask, request, jsonify, send_file, Response, session
from functools import wraps
from datetime import timedelta

app = Flask(__name__)
app.secret_key = os.urandom(24)
app.permanent_session_lifetime = timedelta(hours=2)

# Paths
REPORTS_DIR = Path("/home/simon/Learning-Management-System-Academy/.continue/agents/reports")
AUTH_FILE = REPORTS_DIR / "auth_required.json"
DATA_FILE = REPORTS_DIR / "infrastructure_data.json"
DIAGRAM_FILE = Path("/var/www/html/infrastructure-diagram.html")

def check_auth_required() -> bool:
    """Check if authentication is required"""
    if AUTH_FILE.exists():
        try:
            with open(AUTH_FILE) as f:
                auth_data = json.load(f)
                return auth_data.get('auth_required', False)
        except Exception:
            pass
    return False

def get_auth_credentials():
    """Get authentication credentials"""
    if AUTH_FILE.exists():
        try:
            with open(AUTH_FILE) as f:
                auth_data = json.load(f)
                return auth_data.get('username'), auth_data.get('password_hash')
        except Exception:
            pass
    return None, None

def verify_password(username: str, password: str) -> bool:
    """Verify username and password"""
    stored_username, stored_hash = get_auth_credentials()
    if not stored_username or not stored_hash:
        return False
    
    password_hash = hashlib.sha256(password.encode()).hexdigest()
    return username == stored_username and password_hash == stored_hash

def require_auth(f):
    """Decorator to require authentication"""
    @wraps(f)
    def decorated(*args, **kwargs):
        if not check_auth_required():
            return f(*args, **kwargs)
        
        if session.get('authenticated'):
            return f(*args, **kwargs)
        
        # Check for basic auth
        auth = request.authorization
        if auth and verify_password(auth.username, auth.password):
            session['authenticated'] = True
            session.permanent = True
            return f(*args, **kwargs)
        
        return Response(
            'Authentication required. Sensitive infrastructure data detected.',
            401,
            {'WWW-Authenticate': 'Basic realm="Infrastructure Diagram"'}
        )
    
    return decorated

@app.route('/infrastructure-diagram.html')
@require_auth
def serve_diagram():
    """Serve infrastructure diagram with authentication"""
    if DIAGRAM_FILE.exists():
        return send_file(DIAGRAM_FILE)
    return "Infrastructure diagram not found", 404

@app.route('/api/infrastructure-data')
@require_auth
def get_infrastructure_data():
    """Get infrastructure data JSON"""
    if DATA_FILE.exists():
        try:
            with open(DATA_FILE) as f:
                data = json.load(f)
            return jsonify(data)
        except Exception as e:
            return jsonify({'error': str(e)}), 500
    return jsonify({'error': 'Data file not found'}), 404

@app.route('/api/auth/status')
def auth_status():
    """Check if authentication is required"""
    return jsonify({
        'auth_required': check_auth_required(),
        'authenticated': session.get('authenticated', False)
    })

@app.route('/api/auth/login', methods=['POST'])
def login():
    """Login endpoint"""
    if not check_auth_required():
        return jsonify({'success': True, 'message': 'No authentication required'})
    
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')
    
    if verify_password(username, password):
        session['authenticated'] = True
        session.permanent = True
        return jsonify({'success': True, 'message': 'Login successful'})
    
    return jsonify({'success': False, 'message': 'Invalid credentials'}), 401

@app.route('/api/auth/logout', methods=['POST'])
def logout():
    """Logout endpoint"""
    session.clear()
    return jsonify({'success': True, 'message': 'Logged out'})

@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'auth_required': check_auth_required()
    })

if __name__ == '__main__':
    # Run on localhost only (nginx will proxy)
    app.run(host='127.0.0.1', port=5555, debug=False)

# Subdomain Configuration Fix

## Current Issue
- **https://www.simondatalab.de/** = Personal Portfolio (✅ CORRECT)
- **https://ollama.simondatalab.de/** = Same as main site (❌ INCORRECT)
- **https://ollama.simondatalab.de/geospatial-viz/index.html** = Geospatial viz (✅ CORRECT)

## Expected Configuration
- **https://www.simondatalab.de/** = Personal Portfolio
- **https://ollama.simondatalab.de/** = Ollama AI Service OR Moodle LMS
- **https://ollama.simondatalab.de/geospatial-viz/** = Geospatial Visualization
- **https://moodle.simondatalab.de/** = Moodle Learning Management System

## Root Cause
The Ollama subdomain is incorrectly configured to serve the same content as the main portfolio site instead of serving the appropriate service (Ollama AI or Moodle LMS).

## Solution Options

### Option 1: Redirect Ollama to Moodle LMS
```nginx
server {
    listen 80;
    server_name ollama.simondatalab.de;
    
    # Redirect root to Moodle LMS
    location = / {
        return 302 http://moodle.simondatalab.de/;
    }
    
    # Serve geospatial visualization
    location /geospatial-viz/ {
        root /var/www/html;
        index index.html;
        try_files $uri $uri/ =404;
    }
    
    # Proxy API calls to Ollama service
    location /api/ {
        proxy_pass http://localhost:11434/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Option 2: Serve Moodle LMS directly on Ollama subdomain
```nginx
server {
    listen 80;
    server_name ollama.simondatalab.de;
    
    # Proxy to Moodle service
    location / {
        proxy_pass http://localhost:8086;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Serve geospatial visualization
    location /geospatial-viz/ {
        root /var/www/html;
        index index.html;
        try_files $uri $uri/ =404;
    }
}
```

### Option 3: Serve Ollama AI Service
```nginx
server {
    listen 80;
    server_name ollama.simondatalab.de;
    
    # Proxy to Ollama service
    location / {
        proxy_pass http://localhost:11434;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Serve geospatial visualization
    location /geospatial-viz/ {
        root /var/www/html;
        index index.html;
        try_files $uri $uri/ =404;
    }
}
```

## Recommended Approach
Based on the context, **Option 2** is recommended because:
1. The Ollama subdomain should serve the Moodle Learning Management System
2. The geospatial visualization should remain accessible
3. This provides a clear separation of services

## Implementation Steps
1. Create nginx configuration for ollama.simondatalab.de
2. Configure proper proxy settings for Moodle service
3. Ensure geospatial visualization remains accessible
4. Test all endpoints
5. Update DNS if necessary

## Files to Update
- `/etc/nginx/sites-available/ollama.simondatalab.de`
- `/etc/nginx/sites-enabled/ollama.simondatalab.de` (symlink)
- Docker compose configuration for Moodle service
- SSL certificates for the subdomain

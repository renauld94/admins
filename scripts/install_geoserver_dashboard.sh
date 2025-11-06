#!/bin/bash
# EPIC GeoServer Dashboard - Full Stack Installer
# VM106: simonadmin@10.0.0.106
# Components: GeoServer 2.25, PostGIS, nginx, React dashboard, Ollama integration

set -e

TARGET="simonadmin@10.0.0.106"
PROXY="root@136.243.155.166:2222"

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║       EPIC GEOSERVER DASHBOARD - INSTALLATION                 ║"
echo "╚═══════════════════════════════════════════════════════════════╝"

ssh -J "$PROXY" "$TARGET" 'bash -s' << 'ENDSSH'
set -e

echo ""
echo "📦 PHASE 1: Installing Prerequisites"
echo "═══════════════════════════════════════════════════════════════"

# Update system
sudo apt-get update

# Install Java 17 (required for GeoServer 2.25)
echo "Installing Java 17..."
sudo apt-get install -y openjdk-17-jdk openjdk-17-jre

# Install Tomcat 10
echo "Installing Tomcat 10..."
sudo apt-get install -y tomcat10 tomcat10-admin

# Install PostGIS
echo "Installing PostGIS extension for PostgreSQL..."
sudo apt-get install -y postgresql-16-postgis-3 postgis

# Install nginx
echo "Installing nginx..."
sudo apt-get install -y nginx

# Install Node.js 20 for dashboard
echo "Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install build tools
sudo apt-get install -y build-essential unzip wget curl

echo "✅ Prerequisites installed"
echo ""

echo "🗺️  PHASE 2: Installing GeoServer 2.25"
echo "═══════════════════════════════════════════════════════════════"

GEOSERVER_VERSION="2.25.5"
GEOSERVER_URL="https://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/geoserver-${GEOSERVER_VERSION}-war.zip/download"

cd /tmp
if [ ! -f "geoserver-${GEOSERVER_VERSION}-war.zip" ]; then
    echo "Downloading GeoServer ${GEOSERVER_VERSION}..."
    wget -O "geoserver-${GEOSERVER_VERSION}-war.zip" "$GEOSERVER_URL"
fi

echo "Extracting GeoServer..."
unzip -o "geoserver-${GEOSERVER_VERSION}-war.zip"

# Deploy to Tomcat
echo "Deploying to Tomcat..."
sudo systemctl stop tomcat10
sudo cp geoserver.war /var/lib/tomcat10/webapps/
sudo chown tomcat:tomcat /var/lib/tomcat10/webapps/geoserver.war

# Create GeoServer data directory
sudo mkdir -p /var/lib/geoserver_data
sudo chown -R tomcat:tomcat /var/lib/geoserver_data

# Configure Tomcat environment
sudo tee /etc/default/tomcat10 > /dev/null << 'EOF'
JAVA_OPTS="-Djava.awt.headless=true -Xmx2048m -Xms1024m -XX:+UseParallelGC"
GEOSERVER_DATA_DIR="/var/lib/geoserver_data"
EOF

echo "Starting Tomcat..."
sudo systemctl start tomcat10
sudo systemctl enable tomcat10

echo "✅ GeoServer deployed (will be ready in ~60 seconds)"
echo ""

echo "🗄️  PHASE 3: Configuring PostGIS"
echo "═══════════════════════════════════════════════════════════════"

sudo -u postgres psql << 'EOPSQL'
-- Create spatial database
CREATE DATABASE geospatial_demo;
\c geospatial_demo

-- Enable PostGIS
CREATE EXTENSION postgis;
CREATE EXTENSION postgis_topology;

-- Create demo table with Vietnam healthcare facilities
CREATE TABLE healthcare_facilities (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    type VARCHAR(100),
    location GEOMETRY(Point, 4326),
    capacity INTEGER,
    services TEXT[],
    active BOOLEAN DEFAULT true
);

-- Insert sample data (Vietnam healthcare network)
INSERT INTO healthcare_facilities (name, type, location, capacity, services) VALUES
('Hanoi Medical University Hospital', 'Hospital', ST_SetSRID(ST_MakePoint(105.8342, 21.0285), 4326), 1200, ARRAY['Emergency', 'Surgery', 'ICU']),
('Ho Chi Minh City General Hospital', 'Hospital', ST_SetSRID(ST_MakePoint(106.6297, 10.8231), 4326), 1500, ARRAY['Emergency', 'Cardiology', 'Oncology']),
('Da Nang Hospital', 'Hospital', ST_SetSRID(ST_MakePoint(108.2022, 16.0544), 4326), 800, ARRAY['Emergency', 'Pediatrics']),
('Can Tho Central Hospital', 'Hospital', ST_SetSRID(ST_MakePoint(105.7683, 10.0452), 4326), 600, ARRAY['Emergency', 'Surgery']),
('Hue Central Hospital', 'Hospital', ST_SetSRID(ST_MakePoint(107.5893, 16.4637), 4326), 700, ARRAY['Emergency', 'Neurology']),
('Nha Trang General Hospital', 'Hospital', ST_SetSRID(ST_MakePoint(109.1967, 12.2388), 4326), 500, ARRAY['Emergency', 'Orthopedics']),
('Vung Tau Hospital', 'Hospital', ST_SetSRID(ST_MakePoint(107.0843, 10.3460), 4326), 400, ARRAY['Emergency', 'Surgery']),
('Hai Phong Medical University Hospital', 'Hospital', ST_SetSRID(ST_MakePoint(106.6880, 20.8449), 4326), 900, ARRAY['Emergency', 'ICU', 'Surgery']);

-- Create research institutions table
CREATE TABLE research_institutions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    focus_area VARCHAR(100),
    location GEOMETRY(Point, 4326),
    staff_count INTEGER,
    established INTEGER
);

INSERT INTO research_institutions (name, focus_area, location, staff_count, established) VALUES
('Vietnam National University - Hanoi', 'Life Sciences', ST_SetSRID(ST_MakePoint(105.8019, 21.0392), 4326), 3000, 1906),
('Vietnam National University - HCMC', 'Biotechnology', ST_SetSRID(ST_MakePoint(106.6983, 10.7629), 4326), 2500, 1995),
('Hanoi University of Science and Technology', 'Bioinformatics', ST_SetSRID(ST_MakePoint(105.8436, 21.0049), 4326), 2000, 1956),
('Can Tho University', 'Agricultural Science', ST_SetSRID(ST_MakePoint(105.7681, 10.0302), 4326), 1200, 1966);

-- Create indexes
CREATE INDEX idx_healthcare_location ON healthcare_facilities USING GIST (location);
CREATE INDEX idx_research_location ON research_institutions USING GIST (location);

-- Grant access
CREATE USER geoserver WITH PASSWORD 'geoserver123!';
GRANT ALL PRIVILEGES ON DATABASE geospatial_demo TO geoserver;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO geoserver;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO geoserver;
EOPSQL

echo "✅ PostGIS configured with sample data"
echo ""

echo "🎨 PHASE 4: Creating Dashboard Frontend"
echo "═══════════════════════════════════════════════════════════════"

# Create dashboard directory
sudo mkdir -p /var/www/geoserver-dashboard
cd /var/www/geoserver-dashboard

# Create package.json
sudo tee package.json > /dev/null << 'EOFJSON'
{
  "name": "geoserver-epic-dashboard",
  "version": "1.0.0",
  "scripts": {
    "build": "webpack --mode production",
    "dev": "webpack serve --mode development"
  },
  "dependencies": {
    "ol": "^10.3.1",
    "chart.js": "^4.4.1",
    "axios": "^1.7.9"
  },
  "devDependencies": {
    "webpack": "^5.97.1",
    "webpack-cli": "^6.0.1",
    "webpack-dev-server": "^5.2.0",
    "css-loader": "^7.1.2",
    "style-loader": "^4.0.0"
  }
}
EOFJSON

echo "Installing dashboard dependencies..."
sudo npm install

echo "✅ Dashboard scaffolded"
echo ""

echo "🌐 PHASE 5: Configuring nginx"
echo "═══════════════════════════════════════════════════════════════"

sudo tee /etc/nginx/sites-available/geoserver-dashboard > /dev/null << 'EOFNGINX'
server {
    listen 8080;
    server_name _;

    # Dashboard frontend
    location / {
        root /var/www/geoserver-dashboard/dist;
        index index.html;
        try_files $uri $uri/ /index.html;
    }

    # GeoServer proxy
    location /geoserver/ {
        proxy_pass http://localhost:8080/geoserver/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # CORS headers
        add_header Access-Control-Allow-Origin *;
        add_header Access-Control-Allow-Methods 'GET, POST, OPTIONS';
        add_header Access-Control-Allow-Headers 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
    }

    # Ollama proxy for AI features
    location /api/ollama/ {
        proxy_pass http://localhost:11434/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOFNGINX

sudo ln -sf /etc/nginx/sites-available/geoserver-dashboard /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx

echo "✅ nginx configured"
echo ""

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                    INSTALLATION COMPLETE!                      ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "📊 Services Status:"
echo "   • GeoServer:  http://10.0.0.106:8080/geoserver"
echo "   • Dashboard:  http://10.0.0.106:8080"
echo "   • PostgreSQL: localhost:5432/geospatial_demo"
echo "   • Ollama:     localhost:11434"
echo ""
echo "🔐 Default Credentials:"
echo "   • GeoServer: admin / geoserver"
echo "   • PostgreSQL: geoserver / geoserver123!"
echo ""
echo "⏳ Note: GeoServer may take 1-2 minutes to fully start"
echo ""
echo "🎯 Next: Run dashboard builder script to create the UI"
ENDSSH

echo ""
echo "✅ Base installation complete on VM106"
echo ""
echo "🚀 Ready to build dashboard UI? Run:"
echo "   ./scripts/build_geoserver_dashboard_ui.sh"

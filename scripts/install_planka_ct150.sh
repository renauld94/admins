#!/bin/bash
# Install Planka (Trello-like task board) on CT 150 for Job Search Tracking
# Planka is a lightweight, self-hosted project management tool

set -e

echo "========================================================================"
echo "📋 PLANKA INSTALLATION ON CT 150"
echo "========================================================================"
echo ""
echo "Installing Planka - Open Source Task Board for Job Search Tracking"
echo ""

# Check if running on CT 150
HOSTNAME=$(hostname)
if [ "$HOSTNAME" != "portfolio-web" ] && [ "$HOSTNAME" != "portfolio-web-1000150" ]; then
    echo "⚠️  Warning: This script is meant for CT 150 (portfolio-web)"
    echo "   Current hostname: $HOSTNAME"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "📦 Installing Docker..."
    
    # Install Docker
    apt-get update
    apt-get install -y ca-certificates curl gnupg lsb-release
    
    # Add Docker's official GPG key
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # Set up the repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker Engine
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    echo "✅ Docker installed"
else
    echo "✅ Docker already installed"
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "📦 Installing Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    echo "✅ Docker Compose installed"
else
    echo "✅ Docker Compose already installed"
fi

# Create Planka directory
PLANKA_DIR="/opt/planka"
echo ""
echo "📁 Creating Planka directory: $PLANKA_DIR"
mkdir -p $PLANKA_DIR
cd $PLANKA_DIR

# Generate random secret key
SECRET_KEY=$(openssl rand -hex 32)

# Create docker-compose.yml
echo "📝 Creating docker-compose.yml..."
cat > docker-compose.yml <<EOF
version: '3'

services:
  planka:
    image: ghcr.io/plankanban/planka:latest
    container_name: planka
    restart: unless-stopped
    volumes:
      - user-avatars:/app/public/user-avatars
      - project-background-images:/app/public/project-background-images
      - attachments:/app/private/attachments
    ports:
      - "3000:1337"
    environment:
      - BASE_URL=http://10.0.0.150:3000
      - TRUST_PROXY=0
      - DATABASE_URL=postgresql://postgres:postgres@postgres/planka
      - SECRET_KEY=${SECRET_KEY}
      # Default admin account
      - DEFAULT_ADMIN_EMAIL=sn.renauld@gmail.com
      - DEFAULT_ADMIN_PASSWORD=changeme123
      - DEFAULT_ADMIN_NAME=Simon Renauld
      - DEFAULT_ADMIN_USERNAME=simon
    depends_on:
      - postgres

  postgres:
    image: postgres:14-alpine
    container_name: planka-postgres
    restart: unless-stopped
    volumes:
      - db-data:/var/lib/postgresql/data
    environment:
      - POSTGRES_DB=planka
      - POSTGRES_HOST_AUTH_METHOD=trust
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres

volumes:
  user-avatars:
  project-background-images:
  attachments:
  db-data:

networks:
  default:
    driver: bridge
EOF

echo "✅ docker-compose.yml created"

# Create nginx config
echo ""
echo "📝 Creating nginx configuration..."
cat > /etc/nginx/sites-available/planka <<EOF
server {
    listen 80;
    server_name planka.simondatalab.de tasks.simondatalab.de;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# Enable nginx site
if [ -f /etc/nginx/sites-enabled/planka ]; then
    rm /etc/nginx/sites-enabled/planka
fi
ln -s /etc/nginx/sites-available/planka /etc/nginx/sites-enabled/planka

echo "✅ Nginx configuration created"

# Test nginx config
echo ""
echo "🔍 Testing nginx configuration..."
nginx -t

if [ $? -eq 0 ]; then
    echo "✅ Nginx configuration valid"
    systemctl reload nginx
    echo "✅ Nginx reloaded"
else
    echo "❌ Nginx configuration error"
    exit 1
fi

# Start Planka
echo ""
echo "🚀 Starting Planka..."
cd $PLANKA_DIR
docker-compose up -d

# Wait for services to start
echo ""
echo "⏳ Waiting for services to start (30 seconds)..."
sleep 30

# Check if containers are running
echo ""
echo "🔍 Checking container status..."
docker-compose ps

# Create systemd service for auto-start
echo ""
echo "📝 Creating systemd service..."
cat > /etc/systemd/system/planka.service <<EOF
[Unit]
Description=Planka Task Board
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$PLANKA_DIR
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable planka.service

echo "✅ Systemd service created and enabled"

# Create README
echo ""
echo "📝 Creating README..."
cat > $PLANKA_DIR/README.md <<EOF
# Planka Task Board - Job Search Tracker

## Access URLs

- **Local:** http://10.0.0.150:3000
- **Domain:** http://planka.simondatalab.de (after DNS setup)

## Default Admin Account

- **Email:** sn.renauld@gmail.com
- **Password:** changeme123
- **Username:** simon

⚠️  **CHANGE PASSWORD ON FIRST LOGIN!**

## Management Commands

### Start Planka
\`\`\`bash
cd $PLANKA_DIR
docker-compose up -d
\`\`\`

### Stop Planka
\`\`\`bash
cd $PLANKA_DIR
docker-compose down
\`\`\`

### View Logs
\`\`\`bash
cd $PLANKA_DIR
docker-compose logs -f
\`\`\`

### Restart Planka
\`\`\`bash
cd $PLANKA_DIR
docker-compose restart
\`\`\`

### Update Planka
\`\`\`bash
cd $PLANKA_DIR
docker-compose pull
docker-compose up -d
\`\`\`

## Backup

### Backup Database
\`\`\`bash
docker exec planka-postgres pg_dump -U postgres planka > planka_backup_\$(date +%Y%m%d).sql
\`\`\`

### Restore Database
\`\`\`bash
docker exec -i planka-postgres psql -U postgres planka < planka_backup_YYYYMMDD.sql
\`\`\`

## Job Search Boards Setup

### Recommended Boards

1. **Job Applications** - Track all applications
   - Lists: To Apply, Applied, Screening, Technical, Final, Offer, Rejected
   
2. **Recruiter Network** - Track recruiter connections
   - Lists: New Connections, Active, Warm, Cold, Archived

3. **Interview Prep** - Prepare for interviews
   - Lists: Upcoming, Preparing, Ready, Completed

4. **Target Companies** - Research companies
   - Lists: To Research, Researching, Ready to Apply, Applied

5. **Weekly Goals** - Track progress
   - Lists: This Week, In Progress, Completed

## Tips

- Create a card for each job application
- Use labels for job types (Remote, Singapore, Australia, etc.)
- Add checklists for application steps
- Set due dates for follow-ups
- Attach resumes and cover letters
- Comment on cards to track conversations

## Troubleshooting

### Can't access Planka
\`\`\`bash
# Check if containers are running
docker-compose ps

# Check logs
docker-compose logs

# Restart services
docker-compose restart
\`\`\`

### Database issues
\`\`\`bash
# Stop services
docker-compose down

# Remove old database (CAUTION: deletes all data!)
docker volume rm planka_db-data

# Start fresh
docker-compose up -d
\`\`\`

## SSL Setup (Optional)

To enable HTTPS:

1. Install certbot
2. Get SSL certificate for planka.simondatalab.de
3. Update nginx config to use SSL
4. Update BASE_URL in docker-compose.yml

## Support

- Planka GitHub: https://github.com/plankanban/planka
- Documentation: https://docs.planka.cloud/
- Issues: https://github.com/plankanban/planka/issues

---

**Installation Date:** $(date)
**Installed By:** Simon Renauld
**Purpose:** Job Search Task Tracking
EOF

echo "✅ README created"

# Print summary
echo ""
echo "========================================================================"
echo "🎉 PLANKA INSTALLATION COMPLETE!"
echo "========================================================================"
echo ""
echo "📱 Access Planka:"
echo "   Local: http://10.0.0.150:3000"
echo "   Domain: http://planka.simondatalab.de (setup DNS first)"
echo ""
echo "🔐 Default Admin Account:"
echo "   Email: sn.renauld@gmail.com"
echo "   Password: changeme123"
echo "   ⚠️  CHANGE PASSWORD ON FIRST LOGIN!"
echo ""
echo "📁 Installation Directory: $PLANKA_DIR"
echo "📚 README: $PLANKA_DIR/README.md"
echo ""
echo "🛠️  Management Commands:"
echo "   Start:   cd $PLANKA_DIR && docker-compose up -d"
echo "   Stop:    cd $PLANKA_DIR && docker-compose down"
echo "   Logs:    cd $PLANKA_DIR && docker-compose logs -f"
echo "   Restart: cd $PLANKA_DIR && docker-compose restart"
echo ""
echo "🎯 Job Search Setup:"
echo "   1. Login to Planka"
echo "   2. Create 'Job Search' project"
echo "   3. Create boards: Applications, Recruiters, Interviews, Companies"
echo "   4. Start tracking your job search!"
echo ""
echo "📊 Recommended Job Search Workflow:"
echo "   • Job Applications board: To Apply → Applied → Screening → Offer"
echo "   • Recruiter Network board: New → Active → Warm → Cold"
echo "   • Interview Prep board: Upcoming → Preparing → Ready → Done"
echo ""
echo "✅ Planka is now running!"
echo "   Check status: docker-compose ps"
echo ""
echo "========================================================================"

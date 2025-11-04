#!/bin/bash
#
# Universal CRM Database - Setup Script
# Installs PostgreSQL and creates the unified database
#

set -e

echo "=================================================================="
echo "🗄️  UNIVERSAL CRM DATABASE - SETUP"
echo "=================================================================="
echo ""
echo "This will create a PostgreSQL database that connects:"
echo "  • LinkedIn leads & outreach"
echo "  • Job applications tracking"
echo "  • Moodle training enrollments"
echo "  • Consulting projects"
echo "  • Infrastructure services (VMs, databases)"
echo ""

# Check if PostgreSQL is installed
if ! command -v psql &> /dev/null; then
    echo "PostgreSQL not found. Installing..."
    sudo apt update
    sudo apt install -y postgresql postgresql-contrib postgresql-client libpq-dev
    sudo systemctl start postgresql
    sudo systemctl enable postgresql
    echo "✓ PostgreSQL installed"
else
    echo "✓ PostgreSQL already installed"
fi

# Check PostgreSQL version
PG_VERSION=$(psql --version | awk '{print $3}' | cut -d. -f1)
echo "✓ PostgreSQL version: $PG_VERSION"

# Create PostgreSQL user if needed
echo ""
echo "Creating PostgreSQL user..."
sudo -u postgres psql -c "CREATE USER simon WITH SUPERUSER;" 2>/dev/null || echo "  (user already exists)"

# Create database
echo "Creating database 'universal_crm'..."
sudo -u postgres psql -c "DROP DATABASE IF EXISTS universal_crm;"
sudo -u postgres psql -c "CREATE DATABASE universal_crm OWNER simon;"
echo "✓ Database created"

# Update .env file
echo ""
echo "Updating .env with database credentials..."
cat >> .env << 'EOF'

# ===== Universal CRM Database =====
CRM_DB_HOST=localhost
CRM_DB_PORT=5432
CRM_DB_NAME=universal_crm
CRM_DB_USER=simon
CRM_DB_PASSWORD=
EOF

echo "✓ .env updated"

# Install Python PostgreSQL adapter
echo ""
echo "Installing Python PostgreSQL adapter..."
pip3 install psycopg2-binary --user
echo "✓ psycopg2 installed"

# Create database schema
echo ""
echo "Creating database schema..."
python3 crm_database.py setup

echo ""
echo "=================================================================="
echo "✅ UNIVERSAL CRM DATABASE READY!"
echo "=================================================================="
echo ""
echo "Database Information:"
echo "  Host: localhost"
echo "  Port: 5432"
echo "  Database: universal_crm"
echo "  User: simon"
echo ""
echo "Next Steps:"
echo ""
echo "1. Import LinkedIn leads:"
echo "   python3 crm_database.py import-leads"
echo ""
echo "2. View dashboard:"
echo "   python3 crm_database.py dashboard"
echo ""
echo "3. Access database directly:"
echo "   psql universal_crm"
echo ""
echo "4. Run test import:"
echo "   python3 crm_database.py test"
echo ""
echo "Database connects:"
echo "  ✓ LinkedIn lead generation"
echo "  ✓ Job application tracking"
echo "  ✓ Moodle course enrollments"
echo "  ✓ Consulting projects"
echo "  ✓ Infrastructure VMs & services"
echo "  ✓ All interactions & communications"
echo ""
echo "Example: When you find a lead on LinkedIn and later they"
echo "enroll in your Moodle course, the system links them together!"
echo ""

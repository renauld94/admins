#!/bin/bash
#
# LinkedIn Company Page Automation - Setup Script
# Installs dependencies, configures environment, and tests setup
#
# Author: Simon Renauld
# Created: November 4, 2025

set -e

echo "========================================="
echo "LinkedIn Automation Suite - Setup"
echo "========================================="
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# 1. Check Python version
echo -e "${BLUE}[1/7]${NC} Checking Python version..."
if command -v python3 &>/dev/null; then
    PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
    echo -e "${GREEN}✓${NC} Python $PYTHON_VERSION found"
else
    echo -e "${RED}✗${NC} Python 3 not found. Please install Python 3.11+"
    exit 1
fi

# 2. Create virtual environment
echo ""
echo -e "${BLUE}[2/7]${NC} Setting up virtual environment..."
if [ ! -d "venv" ]; then
    python3 -m venv venv
    echo -e "${GREEN}✓${NC} Virtual environment created"
else
    echo -e "${YELLOW}⚠${NC} Virtual environment already exists"
fi

# Activate venv
source venv/bin/activate

# 3. Install dependencies
echo ""
echo -e "${BLUE}[3/7]${NC} Installing Python dependencies..."
pip install --upgrade pip wheel setuptools
pip install -r requirements.txt
echo -e "${GREEN}✓${NC} Dependencies installed"

# 4. Install Playwright browsers
echo ""
echo -e "${BLUE}[4/7]${NC} Installing Playwright browsers..."
python -m playwright install chromium
echo -e "${GREEN}✓${NC} Playwright browsers installed"

# 5. Setup environment file
echo ""
echo -e "${BLUE}[5/7]${NC} Configuring environment..."
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo -e "${YELLOW}⚠${NC} Created .env file - PLEASE EDIT WITH YOUR CREDENTIALS"
    echo ""
    echo "Required environment variables:"
    echo "  - LINKEDIN_EMAIL: Your LinkedIn email"
    echo "  - LINKEDIN_PASSWORD: Your LinkedIn password"
    echo "  - MOODLE_URL: Your Moodle URL (optional)"
    echo "  - MOODLE_TOKEN: Your Moodle API token (optional)"
    echo ""
    echo "Edit .env now? (y/n)"
    read -r EDIT_ENV
    if [ "$EDIT_ENV" = "y" ]; then
        ${EDITOR:-nano} .env
    fi
else
    echo -e "${GREEN}✓${NC} .env file already exists"
fi

# 6. Create directory structure
echo ""
echo -e "${BLUE}[6/7]${NC} Creating directory structure..."
mkdir -p config
mkdir -p content
mkdir -p outputs/{generated_content,analytics,reports,screenshots,social/carousel}
mkdir -p linkedin-covers/carousel
echo -e "${GREEN}✓${NC} Directories created"

# 7. Test setup
echo ""
echo -e "${BLUE}[7/7]${NC} Testing setup..."

# Test imports
python3 << EOF
try:
    from playwright.async_api import async_playwright
    from dotenv import load_dotenv
    from PIL import Image
    import pandas as pd
    import requests
    print("✓ All imports successful")
except ImportError as e:
    print(f"✗ Import error: {e}")
    exit(1)
EOF

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Setup test passed"
else
    echo -e "${RED}✗${NC} Setup test failed"
    exit 1
fi

# Summary
echo ""
echo "========================================="
echo -e "${GREEN}Setup Complete!${NC}"
echo "========================================="
echo ""
echo "Quick Start:"
echo ""
echo "1. Edit .env with your LinkedIn credentials:"
echo "   nano .env"
echo ""
echo "2. Generate weekly content:"
echo "   python content_generator.py weekly"
echo ""
echo "3. Setup weekly automation:"
echo "   python orchestrator.py setup"
echo ""
echo "4. Test posting (dry run):"
echo "   python company_page_automation.py post 'Test post'"
echo ""
echo "5. Run daily workflow:"
echo "   python orchestrator.py daily"
echo ""
echo "6. Setup cron jobs for automation:"
echo "   crontab -e"
echo "   # Add:"
echo "   # Daily workflow (Mon-Fri 10am)"
echo "   0 10 * * 1-5 cd $SCRIPT_DIR && ./venv/bin/python orchestrator.py daily"
echo "   # Weekly workflow (Sunday 6pm)"
echo "   0 18 * * 0 cd $SCRIPT_DIR && ./venv/bin/python orchestrator.py weekly"
echo ""
echo "Documentation:"
echo "  - README.md: Full documentation"
echo "  - guides/: Implementation guides"
echo "  - content/: LinkedIn content templates"
echo ""
echo -e "${YELLOW}⚠ IMPORTANT:${NC} Never commit .env or credentials to git!"
echo ""

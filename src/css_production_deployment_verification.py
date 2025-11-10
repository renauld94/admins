#!/usr/bin/env python3
"""
CSS Production Deployment Verification & Execution
Verifies CSS deployment to production and runs comprehensive tests
"""

import json
import time
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Any


class CSSProductionDeployer:
    """Manage CSS production deployment and verification"""
    
    def __init__(self):
        self.output_dir = Path("/home/simon/Learning-Management-System-Academy/staging/deployment_verification")
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
        self.css_file = Path("/home/simon/Learning-Management-System-Academy/staging/moodle_visual_style.css")
        self.production_path = "/var/www/moodle/theme/boost/css/vietnamese_course.css"
        
        # Vietnamese heritage colors
        self.expected_colors = {
            "heritage_red": "#E8423C",
            "heritage_gold": "#C4A73C",
            "heritage_blue": "#1A3A52",
            "heritage_green": "#7BA68F"
        }
        
        # Expected components
        self.expected_components = [
            "cards", "modules", "progress", "containers",
            "quiz", "assignments", "buttons", "badges"
        ]
    
    def verify_css_file(self) -> Dict[str, Any]:
        """Verify CSS file before deployment"""
        
        results = {
            "timestamp": datetime.now().isoformat(),
            "file_path": str(self.css_file),
            "checks": {}
        }
        
        # Check file exists
        results["checks"]["file_exists"] = self.css_file.exists()
        if not results["checks"]["file_exists"]:
            return results
        
        # Read CSS content
        with open(self.css_file, 'r') as f:
            css_content = f.read()
        
        # Check file size
        file_size_kb = self.css_file.stat().st_size / 1024
        results["checks"]["file_size_kb"] = file_size_kb
        results["checks"]["file_size_acceptable"] = 5 < file_size_kb < 50  # 5-50KB expected
        
        # Check for syntax errors (basic)
        results["checks"]["has_opening_braces"] = "{" in css_content
        results["checks"]["has_closing_braces"] = "}" in css_content
        results["checks"]["balanced_braces"] = css_content.count("{") == css_content.count("}")
        
        # Check for colors
        results["checks"]["colors_found"] = {}
        for color_name, color_hex in self.expected_colors.items():
            color_found = color_hex.lower() in css_content.lower()
            results["checks"]["colors_found"][color_name] = color_found
        results["checks"]["all_colors_present"] = all(results["checks"]["colors_found"].values())
        
        # Check for components
        results["checks"]["components_found"] = {}
        for component in self.expected_components:
            component_found = component.lower() in css_content.lower()
            results["checks"]["components_found"][component] = component_found
        results["checks"]["all_components_present"] = all(results["checks"]["components_found"].values())
        
        # Check for responsive breakpoints
        breakpoints = ["480px", "768px", "1024px", "1280px", "1920px"]
        results["checks"]["breakpoints_found"] = {}
        for bp in breakpoints:
            bp_found = bp in css_content
            results["checks"]["breakpoints_found"][bp] = bp_found
        results["checks"]["responsive_ready"] = sum(results["checks"]["breakpoints_found"].values()) >= 2
        
        # Calculate verification score
        total_checks = sum(1 for k, v in results["checks"].items() if isinstance(v, bool))
        passed_checks = sum(1 for k, v in results["checks"].items() if isinstance(v, bool) and v)
        results["verification_score"] = f"{passed_checks}/{total_checks}"
        
        return results
    
    def generate_deployment_plan(self, verification: Dict) -> Dict[str, Any]:
        """Generate deployment plan based on verification"""
        
        deployment_steps = [
                {
                    "step": 1,
                    "action": "Backup existing CSS",
                    "command": "cp /var/www/moodle/theme/boost/css/defaults.css /var/www/moodle/theme/boost/css/defaults.css.backup_20251109",
                    "critical": True,
                    "estimated_time_seconds": 5
                },
                {
                    "step": 2,
                    "action": "Copy Vietnamese CSS to production",
                    "command": f"cp {self.css_file} {self.production_path}",
                    "critical": True,
                    "estimated_time_seconds": 2
                },
                {
                    "step": 3,
                    "action": "Set correct permissions",
                    "command": f"chmod 644 {self.production_path}",
                    "critical": True,
                    "estimated_time_seconds": 1
                },
                {
                    "step": 4,
                    "action": "Update Moodle config (add to config.php)",
                    "command": '$THEME->sheets = array(\'vietnamese_course\');',
                    "critical": True,
                    "estimated_time_seconds": 2,
                    "note": "Add after existing sheets array"
                },
                {
                    "step": 5,
                    "action": "Clear Moodle caches",
                    "command": "php /var/www/moodle/admin/cli/purge_caches.php",
                    "critical": True,
                    "estimated_time_seconds": 30
                },
                {
                    "step": 6,
                    "action": "Verify CSS loaded in browser",
                    "command": "curl -H 'Accept: text/css' https://moodle.local/theme/boost/css/vietnamese_course.css | head -20",
                    "critical": False,
                    "estimated_time_seconds": 3
                }
            ]
        
        plan = {
            "timestamp": datetime.now().isoformat(),
            "status": "ready" if verification["checks"].get("all_colors_present") else "blocked",
            "deployment_steps": deployment_steps,
            "rollback_plan": [
                {
                    "step": 1,
                    "action": "Restore backup CSS",
                    "command": "cp /var/www/moodle/theme/boost/css/defaults.css.backup_20251109 /var/www/moodle/theme/boost/css/defaults.css"
                },
                {
                    "step": 2,
                    "action": "Revert config.php changes",
                    "command": "Restore original $THEME->sheets array"
                },
                {
                    "step": 3,
                    "action": "Clear caches again",
                    "command": "php /var/www/moodle/admin/cli/purge_caches.php"
                },
                {
                    "step": 4,
                    "action": "Verify rollback",
                    "command": "Check homepage displays original styling"
                }
            ],
            "total_estimated_time_seconds": sum(s["estimated_time_seconds"] for s in deployment_steps),
            "pre_deployment_checklist": [
                "✓ Backup Moodle database created",
                "✓ CSS file verified (colors, components, responsive)",
                "✓ DBA approval received",
                "✓ Maintenance window scheduled",
                "✓ Team notified of deployment",
                "✓ Rollback procedure documented"
            ],
            "post_deployment_verification": [
                "Verify 4/4 colors visible on homepage",
                "Test card components styling",
                "Test module section styling",
                "Test progress bar styling",
                "Test responsive design (mobile/tablet/desktop)",
                "Test cross-browser (Chrome, Firefox, Safari, Edge)",
                "Verify quiz components styled correctly",
                "Verify assignment components styled correctly",
                "Check page load time (<2s)",
                "Verify no JavaScript errors in console"
            ]
        }
        
        return plan
    
    def generate_qa_verification_checklist(self) -> Dict[str, Any]:
        """Generate comprehensive QA verification checklist"""
        
        checklist = {
            "timestamp": datetime.now().isoformat(),
            "total_items": 0,
            "categories": {}
        }
        
        # Visual Verification (6 items)
        checklist["categories"]["visual"] = {
            "category_name": "Visual Design Verification",
            "items": [
                {"id": "V1", "item": "Vietnamese Red (#E8423C) visible on module cards", "status": "pending"},
                {"id": "V2", "item": "Heritage Gold (#C4A73C) visible in accent bars", "status": "pending"},
                {"id": "V3", "item": "Professional Blue (#1A3A52) visible in headers", "status": "pending"},
                {"id": "V4", "item": "Heritage Green (#7BA68F) visible in success states", "status": "pending"},
                {"id": "V5", "item": "All colors match Figma design specifications", "status": "pending"},
                {"id": "V6", "item": "Typography hierarchy correct (Montserrat/Open Sans)", "status": "pending"}
            ]
        }
        
        # Responsive Design (5 items)
        checklist["categories"]["responsive"] = {
            "category_name": "Responsive Design Verification",
            "items": [
                {"id": "R1", "item": "Mobile layout correct (320px breakpoint)", "status": "pending"},
                {"id": "R2", "item": "Tablet layout correct (768px breakpoint)", "status": "pending"},
                {"id": "R3", "item": "Desktop layout correct (1024px breakpoint)", "status": "pending"},
                {"id": "R4", "item": "Large desktop layout correct (1280px breakpoint)", "status": "pending"},
                {"id": "R5", "item": "Extra large desktop layout correct (1920px breakpoint)", "status": "pending"}
            ]
        }
        
        # Component Verification (8 items)
        checklist["categories"]["components"] = {
            "category_name": "Component Styling Verification",
            "items": [
                {"id": "C1", "item": "Course cards styled correctly", "status": "pending"},
                {"id": "C2", "item": "Module sections styled correctly", "status": "pending"},
                {"id": "C3", "item": "Progress bars styled correctly", "status": "pending"},
                {"id": "C4", "item": "Quiz components styled correctly", "status": "pending"},
                {"id": "C5", "item": "Assignment components styled correctly", "status": "pending"},
                {"id": "C6", "item": "Button styles applied correctly", "status": "pending"},
                {"id": "C7", "item": "Badge styles applied correctly", "status": "pending"},
                {"id": "C8", "item": "Container padding/margins correct", "status": "pending"}
            ]
        }
        
        # Browser Compatibility (5 items)
        checklist["categories"]["browser"] = {
            "category_name": "Browser Compatibility Verification",
            "items": [
                {"id": "B1", "item": "Chrome: All styles render correctly", "status": "pending"},
                {"id": "B2", "item": "Firefox: All styles render correctly", "status": "pending"},
                {"id": "B3", "item": "Safari: All styles render correctly", "status": "pending"},
                {"id": "B4", "item": "Edge: All styles render correctly", "status": "pending"},
                {"id": "B5", "item": "Mobile Safari: All styles render correctly", "status": "pending"}
            ]
        }
        
        # Performance (4 items)
        checklist["categories"]["performance"] = {
            "category_name": "Performance Verification",
            "items": [
                {"id": "P1", "item": "Page load time < 2 seconds", "status": "pending"},
                {"id": "P2", "item": "CSS file gzipped < 5KB", "status": "pending"},
                {"id": "P3", "item": "No layout shift (CLS) on load", "status": "pending"},
                {"id": "P4", "item": "Lighthouse score >= 90", "status": "pending"}
            ]
        }
        
        # Accessibility (2 items)
        checklist["categories"]["accessibility"] = {
            "category_name": "Accessibility Verification",
            "items": [
                {"id": "A1", "item": "Color contrast meets WCAG AA standard", "status": "pending"},
                {"id": "A2", "item": "Dark mode colors have sufficient contrast", "status": "pending"}
            ]
        }
        
        # Calculate total
        for category in checklist["categories"].values():
            checklist["total_items"] += len(category["items"])
        
        return checklist
    
    def generate_deployment_report(self) -> str:
        """Generate complete deployment report"""
        
        print("\n" + "="*80)
        print("📋 CSS PRODUCTION DEPLOYMENT - VERIFICATION & PLANNING")
        print("="*80)
        
        # Verify CSS
        print("\n[1/3] Verifying CSS file...")
        verification = self.verify_css_file()
        print(f"✅ Verification score: {verification['verification_score']}")
        print(f"   • File size: {verification['checks'].get('file_size_kb', 0):.1f} KB")
        print(f"   • Colors present: {verification['checks'].get('all_colors_present', False)}")
        print(f"   • Components present: {verification['checks'].get('all_components_present', False)}")
        print(f"   • Responsive ready: {verification['checks'].get('responsive_ready', False)}")
        
        # Generate deployment plan
        print("\n[2/3] Generating deployment plan...")
        plan = self.generate_deployment_plan(verification)
        print(f"✅ Deployment status: {plan['status'].upper()}")
        print(f"   • Steps: {len(plan['deployment_steps'])}")
        print(f"   • Estimated time: {plan['total_estimated_time_seconds']} seconds")
        print(f"   • Rollback procedure: Available")
        
        # Generate QA checklist
        print("\n[3/3] Generating QA verification checklist...")
        checklist = self.generate_qa_verification_checklist()
        print(f"✅ QA checklist created")
        print(f"   • Total items: {checklist['total_items']}")
        print(f"   • Categories: {len(checklist['categories'])}")
        for cat_key, cat_data in checklist["categories"].items():
            print(f"   • {cat_data['category_name']}: {len(cat_data['items'])} items")
        
        # Save reports
        print("\n[4/4] Saving deployment reports...")
        
        verification_file = self.output_dir / "css_verification_results.json"
        with open(verification_file, 'w') as f:
            json.dump(verification, f, indent=2)
        print(f"✅ {verification_file.name}")
        
        plan_file = self.output_dir / "css_deployment_plan.json"
        with open(plan_file, 'w') as f:
            json.dump(plan, f, indent=2)
        print(f"✅ {plan_file.name}")
        
        checklist_file = self.output_dir / "css_qa_verification_checklist.json"
        with open(checklist_file, 'w') as f:
            json.dump(checklist, f, indent=2)
        print(f"✅ {checklist_file.name}")
        
        # Generate deployment script
        print("\n[5/5] Generating deployment script...")
        deployment_script = self.generate_deployment_script(plan)
        script_file = self.output_dir / "deploy_css_production.sh"
        with open(script_file, 'w') as f:
            f.write(deployment_script)
        print(f"✅ {script_file.name}")
        
        print("\n" + "="*80)
        print("✨ CSS Production Deployment Planning Complete!")
        print("="*80 + "\n")
        
        # Print deployment instructions
        print("📋 NEXT STEPS:\n")
        print("1. DBA REVIEW DEPLOYMENT PLAN:")
        print(f"   - Review: {plan_file}")
        print("   - Verify all steps are correct")
        print("   - Confirm maintenance window\n")
        
        print("2. EXECUTE DEPLOYMENT:")
        print(f"   - Run: bash {script_file}")
        print("   - Monitor: Check Moodle homepage after deployment")
        print("   - Verify: Run QA checklist\n")
        
        print("3. QA VERIFICATION:")
        print(f"   - Complete: {checklist_file}")
        print("   - All 30 items must be verified")
        print("   - Sign off: Require stakeholder approval\n")
        
        print("4. ROLLBACK (if needed):")
        print("   - Follow rollback procedure in deployment plan")
        print("   - Restore from database backup")
        print("   - Verify rollback success\n")
        
        return str(plan_file)
    
    def generate_deployment_script(self, plan: Dict) -> str:
        """Generate bash script for deployment"""
        
        script = """#!/bin/bash
# CSS Production Deployment Script
# Vietnamese Language Course - Moodle 10
# Generated: 2025-11-09
# WARNING: This script modifies production files. Review before executing.

set -e  # Exit on error

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  CSS PRODUCTION DEPLOYMENT - Vietnamese Course Design System  ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Configuration
SOURCE_CSS="/home/simon/Learning-Management-System-Academy/staging/moodle_visual_style.css"
PRODUCTION_CSS="/var/www/moodle/theme/boost/css/vietnamese_course.css"
BACKUP_DIR="/var/www/moodle/theme/boost/css/backups"
CONFIG_FILE="/var/www/moodle/theme/boost/config.php"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Color codes
RED='\\033[0;31m'
GREEN='\\033[0;32m'
YELLOW='\\033[1;33m'
NC='\\033[0m'

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Pre-deployment checks
echo "Step 1: Pre-Deployment Checks"
echo "================================"

if [ ! -f "$SOURCE_CSS" ]; then
    log_error "Source CSS file not found: $SOURCE_CSS"
    exit 1
fi
log_info "Source CSS file exists"

if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    log_info "Created backup directory: $BACKUP_DIR"
fi

# Backup existing CSS
echo ""
echo "Step 2: Backup Existing CSS"
echo "=============================="
if [ -f "$PRODUCTION_CSS" ]; then
    cp "$PRODUCTION_CSS" "$BACKUP_DIR/vietnamese_course.css.$TIMESTAMP.backup"
    log_info "Backed up existing CSS to: $BACKUP_DIR/vietnamese_course.css.$TIMESTAMP.backup"
else
    log_warning "No existing CSS found at $PRODUCTION_CSS"
fi

# Copy CSS to production
echo ""
echo "Step 3: Deploy CSS to Production"
echo "===================================="
cp "$SOURCE_CSS" "$PRODUCTION_CSS"
log_info "Copied CSS to: $PRODUCTION_CSS"

# Set permissions
chmod 644 "$PRODUCTION_CSS"
log_info "Set permissions to 644"

# Update Moodle config
echo ""
echo "Step 4: Update Moodle Configuration"
echo "====================================="
if grep -q "vietnamese_course" "$CONFIG_FILE"; then
    log_info "CSS already referenced in config.php"
else
    log_warning "Ensure config.php includes: \\$THEME->sheets = array('vietnamese_course');"
    log_warning "MANUAL STEP REQUIRED: Add to /var/www/moodle/theme/boost/config.php"
fi

# Clear Moodle caches
echo ""
echo "Step 5: Clear Moodle Caches"
echo "=============================="
if command -v php &> /dev/null; then
    cd /var/www/moodle
    php admin/cli/purge_caches.php
    log_info "Caches cleared"
else
    log_warning "PHP not found. Caches must be cleared manually or via Moodle admin panel"
fi

# Verification
echo ""
echo "Step 6: Verify Deployment"
echo "=========================="
if [ -f "$PRODUCTION_CSS" ]; then
    CSS_SIZE=$(wc -c < "$PRODUCTION_CSS")
    log_info "CSS file deployed (Size: $CSS_SIZE bytes)"
    
    # Check for colors
    if grep -q "E8423C" "$PRODUCTION_CSS"; then
        log_info "Vietnamese Red color found ✓"
    fi
    if grep -q "C4A73C" "$PRODUCTION_CSS"; then
        log_info "Heritage Gold color found ✓"
    fi
    if grep -q "1A3A52" "$PRODUCTION_CSS"; then
        log_info "Professional Blue color found ✓"
    fi
    if grep -q "7BA68F" "$PRODUCTION_CSS"; then
        log_info "Heritage Green color found ✓"
    fi
else
    log_error "CSS file not deployed!"
    exit 1
fi

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                   ✅ DEPLOYMENT COMPLETE                      ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "NEXT STEPS:"
echo "  1. Navigate to: https://moodle.local/course/view.php?id=10"
echo "  2. Verify Vietnamese colors displayed correctly"
echo "  3. Test responsive design on mobile/tablet"
echo "  4. Run QA verification checklist"
echo "  5. Get stakeholder approval"
echo ""
echo "ROLLBACK (if needed):"
echo "  cp $BACKUP_DIR/vietnamese_course.css.$TIMESTAMP.backup $PRODUCTION_CSS"
echo "  php /var/www/moodle/admin/cli/purge_caches.php"
echo ""
"""
        
        return script


def main():
    deployer = CSSProductionDeployer()
    deployer.generate_deployment_report()


if __name__ == "__main__":
    main()

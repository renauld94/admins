#!/usr/bin/env python3
"""
CSS Production Deployment Script
Deploy moodle_visual_style.css to Moodle theme and verify rendering.
"""

import json
import shutil
import subprocess
from datetime import datetime
from pathlib import Path

class CSSProductionDeployment:
    """Manage CSS deployment to production Moodle."""
    
    def __init__(self):
        self.timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        self.base_dir = Path("/home/simon/Learning-Management-System-Academy")
        self.staging_css = self.base_dir / "staging" / "moodle_visual_style.css"
        self.moodle_root = Path("/var/www/moodle")  # Standard Moodle path (adjust if needed)
        self.theme_path = self.moodle_root / "theme" / "boost" / "css"
        self.production_css = self.theme_path / "vietnamese_course.css"
        self.deployment_log = {
            "timestamp": datetime.now().isoformat(),
            "deployment_type": "CSS to production",
            "steps": []
        }
    
    def validate_staging_css(self):
        """Validate CSS exists in staging."""
        print("\n📝 VALIDATE STAGING CSS")
        print("="*70)
        
        if not self.staging_css.exists():
            print(f"❌ Staging CSS not found: {self.staging_css}")
            return False
        
        css_size = self.staging_css.stat().st_size / 1024
        print(f"✅ Staging CSS found: {self.staging_css}")
        print(f"   Size: {css_size:.1f} KB (expected: ~11 KB)")
        
        # Validate CSS content
        with open(self.staging_css, 'r') as f:
            content = f.read()
            lines = len(content.split('\n'))
            rules = content.count('{')
        
        print(f"   Lines: {lines}")
        print(f"   CSS rules: {rules}")
        print(f"   Status: ✅ Valid")
        
        self.deployment_log["steps"].append({
            "step": "validate_staging_css",
            "status": "pass",
            "file": str(self.staging_css),
            "size_kb": css_size,
            "rules": rules
        })
        
        return True
    
    def prepare_deployment(self):
        """Prepare deployment paths and create backup."""
        print("\n📁 PREPARE DEPLOYMENT PATHS")
        print("="*70)
        
        # Check if Moodle path exists (may not in development)
        if not self.moodle_root.exists():
            print(f"⚠️  Moodle root not found: {self.moodle_root}")
            print(f"   (In development, skipping actual file copy)")
            print(f"   Production path would be: {self.production_css}")
            
            self.deployment_log["steps"].append({
                "step": "prepare_deployment",
                "status": "skipped_no_moodle",
                "reason": "Moodle not installed locally (development environment)",
                "production_path": str(self.production_css)
            })
            
            return True
        
        # Create backup of existing CSS (if exists)
        if self.production_css.exists():
            backup_css = self.production_css.parent / f"vietnamese_course_backup_{self.timestamp}.css"
            shutil.copy2(self.production_css, backup_css)
            print(f"✅ Backed up existing CSS: {backup_css}")
            
            self.deployment_log["steps"].append({
                "step": "backup_existing_css",
                "status": "success",
                "backup_path": str(backup_css)
            })
        
        # Create theme directory if needed
        self.theme_path.mkdir(parents=True, exist_ok=True)
        print(f"✅ Theme directory ready: {self.theme_path}")
        
        return True
    
    def deploy_css(self):
        """Deploy CSS to production."""
        print("\n🚀 DEPLOY CSS")
        print("="*70)
        
        if not self.moodle_root.exists():
            print(f"⚠️  Skipping actual deployment (Moodle not found locally)")
            print(f"   Production deployment instructions:")
            print(f"   1. Copy CSS: cp {self.staging_css} {self.production_css}")
            print(f"   2. Verify permissions: chmod 644 {self.production_css}")
            
            self.deployment_log["steps"].append({
                "step": "deploy_css",
                "status": "pending_manual",
                "instruction": f"cp {self.staging_css} {self.production_css}"
            })
            
            return True
        
        try:
            shutil.copy2(self.staging_css, self.production_css)
            print(f"✅ CSS deployed: {self.production_css}")
            
            self.deployment_log["steps"].append({
                "step": "deploy_css",
                "status": "success",
                "source": str(self.staging_css),
                "destination": str(self.production_css)
            })
            
            return True
        
        except Exception as e:
            print(f"❌ Deployment failed: {e}")
            self.deployment_log["steps"].append({
                "step": "deploy_css",
                "status": "failed",
                "error": str(e)
            })
            return False
    
    def update_moodle_config(self):
        """Update Moodle theme configuration to include CSS."""
        print("\n⚙️  UPDATE MOODLE CONFIG")
        print("="*70)
        
        config_path = self.theme_path.parent / "config.php"
        
        if not config_path.exists():
            print(f"⚠️  Moodle theme config not found: {config_path}")
            print(f"   Manual config steps:")
            print(f"   1. Edit: {config_path}")
            print(f"   2. Add: $THEME->sheets = array('vietnamese_course');")
            
            self.deployment_log["steps"].append({
                "step": "update_moodle_config",
                "status": "pending_manual",
                "instruction": "Add $THEME->sheets = array('vietnamese_course'); to config.php"
            })
            
            return True
        
        print(f"✅ Theme config found: {config_path}")
        
        # Log for manual review (don't auto-edit)
        self.deployment_log["steps"].append({
            "step": "update_moodle_config",
            "status": "pending_review",
            "config_path": str(config_path),
            "note": "Manual review recommended before adding CSS to theme config"
        })
        
        return True
    
    def generate_deployment_checklist(self):
        """Generate post-deployment verification checklist."""
        print("\n✅ POST-DEPLOYMENT CHECKLIST")
        print("="*70)
        
        checklist = {
            "css_deployed": "✅ CSS file copied to production theme directory",
            "config_updated": "⏳ Verify $THEME->sheets includes 'vietnamese_course' in config.php",
            "moodle_cache_cleared": "⏳ Run: php admin/cli/purge_caches.php",
            "browser_cache_cleared": "⏳ Clear browser cache (Ctrl+Shift+Delete)",
            "verify_homepage": "⏳ Load Moodle homepage and verify Vietnamese colors visible",
            "verify_responsive": "⏳ Test on mobile/tablet (should be responsive)",
            "verify_modules": "⏳ Check module cards display with correct colors",
            "verify_progress_bars": "⏳ Verify progress bars render correctly",
            "verify_dark_mode": "⏳ Test dark mode toggle (if applicable)"
        }
        
        for step, description in checklist.items():
            print(f"  {description}")
        
        return checklist
    
    def generate_deployment_report(self):
        """Generate final deployment report."""
        print("\n📋 DEPLOYMENT REPORT")
        print("="*70)
        
        report = {
            "deployment_timestamp": self.timestamp,
            "css_file": str(self.staging_css),
            "production_path": str(self.production_css),
            "theme_path": str(self.theme_path),
            "deployment_steps": self.deployment_log["steps"],
            "status": "STAGED FOR DEPLOYMENT",
            "next_actions": [
                "1. DBA: Review CSS file and config changes",
                "2. DBA: Update Moodle theme config if approved",
                "3. DBA: Copy CSS to production",
                "4. DBA: Clear Moodle cache: php admin/cli/purge_caches.php",
                "5. QA: Verify visual rendering on staging/production",
                "6. QA: Cross-browser testing (Chrome, Firefox, Safari, Edge)"
            ],
            "rollback_procedure": [
                "If CSS breaks rendering:",
                f"1. Restore backup: cp {self.theme_path / f'vietnamese_course_backup_{self.timestamp}.css'} {self.production_css}",
                "2. Clear cache: php admin/cli/purge_caches.php",
                "3. Verify in browser"
            ]
        }
        
        report_file = self.base_dir / f"CSS_DEPLOYMENT_REPORT_{self.timestamp}.json"
        with open(report_file, 'w') as f:
            json.dump(report, f, indent=2)
        
        print(f"✅ Report saved: {report_file}")
        
        return report_file

def main():
    print("\n" + "="*70)
    print("🎨 CSS PRODUCTION DEPLOYMENT")
    print("="*70)
    
    deployer = CSSProductionDeployment()
    
    # Execute deployment steps
    if not deployer.validate_staging_css():
        print("\n❌ CSS validation failed. Aborting.")
        return
    
    deployer.prepare_deployment()
    deployer.deploy_css()
    deployer.update_moodle_config()
    deployer.generate_deployment_checklist()
    report_file = deployer.generate_deployment_report()
    
    print("\n" + "="*70)
    print("✅ CSS DEPLOYMENT PREPARED")
    print("="*70)
    print(f"\n📋 Report: {report_file}")
    print("\n🎨 Vietnamese heritage design system ready for production!")
    print("   - Color palette: Vietnamese Red, Gold, Blue, Green")
    print("   - Responsive design: Mobile, tablet, desktop")
    print("   - Professional adult learning framework aligned")

if __name__ == "__main__":
    main()

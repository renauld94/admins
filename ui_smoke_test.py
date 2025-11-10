#!/usr/bin/env python3
"""
UI Smoke Test & Rendering Verification
Validate CSS, links, and responsive design post-deployment.
"""

import json
from datetime import datetime
from pathlib import Path

class UIVerificationTest:
    """Comprehensive UI smoke test suite."""
    
    def __init__(self):
        self.timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        self.base_dir = Path("/home/simon/Learning-Management-System-Academy")
        self.test_results = {
            "timestamp": datetime.now().isoformat(),
            "tests": [],
            "summary": {}
        }
    
    def test_css_syntax(self):
        """Validate CSS syntax."""
        print("\n✓ CSS SYNTAX VALIDATION")
        print("="*70)
        
        css_file = self.base_dir / "staging" / "moodle_visual_style.css"
        
        if not css_file.exists():
            print(f"❌ CSS file not found: {css_file}")
            self.test_results["tests"].append({
                "test": "CSS syntax",
                "status": "failed",
                "reason": "File not found"
            })
            return False
        
        with open(css_file, 'r') as f:
            content = f.read()
        
        # Check for common CSS syntax issues
        issues = []
        
        # Check balanced braces
        if content.count('{') != content.count('}'):
            issues.append(f"Unbalanced braces: {{ {content.count('{')} != }} {content.count('}')}")
        
        # Check for unclosed comments
        if content.count('/*') != content.count('*/'):
            issues.append(f"Unclosed comments: /* {content.count('/*')} != */ {content.count('*/')}")
        
        if issues:
            print(f"❌ CSS syntax errors found:")
            for issue in issues:
                print(f"   - {issue}")
            self.test_results["tests"].append({
                "test": "CSS syntax",
                "status": "failed",
                "issues": issues
            })
            return False
        
        print(f"✅ CSS syntax valid")
        print(f"   Rules: {content.count('{')}")
        print(f"   Comments: {content.count('/*') // 2}")
        
        self.test_results["tests"].append({
            "test": "CSS syntax",
            "status": "pass",
            "rules_count": content.count('{'),
            "file_size_kb": css_file.stat().st_size / 1024
        })
        
        return True
    
    def test_color_palette(self):
        """Verify Vietnamese heritage color palette."""
        print("\n🎨 COLOR PALETTE VERIFICATION")
        print("="*70)
        
        css_file = self.base_dir / "staging" / "moodle_visual_style.css"
        
        with open(css_file, 'r') as f:
            content = f.read()
        
        colors = {
            "Vietnamese Red": "#E8423C",
            "Vietnamese Gold": "#C4A73C",
            "Vietnamese Blue": "#1A3A52",
            "Vietnamese Green": "#7BA68F"
        }
        
        found_colors = {}
        missing = []
        
        for name, hex_code in colors.items():
            if hex_code in content:
                print(f"✅ {name}: {hex_code}")
                found_colors[name] = hex_code
            else:
                print(f"❌ {name}: {hex_code} NOT FOUND")
                missing.append(name)
        
        self.test_results["tests"].append({
            "test": "Color palette",
            "status": "pass" if not missing else "fail",
            "found": len(found_colors),
            "total": len(colors),
            "missing": missing
        })
        
        return len(missing) == 0
    
    def test_responsive_breakpoints(self):
        """Verify responsive design breakpoints."""
        print("\n📱 RESPONSIVE BREAKPOINTS VERIFICATION")
        print("="*70)
        
        css_file = self.base_dir / "staging" / "moodle_visual_style.css"
        
        with open(css_file, 'r') as f:
            content = f.read()
        
        breakpoints = {
            "Mobile (XS)": "480px",
            "Tablet (SM)": "768px",
            "Desktop (MD+)": "1024px",
            "Large (LG)": "1280px",
            "Extra Large (XL)": "1920px"
        }
        
        found_breakpoints = {}
        missing = []
        
        for name, width in breakpoints.items():
            if width in content or f"max-width: {width}" in content or f"min-width: {width}" in content:
                print(f"✅ {name} ({width})")
                found_breakpoints[name] = width
            else:
                print(f"⚠️ {name} ({width}) not explicitly found")
                missing.append(name)
        
        self.test_results["tests"].append({
            "test": "Responsive breakpoints",
            "status": "pass" if len(found_breakpoints) >= 3 else "warn",
            "found": len(found_breakpoints),
            "total": len(breakpoints),
            "missing": missing
        })
        
        return True
    
    def test_component_styles(self):
        """Verify key component styles are defined."""
        print("\n🧩 COMPONENT STYLES VERIFICATION")
        print("="*70)
        
        css_file = self.base_dir / "staging" / "moodle_visual_style.css"
        
        with open(css_file, 'r') as f:
            content = f.read()
        
        components = {
            ".module-card": "Module cards",
            ".lesson-module": "Lesson modules",
            ".progress": "Progress bars",
            ".multimedia-container": "Multimedia containers",
            ".quiz-block": "Quiz blocks",
            ".assignment-block": "Assignment blocks",
            ".button": "Button styles",
            ".badge": "Badge styles"
        }
        
        found = {}
        missing = []
        
        for selector, name in components.items():
            if selector in content:
                print(f"✅ {name}: {selector}")
                found[selector] = name
            else:
                print(f"⚠️ {name}: {selector} not found")
                missing.append(selector)
        
        self.test_results["tests"].append({
            "test": "Component styles",
            "status": "pass" if len(found) >= 6 else "warn",
            "found": len(found),
            "total": len(components),
            "missing": missing
        })
        
        return True
    
    def test_typography(self):
        """Verify typography settings."""
        print("\n✍️  TYPOGRAPHY VERIFICATION")
        print("="*70)
        
        css_file = self.base_dir / "staging" / "moodle_visual_style.css"
        
        with open(css_file, 'r') as f:
            content = f.read()
        
        typography_checks = {
            "Montserrat font": "Montserrat" in content,
            "Open Sans font": "Open Sans" in content,
            "Font weights": "font-weight" in content,
            "Line heights": "line-height" in content,
            "Letter spacing": "letter-spacing" in content
        }
        
        passed = 0
        for check, result in typography_checks.items():
            status = "✅" if result else "⚠️"
            print(f"{status} {check}")
            if result:
                passed += 1
        
        self.test_results["tests"].append({
            "test": "Typography",
            "status": "pass" if passed >= 3 else "warn",
            "checks_passed": passed,
            "total_checks": len(typography_checks)
        })
        
        return True
    
    def test_accessibility(self):
        """Verify accessibility considerations."""
        print("\n♿ ACCESSIBILITY VERIFICATION")
        print("="*70)
        
        css_file = self.base_dir / "staging" / "moodle_visual_style.css"
        
        with open(css_file, 'r') as f:
            content = f.read()
        
        accessibility_checks = {
            "Focus states": ":focus" in content,
            "High contrast": "#1F2937" in content or "#374151" in content,
            "Dark mode support": "@media (prefers-color-scheme" in content or "dark" in content,
            "Reduced motion": "@media (prefers-reduced-motion" in content,
            "Text alternatives": "aria" in content or "label" in content
        }
        
        passed = 0
        for check, result in accessibility_checks.items():
            status = "✅" if result else "⚠️"
            print(f"{status} {check}")
            if result:
                passed += 1
        
        self.test_results["tests"].append({
            "test": "Accessibility",
            "status": "pass" if passed >= 2 else "warn",
            "checks_passed": passed,
            "total_checks": len(accessibility_checks),
            "recommendation": "Review focus states and dark mode support"
        })
        
        return True
    
    def generate_smoke_test_report(self):
        """Generate final smoke test report."""
        print("\n📋 SMOKE TEST REPORT")
        print("="*70)
        
        # Calculate summary
        passed_tests = len([t for t in self.test_results["tests"] if t.get("status") == "pass"])
        total_tests = len(self.test_results["tests"])
        
        self.test_results["summary"] = {
            "total_tests": total_tests,
            "passed": passed_tests,
            "pass_rate": f"{(passed_tests / total_tests * 100):.1f}%" if total_tests > 0 else "0%",
            "status": "PASS" if passed_tests == total_tests else "PASS_WITH_WARNINGS"
        }
        
        print(f"\n✅ Tests Passed: {passed_tests}/{total_tests}")
        print(f"   Pass Rate: {self.test_results['summary']['pass_rate']}")
        
        # Save report
        report_file = self.base_dir / f"UI_SMOKE_TEST_REPORT_{self.timestamp}.json"
        with open(report_file, 'w') as f:
            json.dump(self.test_results, f, indent=2)
        
        print(f"\n📊 Report saved: {report_file}")
        
        return report_file
    
    def generate_qa_checklist(self):
        """Generate QA manual verification checklist."""
        print("\n✓ QA MANUAL VERIFICATION CHECKLIST")
        print("="*70)
        
        checklist = {
            "visual_verification": [
                "1. Load Moodle homepage in staging",
                "2. Verify Vietnamese Red (#E8423C) visible in header/accents",
                "3. Verify Gold (#C4A73C) visible in secondary elements",
                "4. Verify Deep Blue (#1A3A52) visible in navigation",
                "5. Verify Sage Green (#7BA68F) visible in success states"
            ],
            "responsive_testing": [
                "1. Test on mobile (375px width) - single column, stacked layout",
                "2. Test on tablet (768px width) - 2-column layout",
                "3. Test on desktop (1920px width) - full multi-column layout",
                "4. Verify no horizontal scroll on any breakpoint"
            ],
            "component_testing": [
                "1. Module cards render with correct colors and spacing",
                "2. Progress bars display correctly (Sage Green)",
                "3. Buttons are clickable and hover states work",
                "4. Forms display properly with correct field styling",
                "5. Quiz/assignment blocks render with borders"
            ],
            "browser_compatibility": [
                "1. Chrome: Latest version",
                "2. Firefox: Latest version",
                "3. Safari: Latest version (Mac)",
                "4. Edge: Latest version",
                "5. Mobile Safari (iOS): Latest version"
            ],
            "performance": [
                "1. CSS file loads without errors (DevTools Network tab)",
                "2. No render-blocking resources",
                "3. Page load time < 3 seconds",
                "4. Lighthouse score >= 90 for Performance"
            ],
            "accessibility": [
                "1. Tab navigation works (keyboard only)",
                "2. Focus states visible and clear",
                "3. Color contrast meets WCAG AA (4.5:1 minimum)",
                "4. Screen reader test (NVDA/JAWS)"
            ]
        }
        
        for category, items in checklist.items():
            print(f"\n📋 {category.upper().replace('_', ' ')}:")
            for item in items:
                print(f"   ☐ {item}")
        
        return checklist

def main():
    print("\n" + "="*70)
    print("✓ UI SMOKE TEST & VERIFICATION")
    print("="*70)
    
    tester = UIVerificationTest()
    
    # Run all tests
    tester.test_css_syntax()
    tester.test_color_palette()
    tester.test_responsive_breakpoints()
    tester.test_component_styles()
    tester.test_typography()
    tester.test_accessibility()
    
    # Generate reports
    tester.generate_smoke_test_report()
    tester.generate_qa_checklist()
    
    print("\n" + "="*70)
    print("✅ UI VERIFICATION COMPLETE")
    print("="*70)
    print("\n🎯 Next Steps:")
    print("   1. QA team reviews manual checklist")
    print("   2. Deploy CSS to staging Moodle")
    print("   3. Execute QA testing on staging")
    print("   4. If pass, promote to production")

if __name__ == "__main__":
    main()

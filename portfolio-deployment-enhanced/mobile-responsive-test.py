#!/usr/bin/env python3
"""
Mobile Responsive Testing Suite
Tests portfolio site on iPhone SE, Samsung Galaxy A12, iPad
Validates: dropdowns, forms, buttons (44x44px), navigation, performance
"""

import json
from datetime import datetime
from pathlib import Path
from playwright.sync_api import sync_playwright, expect

class MobileResponsiveTest:
    """Comprehensive mobile device testing suite."""
    
    def __init__(self):
        self.timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        self.base_dir = Path(__file__).parent
        self.report_file = self.base_dir / f"mobile_test_report_{self.timestamp}.json"
        
        # Device configurations
        self.devices = {
            "iPhone SE": {
                "viewport": {"width": 375, "height": 667},
                "user_agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15",
                "device_scale_factor": 2,
                "is_mobile": True,
                "has_touch": True
            },
            "Samsung Galaxy A12": {
                "viewport": {"width": 360, "height": 800},
                "user_agent": "Mozilla/5.0 (Linux; Android 11; SM-A125F) AppleWebKit/537.36",
                "device_scale_factor": 2,
                "is_mobile": True,
                "has_touch": True
            },
            "iPad": {
                "viewport": {"width": 768, "height": 1024},
                "user_agent": "Mozilla/5.0 (iPad; CPU OS 15_0 like Mac OS X) AppleWebKit/605.1.15",
                "device_scale_factor": 2,
                "is_mobile": True,
                "has_touch": True
            }
        }
        
        self.test_results = {
            "timestamp": datetime.now().isoformat(),
            "site": "https://www.simondatalab.de/",
            "devices": {},
            "summary": {"total_tests": 0, "passed": 0, "failed": 0}
        }
    
    def test_device(self, page, device_name, config):
        """Run all tests for a specific device."""
        print(f"\n{'='*70}")
        print(f"🔍 Testing: {device_name}")
        print(f"   Viewport: {config['viewport']['width']}x{config['viewport']['height']}")
        print(f"{'='*70}")
        
        device_results = {
            "viewport": config["viewport"],
            "tests": [],
            "passed": 0,
            "failed": 0,
            "screenshots": []
        }
        
        # Navigate to site
        try:
            page.goto("https://www.simondatalab.de/", wait_until="networkidle", timeout=30000)
            print("✅ Site loaded successfully")
            device_results["tests"].append({"test": "Page Load", "status": "pass"})
            device_results["passed"] += 1
        except Exception as e:
            print(f"❌ Failed to load site: {e}")
            device_results["tests"].append({"test": "Page Load", "status": "fail", "error": str(e)})
            device_results["failed"] += 1
            return device_results
        
        # Test 1: Navigation Menu
        nav_result = self.test_navigation(page, device_name)
        device_results["tests"].append(nav_result)
        if nav_result["status"] == "pass":
            device_results["passed"] += 1
        else:
            device_results["failed"] += 1
        
        # Test 2: Mobile Menu (for phones)
        if config["viewport"]["width"] < 768:
            mobile_menu_result = self.test_mobile_menu(page, device_name)
            device_results["tests"].append(mobile_menu_result)
            if mobile_menu_result["status"] == "pass":
                device_results["passed"] += 1
            else:
                device_results["failed"] += 1
        
        # Test 3: Button Touch Targets
        button_result = self.test_button_sizes(page, device_name)
        device_results["tests"].append(button_result)
        if button_result["status"] == "pass":
            device_results["passed"] += 1
        else:
            device_results["failed"] += 1
        
        # Test 4: Form Accessibility
        form_result = self.test_forms(page, device_name)
        device_results["tests"].append(form_result)
        if form_result["status"] == "pass":
            device_results["passed"] += 1
        else:
            device_results["failed"] += 1
        
        # Test 5: Dropdown Functionality
        dropdown_result = self.test_dropdowns(page, device_name)
        device_results["tests"].append(dropdown_result)
        if dropdown_result["status"] == "pass":
            device_results["passed"] += 1
        else:
            device_results["failed"] += 1
        
        # Test 6: Hero Visualization Performance
        viz_result = self.test_visualization_performance(page, device_name)
        device_results["tests"].append(viz_result)
        if viz_result["status"] == "pass":
            device_results["passed"] += 1
        else:
            device_results["failed"] += 1
        
        # Test 7: Certificates Section
        cert_result = self.test_certificates_section(page, device_name)
        device_results["tests"].append(cert_result)
        if cert_result["status"] == "pass":
            device_results["passed"] += 1
        else:
            device_results["failed"] += 1
        
        # Take screenshot
        screenshot_path = self.base_dir / f"screenshot_{device_name.replace(' ', '_')}_{self.timestamp}.png"
        page.screenshot(path=str(screenshot_path), full_page=True)
        device_results["screenshots"].append(str(screenshot_path))
        print(f"📸 Screenshot saved: {screenshot_path.name}")
        
        return device_results
    
    def test_navigation(self, page, device_name):
        """Test main navigation accessibility and functionality."""
        print("\n📱 Testing Navigation...")
        try:
            nav = page.locator("nav, .main-navigation")
            expect(nav).to_be_visible(timeout=5000)
            
            # Check navigation links
            nav_links = page.locator("nav a, .nav-link")
            link_count = nav_links.count()
            
            if link_count > 0:
                print(f"   ✅ Found {link_count} navigation links")
                return {"test": "Navigation", "status": "pass", "link_count": link_count}
            else:
                print(f"   ⚠️  No navigation links found")
                return {"test": "Navigation", "status": "fail", "reason": "No links found"}
                
        except Exception as e:
            print(f"   ❌ Navigation test failed: {e}")
            return {"test": "Navigation", "status": "fail", "error": str(e)}
    
    def test_mobile_menu(self, page, device_name):
        """Test mobile hamburger menu functionality."""
        print("\n🍔 Testing Mobile Menu...")
        try:
            # Find mobile menu button
            menu_btn = page.locator(".mobile-menu-btn, button[aria-label*='menu']").first
            
            if not menu_btn.is_visible():
                print("   ⚠️  Mobile menu button not visible")
                return {"test": "Mobile Menu", "status": "fail", "reason": "Button not visible"}
            
            # Click to open menu
            menu_btn.click()
            page.wait_for_timeout(500)  # Wait for animation
            
            # Check if menu is open
            mobile_nav = page.locator(".mobile-nav, #mobile-navigation")
            is_open = mobile_nav.is_visible()
            
            if is_open:
                print("   ✅ Mobile menu opens successfully")
                
                # Click again to close
                menu_btn.click()
                page.wait_for_timeout(500)
                
                return {"test": "Mobile Menu", "status": "pass", "toggle_works": True}
            else:
                print("   ❌ Mobile menu did not open")
                return {"test": "Mobile Menu", "status": "fail", "reason": "Menu did not open"}
                
        except Exception as e:
            print(f"   ❌ Mobile menu test failed: {e}")
            return {"test": "Mobile Menu", "status": "fail", "error": str(e)}
    
    def test_button_sizes(self, page, device_name):
        """Verify all buttons meet 44x44px touch target requirement."""
        print("\n👆 Testing Button Touch Targets (≥44x44px)...")
        try:
            buttons = page.locator("button, .btn, a.btn-primary, a.btn-secondary").all()
            
            small_buttons = []
            total_buttons = len(buttons)
            
            for i, btn in enumerate(buttons):
                if not btn.is_visible():
                    continue
                    
                box = btn.bounding_box()
                if box:
                    width, height = box["width"], box["height"]
                    if width < 44 or height < 44:
                        small_buttons.append({
                            "index": i,
                            "size": f"{width:.0f}x{height:.0f}",
                            "text": btn.inner_text()[:30] if btn.inner_text() else "N/A"
                        })
            
            if not small_buttons:
                print(f"   ✅ All {total_buttons} visible buttons meet 44x44px requirement")
                return {"test": "Button Sizes", "status": "pass", "total_buttons": total_buttons}
            else:
                print(f"   ⚠️  {len(small_buttons)}/{total_buttons} buttons below 44x44px:")
                for btn_info in small_buttons[:5]:  # Show first 5
                    print(f"      - {btn_info['size']} | {btn_info['text']}")
                return {
                    "test": "Button Sizes",
                    "status": "fail",
                    "small_buttons": len(small_buttons),
                    "total_buttons": total_buttons,
                    "examples": small_buttons[:5]
                }
                
        except Exception as e:
            print(f"   ❌ Button size test failed: {e}")
            return {"test": "Button Sizes", "status": "fail", "error": str(e)}
    
    def test_forms(self, page, device_name):
        """Test form input accessibility."""
        print("\n📝 Testing Form Inputs...")
        try:
            # Scroll to contact section
            contact_section = page.locator("#contact, .contact-section")
            if contact_section.is_visible():
                contact_section.scroll_into_view_if_needed()
                page.wait_for_timeout(500)
            
            # Find form inputs
            inputs = page.locator("input, textarea, select").all()
            visible_inputs = [inp for inp in inputs if inp.is_visible()]
            
            if not visible_inputs:
                print("   ⚠️  No visible form inputs found")
                return {"test": "Forms", "status": "pass", "note": "No forms on page"}
            
            small_inputs = []
            for i, inp in enumerate(visible_inputs):
                box = inp.bounding_box()
                if box and box["height"] < 44:
                    input_type = inp.get_attribute("type") or "textarea"
                    small_inputs.append({
                        "index": i,
                        "height": f"{box['height']:.0f}px",
                        "type": input_type
                    })
            
            if not small_inputs:
                print(f"   ✅ All {len(visible_inputs)} form inputs have adequate height (≥44px)")
                return {"test": "Forms", "status": "pass", "total_inputs": len(visible_inputs)}
            else:
                print(f"   ⚠️  {len(small_inputs)}/{len(visible_inputs)} inputs below 44px height")
                return {
                    "test": "Forms",
                    "status": "fail",
                    "small_inputs": len(small_inputs),
                    "total_inputs": len(visible_inputs),
                    "examples": small_inputs[:3]
                }
                
        except Exception as e:
            print(f"   ❌ Form test failed: {e}")
            return {"test": "Forms", "status": "fail", "error": str(e)}
    
    def test_dropdowns(self, page, device_name):
        """Test dropdown functionality."""
        print("\n🔽 Testing Dropdowns...")
        try:
            # Look for dropdown toggles
            dropdown_toggles = page.locator(".dropdown-toggle, .mobile-dropdown-toggle").all()
            
            if not dropdown_toggles:
                print("   ℹ️  No dropdowns found on page")
                return {"test": "Dropdowns", "status": "pass", "note": "No dropdowns present"}
            
            working_dropdowns = 0
            for i, toggle in enumerate(dropdown_toggles):
                if not toggle.is_visible():
                    continue
                    
                try:
                    toggle.click()
                    page.wait_for_timeout(300)
                    
                    # Check if dropdown menu appears
                    dropdown_menu = page.locator(".dropdown-menu, .mobile-dropdown-menu").nth(i)
                    if dropdown_menu.is_visible():
                        working_dropdowns += 1
                        
                        # Close it
                        toggle.click()
                        page.wait_for_timeout(300)
                except:
                    pass
            
            total_visible = len([t for t in dropdown_toggles if t.is_visible()])
            
            if working_dropdowns == total_visible:
                print(f"   ✅ All {working_dropdowns} dropdowns working")
                return {"test": "Dropdowns", "status": "pass", "working_dropdowns": working_dropdowns}
            else:
                print(f"   ⚠️  {working_dropdowns}/{total_visible} dropdowns working")
                return {
                    "test": "Dropdowns",
                    "status": "partial",
                    "working": working_dropdowns,
                    "total": total_visible
                }
                
        except Exception as e:
            print(f"   ❌ Dropdown test failed: {e}")
            return {"test": "Dropdowns", "status": "fail", "error": str(e)}
    
    def test_visualization_performance(self, page, device_name):
        """Test hero visualization loads and performs well."""
        print("\n🎨 Testing Hero Visualization Performance...")
        try:
            # Check if hero viz container exists
            hero_viz = page.locator("#hero-visualization, .hero-viz")
            expect(hero_viz).to_be_visible(timeout=5000)
            
            # Wait for THREE.js initialization
            page.wait_for_timeout(3000)
            
            # Check for canvas element
            canvas = page.locator("#hero-visualization canvas").first
            
            if canvas.is_visible():
                # Check canvas size
                box = canvas.bounding_box()
                if box:
                    print(f"   ✅ Visualization canvas rendered: {box['width']:.0f}x{box['height']:.0f}px")
                    
                    # Check for console errors
                    errors = []
                    page.on("console", lambda msg: errors.append(msg.text) if msg.type == "error" else None)
                    page.wait_for_timeout(2000)
                    
                    viz_errors = [e for e in errors if "THREE" in e or "visualization" in e.lower()]
                    
                    if not viz_errors:
                        return {
                            "test": "Visualization Performance",
                            "status": "pass",
                            "canvas_size": f"{box['width']:.0f}x{box['height']:.0f}"
                        }
                    else:
                        return {
                            "test": "Visualization Performance",
                            "status": "fail",
                            "errors": viz_errors[:3]
                        }
            else:
                print("   ⚠️  Canvas not visible")
                return {"test": "Visualization Performance", "status": "fail", "reason": "Canvas not visible"}
                
        except Exception as e:
            print(f"   ❌ Visualization test failed: {e}")
            return {"test": "Visualization Performance", "status": "fail", "error": str(e)}
    
    def test_certificates_section(self, page, device_name):
        """Test certificates section is visible and responsive."""
        print("\n🎓 Testing Certificates Section...")
        try:
            # Scroll to certificates section
            cert_section = page.locator("#certifications, .certifications-section")
            
            if not cert_section.is_visible():
                # Try scrolling down
                page.evaluate("window.scrollTo(0, document.body.scrollHeight / 2)")
                page.wait_for_timeout(500)
            
            if cert_section.is_visible():
                cert_section.scroll_into_view_if_needed()
                page.wait_for_timeout(500)
                
                # Count certificate cards
                cert_cards = page.locator(".certification-card, .certificate-card").all()
                visible_cards = [c for c in cert_cards if c.is_visible()]
                
                print(f"   ✅ Certificates section visible with {len(visible_cards)} cards")
                return {
                    "test": "Certificates Section",
                    "status": "pass",
                    "certificate_count": len(visible_cards)
                }
            else:
                print("   ⚠️  Certificates section not found (may not be deployed yet)")
                return {"test": "Certificates Section", "status": "fail", "reason": "Section not visible"}
                
        except Exception as e:
            print(f"   ❌ Certificates test failed: {e}")
            return {"test": "Certificates Section", "status": "fail", "error": str(e)}
    
    def run_all_tests(self):
        """Run tests on all devices."""
        print(f"\n{'='*70}")
        print(f"🚀 Mobile Responsive Testing Suite")
        print(f"   Site: https://www.simondatalab.de/")
        print(f"   Timestamp: {self.timestamp}")
        print(f"{'='*70}")
        
        with sync_playwright() as p:
            browser = p.chromium.launch(headless=True)
            
            for device_name, config in self.devices.items():
                context = browser.new_context(**config)
                page = context.new_page()
                
                device_results = self.test_device(page, device_name, config)
                self.test_results["devices"][device_name] = device_results
                
                # Update summary
                self.test_results["summary"]["total_tests"] += device_results["passed"] + device_results["failed"]
                self.test_results["summary"]["passed"] += device_results["passed"]
                self.test_results["summary"]["failed"] += device_results["failed"]
                
                context.close()
            
            browser.close()
        
        # Save report
        with open(self.report_file, 'w') as f:
            json.dump(self.test_results, f, indent=2)
        
        # Print summary
        self.print_summary()
    
    def print_summary(self):
        """Print test summary."""
        print(f"\n{'='*70}")
        print(f"📊 TEST SUMMARY")
        print(f"{'='*70}")
        
        summary = self.test_results["summary"]
        total = summary["total_tests"]
        passed = summary["passed"]
        failed = summary["failed"]
        pass_rate = (passed / total * 100) if total > 0 else 0
        
        print(f"\nOverall Results:")
        print(f"   Total Tests: {total}")
        print(f"   ✅ Passed: {passed}")
        print(f"   ❌ Failed: {failed}")
        print(f"   Pass Rate: {pass_rate:.1f}%")
        
        print(f"\nDevice Breakdown:")
        for device_name, results in self.test_results["devices"].items():
            device_total = results["passed"] + results["failed"]
            device_rate = (results["passed"] / device_total * 100) if device_total > 0 else 0
            status_emoji = "✅" if device_rate >= 80 else "⚠️" if device_rate >= 60 else "❌"
            print(f"   {status_emoji} {device_name}: {results['passed']}/{device_total} ({device_rate:.0f}%)")
        
        print(f"\n📄 Full report saved: {self.report_file.name}")
        print(f"{'='*70}\n")


if __name__ == "__main__":
    tester = MobileResponsiveTest()
    tester.run_all_tests()

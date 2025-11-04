#!/usr/bin/env python3
"""
Quick Test - Verify Chrome Profile Login
Tests that your Chrome profile works with LinkedIn automation
"""

import asyncio
from playwright.async_api import async_playwright

CHROME_USER_DATA_DIR = "/home/simon/.config/google-chrome"
CHROME_PROFILE = "Default"

async def test_chrome_profile():
    print("=" * 60)
    print("Testing Chrome Profile LinkedIn Access")
    print("=" * 60)
    print(f"Profile: {CHROME_USER_DATA_DIR}/{CHROME_PROFILE}")
    print()
    
    playwright = await async_playwright().start()
    
    print("Launching Chrome with your profile...")
    browser = await playwright.chromium.launch_persistent_context(
        user_data_dir=f"{CHROME_USER_DATA_DIR}/{CHROME_PROFILE}",
        headless=False,
        args=['--disable-blink-features=AutomationControlled']
    )
    
    pages = browser.pages
    if pages:
        page = pages[0]
    else:
        page = await browser.new_page()
    
    print("✓ Browser opened")
    print()
    print("Navigating to LinkedIn...")
    await page.goto('https://www.linkedin.com/feed/', timeout=60000)
    
    await asyncio.sleep(3)
    
    # Check if logged in
    try:
        search_bar = await page.wait_for_selector('input[placeholder*="Search"]', timeout=5000)
        if search_bar:
            print("✓ SUCCESS! Already logged into LinkedIn")
            print("✓ Chrome profile session is valid")
            print()
            
            # Try to get profile name
            try:
                profile_button = await page.query_selector('button[id*="ember"]')
                if profile_button:
                    print("✓ Profile menu found - session is active")
            except:
                pass
                
    except:
        print("✗ Not logged in - please login manually")
        print("  The browser will stay open for 60 seconds")
        print("  Please login, then we'll verify")
        await asyncio.sleep(60)
        
        # Check again
        try:
            await page.wait_for_selector('input[placeholder*="Search"]', timeout=5000)
            print("✓ Login successful!")
        except:
            print("✗ Still not logged in - check your credentials")
    
    print()
    print("Test complete! Browser will close in 10 seconds...")
    await asyncio.sleep(10)
    
    await browser.close()
    await playwright.stop()

if __name__ == "__main__":
    asyncio.run(test_chrome_profile())

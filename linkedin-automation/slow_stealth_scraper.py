#!/usr/bin/env python3
"""
Slow Stealth LinkedIn Scraper - Runs All Day
============================================

Strategy: Behave like a human browsing LinkedIn naturally
- Random delays (2-10 minutes between searches)
- Random scroll patterns
- Occasional "distraction" (visit random profiles)
- Realistic session duration (8-10 hours with breaks)
- Save progress continuously (resume if interrupted)

This is designed to run all day Monday-Friday automatically.
"""

import asyncio
import random
import json
import logging
from datetime import datetime, timedelta
from pathlib import Path
from playwright.async_api import async_playwright, TimeoutError as PlaywrightTimeout
import sys

# Configuration
LINKEDIN_EMAIL = "sn.renauld@gmail.com"  # Your Chrome profile email
LINKEDIN_PASSWORD = None  # Not needed - using Chrome profile with saved session

# Chrome Profile Settings
CHROME_USER_DATA_DIR = "/home/simon/.config/google-chrome"  # Your Chrome profile
CHROME_PROFILE = "Default"  # Or "Profile 1", "Profile 2" etc.

# Stealth Settings - Mimic Human Behavior
MIN_DELAY_BETWEEN_SEARCHES = 120  # 2 minutes
MAX_DELAY_BETWEEN_SEARCHES = 600  # 10 minutes
MIN_SCROLL_DELAY = 2  # seconds
MAX_SCROLL_DELAY = 8  # seconds
LUNCH_BREAK_HOUR = 12  # Take 30-60 min break at noon
COFFEE_BREAK_PROBABILITY = 0.15  # 15% chance of 5-10 min break
SESSION_DURATION_HOURS = 8  # Run for 8 hours max

# Search Configuration
DAILY_SEARCH_QUERIES = {
    0: [  # Monday - Canada Data Quality
        "Data Quality Engineer Canada Remote",
        "QA Engineer Data Toronto",
        "Senior Data Engineer Quality Vancouver",
        "Data Governance Engineer Canada",
        "Test Engineer Data Platform Montreal"
    ],
    1: [  # Tuesday - Singapore/Asia QA
        "QA Engineer Singapore Data",
        "Quality Engineer Ho Chi Minh City",
        "Test Automation Engineer Bangkok",
        "Data Quality Analyst Singapore",
        "QA Lead Kuala Lumpur"
    ],
    2: [  # Wednesday - Leadership
        "Head of Data Quality Remote",
        "Director Data Engineering Canada",
        "VP Data Startup",
        "Chief Data Officer Scale-up",
        "Data Platform Lead"
    ],
    3: [  # Thursday - Healthcare
        "Data Engineer Healthcare HIPAA",
        "QA Engineer Medical Device",
        "Healthcare Analytics Engineer",
        "Clinical Data Manager",
        "Pharma Data Quality"
    ],
    4: [  # Friday - E-commerce
        "Data Engineer E-commerce",
        "Analytics Engineer Marketplace",
        "Data Quality Engineer Retail",
        "Product Data Engineer",
        "Catalog Quality Engineer"
    ]
}

# Output
OUTPUT_DIR = Path("outputs/slow_stealth")
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
LOG_FILE = OUTPUT_DIR / f"scraper_{datetime.now().strftime('%Y%m%d')}.log"
PROGRESS_FILE = OUTPUT_DIR / f"progress_{datetime.now().strftime('%Y%m%d')}.json"
LEADS_FILE = OUTPUT_DIR / f"leads_{datetime.now().strftime('%Y%m%d')}.json"

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(LOG_FILE),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)


class StealthScraper:
    """LinkedIn scraper that mimics human behavior"""
    
    def __init__(self):
        self.browser = None
        self.context = None
        self.page = None
        self.leads_collected = []
        self.searches_completed = []
        self.start_time = None
        self.session_active = False
        
    async def human_delay(self, min_seconds=2, max_seconds=8):
        """Random delay to mimic human behavior"""
        delay = random.uniform(min_seconds, max_seconds)
        logger.debug(f"Waiting {delay:.1f} seconds (human delay)")
        await asyncio.sleep(delay)
        
    async def random_scroll(self):
        """Scroll page randomly like a human"""
        scroll_distance = random.randint(300, 800)
        scroll_duration = random.randint(500, 1500)
        
        await self.page.evaluate(f"""
            window.scrollBy({{
                top: {scroll_distance},
                left: 0,
                behavior: 'smooth'
            }});
        """)
        await self.human_delay(1, 3)
        
    async def take_coffee_break(self):
        """Random 5-10 minute break"""
        if random.random() < COFFEE_BREAK_PROBABILITY:
            break_minutes = random.randint(5, 10)
            logger.info(f"☕ Taking coffee break for {break_minutes} minutes")
            await asyncio.sleep(break_minutes * 60)
            
    async def take_lunch_break(self):
        """30-60 minute lunch break"""
        current_hour = datetime.now().hour
        if current_hour == LUNCH_BREAK_HOUR and not hasattr(self, '_lunch_taken'):
            lunch_minutes = random.randint(30, 60)
            logger.info(f"🍽️  Taking lunch break for {lunch_minutes} minutes")
            self._lunch_taken = True
            await asyncio.sleep(lunch_minutes * 60)
            
    async def init_browser(self):
        """Initialize browser using your existing Chrome profile"""
        logger.info("Initializing browser with your Chrome profile...")
        logger.info(f"Profile: {CHROME_USER_DATA_DIR}/{CHROME_PROFILE}")
        
        playwright = await async_playwright().start()
        
        # Launch Chrome with your existing profile (already logged into LinkedIn!)
        self.browser = await playwright.chromium.launch_persistent_context(
            user_data_dir=f"{CHROME_USER_DATA_DIR}/{CHROME_PROFILE}",
            headless=False,  # Visible browser
            args=[
                '--disable-blink-features=AutomationControlled',
                '--disable-dev-shm-usage',
                '--no-sandbox'
            ],
            viewport={'width': 1920, 'height': 1080},
            locale='en-US',
            timezone_id='America/Toronto'
        )
        
        # Add anti-detection script
        await self.browser.add_init_script("""
            Object.defineProperty(navigator, 'webdriver', {
                get: () => false
            });
        """)
        
        # Get first page (or create new one)
        pages = self.browser.pages
        if pages:
            self.page = pages[0]
        else:
            self.page = await self.browser.new_page()
            
        logger.info("✓ Browser initialized with your Chrome profile")
        logger.info("✓ You should already be logged into LinkedIn!")
        
    async def login(self):
        """Verify LinkedIn session (should already be logged in via Chrome profile)"""
        logger.info("Verifying LinkedIn session...")
        
        try:
            # Go to LinkedIn homepage to check if logged in
            await self.page.goto('https://www.linkedin.com/feed/', timeout=60000)
            await self.human_delay(3, 5)
            
            # Check if we're logged in by looking for search bar
            try:
                await self.page.wait_for_selector('input[placeholder*="Search"]', timeout=10000)
                logger.info("✓ Already logged in via Chrome profile!")
                logger.info(f"✓ Session active for: {LINKEDIN_EMAIL}")
                return
            except PlaywrightTimeout:
                logger.warning("⚠️  Not logged in - redirecting to login page")
                
            # If not logged in, go to login page
            await self.page.goto('https://www.linkedin.com/login', timeout=60000)
            await self.human_delay(2, 4)
            
            # Check if email is pre-filled
            email_input = await self.page.query_selector('#username')
            if email_input:
                current_value = await email_input.input_value()
                if not current_value:
                    # Type email slowly
                    for char in LINKEDIN_EMAIL:
                        await email_input.type(char, delay=random.randint(50, 150))
                    logger.info("✓ Email entered")
            
            logger.warning("⚠️  Please complete login in the browser window")
            logger.warning("    (Password should be saved in Chrome)")
            
            # Wait for login to complete
            await self.page.wait_for_selector('input[placeholder*="Search"]', timeout=120000)
            logger.info("✓ Login successful!")
                
        except Exception as e:
            logger.error(f"Login verification failed: {e}")
            logger.error("Please login manually in the browser window")
            await asyncio.sleep(30)  # Give user time to login manually
            
    async def search_people(self, query: str, max_results: int = 10) -> list:
        """Search for people with a query, collect profiles slowly"""
        logger.info(f"🔍 Searching: '{query}' (target: {max_results} results)")
        
        leads = []
        
        try:
            # Go to LinkedIn search
            search_url = f"https://www.linkedin.com/search/results/people/?keywords={query.replace(' ', '%20')}"
            await self.page.goto(search_url, timeout=60000)
            await self.human_delay(3, 6)
            
            # Random scroll to load results
            for _ in range(random.randint(2, 4)):
                await self.random_scroll()
                
            # Collect profile cards
            profile_cards = await self.page.query_selector_all('.reusable-search__result-container')
            logger.info(f"Found {len(profile_cards)} profile cards on page")
            
            for i, card in enumerate(profile_cards[:max_results]):
                try:
                    # Extract profile data
                    name_elem = await card.query_selector('.entity-result__title-text a span[aria-hidden="true"]')
                    title_elem = await card.query_selector('.entity-result__primary-subtitle')
                    location_elem = await card.query_selector('.entity-result__secondary-subtitle')
                    link_elem = await card.query_selector('.entity-result__title-text a')
                    
                    if name_elem and link_elem:
                        name = await name_elem.inner_text()
                        title = await title_elem.inner_text() if title_elem else "Unknown"
                        location = await location_elem.inner_text() if location_elem else "Unknown"
                        profile_url = await link_elem.get_attribute('href')
                        
                        # Clean LinkedIn URL (remove tracking params)
                        if profile_url:
                            profile_url = profile_url.split('?')[0]
                        
                        lead = {
                            "name": name.strip(),
                            "title": title.strip(),
                            "location": location.strip(),
                            "linkedin_url": profile_url,
                            "source": "linkedin_stealth_scraper",
                            "search_query": query,
                            "collected_at": datetime.now().isoformat(),
                            "fit_score": 7  # Default, manually adjust later
                        }
                        
                        leads.append(lead)
                        logger.info(f"  ✓ [{i+1}/{max_results}] {name} - {title[:50]}")
                        
                        # Human delay between profile extractions
                        await self.human_delay(1, 3)
                        
                except Exception as e:
                    logger.warning(f"  ✗ Failed to extract profile {i+1}: {e}")
                    continue
                    
            # Random "distraction" - occasionally click a profile (but don't scrape it)
            if random.random() < 0.3 and profile_cards:
                logger.debug("Random distraction: viewing a profile briefly...")
                random_card = random.choice(profile_cards[:5])
                link = await random_card.query_selector('.entity-result__title-text a')
                if link:
                    await link.click()
                    await self.human_delay(5, 10)
                    await self.page.go_back()
                    await self.human_delay(2, 4)
                    
        except Exception as e:
            logger.error(f"Search failed for '{query}': {e}")
            
        return leads
        
    async def run_daily_session(self):
        """Run a full day's scraping session"""
        self.start_time = datetime.now()
        self.session_active = True
        
        # Get today's search queries
        day_of_week = datetime.now().weekday()
        queries = DAILY_SEARCH_QUERIES.get(day_of_week, DAILY_SEARCH_QUERIES[0])
        
        logger.info("=" * 70)
        logger.info(f"🚀 Starting stealth scraping session - {datetime.now().strftime('%A, %B %d, %Y')}")
        logger.info(f"📋 Queries: {len(queries)}")
        logger.info(f"⏱️  Expected duration: {SESSION_DURATION_HOURS} hours")
        logger.info("=" * 70)
        
        try:
            # Initialize browser with Chrome profile
            await self.init_browser()
            
            # Verify session (should already be logged in)
            await self.login()
            
            # Load previous progress if exists
            if PROGRESS_FILE.exists():
                with open(PROGRESS_FILE, 'r') as f:
                    progress = json.load(f)
                    self.searches_completed = progress.get('completed_searches', [])
                    logger.info(f"📂 Resumed: {len(self.searches_completed)} searches already completed")
            
            # Main scraping loop
            for i, query in enumerate(queries):
                # Check if already completed
                if query in self.searches_completed:
                    logger.info(f"⏭️  Skipping '{query}' (already completed)")
                    continue
                
                # Check session duration
                elapsed = (datetime.now() - self.start_time).total_seconds() / 3600
                if elapsed >= SESSION_DURATION_HOURS:
                    logger.info(f"⏱️  Session duration limit reached ({SESSION_DURATION_HOURS}h)")
                    break
                
                # Lunch break
                await self.take_lunch_break()
                
                # Coffee break
                await self.take_coffee_break()
                
                # Perform search
                logger.info(f"\n[{i+1}/{len(queries)}] Processing: '{query}'")
                leads = await self.search_people(query, max_results=10)
                
                if leads:
                    self.leads_collected.extend(leads)
                    logger.info(f"✓ Collected {len(leads)} leads (total: {len(self.leads_collected)})")
                    
                    # Save immediately
                    self.save_leads()
                
                # Mark as completed
                self.searches_completed.append(query)
                self.save_progress()
                
                # Human delay before next search (2-10 minutes)
                if i < len(queries) - 1:  # Don't delay after last search
                    delay_seconds = random.randint(MIN_DELAY_BETWEEN_SEARCHES, MAX_DELAY_BETWEEN_SEARCHES)
                    delay_minutes = delay_seconds / 60
                    logger.info(f"⏸️  Waiting {delay_minutes:.1f} minutes before next search...")
                    await asyncio.sleep(delay_seconds)
                    
        except KeyboardInterrupt:
            logger.info("\n⚠️  Interrupted by user - saving progress...")
            self.save_leads()
            self.save_progress()
            
        except Exception as e:
            logger.error(f"Session error: {e}", exc_info=True)
            self.save_leads()
            self.save_progress()
            
        finally:
            # Cleanup
            if self.browser:
                await self.browser.close()
                
            self.session_active = False
            
            # Final summary
            elapsed = (datetime.now() - self.start_time).total_seconds() / 3600
            logger.info("\n" + "=" * 70)
            logger.info(f"✅ Session completed!")
            logger.info(f"⏱️  Duration: {elapsed:.1f} hours")
            logger.info(f"🔍 Searches completed: {len(self.searches_completed)}/{len(queries)}")
            logger.info(f"👥 Leads collected: {len(self.leads_collected)}")
            logger.info(f"💾 Saved to: {LEADS_FILE}")
            logger.info("=" * 70)
            
    def save_leads(self):
        """Save collected leads to JSON"""
        with open(LEADS_FILE, 'w') as f:
            json.dump({
                "collected_at": datetime.now().isoformat(),
                "total_leads": len(self.leads_collected),
                "leads": self.leads_collected
            }, f, indent=2)
        logger.debug(f"💾 Saved {len(self.leads_collected)} leads to {LEADS_FILE}")
        
    def save_progress(self):
        """Save progress (for resuming)"""
        with open(PROGRESS_FILE, 'w') as f:
            json.dump({
                "last_updated": datetime.now().isoformat(),
                "completed_searches": self.searches_completed,
                "leads_count": len(self.leads_collected)
            }, f, indent=2)
        logger.debug(f"💾 Saved progress: {len(self.searches_completed)} searches completed")


async def main():
    """Main entry point"""
    scraper = StealthScraper()
    await scraper.run_daily_session()


if __name__ == "__main__":
    # Run the scraper
    asyncio.run(main())

"""
Job Scraper - Multi-Board Job Search Automation
Author: Simon Renauld
Created: October 15, 2025

Purpose: Scrape job listings from multiple job boards:
- LinkedIn Jobs
- Indeed
- Glassdoor
- Remote job boards (We Work Remotely, Remote.co)

Features:
- Keyword-based filtering
- Location filtering
- Salary range filtering
- Duplicate detection
- Export to JSON/CSV

Usage:
    python tools/job_scraper.py \\
        --keywords "Lead Data Engineer,Analytics Lead" \\
        --location "Ho Chi Minh City,Remote" \\
        --output outputs/job_listings/
"""

import argparse
import json
import os
import time
from datetime import datetime
from typing import List, Dict, Optional
from urllib.parse import quote_plus

try:
    import requests
    from bs4 import BeautifulSoup
    import pandas as pd
    from selenium import webdriver
    from selenium.webdriver.common.by import By
    from selenium.webdriver.chrome.options import Options
    from selenium.webdriver.support.ui import WebDriverWait
    from selenium.webdriver.support import expected_conditions as EC
except ImportError as e:
    print(f"Missing dependency: {e}")
    print("Install: pip install requests beautifulsoup4 pandas selenium")
    sys.exit(1)


class JobScraper:
    """Multi-board job scraper"""
    
    def __init__(self, headless: bool = True):
        """Initialize scraper with browser options"""
        self.headless = headless
        self.results = []
        
    def _init_browser(self) -> webdriver.Chrome:
        """Initialize Selenium WebDriver"""
        chrome_options = Options()
        if self.headless:
            chrome_options.add_argument("--headless")
        chrome_options.add_argument("--no-sandbox")
        chrome_options.add_argument("--disable-dev-shm-usage")
        chrome_options.add_argument("--disable-blink-features=AutomationControlled")
        chrome_options.add_argument("user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")
        
        driver = webdriver.Chrome(options=chrome_options)
        return driver
    
    def scrape_linkedin(self, keywords: List[str], location: str) -> List[Dict]:
        """Scrape LinkedIn Jobs (requires login for full access)"""
        jobs = []
        
        for keyword in keywords:
            url = f"https://www.linkedin.com/jobs/search/?keywords={quote_plus(keyword)}&location={quote_plus(location)}"
            
            print(f"🔍 Scraping LinkedIn: {keyword} in {location}")
            
            # LinkedIn blocks automated scraping - use API or manual scraping with login
            # For now, return placeholder
            print("⚠️  LinkedIn scraping requires authentication - use LinkedIn Job Search API or manual export")
            
        return jobs
    
    def scrape_indeed(self, keywords: List[str], location: str) -> List[Dict]:
        """Scrape Indeed Jobs"""
        jobs = []
        
        for keyword in keywords:
            url = f"https://www.indeed.com/jobs?q={quote_plus(keyword)}&l={quote_plus(location)}"
            
            print(f"🔍 Scraping Indeed: {keyword} in {location}")
            
            try:
                response = requests.get(url, headers={"User-Agent": "Mozilla/5.0"})
                soup = BeautifulSoup(response.content, 'html.parser')
                
                job_cards = soup.find_all('div', class_='job_seen_beacon')
                
                for card in job_cards[:20]:  # Limit to 20 per keyword
                    try:
                        title = card.find('h2', class_='jobTitle').get_text(strip=True)
                        company = card.find('span', {'data-testid': 'company-name'}).get_text(strip=True)
                        location_elem = card.find('div', {'data-testid': 'text-location'})
                        job_location = location_elem.get_text(strip=True) if location_elem else location
                        
                        link_elem = card.find('a', class_='jcs-JobTitle')
                        job_link = f"https://www.indeed.com{link_elem['href']}" if link_elem else ""
                        
                        jobs.append({
                            "title": title,
                            "company": company,
                            "location": job_location,
                            "source": "Indeed",
                            "url": job_link,
                            "keyword": keyword,
                            "scraped_at": datetime.now().isoformat()
                        })
                    except Exception as e:
                        print(f"Error parsing job card: {e}")
                        continue
                
                time.sleep(2)  # Rate limiting
                
            except Exception as e:
                print(f"Error scraping Indeed: {e}")
        
        return jobs
    
    def scrape_glassdoor(self, keywords: List[str], location: str) -> List[Dict]:
        """Scrape Glassdoor Jobs (requires browser automation)"""
        jobs = []
        driver = self._init_browser()
        
        for keyword in keywords:
            url = f"https://www.glassdoor.com/Job/jobs.htm?sc.keyword={quote_plus(keyword)}&locT=C&locId={location}"
            
            print(f"🔍 Scraping Glassdoor: {keyword} in {location}")
            
            try:
                driver.get(url)
                time.sleep(3)
                
                # Wait for job cards to load
                WebDriverWait(driver, 10).until(
                    EC.presence_of_element_located((By.CLASS_NAME, "JobCard"))
                )
                
                job_cards = driver.find_elements(By.CLASS_NAME, "JobCard")
                
                for card in job_cards[:20]:
                    try:
                        title = card.find_element(By.CLASS_NAME, "JobCard_jobTitle").text
                        company = card.find_element(By.CLASS_NAME, "EmployerProfile_employerName").text
                        job_location = card.find_element(By.CLASS_NAME, "JobCard_location").text
                        
                        jobs.append({
                            "title": title,
                            "company": company,
                            "location": job_location,
                            "source": "Glassdoor",
                            "url": driver.current_url,
                            "keyword": keyword,
                            "scraped_at": datetime.now().isoformat()
                        })
                    except Exception as e:
                        print(f"Error parsing Glassdoor job card: {e}")
                        continue
                
                time.sleep(2)
                
            except Exception as e:
                print(f"Error scraping Glassdoor: {e}")
        
        driver.quit()
        return jobs
    
    def scrape_remote_boards(self, keywords: List[str]) -> List[Dict]:
        """Scrape remote job boards (We Work Remotely, Remote.co)"""
        jobs = []
        
        # We Work Remotely
        for keyword in keywords:
            url = f"https://weworkremotely.com/remote-jobs/search?term={quote_plus(keyword)}"
            
            print(f"🔍 Scraping We Work Remotely: {keyword}")
            
            try:
                response = requests.get(url, headers={"User-Agent": "Mozilla/5.0"})
                soup = BeautifulSoup(response.content, 'html.parser')
                
                job_listings = soup.find_all('li', class_='feature')
                
                for listing in job_listings[:20]:
                    try:
                        title_elem = listing.find('span', class_='title')
                        company_elem = listing.find('span', class_='company')
                        link_elem = listing.find('a')
                        
                        if title_elem and company_elem:
                            jobs.append({
                                "title": title_elem.get_text(strip=True),
                                "company": company_elem.get_text(strip=True),
                                "location": "Remote",
                                "source": "We Work Remotely",
                                "url": f"https://weworkremotely.com{link_elem['href']}" if link_elem else "",
                                "keyword": keyword,
                                "scraped_at": datetime.now().isoformat()
                            })
                    except Exception as e:
                        print(f"Error parsing WWR job: {e}")
                        continue
                
                time.sleep(2)
                
            except Exception as e:
                print(f"Error scraping We Work Remotely: {e}")
        
        return jobs
    
    def deduplicate(self, jobs: List[Dict]) -> List[Dict]:
        """Remove duplicate job listings"""
        seen = set()
        unique_jobs = []
        
        for job in jobs:
            key = (job['title'].lower(), job['company'].lower())
            if key not in seen:
                seen.add(key)
                unique_jobs.append(job)
        
        return unique_jobs
    
    def filter_by_keywords(self, jobs: List[Dict], required_keywords: List[str]) -> List[Dict]:
        """Filter jobs by required keywords in title/description"""
        filtered = []
        
        for job in jobs:
            title_lower = job['title'].lower()
            if any(keyword.lower() in title_lower for keyword in required_keywords):
                filtered.append(job)
        
        return filtered
    
    def save_results(self, jobs: List[Dict], output_dir: str):
        """Save scraped jobs to JSON and CSV"""
        os.makedirs(output_dir, exist_ok=True)
        
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        # JSON
        json_path = os.path.join(output_dir, f"jobs_{timestamp}.json")
        with open(json_path, 'w') as f:
            json.dump(jobs, f, indent=2)
        
        # CSV
        csv_path = os.path.join(output_dir, f"jobs_{timestamp}.csv")
        df = pd.DataFrame(jobs)
        df.to_csv(csv_path, index=False)
        
        print(f"\n✅ Results saved:")
        print(f"JSON: {json_path}")
        print(f"CSV: {csv_path}")
        print(f"Total jobs: {len(jobs)}")


def main():
    parser = argparse.ArgumentParser(description="Multi-Board Job Scraper")
    parser.add_argument("--keywords", required=True, help="Comma-separated keywords (e.g., 'Lead Data Engineer,Analytics Lead')")
    parser.add_argument("--location", default="Remote", help="Job location (e.g., 'Ho Chi Minh City,Remote')")
    parser.add_argument("--boards", default="indeed,remote", help="Job boards to scrape (indeed,glassdoor,remote)")
    parser.add_argument("--output", default="outputs/job_listings/", help="Output directory")
    parser.add_argument("--headless", action="store_true", help="Run browser in headless mode")
    
    args = parser.parse_args()
    
    keywords = [k.strip() for k in args.keywords.split(',')]
    locations = [l.strip() for l in args.location.split(',')]
    boards = [b.strip() for b in args.boards.split(',')]
    
    scraper = JobScraper(headless=args.headless)
    all_jobs = []
    
    for location in locations:
        if 'indeed' in boards:
            jobs = scraper.scrape_indeed(keywords, location)
            all_jobs.extend(jobs)
        
        if 'glassdoor' in boards:
            jobs = scraper.scrape_glassdoor(keywords, location)
            all_jobs.extend(jobs)
    
    if 'remote' in boards:
        jobs = scraper.scrape_remote_boards(keywords)
        all_jobs.extend(jobs)
    
    # Deduplicate
    all_jobs = scraper.deduplicate(all_jobs)
    
    # Filter by keywords
    all_jobs = scraper.filter_by_keywords(all_jobs, keywords)
    
    # Save results
    scraper.save_results(all_jobs, args.output)


if __name__ == "__main__":
    main()

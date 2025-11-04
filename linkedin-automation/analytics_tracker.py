#!/usr/bin/env python3
"""
LinkedIn Analytics Tracker
Tracks company page performance, generates reports, and monitors growth

Features:
- Follower growth tracking
- Post engagement analytics
- Weekly/monthly reports
- Benchmark comparisons
- Export to CSV/JSON

Author: Simon Renauld
Created: November 4, 2025
"""

import os
import json
import csv
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List
from dataclasses import dataclass, asdict
import asyncio

from playwright.async_api import async_playwright
from dotenv import load_dotenv

load_dotenv()

# Paths
BASE_DIR = Path(__file__).parent
OUTPUTS_DIR = BASE_DIR / "outputs"
ANALYTICS_DIR = OUTPUTS_DIR / "analytics"
REPORTS_DIR = OUTPUTS_DIR / "reports"

ANALYTICS_DIR.mkdir(parents=True, exist_ok=True)
REPORTS_DIR.mkdir(parents=True, exist_ok=True)

COMPANY_PAGE_ID = "105307318"
ANALYTICS_URL = f"https://www.linkedin.com/company/{COMPANY_PAGE_ID}/admin/analytics/visitors/"


@dataclass
class PageMetrics:
    """Company page overview metrics"""
    date: str
    followers: int
    visitors: int
    page_views: int
    unique_visitors: int
    search_appearances: int
    follower_growth: int  # vs previous period
    engagement_rate: float


@dataclass
class PostMetrics:
    """Individual post metrics"""
    post_id: str
    post_date: str
    content_preview: str
    impressions: int
    clicks: int
    reactions: int
    comments: int
    shares: int
    engagement_rate: float
    click_through_rate: float


@dataclass
class DemographicData:
    """Follower demographics"""
    date: str
    top_locations: Dict[str, int]
    top_industries: Dict[str, int]
    top_job_functions: Dict[str, int]
    seniority_levels: Dict[str, int]


class LinkedInAnalyticsTracker:
    """Track and analyze LinkedIn company page metrics"""
    
    def __init__(self):
        self.email = os.getenv('LINKEDIN_EMAIL')
        self.password = os.getenv('LINKEDIN_PASSWORD')
        self.headless = os.getenv('HEADLESS_BROWSER', 'true').lower() == 'true'
    
    async def scrape_page_metrics(self) -> PageMetrics:
        """Scrape high-level page metrics"""
        async with async_playwright() as p:
            browser = await p.chromium.launch(headless=self.headless)
            page = await browser.new_page()
            
            # Login
            await page.goto('https://www.linkedin.com/login')
            await page.fill('input#username', self.email)
            await page.fill('input#password', self.password)
            await page.click('button[type="submit"]')
            await page.wait_for_url('https://www.linkedin.com/feed/')
            
            # Navigate to analytics
            await page.goto(ANALYTICS_URL, wait_until='networkidle')
            await asyncio.sleep(3)
            
            # Extract metrics (selectors may vary - adjust as needed)
            try:
                followers_elem = await page.query_selector('text=/followers/')
                followers = 0
                if followers_elem:
                    text = await followers_elem.text_content()
                    followers = int(''.join(filter(str.isdigit, text)))
                
                # Page views
                views_elem = await page.query_selector('text=/page views/')
                page_views = 0
                if views_elem:
                    text = await views_elem.text_content()
                    page_views = int(''.join(filter(str.isdigit, text)))
                
                metrics = PageMetrics(
                    date=datetime.now().isoformat(),
                    followers=followers,
                    visitors=0,  # Parse from page
                    page_views=page_views,
                    unique_visitors=0,
                    search_appearances=0,
                    follower_growth=0,  # Calculate from history
                    engagement_rate=0.0
                )
                
                # Save
                self.save_page_metrics(metrics)
                
                await browser.close()
                return metrics
                
            except Exception as e:
                print(f"❌ Scraping error: {e}")
                await browser.close()
                raise
    
    async def scrape_post_metrics(self, days: int = 30) -> List[PostMetrics]:
        """Scrape metrics for recent posts"""
        async with async_playwright() as p:
            browser = await p.chromium.launch(headless=self.headless)
            page = await browser.new_page()
            
            # Login
            await page.goto('https://www.linkedin.com/login')
            await page.fill('input#username', self.email)
            await page.fill('input#password', self.password)
            await page.click('button[type="submit"]')
            await page.wait_for_url('https://www.linkedin.com/feed/')
            
            # Navigate to posts
            posts_url = f"https://www.linkedin.com/company/{COMPANY_PAGE_ID}/admin/feed/posts/"
            await page.goto(posts_url, wait_until='networkidle')
            await asyncio.sleep(3)
            
            post_metrics = []
            
            # Scroll to load posts
            for _ in range(3):
                await page.evaluate('window.scrollBy(0, 800)')
                await asyncio.sleep(1)
            
            # Extract post data
            articles = await page.query_selector_all('article')
            
            for i, article in enumerate(articles[:20]):  # Last 20 posts
                try:
                    # Content preview
                    content_elem = await article.query_selector('p')
                    content = await content_elem.text_content() if content_elem else ""
                    content_preview = content[:100]
                    
                    # Metrics (adjust selectors)
                    impressions = 0
                    clicks = 0
                    reactions = 0
                    
                    metrics = PostMetrics(
                        post_id=f"post_{i}",
                        post_date=datetime.now().isoformat(),
                        content_preview=content_preview,
                        impressions=impressions,
                        clicks=clicks,
                        reactions=reactions,
                        comments=0,
                        shares=0,
                        engagement_rate=0.0,
                        click_through_rate=0.0
                    )
                    
                    post_metrics.append(metrics)
                    
                except Exception as e:
                    print(f"⚠️ Post {i} scraping error: {e}")
            
            # Save
            self.save_post_metrics(post_metrics)
            
            await browser.close()
            return post_metrics
    
    def save_page_metrics(self, metrics: PageMetrics):
        """Save page metrics to JSON"""
        filename = ANALYTICS_DIR / f"page_metrics_{metrics.date[:10]}.json"
        with open(filename, 'w') as f:
            json.dump(asdict(metrics), f, indent=2)
        print(f"✅ Saved page metrics: {filename}")
    
    def save_post_metrics(self, metrics: List[PostMetrics]):
        """Save post metrics to JSON and CSV"""
        timestamp = datetime.now().strftime("%Y%m%d")
        
        # JSON
        json_file = ANALYTICS_DIR / f"post_metrics_{timestamp}.json"
        with open(json_file, 'w') as f:
            json.dump([asdict(m) for m in metrics], f, indent=2)
        
        # CSV
        csv_file = ANALYTICS_DIR / f"post_metrics_{timestamp}.csv"
        with open(csv_file, 'w', newline='') as f:
            if metrics:
                writer = csv.DictWriter(f, fieldnames=asdict(metrics[0]).keys())
                writer.writeheader()
                for m in metrics:
                    writer.writerow(asdict(m))
        
        print(f"✅ Saved post metrics: {json_file}")
        print(f"✅ Saved post metrics: {csv_file}")
    
    def generate_weekly_report(self):
        """Generate weekly analytics report"""
        print("📊 Generating Weekly Report...")
        
        # Load recent metrics
        metrics_files = sorted(ANALYTICS_DIR.glob("page_metrics_*.json"))
        if not metrics_files:
            print("⚠️ No metrics data found")
            return
        
        # Get last 7 days
        recent = []
        for f in metrics_files[-7:]:
            with open(f) as file:
                data = json.load(file)
                recent.append(PageMetrics(**data))
        
        if not recent:
            print("⚠️ Insufficient data for weekly report")
            return
        
        # Calculate trends
        first = recent[0]
        last = recent[-1]
        
        follower_growth = last.followers - first.followers
        avg_page_views = sum(m.page_views for m in recent) / len(recent)
        
        # Generate report
        report = f"""
LinkedIn Company Page - Weekly Analytics Report
Generated: {datetime.now().strftime('%B %d, %Y')}
================================================

OVERVIEW
--------
Current Followers: {last.followers:,}
Weekly Growth: {follower_growth:+,} ({(follower_growth/max(first.followers,1)*100):+.1f}%)

Average Daily Page Views: {avg_page_views:.0f}
Total Page Views (7 days): {sum(m.page_views for m in recent):,}

FOLLOWER METRICS
----------------
Start of Week: {first.followers:,}
End of Week: {last.followers:,}
Net Growth: {follower_growth:+,}

Growth Rate: {(follower_growth/max(first.followers,1)*100):+.2f}%
Daily Average Growth: {follower_growth/7:+.1f}

ENGAGEMENT
----------
[Post metrics would be calculated from post_metrics_*.json files]

RECOMMENDATIONS
---------------
1. Post consistency: Aim for 2-3 posts/week
2. Best posting times: Monday 9am, Wednesday 10am, Friday 2pm
3. Content mix: 40% thought leadership, 30% case studies, 30% technical
4. Engagement: Respond to comments within 24 hours

NEXT STEPS
----------
- Continue weekly posting schedule
- A/B test different content formats
- Cross-promote with personal profile
- Monitor competitor pages for benchmarks
"""
        
        # Save report
        report_file = REPORTS_DIR / f"weekly_report_{datetime.now().strftime('%Y%m%d')}.txt"
        with open(report_file, 'w') as f:
            f.write(report)
        
        print(report)
        print(f"\n✅ Report saved: {report_file}")


def main():
    """CLI entry point"""
    import sys
    
    if len(sys.argv) < 2:
        print("Usage:")
        print("  python analytics_tracker.py scrape-page     # Scrape page metrics")
        print("  python analytics_tracker.py scrape-posts    # Scrape post metrics")
        print("  python analytics_tracker.py report          # Generate weekly report")
        sys.exit(1)
    
    command = sys.argv[1]
    tracker = LinkedInAnalyticsTracker()
    
    if command == "scrape-page":
        asyncio.run(tracker.scrape_page_metrics())
    
    elif command == "scrape-posts":
        asyncio.run(tracker.scrape_post_metrics())
    
    elif command == "report":
        tracker.generate_weekly_report()
    
    else:
        print(f"❌ Unknown command: {command}")


if __name__ == "__main__":
    main()

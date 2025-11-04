#!/usr/bin/env python3
"""
LinkedIn Company Page Automation Orchestrator
Manages the complete automation workflow:
1. Generate content
2. Schedule posts
3. Publish posts
4. Track analytics
5. Generate reports

Author: Simon Renauld
Created: November 4, 2025
"""

import asyncio
import json
import os
from datetime import datetime, timedelta
from pathlib import Path
from typing import List

from content_generator import ContentGenerator, ContentPost
from company_page_automation import LinkedInCompanyPageAutomation, PostScheduler, ScheduledPost
from analytics_tracker import LinkedInAnalyticsTracker

# Paths
BASE_DIR = Path(__file__).parent
CONFIG_DIR = BASE_DIR / "config"
LOGS_DIR = BASE_DIR / "outputs" / "logs"

LOGS_DIR.mkdir(parents=True, exist_ok=True)


class AutomationOrchestrator:
    """Orchestrates all LinkedIn automation tasks"""
    
    def __init__(self):
        self.content_generator = ContentGenerator()
        self.scheduler = PostScheduler()
        self.automation = LinkedInCompanyPageAutomation()
        self.analytics = LinkedInAnalyticsTracker()
        self.log_file = LOGS_DIR / f"orchestrator_{datetime.now().strftime('%Y%m%d')}.log"
    
    def log(self, message: str):
        """Log message to file and console"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        log_line = f"[{timestamp}] {message}"
        print(log_line)
        
        with open(self.log_file, 'a') as f:
            f.write(log_line + "\n")
    
    # ===== Weekly Workflow =====
    
    def setup_weekly_content(self):
        """Generate and schedule a week's content"""
        self.log("🎯 Setting up weekly content...")
        
        # Generate posts
        posts = [
            self.content_generator.get_healthcare_analytics_post(),
            self.content_generator.get_homelab_mlops_post(),
            self.content_generator.get_data_governance_post(),
        ]
        
        # Schedule at optimal times
        now = datetime.now()
        # Next Monday 9am
        next_monday = now + timedelta(days=(7 - now.weekday()) % 7)
        schedule_times = [
            next_monday.replace(hour=9, minute=0, second=0),
            next_monday.replace(hour=9, minute=0, second=0) + timedelta(days=2),  # Wed
            next_monday.replace(hour=9, minute=0, second=0) + timedelta(days=4),  # Fri
        ]
        
        # Add to scheduler
        for post, schedule_time in zip(posts, schedule_times):
            scheduled_post = ScheduledPost(
                id=post.id,
                content=post.content,
                media_type=post.media_type,
                media_paths=post.media_paths,
                scheduled_time=schedule_time.isoformat(),
                status='pending',
                tags=post.hashtags,
                link=post.link
            )
            self.scheduler.add_post(scheduled_post)
            self.log(f"  ✅ Scheduled: {post.title} for {schedule_time.strftime('%A, %b %d at %I:%M %p')}")
        
        self.log(f"✅ Weekly content setup complete: {len(posts)} posts scheduled")
    
    async def publish_pending_posts(self):
        """Publish all pending scheduled posts"""
        self.log("📤 Checking for pending posts...")
        
        pending = self.scheduler.get_pending_posts()
        
        if not pending:
            self.log("✅ No pending posts to publish")
            return
        
        self.log(f"📅 Found {len(pending)} pending posts")
        
        try:
            await self.automation.init_browser()
            await self.automation.login()
            
            for post in pending:
                try:
                    self.log(f"  Publishing: {post.id}")
                    
                    if post.media_type == 'text':
                        await self.automation.create_text_post(post.content, post.link)
                    elif post.media_type == 'image':
                        await self.automation.create_image_post(post.content, post.media_paths)
                    elif post.media_type == 'document':
                        await self.automation.create_document_post(post.content, post.media_paths[0])
                    
                    self.scheduler.mark_posted(post.id, "https://linkedin.com/company/105307318")
                    self.log(f"  ✅ Published: {post.id}")
                    
                    # Rate limiting
                    await asyncio.sleep(60)
                    
                except Exception as e:
                    self.log(f"  ❌ Failed to publish {post.id}: {e}")
                    self.scheduler.mark_failed(post.id, str(e))
        
        finally:
            await self.automation.close()
    
    async def scrape_analytics(self):
        """Scrape and save analytics"""
        self.log("📊 Scraping analytics...")
        
        try:
            # Page metrics
            page_metrics = await self.analytics.scrape_page_metrics()
            self.log(f"  ✅ Page metrics: {page_metrics.followers} followers")
            
            # Post metrics
            post_metrics = await self.analytics.scrape_post_metrics(days=30)
            self.log(f"  ✅ Post metrics: {len(post_metrics)} posts analyzed")
            
        except Exception as e:
            self.log(f"  ❌ Analytics scraping failed: {e}")
    
    def generate_weekly_report(self):
        """Generate weekly analytics report"""
        self.log("📄 Generating weekly report...")
        
        try:
            self.analytics.generate_weekly_report()
            self.log("  ✅ Report generated")
        except Exception as e:
            self.log(f"  ❌ Report generation failed: {e}")
    
    # ===== Automation Workflows =====
    
    async def run_daily_workflow(self):
        """Daily automation: publish pending posts + scrape analytics"""
        self.log("=" * 60)
        self.log("🤖 Starting DAILY workflow")
        self.log("=" * 60)
        
        # 1. Publish pending posts
        await self.publish_pending_posts()
        
        # 2. Scrape analytics
        await self.scrape_analytics()
        
        self.log("=" * 60)
        self.log("✅ Daily workflow complete")
        self.log("=" * 60)
    
    async def run_weekly_workflow(self):
        """Weekly automation: setup content + generate report"""
        self.log("=" * 60)
        self.log("🤖 Starting WEEKLY workflow")
        self.log("=" * 60)
        
        # 1. Setup next week's content
        self.setup_weekly_content()
        
        # 2. Generate weekly report
        self.generate_weekly_report()
        
        self.log("=" * 60)
        self.log("✅ Weekly workflow complete")
        self.log("=" * 60)


# ===== CLI =====

async def main():
    """CLI entry point"""
    import sys
    
    if len(sys.argv) < 2:
        print("""
LinkedIn Company Page Automation Orchestrator
==============================================

Usage:
  python orchestrator.py daily       # Run daily workflow (publish + analytics)
  python orchestrator.py weekly      # Run weekly workflow (setup content + report)
  python orchestrator.py setup       # Setup weekly content only
  python orchestrator.py publish     # Publish pending posts only
  python orchestrator.py analytics   # Scrape analytics only
  python orchestrator.py report      # Generate report only

Recommended Cron Schedule:
  # Daily: Publish pending posts + scrape analytics (Mon-Fri 10am)
  0 10 * * 1-5 cd /path/to/linkedin-automation && python orchestrator.py daily
  
  # Weekly: Setup content + generate report (Sunday 6pm)
  0 18 * * 0 cd /path/to/linkedin-automation && python orchestrator.py weekly
""")
        sys.exit(1)
    
    command = sys.argv[1]
    orchestrator = AutomationOrchestrator()
    
    if command == "daily":
        await orchestrator.run_daily_workflow()
    
    elif command == "weekly":
        await orchestrator.run_weekly_workflow()
    
    elif command == "setup":
        orchestrator.setup_weekly_content()
    
    elif command == "publish":
        await orchestrator.publish_pending_posts()
    
    elif command == "analytics":
        await orchestrator.scrape_analytics()
    
    elif command == "report":
        orchestrator.generate_weekly_report()
    
    else:
        print(f"❌ Unknown command: {command}")
        sys.exit(1)


if __name__ == "__main__":
    asyncio.run(main())

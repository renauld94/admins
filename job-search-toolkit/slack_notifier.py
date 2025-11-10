#!/usr/bin/env python3
"""
Slack Integration - Real-time job search notifications
Sends Slack messages for jobs, responses, and interviews
Created: November 10, 2025
"""

import json
import requests
import sqlite3
from pathlib import Path
from datetime import datetime
from typing import Dict, List

BASE_DIR = Path(__file__).parent
DATA_DIR = BASE_DIR / "data"
CONFIG_DIR = BASE_DIR / "config"

class SlackNotifier:
    def __init__(self, webhook_url: str):
        """Initialize Slack notifier with webhook URL"""
        self.webhook_url = webhook_url
        self.db_path = DATA_DIR / "job_search.db"
    
    def send_message(self, message: Dict) -> bool:
        """Send message to Slack"""
        try:
            response = requests.post(self.webhook_url, json=message)
            response.raise_for_status()
            return True
        except Exception as e:
            print(f"❌ Error sending Slack message: {e}")
            return False
    
    def notify_high_scoring_job(self, job: Dict) -> bool:
        """Notify about high-scoring job (score >85)"""
        message = {
            "blocks": [
                {
                    "type": "header",
                    "text": {
                        "type": "plain_text",
                        "text": f"🎯 High-Scoring Job Match!"
                    }
                },
                {
                    "type": "section",
                    "fields": [
                        {
                            "type": "mrkdwn",
                            "text": f"*Role:*\n{job['title']}"
                        },
                        {
                            "type": "mrkdwn",
                            "text": f"*Company:*\n{job['company']}"
                        },
                        {
                            "type": "mrkdwn",
                            "text": f"*Location:*\n{job['location']}"
                        },
                        {
                            "type": "mrkdwn",
                            "text": f"*Match Score:*\n{job['relevance_score']}/100"
                        }
                    ]
                },
                {
                    "type": "section",
                    "text": {
                        "type": "mrkdwn",
                        "text": f"*Salary Range:* {job['salary_range'] or 'Not specified'}\n*Posted:* {job['posted_date']}"
                    }
                },
                {
                    "type": "actions",
                    "elements": [
                        {
                            "type": "button",
                            "text": {
                                "type": "plain_text",
                                "text": "View Job"
                            },
                            "url": job['job_url'],
                            "style": "primary"
                        }
                    ]
                }
            ]
        }
        return self.send_message(message)
    
    def notify_linkedin_response(self, contact: Dict) -> bool:
        """Notify about LinkedIn response received"""
        message = {
            "blocks": [
                {
                    "type": "header",
                    "text": {
                        "type": "plain_text",
                        "text": "💬 LinkedIn Response Received!"
                    }
                },
                {
                    "type": "section",
                    "fields": [
                        {
                            "type": "mrkdwn",
                            "text": f"*From:*\n{contact.get('name', 'Unknown')}"
                        },
                        {
                            "type": "mrkdwn",
                            "text": f"*Company:*\n{contact.get('company', 'N/A')}"
                        },
                        {
                            "type": "mrkdwn",
                            "text": f"*Title:*\n{contact.get('title', 'N/A')}"
                        },
                        {
                            "type": "mrkdwn",
                            "text": f"*Time:*\n{datetime.now().strftime('%H:%M')}"
                        }
                    ]
                },
                {
                    "type": "section",
                    "text": {
                        "type": "mrkdwn",
                        "text": f"{contact.get('message', 'No message content')}"
                    }
                }
            ]
        }
        return self.send_message(message)
    
    def notify_interview_invitation(self, interview: Dict) -> bool:
        """Notify about interview invitation"""
        message = {
            "blocks": [
                {
                    "type": "header",
                    "text": {
                        "type": "plain_text",
                        "text": "🎉 Interview Invitation!"
                    }
                },
                {
                    "type": "section",
                    "fields": [
                        {
                            "type": "mrkdwn",
                            "text": f"*Company:*\n{interview.get('company', 'Unknown')}"
                        },
                        {
                            "type": "mrkdwn",
                            "text": f"*Position:*\n{interview.get('position', 'Unknown')}"
                        },
                        {
                            "type": "mrkdwn",
                            "text": f"*Round:*\n{interview.get('round', '1')}"
                        },
                        {
                            "type": "mrkdwn",
                            "text": f"*Scheduled:*\n{interview.get('datetime', 'TBD')}"
                        }
                    ]
                },
                {
                    "type": "section",
                    "text": {
                        "type": "mrkdwn",
                        "text": f"*Interviewer:* {interview.get('interviewer', 'N/A')}\n*Details:* {interview.get('details', 'No additional details')}"
                    }
                }
            ]
        }
        return self.send_message(message)
    
    def notify_job_offer(self, offer: Dict) -> bool:
        """Notify about job offer received"""
        message = {
            "blocks": [
                {
                    "type": "header",
                    "text": {
                        "type": "plain_text",
                        "text": "🎊 JOB OFFER RECEIVED!"
                    }
                },
                {
                    "type": "section",
                    "fields": [
                        {
                            "type": "mrkdwn",
                            "text": f"*Company:*\n{offer.get('company', 'Unknown')}"
                        },
                        {
                            "type": "mrkdwn",
                            "text": f"*Position:*\n{offer.get('position', 'Unknown')}"
                        },
                        {
                            "type": "mrkdwn",
                            "text": f"*Base Salary:*\n${offer.get('salary', 0):,.0f}"
                        },
                        {
                            "type": "mrkdwn",
                            "text": f"*Total Comp:*\n${offer.get('total_comp', 0):,.0f}"
                        }
                    ]
                },
                {
                    "type": "section",
                    "text": {
                        "type": "mrkdwn",
                        "text": f"*Equity:* {offer.get('equity', 'N/A')}\n*Benefits:* {offer.get('benefits', 'N/A')}\n*Response Deadline:* {offer.get('deadline', 'TBD')}"
                    }
                },
                {
                    "type": "actions",
                    "elements": [
                        {
                            "type": "button",
                            "text": {
                                "type": "plain_text",
                                "text": "View Full Offer"
                            },
                            "url": offer.get('offer_url', '#'),
                            "style": "primary"
                        }
                    ]
                }
            ]
        }
        return self.send_message(message)
    
    def notify_daily_summary(self, metrics: Dict) -> bool:
        """Send daily metrics summary"""
        message = {
            "blocks": [
                {
                    "type": "header",
                    "text": {
                        "type": "plain_text",
                        "text": "📊 Daily Job Search Summary"
                    }
                },
                {
                    "type": "section",
                    "fields": [
                        {
                            "type": "mrkdwn",
                            "text": f"*Jobs Discovered:*\n{metrics.get('jobs_discovered', 0)}"
                        },
                        {
                            "type": "mrkdwn",
                            "text": f"*Applications Sent:*\n{metrics.get('applications_sent', 0)}"
                        },
                        {
                            "type": "mrkdwn",
                            "text": f"*High-Scoring Jobs:*\n{metrics.get('high_scoring', 0)}"
                        },
                        {
                            "type": "mrkdwn",
                            "text": f"*LinkedIn Actions:*\n{metrics.get('linkedin_actions', 0)}"
                        }
                    ]
                },
                {
                    "type": "section",
                    "text": {
                        "type": "mrkdwn",
                        "text": f"*Top Company Today:* {metrics.get('top_company', 'N/A')}\n*Response Rate:* {metrics.get('response_rate', 'Calculating...')}%"
                    }
                }
            ]
        }
        return self.send_message(message)
    
    def setup_instructions(self) -> str:
        """Get setup instructions"""
        return """
✅ TO SET UP SLACK NOTIFICATIONS:

1. Create Slack App & Webhook:
   a) Go to: https://api.slack.com/apps
   b) Click "Create New App" → "From scratch"
   c) Name: "Job Search Bot"
   d) Choose workspace
   e) Go to "Incoming Webhooks"
   f) Click "Add New Webhook to Workspace"
   g) Select channel (e.g., #job-search)
   h) Copy the Webhook URL

2. Add to .env file:
   SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL

3. Test it:
   python3 -c "
   from slack_notifier import SlackNotifier
   notifier = SlackNotifier('YOUR_WEBHOOK_URL')
   
   test_job = {
        'title': 'Lead Data Engineer',
        'company': 'Test Company',
        'location': 'Remote',
        'relevance_score': 92,
        'salary_range': '$200K-$250K',
        'posted_date': 'Today',
        'job_url': 'https://example.com'
   }
   notifier.notify_high_scoring_job(test_job)
   "

4. Add to cron job:
   In your daily_run script, add:
   
   python3 -c "
   from slack_notifier import SlackNotifier
   notifier = SlackNotifier(os.getenv('SLACK_WEBHOOK_URL'))
   notifier.notify_daily_summary({
       'jobs_discovered': 45,
       'applications_sent': 3,
       'high_scoring': 12,
       'linkedin_actions': 8
   })
   "

5. You'll get notifications for:
   ✅ High-scoring jobs (>85)
   ✅ LinkedIn responses
   ✅ Interview invitations
   ✅ Job offers
   ✅ Daily summary metrics
"""

if __name__ == "__main__":
    import os
    from dotenv import load_dotenv
    
    load_dotenv()
    
    webhook_url = os.getenv("SLACK_WEBHOOK_URL")
    
    if not webhook_url:
        notifier = SlackNotifier("")
        print(notifier.setup_instructions())
    else:
        notifier = SlackNotifier(webhook_url)
        
        # Test notification
        test_job = {
            'title': 'Lead Data Engineer',
            'company': 'Shopee',
            'location': 'Singapore',
            'relevance_score': 92,
            'salary_range': '$200K-$250K',
            'posted_date': 'Today',
            'job_url': 'https://example.com/job'
        }
        
        if notifier.notify_high_scoring_job(test_job):
            print("✅ Test notification sent successfully!")
        else:
            print("❌ Failed to send test notification")

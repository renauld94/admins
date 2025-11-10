#!/usr/bin/env python3
"""
Daily Email Digest - Automated job search updates
Sends daily email with top job matches and metrics
Created: November 10, 2025
"""

import smtplib
import json
import sqlite3
from pathlib import Path
from datetime import datetime
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from typing import List, Dict

BASE_DIR = Path(__file__).parent
CONFIG_DIR = BASE_DIR / "config"
DATA_DIR = BASE_DIR / "data"

class EmailDigest:
    def __init__(self, email: str, password: str, smtp_server: str = "smtp.gmail.com", smtp_port: int = 587):
        """Initialize email digest system"""
        self.sender_email = email
        self.password = password
        self.smtp_server = smtp_server
        self.smtp_port = smtp_port
        self.db_path = DATA_DIR / "job_search.db"
    
    def get_top_jobs(self, limit: int = 5) -> List[Dict]:
        """Get top scoring jobs from database"""
        try:
            with sqlite3.connect(self.db_path) as conn:
                conn.row_factory = sqlite3.Row
                cursor = conn.execute("""
                    SELECT title, company, location, salary_range, job_url, 
                           relevance_score, posted_date, description
                    FROM jobs
                    WHERE relevance_score >= 75
                    ORDER BY relevance_score DESC, discovered_at DESC
                    LIMIT ?
                """, (limit,))
                
                jobs = [dict(row) for row in cursor.fetchall()]
                return jobs
        except Exception as e:
            print(f"❌ Error fetching jobs: {e}")
            return []
    
    def get_daily_metrics(self) -> Dict:
        """Get daily job search metrics"""
        try:
            with sqlite3.connect(self.db_path) as conn:
                # Total jobs discovered
                cursor = conn.execute("SELECT COUNT(*) FROM jobs")
                total_jobs = cursor.fetchone()[0]
                
                # Applications sent
                cursor = conn.execute("SELECT COUNT(*) FROM applications")
                applications_sent = cursor.fetchone()[0]
                
                # High-scoring jobs (>80)
                cursor = conn.execute("SELECT COUNT(*) FROM jobs WHERE relevance_score >= 80")
                high_score_jobs = cursor.fetchone()[0]
                
                # LinkedIn activities
                cursor = conn.execute("SELECT COUNT(*) FROM linkedin_interactions")
                linkedin_actions = cursor.fetchone()[0]
                
                return {
                    'total_jobs': total_jobs,
                    'applications_sent': applications_sent,
                    'high_scoring_jobs': high_score_jobs,
                    'linkedin_actions': linkedin_actions,
                    'date': datetime.now().strftime('%Y-%m-%d')
                }
        except Exception as e:
            print(f"❌ Error getting metrics: {e}")
            return {}
    
    def create_email_body(self) -> tuple:
        """Create HTML and text email body"""
        metrics = self.get_daily_metrics()
        top_jobs = self.get_top_jobs(5)
        
        # HTML version
        html = f"""
        <html>
            <body style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto;">
                <div style="background-color: #1e1e1e; color: #fff; padding: 20px; text-align: center;">
                    <h1>🚀 Daily Job Search Update</h1>
                    <p>{datetime.now().strftime('%A, %B %d, %Y')}</p>
                </div>
                
                <div style="padding: 20px;">
                    <h2>📊 Today's Metrics</h2>
                    <table style="width: 100%; border-collapse: collapse;">
                        <tr style="background-color: #f0f0f0;">
                            <td style="padding: 10px; border: 1px solid #ddd;"><strong>Total Jobs Discovered</strong></td>
                            <td style="padding: 10px; border: 1px solid #ddd; text-align: right;"><strong>{metrics.get('total_jobs', 0)}</strong></td>
                        </tr>
                        <tr>
                            <td style="padding: 10px; border: 1px solid #ddd;">Applications Sent</td>
                            <td style="padding: 10px; border: 1px solid #ddd; text-align: right;">{metrics.get('applications_sent', 0)}</td>
                        </tr>
                        <tr style="background-color: #f0f0f0;">
                            <td style="padding: 10px; border: 1px solid #ddd;">High-Scoring Jobs (>80)</td>
                            <td style="padding: 10px; border: 1px solid #ddd; text-align: right;">{metrics.get('high_scoring_jobs', 0)}</td>
                        </tr>
                        <tr>
                            <td style="padding: 10px; border: 1px solid #ddd;">LinkedIn Actions</td>
                            <td style="padding: 10px; border: 1px solid #ddd; text-align: right;">{metrics.get('linkedin_actions', 0)}</td>
                        </tr>
                    </table>
                    
                    <h2 style="margin-top: 30px;">🎯 Top 5 Job Matches</h2>
        """
        
        if top_jobs:
            for i, job in enumerate(top_jobs, 1):
                score_color = '#28a745' if job['relevance_score'] >= 85 else '#ffc107'
                html += f"""
                    <div style="border: 1px solid #ddd; padding: 15px; margin-bottom: 10px; border-radius: 5px;">
                        <h3 style="margin-top: 0;">{i}. {job['title']} at {job['company']}</h3>
                        <p><strong>Location:</strong> {job['location']}</p>
                        <p><strong>Salary:</strong> {job['salary_range'] or 'Not specified'}</p>
                        <p><strong>Match Score:</strong> <span style="background-color: {score_color}; color: white; padding: 3px 8px; border-radius: 3px;">{job['relevance_score']}/100</span></p>
                        <p><strong>Posted:</strong> {job['posted_date']}</p>
                        <p><a href="{job['job_url']}" style="background-color: #007bff; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block;">View Job</a></p>
                    </div>
                """
        else:
            html += "<p>No high-scoring jobs today. Check back tomorrow!</p>"
        
        html += """
                    <h2 style="margin-top: 30px;">💡 Next Steps</h2>
                    <ul>
                        <li>Review the top matches above</li>
                        <li>Check your LinkedIn for new messages</li>
                        <li>Follow up on pending applications (after 5-7 days)</li>
                        <li>Update your profile if needed</li>
                    </ul>
                    
                    <hr style="margin-top: 30px;">
                    <p style="color: #666; font-size: 12px; text-align: center;">
                        This is an automated message from your EPIC Job Search System.
                        <br>Next update: Tomorrow at 7:00 AM UTC+7
                    </p>
                </div>
            </body>
        </html>
        """
        
        # Text version
        text = f"""
DAILY JOB SEARCH UPDATE
{datetime.now().strftime('%A, %B %d, %Y')}

📊 TODAY'S METRICS
Total Jobs Discovered: {metrics.get('total_jobs', 0)}
Applications Sent: {metrics.get('applications_sent', 0)}
High-Scoring Jobs (>80): {metrics.get('high_scoring_jobs', 0)}
LinkedIn Actions: {metrics.get('linkedin_actions', 0)}

🎯 TOP 5 JOB MATCHES
"""
        
        if top_jobs:
            for i, job in enumerate(top_jobs, 1):
                text += f"""
{i}. {job['title']} at {job['company']}
   Location: {job['location']}
   Salary: {job['salary_range'] or 'Not specified'}
   Match Score: {job['relevance_score']}/100
   Posted: {job['posted_date']}
   View: {job['job_url']}
"""
        
        text += """
💡 NEXT STEPS
- Review the top matches above
- Check your LinkedIn for new messages
- Follow up on pending applications (after 5-7 days)
- Update your profile if needed

This is an automated message from your EPIC Job Search System.
Next update: Tomorrow at 7:00 AM UTC+7
"""
        
        return html, text
    
    def send_email(self, recipient_email: str, subject: str = None) -> bool:
        """Send email digest"""
        try:
            if subject is None:
                subject = f"🚀 Daily Job Search Update - {datetime.now().strftime('%B %d, %Y')}"
            
            # Create message
            message = MIMEMultipart("alternative")
            message["Subject"] = subject
            message["From"] = self.sender_email
            message["To"] = recipient_email
            
            # Get email content
            html, text = self.create_email_body()
            
            # Attach parts
            part1 = MIMEText(text, "plain")
            part2 = MIMEText(html, "html")
            message.attach(part1)
            message.attach(part2)
            
            # Send email
            with smtplib.SMTP(self.smtp_server, self.smtp_port) as server:
                server.starttls()
                server.login(self.sender_email, self.password)
                server.sendmail(self.sender_email, recipient_email, message.as_string())
            
            print(f"✅ Email sent to {recipient_email}")
            return True
        
        except Exception as e:
            print(f"❌ Error sending email: {e}")
            return False
    
    def setup_automated_emails(self, recipient_email: str):
        """Instructions for setting up automated emails"""
        return f"""
✅ TO SET UP AUTOMATED DAILY EMAILS:

1. Update your credentials:
   Edit your .env file with:
   GMAIL_EMAIL=your_email@gmail.com
   GMAIL_PASSWORD=your_app_password
   
   (Generate app password at: https://myaccount.google.com/apppasswords)

2. Add to daily cron job:
   crontab -e
   
   Add line:
   0 7 * * * cd /home/simon/Learning-Management-System-Academy/job-search-toolkit && \\
     python3 -c "from email_digest import EmailDigest; d = EmailDigest('YOUR_EMAIL', 'YOUR_PASSWORD'); d.send_email('{recipient_email}')" >> outputs/logs/email.log 2>&1

3. Test it:
   python3 -c "from email_digest import EmailDigest; d = EmailDigest('your_email@gmail.com', 'your_password'); d.send_email('{recipient_email}')"

Daily digest will arrive at 7:00 AM UTC+7 with:
- Top 5 job matches
- Daily metrics
- LinkedIn activity summary
- Next steps
"""

# CLI
if __name__ == "__main__":
    import os
    from dotenv import load_dotenv
    
    load_dotenv()
    
    email = os.getenv("GMAIL_EMAIL")
    password = os.getenv("GMAIL_PASSWORD")
    recipient = os.getenv("RECIPIENT_EMAIL", email)
    
    if not email or not password:
        digest = EmailDigest("", "")
        print(digest.setup_automated_emails(recipient))
    else:
        digest = EmailDigest(email, password)
        digest.send_email(recipient)

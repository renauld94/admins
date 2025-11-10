#!/usr/bin/env python3
"""
Email Delivery System - Send resumes and cover letters
Supports: Gmail (SMTP), MailHog (local testing), or manual email management
"""

import smtplib
import os
import json
from pathlib import Path
from datetime import datetime
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email import encoders

class EmailDeliverySystem:
    """Manage email sending for job applications"""
    
    # Your email addresses
    TARGET_EMAILS = [
        "contact@simondatalab.de",  # Primary professional email
        "sn@gmail.com"  # Backup Gmail
    ]
    
    def __init__(self):
        """Initialize email system"""
        self.setup_smtp()
        self.create_log_dir()
    
    def setup_smtp(self):
        """Configure SMTP settings from environment variables"""
        self.smtp_method = os.getenv("EMAIL_METHOD", "mailhog").lower()
        
        if self.smtp_method == "gmail":
            self.smtp_config = {
                "server": "smtp.gmail.com",
                "port": 587,
                "email": os.getenv("GMAIL_EMAIL"),
                "password": os.getenv("GMAIL_PASSWORD"),
                "use_tls": True
            }
        elif self.smtp_method == "mailhog":
            # Local testing with MailHog
            self.smtp_config = {
                "server": "localhost",
                "port": 1025,
                "email": None,
                "password": None,
                "use_tls": False
            }
        else:
            # Manual / external email service
            self.smtp_config = {
                "method": "manual",
                "note": "Save email files for manual sending"
            }
    
    def create_log_dir(self):
        """Create logging directory"""
        self.log_dir = Path("outputs/email_log")
        self.log_dir.mkdir(parents=True, exist_ok=True)
    
    def send_application(self, recipient_email: str, job_title: str, company: str,
                        resume_file: str, cover_letter_file: str,
                        from_email: str = "contact@simondatalab.de") -> dict:
        """Send application email with attachments"""
        
        result = {
            "timestamp": datetime.now().isoformat(),
            "recipient": recipient_email,
            "job": f"{job_title} @ {company}",
            "from": from_email,
            "status": "pending",
            "method": self.smtp_method
        }
        
        try:
            # Create email message
            msg = MIMEMultipart()
            msg['From'] = from_email
            msg['To'] = recipient_email
            msg['Subject'] = f"Application: {job_title} at {company}"
            
            # Email body
            body = f"""Dear Hiring Manager,

Please find attached my application for the {job_title} position at {company}.

I am very interested in this opportunity and believe my experience aligns well with your needs.

Thank you for considering my application.

Best regards,
Simon Renauld
Data Engineering Expert
contact@simondatalab.de | sn@gmail.com
linkedin.com/in/simonrenauld
"""
            
            msg.attach(MIMEText(body, 'plain'))
            
            # Attach resume
            if Path(resume_file).exists():
                self._attach_file(msg, resume_file, "Simon_Renauld_Resume.txt")
            
            # Attach cover letter
            if Path(cover_letter_file).exists():
                self._attach_file(msg, cover_letter_file, f"Cover_Letter_{company}.txt")
            
            # Send via appropriate method
            if self.smtp_method == "mailhog":
                self._send_via_mailhog(msg, from_email, recipient_email, result)
            elif self.smtp_method == "gmail":
                self._send_via_gmail(msg, result)
            else:
                self._save_for_manual_send(msg, recipient_email, job_title, company, result)
            
            return result
            
        except Exception as e:
            result["status"] = "failed"
            result["error"] = str(e)
            return result
    
    def _attach_file(self, msg, file_path, display_name):
        """Attach a file to email"""
        try:
            with open(file_path, 'rb') as attachment:
                part = MIMEBase('application', 'octet-stream')
                part.set_payload(attachment.read())
                encoders.encode_base64(part)
                part.add_header('Content-Disposition', f'attachment; filename= {display_name}')
                msg.attach(part)
        except:
            print(f"⚠️  Could not attach {file_path}")
    
    def _send_via_mailhog(self, msg, from_email, to_email, result):
        """Send via local MailHog server (for testing)"""
        try:
            server = smtplib.SMTP(self.smtp_config["server"], self.smtp_config["port"])
            server.sendmail(from_email, to_email, msg.as_string())
            server.quit()
            result["status"] = "sent_mailhog"
            print(f"✅ Sent via MailHog to {to_email}")
        except Exception as e:
            result["status"] = "failed_mailhog"
            result["error"] = str(e)
            print(f"❌ MailHog error: {e}")
    
    def _send_via_gmail(self, msg, result):
        """Send via Gmail SMTP"""
        try:
            if not self.smtp_config["email"] or not self.smtp_config["password"]:
                raise ValueError("Gmail credentials not configured in .env")
            
            server = smtplib.SMTP(self.smtp_config["server"], self.smtp_config["port"])
            server.starttls()
            server.login(self.smtp_config["email"], self.smtp_config["password"])
            server.send_message(msg)
            server.quit()
            result["status"] = "sent_gmail"
            print(f"✅ Sent via Gmail to {msg['To']}")
        except Exception as e:
            result["status"] = "failed_gmail"
            result["error"] = str(e)
            print(f"❌ Gmail error: {e}")
    
    def _save_for_manual_send(self, msg, to_email, job_title, company, result):
        """Save email for manual sending"""
        safe_company = company.replace(" ", "_").replace("/", "_")
        email_file = self.log_dir / f"{datetime.now().strftime('%Y%m%d_%H%M%S')}_{safe_company}_{job_title[:20]}.eml"
        
        try:
            email_file.write_text(msg.as_string())
            result["status"] = "saved_for_manual"
            result["file_path"] = str(email_file)
            print(f"💾 Email saved for manual sending: {email_file}")
        except Exception as e:
            result["status"] = "failed_save"
            result["error"] = str(e)
    
    def send_bulk_applications(self, applications: list):
        """Send multiple applications"""
        print("\n" + "="*80)
        print("📧 SENDING APPLICATIONS")
        print("="*80 + "\n")
        
        results = []
        
        for app in applications:
            print(f"📨 Sending: {app['job_title']} @ {app['company']}")
            
            # Send to primary email (contact@simondatalab.de)
            result1 = self.send_application(
                recipient_email="contact@simondatalab.de",
                job_title=app['job_title'],
                company=app['company'],
                resume_file=app['resume_file'],
                cover_letter_file=app['cover_letter_file'],
                from_email="contact@simondatalab.de"
            )
            results.append(result1)
            
            # Send to backup email (sn@gmail.com)
            result2 = self.send_application(
                recipient_email="sn@gmail.com",
                job_title=app['job_title'],
                company=app['company'],
                resume_file=app['resume_file'],
                cover_letter_file=app['cover_letter_file'],
                from_email="contact@simondatalab.de"
            )
            results.append(result2)
        
        # Save results log
        log_file = self.log_dir / f"application_log_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        log_file.write_text(json.dumps(results, indent=2))
        
        print(f"\n✅ Sent {len(applications)} applications")
        print(f"📋 Log saved to: {log_file}\n")
        
        return results


def setup_email_credentials():
    """Create .env file template for email setup"""
    
    env_file = Path(".env")
    
    if not env_file.exists():
        print("\n🔧 SETTING UP EMAIL CONFIGURATION\n")
        
        template = """# EMAIL CONFIGURATION
# Choose your email delivery method: mailhog, gmail, or manual

EMAIL_METHOD=mailhog

# Gmail Configuration (optional - only needed if using Gmail)
# To get app password: https://myaccount.google.com/apppasswords
GMAIL_EMAIL=your_email@gmail.com
GMAIL_PASSWORD=your_16_character_app_password

# Your contact emails (already configured in code)
# PRIMARY: contact@simondatalab.de
# BACKUP: sn@gmail.com
"""
        
        env_file.write_text(template)
        print("✅ Created .env file")
        print("📝 Edit .env file with your email settings")
        print("\n🎯 Email Method Options:")
        print("   1. 'mailhog' - Local testing (requires MailHog running on localhost:1025)")
        print("   2. 'gmail' - Production Gmail sending")
        print("   3. 'manual' - Save files for manual sending\n")
    else:
        print("✅ .env file already exists\n")


if __name__ == "__main__":
    # Setup credentials
    setup_email_credentials()
    
    # Test email system
    print("🧪 TESTING EMAIL SYSTEM\n")
    
    system = EmailDeliverySystem()
    
    print(f"📧 Email Method: {system.smtp_method}")
    print(f"📧 Target: contact@simondatalab.de, sn@gmail.com")
    print(f"💾 Log directory: {system.log_dir}\n")
    
    # Test with sample application
    sample_app = {
        "job_title": "Senior Data Engineer",
        "company": "Stripe",
        "resume_file": "outputs/applications/SAMPLE_RESUME.txt",
        "cover_letter_file": "outputs/applications/SAMPLE_COVER_LETTER.txt"
    }
    
    results = system.send_bulk_applications([sample_app])
    
    for r in results:
        print(f"  {r['recipient']}: {r['status']}")

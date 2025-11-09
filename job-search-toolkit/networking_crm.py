#!/usr/bin/env python3
"""
Networking CRM - Relationship Management & Follow-up Automation
===============================================================

Manages:
- Contact tracking (recruiters, hiring managers, peers)
- Interaction history
- Smart follow-up scheduling
- Relationship scoring
- Network analysis

Author: Simon Renauld
Created: November 9, 2025
"""

import sqlite3
import json
import logging
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass, asdict
from enum import Enum
import hashlib

# ===== CONFIGURATION =====
BASE_DIR = Path(__file__).parent
DATA_DIR = BASE_DIR / "data"
OUTPUTS_DIR = BASE_DIR / "outputs"
LOGS_DIR = OUTPUTS_DIR / "logs"

# Create directories
for d in [DATA_DIR, OUTPUTS_DIR, LOGS_DIR]:
    d.mkdir(parents=True, exist_ok=True)

# ===== LOGGING =====
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(LOGS_DIR / f"crm_{datetime.now().strftime('%Y%m%d')}.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


# ===== DATA MODELS =====

class ContactType(Enum):
    RECRUITER = "recruiter"
    HIRING_MANAGER = "hiring_manager"
    PEER = "peer"
    REFERRAL = "referral"
    COMPANY_CONTACT = "company_contact"


class InteractionType(Enum):
    CONNECTION = "connection"
    MESSAGE = "message"
    CALL = "call"
    EMAIL = "email"
    COFFEE_CHAT = "coffee_chat"
    INTERVIEW = "interview"
    OFFER = "offer"


@dataclass
class Contact:
    """Represents a networking contact"""
    id: str
    name: str
    title: str
    company: str
    contact_type: ContactType
    email: Optional[str] = None
    phone: Optional[str] = None
    linkedin_url: Optional[str] = None
    relationship_quality: int = 0  # 0-100
    value_score: int = 0  # 0-100
    last_interaction: Optional[str] = None
    interaction_count: int = 0
    notes: str = ""
    created_at: str = None
    next_followup: Optional[str] = None
    
    def __post_init__(self):
        if self.created_at is None:
            self.created_at = datetime.now().isoformat()


@dataclass
class Interaction:
    """Represents contact interaction"""
    id: str
    contact_id: str
    interaction_type: InteractionType
    date: str
    notes: str
    outcome: str  # positive, neutral, negative, no_response
    follow_up_required: bool = False
    follow_up_date: Optional[str] = None


class NetworkingCRM:
    """
    Comprehensive CRM for networking and relationship management
    """
    
    def __init__(self):
        self.db_path = DATA_DIR / "networking_crm.db"
        self.init_db()
        logger.info("🤝 Networking CRM initialized")
    
    def init_db(self):
        """Initialize CRM database"""
        conn = sqlite3.connect(self.db_path)
        c = conn.cursor()
        
        # Contacts table
        c.execute('''
            CREATE TABLE IF NOT EXISTS contacts (
                id TEXT PRIMARY KEY,
                name TEXT,
                title TEXT,
                company TEXT,
                contact_type TEXT,
                email TEXT,
                phone TEXT,
                linkedin_url TEXT UNIQUE,
                relationship_quality INTEGER,
                value_score INTEGER,
                last_interaction TEXT,
                interaction_count INTEGER,
                notes TEXT,
                created_at TEXT,
                next_followup TEXT
            )
        ''')
        
        # Interactions table
        c.execute('''
            CREATE TABLE IF NOT EXISTS interactions (
                id TEXT PRIMARY KEY,
                contact_id TEXT,
                interaction_type TEXT,
                date TEXT,
                notes TEXT,
                outcome TEXT,
                follow_up_required INTEGER,
                follow_up_date TEXT,
                FOREIGN KEY(contact_id) REFERENCES contacts(id)
            )
        ''')
        
        # Follow-ups table
        c.execute('''
            CREATE TABLE IF NOT EXISTS followups (
                id TEXT PRIMARY KEY,
                contact_id TEXT,
                type TEXT,
                scheduled_date TEXT,
                created_at TEXT,
                completed INTEGER,
                notes TEXT,
                FOREIGN KEY(contact_id) REFERENCES contacts(id)
            )
        ''')
        
        # Opportunity tracking
        c.execute('''
            CREATE TABLE IF NOT EXISTS opportunities (
                id TEXT PRIMARY KEY,
                contact_id TEXT,
                job_title TEXT,
                company TEXT,
                status TEXT,
                referred_by TEXT,
                created_at TEXT,
                notes TEXT,
                FOREIGN KEY(contact_id) REFERENCES contacts(id)
            )
        ''')
        
        conn.commit()
        conn.close()
        logger.info(f"✅ CRM database initialized: {self.db_path}")
    
    # ===== CONTACT MANAGEMENT =====
    
    def add_contact(self, contact: Contact) -> bool:
        """Add new contact to CRM"""
        try:
            conn = sqlite3.connect(self.db_path)
            c = conn.cursor()
            
            c.execute('''
                INSERT OR REPLACE INTO contacts VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                contact.id,
                contact.name,
                contact.title,
                contact.company,
                contact.contact_type.value,
                contact.email,
                contact.phone,
                contact.linkedin_url,
                contact.relationship_quality,
                contact.value_score,
                contact.last_interaction,
                contact.interaction_count,
                contact.notes,
                contact.created_at,
                contact.next_followup
            ))
            
            conn.commit()
            conn.close()
            logger.info(f"✅ Contact added: {contact.name} @ {contact.company}")
            return True
            
        except Exception as e:
            logger.error(f"❌ Failed to add contact: {e}")
            return False
    
    def get_contact(self, contact_id: str) -> Optional[Contact]:
        """Retrieve contact by ID"""
        conn = sqlite3.connect(self.db_path)
        c = conn.cursor()
        
        c.execute('SELECT * FROM contacts WHERE id = ?', (contact_id,))
        row = c.fetchone()
        conn.close()
        
        if not row:
            return None
        
        return Contact(
            id=row[0],
            name=row[1],
            title=row[2],
            company=row[3],
            contact_type=ContactType(row[4]),
            email=row[5],
            phone=row[6],
            linkedin_url=row[7],
            relationship_quality=row[8],
            value_score=row[9],
            last_interaction=row[10],
            interaction_count=row[11],
            notes=row[12],
            created_at=row[13],
            next_followup=row[14]
        )
    
    def get_contacts_by_type(self, contact_type: ContactType) -> List[Contact]:
        """Get all contacts of specific type"""
        conn = sqlite3.connect(self.db_path)
        c = conn.cursor()
        
        c.execute('''
            SELECT * FROM contacts 
            WHERE contact_type = ? 
            ORDER BY value_score DESC
        ''', (contact_type.value,))
        
        rows = c.fetchall()
        conn.close()
        
        contacts = []
        for row in rows:
            contacts.append(Contact(
                id=row[0],
                name=row[1],
                title=row[2],
                company=row[3],
                contact_type=ContactType(row[4]),
                email=row[5],
                phone=row[6],
                linkedin_url=row[7],
                relationship_quality=row[8],
                value_score=row[9],
                last_interaction=row[10],
                interaction_count=row[11],
                notes=row[12],
                created_at=row[13],
                next_followup=row[14]
            ))
        
        return contacts
    
    def get_contacts_by_company(self, company: str) -> List[Contact]:
        """Get all contacts at specific company"""
        conn = sqlite3.connect(self.db_path)
        c = conn.cursor()
        
        c.execute('''
            SELECT * FROM contacts 
            WHERE company = ? 
            ORDER BY value_score DESC
        ''', (company,))
        
        rows = c.fetchall()
        conn.close()
        
        contacts = []
        for row in rows:
            contacts.append(Contact(
                id=row[0],
                name=row[1],
                title=row[2],
                company=row[3],
                contact_type=ContactType(row[4]),
                email=row[5],
                phone=row[6],
                linkedin_url=row[7],
                relationship_quality=row[8],
                value_score=row[9],
                last_interaction=row[10],
                interaction_count=row[11],
                notes=row[12],
                created_at=row[13],
                next_followup=row[14]
            ))
        
        return contacts
    
    # ===== INTERACTION TRACKING =====
    
    def log_interaction(
        self,
        contact_id: str,
        interaction_type: InteractionType,
        notes: str,
        outcome: str,
        follow_up_required: bool = False,
        follow_up_days: int = 7
    ) -> bool:
        """Log interaction with contact"""
        try:
            interaction_id = hashlib.md5(
                f"{contact_id}_{interaction_type.value}_{datetime.now().isoformat()}".encode()
            ).hexdigest()[:8]
            
            follow_up_date = None
            if follow_up_required:
                follow_up_date = (datetime.now() + timedelta(days=follow_up_days)).isoformat()
            
            conn = sqlite3.connect(self.db_path)
            c = conn.cursor()
            
            # Add interaction
            c.execute('''
                INSERT INTO interactions VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                interaction_id,
                contact_id,
                interaction_type.value,
                datetime.now().isoformat(),
                notes,
                outcome,
                1 if follow_up_required else 0,
                follow_up_date
            ))
            
            # Update contact
            c.execute('''
                UPDATE contacts 
                SET last_interaction = ?, interaction_count = interaction_count + 1, next_followup = ?
                WHERE id = ?
            ''', (datetime.now().isoformat(), follow_up_date, contact_id))
            
            # Update relationship quality based on outcome
            if outcome == "positive":
                c.execute('''
                    UPDATE contacts 
                    SET relationship_quality = MIN(100, relationship_quality + 10)
                    WHERE id = ?
                ''', (contact_id,))
            elif outcome == "negative":
                c.execute('''
                    UPDATE contacts 
                    SET relationship_quality = MAX(0, relationship_quality - 5)
                    WHERE id = ?
                ''', (contact_id,))
            
            conn.commit()
            conn.close()
            
            logger.info(f"✅ Interaction logged: {contact_id} ({interaction_type.value})")
            return True
            
        except Exception as e:
            logger.error(f"❌ Failed to log interaction: {e}")
            return False
    
    # ===== FOLLOW-UP MANAGEMENT =====
    
    def get_pending_followups(self) -> List[Tuple[Contact, List[Interaction]]]:
        """Get all contacts with pending follow-ups"""
        conn = sqlite3.connect(self.db_path)
        c = conn.cursor()
        
        now = datetime.now().isoformat()
        
        # Get contacts with overdue follow-ups
        c.execute('''
            SELECT * FROM contacts 
            WHERE next_followup IS NOT NULL 
            AND next_followup <= ?
            ORDER BY next_followup ASC
        ''', (now,))
        
        rows = c.fetchall()
        conn.close()
        
        pending = []
        for row in rows:
            contact = Contact(
                id=row[0],
                name=row[1],
                title=row[2],
                company=row[3],
                contact_type=ContactType(row[4]),
                email=row[5],
                phone=row[6],
                linkedin_url=row[7],
                relationship_quality=row[8],
                value_score=row[9],
                last_interaction=row[10],
                interaction_count=row[11],
                notes=row[12],
                created_at=row[13],
                next_followup=row[14]
            )
            pending.append((contact, []))
        
        return pending
    
    def generate_followup_template(self, contact: Contact) -> str:
        """Generate follow-up message template"""
        
        message = f"""Hi {contact.name},

It was great connecting with you recently. I wanted to follow up on our conversation about opportunities at {contact.company}.

I'm very interested in {contact.title} and similar roles on your team, particularly those involving:
- Python, SQL, and data platform architecture
- Apache Airflow and ETL pipeline design
- Cloud infrastructure (AWS/GCP)

Would love to chat about how I can contribute to your team's success.

Looking forward to hearing from you!

Best regards,
Simon Renauld"""
        
        return message
    
    # ===== OPPORTUNITY TRACKING =====
    
    def add_opportunity(
        self,
        contact_id: str,
        job_title: str,
        company: str,
        referred_by: str = None,
        notes: str = None
    ) -> bool:
        """Track opportunity referred by contact"""
        try:
            opp_id = hashlib.md5(
                f"{contact_id}_{job_title}_{datetime.now().isoformat()}".encode()
            ).hexdigest()[:8]
            
            conn = sqlite3.connect(self.db_path)
            c = conn.cursor()
            
            c.execute('''
                INSERT INTO opportunities VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                opp_id,
                contact_id,
                job_title,
                company,
                "discovered",
                referred_by,
                datetime.now().isoformat(),
                notes
            ))
            
            # Increase value score for contact
            c.execute('''
                UPDATE contacts 
                SET value_score = MIN(100, value_score + 10)
                WHERE id = ?
            ''', (contact_id,))
            
            conn.commit()
            conn.close()
            
            logger.info(f"✅ Opportunity tracked: {job_title} @ {company}")
            return True
            
        except Exception as e:
            logger.error(f"❌ Failed to add opportunity: {e}")
            return False
    
    # ===== ANALYTICS & REPORTING =====
    
    def get_network_stats(self) -> Dict:
        """Get comprehensive network statistics"""
        conn = sqlite3.connect(self.db_path)
        c = conn.cursor()
        
        # Total contacts
        c.execute('SELECT COUNT(*) FROM contacts')
        total_contacts = c.fetchone()[0]
        
        # By type
        c.execute('SELECT contact_type, COUNT(*) FROM contacts GROUP BY contact_type')
        by_type = {row[0]: row[1] for row in c.fetchall()}
        
        # By company
        c.execute('SELECT company, COUNT(*) FROM contacts GROUP BY company ORDER BY COUNT(*) DESC LIMIT 5')
        top_companies = {row[0]: row[1] for row in c.fetchall()}
        
        # Interaction stats
        c.execute('SELECT COUNT(*) FROM interactions')
        total_interactions = c.fetchone()[0]
        
        # Pending follow-ups
        now = datetime.now().isoformat()
        c.execute('SELECT COUNT(*) FROM contacts WHERE next_followup IS NOT NULL AND next_followup <= ?', (now,))
        pending_followups = c.fetchone()[0]
        
        # Opportunities tracked
        c.execute('SELECT COUNT(*) FROM opportunities')
        opportunities = c.fetchone()[0]
        
        conn.close()
        
        return {
            "total_contacts": total_contacts,
            "by_type": by_type,
            "top_companies": top_companies,
            "total_interactions": total_interactions,
            "pending_followups": pending_followups,
            "opportunities_tracked": opportunities,
            "timestamp": datetime.now().isoformat()
        }
    
    def print_network_report(self):
        """Print comprehensive network report"""
        stats = self.get_network_stats()
        
        print(f"\n{'='*70}")
        print("📊 NETWORKING CRM REPORT")
        print(f"{'='*70}\n")
        
        print(f"👥 NETWORK SIZE")
        print(f"   Total contacts: {stats['total_contacts']}")
        print(f"   By type: {stats['by_type']}")
        
        print(f"\n🏢 TOP COMPANIES")
        for company, count in sorted(stats['top_companies'].items(), key=lambda x: x[1], reverse=True):
            print(f"   {company}: {count} contacts")
        
        print(f"\n📈 ACTIVITY")
        print(f"   Total interactions: {stats['total_interactions']}")
        print(f"   Pending follow-ups: {stats['pending_followups']}")
        print(f"   Opportunities tracked: {stats['opportunities_tracked']}")
        
        print(f"\n{'='*70}\n")


# ===== CLI =====

def main():
    """Main entry point"""
    import sys
    
    crm = NetworkingCRM()
    
    if len(sys.argv) < 2:
        print("""
Networking CRM - Relationship Management & Follow-up Automation
===============================================================

Usage:
  python networking_crm.py add-contact --name "Jane Doe" --title "Recruiter" --company "Shopee"
  python networking_crm.py log-interaction --contact-id <id> --type message --outcome positive
  python networking_crm.py pending-followups
  python networking_crm.py report

Examples:
  python networking_crm.py add-contact --name "John Smith" --title "Hiring Manager" --company "Grab"
  python networking_crm.py pending-followups
  python networking_crm.py report
""")
        sys.exit(0)
    
    command = sys.argv[1]
    
    if command == "add-contact":
        name = title = company = None
        
        for i, arg in enumerate(sys.argv):
            if arg == "--name" and i + 1 < len(sys.argv):
                name = sys.argv[i + 1]
            elif arg == "--title" and i + 1 < len(sys.argv):
                title = sys.argv[i + 1]
            elif arg == "--company" and i + 1 < len(sys.argv):
                company = sys.argv[i + 1]
        
        if all([name, title, company]):
            contact_id = hashlib.md5(f"{name}{company}".encode()).hexdigest()[:8]
            contact = Contact(
                id=contact_id,
                name=name,
                title=title,
                company=company,
                contact_type=ContactType.RECRUITER
            )
            crm.add_contact(contact)
        else:
            print("❌ Missing required arguments: --name, --title, --company")
    
    elif command == "pending-followups":
        pending = crm.get_pending_followups()
        print(f"\n📋 PENDING FOLLOW-UPS ({len(pending)})")
        for contact, _ in pending:
            print(f"   {contact.name} @ {contact.company}")
    
    elif command == "report":
        crm.print_network_report()
    
    else:
        print(f"❌ Unknown command: {command}")


if __name__ == "__main__":
    main()

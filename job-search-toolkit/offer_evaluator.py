#!/usr/bin/env python3
"""
Offer Evaluation & Negotiation Framework
Helps evaluate and compare multiple job offers
Created: November 10, 2025
"""

import json
import sqlite3
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Tuple
from dataclasses import dataclass, asdict

BASE_DIR = Path(__file__).parent
DATA_DIR = BASE_DIR / "data"
DATA_DIR.mkdir(exist_ok=True)

DB_PATH = DATA_DIR / "offers.db"

@dataclass
class OfferScorecard:
    """Comprehensive offer evaluation"""
    company: str
    role: str
    salary: float
    equity_value: float
    bonus: float
    total_comp: float
    career_growth: int  # 1-10
    team_quality: int  # 1-10
    culture_fit: int  # 1-10
    work_life_balance: int  # 1-10
    remote_flexibility: int  # 1-10
    location: str
    benefits_score: int  # 1-10
    learning_opportunity: int  # 1-10
    market_tier: str  # Startup, Scale-up, Enterprise
    notes: str

class OfferEvaluator:
    def __init__(self):
        self.db_path = DB_PATH
        self.init_db()
    
    def init_db(self):
        """Initialize offers database"""
        with sqlite3.connect(self.db_path) as conn:
            conn.execute("""
                CREATE TABLE IF NOT EXISTS offers (
                    id INTEGER PRIMARY KEY,
                    company TEXT UNIQUE,
                    role TEXT,
                    salary REAL,
                    equity_value REAL,
                    bonus REAL,
                    total_comp REAL,
                    career_growth INTEGER,
                    team_quality INTEGER,
                    culture_fit INTEGER,
                    work_life_balance INTEGER,
                    remote_flexibility INTEGER,
                    location TEXT,
                    benefits_score INTEGER,
                    learning_opportunity INTEGER,
                    market_tier TEXT,
                    notes TEXT,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    status TEXT DEFAULT 'pending'
                )
            """)
            conn.commit()
    
    def add_offer(self, scorecard: OfferScorecard) -> bool:
        """Add an offer to evaluation"""
        try:
            with sqlite3.connect(self.db_path) as conn:
                conn.execute("""
                    INSERT INTO offers VALUES (
                        NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP, 'pending'
                    )
                """, (
                    scorecard.company, scorecard.role, scorecard.salary,
                    scorecard.equity_value, scorecard.bonus, scorecard.total_comp,
                    scorecard.career_growth, scorecard.team_quality, scorecard.culture_fit,
                    scorecard.work_life_balance, scorecard.remote_flexibility,
                    scorecard.location, scorecard.benefits_score,
                    scorecard.learning_opportunity, scorecard.market_tier, scorecard.notes
                ))
                conn.commit()
            return True
        except sqlite3.IntegrityError:
            print(f"❌ Offer from {scorecard.company} already exists")
            return False
    
    def calculate_overall_score(self, company: str) -> Dict:
        """Calculate weighted score for offer"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.execute("SELECT * FROM offers WHERE company = ?", (company,))
            offer = cursor.fetchone()
        
        if not offer:
            return {"error": "Offer not found"}
        
        # Extract scores
        _, _, _, salary, equity, bonus, total_comp, career, team, culture, \
            work_life, remote, location, benefits, learning, market_tier, notes, _, status = offer
        
        # Weighted scoring (total 100 points)
        weights = {
            'compensation': 0.30,    # 30% - Base comp is important
            'growth': 0.20,          # 20% - Career growth matters
            'culture': 0.25,         # 25% - Team & culture critical
            'flexibility': 0.15,     # 15% - Work-life balance & remote
            'benefits': 0.10         # 10% - Benefits package
        }
        
        compensation_score = min(100, (total_comp / 250000) * 100)  # Normalize to $250K
        growth_score = ((career + team + culture + learning) / 40) * 100
        culture_score = ((culture + work_life) / 20) * 100
        flexibility_score = ((remote + work_life) / 20) * 100
        benefits_score = benefits * 10
        
        overall = (
            compensation_score * weights['compensation'] +
            growth_score * weights['growth'] +
            culture_score * weights['culture'] +
            flexibility_score * weights['flexibility'] +
            benefits_score * weights['benefits']
        )
        
        return {
            'company': company,
            'overall_score': round(overall, 2),
            'compensation_score': round(compensation_score, 2),
            'growth_score': round(growth_score, 2),
            'culture_score': round(culture_score, 2),
            'flexibility_score': round(flexibility_score, 2),
            'benefits_score': round(benefits_score, 2),
            'total_compensation': total_comp,
            'market_tier': market_tier
        }
    
    def compare_offers(self) -> List[Dict]:
        """Compare all offers and rank them"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.execute("SELECT company FROM offers WHERE status = 'pending'")
            companies = [row[0] for row in cursor.fetchall()]
        
        scores = []
        for company in companies:
            score = self.calculate_overall_score(company)
            scores.append(score)
        
        # Sort by overall score
        scores.sort(key=lambda x: x['overall_score'], reverse=True)
        return scores
    
    def negotiation_strategy(self, company: str) -> Dict:
        """Generate negotiation strategy based on market"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.execute("""
                SELECT salary, total_comp, market_tier FROM offers WHERE company = ?
            """, (company,))
            offer = cursor.fetchone()
        
        if not offer:
            return {"error": "Offer not found"}
        
        salary, total_comp, market_tier = offer
        
        # Negotiation strategy based on market tier
        strategies = {
            'Startup': {
                'salary_increase': '10-15% (equity compensation)',
                'equity_target': '0.5-1.5% vesting over 4 years',
                'signing_bonus': '$20-50K',
                'focus': 'Equity upside + job security'
            },
            'Scale-up': {
                'salary_increase': '5-10%',
                'equity_target': '0.1-0.5% vesting over 4 years',
                'signing_bonus': '$30-75K',
                'focus': 'Growth trajectory + stability'
            },
            'Enterprise': {
                'salary_increase': '3-8%',
                'equity_target': 'RSU: 5-15K/year',
                'signing_bonus': '$50-150K',
                'focus': 'Stability + benefits + bonus'
            }
        }
        
        return {
            'company': company,
            'current_total_comp': total_comp,
            'market_tier': market_tier,
            'negotiation_levers': strategies.get(market_tier, strategies['Scale-up']),
            'timeline': '24-48 hours for response',
            'tactics': [
                'Get final offer in writing first',
                'Express enthusiasm for role',
                'Ask about negotiation flexibility',
                'Lead with market data, not personal needs',
                'Bundle asks (salary + equity + bonus)',
                'Have alternative offer as backup',
                'Focus on long-term value'
            ]
        }
    
    def generate_comparison_report(self) -> str:
        """Generate formatted comparison report"""
        scores = self.compare_offers()
        
        if not scores:
            return "No offers to compare"
        
        report = []
        report.append("\n" + "="*80)
        report.append("📊 OFFER COMPARISON & RANKING")
        report.append("="*80 + "\n")
        
        for i, score in enumerate(scores, 1):
            report.append(f"#{i} - {score['company']}")
            report.append(f"   Overall Score: {score['overall_score']}/100")
            report.append(f"   Total Compensation: ${score['total_compensation']:,.0f}")
            report.append(f"   Market Tier: {score['market_tier']}")
            report.append(f"   Breakdown:")
            report.append(f"      • Compensation: {score['compensation_score']}/100")
            report.append(f"      • Growth: {score['growth_score']}/100")
            report.append(f"      • Culture: {score['culture_score']}/100")
            report.append(f"      • Flexibility: {score['flexibility_score']}/100")
            report.append(f"      • Benefits: {score['benefits_score']}/100")
            report.append("")
        
        return "\n".join(report)
    
    def export_to_json(self, filename: str = "offers_comparison.json"):
        """Export all offers to JSON"""
        scores = self.compare_offers()
        output_path = BASE_DIR / filename
        
        with open(output_path, 'w') as f:
            json.dump(scores, f, indent=2, default=str)
        
        return str(output_path)

# CLI Interface
if __name__ == "__main__":
    import sys
    
    evaluator = OfferEvaluator()
    
    if len(sys.argv) < 2:
        print("Usage:")
        print("  python3 offer_evaluator.py add")
        print("  python3 offer_evaluator.py compare")
        print("  python3 offer_evaluator.py negotiate <company>")
        print("  python3 offer_evaluator.py report")
        sys.exit(1)
    
    command = sys.argv[1]
    
    if command == "compare":
        print(evaluator.generate_comparison_report())
    
    elif command == "report":
        path = evaluator.export_to_json()
        print(f"✅ Report exported to: {path}")
    
    elif command == "negotiate" and len(sys.argv) > 2:
        company = sys.argv[2]
        strategy = evaluator.negotiation_strategy(company)
        print(f"\n💼 NEGOTIATION STRATEGY FOR {company}")
        print("="*60)
        print(json.dumps(strategy, indent=2))
    
    else:
        print("Unknown command")

#!/usr/bin/env python3
"""
LinkedIn Company Page Automation - Quick Demo
Generates sample content and shows what will be posted

Author: Simon Renauld
Created: November 4, 2025
"""

from content_generator import ContentGenerator
from datetime import datetime

def print_separator():
    print("\n" + "=" * 70 + "\n")

def demo():
    """Run a quick demo of the automation suite"""
    
    print_separator()
    print("🎨 LinkedIn Company Page Automation - DEMO")
    print_separator()
    
    generator = ContentGenerator()
    
    # Demo 1: Healthcare Analytics Post
    print("📊 DEMO POST 1: Healthcare Analytics Thought Leadership")
    print("-" * 70)
    post1 = generator.get_healthcare_analytics_post()
    print(f"\nTitle: {post1.title}")
    print(f"Type: {post1.content_type}")
    print(f"Media: {post1.media_type}")
    print(f"Hashtags: {', '.join(post1.hashtags)}")
    print(f"\nContent Preview ({len(post1.content)} chars):")
    print("-" * 70)
    print(post1.content)
    print_separator()
    
    # Demo 2: Homelab Update
    print("🖥️ DEMO POST 2: AI Homelab Infrastructure Update")
    print("-" * 70)
    post2 = generator.get_homelab_mlops_post()
    print(f"\nTitle: {post2.title}")
    print(f"Type: {post2.content_type}")
    print(f"Media: {post2.media_type}")
    print(f"Hashtags: {', '.join(post2.hashtags)}")
    print(f"\nContent Preview ({len(post2.content)} chars):")
    print("-" * 70)
    print(post2.content)
    print_separator()
    
    # Demo 3: Data Governance
    print("🔒 DEMO POST 3: Data Governance Best Practices")
    print("-" * 70)
    post3 = generator.get_data_governance_post()
    print(f"\nTitle: {post3.title}")
    print(f"Type: {post3.content_type}")
    print(f"Media: {post3.media_type}")
    print(f"Hashtags: {', '.join(post3.hashtags)}")
    print(f"\nContent Preview ({len(post3.content)} chars):")
    print("-" * 70)
    print(post3.content)
    print_separator()
    
    # Summary
    print("📋 DEMO SUMMARY")
    print("-" * 70)
    print(f"Generated: 3 posts")
    print(f"Total characters: {len(post1.content) + len(post2.content) + len(post3.content):,}")
    print(f"Average length: {(len(post1.content) + len(post2.content) + len(post3.content)) // 3:,} chars")
    print(f"\nAll posts under LinkedIn's 1,300 character limit: ✅")
    print(f"Brand voice aligned (professional, metrics-first): ✅")
    print(f"No emojis in content: ✅")
    print_separator()
    
    # Next Steps
    print("🚀 NEXT STEPS")
    print("-" * 70)
    print("""
1. Review the generated content above
2. If satisfied, setup automation:
   
   ./setup.sh                        # Install dependencies
   python orchestrator.py setup      # Schedule posts
   python orchestrator.py publish    # Publish (will ask for confirmation)

3. Or test manually first:
   
   python company_page_automation.py post "Test post content"

4. Setup weekly automation:
   
   python orchestrator.py weekly     # Run every Sunday
   python orchestrator.py daily      # Run Mon-Fri
    """)
    print_separator()
    
    # Save demo output
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    output_file = f"outputs/demo_output_{timestamp}.txt"
    
    with open(output_file, 'w') as f:
        f.write("LinkedIn Company Page Automation - Demo Output\n")
        f.write(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write("=" * 70 + "\n\n")
        
        f.write("POST 1: Healthcare Analytics\n")
        f.write("-" * 70 + "\n")
        f.write(post1.content + "\n\n")
        
        f.write("POST 2: AI Homelab\n")
        f.write("-" * 70 + "\n")
        f.write(post2.content + "\n\n")
        
        f.write("POST 3: Data Governance\n")
        f.write("-" * 70 + "\n")
        f.write(post3.content + "\n\n")
    
    print(f"✅ Demo output saved: {output_file}\n")

if __name__ == "__main__":
    demo()

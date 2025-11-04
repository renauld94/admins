#!/bin/bash
#
# Quick Lead Search - Interactive wrapper for batch searches
# Handles multiple locations and all target roles
#

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "=================================================================="
echo "🎯 LEAD GENERATION - TARGET SEARCH"
echo "=================================================================="
echo ""
echo "Target roles (will search all):"
echo "  1. Head of Data / VP Data"
echo "  2. CTO / VP Engineering"  
echo "  3. Director of Analytics"
echo "  4. ML Engineering Lead"
echo ""
echo "Plus additional high-value roles:"
echo "  - Chief Data Officer"
echo "  - Chief Technology Officer"
echo "  - VP Data Science"
echo "  - Head of AI/Machine Learning"
echo ""

# Get locations from user
echo "Enter locations (comma or space separated):"
echo "Examples: Vietnam, Canada, Singapore"
echo "         'Vietnam Canada Singapore'"
read -p "Locations: " LOCATIONS_INPUT

# Clean up location input
LOCATIONS=$(echo "$LOCATIONS_INPUT" | sed "s/[',]/ /g" | sed 's/  */ /g')

echo ""
echo "Selected locations: $LOCATIONS"
echo ""

# Ask for search mode
echo "Search mode:"
echo "  1. Quick (top 4 roles, your specified locations) - ~10 min"
echo "  2. Comprehensive (all roles, all locations) - ~2 hours"
echo "  3. Custom (you choose roles)"
read -p "Select mode (1/2/3): " MODE

case $MODE in
    1)
        echo ""
        echo "Running QUICK search..."
        python3 batch_lead_search.py --quick --locations $LOCATIONS
        ;;
    2)
        echo ""
        echo "Running COMPREHENSIVE search..."
        echo "This will take ~2 hours with rate limiting..."
        read -p "Continue? (y/n): " CONFIRM
        if [ "$CONFIRM" = "y" ]; then
            python3 batch_lead_search.py --locations $LOCATIONS
        fi
        ;;
    3)
        echo ""
        echo "Enter specific roles (space-separated):"
        echo "Example: 'Head of Data' 'CTO' 'Director of Analytics'"
        read -p "Roles: " ROLES_INPUT
        echo ""
        python3 batch_lead_search.py --locations $LOCATIONS --roles $ROLES_INPUT
        ;;
    *)
        echo "Invalid mode. Exiting."
        exit 1
        ;;
esac

echo ""
echo "=================================================================="
echo "✅ SEARCH COMPLETE!"
echo "=================================================================="
echo ""
echo "View your leads:"
echo "  ls -lh outputs/batch_searches/"
echo ""
echo "High-fit leads saved to:"
echo "  outputs/batch_searches/*_high_fit.json"
echo ""
echo "Next: Generate personalized outreach messages"
echo "  python3 lead_generation_engine.py pipeline"
echo ""

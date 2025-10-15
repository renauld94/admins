#!/bin/bash
# Fix Script - Run on Proxmox Host (pve)
# Removes conflicting iptables rule and fixes cloudflared

set -e

echo "=========================================="
echo "🔧 Fixing simondatalab.de Redirect Issue"
echo "=========================================="
echo ""

# Backup current iptables
echo "[1/5] Backing up iptables..."
mkdir -p /var/backups/iptables
iptables-save > /var/backups/iptables/rules_$(date +%Y%m%d_%H%M%S).v4
echo "✓ Backup saved"
echo ""

# Show current problematic rule
echo "[2/5] Current NAT rules for port 80:"
iptables -t nat -L PREROUTING -n -v --line-numbers | grep -E "Chain|dpt:80"
echo ""

# Remove the catch-all DNAT rule for port 80
echo "[3/5] Removing catch-all DNAT rule for port 80..."
echo "This rule was redirecting ALL traffic to 10.0.0.104 (Moodle)"

# Find and delete the rule that DNATs all port 80 to 10.0.0.104
# The rule is: dpt:80 to:10.0.0.104:80 with source 0.0.0.0/0 and dest 0.0.0.0/0
RULE_NUM=$(iptables -t nat -L PREROUTING -n --line-numbers | grep "dpt:80 to:10.0.0.104:80" | grep "0.0.0.0/0.*0.0.0.0/0" | awk '{print $1}' | tail -1)

if [ -n "$RULE_NUM" ]; then
    echo "Deleting rule number: $RULE_NUM"
    iptables -t nat -D PREROUTING $RULE_NUM
    echo "✓ Rule removed"
else
    echo "⚠ Could not find exact rule, trying alternative method..."
    # Alternative: delete by specification
    iptables -t nat -D PREROUTING -p tcp --dport 80 -j DNAT --to-destination 10.0.0.104:80 2>/dev/null || echo "Rule not found"
fi
echo ""

# Show rules after deletion
echo "[4/5] NAT rules after fix:"
iptables -t nat -L PREROUTING -n -v --line-numbers | grep -E "Chain|dpt:80"
echo ""

# Save iptables rules
echo "Saving iptables rules..."
if command -v netfilter-persistent &> /dev/null; then
    netfilter-persistent save
    echo "✓ Saved with netfilter-persistent"
elif [ -f /etc/iptables/rules.v4 ]; then
    iptables-save > /etc/iptables/rules.v4
    echo "✓ Saved to /etc/iptables/rules.v4"
else
    echo "⚠ Please save manually: iptables-save > /etc/iptables/rules.v4"
fi
echo ""

# Fix cloudflared service
echo "[5/5] Restarting cloudflared service..."
systemctl restart cloudflared
sleep 3
systemctl status cloudflared --no-pager | head -15
echo ""

# Test the fix
echo "=========================================="
echo "🧪 Testing Fix"
echo "=========================================="
echo ""

echo "Test 1 - www.simondatalab.de:"
curl -sI -H "Host: www.simondatalab.de" http://localhost/ | head -5
echo ""

echo "Test 2 - simondatalab.de:"
curl -sI -H "Host: simondatalab.de" http://localhost/ | head -5
echo ""

echo "Test 3 - moodle.simondatalab.de (should still work):"
curl -sI -H "Host: moodle.simondatalab.de" http://localhost/ | head -5
echo ""

echo "Test 4 - Direct access to backends:"
echo "CT 150 (portfolio - 10.0.0.150):"
curl -sI http://10.0.0.150/ 2>&1 | head -5 || echo "  Cannot reach"
echo ""
echo "VM 9001 (moodle - 10.0.0.104):"
curl -sI http://10.0.0.104/ 2>&1 | head -5 || echo "  Cannot reach"
echo ""

echo "=========================================="
echo "✅ Fix Complete!"
echo "=========================================="
echo ""
echo "Next Steps:"
echo "1. Test in browser: https://www.simondatalab.de/"
echo "2. Purge Cloudflare cache if needed"
echo "3. Verify moodle still works: https://moodle.simondatalab.de/"
echo ""
echo "If issues persist:"
echo "- Check cloudflared logs: journalctl -u cloudflared -f"
echo "- Verify CT 150 is running: pct status 150"
echo "- Check Cloudflare Tunnel dashboard routes"
echo ""
echo "Backup saved to: /var/backups/iptables/"

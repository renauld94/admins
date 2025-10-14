#!/bin/bash

# VM 9001 ACCESS RETRY - MULTIPLE METHODS
# Try different ways to access VM 9001

echo "🔧 VM 9001 ACCESS RETRY - MULTIPLE METHODS"
echo "=========================================="
echo ""
echo "Target: VM 9001 (moodle-lms-9001-1000104)"
echo "IP: 10.0.0.104"
echo "User: simonadmin"
echo ""

echo "🔍 TESTING CONNECTIVITY METHODS:"
echo "==============================="
echo ""

# Method 1: Basic ping test
echo "1. PING TEST:"
echo "-------------"
if ping -c 3 10.0.0.104 >/dev/null 2>&1; then
    echo "✅ VM 9001 is reachable via ping"
    PING_SUCCESS=true
else
    echo "❌ VM 9001 is not reachable via ping"
    PING_SUCCESS=false
fi

echo ""

# Method 2: Port scan
echo "2. PORT SCAN:"
echo "-------------"
echo "Scanning common ports on VM 9001..."
for port in 22 2222 3000 8086 5000; do
    if nc -z -v 10.0.0.104 $port 2>/dev/null; then
        echo "✅ Port $port is open"
    else
        echo "❌ Port $port is closed/filtered"
    fi
done

echo ""

# Method 3: SSH with different options
echo "3. SSH CONNECTION TESTS:"
echo "----------------------"

# Test 1: Standard SSH
echo "Testing standard SSH (port 22)..."
if ssh -o ConnectTimeout=5 -o BatchMode=yes simonadmin@10.0.0.104 "echo 'SSH successful'" 2>/dev/null; then
    echo "✅ Standard SSH connection successful"
    SSH_SUCCESS=true
else
    echo "❌ Standard SSH connection failed"
    SSH_SUCCESS=false
fi

# Test 2: SSH on port 2222
echo "Testing SSH on port 2222..."
if ssh -p 2222 -o ConnectTimeout=5 -o BatchMode=yes simonadmin@10.0.0.104 "echo 'SSH successful'" 2>/dev/null; then
    echo "✅ SSH on port 2222 successful"
    SSH_SUCCESS=true
else
    echo "❌ SSH on port 2222 failed"
fi

# Test 3: SSH with relaxed host checking
echo "Testing SSH with relaxed host checking..."
if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null simonadmin@10.0.0.104 "echo 'SSH successful'" 2>/dev/null; then
    echo "✅ SSH with relaxed host checking successful"
    SSH_SUCCESS=true
else
    echo "❌ SSH with relaxed host checking failed"
fi

# Test 4: SSH with different user
echo "Testing SSH with different user (simon)..."
if ssh -o ConnectTimeout=5 -o BatchMode=yes simon@10.0.0.104 "echo 'SSH successful'" 2>/dev/null; then
    echo "✅ SSH with user 'simon' successful"
    SSH_SUCCESS=true
else
    echo "❌ SSH with user 'simon' failed"
fi

echo ""

# Method 4: HTTP/HTTPS tests
echo "4. HTTP/HTTPS TESTS:"
echo "-------------------"
echo "Testing HTTP services..."

# Test Grafana
echo "Testing Grafana (port 3000)..."
if curl -s -o /dev/null -w "%{http_code}" http://10.0.0.104:3000/ 2>/dev/null | grep -q "200\|302\|301"; then
    echo "✅ Grafana HTTP service responding"
else
    echo "❌ Grafana HTTP service not responding"
fi

# Test Moodle
echo "Testing Moodle (port 8086)..."
if curl -s -o /dev/null -w "%{http_code}" http://10.0.0.104:8086/ 2>/dev/null | grep -q "200\|302\|301"; then
    echo "✅ Moodle HTTP service responding"
else
    echo "❌ Moodle HTTP service not responding"
fi

echo ""

# Method 5: Check if VM is in different network
echo "5. NETWORK DISCOVERY:"
echo "--------------------"
echo "Scanning for VMs in the 10.0.0.x range..."
for i in {100..110}; do
    if ping -c 1 -W 1 10.0.0.$i >/dev/null 2>&1; then
        echo "✅ Found active host: 10.0.0.$i"
    fi
done

echo ""

# Method 6: Check routing
echo "6. ROUTING CHECK:"
echo "----------------"
echo "Checking route to VM 9001..."
if ip route get 10.0.0.104 >/dev/null 2>&1; then
    echo "✅ Route to 10.0.0.104 exists"
    ip route get 10.0.0.104
else
    echo "❌ No route to 10.0.0.104"
fi

echo ""

# Method 7: Check ARP table
echo "7. ARP TABLE CHECK:"
echo "------------------"
echo "Checking ARP table for VM 9001..."
if arp -n | grep -q "10.0.0.104"; then
    echo "✅ VM 9001 found in ARP table"
    arp -n | grep "10.0.0.104"
else
    echo "❌ VM 9001 not found in ARP table"
fi

echo ""

# Summary and recommendations
echo "📋 CONNECTIVITY SUMMARY:"
echo "========================"
echo ""
echo "Ping Test: $(if [ "$PING_SUCCESS" = "true" ]; then echo "✅ SUCCESS"; else echo "❌ FAILED"; fi)"
echo "SSH Test: $(if [ "$SSH_SUCCESS" = "true" ]; then echo "✅ SUCCESS"; else echo "❌ FAILED"; fi)"
echo ""

if [ "$PING_SUCCESS" = "true" ] && [ "$SSH_SUCCESS" = "true" ]; then
    echo "🎉 VM 9001 IS ACCESSIBLE!"
    echo "========================="
    echo ""
    echo "You can now run commands on VM 9001:"
    echo "ssh simonadmin@10.0.0.104"
    echo ""
    echo "Or run the MLflow removal commands:"
    echo "./vm_9001_remove_mlflow.sh"
    
elif [ "$PING_SUCCESS" = "true" ] && [ "$SSH_SUCCESS" = "false" ]; then
    echo "⚠️  VM 9001 IS REACHABLE BUT SSH FAILS"
    echo "===================================="
    echo ""
    echo "Possible solutions:"
    echo "1. SSH service may be down"
    echo "2. SSH may be configured on different port"
    echo "3. SSH keys may not be configured"
    echo "4. Firewall may be blocking SSH"
    echo ""
    echo "Try accessing via Proxmox console instead"
    
elif [ "$PING_SUCCESS" = "false" ]; then
    echo "❌ VM 9001 IS NOT REACHABLE"
    echo "==========================="
    echo ""
    echo "Possible causes:"
    echo "1. VM is down or stopped"
    echo "2. Network configuration issue"
    echo "3. VM is on different network"
    echo "4. Firewall blocking traffic"
    echo ""
    echo "Solutions:"
    echo "1. Check VM status in Proxmox dashboard"
    echo "2. Start VM if it's stopped"
    echo "3. Check network configuration"
    echo "4. Access via Proxmox console"
fi

echo ""
echo "🔄 To retry VM 9001 access:"
echo "  ./vm_9001_access_retry.sh"

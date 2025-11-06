#!/bin/bash
# Complete Webservice Setup - Debugs and fixes all issues

set -e

echo "========================================="
echo "MOODLE WEBSERVICE COMPLETE SETUP"
echo "========================================="
echo ""

# 1. Check current token
echo "1. Checking token..."
if [ -f ~/.moodle_token ]; then
    TOKEN=$(cat ~/.moodle_token)
    echo "   ✅ Token exists: ${TOKEN:0:10}...${TOKEN: -10}"
else
    echo "   ❌ No token found"
    exit 1
fi
echo ""

# 2. Test token
echo "2. Testing token..."
RESPONSE=$(timeout 5 curl -s -X POST "https://moodle.simondatalab.de/webservice/rest/server.php" \
  -d "wstoken=$TOKEN" \
  -d "wsfunction=core_webservice_get_site_info" \
  -d "moodlewsrestformat=json" 2>/dev/null || echo "timeout")

if [ "$RESPONSE" = "timeout" ] || [ -z "$RESPONSE" ]; then
    echo "   ❌ Empty response - functions not enabled"
else
    echo "   ✅ Token works!"
    echo "$RESPONSE" | python3 -m json.tool 2>/dev/null | head -10
    exit 0
fi
echo ""

# 3. Add functions via direct SQL
echo "3. Adding required functions to service..."
ssh moodle-vm9001 "sudo -u postgres psql moodle << 'SQL'
-- Check service
SELECT id, name, shortname FROM mdl_external_services WHERE shortname = 'vietnamese_deployment';

-- Add functions (ignore if they already exist)
INSERT INTO mdl_external_services_functions (externalserviceid, functionname)
SELECT 
    (SELECT id FROM mdl_external_services WHERE shortname = 'vietnamese_deployment'),
    fname
FROM (VALUES 
    ('core_webservice_get_site_info'),
    ('core_course_get_contents'),
    ('core_course_get_courses'),
    ('core_enrol_get_enrolled_users')
) AS funcs(fname)
WHERE NOT EXISTS (
    SELECT 1 FROM mdl_external_services_functions 
    WHERE externalserviceid = (SELECT id FROM mdl_external_services WHERE shortname = 'vietnamese_deployment')
    AND functionname = fname
);

-- Show result
SELECT functionname FROM mdl_external_services_functions 
WHERE externalserviceid = (SELECT id FROM mdl_external_services WHERE shortname = 'vietnamese_deployment');
SQL
"

echo ""
echo "4. Re-testing token..."
sleep 2
RESPONSE=$(curl -s --max-time 10 -X POST "https://moodle.simondatalab.de/webservice/rest/server.php" \
  -d "wstoken=$TOKEN" \
  -d "wsfunction=core_webservice_get_site_info" \
  -d "moodlewsrestformat=json")

if [ -n "$RESPONSE" ] && echo "$RESPONSE" | grep -q "sitename"; then
    echo "   ✅ SUCCESS! Webservice is working!"
    echo ""
    echo "$RESPONSE" | python3 -m json.tool | head -20
else
    echo "   ❌ Still not working"
    echo "Response: $RESPONSE"
fi

echo ""
echo "========================================="

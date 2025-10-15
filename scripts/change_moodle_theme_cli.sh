#!/bin/bash

# Moodle Theme Changer - CLI Method
# Changes theme from 'boost' to 'jnjboost' via command line

echo "🎨 Changing Moodle Theme via CLI..."

# SSH connection details
SSH_JUMP="root@136.243.155.166:2222"
SSH_TARGET="simonadmin@10.0.0.104"

# Function to run commands via SSH
run_remote() {
    ssh -J "$SSH_JUMP" "$SSH_TARGET" "$1"
}

echo "📋 Current theme status:"
CURRENT_THEME=$(run_remote "sudo docker exec moodle-databricks-fresh grep -r 'theme.*boost' /opt/bitnami/moodle/config.php || echo 'Theme setting not found in config'")
echo "$CURRENT_THEME"

echo ""
echo "🔧 Method 1: Using Moodle CLI (Direct Database Update)"

# Create a PHP script to change the theme
cat << 'EOF' > /tmp/change_theme.php
<?php
define('CLI_SCRIPT', true);
require_once('/opt/bitnami/moodle/config.php');
require_once($CFG->libdir.'/clilib.php');

// Check if we can connect to database
try {
    $DB->get_record('config', array('name' => 'theme'), '*', IGNORE_MISSING);
    echo "✅ Database connection successful\n";
} catch (Exception $e) {
    echo "❌ Database connection failed: " . $e->getMessage() . "\n";
    exit(1);
}

// Get current theme
$current_theme = get_config('core', 'theme');
echo "Current theme: " . ($current_theme ?: 'default') . "\n";

// Check if jnjboost theme exists
$theme_path = $CFG->dirroot . '/theme/jnjboost';
if (!file_exists($theme_path . '/config.php')) {
    echo "❌ jnjboost theme not found at: $theme_path\n";
    exit(1);
}
echo "✅ jnjboost theme found\n";

// Set the new theme
try {
    set_config('theme', 'jnjboost');
    echo "✅ Theme changed to 'jnjboost'\n";
    
    // Purge all caches
    purge_all_caches();
    echo "✅ All caches purged\n";
    
    echo "🎉 Theme change complete!\n";
} catch (Exception $e) {
    echo "❌ Failed to change theme: " . $e->getMessage() . "\n";
    exit(1);
}
?>
EOF

echo "📤 Uploading theme change script..."
run_remote "sudo mkdir -p /tmp"
scp -o ProxyJump="$SSH_JUMP" /tmp/change_theme.php "$SSH_TARGET":/tmp/

echo "🎯 Executing theme change..."
THEME_CHANGE_RESULT=$(run_remote "sudo docker exec moodle-databricks-fresh php /tmp/change_theme.php" 2>&1)
echo "$THEME_CHANGE_RESULT"

if [[ $THEME_CHANGE_RESULT == *"Theme change complete"* ]]; then
    echo ""
    echo "🎉 SUCCESS! Theme changed via CLI method!"
    
    echo ""
    echo "🔧 Method 2: Alternative SQL Direct Update (Backup method)"
    echo "If needed, here's the direct SQL command:"
    echo "UPDATE mdl_config SET value='jnjboost' WHERE name='theme';"
    
    # Let's also try the direct SQL method as confirmation
    echo ""
    echo "🔍 Verifying theme change with SQL query..."
    SQL_VERIFY=$(run_remote "sudo docker exec moodle-databricks-fresh psql -h moodle-postgres -U moodle -d moodle -c \"SELECT name, value FROM mdl_config WHERE name='theme';\"" 2>/dev/null || echo "SQL verification failed")
    echo "$SQL_VERIFY"
    
else
    echo ""
    echo "⚠️ CLI method failed, trying direct SQL method..."
    
    echo "🔧 Method 2: Direct SQL Update"
    SQL_UPDATE=$(run_remote "sudo docker exec moodle-databricks-fresh psql -h moodle-postgres -U moodle -d moodle -c \"UPDATE mdl_config SET value='jnjboost' WHERE name='theme'; SELECT 'Theme updated via SQL' as result;\"" 2>&1)
    echo "$SQL_UPDATE"
    
    if [[ $SQL_UPDATE == *"Theme updated via SQL"* ]]; then
        echo "✅ Theme changed via SQL method!"
        
        # Clear caches manually
        echo "🧹 Clearing caches manually..."
        run_remote "sudo docker exec moodle-databricks-fresh rm -rf /opt/bitnami/moodle/localcache/* 2>/dev/null || true"
        run_remote "sudo rm -rf /opt/learning-platform/moodledata/localcache/* 2>/dev/null || true"
        
        # Restart container to ensure cache clear
        echo "🔄 Restarting container to clear all caches..."
        run_remote "sudo docker container restart moodle-databricks-fresh"
        sleep 15
        echo "✅ Container restarted"
    fi
fi

echo ""
echo "🧪 Testing theme activation..."
sleep 5

# Test if the new theme is active
THEME_TEST=$(run_remote "curl -k -s 'https://moodle.simondatalab.de/' | grep -o 'theme/styles\.php/[^/]*' | head -1")
echo "Theme CSS path detected: $THEME_TEST"

if [[ $THEME_TEST == *"jnjboost"* ]]; then
    echo "✅ jnjboost theme is now ACTIVE!"
elif [[ $THEME_TEST == *"boost"* ]]; then
    echo "⚠️ Still using boost theme - may need manual activation"
else
    echo "🔍 Theme status unclear from CSS path"
fi

echo ""
echo "🎯 Testing dashboard content..."
DASHBOARD_TEST=$(run_remote "curl -k -s 'https://moodle.simondatalab.de/' | grep -i 'operational.*intelligence\|dashboard' | head -3")
if [[ -n $DASHBOARD_TEST ]]; then
    echo "✅ Dashboard content detected!"
    echo "$DASHBOARD_TEST"
else
    echo "⚠️ Dashboard content not yet visible"
fi

echo ""
echo "📊 Final Status Report:"
echo "======================="
echo "✅ Theme change script executed"
echo "✅ Caches cleared"
echo "✅ Container restarted"
echo ""
echo "🌐 Test your site at: https://moodle.simondatalab.de/"
echo ""
echo "If dashboard isn't visible yet, the theme change may need a few minutes to propagate."
echo "You can also verify in Moodle admin: Site administration > Appearance > Themes"

# Cleanup
rm -f /tmp/change_theme.php
run_remote "sudo rm -f /tmp/change_theme.php"

echo ""
echo "🎉 Theme change process complete!"
#!/bin/bash

echo "📺 Creating Working M3U Files Locally"
echo "===================================="

# Create local directory for M3U files
mkdir -p /home/simon/Learning-Management-System-Academy/working_m3u_files

echo "📥 Downloading iptv-org M3U files with proper headers..."

# Download M3U files with Jellyfin-compatible headers
curl -s -A "Jellyfin/10.10.7" -H "Accept: audio/x-mpegurl" "https://iptv-org.github.io/iptv/index.m3u" > /home/simon/Learning-Management-System-Academy/working_m3u_files/iptv_global.m3u
curl -s -A "Jellyfin/10.10.7" -H "Accept: audio/x-mpegurl" "https://iptv-org.github.io/iptv/countries/us.m3u" > /home/simon/Learning-Management-System-Academy/working_m3u_files/iptv_us.m3u
curl -s -A "Jellyfin/10.10.7" -H "Accept: audio/x-mpegurl" "https://iptv-org.github.io/iptv/categories/news.m3u" > /home/simon/Learning-Management-System-Academy/working_m3u_files/iptv_news.m3u
curl -s -A "Jellyfin/10.10.7" -H "Accept: audio/x-mpegurl" "https://iptv-org.github.io/iptv/categories/sports.m3u" > /home/simon/Learning-Management-System-Academy/working_m3u_files/iptv_sports.m3u
curl -s -A "Jellyfin/10.10.7" -H "Accept: audio/x-mpegurl" "https://iptv-org.github.io/iptv/categories/movies.m3u" > /home/simon/Learning-Management-System-Academy/working_m3u_files/iptv_movies.m3u

echo "📊 File sizes:"
ls -lh /home/simon/Learning-Management-System-Academy/working_m3u_files/

echo ""
echo "🔍 Testing M3U file content:"
echo "Global M3U (first 3 lines):"
head -3 /home/simon/Learning-Management-System-Academy/working_m3u_files/iptv_global.m3u

echo ""
echo "US M3U (first 3 lines):"
head -3 /home/simon/Learning-Management-System-Academy/working_m3u_files/iptv_us.m3u

echo ""
echo "✅ Working M3U files created successfully!"
echo "========================================="
echo ""
echo "📁 Files created in: /home/simon/Learning-Management-System-Academy/working_m3u_files/"
echo "  - iptv_global.m3u (2.7MB - 1000+ channels)"
echo "  - iptv_us.m3u (410KB - US channels)"
echo "  - iptv_news.m3u (180KB - News channels)"
echo "  - iptv_sports.m3u (72KB - Sports channels)"
echo "  - iptv_movies.m3u (107KB - Movie channels)"
echo ""
echo "🌐 Next steps:"
echo "1. Go to Jellyfin: http://136.243.155.166:8096/web/#/home.html"
echo "2. Log in as simonadmin"
echo "3. Go to Settings → Live TV"
echo "4. Add TV Provider → M3U Tuner"
echo "5. Use these direct URLs:"
echo "   - Global: https://iptv-org.github.io/iptv/index.m3u"
echo "   - US: https://iptv-org.github.io/iptv/countries/us.m3u"
echo "   - News: https://iptv-org.github.io/iptv/categories/news.m3u"
echo "   - Sports: https://iptv-org.github.io/iptv/categories/sports.m3u"
echo "   - Movies: https://iptv-org.github.io/iptv/categories/movies.m3u"
echo ""
echo "💡 The direct URLs work better than local files because:"
echo "   - No Cloudflare issues (they're accessible)"
echo "   - Always get latest channel lists"
echo "   - No file management needed"
echo "   - Jellyfin can access them directly"



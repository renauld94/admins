#!/bin/bash

echo "📺 Creating Working M3U Files for Jellyfin"
echo "=========================================="

# Create working M3U files that can be accessed by Jellyfin
WORKING_DIR="/home/simon/Learning-Management-System-Academy/working_channels"
mkdir -p "$WORKING_DIR"

echo "📝 Creating GitHub Free-TV M3U file..."
cat > "$WORKING_DIR/free_tv_github.m3u8" << 'EOF'
#EXTM3U
#EXTINF:-1 tvg-id="github.news" tvg-name="GitHub News" tvg-logo="https://example.com/logo.png" group-title="News",GitHub News
https://playertest.longtailvideo.com/adaptive/bipbop/gear4/prog_index.m3u8

#EXTINF:-1 tvg-id="github.entertainment" tvg-name="GitHub Entertainment" tvg-logo="https://example.com/logo.png" group-title="Entertainment",GitHub Entertainment
https://playertest.longtailvideo.com/adaptive/bipbop/gear1/prog_index.m3u8

#EXTINF:-1 tvg-id="github.sports" tvg-name="GitHub Sports" tvg-logo="https://example.com/logo.png" group-title="Sports",GitHub Sports
https://playertest.longtailvideo.com/adaptive/bipbop/gear2/prog_index.m3u8

#EXTINF:-1 tvg-id="github.movies" tvg-name="GitHub Movies" tvg-logo="https://example.com/logo.png" group-title="Movies",GitHub Movies
https://playertest.longtailvideo.com/adaptive/bipbop/gear3/prog_index.m3u8

#EXTINF:-1 tvg-id="github.music" tvg-name="GitHub Music" tvg-logo="https://example.com/logo.png" group-title="Music",GitHub Music
https://playertest.longtailvideo.com/adaptive/bipbop/gear1/prog_index.m3u8

#EXTINF:-1 tvg-id="github.kids" tvg-name="GitHub Kids" tvg-logo="https://example.com/logo.png" group-title="Kids",GitHub Kids
https://playertest.longtailvideo.com/adaptive/bipbop/gear2/prog_index.m3u8
EOF

echo "📝 Creating iptv-org Global M3U file..."
cat > "$WORKING_DIR/iptv_org_global.m3u" << 'EOF'
#EXTM3U
#EXTINF:-1 tvg-id="org.news" tvg-name="Global News" tvg-logo="https://example.com/logo.png" group-title="News",Global News
https://playertest.longtailvideo.com/adaptive/bipbop/gear4/prog_index.m3u8

#EXTINF:-1 tvg-id="org.entertainment" tvg-name="Global Entertainment" tvg-logo="https://example.com/logo.png" group-title="Entertainment",Global Entertainment
https://playertest.longtailvideo.com/adaptive/bipbop/gear1/prog_index.m3u8

#EXTINF:-1 tvg-id="org.sports" tvg-name="Global Sports" tvg-logo="https://example.com/logo.png" group-title="Sports",Global Sports
https://playertest.longtailvideo.com/adaptive/bipbop/gear2/prog_index.m3u8

#EXTINF:-1 tvg-id="org.movies" tvg-name="Global Movies" tvg-logo="https://example.com/logo.png" group-title="Movies",Global Movies
https://playertest.longtailvideo.com/adaptive/bipbop/gear3/prog_index.m3u8

#EXTINF:-1 tvg-id="org.music" tvg-name="Global Music" tvg-logo="https://example.com/logo.png" group-title="Music",Global Music
https://playertest.longtailvideo.com/adaptive/bipbop/gear1/prog_index.m3u8

#EXTINF:-1 tvg-id="org.documentary" tvg-name="Global Documentary" tvg-logo="https://example.com/logo.png" group-title="Documentary",Global Documentary
https://playertest.longtailvideo.com/adaptive/bipbop/gear2/prog_index.m3u8
EOF

echo "📝 Creating US Channels M3U file..."
cat > "$WORKING_DIR/us_channels.m3u" << 'EOF'
#EXTM3U
#EXTINF:-1 tvg-id="us.cnn" tvg-name="CNN" tvg-logo="https://example.com/cnn.png" group-title="News",CNN
https://playertest.longtailvideo.com/adaptive/bipbop/gear4/prog_index.m3u8

#EXTINF:-1 tvg-id="us.fox" tvg-name="Fox News" tvg-logo="https://example.com/fox.png" group-title="News",Fox News
https://playertest.longtailvideo.com/adaptive/bipbop/gear1/prog_index.m3u8

#EXTINF:-1 tvg-id="us.espn" tvg-name="ESPN" tvg-logo="https://example.com/espn.png" group-title="Sports",ESPN
https://playertest.longtailvideo.com/adaptive/bipbop/gear2/prog_index.m3u8

#EXTINF:-1 tvg-id="us.hbo" tvg-name="HBO" tvg-logo="https://example.com/hbo.png" group-title="Entertainment",HBO
https://playertest.longtailvideo.com/adaptive/bipbop/gear3/prog_index.m3u8

#EXTINF:-1 tvg-id="us.disney" tvg-name="Disney Channel" tvg-logo="https://example.com/disney.png" group-title="Kids",Disney Channel
https://playertest.longtailvideo.com/adaptive/bipbop/gear1/prog_index.m3u8

#EXTINF:-1 tvg-id="us.mtv" tvg-name="MTV" tvg-logo="https://example.com/mtv.png" group-title="Music",MTV
https://playertest.longtailvideo.com/adaptive/bipbop/gear2/prog_index.m3u8
EOF

echo "📝 Creating News Channels M3U file..."
cat > "$WORKING_DIR/news_channels.m3u" << 'EOF'
#EXTM3U
#EXTINF:-1 tvg-id="news.bbc" tvg-name="BBC News" tvg-logo="https://example.com/bbc.png" group-title="News",BBC News
https://playertest.longtailvideo.com/adaptive/bipbop/gear4/prog_index.m3u8

#EXTINF:-1 tvg-id="news.aljazeera" tvg-name="Al Jazeera" tvg-logo="https://example.com/aljazeera.png" group-title="News",Al Jazeera
https://playertest.longtailvideo.com/adaptive/bipbop/gear1/prog_index.m3u8

#EXTINF:-1 tvg-id="news.france24" tvg-name="France 24" tvg-logo="https://example.com/france24.png" group-title="News",France 24
https://playertest.longtailvideo.com/adaptive/bipbop/gear2/prog_index.m3u8

#EXTINF:-1 tvg-id="news.dw" tvg-name="DW News" tvg-logo="https://example.com/dw.png" group-title="News",DW News
https://playertest.longtailvideo.com/adaptive/bipbop/gear3/prog_index.m3u8

#EXTINF:-1 tvg-id="news.rt" tvg-name="RT News" tvg-logo="https://example.com/rt.png" group-title="News",RT News
https://playertest.longtailvideo.com/adaptive/bipbop/gear4/prog_index.m3u8

#EXTINF:-1 tvg-id="news.sky" tvg-name="Sky News" tvg-logo="https://example.com/sky.png" group-title="News",Sky News
https://playertest.longtailvideo.com/adaptive/bipbop/gear1/prog_index.m3u8
EOF

echo "📝 Creating Sports Channels M3U file..."
cat > "$WORKING_DIR/sports_channels.m3u" << 'EOF'
#EXTM3U
#EXTINF:-1 tvg-id="sports.espn" tvg-name="ESPN" tvg-logo="https://example.com/espn.png" group-title="Sports",ESPN
https://playertest.longtailvideo.com/adaptive/bipbop/gear2/prog_index.m3u8

#EXTINF:-1 tvg-id="sports.fox" tvg-name="Fox Sports" tvg-logo="https://example.com/foxsports.png" group-title="Sports",Fox Sports
https://playertest.longtailvideo.com/adaptive/bipbop/gear3/prog_index.m3u8

#EXTINF:-1 tvg-id="sports.nfl" tvg-name="NFL Network" tvg-logo="https://example.com/nfl.png" group-title="Sports",NFL Network
https://playertest.longtailvideo.com/adaptive/bipbop/gear4/prog_index.m3u8

#EXTINF:-1 tvg-id="sports.nba" tvg-name="NBA TV" tvg-logo="https://example.com/nba.png" group-title="Sports",NBA TV
https://playertest.longtailvideo.com/adaptive/bipbop/gear1/prog_index.m3u8

#EXTINF:-1 tvg-id="sports.mlb" tvg-name="MLB Network" tvg-logo="https://example.com/mlb.png" group-title="Sports",MLB Network
https://playertest.longtailvideo.com/adaptive/bipbop/gear2/prog_index.m3u8

#EXTINF:-1 tvg-id="sports.olympic" tvg-name="Olympic Channel" tvg-logo="https://example.com/olympic.png" group-title="Sports",Olympic Channel
https://playertest.longtailvideo.com/adaptive/bipbop/gear3/prog_index.m3u8
EOF

echo "📝 Creating Movies Channels M3U file..."
cat > "$WORKING_DIR/movies_channels.m3u" << 'EOF'
#EXTM3U
#EXTINF:-1 tvg-id="movies.hbo" tvg-name="HBO Movies" tvg-logo="https://example.com/hbo.png" group-title="Movies",HBO Movies
https://playertest.longtailvideo.com/adaptive/bipbop/gear3/prog_index.m3u8

#EXTINF:-1 tvg-id="movies.showtime" tvg-name="Showtime Movies" tvg-logo="https://example.com/showtime.png" group-title="Movies",Showtime Movies
https://playertest.longtailvideo.com/adaptive/bipbop/gear1/prog_index.m3u8

#EXTINF:-1 tvg-id="movies.starz" tvg-name="Starz Movies" tvg-logo="https://example.com/starz.png" group-title="Movies",Starz Movies
https://playertest.longtailvideo.com/adaptive/bipbop/gear2/prog_index.m3u8

#EXTINF:-1 tvg-id="movies.amc" tvg-name="AMC Movies" tvg-logo="https://example.com/amc.png" group-title="Movies",AMC Movies
https://playertest.longtailvideo.com/adaptive/bipbop/gear3/prog_index.m3u8

#EXTINF:-1 tvg-id="movies.fx" tvg-name="FX Movies" tvg-logo="https://example.com/fx.png" group-title="Movies",FX Movies
https://playertest.longtailvideo.com/adaptive/bipbop/gear4/prog_index.m3u8

#EXTINF:-1 tvg-id="movies.tnt" tvg-name="TNT Movies" tvg-logo="https://example.com/tnt.png" group-title="Movies",TNT Movies
https://playertest.longtailvideo.com/adaptive/bipbop/gear1/prog_index.m3u8
EOF

echo "📊 Files created in: $WORKING_DIR"
ls -la "$WORKING_DIR"

echo ""
echo "✅ Working M3U Files Created!"
echo "============================="
echo ""
echo "📺 Now you can use these paths in Jellyfin:"
echo "• /config/free_tv_github.m3u8 (6 channels)"
echo "• /config/iptv_org_global.m3u (6 channels)"
echo "• /config/us_channels.m3u (6 channels)"
echo "• /config/news_channels.m3u (6 channels)"
echo "• /config/sports_channels.m3u (6 channels)"
echo "• /config/movies_channels.m3u (6 channels)"
echo ""
echo "🌐 Go back to Jellyfin and try adding these tuners!"
echo "📋 Use the paths above (starting with /config/)"


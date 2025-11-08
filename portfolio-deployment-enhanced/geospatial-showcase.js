// Geospatial Showcase Animation & RainViewer Integration
// Adds creative interactivity to the epic showcase section

(function() {
    // Animate radar sweep and city lights on hover/click
    document.addEventListener('DOMContentLoaded', function() {
        // Radar sweep: pulse on hover
        const radarCard = document.querySelector('.weather-card');
        if (radarCard) {
            radarCard.addEventListener('mouseenter', () => {
                radarCard.classList.add('active');
            });
            radarCard.addEventListener('mouseleave', () => {
                radarCard.classList.remove('active');
            });
        }
        // City lights: twinkle on hover
        const nightCard = document.querySelector('.nightlights-card');
        if (nightCard) {
            nightCard.addEventListener('mouseenter', () => {
                nightCard.classList.add('active');
            });
            nightCard.addEventListener('mouseleave', () => {
                nightCard.classList.remove('active');
            });
        }
        // RainViewer API: fetch latest radar frame for Ho Chi Minh City
        // (Demo: overlays a radar image as a background in the radar container)
        const radarContainer = document.querySelector('.radar-container');
        if (radarContainer) {
            fetch('https://api.rainviewer.com/public/weather-maps.json')
                .then(res => res.json())
                .then(data => {
                    // Find latest frame for Vietnam region
                    const frames = data.radar && data.radar.past;
                    if (frames && frames.length) {
                        const latest = frames[frames.length - 1];
                        // RainViewer tile for Ho Chi Minh City (approx lat/lon)
                        const url = `https://tilecache.rainviewer.com/v2/radar/${latest}/256/11/1762/1102/1/1_1.png`;
                        const img = document.createElement('img');
                        img.src = url;
                        img.alt = 'Live Weather Radar';
                        img.style.position = 'absolute';
                        img.style.top = '0';
                        img.style.left = '0';
                        img.style.width = '100%';
                        img.style.height = '100%';
                        img.style.opacity = '0.45';
                        img.style.pointerEvents = 'none';
                        img.style.zIndex = '2';
                        radarContainer.appendChild(img);
                    }
                });
        }
    });
})();

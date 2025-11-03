# Fixing Mixed Content (insecure audio) for Moodle pages

Problem

The Moodle page is loaded over HTTPS but includes audio files served over plain HTTP from 136.243.155.166:8086. Modern browsers block mixed content, so audio/video files requested with http:// will not load and the media player will show MEDIA_ERR_SRC_NOT_SUPPORTED.

Two safe fixes (pick one):

1) Proxy the audio via your Moodle domain (recommended)

- Configure your Moodle webserver (nginx) to proxy requests for a path like `/vietnamese-audio/` to the backend HTTP host `https://moodle.simondatalab.de/vietnamese-audio/`. That way the browser requests `https://moodle.simondatalab.de/vietnamese-audio/colloquial_track_02.mp3` (secure), nginx fetches the audio over HTTP internally and serves it over HTTPS.
- This requires no content edits in Moodle (you can update the page to point at the proxied path) and preserves the original backend.

Example nginx location block (add to your Moodle server config and reload nginx):

```nginx
location ^~ /vietnamese-audio/ {
    proxy_pass https://moodle.simondatalab.de/vietnamese-audio/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    # Optional: enable caching and range requests for seeking
    proxy_cache_bypass $http_range;
    proxy_set_header Range $http_range;
    proxy_set_header If-Range $http_if_range;
}
```

After adding the above, reload nginx:

```bash
sudo nginx -t && sudo systemctl reload nginx
```

Then update any Moodle page content that points to `https://moodle.simondatalab.de/vietnamese-audio/...` to `https://moodle.simondatalab.de/vietnamese-audio/...` (or leave the original URL if you set a rewrite rule that redirects the old host to the proxied path).

2) Host audio directly in Moodle (simpler for small sets)

- Upload the audio files to the course (Files or a resource), then change the page links to the Moodle file URLs (these will be HTTPS). This is best for small numbers of files and avoids running a proxy.

Quick checks and commands

- Find all pages/content that point to the insecure host (run locally in the repo or on the server):

```bash
grep -R "136.243.155.166:8086" -n || true
```

- Test the proxied URL once nginx is configured:

```bash
curl -I "https://moodle.simondatalab.de/vietnamese-audio/colloquial_track_02.mp3"
```

Notes about the VIDEOJS error

- The MEDIA_ERR_SRC_NOT_SUPPORTED error is a generic browser error that commonly appears when the media source is blocked (mixed content) or when the server does not support range requests required for seeking. The nginx snippet above preserves range headers to help video/audio players.

Security and performance

- If the backend is trusted and internal, proxying is fine. Add caching for production (proxy_cache) to reduce load on the backend.
- Use TLS termination at the proxy (the Moodle site already uses HTTPS) and protect the backend behind firewall rules if possible.

If you want, I can:
- Create a ready-to-drop nginx snippet file in this repo and a one-line command you can run on the Moodle host to enable it (I can add that now), or
- Update Moodle page HTML in the repo to point to the new proxied HTTPS paths, or
- Prepare a small script that uploads the audio into Moodle via webservice and updates page HTML automatically (requires a Moodle token).

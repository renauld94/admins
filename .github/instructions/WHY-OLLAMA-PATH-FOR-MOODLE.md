# ❓ Why Does Moodle Use `/etc/letsencrypt/live/ollama.simondatalab.de/` Path?

**Quick Answer:** The directory name `ollama.simondatalab.de` is **just a label**. The actual certificate inside covers **all 8 domains** including `moodle.simondatalab.de`.

---

## 📝 The Explanation

### What You're Seeing in the Config

```nginx
server {
    listen 443 ssl http2;
    server_name moodle.simondatalab.de;

    ssl_certificate /etc/letsencrypt/live/ollama.simondatalab.de/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/ollama.simondatalab.de/privkey.pem;
}
```

**This looks confusing** because:
- You're serving `moodle.simondatalab.de`
- But the certificate path says `ollama.simondatalab.de`

---

## ✅ Why This Actually Works

### 1. It's a Multi-Domain Certificate

When we obtained the certificate, we requested it for **ALL domains at once**:

```bash
certbot certonly --dns-cloudflare \
  -d simondatalab.de \
  -d www.simondatalab.de \
  -d moodle.simondatalab.de \
  -d grafana.simondatalab.de \
  -d ollama.simondatalab.de \
  -d mlflow.simondatalab.de \
  -d booklore.simondatalab.de \
  -d geoneuralviz.simondatalab.de
```

This created **ONE certificate** that works for all 8 domains.

### 2. Certbot's Naming Convention

Certbot needs to store this certificate somewhere, so it creates a directory. The directory name is chosen from one of the domains in the request (usually the first one processed or alphabetically).

In our case, it chose: `/etc/letsencrypt/live/ollama.simondatalab.de/`

**This is just a filesystem path!** The directory could be called anything:
- `/etc/letsencrypt/live/ollama.simondatalab.de/`
- `/etc/letsencrypt/live/simondatalab.de/`
- `/etc/letsencrypt/live/my-awesome-cert/`
- `/etc/letsencrypt/live/bananas/`

The name doesn't affect functionality!

### 3. The Certificate Contains SANs (Subject Alternative Names)

The actual certificate file (`fullchain.pem`) contains a list of **all valid domains**:

```bash
# View the certificate SANs
openssl x509 -in /etc/letsencrypt/live/ollama.simondatalab.de/fullchain.pem \
  -noout -text | grep -A 10 "Subject Alternative Name"
```

**Output:**
```
X509v3 Subject Alternative Name:
    DNS:booklore.simondatalab.de
    DNS:geoneuralviz.simondatalab.de
    DNS:grafana.simondatalab.de
    DNS:moodle.simondatalab.de          ← MOODLE IS HERE!
    DNS:mlflow.simondatalab.de
    DNS:ollama.simondatalab.de
    DNS:simondatalab.de
    DNS:www.simondatalab.de
```

When a browser connects to `https://moodle.simondatalab.de`:

1. **Nginx** receives the request
2. **SNI (Server Name Indication)** tells nginx the client wants `moodle.simondatalab.de`
3. Nginx matches the `server_name moodle.simondatalab.de` block
4. Nginx sends the certificate from `/etc/letsencrypt/live/ollama.simondatalab.de/fullchain.pem`
5. **Browser checks** if certificate SANs include `moodle.simondatalab.de` ✅
6. **SSL handshake succeeds** because `moodle.simondatalab.de` is in the SANs list!

---

## 🔄 Why Use One Certificate for All Domains?

### Benefits

1. **Simpler Management**
   - One renewal process instead of 8
   - One configuration to maintain
   - One expiration date to track

2. **Cost-Effective**
   - Let's Encrypt has rate limits (50 certificates per week)
   - Using one multi-domain cert stays well within limits

3. **Performance**
   - One certificate to load into memory
   - Smaller nginx config files

4. **Easier Updates**
   - Change certificate once, affects all domains
   - No need to update 8 different configs

### Drawbacks

**Minimal:**
- Slightly confusing directory name (this document solves that!)
- If one domain needs different certificate settings, you'd need to split

---

## 🛠️ How to Verify This

### Check Certificate Subject

```bash
ssh -p 2222 root@136.243.155.166 \
  'openssl x509 -in /etc/letsencrypt/live/ollama.simondatalab.de/fullchain.pem -noout -subject'
```

**Output:**
```
subject=CN = simondatalab.de
```

Notice: **Subject CN is `simondatalab.de`**, not `ollama`! The directory name is irrelevant.

### Check Certificate SANs

```bash
ssh -p 2222 root@136.243.155.166 \
  'openssl x509 -in /etc/letsencrypt/live/ollama.simondatalab.de/fullchain.pem -noout -text | grep -A 10 "Subject Alternative Name"'
```

You'll see all 8 domains listed, including `moodle.simondatalab.de`.

### Test Moodle SSL

```bash
echo | openssl s_client -connect moodle.simondatalab.de:443 \
  -servername moodle.simondatalab.de 2>/dev/null | grep -E "subject|issuer|Verify"
```

**Expected Output:**
```
subject=CN = simondatalab.de
issuer=C = US, O = Let's Encrypt, CN = E8
Verify return code: 0 (ok)
```

The verification succeeds because `moodle.simondatalab.de` is in the SANs!

---

## 📚 Technical Deep Dive

### How TLS/SSL Certificates Work

1. **Subject (CN):** The primary domain (usually the first one requested)
2. **Subject Alternative Names (SANs):** Additional domains the certificate covers
3. **Browser Validation:** Browser checks if requested domain matches **either** CN **or** any SAN

### Example Certificate Structure

```
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: ...
        Signature Algorithm: ecdsa-with-SHA256
        Issuer: C=US, O=Let's Encrypt, CN=E8
        Validity
            Not Before: Oct 14 01:38:22 2025 GMT
            Not After : Jan 12 01:38:21 2026 GMT
        Subject: CN=simondatalab.de                    ← Main subject
        ...
        X509v3 extensions:
            X509v3 Subject Alternative Name:           ← The important part!
                DNS:booklore.simondatalab.de
                DNS:geoneuralviz.simondatalab.de
                DNS:grafana.simondatalab.de
                DNS:moodle.simondatalab.de            ← Moodle covered here!
                DNS:mlflow.simondatalab.de
                DNS:ollama.simondatalab.de
                DNS:simondatalab.de
                DNS:www.simondatalab.de
```

The certificate is **valid for any domain in the SANs list**, regardless of:
- The Subject CN
- The directory name on disk
- Which nginx server block uses it

---

## 🔧 If You Want to Rename the Directory

**You can rename it for clarity, but it's not necessary!**

### Steps to Rename

```bash
# 1. Stop nginx
systemctl stop nginx

# 2. Rename certificate directory
mv /etc/letsencrypt/live/ollama.simondatalab.de \
   /etc/letsencrypt/live/simondatalab-all-domains

# 3. Rename renewal config
mv /etc/letsencrypt/renewal/ollama.simondatalab.de.conf \
   /etc/letsencrypt/renewal/simondatalab-all-domains.conf

# 4. Update renewal config internal paths
sed -i 's|ollama.simondatalab.de|simondatalab-all-domains|g' \
   /etc/letsencrypt/renewal/simondatalab-all-domains.conf

# 5. Update ALL nginx configs
sed -i 's|/etc/letsencrypt/live/ollama.simondatalab.de/|/etc/letsencrypt/live/simondatalab-all-domains/|g' \
   /etc/nginx/sites-enabled/*.conf

# 6. Test nginx config
nginx -t

# 7. Start nginx
systemctl start nginx
```

**However:** This is **purely cosmetic**. The certificate will work exactly the same before and after.

---

## 📊 Summary Comparison

| Aspect | Current Setup | If You Renamed |
|--------|---------------|----------------|
| **Directory Path** | `/etc/letsencrypt/live/ollama.simondatalab.de/` | `/etc/letsencrypt/live/simondatalab-all/` |
| **Certificate Subject** | CN=simondatalab.de | CN=simondatalab.de |
| **Domains Covered** | 8 domains (SANs) | 8 domains (SANs) |
| **Functionality** | ✅ Works perfectly | ✅ Works perfectly |
| **Clarity** | Slightly confusing | More intuitive |
| **Risk** | None | Low (if done carefully) |
| **Benefit** | No action needed | Better documentation |

**Recommendation:** **Leave it as-is** unless the naming really bothers you. It works perfectly fine!

---

## 🎯 Key Takeaways

1. **Directory name ≠ Certificate validity**
   - `/etc/letsencrypt/live/ollama.simondatalab.de/` is just a filesystem path
   - The certificate inside works for **all 8 domains**

2. **One certificate, many domains**
   - This is a **multi-domain (SAN) certificate**
   - All nginx server blocks use the **same certificate file**

3. **How it works**
   - Browser requests `https://moodle.simondatalab.de`
   - Nginx sends certificate from `ollama.simondatalab.de` directory
   - Browser checks SANs, finds `moodle.simondatalab.de`, validates ✅

4. **Why certbot chose "ollama"**
   - Possibly first domain processed alphabetically
   - Or from a previous certificate that existed
   - Doesn't matter - it's just a label

5. **Should you rename it?**
   - **No** - it works fine as-is
   - **Yes** - only if you want better clarity in your configs
   - **Risk** - low, but requires careful updating of all nginx configs

---

## 📖 Further Reading

- [Let's Encrypt Multi-Domain Certificates](https://letsencrypt.org/docs/rate-limits/)
- [SSL Certificate SANs Explained](https://en.wikipedia.org/wiki/Subject_Alternative_Name)
- [Nginx SNI Configuration](https://nginx.org/en/docs/http/configuring_https_servers.html#sni)

---

**For complete infrastructure details, see:**
- `/home/simon/Learning-Management-System-Academy/.github/instructions/infrastructure-configuration.md`
- `/home/simon/Learning-Management-System-Academy/.github/instructions/quick-reference.md`

**Document Version:** 1.0  
**Created:** October 15, 2025  
**Author:** Simon Renauld

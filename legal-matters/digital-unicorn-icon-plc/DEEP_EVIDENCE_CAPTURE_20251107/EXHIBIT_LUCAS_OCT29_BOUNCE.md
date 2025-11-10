# EXHIBIT: Lucas Account Deactivation Bounce (Oct 29, 2025)

**Chain of Custody:** Extracted from Gmail All Mail mbox (Google Takeout)
**Extraction Date:** 2025-11-07T17:54:23.796056
**Evidence ID:** EXHIBIT_LUCAS_OCT29_BOUNCE_001

## Top 3 Candidate Bounce Messages


### Candidate #1

**Filename:** bounce_000396.eml
**SHA-256:** 662c60ead484b1cd42b490a641198226aee86ac785594337428ce54077b8d795
**Date:** Wed, 29 Oct 2025 01:19:05 -0700 (PDT)
**From:** Mail Delivery Subsystem <mailer-daemon@googlemail.com>
**Subject:** Delivery Status Notification (Failure)
**Score:** 179

**Preview:**
```
X-GM-THRID: 1846679782616359562
X-Gmail-Labels: Inbox,Important,Opened,Category Updates
Delivered-To: sn.renauld@gmail.com
Received: by 2002:a17:907:7fab:b0:b5f:f44b:774e with SMTP id qk43csp58658ejc;
        Wed, 29 Oct 2025 01:19:06 -0700 (PDT)
X-Received: by 2002:a17:906:fe0e:b0:b47:de64:df34 with SMTP id
 a640c23a62f3a-b703d53f851mr191647666b.51.1761725946100;
        Wed, 29 Oct 2025 01:19:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1761725946; cv=none;
        d=google.com; s=arc-20240605;
        b=UcnVGRBAvZ38OsdOJ39SOUkmmMj0M80Yeg/a/POS63vFzqJzGhebWSHvU6he2VRanx
         wh1g6zJ6zjvrnhSV6sfPJASiZzOKRgEQXgtRY6fvcVK7A4ZUDUFMQOmrNxPdxhiOfMz2
         ywi/xJ+jpw2pxPQt52QzKQG723kcIcGh9MlC8/p/OahB69GJBkuOxrblInjlNX2vhUQY
         WGsnyes5uX2kFVJ2jDamYJz6XXcIW8DZW/05/ZMKl1AGbfXvJOzfLSO1XeEYqtPtByaE
         WIflC4d0QyPikFJwOJlBp0RtBCjsBLUMkOEVMeW23itHdJd0X+akBme2NJ+QeyOLv++1
         nWDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com;
 s=arc-20240605;

...
```

### Candidate #2

**Filename:** bounce_000166.eml
**SHA-256:** c5df08f25072783c635d8c5f2270ede2bc39005aa6d388f5a05acfe9a7ed339c
**Date:** Tue, 21 Oct 2025 14:25:00 -0700 (PDT)
**From:** Mail Delivery Subsystem <mailer-daemon@googlemail.com>
**Subject:** Delivery Status Notification (Failure)
**Score:** 159

**Preview:**
```
X-GM-THRID: 1846456220478155188
X-Gmail-Labels: Inbox,Important,Opened,Category Updates
Delivered-To: sn.renauld@gmail.com
Received: by 2002:a17:907:d205:b0:b5f:f44b:774e with SMTP id vd5csp4158816ejc;
        Tue, 21 Oct 2025 14:25:01 -0700 (PDT)
X-Received: by 2002:a17:906:2b15:b0:b64:b522:9bb0 with SMTP id
 a640c23a62f3a-b64b5229bc3mr1506030066b.26.1761081900824;
        Tue, 21 Oct 2025 14:25:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1761081900; cv=none;
        d=google.com; s=arc-20240605;
        b=U4lDrMKSTB1d2oM5oIuCDHKefZPIgM7LICrwjeN4qeM/YiesAPRxlsHQO67epE8egh
         HdAo4Qd9eM8C1e3AY+d3bqyy/4Jt/ABSjwGXoWE3tJs/8mqsuRcwHNG0ch1O4OEEXNrB
         ck1TDzAJrYjuv/xAyV3gOvCkJ9KnjMM8d9r1nWWbCf6egkciR9jNP8FtlRlHuqwVvsaC
         tKxRZ4Fq0Sze1lF6JvdZVYc11ylNRxO7RMc+OG6DbzvBrtLPFjYolmxwgQFmR6r3yJjZ
         Z/l252lcgQTufFv2TbtirWR0V95iGw0P5aRZGxRE6uVNiH2FPVRRLMEtXYDOF21aYVME
         n+dA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com;
 s=arc-20240605
...
```

### Candidate #3

**Filename:** bounce_000167.eml
**SHA-256:** 7d9774088d36759b1270ebfc32c877c26661d172e0477270596cdf1f57e167ec
**Date:** Mon, 20 Oct 2025 18:15:14 -0700 (PDT)
**From:** Mail Delivery Subsystem <mailer-daemon@googlemail.com>
**Subject:** Delivery Status Notification (Delay)
**Score:** 159

**Preview:**
```
X-GM-THRID: 1846456220478155188
X-Gmail-Labels: Archived,Important,Opened,Category Updates
Delivered-To: sn.renauld@gmail.com
Received: by 2002:a17:907:d205:b0:b5f:f44b:774e with SMTP id vd5csp3558297ejc;
        Mon, 20 Oct 2025 18:15:14 -0700 (PDT)
X-Received: by 2002:a17:907:2d06:b0:b40:cfe9:ed2c with SMTP id
 a640c23a62f3a-b64769cd245mr1688921366b.64.1761009314619;
        Mon, 20 Oct 2025 18:15:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1761009314; cv=none;
        d=google.com; s=arc-20240605;
        b=RAyAy8xamXsYwJ+4ZYrPYXnzDqBIjPAAjKsTbUiWwNILF/vdV6PYGqu15BWlHyIs84
         ZZQeVuHWjWLBGaN+CZEL1LiaqtVW3yzyjyiyHL8p1vuUko+ij2p9CO0KAEfCVhhJCyM/
         N7DKJKfctqCIHaNAq9G6s0lAcNiNMBJ91xgCKo9IVMzlEeVQiw72iIsK97fkk3XEuwlR
         2CL9o5Z1++pXaE4PxKcKUdHfQktiocPJpx7Bgr+dAVvvZjnkfELKw5gbBokIA2uSiIS2
         FbpWdw9HeGs1t3+iBSqW74GdfBRDmSSj/SX6rChpsD9zINc80GbLVkzr0YU/P+ZicXuG
         hzdw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com;
 s=arc-20240
...
```

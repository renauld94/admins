#!/usr/bin/env bash
set -euo pipefail

PHP=/opt/bitnami/php/bin/php
CLI=/opt/bitnami/moodle/admin/cli
PAYLOAD_FILE=/tmp/moodle_head_payload.html

if [ -f "$PAYLOAD_FILE" ]; then
  PAY=$(tr -d '\n' < "$PAYLOAD_FILE")
else
  PAY='<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin><link rel="stylesheet" href="/moodle-simondatalab.css"><script defer src="/moodle-remove-emojis.js"></script>'
fi

CUR="$($PHP $CLI/cfg.php --component=core --name=additionalhtmlhead || true)"
if printf '%s' "$CUR" | grep -q 'moodle-simondatalab.css'; then
  echo 'Already'
else
  printf '%s' "$CUR$PAY" > /tmp/_payload.html
  VAL=$(tr -d '\n' < /tmp/_payload.html)
  $PHP $CLI/cfg.php --component=core --name=additionalhtmlhead --set="$VAL"
  rm -f /tmp/_payload.html
  echo 'Updated'
fi

$PHP $CLI/purge_caches.php

#!/bin/bash
# filepath: /home/simon/Desktop/learning-platform/set_jnj_theme_pg.sh

# --- CONFIGURATION ---
DB_CONTAINER="moodle-db"         # Change if your DB container is named differently
DB_USER="bn_moodle"
DB_PASS="moodle_pass"
DB_NAME="bitnami_moodle"
TABLE_PREFIX="mdl_"              # Default Moodle prefix for Bitnami/Postgres

# --- J&J CSS ---
JNJ_CSS='<link href="https://fonts.googleapis.com/css?family=Open+Sans:400,600,700&display=swap" rel="stylesheet">
<style>
body, html { background: #f5f5f5 !important; font-family: "Open Sans", Arial, sans-serif !important; color: #002f6c !important; }
header .logo img, .login-logo img, .navbar-brand img { content: url("https://www.jnjvisionpro.com/themes/custom/jnjvisionpro/logo.svg"); max-width: 180px !important; margin: 0 auto 1.5rem auto !important; display: block !important; }
a, .btn-link { color: #002f6c !important; text-decoration: underline; }
a:hover, .btn-link:hover { color: #d71920 !important; }
.btn-primary, input[type="submit"], button, .btn { background: #d71920 !important; color: #fff !important; border: none !important; border-radius: 6px !important; font-weight: 600 !important; font-size: 1.1rem !important; padding: 0.75rem 1.5rem !important; }
.btn-primary:hover, input[type="submit"]:hover, button:hover, .btn:hover { background: #b0161a !important; }
.navbar, .navbar-nav, .navbar-brand { background: #002f6c !important; color: #fff !important; }
.navbar a, .navbar-nav a { color: #fff !important; }
.navbar a:hover, .navbar-nav a:hover { color: #d71920 !important; }
.card, .block, .login-wrapper, .login-container, .modal-content { background: #fff !important; border-radius: 12px !important; box-shadow: 0 4px 24px rgba(0,47,108,0.08) !important; }
footer, #page-footer { background: #002f6c !important; color: #fff !important; border-top: 4px solid #d71920 !important; }
footer a, #page-footer a { color: #fff !important; text-decoration: underline !important; }
footer a:hover, #page-footer a:hover { color: #d71920 !important; }
h1, h2, h3, h4, h5, h6 { color: #002f6c !important; font-family: "Open Sans", Arial, sans-serif !important; font-weight: 700 !important; }
::-webkit-scrollbar-thumb { background: #d71920 !important; }
::-webkit-scrollbar-track { background: #f5f5f5 !important; }
</style>'

# --- APPLY TO POSTGRESQL ---
docker exec -e PGPASSWORD="$DB_PASS" -i $DB_CONTAINER psql -U "$DB_USER" -d "$DB_NAME" \
  -c "INSERT INTO ${TABLE_PREFIX}config (name, value) VALUES ('additionalhtmlhead', \$\$${JNJ_CSS}\$\$)
      ON CONFLICT (name) DO UPDATE SET value = EXCLUDED.value;"

echo "J&J CSS applied to Moodle Additional HTML (Within HEAD)."

# --- RESTART DOCKER SERVICES ---
docker compose down
docker compose up -d

echo "Docker containers restarted."

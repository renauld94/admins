#!/bin/bash
# Install Taiga (Agile project management) on CT 150 for job search tracking

set -euo pipefail

BOLD="\033[1m"
NC="\033[0m"

separator() {
  echo "========================================================================"
}

echo
separator
echo "${BOLD}🌱 Taiga Installation for CT 150${NC}"
separator
echo

TAIGA_DIR="/opt/taiga"
HOSTNAME_EXPECTED="portfolio-web"
ALT_HOSTNAME="portfolio-web-1000150"
CURRENT_HOSTNAME="$(hostname)"

if [[ "$CURRENT_HOSTNAME" != "$HOSTNAME_EXPECTED" && "$CURRENT_HOSTNAME" != "$ALT_HOSTNAME" ]]; then
  echo "⚠️  This script is intended to run on CT 150 (${HOSTNAME_EXPECTED})."
  echo "   Current host: ${CURRENT_HOSTNAME}"
  read -r -p "Continue anyway? (y/N): " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
  fi
fi

echo "📁 Creating Taiga base directory at ${TAIGA_DIR}"
mkdir -p "$TAIGA_DIR"
cd "$TAIGA_DIR"

echo "🔐 Generating secrets"
SECRET_KEY="$(openssl rand -hex 32)"
TAIGA_DB_PASS="$(openssl rand -hex 24)"
RABBIT_PASS="$(openssl rand -hex 16)"
REDIS_PASS="$(openssl rand -hex 16)"

if ! command -v docker >/dev/null 2>&1; then
  echo "🐳 Installing Docker"
  apt-get update
  apt-get install -y ca-certificates curl gnupg lsb-release
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list >/dev/null
  apt-get update
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  systemctl enable docker
  systemctl start docker
else
  echo "✅ Docker already installed"
fi

if ! command -v docker-compose >/dev/null 2>&1; then
  echo "📦 Installing docker-compose"
  curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
else
  echo "✅ docker-compose already available"
fi

env_file="${TAIGA_DIR}/.env"
cat > "$env_file" <<EOF
# Taiga environment configuration
TAIGA_SECRET_KEY=${SECRET_KEY}
TAIGA_DB_NAME=taiga
TAIGA_DB_USER=taiga
TAIGA_DB_PASSWORD=${TAIGA_DB_PASS}
TAIGA_DB_HOST=taiga-db
TAIGA_DB_PORT=5432
TAIGA_RABBITMQ_USER=taiga
TAIGA_RABBITMQ_PASSWORD=${RABBIT_PASS}
TAIGA_REDIS_PASSWORD=${REDIS_PASS}
TAIGA_REDIS_HOST=taiga-redis
TAIGA_REDIS_PORT=6379
TAIGA_EVENTS_HOST=taiga-events
TAIGA_EVENTS_PORT=3899
TAIGA_DOMAIN=taiga.simondatalab.de
TAIGA_SCHEME=https
PUBLIC_REGISTER_ENABLED=false
DEFAULT_FROM_EMAIL=notifications@simondatalab.de
EMAIL_USE_TLS=false
EMAIL_USE_SSL=false
EMAIL_HOST=mail.simondatalab.de
EMAIL_PORT=587
EMAIL_HOST_USER=
EMAIL_HOST_PASSWORD=
EOF

echo "🧾 .env configuration generated"

docker_compose_file="${TAIGA_DIR}/docker-compose.yml"
cat > "$docker_compose_file" <<'EOF'
version: "3.9"

services:
  taiga-db:
    image: postgres:14-alpine
    container_name: taiga-db
    restart: unless-stopped
    environment:
      POSTGRES_DB: ${TAIGA_DB_NAME}
      POSTGRES_USER: ${TAIGA_DB_USER}
      POSTGRES_PASSWORD: ${TAIGA_DB_PASSWORD}
    volumes:
      - db-data:/var/lib/postgresql/data

  taiga-redis:
    image: redis:6-alpine
    container_name: taiga-redis
    restart: unless-stopped
    command: ["redis-server", "--requirepass", "${TAIGA_REDIS_PASSWORD}"]
    volumes:
      - redis-data:/data

  taiga-events:
    image: ghcr.io/taigaio/taiga-events:6.8.0
    container_name: taiga-events
    restart: unless-stopped
    environment:
      RABBITMQ_URL: amqp://taiga:${TAIGA_RABBITMQ_PASSWORD}@taiga-rabbitmq:5672//
    depends_on:
      - taiga-rabbitmq

  taiga-rabbitmq:
    image: rabbitmq:3.11-management-alpine
    container_name: taiga-rabbitmq
    restart: unless-stopped
    environment:
      RABBITMQ_DEFAULT_USER: taiga
      RABBITMQ_DEFAULT_PASS: ${TAIGA_RABBITMQ_PASSWORD}
      RABBITMQ_DEFAULT_VHOST: /
    volumes:
      - rabbitmq-data:/var/lib/rabbitmq

  taiga-back:
    image: ghcr.io/taigaio/taiga-back:6.8.0
    container_name: taiga-back
    restart: unless-stopped
    env_file:
      - .env
    environment:
      DJANGO_SETTINGS_MODULE: "taiga.settings"
      TAIGA_SSL: "true"
      TAIGA_SECRET_KEY: ${TAIGA_SECRET_KEY}
      TAIGA_URL: ${TAIGA_SCHEME}://${TAIGA_DOMAIN}
      EMAIL_USE_TLS: ${EMAIL_USE_TLS}
      EMAIL_USE_SSL: ${EMAIL_USE_SSL}
    volumes:
      - media-data:/taiga/media
      - static-data:/taiga/static
    depends_on:
      - taiga-db
      - taiga-redis
      - taiga-rabbitmq

  taiga-front:
    image: ghcr.io/taigaio/taiga-front:6.8.0
    container_name: taiga-front
    restart: unless-stopped
    environment:
      TAIGA_URL: ${TAIGA_SCHEME}://${TAIGA_DOMAIN}
      TAIGA_WEBSOCKETS_URL: wss://${TAIGA_DOMAIN}:443
    depends_on:
      - taiga-back
      - taiga-events
    ports:
      - "9000:80"

  taiga-protected:
    image: ghcr.io/taigaio/taiga-protected:6.8.0
    container_name: taiga-protected
    restart: unless-stopped
    volumes:
      - media-data:/taiga/media
      - protected-data:/taiga/protected
    depends_on:
      - taiga-back

volumes:
  db-data:
  media-data:
  static-data:
  protected-data:
  redis-data:
  rabbitmq-data:
EOF

echo "🧾 docker-compose.yml written"

echo "🌐 Configuring nginx reverse proxy"
cat > /etc/nginx/sites-available/taiga <<'EOF'
server {
    listen 80;
    server_name taiga.simondatalab.de;

    location / {
        proxy_pass http://127.0.0.1:9000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

ln -sf /etc/nginx/sites-available/taiga /etc/nginx/sites-enabled/taiga

nginx -t
systemctl reload nginx

echo "✅ nginx reloaded"

echo "🚀 Starting Taiga stack"
cd "$TAIGA_DIR"
docker-compose pull
docker-compose up -d

sleep 20

echo
separator
echo "${BOLD}🔧 Taiga is deploying...${NC}"
separator
echo

docker-compose ps

readme_file="${TAIGA_DIR}/README.md"
cat > "$readme_file" <<EOF
# Taiga Project Management - CT 150 Deployment

## Access

- Local: http://10.0.0.150:9000
- Domain: http://taiga.simondatalab.de (after DNS & SSL)

## Next Steps

1. Add DNS record `taiga.simondatalab.de` → CT 150 public IP.
2. Configure SSL (use certbot or existing automation).
3. Create initial admin user:
   \`\`\`
   cd ${TAIGA_DIR}
   docker-compose exec taiga-back python manage.py createsuperuser
   \`\`\`
4. Log in at http://taiga.simondatalab.de
5. Under Admin → Sites, update domain to `taiga.simondatalab.de`.
6. In Admin → Config, set proper email settings if needed.

## Useful Commands

- Start:   \`cd ${TAIGA_DIR} && docker-compose up -d\`
- Stop:    \`cd ${TAIGA_DIR} && docker-compose down\`
- Logs:    \`cd ${TAIGA_DIR} && docker-compose logs -f\`
- Update:  \`cd ${TAIGA_DIR} && docker-compose pull && docker-compose up -d\`
- Backup DB: \`docker exec taiga-db pg_dump -U taiga taiga > taiga_$(date +%Y%m%d).sql\`
- Restore DB: \`docker exec -i taiga-db psql -U taiga taiga < taiga_YYYYMMDD.sql\`

## Board Suggestions (Job Search)

- Project: "Job Search 2025"
  - Epics: Applications, Interviews, Offers, Recruiters, Research
  - User Stories: One per company/role
  - Kanban: Apply → Screen → Tech → Final → Offer → Offer Signed

- Project: "Recruiter Pipeline"
  - Use Kanban for outreach stages (New, Contacted, Active, Warm, Cold)

- Project: "Skill Refresh"
  - Use sprints for weekly learning (LeetCode, System Design, Domain knowledge)

## Services

- PostgreSQL   (taiga-db)
- Redis        (taiga-redis)
- RabbitMQ     (taiga-rabbitmq)
- Backend API  (taiga-back)
- Frontend     (taiga-front)
- Protected    (taiga-protected)
- Events       (taiga-events)

## Troubleshooting

- Check services: \`docker-compose ps\`
- Tail logs: \`docker-compose logs -f taiga-back\`
- Restart stack: \`docker-compose restart\`

Installation Date: $(date)
EOF

echo
separator
echo "${BOLD}🎉 Taiga deployment complete${NC}"
separator
echo

echo "📍 Directory: ${TAIGA_DIR}"
echo "📘 README:    ${readme_file}"
echo "🌐 Access:    http://10.0.0.150:9000"
echo "📝 DNS:       Point taiga.simondatalab.de to CT 150"
echo

echo "Next steps:"
echo "  1. Create admin account with docker-compose exec command."
echo "  2. Log in and configure projects."
echo "  3. Enable HTTPS after DNS update."
echo

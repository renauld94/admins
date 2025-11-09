#!/bin/bash

# EPIC Geodashboard - Production Deployment Automation Script
# This script automates the production deployment process
# Usage: sudo bash deploy_to_production.sh <domain> <email> <environment>

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOMAIN="${1:-geodashboard.example.com}"
EMAIL="${2:-admin@example.com}"
ENVIRONMENT="${3:-production}"
INSTALL_DIR="/opt/geodashboard"
BACKUP_DIR="/mnt/backups/geodashboard"

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
    exit 1
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        log_error "This script must be run as root"
    fi
    
    # Check OS
    if ! grep -q "Ubuntu" /etc/os-release; then
        log_warn "This script is optimized for Ubuntu. Compatibility not guaranteed."
    fi
    
    # Check disk space
    AVAILABLE_SPACE=$(df /opt | awk 'NR==2 {print $4}')
    if [ "$AVAILABLE_SPACE" -lt 20971520 ]; then
        log_error "Insufficient disk space (need 20GB, have $(($AVAILABLE_SPACE/1024/1024))GB)"
    fi
    
    # Check memory
    TOTAL_MEMORY=$(free -m | awk 'NR==2 {print $2}')
    if [ "$TOTAL_MEMORY" -lt 4096 ]; then
        log_error "Insufficient memory (need 4GB, have ${TOTAL_MEMORY}MB)"
    fi
    
    log_success "Prerequisites check passed"
}

setup_system() {
    log_info "Setting up system packages..."
    
    # Update package manager
    apt-get update
    apt-get upgrade -y
    
    # Install required packages
    apt-get install -y \
        curl \
        wget \
        git \
        nginx \
        certbot \
        python3-certbot-nginx \
        docker.io \
        docker-compose \
        build-essential \
        openssl \
        apache2-utils
    
    # Add Docker to sudoers group
    usermod -aG docker ubuntu 2>/dev/null || true
    
    log_success "System packages installed"
}

clone_repository() {
    log_info "Cloning repository..."
    
    # Create install directory
    mkdir -p "$INSTALL_DIR"
    cd "$INSTALL_DIR"
    
    # Clone repository
    if [ -d .git ]; then
        git pull origin main
    else
        git clone git@github.com:renauld94/admins.git .
    fi
    
    # Checkout main branch
    git checkout main
    git pull origin main
    
    log_success "Repository cloned/updated"
}

create_environment_file() {
    log_info "Creating environment configuration..."
    
    # Check if .env exists
    if [ -f "$INSTALL_DIR/.env" ]; then
        log_warn ".env file already exists, skipping creation"
        return
    fi
    
    # Create .env file
    cat > "$INSTALL_DIR/.env" << EOF
# EPIC Geodashboard Production Configuration
ENVIRONMENT=$ENVIRONMENT
DEBUG=false
DOMAIN=$DOMAIN

# Backend Configuration
BACKEND_HOST=0.0.0.0
BACKEND_PORT=8000
WORKERS=4

# Security
ALLOWED_HOSTS=$DOMAIN
CORS_ORIGINS=https://$DOMAIN
SECRET_KEY=$(openssl rand -base64 32)

# Monitoring
PROMETHEUS_RETENTION=200h
GRAFANA_ADMIN_PASSWORD=$(openssl rand -base64 16)
ALERTMANAGER_EMAIL=$EMAIL

# SSL/TLS
CERTBOT_EMAIL=$EMAIL
SSL_CERT_PATH=/etc/letsencrypt/live/$DOMAIN/fullchain.pem
SSL_KEY_PATH=/etc/letsencrypt/live/$DOMAIN/privkey.pem
EOF

    chmod 600 "$INSTALL_DIR/.env"
    log_success "Environment file created"
}

setup_backup_directory() {
    log_info "Setting up backup directory..."
    
    mkdir -p "$BACKUP_DIR"
    chmod 750 "$BACKUP_DIR"
    
    # Create backup script
    cat > "$INSTALL_DIR/backup.sh" << 'EOF'
#!/bin/bash
BACKUP_DIR="/mnt/backups/geodashboard"
mkdir -p $BACKUP_DIR
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> $BACKUP_DIR/backup.log
}

log "Starting backup..."

# Backup Prometheus data
docker exec prometheus-geodashboard tar czf - /prometheus 2>/dev/null > $BACKUP_DIR/prometheus_$TIMESTAMP.tar.gz || log "Prometheus backup failed"

# Backup Grafana data
docker exec grafana-geodashboard tar czf - /var/lib/grafana 2>/dev/null > $BACKUP_DIR/grafana_$TIMESTAMP.tar.gz || log "Grafana backup failed"

# Backup configurations
tar czf $BACKUP_DIR/configs_$TIMESTAMP.tar.gz /etc/prometheus /etc/nginx/sites-available 2>/dev/null || log "Config backup failed"

# Keep only last 7 days
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete

log "Backup completed: $(du -sh $BACKUP_DIR | cut -f1)"
EOF
    
    chmod +x "$INSTALL_DIR/backup.sh"
    
    # Schedule backup
    (crontab -l 2>/dev/null | grep -v "backup.sh" || true; echo "0 2 * * * $INSTALL_DIR/backup.sh") | crontab -
    
    log_success "Backup system configured"
}

deploy_backend() {
    log_info "Deploying backend service..."
    
    cd "$INSTALL_DIR"
    bash scripts/deploy_backend_systemd.sh "$ENVIRONMENT" || log_error "Backend deployment failed"
    
    sleep 5
    
    # Verify backend is running
    if systemctl is-active --quiet geospatial-data-agent.service; then
        log_success "Backend service deployed and running"
    else
        log_error "Backend service failed to start"
    fi
}

deploy_monitoring() {
    log_info "Deploying monitoring stack..."
    
    cd "$INSTALL_DIR"
    bash scripts/deploy_geodashboard_monitoring.sh "$ENVIRONMENT" || log_error "Monitoring deployment failed"
    
    sleep 10
    
    # Verify containers are running
    if docker ps | grep -q "prometheus-geodashboard"; then
        log_success "Monitoring stack deployed"
    else
        log_error "Monitoring containers failed to start"
    fi
}

configure_nginx() {
    log_info "Configuring nginx reverse proxy..."
    
    # Copy nginx config
    cp "$INSTALL_DIR/deploy/nginx/geodashboard.conf" /etc/nginx/sites-available/geodashboard
    
    # Replace localhost with domain
    sed -i "s/localhost/$DOMAIN/g" /etc/nginx/sites-available/geodashboard
    
    # Enable site
    ln -sf /etc/nginx/sites-available/geodashboard /etc/nginx/sites-enabled/
    rm -f /etc/nginx/sites-enabled/default
    
    # Test configuration
    if ! nginx -t; then
        log_error "nginx configuration test failed"
    fi
    
    # Reload nginx
    systemctl reload nginx || systemctl start nginx
    
    log_success "nginx configured and reloaded"
}

setup_ssl() {
    log_info "Setting up SSL/TLS certificate with Let's Encrypt..."
    
    # Obtain certificate
    certbot certonly --nginx \
        -d "$DOMAIN" \
        -d "admin.$DOMAIN" \
        --email "$EMAIL" \
        --agree-tos \
        --no-eff-email \
        --non-interactive \
        || log_error "Certificate acquisition failed"
    
    # Install certificate in nginx
    certbot install --nginx \
        -d "$DOMAIN" \
        --non-interactive \
        || log_warn "Certificate installation had issues"
    
    # Enable auto-renewal
    systemctl enable certbot.timer
    systemctl start certbot.timer
    
    # Test auto-renewal
    certbot renew --dry-run
    
    log_success "SSL/TLS certificate configured with auto-renewal"
}

verify_deployment() {
    log_info "Verifying deployment..."
    
    local FAILURES=0
    
    # Check backend
    if ! curl -sf http://localhost:8000/health > /dev/null; then
        log_warn "Backend health check failed"
        ((FAILURES++))
    else
        log_success "Backend health check passed"
    fi
    
    # Check Prometheus
    if ! curl -sf http://localhost:9090/-/healthy > /dev/null; then
        log_warn "Prometheus health check failed"
        ((FAILURES++))
    else
        log_success "Prometheus health check passed"
    fi
    
    # Check Grafana
    if ! curl -sf http://localhost:3000/api/health > /dev/null; then
        log_warn "Grafana health check failed"
        ((FAILURES++))
    else
        log_success "Grafana health check passed"
    fi
    
    # Check nginx
    if ! curl -sf https://localhost/ > /dev/null 2>&1; then
        log_warn "nginx health check failed"
        ((FAILURES++))
    else
        log_success "nginx health check passed"
    fi
    
    if [ $FAILURES -gt 0 ]; then
        log_warn "Some health checks failed - review logs"
    fi
}

setup_monitoring_alerts() {
    log_info "Configuring monitoring alerts..."
    
    # Update Alertmanager config with email
    sed -i "s/ALERT_EMAIL/$EMAIL/g" /etc/prometheus/alertmanager.yml
    
    # Restart Alertmanager
    docker restart alertmanager-geodashboard || log_warn "Failed to restart Alertmanager"
    
    log_success "Monitoring alerts configured"
}

print_summary() {
    log_info "Deployment completed successfully!"
    
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}EPIC Geodashboard Production Deployment${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo -e "Domain:              ${BLUE}https://$DOMAIN${NC}"
    echo -e "Admin URL:           ${BLUE}https://admin.$DOMAIN/admin/grafana${NC}"
    echo -e "Prometheus:          ${BLUE}http://localhost:9090${NC}"
    echo -e "Grafana:             ${BLUE}http://localhost:3000${NC}"
    echo ""
    echo -e "Installation Dir:    ${BLUE}$INSTALL_DIR${NC}"
    echo -e "Backup Dir:          ${BLUE}$BACKUP_DIR${NC}"
    echo -e "Environment:         ${BLUE}$ENVIRONMENT${NC}"
    echo ""
    echo -e "${YELLOW}Next Steps:${NC}"
    echo "  1. Verify all services: systemctl status geospatial-data-agent nginx"
    echo "  2. Check logs: journalctl -u geospatial-data-agent -f"
    echo "  3. Monitor dashboard: https://admin.$DOMAIN/admin/grafana"
    echo "  4. Test API: curl https://$DOMAIN/health"
    echo ""
    echo -e "${YELLOW}Important Notes:${NC}"
    echo "  • SSL certificate auto-renewal is configured"
    echo "  • Daily backups scheduled at 02:00 UTC"
    echo "  • Change default Grafana admin password immediately"
    echo "  • Review alertmanager.yml for notification settings"
    echo ""
}

# Main execution
main() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   EPIC Geodashboard Production Deployment Script  ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    log_info "Starting production deployment..."
    log_info "Domain: $DOMAIN"
    log_info "Email: $EMAIL"
    log_info "Environment: $ENVIRONMENT"
    echo ""
    
    check_prerequisites
    setup_system
    clone_repository
    create_environment_file
    setup_backup_directory
    deploy_backend
    deploy_monitoring
    configure_nginx
    setup_ssl
    setup_monitoring_alerts
    verify_deployment
    print_summary
    
    log_success "Production deployment completed successfully!"
}

# Run main function
main "$@"

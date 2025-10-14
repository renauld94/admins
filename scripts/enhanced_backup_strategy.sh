#!/bin/bash

# Enhanced Backup Strategy for Learning Management System Academy
# Server: 136.243.155.166 (Proxmox VE)

set -e

BACKUP_BASE_DIR="/home/simon/Desktop/Learning Management System Academy/backups"
DATE=$(date +%Y%m%d_%H%M%S)
PROXMOX_IP="136.243.155.166"
VM_ID="106"  # Your enterprise VM

echo "🔄 Starting Enhanced Backup Strategy - $DATE"

# Create backup directory structure
mkdir -p "$BACKUP_BASE_DIR"/{proxmox,vm_data,database,config,files}

# Function to backup Proxmox host configuration
backup_proxmox_config() {
    echo "📋 Backing up Proxmox host configuration..."
    
    # Backup Proxmox configuration files
    ssh root@$PROXMOX_IP << EOF
        # Create temporary backup directory
        mkdir -p /tmp/proxmox_backup_$DATE
        
        # Backup Proxmox configuration
        cp -r /etc/pve /tmp/proxmox_backup_$DATE/
        cp /etc/hosts /tmp/proxmox_backup_$DATE/
        cp /etc/network/interfaces /tmp/proxmox_backup_$DATE/
        
        # Backup VM configurations
        qm config $VM_ID > /tmp/proxmox_backup_$DATE/vm_$VM_ID.conf
        
        # Create archive
        tar czf /tmp/proxmox_config_$DATE.tar.gz -C /tmp/proxmox_backup_$DATE .
        
        # Cleanup
        rm -rf /tmp/proxmox_backup_$DATE
EOF
    
    # Download the backup
    scp root@$PROXMOX_IP:/tmp/proxmox_config_$DATE.tar.gz "$BACKUP_BASE_DIR/proxmox/"
    ssh root@$PROXMOX_IP "rm /tmp/proxmox_config_$DATE.tar.gz"
}

# Function to backup VM data
backup_vm_data() {
    echo "🖥️ Backing up VM data..."
    
    # Backup Docker volumes
    ssh root@$PROXMOX_IP << EOF
        # Create VM backup directory
        mkdir -p /tmp/vm_backup_$DATE
        
        # Backup Docker volumes from VM
        docker run --rm -v openwebui_data:/data -v /tmp/vm_backup_$DATE:/backup alpine tar czf /backup/openwebui_data_$DATE.tar.gz -C /data .
        docker run --rm -v geoserver_data:/data -v /tmp/vm_backup_$DATE:/backup alpine tar czf /backup/geoserver_data_$DATE.tar.gz -C /data .
        docker run --rm -v ollama_data:/data -v /tmp/vm_backup_$DATE:/backup alpine tar czf /backup/ollama_data_$DATE.tar.gz -C /data .
        docker run --rm -v mlflow_data:/data -v /tmp/vm_backup_$DATE:/backup alpine tar czf /backup/mlflow_data_$DATE.tar.gz -C /data .
        
        # Create archive
        tar czf /tmp/vm_data_$DATE.tar.gz -C /tmp/vm_backup_$DATE .
        
        # Cleanup
        rm -rf /tmp/vm_backup_$DATE
EOF
    
    # Download the backup
    scp root@$PROXMOX_IP:/tmp/vm_data_$DATE.tar.gz "$BACKUP_BASE_DIR/vm_data/"
    ssh root@$PROXMOX_IP "rm /tmp/vm_data_$DATE.tar.gz"
}

# Function to backup databases
backup_databases() {
    echo "🗄️ Backing up databases..."
    
    # Backup PostgreSQL database
    ssh root@$PROXMOX_IP << EOF
        # Backup PostgreSQL database
        sudo -u postgres pg_dump geoneural_enterprise > /tmp/geoneural_enterprise_$DATE.sql
        
        # Backup Moodle database if exists
        sudo -u postgres pg_dump moodle > /tmp/moodle_$DATE.sql 2>/dev/null || echo "Moodle database not found"
        
        # Create archive
        tar czf /tmp/databases_$DATE.tar.gz /tmp/*_$DATE.sql
        
        # Cleanup
        rm /tmp/*_$DATE.sql
EOF
    
    # Download the backup
    scp root@$PROXMOX_IP:/tmp/databases_$DATE.tar.gz "$BACKUP_BASE_DIR/database/"
    ssh root@$PROXMOX_IP "rm /tmp/databases_$DATE.tar.gz"
}

# Function to backup configuration files
backup_config_files() {
    echo "⚙️ Backing up configuration files..."
    
    ssh root@$PROXMOX_IP << EOF
        # Create config backup
        tar czf /tmp/config_$DATE.tar.gz /etc/nginx /etc/postgresql /etc/redis /etc/fail2ban /etc/docker
EOF
    
    # Download the backup
    scp root@$PROXMOX_IP:/tmp/config_$DATE.tar.gz "$BACKUP_BASE_DIR/config/"
    ssh root@$PROXMOX_IP "rm /tmp/config_$DATE.tar.gz"
}

# Function to backup Moodle files
backup_moodle_files() {
    echo "📚 Backing up Moodle files..."
    
    # Backup local Moodle installation
    tar czf "$BACKUP_BASE_DIR/files/moodle_files_$DATE.tar.gz" \
        --exclude='moodle/cache' \
        --exclude='moodle/temp' \
        --exclude='moodledata/cache' \
        --exclude='moodledata/temp' \
        --exclude='moodledata/sessions' \
        moodle/ moodledata/
}

# Function to create backup manifest
create_backup_manifest() {
    echo "📋 Creating backup manifest..."
    
    cat > "$BACKUP_BASE_DIR/backup_manifest_$DATE.txt" << EOF
Backup Manifest - $DATE
========================

Backup Components:
- Proxmox Configuration: proxmox/proxmox_config_$DATE.tar.gz
- VM Data: vm_data/vm_data_$DATE.tar.gz
- Databases: database/databases_$DATE.tar.gz
- Configuration Files: config/config_$DATE.tar.gz
- Moodle Files: files/moodle_files_$DATE.tar.gz

Backup Size:
$(du -sh "$BACKUP_BASE_DIR"/*_$DATE* 2>/dev/null | sort -hr)

Backup Location: $BACKUP_BASE_DIR
Server: $PROXMOX_IP
VM ID: $VM_ID

Created: $(date)
EOF
}

# Function to cleanup old backups
cleanup_old_backups() {
    echo "🧹 Cleaning up old backups..."
    
    # Keep backups for 30 days
    find "$BACKUP_BASE_DIR" -name "*.tar.gz" -mtime +30 -delete
    find "$BACKUP_BASE_DIR" -name "*.sql" -mtime +30 -delete
    find "$BACKUP_BASE_DIR" -name "backup_manifest_*.txt" -mtime +30 -delete
    
    echo "✅ Old backups cleaned up (kept last 30 days)"
}

# Function to verify backup integrity
verify_backups() {
    echo "🔍 Verifying backup integrity..."
    
    for backup_file in "$BACKUP_BASE_DIR"/*_$DATE.tar.gz; do
        if [ -f "$backup_file" ]; then
            if tar -tzf "$backup_file" >/dev/null 2>&1; then
                echo "✅ $backup_file: Valid"
            else
                echo "❌ $backup_file: Corrupted"
            fi
        fi
    done
}

# Main backup execution
main() {
    echo "🚀 Starting comprehensive backup process..."
    
    # Execute backup functions
    backup_proxmox_config
    backup_vm_data
    backup_databases
    backup_config_files
    backup_moodle_files
    
    # Create manifest and cleanup
    create_backup_manifest
    cleanup_old_backups
    verify_backups
    
    echo ""
    echo "✅ Enhanced backup completed successfully!"
    echo "📁 Backup location: $BACKUP_BASE_DIR"
    echo "📋 Manifest: $BACKUP_BASE_DIR/backup_manifest_$DATE.txt"
    echo ""
    echo "💡 Next steps:"
    echo "   1. Test restore procedures"
    echo "   2. Set up automated scheduling"
    echo "   3. Configure off-site backup replication"
    echo "   4. Implement Proxmox Backup Server (PBS)"
}

# Run main function
main "$@"

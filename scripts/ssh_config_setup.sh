# SSH Config for ProxyJump to CT 150 Server
# Add this to your ~/.ssh/config file

Host proxmox
    HostName 136.243.155.166
    User root
    Port 22
    IdentityFile ~/.ssh/id_rsa
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null

Host ct150
    HostName 10.0.0.150
    User root
    Port 22
    ProxyJump proxmox
    IdentityFile ~/.ssh/id_rsa
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null

# Usage examples after configuration:
# ssh ct150
# rsync -avz local/files/ ct150:/var/www/html/
# scp file.txt ct150:/var/www/html/
# ssh ct150 "systemctl status nginx"


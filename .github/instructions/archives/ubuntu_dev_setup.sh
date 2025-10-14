#!/bin/bash
set -e

echo "🔐 Generating SSH key if it doesn't exist..."
if [ ! -f ~/.ssh/id_ed25519 ]; then
    ssh-keygen -t ed25519 -C "simon@homelab" -f ~/.ssh/id_ed25519 -N ""
fi

echo "📁 Writing SSH config..."
mkdir -p ~/.ssh
chmod 700 ~/.ssh

cat > ~/.ssh/config <<EOF
Host vm150
  HostName 10.0.0.110
  User simonadmin
  IdentityFile ~/.ssh/id_ed25519

Host vm200
  HostName 10.0.0.103
  User simonadmin
  IdentityFile ~/.ssh/id_ed25519

Host vm9001
  HostName 10.0.0.104
  User simonadmin
  IdentityFile ~/.ssh/id_ed25519
EOF

chmod 600 ~/.ssh/config

echo "📤 Copying SSH keys to VMs..."
ssh-copy-id -i ~/.ssh/id_ed25519.pub simonadmin@10.0.0.110
ssh-copy-id -i ~/.ssh/id_ed25519.pub simonadmin@10.0.0.103
ssh-copy-id -i ~/.ssh/id_ed25519.pub simonadmin@10.0.0.104

echo "🛠️ Installing Remote Dev Stack on vm9001..."
ssh vm9001 <<'ENDSSH'
  set -e
  echo "🚀 Updating system..."
  sudo apt update && sudo apt install -y python3 python3-pip openjdk-11-jdk git curl wget unzip

  echo "🐍 Installing PySpark..."
  pip3 install pyspark

  echo "📦 Installing Databricks CLI..."
  pip3 install databricks-cli

  echo "🐳 Installing Docker..."
  sudo apt install -y docker.io
  sudo usermod -aG docker $USER

  echo "🧹 Cleaning up..."
  sudo apt autoremove -y
ENDSSH

echo "✅ All done! Try connecting: ssh vm9001 or use VS Code Remote SSH."

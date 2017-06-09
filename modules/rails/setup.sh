#!/bin/sh

set -xeu

[[ -f setup/config-variables ]] && source setup/config-variables

# Install dependencies
sudo apt-get update && sudo apt-get install -y \
  redis-server \
  nodejs \
  exiftool \
  imagemagick

sudo service redis-server start

# nginx config
sudo cp setup/modules/rails/files/nginx/site.conf /etc/nginx/sites-available/$cfg_app_name.conf

if [ ! -f /etc/nginx/sites-enabled/$cfg_app_name.conf ]; then
  sudo ln -s /etc/nginx/sites-available/$cfg_app_name.conf /etc/nginx/sites-enabled/$cfg_app_name.conf
fi

# Create app directories
sudo mkdir -p $cfg_app_dir
sudo mkdir -p $cfg_app_shared_dir
sudo mkdir -p $cfg_app_shared_config_dir
sudo mkdir -p $cfg_app_uploads_dir

sudo chown deploy $cfg_app_dir
sudo chmod 755 $cfg_app_dir

sudo chown deploy $cfg_app_shared_dir
sudo chmod 755 $cfg_app_shared_dir

sudo chown deploy $cfg_app_shared_config_dir
sudo chmod 755 $cfg_app_shared_config_dir

sudo chown deploy $cfg_app_uploads_dir
sudo chmod 755 $cfg_app_uploads_dir

# Set up systemd for sidekiq
sudo cp setup/modules/rails/files/systemd/sidekiq.service /lib/systemd/system/sidekiq.service
sudo systemctl enable sidekiq
sudo systemctl start sidekiq

# Set up systemd for puma
sudo cp setup/modules/rails/files/systemd/puma.service /lib/systemd/system/puma.service
sudo systemctl enable puma
sudo systemctl start puma

# Allow deploy user to restart sidekiq & puma
if ! sudo grep -Fqs "systemctl restart sidekiq" /etc/sudoers; then
  sudo bash -c 'echo "deploy ALL=NOPASSWD: /bin/systemctl restart sidekiq" | (EDITOR="tee -a" visudo)'
fi

if ! sudo grep -Fqs "systemctl restart puma" /etc/sudoers; then
  sudo bash -c 'echo "deploy ALL=NOPASSWD: /bin/systemctl restart puma" | (EDITOR="tee -a" visudo)'
fi

sudo service nginx reload

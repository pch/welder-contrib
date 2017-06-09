#!/bin/sh
#
# letsencrypt setup
#
# Not well-tested yet
#
set -xeu

[[ -f setup/config-variables ]] && source setup/config-variables

# # Install dependencies
sudo apt-get update && sudo apt-get install -y \
  openssl
  certbot

sudo mkdir -p $cfg_letsencrypt_web_dir

sudo chown deploy $cfg_letsencrypt_web_dir
sudo chmod 755 $cfg_letsencrypt_web_dir

sudo certbot certonly --webroot --webroot-path=/var/www/html -d $cfg_app_domain -d www.$cfg_app_domain

sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

# nginx config
sudo cp setup/modules/letsencrypt/files/nginx/ssl-certs.conf /etc/nginx/snippets/ssl-$cfg_app_domain.conf
sudo cp setup/modules/letsencrypt/files/nginx/ssl-params.conf /etc/nginx/snippets/ssl-params.conf

# cron (autorenew)
sudo cp setup/modules/letsencrypt/files/cron /etc/cron.d/renewletsencrypt

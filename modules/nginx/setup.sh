#!/bin/sh
#
# nginx setup
#
set -xeu

[[ -f setup/config-variables ]] && source setup/config-variables

sudo add-apt-repository -y ppa:nginx/stable
sudo apt-get update && sudo apt-get install -y nginx

sudo service nginx start

sudo cp -r setup/modules/nginx/files/h5bp /etc/nginx
sudo cp setup/modules/nginx/files/nginx.conf /etc/nginx/nginx.conf
sudo cp setup/modules/nginx/files/mime.types /etc/nginx/mime.types

# Disable default site
if [ -f /etc/nginx/sites-enabled/default ]; then
  sudo rm /etc/nginx/sites-enabled/default
fi

sudo service nginx restart

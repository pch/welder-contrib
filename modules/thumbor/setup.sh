#!/bin/sh
#
# Thumbor
#

set -xeu

[[ -f setup/config-variables ]] && source setup/config-variables

sudo apt-get update && sudo apt-get install -y \
  ffmpeg \
  libjpeg-dev \
  libpng-dev \
  libtiff-dev \
  libjasper-dev \
  libgtk2.0-dev \
  python-numpy \
  python-pycurl \
  webp \
  python-opencv \
  python-dev \
  python-pip

sudo pip install thumbor

# nginx config
sudo cp setup/modules/thumbor/files/thumbor-nginx.conf /etc/nginx/sites-available/thumbor.conf

if [ ! -f /etc/nginx/sites-enabled/thumbor.conf ]; then
  sudo ln -s /etc/nginx/sites-available/thumbor.conf /etc/nginx/sites-enabled/thumbor.conf
fi

# Set up systemd for all instances
for inst in ${thumbor_instances[@]}; do
  echo "$inst"

  sudo cp setup/modules/thumbor/files/systemd/thumbor.service /lib/systemd/system/thumbor-$inst.service
  sudo sed -i "s/INST_NUMBER/$inst/" /lib/systemd/system/thumbor-$inst.service
  sudo systemctl enable thumbor-$inst
  sudo systemctl start thumbor-$inst
done

sudo service nginx reload

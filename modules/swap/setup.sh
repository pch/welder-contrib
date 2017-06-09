#!/bin/sh

set -xeu

[[ -f setup/config-variables ]] && source setup/config-variables

sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo swapon --show

# TODO: not indempotent
if ! grep -Fqs "/swapfile" /etc/fstab; then
  echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
fi

if ! grep -Fqs "vm.swappiness" /etc/sysctl.conf; then
  sudo sed -i -e "s/vm\.swappiness=.*/vm.swappiness=10/" /etc/sysctl.conf
else
  echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
fi

if ! grep -Fqs "vm.vfs_cache_pressure" /etc/sysctl.conf; then
  sudo sed -i -e "s/vm\.vfs_cache_pressure=.*/vm.vfs_cache_pressure=50/" /etc/sysctl.conf
else
  echo 'vm.vfs_cache_pressure=50' | sudo tee -a /etc/sysctl.conf
fi

#!/bin/sh

set -xeu

[[ -f setup/config-variables ]] && source setup/config-variables

# Install basic packages
sudo apt-get update && sudo apt-get install -y \
  acl \
  unattended-upgrades \
  policykit-1 \
  ntp \
  wget \
  curl \
  vim \
  ack-grep \
  git \
  unzip \
  htop \
  tmux \
  logrotate

sudo service ntp start

# Fix locale
sudo update-locale LC_ALL=en_US.UTF-8
sudo sed -i -e "s/# LC_ALL.*/LC_ALL=\"en_US.UTF-8\"/" /etc/default/locale

# Set up unattended upgrades
sudo cp setup/modules/system/files/10periodic /etc/apt/apt.conf.d/10periodic
sudo chown root $_

sudo cp setup/modules/system/files/50unattended-upgrades /etc/apt/apt.conf.d/50unattended-upgrades
sudo chown root $_

sudo service unattended-upgrades restart

# Set up admin & deploy accounts

id -u admin &>/dev/null || sudo useradd -g sudo admin
echo admin:$cfg_admin_password | sudo chpasswd -e
sudo usermod -s /bin/bash admin # set up default shell

id -u deploy &>/dev/null || sudo useradd -G www-data deploy
echo deploy:$cfg_deploy_password | sudo chpasswd -e
sudo usermod -s /bin/bash deploy # set up default shell

sudo mkdir -p /home/admin/.ssh
sudo chmod 700 /home/admin/.ssh

sudo mkdir -p /home/deploy/.ssh
sudo chmod 700 /home/deploy/.ssh

# add ssh keys
# NOTE: this will erase all existing keys in authorized_keys
sudo sudo bash -c 'cat setup/modules/system/files/ssh_key >> /home/admin/.ssh/authorized_keys'
sudo chown -R admin /home/admin
sudo chmod 400 /home/admin/.ssh/authorized_keys # allows it to be read by owner only

sudo sudo bash -c 'cat setup/modules/system/files/ssh_key >> /home/deploy/.ssh/authorized_keys'
sudo chown -R deploy /home/deploy
sudo chmod 400 /home/deploy/.ssh/authorized_keys # allows it to be read by owner only

# Update ssh config: disable root login & password login
sudo sed -i -e "s/PermitRootLogin.*/PermitRootLogin no/" /etc/ssh/sshd_config
sudo sed -i -e "s/PasswordAuthentication.*/PasswordAuthentication no/" /etc/ssh/sshd_config

sudo systemctl reload sshd

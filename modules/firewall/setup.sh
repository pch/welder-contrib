#!/bin/sh

set -xeu

[[ -f setup/config-variables ]] && source setup/config-variables

sudo apt-get update && sudo apt-get install -y iptables-persistent

sudo cp setup/modules/firewall/files/rules.v4 /etc/iptables/rules.v4
sudo chown root $_
sudo chmod 644 $_

sudo service iptables-persistent restart

# fail2ban
sudo apt-get install -y fail2ban
sudo service fail2ban start

sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

sudo service fail2ban restart

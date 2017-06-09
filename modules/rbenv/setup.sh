#!/bin/sh
#
# Installs rbenv, ruby-build, rben-vars + the specified ruby version
#
set -xeu

[[ -f setup/config-variables ]] && source setup/config-variables

sudo apt-get update && sudo apt-get install -y \
  autoconf \
  automake \
  bison \
  build-essential \
  curl \
  exuberant-ctags \
  git-core \
  libc6-dev \
  libncurses5-dev \
  libffi-dev \
  libreadline6 \
  libreadline6-dev \
  libreadline-dev \
  libsqlite3-0 \
  libsqlite3-dev \
  libssl-dev \
  libtool \
  libyaml-dev \
  libxml2-dev \
  libxslt1-dev \
  openssl \
  sqlite3 \
  zlib1g \
  zlib1g-dev

if [ ! -d /home/deploy/.rbenv ]; then
  sudo git clone https://github.com/rbenv/rbenv.git /home/deploy/.rbenv
fi

sudo mkdir -p /home/deploy/.bash.d/
sudo cp setup/modules/rbenv/files/50_rbenv.bash /home/deploy/.bash.d/50_rbenv.bash
sudo chmod 700 /home/deploy/.bash.d/50_rbenv.bash

sudo touch /home/deploy/.bash_profile

if ! sudo grep -Fqs "50_rbenv.bash" /home/deploy/.bash_profile; then
  echo 'source ~/.bash.d/50_rbenv.bash' | sudo tee --append /home/deploy/.bash_profile
fi

sudo mkdir -p /home/deploy/.rbenv/plugins/
sudo chmod 755 $_

if [ ! -d /home/deploy/.rbenv/plugins/ruby-build ]; then
  sudo git clone https://github.com/rbenv/ruby-build.git /home/deploy/.rbenv/plugins/ruby-build
fi

if [ ! -d /home/deploy/.rbenv/plugins/rbenv-vars ]; then
  sudo git clone https://github.com/rbenv/rbenv-vars.git /home/deploy/.rbenv/plugins/rbenv-vars
fi

sudo cp setup/modules/rbenv/files/gemrc /home/deploy/.gemrc

sudo chown -R deploy: /home/deploy/

sudo -u deploy -i <<EOF
rbenv versions | grep $cfg_ruby_version || MAKEOPTS=-j2 CONFIGURE_OPTS="--disable-install-rdoc" rbenv install $cfg_ruby_version
rbenv global $cfg_ruby_version
gem install bundler
EOF

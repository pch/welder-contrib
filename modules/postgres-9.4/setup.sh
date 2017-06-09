#!/bin/sh

set -xeu

[[ -f setup/config-variables ]] && source setup/config-variables

sudo apt-get install wget ca-certificates

sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

sudo apt-get update && sudo apt-get install -y \
  python-psycopg2 \
  postgresql-9.4 \
  postgresql-contrib-9.4 \
  libpq-dev

sudo cp setup/modules/postgresql/files/postgresql.conf /etc/postgresql/9.4/main/postgresql.conf
sudo cp setup/modules/postgresql/files/pg_hba.conf /etc/postgresql/9.4/main/pg_hba.conf

sudo service postgresql restart

sudo -u postgres -i <<EOF
psql -c "CREATE ROLE $cfg_postgres_username WITH LOGIN PASSWORD '$cfg_postgres_password' NOSUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;"
EOF

sudo -u postgres -i <<EOF
psql -c "CREATE DATABASE $cfg_postgres_database OWNER = $cfg_postgres_username ENCODING = 'UTF8' LC_COLLATE='en_US.UTF-8' LC_CTYPE='en_US.UTF-8'"
EOF

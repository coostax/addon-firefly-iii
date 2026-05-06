#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Community Add-on: Firefly III
# This file creates the file structure and configures the app key
# ==============================================================================

declare host
declare key
declare password
declare port
declare username

if ! bashio::fs.directory_exists "/data/firefly/upload"; then
    bashio::log "Creating upload directory"
    mkdir -p /data/firefly/upload
    chown www-data:www-data /data/firefly/upload
fi

rm -r /var/www/firefly/storage/upload
ln -s /data/firefly/upload /var/www/firefly/storage/upload
# Run composer install again
cd /var/www/firefly || exit
echo "APP_KEY=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -1)" >> /var/www/firefly/.env
php composer.phar install

chown -R www-data:www-data /var/www/firefly/storage
chmod -R 755 /var/www/firefly/storage
chmod 600 /var/www/firefly/storage/oauth-*.key

#Create APP key if needed
if ! bashio::fs.file_exists "/data/firefly/.env"; then
 	bashio::log.info "Generating app key"
 	key=$(php /var/www/firefly/artisan key:generate --show)
 	echo "APP_KEY=${key}" > /data/firefly/.env
 	bashio::log.info "App Key generated: ${key}"
fi
bashio::log.info "Setting App Key"
cp -f /data/firefly/.env /var/www/firefly/.env

if bashio::config.has_value 'remote_mysql_host'; then
  if ! bashio::config.has_value 'remote_mysql_database'; then
    bashio::exit.nok \
      "Remote database has been specified but no database is configured"
  fi

  if ! bashio::config.has_value 'remote_mysql_username'; then
    bashio::exit.nok \
      "Remote database has been specified but no username is configured"
  fi

  if ! bashio::config.has_value 'remote_mysql_password'; then
    bashio::log.fatal \
      "Remote database has been specified but no password is configured"
  fi

  if ! bashio::config.exists 'remote_mysql_port'; then
    bashio::exit.nok \
      "Remote database has been specified but no port is configured"
  fi
else
  if ! bashio::services.available 'mysql'; then
     bashio::log.fatal \
       "Local database access should be provided by the MariaDB addon"
     bashio::exit.nok \
       "Please ensure it is installed and started"
  fi

  host=$(bashio::services "mysql" "host")
  password=$(bashio::services "mysql" "password")
  port=$(bashio::services "mysql" "port")
  username=$(bashio::services "mysql" "username")

  bashio::log.warning "Firefly-iii is using the Maria DB addon"
  bashio::log.warning "Please ensure this is included in your backups"
  bashio::log.warning "Uninstalling the MariaDB addon will remove any data"

  bashio::log.info "Creating database for Firefly-iii if required"
  mysql \
    -u "${username}" -p"${password}" \
    -h "${host}" -P "${port}" \
    -e "CREATE DATABASE IF NOT EXISTS \`firefly\` ;"
fi

#Create .env file
bashio::log.info "Setting environment variable file for Firefly-iii"

if bashio::config.has_value 'app_url'; then
  echo "APP_URL=""$(bashio::config "app_url")" > /var/www/firefly/.env
fi

if bashio::config.has_value 'trusted_proxy'; then
  echo "TRUSTED_PROXIES=""$(bashio::config "trusted_proxy")" > /var/www/firefly/.env
fi
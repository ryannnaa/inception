#!/bin/sh
set -e

WP_PATH="/var/www/html"

# Read secrets (trim newline!)
DB_PASSWORD="$(tr -d '\n' < /run/secrets/db_password)"
ADMIN_PASSWORD="$(tr -d '\n' < /run/secrets/wp_admin_password)"
USER_PASSWORD="$(tr -d '\n' < /run/secrets/wp_user_password)"

# Wait for MariaDB to be ready
echo "[WordPress] Waiting for MariaDB..."
until mysqladmin ping \
    -h"$MYSQL_HOST" \
    -u"$MYSQL_USER" \
    -p"$DB_PASSWORD" \
    --silent; do
    sleep 2
done

echo "[WordPress] MariaDB is ready."

cd "$WP_PATH"

# Install WordPress if not already installed
if [ ! -f wp-config.php ]; then
    echo "[WordPress] Downloading core..."
    wp core download --allow-root

    echo "[WordPress] Creating wp-config.php..."
    wp config create \
        --allow-root \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$DB_PASSWORD" \
        --dbhost="$MYSQL_HOST" \
        --skip-check

    echo "[WordPress] Installing WordPress..."
    wp core install \
        --allow-root \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception Site" \
        --admin_user="admin" \
        --admin_password="$ADMIN_PASSWORD" \
        --admin_email="admin@${DOMAIN_NAME}"

    echo "[WordPress] Creating normal user..."
    wp user create \
        wp_user "user@${DOMAIN_NAME}" \
        --user_pass="$USER_PASSWORD" \
        --allow-root

    chown -R www-data:www-data "$WP_PATH"
else
    echo "[WordPress] Already installed."
fi

exec php-fpm8.2 -F


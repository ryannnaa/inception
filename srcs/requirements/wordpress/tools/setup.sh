#!/bin/sh
set -e

WP_PATH="/var/www/html"

# --- Read secrets and export environment variables ---
export MYSQL_PASSWORD="$(tr -d '\n' < /run/secrets/db_password)"
export MYSQL_USER="$MYSQL_USER"
export MYSQL_DATABASE="$MYSQL_DATABASE"
export MYSQL_HOST="$MYSQL_HOST"

export WP_ADMIN_PASSWORD="$(tr -d '\n' < /run/secrets/wp_admin_password)"
export WP_USER_PASSWORD="$(tr -d '\n' < /run/secrets/wp_user_password)"

# --- Wait for MariaDB to be ready ---
echo "[WordPress] Waiting for MariaDB to be ready..."
until mysqladmin ping -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; do
    sleep 2
done
echo "[WordPress] MariaDB is ready."

# --- Navigate to WordPress path ---
cd "$WP_PATH"

# --- Install WordPress if not already installed ---
if [ ! -f wp-config.php ]; then
    echo "[WordPress] Downloading WordPress core..."
    wp core download --allow-root

    echo "[WordPress] Creating wp-config.php..."
    wp config create \
        --allow-root \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost="$MYSQL_HOST" \
        --skip-check

    echo "[WordPress] Installing WordPress..."
    wp core install \
        --allow-root \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception Site" \
        --admin_user="admin" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="admin@${DOMAIN_NAME}"

    echo "[WordPress] Creating normal user..."
    wp user create wp_user "user@${DOMAIN_NAME}" \
        --user_pass="$WP_USER_PASSWORD" \
        --allow-root

    echo "[WordPress] Setting ownership..."
    chown -R www-data:www-data "$WP_PATH"
else
    echo "[WordPress] WordPress already installed."
fi

# --- Start PHP-FPM ---
exec php-fpm8.2 -F


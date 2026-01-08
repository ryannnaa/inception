#!/bin/sh

if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Installing WordPress..."
    curl -o wordpress.tar.gz https://wordpress.org/latest.tar.gz
    tar -xzf wordpress.tar.gz --strip-components=1
    rm wordpress.tar.gz
    chown -R www-data:www-data /var/www/html
    chmod -R 755 /var/www/html
fi

exec php-fpm

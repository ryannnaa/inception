#!/bin/bash

#keys for the wordpress
export WP_ADMIN_PW=$(cat /run/secrets/wp_admin_password)
export WP_USER_PW=$(cat /run/secrets/wp_user_password)
export WORDPRESS_DB_PASSWORD=$(cat /run/secrets/db_password)

#check wp-config file
if [ ! -f /var/www/html/wp-config.php ]; then

    #clean existing files
    echo "Deleting existing files under /var/www/html..."
    rm -rf /var/www/html/*

    #download wp-cli
    echo "Downloading wp-cli..."
    wp core download --allow-root

    #unpacking wp-config.php
    echo "Unpacking wp-config.php file..."
    wp config create \
    --dbname=$MYSQL_DATABASE \
    --dbuser=$MYSQL_USER \
    --dbpass=$WORDPRESS_DB_PASSWORD \
    --dbhost=$MYSQL_HOST \
    --allow-root
    
    #wait database to be ready
    echo "Waiting for database..."
    until wp db check --allow-root 2>/dev/null; do
        echo "Database in progress..."
        sleep 3
    done

    #installation
    echo "Installing wp-core..."
    wp core install \
    --admin_user=$WP_ADMIN \
    --admin_password=$WP_ADMIN_PW \
    --url=$DOMAIN_NAME \
    --title=$TITLE \
    --admin_email=$WP_ADMIN_EMAIL \
    --allow-root

    #user creation
    wp user create $WP_USER $WP_USER_EMAIL \
    --role=author \
    --user_pass=$WP_USER_PW \
    --allow-root

fi

#start PHP-FPM in the foreground
echo "Starting PHP-FPM..."
exec /usr/sbin/php-fpm8.2 -F


FROM php:8.2-fpm

WORKDIR /var/www/html

RUN apt-get update && \
    apt-get install -y libzip-dev unzip curl default-mysql-client && \
    docker-php-ext-install mysqli pdo pdo_mysql zip && \
    rm -rf /var/lib/apt/lists/*

# Copy your setup script
COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh

# Ensure proper permissions on the working directory
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Run setup script as CMD
CMD ["/setup.sh"]


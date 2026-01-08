FROM php:8.2-fpm

WORKDIR /var/www/html

RUN apt-get update && \
	apt-get install -y \
	libzip-dev \
	unzip && \
	docker-php-ext-install mysqli pdo pdo_mysql zip

RUN curl -o wordpress.tar.gz https://wordpress.org/latest.tar.gz \
	&& tar -xzf wordpress.tar.gz --strip-components=1 \
	&& rm wordpress.tar.gz

RUN chown -R www-data:www-data /var/www/html \
	&& chmod -R 755 /var/www/html

COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh

CMD ["/setup.sh"]

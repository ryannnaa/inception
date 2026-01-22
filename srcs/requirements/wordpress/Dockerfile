FROM debian:12

#install required requirements
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    curl \
    nano \
    php-fpm \
    php-cli \
    php-mysqli \
    mariadb-client

#configure the wordpress to listen on 9000 instead of its default as listening on the socket
RUN sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' \
    /etc/php/8.2/fpm/pool.d/www.conf

#install the wp-cli
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

#change the permission
RUN chmod +x wp-cli.phar

#move the executable phar to the default path so that could be exectued directly using wp
RUN mv wp-cli.phar /usr/local/bin/wp

WORKDIR /var/www/html

COPY /tools/setup.sh /setup.sh

RUN chmod +x /setup.sh

EXPOSE 9000

CMD ["/setup.sh"]


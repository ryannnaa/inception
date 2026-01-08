FROM debian:12

RUN apt-get update && apt-get upgrade && \
	apt-get install -y php-fpm

CMD ["php-fpm8.2", "-F"]

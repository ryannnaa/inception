FROM debian:12

RUN apt-get update && \
	    apt-get install -y mariadb-server gettext-base && \
	    rm -rf /var/lib/apt-get/lists/*

COPY conf/db.cnf /etc/mysql/db.cnf
COPY tools/entrypoint.sh /entrypoint.sh
COPY tools/init.sql.template /etc/mysql/init.sql.template

RUN chmod +x /entrypoint.sh

EXPOSE 3306

ENTRYPOINT ["/entrypoint.sh"]

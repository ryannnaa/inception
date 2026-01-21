FROM debian:12

RUN apt-get update && \
    apt-get install -y mariadb-server mariadb-client gettext-base && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/lib/mysql /var/run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql /var/run/mysqld && \
    chmod 777 /var/run/mysqld

COPY tools/setup.sh /setup.sh
RUN chmod +x /setup.sh

RUN sed -i "s/127.0.0.1/0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf

EXPOSE 3306
ENTRYPOINT ["/setup.sh"]

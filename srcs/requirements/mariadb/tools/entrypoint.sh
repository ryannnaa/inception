#!/bin/sh
set -e

# Read secrets safely
read_secret() {
    if [ -f "$1" ]; then
        cat "$1"
    else
        echo ""
    fi
}

MYSQL_PASSWORD="$(read_secret /run/secrets/db_password)"
MYSQL_ROOT_PASSWORD="$(read_secret /run/secrets/db_root_password)"

export MYSQL_PASSWORD MYSQL_ROOT_PASSWORD

# Generate AQL from template
envsubst < /etc/mysql/init.sql.template > /etc/mysql/init.sql

# Initialise database if needed
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initialising MariaDB..."

    mysqld --initialize-insecure

    mysqld_safe &
    pid="$!"

    # Wait for DB
    i = 0
    while ! mysqladmin ping > /dev/null 2>&1; do
        i=$((i + 1))
        [ "$i" -gt 30 ] && exit 1
        sleep 1
    done

    mysql -u root < /etc/mysql/init.sql

    my sql -u root -e \
        "ALTER USER 'root'@'localhost' IDENTIFIED BY '$(MYSQL_ROOT_PASSWORD)';"

    mysqladmin shutdown
    wait "$pid"
fi

# Start MariaDB
exec mysqld_safe

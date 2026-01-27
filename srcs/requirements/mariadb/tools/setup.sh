#!/bin/sh
set -e

MYSQL_DATA_DIR="/var/lib/mysql"

ROOT_PASSWORD="$(tr -d '\n' < /run/secrets/db_root_password)"
USER_PASSWORD="$(tr -d '\n' < /run/secrets/db_password)"
DB_NAME="$MYSQL_DATABASE"
DB_USER="$MYSQL_USER"

if [ -z "$DB_NAME" ] || [ -z "$DB_USER" ] || [ -z "$ROOT_PASSWORD" ] || [ -z "$USER_PASSWORD" ]; then
    echo "[ERROR] One or more required variables are empty!"
    echo "DB_NAME empty: $([ -z "$DB_NAME" ] && echo YES || echo NO)"
    echo "DB_USER empty: $([ -z "$DB_USER" ] && echo YES || echo NO)"
    echo "ROOT_PASSWORD empty: $([ -z "$ROOT_PASSWORD" ] && echo YES || echo NO)"
    echo "USER_PASSWORD empty: $([ -z "$USER_PASSWORD" ] && echo YES || echo NO)"
    exit 1
fi

if [ ! -f "$MYSQL_DATA_DIR/created.txt" ]; then
    echo "[MariaDB] First run - initializing database..."
    touch $MYSQL_DATA_DIR/created.txt
    
    mariadb-install-db --user=mysql --datadir="$MYSQL_DATA_DIR"
    
    echo "[MariaDB] Creating initialization SQL file..."
    
    cat > /tmp/init.sql <<EOF
USE mysql;
FLUSH PRIVILEGES;

-- Set root password
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASSWORD}';
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

-- Create WordPress database
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;

-- Create WordPress user
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${USER_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';

FLUSH PRIVILEGES;
EOF

    echo "[MariaDB] SQL file contents:"
    cat /tmp/init.sql
    echo ""
    echo "[MariaDB] Running bootstrap..."
    
    if mysqld --user=mysql --datadir="$MYSQL_DATA_DIR" --bootstrap --verbose < /tmp/init.sql; then
        echo "[MariaDB] Bootstrap completed successfully"
    else
        echo "[ERROR] Bootstrap failed!"
        exit 1
    fi
    
    rm /tmp/init.sql
    
    echo "[MariaDB] Database initialized and configured"
else
    echo "[MariaDB] Database already initialized - SKIPPING SETUP"
    echo "[MariaDB] Contents of $MYSQL_DATA_DIR:"
    ls -la "$MYSQL_DATA_DIR/"
fi

echo "[MariaDB] Starting MariaDB server..."
exec mysqld --user=mysql --datadir="$MYSQL_DATA_DIR" --bind-address=0.0.0.0


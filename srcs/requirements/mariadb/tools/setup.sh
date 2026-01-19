#!/bin/sh
set -e

MYSQL_DATA_DIR="/var/lib/mysql"

# Read secrets (trim newline!)
ROOT_PASSWORD="$(tr -d '\n' < /run/secrets/db_root_password)"
USER_PASSWORD="$(tr -d '\n' < /run/secrets/db_password)"
DB_NAME="$MYSQL_DATABASE"
DB_USER="$MYSQL_USER"

# Initialize DB if empty
if [ ! -d "$MYSQL_DATA_DIR/mysql" ]; then
    echo "[MariaDB] Initializing database..."
    mariadb-install-db --datadir="$MYSQL_DATA_DIR"
fi

echo "[MariaDB] Starting temporary MariaDB server (socket only)..."
# Run temp server in background
mysqld --datadir="$MYSQL_DATA_DIR" --skip-networking &
PID="$!"

# Wait for server to be ready (socket only)
until mysql --protocol=socket -uroot -e "SELECT 1;" >/dev/null 2>&1; do
    echo "[MariaDB] Waiting for server socket..."
    sleep 1
done

echo "[MariaDB] Configuring users and database..."

mysql --protocol=socket -uroot <<EOF
-- Set root password and allow root from any host
ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASSWORD}';
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

-- Create your application database and user
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${USER_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF

echo "[MariaDB] Shutting down temporary server..."
mysqladmin --protocol=socket -uroot -p"$ROOT_PASSWORD" shutdown
wait "$PID"

echo "[MariaDB] Starting main MariaDB server (TCP enabled)..."
exec mysqld --datadir="$MYSQL_DATA_DIR" --bind-address=0.0.0.0


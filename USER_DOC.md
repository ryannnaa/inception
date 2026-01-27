# User Documentation

## Overview

This project provides a secure, containerized web infrastructure running WordPress with HTTPS support. The stack includes three main services that work together to deliver a fully functional website.

---

## 📦 Services Provided

### 1. **NGINX Web Server**
- Acts as the main entry point to your website
- Handles all HTTPS connections securely
- Supports TLS 1.2 and TLS 1.3 encryption
- Routes traffic to WordPress

### 2. **WordPress Content Management System**
- Manages your website content
- Accessible via web browser
- Includes an administration panel for content editing
- Runs on PHP-FPM for optimal performance

### 3. **MariaDB Database**
- Stores all WordPress data (posts, pages, users, settings)
- Runs in isolation for security
- Data persists across restarts

---

## 🚀 Starting the Project

To start all services:

```bash
make
```

Or alternatively:

```bash
docker-compose up -d
```

The `-d` flag runs containers in detached mode (background). The services will:
- Build if necessary
- Start in the correct order
- Restart automatically if they crash

**Expected output:**
```
Creating network "inception_network" ...
Creating volume "inception_mariadb_data" ...
Creating volume "inception_wordpress_data" ...
Creating mariadb ... done
Creating wordpress ... done
Creating nginx ... done
```

---

## 🛑 Stopping the Project

To stop all services:

```bash
make down
```

Or:

```bash
docker-compose down
```

This stops and removes containers but **preserves your data** in Docker volumes.

---

## 🌐 Accessing the Services

### Website
Once the services are running, access your website at:

```
https://tiatan.42.fr
```

**Note:** Since this uses a self-signed certificate, your browser will show a security warning. This is expected in a development environment. Click "Advanced" and proceed to the site.

### WordPress Admin Panel
Access the administration panel at:

```
https://tiatan.42.fr/wp-admin
```

---

## 🔐 Credentials Management

### Locating Credentials

Credentials are stored securely using Docker secrets in the `.env` file at the root of the project.

**Default .env structure:**
```env
# Domain
DOMAIN_NAME=tiatan.42.fr

# MariaDB Configuration
MYSQL_ROOT_PASSWORD=secure_root_password
MYSQL_DATABASE=wordpress
MYSQL_USER=wordpress_user
MYSQL_PASSWORD=secure_user_password

# WordPress Configuration
WP_ADMIN_USER=admin
WP_ADMIN_PASSWORD=secure_admin_password
WP_ADMIN_EMAIL=admin@tiatan.42.fr
WP_TITLE=Inception WordPress

WP_USER=editor
WP_USER_PASSWORD=secure_editor_password
WP_USER_EMAIL=editor@tiatan.42.fr
```

### WordPress Credentials

**Administrator Account:**
- Username: Value of `WP_ADMIN_USER` (default: `admin`)
- Password: Value of `WP_ADMIN_PASSWORD`

**Editor Account:**
- Username: Value of `WP_USER` (default: `editor`)
- Password: Value of `WP_USER_PASSWORD`

### Database Credentials

**Root Access:**
- Username: `root`
- Password: Value of `MYSQL_ROOT_PASSWORD`

**WordPress Database User:**
- Username: Value of `MYSQL_USER` (default: `wordpress_user`)
- Password: Value of `MYSQL_PASSWORD`

### Changing Credentials

1. Stop the project:
   ```bash
   make down
   ```

2. Edit the `.env` file with your preferred text editor:
   ```bash
   nano .env
   ```

3. Modify the desired credentials

4. Remove existing volumes (this will delete all data):
   ```bash
   make fclean
   ```

5. Rebuild and restart:
   ```bash
   make
   ```

**⚠️ Warning:** Changing credentials after initial setup requires removing volumes, which deletes all website data.

---

## ✅ Checking Service Status

### Quick Health Check

Check if all containers are running:

```bash
docker-compose ps
```

**Expected output:**
```
    Name                   Command               State          Ports
--------------------------------------------------------------------------------
inception_mariadb_1    docker-entrypoint.sh mysqld    Up      3306/tcp
inception_nginx_1      nginx -g daemon off;           Up      0.0.0.0:443->443/tcp
inception_wordpress_1  php-fpm -F                     Up      9000/tcp
```

All services should show `Up` in the State column.

### Detailed Service Logs

View logs for all services:

```bash
docker-compose logs
```

View logs for a specific service:

```bash
docker-compose logs nginx
docker-compose logs wordpress
docker-compose logs mariadb
```

Follow logs in real-time:

```bash
docker-compose logs -f
```

### Individual Container Status

Check running containers:

```bash
docker ps
```

Check all containers (including stopped):

```bash
docker ps -a
```

### Testing Website Connectivity

Test NGINX response:

```bash
curl -k https://tiatan.42.fr
```

The `-k` flag allows insecure connections (self-signed certificate).

### Verifying Database Connection

Access MariaDB container:

```bash
docker exec -it inception_mariadb_1 mysql -u root -p
```

Enter the `MYSQL_ROOT_PASSWORD` when prompted.

Once inside, verify the WordPress database:

```sql
SHOW DATABASES;
USE wordpress;
SHOW TABLES;
EXIT;
```

---

## 🔧 Common Issues and Solutions

### Issue: Browser shows "Connection refused"
**Solution:** 
- Verify services are running: `docker-compose ps`
- Check NGINX logs: `docker-compose logs nginx`
- Ensure port 443 is not blocked by firewall

### Issue: "Database connection error" in WordPress
**Solution:**
- Check MariaDB is running: `docker-compose ps mariadb`
- Verify database credentials in `.env` match
- Check MariaDB logs: `docker-compose logs mariadb`

### Issue: Changes to `.env` not taking effect
**Solution:**
- Stop containers: `make down`
- Remove volumes: `make fclean`
- Rebuild: `make`

### Issue: Self-signed certificate warning
**Solution:**
- This is expected in development
- For production, use a certificate from Let's Encrypt or a trusted CA

---

## 📊 Monitoring Resource Usage

Check container resource consumption:

```bash
docker stats
```

This shows CPU, memory, network, and disk usage for each container in real-time.

---

## 🔄 Restarting Services

Restart all services:

```bash
docker-compose restart
```

Restart a specific service:

```bash
docker-compose restart nginx
docker-compose restart wordpress
docker-compose restart mariadb
```

---

## 📁 Backup and Restore

### Creating a Backup

Export WordPress data volume:

```bash
docker run --rm -v inception_wordpress_data:/data -v $(pwd):/backup alpine tar czf /backup/wordpress_backup.tar.gz -C /data .
```

Export MariaDB data volume:

```bash
docker run --rm -v inception_mariadb_data:/data -v $(pwd):/backup alpine tar czf /backup/mariadb_backup.tar.gz -C /data .
```

### Restoring from Backup

Stop services:

```bash
make down
```

Restore WordPress volume:

```bash
docker run --rm -v inception_wordpress_data:/data -v $(pwd):/backup alpine sh -c "cd /data && tar xzf /backup/wordpress_backup.tar.gz"
```

Restore MariaDB volume:

```bash
docker run --rm -v inception_mariadb_data:/data -v $(pwd):/backup alpine sh -c "cd /data && tar xzf /backup/mariadb_backup.tar.gz"
```

Restart services:

```bash
make
```

---

## 🆘 Getting Help

If you encounter issues:

1. Check the logs: `docker-compose logs`
2. Verify service status: `docker-compose ps`
3. Consult the Developer Documentation (DEV_DOC.md)
4. Review container configuration in `docker-compose.yml`

---

## 🧹 Complete Cleanup

To completely remove all containers, volumes, and networks:

```bash
make fclean
```

**⚠️ Warning:** This permanently deletes all website data and database content.

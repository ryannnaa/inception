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
docker compose up -d
```

The `-d` flag runs containers in detached mode (background). The services will:
- Build if necessary
- Start in the correct order
- Restart automatically if they crash

**Expected output:**
```
✔ Image mariadb         Built                                                                     
✔ Image wordpress       Built                                                                     
✔ Image nginx           Built                                                                     
✔ Network inception     Created                                                                   
✔ Volume srcs_wp        Created                                                                   
✔ Volume srcs_db        Created                                                                   
✔ Container mariadb-1   Healthy                                                                   
✔ Container wordpress-1 Created                                                                   
✔ Container nginx-1     Created                                                                   

```

---

## 🛑 Stopping the Project

To stop all services:

```bash
make down
```

Or:

```bash
docker compose down
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

Credentials are stored securely using Docker secrets in the secrets folder at the root of the project.

**Default .env structure:**
```env
# Domain
DOMAIN_NAME=tiatan.42.fr

# MariaDB Configuration
MYSQL_USER=wp_user
MYSQL_DATABASE=wordpress

# WordPress Configuration
WP_USER=user
WP_ADMIN=admin
WP_USER_EMAIL=user@mail.com
WP_ADMIN_EMAIL=admin@mail.com
TITLE=wordpress
```

### WordPress Credentials

**Administrator Account:**
- Username: Value of `WP_ADMIN_USER` (default: `admin`)
- Password: Value of `WP_ADMIN_PASSWORD`

**User Account:**
- Username: Value of `WP_USER` (default: `user`)
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
docker ps
```

**Expected output:**
```
CONTAINER ID   IMAGE       COMMAND                  CREATED             STATUS                       PORT
S                                     NAMES
19f56e9baa90   nginx       "nginx -g 'daemon of…"   About an hour ago   Up About an hour             0.0.
0.0:443->443/tcp, [::]:443->443/tcp   nginx-1
d7ad3a7eba2f   wordpress   "/setup.sh"              About an hour ago   Up About an hour             9000
/tcp                                  wordpress-1
2f3d55ad5263   mariadb     "/setup.sh"              About an hour ago   Up About an hour (healthy)   3306
/tcp                                  mariadb-1
```

All services should show `Up` in the State column.

### Detailed Service Logs

View logs for all services:

```bash
docker logs
```

View logs for a specific service:

```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

Follow logs in real-time:

```bash
docker logs -f
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
- Verify services are running: `docker ps`
- Check NGINX logs: `docker logs nginx`
- Ensure port 443 is not blocked by firewall

### Issue: "Database connection error" in WordPress
**Solution:**
- Check MariaDB is running: `docker ps`
- Verify database credentials in `.env` match
- Check MariaDB logs: `docker logs mariadb`

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
docker restart
```

Restart a specific service:

```bash
docker restart nginx
docker restart wordpress
docker restart mariadb
```

---

## 🆘 Getting Help

If you encounter issues:

1. Check the logs: `docker compose logs`
2. Verify service status: `docker compose ps`
3. Consult the Developer Documentation (DEV_DOC.md)
4. Review container configuration in `docker-compose.yml`

---

## 🧹 Complete Cleanup

To completely remove all containers, volumes, and networks:

```bash
make fclean
```

**⚠️ Warning:** This permanently deletes all website data and database content.

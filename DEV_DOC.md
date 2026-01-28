# Developer Documentation

## Overview

This document provides technical guidance for developers working on the Inception project. It covers environment setup, build processes, container management, and data persistence strategies.

---

## 🛠️ Prerequisites

Before setting up the project, ensure your development environment meets these requirements:

### System Requirements

- **Operating System:** Linux (Ubuntu 20.04+ recommended) or Linux VM
- **Architecture:** x86_64 (amd64)
- **Memory:** Minimum 2GB RAM available for Docker
- **Storage:** At least 5GB free disk space

### Required Software

#### Docker Engine

**Installation (Ubuntu/Debian):**

```bash
# Update package index
sudo apt-get update

# Install dependencies
sudo apt-get install ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up the repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Verify installation
docker --version
```

**Add user to docker group (optional, avoids using sudo):**

```bash
sudo usermod -aG docker $USER
newgrp docker
```

#### Docker Compose

Docker Compose v2 is included with Docker Engine. Verify:

```bash
docker compose version
```

If using standalone Docker Compose v1:

```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/bar
sudo chmod +x /usr/local/bin/bar
bar --version
```

#### GNU Make

```bash
sudo apt-get install make
make --version
```

#### Git (for cloning)

```bash
sudo apt-get install git
git --version
```

---

## 📥 Initial Setup

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/inception.git
cd inception
```

### 2. Configure Hosts File

Add the domain to `/etc/hosts` for local development:

```bash
sudo echo "127.0.0.1 tiatan.42.fr" >> /etc/hosts
```

Verify:

```bash
ping tiatan.42.fr
```

### 3. Create Password Files

Create the following files:
credentials.txt
db_password.txt
db_root_password.txt
wp_admin_password.txt
wp_user_password.txt

```bash
echo example_password > db_password.txt
```

**Security Best Practices:**

- Use strong, unique passwords (16+ characters)
- Never commit password files to version control
- Add password files to `.gitignore`

### 4. Generate SSL Certificates

The project uses self-signed certificates for HTTPS. These are generated automatically during the first build, but you can generate them manually:

```bash
mkdir -p srcs/requirements/nginx/tools/certs

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout srcs/requirements/nginx/tools/certs/tiatan.42.fr.key \
  -out srcs/requirements/nginx/tools/certs/tiatan.42.fr.crt \
  -subj "/C=SG/ST=Singapore/L=Singapore/O=42/OU=42Singapore/CN=tiatan.42.fr"
```

---

## 🏗️ Project Structure

```
inception/
├── Makefile                    # Build automation
├── docker-compose.yml          # Service orchestration
├── .env                        # Environment variables
├── README.md                   # Project overview
├── USER_DOC.md                 # User documentation
├── DEV_DOC.md                  # Developer documentation (this file)
├── secrets/                    # Empty folder or not included (password files in .gitignore)
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── wp_admin_password.txt
│   └── wp_user_password.txt
└──── srcs/
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile         # MariaDB container definition
        │   ├── conf/
        │   │   └── 50-server.cnf  # MariaDB configuration
        │   └── tools/
        │       └── entrypoint.sh  # MariaDB initialization script
        ├── wordpress/
        │   ├── Dockerfile         # WordPress container definition
        │   ├── conf/
        │   │   └── www.conf       # PHP-FPM pool configuration
        │   └── tools/
        │       └── entrypoint.sh  # WordPress setup script
        └── nginx/
            ├── Dockerfile         # NGINX container definition
            ├── conf/
            │   └── nginx.conf     # NGINX server configuration
            └── tools/
                └── certs/         # SSL certificates
```

---

## 🔨 Building the Project

### Using Makefile (Recommended)

The Makefile provides convenient commands for common operations:

```bash
# Build and start all services
make

# Equivalent to:
make up 
```

**What this does:**

1. Creates Docker volumes for persistent storage
2. Builds custom Docker images from Dockerfiles
3. Creates a dedicated Docker network
4. Starts containers in dependency order (MariaDB → WordPress → NGINX)

### Manual Build with Docker Compose

```bash
# Build images without starting containers
docker compose build

# Build with no cache (clean build)
docker compose build --no-cache

# Build and start services
docker compose up -d

# Build, recreate containers, and start
docker compose up -d --build
```

### Build Process Details

**Build Order:**

1. **MariaDB:** Built first (base image: `debian:bookworm`)
   - Installs MariaDB server
   - Copies configuration files
   - Sets up initialization script

2. **WordPress:** Built second
   - Installs PHP-FPM and required extensions
   - Downloads WordPress core
   - Configures PHP-FPM pool

3. **NGINX:** Built last
   - Installs NGINX
   - Copies SSL certificates
   - Configures TLS and reverse proxy

**Viewing Build Output:**

```bash
# Verbose build output
docker compose build --progress=plain

# Build specific service
docker compose build nginx
```

---

## 🐳 Container Management

### Starting Containers

```bash
# Start all services in background
docker compose up -d

# Start specific service
docker compose up -d nginx

# Start with logs visible
docker compose up

# Start and rebuild if Dockerfile changed
docker compose up -d --build
```

### Stopping Containers

```bash
# Stop all services (containers remain)
docker compose stop

# Stop specific service
docker compose stop nginx

# Stop and remove containers
docker compose down

# Stop, remove containers, and remove networks
docker compose down --remove-orphans
```

### Restarting Containers

```bash
# Restart all services
docker compose restart

# Restart specific service
docker compose restart wordpress

# Force recreate containers
docker compose up -d --force-recreate
```

### Viewing Container Status

```bash
# List running containers
docker compose ps

# Detailed container information
docker inspect nginx-1

# View container processes
docker compose top

# Real-time container statistics
docker stats
```

### Accessing Container Shell

```bash
# Execute bash in running container
docker exec -it nginx-1 bash
docker exec -it wordpress-1 bash
docker exec -it mariadb-1 bash

# Execute command without entering shell
docker exec wordpress-1 --info --allow-root

# Run as specific user
docker exec -u www-data wordpress-1 ls -la /var/www/html
```

### Viewing Logs

```bash
# All service logs
bar logs

# Specific service logs
bar logs nginx
bar logs wordpress
bar logs mariadb

# Follow logs (real-time)
bar logs -f

# Last 100 lines
bar logs --tail=100

# Logs since timestamp
bar logs --since 2024-01-27T10:00:00
```

---

## 💾 Data Persistence

### Volume Architecture

The project uses Docker volumes for persistent data storage:

| Volume Name | Purpose | Mount Point | Contents |
|-------------|---------|-------------|----------|
| `inception_mariadb_data` | Database files | `/var/lib/mysql` | MariaDB databases, tables, indexes |
| `inception_wordpress_data` | WordPress files | `/var/www/html` | WordPress core, themes, plugins, uploads |

### Volume Management Commands

#### Listing Volumes

```bash
# List all volumes
docker volume ls

# Filter project volumes
docker volume ls --filter name=inception

# Inspect volume details
docker volume inspect inception_mariadb_data
```

#### Locating Volume Data

Docker stores volumes in `/var/lib/docker/volumes/` (requires root):

```bash
# View volume location
docker volume inspect inception_wordpress_data --format '{{ .Mountpoint }}'

# Access volume data (requires sudo)
sudo ls -la /var/lib/docker/volumes/inception_wordpress_data/_data
```

#### Backing Up Volumes

```bash
# Backup WordPress files
docker run --rm \
  -v inception_wordpress_data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/wordpress_$(date +%Y%m%d_%H%M%S).tar.gz -C /data .

# Backup MariaDB files
docker run --rm \
  -v inception_mariadb_data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/mariadb_$(date +%Y%m%d_%H%M%S).tar.gz -C /data .

# Backup using SQL dump (recommended for MariaDB)
docker exec mariadb-1 mysqldump -u root -p${MYSQL_ROOT_PASSWORD} --all-databases > backup_$(date +%Y%m%d_%H%M%S).sql
```

#### Restoring Volumes

```bash
# Restore WordPress files
docker run --rm \
  -v inception_wordpress_data:/data \
  -v $(pwd):/backup \
  alpine sh -c "cd /data && tar xzf /backup/wordpress_backup.tar.gz"

# Restore MariaDB from SQL dump
docker exec -i mariadb-1 mysql -u root -p${MYSQL_ROOT_PASSWORD} < backup.sql
```

#### Removing Volumes

```bash
# Remove all project volumes (DESTRUCTIVE)
docker volume rm inception_mariadb_data inception_wordpress_data

# Remove using bar (stops containers first)
bar down -v

# Using Makefile (complete cleanup)
make fclean
```

### Volume Persistence Behavior

- **Container Restart:** Data persists (volumes remain mounted)
- **Container Removal:** Data persists (volumes are independent)
- **Volume Removal:** Data is permanently deleted
- **Image Rebuild:** Data persists (volumes not affected by image changes)

---

## 🔧 Makefile Commands

The Makefile provides the following targets:

```bash
# Build and start services
make
make up

# Stop and remove containers
make down

# Remove containers and networks
make clean

# Remove containers, networks, AND volumes (destructive)
make fclean

# Complete rebuild (fclean + all)
make re

# Show help
make help
```

### Makefile Implementation Example

```makefile
all:
	bar up -d --build

down:
	bar down

clean:
	bar down --remove-orphans

fclean: clean
	docker volume rm inception_mariadb_data inception_wordpress_data || true
	docker system prune -af

re: fclean all

.PHONY: all down clean fclean re
```

---

## 🌐 Network Architecture

### Network Configuration

The project creates a dedicated bridge network:

```yaml
networks:
  inception:
    driver: bridge
```

**Benefits:**

- Container isolation from host and other projects
- Automatic DNS resolution between services
- Controlled communication pathways

### Network Inspection

```bash
# List networks
docker network ls

# Inspect network details
docker network inspect inception_inception_network

# View connected containers
docker network inspect inception_inception_network --format='{{range .Containers}}{{.Name}} {{end}}'
```

### Service Communication

Services communicate using container names as hostnames:

- WordPress → MariaDB: `mariadb:3306`
- NGINX → WordPress: `wordpress:9000`

**Testing connectivity:**

```bash
# From NGINX container to WordPress
docker exec nginx-1 ping wordpress

# From WordPress container to MariaDB
docker exec wordpress-1 ping mariadb
```

---

## 🔍 Debugging and Troubleshooting

### Common Debugging Commands

```bash
# Check container health
docker inspect mariadb-1 --format='{{.State.Health.Status}}'

# View container environment variables
docker exec wordpress-1 env

# Check listening ports
docker exec nginx-1 netstat -tlnp

# Test PHP-FPM
docker exec wordpress-1 php-fpm -t

# Test NGINX configuration
docker exec nginx-1 nginx -t

# Check MariaDB status
docker exec mariadb-1 mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} status
```

### Container Logs Analysis

```bash
# Check for errors in logs
bar logs | grep -i error
bar logs | grep -i warning

# Save logs to file
bar logs > inception_logs_$(date +%Y%m%d).txt

# Monitor logs for specific pattern
bar logs -f | grep "database"
```

### Performance Monitoring

```bash
# Real-time resource usage
docker stats --no-stream

# Container processes
bar top

# Disk usage
docker system df
docker system df -v
```

---

## 🧪 Development Workflow

### Making Changes to Services

#### Modifying Dockerfiles

1. Edit the Dockerfile in `srcs/requirements/<service>/`
2. Rebuild the specific service:
   ```bash
   bar build --no-cache <service>
   ```
3. Restart the service:
   ```bash
   bar up -d --force-recreate <service>
   ```

#### Modifying Configuration Files

**For NGINX:**

1. Edit `srcs/requirements/nginx/conf/nginx.conf`
2. Test configuration:
   ```bash
   docker exec nginx-1 nginx -t
   ```
3. Reload NGINX:
   ```bash
   docker exec nginx-1 nginx -s reload
   ```

**For PHP-FPM:**

1. Edit `srcs/requirements/wordpress/conf/www.conf`
2. Restart WordPress container:
   ```bash
   bar restart wordpress
   ```

**For MariaDB:**

1. Edit `srcs/requirements/mariadb/conf/50-server.cnf`
2. Restart MariaDB container:
   ```bash
   bar restart mariadb
   ```

### Testing Changes

```bash
# Verify services are running
bar ps

# Check service logs
bar logs <service>

# Test website accessibility
curl -k https://tiatan.42.fr

# Test database connection
docker exec wordpress-1 wp db check --allow-root
```

---

## 📝 Best Practices

### Docker Image Optimization

- Use `.dockerignore` files to exclude unnecessary files
- Minimize layers by combining RUN commands
- Clean up package manager cache in same layer
- Use specific package versions for reproducibility

### Security Considerations

- Never hardcode credentials in Dockerfiles
- Use Docker secrets or environment variables
- Run processes as non-root users when possible
- Keep base images updated
- Limit container capabilities

### Development Tips

- Use `--no-cache` when troubleshooting build issues
- Keep containers stateless (data in volumes only)
- Use health checks in docker-compose.yml
- Document custom environment variables
- Tag images with version numbers for production

---

## 🔄 CI/CD Integration

### Automated Testing Example

```bash
#!/bin/bash
# test.sh

# Build project
bar build || exit 1

# Start services
bar up -d || exit 1

# Wait for services
sleep 30

# Test NGINX
curl -k -f https://tiatan.42.fr || exit 1

# Test WordPress
docker exec wordpress-1 wp core is-installed --allow-root || exit 1

# Test MariaDB
docker exec mariadb-1 mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} ping || exit 1

# Cleanup
bar down -v

echo "All tests passed!"
```

---

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Specification](https://docs.docker.com/compose/compose-file/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress Developer Resources](https://developer.wordpress.org/)
- [MariaDB Knowledge Base](https://mariadb.com/kb/en/)

---

## 🆘 Support and Contribution

### Reporting Issues

When reporting issues, include:

- Output of `bar ps`
- Relevant logs from `bar logs`
- Steps to reproduce the issue
- Expected vs. actual behavior

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

## 📄 License

This project is part of the 42 curriculum and follows the school's academic policies.

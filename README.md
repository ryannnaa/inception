# Inception 🐳

This repository contains work completed as part of the **42 curriculum**, authored by **tiatan**, for the **Inception** project.

## 📌 Project Overview

**Inception** introduces core containerization concepts through the design and deployment of a secure, modular web infrastructure using **Docker** and **Docker Compose**.

Rather than relying on prebuilt images, each service is **manually built from a custom Dockerfile**, following strict constraints that encourage best practices in security, networking, and container lifecycle management.

The final result is a fully functional **WordPress** website served over **HTTPS**, with persistent storage and a clean separation of concerns between services.

---

## 🎯 Objectives

This project focuses on:

- Understanding the difference between **containers and virtual machines**
- Writing **reliable, standards-compliant Dockerfiles**
- Building and orchestrating multi-container applications with **Docker Compose**
- Properly configuring:
  - Networks
  - Volumes
  - Secrets
- Enforcing correct container behavior:
  - One main process per container
  - Proper PID 1 handling
  - No artificial keep-alive loops

---

## 🏗️ Architecture

The application stack consists of the following services:

### 🔒 NGINX
- Acts as the single entry point to the application
- Terminates TLS connections
- Serves **HTTPS only**
- Supports **TLS 1.2 and TLS 1.3 exclusively**

### 📝 WordPress
- Runs using **PHP-FPM only**
- No embedded web server
- Communicates internally with NGINX and MariaDB

### 🗄️ MariaDB
- Provides the database backend for WordPress
- Uses persistent storage to preserve data across restarts

### 🌐 Docker Network
- A dedicated Docker network ensures:
  - Service isolation
  - Secure internal communication
  - Built-in DNS resolution

### 💾 Persistent Volumes
- One volume for **MariaDB data**
- One volume for **WordPress files**

---

## ⚙️ Technical Constraints

All services:

- Are built from **custom Dockerfiles**
- Use **Debian Bookworm** as the base image
- Restart automatically on failure
- Do **not** use host networking
- Do **not** rely on bind mounts
- Use **Docker secrets** for sensitive data

---

## 🧰 Requirements

To run this project, you need:

- A Linux-based virtual machine
- Docker
- Docker Compose
- GNU Make

---

## 🚀 Build & Run

Build images and start all services:

```bash
make


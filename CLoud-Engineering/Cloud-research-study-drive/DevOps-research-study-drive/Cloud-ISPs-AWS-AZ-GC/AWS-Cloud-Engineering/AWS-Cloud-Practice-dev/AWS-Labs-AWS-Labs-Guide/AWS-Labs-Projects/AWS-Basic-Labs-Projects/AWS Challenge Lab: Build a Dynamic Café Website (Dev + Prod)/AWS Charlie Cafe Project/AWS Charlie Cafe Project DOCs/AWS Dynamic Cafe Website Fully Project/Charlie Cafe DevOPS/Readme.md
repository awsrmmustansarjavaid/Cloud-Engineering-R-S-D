# Charlie Cafe 




---
### Lamp Server Script.sh

> **Update Version: 1.1**

Your current script is clean 👍 — we’ll upgrade it into a production-ready DevOps-friendly EC2 bootstrap script by adding:

- Docker (with auto-start + permissions)

- Git

- Docker Compose (important for your microservices)

- Useful DevOps tools (htop, unzip, curl, etc.)

Best practices (user permissions, service enablement)

#### ✅ FULL UPDATED EC2 USER DATA SCRIPT (Amazon Linux 2023)

```
#!/bin/bash
# =========================================================
# ☕ Charlie Cafe — EC2 Bootstrap Script (Production Ready)
# Amazon Linux 2023
# LAMP + Docker + DevOps Tools
# =========================================================

set -e  # Stop on error

echo "🚀 Starting EC2 Setup..."

# ---------------------------------------------------------
# 1️⃣ Update OS (MANDATORY)
# ---------------------------------------------------------
dnf update -y

# ---------------------------------------------------------
# 2️⃣ Install Apache (httpd)
# ---------------------------------------------------------
dnf install -y httpd
systemctl enable httpd
systemctl start httpd

# ---------------------------------------------------------
# 3️⃣ Install PHP + MySQL Support
# ---------------------------------------------------------
dnf install -y \
php \
php-mysqlnd \
php-cli \
php-common \
php-mbstring \
php-xml

# ---------------------------------------------------------
# 4️⃣ Fix Web Directory Permissions
# ---------------------------------------------------------
chown -R apache:apache /var/www
chmod -R 755 /var/www

# ---------------------------------------------------------
# 5️⃣ Install MySQL Client (MariaDB)
# ---------------------------------------------------------
dnf install -y mariadb105

# ---------------------------------------------------------
# 6️⃣ Install Docker
# ---------------------------------------------------------
dnf install -y docker

systemctl enable docker
systemctl start docker

# Allow ec2-user to run docker without sudo
usermod -aG docker ec2-user

# ---------------------------------------------------------
# 7️⃣ Install Docker Compose (v2)
# ---------------------------------------------------------
mkdir -p /usr/local/lib/docker/cli-plugins/

curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
-o /usr/local/lib/docker/cli-plugins/docker-compose

chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Verify
docker compose version

# ---------------------------------------------------------
# 8️⃣ Install Git
# ---------------------------------------------------------
dnf install -y git

# ---------------------------------------------------------
# 9️⃣ Install Useful DevOps Tools
# ---------------------------------------------------------
dnf install -y \
htop \
unzip \
curl \
wget \
nano \
vim \
tar

# ---------------------------------------------------------
# 🔟 Install AWS CLI (already included in AL2023 but ensure)
# ---------------------------------------------------------
dnf install -y awscli

# ---------------------------------------------------------
# 1️⃣1️⃣ Create PHP Info Page (Optional)
# ---------------------------------------------------------
echo "<?php phpinfo(); ?>" > /var/www/html/info.php

# ---------------------------------------------------------
# 1️⃣2️⃣ Restart Apache
# ---------------------------------------------------------
systemctl restart httpd

# ---------------------------------------------------------
# ✅ Done
# ---------------------------------------------------------
echo "✅ EC2 Setup Completed Successfully!"
```

### 🔥 What You Just Added (Important)

#### 🐳 Docker Setup

- Installed + enabled at boot

- ec2-user can run Docker (no sudo)

#### 👉 After SSH:

```
docker ps
docker run hello-world
```

### 🧱 Docker Compose (CRITICAL for your project)

You’ll use this for:

- Frontend (React / HTML)

- Backend (PHP / API)

- Database (MySQL container if needed)

### 🔧 DevOps Tools Installed

| Tool      | Purpose                |
| --------- | ---------------------- |
| git       | Pull code from GitHub  |
| curl/wget | API testing, downloads |
| htop      | Monitor CPU/RAM        |
| unzip/tar | Extract files          |
| nano/vim  | Edit configs           |

### ⚠️ Important Notes (REAL-WORLD)

### 1. Docker group change requires re-login

#### After SSH:

```
exit
# login again
```

### 2. Security Group Reminder

##### Make sure EC2 allows:

- 80 (HTTP)

- 443 (HTTPS)

- 22 (SSH)

### 3. Production Improvement (Next Step)

#### Later you should add:

- Nginx reverse proxy

- SSL (Let's Encrypt)

- CI/CD (GitHub Actions)

- Dockerized app (instead of LAMP)

## simple, real-world way using your Charlie Cafe project

### 🧠 1. Your CURRENT setup (What you have now)

Right now your architecture is:

```
EC2 (LAMP Server)
 ├── Apache (httpd)
 ├── PHP
 ├── MySQL (RDS)
 └── Your app files (manually uploaded)
```

### ❌ Problems in this approach

- Manual deployment (upload files again & again)

- Risk of breaking server config

- Hard to scale

- Not portable (works only on THIS EC2)

- No version control for infra

- No rollback if something breaks

👉 This is called “Traditional Deployment”

### 🚀 2. What Docker Solves

Think of Docker like:

👉 "A portable mini-server inside a box"

#### Instead of installing everything on EC2:

```
EC2
 └── Docker
      ├── App Container (PHP + Apache)
      ├── MySQL Container (optional)
      └── Other services
```

### 🔥 Benefits (VERY IMPORTANT)

### ✅ 1. No more "it works on my machine" problem

#### Same container runs everywhere:

- EC2

- Laptop

- Another cloud

### ✅ 2. Easy Deployment

#### Instead of installing manually:

```
docker compose up -d
```

DONE ✅

### ✅ 3. Isolation

#### Each service runs separately:

- Frontend container

- Backend container

- DB container

- No conflicts

### ✅ 4. Easy Scaling

#### You can run multiple containers:

```
docker scale app=3
```

### ⚙️ 3. What is Docker Compose (VERY IMPORTANT)

#### Instead of running multiple containers manually:

```
docker run ...
docker run ...
docker run ...
```

#### You define everything in ONE file:

```
docker-compose.yml
```

Example:

```
services:
  web:
    image: php-apache
  db:
    image: mysql
```

#### Then run:

```
docker compose up -d
```

### 🔄 4. What is CI/CD (Game Changer)

CI/CD = Automatic Deployment System

### 🧩 Without CI/CD

#### You:

- Write code

- Upload manually to EC2

- Restart server

- Pray it works 😅

### ⚡ With CI/CD

#### You:

- Push code to GitHub

#### Then automatically:

```
GitHub → Build → Test → Deploy → EC2
```

No manual work 😎

### 🔥 5. Your FUTURE architecture (Target)

```
GitHub
   ↓
CI/CD Pipeline
   ↓
EC2 (Docker)
   ↓
Containers:
   ├── Frontend
   ├── Backend (PHP API)
   └── (Optional DB)
```

### 🧱 6. Where your current project fits

#### Your Charlie Cafe already has:

PHP backend ✅

MySQL (RDS) ✅

Frontend ✅

AWS infra ✅

👉 PERFECT candidate for Docker + CI/CD

### 🧠 7. Key Concepts You MUST Understand First

#### Before we build, make sure you're clear on:

### 🔹 Docker

- Image = blueprint

- Container = running app

- Dockerfile = how image is built

### 🔹 Docker Compose

- Multi-container setup

- One command deployment

### 🔹 CI/CD

- GitHub Actions (we’ll use this)

- Auto deploy on push

### 🔹 Environment Variables

#### Instead of hardcoding DB:

```
DB_HOST=your-rds-endpoint
DB_USER=admin
```

### ⚠️ 8. Important Truth (No Fluff)

Your current LAMP setup will become:

👉 LESS important

Because:

- Apache → inside container

- PHP → inside container

- Manual setup → gone

### 🧭 9. Learning Path (VERY CLEAR)

We will go step-by-step:

### STEP 1 → Dockerize your app

- Create Dockerfile

- Run container

#### STEP 2 → Docker Compose

- Add services

- Connect app + DB

#### STEP 3 → GitHub Setup

- Push project

#### STEP 4 → CI/CD Pipeline

- Auto deploy to EC2

### 💬 Before We Start

I need to understand your current setup better:

#### 👉 Answer these:

Is your frontend inside /var/www/html (PHP + HTML mix)?

Are you using:

Pure PHP (no framework)?

Do you want:

Keep RDS (recommended) ✅

OR move DB to Docker ❌ (not recommended for prod)


---

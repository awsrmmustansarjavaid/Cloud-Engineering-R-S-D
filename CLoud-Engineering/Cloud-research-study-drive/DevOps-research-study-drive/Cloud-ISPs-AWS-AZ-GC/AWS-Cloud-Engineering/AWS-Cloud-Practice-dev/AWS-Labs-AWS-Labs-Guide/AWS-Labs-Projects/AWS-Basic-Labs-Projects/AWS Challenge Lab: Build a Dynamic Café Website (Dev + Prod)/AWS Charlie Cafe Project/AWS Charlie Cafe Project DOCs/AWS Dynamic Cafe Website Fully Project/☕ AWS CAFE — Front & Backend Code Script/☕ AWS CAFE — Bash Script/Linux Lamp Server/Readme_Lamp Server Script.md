# Charlie Cafe - Lamp Server Script


### Lamp Server Script.sh

> **Update Version: 1.0**


```
#!/bin/bash
# --------------------------------------------
# EC2 User Data Script
# Amazon Linux 2023
# Installs LAMP Stack + MySQL Client
# --------------------------------------------

# 1️⃣ Update OS (MANDATORY FIRST)
dnf update -y

# 2️⃣ Install Apache (httpd)
dnf install -y httpd
systemctl enable httpd
systemctl start httpd

# 3️⃣ Install PHP + MySQL Support
dnf install -y \
php \
php-mysqlnd \
php-cli \
php-common \
php-mbstring \
php-xml

# 4️⃣ Fix Web Directory Permissions (MANDATORY)
chown -R apache:apache /var/www
chmod -R 755 /var/www

# 5️⃣ Install MySQL Client (MariaDB)
dnf install -y mariadb105

# 6️⃣ Create a PHP Info Page (Optional Verification)
echo "<?php phpinfo(); ?>" > /var/www/html/info.php

# 7️⃣ Restart Apache to Apply PHP
systemctl restart httpd

# 8️⃣ Install AWS CLI
sudo dnf install -y awscli


# --------------------------------------------
# END OF USER DATA
# --------------------------------------------
```

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

---
### Lamp Server Script.sh

> **Update Version: 1.2**

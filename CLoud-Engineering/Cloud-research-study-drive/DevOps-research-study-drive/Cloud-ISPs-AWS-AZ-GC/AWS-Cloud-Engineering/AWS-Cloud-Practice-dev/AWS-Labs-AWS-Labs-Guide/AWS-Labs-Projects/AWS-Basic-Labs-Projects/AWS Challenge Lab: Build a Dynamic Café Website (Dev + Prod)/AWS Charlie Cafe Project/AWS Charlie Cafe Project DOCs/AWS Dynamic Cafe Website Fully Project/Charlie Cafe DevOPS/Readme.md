# Charlie Cafe 

### 🐳 ✅ FINAL Dockerfile (Use This Only)

#### Create:

```
docker/apache-php/Dockerfile
```

```
# -------------------------------------------------
# ☕ Charlie Cafe - FINAL Dockerfile (PHP + Apache)
# Production Ready | DevOps Standard
# -------------------------------------------------

# Use official PHP with Apache
FROM php:8.2-apache

# -------------------------------------------------
# Install required PHP extensions
# (For MySQL / RDS connectivity)
# -------------------------------------------------
RUN docker-php-ext-install mysqli pdo pdo_mysql

# -------------------------------------------------
# Enable Apache rewrite module (for clean URLs / routing)
# -------------------------------------------------
RUN a2enmod rewrite

# -------------------------------------------------
# Set working directory
# -------------------------------------------------
WORKDIR /var/www/html

# -------------------------------------------------
# Copy frontend code (NO modification required)
# -------------------------------------------------
COPY app/frontend/ /var/www/html/

# -------------------------------------------------
# Set proper permissions
# -------------------------------------------------
RUN chown -R www-data:www-data /var/www/html

# -------------------------------------------------
# Expose Apache port
# -------------------------------------------------
EXPOSE 80
```

### 🔍 Why This Is the FINAL Version

This combines everything correctly:

| Feature             | Included |
| ------------------- | -------- |
| PHP 8.2 Apache      | ✅        |
| MySQL (RDS) support | ✅        |
| PDO support         | ✅        |
| mod_rewrite         | ✅        |
| Clean WORKDIR       | ✅        |
| Correct COPY path   | ✅        |
| Permissions         | ✅        |

### ❗ Important Fix (Why earlier versions differed)

You saw 3 versions because of:

#### ❌ Wrong paths (old versions)

```
COPY ../../app/frontend/
```

👉 This breaks Docker build context

#### ✅ Correct version (FINAL)

```
COPY app/frontend/ /var/www/html/
```

✔ Works with standard repo structure

✔ Works with docker-compose

✔ No hacks needed

### ⚙️ FINAL docker-compose.yml (MATCHED)

Make sure it matches this Dockerfile:

```
version: "3.8"

services:

  web:
    build:
      context: .
      dockerfile: docker/apache-php/Dockerfile
    container_name: charlie_web
    ports:
      - "8080:80"
    volumes:
      - ./app/frontend:/var/www/html
    restart: always

  db:
    image: mysql:8.0
    container_name: charlie_db
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: cafe_db
    ports:
      - "3306:3306"
    volumes:
      - ./infrastructure/rds:/docker-entrypoint-initdb.d
```

### 🧪 Test It (Final Check)

```
docker-compose up --build
```

Open:

```
http://localhost:8080
```

### 💡 Pro Tip (Very Important)

Because you are using:

```
volumes:
  - ./app/frontend:/var/www/html
```

#### 👉 This means:

Your local code overrides container code
So even if COPY fails, your app still works

✔ This is good for development

✔ For production, you can remove volume

### 🧠 Final Understanding

You now have:

- Dockerfile → builds image

- docker-compose → runs services

- schema.sql → creates DB

- GitHub → stores everything

- Lambda → backend API


So the “final” setup is:

✅ Dockerfile #1 → Apache + PHP (frontend)

✅ Dockerfile #2 → MySQL (database with schema.sql)

### 🐳 ✅ FINAL MySQL Dockerfile (Your Requirement)

Create:

```
docker/mysql/Dockerfile
```

```
# -------------------------------------------------
# ☕ Charlie Cafe - MySQL Dockerfile (FINAL)
# Auto DB + Schema + Data Setup
# -------------------------------------------------

FROM mysql:8.0

# -------------------------------------------------
# Environment Variables
# -------------------------------------------------
ENV MYSQL_ROOT_PASSWORD=rootpassword
ENV MYSQL_DATABASE=cafe_db

# -------------------------------------------------
# Auto-run SQL files on container startup
# (Executed in alphabetical order)
# -------------------------------------------------
COPY infrastructure/rds/schema.sql /docker-entrypoint-initdb.d/01-schema.sql
COPY infrastructure/rds/data.sql /docker-entrypoint-initdb.d/02-data.sql

# -------------------------------------------------
# Expose MySQL port
# -------------------------------------------------
EXPOSE 3306
```

- MySQL image runs the scripts automatically on first container startup.

- verify.sql is not copied — you run it manually or via CI/CD test.

### ⚠️ Important Fix (VERY IMPORTANT)

You wrote:

```
COPY ../../infrastructure/rds/schema.sql
```

❌ This is WRONG in Docker

👉 Docker cannot access files outside build context

✅ Correct version (FINAL)

```
COPY infrastructure/rds/schema.sql ...
```

✔ Works with docker-compose

✔ Works in CI/CD

✔ Industry standard

### 🐳 ✅ FINAL Apache + PHP Dockerfile (Complete Setup)

```
# -------------------------------------------------
# ☕ Charlie Cafe - Apache + PHP Dockerfile (FINAL)
# -------------------------------------------------

FROM php:8.2-apache

RUN docker-php-ext-install mysqli pdo pdo_mysql
RUN a2enmod rewrite

WORKDIR /var/www/html

COPY app/frontend/ /var/www/html/

RUN chown -R www-data:www-data /var/www/html

EXPOSE 80
```

### ⚙️ ✅ FINAL docker-compose.yml (FULLY CONNECTED)

```
version: "3.8"

services:

  web:
    build:
      context: .
      dockerfile: docker/apache-php/Dockerfile
    container_name: charlie_web
    ports:
      - "8080:80"
    volumes:
      - ./app/frontend:/var/www/html
    depends_on:
      - db
    restart: always

  db:
    build:
      context: .
      dockerfile: docker/mysql/Dockerfile
    container_name: charlie_db
    ports:
      - "3306:3306"
    restart: always
```

### 🔄 How It Works (Simple)

When you run:

```
docker-compose up --build
```

👉 Docker does this:

### 🐬 MySQL container:

Starts MySQL

Runs:

```
01-schema.sql
02-data.sql
```

Creates DB + tables + data

### 🌐 Web container:

Runs Apache + PHP

Loads your frontend

Connects to DB

### 💡 Pro Tips (Very Important)

### ✅ 1. File Execution Order

```
01-schema.sql
02-data.sql
```

✔ Ensures:

Tables created first

Data inserted second

### ✅ 2. First Run Only Behavior

👉 MySQL runs SQL files ONLY if:

```
database is empty
```

If you restart container:

❌ SQL will NOT run again

### ✅ 3. Reset Database (if needed)

```
docker-compose down -v
docker-compose up --build
```

### ✅ 4. Optional: Merge schema + data

If you want simpler:

```
schema.sql (with inserts inside)
```

### 🎯 Final Result

You now have:

✅ Clean Docker architecture

✅ MySQL auto schema setup

✅ No manual DB setup needed

✅ Works with GitHub + CI/CD

✅ Fully DevOps-ready

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

- Are you using:

Pure PHP (no framework)?

- Do you want:

Keep RDS (recommended) ✅

- OR move DB to Docker ❌ (not recommended for prod)


---
## Dockerfile (custom for your project)

let’s start Step 1: Dockerize your Charlie Cafe app 🚀
I’ll keep it practical + tailored to your setup (PHP + Apache + RDS).

### 🧱 STEP 1 — Create Your First Docker Image

Since you said yes, I’ll assume:

✅ You are using pure PHP (no framework)

✅ Your code is inside something like:

```
app/frontend/
```

✅ You want to keep RDS (correct decision 👍)

### 🧠 What we are doing

We will replace this:

```
EC2 → Apache + PHP installed manually
```

With this:

```
EC2 → Docker → PHP + Apache container
```

### 📦 1. Create a Dockerfile

Inside your project root (charlie-cafe-devops/), create:

```
Dockerfile
```

### ✅ Your FIRST Dockerfile (Production Ready)

```
# -------------------------------------------------
# ☕ Charlie Cafe Dockerfile (PHP + Apache)
# -------------------------------------------------

# Use official PHP Apache image
FROM php:8.2-apache

# Install PHP extensions
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Enable Apache mod_rewrite (important)
RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# Copy your app code into container
COPY app/frontend/ /var/www/html/

# Set correct permissions
RUN chown -R www-data:www-data /var/www/html

# Expose port 80
EXPOSE 80
```

### 📦 2. Create .dockerignore (IMPORTANT)

This prevents junk files from going into Docker image.

```
.dockerignore
```

```
.git
node_modules
.env
*.log
```

### ⚙️ 3. Build Your Docker Image

SSH into EC2 and go to your project:

```
cd charlie-cafe-devops
```

Then run:

```
docker build -t charlie-cafe .
```

### ▶️ 4. Run Your Container

```
docker run -d -p 80:80 --name cafe-app charlie-cafe
```

### 🌐 Now test in browser:

```
http://YOUR-EC2-PUBLIC-IP
```

👉 Your PHP app should load 🔥

### ⚠️ 5. IMPORTANT (RDS Connection)

#### Your app must NOT use:

```
localhost
```

#### Instead use:

```
RDS endpoint
```

Example:

```
$host = "your-rds-endpoint.amazonaws.com";
```

### 🧪 6. Debug Commands (VERY USEFUL)

#### Check running containers:

```
docker ps
```

#### See logs:

```
docker logs cafe-app
```

#### Enter container:

```
docker exec -it cafe-app bash
```

### 🔥 7. What You Achieved

You just:

✅ Removed dependency on EC2 setup

✅ Made your app portable

✅ Prepared for CI/CD

✅ Entered real DevOps workflow

### 🧭 NEXT STEP (Don’t skip this)

Next we will build:

### 👉 Docker Compose (Multi-container setup)

So instead of:

```
docker run ...
```

You’ll use:

```
docker compose up -d
```


---







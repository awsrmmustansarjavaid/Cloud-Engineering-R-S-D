# Charlie Cafe - RDS Database




### ⚙️ 4. How It Works (Very Important)

#### In Docker:

```
volumes:
  - ./infrastructure/rds:/docker-entrypoint-initdb.d
```

#### 👉 What happens:

- MySQL container starts

- Automatically runs:

```
schema.sql
```

- Database + tables created instantly

### 🧪 5. VERIFICATION SQL (You Asked This 👍)

#### Create another file:

```
infrastructure/rds/verify.sql
```

### ✅ FULL VERIFICATION SCRIPT

```
-- ==========================================================
-- ☕ Charlie Cafe — VERIFICATION & ANALYTICS
-- PURPOSE:
-- Verify DB structure, data, foreign keys, and analytics.
-- ==========================================================

USE cafe_db;

-- =============================
-- VERIFY DATABASE
-- =============================
SELECT DATABASE();

-- =============================
-- SHOW TABLES
-- =============================
SHOW TABLES;

-- =============================
-- DESCRIBE TABLES
-- =============================
DESCRIBE employees;
DESCRIBE attendance;
DESCRIBE leaves;
DESCRIBE holidays;
DESCRIBE orders;

-- =============================
-- VIEW ALL DATA
-- =============================
SELECT * FROM employees;
SELECT * FROM attendance;
SELECT * FROM leaves;
SELECT * FROM holidays;
SELECT * FROM orders;

-- =============================
-- VERIFY FOREIGN KEYS
-- =============================
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'cafe_db'
AND REFERENCED_TABLE_NAME IS NOT NULL;

-- =============================
-- VERIFY INDEXES
-- =============================
SHOW INDEX FROM orders;

-- =============================
-- ROW COUNTS
-- =============================
SELECT
(SELECT COUNT(*) FROM orders) AS total_orders,
(SELECT COUNT(*) FROM employees) AS total_employees,
(SELECT COUNT(*) FROM attendance) AS total_attendance,
(SELECT COUNT(*) FROM holidays) AS total_holidays;

-- =============================
-- ANALYTICS TESTS
-- =============================

-- Paid Orders
SELECT COUNT(*) AS paid_orders
FROM orders
WHERE payment_status='PAID';

-- Today Sales
SELECT COUNT(*) AS today_sales
FROM orders
WHERE payment_status='PAID'
AND created_at >= CURDATE();

-- Week Sales
SELECT COUNT(*) AS week_sales
FROM orders
WHERE payment_status='PAID'
AND created_at >= NOW() - INTERVAL 7 DAY;

-- Month Sales
SELECT COUNT(*) AS month_sales
FROM orders
WHERE payment_status='PAID'
AND created_at >= DATE_FORMAT(NOW(),'%Y-%m-01');
```

### ▶️ 6. How to Run Verification

#### Inside container:

```
docker exec -it charlie_db mysql -u root -p
```

Then:

```
SOURCE /docker-entrypoint-initdb.d/verify.sql;
```

### 🚀 7. How This Fits Your DevOps Project

Now your project becomes:

#### Before:

❌ Bash-only setup

❌ Hard to reuse

❌ Not portable

#### After:

✅ Docker auto DB setup

✅ GitHub version control

✅ Clean separation

✅ Industry standard

### 💡 8. Professional Upgrade Tips (IMPORTANT)

### ✅ 1. Split Files (Advanced)

#### Later:

```
schema.sql
data.sql
verify.sql
```

### ✅ 2. Add Migration Tool (Future)

#### Use:

- Flyway

- Liquibase

### ✅ 3. Use Environment Variables

#### Instead of hardcoding:

```
cafe_db
```

### ✅ 4. Keep Your Bash Script

#### 👉 Your script is still useful for:

- AWS RDS setup

- Production automation

### 🎯 Final Understanding

👉 Your Bash script = Automation Layer

👉 Your schema.sql = Database Blueprint

Both are important.
---

Right now your Bash script is doing 3 things mixed together:

Creating schema (tables, DB structure)
Inserting data
Running verification/tests

We will separate these into clean professional files:

### ✅ ✅ FINAL SPLIT (PRODUCTION STYLE)

You will have:

```
schema.sql   → structure (DB + tables)
data.sql     → sample/test data
verify.sql   → testing + analytics
```






### ⚙️ HOW IT WORKS (STEP BY STEP)

### ✅ Step 1 — Create schema

```
mysql -h <host> -u <user> -p < schema.sql
```

#### 👉 Creates:

- database

- tables

- relationships

### ✅ Step 2 — Insert data

```
mysql -h <host> -u <user> -p < data.sql
```

### ✅ Step 3 — Verify

```
mysql -h <host> -u <user> -p < verify.sql
```

### 🔥 PRO TIP (IMPORTANT FOR YOU)

#### You can now simplify your bash script like this:

```
mysql --defaults-extra-file="$CREDENTIALS_FILE" < schema.sql
mysql --defaults-extra-file="$CREDENTIALS_FILE" < data.sql
mysql --defaults-extra-file="$CREDENTIALS_FILE" < verify.sql
```

### 🚀 REAL-WORLD BENEFITS

This is why companies do this:

#### ✅ 1. Version Control (GitHub)

- Track DB changes like code

#### ✅ 2. Easy Deployment

#### Run same schema on:

- Dev

- Staging

- Production

#### ✅ 3. Debugging

Fix errors like:

- Unknown column 'payment_method'

👉 by editing schema.sql only

#### ✅ 4. Automation (CI/CD)

Used in:

- AWS CodePipeline

- Terraform

- Docker

### ⚠️ IMPORTANT OBSERVATION (FROM YOUR ERROR)

You got:

```
Unknown column 'payment_method'
```

#### 👉 That means:

- Your Lambda expects column

- But schema.sql doesn't have it

If needed, we can upgrade schema.sql safely (next step).


### 🌐 How to run your current files in production without Docker/CI/CD

```
# Connect to RDS
mysql -h <RDS_HOST> -u <USER> -p < schema.sql    # Create DB and tables
mysql -h <RDS_HOST> -u <USER> -p < data.sql      # Optional: seed data
mysql -h <RDS_HOST> -u <USER> -p < verify.sql    # QA check
```

✅ This is safe and works now.

### 🌐 How to integrate schema.sql, data.sql, verify.sql into Docker + CI/CD

Since you already have:

```
charlie-cafe-devops/
├── docker/
│   └── mysql/
│       └── Dockerfile
├── docker-compose.yml
└── .github/workflows/deploy.yml
```

Here’s the common production-ready pattern:

### Step 1 — Dockerize MySQL for local testing

#### docker/mysql/Dockerfile

```
FROM mysql:8.0

ENV MYSQL_ROOT_PASSWORD=rootpassword
ENV MYSQL_DATABASE=cafe_db

# Copy schema and data
COPY ../../infrastructure/rds/schema.sql /docker-entrypoint-initdb.d/01-schema.sql
COPY ../../infrastructure/rds/data.sql /docker-entrypoint-initdb.d/02-data.sql
```

- MySQL image runs the scripts automatically on first container startup.

- verify.sql is not copied — you run it manually or via CI/CD test.

#### docker-compose.yml

```
version: "3.9"

services:
  mysql:
    build: ./docker/mysql
    container_name: charlie-cafe-mysql
    ports:
      - "3306:3306"
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
    volumes:
      - mysql_data:/var/lib/mysql

  apache-php:
    build: ./docker/apache-php
    container_name: charlie-cafe-web
    ports:
      - "8080:80"
    depends_on:
      - mysql

volumes:
  mysql_data:
```

### Step 2 — Add verify.sql to CI/CD for QA

#### .github/workflows/deploy.yml

```
name: Deploy Charlie Cafe

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest

    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: rootpassword
          MYSQL_DATABASE: cafe_db
        ports:
          - 3306:3306
        options: >-
          --health-cmd="mysqladmin ping --silent"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=3

    steps:
      - uses: actions/checkout@v3

      - name: Wait for MySQL
        run: |
          until mysqladmin ping -h 127.0.0.1 -uroot -prootpassword; do
            echo "Waiting for MySQL..."
            sleep 5
          done

      - name: Apply schema
        run: mysql -h 127.0.0.1 -uroot -prootpassword < infrastructure/rds/schema.sql

      - name: Apply sample data
        run: mysql -h 127.0.0.1 -uroot -prootpassword < infrastructure/rds/data.sql

      - name: Verify schema
        run: mysql -h 127.0.0.1 -uroot -prootpassword < infrastructure/rds/verify.sql
```

✅ This allows automatic DB creation + QA verification in CI/CD whenever you push code.

### Step 3 — Production vs Local

- Local development: Use Docker MySQL container + schema + data.

- Production RDS: Run schema.sql only + optional verify.sql.

- No Docker is needed on production RDS — RDS is fully managed by AWS.

### Step 4 — Optional Advanced

#### Later, you can add:

- Terraform script to provision RDS automatically

- CI/CD scripts to run schema migrations

- Versioned SQL migrations (like Flyway or Liquibase)

### 💡 Key takeaway:

- Your three SQL files are already production-ready without Docker or CI/CD. Docker + CI/CD is only automation and testing convenience, not a requirement.

## 🌐 a fully working docker-compose + CI/CD pipeline ready to run your Charlie Cafe database

✅ Docker (local environment)

✅ MySQL auto schema + data load

✅ CI/CD (GitHub Actions) with verification

✅ Clean structure (based on your repo)

### 🚀 FINAL GOAL

#### You will run:

```
docker-compose up -d
```

#### 👉 And get:

- MySQL running

- Database created

- Tables created

- Sample data inserted

- App ready

### 🐬 2. DOCKER MYSQL SETUP (AUTO LOAD SCHEMA)

#### 📄 docker/mysql/Dockerfile

```
FROM mysql:8.0

ENV MYSQL_ROOT_PASSWORD=rootpassword
ENV MYSQL_DATABASE=cafe_db

# Auto-run SQL files on container start
COPY ../../infrastructure/rds/schema.sql /docker-entrypoint-initdb.d/01-schema.sql
COPY ../../infrastructure/rds/data.sql /docker-entrypoint-initdb.d/02-data.sql
```

### ⚠️ IMPORTANT RULE

#### Docker runs files in this order:

```
01-schema.sql  ✅
02-data.sql    ✅
```

### 🌐 3. DOCKER APACHE + PHP

#### 📄 docker/apache-php/Dockerfile

```
FROM php:8.2-apache

# Install MySQL extension
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Copy your frontend code
COPY ../../app/frontend/ /var/www/html/

# Enable Apache mod_rewrite
RUN a2enmod rewrite

EXPOSE 80
```

### ⚙️ 4. docker-compose.yml (MAIN ENGINE)

```
version: "3.9"

services:
  mysql:
    build: ./docker/mysql
    container_name: cafe-mysql
    restart: always
    ports:
      - "3306:3306"
    environment:
      MYSQL_ROOT_PASSWORD: rootpassword
      MYSQL_DATABASE: cafe_db
    volumes:
      - mysql_data:/var/lib/mysql

  web:
    build: ./docker/apache-php
    container_name: cafe-web
    restart: always
    ports:
      - "8080:80"
    depends_on:
      - mysql

volumes:
  mysql_data:
```

### ▶️ 5. RUN YOUR PROJECT

```
docker-compose up -d
```

### 🌍 ACCESS YOUR APP

#### Open browser:

```
http://localhost:8080
```

### 🧪 6. RUN VERIFICATION MANUALLY

```
docker exec -i cafe-mysql mysql -uroot -prootpassword cafe_db < infrastructure/rds/verify.sql
```

### 🔥 7. FULL CI/CD PIPELINE (AUTO TEST)

#### 📄 .github/workflows/deploy.yml

```
name: Charlie Cafe CI/CD

on:
  push:
    branches: [main]

jobs:
  test-db:
    runs-on: ubuntu-latest

    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: rootpassword
          MYSQL_DATABASE: cafe_db
        ports:
          - 3306:3306
        options: >-
          --health-cmd="mysqladmin ping --silent"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=5

    steps:
      - name: Checkout Code
        uses: actions/checkout@v3

      - name: Wait for MySQL
        run: |
          until mysqladmin ping -h 127.0.0.1 -uroot -prootpassword; do
            echo "Waiting for MySQL..."
            sleep 5
          done

      - name: Run Schema
        run: |
          mysql -h 127.0.0.1 -uroot -prootpassword < infrastructure/rds/schema.sql

      - name: Run Data
        run: |
          mysql -h 127.0.0.1 -uroot -prootpassword < infrastructure/rds/data.sql

      - name: Run Verification
        run: |
          mysql -h 127.0.0.1 -uroot -prootpassword < infrastructure/rds/verify.sql
```

### 🧠 HOW EVERYTHING WORKS (IMPORTANT)

#### 🔹 Docker Flow

- Start MySQL container

- MySQL auto-runs:

    - schema.sql

    - data.sql

- Database ready

####  🔹CI/CD Flow

- GitHub push

- MySQL container starts

- schema.sql runs

- data.sql runs

- verify.sql tests everything

### 🏆 FINAL RESULT

You now have:

✅ Production-style schema

✅ Docker local environment

✅ Auto DB setup

✅ CI/CD validation

✅ Clean DevOps structure

### ⚠️ IMPORTANT NEXT STEP (VERY IMPORTANT)

#### Remember your earlier error:

```
Unknown column 'payment_method'
```

👉 Your current schema does NOT include it

### ✅ FIX (OPTIONAL UPGRADE)

#### Add this to orders table:

```
payment_method VARCHAR(20),
```


### ✅ Recommended GitHub Actions Usage

In deploy pipeline:

```
- name: Run Schema
  run: mysql -h $DB_HOST -u $DB_USER -p$DB_PASS < schema.sql

- name: Insert Data
  run: mysql -h $DB_HOST -u $DB_USER -p$DB_PASS < data.sql

- name: Verify DB
  run: mysql -h $DB_HOST -u $DB_USER -p$DB_PASS < verify.sql
```

### ✅ Senior DevOps Advice

Best practice for production:

Do NOT run DROP TABLE schema every deployment in real production.

Instead:

Dev/Test → okay to rebuild.
Production → use migrations (Flyway/Liquibase/manual ALTERs).

Because dropping tables each deploy deletes real customer data.

----
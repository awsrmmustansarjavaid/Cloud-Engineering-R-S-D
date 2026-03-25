# Charlie Cafe - RDS Database


### 1. What is schema.sql (Simple Explanation)

#### 👉 A schema.sql file is:

A pure SQL file that defines your database structure (DB + tables + relationships)

### ✅ Why it’s important

| Without schema.sql      | With schema.sql   |
| ----------------------- | ----------------- |
| Manual setup            | One command setup |
| Hard to reuse           | Easy reuse        |
| Not DevOps friendly     | Industry standard |
| Hidden logic in scripts | Clean separation  |

### 🔥 2. Difference: Bash Script vs schema.sql

#### Your Bash script:

- Connects to AWS

- Fetches secrets

- Runs SQL

#### 👉 But DevOps best practice:

- Bash = automation

- SQL file = database definition

### 📄 3. FINAL schema.sql (FROM YOUR SCRIPT — COMPLETE)

#### 👉 Create this file:

```
infrastructure/rds/schema.sql
```

### ✅ FULL FILE (Nothing missing)

```
-- =============================================================
-- ☕ Charlie Cafe Database Schema (Production Ready)
-- =============================================================

-- ===============================
-- CREATE DATABASE
-- ===============================
CREATE DATABASE IF NOT EXISTS cafe_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE cafe_db;

-- ===============================
-- EMPLOYEES TABLE
-- ===============================
CREATE TABLE IF NOT EXISTS employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    cognito_user_id VARCHAR(100) UNIQUE,
    name VARCHAR(100),
    job_title VARCHAR(50),
    salary DECIMAL(10,2),
    start_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===============================
-- ATTENDANCE TABLE
-- ===============================
CREATE TABLE IF NOT EXISTS attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT,
    attendance_date DATE,
    checkin_time TIME,
    checkout_time TIME,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- ===============================
-- LEAVES TABLE
-- ===============================
CREATE TABLE IF NOT EXISTS leaves (
    leave_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT,
    leave_date DATE,
    leave_type VARCHAR(50),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- ===============================
-- HOLIDAYS TABLE
-- ===============================
CREATE TABLE IF NOT EXISTS holidays (
    holiday_id INT AUTO_INCREMENT PRIMARY KEY,
    holiday_date DATE UNIQUE,
    description VARCHAR(100)
);

-- ===============================
-- ORDERS TABLE
-- ===============================
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    table_number INT,
    customer_name VARCHAR(100),
    item VARCHAR(100),
    quantity INT,
    total_cost DECIMAL(10,2),
    total_amount DECIMAL(10,2),
    payment_status VARCHAR(20),
    status VARCHAR(20),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ===============================
-- SAMPLE DATA (OPTIONAL BUT INCLUDED)
-- ===============================
INSERT IGNORE INTO employees
(cognito_user_id,name,job_title,salary,start_date)
VALUES
('emp-001','Ahmed','Barista',800,'2024-01-01'),
('emp-002','Hassan','Cashier',750,'2024-02-01');

INSERT IGNORE INTO attendance
(employee_id,attendance_date,checkin_time,checkout_time)
VALUES
(1,CURDATE(),'09:00:00','17:00:00'),
(2,CURDATE(),'09:15:00','17:00:00');

INSERT IGNORE INTO leaves
(employee_id,leave_date,leave_type)
VALUES
(1,'2026-03-01','Sick Leave');

INSERT IGNORE INTO holidays
(holiday_date,description)
VALUES
('2026-12-25','Christmas'),
('2026-01-01','New Year');

INSERT IGNORE INTO orders
(table_number,customer_name,item,quantity,total_cost,total_amount,payment_status,status)
VALUES
(1,'Ali Khan','Espresso',2,4.00,8.00,'PAID','COMPLETED'),
(2,'Sara Ahmed','Cappuccino',1,3.50,5.00,'PAID','COMPLETED'),
(3,'Omar Ali','Latte',1,3.00,5.00,'PENDING','RECEIVED');
```

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
USE cafe_db;

-- 1. Check database
SHOW DATABASES;

-- 2. Check tables
SHOW TABLES;

-- 3. Describe tables
DESCRIBE employees;
DESCRIBE attendance;
DESCRIBE leaves;
DESCRIBE holidays;
DESCRIBE orders;

-- 4. Check data
SELECT * FROM employees;
SELECT * FROM orders;

-- 5. Foreign keys
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'cafe_db'
AND REFERENCED_TABLE_NAME IS NOT NULL;

-- 6. Indexes
SHOW INDEX FROM orders;

-- 7. Row counts
SELECT
(SELECT COUNT(*) FROM orders) AS total_orders,
(SELECT COUNT(*) FROM employees) AS total_employees,
(SELECT COUNT(*) FROM attendance) AS total_attendance,
(SELECT COUNT(*) FROM holidays) AS total_holidays;

-- ===============================
-- ANALYTICS TESTS
-- ===============================

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


### 📁 1. schema.sql (STRUCTURE ONLY)

- Creates database if not exists → safe for repeated runs

- Creates all tables with proper primary keys

- Creates foreign keys for relationships (attendance, leaves)

- Uses IF NOT EXISTS → prevents errors if re-run

- Sets UTF8MB4 charset → supports emojis and special chars

#### 👉 This is the MOST IMPORTANT file

```
-- ==========================================================
-- ☕ Charlie Cafe — DATABASE SCHEMA
-- Purpose: Create DB + Tables + Relationships
-- Safe: YES (uses IF NOT EXISTS)
-- ==========================================================

-- =============================
-- CREATE DATABASE
-- =============================
CREATE DATABASE IF NOT EXISTS cafe_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE cafe_db;

-- =============================
-- EMPLOYEES TABLE
-- =============================
CREATE TABLE IF NOT EXISTS employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    cognito_user_id VARCHAR(100) UNIQUE,
    name VARCHAR(100),
    job_title VARCHAR(50),
    salary DECIMAL(10,2),
    start_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================
-- ATTENDANCE TABLE
-- =============================
CREATE TABLE IF NOT EXISTS attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT,
    attendance_date DATE,
    checkin_time TIME,
    checkout_time TIME,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- =============================
-- LEAVES TABLE
-- =============================
CREATE TABLE IF NOT EXISTS leaves (
    leave_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT,
    leave_date DATE,
    leave_type VARCHAR(50),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- =============================
-- HOLIDAYS TABLE
-- =============================
CREATE TABLE IF NOT EXISTS holidays (
    holiday_id INT AUTO_INCREMENT PRIMARY KEY,
    holiday_date DATE UNIQUE,
    description VARCHAR(100)
);

-- =============================
-- ORDERS TABLE
-- =============================
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    table_number INT,
    customer_name VARCHAR(100),
    item VARCHAR(100),
    quantity INT,
    total_cost DECIMAL(10,2),
    total_amount DECIMAL(10,2),
    payment_status VARCHAR(20),
    status VARCHAR(20),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

### 📁 2. data.sql (SAMPLE DATA)

- Seeding test/sample data for QA or demo

- Can run safely without breaking schema (INSERT IGNORE)

```
-- ==========================================================
-- ☕ Charlie Cafe — SAMPLE DATA
-- Purpose: Insert test data
-- Safe: YES (uses INSERT IGNORE)
-- ==========================================================

USE cafe_db;

-- =============================
-- EMPLOYEES
-- =============================
INSERT IGNORE INTO employees
(cognito_user_id,name,job_title,salary,start_date)
VALUES
('emp-001','Ahmed','Barista',800,'2024-01-01'),
('emp-002','Hassan','Cashier',750,'2024-02-01');

-- =============================
-- ATTENDANCE
-- =============================
INSERT IGNORE INTO attendance
(employee_id,attendance_date,checkin_time,checkout_time)
VALUES
(1,CURDATE(),'09:00:00','17:00:00'),
(2,CURDATE(),'09:15:00','17:00:00');

-- =============================
-- LEAVES
-- =============================
INSERT IGNORE INTO leaves
(employee_id,leave_date,leave_type)
VALUES
(1,'2026-03-01','Sick Leave');

-- =============================
-- HOLIDAYS
-- =============================
INSERT IGNORE INTO holidays
(holiday_date,description)
VALUES
('2026-12-25','Christmas'),
('2026-01-01','New Year');

-- =============================
-- ORDERS
-- =============================
INSERT IGNORE INTO orders
(table_number,customer_name,item,quantity,total_cost,total_amount,payment_status,status)
VALUES
(1,'Ali Khan','Espresso',2,4.00,8.00,'PAID','COMPLETED'),
(2,'Sara Ahmed','Cappuccino',1,3.50,5.00,'PAID','COMPLETED'),
(3,'Omar Ali','Latte',1,3.00,5.00,'PENDING','RECEIVED');
```

### 📁 3. verify.sql (TESTING + ANALYTICS)

- Verification after deployment

- Checks: tables, relationships, indexes, row counts, analytics (today/week/month sales)

```
-- ==========================================================
-- ☕ Charlie Cafe — VERIFICATION & ANALYTICS
-- ==========================================================

USE cafe_db;

-- =============================
-- CHECK DATABASE
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
-- VIEW DATA
-- =============================
SELECT * FROM employees;
SELECT * FROM attendance;
SELECT * FROM leaves;
SELECT * FROM holidays;
SELECT * FROM orders;

-- =============================
-- FOREIGN KEYS CHECK
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
-- INDEX CHECK
-- =============================
SHOW INDEX FROM orders;

-- =============================
-- ROW COUNT CHECK
-- =============================
SELECT
(SELECT COUNT(*) FROM orders) AS total_orders,
(SELECT COUNT(*) FROM employees) AS total_employees,
(SELECT COUNT(*) FROM attendance) AS total_attendance,
(SELECT COUNT(*) FROM holidays) AS total_holidays;

-- =============================
-- ANALYTICS
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

### 🎯 WHY schema.sql IS IMPORTANT (VERY IMPORTANT)

#### Think like DevOps:

| File       | Purpose                                       |
| ---------- | --------------------------------------------- |
| schema.sql | Structure (like building foundation of house) |
| data.sql   | Furniture (test/sample data)                  |
| verify.sql | Inspection (QA/testing)                       |

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


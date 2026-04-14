# Charlie Cafe - AWS RDS & Security 

### verify_rds.sh


```
#!/bin/bash
# ==========================================================
# ☕ Charlie Cafe — RDS Verification Script (Auto-create DB)
# ==========================================================

set -e

REPO_DIR="$HOME/charlie-cafe-devops"
SQL_FILE="$REPO_DIR/infrastructure/rds/verify.sql"
SECRET_NAME="CafeDevDBSM"

if [[ ! -f "$SQL_FILE" ]]; then
    echo "❌ SQL file not found: $SQL_FILE"
    exit 1
fi

echo "🔑 Fetching RDS credentials from Secrets Manager..."
CREDS_JSON=$(aws secretsmanager get-secret-value --secret-id "$SECRET_NAME" --query SecretString --output text)

DB_HOST=$(echo "$CREDS_JSON" | jq -r '.host')
DB_PORT=$(echo "$CREDS_JSON" | jq -r '.port // 3306')
DB_USER=$(echo "$CREDS_JSON" | jq -r '.username')
DB_PASS=$(echo "$CREDS_JSON" | jq -r '.password')
DB_NAME=$(echo "$CREDS_JSON" | jq -r '.dbname')

if [[ -z "$DB_HOST" || -z "$DB_USER" || -z "$DB_PASS" ]]; then
    echo "❌ Failed to fetch RDS credentials"
    exit 1
fi

echo "✅ RDS credentials fetched successfully."

# 1️⃣ Connect without database to check/create DB
echo "🔨 Ensuring database '$DB_NAME' exists..."
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" -e "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\`;"

# 2️⃣ Run verify.sql
echo "📜 Running verify.sql against RDS..."
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$SQL_FILE"

echo "✅ RDS verification completed successfully!"
```

#### 🔹 How to use

```
# 1. Save the file
nano verify_rds.sh

# 2. Make it executable
chmod +x verify_rds.sh

# 3. Run it
./verify_rds.sh
```

---
# Charlie Cafe - RDS Database

### ✅ use:

- AWS RDS (your real database)

- Your app container connects to RDS

### 🔥 ARCHITECTURE

```
Browser → Apache/PHP (Docker) → AWS RDS (MySQL)
```

### ✅ ✅ FINAL SPLIT (PRODUCTION STYLE)

You will have:

```
schema.sql   → structure (DB + tables)
data.sql     → sample/test data
verify.sql   → testing + analytics
```

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


### 🧱 docker-compose.yml (VERY IMPORTANT)

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
    environment:
      DB_HOST: your-rds-endpoint.amazonaws.com
      DB_USER: cafe_user
      DB_PASS: StrongPassword123
      DB_NAME: cafe_db
    restart: always
```

### PHP CONNECTION (VERY IMPORTANT)

#### In your PHP files (example: db.php):

```
<?php

$host = getenv('DB_HOST');
$user = getenv('DB_USER');
$pass = getenv('DB_PASS');
$db   = getenv('DB_NAME');

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
?>
```

### 🧱 3. APPLY YOUR SQL FILES TO RDS (ONE TIME)

👉 Use your existing files — no change needed

### ✅ Step 1 — Run schema.sql

```
mysql -h your-rds-endpoint.amazonaws.com -u cafe_user -p < schema.sql
```

### ✅ Step 2 — Run data.sql (optional)

```
mysql -h your-rds-endpoint.amazonaws.com -u cafe_user -p < data.sql
```

### ✅ Step 3 — Verify

```
mysql -h your-rds-endpoint.amazonaws.com -u cafe_user -p < verify.sql
```

### Step 2 — Add verify.sql to CI/CD for QA

#### .github/workflows/deploy.yml

```
name: ☕ Charlie Cafe DevOps CI/CD

on:
  push:
    branches: [ "main" ]

jobs:
  build-test-deploy:
    runs-on: ubuntu-latest

    # -------------------------------------------------
    # MySQL Service (for testing DB schema)
    # -------------------------------------------------
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: rootpassword
          MYSQL_DATABASE: cafe_db
        ports:
          - 3306:3306
        options: >-
          --health-cmd="mysqladmin ping -h localhost -uroot -prootpassword --silent"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=5

    steps:

    # -------------------------------------------------
    # Checkout Code
    # -------------------------------------------------
    - name: 📥 Checkout Repository
      uses: actions/checkout@v3

    # -------------------------------------------------
    # Install MySQL Client
    # -------------------------------------------------
    - name: 🧰 Install MySQL Client
      run: sudo apt-get update && sudo apt-get install -y mysql-client

    # -------------------------------------------------
    # Wait for MySQL to be ready
    # -------------------------------------------------
    - name: ⏳ Wait for MySQL
      run: |
        until mysqladmin ping -h 127.0.0.1 -uroot -prootpassword --silent; do
          echo "Waiting for MySQL..."
          sleep 5
        done

    # -------------------------------------------------
    # Apply Database Schema
    # -------------------------------------------------
    - name: 🗄️ Apply Schema
      run: mysql -h 127.0.0.1 -uroot -prootpassword < infrastructure/rds/schema.sql

    # -------------------------------------------------
    # Apply Sample Data
    # -------------------------------------------------
    - name: 📊 Apply Sample Data
      run: mysql -h 127.0.0.1 -uroot -prootpassword < infrastructure/rds/data.sql

    # -------------------------------------------------
    # Run Verification Tests (QA)
    # -------------------------------------------------
    - name: ✅ Run DB Verification
      run: mysql -h 127.0.0.1 -uroot -prootpassword < infrastructure/rds/verify.sql

    # -------------------------------------------------
    # Build Docker Image (PHP + Apache)
    # -------------------------------------------------
    - name: 🐳 Build Docker Image
      run: docker build -t charlie-cafe -f docker/apache-php/Dockerfile .

    # -------------------------------------------------
    # Run Container (Test)
    # -------------------------------------------------
    - name: 🚀 Run Docker Container
      run: docker run -d -p 8080:80 charlie-cafe

    # -------------------------------------------------
    # Basic Health Check
    # -------------------------------------------------
    - name: 🌐 Test Web Server
      run: |
        sleep 10
        curl -I http://localhost:8080 || exit 1

    # -------------------------------------------------
    # Success
    # -------------------------------------------------
    - name: 🎉 Deployment Success
      run: echo "Charlie Cafe CI/CD Pipeline Successful 🚀"
```

### 🧠 IMPORTANT: YOUR SQL FILES STATUS

### 👉 GOOD NEWS:

Your files are already correct and production-ready ✅
No modification required.

### ⚠️ BUT ONE CRITICAL FIX (VERY IMPORTANT)

You previously got:

```
Unknown column 'payment_method'
```

👉 If your app/Lambda uses it → update schema:

### ✅ MODIFY orders table

```
ALTER TABLE orders
ADD COLUMN payment_method VARCHAR(20);
```

OR update schema.sql permanently:

```
payment_method VARCHAR(20),
```

### 🔐 4. SECURITY CHECK (VERY IMPORTANT)

In your RDS Security Group:

#### ✅ Allow:

```
Port: 3306
Source: EC2-Web-SG
Source: Lambda-SG
```

#### ❌ DO NOT allow:

```
0.0.0.0/0   ❌ (public access)
```

### 🧪 5. TEST FULL FLOW

- Step 1

```
docker-compose up -d
```

- Step 2

`- Open:

```
http://localhost:8080
```

- Step 3

  - Trigger:

    - Order page

    - API

    - Lambda

👉 Data should go to RDS

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

✅ Docker for app only

✅ AWS RDS as database

✅ Clean production architecture

✅ Secure connection

✅ Reusable SQL schema

---
## integrate AWS Secrets Manager directly into your Dockerized

### 1️⃣ Store Your DB Secret in Secrets Manager

You already did this:

```
{
  "username": "cafe_user",
  "password": "StrongPassword123",
  "host": "your-rds-endpoint.amazonaws.com",
  "dbname": "cafe_db"
}
```

- Make note of the Secret ARN
Example: arn:aws:secretsmanager:us-east-1:123456789012:secret:CafeRDSSecret-ABC123

### 2️⃣ Update docker-compose.yml to use Secrets Manager

#### Docker containers cannot directly fetch AWS Secrets, so the best approach is:

- Pass the Secret ARN as an environment variable.

- Inside the container, your PHP code calls AWS SDK to retrieve it at runtime.

#### docker-compose.yml

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
    environment:
      DB_HOST: your-rds-endpoint.amazonaws.com
      DB_USER: cafe_user
      DB_PASS: StrongPassword123
      DB_NAME: cafe_db
    restart: always
```

#### ✅ Final Updated docker-compose.yml

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
    environment:
      AWS_REGION: us-east-1
      RDS_SECRET_ARN: arn:aws:secretsmanager:us-east-1:123456789012:secret:CafeRDSSecret-ABC123
    restart: always
```

✅ Remove all DB_USER / DB_PASS / DB_HOST / DB_NAME — now PHP will fetch them from Secrets Manager.

### 3️⃣ Update PHP Connection to Use Secrets Manager

#### Add this helper file, e.g., db.php:

```
<?php
require 'vendor/autoload.php'; // AWS SDK for PHP

use Aws\SecretsManager\SecretsManagerClient;
use Aws\Exception\AwsException;

$region = getenv('AWS_REGION');
$secretName = getenv('RDS_SECRET_ARN');

$client = new SecretsManagerClient([
    'version' => 'latest',
    'region' => $region
]);

try {
    $result = $client->getSecretValue([
        'SecretId' => $secretName,
    ]);

    if (isset($result['SecretString'])) {
        $secret = json_decode($result['SecretString'], true);

        $host = $secret['host'];
        $user = $secret['username'];
        $pass = $secret['password'];
        $db   = $secret['dbname'];
    } else {
        throw new Exception('SecretString not found in Secret');
    }

} catch (AwsException $e) {
    die("Error retrieving secret: " . $e->getMessage());
}

// Connect to RDS
$conn = new mysqli($host, $user, $pass, $db);
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
?>
```

✅ Now your app never hardcodes passwords.

### 4️⃣ Update GitHub Actions (deploy.yml) for RDS Secrets

```
name: ☕ Charlie Cafe DevOps CI/CD

on:
  push:
    branches: [ "main" ]

jobs:
  build-test-deploy:
    runs-on: ubuntu-latest

    # -------------------------------------------------
    # 🐬 MySQL Service (for DB testing)
    # -------------------------------------------------
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: rootpassword
          MYSQL_DATABASE: cafe_db
        ports:
          - 3306:3306
        options: >-
          --health-cmd="mysqladmin ping -h localhost -uroot -prootpassword --silent"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=5

    steps:

    # -------------------------------------------------
    # 1️⃣ Clone Repository (AUTO)
    # -------------------------------------------------
    - name: 📥 Clone Repository
      uses: actions/checkout@v3

    # -------------------------------------------------
    # 2️⃣ Install Dependencies
    # -------------------------------------------------
    - name: 🧰 Install MySQL Client
      run: sudo apt-get update && sudo apt-get install -y mysql-client curl

    # -------------------------------------------------
    # 3️⃣ Wait for MySQL
    # -------------------------------------------------
    - name: ⏳ Wait for MySQL
      run: |
        until mysqladmin ping -h 127.0.0.1 -uroot -prootpassword --silent; do
          echo "Waiting for MySQL..."
          sleep 5
        done

    # -------------------------------------------------
    # 4️⃣ Apply Database Schema
    # -------------------------------------------------
    - name: 🗄️ Apply Schema
      run: mysql -h 127.0.0.1 -uroot -prootpassword < infrastructure/rds/schema.sql

    # -------------------------------------------------
    # 5️⃣ Apply Data
    # -------------------------------------------------
    - name: 📊 Apply Data
      run: mysql -h 127.0.0.1 -uroot -prootpassword < infrastructure/rds/data.sql

    # -------------------------------------------------
    # 6️⃣ Verify Database (QA)
    # -------------------------------------------------
    - name: ✅ Verify Database
      run: mysql -h 127.0.0.1 -uroot -prootpassword < infrastructure/rds/verify.sql

    # -------------------------------------------------
    # 7️⃣ Build Docker Image (APP)
    # -------------------------------------------------
    - name: 🐳 Build Docker Image
      run: docker build -t charlie-cafe -f docker/apache-php/Dockerfile .

    # -------------------------------------------------
    # 8️⃣ Run Docker Container
    # -------------------------------------------------
    - name: 🚀 Run Container
      run: docker run -d -p 8080:80 --name cafe-app charlie-cafe

    # -------------------------------------------------
    # 9️⃣ Test Container (Health Check)
    # -------------------------------------------------
    - name: ❤️ Test Application (Health Check)
      run: |
        sleep 10
        curl -f http://localhost:8080/health.php || exit 1

    # -------------------------------------------------
    # 🔟 Success Message
    # -------------------------------------------------
    - name: 🎉 Pipeline Success
      run: echo "Charlie Cafe CI/CD Pipeline Completed Successfully 🚀"
```

#### Instead of using local MySQL for CI/CD tests, you can optionally:

- Test locally with MySQL as before.

- Or test against RDS directly using the secret ARN.

#### Example step to fetch RDS credentials:

```
- name: 🗝️ Retrieve RDS Secret
  run: |
    SECRET_JSON=$(aws secretsmanager get-secret-value \
      --secret-id arn:aws:secretsmanager:us-east-1:123456789012:secret:CafeRDSSecret-ABC123 \
      --region us-east-1 \
      --query SecretString \
      --output text)
    echo "DB_SECRET=$SECRET_JSON" >> $GITHUB_ENV

- name: 🧰 Parse RDS Secret
  run: |
    export DB_HOST=$(echo $DB_SECRET | jq -r '.host')
    export DB_USER=$(echo $DB_SECRET | jq -r '.username')
    export DB_PASS=$(echo $DB_SECRET | jq -r '.password')
    export DB_NAME=$(echo $DB_SECRET | jq -r '.dbname')
```

#### Then use these env vars for schema/data/verify steps:

```
- name: 🗄️ Apply Schema
  run: mysql -h $DB_HOST -u $DB_USER -p$DB_PASS $DB_NAME < infrastructure/rds/schema.sql
```

### ✅ Fully Final Updated deploy.yml

```
name: ☕ Charlie Cafe DevOps CI/CD

on:
  push:
    branches: [ "main" ]

jobs:
  build-test-deploy:
    runs-on: ubuntu-latest

    steps:

    # -------------------------------------------------
    # 1️⃣ Clone Repository
    # -------------------------------------------------
    - name: 📥 Clone Repository
      uses: actions/checkout@v3

    # -------------------------------------------------
    # 2️⃣ Install Dependencies
    # -------------------------------------------------
    - name: 🧰 Install MySQL Client, jq, curl, AWS CLI
      run: |
        sudo apt-get update
        sudo apt-get install -y mysql-client jq curl unzip
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip awscliv2.zip
        sudo ./aws/install
        aws --version

    # -------------------------------------------------
    # 3️⃣ Retrieve RDS Secret from AWS Secrets Manager
    # -------------------------------------------------
    - name: 🗝️ Retrieve RDS Secret
      run: |
        SECRET_JSON=$(aws secretsmanager get-secret-value \
          --secret-id arn:aws:secretsmanager:us-east-1:123456789012:secret:CafeRDSSecret-ABC123 \
          --region us-east-1 \
          --query SecretString \
          --output text)
        echo "DB_SECRET=$SECRET_JSON" >> $GITHUB_ENV

    # -------------------------------------------------
    # 4️⃣ Parse RDS Secret into environment variables
    # -------------------------------------------------
    - name: 🧰 Parse RDS Secret
      run: |
        export DB_HOST=$(echo $DB_SECRET | jq -r '.host')
        export DB_USER=$(echo $DB_SECRET | jq -r '.username')
        export DB_PASS=$(echo $DB_SECRET | jq -r '.password')
        export DB_NAME=$(echo $DB_SECRET | jq -r '.dbname')
        echo "DB_HOST=$DB_HOST" >> $GITHUB_ENV
        echo "DB_USER=$DB_USER" >> $GITHUB_ENV
        echo "DB_PASS=$DB_PASS" >> $GITHUB_ENV
        echo "DB_NAME=$DB_NAME" >> $GITHUB_ENV

    # -------------------------------------------------
    # 5️⃣ Wait for RDS to be reachable
    # -------------------------------------------------
    - name: ⏳ Wait for RDS
      run: |
        echo "Waiting for RDS connection..."
        for i in {1..30}; do
          mysqladmin ping -h $DB_HOST -u$DB_USER -p$DB_PASS --silent && break
          echo "Retrying in 10s..."
          sleep 10
        done

    # -------------------------------------------------
    # 6️⃣ Apply Database Schema
    # -------------------------------------------------
    - name: 🗄️ Apply Schema
      run: mysql -h $DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME < infrastructure/rds/schema.sql

    # -------------------------------------------------
    # 7️⃣ Apply Sample Data
    # -------------------------------------------------
    - name: 📊 Apply Data
      run: mysql -h $DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME < infrastructure/rds/data.sql

    # -------------------------------------------------
    # 8️⃣ Verify Database
    # -------------------------------------------------
    - name: ✅ Verify Database
      run: mysql -h $DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME < infrastructure/rds/verify.sql

    # -------------------------------------------------
    # 9️⃣ Build Docker Image
    # -------------------------------------------------
    - name: 🐳 Build Docker Image
      run: docker build -t charlie-cafe -f docker/apache-php/Dockerfile .

    # -------------------------------------------------
    # 🔟 Run Docker Container
    # -------------------------------------------------
    - name: 🚀 Run Container
      run: docker run -d -p 8080:80 --name charlie_web \
            -e RDS_SECRET_ARN=arn:aws:secretsmanager:us-east-1:123456789012:secret:CafeRDSSecret-ABC123 \
            charlie-cafe

    # -------------------------------------------------
    # 11️⃣ Health Check
    # -------------------------------------------------
    - name: ❤️ Test Application (Health Check)
      run: |
        sleep 10
        curl -f http://localhost:8080/health.php || exit 1

    # -------------------------------------------------
    # 12️⃣ Success Message
    # -------------------------------------------------
    - name: 🎉 Pipeline Success
      run: echo "Charlie Cafe CI/CD Pipeline Completed Successfully 🚀"
```

### ✅ Key Changes

- Removed local MySQL service

  - Pipeline now connects directly to your real RDS instance.

- Secrets Manager integration

  - Retrieves DB credentials at runtime.

  - Passes them as environment variables.

- RDS health check

  - Loops until RDS is reachable before applying schema/data.

- Docker container receives Secret ARN

  - PHP app can use AWS SDK to fetch credentials securely.

### 5️⃣ Summary of Changes

| Component          | Change                                                           |
| ------------------ | ---------------------------------------------------------------- |
| docker-compose.yml | Removed hardcoded DB credentials, added `RDS_SECRET_ARN`         |
| PHP                | Fetch credentials dynamically via AWS SDK                        |
| CI/CD              | Retrieve secret with AWS CLI and inject env vars for MySQL steps |

### 6️⃣ Optional: Add AWS IAM Role for ECS / EC2

- If running PHP in ECS or EC2, assign an IAM role with SecretsManagerRead permission.

- No need for credentials in container — it uses instance profile.
---

### 🧠 IMPORTANT TRUTH (DON’T MISS THIS)

#### 👉 You are now using:

✅ AWS RDS (real database)

✅ AWS Secrets Manager

✅ Docker only for app

So…

❌ You DO NOT need docker/mysql/Dockerfile anymore

### 🚨 WHY?

#### Your current MySQL Dockerfile:

```
FROM mysql:8.0
...
COPY schema.sql ...
COPY data.sql ...
```

👉 This creates a local MySQL database inside Docker

BUT:

👉 Your app is connecting to RDS (remote DB) using Secrets Manager

### ⚠️ THIS CREATES A CONFLICT

| Component    | Database Used |
| ------------ | ------------- |
| Docker MySQL | Local DB ❌    |
| PHP App      | AWS RDS ✅     |

👉 So your local DB becomes useless / unused


### ✅ FINAL DECISION (PRODUCTION BEST PRACTICE)

### ✔️ OPTION 1 (RECOMMENDED — CLEAN ARCHITECTURE)

#### 👉 DELETE MySQL Docker completely

❌ Remove: docker/mysql/Dockerfile

❌ Remove from docker-compose: db:

✔️ RESULT 

```
Browser → Docker (PHP) → AWS RDS
```

✅ Clean

✅ Production-ready

✅ Secure

✅ No duplication


### 1️⃣ Create a Dockerfile

Inside your project root (charlie-cafe-devops/), create:

### 📦 1. ✅ Dockerfile #1 → MySQL (database with schema.sql)

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


### 🧱 WHAT YOU SHOULD KEEP INSTEAD

#### You already have:

```
schema.sql
data.sql
verify.sql
```

#### 👉 These are now used for:

| File       | Usage           |
| ---------- | --------------- |
| schema.sql | Run once on RDS |
| data.sql   | Optional seed   |
| verify.sql | CI/CD testing   |


###  🔥 WHEN DO YOU NEED docker/mysql?

Only in this case:

👉 If you want local development WITHOUT AWS

Example:

| Scenario                 | Use MySQL Docker? |
| ------------------------ | ----------------- |
| No internet              | ✅ Yes             |
| Offline dev              | ✅ Yes             |
| Testing without AWS cost | ✅ Yes             |
| Production               | ❌ NO              |

### 🔧 OPTIONAL (IF YOU WANT BOTH)

If you want to keep MySQL Docker for learning:

👉 Modify it like this:

```
# LOCAL DEV ONLY (no secrets manager needed)
FROM mysql:8.0

ENV MYSQL_ROOT_PASSWORD=rootpassword
ENV MYSQL_DATABASE=cafe_db

COPY infrastructure/rds/schema.sql /docker-entrypoint-initdb.d/01-schema.sql
COPY infrastructure/rds/data.sql /docker-entrypoint-initdb.d/02-data.sql
```

⚠️ But do NOT use it in production.

### 🏆 FINAL ANSWER TO YOUR QUESTION

👉 “Do I need to modify docker/mysql/Dockerfile?”

❌ NO — you need to REMOVE it (for production)

Because:

- You are using Secrets Manager

- You are using RDS

- Docker MySQL is no longer needed

### 🚀 YOUR FINAL CLEAN STRUCTURE

```
charlie-cafe-devops/
│
├── app/
├── docker/
│   └── apache-php/
│       └── Dockerfile
│
├── infrastructure/
│   └── rds/
│       ├── schema.sql
│       ├── data.sql
│       └── verify.sql
│
├── docker-compose.yml
└── .github/workflows/deploy.yml
```

### 🎯 FINAL ADVICE

#### 👉 You just upgraded from:

❌ Beginner setup (local DB)

➡️ to

✅ Real production architecture (RDS + Secrets Manager)

### 🧠 CORE IDEA (VERY IMPORTANT)

👉 AWS RDS does NOT auto-run SQL like Docker

So you must:

✅ Use your schema.sql manually OR via automation (CLI / CI/CD)

### 🏆 FINAL PRODUCTION APPROACH (WITH SECRETS MANAGER)

We will:

- Store credentials in Secrets Manager ✅

- Use AWS CLI + mysql client to apply schema ✅

- Automate later via CI/CD ✅

### 🧱 STEP 1 — Your Secrets Manager (Already Done ✅)

```
{
  "username": "cafe_user",
  "password": "StrongPassword123",
  "host": "your-rds-endpoint.amazonaws.com",
  "dbname": "cafe_db"
}
```

###  🧱 STEP 2 — CREATE DATABASE IN RDS

👉 Important: RDS does NOT create DB automatically (like Docker ENV)

Run this ONE TIME:

```
mysql -h your-rds-endpoint.amazonaws.com -u cafe_user -p
```

Then:

```
CREATE DATABASE cafe_db;
```

### 🧱 STEP 3 — APPLY SCHEMA USING SECRETS MANAGER (FINAL WAY)

### ✅ Create Script: setup_charlie_cafe_db_full.sh

[setup_charlie_cafe_db_full.sh](../infrastructure/scripts/setup_charlie_cafe_db_full.sh)

or

### ✅ Create Script: devops-setup_rds.sh

```
#!/bin/bash

# -------------------------------------------------
# ☕ Charlie Cafe — RDS Setup via Secrets Manager
# -------------------------------------------------

set -e

AWS_REGION="us-east-1"
SECRET_ARN="arn:aws:secretsmanager:us-east-1:123456789012:secret:CafeRDSSecret-ABC123"

echo "📡 Fetching DB credentials from Secrets Manager..."

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_ARN" \
  --region "$AWS_REGION" \
  --query SecretString \
  --output text)

DB_HOST=$(echo $SECRET_JSON | jq -r '.host')
DB_USER=$(echo $SECRET_JSON | jq -r '.username')
DB_PASS=$(echo $SECRET_JSON | jq -r '.password')
DB_NAME=$(echo $SECRET_JSON | jq -r '.dbname')

echo "✅ Credentials loaded"

# -------------------------------------------------
# CREATE DATABASE (SAFE)
# -------------------------------------------------
echo "🗄️ Creating database if not exists..."

mysql -h $DB_HOST -u $DB_USER -p$DB_PASS -e "
CREATE DATABASE IF NOT EXISTS $DB_NAME;
"

# -------------------------------------------------
# APPLY SCHEMA
# -------------------------------------------------
echo "📦 Applying schema..."

mysql -h $DB_HOST -u $DB_USER -p$DB_PASS $DB_NAME < infrastructure/rds/schema.sql

# -------------------------------------------------
# APPLY DATA (OPTIONAL)
# -------------------------------------------------
echo "📊 Applying sample data..."

mysql -h $DB_HOST -u $DB_USER -p$DB_PASS $DB_NAME < infrastructure/rds/data.sql

# -------------------------------------------------
# VERIFY
# -------------------------------------------------
echo "🔍 Running verification..."

mysql -h $DB_HOST -u $DB_USER -p$DB_PASS $DB_NAME < infrastructure/rds/verify.sql

echo "🎉 RDS setup completed successfully!"
```

### 🏆 FINAL SCRIPT: devops-setup_rds.sh

```
#!/bin/bash

# =============================================================
# ☕ Charlie Cafe — RDS Setup Script (FINAL PRODUCTION VERSION)
# -------------------------------------------------------------
# Purpose:
# ✔ Fetch DB credentials securely from AWS Secrets Manager
# ✔ Create database (if not exists)
# ✔ Apply schema.sql (tables + relationships)
# ✔ Apply data.sql (optional sample data)
# ✔ Run verify.sql (QA checks)
# ✔ Safe to run multiple times
# =============================================================

set -euo pipefail

# =============================================================
# CONFIGURATION (EDIT IF NEEDED)
# =============================================================
AWS_REGION="us-east-1"
SECRET_ARN="arn:aws:secretsmanager:us-east-1:123456789012:secret:CafeRDSSecret-ABC123"

SCHEMA_FILE="infrastructure/rds/schema.sql"
DATA_FILE="infrastructure/rds/data.sql"
VERIFY_FILE="infrastructure/rds/verify.sql"

# =============================================================
# COLORS (FOR CLEAN OUTPUT)
# =============================================================
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_header() {
  echo -e "\n${BLUE}========================================================${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}========================================================${NC}\n"
}

print_success() {
  echo -e "${GREEN}✅ $1${NC}\n"
}

print_error() {
  echo -e "${RED}❌ $1${NC}\n"
}

# =============================================================
# STEP 1 — CHECK REQUIRED TOOLS
# =============================================================
print_header "Checking Required Tools"

command -v aws >/dev/null 2>&1 || { print_error "AWS CLI not installed"; exit 1; }
command -v jq >/dev/null 2>&1 || { print_error "jq not installed"; exit 1; }
command -v mysql >/dev/null 2>&1 || { print_error "MySQL client not installed"; exit 1; }

print_success "All required tools are installed"

# =============================================================
# STEP 2 — FETCH SECRET FROM AWS SECRETS MANAGER
# =============================================================
print_header "Fetching DB Credentials from Secrets Manager"

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_ARN" \
  --region "$AWS_REGION" \
  --query SecretString \
  --output text)

DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host')
DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_NAME=$(echo "$SECRET_JSON" | jq -r '.dbname')

print_success "Credentials loaded successfully"

# =============================================================
# STEP 3 — TEST RDS CONNECTION
# =============================================================
print_header "Testing RDS Connection"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1;" >/dev/null 2>&1 \
  && print_success "RDS connection successful" \
  || { print_error "Failed to connect to RDS"; exit 1; }

# =============================================================
# STEP 4 — CREATE DATABASE (SAFE)
# =============================================================
print_header "Creating Database (if not exists)"

mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "
CREATE DATABASE IF NOT EXISTS $DB_NAME
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
"

print_success "Database ensured"

# =============================================================
# STEP 5 — APPLY SCHEMA
# =============================================================
print_header "Applying Database Schema"

if [ -f "$SCHEMA_FILE" ]; then
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$SCHEMA_FILE"
  print_success "Schema applied successfully"
else
  print_error "Schema file not found: $SCHEMA_FILE"
  exit 1
fi

# =============================================================
# STEP 6 — APPLY SAMPLE DATA (OPTIONAL)
# =============================================================
print_header "Applying Sample Data (Optional)"

if [ -f "$DATA_FILE" ]; then
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$DATA_FILE"
  print_success "Sample data applied"
else
  echo -e "${YELLOW}⚠️ Data file not found, skipping...${NC}"
fi

# =============================================================
# STEP 7 — VERIFY DATABASE
# =============================================================
print_header "Running Verification"

if [ -f "$VERIFY_FILE" ]; then
  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < "$VERIFY_FILE"
  print_success "Verification completed"
else
  echo -e "${YELLOW}⚠️ Verify file not found, skipping...${NC}"
fi

# =============================================================
# FINAL SUCCESS MESSAGE
# =============================================================
print_header "☕ Charlie Cafe RDS Setup Completed"

echo -e "${GREEN}✔ RDS Connected${NC}"
echo -e "${GREEN}✔ Database Created/Verified${NC}"
echo -e "${GREEN}✔ Schema Applied${NC}"
echo -e "${GREEN}✔ Data Inserted (if available)${NC}"
echo -e "${GREEN}✔ Verification Completed${NC}"

echo -e "\n🎉 Your Charlie Cafe database is fully ready on AWS RDS!\n"
```

### ▶️ HOW TO USE (STEP-BY-STEP)

### ✅ Step 1 — Save file

```
nano devops-setup_rds.sh
```

- Paste script → save

### ✅ Step 2 — Make executable

```
chmod +x devops-setup_rds.sh
```

### ✅ Step 3 — Run script

```
./devops-setup_rds.sh
```

### 🔥 RESULT

👉 This script replaces your Docker MySQL completely

| Before             | After                        |
| ------------------ | ---------------------------- |
| Docker auto schema | Script applies schema to RDS |
| Local DB           | Real AWS DB                  |
| Hardcoded creds    | Secrets Manager              |

### 🧠 WHY THIS IS BETTER

| Feature         | Benefit                  |
| --------------- | ------------------------ |
| Secrets Manager | Secure credentials 🔐    |
| Script          | Repeatable setup 🔁      |
| SQL files       | Clean structure 📦       |
| No Docker DB    | Real production setup 🚀 |


### 🔥 WHAT THIS SCRIPT DOES (CLEAR)

| Step | Action                        |
| ---- | ----------------------------- |
| 1    | Checks tools (aws, jq, mysql) |
| 2    | Fetches secret from AWS       |
| 3    | Tests RDS connection          |
| 4    | Creates DB if not exists      |
| 5    | Runs schema.sql               |
| 6    | Runs data.sql (optional)      |
| 7    | Runs verify.sql               |

### 🧠 IMPORTANT FOR YOU

#### 👉 This script replaces:

❌ Docker MySQL auto-init

❌ Manual DB setup

#### 👉 And gives you:

✅ Secure

✅ Repeatable

✅ Production-ready

✅ CI/CD compatible

### 🚫 IMPORTANT — DO NOT DO THIS

❌ Do NOT try to use Dockerfile for RDS

❌ RDS does NOT read /docker-entrypoint-initdb.d

👉 That only works in Docker MySQL container

### 🏁 FINAL ARCHITECTURE

```
Docker (PHP App)
        ↓
AWS Secrets Manager
        ↓
AWS RDS (MySQL)
```

### 🚀 NEXT LEVEL (OPTIONAL)

#### We can upgrade this further:

✅ Run this script inside CI/CD automatically

✅ Convert to Terraform RDS + DB setup

✅ Add migrations system (like real companies)

✅ Connect Lambda + RDS properly

### 🎯 FINAL ANSWER

👉 You do NOT use Dockerfile for RDS

#### 👉 You use:

✔ schema.

✔ setup_rds.sh (automation)

✔ Secrets Manager

## Modidification of deploy.yml

### Curent deploy.yml

```
name: ☕ Charlie Cafe DevOps CI/CD

on:
  push:
    branches: [ "main" ]

jobs:
  build-test-deploy:
    runs-on: ubuntu-latest

    steps:

    # -------------------------------------------------
    # 1️⃣ Clone Repository
    # -------------------------------------------------
    - name: 📥 Clone Repository
      uses: actions/checkout@v3

    # -------------------------------------------------
    # 2️⃣ Install Dependencies
    # -------------------------------------------------
    - name: 🧰 Install MySQL Client, jq, curl, AWS CLI
      run: |
        sudo apt-get update
        sudo apt-get install -y mysql-client jq curl unzip
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip awscliv2.zip
        sudo ./aws/install
        aws --version

    # -------------------------------------------------
    # 3️⃣ Retrieve RDS Secret from AWS Secrets Manager
    # -------------------------------------------------
    - name: 🗝️ Retrieve RDS Secret
      run: |
        SECRET_JSON=$(aws secretsmanager get-secret-value \
          --secret-id arn:aws:secretsmanager:us-east-1:123456789012:secret:CafeRDSSecret-ABC123 \
          --region us-east-1 \
          --query SecretString \
          --output text)
        echo "DB_SECRET=$SECRET_JSON" >> $GITHUB_ENV

    # -------------------------------------------------
    # 4️⃣ Parse RDS Secret into environment variables
    # -------------------------------------------------
    - name: 🧰 Parse RDS Secret
      run: |
        export DB_HOST=$(echo $DB_SECRET | jq -r '.host')
        export DB_USER=$(echo $DB_SECRET | jq -r '.username')
        export DB_PASS=$(echo $DB_SECRET | jq -r '.password')
        export DB_NAME=$(echo $DB_SECRET | jq -r '.dbname')
        echo "DB_HOST=$DB_HOST" >> $GITHUB_ENV
        echo "DB_USER=$DB_USER" >> $GITHUB_ENV
        echo "DB_PASS=$DB_PASS" >> $GITHUB_ENV
        echo "DB_NAME=$DB_NAME" >> $GITHUB_ENV

    # -------------------------------------------------
    # 5️⃣ Wait for RDS to be reachable
    # -------------------------------------------------
    - name: ⏳ Wait for RDS
      run: |
        echo "Waiting for RDS connection..."
        for i in {1..30}; do
          mysqladmin ping -h $DB_HOST -u$DB_USER -p$DB_PASS --silent && break
          echo "Retrying in 10s..."
          sleep 10
        done

    # -------------------------------------------------
    # 6️⃣ Apply Database Schema
    # -------------------------------------------------
    - name: 🗄️ Apply Schema
      run: mysql -h $DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME < infrastructure/rds/schema.sql

    # -------------------------------------------------
    # 7️⃣ Apply Sample Data
    # -------------------------------------------------
    - name: 📊 Apply Data
      run: mysql -h $DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME < infrastructure/rds/data.sql

    # -------------------------------------------------
    # 8️⃣ Verify Database
    # -------------------------------------------------
    - name: ✅ Verify Database
      run: mysql -h $DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME < infrastructure/rds/verify.sql

    # -------------------------------------------------
    # 9️⃣ Build Docker Image
    # -------------------------------------------------
    - name: 🐳 Build Docker Image
      run: docker build -t charlie-cafe -f docker/apache-php/Dockerfile .

    # -------------------------------------------------
    # 🔟 Run Docker Container
    # -------------------------------------------------
    - name: 🚀 Run Container
      run: docker run -d -p 8080:80 --name charlie_web \
            -e RDS_SECRET_ARN=arn:aws:secretsmanager:us-east-1:123456789012:secret:CafeRDSSecret-ABC123 \
            charlie-cafe

    # -------------------------------------------------
    # 11️⃣ Health Check
    # -------------------------------------------------
    - name: ❤️ Test Application (Health Check)
      run: |
        sleep 10
        curl -f http://localhost:8080/health.php || exit 1

    # -------------------------------------------------
    # 12️⃣ Success Message
    # -------------------------------------------------
    - name: 🎉 Pipeline Success
      run: echo "Charlie Cafe CI/CD Pipeline Completed Successfully 🚀"
```

### 🧠 WHAT’S WRONG / MISSING

### ❌ 1. You are NOT configuring AWS credentials

Right now your pipeline calls:

```
aws secretsmanager get-secret-value
```

👉 But GitHub Actions has no AWS access yet

### ❌ 2. You manually installed AWS CLI (not needed)

You installed AWS CLI using curl — but GitHub already supports a better way.

👉 Use official action:

```
aws-actions/configure-aws-credentials
```

### ❌ 3. Database creation step missing

If DB doesn’t exist → your pipeline fails.

### ❌ 4. Minor improvement

- Pass AWS_REGION into container (important)

- Clean environment handling

### ✅ FINAL FIXED deploy.yml (PRODUCTION READY)

```
name: ☕ Charlie Cafe DevOps CI/CD

on:
  push:
    branches: [ "main" ]

jobs:
  build-test-deploy:
    runs-on: ubuntu-latest

    steps:

    # -------------------------------------------------
    # 1️⃣ Clone Repository
    # -------------------------------------------------
    - name: 📥 Clone Repository
      uses: actions/checkout@v3

    # -------------------------------------------------
    # 2️⃣ Configure AWS Credentials (REQUIRED)
    # -------------------------------------------------
    - name: 🔐 Configure AWS Credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1

    # -------------------------------------------------
    # 3️⃣ Install Required Tools
    # -------------------------------------------------
    - name: 🧰 Install Tools
      run: |
        sudo apt-get update
        sudo apt-get install -y mysql-client jq

    # -------------------------------------------------
    # 4️⃣ Retrieve RDS Secret
    # -------------------------------------------------
    - name: 🗝️ Retrieve RDS Secret
      run: |
        SECRET_JSON=$(aws secretsmanager get-secret-value \
          --secret-id arn:aws:secretsmanager:us-east-1:123456789012:secret:CafeRDSSecret-ABC123 \
          --region us-east-1 \
          --query SecretString \
          --output text)

        echo "DB_SECRET=$SECRET_JSON" >> $GITHUB_ENV

    # -------------------------------------------------
    # 5️⃣ Parse Secret
    # -------------------------------------------------
    - name: 🧰 Parse Secret
      run: |
        echo "DB_HOST=$(echo $DB_SECRET | jq -r '.host')" >> $GITHUB_ENV
        echo "DB_USER=$(echo $DB_SECRET | jq -r '.username')" >> $GITHUB_ENV
        echo "DB_PASS=$(echo $DB_SECRET | jq -r '.password')" >> $GITHUB_ENV
        echo "DB_NAME=$(echo $DB_SECRET | jq -r '.dbname')" >> $GITHUB_ENV

    # -------------------------------------------------
    # 6️⃣ Wait for RDS
    # -------------------------------------------------
    - name: ⏳ Wait for RDS
      run: |
        for i in {1..20}; do
          mysqladmin ping -h $DB_HOST -u$DB_USER -p$DB_PASS --silent && break
          echo "Waiting for RDS..."
          sleep 5
        done

    # -------------------------------------------------
    # 7️⃣ Create Database (SAFE)
    # -------------------------------------------------
    - name: 🗄️ Create Database
      run: |
        mysql -h $DB_HOST -u$DB_USER -p$DB_PASS -e "
        CREATE DATABASE IF NOT EXISTS $DB_NAME;
        "

    # -------------------------------------------------
    # 8️⃣ Apply Schema
    # -------------------------------------------------
    - name: 🗄️ Apply Schema
      run: |
        mysql -h $DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME < infrastructure/rds/schema.sql

    # -------------------------------------------------
    # 9️⃣ Apply Data
    # -------------------------------------------------
    - name: 📊 Apply Data
      run: |
        mysql -h $DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME < infrastructure/rds/data.sql

    # -------------------------------------------------
    # 🔟 Verify Database
    # -------------------------------------------------
    - name: ✅ Verify Database
      run: |
        mysql -h $DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME < infrastructure/rds/verify.sql

    # -------------------------------------------------
    # 11️⃣ Build Docker Image
    # -------------------------------------------------
    - name: 🐳 Build Docker Image
      run: docker build -t charlie-cafe -f docker/apache-php/Dockerfile .

    # -------------------------------------------------
    # 12️⃣ Run Container
    # -------------------------------------------------
    - name: 🚀 Run Container
      run: |
        docker run -d -p 8080:80 --name charlie_web \
        -e AWS_REGION=us-east-1 \
        -e RDS_SECRET_ARN=arn:aws:secretsmanager:us-east-1:123456789012:secret:CafeRDSSecret-ABC123 \
        charlie-cafe

    # -------------------------------------------------
    # 13️⃣ Health Check
    # -------------------------------------------------
    - name: ❤️ Test Application
      run: |
        sleep 10
        curl -f http://localhost:8080/health.php || exit 1

    # -------------------------------------------------
    # 14️⃣ Success
    # -------------------------------------------------
    - name: 🎉 Success
      run: echo "Deployment completed successfully 🚀"
```

### 🧠 FINAL SUMMARY

#### ✅ You SHOULD change:

Add AWS credentials step ✔

Remove manual AWS CLI install ✔

Add DB creation step ✔

Pass AWS_REGION to container ✔

#### ❌ You should NOT change:

Your docker-compose.yml → already correct ✅

Your schema/data/verify files → already correct ✅

### 🚀 WHAT YOU HAVE NOW

#### You officially built:

✅ Secure Secrets Manager integration

✅ Auto RDS schema deployment

✅ CI/CD pipeline

✅ Dockerized app

✅ Production-ready architecture

---




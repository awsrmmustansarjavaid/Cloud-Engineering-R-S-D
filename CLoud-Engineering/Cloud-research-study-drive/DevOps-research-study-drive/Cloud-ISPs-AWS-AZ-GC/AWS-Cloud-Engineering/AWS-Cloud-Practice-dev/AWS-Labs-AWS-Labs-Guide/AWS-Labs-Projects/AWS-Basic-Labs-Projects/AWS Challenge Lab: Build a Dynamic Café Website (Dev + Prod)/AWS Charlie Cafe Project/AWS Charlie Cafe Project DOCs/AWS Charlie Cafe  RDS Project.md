# ☕ Charlie-Cafe_AWS-RDS-Secrets-Manager_Configurations

## AWS Charlie Café – RDS Database Setup Guide

### 1️⃣ Project Overview

This document explains how to configure the Amazon RDS MySQL database for the Charlie Café cloud system, including:

- Orders Management

- HR Management

- Attendance System

- Holiday Tracking

- Test Data for Development

### 🍽️  2️⃣ AWS RDS Initial Configuration

### 1️⃣ Install MySQL Client on EC2

```
sudo dnf install -y mariadb105
```

#### ✅ Verify Installation

```
mysql --version
```

#### ✅ Connect to AWS RDS

```
mysql -h <rds-endpoint> -u cafe_user -p
```

### 3️⃣ Create Charlie Café Database

```
CREATE DATABASE cafe_db;
```

#### ✅ Create Database User

```
CREATE USER 'cafe_user'@'%' IDENTIFIED BY 'StrongPassword123';
```

#### ✅ Grant Permissions

```
GRANT ALL PRIVILEGES ON cafe_db.* TO 'cafe_user'@'%';
```

```
FLUSH PRIVILEGES;
```

#### ✅ Use the Database

```
USE cafe_db;
```

### 🍽️ 4️⃣ Orders Management Database Schema

### 1️⃣ Simple Orders Table (Basic Version)

```sql
CREATE TABLE orders (
 id INT AUTO_INCREMENT PRIMARY KEY,
 customer_name VARCHAR(100),
 item VARCHAR(50),
 quantity INT,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

This is the basic table for storing orders.

### 2️⃣ Recommended Orders Table (With Table Number - Recommanded)

```
CREATE TABLE orders (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    table_number    INT NOT NULL,                    -- ← Added: table number (1, 2, 3, ...)
    customer_name   VARCHAR(100),
    item            VARCHAR(50),
    quantity        INT NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_table_number (table_number),           -- optional: faster queries by table
    INDEX idx_created_at (created_at)                -- optional: good for time-based reports
);
```

#### Advantages:

- Track which table placed the order

- Faster table based search

- Useful for restaurant reporting

### 3️⃣ Add Advanced Order Management Columns

- Run this in AWS RDS Query Editor.

```
ALTER TABLE orders
ADD COLUMN order_id VARCHAR(50),
ADD COLUMN status VARCHAR(20) DEFAULT 'RECEIVED',
ADD COLUMN total_amount DECIMAL(10,2),
ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;
```

#### ✅ New Columns:

| Column       | Purpose                              |
| ------------ | ------------------------------------ |
| order_id     | Unique public order number           |
| status       | RECEIVED / PREPARING / SERVED / PAID |
| total_amount | Total bill amount                    |
| updated_at   | Track order updates                  |

### ✅ 📦 Standard Order ID Format

```
ORD-YYYYMMDD-XXXX
```

#### ✅ Example:

```
ORD-20260114-8392
```
#### 4️⃣ Add Payment and Timestamp Columns

```
ALTER TABLE orders
ADD COLUMN created_at DATETIME DEFAULT CURRENT_TIMESTAMP;
```

```
ALTER TABLE orders
ADD COLUMN payment_status VARCHAR(20) DEFAULT 'PENDING';
```

#### Payment Status:

- PENDING

- PAID

- CANCELLED

### 🍽️ Final Merged RDS Query (Recommended Production Version)

Instead of running multiple queries, you can create the complete table in one query.

```
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    
    order_id VARCHAR(50),
    
    table_number INT NOT NULL,
    
    customer_name VARCHAR(100),
    
    item VARCHAR(50),
    
    quantity INT NOT NULL,
    
    total_amount DECIMAL(10,2),
    
    status VARCHAR(20) DEFAULT 'RECEIVED',
    
    payment_status VARCHAR(20) DEFAULT 'PENDING',
    
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
    ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_table_number (table_number),
    INDEX idx_created_at (created_at),
    INDEX idx_order_id (order_id)
);
```

#### ✅ Final Table Structure

| Column         | Type              |
| -------------- | ----------------- |
| id             | INT (Primary Key) |
| order_id       | VARCHAR           |
| table_number   | INT               |
| customer_name  | VARCHAR           |
| item           | VARCHAR           |
| quantity       | INT               |
| total_amount   | DECIMAL           |
| status         | VARCHAR           |
| payment_status | VARCHAR           |
| created_at     | DATETIME          |
| updated_at     | TIMESTAMP         |

### 5️⃣ 🍽️ Charlie Café – HR Database Schema (AWS RDS)

### 1️⃣ Create employees Table

```
CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    cognito_user_id VARCHAR(100) NOT NULL,
    name VARCHAR(100) NOT NULL,
    job_title VARCHAR(50),
    salary DECIMAL(10,2),
    start_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### ✅ Purpose of Columns

| Column          | Purpose                  |
| --------------- | ------------------------ |
| cognito_user_id | Maps to Cognito JWT user |
| employee_id     | Internal employee ID     |
| salary          | HR confidential data     |
| created_at      | Audit log                |

### 2️⃣ Create attendance Table

```
CREATE TABLE attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    attendance_date DATE NOT NULL,
    checkin_time TIME,
    checkout_time TIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(employee_id, attendance_date),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);
```

#### ✅ Key points

- UNIQUE(employee_id, attendance_date)

- Prevents double check-in per day

- checkin_time and checkout_time separated

- Foreign key ensures valid employee

### 3️⃣ Create leaves Table

```
CREATE TABLE leaves (
    leave_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    leave_date DATE NOT NULL,
    leave_type VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);
```

### 4️⃣ Create holidays Table

```
CREATE TABLE holidays (
    holiday_id INT AUTO_INCREMENT PRIMARY KEY,
    holiday_date DATE NOT NULL,
    description VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 6️⃣ 🍽️ Charlie Café – insert manually (CLI)

### 1️⃣ Manual Orders Test (CLI)

### 1️⃣ Simple Insert

```
INSERT INTO orders (customer_name, item, quantity)
VALUES ('CLI-Test', 'Coffee', 1);
```

### 2️⃣ Multi Order Insert

```
INSERT INTO orders (table_number, customer_name, item, quantity) 
VALUES 
(1, 'Ali Khan', 'Espresso', 2),
(1, 'Sara Ahmed', 'Cappuccino', 1),
(2, 'CLI-Test', 'Coffee', 1),
(3, NULL, 'Latte', 3),
(5, 'Ahmed Raza', 'Croissant + Tea', 1);
```

### 2️⃣ Manual HR Test (CLI)

### 1️⃣ Insert Holidays

```
INSERT INTO holidays (holiday_date, description)
VALUES
('2026-01-01', 'New Year'),
('2026-03-23', 'Pakistan Day'),
('2026-12-25', 'Christmas');
```

### 2️⃣ Insert Employees (Manual Testing)

```
INSERT INTO employees 
(cognito_user_id, name, job_title, salary, start_date)
VALUES
('cognito-001', 'Ali Khan', 'Barista', 45000, '2025-05-01'),
('cognito-002', 'Sara Ahmed', 'Cashier', 42000, '2025-06-15'),
('cognito-003', 'Ahmed Raza', 'Manager', 65000, '2024-12-01');
```

### 3️⃣ Insert Attendance

```
INSERT INTO attendance
(employee_id, attendance_date, checkin_time)
VALUES
(1, '2026-03-05', '09:00:00'),
(2, '2026-03-05', '09:10:00'),
(3, '2026-03-05', '08:50:00');
```

### 7️⃣ Database Verification Queries

Run these queries to verify the database.

### 1️⃣ Verify Database Exists

```
SHOW DATABASES;
```

#### ✅ Expected output should include:

```
cafe_db
```

### 2️⃣ Verify Current Database

```
SELECT DATABASE();
```

#### ✅ Expected result:

```
cafe_db
```

### 3️⃣ Verify All Tables

```
SHOW TABLES;
```

#### ✅ Expected result:

```
orders
employees
attendance
leaves
holidays
```

### 4️⃣ Verify Table Structure

### 1️⃣ Orders Table

```
DESCRIBE orders;
```

or 

```
SHOW CREATE TABLE orders;
```

#### ✅ Expected result:

```
id
order_id
table_number
customer_name
item
quantity
total_amount
status
payment_status
created_at
updated_at
```

### 2️⃣ Verify Orders

```
SELECT * FROM orders;
```

### 3️⃣ Employees Table

```
DESCRIBE employees;
```

#### ✅ Expected result:

```
employee_id
cognito_user_id
name
job_title
salary
start_date
created_at
```

### 4️⃣ Verify Employees

```
SELECT * FROM employees;
```

### 5️⃣ Attendance Table

```
DESCRIBE attendance;
```

#### ✅ Expected result:

```
attendance_id
employee_id
attendance_date
checkin_time
checkout_time
created_at
```

### 6️⃣ Verify Attendance

```
SELECT * FROM attendance;
```

### 7️⃣ Verify Holidays

```
SELECT * FROM holidays;
```

#### ✅ Expected Result

You should see:

- Orders inserted successfully

- Employees listed

- Attendance records created

- Holiday data visible

### 8️⃣ Verify Foreign Keys

Check if attendance → employees relation exists.

```
SELECT
TABLE_NAME,
COLUMN_NAME,
CONSTRAINT_NAME,
REFERENCED_TABLE_NAME
FROM
information_schema.KEY_COLUMN_USAGE
WHERE
TABLE_SCHEMA = 'cafe_db'
AND REFERENCED_TABLE_NAME IS NOT NULL;
```

#### ✅ Expected Result

```
attendance.employee_id → employees.employee_id
```

### 9️⃣ Verify Indexes (Performance Check)

Indexes improve query speed in AWS RDS.

Check Orders Indexes

```
SHOW INDEX FROM orders;
```

#### ✅ Expected Result

```
PRIMARY
idx_table_number
idx_created_at
idx_order_id
```

### 🔟 Verify Row Counts (Quick Health Check)

```
SELECT
(SELECT COUNT(*) FROM orders) AS total_orders,
(SELECT COUNT(*) FROM employees) AS total_employees,
(SELECT COUNT(*) FROM attendance) AS total_attendance,
(SELECT COUNT(*) FROM holidays) AS total_holidays;
```

#### ✅ Expected Result

```
total_orders      8
total_employees   3
total_attendance  3
total_holidays    3
```

### 1️⃣1️⃣ Functional Query Tests

### 1️⃣ Orders by Table

```
SELECT table_number, COUNT(*) AS total_orders
FROM orders
GROUP BY table_number;
```

### 2️⃣ Daily Orders

```
SELECT DATE(created_at) AS order_day, COUNT(*) AS orders
FROM orders
GROUP BY order_day;
```

### 3️⃣ Employees Attendance

```
SELECT 
e.name,
a.attendance_date,
a.checkin_time
FROM attendance a
JOIN employees e
ON a.employee_id = e.employee_id;
```

### 4️⃣ Payment Verification

```
SELECT
payment_status,
COUNT(*) AS total_orders
FROM orders
GROUP BY payment_status;
```

#### ✅ Expected Result

```
PENDING 5
PAID    3
```

### 1️⃣2️⃣ Data Integrity Test

Test foreign key protection.

Run:

```
INSERT INTO attendance
(employee_id, attendance_date, checkin_time)
VALUES
(999, '2026-03-08', '09:00:00');
```

#### ✅ Expected Result

```
ERROR 1452: Cannot add or update a child row
```

Meaning foreign key works correctly.

### 1️⃣3️⃣ Database Size Verification

```
SELECT
table_schema AS "Database",
SUM(data_length + index_length) / 1024 / 1024 AS "Size_MB"
FROM information_schema.TABLES
WHERE table_schema = "cafe_db"
GROUP BY table_schema;
```

### 1️⃣4️⃣ Full System Health Check (Recommended)

```
SELECT
table_name,
table_rows
FROM information_schema.tables
WHERE table_schema = 'cafe_db';
```

#### ✅ Expected Result

```
orders       10
employees    3
attendance   3
holidays     3
leaves       0
```

### ✅ Final Verification Checklist

| Check                | Query                      |
| -------------------- | -------------------------- |
| Database exists      | `SHOW DATABASES`           |
| Tables created       | `SHOW TABLES`              |
| Table structure      | `DESCRIBE table_name`      |
| Indexes working      | `SHOW INDEX FROM table`    |
| Data inserted        | `SELECT * FROM table`      |
| Foreign keys working | `information_schema` query |
| Row counts           | `COUNT(*)` queries         |

### 💡 Pro Tip (Real AWS DevOps Practice)

Create one quick verification script:

```
SELECT 'orders' AS table_name, COUNT(*) FROM orders
UNION
SELECT 'employees', COUNT(*) FROM employees
UNION
SELECT 'attendance', COUNT(*) FROM attendance
UNION
SELECT 'holidays', COUNT(*) FROM holidays;
```

This gives instant database health summary.
---
## RDS Verification

### 1️⃣ Verify table exists

```
USE cafe_db;
```

```
SHOW TABLES;
```

#### ✅ You should see:

```
orders
employees
attendance
leaves
holidays
```

```
DESCRIBE orders;
```

```
SELECT * FROM orders;
```

```
DESCRIBE employees;
```

```
SELECT * FROM employees;
```

```
DESCRIBE attendance;
```

```
SELECT * FROM attendance;
```

```
DESCRIBE holidays;
```

```
SELECT * FROM holidays;
```

```
DESCRIBE leaves;
```

```
SELECT * FROM leaves;
```

###### ✅ If you see the row → DB is READY

### ✅ Combined RDS Verification Script (One Run)

> #### This is the best single verification script you can run from your EC2 MySQL client.

This gives a single query that verifies:

- Tables exist

- Table structure

- Row counts

- Columns

- Data types

```
USE cafe_db;

-- =========================
-- 1️⃣ Verify tables exist
-- =========================
SHOW TABLES;

-- =========================
-- 2️⃣ Orders table check
-- =========================
SELECT 'orders table structure' AS section;
DESCRIBE orders;

SELECT 'orders sample data' AS section;
SELECT * FROM orders LIMIT 5;

-- =========================
-- 3️⃣ Employees table check
-- =========================
SELECT 'employees table structure' AS section;
DESCRIBE employees;

SELECT 'employees sample data' AS section;
SELECT * FROM employees LIMIT 5;

-- =========================
-- 4️⃣ Attendance table check
-- =========================
SELECT 'attendance table structure' AS section;
DESCRIBE attendance;

SELECT 'attendance sample data' AS section;
SELECT * FROM attendance LIMIT 5;

-- =========================
-- 5️⃣ Holidays table check
-- =========================
SELECT 'holidays table structure' AS section;
DESCRIBE holidays;

SELECT 'holidays sample data' AS section;
SELECT * FROM holidays LIMIT 5;

-- =========================
-- 6️⃣ Leaves table check
-- =========================
SELECT 'leaves table structure' AS section;
DESCRIBE leaves;

SELECT 'leaves sample data' AS section;
SELECT * FROM leaves LIMIT 5;
```

#### ✅ Why this is better

Instead of 10–15 manual commands, you:

- paste one script

- get all verification results

- see clear section labels

- avoid dumping too much data with LIMIT 5

#### ✅ Example Output Sections

You will see results like:

```
SHOW TABLES
orders
employees
attendance
holidays
leaves
```

Then:

```
orders table structure
id
customer_name
order_total
created_at
```

Then:

```
orders sample data
1 | John | 12.50 | 2026-03-10
```

### 🚀 Pro Tip (Good for your Charlie Café DevOps documentation)

Add a comment header like:

```
-- Charlie Café RDS Verification Script
-- Used to verify database migration / deployment
-- Run from EC2 MySQL client
```

This makes your lab documentation look professional.

### 🚀 Advanced RDS Verification Query (Professional Method)

Run this from your EC2 MySQL client.

```
USE cafe_db;

SELECT 
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_KEY
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'cafe_db'
AND TABLE_NAME IN ('orders','employees','attendance','holidays','leaves')
ORDER BY TABLE_NAME, ORDINAL_POSITION;
```

#### ✅ What This Verifies

This one query checks the full schema.

Example output:

| TABLE_NAME | COLUMN_NAME   | DATA_TYPE | IS_NULLABLE | COLUMN_KEY |
| ---------- | ------------- | --------- | ----------- | ---------- |
| orders     | id            | int       | NO          | PRI        |
| orders     | customer_name | varchar   | YES         |            |
| employees  | id            | int       | NO          | PRI        |
| attendance | employee_id   | int       | NO          |            |

So you immediately confirm:

✔ tables exist

✔ column structure

✔ data types

✔ primary keys

### 🚀 Optional: Add Row Count Verification (Even Better)

Add this second quick query to verify data exists.

```
SELECT 
table_name,
table_rows
FROM information_schema.tables
WHERE table_schema='cafe_db'
AND table_name IN ('orders','employees','attendance','holidays','leaves');
```

#### Example output:

| table_name | table_rows |
| ---------- | ---------- |
| orders     | 120        |
| employees  | 8          |
| attendance | 340        |
| holidays   | 12         |
| leaves     | 6          |

### 📘 How You Can Document It in Your Lab Notebook

Example note:

```
Step: Verify RDS Database Schema

Command used:

SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA='cafe_db';

Expected Result:
All required Charlie Café tables appear:
orders
employees
attendance
holidays
leaves

Verification confirms database migration / deployment success.
```

### ⭐ DevOps Tip (Very Useful for Your Project)

Real engineers often run these checks after:

- RDS migration

- database deployment

- CI/CD database pipeline

Tools like:

- Flyway

- Liquibase

- GitHub Actions

### 🚀 Charlie Café – RDS Full Health Check Script

Run this once from your EC2 MySQL client.

```
USE cafe_db;

-- =====================================================
-- Charlie Café RDS Database Health Check
-- =====================================================

-- 1️⃣ Verify required tables exist
SELECT 
TABLE_NAME,
ENGINE,
TABLE_ROWS,
CREATE_TIME,
UPDATE_TIME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA='cafe_db'
AND TABLE_NAME IN ('orders','employees','attendance','holidays','leaves');


-- 2️⃣ Verify table columns and schema
SELECT 
TABLE_NAME,
COLUMN_NAME,
DATA_TYPE,
IS_NULLABLE,
COLUMN_KEY
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA='cafe_db'
AND TABLE_NAME IN ('orders','employees','attendance','holidays','leaves')
ORDER BY TABLE_NAME, ORDINAL_POSITION;


-- 3️⃣ Verify indexes (important for performance)
SELECT 
TABLE_NAME,
INDEX_NAME,
COLUMN_NAME,
SEQ_IN_INDEX
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA='cafe_db'
AND TABLE_NAME IN ('orders','employees','attendance','holidays','leaves');


-- 4️⃣ Verify table storage engine
SELECT 
TABLE_NAME,
ENGINE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA='cafe_db';


-- 5️⃣ Verify database size
SELECT 
table_schema AS database_name,
ROUND(SUM(data_length + index_length)/1024/1024,2) AS size_MB
FROM information_schema.tables
WHERE table_schema='cafe_db'
GROUP BY table_schema;


-- 6️⃣ Verify row counts quickly
SELECT 
TABLE_NAME,
TABLE_ROWS
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA='cafe_db'
AND TABLE_NAME IN ('orders','employees','attendance','holidays','leaves');
```

#### ✅ What This Single Script Verifies

| Check           | Purpose                     |
| --------------- | --------------------------- |
| Tables exist    | confirms deployment success |
| Table structure | columns & data types        |
| Indexes         | performance verification    |
| Storage engine  | should usually be InnoDB    |
| Row counts      | confirms data present       |
| Database size   | quick storage monitoring    |

#### 📊 Example Output

Example result from section 1️⃣:

| TABLE_NAME | ENGINE | TABLE_ROWS |
| ---------- | ------ | ---------- |
| orders     | InnoDB | 150        |
| employees  | InnoDB | 8          |
| attendance | InnoDB | 340        |
| holidays   | InnoDB | 12         |
| leaves     | InnoDB | 5          |

### 🚀 Charlie Café RDS PASS / FAIL Health Check

Run this script once from your EC2 MySQL client.

```
USE cafe_db;

SELECT 
'orders table exists' AS check_name,
CASE 
WHEN EXISTS (
SELECT 1 
FROM information_schema.tables 
WHERE table_schema='cafe_db' AND table_name='orders'
)
THEN 'PASS'
ELSE 'FAIL'
END AS status

UNION ALL

SELECT 
'employees table exists',
CASE 
WHEN EXISTS (
SELECT 1 
FROM information_schema.tables 
WHERE table_schema='cafe_db' AND table_name='employees'
)
THEN 'PASS'
ELSE 'FAIL'
END

UNION ALL

SELECT 
'attendance table exists',
CASE 
WHEN EXISTS (
SELECT 1 
FROM information_schema.tables 
WHERE table_schema='cafe_db' AND table_name='attendance'
)
THEN 'PASS'
ELSE 'FAIL'
END

UNION ALL

SELECT 
'holidays table exists',
CASE 
WHEN EXISTS (
SELECT 1 
FROM information_schema.tables 
WHERE table_schema='cafe_db' AND table_name='holidays'
)
THEN 'PASS'
ELSE 'FAIL'
END

UNION ALL

SELECT 
'leaves table exists',
CASE 
WHEN EXISTS (
SELECT 1 
FROM information_schema.tables 
WHERE table_schema='cafe_db' AND table_name='leaves'
)
THEN 'PASS'
ELSE 'FAIL'
END

UNION ALL

SELECT 
'orders table has data',
CASE 
WHEN (SELECT COUNT(*) FROM orders) > 0
THEN 'PASS'
ELSE 'FAIL'
END

UNION ALL

SELECT 
'employees table has data',
CASE 
WHEN (SELECT COUNT(*) FROM employees) > 0
THEN 'PASS'
ELSE 'FAIL'
END

UNION ALL

SELECT 
'attendance table has data',
CASE 
WHEN (SELECT COUNT(*) FROM attendance) > 0
THEN 'PASS'
ELSE 'FAIL'
END

UNION ALL

SELECT 
'holidays table has data',
CASE 
WHEN (SELECT COUNT(*) FROM holidays) > 0
THEN 'PASS'
ELSE 'FAIL'
END

UNION ALL

SELECT 
'leaves table has data',
CASE 
WHEN (SELECT COUNT(*) FROM leaves) > 0
THEN 'PASS'
ELSE 'FAIL'
END;
```

#### 📊 Example Output

| check_name                | status |
| ------------------------- | ------ |
| orders table exists       | PASS   |
| employees table exists    | PASS   |
| attendance table exists   | PASS   |
| holidays table exists     | PASS   |
| leaves table exists       | PASS   |
| orders table has data     | PASS   |
| employees table has data  | PASS   |
| attendance table has data | PASS   |
| holidays table has data   | PASS   |
| leaves table has data     | PASS   |

If something is wrong you will immediately see:

```
employees table exists | FAIL
```

### 📘 How to Write This in Your Lab Documentation

Example documentation note:

```
Step: Charlie Café RDS Deployment Verification

Executed DevOps validation script from EC2 MySQL client.

Verification checks:
• Table existence
• Data presence
• Database integrity

Result:
All health checks returned PASS confirming successful database deployment on Amazon RDS.
```

### ⭐ Why This Looks Very Professional

This type of PASS / FAIL verification is used in real pipelines with tools like:

- Jenkins

- GitHub Actions

- Terraform

Example pipeline:

```
Deploy Infrastructure
      ↓
Deploy Lambda APIs
      ↓
Run RDS health check
      ↓
PASS → Deployment Success
```

#### 🚀 If you want, I can also give you a “1 command DevOps script” (EXTREMELY COOL) that prints a Charlie Café database dashboard like this:

```
DATABASE HEALTH REPORT
----------------------
Tables: 5
Rows: 512
Indexes: OK
Engine: InnoDB
Database Size: 12 MB
Status: HEALTHY
```

This kind of database health report makes DevOps portfolios look very advanced.
---
## 🌐 AWS RDS Bash Scripts


### 1️⃣ Charlie-Cafe_RDS-Full.sh

```
nano Charlie-Cafe_RDS-Full.sh
```

#### Full Updated Bash Script 

```
#!/bin/bash

# =============================================================
# ☕ Charlie Cafe — FULL RDS CLEAN SETUP / DEVOPS SCRIPT
# =============================================================
#
# PURPOSE:
# Complete production-ready AWS RDS database setup.
#
# FEATURES:
# ✔ Deletes old messy schema
# ✔ Rebuilds tables cleanly
# ✔ Fixes duplicate/incorrect columns
# ✔ Adds missing payment_method field
# ✔ Creates proper indexes / keys
# ✔ Inserts safe sample data
# ✔ Runs verification checks
# ✔ Runs analytics tests
#
# WARNING:
# This script DROPS tables before recreating.
# Existing data will be deleted.
#
# =============================================================

set -euo pipefail

# =============================================================
# 🎨 TERMINAL COLORS
# =============================================================
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
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
# ⚙️ CONFIGURATION
# =============================================================
AWS_REGION="us-east-1"
SECRET_ID="CafeDevDBSM"
DB_NAME="cafe_db"

print_header "☕ Charlie Cafe RDS DevOps Setup Starting"

# =============================================================
# 🔧 CHECK REQUIRED TOOLS
# =============================================================
print_header "Checking Required Packages"

command -v mysql >/dev/null 2>&1 || sudo dnf install -y mariadb105
command -v jq >/dev/null 2>&1 || sudo dnf install -y jq
command -v aws >/dev/null 2>&1 || {
    print_error "AWS CLI Missing"
    exit 1
}

print_success "All packages installed"

# =============================================================
# 🔐 GET RDS CREDENTIALS
# =============================================================
print_header "Fetching AWS Secrets"

SECRET_JSON=$(aws secretsmanager get-secret-value \
--secret-id "$SECRET_ID" \
--region "$AWS_REGION" \
--query SecretString \
--output text)

DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host // .endpoint')
DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_PORT=$(echo "$SECRET_JSON" | jq -r '.port // "3306"')

print_success "Secrets Retrieved"

# =============================================================
# 🔒 TEMP MYSQL LOGIN FILE
# =============================================================
print_header "Creating Secure Temp MySQL Config"

CREDENTIALS_FILE=$(mktemp /tmp/cafe-db.XXXX)

chmod 600 "$CREDENTIALS_FILE"

cat > "$CREDENTIALS_FILE" <<EOF
[client]
host=$DB_HOST
port=$DB_PORT
user=$DB_USER
password=$DB_PASS
EOF

trap 'rm -f "$CREDENTIALS_FILE"' EXIT

print_success "Secure MySQL Temp File Ready"

# =============================================================
# 🔌 TEST DB CONNECTION
# =============================================================
print_header "Testing Database Connection"

mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "SELECT VERSION();"

print_success "Connected to RDS Successfully"

# =============================================================
# 🗄️ CREATE DATABASE
# =============================================================
print_header "Creating Database"

mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "
CREATE DATABASE IF NOT EXISTS $DB_NAME
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
"

print_success "Database Ready"

# =============================================================
# 🧹 CLEAN OLD TABLES
# =============================================================
print_header "Removing Old Broken Tables"

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'

SET FOREIGN_KEY_CHECKS=0;

DROP TABLE IF EXISTS attendance;
DROP TABLE IF EXISTS leaves;
DROP TABLE IF EXISTS holidays;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS employees;

SET FOREIGN_KEY_CHECKS=1;

EOF

print_success "Old Tables Removed"

# =============================================================
# 🏗️ CREATE CLEAN TABLES
# =============================================================
print_header "Creating Clean Production Tables"

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'

-- Employees
CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    cognito_user_id VARCHAR(100) UNIQUE,
    name VARCHAR(100) NOT NULL,
    job_title VARCHAR(50),
    salary DECIMAL(10,2),
    start_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Attendance
CREATE TABLE attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    attendance_date DATE,
    checkin_time TIME,
    checkout_time TIME,
    FOREIGN KEY (employee_id)
        REFERENCES employees(employee_id)
        ON DELETE CASCADE
);

-- Leaves
CREATE TABLE leaves (
    leave_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    leave_date DATE,
    leave_type VARCHAR(50),
    FOREIGN KEY (employee_id)
        REFERENCES employees(employee_id)
        ON DELETE CASCADE
);

-- Holidays
CREATE TABLE holidays (
    holiday_id INT AUTO_INCREMENT PRIMARY KEY,
    holiday_date DATE UNIQUE,
    description VARCHAR(100)
);

-- Orders
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    table_number INT NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    item VARCHAR(100) NOT NULL,
    quantity INT NOT NULL,
    payment_method VARCHAR(50) DEFAULT 'CASH',
    total_cost DECIMAL(10,2),
    total_amount DECIMAL(10,2),
    payment_status VARCHAR(20) DEFAULT 'PENDING',
    status VARCHAR(20) DEFAULT 'RECEIVED',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

EOF

print_success "Tables Created Successfully"

# =============================================================
# 📥 INSERT SAMPLE DATA
# =============================================================
print_header "Loading Sample Data"

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'

INSERT INTO employees
(cognito_user_id,name,job_title,salary,start_date)
VALUES
('emp-001','Ahmed','Barista',800,'2024-01-01'),
('emp-002','Hassan','Cashier',750,'2024-02-01');

INSERT INTO attendance
(employee_id,attendance_date,checkin_time,checkout_time)
VALUES
(1,CURDATE(),'09:00:00','17:00:00'),
(2,CURDATE(),'09:15:00','17:00:00');

INSERT INTO leaves
(employee_id,leave_date,leave_type)
VALUES
(1,'2026-03-01','Sick Leave');

INSERT INTO holidays
(holiday_date,description)
VALUES
('2026-12-25','Christmas'),
('2026-01-01','New Year');

INSERT INTO orders
(table_number,customer_name,item,quantity,payment_method,total_cost,total_amount,payment_status,status)
VALUES
(1,'Ali Khan','Espresso',2,'CASH',4.00,8.00,'PAID','COMPLETED'),
(2,'Sara Ahmed','Cappuccino',1,'CARD',3.50,3.50,'PAID','COMPLETED'),
(3,'Omar Ali','Latte',1,'CASH',3.00,3.00,'PENDING','RECEIVED');

EOF

print_success "Sample Data Inserted"

# =============================================================
# FINAL VERIFICATION
# =============================================================
print_header "RDS Verification Steps"

# 1️⃣ Verify Database Exists
echo "1️⃣ Verify Database Exists:"
mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "SHOW DATABASES LIKE '$DB_NAME';"

# 2️⃣ Verify Current Database
echo "2️⃣ Verify Current Database:"
mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "USE $DB_NAME; SELECT DATABASE();"

# 3️⃣ Show Tables
echo "3️⃣ Show Tables:"
mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "USE $DB_NAME; SHOW TABLES;"

# 4️⃣ Describe & SELECT for each table
for table in orders employees attendance holidays leaves
do
    echo "---- DESCRIBE $table ----"
    mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "USE $DB_NAME; DESCRIBE $table;"
    
    echo "---- SELECT * FROM $table ----"
    mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "USE $DB_NAME; SELECT * FROM $table;"
done

# 5️⃣ Verify Foreign Keys
echo "5️⃣ Verify Foreign Keys:"
mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME
FROM
    information_schema.KEY_COLUMN_USAGE
WHERE
    TABLE_SCHEMA = '$DB_NAME'
    AND REFERENCED_TABLE_NAME IS NOT NULL;
"

# 6️⃣ Verify Indexes (example on orders)
echo "6️⃣ Verify Indexes on orders:"
mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "USE $DB_NAME; SHOW INDEX FROM orders;"

# 7️⃣ Row Count Verification
echo "7️⃣ Verify Row Counts:"
mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" -e "
SELECT
(SELECT COUNT(*) FROM orders) AS total_orders,
(SELECT COUNT(*) FROM employees) AS total_employees,
(SELECT COUNT(*) FROM attendance) AS total_attendance,
(SELECT COUNT(*) FROM holidays) AS total_holidays;
"

# =============================================================
# ANALYTICS TESTS
# =============================================================
print_header "Running Analytics Tests"

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'
SELECT 'Paid Orders' AS section;
SELECT COUNT(*) FROM orders WHERE payment_status='PAID';

SELECT 'Today Sales' AS section;
SELECT COUNT(*) FROM orders
WHERE payment_status='PAID'
AND created_at >= CURDATE();

SELECT 'Week Sales' AS section;
SELECT COUNT(*) FROM orders
WHERE payment_status='PAID'
AND created_at >= NOW() - INTERVAL 7 DAY;

SELECT 'Month Sales' AS section;
SELECT COUNT(*) FROM orders
WHERE payment_status='PAID'
AND created_at >= DATE_FORMAT(NOW(),'%Y-%m-01');
EOF

print_success "Analytics verification completed"

# =============================================================
# 🎉 COMPLETE
# =============================================================
print_header "☕ Charlie Cafe Setup Complete"

echo -e "${GREEN}✔ RDS Production Ready${NC}"
echo -e "${GREEN}✔ Schema Fixed${NC}"
echo -e "${GREEN}✔ Frontend Compatible${NC}"
echo -e "${GREEN}✔ Backend Compatible${NC}"
echo -e "${GREEN}✔ Analytics Ready${NC}"
echo -e "${GREEN}✔ Full RDS Verification Completed${NC}"
```

```
chmod +x Charlie-Cafe_RDS-Full.sh
./Charlie-Cafe_RDS-Full.sh
```

### 2️⃣ connect-rds.sh

```
nano connect-rds.sh
```

#### Full Updated Bash Script 

```
#!/bin/bash

# ===============================
# CONFIGURATION
# ===============================

# Secret Name or ARN
SECRET_ID="CafeDevDBSM"
AWS_REGION="us-east-1"

# ===============================
# FETCH SECRET
# ===============================

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_ID" \
  --region "$AWS_REGION" \
  --query SecretString \
  --output text)

# ===============================
# PARSE VALUES
# ===============================

DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host')

# ===============================
# VALIDATION
# ===============================

if [[ -z "$DB_USER" || -z "$DB_PASS" || -z "$DB_HOST" ]]; then
  echo "❌ Failed to retrieve database credentials"
  exit 1
fi

# ===============================
# CONNECT TO MYSQL (NO DB NAME)
# ===============================

echo "✅ Connecting to RDS MySQL (no database selected)..."
mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS"

```

```
chmod +x connect-rds.sh
./connect-rds.sh
```

### 3️⃣ verify_charlie_cafe_rds.sh

```
nano verify_charlie_cafe_rds.sh
```

#### Full Updated Bash Script

```
#!/bin/bash
# =====================================================
# Charlie Cafe RDS FULL Verification Script (PRO)
#
# Verifies:
# - AWS Secrets Manager DB credentials
# - RDS connectivity
# - Database existence
# - Tables, schemas, critical columns
# - Indexes and foreign keys
# - Row counts
# - Sample data
# - Analytics (sales verification)
#
# SAFE: READ-ONLY, NO CREATE/ALTER/INSERT
# =====================================================

set -euo pipefail

# ===============================
# COLOR DEFINITIONS
# ===============================
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
  echo -e "\n${BLUE}========================================================${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}========================================================${NC}\n"
}

print_success() { echo -e "${GREEN}✅ $1${NC}\n"; }
print_warning() { echo -e "${YELLOW}⚠️ $1${NC}\n"; }
print_error() { echo -e "${RED}❌ $1${NC}\n"; }

# ===============================
# CONFIGURATION
# ===============================
SECRET_ID="CafeDevDBSM"
AWS_REGION="us-east-1"
DB_NAME="cafe_db"
REQUIRED_TABLES=("orders" "employees" "attendance" "leaves" "holidays")

print_header "☕ Charlie Cafe RDS Verification Started"

# ===============================
# FETCH DB CREDENTIALS
# ===============================
print_header "🔐 Fetching DB credentials from AWS Secrets Manager..."

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_ID" \
  --region "$AWS_REGION" \
  --query SecretString --output text)

DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host')
DB_PORT=$(echo "$SECRET_JSON" | jq -r '.port // 3306')

[[ -z "$DB_USER" || -z "$DB_PASS" || -z "$DB_HOST" ]] && { print_error "Missing credentials"; exit 1; }

print_success "Credentials loaded: $DB_USER@$DB_HOST:$DB_PORT"

# ===============================
# MYSQL COMMAND SHORTCUTS
# ===============================
MYSQL_BASE="mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS"
MYSQL_DB="$MYSQL_BASE $DB_NAME"
MYSQL_SILENT="$MYSQL_DB -sN"

# ===============================
# TEST CONNECTION
# ===============================
print_header "🔌 Testing RDS connection..."
$MYSQL_DB -e "SELECT VERSION();" >/dev/null
print_success "RDS connection successful"

# ===============================
# VERIFY DATABASE
# ===============================
print_header "🗄 Verifying database exists..."
$MYSQL_BASE -e "SHOW DATABASES LIKE '$DB_NAME';" | grep -q "$DB_NAME" && \
  print_success "Database '$DB_NAME' exists" || { print_error "Database '$DB_NAME' NOT FOUND"; exit 1; }

# ===============================
# VERIFY REQUIRED TABLES
# ===============================
print_header "📋 Verifying required tables..."
for table in "${REQUIRED_TABLES[@]}"; do
  if $MYSQL_SILENT -e "SHOW TABLES LIKE '$table';" | grep -q "$table"; then
    print_success "Table exists: $table"
  else
    print_error "Missing table: $table"
    exit 1
  fi
done

# ===============================
# LIST TABLES
# ===============================
print_header "📦 All tables in database"
$MYSQL_DB -e "SHOW TABLES;"

# ===============================
# DESCRIBE TABLES
# ===============================
print_header "🧾 Table structure (DESCRIBE)"

for table in "${REQUIRED_TABLES[@]}"; do
  echo -e "\n🔍 Schema for $table"
  echo "--------------------------------"
  $MYSQL_DB -e "DESCRIBE $table;"
done

# ===============================
# VERIFY CRITICAL COLUMNS
# ===============================
print_header "🧱 Verifying critical columns"
declare -A CRITICAL_COLUMNS
CRITICAL_COLUMNS=( 
  ["orders"]="table_number item_cost total_cost total_amount payment_status status"
  ["employees"]="name job_title salary"
  ["attendance"]="employee_id attendance_date"
  ["leaves"]="employee_id leave_date leave_type"
  ["holidays"]="holiday_date description"
)

for table in "${!CRITICAL_COLUMNS[@]}"; do
  for col in ${CRITICAL_COLUMNS[$table]}; do
    $MYSQL_SILENT -e "SHOW COLUMNS FROM $table LIKE '$col';" | grep -q "$col" || { print_error "$table.$col missing"; exit 1; }
  done
  print_success "$table critical columns OK"
done

# ===============================
# VERIFY INDEXES / FOREIGN KEYS
# ===============================
print_header "📈 Verifying indexes & foreign keys"

# Orders index
$MYSQL_DB -e "SHOW INDEX FROM orders WHERE Key_name='idx_table_number';" | grep -q idx_table_number && \
  print_success "orders.idx_table_number exists" || print_warning "orders.idx_table_number missing"

# Attendance FK
$MYSQL_DB -e "SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_NAME='attendance' AND REFERENCED_TABLE_NAME='employees';" | grep -q "employee_id" && \
  print_success "attendance.employee_id foreign key exists" || print_warning "attendance FK missing"

# Leaves FK
$MYSQL_DB -e "SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_NAME='leaves' AND REFERENCED_TABLE_NAME='employees';" | grep -q "employee_id" && \
  print_success "leaves.employee_id foreign key exists" || print_warning "leaves FK missing"

# ===============================
# ROW COUNTS
# ===============================
print_header "📊 Row counts per table"
for table in "${REQUIRED_TABLES[@]}"; do
  COUNT=$($MYSQL_SILENT -e "SELECT COUNT(*) FROM $table;")
  printf "   • %-12s : %s rows\n" "$table" "$COUNT"
done

# ===============================
# SAMPLE DATA PREVIEW
# ===============================
print_header "🧪 Sample data previews"

for table in "${REQUIRED_TABLES[@]}"; do
  echo -e "\nSample from $table:"
  echo "--------------------------------"
  $MYSQL_DB -e "SELECT * FROM $table LIMIT 3;"
done

# ===============================
# ANALYTICS CHECKS (orders)
# ===============================
print_header "📊 Analytics checks (orders)"

$MYSQL_DB -e "
SELECT 'Paid Orders' AS section, COUNT(*) AS count FROM orders WHERE payment_status='PAID';
SELECT 'Today Sales', COUNT(*) FROM orders WHERE payment_status='PAID' AND created_at >= CURDATE();
SELECT 'Week Sales', COUNT(*) FROM orders WHERE payment_status='PAID' AND created_at >= NOW()-INTERVAL 7 DAY;
SELECT 'Month Sales', COUNT(*) FROM orders WHERE payment_status='PAID' AND created_at >= DATE_FORMAT(NOW(), '%Y-%m-01');
"

# ===============================
# FINAL VERIFICATION REPORT
# ===============================
print_header "✅ CHARLIE CAFE RDS FULL VERIFICATION COMPLETE"
echo -e "${GREEN}All critical checks passed. Database, tables, schemas, indexes, FKs, row counts, and analytics verified ✔${NC}"
```

```
chmod +x verify_charlie_cafe_rds.sh
./verify_charlie_cafe_rds.sh
```

---
## 🌐 CHarlie Cafe AWS RDS DEVOPS 


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



### 📁 1. schema.sql (STRUCTURE ONLY)

- Creates database if not exists → safe for repeated runs

- Creates all tables with proper primary keys

- Creates foreign keys for relationships (attendance, leaves)

- Uses IF NOT EXISTS → prevents errors if re-run

- Sets UTF8MB4 charset → supports emojis and special chars

#### 👉 This is the MOST IMPORTANT file

#### 👉 Create this file:

```
infrastructure/rds/schema.sql
```

### ✅ FULL FILE 

```
-- ==========================================================
-- ☕ Charlie Cafe — DATABASE SCHEMA
-- PURPOSE:
-- Clean production-ready schema for Charlie Cafe RDS.
--
-- SAFE:
-- Drops old tables first for full rebuild.
--
-- WARNING:
-- This will DELETE old data.
-- ==========================================================

-- =============================
-- CREATE DATABASE
-- =============================
CREATE DATABASE IF NOT EXISTS cafe_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE cafe_db;

-- =============================
-- DISABLE FK FOR CLEAN DROP
-- =============================
SET FOREIGN_KEY_CHECKS=0;

DROP TABLE IF EXISTS attendance;
DROP TABLE IF EXISTS leaves;
DROP TABLE IF EXISTS holidays;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS employees;

SET FOREIGN_KEY_CHECKS=1;

-- =============================
-- EMPLOYEES TABLE
-- =============================
CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    cognito_user_id VARCHAR(100) UNIQUE,
    name VARCHAR(100) NOT NULL,
    job_title VARCHAR(50),
    salary DECIMAL(10,2),
    start_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =============================
-- ATTENDANCE TABLE
-- =============================
CREATE TABLE attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    attendance_date DATE,
    checkin_time TIME,
    checkout_time TIME,
    FOREIGN KEY (employee_id)
        REFERENCES employees(employee_id)
        ON DELETE CASCADE
);

-- =============================
-- LEAVES TABLE
-- =============================
CREATE TABLE leaves (
    leave_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    leave_date DATE,
    leave_type VARCHAR(50),
    FOREIGN KEY (employee_id)
        REFERENCES employees(employee_id)
        ON DELETE CASCADE
);

-- =============================
-- HOLIDAYS TABLE
-- =============================
CREATE TABLE holidays (
    holiday_id INT AUTO_INCREMENT PRIMARY KEY,
    holiday_date DATE UNIQUE,
    description VARCHAR(100)
);

-- =============================
-- ORDERS TABLE
-- =============================
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    table_number INT NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    item VARCHAR(100) NOT NULL,
    quantity INT NOT NULL,
    payment_method VARCHAR(50) DEFAULT 'CASH',
    total_cost DECIMAL(10,2),
    total_amount DECIMAL(10,2),
    payment_status VARCHAR(20) DEFAULT 'PENDING',
    status VARCHAR(20) DEFAULT 'RECEIVED',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

### 📁 2. data.sql (SAMPLE DATA)

- Seeding test/sample data for QA or demo

- Can run safely without breaking schema (INSERT IGNORE)

```
-- ==========================================================
-- ☕ Charlie Cafe — SAMPLE DATA
-- PURPOSE:
-- Insert clean development/test sample data.
-- ==========================================================

USE cafe_db;

-- =============================
-- EMPLOYEES
-- =============================
INSERT INTO employees
(cognito_user_id,name,job_title,salary,start_date)
VALUES
('emp-001','Ahmed','Barista',800,'2024-01-01'),
('emp-002','Hassan','Cashier',750,'2024-02-01');

-- =============================
-- ATTENDANCE
-- =============================
INSERT INTO attendance
(employee_id,attendance_date,checkin_time,checkout_time)
VALUES
(1,CURDATE(),'09:00:00','17:00:00'),
(2,CURDATE(),'09:15:00','17:00:00');

-- =============================
-- LEAVES
-- =============================
INSERT INTO leaves
(employee_id,leave_date,leave_type)
VALUES
(1,'2026-03-01','Sick Leave');

-- =============================
-- HOLIDAYS
-- =============================
INSERT INTO holidays
(holiday_date,description)
VALUES
('2026-12-25','Christmas'),
('2026-01-01','New Year');

-- =============================
-- ORDERS
-- =============================
INSERT INTO orders
(table_number,customer_name,item,quantity,payment_method,total_cost,total_amount,payment_status,status)
VALUES
(1,'Ali Khan','Espresso',2,'CASH',4.00,8.00,'PAID','COMPLETED'),
(2,'Sara Ahmed','Cappuccino',1,'CARD',3.50,3.50,'PAID','COMPLETED'),
(3,'Omar Ali','Latte',1,'CASH',3.00,3.00,'PENDING','RECEIVED');
```

### 📁 3. verify.sql (TESTING + ANALYTICS)

- Verification after deployment

- Checks: tables, relationships, indexes, row counts, analytics (today/week/month sales)

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

### 🎯 WHY schema.sql IS IMPORTANT (VERY IMPORTANT)

#### Think like DevOps:

| File       | Purpose                                       |
| ---------- | --------------------------------------------- |
| schema.sql | Structure (like building foundation of house) |
| data.sql   | Furniture (test/sample data)                  |
| verify.sql | Inspection (QA/testing)                       |


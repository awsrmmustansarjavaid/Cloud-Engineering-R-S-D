# ☕ AWS Charlie Café – RDS Database Setup Guide

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
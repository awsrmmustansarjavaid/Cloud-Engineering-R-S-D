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

### 1️⃣ Verify Orders

```
SELECT * FROM orders;
```

### 2️⃣ Verify Employees

```
SELECT * FROM employees;
```

### 3️⃣ Verify Attendance

```
SELECT * FROM attendance;
```

### 4️⃣ Verify Holidays

```
SELECT * FROM holidays;
```

### ✅ Expected Result

You should see:

- Orders inserted successfully

- Employees listed

- Attendance records created

- Holiday data visible

### 
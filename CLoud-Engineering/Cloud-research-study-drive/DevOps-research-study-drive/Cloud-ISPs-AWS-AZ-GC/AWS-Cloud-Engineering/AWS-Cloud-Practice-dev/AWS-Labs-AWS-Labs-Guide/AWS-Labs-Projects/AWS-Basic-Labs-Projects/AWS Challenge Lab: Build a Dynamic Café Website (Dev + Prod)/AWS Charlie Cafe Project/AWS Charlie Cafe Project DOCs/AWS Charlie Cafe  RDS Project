# AWS Charlie Cafe RDS Project

### ✅ Basic RDS Schema CONFIGURATIONS

### 1️⃣ Create Schema in RDS

- **✔️ Connect from EC2:**

### 2️⃣ — Basic RDS CONFIGURATIONS

### 1️⃣ Install & Login MySQL Client

```
sudo dnf install -y mariadb105
```

##### Verify mysql

```
mysql --version
```

##### Login to MariaDB:

```
mysql -h <rds-endpoint> -u cafe_user -p
```

### 3️⃣ Create Café Database

```sql
CREATE DATABASE cafe_db;
```

```
CREATE USER 'cafe_user'@'%' IDENTIFIED BY 'StrongPassword123';
```

```
GRANT ALL PRIVILEGES ON cafe_db.* TO 'cafe_user'@'%';
```

```
FLUSH PRIVILEGES;
```

### 4️⃣ Use the correct database

```
USE cafe_db;
```

### 5️⃣ Orders Table

### ✅ Simple Order Table

```sql
CREATE TABLE orders (
 id INT AUTO_INCREMENT PRIMARY KEY,
 customer_name VARCHAR(100),
 item VARCHAR(50),
 quantity INT,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 1️⃣ CREATE TABLE with table_number (Recommended)

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

### 2️⃣ Open RDS → Query Editor (or MySQL client)

- Connect to your cafe database.

#### 1️⃣ Add Required Columns

#### ✅ Run exactly this SQL:

```
ALTER TABLE orders
ADD COLUMN order_id VARCHAR(50),
ADD COLUMN status VARCHAR(20) DEFAULT 'RECEIVED',
ADD COLUMN total_amount DECIMAL(10,2),
ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;
```

#### ✅ You MUST see:

- order_id

- status

- total_amount

- updated_at

### ✅ ORDER ID FORMAT (STANDARD)

```
ORD-YYYYMMDD-XXXX
```

#### ✅ Example:

```
ORD-20260114-8392
```
#### 3️⃣ Add Required Columns

```
ALTER TABLE orders
ADD COLUMN created_at DATETIME DEFAULT CURRENT_TIMESTAMP;
```

```
ALTER TABLE orders
ADD COLUMN payment_status VARCHAR(20) DEFAULT 'PENDING';
```

#### 1️⃣ Create employees Table

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

### Why each column exists

- cognito_user_id → maps Cognito JWT sub

- employee_id → internal café ID

- salary → HR-only field

- created_at → audit trail

#### 2️⃣ Create attendance Table

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

#### Key points

UNIQUE(employee_id, attendance_date)

Prevents double check-in per day

checkin_time and checkout_time separated

Foreign key ensures valid employee

#### 3️⃣ Create leaves Table

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

#### 4️⃣ Create holidays Table

```
CREATE TABLE holidays (
    holiday_id INT AUTO_INCREMENT PRIMARY KEY,
    holiday_date DATE NOT NULL,
    description VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```
### 3️⃣ Insert Test Data (Required for Frontend Testing)

#### 1️⃣ Insert Holidays

```
INSERT INTO holidays (holiday_date, description)
VALUES
('2026-01-01', 'New Year'),
('2026-03-23', 'Pakistan Day');
```


### 6️⃣ Test insert manually (CLI)

```
INSERT INTO orders (customer_name, item, quantity)
VALUES ('CLI-Test', 'Coffee', 1);
```
#### 📢 Multi Values (with table_number)

```
-- For your first (simpler) table
INSERT INTO orders (table_number, customer_name, item, quantity) 
VALUES 
    (1, 'Ali Khan', 'Espresso', 2),
    (1, 'Sara Ahmed', 'Cappuccino', 1),
    (2, 'CLI-Test', 'Coffee', 1),
    (3, NULL, 'Latte', 3),
    (5, 'Ahmed Raza', 'Croissant + Tea', 1);
``` 

#### Most common quick test inserts (good for development):

```
-- Quick test inserts - very useful for checking
INSERT INTO orders (table_number, customer_name, item, quantity) VALUES
    (1, 'Test User', 'Black Coffee', 1),
    (2, NULL, 'Green Tea', 2),
    (4, 'CLI-Test', 'Coffee', 1);
```


```
INSERT INTO orders (order_id, table_number, customer_name, item, quantity, total_cost, total_amount, payment_method, payment_status, status)
VALUES ('ORD-20260302-9999', 1, 'Alice', 'Latte', 2, 4.0, 6.0, 'CASH', 'PAID', 'RECEIVED');
```






#### 3️⃣ Verify Columns

```
DESCRIBE orders;
```



### 5️⃣ Verify table exists

```
SHOW TABLES;
```

##### You should see:

```
orders
```
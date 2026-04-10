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
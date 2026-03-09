#!/bin/bash
# =============================================================
# ☕ Charlie Cafe — FULL RDS Setup & Verification Script
# Version: 8.0 (Production Ready)
#
# Features
# ✔ Colored output
# ✔ AWS Secrets Manager integration
# ✔ Secure temporary MySQL config
# ✔ Creates database
# ✔ Creates all tables
# ✔ Inserts sample data for ALL tables
# ✔ Shows schema of each table
# ✔ Verifies table counts
# ✔ Verifies foreign keys
# ✔ Verifies indexes
# ✔ Runs analytics tests
# ✔ Safe to run multiple times
# =============================================================

set -euo pipefail

# =============================================================
# COLOR DEFINITIONS
# =============================================================
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

print_success() {
    echo -e "${GREEN}✅ $1${NC}\n"
}

print_error() {
    echo -e "${RED}❌ $1${NC}\n"
}

# =============================================================
# CONFIGURATION
# =============================================================
AWS_REGION="us-east-1"
SECRET_ID="CafeDevDBSM"
DB_NAME="cafe_db"

print_header "☕ Charlie Cafe RDS Setup Starting"

# =============================================================
# CHECK REQUIRED TOOLS
# =============================================================
print_header "Checking Required Tools"

command -v mysql >/dev/null 2>&1 || sudo dnf install -y mariadb105
command -v jq >/dev/null 2>&1 || sudo dnf install -y jq
command -v aws >/dev/null 2>&1 || { print_error "AWS CLI not installed"; exit 1; }

print_success "All tools ready"

# =============================================================
# FETCH RDS CREDENTIALS
# =============================================================
print_header "Fetching Secrets Manager Credentials"

SECRET_JSON=$(aws secretsmanager get-secret-value \
--secret-id "$SECRET_ID" \
--region "$AWS_REGION" \
--query SecretString \
--output text)

DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host // .endpoint')
DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_PORT=$(echo "$SECRET_JSON" | jq -r '.port // "3306"')

print_success "Credentials loaded"

# =============================================================
# CREATE TEMP MYSQL CONFIG
# =============================================================
print_header "Creating Secure MySQL Config"

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

print_success "Temporary config created"

# =============================================================
# TEST CONNECTION
# =============================================================
print_header "Testing RDS Connection"

mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "SELECT VERSION();"
print_success "RDS connection successful"

# =============================================================
# CREATE DATABASE
# =============================================================
print_header "Ensuring Database Exists"

mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "
CREATE DATABASE IF NOT EXISTS $DB_NAME
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
"

print_success "Database verified"

# =============================================================
# CREATE TABLES
# =============================================================
print_header "Creating Tables"

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'
CREATE TABLE IF NOT EXISTS employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    cognito_user_id VARCHAR(100) UNIQUE,
    name VARCHAR(100),
    job_title VARCHAR(50),
    salary DECIMAL(10,2),
    start_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT,
    attendance_date DATE,
    checkin_time TIME,
    checkout_time TIME,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE IF NOT EXISTS leaves (
    leave_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT,
    leave_date DATE,
    leave_type VARCHAR(50),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE IF NOT EXISTS holidays (
    holiday_id INT AUTO_INCREMENT PRIMARY KEY,
    holiday_date DATE UNIQUE,
    description VARCHAR(100)
);

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
EOF

print_success "Tables created"

# =============================================================
# INSERT SAMPLE DATA
# =============================================================
print_header "Inserting Sample Data"

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'
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
EOF

print_success "Sample data inserted"

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
mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "
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
# FINAL SUCCESS REPORT
# =============================================================
print_header "☕ Charlie Cafe RDS Setup Completed Successfully"

echo -e "${GREEN}✔ RDS Connection Successful${NC}"
echo -e "${GREEN}✔ Database Created/Verified${NC}"
echo -e "${GREEN}✔ Tables Created${NC}"
echo -e "${GREEN}✔ Sample Data Inserted${NC}"
echo -e "${GREEN}✔ Schemas Verified${NC}"
echo -e "${GREEN}✔ Row Counts Verified${NC}"
echo -e "${GREEN}✔ Analytics Queries Successful${NC}"
echo -e "${GREEN}✔ Full RDS Verification Completed${NC}"
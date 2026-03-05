#!/bin/bash
# =============================================================
# ☕ Charlie Cafe — Master RDS Setup & Verification Script
# Version: 6.0 (Production Ready)
#
# Features
# ✔ Colored output UI
# ✔ Secure AWS Secrets Manager integration
# ✔ Automatic dependency installation
# ✔ Creates ALL required tables
# ✔ Idempotent (safe to run multiple times)
# ✔ Analytics verification
# ✔ Schema verification
# ✔ Sample data
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
echo -e "\n${BLUE}==============================================================${NC}"
echo -e "${BLUE}$1${NC}"
echo -e "${BLUE}==============================================================${NC}\n"
}

print_success() {
echo -e "${GREEN}✅ $1${NC}\n"
}

print_warning() {
echo -e "${YELLOW}⚠️ $1${NC}\n"
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

print_header "☕ Charlie Cafe — Complete RDS Setup Starting"

# =============================================================
# CHECK REQUIRED TOOLS
# =============================================================

print_header "📦 Checking Required Tools"

command -v mysql >/dev/null 2>&1 || {
print_warning "Installing MariaDB client..."
sudo dnf install -y mariadb105
}

command -v jq >/dev/null 2>&1 || {
print_warning "Installing jq..."
sudo dnf install -y jq
}

command -v aws >/dev/null 2>&1 || {
print_error "AWS CLI not installed"
exit 1
}

print_success "All required tools are installed"

# =============================================================
# FETCH RDS CREDENTIALS
# =============================================================

print_header "🔐 Fetching RDS Credentials"

SECRET_JSON=$(aws secretsmanager get-secret-value \
--secret-id "$SECRET_ID" \
--region "$AWS_REGION" \
--query SecretString \
--output text)

DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host // .endpoint')
DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_PORT=$(echo "$SECRET_JSON" | jq -r '.port // "3306"')

print_success "Credentials Loaded: $DB_USER@$DB_HOST:$DB_PORT"

# =============================================================
# CREATE TEMP MYSQL CONFIG
# =============================================================

print_header "🔑 Creating Secure Connection File"

CREDENTIALS_FILE=$(mktemp /tmp/cafe-db.XXXXXX)

chmod 600 "$CREDENTIALS_FILE"

cat > "$CREDENTIALS_FILE" <<EOF
[client]
host=$DB_HOST
port=$DB_PORT
user=$DB_USER
password=$DB_PASS
connect-timeout=10
EOF

trap 'rm -f "$CREDENTIALS_FILE"' EXIT

print_success "Temporary credential file created"

# =============================================================
# TEST CONNECTION
# =============================================================

print_header "🔌 Testing Database Connection"

mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "SELECT 1;" >/dev/null

print_success "Connection to RDS successful"

# =============================================================
# CREATE DATABASE
# =============================================================

print_header "🗄 Ensuring Database Exists"

mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "

CREATE DATABASE IF NOT EXISTS $DB_NAME
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

"

print_success "Database is ready"

# =============================================================
# CREATE TABLES
# =============================================================

print_header "📋 Creating Tables"

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'

-- =============================================================
-- ORDERS TABLE
-- =============================================================

CREATE TABLE IF NOT EXISTS orders (

id INT AUTO_INCREMENT PRIMARY KEY,

order_id VARCHAR(50),

table_number INT NOT NULL,

customer_name VARCHAR(100),

item VARCHAR(100),

quantity INT NOT NULL,

item_cost DECIMAL(6,2),

total_cost DECIMAL(10,2),

total_amount DECIMAL(10,2),

payment_method VARCHAR(20),

payment_status VARCHAR(20) DEFAULT 'PENDING',

status VARCHAR(20) DEFAULT 'RECEIVED',

created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
ON UPDATE CURRENT_TIMESTAMP,

INDEX idx_table_number (table_number),

INDEX idx_created_at (created_at)

) ENGINE=InnoDB;


-- =============================================================
-- EMPLOYEES TABLE
-- =============================================================

CREATE TABLE IF NOT EXISTS employees (

employee_id INT AUTO_INCREMENT PRIMARY KEY,

cognito_user_id VARCHAR(100) NOT NULL,

name VARCHAR(100) NOT NULL,

job_title VARCHAR(50),

salary DECIMAL(10,2),

start_date DATE,

created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

UNIQUE KEY uk_cognito (cognito_user_id)

) ENGINE=InnoDB;


-- =============================================================
-- ATTENDANCE TABLE
-- =============================================================

CREATE TABLE IF NOT EXISTS attendance (

attendance_id INT AUTO_INCREMENT PRIMARY KEY,

employee_id INT NOT NULL,

attendance_date DATE NOT NULL,

checkin_time TIME,

checkout_time TIME,

created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

UNIQUE KEY uk_day (employee_id, attendance_date),

FOREIGN KEY (employee_id)
REFERENCES employees(employee_id)
ON DELETE CASCADE

) ENGINE=InnoDB;


-- =============================================================
-- LEAVES TABLE
-- =============================================================

CREATE TABLE IF NOT EXISTS leaves (

leave_id INT AUTO_INCREMENT PRIMARY KEY,

employee_id INT NOT NULL,

leave_date DATE NOT NULL,

leave_type VARCHAR(50),

created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

FOREIGN KEY (employee_id)
REFERENCES employees(employee_id)
ON DELETE CASCADE

) ENGINE=InnoDB;


-- =============================================================
-- HOLIDAYS TABLE
-- =============================================================

CREATE TABLE IF NOT EXISTS holidays (

holiday_id INT AUTO_INCREMENT PRIMARY KEY,

holiday_date DATE NOT NULL UNIQUE,

description VARCHAR(100),

created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP

) ENGINE=InnoDB;

EOF

print_success "All tables created successfully"

# =============================================================
# INSERT SAMPLE DATA
# =============================================================

print_header "🌱 Inserting Sample Data"

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'

INSERT IGNORE INTO orders
(table_number, customer_name, item, quantity, total_cost, total_amount, payment_status, status)
VALUES
(1,'Ali Khan','Espresso',2,4.00,8.00,'PAID','COMPLETED'),
(2,'Sara Ahmed','Cappuccino',1,3.50,5.00,'PAID','COMPLETED'),
(3,'Omar Ali','Latte',1,3.00,5.00,'PENDING','RECEIVED');

EOF

print_success "Sample data inserted"

# =============================================================
# VERIFY SCHEMA
# =============================================================

print_header "🔎 Verifying Schema"

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" -e "

SHOW TABLES;

DESCRIBE orders;

SELECT * FROM orders LIMIT 5;

"

print_success "Schema verification completed"

# =============================================================
# ANALYTICS TEST
# =============================================================

print_header "📊 Running Analytics Queries"

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'

SELECT 'Paid Orders' AS section;
SELECT COUNT(*) AS paid_orders
FROM orders
WHERE payment_status='PAID';

SELECT 'Today Sales' AS section;
SELECT COUNT(*) AS today_sales
FROM orders
WHERE payment_status='PAID'
AND created_at >= CURDATE();

SELECT 'Week Sales' AS section;
SELECT COUNT(*) AS week_sales
FROM orders
WHERE payment_status='PAID'
AND created_at >= NOW() - INTERVAL 7 DAY;

SELECT 'Month Sales' AS section;
SELECT COUNT(*) AS month_sales
FROM orders
WHERE payment_status='PAID'
AND created_at >= DATE_FORMAT(NOW(),'%Y-%m-01');

EOF

print_success "Analytics verification completed"

print_header "🎉 ALL TASKS COMPLETED SUCCESSFULLY"

echo -e "${GREEN}Charlie Cafe RDS setup finished successfully ☕${NC}"

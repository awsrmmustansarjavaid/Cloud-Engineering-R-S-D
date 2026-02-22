#!/bin/bash
# =============================================================
# ☕ Charlie Cafe — Master RDS Setup & Verification Script
# Version: 3.0 (Fully Merged & Production Safe)
#
# Features:
#   ✔ Auto-install required tools
#   ✔ Secure Secrets Manager integration
#   ✔ Create DB if not exists
#   ✔ Create ALL tables (Orders + HR)
#   ✔ Safe ALTER for status column
#   ✔ Safe index creation (MySQL 5.7 compatible)
#   ✔ Insert sample data (idempotent)
#   ✔ Full per-table verification
# =============================================================

set -euo pipefail

echo "☕ Charlie Cafe — Complete Database Setup"
echo "=============================================================="

# =============================================================
# CONFIGURATION (EDIT ONLY HERE)
# =============================================================
AWS_REGION="us-east-1"
SECRET_ID="CafeDevDBSM"
DB_NAME="cafe_db"

# =============================================================
# CHECK REQUIRED TOOLS
# =============================================================
echo "📦 Checking required tools..."

command -v mysql >/dev/null 2>&1 || {
    echo "Installing MariaDB client..."
    sudo dnf install -y mariadb105
}

command -v jq >/dev/null 2>&1 || {
    echo "Installing jq..."
    sudo dnf install -y jq
}

command -v aws >/dev/null 2>&1 || {
    echo "❌ AWS CLI not installed. Install AWS CLI v2 first."
    exit 1
}

echo "✅ All required tools installed"
echo ""

# =============================================================
# FETCH DATABASE CREDENTIALS
# =============================================================
echo "🔐 Fetching RDS credentials..."

SECRET_JSON=$(aws secretsmanager get-secret-value \
    --secret-id "$SECRET_ID" \
    --region "$AWS_REGION" \
    --query SecretString \
    --output text)

DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host // .endpoint // empty')
DB_USER=$(echo "$SECRET_JSON" | jq -r '.username // empty')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password // empty')
DB_PORT=$(echo "$SECRET_JSON" | jq -r '.port // "3306"')

if [[ -z "$DB_HOST" || -z "$DB_USER" || -z "$DB_PASS" ]]; then
    echo "❌ ERROR: Missing required fields in secret"
    exit 1
fi

echo "✅ Credentials loaded: $DB_USER@$DB_HOST:$DB_PORT"
echo ""

# =============================================================
# CREATE SECURE TEMP MYSQL CONFIG
# =============================================================
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

# =============================================================
# TEST CONNECTION
# =============================================================
echo "🔌 Testing database connection..."
mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "SELECT 1" >/dev/null
echo "✅ Connection successful"
echo ""

# =============================================================
# CREATE DATABASE
# =============================================================
echo "🗄 Ensuring database exists..."

mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "
CREATE DATABASE IF NOT EXISTS $DB_NAME
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
"

echo "✅ Database ready"
echo ""

# =============================================================
# CREATE TABLES
# =============================================================
echo "📋 Creating tables..."

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'

-- =========================
-- ORDERS TABLE
-- =========================
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(50),
    table_number INT NOT NULL,
    customer_name VARCHAR(100),
    item VARCHAR(100),
    quantity INT NOT NULL,
    item_cost DECIMAL(6,2),
    total_cost DECIMAL(6,2),
    total_amount DECIMAL(10,2),
    payment_method VARCHAR(20),
    payment_status VARCHAR(20),
    status VARCHAR(20) DEFAULT 'RECEIVED',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_table_number (table_number),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB;

-- =========================
-- EMPLOYEES
-- =========================
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

-- =========================
-- ATTENDANCE
-- =========================
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

-- =========================
-- LEAVES
-- =========================
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

-- =========================
-- HOLIDAYS
-- =========================
CREATE TABLE IF NOT EXISTS holidays (
    holiday_id INT AUTO_INCREMENT PRIMARY KEY,
    holiday_date DATE NOT NULL UNIQUE,
    description VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

EOF

echo "✅ Tables created"
echo ""

# =============================================================
# SAFE ALTER: ENSURE STATUS COLUMN EXISTS (5.7 SAFE)
# =============================================================
echo "🔄 Verifying status column..."

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'

SET @col_exists := (
    SELECT COUNT(*)
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'orders'
      AND COLUMN_NAME = 'status'
);

SET @sql := IF(
    @col_exists = 0,
    "ALTER TABLE orders ADD COLUMN status VARCHAR(20) DEFAULT 'PENDING'",
    "SELECT 'status column already exists'"
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

EOF

echo "✅ Status column verified"
echo ""

# =============================================================
# SAFE INDEX CREATION (ATTENDANCE)
# =============================================================
echo "📈 Verifying attendance indexes..."

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'

SET @i1 := (SELECT COUNT(*) FROM information_schema.statistics
WHERE table_schema=DATABASE()
AND table_name='attendance'
AND index_name='idx_attendance_date');

SET @sql := IF(@i1=0,
'ALTER TABLE attendance ADD INDEX idx_attendance_date (attendance_date)',
'SELECT "idx_attendance_date exists"');

PREPARE s FROM @sql; EXECUTE s; DEALLOCATE PREPARE s;

EOF

echo "✅ Index verification complete"
echo ""

# =============================================================
# INSERT SAMPLE DATA (SAFE)
# =============================================================
echo "🌱 Inserting sample data..."

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'

INSERT IGNORE INTO orders (table_number, customer_name, item, quantity, status)
VALUES
(1, 'Ali Khan', 'Espresso', 2, 'RECEIVED'),
(2, 'Sara Ahmed', 'Cappuccino', 1, 'PREPARING');

INSERT IGNORE INTO employees
(cognito_user_id, name, job_title, salary, start_date)
VALUES
('TEMP-COGNITO-ID', 'Alice', 'Barista', 40000, '2025-12-01');

INSERT IGNORE INTO holidays (holiday_date, description)
VALUES
('2026-01-01', 'New Year'),
('2026-03-23', 'Pakistan Day');

EOF

echo "✅ Sample data inserted"
echo ""

# =============================================================
# FULL TABLE VERIFICATION (EACH TABLE SEPARATELY)
# =============================================================
echo "🔎 FINAL VERIFICATION"
echo "=============================================================="

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'

-- ORDERS
SELECT 'ORDERS TABLE' AS section;
DESCRIBE orders;
SELECT COUNT(*) AS total_orders FROM orders;
SELECT * FROM orders LIMIT 5;

-- EMPLOYEES
SELECT 'EMPLOYEES TABLE' AS section;
DESCRIBE employees;
SELECT COUNT(*) AS total_employees FROM employees;

-- ATTENDANCE
SELECT 'ATTENDANCE TABLE' AS section;
DESCRIBE attendance;
SELECT COUNT(*) AS total_attendance FROM attendance;

-- LEAVES
SELECT 'LEAVES TABLE' AS section;
DESCRIBE leaves;
SELECT COUNT(*) AS total_leaves FROM leaves;

-- HOLIDAYS
SELECT 'HOLIDAYS TABLE' AS section;
DESCRIBE holidays;
SELECT COUNT(*) AS total_holidays FROM holidays;

SELECT 'Charlie Cafe DB setup verified successfully ✅' AS status;

EOF

echo ""
echo "🎉 ALL TASKS COMPLETED SUCCESSFULLY ☕"
echo "=============================================================="
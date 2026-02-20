#!/bin/bash
# =============================================================
# ☕ Charlie Cafe — Complete RDS Setup & Verification Script
# Version: 1.2
# Includes: Create/Verify Tables + Sample Data + ALTER TABLE
# =============================================================

set -euo pipefail

echo "☕ Charlie Cafe — Complete RDS Setup & Verification"
echo "=============================================================="

# =============================================================
# CONFIGURATION
# =============================================================
AWS_REGION="us-east-1"
SECRET_ID="CafeDevDBSM"
DB_NAME="cafe_db"

# =============================================================
# INSTALL REQUIRED PACKAGES (MariaDB client + jq)
# =============================================================
echo "📦 Checking required packages..."

command -v mysql >/dev/null 2>&1 || { echo "Installing MariaDB client..."; sudo dnf install -y mariadb105; }
command -v jq >/dev/null 2>&1    || { echo "Installing jq..."; sudo dnf install -y jq; }
command -v aws >/dev/null 2>&1   || { echo "❌ AWS CLI not installed. Please install AWS CLI v2."; exit 1; }

echo "✅ All required tools are installed"
echo ""

# =============================================================
# FETCH DATABASE CREDENTIALS FROM AWS SECRETS MANAGER
# =============================================================
echo "🔐 Fetching RDS credentials from Secrets Manager..."

SECRET_JSON=$(aws secretsmanager get-secret-value \
    --secret-id "$SECRET_ID" \
    --region "$AWS_REGION" \
    --query SecretString --output text)

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
# CREATE TEMP MYSQL CONFIG FILE (SECURE CONNECTION)
# =============================================================
CREDENTIALS_FILE=$(mktemp /tmp/cafe-rds-cred.XXXXXX)
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
# TEST CONNECTION TO RDS
# =============================================================
echo "🔌 Testing RDS connection..."
mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "SELECT 1" >/dev/null
echo "✅ RDS connection successful"
echo ""

# =============================================================
# CREATE DATABASE IF NOT EXISTS
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
# CREATE TABLES (ORDERS, EMPLOYEES, ATTENDANCE, LEAVES, HOLIDAYS)
# =============================================================
echo "📋 Creating tables (Orders + HR)..."

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'

-- =====================================================
-- ORDERS TABLE (Full Production Version)
-- =====================================================
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id       VARCHAR(50),
    table_number   INT NOT NULL,
    customer_name  VARCHAR(100),
    item           VARCHAR(100),
    quantity       INT NOT NULL,
    -- Pricing
    item_cost      DECIMAL(6,2),
    total_cost     DECIMAL(6,2),
    total_amount   DECIMAL(10,2),
    -- Payment
    payment_method VARCHAR(20),
    payment_status VARCHAR(20),
    -- Order Status
    status         VARCHAR(20) DEFAULT 'RECEIVED',
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                    ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_table_number (table_number),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB;

-- =====================================================
-- EMPLOYEES TABLE
-- =====================================================
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

-- =====================================================
-- ATTENDANCE TABLE
-- =====================================================
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

-- =====================================================
-- LEAVES TABLE
-- =====================================================
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

-- =====================================================
-- HOLIDAYS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS holidays (
    holiday_id INT AUTO_INCREMENT PRIMARY KEY,
    holiday_date DATE NOT NULL UNIQUE,
    description VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

EOF

echo "✅ Tables created or verified"
echo ""

# =============================================================
# ALTER ORDERS TABLE (Add status + created_at if missing)
# =============================================================
echo "🔄 Altering 'orders' table (ensure status & created_at columns exist)..."

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'
ALTER TABLE orders
    ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'PENDING',
    ADD COLUMN IF NOT EXISTS created_at DATETIME;
EOF

echo "✅ Orders table ALTER completed"
echo ""

# =============================================================
# SAFE INDEX CHECK (MySQL 5.7 Compatible)
# =============================================================
echo "📈 Ensuring attendance indexes exist..."

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

echo "✅ Index check complete"
echo ""

# =============================================================
# INSERT SAMPLE DATA (SAFE TO RE-RUN)
# =============================================================
echo "🌱 Inserting sample data..."

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'
INSERT IGNORE INTO orders (table_number, customer_name, item, quantity, status)
VALUES
(1, 'Ali Khan', 'Espresso', 2, 'RECEIVED'),
(2, 'Sara Ahmed', 'Latte', 1, 'PREPARING');

INSERT IGNORE INTO holidays (holiday_date, description)
VALUES
('2026-01-01', 'New Year'),
('2026-03-23', 'Pakistan Day');

INSERT IGNORE INTO employees
(cognito_user_id, name, job_title, salary, start_date)
VALUES
('TEMP-ID-001', 'Alice', 'Barista', 40000, '2025-12-01');
EOF

echo "✅ Sample data inserted"
echo ""

# =============================================================
# FINAL VERIFICATION
# =============================================================
echo "🔎 FINAL VERIFICATION"
echo "=============================================================="

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'

-- Show all tables
SHOW TABLES;

-- Show row counts
SELECT 'orders' AS table_name, COUNT(*) FROM orders
UNION ALL
SELECT 'employees', COUNT(*) FROM employees
UNION ALL
SELECT 'attendance', COUNT(*) FROM attendance
UNION ALL
SELECT 'leaves', COUNT(*) FROM leaves
UNION ALL
SELECT 'holidays', COUNT(*) FROM holidays;

-- Show structure of orders table
DESCRIBE orders;

-- Show indexes
SHOW INDEX FROM attendance;

-- Preview data
SELECT * FROM orders LIMIT 5;

SELECT 'Charlie Cafe DB setup verified successfully ✅' AS status;

EOF

echo ""
echo "🎉 ALL TASKS COMPLETED SUCCESSFULLY ☕"
echo "=============================================================="
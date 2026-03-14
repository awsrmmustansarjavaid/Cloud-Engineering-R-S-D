#!/bin/bash
set -euo pipefail

echo "☕ Charlie Cafe — Order Processing & HR Database Setup"
echo "====================================================="

# =========================================================
# CONFIGURATION
# =========================================================
AWS_REGION="us-east-1"
SECRET_ID="CafeDevDBSM"
DB_NAME="cafe_db"

# =========================================================
# FETCH DATABASE CREDENTIALS
# =========================================================
echo "🔐 Fetching RDS credentials from AWS Secrets Manager..."

SECRET_JSON=$(aws secretsmanager get-secret-value \
    --secret-id "$SECRET_ID" \
    --region "$AWS_REGION" \
    --query SecretString \
    --output text)

DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host // .endpoint')
DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_PORT=$(echo "$SECRET_JSON" | jq -r '.port // "3306"')

if [[ -z "$DB_HOST" || -z "$DB_USER" || -z "$DB_PASS" ]]; then
    echo "❌ ERROR: Missing DB credentials in Secrets Manager"
    exit 1
fi

echo "✅ Credentials loaded"
echo "   • Host: $DB_HOST"
echo "   • User: $DB_USER"
echo "   • DB  : $DB_NAME"
echo ""

# =========================================================
# CREATE TEMP MYSQL CONFIG (SECURE)
# =========================================================
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

# =========================================================
# TEST CONNECTION
# =========================================================
echo "🔌 Testing MySQL connection..."
mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "SELECT 1" >/dev/null
echo "✅ MySQL connection successful"
echo ""

# =========================================================
# CREATE DATABASE
# =========================================================
echo "🗄 Ensuring database exists..."
mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "
CREATE DATABASE IF NOT EXISTS $DB_NAME
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
"

# =========================================================
# CREATE TABLES
# =========================================================
echo "📋 Creating tables (Orders + HR)..."

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'
-- =======================
-- ORDERS TABLE
-- =======================
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    table_number INT NOT NULL,
    customer_name VARCHAR(100),
    item VARCHAR(50),
    quantity INT NOT NULL,
    item_cost DECIMAL(6,2),
    total_cost DECIMAL(6,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_table_number (table_number),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB;

-- =======================
-- EMPLOYEES
-- =======================
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

-- =======================
-- ATTENDANCE
-- =======================
CREATE TABLE IF NOT EXISTS attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    attendance_date DATE NOT NULL,
    checkin_time TIME,
    checkout_time TIME,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_day (employee_id, attendance_date),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =======================
-- LEAVES
-- =======================
CREATE TABLE IF NOT EXISTS leaves (
    leave_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    leave_date DATE NOT NULL,
    leave_type VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =======================
-- HOLIDAYS
-- =======================
CREATE TABLE IF NOT EXISTS holidays (
    holiday_id INT AUTO_INCREMENT PRIMARY KEY,
    holiday_date DATE NOT NULL UNIQUE,
    description VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
EOF

# =========================================================
# ADD INDEXES (MYSQL 5.7 SAFE)
# =========================================================
echo "📈 Ensuring attendance indexes exist..."

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'
SET @i1 := (SELECT COUNT(*) FROM information_schema.statistics
            WHERE table_schema=DATABASE()
            AND table_name='attendance'
            AND index_name='idx_attendance_date');

SET @i2 := (SELECT COUNT(*) FROM information_schema.statistics
            WHERE table_schema=DATABASE()
            AND table_name='attendance'
            AND index_name='idx_attendance_employee');

SET @sql := IF(@i1=0,
    'ALTER TABLE attendance ADD INDEX idx_attendance_date (attendance_date)',
    'SELECT "idx_attendance_date exists"');
PREPARE s FROM @sql; EXECUTE s; DEALLOCATE PREPARE s;

SET @sql := IF(@i2=0,
    'ALTER TABLE attendance ADD INDEX idx_attendance_employee (employee_id)',
    'SELECT "idx_attendance_employee exists"');
PREPARE s FROM @sql; EXECUTE s; DEALLOCATE PREPARE s;
EOF

# =========================================================
# INSERT TEST DATA (SAFE TO RE-RUN)
# =========================================================
echo "🌱 Inserting test data..."

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'
INSERT IGNORE INTO orders (table_number, customer_name, item, quantity)
VALUES
    (1, 'Ali Khan', 'Espresso', 2),
    (1, 'Sara Ahmed', 'Cappuccino', 1),
    (2, 'CLI-Test', 'Coffee', 1),
    (3, NULL, 'Latte', 3),
    (5, 'Ahmed Raza', 'Croissant + Tea', 1);

INSERT IGNORE INTO holidays (holiday_date, description)
VALUES
    ('2026-01-01', 'New Year'),
    ('2026-03-23', 'Pakistan Day');

INSERT IGNORE INTO employees
(cognito_user_id, name, job_title, salary, start_date)
VALUES
('TEMP-COGNITO-ID', 'Alice', 'Barista', 40000, '2025-12-01');
EOF

# =========================================================
# FINAL VERIFICATION
# =========================================================
echo ""
echo "🔍 FINAL VERIFICATION"
echo "------------------------------------------------"

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'
SHOW TABLES;

SELECT 'orders' AS table_name, COUNT(*) FROM orders
UNION ALL
SELECT 'employees', COUNT(*) FROM employees
UNION ALL
SELECT 'attendance', COUNT(*) FROM attendance
UNION ALL
SELECT 'leaves', COUNT(*) FROM leaves
UNION ALL
SELECT 'holidays', COUNT(*) FROM holidays;

DESCRIBE orders;
SELECT * FROM orders LIMIT 5;

SHOW INDEX FROM attendance;

SELECT 'Charlie Cafe DB setup verified successfully ✅' AS status;
EOF

echo ""
echo "✅ ALL TASKS COMPLETED SUCCESSFULLY ☕"
echo "====================================================="

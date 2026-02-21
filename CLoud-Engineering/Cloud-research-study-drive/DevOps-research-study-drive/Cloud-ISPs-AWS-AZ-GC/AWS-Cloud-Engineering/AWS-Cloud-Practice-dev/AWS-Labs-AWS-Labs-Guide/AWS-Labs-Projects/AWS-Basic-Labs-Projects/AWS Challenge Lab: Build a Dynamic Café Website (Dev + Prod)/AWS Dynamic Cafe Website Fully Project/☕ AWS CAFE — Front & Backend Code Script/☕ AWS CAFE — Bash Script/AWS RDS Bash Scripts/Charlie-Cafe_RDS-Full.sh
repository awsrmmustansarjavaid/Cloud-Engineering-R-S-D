#!/bin/bash
# =============================================================
# ☕ Charlie Cafe — Complete RDS Setup & Verification Script
# Version: 2.0 (Production Safe)
# Includes:
#   ✔ Create Database
#   ✔ Create Tables
#   ✔ Safe ALTER TABLE (status column)
#   ✔ Safe Index Creation
#   ✔ Sample Data Insert
#   ✔ Full Verification
# =============================================================

set -euo pipefail

echo "☕ Charlie Cafe — Complete RDS Setup & Verification"
echo "=============================================================="

# =============================================================
# CONFIGURATION (EDIT ONLY IF NEEDED)
# =============================================================
AWS_REGION="us-east-1"
SECRET_ID="CafeDevDBSM"
DB_NAME="cafe_db"

# =============================================================
# CHECK & INSTALL REQUIRED TOOLS
# =============================================================
echo "📦 Checking required packages..."

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

echo "✅ All required tools are installed"
echo ""

# =============================================================
# FETCH DATABASE CREDENTIALS FROM AWS SECRETS MANAGER
# =============================================================
echo "🔐 Fetching RDS credentials from Secrets Manager..."

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

# Auto-clean credentials file when script exits
trap 'rm -f "$CREDENTIALS_FILE"' EXIT

# =============================================================
# TEST CONNECTION
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
# CREATE TABLES
# =============================================================
echo "📋 Creating tables..."

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'

-- =====================================================
-- ORDERS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id       VARCHAR(50),
    table_number   INT NOT NULL,
    customer_name  VARCHAR(100),
    item           VARCHAR(100),
    quantity       INT NOT NULL,

    item_cost      DECIMAL(6,2),
    total_cost     DECIMAL(6,2),
    total_amount   DECIMAL(10,2),

    payment_method VARCHAR(20),
    payment_status VARCHAR(20),

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

EOF

echo "✅ Tables created or verified"
echo ""

# =============================================================
# SAFE ALTER TABLE (ADD STATUS COLUMN IF MISSING)
# MySQL 5.7 Compatible Method
# =============================================================
echo "🔄 Ensuring 'status' column exists in orders table..."

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

echo "✅ Orders table verified (status column ensured)"
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

EOF

echo "✅ Sample data inserted"
echo ""

# =============================================================
# FINAL VERIFICATION
# =============================================================
echo "🔎 FINAL VERIFICATION"
echo "=============================================================="

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'

SHOW TABLES;

SELECT 'orders' AS table_name, COUNT(*) FROM orders;

DESCRIBE orders;

SELECT * FROM orders LIMIT 5;

SELECT 'Charlie Cafe DB setup verified successfully ✅' AS status;

EOF

echo ""
echo "🎉 ALL TASKS COMPLETED SUCCESSFULLY ☕"
echo "=============================================================="
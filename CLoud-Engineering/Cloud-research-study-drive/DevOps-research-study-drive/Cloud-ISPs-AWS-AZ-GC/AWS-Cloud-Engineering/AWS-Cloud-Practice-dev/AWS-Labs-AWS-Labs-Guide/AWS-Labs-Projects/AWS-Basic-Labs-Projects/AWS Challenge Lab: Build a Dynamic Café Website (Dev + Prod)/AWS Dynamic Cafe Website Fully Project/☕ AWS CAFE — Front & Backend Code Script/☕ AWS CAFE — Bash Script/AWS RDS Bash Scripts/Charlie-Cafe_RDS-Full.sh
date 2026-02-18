#!/bin/bash
set -euo pipefail

echo "☕ Cafe RDS Complete Setup & Verification Script"
echo "=============================================================="

# ============================================================
# CONFIGURATION
# ============================================================
AWS_REGION="us-east-1"
SECRET_ARN="arn:aws:secretsmanager:us-east-1:910599465397:secret:CafeDevDBSM-NSiXdV"
DB_NAME="cafe_db"

# ============================================================
# INSTALL REQUIRED PACKAGES (MariaDB client + jq)
# ============================================================
echo "📦 Checking required packages..."

if ! command -v mysql >/dev/null 2>&1; then
    echo "Installing MariaDB client..."
    sudo dnf install -y mariadb105
fi

if ! command -v jq >/dev/null 2>&1; then
    echo "Installing jq..."
    sudo dnf install -y jq
fi

# Verify AWS CLI exists
if ! command -v aws >/dev/null 2>&1; then
    echo "❌ AWS CLI not found. Install AWS CLI v2 first."
    exit 1
fi

echo "✅ All required tools available"
echo ""

# ============================================================
# FETCH RDS CREDENTIALS FROM SECRETS MANAGER
# ============================================================
echo "🔐 Fetching database credentials..."

SECRET_JSON=$(aws secretsmanager get-secret-value \
    --secret-id "$SECRET_ARN" \
    --region "$AWS_REGION" \
    --query SecretString \
    --output text)

DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host // .endpoint // empty')
DB_USER=$(echo "$SECRET_JSON" | jq -r '.username // empty')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password // empty')
DB_PORT=$(echo "$SECRET_JSON" | jq -r '.port // "3306"')

if [[ -z "$DB_HOST" || -z "$DB_USER" || -z "$DB_PASS" ]]; then
    echo "❌ Secret is missing required fields"
    exit 1
fi

echo "✅ Secret loaded"
echo "RDS Endpoint: $DB_HOST"
echo ""

# ============================================================
# CREATE TEMP MYSQL CREDENTIAL FILE (SECURE)
# ============================================================
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

# ============================================================
# TEST RDS CONNECTION
# ============================================================
echo "🔌 Testing RDS connection..."
mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "SELECT 1" >/dev/null
echo "✅ RDS connection successful"
echo ""

# ============================================================
# CREATE DATABASE
# ============================================================
echo "🗄 Creating database if not exists..."
mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "
CREATE DATABASE IF NOT EXISTS $DB_NAME
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
"
echo "✅ Database ensured"
echo ""

# ============================================================
# CREATE TABLES (FINAL STRUCTURE)
# ============================================================
echo "📋 Creating tables..."

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'

-- =====================================================
-- ORDERS TABLE (WITH PAYMENT + STATUS + TRACKING)
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

echo "✅ Tables created/verified"
echo ""

# ============================================================
# INSERT SAMPLE DATA (SAFE TO RE-RUN)
# ============================================================
echo "🌱 Inserting test data..."

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'
INSERT IGNORE INTO orders (table_number, customer_name, item, quantity, status)
VALUES
(1, 'Ali Khan', 'Espresso', 2, 'RECEIVED'),
(2, 'Sara Ahmed', 'Latte', 1, 'PREPARING');

INSERT IGNORE INTO holidays (holiday_date, description)
VALUES ('2026-01-01', 'New Year');

INSERT IGNORE INTO employees
(cognito_user_id, name, job_title, salary, start_date)
VALUES ('TEMP-ID-001', 'Alice', 'Barista', 40000, '2025-12-01');
EOF

echo "✅ Sample data ensured"
echo ""

# ============================================================
# FINAL VERIFICATION SECTION
# ============================================================
echo "🔎 FINAL VERIFICATION"
echo "=============================================================="

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'

-- Show all tables
SHOW TABLES;

-- Show structure of orders table
DESCRIBE orders;

-- Show indexes
SHOW INDEX FROM orders;

-- Row counts
SELECT 'orders' AS table_name, COUNT(*) FROM orders
UNION ALL
SELECT 'employees', COUNT(*) FROM employees
UNION ALL
SELECT 'attendance', COUNT(*) FROM attendance
UNION ALL
SELECT 'leaves', COUNT(*) FROM leaves
UNION ALL
SELECT 'holidays', COUNT(*) FROM holidays;

-- Sample data preview
SELECT * FROM orders LIMIT 5;

SELECT 'RDS Setup Verification Successful ✅' AS STATUS;

EOF

echo ""
echo "🎉 COMPLETE: RDS, Database, Tables & Data Verified Successfully"
echo "=============================================================="

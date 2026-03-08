#!/bin/bash
# ============================================================
# ☕ CHARLIE CAFE — FULL INFRA + RDS + FRONTEND SETUP
# Amazon Linux 2023
# ============================================================

set -euo pipefail

echo "=============================================================="
echo "☕ CHARLIE CAFE — COMPLETE SETUP"
echo "=============================================================="

# ============================================================
# 🔧 GLOBAL CONFIGURATION (EDIT ONCE)
# ============================================================

AWS_REGION="us-east-1"
SECRET_ID="CafeDevDBSM"
DB_NAME="cafe_db"

S3_BUCKET="charlie-cafe-s3-bucket"
LAYER_S3_KEY="layers/pymysql-layer.zip"

COGNITO_USER_POOL_ID="us-east-1_1wxssmoiqi"
COGNITO_CLIENT_ID="3a4uchovr497k8v3gl52e2j5d8"
COGNITO_DOMAIN="us-east-1wxssmoiqi.auth.us-east-1.amazoncognito.com"

API_BASE="https://a1053skr51.execute-api.us-east-1.amazonaws.com"
CLOUDFRONT_BASE="https://d3lnkgtsj0uwlu.cloudfront.net"

# ============================================================
# 1️⃣ SYSTEM UPDATE
# ============================================================

echo "🔄 Updating system..."
sudo dnf update -y

# ============================================================
# 2️⃣ INSTALL LAMP STACK
# ============================================================

echo "🌐 Installing Apache + PHP..."
sudo dnf install -y httpd php php-mysqlnd php-cli php-common php-mbstring php-xml
sudo systemctl enable httpd
sudo systemctl start httpd

echo "🔐 Fixing permissions..."
sudo chown -R apache:apache /var/www
sudo chmod -R 755 /var/www
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php >/dev/null
sudo systemctl restart httpd

# ============================================================
# 3️⃣ INSTALL REQUIRED TOOLS
# ============================================================

echo "🧰 Installing AWS CLI, jq, MariaDB client, Python..."
sudo dnf install -y awscli jq mariadb105 zip python3 python3-pip

# ============================================================
# 4️⃣ FETCH RDS CREDENTIALS
# ============================================================

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
  echo "❌ Failed to retrieve database credentials"
  exit 1
fi

echo "✅ Credentials loaded"

# ============================================================
# 5️⃣ CREATE SECURE MYSQL CONNECTION FILE
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
# 6️⃣ TEST CONNECTION
# ============================================================

echo "🔌 Testing RDS connection..."
mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "SELECT 1" >/dev/null
echo "✅ RDS connection successful"

# ============================================================
# 7️⃣ CREATE DATABASE
# ============================================================

echo "🗄 Creating database..."
mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "
CREATE DATABASE IF NOT EXISTS $DB_NAME
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;
"

# ============================================================
# 8️⃣ CREATE ALL TABLES
# ============================================================

echo "📋 Creating tables..."

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<'EOF'

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

CREATE TABLE IF NOT EXISTS holidays (
    holiday_id INT AUTO_INCREMENT PRIMARY KEY,
    holiday_date DATE NOT NULL UNIQUE,
    description VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

EOF

echo "✅ Tables created"

# ============================================================
# 9️⃣ INSERT SAMPLE DATA
# ============================================================

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

EOF

echo "✅ Sample data inserted"

# ============================================================
# 🔟 BUILD PYMYSQL LAMBDA LAYER
# ============================================================

echo "📦 Building PyMySQL Lambda Layer..."

BUILD_DIR="lambda-layer"
PYTHON_DIR="$BUILD_DIR/python"
ZIP_FILE="pymysql-layer.zip"

rm -rf "$BUILD_DIR" "$ZIP_FILE"
mkdir -p "$PYTHON_DIR"

pip3 install pymysql -t "$PYTHON_DIR" --no-cache-dir

cd "$BUILD_DIR"
zip -r "../$ZIP_FILE" python >/dev/null
cd ..

aws s3 cp "$ZIP_FILE" "s3://$S3_BUCKET/$LAYER_S3_KEY" --region "$AWS_REGION"

echo "✅ Lambda layer uploaded to S3"

# ============================================================
# 1️⃣1️⃣ CREATE CENTRAL AUTH JS
# ============================================================

echo "🧠 Creating central-auth-api.js..."

sudo mkdir -p /var/www/html/js

sudo tee /var/www/html/js/central-auth-api.js >/dev/null <<EOF
const CHARLIE = (() => {
    const CONFIG = {
        REGION: "${AWS_REGION}",
        USER_POOL_ID: "${COGNITO_USER_POOL_ID}",
        CLIENT_ID: "${COGNITO_CLIENT_ID}",
        COGNITO_DOMAIN: "${COGNITO_DOMAIN}",
        API_BASE: "${API_BASE}",
        CLOUDFRONT_BASE: "${CLOUDFRONT_BASE}"
    };
    return { CONFIG };
})();
EOF

sudo chown apache:apache /var/www/html/js/*
sudo chmod 644 /var/www/html/js/*

# ============================================================
# 🎉 FINAL VERIFICATION
# ============================================================

mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" -e "SHOW TABLES;"

echo ""
echo "=============================================================="
echo "🎉 CHARLIE CAFE FULL SETUP COMPLETED SUCCESSFULLY ☕"
echo "EC2 | Apache | PHP | RDS | HR System | Lambda Layer | Frontend"
echo "=============================================================="

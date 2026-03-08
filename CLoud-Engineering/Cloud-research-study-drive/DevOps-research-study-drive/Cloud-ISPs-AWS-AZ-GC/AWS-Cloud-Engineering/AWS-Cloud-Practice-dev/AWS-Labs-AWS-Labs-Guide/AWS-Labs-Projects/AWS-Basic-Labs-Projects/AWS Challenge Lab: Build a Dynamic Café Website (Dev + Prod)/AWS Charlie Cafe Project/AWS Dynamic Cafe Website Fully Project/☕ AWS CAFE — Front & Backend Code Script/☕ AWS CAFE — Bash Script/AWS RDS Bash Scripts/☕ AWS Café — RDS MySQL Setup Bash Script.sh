#!/bin/bash
set -euo pipefail

echo "☕ Starting Cafe RDS First-Time Setup..."

# ================= CONFIG =================
AWS_REGION="us-east-1"
SECRET_ARN="arn:aws:secretsmanager:us-east-1:910599465397:secret:CafeDevDBSM-NSiXdV"   # ← CHANGE TO YOUR REAL SECRET ARN

DB_NAME="cafe_db"   # Hard-coded for your new cafe setup

# ================= INSTALL REQUIRED PACKAGES =================
echo "📦 Installing MariaDB client & jq if missing..."
sudo dnf install -y mariadb105 jq

# AWS CLI v2 is pre-installed on Amazon Linux 2023 – verify it
if ! command -v aws >/dev/null 2>&1; then
    echo "⚠️ AWS CLI not found (unusual on AL2023) – installing official v2..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install --update
    rm -rf aws awscliv2.zip
fi

aws --version || { echo "❌ AWS CLI failed to run – check installation"; exit 1; }
mysql --version
echo ""

# ================= FETCH SECRET FROM SECRETS MANAGER =================
echo "🔐 Fetching RDS credentials from Secrets Manager..."
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
    echo "❌ ERROR: Missing required fields in secret (host/username/password)"
    exit 1
fi

echo "✅ Secret loaded"
echo "🔗 RDS Endpoint: $DB_HOST"
echo "   Port:       $DB_PORT"
echo "👤 DB User:     $DB_USER"
echo "🗄 Database:     $DB_NAME (creating if not exists)"
echo ""

# ================= CREATE TEMP CREDENTIALS FILE =================
CREDENTIALS_FILE=$(mktemp /tmp/rds-cafe-cred.XXXXXX)
chmod 600 "$CREDENTIALS_FILE"

cat > "$CREDENTIALS_FILE" << EOF
[client]
host=$DB_HOST
port=$DB_PORT
user=$DB_USER
password=$DB_PASS
connect-timeout=10
EOF

trap 'rm -f "$CREDENTIALS_FILE"' EXIT

# ================= TEST CONNECTION =================
echo "🔌 Testing RDS connection..."
if ! mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "SELECT 1" >/dev/null 2>&1; then
    echo "❌ Connection failed. Check:"
    echo "   • Security Group allows 3306 from this EC2"
    echo "   • RDS is in same VPC/subnet or properly peered"
    echo "   • Credentials & endpoint in secret are correct"
    exit 1
fi
echo "✅ Connection OK"
echo ""

# ================= CREATE DATABASE =================
echo "🗄 Creating database '$DB_NAME'..."
mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
echo ""

# ================= CREATE ORDERS TABLE =================
echo "📋 Creating orders table..."
mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<EOF
CREATE TABLE IF NOT EXISTS orders (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    table_number  INT NOT NULL,
    customer_name VARCHAR(100),
    item          VARCHAR(100),
    quantity      INT NOT NULL,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_table_number (table_number),
    INDEX idx_created_at   (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
EOF
echo ""

# ================= VERIFY =================
echo "🔍 Verifying setup..."
mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" -e "
    SHOW TABLES;
    SELECT 'Cafe database ready' AS message;
"
echo ""

echo "✅ Cafe RDS setup completed successfully ☕"
echo "Next steps:"
echo "  - Use database: $DB_NAME"
echo "  - Endpoint:    $DB_HOST"
echo "  - User:        $DB_USER"
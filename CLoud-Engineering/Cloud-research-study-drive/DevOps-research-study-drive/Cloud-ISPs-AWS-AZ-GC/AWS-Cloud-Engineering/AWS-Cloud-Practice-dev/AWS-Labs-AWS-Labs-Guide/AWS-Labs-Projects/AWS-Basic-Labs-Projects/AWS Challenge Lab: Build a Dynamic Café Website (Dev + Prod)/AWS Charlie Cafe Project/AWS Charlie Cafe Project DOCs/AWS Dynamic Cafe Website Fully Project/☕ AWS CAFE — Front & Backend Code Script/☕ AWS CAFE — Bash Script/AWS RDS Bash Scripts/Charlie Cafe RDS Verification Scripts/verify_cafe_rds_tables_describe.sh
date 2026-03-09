#!/bin/bash
# =====================================================
# Cafe RDS Table Structure Verification Script
# - Lists all tables in the database
# - DESCRIBEs each table (like manual MySQL check)
# - Shows row counts for quick validation
# =====================================================

set -e

# ===============================
# CONFIGURATION
# ===============================
SECRET_ID="CafeDevDBSM"
AWS_REGION="us-east-1"
DB_NAME="cafe_db"

echo "🔍 Cafe RDS Table Verification Started"
echo "====================================="

# ===============================
# FETCH DB CREDENTIALS
# ===============================
echo "🔐 Fetching DB credentials from Secrets Manager..."

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_ID" \
  --region "$AWS_REGION" \
  --query SecretString \
  --output text)

DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host')
DB_PORT=$(echo "$SECRET_JSON" | jq -r '.port // 3306')

if [[ -z "$DB_USER" || -z "$DB_PASS" || -z "$DB_HOST" ]]; then
  echo "❌ Failed to load database credentials"
  exit 1
fi

echo "✅ Credentials loaded"
echo "   • Host: $DB_HOST"
echo "   • User: $DB_USER"
echo "   • DB  : $DB_NAME"

# ===============================
# MYSQL SHORTCUT
# ===============================
MYSQL_CMD="mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS $DB_NAME"

# ===============================
# TEST CONNECTION
# ===============================
echo
echo "🔌 Testing database connection..."
$MYSQL_CMD -e "SELECT 1;" >/dev/null
echo "✅ Connection successful"

# ===============================
# SHOW ALL TABLES
# ===============================
echo
echo "📋 Tables in database '$DB_NAME':"
echo "---------------------------------"
$MYSQL_CMD -e "SHOW TABLES;"

# ===============================
# GET TABLE LIST (FOR LOOP)
# ===============================
TABLES=$($MYSQL_CMD -sN -e "SHOW TABLES;")

# ===============================
# DESCRIBE EACH TABLE
# ===============================
for table in $TABLES; do
  echo
  echo "🧾 DESCRIBE TABLE: $table"
  echo "---------------------------------"
  $MYSQL_CMD -e "DESCRIBE $table;"
done

# ===============================
# ROW COUNT PER TABLE
# ===============================
echo
echo "📊 Row count per table:"
echo "---------------------------------"

for table in $TABLES; do
  COUNT=$($MYSQL_CMD -sN -e "SELECT COUNT(*) FROM $table;")
  printf "   • %-12s : %s rows\n" "$table" "$COUNT"
done

# ===============================
# FINAL STATUS
# ===============================
echo
echo "====================================="
echo "🎉 RDS TABLE VERIFICATION COMPLETED"
echo "All tables listed and described ✔"

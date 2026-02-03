#!/bin/bash
# =====================================================
# Charlie Cafe RDS Verification Script (FINAL)
#
# This script performs FULL verification of:
# - AWS Secrets Manager DB credentials
# - RDS connectivity
# - Database existence
# - Required tables
# - Table structure (DESCRIBE)
# - Critical columns
# - Indexes / constraints
# - Row counts
# - Sample data
#
# SAFE SCRIPT:
# ✔ READ-ONLY
# ✔ NO CREATE / ALTER / INSERT
# =====================================================

set -e

# ===============================
# CONFIGURATION
# ===============================
SECRET_ID="CafeDevDBSM"
AWS_REGION="us-east-1"
DB_NAME="cafe_db"

echo "☕ Charlie Cafe RDS Verification Started"
echo "======================================="

# ===============================
# FETCH DB CREDENTIALS
# ===============================
echo "🔐 Fetching DB credentials from AWS Secrets Manager..."

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_ID" \
  --region "$AWS_REGION" \
  --query SecretString \
  --output text)

DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host')
DB_PORT=$(echo "$SECRET_JSON" | jq -r '.port // 3306')

# Validate credentials
if [[ -z "$DB_USER" || -z "$DB_PASS" || -z "$DB_HOST" ]]; then
  echo "❌ Failed to load database credentials"
  exit 1
fi

echo "✅ Credentials loaded"
echo "   • Host: $DB_HOST"
echo "   • Port: $DB_PORT"
echo "   • User: $DB_USER"
echo "   • DB  : $DB_NAME"

# ===============================
# MYSQL COMMAND SHORTCUT
# -sN = silent + no column names
# ===============================
MYSQL_BASE="mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS"
MYSQL_DB="$MYSQL_BASE $DB_NAME"
MYSQL_SILENT="$MYSQL_DB -sN"

# ===============================
# TEST DATABASE CONNECTION
# ===============================
echo
echo "🔌 Testing database connection..."
$MYSQL_DB -e "SELECT 1;" >/dev/null
echo "✅ Database connection successful"

# ===============================
# VERIFY DATABASE EXISTS
# ===============================
echo
echo "🗄 Verifying database exists..."

$MYSQL_BASE -e "SHOW DATABASES LIKE '$DB_NAME';" | grep "$DB_NAME" >/dev/null \
  && echo "✅ Database '$DB_NAME' exists" \
  || { echo "❌ Database '$DB_NAME' NOT FOUND"; exit 1; }

# ===============================
# VERIFY REQUIRED TABLES
# ===============================
echo
echo "📋 Verifying required tables..."

REQUIRED_TABLES=("orders" "employees" "attendance" "leaves" "holidays")

for table in "${REQUIRED_TABLES[@]}"; do
  if $MYSQL_SILENT -e "SHOW TABLES LIKE '$table';" | grep "$table" >/dev/null; then
    echo "✅ Table exists: $table"
  else
    echo "❌ Missing table: $table"
    exit 1
  fi
done

# ===============================
# LIST ALL TABLES
# ===============================
echo
echo "📦 All tables in '$DB_NAME':"
echo "---------------------------------"
$MYSQL_DB -e "SHOW TABLES;"

# ===============================
# DESCRIBE EACH TABLE
# ===============================
echo
echo "🧾 Table structure verification (DESCRIBE):"

TABLES=$($MYSQL_SILENT -e "SHOW TABLES;")

for table in $TABLES; do
  echo
  echo "🔍 DESCRIBE $table"
  echo "---------------------------------"
  $MYSQL_DB -e "DESCRIBE $table;"
done

# ===============================
# VERIFY CRITICAL COLUMNS
# ===============================
echo
echo "🧱 Verifying critical columns..."

# orders table
$MYSQL_SILENT -e "SHOW COLUMNS FROM orders LIKE 'table_number';" | grep table_number >/dev/null \
  || { echo "❌ orders.table_number missing"; exit 1; }

$MYSQL_SILENT -e "SHOW COLUMNS FROM orders LIKE 'item_cost';" | grep item_cost >/dev/null \
  || { echo "❌ orders.item_cost missing"; exit 1; }

$MYSQL_SILENT -e "SHOW COLUMNS FROM orders LIKE 'total_cost';" | grep total_cost >/dev/null \
  || { echo "❌ orders.total_cost missing"; exit 1; }

echo "✅ Orders table critical columns OK"

# attendance table
$MYSQL_SILENT -e "SHOW COLUMNS FROM attendance LIKE 'attendance_date';" | grep attendance_date >/dev/null \
  || { echo "❌ attendance.attendance_date missing"; exit 1; }

echo "✅ Attendance table critical columns OK"

# ===============================
# VERIFY INDEXES / CONSTRAINTS
# ===============================
echo
echo "📈 Verifying indexes & constraints..."

# orders.table_number index
$MYSQL_DB -e "SHOW INDEX FROM orders WHERE Key_name='idx_table_number';" | grep idx_table_number >/dev/null \
  && echo "✅ idx_table_number exists (orders)" \
  || echo "⚠️ idx_table_number not found (optional)"

# attendance unique constraint (employee_id + attendance_date)
$MYSQL_DB -e "SHOW INDEX FROM attendance;" | grep employee_id >/dev/null \
  && echo "✅ Attendance unique/index constraint exists" \
  || echo "⚠️ Attendance constraint missing"

# ===============================
# ROW COUNTS PER TABLE
# ===============================
echo
echo "📊 Row count per table:"
echo "---------------------------------"

for table in $TABLES; do
  COUNT=$($MYSQL_SILENT -e "SELECT COUNT(*) FROM $table;")
  printf "   • %-12s : %s rows\n" "$table" "$COUNT"
done

# ===============================
# SAMPLE DATA OUTPUT
# ===============================
echo
echo "🧪 Sample order record:"
$MYSQL_DB -e "SELECT id, table_number, item, quantity, created_at FROM orders LIMIT 1;"

# ===============================
# FINAL STATUS
# ===============================
echo
echo "======================================="
echo "🎉 CHARLIE CAFE RDS VERIFICATION COMPLETE"
echo "All critical checks passed ✔"

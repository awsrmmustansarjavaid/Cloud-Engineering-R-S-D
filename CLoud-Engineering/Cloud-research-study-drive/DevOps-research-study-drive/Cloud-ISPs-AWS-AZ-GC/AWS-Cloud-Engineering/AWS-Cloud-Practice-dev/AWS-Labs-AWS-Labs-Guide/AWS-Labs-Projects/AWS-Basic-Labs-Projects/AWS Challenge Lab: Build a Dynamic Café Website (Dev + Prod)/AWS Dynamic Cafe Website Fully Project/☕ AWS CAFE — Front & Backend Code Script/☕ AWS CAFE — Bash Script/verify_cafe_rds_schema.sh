#!/bin/bash
# =====================================================
# Cafe RDS Verification Script
# Verifies DB, tables, columns, indexes & test data
# =====================================================

set -e

# ===============================
# CONFIG
# ===============================
SECRET_ID="CafeDevDBSM"
AWS_REGION="us-east-1"
DB_NAME="cafe_db"

echo "🔍 Starting Cafe RDS Verification..."
echo "------------------------------------"

# ===============================
# FETCH SECRET
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
  echo "❌ Failed to load DB credentials"
  exit 1
fi

echo "✅ Credentials loaded"
echo "   • Host: $DB_HOST"
echo "   • User: $DB_USER"
echo "   • DB  : $DB_NAME"

# ===============================
# MYSQL COMMAND SHORTCUT
# ===============================
MYSQL_CMD="mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS $DB_NAME -sN"

# ===============================
# TEST CONNECTION
# ===============================
echo "🔌 Testing DB connection..."
$MYSQL_CMD -e "SELECT 1;" >/dev/null
echo "✅ Database connection OK"

# ===============================
# VERIFY DATABASE
# ===============================
echo "🗄 Verifying database exists..."
mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASS" -e "SHOW DATABASES LIKE '$DB_NAME';" | grep "$DB_NAME" >/dev/null \
  && echo "✅ Database '$DB_NAME' exists" \
  || { echo "❌ Database missing"; exit 1; }

# ===============================
# VERIFY TABLES
# ===============================
echo "📋 Verifying required tables..."

REQUIRED_TABLES=("orders" "employees" "attendance" "leaves" "holidays")

for table in "${REQUIRED_TABLES[@]}"; do
  if $MYSQL_CMD -e "SHOW TABLES LIKE '$table';" | grep "$table" >/dev/null; then
    echo "✅ Table exists: $table"
  else
    echo "❌ Missing table: $table"
    exit 1
  fi
done

# ===============================
# VERIFY COLUMNS (CRITICAL)
# ===============================
echo "🧱 Verifying critical columns..."

# orders table
$MYSQL_CMD -e "SHOW COLUMNS FROM orders LIKE 'table_number';" | grep table_number >/dev/null || { echo "❌ orders.table_number missing"; exit 1; }
$MYSQL_CMD -e "SHOW COLUMNS FROM orders LIKE 'item_cost';" | grep item_cost >/dev/null || { echo "❌ orders.item_cost missing"; exit 1; }
$MYSQL_CMD -e "SHOW COLUMNS FROM orders LIKE 'total_cost';" | grep total_cost >/dev/null || { echo "❌ orders.total_cost missing"; exit 1; }

echo "✅ Orders table columns OK"

# attendance table
$MYSQL_CMD -e "SHOW COLUMNS FROM attendance LIKE 'attendance_date';" | grep attendance_date >/dev/null || { echo "❌ attendance.attendance_date missing"; exit 1; }

echo "✅ Attendance table columns OK"

# ===============================
# VERIFY INDEXES
# ===============================
echo "📈 Verifying indexes..."

# orders.table_number index
$MYSQL_CMD -e "SHOW INDEX FROM orders WHERE Key_name='idx_table_number';" | grep idx_table_number >/dev/null \
  && echo "✅ idx_table_number exists" \
  || echo "⚠️ idx_table_number not found (optional)"

# attendance unique constraint
$MYSQL_CMD -e "SHOW INDEX FROM attendance WHERE Key_name='employee_id';" | grep employee_id >/dev/null \
  && echo "✅ Attendance unique constraint exists" \
  || echo "⚠️ Attendance unique constraint missing"

# ===============================
# VERIFY DATA COUNTS
# ===============================
echo "📊 Verifying test data..."

EMP_COUNT=$($MYSQL_CMD -e "SELECT COUNT(*) FROM employees;")
ORDERS_COUNT=$($MYSQL_CMD -e "SELECT COUNT(*) FROM orders;")
HOLIDAY_COUNT=$($MYSQL_CMD -e "SELECT COUNT(*) FROM holidays;")

echo "   • Employees : $EMP_COUNT"
echo "   • Orders    : $ORDERS_COUNT"
echo "   • Holidays  : $HOLIDAY_COUNT"

if [[ "$ORDERS_COUNT" -gt 0 ]]; then
  echo "✅ Orders test data present"
else
  echo "⚠️ Orders table empty"
fi

# ===============================
# SAMPLE ROW OUTPUT
# ===============================
echo "🧪 Sample order record:"
$MYSQL_CMD -e "SELECT id, table_number, item, quantity, created_at FROM orders LIMIT 1;"

# ===============================
# FINAL STATUS
# ===============================
echo "------------------------------------"
echo "🎉 RDS VERIFICATION COMPLETED SUCCESSFULLY"
echo "All critical checks passed ✔"

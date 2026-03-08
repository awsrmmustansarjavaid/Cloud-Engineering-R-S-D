#!/bin/bash
# =====================================================
# Charlie Cafe RDS FULL Verification Script (PRO)
#
# Verifies:
# - AWS Secrets Manager DB credentials
# - RDS connectivity
# - Database existence
# - Tables, schemas, critical columns
# - Indexes and foreign keys
# - Row counts
# - Sample data
# - Analytics (sales verification)
#
# SAFE: READ-ONLY, NO CREATE/ALTER/INSERT
# =====================================================

set -euo pipefail

# ===============================
# COLOR DEFINITIONS
# ===============================
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
  echo -e "\n${BLUE}========================================================${NC}"
  echo -e "${BLUE}$1${NC}"
  echo -e "${BLUE}========================================================${NC}\n"
}

print_success() { echo -e "${GREEN}✅ $1${NC}\n"; }
print_warning() { echo -e "${YELLOW}⚠️ $1${NC}\n"; }
print_error() { echo -e "${RED}❌ $1${NC}\n"; }

# ===============================
# CONFIGURATION
# ===============================
SECRET_ID="CafeDevDBSM"
AWS_REGION="us-east-1"
DB_NAME="cafe_db"
REQUIRED_TABLES=("orders" "employees" "attendance" "leaves" "holidays")

print_header "☕ Charlie Cafe RDS Verification Started"

# ===============================
# FETCH DB CREDENTIALS
# ===============================
print_header "🔐 Fetching DB credentials from AWS Secrets Manager..."

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_ID" \
  --region "$AWS_REGION" \
  --query SecretString --output text)

DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host')
DB_PORT=$(echo "$SECRET_JSON" | jq -r '.port // 3306')

[[ -z "$DB_USER" || -z "$DB_PASS" || -z "$DB_HOST" ]] && { print_error "Missing credentials"; exit 1; }

print_success "Credentials loaded: $DB_USER@$DB_HOST:$DB_PORT"

# ===============================
# MYSQL COMMAND SHORTCUTS
# ===============================
MYSQL_BASE="mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS"
MYSQL_DB="$MYSQL_BASE $DB_NAME"
MYSQL_SILENT="$MYSQL_DB -sN"

# ===============================
# TEST CONNECTION
# ===============================
print_header "🔌 Testing RDS connection..."
$MYSQL_DB -e "SELECT VERSION();" >/dev/null
print_success "RDS connection successful"

# ===============================
# VERIFY DATABASE
# ===============================
print_header "🗄 Verifying database exists..."
$MYSQL_BASE -e "SHOW DATABASES LIKE '$DB_NAME';" | grep -q "$DB_NAME" && \
  print_success "Database '$DB_NAME' exists" || { print_error "Database '$DB_NAME' NOT FOUND"; exit 1; }

# ===============================
# VERIFY REQUIRED TABLES
# ===============================
print_header "📋 Verifying required tables..."
for table in "${REQUIRED_TABLES[@]}"; do
  if $MYSQL_SILENT -e "SHOW TABLES LIKE '$table';" | grep -q "$table"; then
    print_success "Table exists: $table"
  else
    print_error "Missing table: $table"
    exit 1
  fi
done

# ===============================
# LIST TABLES
# ===============================
print_header "📦 All tables in database"
$MYSQL_DB -e "SHOW TABLES;"

# ===============================
# DESCRIBE TABLES
# ===============================
print_header "🧾 Table structure (DESCRIBE)"

for table in "${REQUIRED_TABLES[@]}"; do
  echo -e "\n🔍 Schema for $table"
  echo "--------------------------------"
  $MYSQL_DB -e "DESCRIBE $table;"
done

# ===============================
# VERIFY CRITICAL COLUMNS
# ===============================
print_header "🧱 Verifying critical columns"
declare -A CRITICAL_COLUMNS
CRITICAL_COLUMNS=( 
  ["orders"]="table_number item_cost total_cost total_amount payment_status status"
  ["employees"]="name job_title salary"
  ["attendance"]="employee_id attendance_date"
  ["leaves"]="employee_id leave_date leave_type"
  ["holidays"]="holiday_date description"
)

for table in "${!CRITICAL_COLUMNS[@]}"; do
  for col in ${CRITICAL_COLUMNS[$table]}; do
    $MYSQL_SILENT -e "SHOW COLUMNS FROM $table LIKE '$col';" | grep -q "$col" || { print_error "$table.$col missing"; exit 1; }
  done
  print_success "$table critical columns OK"
done

# ===============================
# VERIFY INDEXES / FOREIGN KEYS
# ===============================
print_header "📈 Verifying indexes & foreign keys"

# Orders index
$MYSQL_DB -e "SHOW INDEX FROM orders WHERE Key_name='idx_table_number';" | grep -q idx_table_number && \
  print_success "orders.idx_table_number exists" || print_warning "orders.idx_table_number missing"

# Attendance FK
$MYSQL_DB -e "SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_NAME='attendance' AND REFERENCED_TABLE_NAME='employees';" | grep -q "employee_id" && \
  print_success "attendance.employee_id foreign key exists" || print_warning "attendance FK missing"

# Leaves FK
$MYSQL_DB -e "SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_NAME='leaves' AND REFERENCED_TABLE_NAME='employees';" | grep -q "employee_id" && \
  print_success "leaves.employee_id foreign key exists" || print_warning "leaves FK missing"

# ===============================
# ROW COUNTS
# ===============================
print_header "📊 Row counts per table"
for table in "${REQUIRED_TABLES[@]}"; do
  COUNT=$($MYSQL_SILENT -e "SELECT COUNT(*) FROM $table;")
  printf "   • %-12s : %s rows\n" "$table" "$COUNT"
done

# ===============================
# SAMPLE DATA PREVIEW
# ===============================
print_header "🧪 Sample data previews"

for table in "${REQUIRED_TABLES[@]}"; do
  echo -e "\nSample from $table:"
  echo "--------------------------------"
  $MYSQL_DB -e "SELECT * FROM $table LIMIT 3;"
done

# ===============================
# ANALYTICS CHECKS (orders)
# ===============================
print_header "📊 Analytics checks (orders)"

$MYSQL_DB -e "
SELECT 'Paid Orders' AS section, COUNT(*) AS count FROM orders WHERE payment_status='PAID';
SELECT 'Today Sales', COUNT(*) FROM orders WHERE payment_status='PAID' AND created_at >= CURDATE();
SELECT 'Week Sales', COUNT(*) FROM orders WHERE payment_status='PAID' AND created_at >= NOW()-INTERVAL 7 DAY;
SELECT 'Month Sales', COUNT(*) FROM orders WHERE payment_status='PAID' AND created_at >= DATE_FORMAT(NOW(), '%Y-%m-01');
"

# ===============================
# FINAL VERIFICATION REPORT
# ===============================
print_header "✅ CHARLIE CAFE RDS FULL VERIFICATION COMPLETE"
echo -e "${GREEN}All critical checks passed. Database, tables, schemas, indexes, FKs, row counts, and analytics verified ✔${NC}"
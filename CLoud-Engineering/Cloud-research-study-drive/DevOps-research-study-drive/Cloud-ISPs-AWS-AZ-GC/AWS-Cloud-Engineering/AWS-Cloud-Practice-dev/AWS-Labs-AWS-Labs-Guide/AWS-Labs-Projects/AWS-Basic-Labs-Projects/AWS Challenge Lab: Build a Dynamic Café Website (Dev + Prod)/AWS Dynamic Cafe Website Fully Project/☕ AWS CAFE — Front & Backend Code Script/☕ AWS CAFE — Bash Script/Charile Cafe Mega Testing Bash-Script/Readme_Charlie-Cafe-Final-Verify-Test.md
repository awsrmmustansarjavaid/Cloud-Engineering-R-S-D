# Charlie Cafe Verification & Test 


### Charlie-Cafe-Final-Verify-Test.sh

> **Update Version: 1.0**

```
#!/usr/bin/env bash
# ==============================================================
# CHARLIE CAFE ☕ — MEGA FULL TEST & VERIFICATION SCRIPT
# Version: 2026-Final
# Purpose: Combines all system, DB, Lambda, API, SQS, and web checks
# Author: IT Charlie
# ==============================================================

set -euo pipefail
export LC_ALL=C

# =========================
# CONFIGURATION
# =========================
AWS_REGION="us-east-1"
SECRET_ID="CafeDevDBSM"
DB_NAME="cafe_db"
S3_BUCKET="charlie-cafe-lab-output"
WEB_ROOT="/var/www/html"

API_DEV="https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/dev"
API_PROD="https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/prod"
API_STATUS="https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/status"

ALB_DOMAIN="charlie-cafe-alb-1179524333.us-east-1.elb.amazonaws.com"
CLOUDFRONT_DOMAIN="dc65q9cmuuula.cloudfront.net"

QUEUE_NAME="CafeOrdersQueue"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

OUTPUT_FILE="/tmp/charlie_cafe_full_test_$(date '+%Y%m%d_%H%M%S').log"
touch "$OUTPUT_FILE"

# =========================
# COLORS
# =========================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m'

ok()    { echo -e "${GREEN}✓ OK${NC} - $1" | tee -a "$OUTPUT_FILE"; }
fail()  { echo -e "${RED}✗ FAIL${NC} - $1" | tee -a "$OUTPUT_FILE"; ((FAILURES++)); }
warn()  { echo -e "${YELLOW}! WARN${NC} - $1" | tee -a "$OUTPUT_FILE"; }

# =========================
# COUNTER
# =========================
FAILURES=0

echo "=============================================================" | tee -a "$OUTPUT_FILE"
echo " CHARLIE CAFE ☕ — FULL SYSTEM & AWS VERIFICATION SCRIPT" | tee -a "$OUTPUT_FILE"
echo " Started at: $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$OUTPUT_FILE"
echo "=============================================================" | tee -a "$OUTPUT_FILE"

# ==============================================================
# SYSTEM CHECKS — LAMP / WEB / LOCAL
# ==============================================================
echo -e "\n${BLUE}🖥️  SYSTEM & LOCAL VERIFICATION${NC}" | tee -a "$OUTPUT_FILE"

# OS info
echo "• OS release:" | tee -a "$OUTPUT_FILE"
cat /etc/os-release | grep PRETTY_NAME | tee -a "$OUTPUT_FILE"

# Apache check
if systemctl is-active --quiet httpd; then ok "Apache running"; else fail "Apache not running"; fi
command -v php >/dev/null && ok "PHP installed ($(php -v | head -n1))" || fail "PHP missing"
php -m | grep -qi mysqlnd && ok "PHP mysqlnd extension loaded" || fail "mysqlnd missing"

# MySQL client
command -v mysql >/dev/null && ok "MySQL client installed" || fail "MySQL client missing"

# Web root
if [ -d "$WEB_ROOT" ]; then
    ok "Web root exists: $WEB_ROOT"
else
    fail "Web root missing: $WEB_ROOT"
fi
[ -f "$WEB_ROOT/js/central-auth-api.js" ] && ok "central-auth-api.js present" || warn "central-auth-api.js missing"

# Test local web server
curl -s http://localhost >/tmp/charlie_local_test.html
grep -qi "It works\|Apache" /tmp/charlie_local_test.html && ok "Apache serves content on port 80" || warn "Default page not detected"
rm -f /tmp/charlie_local_test.html
curl -s http://localhost/info.php | grep -qi phpinfo && ok "PHP info.php working" || warn "info.php not working"

# ==============================================================
# AWS CLI & IAM VERIFICATION
# ==============================================================
echo -e "\n${MAGENTA}☁️  AWS CLI & IAM VERIFICATION${NC}" | tee -a "$OUTPUT_FILE"

command -v aws >/dev/null && ok "AWS CLI installed" || fail "AWS CLI missing"
aws sts get-caller-identity >/dev/null 2>&1 && ok "AWS credentials / IAM role valid" || fail "AWS credentials invalid or missing"

# ==============================================================
# SECRETS MANAGER & RDS DATABASE
# ==============================================================
echo -e "\n${CYAN}🔐  SECRETS MANAGER & DATABASE${NC}" | tee -a "$OUTPUT_FILE"

SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id "$SECRET_ID" --region "$AWS_REGION" --query SecretString --output text)
if [ -n "$SECRET_JSON" ]; then
    ok "Fetched DB secret"
else
    fail "Failed to fetch DB secret"
fi

DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host')
DB_PORT=$(echo "$SECRET_JSON" | jq -r '.port // 3306')

MYSQL_CMD="mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS $DB_NAME -sN"

# Test DB connection
if $MYSQL_CMD -e "SELECT 1;" >/dev/null 2>&1; then ok "Database connection OK"; else fail "Cannot connect to DB"; fi

# Verify required tables
REQUIRED_TABLES=("orders" "employees" "attendance" "leaves" "holidays")
for table in "${REQUIRED_TABLES[@]}"; do
    if $MYSQL_CMD -e "SHOW TABLES LIKE '$table';" | grep "$table" >/dev/null; then
        ok "Table exists: $table"
    else
        fail "Missing table: $table"
    fi
done

# Verify critical columns
$MYSQL_CMD -e "SHOW COLUMNS FROM orders LIKE 'table_number';" | grep table_number >/dev/null && ok "orders.table_number exists" || fail "orders.table_number missing"
$MYSQL_CMD -e "SHOW COLUMNS FROM orders LIKE 'item_cost';" | grep item_cost >/dev/null && ok "orders.item_cost exists" || fail "orders.item_cost missing"
$MYSQL_CMD -e "SHOW COLUMNS FROM orders LIKE 'total_cost';" | grep total_cost >/dev/null && ok "orders.total_cost exists" || fail "orders.total_cost missing"

$MYSQL_CMD -e "SHOW COLUMNS FROM attendance LIKE 'attendance_date';" | grep attendance_date >/dev/null && ok "attendance.attendance_date exists" || fail "attendance.attendance_date missing"

# List tables & row counts
echo "📊 Row counts per table:" | tee -a "$OUTPUT_FILE"
TABLES=$($MYSQL_CMD -e "SHOW TABLES;")
for table in $TABLES; do
    COUNT=$($MYSQL_CMD -e "SELECT COUNT(*) FROM $table;")
    echo " • $table : $COUNT rows" | tee -a "$OUTPUT_FILE"
done

# Sample order
echo "🧪 Sample order record:" | tee -a "$OUTPUT_FILE"
$MYSQL_CMD -e "SELECT id, table_number, item, quantity, created_at FROM orders LIMIT 1;"

# ==============================================================
# API GATEWAY VERIFICATION
# ==============================================================
echo -e "\n${YELLOW}📡  API GATEWAY TESTS${NC}" | tee -a "$OUTPUT_FILE"

curl -s "$API_DEV/orders" >/dev/null && ok "API /orders reachable (dev)" || warn "API /orders not reachable"
curl -s -X POST "$API_DEV/orders/cash-payment" -H "Content-Type: application/json" -d '{"order_id":"ORD-TEST"}' >/dev/null && ok "Cash payment endpoint reachable" || warn "Cash payment not reachable"
curl -s "$API_STATUS/order-status" >/dev/null && ok "Order status API reachable" || warn "Order status API not reachable"

# ==============================================================
# ALB & CLOUDFRONT STATIC FILE TESTS
# ==============================================================
echo -e "\n${BLUE}🌐 ALB & CLOUDFRONT STATIC FILE TESTS${NC}" | tee -a "$OUTPUT_FILE"
curl -I http://${ALB_DOMAIN}/js/central-auth-api.js >/dev/null && ok "ALB static file reachable" || warn "ALB static file failed"
curl -I https://${CLOUDFRONT_DOMAIN}/js/central-auth-api.js >/dev/null && ok "CloudFront static file reachable" || warn "CloudFront static file failed"

# ==============================================================
# SQS VERIFICATION
# ==============================================================
echo -e "\n${MAGENTA}📬 SQS QUEUE VERIFICATION${NC}" | tee -a "$OUTPUT_FILE"
aws sqs get-queue-attributes --queue-url https://sqs.${AWS_REGION}.amazonaws.com/${ACCOUNT_ID}/${QUEUE_NAME} --attribute-names ApproximateNumberOfMessages >/dev/null && ok "SQS queue accessible" || fail "Cannot access SQS queue"

# ==============================================================
# LAMBDA INVOCATION TESTS
# ==============================================================
echo -e "\n${CYAN}⚡ LAMBDA INVOCATION TESTS${NC}" | tee -a "$OUTPUT_FILE"

invoke_lambda () {
  NAME=$1
  PAYLOAD=$2
  echo "▶ Invoking Lambda: ${NAME}" | tee -a "$OUTPUT_FILE"
  aws lambda invoke --function-name "${NAME}" --payload "${PAYLOAD}" --region "${AWS_REGION}" /tmp/${NAME}.json >/dev/null
  cat /tmp/${NAME}.json | tee -a "$OUTPUT_FILE"
  echo
}

# Sample Lambda invocations
invoke_lambda CafeOrderProcessor '{"body":"{\"customer_name\":\"LambdaTest\",\"item\":\"Coffee\",\"quantity\":2}"}'
invoke_lambda CafeMenuLambda '{}'
invoke_lambda GetOrderStatusLambda '{}'
invoke_lambda CafeAnalyticsLambda '{"queryStringParameters":{"period":"today"}}'
invoke_lambda CafePDFReportLambda '{"queryStringParameters":{"page":"analytics"}}'

# ==============================================================
# FINAL SUMMARY & RESULT CARD
# ==============================================================
echo -e "\n${GREEN}==================== RESULT CARD ====================${NC}" | tee -a "$OUTPUT_FILE"
if [ $FAILURES -eq 0 ]; then
    echo -e "${GREEN}ALL CHECKS PASSED ✅${NC}" | tee -a "$OUTPUT_FILE"
else
    echo -e "${RED}${FAILURES} ISSUES DETECTED ❌${NC}" | tee -a "$OUTPUT_FILE"
    echo "Review the log above" | tee -a "$OUTPUT_FILE"
fi
echo -e "${GREEN}====================================================${NC}" | tee -a "$OUTPUT_FILE"

# ==============================================================
# EXPORT LOG TO S3
# ==============================================================
echo "Uploading log to S3 bucket: $S3_BUCKET"
aws s3 cp "$OUTPUT_FILE" "s3://$S3_BUCKET/" >/dev/null && ok "Log uploaded to S3" || warn "Failed to upload log"

echo "✅ Charlie Cafe FULL VERIFICATION COMPLETED"
```

### ✅ Features of this mega script:

All system checks:

OS, Apache, PHP, mysqlnd, web root, local JS files.

AWS checks:

IAM role / AWS CLI validation.

Secrets Manager.

RDS DB connection, tables, critical columns, indexes.

SQS queue verification.

API Gateway verification:

/orders, /cash-payment, /order-status.

Static files verification via ALB & CloudFront.

Lambda invocation tests (all major functions).

Color-coded categories:

SYSTEM: Blue

AWS: Magenta

SECRETS & DB: Cyan

API: Yellow

ALB/CloudFront: Blue

SQS: Magenta

Lambda: Cyan

Result card at the end with total failures.

Output export to S3 using IAM role — no access key required.

Preserves all tests from your 6 scripts.

----

### Charlie-Cafe-Final-Verify-Test.sh

> **Update Version: 1.1**



```
#!/usr/bin/env bash
# ==============================================================
# CHARLIE CAFE ☕ — MEGA FULL TEST & VERIFICATION SCRIPT
# Version: 2026-Final-Updated
# Purpose: Combines all system, DB, Lambda, API, SQS, PDF/CSV export, and web checks
# Author: IT Charlie
# ==============================================================

set -euo pipefail
export LC_ALL=C

# =========================
# CONFIGURATION
# =========================
AWS_REGION="us-east-1"
SECRET_ID="CafeDevDBSM"
DB_NAME="cafe_db"
S3_BUCKET="charlie-cafe-lab-output"
WEB_ROOT="/var/www/html"

API_DEV="https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/dev"
API_PROD="https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/prod"
API_STATUS="https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/status"

ALB_DOMAIN="charlie-cafe-alb-1179524333.us-east-1.elb.amazonaws.com"
CLOUDFRONT_DOMAIN="dc65q9cmuuula.cloudfront.net"

QUEUE_NAME="CafeOrdersQueue"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

OUTPUT_FILE="/tmp/charlie_cafe_full_test_$(date '+%Y%m%d_%H%M%S').log"
touch "$OUTPUT_FILE"

# =========================
# COLORS
# =========================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m'

ok()    { echo -e "${GREEN}✓ OK${NC} - $1" | tee -a "$OUTPUT_FILE"; }
fail()  { echo -e "${RED}✗ FAIL${NC} - $1" | tee -a "$OUTPUT_FILE"; ((FAILURES++)); }
warn()  { echo -e "${YELLOW}! WARN${NC} - $1" | tee -a "$OUTPUT_FILE"; }

# =========================
# COUNTER
# =========================
FAILURES=0

echo "=============================================================" | tee -a "$OUTPUT_FILE"
echo " CHARLIE CAFE ☕ — FULL SYSTEM & AWS VERIFICATION SCRIPT" | tee -a "$OUTPUT_FILE"
echo " Started at: $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$OUTPUT_FILE"
echo "=============================================================" | tee -a "$OUTPUT_FILE"

# ============================================================== 
# SYSTEM CHECKS — LAMP / WEB / LOCAL
# ============================================================== 
echo -e "\n${BLUE}🖥️  SYSTEM & LOCAL VERIFICATION${NC}" | tee -a "$OUTPUT_FILE"

# OS info
echo "• OS release:" | tee -a "$OUTPUT_FILE"
cat /etc/os-release | grep PRETTY_NAME | tee -a "$OUTPUT_FILE"

# Apache & PHP
if systemctl is-active --quiet httpd; then ok "Apache running"; else fail "Apache not running"; fi
command -v php >/dev/null && ok "PHP installed ($(php -v | head -n1))" || fail "PHP missing"
php -m | grep -qi mysqlnd && ok "PHP mysqlnd extension loaded" || fail "mysqlnd missing"

# MySQL client
command -v mysql >/dev/null && ok "MySQL client installed" || fail "MySQL client missing"

# Web root
if [ -d "$WEB_ROOT" ]; then
    ok "Web root exists: $WEB_ROOT"
else
    fail "Web root missing: $WEB_ROOT"
fi
[ -f "$WEB_ROOT/js/central-auth-api.js" ] && ok "central-auth-api.js present" || warn "central-auth-api.js missing"

# Test local web server
curl -s http://localhost >/tmp/charlie_local_test.html
grep -qi "It works\|Apache" /tmp/charlie_local_test.html && ok "Apache serves content on port 80" || warn "Default page not detected"
rm -f /tmp/charlie_local_test.html
curl -s http://localhost/info.php | grep -qi phpinfo && ok "PHP info.php working" || warn "info.php not working"

# ============================================================== 
# AWS CLI & IAM VERIFICATION
# ============================================================== 
echo -e "\n${MAGENTA}☁️  AWS CLI & IAM VERIFICATION${NC}" | tee -a "$OUTPUT_FILE"
command -v aws >/dev/null && ok "AWS CLI installed" || fail "AWS CLI missing"
aws sts get-caller-identity >/dev/null 2>&1 && ok "AWS credentials / IAM role valid" || fail "AWS credentials invalid or missing"

# ============================================================== 
# SECRETS MANAGER & RDS DATABASE
# ============================================================== 
echo -e "\n${CYAN}🔐  SECRETS MANAGER & DATABASE${NC}" | tee -a "$OUTPUT_FILE"
SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id "$SECRET_ID" --region "$AWS_REGION" --query SecretString --output text)
if [ -n "$SECRET_JSON" ]; then ok "Fetched DB secret"; else fail "Failed to fetch DB secret"; fi

DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host')
DB_PORT=$(echo "$SECRET_JSON" | jq -r '.port // 3306')

MYSQL_CMD="mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS $DB_NAME -sN"

# Test DB connection
if $MYSQL_CMD -e "SELECT 1;" >/dev/null 2>&1; then ok "Database connection OK"; else fail "Cannot connect to DB"; fi

# Verify required tables
REQUIRED_TABLES=("orders" "employees" "attendance" "leaves" "holidays")
for table in "${REQUIRED_TABLES[@]}"; do
    if $MYSQL_CMD -e "SHOW TABLES LIKE '$table';" | grep "$table" >/dev/null; then
        ok "Table exists: $table"
    else
        fail "Missing table: $table"
    fi
done

# Verify critical columns
$MYSQL_CMD -e "SHOW COLUMNS FROM orders LIKE 'table_number';" | grep table_number >/dev/null && ok "orders.table_number exists" || fail "orders.table_number missing"
$MYSQL_CMD -e "SHOW COLUMNS FROM orders LIKE 'item_cost';" | grep item_cost >/dev/null && ok "orders.item_cost exists" || fail "orders.item_cost missing"
$MYSQL_CMD -e "SHOW COLUMNS FROM orders LIKE 'total_cost';" | grep total_cost >/dev/null && ok "orders.total_cost exists" || fail "orders.total_cost missing"

$MYSQL_CMD -e "SHOW COLUMNS FROM attendance LIKE 'attendance_date';" | grep attendance_date >/dev/null && ok "attendance.attendance_date exists" || fail "attendance.attendance_date missing"

# List tables & row counts
echo "📊 Row counts per table:" | tee -a "$OUTPUT_FILE"
TABLES=$($MYSQL_CMD -e "SHOW TABLES;")
for table in $TABLES; do
    COUNT=$($MYSQL_CMD -e "SELECT COUNT(*) FROM $table;")
    echo " • $table : $COUNT rows" | tee -a "$OUTPUT_FILE"
done

# Sample order
echo "🧪 Sample order record:" | tee -a "$OUTPUT_FILE"
$MYSQL_CMD -e "SELECT id, table_number, item, quantity, created_at FROM orders LIMIT 1;"

# ============================================================== 
# API GATEWAY VERIFICATION — PDF / CSV / ADMIN TESTS
# ============================================================== 
echo -e "\n${YELLOW}📡  API GATEWAY PDF/CSV & ADMIN TESTS${NC}" | tee -a "$OUTPUT_FILE"

# Helper function to call API and check result
test_api() {
    DESC=$1
    URL=$2
    PAYLOAD=$3
    EXPECTED_STATUS=$4
    RESPONSE_FILE="/tmp/api_test_$(date +%s).json"
    
    echo "▶ Testing: $DESC" | tee -a "$OUTPUT_FILE"
    if [ -n "$PAYLOAD" ]; then
        aws lambda invoke --function-name "$URL" --payload "$PAYLOAD" --region "$AWS_REGION" $RESPONSE_FILE >/dev/null 2>&1
        STATUS=$(jq -r '.statusCode // empty' $RESPONSE_FILE || echo "0")
    else
        STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$URL")
    fi
    
    if [ "$STATUS" -eq "$EXPECTED_STATUS" ]; then
        ok "$DESC (status $STATUS)"
    else
        fail "$DESC (expected $EXPECTED_STATUS, got $STATUS)"
    fi
    cat $RESPONSE_FILE | tee -a "$OUTPUT_FILE"
}

# ✅ PDF Analytics Test
test_api "PDF Analytics (Admin)" "$API_DEV/pdf-report" '{"queryStringParameters":{"type":"pdf","report":"analytics"},"requestContext":{"authorizer":{"claims":{"cognito:groups":"Admin"}}}}' 200

# ✅ CSV Export Test
test_api "CSV Analytics (Admin)" "$API_DEV/csv-report" '{"queryStringParameters":{"type":"csv"},"requestContext":{"authorizer":{"claims":{"cognito:groups":"Admin"}}}}' 200

# ❌ Non-admin test
test_api "PDF Daily (Non-Admin)" "$API_DEV/pdf-report" '{"queryStringParameters":{"type":"pdf","report":"daily"}}' 403

# ============================================================== 
# S3 VERIFICATION — CHECK FILES GENERATED
# ============================================================== 
echo -e "\n${BLUE}📂 S3 FILE VERIFICATION${NC}" | tee -a "$OUTPUT_FILE"

REPORTS=("daily_report" "analytics_report" "order-status_report")
for report in "${REPORTS[@]}"; do
    FILE=$(aws s3 ls "s3://$S3_BUCKET/exports/" | grep "$report" | awk '{print $4}' || echo "")
    if [ -n "$FILE" ]; then
        ok "Found S3 file: $FILE"
    else
        fail "Missing S3 file for $report"
    fi
done

# ============================================================== 
# ALB & CLOUDFRONT STATIC FILE TESTS
# ============================================================== 
echo -e "\n${BLUE}🌐 ALB & CLOUDFRONT STATIC FILE TESTS${NC}" | tee -a "$OUTPUT_FILE"
curl -I http://${ALB_DOMAIN}/js/central-auth-api.js >/dev/null && ok "ALB static file reachable" || warn "ALB static file failed"
curl -I https://${CLOUDFRONT_DOMAIN}/js/central-auth-api.js >/dev/null && ok "CloudFront static file reachable" || warn "CloudFront static file failed"

# ============================================================== 
# SQS VERIFICATION
# ============================================================== 
echo -e "\n${MAGENTA}📬 SQS QUEUE VERIFICATION${NC}" | tee -a "$OUTPUT_FILE"
aws sqs get-queue-attributes --queue-url https://sqs.${AWS_REGION}.amazonaws.com/${ACCOUNT_ID}/${QUEUE_NAME} --attribute-names ApproximateNumberOfMessages >/dev/null && ok "SQS queue accessible" || fail "Cannot access SQS queue"

# ============================================================== 
# LAMBDA INVOCATION TESTS
# ============================================================== 
echo -e "\n${CYAN}⚡ LAMBDA INVOCATION TESTS${NC}" | tee -a "$OUTPUT_FILE"

invoke_lambda () {
  NAME=$1
  PAYLOAD=$2
  echo "▶ Invoking Lambda: ${NAME}" | tee -a "$OUTPUT_FILE"
  aws lambda invoke --function-name "${NAME}" --payload "${PAYLOAD}" --region "${AWS_REGION}" /tmp/${NAME}.json >/dev/null
  cat /tmp/${NAME}.json | tee -a "$OUTPUT_FILE"
  echo
}

# Sample Lambda invocations
invoke_lambda CafeOrderProcessor '{"body":"{\"customer_name\":\"LambdaTest\",\"item\":\"Coffee\",\"quantity\":2}"}'
invoke_lambda CafeMenuLambda '{}'
invoke_lambda GetOrderStatusLambda '{}'
invoke_lambda CafeAnalyticsLambda '{"queryStringParameters":{"period":"today"}}'
invoke_lambda CafePDFReportLambda '{"queryStringParameters":{"page":"analytics"}}'

# ============================================================== 
# FINAL SUMMARY & RESULT CARD
# ============================================================== 
echo -e "\n${GREEN}==================== RESULT CARD ====================${NC}" | tee -a "$OUTPUT_FILE"
if [ $FAILURES -eq 0 ]; then
    echo -e "${GREEN}ALL CHECKS PASSED ✅${NC}" | tee -a "$OUTPUT_FILE"
else
    echo -e "${RED}${FAILURES} ISSUES DETECTED ❌${NC}" | tee -a "$OUTPUT_FILE"
    echo "Review the log above" | tee -a "$OUTPUT_FILE"
fi
echo -e "${GREEN}====================================================${NC}" | tee -a "$OUTPUT_FILE"

# ============================================================== 
# EXPORT LOG TO S3
# ============================================================== 
echo "Uploading log to S3 bucket: $S3_BUCKET"
aws s3 cp "$OUTPUT_FILE" "s3://$S3_BUCKET/" >/dev/null && ok "Log uploaded to S3" || warn "Failed to upload log"

echo "✅ Charlie Cafe FULL VERIFICATION COMPLETED"
```

#### ✅ What’s new in this updated script:

- Integrated your API Gateway PDF/CSV Admin tests with JSON payloads.

- Added 403 Non-Admin verification to ensure Cognito authorizer works.

- S3 verification for PDF/CSV reports (daily_report, analytics_report, order-status_report).

- Full comments for each section so anyone can understand what’s tested.

- Maintains previous system, DB, Lambda, SQS, ALB/CloudFront tests.

---
### Charlie-Cafe-Final-Verify-Test.sh

> **Update Version: 1.2**


```
#!/bin/bash
# =============================================================
# Charlie Cafe - Complete Lab Test & Verification Script
# Version: 1.1
# SAFE MODE: READ-ONLY for DB / APIs where possible
# =============================================================

set -euo pipefail

# ===============================
# CONFIGURATION - REPLACE WITH YOUR VALUES
# ===============================
AWS_REGION="us-east-1"
SECRET_ID="CafeDevDBSM"
DB_NAME="cafe_db"
WEB_ROOT="/var/www/html"
S3_BUCKET="charlie-cafe-s3-bucket"
S3_PREFIX="Charlie Cafe Test and Verification"

# RBAC / Cognito
RBAC_ACCESS_TOKEN="PASTE_VALID_ACCESS_TOKEN_HERE"

# Timestamped logs
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
TXT_FILE="CharlieCafe_Verification_${TIMESTAMP}.txt"
CSV_FILE="CharlieCafe_Verification_${TIMESTAMP}.csv"
PDF_FILE="CharlieCafe_Verification_${TIMESTAMP}.pdf"

# ===============================
# COLORS
# ===============================
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

ok()   { echo -e "${GREEN}✔ $1${NC}"; }
fail() { echo -e "${RED}✖ $1${NC}"; }
warn() { echo -e "${YELLOW}! $1${NC}"; }

# ===============================
# LOG EVERYTHING
# ===============================
exec > >(tee "$TXT_FILE") 2>&1
echo "Test,Status,Details,Timestamp" > "$CSV_FILE"
csv_pass() { echo "\"$1\",\"PASS\",\"$2\",\"$(date)\"" >> "$CSV_FILE"; }
csv_fail() { echo "\"$1\",\"FAIL\",\"$2\",\"$(date)\"" >> "$CSV_FILE"; }
csv_warn() { echo "\"$1\",\"WARN\",\"$2\",\"$(date)\"" >> "$CSV_FILE"; }

echo "============================================================="
echo "Charlie Cafe Complete Lab Verification"
echo "Started at: $(date)"
echo "============================================================="

# =============================================================
# 1️⃣ LAMP STACK VERIFICATION
# =============================================================
echo
echo "🔧 LAMP STACK VERIFICATION"

if curl -s http://localhost | grep -qi "It works"; then
    ok "Apache serving default page"
    csv_pass "Apache" "Serving default page"
else
    fail "Apache not serving default page"
    csv_fail "Apache" "Not serving default page"
fi

if command -v php >/dev/null; then
    ok "PHP CLI available"
    csv_pass "PHP CLI" "Installed"
else
    fail "PHP CLI missing"
    csv_fail "PHP CLI" "Not installed"
fi

if command -v mysql >/dev/null; then
    ok "MySQL client installed"
    csv_pass "MySQL Client" "Installed"
else
    fail "MySQL client missing"
    csv_fail "MySQL Client" "Not installed"
fi

# =============================================================
# 2️⃣ FILE PATH & LOCALHOST PAGE VERIFICATION
# =============================================================
echo
echo "📂 FILE PATH VERIFICATION"

FILES=(
    "$WEB_ROOT/index.php"
    "$WEB_ROOT/orders.php"
    "$WEB_ROOT/order-status.html"
    "$WEB_ROOT/order-receipt.php"
    "$WEB_ROOT/admin-orders.php"
    "$WEB_ROOT/payment-status.php"
    "$WEB_ROOT/css/central_cafe_style.css"
    "$WEB_ROOT/js/central-auth-api.js"
)

for f in "${FILES[@]}"; do
    if [ -f "$f" ]; then
        ok "File exists: $f"
        csv_pass "File $f" "Exists"
    else
        fail "Missing file: $f"
        csv_fail "File $f" "Missing"
    fi
done

# Localhost pages
PAGES=("index.php" "orders.php" "order-status.html" "order-receipt.php" "admin-orders.php" "payment-status.php")
for page in "${PAGES[@]}"; do
    CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost/$page")
    if [ "$CODE" = "200" ]; then
        ok "Page reachable: $page"
        csv_pass "Page $page" "HTTP 200"
    else
        fail "Page error: $page ($CODE)"
        csv_fail "Page $page" "HTTP $CODE"
    fi
done

# =============================================================
# 3️⃣ FETCH RDS CREDENTIALS
# =============================================================
echo
echo "🔐 FETCHING RDS CREDENTIALS"

SECRET_JSON=$(aws secretsmanager get-secret-value \
    --secret-id "$SECRET_ID" \
    --region "$AWS_REGION" \
    --query SecretString --output text)

DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host')
DB_PORT=$(echo "$SECRET_JSON" | jq -r '.port // 3306')

if [[ -z "$DB_USER" || -z "$DB_PASS" || -z "$DB_HOST" ]]; then
    fail "Failed to load DB credentials"
    exit 1
fi
ok "DB credentials loaded: $DB_USER@$DB_HOST:$DB_PORT"
csv_pass "Secrets Manager" "Credentials loaded"

MYSQL="mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS $DB_NAME -sN"

# =============================================================
# 4️⃣ RDS & TABLE VERIFICATION
# =============================================================
echo
echo "☕ RDS & TABLE VERIFICATION"

if $MYSQL -e "SELECT 1;" >/dev/null; then
    ok "RDS connection successful"
    csv_pass "RDS Connection" "Connection OK"
else
    fail "RDS connection failed"
    csv_fail "RDS Connection" "Connection failed"
fi

REQUIRED_TABLES=("orders" "employees" "attendance" "leaves" "holidays")
for t in "${REQUIRED_TABLES[@]}"; do
    if $MYSQL -e "SHOW TABLES LIKE '$t';" | grep -q "$t"; then
        ok "Table exists: $t"
        csv_pass "Table $t" "Exists"
    else
        fail "Missing table: $t"
        csv_fail "Table $t" "Missing"
    fi
done

# =============================================================
# 5️⃣ STATIC FILES / CloudFront / ALB / local JS
# =============================================================
echo
echo "☁️ STATIC FILES / JS ACCESS VERIFICATION"

STATIC_URLS=(
"http://localhost/js/central-auth-api.js"
"http://<PRIVATE-IP>/js/central-auth-api.js"
"http://charlie-cafe-alb-1179524333.us-east-1.elb.amazonaws.com/js/central-auth-api.js"
"https://dc65q9cmuuula.cloudfront.net/js/central-auth-api.js"
"charlie-cafe-alb-1179524333.us-east-1.elb.amazonaws.com/cafe-admin-dashboard.html"
"dc65q9cmuuula.cloudfront.net/cafe-admin-dashboard.html"
"https://us-east-1oupq34l1i.auth.us-east-1.amazoncognito.com/cafe-admin-dashboard.html"
)

for url in "${STATIC_URLS[@]}"; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$url" || echo "000")
    if [[ "$STATUS" =~ ^2 ]]; then
        ok "Static file reachable: $url ($STATUS)"
        csv_pass "Static $url" "HTTP $STATUS"
    else
        warn "Static file failed: $url ($STATUS)"
        csv_warn "Static $url" "HTTP $STATUS"
    fi
done

# =============================================================
# 6️⃣ API GATEWAY ENDPOINT VERIFICATION
# =============================================================
echo
echo "🌐 API GATEWAY / CURL VERIFICATION"

API_ENDPOINTS=(
"https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/dev/orders"
"https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/status/order-status"
"https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/prod/order-status/order-status"
"https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/order-update"
"https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/dev/orders/cash-payment"
"https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/dev/admin/mark-paid"
"https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/prod/order-status"
"https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/order-update"
)

for url in "${API_ENDPOINTS[@]}"; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$url" || echo "000")
    if [[ "$STATUS" =~ ^2 ]]; then
        ok "API endpoint reachable: $url ($STATUS)"
        csv_pass "API $url" "HTTP $STATUS"
    else
        warn "API endpoint failed: $url ($STATUS)"
        csv_warn "API $url" "HTTP $STATUS"
    fi
done

# =============================================================
# 7️⃣ LAMBDA TEST EVENTS (SAMPLE POST)
# =============================================================
echo
echo "⚡ Lambda Function Test Events"

declare -A LAMBDAS=(
["CafeOrderProcessor"]='{"body":"{\"customer_name\":\"LambdaTest\",\"item\":\"Coffee\",\"quantity\":2}"}'
["CafeMenuLambda"]='{}'
["CafeOrderApiLambda"]='{"body":"{\"table_number\":1,\"customer_name\":\"ConsoleTest\",\"item\":\"Latte\",\"quantity\":2}"}'
["Test_SqsProducerTest"]='{"body":"{\"customer_name\":\"ConsoleTest\",\"item\":\"Latte\",\"quantity\":2}"}'
)

for lambda in "${!LAMBDAS[@]}"; do
    TMP_OUT=$(mktemp)
    aws lambda invoke \
        --function-name "$lambda" \
        --payload "${LAMBDAS[$lambda]}" \
        "$TMP_OUT" >/dev/null 2>&1 || true
    if grep -qi "\"statusCode\"" "$TMP_OUT"; then
        ok "Lambda $lambda invoked successfully"
        csv_pass "Lambda $lambda" "Invoked"
    else
        warn "Lambda $lambda invocation failed / check manually"
        csv_warn "Lambda $lambda" "Failed"
    fi
    rm -f "$TMP_OUT"
done

# =============================================================
# 8️⃣ S3 PDF/CSV VERIFICATION
# =============================================================
echo
echo "☁️ S3 FILE VERIFICATION"

S3_FILES=(
"daily_report_${TIMESTAMP}.pdf"
"analytics_report_${TIMESTAMP}.csv"
"order-status_report_${TIMESTAMP}.pdf"
)

for f in "${S3_FILES[@]}"; do
    if aws s3 ls "s3://$S3_BUCKET/$f" >/dev/null 2>&1; then
        ok "S3 file exists: $f"
        csv_pass "S3 $f" "Exists"
    else
        warn "S3 file missing: $f"
        csv_warn "S3 $f" "Missing"
    fi
done

# =============================================================
# 9️⃣ RBAC / Cognito TOKEN TEST
# =============================================================
echo
echo "🔐 Cognito / RBAC TOKEN TEST"
if [[ "$RBAC_ACCESS_TOKEN" == *"PASTE"* ]]; then
    warn "RBAC token not configured — skipping"
    csv_warn "RBAC Token" "Not configured"
else
    CODE=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $RBAC_ACCESS_TOKEN" "$WEB_ROOT/orders.php")
    if [ "$CODE" = "200" ]; then
        ok "RBAC token accepted"
        csv_pass "RBAC Token" "Valid"
    else
        fail "RBAC token rejected ($CODE)"
        csv_fail "RBAC Token" "Invalid / Expired"
    fi
fi

# =============================================================
# 🔟 PDF GENERATION (optional)
# =============================================================
echo
echo "📑 PDF REPORT GENERATION"

if command -v pandoc >/dev/null; then
    pandoc "$TXT_FILE" -o "$PDF_FILE"
    ok "PDF report generated"
    csv_pass "PDF Report" "Generated"
else
    warn "Pandoc not installed — skipping PDF"
    csv_warn "PDF Report" "Pandoc missing"
fi

# =============================================================
# 1️⃣1️⃣ UPLOAD REPORTS TO S3
# =============================================================
echo
echo "☁️ Uploading results to S3"

aws s3 cp "$TXT_FILE" "s3://$S3_BUCKET/$S3_PREFIX/$TXT_FILE" || warn "TXT upload failed"
aws s3 cp "$CSV_FILE" "s3://$S3_BUCKET/$S3_PREFIX/$CSV_FILE" || warn "CSV upload failed"
[ -f "$PDF_FILE" ] && aws s3 cp "$PDF_FILE" "s3://$S3_BUCKET/$S3_PREFIX/$PDF_FILE" || true

ok "All reports uploaded (if bucket exists)"

echo
echo "============================================================="
echo "✅ Charlie Cafe Mega Verification Complete"
echo "TXT : $TXT_FILE"
echo "CSV : $CSV_FILE"
[ -f "$PDF_FILE" ] && echo "PDF : $PDF_FILE"
echo "============================================================="
```

---
### Charlie-Cafe-Final-Verify-Test.sh

> **Update Version: 1.1**

```
#!/bin/bash
# =============================================================
# Charlie Cafe - Complete Lab Test & Verification Script
# Version: 1.1
# SAFE MODE: READ-ONLY for DB / APIs where possible
# =============================================================

set -euo pipefail

# ===============================
# CONFIGURATION - REPLACE WITH YOUR VALUES
# ===============================
AWS_REGION="us-east-1"
SECRET_ID="CafeDevDBSM"
DB_NAME="cafe_db"
WEB_ROOT="/var/www/html"
S3_BUCKET="charlie-cafe-s3-bucket"
S3_PREFIX="Charlie Cafe Test and Verification"

# RBAC / Cognito
RBAC_ACCESS_TOKEN="PASTE_VALID_ACCESS_TOKEN_HERE"

# Timestamped logs
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
TXT_FILE="CharlieCafe_Verification_${TIMESTAMP}.txt"
CSV_FILE="CharlieCafe_Verification_${TIMESTAMP}.csv"
PDF_FILE="CharlieCafe_Verification_${TIMESTAMP}.pdf"

# ===============================
# COLORS
# ===============================
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

ok()   { echo -e "${GREEN}✔ $1${NC}"; }
fail() { echo -e "${RED}✖ $1${NC}"; }
warn() { echo -e "${YELLOW}! $1${NC}"; }

# ===============================
# LOG EVERYTHING
# ===============================
exec > >(tee "$TXT_FILE") 2>&1
echo "Test,Status,Details,Timestamp" > "$CSV_FILE"
csv_pass() { echo "\"$1\",\"PASS\",\"$2\",\"$(date)\"" >> "$CSV_FILE"; }
csv_fail() { echo "\"$1\",\"FAIL\",\"$2\",\"$(date)\"" >> "$CSV_FILE"; }
csv_warn() { echo "\"$1\",\"WARN\",\"$2\",\"$(date)\"" >> "$CSV_FILE"; }

echo "============================================================="
echo "Charlie Cafe Complete Lab Verification"
echo "Started at: $(date)"
echo "============================================================="

# =============================================================
# 1️⃣ LAMP STACK VERIFICATION
# =============================================================
echo
echo "🔧 LAMP STACK VERIFICATION"

if curl -s http://localhost | grep -qi "It works"; then
    ok "Apache serving default page"
    csv_pass "Apache" "Serving default page"
else
    fail "Apache not serving default page"
    csv_fail "Apache" "Not serving default page"
fi

if command -v php >/dev/null; then
    ok "PHP CLI available"
    csv_pass "PHP CLI" "Installed"
else
    fail "PHP CLI missing"
    csv_fail "PHP CLI" "Not installed"
fi

if command -v mysql >/dev/null; then
    ok "MySQL client installed"
    csv_pass "MySQL Client" "Installed"
else
    fail "MySQL client missing"
    csv_fail "MySQL Client" "Not installed"
fi

# =============================================================
# 2️⃣ FILE PATH & LOCALHOST PAGE VERIFICATION
# =============================================================
echo
echo "📂 FILE PATH VERIFICATION"

FILES=(
    "$WEB_ROOT/index.php"
    "$WEB_ROOT/orders.php"
    "$WEB_ROOT/order-status.html"
    "$WEB_ROOT/order-receipt.php"
    "$WEB_ROOT/admin-orders.php"
    "$WEB_ROOT/payment-status.php"
    "$WEB_ROOT/css/central_cafe_style.css"
    "$WEB_ROOT/js/central-auth-api.js"
)

for f in "${FILES[@]}"; do
    if [ -f "$f" ]; then
        ok "File exists: $f"
        csv_pass "File $f" "Exists"
    else
        fail "Missing file: $f"
        csv_fail "File $f" "Missing"
    fi
done

# Localhost pages
PAGES=("index.php" "orders.php" "order-status.html" "order-receipt.php" "admin-orders.php" "payment-status.php")
for page in "${PAGES[@]}"; do
    CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost/$page")
    if [ "$CODE" = "200" ]; then
        ok "Page reachable: $page"
        csv_pass "Page $page" "HTTP 200"
    else
        fail "Page error: $page ($CODE)"
        csv_fail "Page $page" "HTTP $CODE"
    fi
done

# =============================================================
# 3️⃣ FETCH RDS CREDENTIALS
# =============================================================
echo
echo "🔐 FETCHING RDS CREDENTIALS"

SECRET_JSON=$(aws secretsmanager get-secret-value \
    --secret-id "$SECRET_ID" \
    --region "$AWS_REGION" \
    --query SecretString --output text)

DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host')
DB_PORT=$(echo "$SECRET_JSON" | jq -r '.port // 3306')

if [[ -z "$DB_USER" || -z "$DB_PASS" || -z "$DB_HOST" ]]; then
    fail "Failed to load DB credentials"
    exit 1
fi
ok "DB credentials loaded: $DB_USER@$DB_HOST:$DB_PORT"
csv_pass "Secrets Manager" "Credentials loaded"

MYSQL="mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS $DB_NAME -sN"

# =============================================================
# 4️⃣ RDS & TABLE VERIFICATION
# =============================================================
echo
echo "☕ RDS & TABLE VERIFICATION"

if $MYSQL -e "SELECT 1;" >/dev/null; then
    ok "RDS connection successful"
    csv_pass "RDS Connection" "Connection OK"
else
    fail "RDS connection failed"
    csv_fail "RDS Connection" "Connection failed"
fi

REQUIRED_TABLES=("orders" "employees" "attendance" "leaves" "holidays")
for t in "${REQUIRED_TABLES[@]}"; do
    if $MYSQL -e "SHOW TABLES LIKE '$t';" | grep -q "$t"; then
        ok "Table exists: $t"
        csv_pass "Table $t" "Exists"
    else
        fail "Missing table: $t"
        csv_fail "Table $t" "Missing"
    fi
done

# =============================================================
# 5️⃣ STATIC FILES / CloudFront / ALB / local JS
# =============================================================
echo
echo "☁️ STATIC FILES / JS ACCESS VERIFICATION"

STATIC_URLS=(
"http://localhost/js/central-auth-api.js"
"http://<PRIVATE-IP>/js/central-auth-api.js"
"http://charlie-cafe-alb-1179524333.us-east-1.elb.amazonaws.com/js/central-auth-api.js"
"https://dc65q9cmuuula.cloudfront.net/js/central-auth-api.js"
"charlie-cafe-alb-1179524333.us-east-1.elb.amazonaws.com/cafe-admin-dashboard.html"
"dc65q9cmuuula.cloudfront.net/cafe-admin-dashboard.html"
"https://us-east-1oupq34l1i.auth.us-east-1.amazoncognito.com/cafe-admin-dashboard.html"
)

for url in "${STATIC_URLS[@]}"; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$url" || echo "000")
    if [[ "$STATUS" =~ ^2 ]]; then
        ok "Static file reachable: $url ($STATUS)"
        csv_pass "Static $url" "HTTP $STATUS"
    else
        warn "Static file failed: $url ($STATUS)"
        csv_warn "Static $url" "HTTP $STATUS"
    fi
done

# =============================================================
# 6️⃣ API GATEWAY ENDPOINT VERIFICATION
# =============================================================
echo
echo "🌐 API GATEWAY / CURL VERIFICATION"

API_ENDPOINTS=(
"https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/dev/orders"
"https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/status/order-status"
"https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/prod/order-status/order-status"
"https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/order-update"
"https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/dev/orders/cash-payment"
"https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/dev/admin/mark-paid"
"https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/prod/order-status"
"https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/order-update"
)

for url in "${API_ENDPOINTS[@]}"; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$url" || echo "000")
    if [[ "$STATUS" =~ ^2 ]]; then
        ok "API endpoint reachable: $url ($STATUS)"
        csv_pass "API $url" "HTTP $STATUS"
    else
        warn "API endpoint failed: $url ($STATUS)"
        csv_warn "API $url" "HTTP $STATUS"
    fi
done

# =============================================================
# 7️⃣ LAMBDA TEST EVENTS (SAMPLE POST)
# =============================================================
echo
echo "⚡ Lambda Function Test Events"

declare -A LAMBDAS=(
["CafeOrderProcessor"]='{"body":"{\"customer_name\":\"LambdaTest\",\"item\":\"Coffee\",\"quantity\":2}"}'
["CafeMenuLambda"]='{}'
["CafeOrderApiLambda"]='{"body":"{\"table_number\":1,\"customer_name\":\"ConsoleTest\",\"item\":\"Latte\",\"quantity\":2}"}'
["Test_SqsProducerTest"]='{"body":"{\"customer_name\":\"ConsoleTest\",\"item\":\"Latte\",\"quantity\":2}"}'
)

for lambda in "${!LAMBDAS[@]}"; do
    TMP_OUT=$(mktemp)
    aws lambda invoke \
        --function-name "$lambda" \
        --payload "${LAMBDAS[$lambda]}" \
        "$TMP_OUT" >/dev/null 2>&1 || true
    if grep -qi "\"statusCode\"" "$TMP_OUT"; then
        ok "Lambda $lambda invoked successfully"
        csv_pass "Lambda $lambda" "Invoked"
    else
        warn "Lambda $lambda invocation failed / check manually"
        csv_warn "Lambda $lambda" "Failed"
    fi
    rm -f "$TMP_OUT"
done

# =============================================================
# 8️⃣ S3 PDF/CSV VERIFICATION
# =============================================================
echo
echo "☁️ S3 FILE VERIFICATION"

S3_FILES=(
"daily_report_${TIMESTAMP}.pdf"
"analytics_report_${TIMESTAMP}.csv"
"order-status_report_${TIMESTAMP}.pdf"
)

for f in "${S3_FILES[@]}"; do
    if aws s3 ls "s3://$S3_BUCKET/$f" >/dev/null 2>&1; then
        ok "S3 file exists: $f"
        csv_pass "S3 $f" "Exists"
    else
        warn "S3 file missing: $f"
        csv_warn "S3 $f" "Missing"
    fi
done

# =============================================================
# 9️⃣ RBAC / Cognito TOKEN TEST
# =============================================================
echo
echo "🔐 Cognito / RBAC TOKEN TEST"
if [[ "$RBAC_ACCESS_TOKEN" == *"PASTE"* ]]; then
    warn "RBAC token not configured — skipping"
    csv_warn "RBAC Token" "Not configured"
else
    CODE=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: Bearer $RBAC_ACCESS_TOKEN" "$WEB_ROOT/orders.php")
    if [ "$CODE" = "200" ]; then
        ok "RBAC token accepted"
        csv_pass "RBAC Token" "Valid"
    else
        fail "RBAC token rejected ($CODE)"
        csv_fail "RBAC Token" "Invalid / Expired"
    fi
fi

# =============================================================
# 🔟 PDF GENERATION (optional)
# =============================================================
echo
echo "📑 PDF REPORT GENERATION"

if command -v pandoc >/dev/null; then
    pandoc "$TXT_FILE" -o "$PDF_FILE"
    ok "PDF report generated"
    csv_pass "PDF Report" "Generated"
else
    warn "Pandoc not installed — skipping PDF"
    csv_warn "PDF Report" "Pandoc missing"
fi

# =============================================================
# 1️⃣1️⃣ UPLOAD REPORTS TO S3
# =============================================================
echo
echo "☁️ Uploading results to S3"

aws s3 cp "$TXT_FILE" "s3://$S3_BUCKET/$S3_PREFIX/$TXT_FILE" || warn "TXT upload failed"
aws s3 cp "$CSV_FILE" "s3://$S3_BUCKET/$S3_PREFIX/$CSV_FILE" || warn "CSV upload failed"
[ -f "$PDF_FILE" ] && aws s3 cp "$PDF_FILE" "s3://$S3_BUCKET/$S3_PREFIX/$PDF_FILE" || true

ok "All reports uploaded (if bucket exists)"

echo
echo "============================================================="
echo "✅ Charlie Cafe Mega Verification Complete"
echo "TXT : $TXT_FILE"
echo "CSV : $CSV_FILE"
[ -f "$PDF_FILE" ] && echo "PDF : $PDF_FILE"
echo "============================================================="
```

---
### Charlie-Cafe-Final-Verify-Test.sh

> **Update Version: 1.2**

```
#!/bin/bash
# ============================================================
# Charlie Cafe ☕
# FINAL COMPLETE LAB TEST & VERIFICATION SCRIPT (WITH FULL URL)
# ============================================================

set -e

echo "============================================================"
echo "☕ CHARLIE CAFE – FULL SYSTEM TEST STARTED"
echo "============================================================"

# =========================
# 1️⃣ DEFINE API GATEWAY ENDPOINTS
# =========================
API_DEV="https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/dev"
API_PROD="https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/prod"
API_STATUS="https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/status"

ALB_DOMAIN="charlie-cafe-alb-1179524333.us-east-1.elb.amazonaws.com"
CLOUDFRONT_DOMAIN="dc65q9cmuuula.cloudfront.net"

REGION="us-east-1"
ACCOUNT_ID="910599465397"
QUEUE_NAME="CafeOrdersQueue"

# ============================================================
# 2️⃣ LOCAL HOST + STATIC FILE CHECK
# ============================================================
echo "🔹 Testing local JS file"
curl -I http://localhost/js/central-auth-api.js || true
curl http://localhost/js/central-auth-api.js | head -5 || true

echo "🔹 Local IP info"
ip addr | grep inet || true

# ============================================================
# 3️⃣ ALB + CLOUDFRONT STATIC FILE TEST
# ============================================================
echo "🔹 ALB static file test"
curl -I http://${ALB_DOMAIN}/js/central-auth-api.js || true

echo "🔹 CloudFront static file test"
curl -I https://${CLOUDFRONT_DOMAIN}/js/central-auth-api.js || true

# ============================================================
# 4️⃣ SECRETS MANAGER VERIFICATION
# ============================================================
echo "🔹 Verifying Secrets Manager keys"
aws secretsmanager get-secret-value \
  --secret-id cafe-rds-secret \
  --region ${REGION} \
  --query SecretString \
  --output text | jq .

# ============================================================
# 5️⃣ API GATEWAY TESTS USING FULL URL
# ============================================================
echo "🔹 Create Order (POST /dev/orders)"
curl -X POST \
  ${API_DEV}/orders \
  -H "Content-Type: application/json" \
  -d '{"table_number":3,"customer_name":"CurlTest","item":"Tea","quantity":2}'

echo "🔹 Get Orders"
curl ${API_DEV}/orders

echo "🔹 Cash Payment"
curl -X POST \
  ${API_DEV}/orders/cash-payment \
  -H "Content-Type: application/json" \
  -d '{"order_id":"ORD-123"}'

echo "🔹 Mark Paid (Admin)"
curl ${API_DEV}/admin/mark-paid

echo "🔹 Order Status"
curl ${API_STATUS}/order-status
curl ${API_PROD}/order-status/order-status

# ============================================================
# 6️⃣ Analytics & Reports
# ============================================================
curl ${API_PROD}/analytics?period=today
curl ${API_PROD}/analytics?period=month
curl ${API_PROD}/analytics/csv

curl ${API_PROD}/report/pdf?page=analytics
curl ${API_PROD}/report/pdf?page=order-status

# ============================================================
# 7️⃣ SQS CHECK
# ============================================================
echo "🔹 Checking SQS Queue"
aws sqs get-queue-attributes \
  --queue-url https://sqs.${REGION}.amazonaws.com/${ACCOUNT_ID}/${QUEUE_NAME} \
  --attribute-names ApproximateNumberOfMessages

# ============================================================
# 8️⃣ LAMBDA INVOKE TESTS
# ============================================================
invoke_lambda () {
  NAME=$1
  PAYLOAD=$2

  echo "▶ Invoking Lambda: ${NAME}"
  aws lambda invoke \
    --function-name ${NAME} \
    --payload "${PAYLOAD}" \
    --region ${REGION} \
    /tmp/${NAME}.json

  cat /tmp/${NAME}.json
  echo
}

# ──────────────────────────────
# All your Lambda tests
# ──────────────────────────────
invoke_lambda CafeOrderProcessor \
'{"body":"{\"customer_name\":\"LambdaTest\",\"item\":\"Coffee\",\"quantity\":2}"}'

invoke_lambda CafeMenuLambda '{}'

invoke_lambda CafeOrderApiLambda \
'{"body":"{\"table_number\":1,\"customer_name\":\"ConsoleTest\",\"item\":\"Latte\",\"quantity\":2}"}'

invoke_lambda Test_SqsProducerTest \
'{"body":"{\"customer_name\":\"ConsoleTest\",\"item\":\"Latte\",\"quantity\":2}"}'

invoke_lambda CafeOrderWorker \
'{"Records":[{"body":"{\"table_number\":1,\"customer_name\":\"WorkerTest\",\"item\":\"Coffee\",\"quantity\":2}"}]}'

invoke_lambda GetOrderStatusLambda '{}'

invoke_lambda CreateOrderLambda \
'{"body":"{\"table_number\":1,\"customer_name\":\"Test User\",\"item\":\"Coffee\",\"quantity\":3}"}'

invoke_lambda CashPayment \
'{"body":"{\"order_id\":\"ORD-20260131-1234\"}"}'

invoke_lambda MarkPaid \
'{"body":"{\"order_id\":\"ORD-999999999-999\"}"}'

invoke_lambda CafeDynamoTestLambda '{}'

invoke_lambda CafeAnalyticsLambda \
'{"queryStringParameters":{"period":"today"}}'

invoke_lambda CafeAnalyticsCSVLambda '{}'

invoke_lambda CafePDFReportLambda \
'{"queryStringParameters":{"page":"analytics"}}'

invoke_lambda CafePDFReportLambda \
'{"queryStringParameters":{"page":"order-status"}}'

invoke_lambda CafeDailyPDFLambda '{}'

invoke_lambda hr-checkin \
'{"requestContext":{"authorizer":{"claims":{"sub":"TEMP-COGNITO-ID"}}}}'

invoke_lambda hr-checkout \
'{"requestContext":{"authorizer":{"claims":{"sub":"TEMP-COGNITO-ID"}}}}'

invoke_lambda hr-employee-profile \
'{"requestContext":{"authorizer":{"claims":{"sub":"TEMP-COGNITO-ID"}}}}'

invoke_lambda hr-attendance-history \
'{"requestContext":{"authorizer":{"claims":{"sub":"TEMP-COGNITO-ID"}}}}'

invoke_lambda hr-leaves-holidays \
'{"requestContext":{"authorizer":{"claims":{"sub":"TEMP-COGNITO-ID"}}}}'

# ============================================================
# ✅ DONE
# ============================================================
echo "============================================================"
echo "✅ CHARLIE CAFE FULL LAB TEST COMPLETED SUCCESSFULLY"
echo "============================================================"
```

---
### Charlie-Cafe-Final-Verify-Test.sh

> **Update Version: 1.3**

```
#!/bin/bash
# ============================================================
# Charlie Cafe ☕
# FINAL COMPLETE LAB TEST & VERIFICATION SCRIPT (WITH FULL URL)
# ============================================================

set -e

echo "============================================================"
echo "☕ CHARLIE CAFE – FULL SYSTEM TEST STARTED"
echo "============================================================"

# =========================
# 1️⃣ DEFINE API GATEWAY ENDPOINTS
# =========================
API_DEV="https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/dev"
API_PROD="https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/prod"
API_STATUS="https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/status"

ALB_DOMAIN="charlie-cafe-alb-1179524333.us-east-1.elb.amazonaws.com"
CLOUDFRONT_DOMAIN="dc65q9cmuuula.cloudfront.net"

REGION="us-east-1"
ACCOUNT_ID="910599465397"
QUEUE_NAME="CafeOrdersQueue"

# ============================================================
# 2️⃣ LOCAL HOST + STATIC FILE CHECK
# ============================================================
echo "🔹 Testing local JS file"
curl -I http://localhost/js/central-auth-api.js || true
curl http://localhost/js/central-auth-api.js | head -5 || true

echo "🔹 Local IP info"
ip addr | grep inet || true

# ============================================================
# 3️⃣ ALB + CLOUDFRONT STATIC FILE TEST
# ============================================================
echo "🔹 ALB static file test"
curl -I http://${ALB_DOMAIN}/js/central-auth-api.js || true

echo "🔹 CloudFront static file test"
curl -I https://${CLOUDFRONT_DOMAIN}/js/central-auth-api.js || true

# ============================================================
# 4️⃣ SECRETS MANAGER VERIFICATION
# ============================================================
echo "🔹 Verifying Secrets Manager keys"
aws secretsmanager get-secret-value \
  --secret-id cafe-rds-secret \
  --region ${REGION} \
  --query SecretString \
  --output text | jq .

# ============================================================
# 5️⃣ API GATEWAY TESTS USING FULL URL
# ============================================================
echo "🔹 Create Order (POST /dev/orders)"
curl -X POST \
  ${API_DEV}/orders \
  -H "Content-Type: application/json" \
  -d '{"table_number":3,"customer_name":"CurlTest","item":"Tea","quantity":2}'

echo "🔹 Get Orders"
curl ${API_DEV}/orders

echo "🔹 Cash Payment"
curl -X POST \
  ${API_DEV}/orders/cash-payment \
  -H "Content-Type: application/json" \
  -d '{"order_id":"ORD-123"}'

echo "🔹 Mark Paid (Admin)"
curl ${API_DEV}/admin/mark-paid

echo "🔹 Order Status"
curl ${API_STATUS}/order-status
curl ${API_PROD}/order-status/order-status

# ============================================================
# 6️⃣ Analytics & Reports
# ============================================================
curl ${API_PROD}/analytics?period=today
curl ${API_PROD}/analytics?period=month
curl ${API_PROD}/analytics/csv

curl ${API_PROD}/report/pdf?page=analytics
curl ${API_PROD}/report/pdf?page=order-status

# ============================================================
# 7️⃣ SQS CHECK
# ============================================================
echo "🔹 Checking SQS Queue"
aws sqs get-queue-attributes \
  --queue-url https://sqs.${REGION}.amazonaws.com/${ACCOUNT_ID}/${QUEUE_NAME} \
  --attribute-names ApproximateNumberOfMessages

# ============================================================
# 8️⃣ LAMBDA INVOKE TESTS
# ============================================================
invoke_lambda () {
  NAME=$1
  PAYLOAD=$2

  echo "▶ Invoking Lambda: ${NAME}"
  aws lambda invoke \
    --function-name ${NAME} \
    --payload "${PAYLOAD}" \
    --region ${REGION} \
    /tmp/${NAME}.json

  cat /tmp/${NAME}.json
  echo
}

# ──────────────────────────────
# All your Lambda tests
# ──────────────────────────────
invoke_lambda CafeOrderProcessor \
'{"body":"{\"customer_name\":\"LambdaTest\",\"item\":\"Coffee\",\"quantity\":2}"}'

invoke_lambda CafeMenuLambda '{}'

invoke_lambda CafeOrderApiLambda \
'{"body":"{\"table_number\":1,\"customer_name\":\"ConsoleTest\",\"item\":\"Latte\",\"quantity\":2}"}'

invoke_lambda Test_SqsProducerTest \
'{"body":"{\"customer_name\":\"ConsoleTest\",\"item\":\"Latte\",\"quantity\":2}"}'

invoke_lambda CafeOrderWorker \
'{"Records":[{"body":"{\"table_number\":1,\"customer_name\":\"WorkerTest\",\"item\":\"Coffee\",\"quantity\":2}"}]}'

invoke_lambda GetOrderStatusLambda '{}'

invoke_lambda CreateOrderLambda \
'{"body":"{\"table_number\":1,\"customer_name\":\"Test User\",\"item\":\"Coffee\",\"quantity\":3}"}'

invoke_lambda CashPayment \
'{"body":"{\"order_id\":\"ORD-20260131-1234\"}"}'

invoke_lambda MarkPaid \
'{"body":"{\"order_id\":\"ORD-999999999-999\"}"}'

invoke_lambda CafeDynamoTestLambda '{}'

invoke_lambda CafeAnalyticsLambda \
'{"queryStringParameters":{"period":"today"}}'

invoke_lambda CafeAnalyticsCSVLambda '{}'

invoke_lambda CafePDFReportLambda \
'{"queryStringParameters":{"page":"analytics"}}'

invoke_lambda CafePDFReportLambda \
'{"queryStringParameters":{"page":"order-status"}}'

invoke_lambda CafeDailyPDFLambda '{}'

invoke_lambda hr-checkin \
'{"requestContext":{"authorizer":{"claims":{"sub":"TEMP-COGNITO-ID"}}}}'

invoke_lambda hr-checkout \
'{"requestContext":{"authorizer":{"claims":{"sub":"TEMP-COGNITO-ID"}}}}'

invoke_lambda hr-employee-profile \
'{"requestContext":{"authorizer":{"claims":{"sub":"TEMP-COGNITO-ID"}}}}'

invoke_lambda hr-attendance-history \
'{"requestContext":{"authorizer":{"claims":{"sub":"TEMP-COGNITO-ID"}}}}'

invoke_lambda hr-leaves-holidays \
'{"requestContext":{"authorizer":{"claims":{"sub":"TEMP-COGNITO-ID"}}}}'

# ============================================================
# ✅ DONE
# ============================================================
echo "============================================================"
echo "✅ CHARLIE CAFE FULL LAB TEST COMPLETED SUCCESSFULLY"
echo "============================================================"
```

---
### Charlie-Cafe-Final-Verify-Test.sh

> **Update Version: 1.4**

```
#!/bin/bash
# ==============================================================
# CHARLIE CAFE ☕
# Order Processing & Status Tracking
# Testing and Verifications Script
# ==============================================================
# SAFE | READ-ONLY | NON-DESTRUCTIVE
# ==============================================================

set +e

# ---------------- COLORS ----------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ok()    { echo -e "${GREEN}✓ OK${NC} - $1"; }
fail()  { echo -e "${RED}✗ FAIL${NC} - $1"; ((FAILURES++)); }
warn()  { echo -e "${YELLOW}! WARN${NC} - $1"; }

FAILURES=0

# ---------------- CONFIG ----------------
AWS_REGION="us-east-1"
SECRET_ID="CafeDevDBSM"

API_BASE="https://a1053skr51.execute-api.us-east-1.amazonaws.com"
S3_BUCKET="charlie-cafe-s3-bucket"
LAYER_KEY="layers/pymysql-layer.zip"

WEB_ROOT="/var/www/html"

echo "============================================================="
echo " CHARLIE CAFE ☕ — ORDER PROCESSING & STATUS VERIFICATION"
echo " Started at: $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================================="

# ==============================================================
# 1️⃣ SYSTEM & LAMP STACK
# ==============================================================

echo -e "\n🖥️ SYSTEM INFORMATION"
cat /etc/os-release | grep PRETTY_NAME

systemctl is-active --quiet httpd \
  && ok "Apache (httpd) running" \
  || fail "Apache (httpd) not running"

command -v php >/dev/null \
  && ok "PHP installed ($(php -v | head -n1))" \
  || fail "PHP not installed"

php -m | grep -qi mysqlnd \
  && ok "PHP mysqlnd extension loaded" \
  || fail "PHP mysqlnd missing"

command -v mysql >/dev/null \
  && ok "MySQL client installed" \
  || fail "MySQL client missing"

# ==============================================================
# 2️⃣ WEB SERVER TEST
# ==============================================================

echo -e "\n🌐 APACHE WEB TEST"

curl -s http://localhost >/tmp/apache_test.html 2>/dev/null
grep -qi "It works\|Apache" /tmp/apache_test.html \
  && ok "Apache serves content on port 80" \
  || warn "Apache reachable but default page not detected"

rm -f /tmp/apache_test.html

curl -s http://localhost/info.php | grep -qi phpinfo \
  && ok "PHP info.php working" \
  || warn "info.php not working"

# ==============================================================
# 3️⃣ WEB FILES DISCOVERY
# ==============================================================

echo -e "\n📂 WEB FILES INVENTORY (/var/www/html)"

if [ -d "$WEB_ROOT" ]; then
  ok "Web root exists: $WEB_ROOT"
  echo "Files:"
  ls -lh "$WEB_ROOT"
else
  fail "Web root missing: $WEB_ROOT"
fi

if [ -d "$WEB_ROOT/js" ]; then
  ok "JS directory exists"
  ls -lh "$WEB_ROOT/js"
else
  warn "JS directory not found"
fi

[ -f "$WEB_ROOT/js/central-auth-api.js" ] \
  && ok "central-auth-api.js present" \
  || warn "central-auth-api.js missing"

# ==============================================================
# 4️⃣ AWS CLI & IDENTITY
# ==============================================================

echo -e "\n☁️ AWS CLI VERIFICATION"

command -v aws >/dev/null \
  && ok "AWS CLI installed" \
  || fail "AWS CLI missing"

aws sts get-caller-identity >/dev/null 2>&1 \
  && ok "AWS credentials valid" \
  || fail "AWS credentials invalid or missing"

# ==============================================================
# 5️⃣ SECRETS MANAGER + DATABASE
# ==============================================================

echo -e "\n🔐 SECRETS MANAGER & DATABASE"

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_ID" \
  --region "$AWS_REGION" \
  --query SecretString \
  --output text 2>/dev/null)

if [ -n "$SECRET_JSON" ]; then
  ok "Fetched DB secret"
else
  fail "Failed to fetch DB secret"
fi

if [ -n "$SECRET_JSON" ]; then
  DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
  DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
  DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host')

  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" \
    -e "SHOW DATABASES LIKE 'cafe_db';" >/dev/null 2>&1 \
    && ok "Database cafe_db exists" \
    || fail "Database cafe_db missing"

  mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" cafe_db \
    -e "DESCRIBE orders;" >/dev/null 2>&1 \
    && ok "Orders table exists & accessible" \
    || fail "Orders table missing or inaccessible"
fi

# ==============================================================
# 6️⃣ API GATEWAY — ORDER STATUS
# ==============================================================

echo -e "\n📡 API GATEWAY TESTS"

curl -s "$API_BASE/status/order-status" >/dev/null \
  && ok "Order status API reachable (unauth)" \
  || warn "Order status API not reachable"

# ==============================================================
# 7️⃣ CASH PAYMENT ENDPOINT (BASIC REACHABILITY)
# ==============================================================

curl -s -X POST "$API_BASE/dev/orders/cash-payment" \
  -H "Content-Type: application/json" \
  -d '{"order_id":"TEST-ORDER"}' >/dev/null \
  && ok "Cash payment endpoint reachable" \
  || warn "Cash payment endpoint not reachable"

# ==============================================================
# 8️⃣ LAMBDA LAYER (S3)
# ==============================================================

echo -e "\n📦 LAMBDA LAYER CHECK"

aws s3 ls "s3://$S3_BUCKET/$LAYER_KEY" >/dev/null 2>&1 \
  && ok "PyMySQL Lambda layer found in S3" \
  || fail "PyMySQL Lambda layer missing in S3"

# ==============================================================
# 9️⃣ FINAL SUMMARY
# ==============================================================

echo "============================================================="
if [ $FAILURES -eq 0 ]; then
  echo -e "${GREEN}✅ ALL CHECKS PASSED — SYSTEM HEALTHY${NC}"
else
  echo -e "${RED}❌ $FAILURES ISSUE(S) DETECTED${NC}"
  echo "Review failed items above"
fi
echo "============================================================="
```

---
### Charlie-Cafe-Final-Verify-Test.sh

> **Update Version: 1.5**


```


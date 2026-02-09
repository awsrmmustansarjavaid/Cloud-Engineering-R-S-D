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

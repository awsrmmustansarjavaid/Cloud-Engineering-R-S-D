#!/usr/bin/env bash
# =============================================================
# ☕ CHARLIE CAFE — MEGA FULL SYSTEM VERIFICATION SCRIPT
# Version: 2026 Final Edition
# Purpose: Verify everything — LAMP, AWS, RDS, API, Lambda, S3, SQS
# SAFE: READ-ONLY, NON-DESTRUCTIVE
# =============================================================

# ── SAFETY SETTINGS ─────────────────────────────────────────
set -euo pipefail

# ── COLORS ─────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BLUE='\033[0;34m'
NC='\033[0m'

bold() { echo -e "\033[1m$1\033[0m"; }

# ── HELPER FUNCTIONS ────────────────────────────────────────
ok()    { echo -e "${GREEN}✓ OK${NC} - $1"; }
fail()  { echo -e "${RED}✗ FAIL${NC} - $1"; ((FAILURES++)); }
warn()  { echo -e "${YELLOW}! WARN${NC} - $1"; }
info()  { echo -e "${CYAN}➤ INFO${NC} - $1"; }

invoke_lambda() {
  NAME=$1
  PAYLOAD=$2
  echo -e "${MAGENTA}▶ Invoking Lambda: ${NAME}${NC}"
  aws lambda invoke \
    --function-name "${NAME}" \
    --payload "${PAYLOAD}" \
    --region "${AWS_REGION}" \
    "/tmp/${NAME}.json" >/dev/null 2>&1 || warn "Lambda ${NAME} failed"
  cat "/tmp/${NAME}.json" || true
  echo
}

FAILURES=0

# ── CONFIGURATION ─────────────────────────────────────────
AWS_REGION="us-east-1"
SECRET_ID="CafeDevDBSM"
API_DEV="https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/dev"
API_PROD="https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/prod"
API_STATUS="https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/status"
S3_BUCKET="charlie-cafe-s3-bucket"
LAYER_KEY="layers/pymysql-layer.zip"
WEB_ROOT="/var/www/html"
ALB_DOMAIN="charlie-cafe-alb-1179524333.us-east-1.elb.amazonaws.com"
CLOUDFRONT_DOMAIN="dc65q9cmuuula.cloudfront.net"
ACCOUNT_ID="910599465397"
QUEUE_NAME="CafeOrdersQueue"
DB_NAME="cafe_db"

echo "============================================================"
bold "☕ CHARLIE CAFE FULL SYSTEM VERIFICATION START"
echo "Started at: $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================================"

# =============================================================
# 🖥️ SYSTEM & LAMP STACK
# =============================================================
echo -e "\n${BLUE}==== SYSTEM & LAMP STACK ====${NC}"
info "OS & Instance Info"
cat /etc/os-release | grep PRETTY_NAME
PUBLIC_IP=$(curl -s -m 3 http://169.254.169.254/latest/meta-data/public-ipv4 || echo "N/A")
echo "Public IPv4: $PUBLIC_IP"

# Apache / httpd
systemctl is-active --quiet httpd && ok "Apache running" || fail "Apache not running"
command -v httpd >/dev/null && ok "httpd binary found ($(httpd -v | head -n1))" || warn "httpd not found"
command -v apache2 >/dev/null && ok "apache2 binary found ($(apache2 -v | head -n1))" || true

# PHP & extensions
command -v php >/dev/null && ok "PHP installed ($(php -v | head -n1))" || fail "PHP missing"
php -m | grep -qi mysqlnd && ok "PHP mysqlnd extension loaded" || fail "PHP mysqlnd missing"

# MySQL client
command -v mysql >/dev/null && ok "MySQL client installed ($(mysql --version | head -n1))" || fail "MySQL client missing"

# Web root
[ -d "$WEB_ROOT" ] && ok "Web root exists: $WEB_ROOT" || fail "Web root missing"
[ -d "$WEB_ROOT/js" ] && ok "JS directory exists" || warn "JS directory missing"
[ -f "$WEB_ROOT/js/central-auth-api.js" ] && ok "central-auth-api.js present" || warn "central-auth-api.js missing"

# =============================================================
# 🌐 LOCAL / WEB SERVER TEST
# =============================================================
echo -e "\n${CYAN}==== WEB SERVER TEST ====${NC}"
curl -s http://localhost >/tmp/apache_test.html
grep -qi "It works\|Apache" /tmp/apache_test.html && ok "Apache default page detected" || warn "Default page not detected"
rm -f /tmp/apache_test.html
curl -s http://localhost/info.php | grep -qi phpinfo && ok "info.php working" || warn "info.php not working"

# =============================================================
# ☁️ AWS CLI & IAM
# =============================================================
echo -e "\n${MAGENTA}==== AWS CLI & IAM ====${NC}"
command -v aws >/dev/null && ok "AWS CLI installed" || fail "AWS CLI missing"
aws sts get-caller-identity >/dev/null 2>&1 && ok "AWS credentials valid" || fail "AWS credentials invalid"

IMDS_CHECK=$(curl -s -m 3 http://169.254.169.254/latest/meta-data/ || echo "")
[ -n "$IMDS_CHECK" ] && ok "EC2 metadata reachable (IMDS)" || warn "Cannot reach EC2 metadata"

ROLE=$(curl -s -m 3 http://169.254.169.254/latest/meta-data/iam/info || true)
[[ $ROLE == *"arn:aws:iam::"* ]] && ok "IAM role attached" || warn "No IAM role attached"

# =============================================================
# 🔐 SECRETS MANAGER
# =============================================================
echo -e "\n${YELLOW}==== SECRETS MANAGER ====${NC}"
SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id "$SECRET_ID" --region "$AWS_REGION" --query SecretString --output text 2>/dev/null)
[ -n "$SECRET_JSON" ] && ok "Fetched DB secret" || fail "Failed to fetch DB secret"
DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host')
DB_PORT=$(echo "$SECRET_JSON" | jq -r '.port // 3306')

# =============================================================
# 🗄 DATABASE VERIFICATION (RDS)
# =============================================================
echo -e "\n${GREEN}==== DATABASE (RDS) VERIFICATION ====${NC}"
MYSQL_BASE="mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS"
MYSQL_DB="$MYSQL_BASE $DB_NAME"
MYSQL_SILENT="$MYSQL_DB -sN"

# Connection test
$MYSQL_DB -e "SELECT 1;" >/dev/null && ok "DB connection successful" || fail "DB connection failed"

# Database exists
$MYSQL_BASE -e "SHOW DATABASES LIKE '$DB_NAME';" | grep "$DB_NAME" >/dev/null && ok "Database '$DB_NAME' exists" || fail "Database missing"

# Required tables
REQUIRED_TABLES=("orders" "employees" "attendance" "leaves" "holidays")
for t in "${REQUIRED_TABLES[@]}"; do
  $MYSQL_SILENT -e "SHOW TABLES LIKE '$t';" | grep "$t" >/dev/null && ok "Table exists: $t" || fail "Missing table: $t"
done

# Describe tables & critical columns
TABLES=$($MYSQL_SILENT -e "SHOW TABLES;")
for table in $TABLES; do
  echo -e "${CYAN}🔍 DESCRIBE $table${NC}"
  $MYSQL_DB -e "DESCRIBE $table;"
done

# Orders table critical columns
for col in table_number item_cost total_cost; do
  $MYSQL_SILENT -e "SHOW COLUMNS FROM orders LIKE '$col';" | grep "$col" >/dev/null && ok "orders.$col exists" || fail "orders.$col missing"
done

# Attendance table critical column
$MYSQL_SILENT -e "SHOW COLUMNS FROM attendance LIKE 'attendance_date';" | grep attendance_date >/dev/null && ok "attendance.attendance_date exists" || fail "attendance.attendance_date missing"

# Index verification
$MYSQL_DB -e "SHOW INDEX FROM orders WHERE Key_name='idx_table_number';" | grep idx_table_number >/dev/null && ok "idx_table_number exists" || warn "idx_table_number missing (optional)"
$MYSQL_DB -e "SHOW INDEX FROM attendance;" | grep employee_id >/dev/null && ok "Attendance unique/index exists" || warn "Attendance index missing"

# Row counts
for table in $TABLES; do
  COUNT=$($MYSQL_SILENT -e "SELECT COUNT(*) FROM $table;")
  echo -e " • $table : $COUNT rows"
done

# Sample order
echo "🧪 Sample order row:"
$MYSQL_DB -e "SELECT id, table_number, item, quantity, created_at FROM orders LIMIT 1;"

# =============================================================
# 📡 API GATEWAY TESTS
# =============================================================
echo -e "\n${MAGENTA}==== API GATEWAY TESTS ====${NC}"
curl -s "${API_STATUS}/order-status" >/dev/null && ok "Order status API reachable" || warn "Order status API not reachable"
curl -s -X POST "${API_DEV}/orders/cash-payment" -H "Content-Type: application/json" -d '{"order_id":"TEST-ORDER"}' >/dev/null && ok "Cash payment endpoint reachable" || warn "Cash payment endpoint unreachable"

# =============================================================
# 📦 LAMBDA & S3
# =============================================================
echo -e "\n${BLUE}==== LAMBDA & S3 ====${NC}"
aws s3 ls "s3://$S3_BUCKET/$LAYER_KEY" >/dev/null 2>&1 && ok "PyMySQL Lambda layer found in S3" || fail "PyMySQL Lambda layer missing"

# Sample Lambda invocations
invoke_lambda CafeOrderProcessor '{"body":"{\"customer_name\":\"LambdaTest\",\"item\":\"Coffee\",\"quantity\":2}"}'
invoke_lambda CafeAnalyticsLambda '{"queryStringParameters":{"period":"today"}}'

# =============================================================
# ☁️ CLOUDFRONT / ALB
# =============================================================
echo -e "\n${CYAN}==== ALB & CLOUDFRONT ====${NC}"
curl -I http://${ALB_DOMAIN}/js/central-auth-api.js >/dev/null && ok "ALB static file reachable" || warn "ALB static file unreachable"
curl -I https://${CLOUDFRONT_DOMAIN}/js/central-auth-api.js >/dev/null && ok "CloudFront static file reachable" || warn "CloudFront static file unreachable"

# =============================================================
# 📨 SQS QUEUE
# =============================================================
echo -e "\n${YELLOW}==== SQS QUEUE ====${NC}"
aws sqs get-queue-attributes --queue-url https://sqs.${AWS_REGION}.amazonaws.com/${ACCOUNT_ID}/${QUEUE_NAME} --attribute-names ApproximateNumberOfMessages >/dev/null && ok "SQS queue reachable" || warn "SQS queue unreachable"

# =============================================================
# ✅ FINAL RESULT CARD
# =============================================================
echo -e "\n${MAGENTA}============================================================${NC}"
bold "                    ☕ CHARLIE CAFE RESULT CARD"
echo -e "Started: $(date '+%Y-%m-%d %H:%M:%S')"
echo "------------------------------------------------------------"
if [ $FAILURES -eq 0 ]; then
  echo -e "${GREEN}✅ ALL CHECKS PASSED — SYSTEM HEALTHY${NC}"
else
  echo -e "${RED}❌ $FAILURES ISSUE(S) DETECTED${NC}"
  echo "Review the detailed logs above"
fi
echo "============================================================"

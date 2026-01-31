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

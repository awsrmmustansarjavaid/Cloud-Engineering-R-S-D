#!/bin/bash
# =============================================================
# Charlie Cafe - Ultimate Lab Test & Verification Script
# Version: 2.1
# Combines Dev / Prod LAMP, RDS, API, Lambda, S3, SQS, RBAC
# =============================================================

set -euo pipefail

# =============================================================
# CONFIGURATION
# =============================================================
AWS_REGION="us-east-1"
SECRET_ID="CafeDevDBSM"           # RDS secret (Dev)
PROD_SECRET_ID="cafe-rds-secret"  # RDS secret (Prod)
DB_NAME="cafe_db"
WEB_ROOT="/var/www/html"
S3_BUCKET="charlie-cafe-s3-bucket"
S3_PREFIX="Charlie Cafe Test and Verification"

RBAC_ACCESS_TOKEN="PASTE_VALID_ACCESS_TOKEN_HERE"

# AWS Services
ACCOUNT_ID="910599465397"
QUEUE_NAME="CafeOrdersQueue"
SQS_URL="https://sqs.us-east-1.amazonaws.com/910599465397/CafeOrdersQueue"  # ✅ Replace with your SQS URL

ALB_DOMAIN="charlie-cafe-alb-1179524333.us-east-1.elb.amazonaws.com"
CLOUDFRONT_DOMAIN="dc65q9cmuuula.cloudfront.net"
API_PROD="https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/prod"

# Timestamped logs
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
TXT_FILE="CharlieCafe_Verification_${TIMESTAMP}.txt"
CSV_FILE="CharlieCafe_Verification_${TIMESTAMP}.csv"
PDF_FILE="CharlieCafe_Verification_${TIMESTAMP}.pdf"

# =============================================================
# COLORS
# =============================================================
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

ok()   { echo -e "${GREEN}✔ $1${NC}"; }
fail() { echo -e "${RED}✖ $1${NC}"; }
warn() { echo -e "${YELLOW}! $1${NC}"; }

# =============================================================
# LOGGING
# =============================================================
exec > >(tee "$TXT_FILE") 2>&1
echo "Test,Status,Details,Timestamp" > "$CSV_FILE"
csv_pass() { echo "\"$1\",\"PASS\",\"$2\",\"$(date)\"" >> "$CSV_FILE"; }
csv_fail() { echo "\"$1\",\"FAIL\",\"$2\",\"$(date)\"" >> "$CSV_FILE"; }
csv_warn() { echo "\"$1\",\"WARN\",\"$2\",\"$(date)\"" >> "$CSV_FILE"; }

echo "============================================================="
echo "Charlie Cafe Ultimate Lab Verification"
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
"http://$ALB_DOMAIN/js/central-auth-api.js"
"https://$CLOUDFRONT_DOMAIN/js/central-auth-api.js"
"http://$ALB_DOMAIN/cafe-admin-dashboard.html"
"https://$CLOUDFRONT_DOMAIN/cafe-admin-dashboard.html"
"$API_PROD/cafe-admin-dashboard.html"
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
# 6️⃣ API GATEWAY / PROD ENDPOINT VERIFICATION
# =============================================================
echo
echo "🌐 API GATEWAY / PROD ENDPOINTS"

API_ENDPOINTS=(
"$API_PROD/orders"
"$API_PROD/get-order-status"
"$API_PROD/cafe-order-status"
"$API_PROD/order-update"
"$API_PROD/admin/mark-paid"
"$API_PROD/analytics?period=today"
)
for url in "${API_ENDPOINTS[@]}"; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$url" || echo "000")
    if [[ "$STATUS" =~ ^2 ]]; then
        ok "API reachable: $url ($STATUS)"
        csv_pass "API $url" "HTTP $STATUS"
    else
        warn "API failed: $url ($STATUS)"
        csv_warn "API $url" "HTTP $STATUS"
    fi
done

# =============================================================
# 7️⃣ SQS QUEUE CHECK
# =============================================================
echo
echo "📥 Checking SQS Queue: $QUEUE_NAME"
aws sqs get-queue-attributes \
  --queue-url "$SQS_URL" \
  --attribute-names ApproximateNumberOfMessages || warn "SQS check failed"

# =============================================================
# 8️⃣ LAMBDA INVOKE TEST FUNCTION
# =============================================================
invoke_lambda () {
  NAME=$1
  PAYLOAD=$2
  TMP_OUT=$(mktemp)

  echo "▶ Invoking Lambda: ${NAME}"
  aws lambda invoke \
    --function-name ${NAME} \
    --payload "${PAYLOAD}" \
    --region ${AWS_REGION} \
    "$TMP_OUT" >/dev/null 2>&1 || true

  if grep -qi "\"statusCode\"" "$TMP_OUT"; then
      ok "Lambda $NAME invoked successfully"
      csv_pass "Lambda $NAME" "Invoked"
  else
      warn "Lambda $NAME invocation failed"
      csv_warn "Lambda $NAME" "Failed"
  fi

  rm -f "$TMP_OUT"
}

# Sample Lambda invocations
declare -A LAMBDAS=(
["CafeOrderProcessor"]='{"body":"{\"table_number\":5,\"customer_name\":\"LambdaTest\",\"item\":\"Coffee\",\"quantity\":2}"}'
["CafeMenuLambda"]='{}'
["GetOrderStatusLambda"]='{}'
["CafeOrderStatusLambda"]='{}'
["CafeOrderWorkerLambda"]='{"body":"{\"order_id\":\"ORD-20260222-1234\",\"status\":\"PREPARING\"}"}'
["AdminMarkPaidLambda"]='{"body":"{\"order_id\": \"ORD-123456\"}"}'
["CafeAnalyticsLambda"]='{"queryStringParameters":{"period":"today"}}'
)

for lambda in "${!LAMBDAS[@]}"; do
    invoke_lambda "$lambda" "${LAMBDAS[$lambda]}"
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
# 🔟 PDF REPORT GENERATION
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
echo "✅ Charlie Cafe Ultimate Verification Complete"
echo "TXT : $TXT_FILE"
echo "CSV : $CSV_FILE"
[ -f "$PDF_FILE" ] && echo "PDF : $PDF_FILE"
echo "============================================================="
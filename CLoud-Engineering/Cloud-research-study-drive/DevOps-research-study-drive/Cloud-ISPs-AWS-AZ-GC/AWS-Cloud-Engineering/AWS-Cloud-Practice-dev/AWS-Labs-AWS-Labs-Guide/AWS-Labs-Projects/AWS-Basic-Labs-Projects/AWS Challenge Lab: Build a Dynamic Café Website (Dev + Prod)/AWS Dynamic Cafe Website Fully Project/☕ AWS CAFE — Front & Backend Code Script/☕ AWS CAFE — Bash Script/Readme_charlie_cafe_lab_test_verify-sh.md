# charlie cafe lab test verify

### charlie_cafe_lab_test_verify.sh

> **Update Version: 1.0**


```
#!/bin/bash
# =============================================================
# Charlie Cafe Basic Lab Configuration Test and Verification
#
# OUTPUTS:
# - TXT  (full console log)
# - CSV  (test summary)
# - PDF  (audit report)
#
# SAFE MODE:
# ✔ READ ONLY
# ✔ NO DB CHANGES
# =============================================================

set -euo pipefail

# ===============================
# AWS AUTH (REPLACE THESE)
# ===============================
export AWS_ACCESS_KEY_ID="YOUR_AWS_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="YOUR_AWS_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="us-east-1"

# ===============================
# CONFIGURATION
# ===============================
SECRET_ID="CafeDevDBSM"
DB_NAME="cafe_db"
S3_BUCKET="charlie-cafe-s3-bucket"
S3_PREFIX="Charlie Cafe Test and Verification"

TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')

TXT_FILE="Basic_Config_Test_Result_${TIMESTAMP}.txt"
CSV_FILE="Basic_Config_Test_Result_${TIMESTAMP}.csv"
PDF_FILE="Basic_Config_Test_Result_${TIMESTAMP}.pdf"

# ===============================
# LOG EVERYTHING (TXT)
# ===============================
exec > >(tee "$TXT_FILE") 2>&1

# ===============================
# CSV HEADER
# ===============================
echo "Test,Status,Details,Timestamp" > "$CSV_FILE"

csv_pass() { echo "\"$1\",\"PASS\",\"$2\",\"$(date)\"" >> "$CSV_FILE"; }
csv_fail() { echo "\"$1\",\"FAIL\",\"$2\",\"$(date)\"" >> "$CSV_FILE"; }
csv_warn() { echo "\"$1\",\"WARN\",\"$2\",\"$(date)\"" >> "$CSV_FILE"; }

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
# HEADER
# ===============================
echo "============================================================="
echo "  Charlie Cafe Basic Lab Configuration Test and Verification"
echo "  Started at: $(date)"
echo "============================================================="
echo

# =============================================================
# LAMP VERIFICATION
# =============================================================
echo "🔧 LAMP STACK VERIFICATION"

# Apache
if curl -s http://localhost | grep -qi "It works"; then
  ok "Apache serving default page"
  csv_pass "Apache" "Serving default page"
else
  fail "Apache not serving default page"
  csv_fail "Apache" "Not serving default page"
fi

# PHP CLI
if command -v php >/dev/null; then
  ok "PHP CLI available"
  csv_pass "PHP CLI" "Installed"
else
  fail "PHP CLI missing"
  csv_fail "PHP CLI" "Not installed"
fi

# MySQL Client
if command -v mysql >/dev/null; then
  ok "MySQL client installed"
  csv_pass "MySQL Client" "Installed"
else
  fail "MySQL client missing"
  csv_fail "MySQL Client" "Not installed"
fi

# =============================================================
# FETCH DB CREDENTIALS
# =============================================================
echo
echo "🔐 FETCHING RDS CREDENTIALS"

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_ID" \
  --query SecretString \
  --output text)

DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host')
DB_PORT=$(echo "$SECRET_JSON" | jq -r '.port // 3306')

MYSQL="mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS $DB_NAME"

ok "Secrets loaded"
csv_pass "Secrets Manager" "Credentials fetched"

# =============================================================
# RDS VERIFICATION
# =============================================================
echo
echo "☕ RDS VERIFICATION"

if $MYSQL -e "SELECT 1;" >/dev/null; then
  ok "RDS connection successful"
  csv_pass "RDS Connection" "Connection OK"
else
  fail "RDS connection failed"
  csv_fail "RDS Connection" "Connection failed"
fi

TABLES=("orders" "employees" "attendance" "leaves" "holidays")

for t in "${TABLES[@]}"; do
  if $MYSQL -e "SHOW TABLES LIKE '$t';" | grep -q "$t"; then
    ok "Table exists: $t"
    csv_pass "Table $t" "Exists"
  else
    fail "Missing table: $t"
    csv_fail "Table $t" "Missing"
  fi
done

# =============================================================
# PDF GENERATION
# =============================================================
echo
echo "📑 PDF REPORT GENERATION"

if command -v pandoc >/dev/null; then
  pandoc "$TXT_FILE" -o "$PDF_FILE"
  ok "PDF report generated"
  csv_pass "PDF Report" "Generated successfully"
else
  warn "pandoc not installed — skipping PDF"
  csv_warn "PDF Report" "pandoc not installed"
fi

# =============================================================
# UPLOAD ALL FILES TO S3
# =============================================================
echo
echo "☁️ Uploading results to S3..."

aws s3 cp "$TXT_FILE" "s3://$S3_BUCKET/$S3_PREFIX/$TXT_FILE"
aws s3 cp "$CSV_FILE" "s3://$S3_BUCKET/$S3_PREFIX/$CSV_FILE"

[ -f "$PDF_FILE" ] && aws s3 cp "$PDF_FILE" "s3://$S3_BUCKET/$S3_PREFIX/$PDF_FILE"

ok "All reports uploaded to S3"

echo
echo "✅ VERIFICATION COMPLETE"
echo "TXT : $TXT_FILE"
echo "CSV : $CSV_FILE"
[ -f "$PDF_FILE" ] && echo "PDF : $PDF_FILE"
echo
```

---
### charlie_cafe_lab_test_verify.sh

> **Update Version: 1.1**


```
#!/bin/bash
# =============================================================
# Charlie Cafe Basic Lab Configuration Test and Verification
# Update version: 1.1
#
# NEW IN v1.1:
# ✔ Web file path verification
# ✔ Frontend asset validation
# ✔ Localhost page availability checks (curl)
#
# OUTPUTS:
# - TXT  (full console log)
# - CSV  (test summary)
# - PDF  (audit report)
#
# SAFE MODE:
# ✔ READ ONLY
# ✔ NO DB CHANGES
# =============================================================

set -euo pipefail

# ===============================
# AWS AUTH (REPLACE THESE)
# ===============================
export AWS_ACCESS_KEY_ID="YOUR_AWS_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="YOUR_AWS_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="us-east-1"

# ===============================
# CONFIGURATION
# ===============================
SECRET_ID="CafeDevDBSM"
DB_NAME="cafe_db"
S3_BUCKET="charlie-cafe-s3-bucket"
S3_PREFIX="Charlie Cafe Test and Verification"

TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')

TXT_FILE="Basic_Config_Test_Result_${TIMESTAMP}.txt"
CSV_FILE="Basic_Config_Test_Result_${TIMESTAMP}.csv"
PDF_FILE="Basic_Config_Test_Result_${TIMESTAMP}.pdf"

# ===============================
# LOG EVERYTHING (TXT)
# ===============================
exec > >(tee "$TXT_FILE") 2>&1

# ===============================
# CSV HEADER
# ===============================
echo "Test,Status,Details,Timestamp" > "$CSV_FILE"

csv_pass() { echo "\"$1\",\"PASS\",\"$2\",\"$(date)\"" >> "$CSV_FILE"; }
csv_fail() { echo "\"$1\",\"FAIL\",\"$2\",\"$(date)\"" >> "$CSV_FILE"; }
csv_warn() { echo "\"$1\",\"WARN\",\"$2\",\"$(date)\"" >> "$CSV_FILE"; }

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
# HEADER
# ===============================
echo "============================================================="
echo "  Charlie Cafe Basic Lab Configuration Test and Verification"
echo "  Started at: $(date)"
echo "============================================================="
echo

# =============================================================
# LAMP VERIFICATION
# =============================================================
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
# FETCH DB CREDENTIALS
# =============================================================
echo
echo "🔐 FETCHING RDS CREDENTIALS"

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "$SECRET_ID" \
  --query SecretString \
  --output text)

DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')
DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host')
DB_PORT=$(echo "$SECRET_JSON" | jq -r '.port // 3306')

MYSQL="mysql -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS $DB_NAME"

ok "Secrets loaded"
csv_pass "Secrets Manager" "Credentials fetched"

# =============================================================
# RDS VERIFICATION
# =============================================================
echo
echo "☕ RDS VERIFICATION"

if $MYSQL -e "SELECT 1;" >/dev/null; then
  ok "RDS connection successful"
  csv_pass "RDS Connection" "Connection OK"
else
  fail "RDS connection failed"
  csv_fail "RDS Connection" "Connection failed"
fi

TABLES=("orders" "employees" "attendance" "leaves" "holidays")

for t in "${TABLES[@]}"; do
  if $MYSQL -e "SHOW TABLES LIKE '$t';" | grep -q "$t"; then
    ok "Table exists: $t"
    csv_pass "Table $t" "Exists"
  else
    fail "Missing table: $t"
    csv_fail "Table $t" "Missing"
  fi
done

# =============================================================
# v1.1 — WEB FILE PATH VERIFICATION
# =============================================================
echo
echo "📂 WEB FILE & ASSET VERIFICATION (v1.1)"

# Root web directory
if ls -lh /var/www/html/* >/dev/null 2>&1; then
  ok "/var/www/html directory accessible"
  csv_pass "Web Root" "/var/www/html accessible"
else
  fail "/var/www/html not accessible"
  csv_fail "Web Root" "Directory missing or permission issue"
fi

# CSS file
if [ -f /var/www/html/css/central_cafe_style.css ]; then
  ok "CSS file found: central_cafe_style.css"
  csv_pass "CSS File" "central_cafe_style.css exists"
else
  fail "Missing CSS file: central_cafe_style.css"
  csv_fail "CSS File" "Missing"
fi

# JS file
if [ -f /var/www/html/js/central-auth-api.js ]; then
  ok "JS file found: central-auth-api.js"
  csv_pass "JS File" "central-auth-api.js exists"
else
  fail "Missing JS file: central-auth-api.js"
  csv_fail "JS File" "Missing"
fi

# =============================================================
# v1.1 — LOCALHOST PAGE AVAILABILITY (curl)
# =============================================================
echo
echo "🌐 LOCALHOST PAGE VERIFICATION (v1.1)"

PAGES=(
  "index.php"
  "cafe-admin-dashboard.html"
  "orders.php"
  "order-status.html"
  "order-receipt.php"
  "admin-orders.php"
  "payment-status.php"
)

for page in "${PAGES[@]}"; do
  if curl -s -o /dev/null -w "%{http_code}" "http://localhost/$page" | grep -q "200"; then
    ok "Page reachable: $page"
    csv_pass "Web Page $page" "HTTP 200 OK"
  else
    fail "Page NOT reachable: $page"
    csv_fail "Web Page $page" "Not reachable"
  fi
done

# =============================================================
# PDF GENERATION
# =============================================================
echo
echo "📑 PDF REPORT GENERATION"

if command -v pandoc >/dev/null; then
  pandoc "$TXT_FILE" -o "$PDF_FILE"
  ok "PDF report generated"
  csv_pass "PDF Report" "Generated successfully"
else
  warn "pandoc not installed — skipping PDF"
  csv_warn "PDF Report" "pandoc not installed"
fi

# =============================================================
# UPLOAD ALL FILES TO S3
# =============================================================
echo
echo "☁️ Uploading results to S3..."

aws s3 cp "$TXT_FILE" "s3://$S3_BUCKET/$S3_PREFIX/$TXT_FILE"
aws s3 cp "$CSV_FILE" "s3://$S3_BUCKET/$S3_PREFIX/$CSV_FILE"

[ -f "$PDF_FILE" ] && aws s3 cp "$PDF_FILE" "s3://$S3_BUCKET/$S3_PREFIX/$PDF_FILE"

ok "All reports uploaded to S3"

echo
echo "============================================================="
echo "✅ VERIFICATION COMPLETE (v1.1)"
echo "TXT : $TXT_FILE"
echo "CSV : $CSV_FILE"
[ -f "$PDF_FILE" ] && echo "PDF : $PDF_FILE"
echo "============================================================="
```

### 🧪 Result Card (What you’ll see at the end)

Your CSV + TXT + console will now include:

✅ Web root accessibility

✅ CSS & JS presence

✅ Each frontend page HTTP status

✅ Clear PASS / FAIL per page

✅ Audit-ready evidence for QA / security

---




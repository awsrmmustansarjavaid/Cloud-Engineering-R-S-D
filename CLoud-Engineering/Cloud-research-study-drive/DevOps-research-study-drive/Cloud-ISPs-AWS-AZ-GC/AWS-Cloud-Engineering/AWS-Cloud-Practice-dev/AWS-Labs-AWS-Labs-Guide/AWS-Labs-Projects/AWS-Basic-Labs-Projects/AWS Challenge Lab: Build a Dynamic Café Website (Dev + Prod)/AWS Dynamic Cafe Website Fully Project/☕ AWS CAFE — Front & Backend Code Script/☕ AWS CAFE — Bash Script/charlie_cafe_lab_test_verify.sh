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
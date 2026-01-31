#!/bin/bash
# RDS Quick Test using AWS Secrets Manager (no hardcoded credentials)
# Amazon Linux 2023 friendly - January 2026 version
# Run with: chmod +x rds-secret-test.sh && sudo ./rds-secret-test.sh

set -u

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "============================================================"
echo "     RDS TEST USING SECRETS MANAGER   (2026)"
echo "============================================================"
echo

FAIL_COUNT=0

# ── CHANGE ONLY THESE TWO VALUES! ────────────────────────────────────────
SECRET_NAME="CafeDevDBSM"          # ← Your secret name or ARN
# Examples: "prod-db-secret", "my-rds-credentials", or full ARN
RDS_DB="cafe_db"                                   # ← Database name to connect to (optional)

PORT="3306"   # almost always 3306 for MySQL/MariaDB/Aurora

# ── Helper functions ─────────────────────────────────────────────────────
ok()    { echo -e "${GREEN}✓ OK${NC}   $1" ; }
fail()  { echo -e "${RED}✗ FAIL${NC}  $1" ; ((FAIL_COUNT++)) ; }
warn()  { echo -e "${YELLOW}⚠ $1${NC}" ; }

# ── 1. Check required tools ──────────────────────────────────────────────
echo -n "1. Required tools (aws cli + jq) ... "
if command -v aws >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
    ok "both found"
else
    fail "missing aws cli or jq!"
    echo "   Install missing tools:"
    echo "   sudo dnf install -y awscli jq    # Amazon Linux 2023"
    echo "   or"
    echo "   sudo yum install -y awscli jq    # older versions"
    exit 1
fi

# ── 2. Retrieve secret from Secrets Manager ──────────────────────────────
echo "2. Retrieving credentials from Secrets Manager..."
SECRET_JSON=$(aws secretsmanager get-secret-value \
    --secret-id "$SECRET_NAME" \
    --query SecretString \
    --output text 2>/dev/null)

if [ $? -ne 0 ] || [ -z "$SECRET_JSON" ]; then
    fail "Failed to retrieve secret!"
    echo "   Possible reasons:"
    echo "   • Wrong SECRET_NAME"
    echo "   • EC2 IAM role missing secretsmanager:GetSecretValue permission"
    echo "   • Secret doesn't exist or is in different region"
    exit 1
fi

# ── 3. Parse username, password, host from JSON ──────────────────────────
RDS_HOST=$(echo "$SECRET_JSON" | jq -r '.host // .endpoint // empty')
RDS_USER=$(echo "$SECRET_JSON" | jq -r '.username // .user // empty')
RDS_PASS=$(echo "$SECRET_JSON" | jq -r '.password // empty')

if [ -z "$RDS_HOST" ] || [ -z "$RDS_USER" ] || [ -z "$RDS_PASS" ]; then
    fail "Could not parse host/username/password from secret JSON"
    echo "   Expected JSON structure like:"
    echo '   {"host":"xxxx.rds.amazonaws.com","username":"admin","password":"xxx"}'
    echo "   Your secret content:"
    echo "$SECRET_JSON" | jq . 2>/dev/null || echo "$SECRET_JSON"
    exit 1
fi

ok "Successfully parsed credentials (host: ${RDS_HOST:0:15}...)"

# ── 4. Basic connection test ─────────────────────────────────────────────
echo "3. Testing basic connection to RDS..."
mysql -h "$RDS_HOST" -P "$PORT" -u "$RDS_USER" -p"$RDS_PASS" \
    -e "SELECT 1" >/dev/null 2>&1

if [ $? -eq 0 ]; then
    ok "Connection successful (can reach RDS)"
else
    fail "Connection failed!"
    echo "   Possible causes:"
    echo "   • Security Group doesn't allow your EC2 IP on port $PORT"
    echo "   • Wrong credentials after all"
    echo "   • RDS is private / VPC mismatch"
    ((FAIL_COUNT++))
    # We still try the queries - maybe only SELECT is blocked
fi

# ── 5. Test SELECT * FROM orders ─────────────────────────────────────────
echo "4. Test query: SELECT * FROM orders LIMIT 5"
RESULT=$(mysql -h "$RDS_HOST" -P "$PORT" -u "$RDS_USER" -p"$RDS_PASS" \
    -D "$RDS_DB" -s -N -e "SELECT * FROM orders LIMIT 5" 2>/dev/null)

if [ $? -eq 0 ]; then
    if [ -z "$RESULT" ]; then
        warn "Table 'orders' exists but is empty"
    else
        ok "Query successful - table has data"
        echo "   Preview (first few rows):"
        echo "$RESULT" | head -n 3 | sed 's/^/      /'
    fi
else
    fail "SELECT * FROM orders failed"
    echo "   → Table may not exist / no SELECT permission / wrong DB name"
fi

# ── 6. Test recent orders ────────────────────────────────────────────────
echo "5. Test query: Recent orders (ORDER BY id DESC LIMIT 3)"
RECENT=$(mysql -h "$RDS_HOST" -P "$PORT" -u "$RDS_USER" -p"$RDS_PASS" \
    -D "$RDS_DB" -s -N -e "SELECT * FROM orders ORDER BY id DESC LIMIT 3" 2>/dev/null)

if [ $? -eq 0 ]; then
    if [ -z "$RECENT" ]; then
        warn "No recent orders found"
    else
        ok "Recent orders query successful"
        echo "   Last 3 rows:"
        echo "$RECENT" | sed 's/^/      /'
    fi
else
    fail "ORDER BY DESC query failed"
fi

# ── Final Summary ────────────────────────────────────────────────────────
echo
echo "============================================================"
if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "${GREEN}         ALL RDS + SECRETS MANAGER TESTS PASSED ✓✓✓${NC}"
else
    echo -e "${RED}         $FAIL_COUNT problem(s) found${NC}"
    echo "   Check ✗ lines above"
fi
echo "============================================================"
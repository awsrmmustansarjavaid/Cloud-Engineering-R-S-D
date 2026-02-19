#!/usr/bin/env bash

# =============================================================================
#  Cafe Order API + RDS Tests (API Gateway + rds-secret-test.sh)
# =============================================================================

set -uo pipefail

# ─── Configuration ────────────────────────────────────────────────────────────

API_URL="https://4njilbv5oj.execute-api.us-east-1.amazonaws.com/prod/orders"

# Unique test marker so you can identify this run in logs / database
TEST_CUSTOMER="TestUser_$(date +%Y%m%d_%H%M%S)"
TEST_ITEM="Latte-Secret-Test"

# Path to your RDS verification script (change if it's in different folder)
RDS_SECRET_SCRIPT="./rds-secret-test.sh"

# ─── Colors & Helpers ─────────────────────────────────────────────────────────

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ok()    { echo -e "${GREEN}✓${NC} $*" ; }
fail()  { echo -e "${RED}✗${NC} $*"; exit 1; }
warn()  { echo -e "${YELLOW}!${NC} $*"; }

# ─── 1. Test API Gateway ──────────────────────────────────────────────────────

echo ""
echo "┌──────────────────────────────┐"
echo "│     1. Testing API Gateway    │"
echo "└──────────────────────────────┘"

curl_payload=$(cat <<EOF
{
  "table_number": 3,
  "customer_name": "${TEST_CUSTOMER}",
  "item": "${TEST_ITEM}",
  "quantity": 1
}
EOF
)

echo "→ POST ${API_URL}"
echo "  Customer: ${TEST_CUSTOMER}"

response=$(curl -s -w "\n%{http_code}" \
  -X POST "${API_URL}" \
  -H "Content-Type: application/json" \
  -d "${curl_payload}")

http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | sed '$d')

if [[ "$http_code" -ge 200 && "$http_code" -le 299 ]]; then
    ok "API call succeeded (HTTP ${http_code})"
    echo "  Response:"
    echo "${body}" | jq . 2>/dev/null || echo "${body}"
else
    fail "API call failed → HTTP ${http_code}"
    echo "${body}"
    exit 1
fi

# Give backend some time to process
sleep 3

# ─── 2. Run rds-secret-test.sh with sudo ──────────────────────────────────────

echo ""
echo "┌─────────────────────────────────────┐"
echo "│ 2. Running RDS secret / connection   │"
echo "│    test script (sudo)                │"
echo "└─────────────────────────────────────┘"

if [[ ! -f "$RDS_SECRET_SCRIPT" ]]; then
    fail "Script not found: ${RDS_SECRET_SCRIPT}"
    echo "Make sure you're running this from the correct directory."
fi

if [[ ! -x "$RDS_SECRET_SCRIPT" ]]; then
    warn "Making ${RDS_SECRET_SCRIPT} executable..."
    chmod +x "$RDS_SECRET_SCRIPT"
fi

echo "→ Executing: sudo ${RDS_SECRET_SCRIPT}"

# Run it and capture exit status
sudo bash "$RDS_SECRET_SCRIPT"

exit_code=$?

echo ""
if [[ $exit_code -eq 0 ]]; then
    ok "rds-secret-test.sh finished successfully (exit code 0)"
else
    warn "rds-secret-test.sh returned non-zero exit code (${exit_code})"
    echo "→ Check output above for errors"
    echo "→ Possible issues: credentials, network, mysql client, permissions"
fi

echo ""
echo "Test sequence completed."
echo "Customer name used: ${TEST_CUSTOMER}"
echo ""

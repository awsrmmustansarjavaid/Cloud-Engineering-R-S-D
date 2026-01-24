#!/bin/bash
# RDS MySQL/MariaDB Quick Test Script
# Style similar to lamp-verify.sh
# Run with:   sudo ./rds-quick-test.sh    or   chmod +x rds-quick-test.sh && sudo ./rds-quick-test.sh

set -u

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "============================================================"
echo "       RDS MySQL/MariaDB CONNECTION TEST   (2026)"
echo "============================================================"
echo

FAIL_COUNT=0

# ── CHANGE THESE 4 VALUES! ───────────────────────────────────────
# Best practice → use AWS Secrets Manager or SSM Parameter Store in production
# For quick dev/testing → put values here (not recommended long-term)

RDS_HOST="your-rds-endpoint.xxxxxxx.us-east-1.rds.amazonaws.com"      # ← CHANGE
RDS_USER="your_username"                                             # ← CHANGE
RDS_PASS="your_strong_password_here"                                 # ← CHANGE
RDS_DB="your_database_name"                                          # ← CHANGE   (optional, can be empty)

# Optional: port (default 3306 is fine in 99% cases)
PORT="3306"

# ── Helper functions ─────────────────────────────────────────────
ok()    { echo -e "${GREEN}✓ OK${NC}   $1" ; }
fail()  { echo -e "${RED}✗ FAIL${NC}  $1" ; ((FAIL_COUNT++)) ; }
warn()  { echo -e "${YELLOW}⚠ $1${NC}" ; }

# ── 1. Check if mysql client is installed ────────────────────────
echo -n "1. MySQL/MariaDB client installed?         "
if command -v mysql >/dev/null 2>&1; then
    ok "found ($(mysql --version | head -1))"
else
    fail "mysql client NOT found!"
    echo
    echo "   Quick fix (Amazon Linux 2023):"
    echo "   sudo dnf install -y mariadb105"
    echo
    exit 1
fi

# ── 2. Basic connection test (just connect + quit) ───────────────
echo "2. Basic connection test (can reach RDS?)"
mysql -h "$RDS_HOST" -P "$PORT" -u "$RDS_USER" -p"$RDS_PASS" -e "SELECT 1" >/dev/null 2>&1

if [ $? -eq 0 ]; then
    ok "Connection successful (can reach RDS endpoint)"
else
    fail "Cannot connect to RDS!"
    echo "   → Possible reasons:"
    echo "     • Wrong endpoint / user / password"
    echo "     • Security Group doesn't allow port $PORT from this EC2"
    echo "     • RDS is in different VPC / not publicly accessible"
    echo "     • Network ACLs / Route tables issue"
    ((FAIL_COUNT++))
    exit 1   # No point continuing if basic connect fails
fi

# ── 3. Test SELECT * FROM orders ─────────────────────────────────
echo "3. Test: SELECT * FROM orders"
RESULT=$(mysql -h "$RDS_HOST" -P "$PORT" -u "$RDS_USER" -p"$RDS_PASS" -D "$RDS_DB" -s -N -e "SELECT * FROM orders LIMIT 5" 2>/dev/null)

if [ $? -eq 0 ]; then
    if [ -z "$RESULT" ]; then
        warn "Table 'orders' exists but is empty"
    else
        ok "Table 'orders' exists and has data"
        echo "   First few rows preview (tab separated):"
        echo "$RESULT" | head -n 3 | sed 's/^/      /'
    fi
else
    fail "Cannot run SELECT * FROM orders"
    echo "   → Table probably doesn't exist or permission denied"
fi

# ── 4. Test recent orders (ORDER BY id DESC) ─────────────────────
echo "4. Test: SELECT * FROM orders ORDER BY id DESC LIMIT 3"
RECENT=$(mysql -h "$RDS_HOST" -P "$PORT" -u "$RDS_USER" -p"$RDS_PASS" -D "$RDS_DB" -s -N -e "SELECT * FROM orders ORDER BY id DESC LIMIT 3" 2>/dev/null)

if [ $? -eq 0 ]; then
    if [ -z "$RECENT" ]; then
        warn "No recent orders (table empty or no rows)"
    else
        ok "Recent orders query successful"
        echo "   Last 3 orders preview:"
        echo "$RECENT" | sed 's/^/      /'
    fi
else
    fail "ORDER BY id DESC query failed"
fi

# ── Final summary ────────────────────────────────────────────────
echo
echo "============================================================"
if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "${GREEN}         ALL RDS TESTS PASSED SUCCESSFULLY ✓✓✓${NC}"
else
    echo -e "${RED}         $FAIL_COUNT problem(s) detected${NC}"
    echo "   Look at the ✗ FAIL lines above"
fi
echo "============================================================"
echo
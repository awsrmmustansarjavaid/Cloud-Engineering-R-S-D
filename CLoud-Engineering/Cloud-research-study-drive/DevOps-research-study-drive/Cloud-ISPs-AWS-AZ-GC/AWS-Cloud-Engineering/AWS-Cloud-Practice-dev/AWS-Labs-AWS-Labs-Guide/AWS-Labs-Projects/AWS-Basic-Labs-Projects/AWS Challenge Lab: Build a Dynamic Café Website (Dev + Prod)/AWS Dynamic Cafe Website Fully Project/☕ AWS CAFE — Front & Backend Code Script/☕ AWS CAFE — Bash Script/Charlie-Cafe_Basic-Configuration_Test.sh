#!/usr/bin/env bash
# Charlie Cafe Basic Configuration Test
# Purpose: Verify LAMP stack + Charlie Cafe DB/setup basics
# Target: Amazon Linux 2 / Amazon Linux 2023
# Recommended: run as root or with sudo
# Version: 2025–2026 edition

set -u
set -euo pipefail  # safer defaults

# ── Colors ────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'    # No Color

# ── Helper functions ──────────────────────────────────────
ok()    { echo -e "${GREEN}✓ OK${NC}  - $1"; }
fail()  { echo -e "${RED}✗ FAILED${NC} - $1"; ((FAILURES++)); }
warn()  { echo -e "${YELLOW}! $1${NC}"; }
check() { [ $? -eq 0 ] && ok "$1" || fail "$1 $2"; }

FAILURES=0

echo
echo "══════════════════════════════════════════════════════════════"
echo "  CHARLIE CAFE BASIC CONFIGURATION TEST  —  $(date '+%Y-%m-%d %H:%M:%S')"
echo "══════════════════════════════════════════════════════════════"
echo

# ── 0. Basic instance / OS info ───────────────────────────
echo "0. System & Instance Information"
echo "──────────────────────────────────────────────"
echo " • OS release : $(cat /etc/os-release 2>/dev/null | grep -m1 PRETTY_NAME | cut -d'"' -f2 || echo 'not found')"
PUBLIC_IP=$(curl -s -m 4 http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "not-detected")
echo " • Public IPv4 : ${PUBLIC_IP}"
echo

# ── 1. Apache / httpd ─────────────────────────────────────
echo "1. Apache Web Server"
echo "──────────────────────────────────────────────"
echo -n " • Service running       : "
if systemctl is-active --quiet httpd 2>/dev/null; then
    ok "httpd active"
elif systemctl is-active --quiet apache2 2>/dev/null; then
    ok "apache2 active"
else
    fail "neither httpd nor apache2 is active"
    systemctl status httpd --no-pager 2>/dev/null || systemctl status apache2 --no-pager 2>/dev/null
fi

echo -n " • Version               : "
if command -v httpd >/dev/null 2>&1; then
    ok "$(httpd -v 2>/dev/null | head -n1)"
elif command -v apache2 >/dev/null 2>&1; then
    ok "$(apache2 -v 2>/dev/null | head -n1)"
else
    fail "httpd/apache2 binary not found"
fi

echo -n " • Default page (localhost) : "
curl -s -m 6 http://localhost -o /tmp/charlie-curl-test.html 2>/dev/null
if grep -qi "It works!" /tmp/charlie-curl-test.html 2>/dev/null; then
    ok "shows default 'It works!' page"
else
    fail "default page not detected"
    if [ -s /tmp/charlie-curl-test.html ]; then
        echo "   → Got something else:"
        head -n 6 /tmp/charlie-curl-test.html | sed 's/^/     /'
    else
        echo "   → connection refused / timeout"
    fi
fi
rm -f /tmp/charlie-curl-test.html

# ── 2. PHP ────────────────────────────────────────────────
echo
echo "2. PHP"
echo "──────────────────────────────────────────────"
echo -n " • CLI version           : "
command -v php >/dev/null && ok "$(php -v | head -n1)" || fail "php binary not found"

echo -n " • info.php (web)        : "
if curl -s -m 7 http://localhost/info.php 2>/dev/null | grep -qi phpinfo; then
    ok "returns phpinfo() content"
else
    fail "info.php not working or missing"
fi

echo -n " • mysqlnd extension     : "
if php -m 2>/dev/null | grep -qi mysqlnd; then
    ok "loaded"
else
    fail "mysqlnd NOT loaded"
    php -m | grep -i mysql 2>/dev/null | sed 's/^/  → /'
fi

# ── 3. MySQL client ───────────────────────────────────────
echo
echo "3. MySQL / MariaDB Client"
echo "──────────────────────────────────────────────"
echo -n " • mysql command         : "
if command -v mysql >/dev/null 2>&1; then
    ok "$(mysql --version | head -n1)"
else
    fail "mysql client not installed"
fi

# ── 4. Web root permissions ───────────────────────────────
echo
echo "4. Web Root Permissions (/var/www/html)"
echo "──────────────────────────────────────────────"
for d in /var/www /var/www/html; do
    if [ -d "$d" ]; then
        stat_info=$(stat -c "%A %U:%G" "$d" 2>/dev/null)
        case "$stat_info" in
            drwxr-xr-x*apache* | drwxr-xr-x*httpd* | drwxr-xr-x*www-data*)
                ok "$d → $stat_info"
                ;;
            *)
                fail "$d → $stat_info"
                warn "Recommended: chown -R apache:apache /var/www && chmod -R 755 /var/www"
                ;;
        esac
    else
        warn "Directory not found → $d"
    fi
done

# ── 5. IAM role metadata check ────────────────────────────
echo
echo "5. IAM Role (EC2 metadata)"
echo "──────────────────────────────────────────────"
echo -n " • Metadata reachable    : "
if curl -s -m 4 http://169.254.169.254/latest/meta-data/ 2>/dev/null | grep -q .; then
    ok "IMDSv1 reachable"
else
    fail "cannot reach instance metadata"
fi

echo -n " • IAM role attached     : "
ROLE=$(curl -s -m 5 http://169.254.169.254/latest/meta-data/iam/info 2>/dev/null | grep -o '"InstanceProfileArn"[^}]*}' || true)
if [[ $ROLE == *"arn:aws:iam::"* ]]; then
    ok "IAM role detected"
    echo "   → $ROLE"
else
    warn "No IAM role attached (or IMDSv2 required)"
fi

# ── 6. Secrets Manager quick smoke test ───────────────────
echo
echo "6. AWS Secrets Manager – CafeDevDBSM"
echo "──────────────────────────────────────────────"
echo -n " • aws cli can see secret : "
if aws secretsmanager get-secret-value --secret-id CafeDevDBSM --region us-east-1 --query SecretString --output text >/dev/null 2>&1; then
    ok "Secret retrieved successfully"
elif aws sts get-caller-identity >/dev/null 2>&1; then
    fail "Secret 'CafeDevDBSM' not found or no permission"
else
    fail "aws cli not authenticated / not installed"
fi

# ── 7. Database connectivity & sample data check ──────────
echo
echo "7. Charlie Cafe Database Checks"
echo "──────────────────────────────────────────────"

if ! command -v mysql >/dev/null; then
    fail "mysql client missing → skipping DB checks"
else
    # You MUST replace these with real values or source them from Secrets Manager / env
    # For automated test → better to source from a file or SSM/Secrets
    DB_HOST="localhost"
    DB_USER="cafeuser"
    DB_PASS="temporary-for-testing-only"
    DB_NAME="charlie_cafe"

    MYSQL_CMD="mysql -h ${DB_HOST} -u ${DB_USER} --password=${DB_PASS} -D ${DB_NAME} --skip-column-names --batch -e"

    echo -n " • Can connect to DB     : "
    if $MYSQL_CMD "SELECT 1" >/dev/null 2>&1; then
        ok "connection successful"
    else
        fail "cannot connect"
        echo "   → try: export DB_PASS=... then re-run"
        echo "   → or source credentials from Secrets Manager"
        ((FAILURES++))
    fi

    if [ $FAILURES -eq 0 ] || true; then   # continue even if connect failed (show all issues)
        echo -n " • Table 'orders' exists : "
        if $MYSQL_CMD "SHOW TABLES LIKE 'orders'" | grep -q orders; then
            ok "found"
        else
            fail "table 'orders' not found"
        fi

        echo -n " • Has some data         : "
        COUNT=$($MYSQL_CMD "SELECT COUNT(*) FROM orders" 2>/dev/null || echo "0")
        if [[ $COUNT -gt 0 ]]; then
            ok "${COUNT} row(s)"
        else
            warn "table empty or query failed"
        fi
    fi
fi

# ── Final summary ─────────────────────────────────────────
echo
echo "══════════════════════════════════════════════════════════════"
echo -n "         FINAL RESULT         →  "
if [ ${FAILURES} -eq 0 ]; then
    echo -e "${GREEN}ALL CRITICAL CHECKS PASSED ✓${NC}"
else
    echo -e "${RED}${FAILURES} failure(s) detected${NC}"
    echo "     Review the ✗ lines above"
fi
echo "══════════════════════════════════════════════════════════════"
echo

if [ ${FAILURES} -gt 0 ]; then
    echo "Quick remediation hints:"
    echo " • Apache     → sudo systemctl restart httpd"
    echo " • PHP module → sudo dnf install php-mysqlnd  (or yum)"
    echo " • Permissions→ sudo chown -R apache:apache /var/www"
    echo " • DB connect → verify credentials / security group / Secrets Manager"
    echo " • IAM        → attach role with SecretsManagerReadWrite policy"
    echo
fi

exit ${FAILURES}
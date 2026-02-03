# ☕ AWS CAFE — Test & Verification 

#### (FRONTEND EXTENSION LAB)

> **Lab Type:** Add-on / Enhancement

> **Risk Level:** Zero (No existing backend changes)

> **Purpose:** Improve customer experience with order tracking, billing, unique URLs, and printable receipts

----
# 🛠 SECTION 1️⃣ CAFE BASIC CONFIGURATIONS

## PHASE 1️⃣ — VERIFY LAMP + MySQL CLIENT

### 1️⃣ VERIFY LAMP + MySQL CLIENT (Amazon Linux 2023)

### 1️⃣ Method 1 – Automated Verification Using One Bash Script
> **📄 lamp-verify.sh**


#### 📣 How to use:

####  1️⃣ Save the script
```
sudo nano lamp-verify.sh
```

####  2️⃣ Make executable

```
sudo chmod +x lamp-verify.sh
```

####  3️⃣ Run (best as root/sudo)

```
sudo ./lamp-verify.sh
```

```
#!/bin/bash
# LAMP Stack Quick Verification Script (Apache + PHP + MySQL client)
# Amazon Linux 2 / 2023 edition friendly
# Run as root or with sudo

set -u
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "============================================================="
echo "     LAMP STACK VERIFICATION - $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================================="
echo

# Helper functions
ok()    { echo -e "${GREEN}✓ OK${NC} - $1"; }
fail()  { echo -e "${RED}✗ FAILED${NC} - $1"; ((FAILURES++)); }
warn()  { echo -e "${YELLOW}! $1${NC}"; }
check() { [ $? -eq 0 ] && ok "$1" || fail "$1"; }

FAILURES=0
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "not-detected")

echo "1. Basic system information"
echo "   • OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "   • Public IP (from metadata): ${PUBLIC_IP:-not detected}"
echo

# ── 1. Apache Web Test ───────────────────────────────────────────────
echo "1. Apache Web Server - http://localhost"
curl -s -m 5 http://localhost -o /tmp/curl-test.html 2>/dev/null

if grep -qi "It works!" /tmp/curl-test.html 2>/dev/null; then
    ok "Apache serves 'It works!' on port 80"
else
    fail "Apache default page not found"
    if [ -s /tmp/curl-test.html ]; then
        echo "   → Got something but not expected:"
        head -n 5 /tmp/curl-test.html | sed 's/^/      /'
    else
        echo "   → Connection refused / timeout"
    fi
fi
rm -f /tmp/curl-test.html

# ── 2. PHP via web (info.php) ─────────────────────────────────────────
echo -n "2. PHP info page (info.php) ...................... "
if curl -s -m 7 http://localhost/info.php 2>/dev/null | grep -qi "phpinfo"; then
    ok "info.php returns phpinfo() content"
else
    fail "info.php not working"
    warn "→ Expected: http://<IP>/info.php shows PHP info page"
fi

# ── 3. MySQL client installed? ────────────────────────────────────────
echo -n "3. MySQL client command ........................... "
if command -v mysql >/dev/null 2>&1; then
    MYSQL_VER=$(mysql --version 2>/dev/null | head -n1)
    ok "mysql client found ($MYSQL_VER)"
else
    fail "mysql client not found"
    ((FAILURES++))
fi

# ── 4. Apache service status ──────────────────────────────────────────
echo -n "4. httpd/apache2 service status ................... "
if systemctl is-active --quiet httpd 2>/dev/null; then
    ok "httpd is active (running)"
elif systemctl is-active --quiet apache2 2>/dev/null; then
    ok "apache2 is active (running)"
else
    fail "httpd/apache2 service not running"
    systemctl status httpd --no-pager 2>/dev/null || systemctl status apache2 --no-pager 2>/dev/null
fi

# ── 5. Apache version ─────────────────────────────────────────────────
echo -n "5. Apache version ................................. "
if httpd -v >/dev/null 2>&1; then
    ok "$(httpd -v | head -n1)"
elif apache2 -v >/dev/null 2>&1; then
    ok "$(apache2 -v | head -n1)"
else
    fail "Cannot run httpd -v / apache2 -v"
fi

# ── 6. PHP CLI version ────────────────────────────────────────────────
echo -n "6. PHP CLI version ................................ "
if command -v php >/dev/null 2>&1; then
    ok "$(php -v | head -n1)"
else
    fail "php command not found"
fi

# ── 7. PHP modules - mysqlnd ──────────────────────────────────────────
echo -n "7. PHP mysqlnd extension .......................... "
if php -m 2>/dev/null | grep -qi mysqlnd; then
    ok "mysqlnd loaded"
else
    fail "mysqlnd NOT loaded in PHP"
    php -m | grep -i mysql 2>/dev/null | sed 's/^/      /'
fi

# ── 8. Important directories permissions ──────────────────────────────
echo "8. Web root permissions check (/var/www/html)"
for dir in /var/www /var/www/html; do
    if [ -d "$dir" ]; then
        STAT=$(stat -c "%A %U:%G" "$dir")
        if [[ $STAT == drwxr-xr-x*apache* || $STAT == drwxr-xr-x*httpd* || $STAT == drwxr-xr-x*www-data* ]]; then
            ok "$dir → $STAT"
        else
            fail "$dir → $STAT"
            warn "Recommended: sudo chown -R apache:apache /var/www && sudo chmod -R 755 /var/www"
        fi
    else
        warn "Directory not found: $dir"
    fi
done

echo
echo "============================================================="
echo -n "               FINAL RESULT:  "

if [ $FAILURES -eq 0 ]; then
    echo -e "${GREEN}ALL IMPORTANT CHECKS PASSED ✓${NC}"
else
    echo -e "${RED}$FAILURES failure(s) detected${NC}"
    echo "Review the ${RED}✗${NC} lines above"
fi
echo "============================================================="
echo

if [ $FAILURES -gt 0 ]; then
    echo "Quick fix suggestions:"
    echo "  • Apache not running → sudo systemctl start httpd"
    echo "  • PHP not loading    → sudo dnf/yum install php php-mysqlnd"
    echo "  • Wrong permissions  → sudo chown -R apache:apache /var/www"
    echo "                       → sudo chmod -R 755 /var/www"
    echo
fi
```

### 2️⃣ Method 2 – Manual Step-by-Step Testing (One by One)

### 1️⃣ Apache Test

#### Open browser:

```
http://<EC2-PUBLIC-IP>/
```

#### You should see:

```
It works!
```

### 2️⃣ PHP Test

#### Open:

```
http://<EC2-PUBLIC-IP>/info.php
```

#### You should see:

- PHP version

- mysqlnd enabled

### 3️⃣ MySQL Client Test (SSH)

```
mysql --version
```

### 4️⃣ VERIFY APACHE (httpd) (CLI)

#### 1️⃣ Check Apache Service Status

```
sudo systemctl status httpd
```

#### ✅ Expected:

```
Active: active (running)
```

#### 2️⃣ Verify Apache Version

```
httpd -v
```

#### ✅ Expected:

```
Server version: Apache/2.4.xx (Amazon Linux)
```

#### 3️⃣ Test Apache Locally (CLI)

```
curl http://localhost
```

#### ✅ Expected:

```
It works!
```

⚠️ If not installed correctly, you’ll get connection refused.

### 5️⃣ VERIFY PHP (CLI)

#### 1️⃣ Check PHP Version

```
php -v
```

#### ✅ Expected:

```
PHP 8.x.x (cli)
```

#### 2️⃣ Create PHP Test File (CLI)

```
sudo nano /var/www/html/test.php
```

##### Paste:

```
<?php
echo "PHP is working";
phpinfo();
?>
```

**Save and exit.**

#### 3️⃣ Test PHP via Apache (LOCAL)

```
curl http://localhost/test.php
```

#### ✅ Expected:

- Text: PHP is working

- PHP info output (HTML text)

**This confirms:**

✔ Apache → PHP module works

✔ PHP interpreter works

### 6️⃣ VERIFY FILE PERMISSIONS (IMPORTANT)

```
ls -ld /var/www /var/www/html
```

#### ✅ Expected:

```
drwxr-xr-x apache apache ...
```

#### ✅ If not:

```
sudo chown -R apache:apache /var/www
```

```
sudo chmod -R 755 /var/www
```

### 7️⃣ VERIFY PHP ↔ MYSQL EXTENSION

```
php -m | grep mysql
```

#### ✅ Expected:

```
mysqlnd
```

### 8️⃣ 🧪 VERIFICATION 2 (MANDATORY)

#### 1️⃣ Test Landing Page

```
http://<EC2_PUBLIC_IP>/
```

#### ☑️ Confirm:

✔️ Logo visible

✔️ “Charlie Cafe” title visible

✔️ Hero image loads from S3

✔️ “Order Now” button works

**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---
## PHASE 2️⃣ — VERIFY IAM ROLE

### 1️⃣ Verify IAM Role is Attached

#### Run this on EC2:

###### If an IAM role is attached correctly to an EC2 instance, these MUST work:

```
curl http://169.254.169.254/latest/meta-data/iam/info
```

#### Expected output (example):

```
{
  "Code" : "Success",
  "LastUpdated" : "2026-01-04T10:22:18Z",
  "InstanceProfileArn" : "arn:aws:iam::123456789012:instance-profile/EC2-Cafe-Secrets-Role",
  "InstanceProfileId" : "AIPAXXXXXXXXX"
}
```

```
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/
```

#### Expected output (example):

```
EC2-Cafe-Secrets-Role
```

###### ✅ If role is attached, you will see JSON output.

**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**
---
## PHASE 3️⃣ — VERIFY CAFE DATABASE CONFIGURATIONS


```
sudo nano verify_cafe_rds_schema.sh
```

[Charlie Cafe Lab RDS Tests](../../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/verify_cafe_rds_schema.sh)

#### ▶️ How to Run

```
sudo chmod +x verify_cafe_rds_schema.sh
```

```
sudo ./verify_cafe_rds_schema.sh
```


### Method 1️⃣ Bash Scripting Cafe  RDS Tests

```
sudo nano rds-secret-test.sh
```

[Cafe RDS Tests for Phase 3](../../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/rds-secret-test.sh)

#### ▶️ How to Run

```
sudo chmod +x rds-secret-test.sh
```

```
sudo ./rds-secret-test.sh
```

### Method 2️⃣ Cafe  RDS Tests

#### 1️⃣ Verify Database

```
SHOW DATABASES;
```

#### 2️⃣ Verify table exists

```
SHOW TABLES;
```

##### You should see:

```
orders
```

### 3️⃣ Test insert manually (CLI)

```
INSERT INTO orders (customer_name, item, quantity)
VALUES ('CLI-Test', 'Coffee', 1);
```
#### 📢 Multi Values (with table_number)


```
-- For your first (simpler) table
INSERT INTO orders (table_number, customer_name, item, quantity) 
VALUES 
    (1, 'Ali Khan', 'Espresso', 2),
    (1, 'Sara Ahmed', 'Cappuccino', 1),
    (2, 'CLI-Test', 'Coffee', 1),
    (3, NULL, 'Latte', 3),
    (5, 'Ahmed Raza', 'Croissant + Tea', 1);
``` 

### 4️⃣ Verify:

```
SELECT * FROM orders;
```

###### ✅ If you see the row → DB is READY

#### 5️⃣ Exit MySQL:

```
EXIT;
```

**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---
## PHASE 4️⃣ — VERIFY Secrets Manager
> **Test Secrets Manager Access from EC2**

### 1️⃣ Install AWS CLI if not present:

```
sudo dnf install -y awscli
```

### 2️⃣ Run:

```
aws secretsmanager get-secret-value \
  --secret-id CafeDevDBSM \
  --region us-east-1
```

#### ✅ If secret value is returned → IAM role works

For example !

```
{
    "ARN": "arn:aws:secretsmanager:us-east-1:910599465397:secret:CafeDevDBSecret-OgLDg9",
    "Name": "CafeDevDBSM",
    "VersionId": "bbdf3ecb-5d93-46ae-8049-5e4d4164fc10",
    "SecretString": "{\"username\":\"cafe_user\",\"password\":\"StrongPassword123\",\"host\":\"10.0.0.130\",\"dbname\":\"cafe_db\"}",
    "VersionStages": [
        "AWSCURRENT"
    ],
    "CreatedDate": "2025-12-27T10:25:34.199000+00:00"
}
```

**✅ PHASE 4️⃣ STATUS**

> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**


# 🟢 SECTION 1️⃣ COMPLETE & VERIFIED
---


# ☕ AWS CAFE — SALES ANALYTICS & REPORTING SYSTEM

# 




# 🟢 SECTION 1️⃣ COMPLETE & VERIFIED
---
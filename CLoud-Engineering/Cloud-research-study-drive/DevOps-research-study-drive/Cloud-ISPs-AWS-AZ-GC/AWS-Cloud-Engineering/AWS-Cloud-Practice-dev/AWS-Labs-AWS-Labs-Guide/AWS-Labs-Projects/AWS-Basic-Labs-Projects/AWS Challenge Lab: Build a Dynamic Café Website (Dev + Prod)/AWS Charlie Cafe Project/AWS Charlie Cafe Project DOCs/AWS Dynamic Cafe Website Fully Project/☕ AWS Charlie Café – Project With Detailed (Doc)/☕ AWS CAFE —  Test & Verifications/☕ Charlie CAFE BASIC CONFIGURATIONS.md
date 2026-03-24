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

## 📢 SECTION 1️⃣ CAFE BASIC CONFIGURATIONS COMPLETE ✅
---
## 📢 SECTION 2️⃣ CAFE DATABASE CONFIGURATIONS

## PHASE 3️⃣ — VERIFY CAFE DATABASE CONFIGURATIONS

🔐 Reads DB creds from AWS Secrets Manager

🔌 Connects to RDS MySQL

✅ Verifies database

✅ Verifies all tables

✅ List ALL tables

✅ DESCRIBE each table (manual-style verification)

✅ Verify critical columns

✅ Verify indexes / constraints

✅ Show row counts per table

✅ Show sample data

✅ Read-only (NO schema changes)

📊 Gives clear pass/fail output

```
sudo nano verify_charlie_cafe_rds.sh
```

[Charlie Cafe Lab RDS Tests](../../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/AWS%20RDS%20Bash%20Scripts/verify_charlie_cafe_rds.sh)

#### ▶️ How to Run

```
sudo chmod +x verify_charlie_cafe_rds.sh
```

```
sudo ./verify_charlie_cafe_rds.sh
```


### Method 1️⃣ Bash Scripting Cafe  RDS Tests

```
sudo nano rds-secret-test.sh
```

[Cafe RDS Tests for Phase 3](../../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/AWS%20RDS%20Bash%20Scripts/rds-secret-test.sh)

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

### 5️⃣ Database Schema & Data Verification Query

```
SELECT TABLE_NAME, COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_KEY, COLUMN_DEFAULT, EXTRA
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'cafe_db'
AND TABLE_NAME IN ('attendance','employees','holidays','leaves','orders')
ORDER BY TABLE_NAME, ORDINAL_POSITION;
```

### 🔍 Test timezone in RDS:

```
SELECT CONVERT_TZ(NOW(), '+00:00', '+05:00');
```

#### If result is:

✅ correct time → good

❌ NULL → timezone not loaded

###### ✅ If you see the row → DB is READY

#### 6️⃣ Exit MySQL:

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

## 📢 SECTION 2️⃣ CAFE BASIC CONFIGURATIONS COMPLETE ✅
---
## 📢 SECTION 4️⃣ CAFE FRONTEND CONFIGURATIONS

## ☕ AWS CAFE - PHASE 1️⃣ FRONTEND central FOUNDATION (REUSABLE)

### 1️⃣ Verify  file path

#### 1️⃣ Verify central-auth-api.js

```
sudo ls -lh /var/www/html/js/central-auth-api.js
```

#### 2️⃣ Verify central_cafe_style.css


```
sudo ls -lh /var/www/html/css/central_cafe_style.css
```

**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---
## ☕ AWS CAFE - PHASE 3️⃣ FrontEnd Deployment Final Configurations

### 1️⃣ Double-check file path

```
sudo ls -lh /var/www/html/*
```

### 2️⃣ Open page in browser (MANDATORY)

```
http:// Your EC2 Public IP/index.php
```

```
http:// Your EC2 Public IP/cafe-admin-dashboard.html
```

```
http:// Your EC2 Public IP/orders.php
```

```
http:// Your EC2 Public IP/order-status.html
```

```
http:// Your EC2 Public IP/order-receipt.php
```

```
http:// Your EC2 Public IP/admin-orders.php
```

```
http:// Your EC2 Public IP/admin-orders.php
```

```
http:// Your EC2 Public IP/payment-status.php
```

### 3️⃣ VERIFY (THIS MUST TURN GREEN)

Run again:

```
curl -I http://localhost/js/central-auth-api.js
```

#### ✅ EXPECTED:

```
HTTP/1.1 200 OK
Content-Type: application/javascript
```

Then:

```
curl -I http://charlie-cafe-alb-1179524333.us-east-1.elb.amazonaws.com/js/central-auth-api.js
```

Then:

```
curl -I https://dc65q9cmuuula.cloudfront.net/js/central-auth-api.js
```

Run the fixes above and paste only this output back:

```
curl -I http://localhost/js/central-auth-api.js
```

#### 4️⃣ Ensure <Directory> allows access

Check /etc/httpd/conf/httpd.conf:

```
<Directory "/var/www/html">
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>
```

Then add explicitly for JS:

```
<Directory "/var/www/html/js">
    Require all granted
</Directory>
```

#### 5️⃣ Check for .htaccess overrides

```
ls -la /var/www/html/js/.htaccess
```

If exists, check for Deny from all → comment it out.

#### 6️⃣ Restart Apache

```
sudo systemctl restart httpd
```

#### 7️⃣ Test locally (CRUCIAL)

```
curl -I http://localhost/js/central-auth-api.js
```

### ⚡ Quick One-Line Fix (Recursively fixes everything for html/js folder):

```
sudo chown -R apache:apache /var/www/html && sudo find /var/www/html -type d -exec chmod 755 {} \; && sudo find /var/www/html -type f -exec chmod 644 {} \; && sudo restorecon -Rv /var/www/html && sudo systemctl restart httpd
```

✅ Should return 200 OK
✅ If yes → ALB and CloudFront automatically work


**✅ All three must return 200 OK.**

#### ⚠️ Use * to apply it to all files (all extensions) in the directory:

```
sudo chown apache:apache /var/www/html/*
```

```
sudo chmod -R 755 /var/www/html/*
```

```
sudo chmod 644 /var/www/html/*
```

#### 👉 If you also want subdirectories included, use:

```
sudo chown -R apache:apache /var/www/html
```
```
sudo chmod -R 644 /var/www/html
```

**⚠️ Note: 644 on directories can break access; if needed, say so and I’ll give the correct mixed permissions.**


**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**

## 📢 SECTION 3️⃣ CAFE DATABASE CONFIGURATIONS COMPLETE ✅
---`
## 📢 SECTION 4️⃣ Secure Admin Order Dashboard

This is exactly how a real production deployment is validated.

We will test:

- Cognito infrastructure

- Hosted UI login

- JWT token correctness

- API Gateway authorizer

- Lambda role enforcement

- Public vs Protected separation

- Failure scenarios (VERY important)

All based on:

- Amazon Cognito

- Amazon API Gateway

- AWS Lambda

## 🔐 PHASE 1️⃣ — Cognito Authentication infrastructure 

### ✅ TEST 1 — User Pool Exists

- Go to: Cognito → User Pools

#### ✅ Verify:

✔ Your pool exists

✔ Region correct (us-east-1)

✔ Status = Active

### ✅ TEST 2 — App Client Configuration

- Go to: User Pool → App clients → Show details

Verify:

| Setting                  | Must Be                |
| ------------------------ | ---------------------- |
| App type                 | Public client          |
| Client secret            | ❌ Disabled             |
| Authorization code grant | ✅ Enabled              |
| Implicit grant           | ❌ Disabled             |
| Scopes                   | openid, email, profile |

If any mismatch → fix before continuing.

### ✅ TEST 3 — Callback & Logout URLs

- Go to: User Pool → App integration → App client → Edit

#### ✅ Verify EXACT match:

```
https://YOUR_CLOUDFRONT/login.html
https://YOUR_CLOUDFRONT/logout.html
```

⚠ Must match character by character

⚠ https required

⚠ No trailing slash difference

- Save → wait 60 seconds.

### ✅ TEST 4 — Groups & Users

- Go to: User Pool → Groups

#### ✅ Verify:

✔ Admin

✔ Manager

✔ Employee

#### ✅ Now check:

- User Pool → Users

- Open each user → Groups tab

#### ✅ Verify:

| User      | Group    |
| --------- | -------- |
| cafeadmin | Admin    |
| manager1  | Manager  |
| ali       | Employee |


If group missing → JWT will not contain cognito:groups.

### ✅ TEST 5 — Manual Login URL

#### ✅ Construct this in browser:

```
https://YOUR_DOMAIN.auth.us-east-1.amazoncognito.com/login
?client_id=YOUR_CLIENT_ID
&response_type=code
&scope=openid+email+profile
&redirect_uri=https://YOUR_CLOUDFRONT/login.html
```

- Open in browser.

#### ✅ Expected:

✔ Cognito login page appears

✔ Enter credentials

✔ Redirects to:

```
https://YOUR_CLOUDFRONT/login.html?code=XYZ123
```

If you see error:

"invalid_request" → check callback URL

"unauthorized_client" → wrong OAuth flow

redirect mismatch → fix exact URL

### 🔐 TEST 6 — Token Exchange Verification

- Now your frontend must exchange code → tokens.

- After exchange, verify:

- Open DevTools → Application → Local Storage

You must see:

```
access_token
id_token
refresh_token
```

If missing → your frontend token exchange is wrong.

### ✅ TEST 7 — Decode Token

> **Verify Token Is Valid**

- Copy access_token.

- Go to [jwt.io](https://jwt.io)

- Paste access_token.

#### ✅ Verify:

- Payload contains:

You see:

```
"cognito:groups"
"email"
"sub"
"exp"
```

If cognito:groups missing → user not assigned to group.


### 🏁 FINAL VERIFICATION CHECKLIST

✔ User pool correct

✔ Public client

✔ Authorization code flow

✔ Groups assigned

✔ Hosted UI works

✔ Token stored

✔ JWT contains groups


## 📢 SECTION 4️⃣ CAFE DATABASE CONFIGURATIONS COMPLETE ✅
---`
## 📢 SECTION 4️⃣ Charlie Cafe Verification 

## PHASE 1️⃣ Charlie Cafe Basic Lab Configuration Test and Verification

### Bash Script

Perfect, this is a serious lab-grade requirement, so I’ll give you a clean, safe, no-bug, production-ready verification script that:

✔ Combines LAMP verification + RDS verification

✔ Shows test list before execution

✔ Shows results during execution

✔ Shows final summarized results

✔ Exports full output to a file

✔ Uploads that file to S3 automatically

✔ Uses explicit AWS Access Key & Secret (you replace them)

✔ Uses clear comments everywhere

✔ Is read-only (no DB changes)

✔ CSV export (machine-readable summary)

✔ Fully commented

✔ Uploads TXT + CSV to S3

### 📄 File Name: charlie_cafe_lab_verify.sh

### 📦 Output Details

#### Local file: Basic_Config_Test_Result_<DATE>.txt

#### S3 bucket: charlie-cafe-s3-bucket

#### S3 folder: Charlie Cafe Test and Verification/

### 📂 Final Output in S3

```
charlie-cafe-s3-bucket/
└── Charlie Cafe Test and Verification/
    ├── Basic_Config_Test_Result_2026-02-03_10-41-22.txt
    └── Basic_Config_Test_Result_2026-02-03_10-41-22.csv
```
### 1️⃣ Final & Last Charlie Cafe Test

```
sudo nano Charlie-Cafe-Final-Verify-Test.sh
```

[Charlie-Cafe-Final-Verify-Test.sh](../../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/Charile%20Cafe%20Mega%20Testing%20Bash-Script/Charlie-Cafe-Final-Verify-Test.sh)

```
sudo chmod +x Charlie-Cafe-Final-Verify-Test.sh
```

```
sudo ./Charlie-Cafe-Final-Verify-Test.sh
```

### 💿 Things to Replace / Configure in Script

- #### S3 Bucket Name

    - Variable: OUTPUT_S3_BUCKET

    - Example: charlie-cafe-test-results

- #### API Gateway Base URLs

Variables:

    - API_DEV → Development endpoint

    - API_PROD → Production endpoint

    - API_STATUS → Status endpoint

Example:

```
API_DEV="https://abcd1234.execute-api.us-east-1.amazonaws.com/dev"
API_PROD="https://abcd1234.execute-api.us-east-1.amazonaws.com/prod"
API_STATUS="https://abcd1234.execute-api.us-east-1.amazonaws.com/status"
```

- #### ALB Domain Name

    - Variable: ALB_DOMAIN

    - Example: charlie-cafe-alb-123456789.us-east-1.elb.amazonaws.com

- #### CloudFront Domain Name

    - Variable: CLOUDFRONT_DOMAIN

    - Example: abcd1234.cloudfront.net

- #### AWS Region

    - Variable: AWS_REGION

    - Example: us-east-1

- #### Secrets Manager Secret Name for DB

    - Variable: SECRET_ID

    - Example: CafeDevDBSM

- #### Database Name

    - Variable: DB_NAME

    - Example: cafe_db

- #### Optional: Test Data / Payloads

    - JSON payloads for API POST requests or Lambda invocations

    - Example:

```
'{"table_number":1,"customer_name":"Test","item":"Coffee","quantity":2}'
```

- #### Optional: Local Web Root Path

    - Variable: WEB_ROOT

    - Example: /var/www/html

- #### Optional: Lambda Function Names

    - Used in invoke_lambda calls

    - Example:

```
CafeOrderProcessor
CafeMenuLambda
CafeOrderApiLambda
```

#### ✅ Once you replace these variables with your real environment values, the mega script will run without needing AWS Access Keys (it will use EC2 IAM roles / instance credentials).


### 5️⃣ Exporting Bash Script Output to S3

#### 1️⃣ Create A file 

```
sudo nano export_bash_output_s3.sh
```

[Exporting Bash Script Output to S3](../../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/export_bash_output_s3/export_bash_output_s3.sh)

### 2️⃣ How to use:

- Make script executable:

```
sudo chmod +x export_bash_output_s3.sh
```

- Run your verification script through it:

```
sudo ./export_bash_output_s3.sh
```

### 3️⃣ EC2 Export to S3

```
sudo nano ec2-export-s3.sh
```

[EC2 Export to S3](../../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/charlie-cafe-export-s3-to-html/ec2-export-s3/ec2-export-s3.sh)

```
sudo chmod +x ec2-export-s3.sh
```
```
sudo ./ec2-export-s3.sh
```

**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**

---
## PHASE 2️⃣ FrontEnd Web 

### 1️⃣ Create the frontend HTML file

```
sudo nano /var/www/html/charlie-cafe-verify.html
```



```
sudo chown apache:apache /var/www/html/charlie-cafe-verify.html
```

```
sudo chmod 644 /var/www/html/charlie-cafe-verify.html
```

```
sudo systemctl restart httpd
```

### 2️⃣ upload your /var/www/html/ folder as a ZIP to an S3 bucket

### 1️⃣ Navigate to a working directory

Let’s go somewhere safe like /home/ec2-user/:

```
cd /home/ec2-user/
```

### 2️⃣ Create a ZIP of your HTML folder

Use zip to compress the /var/www/html/ folder. Name the ZIP html.zip:

```
sudo zip -r html.zip /var/www/html/
```

#### Explanation:

-r → recursive (include subfolders like css, js)

/var/www/html/ → folder to compress

html.zip → ZIP file created in current directory (/home/ec2-user/)

#### Check the ZIP:

```
ls -lh html.zip
```

### 3️⃣ Upload ZIP to S3 under a folder charliecafe-dev

S3 “folders” are just part of the object key. Use this command:

```
aws s3 cp html.zip s3://charlie-cafe-s3-bucket/charliecafe-dev/html.zip --region us-east-1
```

#### Explanation:

html.zip → local file

s3://charlie-cafe-s3-bucket/charliecafe-dev/html.zip → S3 path (creates charliecafe-dev/ folder automatically)

--region us-east-1 → AWS region

#### Check if it uploaded:

```
aws s3 ls s3://charlie-cafe-s3-bucket/charliecafe-dev/
```

#### You should see:

```
2026-02-11 17:45  123456 html.zip
```

### ✅ Optional: Upload entire HTML folder directly without ZIP

If you want all files and subfolders uploaded as-is to charliecafe-dev/:

```
aws s3 cp /var/www/html/ s3://charlie-cafe-s3-bucket/charliecafe-dev/ --recursive --region us-east-1
```

--recursive → uploads all files and subfolders

S3 will mirror the folder structure under charliecafe-dev/

#### Check:

```
aws s3 ls s3://charlie-cafe-s3-bucket/charliecafe-dev/
```

#### ✅ Summary of commands:

```
cd /home/ec2-user/
sudo zip -r html.zip /var/www/html/
aws s3 cp html.zip s3://charlie-cafe-s3-bucket/charliecafe-dev/html.zip --region us-east-1
# OR to upload all files directly
aws s3 cp /var/www/html/ s3://charlie-cafe-s3-bucket/charliecafe-dev/ --recursive --region us-east-1
```

# 📢 SECTION 4️⃣  COMPLETE ✅
---`



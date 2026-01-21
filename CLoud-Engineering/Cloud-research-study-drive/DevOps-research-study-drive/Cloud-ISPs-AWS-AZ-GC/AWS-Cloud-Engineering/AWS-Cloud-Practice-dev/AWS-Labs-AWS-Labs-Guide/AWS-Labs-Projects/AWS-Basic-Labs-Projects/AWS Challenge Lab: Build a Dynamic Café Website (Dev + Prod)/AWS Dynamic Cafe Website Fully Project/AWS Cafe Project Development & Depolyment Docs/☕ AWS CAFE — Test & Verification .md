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
# ☕ AWS CAFE — Order_Async_Processing_Tracking_System 

# 🛠 SECTION 1️⃣ Cafe Order Processor

## PHASE 7️⃣ — Test & Verification

### 1️⃣  FRONTEND → BACKEND VERIFICATION

#### 1️⃣ Submit order from orders.php

📊 Table Number: 2

☕ Item: Tea

👨🏾‍🍳 Quantity: 1

### 2️⃣  BACKEND VERIFICATION (MANDATORY)

### 1️⃣ Test Lambda Directly (Console)

- Check your Lambda CloudWatch logs to ensure the function executed correctly.

- Verify new orders appear in your MariaDB database.

- In Lambda → Test

- **Event name:** Test_CafeOrderProcessor

#### Test Event JSON:

```
{
  "body": "{\"customer_name\":\"LambdaTest\",\"item\":\"Coffee\",\"quantity\":2}"
}
```

#### Expected result:

```
{
  "statusCode": 200,
  "body": "{\"message\":\"Order saved successfully\"}"
}
```
#### Test Updated Event JSON:

```
{
  "body": "{\"table_number\":1,\"customer_name\":\"LambdaTest\",\"item\":\"Coffee\",\"quantity\":2}"
}
```

#### Expected result:

```
1 | LambdaTest | Coffee | 2 | 2026-01-10 10:32:11
```
---

### Method 2️⃣ Cafe Order API + RDS Tests

### 1️⃣ Test API Gateway

#### Test via CURL

```
curl -X POST \
  https://svirhyw5a3.execute-api.us-east-1.amazonaws.com/dev/orders \
  -H "Content-Type: application/json" \
  -d '{"customer_name":"TestUser","item":"Latte","quantity":1}'
```

#### Expected result:

```
{
  "message": "Order placed successfully"
}
```

#### ✅ New UPDATED API GATEWAY CURL TEST AFTER ADDED TABLE NUMBER (REQUIRED)

```
curl -X POST \
  https://svirhyw5a3.execute-api.us-east-1.amazonaws.com/dev/orders \
  -H "Content-Type: application/json" \
  -d '{
    "table_number": 3,
    "customer_name": "TestUser",
    "item": "Latte",
    "quantity": 1
  }'
```

#### 🟢 Expected Response (SUCCESS)

```
{
  "message": "Order saved successfully",
  "table_number": 3
}
```

#### 🟢 API GATEWAY TEST (MANDATORY)

- **go to  CafeOrderAPI > post method > Test Event Body**

```
{
  "table_number": 5,
  "customer_name": "Charlie",
  "item": "Coffee",
  "quantity": 2
}
```

#### Expected Result

```
{
  "message": "Order saved successfully",
  "table_number": 5
}
```

### 2️⃣ Verify Database

### Method 1 Simple 1-To-1 RDS Test

```
mysql -u cafe_user -p cafe_db
```

or

```
mysql -h <rds-endpoint> -u cafe_user -p
```

```sql
SELECT * FROM orders ORDER BY id DESC;
```
or 
```
use cafe_db;
```
```
SELECT * FROM orders;
```

#### You should see:

```
EC2-Test | Latte | 1
```

#### Updated RDS

```
SELECT id, table_number, customer_name, item, quantity, created_at
FROM orders
ORDER BY id DESC;
```

✔ table_number populated

✔ created_at auto-generated

✔ No duplicate or missing fields

---

#### 3️⃣ Check CloudWatch Logs

- **Lambda → Monitor → Logs**

### You should see:

```
START RequestId:
END RequestId:
```

❌ No SQL errors

---

### 🟢 Common Mistakes (Avoid These)

| Mistake                | Result             |
| ---------------------- | ------------------ |
| Missing `table_number` | 500 error          |
| table_number as string | Type error         |
| quantity ≤ 0           | Validation failure |
| Wrong API stage        | Order not inserted |

### 🟢 SYSTEM STATUS CHECK

✔ API Gateway updated

✔ Lambda aligned

✔ RDS schema aligned

✔ Frontend orders.php aligned

Your system is now schema-consistent from browser → DB.

---

### 🏆 Result

#### You now have:

☕ Restaurant-style table orders

📊 Future-ready analytics

🧱 No backend breakage

🚀 Production-safe change


**✅ PHASE 7️⃣ STATUS**

> **🟢 PHASE 7️⃣ COMPLETE & VERIFIED**

# 🟢 SECTION 1️⃣ COMPLETE & VERIFIED
---
# 🛠 SECTION 3️⃣ — AWS CAFE SQS (Async Order Processing)

## PHASE 3️⃣ — Verification SQS/LAMBDA (Producer)

#### 1️⃣ CREATE LAMBDA TEST (CONSOLE TEST)

- Click Test

- Select Create new test event

- Event name:

```
ApiOrderTest
```

Event JSON:


```
{
  "body": "{\"table_number\":1,\"customer_name\":\"ConsoleTest\",\"item\":\"Latte\",\"quantity\":2}"
}
```

Click Save

Click Test

#### Expected Result (SUCCESS)

```
{
  "statusCode": 202,
  "body": "{\"message\":\"Order accepted\",\"order\":{\"table_number\":1,\"customer_name\":\"ConsoleTest\",\"item\":\"Latte\",\"quantity\":2}}"
}
```

#### CloudWatch Logs:

```
Order accepted
```

#### SQS:

- Message appears briefly

- Then disappears (worker consumes it)

#### RDS:

```
SELECT * FROM orders ORDER BY id DESC;
```

#### Result:

```
id | table_number | customer_name | item  | quantity | created_at
---------------------------------------------------------------
12 | 1            | ConsoleTest   | Latte | 2        | 2026-01-xx
```

#### 2️⃣ VERIFY MESSAGE IN SQS (CRITICAL)

- AWS Console → SQS

- Click CafeOrdersQueue

- Click Send and receive messages

- Click Poll for messages

#### Expected Output:

You should see message like:

```
{
  "customer_name": "ConsoleTest",
  "item": "Latte",
  "quantity": 2
}
```

✅ If message exists → Producer Lambda WORKS

#### SQS Message Body (Manual Test)

```
{
  "table_number": 2,
  "customer_name": "WorkerTest",
  "item": "Latte",
  "quantity": 2
}
```
---

### 3️⃣ Frontend (orders.php)

You already fixed it ✔
Ensure payload includes:

```
{
  "table_number": 1,
  "customer_name": "Charlie",
  "item": "Tea",
  "quantity": 2
}
```

### 4️⃣ Test with API Gateway or Lambda test

#### Update test body

```
{
  "table_number": 3,
  "customer_name": "ApiTest",
  "item": "Coffee",
  "quantity": 1
}
```
#### curl Test

```
curl -X POST \
  https://svirhyw5a3.execute-api.us-east-1.amazonaws.com/dev/orders \
  -H "Content-Type: application/json" \
  -d '{"table_number":3,"customer_name":"CurlTest","item":"Tea","quantity":2}'
```

### 🔍 METHOD A — TEST USING LAMBDA CONSOLE (EASIEST)

> **This tests only the Lambda logic, not API Gateway.**

#### 🟦 A1 — OPEN THE PRODUCER LAMBDA

- AWS Console → Lambda

- Click your Order API Lambda
(the one sending messages to SQS)

#### 🟦 A2 — CREATE A TEST EVENT

- Click Test

- Click Create new event

**Event configuration:**

| Field      | Value             |
| ---------- | ----------------- |
| Event name | `SqsProducerTest` |
| Template   | `Hello World`     |


#### 🟦 A3 — REPLACE EVENT JSON (IMPORTANT)

#### Delete everything and paste exactly:

```
{
  "body": "{\"customer_name\":\"ConsoleTest\",\"item\":\"Latte\",\"quantity\":2}"
}
```

#### ⚠️ Notice:

- body must be a STRING

- This simulates API Gateway behavior

#### 🟦 A4 — RUN TEST

- Click Save

- Click Test

#### ✅ EXPECTED RESULT (LAMBDA)

**Lambda Response:**

```
{
  "statusCode": 202,
  "body": "{\"message\": \"Order accepted\"}"
}
```

#### 🟦 A5 — VERIFY MESSAGE IN SQS

- AWS Console → SQS

- Click CafeOrdersQueue

- Click Send and receive messages

- Click Poll for messages

#### ✅ You should see:

```
{
  "customer_name": "ApiTestUser",
  "item": "Latte",
  "quantity": 1
}
```

If you see this → Producer Lambda works perfectly ✅

### 🌐 METHOD B — TEST USING API GATEWAY (REAL END-USER TEST)

This tests the full HTTP flow.

#### 🟦 B1 — OPEN API GATEWAY

- AWS Console → search API Gateway

- Click API Gateway

- Click your Order API (REST API)

#### 🟦 B2 — SELECT THE RESOURCE

#### In left panel, expand:

- /orders (or your order path)

- Click POST

#### 🟦 B3 — USE API GATEWAY TEST FEATURE

- Click Test (⚠️ NOT Deploy)

#### In Request Body, paste:

```
{
  "customer_name": "ApiTestUser",
  "item": "Latte",
  "quantity": 1
}
```

- Click Test

#### ✅ EXPECTED API RESPONSE 

#### Status:

```
202
```

#### Body:

```
{"message":"Order accepted"}
```

#### 🟦 B4 — VERIFY SQS MESSAGE

#### Same as before:

- SQS → CafeOrdersQueue

- Send and receive messages

- Poll for messages

#### You should see:

```
{
  "customer_name": "ApiTestUser",
  "item": "Latte",
  "quantity": 1
}
```

### 🌍 METHOD C — TEST USING PUBLIC API URL (OPTIONAL BUT REALISTIC)

#### If API is deployed:

#### 🟦 C1 — GET INVOKE URL

- API Gateway → Stages

- Click your stage (e.g., prod)

- Copy Invoke URL

#### Example:

```
https://abcd1234.execute-api.ap-south-1.amazonaws.com/prod/orders
```

#### 🟦 C2 — TEST USING CURL (OPTIONAL)

```
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"order_id":"ORD-3001","item":"Tea","quantity":3}' \
  https://abcd1234.execute-api.ap-south-1.amazonaws.com/prod/orders
```

#### 🟦 C3 — VERIFY SQS

- Same verification steps.

### 6️⃣ Worker Lambda

#### Must read:

```
table_number = order["table_number"]
```

#### and insert:

```
INSERT INTO orders (table_number, customer_name, item, quantity)
```

### 🧠 RULE TO REMEMBER (VERY IMPORTANT)

Every layer must send the SAME JSON shape

```
{
  "table_number": INT,
  "customer_name": STRING,
  "item": STRING,
  "quantity": INT
}
```

If one layer misses a field, the pipeline breaks.

**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---

## PHASE 7️⃣ — Verification SQS/Worker LAMBDA (Consumer)


### 1️⃣ Test manually from Lambda console

#### 1️⃣ You must wrap the test event in Records:

- **Event name:** Test_CafeOrderWorker

```
{
  "Records": [
    {
      "body": "{\"table_number\": 1, \"customer_name\": \"WorkerTest\", \"item\": \"Coffee\", \"quantity\": 2}"
    }
  ]
}
```

✔ Inserts into RDS

✔ Updates DynamoDB

✔ No retries

✔ No errors

- This mimics SQS event structure

- Now the Lambda code won’t fail with 'Records'


#### ✅ EXPECTED CLOUDWATCH LOGS (SUCCESS)

You should see:

```
DEBUG: Lambda invoked
DEBUG: Event = {...}
DEBUG: Secret fetched
DEBUG: RDS connected
✅ Order processed: {...}
```

#### 2️⃣ Verify RDS

```
mysql -h <rds-endpoint> -u cafe_user -p cafe_db
```

```
SELECT * FROM orders ORDER BY id DESC;
```

#### Expected row:

```
WorkerTest | Coffee | 2
```

#### 3️⃣ Verify DynamoDB

- DynamoDB → CafeMenu → Coffee

- Attribute orders increased

### 2️⃣ TEST END-TO-END (MANDATORY)

#### 🧪 TESTING OVERVIEW

```
API Gateway / Manual SQS
        ↓
CafeOrdersQueue
        ↓
CafeOrderWorker (AUTO)
        ↓
RDS + DynamoDB
```

**We will test in 2 ways:**

1️⃣ Direct SQS test (simplest, safest)

2️⃣ Full end-to-end API test

> **Start with Method 1. Do NOT skip it.**

#### ✅ METHOD 1 — TEST WORKER LAMBDA DIRECTLY VIA SQS (RECOMMENDED FIRST)

This avoids API Gateway confusion.

#### 🟩 STEP 1 — OPEN SQS QUEUE

- AWS Console → SQS

- Click CafeOrdersQueue

- Click Send and receive messages

#### 🟩 STEP 2 — SEND A TEST MESSAGE (MANUAL)
- Click Send message

- Message body (COPY EXACTLY):

```
{
  "table_number": 5,
  "customer_name": "WorkerTest",
  "item": "Coffee",
  "quantity": 2
}
```

Leave everything else default

- Click Send message

✅ Message successfully sent

#### 🟩 STEP 3 — WAIT (IMPORTANT)

⏳ Wait 5–10 seconds

Lambda polls SQS automatically

You do NOT click anything

#### 🟩 STEP 4 — CONFIRM MESSAGE IS CONSUMED

- Still inside CafeOrdersQueue

- Click Send and receive messages

- Click Poll for messages

#### Expected result:

```
No messages available
```

#### ✅ This means:

- Worker Lambda ran

- Message was deleted

- No errors

#### 🟩 STEP 5 — CHECK WORKER LAMBDA LOGS (MANDATORY)

- AWS Console → CloudWatch

- Click Logs → Log groups

#### Open:

```
/aws/lambda/CafeOrderWorker
```

- Click latest log stream

#### You should see lines like:

```
START RequestId:
Order processed: {'customer_name': 'WorkerTest', 'item': 'Coffee', 'quantity': 2}
END RequestId:
REPORT RequestId:
```

#### ✅ This confirms:

- Worker Lambda executed

- JSON parsed

- No retries

#### 🟩 STEP 6 — VERIFY DATABASE (MANDATORY)

#### From EC2 or DB client:

```
mysql -h <rds-endpoint> -u cafe_user -p cafe_db
```

```
SELECT * FROM orders ORDER BY id DESC;
```

or 

```
SELECT * FROM orders ORDER BY created_at DESC;
```

#### Expected:

```
WorkerTest | Coffee | 2
```

table_number ✅

status = RECEIVED ✅

created_at auto-filled ✅

#### 🟩 STEP 7 — VERIFY DYNAMODB (CafeMenu)

- AWS Console → DynamoDB

- Click CafeMenu

- Click Explore table

- Click Coffee

#### Expected:

```
{
  "item": "Coffee",
  "price": 3,
  "orders": 14
}
```

- Attribute orders exists

- Value increased by 2

#### 🟩 STEP 8 — VERIFY CloudWatch Logs

```
✅ Order processed
```

No retries, no DLQ hits.



#### ✅ METHOD 1 COMPLETE

#### At this point:

- Worker Lambda is 100% working

- SQS trigger is correct

- IAM is correct

- VPC access is correct

#### 🚀 METHOD 2 — FULL END-TO-END TEST (API → SQS → WORKER)

Only do this AFTER Method 1 works

#### 🟦 STEP 1 — CALL API GATEWAY

#### From your terminal:

```
curl -X POST \
https://<api-id>.execute-api.us-east-1.amazonaws.com/dev/orders \
-H "Content-Type: application/json" \
-d '{
  "table_number": 2,
  "customer_name": "ApiTest",
  "item": "Latte",
  "quantity": 1
}'
```

#### Expected response:

```
{
  "message": "Order accepted"
}
```

#### 🟦 STEP 2 — CHECK SQS (BRIEFLY)

- Open CafeOrdersQueue

- You may see messages for a few seconds

- They should disappear automatically

#### 🟦 STEP 3 — CHECK WORKER LOGS

- CloudWatch → /aws/lambda/CafeOrderWorker

#### You should see:

```
Order processed: {'customer_name': 'ApiTest', 'item': 'Latte', 'quantity': 1}
```

#### 🟦 STEP 4 — VERIFY DB + DYNAMODB

- Same as Method 1

#### 🔁 FAILURE TEST (OPTIONAL BUT IMPORTANT)

#### To confirm retry behavior:

- Temporarily break worker code

```
raise Exception("FORCE FAIL")
```

- Send SQS message again

#### Observe:

- Message reappears after visibility timeout

- Multiple retries

- Logs show repeated failures

This proves production-grade reliability

### ✅ VERIFY SQS

#### 🟢 Method 1 — CloudWatch Logs (PRIMARY)

**CloudWatch → Logs →  /aws/lambda/CafeOrderWorker**

You should see entries like:

```
Lambda triggered by SQS
Order processed: {'customer_name': 'charlie', 'item': 'Tea', 'quantity': 2}
```

**✅ This is the proof.**

#### 🟢 Method 2 — SQS Metrics (BEST PRACTICE)

**SQS → CafeOrdersQueue → Monitoring**

#### Check these graphs:

| Metric                             | Expected |
| ---------------------------------- | -------- |
| NumberOfMessagesSent               | ↑        |
| NumberOfMessagesReceived           | ↑        |
| NumberOfMessagesDeleted            | ↑        |
| ApproximateNumberOfMessagesVisible | ~0       |

**✅ If Received & Deleted increase, your pipeline is healthy.**

#### 🟢 Method 3 — Disable Trigger (FOR LEARNING ONLY)

#### If you want to see messages again:

1️⃣ Lambda → CafeOrderWorker

2️⃣ Disable SQS trigger

3️⃣ Send message

4️⃣ Poll manually → message appears

Re-enable trigger afterward.

### ⚠️ VERY IMPORTANT AWS RULE (REMEMBER THIS)

> **You NEVER manually poll SQS when Lambda trigger is enabled**

That’s two consumers competing for the same messages.

### 🧠 WHY YOU CANNOT SEE THE MESSAGE IN SQS

**When SQS → Lambda trigger is enabled:**

- Lambda polls SQS automatically

- Message is:

  - Retrieved

  - Processed

  - Deleted immediately on success

- When you click Poll for messages in the console:

  - There is nothing left to poll

So you will see:

```
No messages available
```
**✅ This is SUCCESS, not a failure.**

### 🔄 WHY YOU COULD SEE MESSAGES BEFORE

#### Earlier, when:

- Trigger was disabled

- Lambda failed

- Or Lambda didn’t raise exceptions

Messages stayed in the queue → you could poll them manually.

#### Now:

- Lambda succeeds

- Messages are deleted

- Queue stays empty

---


### 🔥 IMPORTANT CLARIFICATIONS

#### ❓ Why SQS message disappeared?

**Because Lambda DID poll it, but timed out before completing**

- SQS deletes message only after successful invocation, but Lambda retried internally until timeout.

#### ❓ Why no logs before?

**Because:**

- Lambda couldn’t reach RDS

- Timeout occurred before prints

#### ❓ Is your code correct?

✅ YES — your code is PRODUCTION-GRADE

The issue was INFRASTRUCTURE, not logic.

### 🧠 FINAL DIAGNOSIS

| Component          | Status    |
| ------------------ | --------- |
| SQS                | ✅ Working |
| Lambda trigger     | ✅ Working |
| IAM                | ✅ Correct |
| Code               | ✅ Correct |
| **VPC attachment** | ❌ Missing |
| **Timeout**        | ❌ Too low |



### 🔑 COMMON MISTAKES (READ THIS)

❌ Using FIFO queue

❌ Same Lambda for producer + consumer

❌ Visibility timeout too low

❌ No IAM permissions

❌ Batch size > 1 while learning

### 🧠 KEY RULES TO REMEMBER (EXAM + REAL LIFE)

| Rule                      | Truth                    |
| ------------------------- | ------------------------ |
| Worker Lambda Test button | ❌ NOT USED               |
| SQS triggers Lambda       | ✅ AUTOMATIC              |
| Lambda deletes message    | ❌ AWS does after success |
| Exception = retry         | ✅ YES                    |
| No logs = no execution    | ❌ Wrong                  |

**✅ PHASE 7️⃣ STATUS**

> **🟢 PHASE 7️⃣ COMPLETE & VERIFIED**







**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---




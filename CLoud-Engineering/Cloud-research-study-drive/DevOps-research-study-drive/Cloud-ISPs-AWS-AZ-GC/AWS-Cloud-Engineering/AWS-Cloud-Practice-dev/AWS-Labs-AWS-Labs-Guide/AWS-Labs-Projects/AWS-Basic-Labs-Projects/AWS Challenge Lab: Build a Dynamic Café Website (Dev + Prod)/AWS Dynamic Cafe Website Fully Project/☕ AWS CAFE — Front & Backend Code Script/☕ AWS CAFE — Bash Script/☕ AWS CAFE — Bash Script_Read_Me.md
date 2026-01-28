# AWS ☕ Charlie CAFE — Bash Script

## ☕ Charlie CAFE 🌐 SECTION 1️⃣ AWS RDS DATABASE BASH Script

### PHASE 1️⃣ — Basic RDS CONFIGURATIONS

### 1️⃣ Create index.php

```
sudo nano /var/www/html/index.php
```

####  2️⃣ Make executable

```
sudo chmod +x lamp-verify.sh
```

####  3️⃣ Run (best as root/sudo)

```
sudo ./lamp-verify.sh
```

### 4️⃣ Restart Apache (MANDATORY)

```
sudo systemctl restart httpd
```

## Method 1️⃣ - ☕ AWS Café — RDS MySQL Setup Bash Script
> **📄 File name : ☕ AWS Café — RDS MySQL Setup Bash Script.sh**

```
sudo nano setup_cafe_rds.sh
```

#### ⚠️ Important Configuration Values NOTE (Before Running This Cafe RDS Setup Script)

> **You MUST replace the placeholder values below with your own AWS RDS credentials before executing this script.**

#### 🔧 Required Changes

> **Update the following variables in the script according to your AWS environment:**

#### AWS Region:

```bash
AWS_REGION="us-east-1"
```
- **Current value:** us-east-1

- **Action:** Replace with your actual AWS region

**👉 Replace with your actual AWS Region**

**Examples: eu-west-1, ap-south-1, us-west-2, sa-east-1**

- **Why:** Secrets Manager and RDS are region-specific

#### Secrets Manager ARN:

```
SECRET_ARN="arn:aws:secretsmanager:us-east-1:910599465397:secret:CafeDevDBSM-NSiXdV"
```

- **Current value:** arn:aws:secretsmanager:us-east-1:910599465397:secret:CafeDevDBSM-NSiXdV

- **Action:** Replace with the real ARN of your target secret
- **How to find it:**
    - AWS Console → Secrets Manager → select your secret → copy the ARN

    - Must match the secret that contains host, username, password

- **Most critical value – wrong ARN = script cannot get credentials**

> **🟢 Method 1️⃣ COMPLETE & VERIFIED**  ✅ 

### PHASE 1️⃣ — COMPLETE & VERIFIED**  ✅ 
---
### PHASE 2️⃣ Cafe Order API + RDS Tests (API Gateway + rds-secret-test.sh)

### Method 1️⃣ Cafe Order API + RDS Tests 
> **📄 File name : ☕ AWS Café — API Gateway + rds-secret-test.sh**

#### 1️⃣ Create & edit file

```
sudo nano test-api-and-rds.sh
```

#### 2️⃣ Edit the Script and Add Your Details



#### 3️⃣ Make the script executable

```
sudo chmod +x test-api-and-rds.sh
```
This command gives permission to run the file as a program/script.

#### 4️⃣ Run the script (with root privileges)

```
sudo ./test-api-and-rds.sh
```

> **🟢 Method 1️⃣ COMPLETE & VERIFIED**  ✅ 
---
### Method 2️⃣ RDS Quick Test Script — One-command style

### Method 2 RDS Quick Test Script — One-command style

#### Save this as rds-quick-test.sh

```
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
```

#### How to use (same style as lamp-verify)

#### 1️⃣ Create & edit file

```
sudo nano rds-quick-test.sh
```

- **(or use vim, vi, or any other editor you prefer)**
- **→ Paste the entire script content into the file**
-  **→ Save and exit**
- **(Ctrl+O → Enter → Ctrl+X in nano)**


#### 2️⃣ Edit the Script and Add Your RDS Details

Before running the script, you **must** tell it how to connect to **your** RDS database.  
This is done by changing just **4 important lines** at the top of the file.

- Open the file again with:  
  `sudo nano rds-quick-test.sh`

- **Find the section near the top that looks like this:**

```
RDS_HOST="your-rds-endpoint.xxxxxxx.us-east-1.rds.amazonaws.com"      # ← CHANGE
  RDS_USER="your_username"                                             # ← CHANGE
  RDS_PASS="your_strong_password_here"                                 # ← CHANGE
  RDS_DB="your_database_name"                                          # ← CHANGE
```

- **After you finish changing these 4 lines → save the file (Ctrl+O → Enter → Ctrl+X in nano)**

#### 3️⃣ Make the script executable

```
sudo chmod +x rds-quick-test.sh
```
This command gives permission to run the file as a program/script.

#### 4️⃣ Run the script (with root privileges)

```
sudo ./rds-quick-test.sh
```


> **🟢 PHASE 7️⃣ COMPLETE & VERIFIED**


> **🟢 Method 1️⃣ COMPLETE & VERIFIED**  ✅ 
---
### Method 2️⃣ RDS Quick Test Script — One-command style
> **📄 File name : ☕ AWS Café — API Gateway + rds-secret-test.sh**

#### 📢 Note: RDS Quick TestRDS Test Script using Secrets Manager

#### 1️⃣ IAM role

- The EC2 instance must have an IAM role attached with permission to call secretsmanager:GetSecretValue for your specific secret

- Recommended minimal policy example:

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "secretsmanager:GetSecretValue",
      "Resource": "arn:aws:secretsmanager:your-region:your-account:secret:your-secret-name-*"
    }
  ]
}
```

#### 2️⃣ Install JSON processor

Install jq (JSON processor) — very common & small tool:

#### 1️⃣ Amazon Linux 2023

```
sudo dnf install -y jq
```

#### 2️⃣ older Amazon Linux 2

```
sudo yum install -y jq 
```

#### 3️⃣ RDS Test Script using Secrets Manager

#### 📢 Quick Usage

#### 1️⃣ Create & edit

```
sudo nano rds-secret-test.sh
```

#### 2️⃣ Paste script, change only SECRET_NAME and RDS_DB

##### Save as rds-secret-test.sh

#### 3️⃣ Make the script executable

```
sudo chmod +x rds-secret-test.sh
```
This command gives permission to run the file as a program/script.

#### 4️⃣ Run the script (with root privileges)

```
sudo ./rds-secret-test.sh
```

#### Common Secret JSON structures (choose correct jq paths)

| Secret format (what you see in console)                  | jq path for host | jq path for username | jq path for password |
|----------------------------------------------------------|------------------|----------------------|----------------------|
| `{"host":"...","username":"...","password":"..."}`       | `.host`          | `.username`          | `.password`          |
| `{"endpoint":"...","user":"...","pwd":"..."}`            | `.endpoint`      | `.user`              | `.pwd`               |
| RDS auto-generated rotation format                       | `.host`          | `.username`          | `.password`          |

- Adjust the three jq -r lines if your secret has different key names.

> **🟢 Method 2️⃣ COMPLETE & VERIFIED**  ✅ 

### PHASE 2️⃣ — COMPLETE & VERIFIED**  ✅ 
---
### PHASE 3️⃣ — PyMySQL Lambda Layer

### Method 1️⃣ - PyMySQL Lambda Layer

#### 2️⃣ How to create, give permission, and run the script on EC2

#### 1️⃣ Create the file

```
nano pymysql-layer.sh
```

→ paste the script above

→ press Ctrl + O → Enter (save)

→ Ctrl + X (exit)


#### 2️⃣ Give execute permission

```
sudo chmod +x pymysql-layer.sh
```

#### 3️⃣ Run it

```
sudo ./pymysql-layer.sh
```

> **After it finishes → you will see pymysql-layer.zip in the current folder (or in ./lambda-layer/ if you cd'ed manually).**
> **You can now upload it to S3 using AWS console (or aws s3 cp if you have AWS CLI configured on the EC2).**

**✔️ Good luck with your Lambda + pymysql setup!**

> **🟢 Method 1️⃣ COMPLETE & VERIFIED**  ✅ 

### PHASE 3️⃣ — COMPLETE & VERIFIED**  ✅ 
---

## 🛠️ Bash Script: Save RDS Credentials to Secrets Manager
> **📄 save-rds-secret.sh**

```
sudo nano save-rds-secret.sh
```

```
#!/bin/bash

# ================================
# CONFIGURATION
# ================================
AWS_REGION="us-east-1"
SECRET_NAME="CafeDevDBSM"

DB_HOST="your-rds-endpoint.amazonaws.com"
DB_PORT="3306"
DB_NAME="cafedb"
DB_USERNAME="admin"
DB_PASSWORD="StrongPasswordHere"

# ================================
# CREATE SECRET JSON
# ================================
SECRET_STRING=$(cat <<EOF
{
  "host": "$DB_HOST",
  "port": "$DB_PORT",
  "dbname": "$DB_NAME",
  "username": "$DB_USERNAME",
  "password": "$DB_PASSWORD"
}
EOF
)

# ================================
# CREATE OR UPDATE SECRET
# ================================
aws secretsmanager create-secret \
  --region "$AWS_REGION" \
  --name "$SECRET_NAME" \
  --secret-string "$SECRET_STRING" \
  2>/dev/null || \
aws secretsmanager put-secret-value \
  --region "$AWS_REGION" \
  --secret-id "$SECRET_NAME" \
  --secret-string "$SECRET_STRING"

# ================================
# CONFIRMATION
# ================================
echo "✅ RDS credentials securely stored in AWS Secrets Manager"
echo "🔐 Secret Name: $SECRET_NAME"
```

#### ▶️ How to Run

```
sudo chmod +x save-rds-secret.sh
```

```
sudo ./save-rds-secret.sh
```



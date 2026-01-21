# ☕ AWS CAFE — BASH Scirpt



---
### 2️⃣ — Basic RDS CONFIGURATIONS

## Method 1 - ☕ AWS Café — RDS MySQL Setup Bash Script

### 📄 File name (recommended)

```
sudo nano setup_cafe_rds.sh
```

### ✅ FULL BASH SCRIPT (100% COMPLETE)

```
#!/bin/bash
set -euo pipefail

echo "☕ Starting Cafe RDS First-Time Setup..."

# ================= CONFIG =================
AWS_REGION="us-east-1"
SECRET_ARN="arn:aws:secretsmanager:us-east-1:910599465397:secret:CafeDevDBSM-NSiXdV"   # ← CHANGE TO YOUR REAL SECRET ARN

DB_NAME="cafe_db"   # Hard-coded for your new cafe setup

# ================= INSTALL REQUIRED PACKAGES =================
echo "📦 Installing MariaDB client & jq if missing..."
sudo dnf install -y mariadb105 jq

# AWS CLI v2 is pre-installed on Amazon Linux 2023 – verify it
if ! command -v aws >/dev/null 2>&1; then
    echo "⚠️ AWS CLI not found (unusual on AL2023) – installing official v2..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install --update
    rm -rf aws awscliv2.zip
fi

aws --version || { echo "❌ AWS CLI failed to run – check installation"; exit 1; }
mysql --version
echo ""

# ================= FETCH SECRET FROM SECRETS MANAGER =================
echo "🔐 Fetching RDS credentials from Secrets Manager..."
SECRET_JSON=$(aws secretsmanager get-secret-value \
    --secret-id "$SECRET_ARN" \
    --region "$AWS_REGION" \
    --query SecretString \
    --output text)

DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host // .endpoint // empty')
DB_USER=$(echo "$SECRET_JSON" | jq -r '.username // empty')
DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password // empty')
DB_PORT=$(echo "$SECRET_JSON" | jq -r '.port // "3306"')

if [[ -z "$DB_HOST" || -z "$DB_USER" || -z "$DB_PASS" ]]; then
    echo "❌ ERROR: Missing required fields in secret (host/username/password)"
    exit 1
fi

echo "✅ Secret loaded"
echo "🔗 RDS Endpoint: $DB_HOST"
echo "   Port:       $DB_PORT"
echo "👤 DB User:     $DB_USER"
echo "🗄 Database:     $DB_NAME (creating if not exists)"
echo ""

# ================= CREATE TEMP CREDENTIALS FILE =================
CREDENTIALS_FILE=$(mktemp /tmp/rds-cafe-cred.XXXXXX)
chmod 600 "$CREDENTIALS_FILE"

cat > "$CREDENTIALS_FILE" << EOF
[client]
host=$DB_HOST
port=$DB_PORT
user=$DB_USER
password=$DB_PASS
connect-timeout=10
EOF

trap 'rm -f "$CREDENTIALS_FILE"' EXIT

# ================= TEST CONNECTION =================
echo "🔌 Testing RDS connection..."
if ! mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "SELECT 1" >/dev/null 2>&1; then
    echo "❌ Connection failed. Check:"
    echo "   • Security Group allows 3306 from this EC2"
    echo "   • RDS is in same VPC/subnet or properly peered"
    echo "   • Credentials & endpoint in secret are correct"
    exit 1
fi
echo "✅ Connection OK"
echo ""

# ================= CREATE DATABASE =================
echo "🗄 Creating database '$DB_NAME'..."
mysql --defaults-extra-file="$CREDENTIALS_FILE" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
echo ""

# ================= CREATE ORDERS TABLE =================
echo "📋 Creating orders table..."
mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" <<EOF
CREATE TABLE IF NOT EXISTS orders (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    table_number  INT NOT NULL,
    customer_name VARCHAR(100),
    item          VARCHAR(100),
    quantity      INT NOT NULL,
    created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_table_number (table_number),
    INDEX idx_created_at   (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
EOF
echo ""

# ================= VERIFY =================
echo "🔍 Verifying setup..."
mysql --defaults-extra-file="$CREDENTIALS_FILE" "$DB_NAME" -e "
    SHOW TABLES;
    SELECT 'Cafe database ready' AS message;
"
echo ""

echo "✅ Cafe RDS setup completed successfully ☕"
echo "Next steps:"
echo "  - Use database: $DB_NAME"
echo "  - Endpoint:    $DB_HOST"
echo "  - User:        $DB_USER"
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

---
### Method 2 RDS Quick Test Script — One-command style

####  RDS Quick TestRDS Test Script using Secrets Manager

#### IAM role

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

#### Install JSON processor

Install jq (JSON processor) — very common & small tool:

#### Amazon Linux 2023

```
sudo dnf install -y jq
```

#### older Amazon Linux 2

```
sudo yum install -y jq 
```

#### RDS Test Script using Secrets Manager

#### Quick Usage

#### Create & edit

```
sudo nano rds-secret-test.sh
```

#### Paste script, change only SECRET_NAME and RDS_DB

##### Save as rds-secret-test.sh

```
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
SECRET_NAME="/cafe/prod/database/credentials"          # ← Your secret name or ARN
# Examples: "prod-db-secret", "my-rds-credentials", or full ARN
RDS_DB="cafe_orders"                                   # ← Database name to connect to (optional)

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
```

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



---

### Method 1️⃣ - PyMySQL Lambda Layer

```
#!/bin/bash

# Script to build pymysql Lambda Layer (Amazon Linux 2023 EC2)

echo "Starting pymysql Lambda Layer creation..."

# Install python + pip
sudo dnf install -y python3 python3-pip

# Create directory and go inside
mkdir -p lambda-layer
cd lambda-layer || { echo "Error: Cannot enter lambda-layer folder"; exit 1; }

# Install pymysql to the correct folder structure
pip3 install pymysql -t python/

# Create zip
zip -r pymysql-layer.zip python

# Show result
echo ""
echo "Finished!"
echo "Layer zip file created: $(pwd)/pymysql-layer.zip"
echo "File size:"
ls -lh pymysql-layer.zip
echo ""
echo "Next: Upload this zip to your S3 bucket,"
echo "then create a Lambda Layer from it in AWS console,"
echo "and attach the layer to your Lambda function."
echo ""
```

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

---


# ☕ AWS Café Lab — Complete Zero-to-Production Master Guide

**Dev → Serverless → Secure → Scalable → Cost-Controlled**

**Author & Architecture Designer:** Charlie

**Level:** Beginner → Advanced (Production-grade)

**Approach:** AWS Console First • No Skipped Steps • Exam + Real-World Safe

---

## ✅ Prerequisites

* AWS Account (EC2, VPC, IAM, Secrets Manager, Lambda , RDS, CloudFront, S3 )
* Basic Linux commands
* PHP + MySQL knowledge
* SSH client or Cloud9

---
# 📢 SECTION 1️⃣ CAFE BASIC CONFIGURATIONS

## PHASE 1️⃣ — NETWORK & COMPUTE (FOUNDATION)

### 1️⃣ Create Development VPC (us‑east‑1)

* VPC Name: `CafeDevVPC`
* CIDR: `10.0.0.0/16`

### 1️⃣ Create Public Subnet

* Name: `CafeDevPublicSubnet`
* CIDR: `10.0.1.0/24`
* Auto‑assign public IP: **Enabled**

### 2️⃣ Create TWO private subnets:

- CafeDevPrivateSubnet1 → 10.0.2.0/24 (AZ-a)
- CafeDevPrivateSubnet2 → 10.0.3.0/24 (AZ-b)


### 3️⃣ Internet Access

* Create Internet Gateway → Attach to VPC
* Route table → Add route `0.0.0.0/0 → IGW`

### 4️⃣ Security Group and NACL


### 5️⃣ EC2 Instance (Amazon Linux 2023)

* AMI: Amazon Linux 2023
* Type: `t2.micro`
* VPC/Subnet: Dev VPC + Public subnet
* Security Group:

  * SSH (22) → Your IP
  * HTTP (80) → 0.0.0.0/0
* Name tag: `CafeDevWebServer`

#### ✅ EC2 LAMP Server USER DATA
> **📍 File Location: ☕ AWS CAFE —FrontEnd Web Development.md**

```
#!/bin/bash
# --------------------------------------------
# EC2 User Data Script
# Amazon Linux 2023
# Installs LAMP Stack + MySQL Client
# --------------------------------------------

# 1️⃣ Update OS (MANDATORY FIRST)
dnf update -y

# 2️⃣ Install Apache (httpd)
dnf install -y httpd
systemctl enable httpd
systemctl start httpd

# 3️⃣ Install PHP + MySQL Support
dnf install -y \
php \
php-mysqlnd \
php-cli \
php-common \
php-mbstring \
php-xml

# 4️⃣ Fix Web Directory Permissions (MANDATORY)
chown -R apache:apache /var/www
chmod -R 755 /var/www

# 5️⃣ Install MySQL Client (MariaDB)
dnf install -y mariadb105

# 6️⃣ Create a PHP Info Page (Optional Verification)
echo "<?php phpinfo(); ?>" > /var/www/html/info.php

# 7️⃣ Restart Apache to Apply PHP
systemctl restart httpd

# 8️⃣ Install AWS CLI
sudo dnf install -y awscli


# --------------------------------------------
# END OF USER DATA
# --------------------------------------------
```



**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---
## PHASE 2️⃣ — Development and Delopment LAMP Server 

[AWSCafeOrderProcessor](./AWS%20Cafe%20Project%20Development%20%26%20Depolyment%20Docs/☕%20AWS%20CAFE%20—FrontEnd%20Web%20Development.md)


**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**
---

## PHASE 3️⃣ — RDS CONFIGURATIONS

### 1️⃣ — Basic RDS CONFIGURATIONS

#### 1️⃣ Create DB Subnet Group
AWS Console → RDS → Subnet groups → Create

- Name: CafeRDSSubnetGroup

- VPC: CafeDevVPC

- Subnets: **PRIVATE subnets (2 AZs)**

- **✔️ Create**

#### 2️⃣ Create Security Group for RDS
VPC → Security Groups → Create

- Name: CafeRDS-SG

- Inbound:
  - MySQL/Aurora (3306) → Source: Lambda-SG
  - MySQL/Aurora (3306) → Source: EC2-Web-SG
- Outbound: All

- **✔️ Create**

#### 3️⃣ Create RDS Instance

RDS → Databases → Create database

- Engine: MySQL (or MariaDB)

- Template: Free tier

- DB identifier: cafedb

- Username: cafe_user

- Password: StrongPassword123

- VPC: CafeDevVPC

- Subnet group: CafeRDSSubnetGroup

- Public access: ❌ No

- Security group: CafeRDS-SG

- Backup: Enabled

- **✔️ Create database ⏳**

#### 4️⃣ Create Schema in RDS

- **✔️ Connect from EC2:**

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


#### Database Name:

```
DB_NAME="cafe_db"
```

- **Current value:** cafe_db

- **Action:** Usually keep as-is for this project

- **When to change:**

    - Different environments: cafe_dev, cafe_staging, cafe_prod

    - Company naming convention: app_cafe_2026, cafe_v1

- **Note:** Script uses CREATE DATABASE IF NOT EXISTS → safe to re-run

### 🔐 HOW TO USE THIS SCRIPT

#### 1️⃣ Make it executable

```
sudo chmod +x setup_cafe_rds.sh
```

#### 2️⃣ Run the script

```
sudo ./setup_cafe_rds.sh
```

**You’ll be prompted once for the admin RDS password (master user).**

### ✅ FINAL SUCCESS CHECKLIST

#### If everything is correct, you will see:

✅ MySQL client installed

✅ cafe_db created

✅ cafe_user created

✅ orders table exists

✅ Test rows displayed via SELECT * FROM orders;

---

## Method 2 - ☕ AWS Café — RDS MySQL Setup 1-To-1

### 1️⃣ Install & Login MySQL Client

```
sudo dnf install -y mariadb105
```

#### Verify mysql

```
mysql --version
```

#### Login to MariaDB:

```
mysql -h <rds-endpoint> -u cafe_user -p
```
---

### 2️⃣ Create Café Database

```sql
CREATE DATABASE cafe_db;
```

```
CREATE USER 'cafe_user'@'%' IDENTIFIED BY 'StrongPassword123';
```

```
GRANT ALL PRIVILEGES ON cafe_db.* TO 'cafe_user'@'%';
```

```
FLUSH PRIVILEGES;
```

### 3️⃣ Use the correct database

```
USE cafe_db;
```

### 4️⃣ Orders Table

```sql
CREATE TABLE orders (
 id INT AUTO_INCREMENT PRIMARY KEY,
 customer_name VARCHAR(100),
 item VARCHAR(50),
 quantity INT,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 📢 Recommended Final CREATE TABLE with table_number

```
CREATE TABLE orders (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    table_number    INT NOT NULL,                    -- ← Added: table number (1, 2, 3, ...)
    customer_name   VARCHAR(100),
    item            VARCHAR(50),
    quantity        INT NOT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_table_number (table_number),           -- optional: faster queries by table
    INDEX idx_created_at (created_at)                -- optional: good for time-based reports
);
```

#### ✅ FINAL orders TABLE with table_number (WITH CLEAR COMMENTS)

```
CREATE TABLE orders (

    -- Primary unique identifier for each order
    id INT AUTO_INCREMENT PRIMARY KEY,

    -- Cafe table number where customer is seated (1, 2, 3, ...)
    table_number INT NOT NULL,

    -- Optional customer name (can be NULL for walk-in customers)
    customer_name VARCHAR(100),

    -- Ordered item name (must match CafeMenu.item_name)
    item VARCHAR(50),

    -- Quantity of the ordered item
    quantity INT NOT NULL,

    -- Date & time when order was created (auto-filled by MySQL)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Index to speed up queries by table number (useful for waiter dashboards)
    INDEX idx_table_number (table_number),

    -- Index to speed up date-based queries (daily, weekly, monthly reports)
    INDEX idx_created_at (created_at)

);
```

#### 📢 Most common real-world version

#### Many cafes/restaurants also like to track status and total amount, so here’s a more complete modern version you might consider:


```
CREATE TABLE orders (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    table_number    INT NOT NULL,
    customer_name   VARCHAR(100) DEFAULT NULL,       -- optional, sometimes anonymous orders
    item            VARCHAR(100) NOT NULL,
    quantity        INT NOT NULL DEFAULT 1,
    unit_price      DECIMAL(10,2) NOT NULL,          -- important for billing
    total_amount    DECIMAL(10,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    status          ENUM('pending', 'preparing', 'served', 'cancelled') DEFAULT 'pending',
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_table_number (table_number),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
);
```

#### ☕ orders TABLE — FULLY COMMENTED (PRODUCTION-READY)

```
CREATE TABLE orders (

    -- Unique ID for each order (auto increases)
    id INT AUTO_INCREMENT PRIMARY KEY,

    -- Cafe table number (e.g., table 1, table 5)
    table_number INT NOT NULL,

    -- Customer name (optional: walk-in or anonymous allowed)
    customer_name VARCHAR(100) DEFAULT NULL,

    -- Item name ordered (must match CafeMenu.item_name)
    item VARCHAR(100) NOT NULL,

    -- Quantity of the item ordered
    quantity INT NOT NULL DEFAULT 1,

    -- Selling price per single item (charged to customer)
    unit_price DECIMAL(10,2) NOT NULL,

    -- Auto-calculated total amount = quantity × unit_price
    -- STORED means value is physically saved (faster reports)
    total_amount DECIMAL(10,2)
        GENERATED ALWAYS AS (quantity * unit_price) STORED,

    -- Order status used by kitchen + order-status dashboard
    status ENUM('pending', 'preparing', 'served', 'cancelled')
        DEFAULT 'pending',

    -- Time when order was created
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Time when order was last updated (status change, etc.)
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    -- Index for quickly finding orders by table number
    INDEX idx_table_number (table_number),

    -- Index for fast filtering by order status
    INDEX idx_status (status),

    -- Index for analytics & reports by date/time
    INDEX idx_created_at (created_at)

);
```

#### 📢 Remove (Delete) the Table

#### Option A: Normal delete (most common)

```
DROP TABLE orders;
```

#### Option B: Delete only if it exists (safer - no error if table doesn't exist)

```
DROP TABLE IF EXISTS orders;
```

#### Option C: Very aggressive - delete even if there are foreign keys pointing to it (usually not recommended unless you really know what you're doing)

```
SET FOREIGN_KEY_CHECKS = 0;
```

```
DROP TABLE orders;
```

```
SET FOREIGN_KEY_CHECKS = 1;
```

####  Also fine - mixed style

```
SET FOREIGN_KEY_CHECKS = 0;
```

```
DROP TABLE IF EXISTS orders;
```

```
SET FOREIGN_KEY_CHECKS = 1;
```

#### 📢 Modify Existing Table (ALTER TABLE)

#### A. Add new column

```
ALTER TABLE orders
    ADD COLUMN table_number INT NOT NULL AFTER id;
```

#### B. Add column with default value

```
ALTER TABLE orders
    ADD COLUMN status ENUM('pending','preparing','served','cancelled') 
    DEFAULT 'pending' AFTER quantity;
```

#### C. Change column type (example: make customer_name longer)

```
ALTER TABLE orders
    MODIFY COLUMN customer_name VARCHAR(150) NOT NULL;
```

#### D. Rename column

```
ALTER TABLE orders
    CHANGE COLUMN item product_name VARCHAR(100);
```

#### E. Drop (remove) column you no longer need

```
ALTER TABLE orders
    DROP COLUMN customer_name;
```

#### F. Add index (very important for performance)

```
ALTER TABLE orders
    ADD INDEX idx_table_number (table_number);
```

#### G. Add auto-increment if you forgot it (very rare case)

```
ALTER TABLE orders
    MODIFY id INT AUTO_INCREMENT PRIMARY KEY;
```

#### H. Change default value for existing column

```
ALTER TABLE orders
    ALTER COLUMN quantity SET DEFAULT 1;
```

### 5️⃣ Verify table exists

```
SHOW TABLES;
```

##### You should see:

```
orders
```

### 6️⃣ Test insert manually (CLI)

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

#### Most common quick test inserts (good for development):

```
-- Quick test inserts - very useful for checking
INSERT INTO orders (table_number, customer_name, item, quantity) VALUES
    (1, 'Test User', 'Black Coffee', 1),
    (2, NULL, 'Green Tea', 2),
    (4, 'CLI-Test', 'Coffee', 1);
```

#### 📢 Complete/Production Version (table NUMBER – with price, status, total_amount)

```
-- For your second (more complete) table
INSERT INTO orders (
    table_number, 
    customer_name, 
    item, 
    quantity, 
    unit_price, 
    status
) VALUES 
    (1, 'Ali Khan', 'Espresso', 2, 450.00, 'served'),
    (1, 'Sara Ahmed', 'Cappuccino', 1, 520.00, 'preparing'),
    (2, 'CLI-Test', 'Coffee', 1, 300.00, 'pending'),
    (3, NULL, 'Latte + Croissant', 1, 780.00, 'pending'),
    (5, 'Ahmed Raza', 'Caramel Macchiato', 2, 650.00, 'served'),
    (4, 'Fatima Noor', 'Iced Americano', 3, 400.00, 'cancelled');
```

#### Quick development/test version (minimal required fields):

```
-- Minimal insert for testing (uses defaults for the rest)
INSERT INTO orders (table_number, item, quantity, unit_price) VALUES
    (1, 'Black Coffee', 1, 300.00),
    (2, 'Green Tea', 2, 250.00),
    (4, 'CLI-Test Coffee', 1, 300.00);
```

### 7️⃣ Verify:

```
SELECT * FROM orders;
```

###### ✅ If you see the row → DB is READY

#### Exit MySQL:

```
EXIT;
```

### 📢 Quick Reference Table - What do you want to do?

| Action                              | Command Example                                   | Risk   |
|-------------------------------------|---------------------------------------------------|--------|
| Delete table (force)                | `DROP TABLE orders;`                              | High   |
| Delete table (safe)                 | `DROP TABLE IF EXISTS orders;`                    | Low    |
| Add new column                      | `ALTER TABLE orders ADD COLUMN table_number INT;` | Low    |
| Change column type/size             | `ALTER TABLE orders MODIFY COLUMN name VARCHAR(200);` | Medium |
| Rename column                       | `ALTER TABLE orders CHANGE COLUMN old_name new_name VARCHAR(100);` | Low    |
| Delete column                       | `ALTER TABLE orders DROP COLUMN customer_name;`   | Medium |
| Add index                           | `ALTER TABLE orders ADD INDEX idx_table (table_number);` | Low    |
| Set/change default value            | `ALTER TABLE orders ALTER COLUMN status SET DEFAULT 'pending';` | Low    |


---




**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---

## PHASE 3️⃣ — S3 Bucket

### 1️⃣ Create S3 Bucket

- AWS Console → Search S3

- Click Create bucket

#### Bucket Configuration :


| Setting             | Value                            |
| ------------------- | -------------------------------- |
| Bucket name         | `charlie-cafe-s3-bucket` |
| Region              | `us-east-1` (same as Lambda)     |
| Object ownership    | ACLs disabled                    |
| Block public access | ✅ Enabled (KEEP ON)             |


Click **Create bucket**

#### ✅ Bucket created

#### 📣 Disable “Block Public Access”

✔️ Uncheck all

✔️ Acknowledge

### 2️⃣ Upload Images to S3 

#### 1️⃣ Upload Images

Example:

```
hero.jpg
espresso.jpg
latte.jpg
```

#### 2️⃣ Make Images Public

- Select image

- Actions → Make public

### 3️⃣ Link S3 Images to index.php

#### Copy S3 Object URL:

```
https://charlie-cafe-assets.s3.amazonaws.com/hero.jpg
```

#### Replace in index.php:

```
<section class="hero" style="background-image:url('https://charlie-cafe-assets.s3.amazonaws.com/hero.jpg')">
```

✅ No backend impact

✅ No API involved

### 4️⃣ 🧪 VERIFICATION 2 (MANDATORY)

#### 1️⃣ Test Landing Page

```
http://<EC2_PUBLIC_IP>/
```

#### ☑️ Confirm:

✔️ Logo visible

✔️ “Charlie Cafe” title visible

✔️ Hero image loads from S3

✔️ “Order Now” button works



**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---

# 📢 SECTION 2 — AWSCafeOrderProcessor


[AWSCafeOrderProcessor](./AWS%20Cafe%20Project%20Development%20%26%20Depolyment%20Docs/AWSCafeOrderProcessor.md)

---

# 📢 SECTION 3 — AWS Cafe PRODUCTION

## PHASE 1 — PRODUCTION (us‑west‑2)

## Create AMI

* Name: `CafeDevWebAMI`

## Launch Prod EC2

* Region: us‑west‑2
* From AMI
* New VPC/Subnet

---

🚀 *Next Sections*: RDS, DynamoDB, SQS, WAF, CI/CD

---

# 📢 SECTION 4 — AWS Cafe Menu + Cache Layer

## PHASE 1 — AMAZON DYNAMODB (Menu + Cache Layer)

## 🎯 Purpose of This Phase (IMPORTANT)

### In your architecture:

- DynamoDB is NOT replacing RDS

- DynamoDB is used for:

    - Menu data (Coffee, Latte, Tea)

    - Fast reads

    - Cache-like behavior

- Lambda reads menu price from DynamoDB

- RDS is still used for orders & transactions

So the flow is:

```
CloudFront
   ↓
API Gateway
   ↓
Lambda (Menu API)
   ↓
DynamoDB (CafeMenu)
```

## 1️⃣ Create DynamoDB Table

- **DynamoDB → Create table**

### 1️⃣ Basic Table Settings

| Field         | Value      |
| ------------- | ---------- |
| Table name    | `CafeMenu` |
| Partition key | `item`     |
| Type          | `String`   |



##### ⚠️ Do NOT add Sort key

##### ⚠️ Partition key name must be exactly item

### 2️⃣ Table Settings (Capacity)

Scroll down to Table settings

- Capacity mode:

    ✅ On-demand

#### Why?

- No capacity planning

- Free-tier friendly

- Ideal for learning & small apps

### 3️⃣ Additional Settings (Keep Default)

Leave ALL of these as default:

- Encryption at rest: AWS owned key

- Table class: Standard

- Deletion protection: Disabled

- Tags: Optional (skip)

### 4️⃣ Create Table

- Click Create table

#### Wait until:

```
Status = ACTIVE
```

##### ⏳ This may take 20–60 seconds

## 2️⃣ Insert Menu Items

- **DynamoDB → CafeMenu → Explore table → Create item**

### 1️⃣ Method 1 JSON EDitor

#### 1️⃣ Create First Item (Coffee)

You will see a JSON editor.

Replace everything with:

```
{
  "item": {
    "S": "Coffee"
  },
  "price": {
    "N": "3"
  }
}
```

- ✅ Click Create item

#### 2️⃣ Create Second Item (Latte)

Click Create item again:

```
{
  "item": {
    "S": "Latte"
  },
  "price": {
    "N": "5"
  }
}
```

- ✅ Click Create item

#### 3️⃣ Create Third Item (Tea)

Click Create item again:

```
{
  "item": {
    "S": "Tea"
  },
  "price": {
    "N": "2"
  }
}
```

- ✅ Click Create item

---

#### 4️⃣ Create Third Item (Cappuccino)

```
{
  "item": {
    "S": "Cappuccino"
  },
  "price": {
    "N": "8"
  }
}
```

- ✅ Click Create item

---

#### 5️⃣ Create Third Item (Fresh Juice)

```
{
  "item": {
    "S": "Fresh Juice"
  },
  "price": {
    "N": "6"
  }
}
```

- ✅ Click Create item

---

### 2️⃣ Method 2 Item editor screen


#### 1️⃣ Create First Item (Coffee)

1. Partition key:

- item → Coffee

2. Click Add new attribute

- Type: Number

- Attribute name: price

- Value: 3

- ✅ Click Create item

#### 2️⃣ Create Second Item (Latte)

1. Partition key:

- item → Latte

2. Click Add new attribute

- Type: Number

- Attribute name: price

- Value: 5

- ✅ Click Create item

#### 3️⃣ Create Third Item (Tea)

1. Partition key:

- item → Latte

2. Click Add new attribute

- Type: Number

- Attribute name: price

- Value: 2

- ✅ Click Create item

#### 4️⃣ Create First Item (Cappuccino)

1. Partition key:

- item → Cappuccino

2. Click Add new attribute

- Type: Number

- Attribute name: price

- Value: 8

- ✅ Click Create item

#### 5️⃣ Create First Item (Fresh Juice)

1. Partition key:

- item → Fresh Juice

2. Click Add new attribute

- Type: Number

- Attribute name: price

- Value: 6

- ✅ Click Create item

---
### 3️⃣ Verify Items

You should now see 5 items in the table. You should now see:

| item   | price |
| ------ | ----- |
| Coffee | 3     |
| Latte  | 5     |
| Cappuccino    | 8     |
| Fresh Juice    | 6     |

✅ DynamoDB table is ready


## 3️⃣ Create IAM Policy for DynamoDB Access

Now Lambda needs permission to read from DynamoDB.

- **Go to IAM → Policies → Create policy** 

- **Policy name:** 

```        
CafeMenuDynamoDBReadPolicy
```

- **Description:**

```
Allow Lambda to read menu items from DynamoDB
```

### 1️⃣ Create Policy (JSON Mode)

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:Scan",
        "dynamodb:PutItem"
      ],
      "Resource": "arn:aws:dynamodb:YOUR-REGION:YOUR-ACCOUNT-ID:table/CafeMenu"
    }
  ]
}
```

#### 📌 Example:

```
arn:aws:dynamodb:us-east-1:123456789012:table/CafeMenu
```

- Click Create policy


### 2️⃣ Attach Policy to Lambda Role

You likely have two Lambdas:

    API Lambda

    Worker Lambda

👉 Attach this policy to API Lambda role

- **Go to IAM → Roles → Search for your Lambda role**

Example:

```
CafeAPILambdaRole
```

- Attach Policy to API Lambda role **CafeLambdaExecutionRole**

```
CafeMenuDynamoDBReadPolicy
```
✅ IAM is now correctly configured

✅ Lambda now has DynamoDB access


## 4️⃣ CREATE NEW LAMBDA (MENU API)

- Open AWS Lambda

- **Function details:**

| Field          | Value                     |
| -------------- | ------------------------- |
| Function name  | `CafeMenuLambda`          |
| Runtime        | Python 3.12               |
| Architecture   | x86_64                    |
| Execution role | Use existing role         |
| Role           | `CafeLambdaExecutionRole` |

**✔️ Click Create function**

## 5️⃣ Lambda Code: Read Menu from DynamoDB (Python)

Now we implement the logic.

Use boto3 to fetch menu/prices before processing orders.

```
import boto3
import json
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('CafeMenu')

def decimal_to_native(obj):
    if isinstance(obj, Decimal):
        # Convert Decimal to int if whole number, else float
        if obj % 1 == 0:
            return int(obj)
        return float(obj)
    raise TypeError

def lambda_handler(event, context):
    response = table.scan()
    items = response.get('Items', [])

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(items, default=decimal_to_native)
    }
```

**✔️ Click Deploy**

## 6️⃣ TEST LAMBDA (MANDATORY)

- Click Test

- Test name: MenuTest

- Event JSON:

```
{}
```

**✔️ Click Test**

#### ✅ Expected Output:

```
{
  "statusCode": 200,
  "headers": {
    "Content-Type": "application/json"
  },
  "body": "[{\"price\": 5, \"item\": \"Latte\"}, {\"price\": 8, \"item\": \"Cappuccino\"}, {\"price\": 6, \"item\": \"Fresh Juice\"}, {\"price\": 2, \"item\": \"Tea\"}, {\"price\": 3, \"item\": \"Coffee\"}]"
}
```

---

# 📢 SECTION 5 — AWS CAFE SQS (Async Order Processing)



[AWS CAFE SQS (Async Order Processing)](./AWS%20Cafe%20Project%20Development%20%26%20Depolyment%20Docs/AWS%20CAFE%20SQS%20(Async%20Order%20Processing).md)



---
# 📢 SECTION 6 — ORDER STATUS DASHBOARD

[AWS CAFE ORDER STATUS DASHBOARD](./AWS%20Cafe%20Project%20Development%20%26%20Depolyment%20Docs/AWSCafeORDERSTATUSDASHBOARD.md)

---

# 📢 SECTION 7 — AWS  Charlie Cafe — Secure Admin Order Dashboard

[AWS  Charlie Cafe — Secure Admin Order Dashboard](./AWS%20Cafe%20Project%20Development%20%26%20Depolyment%20Docs/AWS%20%20Charlie%20Cafe%20—%20Secure%20Admin%20Order%20Dashboard.md)

---


# 📢 SECTION 8 — CAFE LAB – SALES ANALYTICS & REPORTING SYSTEM


[CAFE LAB – SALES ANALYTICS & REPORTING SYSTEM](./AWS%20Cafe%20Project%20Development%20%26%20Depolyment%20Docs/☕%20AWS%20CAFE%20—%20SALES%20ANALYTICS%20%26%20REPORTING%20SYSTEM.md)


---

# 📢 SECTION 9 — AWS CAFE Customer Order Tracking, Billing & Receipt (Frontend-Only, Zero-Risk)

[AWS CAFE Customer Order Tracking, Billing & Receipt (Frontend-Only, Zero-Risk)](./AWS%20Cafe%20Project%20Development%20%26%20Depolyment%20Docs/☕%20AWS%20CAFE%20—%20CUSTOMER%20ORDER%20TRACKING%20%26%20BILLING.md)

---
# SECTION 10 — CloudFront with EC2 (Apache + ALB) AND API Gateway (Dual Architecture)

[CloudFront with EC2 (Apache + ALB) AND API Gateway (Dual Architecture)](./AWS%20Cafe%20Project%20Development%20%26%20Depolyment%20Docs/AWS%20CAFE-cloudfront-ec2-api-dual-arch.md)

---

# 📢 SECTION 11 — AWS CAFE SECURITY


[AWS CAFE SECURITY](./AWS%20Cafe%20Project%20Development%20%26%20Depolyment%20Docs/AWSCAFESECURITY.md)

---

# 📢 SECTION 12 — AWS CAFE CI/CD (CodePipeline)

[AWS CAFE CI/CD (CodePipeline)](./AWS%20Cafe%20Project%20Development%20%26%20Depolyment%20Docs/AWSCafeCICD(CodePipeline).md)


---
# 📢 SECTION 13 — BILLING ALERTS & BUDGETS

## 1️⃣ Enable Billing Alerts

AWS Console → Billing → Billing preferences
- Receive billing alerts: ✅ Enable

Save

---

## 2️⃣ Create Budget

Billing → Budgets → Create budget

### Budget details
- Type: Cost budget
- Amount: $5
- Period: Monthly

### Alerts
- Alert at 80%
- Alert at 100%
- Email: your email

Create budget

---

## 3️⃣ CloudWatch Billing Alarm

CloudWatch → Alarms → Create alarm
- Metric: Billing → EstimatedCharges
- Threshold: $5
- SNS Topic: Create new → Email

Create alarm

---

# 📢 SECTION 14 — TESTING

## API Test
curl -X POST <api-url> -d '{"customer_name":"CI","item":"Coffee","quantity":1}'

## Verify
- SQS: messages consumed
- Lambda logs clean
- RDS rows inserted
- DynamoDB updated

## Cognito Test
- Sign up user
- Login → copy JWT token

## API Test with Token

```
curl -X POST <cloudfront-url>/dev/orders  -H "Authorization: Bearer <JWT>"  -H "Content-Type: application/json"  -d '{"customer_name":"AuthUser","item":"Coffee","quantity":1}'
```

Expected: 200 OK

---

## AWS Cafe Common Issues & Troubleshooting

[AWS Cafe Common Issues & Troubleshooting](./AWS%20Cafe%20Project%20Development%20%26%20Depolyment%20Docs/AWS%20Cafe%20Common%20Issues%20%26%20Troubleshooting.md)

---

# 🏁 FINAL RESULT

You now have a **real AWS production architecture** with:

✔ Secure credentials

✔ Automation

✔ Multi‑region deployment

✔ Exam‑ready design

✔ Authenticated users only  

✔ Cached & accelerated API 

✔ Protected costs  

✔ Billing alerts active  

---

## 🚀 Next Steps
- Cognito + IAM fine-grained roles
- CloudFront + WAF
- Savings Plans
- Multi-account billing









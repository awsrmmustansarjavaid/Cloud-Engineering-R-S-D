
# ☕ AWS CAFE — Cafe Order Development & Deployment

**Dev → Serverless → Secure → Scalable → Cost-Controlled**

**Author & Architecture Designer:** Charlie

**Level:** Beginner → Advanced (Production-grade)

**Approach:** AWS Console First • No Skipped Steps • Exam + Real-World Safe

---

# SECTION 1️⃣ Cafe Order Processor

## PHASE 1️⃣ — AUTOMATION Lambda Cafe-Order (SERVERLESS)

### 1️⃣ Create Lambda Role

* Name: `Lambda-Cafe-Order-Role`
* Policies:

  * AWSLambdaBasicExecutionRole
  * Secrets Manager custom policy

---

### 2️⃣ Create Lambda Function

* Name: `CafeOrderProcessor`
* Runtime: Python 3.12
* Role: `Lambda-Cafe-Order-Role`

---

### 3️⃣ Lambda Layer (pymysql)

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

### Method 2️⃣ - PyMySQL Lambda Layer (1-to-1)

#### 1️⃣ Prepare ZIP File (EC2 or Local)

```bash
sudo dnf install -y python3 python3-pip
```

```
mkdir lambda-layer && cd lambda-layer
```

```
pip3 install pymysql -t python/
```

```
zip -r pymysql-layer.zip python
```

#### 2️⃣ Confirm ZIP exists:

```bash
ls -lh pymysql-layer.zip
```

**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---

## PHASE 2️⃣ — S3 Bucket - Upload ZIP

## 1️⃣ S3 Bucket - Upload ZIP to Lambda

### Upload layer → Attach to Lambda.

### 1️⃣ Upload ZIP to S3

#### connect Configure AWS CLI

Run this on your local machine / EC2 / CloudShell:

```
aws configure
```

#### Enter values exactly like this:

```
AWS Access Key ID [None]: AKIA************
AWS Secret Access Key [None]: ********************
Default region name [None]: us-east-1
Default output format [None]: json
```

✔ Press Enter after each input

#### Verify CLI Configuration

```
aws sts get-caller-identity
```

#### Expected output:

```
{
  "UserId": "AIDA************",
  "Account": "123456789012",
  "Arn": "arn:aws:iam::123456789012:user/cafe-lab-cli-user"
}
```

✔ This confirms AWS CLI is correctly authenticated.


#### Upload via AWS CLI (Recommended)

```bash
aws s3 cp pymysql-layer.zip s3://mn-cafe-s3-bucket/layers/pymysql-layer.zip
```

#### Expected output:

```
upload: ./pymysql-layer.zip to s3://mn-cafe-s3-bucket/layers/pymysql-layer.zip
```


##### Option B: Upload via S3 Console

* Open your S3 bucket
* Click **Upload**
* Add file → select `pymysql-layer.zip`
* Click **Upload**


**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**
---

## PHASE 3️⃣ — Lambda Layer

### 1️⃣ Create Lambda Layer Using S3

### 1️⃣  Lambda Console

* AWS Console → **Lambda**
* Click **Layers**
* Click **Create layer**

### 2️⃣  Layer Settings

| Field              | Value                                                          |
| ------------------ | -------------------------------------------------------------- |
| Name               | `pymysql-layer`                                                |
| Description        | PyMySQL dependency layer                                       |
| Code entry type    | **Upload a file from Amazon S3**                               |
| S3 URI             | `s3://cafe-lambda-artifacts-<unique>/layers/pymysql-layer.zip` |
| Compatible runtime | Python 3.12                                                    |

Click **Create**

✅ Lambda Layer created from S3

### 2️⃣ Attach Layer to Lambda Function

####  1️⃣ Open Lambda Function

* Lambda → Functions → `CafeOrderProcessor`

#### 2️⃣ Add Layer

* Scroll to **Layers** section
* Click **Add a layer**
* Choose **Custom layers**
* Select:

  * Layer: `pymysql-layer`
  * Version: latest

Click **Add**

**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---

## PHASE 4️⃣ — API Gateway


## Objective:

Expose your `CafeOrderProcessor` Lambda function via REST API so your EC2 Café web app can send orders to it.

### 1️⃣ Create a REST API

1. Open **AWS Management Console → API Gateway**.
2. Click **Create API**.
3. Choose **REST API → Build**.
4. **Configuration:**
   - API name: `CafeOrderAPI`
   - Description: `API for processing café orders`
   - Endpoint type: `Regional` (default)
5. Click **Create API**.



### 2️⃣ Create Resource

1. In your API, click **Resources → Actions → Create Resource**.
2. Configure:
   - Resource Name: `orders`
   - Resource Path: `/orders`
3. Click **Create Resource**.



### 3️⃣ Create POST Method

1. Select `/orders` resource.
2. Click **Actions → Create Method → POST**.
3. Integration type: **Lambda Function**
   - Check **Use Lambda Proxy integration**
   - Lambda Region: `us-east-1`
   - Lambda Function: `CafeOrderProcessor`
4. Click **Save** → **OK** to give permissions to API Gateway to invoke Lambda.



### 4️⃣ Enable CORS (Cross-Origin Resource Sharing)

1. Select `/orders` resource.
2. Click **Actions → Enable CORS**.
3. Configure:
   - Allowed Methods: `POST`
   - Allowed Headers: `Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token`
   - Allow Credentials: unchecked
4. Click **Enable CORS and replace existing CORS headers**.
5. Click **Yes, replace existing values** if prompted.



### 5️⃣ Deploy API

1. Click **Actions → Deploy API**.
2. Configure:
   - Deployment stage: `dev`
   - Stage description: `Development stage`
   - Deployment description: `Initial deployment`
3. Click **Deploy**.



### 6️⃣ Copy API Invoke URL

After deployment, you’ll see an **Invoke URL** at the top of the Stage page, e.g.:

```
https://abcdef123.execute-api.us-east-1.amazonaws.com/dev/orders
```

> This URL will be used in your EC2 PHP web app `curl` requests.

**✅ PHASE 4️⃣ STATUS**

> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**
---

## PHASE 5️⃣ — Frontend Development Code

##  Modify orders.php (Automation)

* Remove direct DB insert
* Send POST JSON to API Gateway

## 🌐 Configuration for Insert Data in EC2 MariaDB server / RDS DB ( Recommanded)

### 1️⃣ Update EC2 PHP App to Use API Gateway

```
sudo nano /var/www/html/orders.php
```

#### In your `orders.php`:

You can copy-paste this entire file safely 👇

```php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $data = json_encode([
        "name" => $_POST['name'],
        "item" => $_POST['item'],
        "quantity" => $_POST['quantity']
    ]);

    $ch = curl_init("https://abcdef123.execute-api.us-east-1.amazonaws.com/dev/orders");
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $data);

    $response = curl_exec($ch);
    curl_close($ch);

    echo "<p>✅ Order sent to serverless backend!</p>";
}
```

#### 💻 MODERN CAFE-STYLE orders.php (Frontend Only Modified)

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Charlie Cafe ☕ | Place Order</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Google Font -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">

    <style>
        body {
            font-family: 'Poppins', sans-serif;
            margin: 0;
            min-height: 100vh;
            background: linear-gradient(rgba(0,0,0,0.65), rgba(0,0,0,0.65)),
                        url("https://images.unsplash.com/photo-1517248135467-4c7edcad34c4");
            background-size: cover;
            background-position: center;
        }

        .navbar {
            background-color: #3b1f0e;
        }

        .navbar-brand {
            color: #fff !important;
            font-weight: 600;
        }

        .order-card {
            background: #ffffff;
            border-radius: 20px;
            padding: 35px;
            box-shadow: 0 15px 30px rgba(0,0,0,0.3);
        }

        .order-card h2 {
            font-weight: 600;
            margin-bottom: 20px;
        }

        label {
            font-weight: 500;
            margin-top: 15px;
        }

        input, select {
            border-radius: 10px;
            padding: 10px;
        }

        .btn-order {
            background-color: #ff9800;
            color: #000;
            font-weight: 600;
            border-radius: 30px;
            padding: 12px;
            border: none;
            transition: 0.3s;
        }

        .btn-order:hover {
            background-color: #e68900;
        }

        footer {
            color: #fff;
            text-align: center;
            padding: 15px;
            margin-top: 40px;
            font-size: 14px;
        }

        .response-box {
            margin-top: 20px;
            font-size: 14px;
        }
    </style>
</head>

<body>

<!-- Navbar -->
<nav class="navbar navbar-dark">
    <div class="container">
        <a class="navbar-brand" href="index.html">☕ Charlie Cafe</a>
    </div>
</nav>

<!-- Order Section -->
<div class="container d-flex justify-content-center align-items-center" style="min-height: 85vh;">
    <div class="col-md-6">
        <div class="order-card">

            <h2 class="text-center">Place Your Order</h2>
            <p class="text-center text-muted">Fresh • Hot • Made with Love</p>

            <form method="POST">

                <!-- NEW: TABLE NUMBER -->
                <label>Table Number</label>
                <input type="number" name="table_number" min="1" class="form-control" required>

                <label>Customer Name</label>
                <input type="text" name="name" class="form-control">

                <label>Select Item</label>
                <select name="item" class="form-select">
                    <option value="Coffee">Coffee</option>
                    <option value="Tea">Tea</option>
                    <option value="Latte">Latte</option>
                    <option value="Cappuccino">Cappuccino</option>
                    <option value="Fresh Juice">Fresh Juice</option>
                </select>

                <label>Quantity</label>
                <input type="number" name="quantity" min="1" value="1" class="form-control">

                <button type="submit" class="btn btn-order w-100 mt-4">
                    ☕ Place Order
                </button>
            </form>

            <!-- Backend Response (UNCHANGED FLOW) -->
            <div class="response-box">
                <?php
                if ($_SERVER["REQUEST_METHOD"] === "POST") {

                    $apiUrl = "https://svirhyw5a3.execute-api.us-east-1.amazonaws.com/dev/orders";

                    $payload = json_encode([
                        "table_number"  => (int)$_POST['table_number'],
                        "customer_name" => $_POST['name'],
                        "item"          => $_POST['item'],
                        "quantity"      => (int)$_POST['quantity']
                    ]);

                    $ch = curl_init($apiUrl);
                    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
                    curl_setopt($ch, CURLOPT_POST, true);
                    curl_setopt($ch, CURLOPT_HTTPHEADER, [
                        "Content-Type: application/json"
                    ]);
                    curl_setopt($ch, CURLOPT_POSTFIELDS, $payload);

                    $response = curl_exec($ch);

                    if ($response === false) {
                        echo "<p class='text-danger'>❌ CURL Error: " . curl_error($ch) . "</p>";
                    } else {
                        echo "<p class='text-success fw-bold'>✅ Order sent successfully</p>";
                        echo "<pre class='bg-light p-2 rounded'>$response</pre>";
                    }

                    curl_close($ch);
                }
                ?>
            </div>

        </div>
    </div>
</div>

<!-- Footer -->
<footer>
    © 2026 Charlie Cafe | Serverless Orders ☁️
</footer>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
```

### 2️⃣ Restart Apache (MANDATORY)

```
sudo systemctl restart httpd
```

**✅ PHASE 5️⃣ STATUS**

> **🟢 PHASE 5️⃣ COMPLETE & VERIFIED**
---

## PHASE 6️⃣ — Backend Development Code

### 1️⃣ Lambda Payload Code (INSERT INTO MariaDB)

Paste THIS EXACT CODE ⬇️


```
import json
import pymysql
import boto3

# ---------- GET DB SECRET ----------
def get_db_secret():
    client = boto3.client('secretsmanager')
    response = client.get_secret_value(SecretId='CafeDevDBSM')
    return json.loads(response['SecretString'])

# ---------- LAMBDA HANDLER ----------
def lambda_handler(event, context):
    try:
        # Parse API Gateway body
        body = json.loads(event['body'])

        # NEW: Table Number
        table_number = int(body['table_number'])

        customer_name = body.get('customer_name', None)
        item = body['item']
        quantity = int(body['quantity'])

        # Fetch DB credentials
        secret = get_db_secret()

        # Connect to RDS
        connection = pymysql.connect(
            host=secret['host'],
            user=secret['username'],
            password=secret['password'],
            database=secret['dbname'],
            connect_timeout=5
        )

        # Insert order
        with connection.cursor() as cursor:
            sql = """
                INSERT INTO orders (table_number, customer_name, item, quantity)
                VALUES (%s, %s, %s, %s)
            """
            cursor.execute(
                sql,
                (table_number, customer_name, item, quantity)
            )
            connection.commit()

        connection.close()

        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({
                "message": "Order saved successfully",
                "table_number": table_number
            })
        }

    except Exception as e:
        print("❌ ERROR:", str(e))
        return {
            "statusCode": 500,
            "headers": {
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({"error": str(e)})
        }
```

Save Lambda

Click Deploy (top right)



---- 

### 2️⃣ Move Lambda Into VPC

- AWS Console → Lambda → Your Function

- Go to Configuration

- Open VPC

- Click Edit

- Select:

    - **VPC → same as EC2**

    - **Subnets → PRIVATE subnets (important)**

    - **Security Group → Lambda SG**

    - Save

**⏳ Wait until Lambda status = Active**


### 3️⃣ Create VPC Endpoint

- **AWS Console → VPC → Endpoints → Create endpoint**

- **Endpoint Name:** secretsmanager-INT-EP

- **Service category:** AWS services

- **Service name:** com.amazonaws.us-east-1.secretsmanager

- **Type:** Interface

- **VPC:** Select VPC 

- **Subnets:**

**✔ Select the SAME private subnets used by Lambda**

- **Security Group:**

**Allow HTTPS (443) inbound from Lambda SG**

Create endpoint ✅



**✅ PHASE 6️⃣ STATUS**

> **🟢 PHASE 6️⃣ COMPLETE & VERIFIED**
---

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

### 2️⃣ Cafe Order API + RDS Tests (API Gateway + rds-secret-test.sh)

### Method 1️⃣ Cafe Order API + RDS Tests

#### 1️⃣ Create & edit file

```
sudo nano test-api-and-rds.sh
```


#### 2️⃣ Edit the Script and Add Your Details

```
#!/usr/bin/env bash

# =============================================================================
#  Cafe Order API + RDS Tests (API Gateway + rds-secret-test.sh)
# =============================================================================

set -uo pipefail

# ─── Configuration ────────────────────────────────────────────────────────────

API_URL="https://d9c4cvq7w9.execute-api.us-east-1.amazonaws.com/dev/orders"

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
```

#### 3️⃣ Make the script executable

```
sudo chmod +x test-api-and-rds.sh
```
This command gives permission to run the file as a program/script.

#### 4️⃣ Run the script (with root privileges)

```
sudo ./test-api-and-rds.sh
```

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



# SECTION 2️⃣ — AWS Cafe Menu + Cache Layer

## PHASE 1 — AMAZON DYNAMODB (Menu + Cache Layer)

### 1️⃣ Create DynamoDB Table

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

### 2️⃣ Insert Menu Items

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


**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---


### 3️⃣ Create IAM Policy for DynamoDB Access

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


### 4️⃣ CREATE NEW LAMBDA (MENU API)

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

### 5️⃣ Lambda Code: Read Menu from DynamoDB (Python)

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

### 6️⃣ TEST LAMBDA (MANDATORY)

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

**✅ PHASE 7️⃣ STATUS**

> **🟢 PHASE 7️⃣ COMPLETE & VERIFIED**





# 🟢 SECTION 2️⃣ COMPLETE & VERIFIED
---









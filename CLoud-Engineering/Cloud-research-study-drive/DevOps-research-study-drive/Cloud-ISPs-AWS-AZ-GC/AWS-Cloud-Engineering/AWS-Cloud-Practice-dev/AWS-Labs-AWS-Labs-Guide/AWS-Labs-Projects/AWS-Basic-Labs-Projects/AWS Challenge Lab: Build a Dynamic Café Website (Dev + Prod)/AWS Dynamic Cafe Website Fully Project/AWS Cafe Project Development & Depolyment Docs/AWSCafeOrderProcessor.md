
# PHASE 1 — AMAZON RDS (Replace EC2 MariaDB)

## 1️⃣ Create DB Subnet Group
AWS Console → RDS → Subnet groups → Create
- Name: CafeRDSSubnetGroup
- VPC: CafeDevVPC
- Subnets: **PRIVATE subnets (2 AZs)**

Create

## 2️⃣ Create Security Group for RDS
VPC → Security Groups → Create
- Name: CafeRDS-SG
- Inbound:
  - MySQL/Aurora (3306) → Source: Lambda-SG
  - MySQL/Aurora (3306) → Source: EC2-Web-SG
- Outbound: All

Create

## 3️⃣ Create RDS Instance
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

Create database ⏳

## 4️⃣ Create Schema in RDS
Connect from EC2:

## 1️⃣ Install & Login MySQL Client

```
sudo dnf install -y mariadb105
```

### Verify mysql

```
mysql --version
```

### Login to MariaDB:

```
mysql -h <rds-endpoint> -u cafe_user -p
```
---

## 2️⃣ Create Café Database

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

## 3️⃣ Use the correct database

```
USE cafe_db;
```

## 4️⃣ Orders Table

```sql
CREATE TABLE orders (
 id INT AUTO_INCREMENT PRIMARY KEY,
 customer_name VARCHAR(100),
 item VARCHAR(50),
 quantity INT,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 📢 Recommended Final CREATE TABLE (with table_number)

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

### 📢 Most common real-world version

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

### 📢 Remove (Delete) the Table

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

### 📢 Modify Existing Table (ALTER TABLE)

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

## 5️⃣ Verify table exists

```
SHOW TABLES;
```

##### You should see:

```
orders
```

## 6️⃣ Test insert manually (CLI)

```
INSERT INTO orders (customer_name, item, quantity)
VALUES ('CLI-Test', 'Coffee', 1);
```
### 📢 Multi Values (with table_number)


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

### 📢 Complete/Production Version (table NUMBER – with price, status, total_amount)

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







## 7️⃣ Verify:

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

# PHASE 2 — Store DB Credentials in Secrets Manager

## 1️⃣ Store DB Credentials in Secrets Manager

- Go to Secrets Manager → Store a new secret

- Type: Other type of secret → Key/Value

- Secret name:

```
CafeDevDBSM
```

### Keys:

```text
username
password
host
dbname
```

### Values:

```text
cafe_user
StrongPassword123
RDS endpoint
cafe_db
```

- Retrieve Secret ARN for later use in the app

---

## 2️⃣ IAM Role for EC2 (Secrets Access)

### Step 1: Create IAM Role

Policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": "secretsmanager:GetSecretValue",
    "Resource": "arn:aws:secretsmanager:us-east-1:*:secret:CafeDevDBSM*"
  }]
}
```

Role name:

```
EC2-Cafe-Secrets-Role
```

Attach role to EC2 (NO reboot).

### Step 2: Verify IAM Role is Attached

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

---

## 3️⃣ Test Secrets Manager Access from EC2

#### Install AWS CLI if not present:

```
sudo dnf install -y awscli
```

#### Run:

```
aws secretsmanager get-secret-value \
  --secret-id CafeDevDBSM \
  --region us-east-1
```

##### ✅ If secret value is returned → IAM role works

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

---

# PHASE 3 — AUTOMATION Lambda Cafe-Order (SERVERLESS)

## 1️⃣ Create Lambda Role

* Name: `Lambda-Cafe-Order-Role`
* Policies:

  * AWSLambdaBasicExecutionRole
  * Secrets Manager custom policy

---

## 2️⃣ Create Lambda Function

* Name: `CafeOrderProcessor`
* Runtime: Python 3.12
* Role: `Lambda-Cafe-Order-Role`

---

## 3️⃣ Lambda Layer (pymysql)

### Prepare ZIP File (EC2 or Local)

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

### Confirm ZIP exists:

```bash
ls -lh pymysql-layer.zip
```

---

# PHASE 4 — S3 Bucket - Upload ZIP

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

# PHASE 5 — Lambda Layer

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

---

# PHASE 6 — API Gateway


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

---

# PHASE 7 — Frontend Development Code

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

        /* Navbar */
        .navbar {
            background-color: #3b1f0e;
        }

        .navbar-brand {
            color: #fff !important;
            font-weight: 600;
        }

        /* Order Card */
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

        /* Button */
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

        /* Footer */
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

                <label>Customer Name</label>
                <input type="text" name="name" class="form-control" required>

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

            <!-- Backend Response (UNCHANGED) -->
            <div class="response-box">
                <?php
                if ($_SERVER["REQUEST_METHOD"] === "POST") {

                    $apiUrl = "https://svirhyw5a3.execute-api.us-east-1.amazonaws.com/dev/orders";

                    $payload = json_encode([
                        "customer_name" => $_POST['name'],
                        "item" => $_POST['item'],
                        "quantity" => (int)$_POST['quantity']
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

---

# PHASE 8 — Backend Development Code

### 1️⃣ Lambda Payload Code (INSERT INTO MariaDB)

Paste THIS EXACT CODE ⬇️


```
import json
import pymysql
import boto3

def get_db_secret():
    client = boto3.client('secretsmanager')
    response = client.get_secret_value(SecretId='CafeDevDBSM')
    return json.loads(response['SecretString'])

def lambda_handler(event, context):
    try:
        body = json.loads(event['body'])

        customer_name = body['customer_name']
        item = body['item']
        quantity = int(body['quantity'])

        secret = get_db_secret()

        connection = pymysql.connect(
            host=secret['host'],
            user=secret['username'],
            password=secret['password'],
            database=secret['dbname'],
            connect_timeout=5
        )

        with connection.cursor() as cursor:
            sql = """
                INSERT INTO orders (customer_name, item, quantity)
                VALUES (%s, %s, %s)
            """
            cursor.execute(sql, (customer_name, item, quantity))
            connection.commit()

        connection.close()

        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({"message": "Order saved successfully"})
        }

    except Exception as e:
        print("ERROR:", str(e))
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

    - VPC → same as EC2

    - Subnets → PRIVATE subnets (important)

    - Security Group → Lambda SG

    - Save

⏳ Wait until Lambda status = Active


### 3️⃣ Create VPC Endpoint

- AWS Console → VPC → Endpoints → Create endpoint

- Service category : AWS services

- Service name : com.amazonaws.us-east-1.secretsmanager

- Type : Interface

- VPC : Select VPC 

- Subnets :

✔ Select the SAME private subnets used by Lambda

- Security Group :

Allow HTTPS (443) inbound from Lambda SG

Create endpoint ✅

---

# PHASE 9 — Test & Verification


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



### 2️⃣ Test Lambda Directly (Console)

- Check your Lambda CloudWatch logs to ensure the function executed correctly.

- Verify new orders appear in your MariaDB database.

- In Lambda → Test

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


### 3️⃣ Verify Database

### Method 1 RDS Test

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
Sudo chmod +x rds-quick-test.sh
```
This command gives permission to run the file as a program/script.

#### 4️⃣ Run the script (with root privileges)

```
sudo ./rds-quick-test.sh
```

### Method 3 RDS Quick TestRDS Test Script using Secrets Manager

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

#### One-liner magic

```
sudo chmod +x rds-secret-test.sh && sudo ./rds-secret-test.sh
```

#### Common Secret JSON structures (choose correct jq paths)

| Secret format (what you see in console)                  | jq path for host | jq path for username | jq path for password |
|----------------------------------------------------------|------------------|----------------------|----------------------|
| `{"host":"...","username":"...","password":"..."}`       | `.host`          | `.username`          | `.password`          |
| `{"endpoint":"...","user":"...","pwd":"..."}`            | `.endpoint`      | `.user`              | `.pwd`               |
| RDS auto-generated rotation format                       | `.host`          | `.username`          | `.password`          |

- Adjust the three jq -r lines if your secret has different key names.


---









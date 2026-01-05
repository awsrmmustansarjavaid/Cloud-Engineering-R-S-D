# ☕ AWS Café Lab – Ordered Zero-to-Production Guide (Dev + Prod + Automation)

**Author & Architecture Designer:** Charlie

> **Trainer-led, exam-safe, production-style guide**
> This document rearranges the entire lab into the **correct real-world order**: infrastructure → OS → runtime → database → security → application → automation → production.

---

## 🎯 Objective

Build a **dynamic café ordering system** using:

* EC2 + LAMP (Dev)
* MariaDB
* Secrets Manager
* IAM Roles (NO hardcoded creds)
* Custom AMI
* Production environment (multi‑region)
* **Automation using Lambda + API Gateway**

---

## 🧱 High-Level Architecture

```
Browser
  ↓
EC2 (Apache + PHP)
  ↓ (POST JSON)
API Gateway
  ↓
Lambda (Order Processor)
  ↓
Secrets Manager
  ↓
MariaDB (Dev) / RDS (Optional)
```

---

## AWS Architecture Diagram 

![AWS Architecture Diagram](./AWS%20Challenge%20Lab%20Build%20a%20Dynamic%20Café%20Website%20Dev%20%20Prod.jpg)

---

## ✅ Prerequisites

* AWS Account (EC2, VPC, IAM, Secrets Manager, Lambda)
* Basic Linux commands
* PHP + MySQL knowledge
* SSH client or Cloud9

---

# PHASE 1 — NETWORK & COMPUTE (FOUNDATION)

## 1️⃣ Create Development VPC (us‑east‑1)

* VPC Name: `CafeDevVPC`
* CIDR: `10.0.0.0/16`

### Create Public Subnet

* Name: `CafeDevPublicSubnet`
* CIDR: `10.0.1.0/24`
* Auto‑assign public IP: **Enabled**

### Internet Access

* Create Internet Gateway → Attach to VPC
* Route table → Add route `0.0.0.0/0 → IGW`

---

## 2️⃣ Launch EC2 Instance (Amazon Linux 2023)

* AMI: Amazon Linux 2023
* Type: `t2.micro`
* VPC/Subnet: Dev VPC + Public subnet
* Security Group:

  * SSH (22) → Your IP
  * HTTP (80) → 0.0.0.0/0
* Name tag: `CafeDevWebServer`

---

## 3️⃣ Connect to EC2

```bash
chmod 400 CafeDevKey.pem
ssh -i CafeDevKey.pem ec2-user@<PUBLIC-IP>
```

---

# PHASE 2 — OPERATING SYSTEM & RUNTIME

## 4️⃣ Install LAMP Stack (ORDER MATTERS)

### Update OS

```bash
sudo dnf update -y
```

### Install Apache

```
sudo dnf install -y httpd
```

```
sudo systemctl enable --now httpd
```

### Install PHP

```bash
sudo dnf install -y php php-mysqlnd php-cli php-common php-mbstring php-xml
```

### Verify

```bash
php -v
httpd -v
```

---

## 5️⃣ Fix Permissions (MANDATORY)

```bash
sudo chown -R apache:apache /var/www
sudo chmod -R 755 /var/www
```

---

# PHASE 3 — DATABASE (LOCAL DEV)

## 6️⃣ Install MariaDB

```bash
sudo dnf install -y mariadb105-server
sudo systemctl enable --now mariadb
```

### Secure DB

```bash
sudo mysql_secure_installation
```
### Login to MariaDB:

```
sudo mysql -u root -p
```
---

## 7️⃣ Create Café Database

```sql
CREATE DATABASE cafe_db;
CREATE USER 'cafe_user'@'%' IDENTIFIED BY 'StrongPassword123';
GRANT ALL PRIVILEGES ON cafe_db.* TO 'cafe_user'@'%';
FLUSH PRIVILEGES;
```

#### Use the correct database

```
USE cafe_db;
```

### Orders Table

```sql
CREATE TABLE orders (
 id INT AUTO_INCREMENT PRIMARY KEY,
 customer_name VARCHAR(100),
 item VARCHAR(50),
 quantity INT,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### Verify table exists

```
SHOW TABLES;
```

##### You should see:

```
orders
```

#### Test insert manually (CLI)

```
INSERT INTO orders (customer_name, item, quantity)
VALUES ('CLI-Test', 'Coffee', 1);
```

#### Verify:

```
SELECT * FROM orders;
```

###### ✅ If you see the row → DB is READY

#### Exit MySQL:

```
EXIT;
```

---

# PHASE 4 — SECRETS & SECURITY (BEST PRACTICE)

## 8️⃣ Store DB Credentials in Secrets Manager

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
<EC2-Private-IP>
cafe_db
```

- Retrieve Secret ARN for later use in the app

---

## 9️⃣ IAM Role for EC2 (Secrets Access)

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

### Step 3: Test Secrets Manager Access from EC2

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

# PHASE 5 — APPLICATION CODE

## 🔹 index.php (Static Café Website – Lab Ready)

* 📂 Location: `/var/www/html/index.php`

* ✅ Purpose: UI + API call (no DB logic)

### Run

```
sudo nano /var/www/html/index.php
```

#### 👉 Copy & paste exactly as it is

- Paste the code → Save → Exit

```
<?php
require 'config.php';
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>AWS Café</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f6f8;
            margin: 0;
            padding: 0;
        }

        header {
            background-color: #2c3e50;
            color: white;
            padding: 20px;
            text-align: center;
        }

        .container {
            width: 90%;
            max-width: 600px;
            margin: 30px auto;
            background-color: white;
            padding: 25px;
            border-radius: 6px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }

        h2 {
            text-align: center;
            color: #333;
        }

        label {
            display: block;
            margin-top: 15px;
            font-weight: bold;
        }

        input, select, button {
            width: 100%;
            padding: 10px;
            margin-top: 5px;
            font-size: 16px;
        }

        button {
            background-color: #27ae60;
            color: white;
            border: none;
            margin-top: 20px;
            cursor: pointer;
        }

        button:hover {
            background-color: #219150;
        }

        footer {
            text-align: center;
            padding: 15px;
            margin-top: 30px;
            background-color: #ecf0f1;
            color: #555;
        }
    </style>
</head>
<body>

<header>
    <h1>☕ AWS Café</h1>
    <p>Welcome to our cloud-powered café</p>
</header>

<div class="container">
    <h2>Place Your Order</h2>

    <form method="POST">
        <label for="name">Customer Name</label>
        <input type="text" id="name" name="name" placeholder="Enter your name" required>

        <label for="item">Select Item</label>
        <select id="item" name="item">
            <option value="Coffee">Coffee</option>
            <option value="Tea">Tea</option>
            <option value="Latte">Latte</option>
            <option value="Cappuccino">Cappuccino</option>
        </select>

        <label for="quantity">Quantity</label>
        <input type="number" id="quantity" name="quantity" min="1" value="1">

        <button type="submit">Place Order</button>
    </form>

    <?php
    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        // Prepare and execute statement safely
        $stmt = $db->prepare("INSERT INTO orders (customer_name, item, quantity) VALUES (?, ?, ?)");
        $stmt->bind_param("ssi", $_POST['name'], $_POST['item'], $_POST['quantity']);
        $stmt->execute();
        echo "<p>✅ Order placed successfully!</p>";
    }
    ?>
</div>

<footer>
    <p>© 2025 AWS Café | Built on Amazon EC2 (LAMP Stack)</p>
</footer>

</body>
</html>
```

---

## 🔹 config.php (Secrets Manager + MariaDB)

* Reads Secrets Manager
* Establishes DB connection
* Uses AWS SDK for PHP
* 📂 Location: `/var/www/html/config.php`

```
sudo nano /var/www/html/config.php
```

```
<?php
require __DIR__ . '/vendor/autoload.php';

use Aws\SecretsManager\SecretsManagerClient;
use Aws\Exception\AwsException;

$region = "us-east-1";   // change for prod if needed
$secretName = "CafeDevDBSecret";

try {
    $client = new SecretsManagerClient([
        'version' => 'latest',
        'region'  => $region
    ]);

    $result = $client->getSecretValue([
        'SecretId' => $secretName
    ]);

    $secret = json_decode($result['SecretString'], true);

    $db = new mysqli(
        $secret['host'],
        $secret['username'],
        $secret['password'],
        $secret['dbname']
    );

    if ($db->connect_error) {
        die("Database connection failed: " . $db->connect_error);
    }

} catch (AwsException $e) {
    die("Secrets Manager error: " . $e->getMessage());
}
?>
```

## Deployment 

### Step 1: Fix Permissions (Very Important)

```
sudo chown -R apache:apache /var/www
```

```
sudo chmod -R 755 /var/www
```

---

### Step 2: Install AWS SDK for PHP

```bash
cd /var/www/html
sudo dnf install -y composer
sudo composer require aws/aws-sdk-php
```

### Step 3: Restart

```bash
sudo systemctl restart httpd
```

---

# PHASE 6 — AUTOMATION (SERVERLESS)

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
mkdir lambda-layer && cd lambda-layer
pip3 install pymysql -t python/
zip -r pymysql-layer.zip python
```

### Confirm ZIP exists:

```bash
ls -lh pymysql-layer.zip
```

---

## 4️⃣ S3 Bucket - Upload ZIP to Lambda

#### Upload layer → Attach to Lambda.

### Step 1: Create S3 Bucket 

- AWS Console → Search S3

- Click Create bucket

#### Bucket Configuration :


| Setting             | Value                            |
| ------------------- | -------------------------------- |
| Bucket name         | `cafe-lambda-artifacts-<unique>` |
| Region              | `us-east-1` (same as Lambda)     |
| Object ownership    | ACLs disabled                    |
| Block public access | ✅ Enabled (KEEP ON)             |


Click **Create bucket**

✅ Bucket created


### Step 2: Upload ZIP to S3

##### Upload via AWS CLI (Recommended)

```bash
aws s3 cp pymysql-layer.zip s3://cafe-lambda-artifacts-<unique>/layers/pymysql-layer.zip
```

#### Expected output:

```
upload: ./pymysql-layer.zip to s3://cafe-lambda-artifacts-xxx/layers/pymysql-layer.zip
```


##### Option B: Upload via S3 Console

* Open your S3 bucket
* Click **Upload**
* Add file → select `pymysql-layer.zip`
* Click **Upload**



---

## 4️⃣ API Gateway

* REST API
* Resource: `/orders`
* Method: POST
* Integration: Lambda (proxy enabled)
* Enable CORS
* Stage: `dev`

---

## 5️⃣ Modify index.php (Automation)

* Remove direct DB insert
* Send POST JSON to API Gateway

---

# PHASE 7 — TESTING & VERIFICATION

## Lambda Test

```json
{
 "body": "{\"name\":\"Test\",\"item\":\"Coffee\",\"quantity\":1}"
}
```

## DB Verify

```sql
SELECT * FROM orders ORDER BY id DESC;
```

---

# PHASE 8 — PRODUCTION (us‑west‑2)

## Create AMI

* Name: `CafeDevWebAMI`

## Launch Prod EC2

* Region: us‑west‑2
* From AMI
* New VPC/Subnet

---

# ✅ FINAL CHECKLIST

* [ ] Dev works
* [ ] Secrets secure
* [ ] Lambda inserts orders
* [ ] API Gateway reachable
* [ ] Prod mirrors Dev

---

## 🏁 RESULT

You now have a **real AWS production architecture** with:

✔ Secure credentials
✔ Automation
✔ Multi‑region deployment
✔ Exam‑ready design

---

🚀 *Next upgrades*: RDS, DynamoDB, SQS, WAF, CI/CD

# ☕ AWS Café Lab — Complete Zero-to-Production Master Guide

**Dev → Serverless → Secure → Scalable → Cost-Controlled**

**Author & Architecture Designer:** Charlie

**Level:** Beginner → Advanced (Production-grade)

**Approach:** AWS Console First • No Skipped Steps • Exam + Real-World Safe

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
CloudFront
  ↓
WAF
  ↓
API Gateway (Cognito Auth)
  ↓
Lambda (API)
  ↓
SQS
  ↓
Lambda Worker
  ↓
RDS (Orders – Source of Truth)
  ↓
DynamoDB (Menu / Cache)

EC2 (Web UI) → API Gateway (NO direct DB access)

```

---

## AWS Architecture Diagram 

![AWS Architecture Diagram](./AWS%20Cafe%20Project%20Architecture%20Diagram/AWS-Cafe-Lab-Cognito-CloudFront-Cost-Billing.jpeg)

---

## ✅ Prerequisites

* AWS Account (EC2, VPC, IAM, Secrets Manager, Lambda , RDS, CloudFront, S3 )
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

### Create TWO private subnets:

- CafeDevPrivateSubnet1 → 10.0.2.0/24 (AZ-a)
- CafeDevPrivateSubnet2 → 10.0.3.0/24 (AZ-b)


### Internet Access

* Create Internet Gateway → Attach to VPC
* Route table → Add route `0.0.0.0/0 → IGW`

---

## 2️⃣ Launch EC2 Instance (Amazon Linux 2023)


[EC2 Instance (Amazon Linux 2023)](./AWS%20Cafe%20Project%20Development%20%26%20Depolyment%20Docs/EC2%20Instance%20(Amazon%20Linux%202023).md)


# PHASE 3 — AMAZON RDS (Replace EC2 MariaDB)

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

## 7️⃣ Verify:

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

# PHASE 5 — APPLICATION CODE

## 1️⃣ Install AWS SDK for PHP

##### (Press ENTER for all prompts)

```bash
cd /var/www/html
```

```
sudo dnf install -y composer
```

```
sudo composer require aws/aws-sdk-php
```



## 2️⃣ Fix Permissions (Very Important)

```
sudo chown -R apache:apache /var/www
```

```
sudo chmod -R 755 /var/www
```

---

## 3️⃣ Restart

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

## 4️⃣ S3 Bucket - Upload ZIP to Lambda

#### Upload layer → Attach to Lambda.

### Step 1: Create S3 Bucket 

- AWS Console → Search S3

- Click Create bucket

#### Bucket Configuration :


| Setting             | Value                            |
| ------------------- | -------------------------------- |
| Bucket name         | `mn-cafe-s3-bucket` |
| Region              | `us-east-1` (same as Lambda)     |
| Object ownership    | ACLs disabled                    |
| Block public access | ✅ Enabled (KEEP ON)             |


Click **Create bucket**

✅ Bucket created


### Step 2: Upload ZIP to S3

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

### Step 3: Create Lambda Layer Using S3

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

### 3️⃣ Attach Layer to Lambda Function

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

---

## 4️⃣ API Gateway

**Objective:**  
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

## 5️⃣ Modify index.php (Automation)

* Remove direct DB insert
* Send POST JSON to API Gateway

### 1️⃣ Update EC2 PHP App to Use API Gateway

#### In your `index.php`:

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

#### FULL UPDATED index.php (FINAL VERSION)

You can copy-paste this entire file safely 👇

```
sudo nano /var/www/html/index.php
```

```
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
        <label>Customer Name</label>
        <input type="text" name="name" required>

        <label>Select Item</label>
        <select name="item">
            <option value="Coffee">Coffee</option>
            <option value="Tea">Tea</option>
            <option value="Latte">Latte</option>
            <option value="Cappuccino">Cappuccino</option>
        </select>

        <label>Quantity</label>
        <input type="number" name="quantity" min="1" value="1">

        <button type="submit">Place Order</button>
    </form>

    <?php
    if ($_SERVER["REQUEST_METHOD"] === "POST") {

        $payload = [
            "customer_name" => $_POST["name"],
            "item"          => $_POST["item"],
            "quantity"      => (int) $_POST["quantity"]
        ];

        $apiUrl = "https://svirhyw5a3.execute-api.us-east-1.amazonaws.com/dev/orders";

        $ch = curl_init($apiUrl);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, ["Content-Type: application/json"]);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        if ($httpCode === 200) {
            echo "<p>✅ Order sent successfully!</p>";
        } else {
            echo "<p>❌ Error sending order</p>";
            echo "<pre>$response</pre>";
        }
    }
    ?>
</div>

<footer>
    <p>© 2025 AWS Café | Serverless Backend</p>
</footer>

</body>
</html>
```
### 2️⃣ Restart Apache (MANDATORY)

```
sudo systemctl restart httpd
```

### 3️⃣ Lambda Payload (IMPORTANT)

##### Your Lambda must expect proxy format:

```
import json

def lambda_handler(event, context):
    body = json.loads(event["body"])

    customer_name = body["customer_name"]
    item = body["item"]
    quantity = body["quantity"]

    return {
        "statusCode": 200,
        "headers": {
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps({"message": "Order saved"})
    }
```

Save Lambda

Click Deploy (top right)

⚠️ If you don’t click Deploy → old code runs

### 4️⃣ Test API Gateway

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



### 5️⃣ Test Lambda Directly (Console)

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

### 6️⃣ Verify Database

```
mysql -u cafe_user -p cafe_db
```

or

```
mysql -h <rds-endpoint> -u cafe_user -p
```

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

---


## 🌐 Configuration for Insert Data in EC2 MariaDB server

### 1️⃣ Update EC2 PHP App to Use API Gateway

#### In your `index.php`:

You can copy-paste this entire file safely 👇

```
sudo nano /var/www/html/index.php
```

```
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
        <label>Customer Name</label>
        <input type="text" name="name" required>

        <label>Select Item</label>
        <select name="item">
            <option value="Coffee">Coffee</option>
            <option value="Tea">Tea</option>
            <option value="Latte">Latte</option>
            <option value="Cappuccino">Cappuccino</option>
        </select>

        <label>Quantity</label>
        <input type="number" name="quantity" min="1" value="1">

        <button type="submit">Place Order</button>
    </form>

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
        echo "<p style='color:red'>❌ CURL Error: " . curl_error($ch) . "</p>";
    } else {
        echo "<p style='color:green'>✅ Order sent successfully</p>";
        echo "<pre>$response</pre>";
    }

    curl_close($ch);
}
?>

</div>

<footer>
    <p>© 2025 AWS Café | Serverless Backend</p>
</footer>

</body>
</html>
```
### 2️⃣ Restart Apache (MANDATORY)

```
sudo systemctl restart httpd
```

### 3️⃣ Lambda Payload Code (INSERT INTO MariaDB)

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

⚠️ If you don’t click Deploy → old code runs

### 4️⃣ Move Lambda Into VPC

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


### 5️⃣ Create VPC Endpoint

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


### 5️⃣ Test API Gateway

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



### 6️⃣ Test Lambda Directly (Console)

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

### 7️⃣ Verify Database

```
mysql -u cafe_user -p cafe_db
```

or

```
mysql -h <rds-endpoint> -u cafe_user -p
```

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

## Common Issues & Troubleshooting


| Issue                              | Solution                                                                |
| ---------------------------------- | ----------------------------------------------------------------------- |
| CORS error in browser              | Ensure CORS is enabled for `/orders` with POST method                   |
| 403 Forbidden / Lambda not invoked | Check Lambda permissions (API Gateway needs `lambda:InvokeFunction`)    |
| 500 Internal Server Error          | Check Lambda CloudWatch logs for errors, confirm secrets are accessible |
| Orders not saving                  | Verify DB credentials in Secrets Manager and Lambda function            |




## ✅ FINAL CHECKLIST

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


# PHASE 9 — AMAZON DYNAMODB (Menu + Cache Layer)

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

---
### 3️⃣ Verify Items

You should now see 3 items in the table. You should now see:

| item   | price |
| ------ | ----- |
| Coffee | 3     |
| Latte  | 5     |
| Tea    | 2     |

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
[
  {"item": "Coffee", "price": 3},
  {"item": "Latte", "price": 5},
  {"item": "Tea", "price": 2}
]
```

---

# PHASE 10 — SQS (Async Order Processing)

## 🧠 WHY SQS EXISTS (VERY IMPORTANT)

### ➖ Without SQS:

- API waits for DB insert ❌

- API fails if DB is slow ❌

- Users get errors ❌

### ➕ With SQS:

- API responds instantly ✅

- Orders are processed in background ✅

- System scales safely ✅

---

## 🏁 ARCHITECTURE STATE (SUCCESS)

```
Client
  ↓
API Gateway
  ↓
CafeOrderApiLambda
  ↓
SQS (CafeOrdersQueue)
  ↓
CafeOrderWorker Lambda
  ↓
RDS + DynamoDB
```

✔ Fully asynchronous

✔ Decoupled

✔ Scalable

✔ Production-ready

---
## 📢 PRE-CHECK (DO NOT SKIP)

#### Before starting, confirm:

- Region is same for Lambda + SQS + RDS

- You have IAM role for Lambda

- You are using Standard Queue (NOT FIFO)

## 1️⃣ Create SQS Queue

- **SQS → Create queue**

- **Queue Type:** Standard

    ⚠️ Do NOT select FIFO

- **Name:** CafeOrdersQueue

**Configuration:**

- **Visibility timeout:** 60

> **💡 Why: Worker Lambda must finish DB insert within this time**

- **Message retention:** 4 days **(Leave default)**

- **Maximum message size:** 256 KB **(Leave default)**

- **Delivery delay:** 0 seconds **(Leave default)**

- **Receive message wait time:** 0 seconds **(Leave default)**

- **Dead-letter queue:** ❌ Disable for now **(we’ll add later)**

- **Encryption:** Select: Disabled **(Free tier friendly)**

- **Access Policy:** Leave Basic **(Do NOT change)**

**✔️ Click Create queue**

### ✅ Verify

- Queue status should be Available

- Copy Queue ARN

- Copy Queue URL (IMPORTANT — save it)


## 2️⃣ IAM PERMISSIONS FOR PRODUCER LAMBDA

**Your API Lambda must be allowed to send messages.**

- **Go to IAM → Policies → Create inline policy**

#### Paste exactly:

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sqs:SendMessage",
      "Resource": "arn:aws:sqs:*:*:CafeOrdersQueue"
    }
  ]
}
```
- Save Policy

- **Name:**

```
SendOrderToSQS
```

**✔️ Click Create policy**


## 3️⃣ CREATE API Lambda Function (Producer)

**(ORDER API → SQS)**

### 🎯 PURPOSE 

This Lambda will:

- Receive HTTP request from API Gateway

- Read order JSON

- Send order to SQS

- Respond immediately (202 Accepted)

### 🧱 ARCHITECTURE POSITION

```
Browser / EC2 PHP App
        ↓
    API Gateway
        ↓
CafeOrderApiLambda   ← (YOU ARE CREATING THIS NOW)
        ↓
   CafeOrdersQueue (SQS)
```

### ✅ PRE-CHECK (DO THIS ONCE)

Make sure SQS Queue already exists:

- AWS Console → SQS

- Queue name: CafeOrdersQueue

- Type: Standard

✔ If exists → Continue

❌ If not → STOP and create it first

### ▶️ Create Lambda Function

- Open Lambda Console

- Click Functions

- Click Create function

#### Basic Information:

| Field         | Value                          |
| ------------- | --------------------           |
| Function name | `CafeOrderApiLambda`           |
| Runtime        | Python 3.12                   |
| Architecture   | x86_64                        |
| Execution role | Use existing role             |
| Role           | Same role with RDS + DynamoDB |

Click Create function

⏳ Wait until status shows Active

## 4️⃣ Update API Lambda (Producer)

### 1️⃣ Open Order API Lambda

- AWS Console → Lambda

- Click your Order API Lambda

### 2️⃣ Add Environment Variable:

- Configuration → Environment variables

- Click Edit

- Add:

| Key           | Value                  |
| ------------- | ---------------------- |
| SQS_QUEUE_URL | (paste your Queue URL) |

#### 📍 How to get Queue URL:

- Open SQS

- Click CafeOrdersQueue

- Copy Queue URL

**✔️ Click Save**

### 3️⃣ Update Lambda Code (FULL)

#### 1️⃣ Replace your order insert logic with this:


#### 📣 CafeOrderApiLambda — Code Evolution & Purpose

In this lab, the CafeOrderApiLambda is responsible for:

✅ Receiving orders from API Gateway

✅ Validating input

✅ Sending orders to Amazon SQS

❌ NOT interacting with RDS directly

> **This section documents all versions of the Lambda code used during learning, including their purpose, limitations, and why improvements were needed.**

#### 🧪 Version 1 — Strict Input Validation (Initial Learning Version)

#### 📌 Purpose

- Learn basic API → Lambda → SQS flow

- Enforce strict input requirements

- Understand how missing fields cause failures

#### 🧠 Key Behavior

- Requires customer_name, item, and quantity

- Fails if any field is missing

- Explicitly converts quantity to integer

- Returns HTTP 400 for client errors

#### ⚠️ Limitation

- No default values

- No CORS header on error

- Not user-friendly for real APIs

#### 💻 Code

```
import json
import boto3
import os

sqs = boto3.client('sqs')
QUEUE_URL = os.environ['SQS_QUEUE_URL']

def lambda_handler(event, context):
    try:
        body = json.loads(event['body'])

        message = {
            "customer_name": body["customer_name"],
            "item": body["item"],
            "quantity": int(body["quantity"])
        }

        sqs.send_message(
            QueueUrl=QUEUE_URL,
            MessageBody=json.dumps(message)
        )

        return {
            "statusCode": 202,
            "headers": {
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({"message": "Order accepted"})
        }

    except Exception as e:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": str(e)})
        }
```        

#### 🧪 Version 2 — Safer Defaults (Improved Usability Version)

#### 📌 Purpose

- Allow optional customer_name

- Avoid breaking API if field is missing

- Improve user experience

#### 🧠 Key Behavior

- Defaults customer_name to "Guest"

- Keeps API functional even if field missing

- Always returns CORS headers

#### ⚠️ Limitation

- Does NOT convert quantity to integer

- Incorrect use of HTTP 500 for client errors

- Still lacks full validation

#### 💻 Code

```
import json
import boto3
import os

sqs = boto3.client('sqs')
QUEUE_URL = os.environ['SQS_QUEUE_URL']

def lambda_handler(event, context):
    try:
        body = json.loads(event['body'])

        order = {
            "customer_name": body.get("customer_name", "Guest"),
            "item": body["item"],
            "quantity": body["quantity"]
        }

        sqs.send_message(
            QueueUrl=QUEUE_URL,
            MessageBody=json.dumps(order)
        )

        return {
            "statusCode": 202,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"message": "Order accepted"})
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": str(e)})
        }
```

#### ✅ Version 3 — Final Merged & Production-Ready (Recommended)

#### 📌 Purpose

- Combine strict validation + safe defaults

- Follow real-world serverless best practices

- Clean separation between API Lambda and Worker Lambda

- Suitable for interviews, demos, and production labs

#### 🧠 Key Improvements

✔ Input validation

✔ Default values

✔ Type safety

✔ Correct HTTP status codes

✔ Proper CORS handling

✔ Clean SQS message format

#### 💻 Final Code (Recommended for This Lab)

```
import json
import boto3
import os

sqs = boto3.client('sqs')
QUEUE_URL = os.environ['SQS_QUEUE_URL']

def lambda_handler(event, context):
    try:
        # Parse request body
        body = json.loads(event.get('body', '{}'))

        # Validate required fields
        if "item" not in body or "quantity" not in body:
            return {
                "statusCode": 400,
                "headers": {"Access-Control-Allow-Origin": "*"},
                "body": json.dumps({"error": "Missing required fields: item, quantity"})
            }

        order = {
            "customer_name": body.get("customer_name", "Guest"),
            "item": body["item"],
            "quantity": int(body["quantity"])
        }

        # Send message to SQS
        sqs.send_message(
            QueueUrl=QUEUE_URL,
            MessageBody=json.dumps(order)
        )

        return {
            "statusCode": 202,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({
                "message": "Order accepted",
                "order": order
            })
        }

    except ValueError:
        return {
            "statusCode": 400,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": "Quantity must be a number"})
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": str(e)})
        }
```
#### 🧠 Learning Summary (Why This Matters)

| Version | What You Learned             |
| ------- | ---------------------------- |
| v1      | Strict validation & failures |
| v2      | Defaults & API safety        |
| v3      | Real-world production design |


> **API Lambda validates and enqueues.**
> **Worker Lambda processes and writes to RDS.**

**✅ This separation is core serverless architecture.**


**✔️ Click Deploy**

#### 2️⃣ CREATE LAMBDA TEST (CONSOLE TEST)

- Click Test

- Select Create new test event

- Event name:

```
ApiOrderTest
```

Event JSON:


```
{
  "body": "{\"customer_name\":\"ConsoleTest\",\"item\":\"Latte\",\"quantity\":2}"
}
```

Click Save

Click Test

#### Expected Result (SUCCESS)

```
{
  "statusCode": 202,
  "body": "{\"message\":\"Order accepted\"}"
}
```

#### 3️⃣ VERIFY MESSAGE IN SQS (CRITICAL)

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

---

### 4️⃣ Test with API Gateway or Lambda test

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


### 🚨 COMMON ERRORS & FIXES

#### ❌ Error: KeyError: 'body'

✔ Fix: Your test event body is not stringified

#### ❌ Error: AccessDenied: sqs:SendMessage

✔ Fix:

- IAM policy missing

- Wrong Queue ARN

- Wrong region

#### ❌ No message in SQS

✔ Fix:

- Check QUEUE_URL

- Check Lambda environment variable

- Check CloudWatch logs

### ✅ FINAL CONFIRMATION CHECKLIST

✔ Lambda returns 202

✔ SQS receives message

✔ No DB insert in producer

✔ Worker Lambda will process later

---

## 5️⃣ Create Worker Lambda (Consumer)

### 📢 Worker Responsibilities:

- Read message
- Insert into RDS
- Update DynamoDB cache

### 🟡 ARCHITECTURE FLOW:

```
Client
 ↓
API Gateway
 ↓
Order API Lambda
 ↓
SQS Queue
 ↓
Worker Lambda
 ↓
RDS + DynamoDB
```

### 1️⃣ Create Lambda Function

- **Lambda → Create function**

- **Select Author from scratch**

| Field          | Value                         |
| -------------- | ----------------------------- |
| Function name  | `CafeOrderWorker`             |
| Runtime        | Python 3.12                   |
| Architecture   | x86_64                        |
| Execution role | Use existing role             |
| Role           | Same role with RDS + DynamoDB |


**✔️ Click Create function**

### 2️⃣ Add SQS Trigger (VERY IMPORTANT)

- Scroll to Function overview

- Click Add trigger

- Select SQS

```
your SQS arn url
```


#### Trigger settings:

| Field                      | Value         |
| -------------------------- | ------------- |
| Activate trigger           | ✅ Checked     |
| Batch size                 | 1             |
| Batch window               | 0             |
| Maximum concurrency        | (leave empty) |
| Report batch item failures | ❌ unchecked   |


**✔️ Click Add**

#### ⚠️ CRITICAL:

- AWS automatically:

- Creates event source mapping

- Adds ReceiveMessage permissions


### 3️⃣ IAM PERMISSIONS FOR WORKER LAMBDA

> **Your worker needs 3 permissions**

- Attach These Permissions


#### Add inline policy with:



```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ],
      "Resource": "your SQS arn url"
    },
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "your secrets manager arn url*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:GetItem"
      ],
      "Resource": "your DynamoDB arn url"
    }
  ]
}
```
- Name: 

```
CafeOrderWorkerPermissions
```

✅ IAM permissions are now correct


### 4️⃣ WORKER LAMBDA CODE (FULL EXAMPLE)

#### 📄 CafeOrderWorker Lambda Codes

> **We have two versions of the Worker Lambda. Both process orders from SQS and insert them into RDS + DynamoDB, but there are subtle differences in production safety and error handling.**

#### 1️⃣ Worker Lambda — Full Example (Original)

#### Purpose:

This is the first full example of a Lambda function that consumes messages from SQS, inserts them into RDS, and updates DynamoDB. Good for learning and initial testing, but not fully safe for production.

#### Pros:

- Simple, clear structure

- Easy to understand for beginners

- Works for initial testing

#### Cons / Risks:

- Does not raise errors to SQS on failure → messages may be lost silently

- No extra logging for debugging production issues

- Short DB timeout (5s) may fail in real-life high-latency situations

#### 💻 Code:

```
import json
import boto3
import pymysql
from decimal import Decimal

# ---------- AWS CLIENTS ----------
secrets_client = boto3.client('secretsmanager')
dynamodb = boto3.resource('dynamodb')

# ---------- CONSTANTS ----------
SECRET_NAME = "CafeDevDBSM"
DYNAMODB_TABLE = "CafeMenu"

# ---------- GET DB CREDS ----------
def get_db_secret():
    response = secrets_client.get_secret_value(
        SecretId=SECRET_NAME
    )
    return json.loads(response["SecretString"])

# ---------- LAMBDA HANDLER ----------
def lambda_handler(event, context):

    secret = get_db_secret()

    connection = pymysql.connect(
        host=secret["host"],
        user=secret["username"],
        password=secret["password"],
        database=secret["dbname"],
        connect_timeout=5
    )

    table = dynamodb.Table(DYNAMODB_TABLE)

    try:
        with connection.cursor() as cursor:

            for record in event["Records"]:

                order = json.loads(record["body"])

                customer_name = order["customer_name"]
                item = order["item"]
                quantity = int(order["quantity"])

                # ---------- INSERT INTO RDS ----------
                sql = """
                    INSERT INTO orders (customer_name, item, quantity)
                    VALUES (%s, %s, %s)
                """
                cursor.execute(sql, (customer_name, item, quantity))
                connection.commit()

                # ---------- UPDATE DYNAMODB CACHE ----------
                table.update_item(
                    Key={"item": item},
                    UpdateExpression="ADD orders :inc",
                    ExpressionAttributeValues={
                        ":inc": Decimal(quantity)
                    }
                )

                print(f"✅ Order processed: {order}")

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Orders processed successfully"})
        }

    except Exception as e:
        print("❌ ERROR:", str(e))
```

#### 2️⃣ Worker Lambda — Fixed / Production Safe (Recommended)

#### Purpose:

This is the improved “production-safe” version. Handles errors properly, has better debug logging, and uses a slightly longer DB timeout. Recommended for real SQS-triggered environments.

#### Pros:

- Production-ready: raises exception to SQS → prevents message loss

- Better logging for troubleshooting

- Slightly longer DB timeout (10s) → more reliable

- Safe for automatic SQS polling

#### Cons:

- Slightly more verbose (prints, exception raising)

- Beginners may find it slightly harder to read

#### 💻 Code:

```
import json
import boto3
import pymysql
from decimal import Decimal

# ---------- AWS CLIENTS ----------
secrets_client = boto3.client('secretsmanager')
dynamodb = boto3.resource('dynamodb')

# ---------- CONSTANTS ----------
SECRET_NAME = "CafeDevDBSM"
DYNAMODB_TABLE = "CafeMenu"

# ---------- GET DB CREDS ----------
def get_db_secret():
    print("Fetching DB secret...")
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])

# ---------- LAMBDA HANDLER ----------
def lambda_handler(event, context):

    print("Lambda triggered by SQS")
    print("Event:", event)

    secret = get_db_secret()

    connection = pymysql.connect(
        host=secret["host"],
        user=secret["username"],
        password=secret["password"],
        database=secret["dbname"],
        connect_timeout=10
    )

    table = dynamodb.Table(DYNAMODB_TABLE)

    try:
        with connection.cursor() as cursor:
            for record in event["Records"]:
                order = json.loads(record["body"])

                customer_name = order["customer_name"]
                item = order["item"]
                quantity = int(order["quantity"])

                # ---------- INSERT INTO RDS ----------
                cursor.execute(
                    "INSERT INTO orders (customer_name, item, quantity) VALUES (%s, %s, %s)",
                    (customer_name, item, quantity)
                )
                connection.commit()

                # ---------- UPDATE DYNAMODB ----------
                table.update_item(
                    Key={"item": item},
                    UpdateExpression="ADD orders :inc",
                    ExpressionAttributeValues={":inc": Decimal(quantity)}
                )

                print("✅ Order processed:", order)

        return {"statusCode": 200}

    except Exception as e:
        print("❌ FATAL ERROR:", str(e))
        raise e   # 🚨 REQUIRED FOR SQS RETRY
```

#### 🔑 Key Differences Between Both Versions

| Feature                     | Original Full Example                                 | Fixed / Production Safe                           |
| --------------------------- | ----------------------------------------------------- | ------------------------------------------------- |
| Error Handling              | Prints error only, returns 200 → messages may be lost | Raises exception → SQS will retry failed messages |
| Logging                     | Basic                                                 | Extensive, shows SQS event, debug messages        |
| DB Timeout                  | 5 seconds                                             | 10 seconds (safer in production)                  |
| Recommended for Production? | ❌ Only for testing                                    | ✅ Best practice                                   |
| Safety with SQS             | Not safe                                              | Safe, retries on failure                          |
| Developer Understanding     | Easy to read                                          | Slightly more complex but safer                   |

#### 💡 Recommendation for this Lab

- Use the Fixed / Production Safe Lambda for CafeOrderWorker.

- Keep the Original version only as a learning reference.

#### Reason:

- Automatic retries from SQS prevent data loss

- Full visibility in CloudWatch logs for debugging

- Matches real-world serverless architecture patterns

**Click Deploy**

### 5️⃣ Attach Layer to Worker Lambda

- Lambda → CafeOrderWorker

> **Scroll to Layers**

- Click Add a layer

- Choose:

    - ☑ Custom layers

    - Select PyMySQLLayer

    - Version: latest

- Click Add

### 6️⃣ Attach Lambda to VPC (MANDATORY)

#### 1️⃣ Attach Lambda to VPC

- **AWS Console → Lambda → CafeOrderWorker**

1️⃣ Click Configuration

2️⃣ Click VPC

3️⃣ Click Edit

Set EXACTLY like this:

| Field           | Value                                 |
| --------------- | ------------------------------------- |
| VPC             | **Same VPC as RDS**                   |
| Subnets         | **Private subnets (same AZs as RDS)** |
| Security groups | **Lambda-SG (or create new)**         |

4️⃣ Click Save

⏳ Wait 1–2 minutes

#### 2️⃣ Fix Security Groups (MANDATORY)

**A) RDS Security Group**

#### Inbound rule:

| Type         | Port | Source        |
| ------------ | ---- | ------------- |
| MySQL/Aurora | 3306 | **Lambda-SG** |


❌ NOT 0.0.0.0/0

✅ MUST be Lambda SG

**B) Lambda Security Group**

#### Outbound rule (default usually OK):

| Type        | Destination |
| ----------- | ----------- |
| All traffic | 0.0.0.0/0   |


#### 3️⃣ Increase Lambda Timeout

**Lambda → Configuration → General configuration → Edit**

| Setting | Value          |
| ------- | -------------- |
| Timeout | **30 seconds** |
| Memory  | **512 MB**     |


👉 Why:

- ENI creation

- Cold start

- DB connection

- Memory also improves network performance.

Click Save

#### 4️⃣ VPC ENDPOINTS (THIS IS WHERE MOST FAIL)

You already have Secrets Manager endpoint ✅

Now add the remaining REQUIRED endpoints.

#### 1️⃣ Create SQS Interface Endpoint

**VPC → Endpoints → Create endpoint**

| Field          | Value                         |
| -------------- | ----------------------------- |
| Service        | `com.amazonaws.us-east-1.sqs` |
| Type           | Interface                     |
| VPC            | Same VPC                      |
| Subnets        | Same private subnets          |
| Security group | Lambda-SG                     |
| Private DNS    | ✅ ENABLE                      |

#### 2️⃣ Create CloudWatch Logs Interface Endpoint

- **Service:**

```
com.amazonaws.us-east-1.logs
```

Same settings as above

Private DNS ✅

#### 3️⃣ Create DynamoDB Gateway Endpoint (VERY IMPORTANT)

- **Service:**

```
com.amazonaws.us-east-1.dynamodb
```

- **Type:** Gateway

- **Attach to:**

  - ALL private route tables

Click Create

#### 4️⃣ Verify IAM Role (YOU ARE ALREADY OK)

You already have correct policies ✅

Nothing to change here.




#### 5️⃣ Verify Secrets Manager Keys (VERY IMPORTANT)

Your secret must contain EXACT keys:

```
{
  "host": "your-rds-endpoint",
  "username": "cafe_user",
  "password": "********",
  "dbname": "cafe_db"
}
```

❌ If even ONE key name differs → connection fails silently

#### 6️⃣ Add DEBUG LOGS (TEMPORARY)

Update your Lambda code temporarily:

```
print("DEBUG: Lambda invoked")
print("DEBUG: Event =", event)

secret = get_db_secret()
print("DEBUG: Secret fetched")

connection = pymysql.connect(
    host=secret["host"],
    user=secret["username"],
    password=secret["password"],
    database=secret["dbname"],
    connect_timeout=5
)

print("DEBUG: RDS connected")
```

This lets us see exactly where it stops.

### 7️⃣ TEST (MANDATORY)


### 1️⃣ Test manually from Lambda console

#### 1️⃣ You must wrap the test event in Records:

```
{
  "Records": [
    {
      "body": "{\"customer_name\": \"WorkerTest\", \"item\": \"Coffee\", \"quantity\": 2}"
    }
  ]
}
```

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

#### Expected:

```
WorkerTest | Coffee | 2
```

#### 🟩 STEP 7 — VERIFY DYNAMODB

- AWS Console → DynamoDB

- Click CafeMenu

- Click Explore table

- Click Coffee

#### Expected:

- Attribute orders exists

- Value increased by 2

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


---

# 🔒 PHASE 11 — AWS WAF (Security)

### Purpose: 

Protect your API Gateway from common attacks (SQL Injection, XSS, rate-limiting) and secure your serverless cafe orders API.

## 1️⃣ — Create WAF Protection Pack (Web ACL) for CafeOrderAPI

**Open the AWS Console → WAF & Shield → Web ACLs → Create Web ACL**

### 1️⃣ — “Tell us about your app”

- **App category:** Click the dropdown and select the most relevant category.

  - For your cafe order API, choose “Business Application” or something closest if available.

- **App focus:** Since your API is primarily for API Gateway requests:

  - Select Both API and web (recommended if you may later expose a website)

- Or select API if it’s purely API requests.

✅ This step tells AWS WAF what kind of attacks to prioritize.

### 2️⃣ — “Select resources to protect”

- Click Select resources to protect

- **Choose your API Gateway resource:** CafeOrderAPI

- Add the stage you want to protect (like prod or test)

- Click Add

✅ This associates your WAF with your API so the rules can start protecting it.

### 3️⃣ — “Choose initial protections”

- AWS will suggest protection rules based on your app category.

**You can either:**

  - Use the recommended protection package (simpler, automatic rules for SQLi, XSS, etc.)

  - Or select individual rules if you want more granular control:

    - AWSManagedRulesCommonRuleSet → common attacks

    - AWSManagedRulesSQLiRuleSet → SQL Injection attacks

- Optionally, add a rate-based rule:

  - Example: Limit to 1000 requests per 5 minutes per IP

✅ These rules are your main defense for API attacks.

### 4️⃣ — “Name and describe”

- Enter a name: CafeWebACL

- Optional description: "Protects CafeOrderAPI from common attacks, SQLi, XSS, and rate limiting"

### 5️⃣ — “Customize protection pack (optional)”

- This is optional.

- You can enable logging to CloudWatch here:

  - Turn on logging

  - Select or create a CloudWatch log group (e.g., /aws/waf/CafeWebACL)

- Leave other settings default for now.

✅ Logging is very useful to monitor attacks and blocked requests.

### 6️⃣ — Create protection pack

- Click Create protection pack (web ACL)

- AWS will provision the Web ACL, attach the rules, and associate it with your API Gateway.

✅ Once created, your API is protected, and WAF will start enforcing rules.

### 7️⃣ — Verification

- Normal API request: Should pass normally (HTTP 200)

- SQL injection attempt: Should be blocked (HTTP 403)

- Rate limit test: Exceed 1000 requests in 5 minutes → requests blocked

- CloudWatch logs: Check /aws/waf/CafeWebACL → confirm logs for blocked requests

### 💡 Tip: Protection packs are automated and recommended for beginners. If you want more granular control, you can manually create a Web ACL as in the previous step-by-step guide.

## 🚫 Important Reality Check — AWS WAF & Free Tier

### ❌ Why you should NOT proceed with WAF now

#### AWS WAF charges:

- Per Web ACL

- Per rule

- Per request

Even with zero traffic, just attaching WAF to API Gateway costs money.

#### ➡️ Conclusion:

- Skip PHASE 11 in hands-on execution
- Document it as a design / future enhancement only

This is how real AWS architects work on Free Tier.

## ✅ What You Should Do Instead (FREE & SAFE)

**We will REPLACE PHASE 11 execution with:**

## 🟢 PHASE 11 — SECURITY (FREE TIER SAFE VERSION)

### ✅ 1️⃣ API Gateway Security (FREE)

#### Already supported:

- IAM authorization

- Request validation

- Throttling

- Usage plans

- CORS control

### ✅ 2️⃣ Lambda-Level Input Validation (FREE)

Block SQLi/XSS inside Lambda
(No cost, no WAF)

### ✅ 3️⃣ CloudWatch Monitoring & Alarms (FREE tier limits)

### 🔐 FREE SECURITY CONTROLS YOU ALREADY HAVE

| Security Layer              | Status      | Cost               |
| --------------------------- | ----------- | ------------------ |
| IAM roles & least privilege | ✅ Done      | Free               |
| Secrets Manager             | ✅ Done      | Free (small usage) |
| API Gateway throttling      | ✅ Available | Free               |
| Lambda input validation     | ✅ Do this   | Free               |
| CloudWatch logs             | ✅ Done      | Free tier          |
| AWS WAF                     | ❌ SKIP      | Paid               |

---

# 🛡️ PHASE 11 (FREE TIER) — SECURITY WITHOUT WAF

Lambda Input Validation + API Gateway Throttling

This REPLACES AWS WAF safely.

## 🔐 PART A — Lambda Input Validation (MANDATORY)

### 🎯 Goal

Block bad / malicious requests BEFORE:

- SQS

- RDS

- DynamoDB

### ✅ STEP A1 — Open Correct Lambda Function

### ⚠️ IMPORTANT (No confusion here)

You must edit ONLY THIS FUNCTION:

✅ CafeOrderApiLambda

❌ NOT the Worker Lambda

❌ NOT the Secrets Lambda

#### Console Steps

- AWS Console → Lambda

- Click CafeOrderApiLambda

- Click Code tab

- Scroll to lambda_handler

### ✅ STEP A2 — Add Validation Function (COPY EXACT)

**📌 Paste this ABOVE lambda_handler**

```
def validate_order(order):
    if "item" not in order or "quantity" not in order:
        raise ValueError("Missing required fields")

    if not isinstance(order["quantity"], int) or order["quantity"] <= 0:
        raise ValueError("Invalid quantity")

    if len(order.get("customer_name", "")) > 50:
        raise ValueError("Invalid customer name")
```

### ✅ STEP A3 — Call Validation Inside lambda_handler

**Find this line:**

```
body = json.loads(event["body"])
```

#### 🔁 Replace with THIS BLOCK

```
order = json.loads(event["body"])
validate_order(order)
```

### ✅ STEP A4 — Full SAFE CafeOrderApiLambda Example

#### Use this REFERENCE VERSION (you can compare):

```
import json
import boto3
import os

sqs = boto3.client("sqs")
QUEUE_URL = os.environ["SQS_QUEUE_URL"]

def validate_order(order):
    if "item" not in order or "quantity" not in order:
        raise ValueError("Missing required fields")

    if not isinstance(order["quantity"], int) or order["quantity"] <= 0:
        raise ValueError("Invalid quantity")

    if len(order.get("customer_name", "")) > 50:
        raise ValueError("Invalid customer name")

def lambda_handler(event, context):
    try:
        order = json.loads(event["body"])
        validate_order(order)

        sqs.send_message(
            QueueUrl=QUEUE_URL,
            MessageBody=json.dumps(order)
        )

        return {
            "statusCode": 202,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"message": "Order accepted"})
        }

    except ValueError as ve:
        return {
            "statusCode": 400,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": str(ve)})
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": "Internal server error"})
        }
```

### ✅ STEP A5 — Deploy Lambda

- Click Deploy

Wait for green success bar

## 🧪 PART B — VERIFY LAMBDA INPUT VALIDATION (MANDATORY)

### ✅ TEST 1 — Valid Request (SHOULD PASS)

- API Gateway Console

- API Gateway → CafeOrderAPI

- Resources → /orders

- Method → POST

- Click Test

#### Request Body

```
{
  "customer_name": "Charlie",
  "item": "Tea",
  "quantity": 2
}
```

#### ✅ Expected Result

- Status: 202

- Message: "Order accepted"

- SQS receives message

- Worker Lambda processes order

### ❌ TEST 2 — Invalid Quantity (SHOULD FAIL)

#### Request Body

```
{
  "item": "Tea",
  "quantity": -5
}
```

#### ❌ Expected Result

- Status: 400

#### Response:

```
{"error": "Invalid quantity"}
```

✔️ Nothing sent to SQS

✔️ Nothing inserted in RDS

✔️ Nothing updated in DynamoDB

### ❌ TEST 3 — Missing Field

```
{
  "quantity": 1
}
```

#### ❌ Expected

```
{"error": "Missing required fields"}
```

### ❌ TEST 4 — Abuse Attempt

```
{
  "customer_name": "A" * 200,
  "item": "Tea",
  "quantity": 1
}
```

#### ❌ Expected

```
{"error": "Invalid customer name"}
```

## 🚦 PART C — API GATEWAY THROTTLING (FREE & REQUIRED)

### ✅ STEP C1 — Open API Stage

- AWS Console → API Gateway

- Click CafeOrderAPI

- Click Stages

- Click prod

### ✅ STEP C2 — Enable Throttling

Scroll to Default Method Throttling

- Set:

  - Rate: 10

  - Burst: 20

Click Save

### 🧪 STEP C3 — Verify Throttling
Test Rapid Requests

Send 20+ requests quickly (Postman / Test button)

#### Expected:

- First requests succeed

- Later requests fail with:

```
429 Too Many Requests
```

✔️ DoS protection working

✔️ Free Tier safe


---

# PHASE 12 — CI/CD (CodePipeline)

## 1️⃣ Create GitHub Repository
Repo structure:

/lambda-api
/lambda-worker
/web
buildspec.yml

## 2️⃣ Create CodeBuild Project
CodeBuild → Create
- Source: GitHub
- Environment: Python 3.12
- Privileged: ❌ No

buildspec.yml:
version: 0.2
phases:
  install:
    commands:
      - pip install -r requirements.txt
  build:
    commands:
      - zip function.zip *.py
artifacts:
  files:
    - function.zip

## 3️⃣ Create CodePipeline
Pipeline → Create
- Source: GitHub
- Build: CodeBuild
- Deploy: Lambda

Repeat pipeline for:
- API Lambda
- Worker Lambda

---

# PHASE 13 — TESTING

## API Test
curl -X POST <api-url> -d '{"customer_name":"CI","item":"Coffee","quantity":1}'

## Verify
- SQS: messages consumed
- Lambda logs clean
- RDS rows inserted
- DynamoDB updated

---

# 🏁 FINAL RESULT

✔ Managed DB (RDS)
✔ Serverless cache (DynamoDB)
✔ Async processing (SQS)
✔ Protected APIs (WAF)
✔ Automated deployments (CI/CD)

---

## 🚀 Next Enhancements
- CloudFront caching
- Cognito authentication
- Terraform IaC
- Multi‑account setup

---

# PHASE 14 — AMAZON COGNITO (AUTHENTICATION)

## 1️⃣ Create Cognito User Pool

AWS Console → Search **Cognito** → User Pools → **Create user pool**

### Step 1: Configure sign-in
- Sign-in options: **Email**
- User name: Email
Click **Next**

### Step 2: Security requirements
- Password policy: Default
- MFA: Optional (recommended later)
Click **Next**

### Step 3: Sign-up experience
- Enable self sign-up: ✅ Enabled
- Required attributes: Email
Click **Next**

### Step 4: Email configuration
- Email provider: Cognito default
Click **Next**

### Step 5: App integration
- User pool name: `CafeUserPool`
- Hosted authentication pages: ❌ Disable
Click **Next**

### Step 6: Review
Click **Create user pool**

✅ User Pool created

---

## 2️⃣ Create App Client

Inside User Pool → **App integration** → App clients → **Create app client**

- App client name: `CafeWebClient`
- Generate client secret: ❌ No (required for browser apps)
- Authentication flows:
  - ALLOW_USER_PASSWORD_AUTH
  - ALLOW_REFRESH_TOKEN_AUTH

Click **Create app client**

Save:
- User Pool ID
- App Client ID

---

## 3️⃣ Create Cognito Domain

User Pool → App integration → Domain
- Domain type: Cognito domain
- Domain prefix: `cafe-auth-<unique>`

Save

---

## 4️⃣ Integrate Cognito with API Gateway

API Gateway → CafeOrderAPI

### Step 1: Create Authorizer
- Authorizers → Create
- Type: Cognito
- Name: CafeCognitoAuthorizer
- User pool: CafeUserPool
- Token source: Authorization

Create

### Step 2: Attach Authorizer
Resources → /orders → POST
- Authorization: CafeCognitoAuthorizer
Save

### Step 3: Redeploy API
Actions → Deploy API → Stage: dev

---

# PHASE 15 — CLOUDFRONT + CACHING

## 1️⃣ Create CloudFront Distribution

AWS Console → CloudFront → Create distribution

### Origin
- Origin domain: API Gateway invoke URL (without https://)
- Origin type: Custom

### Default cache behavior
- Viewer protocol policy: Redirect HTTP to HTTPS
- Allowed HTTP methods: GET, HEAD, OPTIONS, POST
- Cache policy: Managed-CachingDisabled (for POST APIs)
- Origin request policy: Managed-AllViewer

Create distribution ⏳

Copy:
- CloudFront domain name

---

## 2️⃣ Update EC2 Web App

Replace API URL in `index.php`:

```php
$apiUrl = "https://<cloudfront-domain>/dev/orders";
```

Restart Apache:

```
sudo systemctl restart httpd
```

---

## 3️⃣ Optional: Cache Menu (GET)

For GET /menu:
- Cache policy: Managed-CachingOptimized
- TTL: Default

---

# PHASE 16 — COST OPTIMIZATION

## 1️⃣ EC2 Cost Optimization
- Instance type: t3.micro
- Enable EC2 auto-stop (Lambda scheduler)
- Delete unused AMIs & snapshots

## 2️⃣ RDS Cost Optimization
- Use db.t3.micro
- Disable Multi-AZ (Dev)
- Set backup retention: 1 day

## 3️⃣ Lambda Optimization
- Reduce timeout to 5 seconds
- Right-size memory
- Enable log retention (7 days)

## 4️⃣ DynamoDB Optimization
- On-demand capacity
- Enable TTL for cache tables

## 5️⃣ S3 Optimization
- Block public access
- Enable lifecycle rules (delete after 30 days)

---

# PHASE 17 — BILLING ALERTS & BUDGETS

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

# PHASE 18 — TESTING

## Cognito Test
- Sign up user
- Login → copy JWT token

## API Test with Token

```
curl -X POST <cloudfront-url>/dev/orders  -H "Authorization: Bearer <JWT>"  -H "Content-Type: application/json"  -d '{"customer_name":"AuthUser","item":"Coffee","quantity":1}'
```

Expected: 200 OK

---

# 🏁 FINAL RESULT

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



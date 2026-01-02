# ☕ AWS Café Lab - Build a Dynamic Café Website (Dev + Prod)

#### API Gateway + Lambda + RDS + Secrets Manager

> **Author & Architecture Desinger:** Charlie


**Goal:**

> **Frontend (index.html) → API Gateway → Lambda → RDS MySQL
Credentials fetched securely from Secrets Manager**

---

## 🏗️ Architecture Overview

**Frontend**

* Static `index.html`
* Hosted on **EC2 behind ALB**

**Backend**

* **API Gateway (REST API)**
* **Lambda (PHP via custom runtime OR Node.js)**
* **Amazon RDS MySQL**
* **AWS Secrets Manager**

**Security & Networking**

* VPC with public & private subnets
* ALB in public subnet
* RDS in private subnet
* IAM least-privilege roles

---

## 🧠 FINAL FLOW

```
Browser (index.html)
        ↓  HTTP POST
API Gateway (/order)
        ↓
Lambda Function
        ↓
Secrets Manager (DB creds)
        ↓
RDS MySQL (orders table)
```

---

## 🏗️ AWS Architecture Diagram

![AWS Architecture Diagram](./AWS%20Café%20Lab-API%20Gateway%20%2B%20Lambda%20%2B%20RDS%20%2B%20Secrets%20Manage.png)

---

## 📌 Region Used

* Primary: **us-east-1**

---

## PHASE 1️⃣ – Networking (VPC Foundation)

### Step 1: Create VPC

* VPC Name: `Cafe-VPC`
* CIDR: `10.0.0.0/16`

### Step 2: Create Subnets

| Name             | Type    | CIDR        | AZ         |
| ---------------- | ------- | ----------- | ---------- |
| Public-Subnet-A  | Public  | 10.0.1.0/24 | us-east-1a |
| Public-Subnet-B  | Public  | 10.0.2.0/24 | us-east-1b |
| Private-Subnet-A | Private | 10.0.3.0/24 | us-east-1a |
| Private-Subnet-B | Private | 10.0.4.0/24 | us-east-1b |

### Step 3: Internet Gateway

* Create IGW: `Cafe-IGW`
* Attach to `Cafe-VPC`

### Step 4: Route Tables

**Public Route Table**

* Route: `0.0.0.0/0 → IGW`
* Associate public subnets

**Private Route Table**

* No internet route
* Associate private subnets

---

## PHASE 2️⃣ – Amazon RDS MySQL

### Step 5: Create DB Subnet Group

* Name: `cafe-db-subnet-group`
* Subnets: Private A & B

### Step 6: Create Secrets Manager Secret

Secret Name: `CafeRDSSecret`

```json
{
  "username": "cafe_user",
  "password": "StrongPassword123!",
  "dbname": "cafe_db",
  "engine": "mysql",
  "port": 3306
}
```

### Step 7: Create RDS MySQL

* Engine: MySQL 8.x
* DB Instance: `cafe-rds`
* Public Access: ❌ No
* Subnet Group: `cafe-db-subnet-group`
* Credentials: **From Secrets Manager**

### Step 8: RDS Security Group

Inbound:

* MySQL (3306)
* Source: Lambda SG

---

## PHASE 3️⃣ – Database Initialization

### Step 9: install and configure Database

##### Update Your System

```
sudo dnf update -y
```

##### Install MySQL Client (Optional but Recommended)

```
sudo dnf install -y mariadb105
```

#### Verify mysql

```
mysql --version
```

##### Connect from Bastion / EC2

```bash
mysql -h <RDS-ENDPOINT> -u cafe_user -p 
```

### Step 10: Create Table

#### Create MySQL Database

```
CREATE DATABASE cafe_db;
```

#### Use the correct database

```
USE cafe_db;
```

#### Create the orders table (REQUIRED)

```sql
CREATE TABLE orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  customer_name VARCHAR(100),
  item VARCHAR(50),
  quantity INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## PHASE 4️⃣ – Backend API (Lambda + API Gateway)

### Step 11: IAM Role for Lambda

Console path:

```
IAM → Roles → Create role
```

#### Trusted entity

- Trusted entity: AWS service

- Use case: Lambda

- Click Next


####  Attach permissions

```
AWSLambdaBasicExecutionRole

SecretsManagerGetSecretValue
```

##### (or better: custom policy with secretsmanager:GetSecretValue)

- Click Next

####  Name the role

- Role name: CafeLambdaRole

- Create role

### Step 12: Create Lambda Function

#### Console path:

```
Lambda → Create function
```
#### Basic info

- Author from scratch

- Function name: CafeOrderAPI

- Runtime: Node.js 18.x

- Architecture: x86_64

#### Permissions

- Execution role: Use an existing role

- Select: CafeLambdaRole

- Click Create function

#### Configure Lambda Networking (RDS ACCESS)

- Go to: Lambda → CafeOrderFunction → Configuration → VPC

- Click Edit

  - VPC: Cafe VPC

  - Subnets: Private Subnet A & B

  - Security group: lambda-sg

##### ⚠️ Lambda MUST be in same VPC as RDS

- Save.

#### Lambda Environment Variables

- Go to: Configuration → Environment variables

- Add:

```
| Key        | Value          |
| ---------- | -------------- |
| DB_SECRET  | CafeRDSSecret  |
| DB_HOST    | <RDS-ENDPOINT> |

```

- Save.

#### LAMBDA CODE (BACKEND LOGIC)

```
const AWS = require('aws-sdk');
const mysql = require('mysql2/promise');

exports.handler = async (event) => {
  try {
    const body = JSON.parse(event.body);

    // AWS_REGION is automatically provided by Lambda
    const sm = new AWS.SecretsManager();

    const secret = await sm.getSecretValue({
      SecretId: process.env.DB_SECRET
    }).promise();

    const creds = JSON.parse(secret.SecretString);

    const conn = await mysql.createConnection({
      host: process.env.DB_HOST,
      user: creds.username,
      password: creds.password,
      database: creds.dbname
    });

    await conn.execute(
      'INSERT INTO orders (customer_name, item, quantity) VALUES (?, ?, ?)',
      [body.name, body.item, body.quantity]
    );

    await conn.end();

    return {
      statusCode: 200,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'OPTIONS,POST'
      },
      body: JSON.stringify({ message: 'Order placed successfully' })
    };

  } catch (err) {
    console.error('ERROR:', err);
    return {
      statusCode: 500,
      headers: {
        'Access-Control-Allow-Origin': '*'
      },
      body: JSON.stringify({ error: err.message })
    };
  }
};

```

#### Add MySQL Dependency (CRITICAL)

Lambda does NOT include mysql library by default.

##### On your local machine (or EC2):

```
mkdir lambda-package
cd lambda-package
npm init -y
npm install mysql2
```

Copy index.js into this folder.

##### Zip contents:

```
zip -r cafe-lambda.zip .
```

##### Upload zip:

```
Lambda → Code → Upload from → .zip file
```

Set environment variable:

* `DB_HOST = <RDS-ENDPOINT>`

---

## PHASE 5️⃣ – API Gateway

#### Console path:

```
API Gateway → Create API
```

#### Choose:

- REST API (not HTTP API)

- Click Build

#### API details

- API name: CafeAPI

- Endpoint type: Regional

- Create API.

#### Create Resource /order

##### In API Gateway:

```
Resources → /
```

- Click Create Resource

  - Resource Name: order

  - Resource Path: /order

- Create resource.

#### Create POST Method

- Click /order

- Click Create Method

  - Method type: POST

  - Integration type: Lambda Function

  - Lambda region: us-east-1

  - Lambda function: CafeOrderFunction

- Click Create method

✔ Allow API Gateway to invoke Lambda → YES

#### Enable CORS (DO NOT SKIP)

- Select /order

- Click Enable CORS

- Check:
  ✔ POST

  ✔ OPTIONS

- Click Save

### DEPLOY API

#### Deploy API

- Click:

```
Deploy API
```

- Stage name: prod

- Deploy

#### Copy Invoke URL

##### You will see:

```
https://abcd1234.execute-api.us-east-1.amazonaws.com/prod
```

##### Final endpoint:

```
https://abcd1234.execute-api.us-east-1.amazonaws.com/prod/order
```

### TEST API

#### Test via CLI

```
curl -X POST \
https://API-ID.execute-api.us-east-1.amazonaws.com/prod/order \
-H "Content-Type: application/json" \
-d '{"name":"Ali","item":"Coffee","quantity":1}'
```

#### Expected response:

```
{"message":"Order placed successfully"}
```

#### Verify in RDS

```
SELECT * FROM orders ORDER BY id DESC;
```



---

## PHASE 6️⃣ – Frontend (index.html)

### Step 16: Create index.html

```html
<!DOCTYPE html>
<html>
<body>
<h2>AWS Café</h2>
<form id="orderForm">
<input name="name" placeholder="Name" />
<input name="item" placeholder="Item" />
<input name="quantity" type="number" />
<button>Order</button>
</form>

<script>
document.getElementById("orderForm").addEventListener("submit", async e => {
  e.preventDefault();

  const data = {
    name: name.value,
    item: item.value,
    quantity: quantity.value
  };

  const res = await fetch(
    "https://API-ID.execute-api.us-east-1.amazonaws.com/prod/order",
    {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(data)
    }
  );

  alert("Order placed!");
});
</script>

</body>
</html>
```

### FINAL VERIFICATION

✔ API Gateway responds

✔ Lambda logs visible in CloudWatch

✔ RDS table updated

✔ Secrets Manager accessed

✔ Frontend works

### 🔍 DEBUGGING CHECKLIST

```
| Problem          | Check                  |
| ---------------- | ---------------------- |
| 500 error        | CloudWatch Lambda logs |
| CORS error       | OPTIONS enabled        |
| Timeout          | Lambda VPC / SG        |
| DB connect fails | RDS SG allows Lambda   |
| Forbidden        | IAM role               |
```

---

## PHASE 7️⃣ – EC2 + ALB

### Step 17: Launch EC2

* Amazon Linux 2023
* Install Apache

```bash
sudo dnf install -y httpd
sudo systemctl enable --now httpd
```

Upload `index.html` to `/var/www/html`

---

### Step 18: Create ALB

#### 1️⃣ Create ALB Security Group

##### Console Path:

```
EC2 → Security Groups → Create security group
```

#### Settings:

- Name: alb-sg

- Description: ALB public access

- VPC: Your Cafe VPC

#### Inbound rules:

```
| Type | Protocol | Port | Source    |
| ---- | -------- | ---- | --------- |
| HTTP | TCP      | 80   | 0.0.0.0/0 |
```

❌ Do NOT add SSH

❌ Do NOT restrict IPs yet

#### Outbound rules:

- Allow all (default)

- Click Create security group

#### 2️⃣Update EC2 Security Group (VERY IMPORTANT)

##### Your EC2 must allow traffic FROM ALB, not from internet.

- **Go to: EC2 → Security Groups → EC2-SG**


#### Inbound rules:

```
| Type | Port | Source |
| ---- | ---- | ------ |
| HTTP | 80   | alb-sg |
```

❌ Remove 0.0.0.0/0 for HTTP

✔ ALB → EC2 only (secure)

- Save rules.

#### 3️⃣ Create Target Group

Console Path:

```
EC2 → Load Balancing → Target Groups → Create target group
```
#### Basic configuration

- Target type: Instances

- Target group name: cafe-tg

- Protocol: HTTP

- Port: 80

- VPC: Your Cafe VPC

- Protocol version: HTTP1

- Click Next

#### Health checks (DO NOT SKIP)

- Set:

  - Health check protocol: HTTP

  - Health check path:

```
 /
```

#### Advanced health check:

- Healthy threshold: 2

- Unhealthy threshold: 2

- Timeout: 5

- Interval: 10

- Success codes: 200

- Click Next

#### Register targets

✔ Select your EC2 instance

✔ Port: 80

- Click Include as pending below

- Click Create target group

#### VERIFY TARGET HEALTH (IMPORTANT)

- Open cafe-tg

- Go to Targets tab

You MUST see:

```
EC2-ID     | Port | Status
-----------|------|--------
i-xxxxxxx  | 80   | healthy
```

#### ❌ If status = unhealthy:

- Apache not running

- Security group issue

- Wrong health check path


#### CREATE APPLICATION LOAD BALANCER

- Console Path:

```
EC2 → Load Balancers → Create load balancer
```
- Choose: Application Load Balancer

#### Basic configuration

- Load balancer name: cafe-alb

- Scheme: Internet-facing

- IP address type: IPv4

#### Network mapping

- VPC: Cafe VPC

- Mappings:

  ✔ Public Subnet AZ-a

  ✔ Public Subnet AZ-b

⚠️ MUST be public subnets

#### Security groups

- Remove default SG

- Select: alb-sg

#### Listeners & routing

- Listener:

  - Protocol: HTTP

  - Port: 80

- Default action:

  - Forward to: cafe-tg

Click Create load balancer

**⏳ Wait 1–2 minutes until:**

```
State: Active
```
---

## PHASE 8️⃣ – ☕ Convert Backend to PHP Lambda

### 🧠 FINAL ARCHITECTURE

```
API Gateway
    ↓
PHP Lambda (Custom Runtime)
    ↓
Secrets Manager
    ↓
RDS MySQL
```

### PHASE 0️⃣ – WHAT YOU NEED TO KNOW FIRST

Why PHP Lambda is different

- No php runtime in AWS

- You must package:

  - PHP binary

  - PHP code

  - Bootstrap file

### PHASE 1️⃣ – CREATE PHP LAMBDA FUNCTION

1️⃣ Create Lambda (Shell Only)
Console path:

```
Lambda → Create function
```

#### Settings:

- Author from scratch

- Function name: CafePHPOrderFunction

- Runtime: Custom runtime

- Runtime: provided.al2

- Architecture: x86_64

- Execution role: CafeLambdaRole

Create function.

### PHASE 2️⃣ – BUILD PHP RUNTIME (IMPORTANT)

You must build PHP on Amazon Linux, not Windows.

#### Best options:

✔ EC2 Amazon Linux 2

✔ CloudShell (recommended)

#### 2️⃣ Launch CloudShell

Open AWS CloudShell

#### 3️⃣ Install Required Tools

```
sudo yum install -y php php-cli php-mysqlnd unzip
```

#### Check:

```
php -v
```

### PHASE 3️⃣ – CREATE LAMBDA FILE STRUCTURE

```
mkdir php-lambda
cd php-lambda
```

#### Required files:

```
php-lambda/
├── bootstrap
├── index.php
└── vendor/ (optional later)
```

### PHASE 4️⃣ – CREATE bootstrap FILE (MOST IMPORTANT)

```
nano bootstrap
```

#### Paste EXACTLY:

```
#!/bin/sh
set -e

while true
do
  EVENT=$(curl -sS \
    -H "Lambda-Runtime-Function-Name: $AWS_LAMBDA_FUNCTION_NAME" \
    http://$AWS_LAMBDA_RUNTIME_API/2018-06-01/runtime/invocation/next)

  RESPONSE=$(echo "$EVENT" | php index.php)

  REQUEST_ID=$(echo "$EVENT" | jq -r '.requestContext.requestId')

  curl -sS -X POST \
    "http://$AWS_LAMBDA_RUNTIME_API/2018-06-01/runtime/invocation/$REQUEST_ID/response" \
    -d "$RESPONSE"
done
```

#### Make executable:

```
chmod +x bootstrap
```

### PHASE 5️⃣ – PHP HANDLER (index.php)

```
<?php
require 'vendor/autoload.php';

use Aws\SecretsManager\SecretsManagerClient;

$event = json_decode(stream_get_contents(STDIN), true);

try {
    $sm = new SecretsManagerClient([
        'version' => 'latest',
        'region' => getenv('AWS_REGION')
    ]);

    $secret = $sm->getSecretValue([
        'SecretId' => getenv('DB_SECRET')
    ]);

    $creds = json_decode($secret['SecretString'], true);

    $db = new mysqli(
        getenv('DB_HOST'),
        $creds['username'],
        $creds['password'],
        $creds['dbname']
    );

    $body = json_decode($event['body'], true);

    $stmt = $db->prepare(
        "INSERT INTO orders (customer_name, item, quantity) VALUES (?, ?, ?)"
    );
    $stmt->bind_param("ssi", $body['name'], $body['item'], $body['quantity']);
    $stmt->execute();

    echo json_encode([
        "statusCode" => 200,
        "headers" => ["Access-Control-Allow-Origin" => "*"],
        "body" => json_encode(["message" => "Order placed"])
    ]);

} catch (Exception $e) {
    echo json_encode([
        "statusCode" => 500,
        "body" => json_encode(["error" => $e->getMessage()])
    ]);
}
```

### PHASE 6️⃣ – INSTALL AWS SDK FOR PHP

```
curl -sS https://getcomposer.org/installer | php
php composer.phar require aws/aws-sdk-php
```

#### This creates:

```
vendor/
```

### PHASE 7️⃣ – PACKAGE LAMBDA

```
zip -r cafe-php-lambda.zip .
```

### PHASE 8️⃣ – UPLOAD TO LAMBDA


- Lambda → Code → Upload from → ZIP

### PHASE 9️⃣ – CONFIGURE LAMBDA SETTINGS

#### Environment variables

```
DB_SECRET = CafeRDSSecret
DB_HOST   = <RDS-ENDPOINT>
AWS_REGION = us-east-1
```

#### Timeout & Memory

- Timeout: 30 seconds

- Memory: 512 MB

### PHASE 🔟 – CONNECT API GATEWAY (SAME AS BEFORE)

- REST API

- POST /order

- Lambda integration

- Enable CORS

- Deploy

### PHASE 1️⃣1️⃣ – TEST

```
curl -X POST \
https://API-ID.execute-api.us-east-1.amazonaws.com/prod/order \
-H "Content-Type: application/json" \
-d '{"name":"Sara","item":"Latte","quantity":2}'
```

### ✅ SUCCESS CHECK

✔ Lambda logs in CloudWatch

✔ Secrets Manager accessed

✔ MySQL updated

✔ API Gateway responds

### ⚠️ COMMON PHP LAMBDA ERRORS

```
| Error         | Fix                   |
| ------------- | --------------------- |
| PHP not found | Build on Amazon Linux |
| 500 error     | Check CloudWatch logs |
| Timeout       | Increase memory       |
| DB fails      | VPC + SG issue        |
| Secrets fail  | IAM permission        |
```

### 🎓 REAL TALK (IMPORTANT)

#### PHP Lambda is:

✔ Great for learning

✔ Works in production

❌ Slower than Node/Python

❌ More complex to maintain

But now you understand Lambda internals, not just code.

---

## PHASE 9️⃣ – Add GET /orders API

### (API Gateway → PHP Lambda → RDS MySQL)

### 🧠 FINAL FLOW

```
Browser / curl
   ↓  GET /orders
API Gateway
   ↓
PHP Lambda (same function)
   ↓
RDS MySQL
```

### PHASE 1️⃣ – DATABASE CHECK (VERY IMPORTANT)

#### SSH into EC2 (or connect via MySQL client)

```
mysql -h <RDS-ENDPOINT> -u <user> -p
```

```
USE cafe_db;

SHOW TABLES;

SELECT * FROM orders;
```

#### You must already have:

```
orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  customer_name VARCHAR(100),
  item VARCHAR(50),
  quantity INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**✅ If this exists → continue**


### PHASE 2️⃣ – UPDATE PHP LAMBDA CODE

>**We will detect HTTP method inside Lambda.**

#### 🔧 Modify index.php

##### Replace your existing index.php with this FULL VERSION
###### (it supports POST /order AND GET /orders)

```
<?php
require 'vendor/autoload.php';

use Aws\SecretsManager\SecretsManagerClient;

$event = json_decode(stream_get_contents(STDIN), true);
$method = $event['requestContext']['http']['method'] ?? 'GET';

try {
    // Secrets Manager
    $sm = new SecretsManagerClient([
        'version' => 'latest',
        'region' => getenv('AWS_REGION')
    ]);

    $secret = $sm->getSecretValue([
        'SecretId' => getenv('DB_SECRET')
    ]);

    $creds = json_decode($secret['SecretString'], true);

    // DB connection
    $db = new mysqli(
        getenv('DB_HOST'),
        $creds['username'],
        $creds['password'],
        $creds['dbname']
    );

    if ($db->connect_error) {
        throw new Exception("DB connection failed");
    }

    /* =======================
       POST /order
       ======================= */
    if ($method === 'POST') {

        $body = json_decode($event['body'], true);

        $stmt = $db->prepare(
            "INSERT INTO orders (customer_name, item, quantity)
             VALUES (?, ?, ?)"
        );

        $stmt->bind_param(
            "ssi",
            $body['name'],
            $body['item'],
            $body['quantity']
        );

        $stmt->execute();

        echo json_encode([
            "statusCode" => 200,
            "headers" => [
                "Content-Type" => "application/json",
                "Access-Control-Allow-Origin" => "*"
            ],
            "body" => json_encode([
                "message" => "Order placed successfully"
            ])
        ]);
        exit;
    }

    /* =======================
       GET /orders
       ======================= */
    if ($method === 'GET') {

        $result = $db->query(
            "SELECT id, customer_name, item, quantity, created_at
             FROM orders
             ORDER BY created_at DESC"
        );

        $orders = [];

        while ($row = $result->fetch_assoc()) {
            $orders[] = $row;
        }

        echo json_encode([
            "statusCode" => 200,
            "headers" => [
                "Content-Type" => "application/json",
                "Access-Control-Allow-Origin" => "*"
            ],
            "body" => json_encode($orders)
        ]);
        exit;
    }

    // Unsupported method
    echo json_encode([
        "statusCode" => 405,
        "body" => json_encode(["error" => "Method not allowed"])
    ]);

} catch (Exception $e) {
    echo json_encode([
        "statusCode" => 500,
        "body" => json_encode(["error" => $e->getMessage()])
    ]);
}
```

### PHASE 3️⃣ – ZIP & UPLOAD AGAIN

#### From your build directory:

```
zip -r cafe-php-lambda.zip .
```

Upload ZIP → Lambda → Deploy

### PHASE 4️⃣ – API GATEWAY CONFIGURATION (NO SKIPS)

#### 1️⃣ Open API Gateway

- API type: HTTP API (recommended)

- Your existing API

#### 2️⃣ Create GET Route

```
Routes → Create
```

```
| Setting | Value   |
| ------- | ------- |
| Method  | GET     |
| Path    | /orders |
```

#### 3️⃣ Attach Integration

- Integration type: Lambda

- Lambda function: CafePHPOrderFunction

Save.

#### 4️⃣ Enable CORS (CRITICAL)

```
CORS → Edit
```

#### Enable:

```
Allow origins: *
Allow methods: GET, POST, OPTIONS
Allow headers: Content-Type
```

Save.

#### 5️⃣ Deploy

```
Deploy → Stage: prod
```

### PHASE 5️⃣ – TEST FROM CLI (EC2 or Local)

#### GET all orders

```
curl https://API-ID.execute-api.us-east-1.amazonaws.com/prod/orders
```

#### Expected response

```
[
  {
    "id": 5,
    "customer_name": "Sara",
    "item": "Latte",
    "quantity": 2,
    "created_at": "2025-12-27 15:22:10"
  }
]
```

### PHASE 6️⃣ – FRONTEND INTEGRATION (OPTIONAL)

Example JS fetch

```
<script>
fetch("https://API-ID.execute-api.us-east-1.amazonaws.com/prod/orders")
  .then(res => res.json())
  .then(data => console.log(data));
</script>
```

### PHASE 7️⃣ – CLOUDWATCH DEBUGGING

#### If something fails:

```
CloudWatch → Logs → /aws/lambda/CafePHPOrderFunction
```

##### Look for:

- DB connection errors

- Permission errors

- Timeout errors

### ✅ FINAL VERIFICATION CHECKLIST

✔ GET /orders returns JSON

✔ POST /order inserts row

✔ Secrets Manager used

✔ No EC2 dependency

✔ Fully serverless backend

### 🎓 WHAT YOU JUST LEARNED (IMPORTANT)

#### You now understand:

- Multi-method Lambda routing

- REST design

- PHP custom runtime

- Real-world API Gateway usage

**This is mid → senior cloud skill 💪**

---

## PHASE 🔟 – ☕ AWS Café Lab – CloudWatch Alarms (Complete Guide)

### 🧠 WHAT WE WILL MONITOR

```
| Component | Alarm                     |
| --------- | ------------------------- |
| ALB       | High 5XX errors           |
| ALB       | High target response time |
| Lambda    | Errors                    |
| Lambda    | Duration                  |
| RDS MySQL | CPU utilization           |
| RDS MySQL | Database connections      |
| SNS       | Email notifications       |
```

### PHASE 1️⃣ – CREATE SNS TOPIC (FOR ALERTS)

Alarms need a notification target.

#### Step 1: Open SNS

```
AWS Console → SNS → Topics → Create topic
```

```
| Setting      | Value       |
| ------------ | ----------- |
| Type         | Standard    |
| Name         | Cafe-Alerts |
| Display name | CafeAlerts  |
```

#### Step 2: Subscribe Email

```
SNS → Cafe-Alerts → Subscriptions → Create
```

```
| Setting  | Value                                                   |
| -------- | ------------------------------------------------------- |
| Protocol | Email                                                   |
| Endpoint | [your-email@example.com](mailto:your-email@example.com) |
```

#### 📩 Check your email and CONFIRM subscription

#### ⚠️ Alarm notifications won’t work until confirmed.

### PHASE 2️⃣ – ALB CLOUDWATCH ALARMS

### 🔔 Alarm 1: ALB 5XX Errors


```
CloudWatch → Alarms → Create alarm
```

#### Select Metric

```
ApplicationELB
→ LoadBalancer
→ HTTPCode_ELB_5XX_Count
```

Choose your ALB name

#### Conditions

```
| Setting    | Value      |
| ---------- | ---------- |
| Statistic  | Sum        |
| Period     | 1 minute   |
| Threshold  | ≥ 5        |
| Evaluation | 1 out of 1 |
```

#### Meaning:

> Alert if ALB returns 5 or more server errors in 1 minute

#### Notification

- Alarm state → In alarm

- SNS topic → Cafe-Alerts

Create alarm.

### 🔔 Alarm 2: ALB High Latency

#### Metric:

```
ApplicationELB → TargetResponseTime
```

```
| Setting   | Value       |
| --------- | ----------- |
| Statistic | Average     |
| Threshold | > 3 seconds |
| Period    | 1 minute    |
```

#### Meaning:

> Backend is slow or overloaded

Create alarm.


### PHASE 3️⃣ – LAMBDA CLOUDWATCH ALARMS

### 🔔 Alarm 3: Lambda Errors

```
CloudWatch → Alarms → Create alarm
```

#### Metric

```
Lambda → By Function Name → Errors
```

Choose your Lambda function.

#### Conditions

```
| Setting   | Value    |
| --------- | -------- |
| Statistic | Sum      |
| Period    | 1 minute |
| Threshold | ≥ 1      |
```

#### Meaning:

> Alert on any Lambda failure

#### Notification

- SNS → Cafe-Alerts

Create alarm.

### 🔔 Alarm 4: Lambda Duration

#### Metric:

```
Lambda → Duration
```

```
| Setting   | Value     |
| --------- | --------- |
| Statistic | Average   |
| Threshold | > 2000 ms |
```

#### Meaning:

> Lambda getting slow (DB, Secrets Manager, network issues)

Create alarm.

### PHASE 4️⃣ – RDS MYSQL CLOUDWATCH ALARMS

### 🔔 Alarm 5: RDS High CPU

#### Metric:

```
RDS → Per-DBInstance → CPUUtilization
```

```
| Setting   | Value     |
| --------- | --------- |
| Threshold | ≥ 70%     |
| Period    | 5 minutes |
```

#### Meaning:

> DB under heavy load

Create alarm.

### 🔔 Alarm 6: RDS Too Many Connections

#### Metric:

```
RDS → DatabaseConnections
```

```
| Setting   | Value     |
| --------- | --------- |
| Threshold | ≥ 80      |
| Period    | 5 minutes |
```

#### Meaning:

> App leaking DB connections

Create alarm.

### PHASE 5️⃣ – TEST ALARMS (VERY IMPORTANT)

#### 🔥 Trigger Lambda Error (Test)

##### Temporarily break DB name in Secrets Manager:

```
dbname: wrong_db
```

#### Call API:

```
curl https://API-ID.execute-api.us-east-1.amazonaws.com/prod/orders
```

✔ Lambda error occurs
✔ Alarm → In alarm
✔ Email received

👉 Fix secret afterward.

#### 🔥 Trigger ALB Error

##### Stop backend target temporarily:

```
Stop EC2 or Lambda integration
```

#### Send traffic.

✔ 5XX alarm fires

✔ Email received

### PHASE 6️⃣ – FINAL VERIFICATION CHECKLIST

✅ SNS email confirmed

✅ ALB error alarm

✅ ALB latency alarm

✅ Lambda error alarm

✅ Lambda duration alarm

✅ RDS CPU alarm

✅ RDS connections alarm


### 🎓 WHAT YOU JUST LEARNED

#### You now know:

✔ Production-grade monitoring

✔ How AWS teams detect outages

✔ How SREs design alerting

✔ End-to-end observability

**This is interview-level AWS knowledge 💼☁️**


---
## PHASE 🔟 – Testing & Verification

### Test via ALB DNS

#### Go to:

```
EC2 → Load Balancers → cafe-alb
```

Copy:

```
DNS name
```

Example:

```
http://cafe-alb-123456.us-east-1.elb.amazonaws.com
```

Paste into browser.

✅ EXPECTED RESULT

You should see:

```
☕ AWS Café
Place Your Order
```

❌ If it fails:

Check target group health

Check EC2 SG

Check Apache

### CLI VERIFICATION

#### On EC2:

```
curl http://localhost
```

#### From your laptop:

```
curl http://ALB-DNS-NAME
```

**✅ Both should return HTML.**

### API Test

```bash
curl -X POST API_URL/order -d '{"name":"Ali","item":"Coffee","quantity":1}'
```

### DB Verification

```sql
SELECT * FROM orders;
```

### Browser Test

* Open ALB DNS
* Place order
* Verify DB

---

## ✅ FINAL RESULT

✔ Static frontend

✔ Serverless backend

✔ Secure RDS

✔ Secrets Manager

✔ ALB

✔ Production-ready

## 🧠 COMMON ALB FAILURES

```
| Problem                     | Cause                   |
| --------------------------- | ----------------------- |
| 503 error                   | Target unhealthy        |
| Infinite loading            | Wrong subnets           |
| Works on EC2 IP but not ALB | SG misconfigured        |
| Health check fails          | index missing           |
| ALB created but no traffic  | Listener not forwarding |
```


---

## 🎯 Interview Talking Points

* Why ALB + API Gateway?
* Why private RDS?
* Why Secrets Manager?
* How scaling works?

---

☕ **You have now built a REAL AWS production system.**





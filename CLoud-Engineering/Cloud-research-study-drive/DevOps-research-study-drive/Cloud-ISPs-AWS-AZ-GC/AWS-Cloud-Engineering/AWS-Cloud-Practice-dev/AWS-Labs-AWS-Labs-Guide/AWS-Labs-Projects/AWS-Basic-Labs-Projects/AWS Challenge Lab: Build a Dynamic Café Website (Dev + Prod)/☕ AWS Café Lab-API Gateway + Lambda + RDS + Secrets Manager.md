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

![AWS Architecture Diagram]()

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

### Step 9: Connect from Bastion / EC2

```bash
mysql -h <RDS-ENDPOINT> -u cafe_user -p cafe_db
```

### Step 10: Create Table

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
| AWS_REGION | us-east-1      |
```

- Save.

#### LAMBDA CODE (BACKEND LOGIC)

```
const AWS = require('aws-sdk');
const mysql = require('mysql2/promise');

exports.handler = async (event) => {
  try {
    const body = JSON.parse(event.body);

    const sm = new AWS.SecretsManager({
      region: process.env.AWS_REGION
    });

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

    return {
      statusCode: 200,
      headers: {
        'Access-Control-Allow-Origin': '*'
      },
      body: JSON.stringify({ message: 'Order placed successfully' })
    };

  } catch (err) {
    console.error(err);
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








---
## PHASE 8️⃣ – Testing & Verification

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

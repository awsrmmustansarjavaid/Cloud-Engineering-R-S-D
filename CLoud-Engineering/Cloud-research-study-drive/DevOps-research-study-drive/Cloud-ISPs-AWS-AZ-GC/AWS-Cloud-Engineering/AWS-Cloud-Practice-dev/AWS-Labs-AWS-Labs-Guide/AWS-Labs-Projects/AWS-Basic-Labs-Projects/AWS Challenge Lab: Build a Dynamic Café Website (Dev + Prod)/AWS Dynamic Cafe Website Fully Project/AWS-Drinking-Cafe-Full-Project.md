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

# 📢 SECTION 1 CAFE BASIC CONFIGURATIONS



## PHASE 1 — NETWORK & COMPUTE (FOUNDATION)

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

#### ✅ EC2 USER DATA

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

---
## PHASE 2 — Development and Delopment LAMP Server 

### 1️⃣ Launch EC2 Instance (Amazon Linux 2023)

```
chmod 400 CafeDevKey.pem
ssh -i CafeDevKey.pem ec2-user@<PUBLIC-IP>
```

### 2️⃣ VERIFY LAMP + MySQL CLIENT (Amazon Linux 2023)

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

### 3️⃣ Frontend Development

### 1️⃣  ✅ Full Responsive Bootstrap Landing Page (index.php)

```
sudo nano /var/www/html/index.php
```
#### 💻 Paste this clean landing page code:



```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Charlie Cafe ☕ | Fresh Drinks & Coffee</title>

    <!-- Favicon -->
    <link rel="icon" href="https://upload.wikimedia.org/wikipedia/commons/4/45/A_small_cup_of_coffee.JPG">

    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Google Font -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">

    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background-color: #f8f9fa;
        }

        /* Navbar */
        .navbar {
            background-color: #3b1f0e;
        }

        .navbar-brand {
            font-weight: 600;
            color: #fff !important;
        }

        /* Hero Section */
        .hero {
            background: linear-gradient(rgba(0,0,0,0.6), rgba(0,0,0,0.6)),
                        url("https://images.unsplash.com/photo-1509042239860-f550ce710b93");
            background-size: cover;
            background-position: center;
            height: 90vh;
            display: flex;
            align-items: center;
            color: #fff;
        }

        /* Cards */
        .menu-card {
            border: none;
            border-radius: 18px;
            overflow: hidden;
            transition: transform 0.3s ease;
        }

        .menu-card:hover {
            transform: translateY(-10px);
        }

        .menu-card img {
            height: 230px;
            width: 100%;
            object-fit: cover;
        }

        /* Order Section with Background */
        .order-section {
            background: linear-gradient(rgba(0,0,0,.65), rgba(0,0,0,.65)),
                        url("https://images.unsplash.com/photo-1517248135467-4c7edcad34c4");
            background-size: cover;
            background-position: center;
            padding: 80px 20px;
            border-radius: 25px;
        }

        .order-box {
            color: #fff;
        }

        /* Buttons */
        .btn-order {
            background-color: #ff9800;
            color: #000;
            font-weight: 600;
            border-radius: 30px;
            padding: 12px 28px;
            transition: 0.3s;
        }

        .btn-order:hover {
            background-color: #e68900;
        }

        /* Footer */
        footer {
            background-color: #3b1f0e;
            color: #fff;
            padding: 15px 0;
        }
    </style>
</head>

<body>

<!-- Navbar -->
<nav class="navbar navbar-expand-lg navbar-dark">
    <div class="container">
        <a class="navbar-brand" href="#">☕ Charlie Cafe</a>
    </div>
</nav>

<!-- Hero -->
<section class="hero">
    <div class="container text-center">
        <h1 class="display-5 fw-bold">Fresh Drinks & Perfect Coffee</h1>
        <p class="lead">Coffee • Tea • Fresh Fruit Juices</p>
        <a href="orders.php" class="btn btn-order mt-3">Order Now</a>
    </div>
</section>

<!-- Menu Section -->
<section class="container py-5">
    <h2 class="text-center fw-bold mb-5">Our Special Menu</h2>

    <div class="row g-4">

        <!-- Coffee -->
        <div class="col-md-4">
            <div class="card menu-card shadow">
                <img src="https://images.unsplash.com/photo-1511920170033-f8396924c348" alt="Coffee">
                <div class="card-body text-center">
                    <h5>Coffee</h5>
                    <p>Espresso, Cappuccino, Latte, Americano</p>
                </div>
            </div>
        </div>

        <!-- Tea -->
        <div class="col-md-4">
            <div class="card menu-card shadow">
                <img src="https://images.unsplash.com/photo-1544787219-7f47ccb76574" alt="Tea">
                <div class="card-body text-center">
                    <h5>Tea</h5>
                    <p>Green Tea, Black Tea, Masala Chai</p>
                </div>
            </div>
        </div>

        <!-- Fresh Juice -->
        <div class="col-md-4">
            <div class="card menu-card shadow">
                <img
                    src="https://images.unsplash.com/photo-1600271886742-f049cd451bba?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
                    alt="Fresh Juice"
                    referrerpolicy="no-referrer"
                    loading="lazy">
                <div class="card-body text-center">
                    <h5>Fresh Juice</h5>
                    <p>Orange, Mango, Apple, Mixed Fruits</p>
                </div>
            </div>
        </div>

    </div>
</section>

<!-- Order Section with Background -->
<section class="container my-5">
    <div class="order-section text-center">
        <div class="order-box">
            <h2 class="fw-bold">Order Your Favorite Drink ☕🥤</h2>
            <p class="mt-3">Fast • Fresh • Delicious</p>
            <a href="orders.php" class="btn btn-order mt-4">Go to Order Page</a>
        </div>
    </div>
</section>

<!-- Footer -->
<footer class="text-center">
    <p class="mb-0">© 2026 Charlie Cafe | Fresh Drinks Everyday</p>
</footer>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
```

**⚠️ Replace S3_IMAGE_URL_HERE later (next phase)**


### 4️⃣ Upload Images to S3 


### 1️⃣ Create S3 Bucket

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

#### ✅ Bucket created

#### 📣 Disable “Block Public Access”

✔️ Uncheck all

✔️ Acknowledge

### 5️⃣ Upload Images to S3 

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

### 6️⃣ Link S3 Images to index.php

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

### 6️⃣ 🧪 VERIFICATION 2 (MANDATORY)

#### 1️⃣ Test Landing Page

```
http://<EC2_PUBLIC_IP>/
```

#### ☑️ Confirm:

✔️ Logo visible

✔️ “Charlie Cafe” title visible

✔️ Hero image loads from S3

✔️ “Order Now” button works






---

# 📢 SECTION 2 — AWSCafeOrderProcessor


[AMAZON RDS (Replace EC2 MariaDB)](./AWS%20Cafe%20Project%20Development%20%26%20Depolyment%20Docs/AWSCafeOrderProcessor.md)

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

# 📢 SECTION 5 — AWS CAFE SQS (Async Order Processing)



[AWS CAFE SQS (Async Order Processing)](./AWS%20Cafe%20Project%20Development%20%26%20Depolyment%20Docs/AWS%20CAFE%20SQS%20(Async%20Order%20Processing).md)



---
# 📢 SECTION 6 — ORDER STATUS DASHBOARD

[AWS CAFE ORDER STATUS DASHBOARD](./AWS%20Cafe%20Project%20Development%20%26%20Depolyment%20Docs/AWSCafeORDERSTATUSDASHBOARD.md)





---
# 📢 SECTION 7 — AWS CAFE SECURITY


[AWS CAFE SECURITY](./AWS%20Cafe%20Project%20Development%20%26%20Depolyment%20Docs/AWSCAFESECURITY.md)


---

# 📢 SECTION 8 — AWS CAFE CI/CD (CodePipeline)

[AWS CAFE CI/CD (CodePipeline)](./AWS%20Cafe%20Project%20Development%20%26%20Depolyment%20Docs/AWSCafeCICD(CodePipeline).md)



---

# 📢 SECTION 9 — TESTING

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

# 📢 SECTION 10 — AMAZON COGNITO (AUTHENTICATION)

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

# 📢 SECTION 11 — CLOUDFRONT + CACHING

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

# 📢 SECTION 12 — COST OPTIMIZATION

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





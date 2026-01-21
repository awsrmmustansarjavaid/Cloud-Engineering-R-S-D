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









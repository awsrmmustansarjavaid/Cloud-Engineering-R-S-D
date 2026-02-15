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
## 📢 SECTION 1️⃣ CAFE BASIC CONFIGURATIONS

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


#### ✅ 2.2 Open Security Group (MANDATORY)

Ensure EC2 Security Group allows:


| Type | Port | Source    |
| ---- | ---- | --------- |
| HTTP | 80   | 0.0.0.0/0 |


### 5️⃣ IAM Role & Policies

### 1️⃣ IAM Role for EC2 (Secrets Access)

- **IAM Role Name:**

```
EC2-Cafe-Secrets-Role
```

- **IAM Role for EC2 (Secrets Access) Policies**

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

- **IAM Role for EC2 (Secrets Access) Policies**

- name: Lambda_test_EC2-CLI 

```json
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": "lambda:InvokeFunction",
			"Resource": "arn:aws:lambda:us-east-1:your aws account id :function:*"
		}
	]
}
```
 or 
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "FullLambdaAccessForTesting",
      "Effect": "Allow",
      "Action": [
        "lambda:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DynamoDBFull",
      "Effect": "Allow",
      "Action": "dynamodb:*",
      "Resource": "*"
    },
    {
      "Sid": "SQSFull",
      "Effect": "Allow",
      "Action": "sqs:*",
      "Resource": "*"
    },
    {
      "Sid": "S3FullForTesting",
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
    },
    {
      "Sid": "SecretsManagerFull",
      "Effect": "Allow",
      "Action": [
        "secretsmanager:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "RDSManagementAndConnect",
      "Effect": "Allow",
      "Action": [
        "rds:*",
        "rds-data:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "APIGatewayManagement",
      "Effect": "Allow",
      "Action": "apigateway:*",
      "Resource": "*"
    },
    {
      "Sid": "CloudWatchLogsAndMetrics",
      "Effect": "Allow",
      "Action": [
        "logs:*",
        "cloudwatch:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "ALBFullAccess",
      "Effect": "Allow",
      "Action": "elasticloadbalancing:*",
      "Resource": "*"
    },
    {
      "Sid": "CloudFrontFull",
      "Effect": "Allow",
      "Action": "cloudfront:*",
      "Resource": "*"
    }
  ]
}
```

**⚠️ Attach role to EC2 (NO reboot).**

- **✔️ Click Create IAM ROLE**

### 2️⃣ IAM Role for Charlie Cafe

- **IAM Role Name:**

```
charlie-cafe-iam-Role
```

- **Description:**

```
Allow Lambda to read menu items from DynamoDB
```

- **IAM Role for Charlie Cafe Policies**

#### 1️⃣ IAM Policies Method -1 ✅ Mega Custom IAM Policy

**👉 Paste into IAM → Policies → Create policy → JSON**

- Policy Name: charlie-cafe-iam-policy

- Region: us-east-1

- Account: Your AWS_Account_ID

#### This policy includes:

#### 1️⃣ AWS Managed Policies (permissions merged)

- AmazonDynamoDBFullAccess

- AmazonDynamoDBFullAccess_v2 (same permissions, safely merged once)

- AWSLambdaBasicExecutionRole

- AWSLambdaVPCAccessExecutionRole

- AmazonRDSDataFullAccess

- CloudWatchLogsFullAccess

#### 2️⃣ Custom Policies (ALL merged)

- AWSLambdaBasicExecution (custom logs scope)

- CafeMenuDynamoDBReadPolicy

- CafeOrderWorkerPermissions

- CafeSecretsManagerAccess

- CafeSecretsManagerReadOnly

- CashPaymentLambda

- LambdaCafeSecretsAccess

- S3AppBucketAccessPolicy

- SendOrderToSQS

#### COPY-PASTE READY POLICY JSON

You can paste this directly into IAM → Policies → Create policy → JSON

[charlie-cafe-iam-policy](./☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20AWS%20IAM%20Policy%20JSON%20Script/charlie-cafe-iam-policy.md)

**⚠️ JUST Replace "Your AWS ACCOUNT ID " with your own account ID**

#### ✅ WHY THIS POLICY IS SAFE & CORRECT

✔ No duplicate invalid statements

✔ No conflicting ARNs

✔ Correct AWS service actions

✔ Passes IAM JSON validation

✔ Works for Lambda + DynamoDB + RDS + SQS + S3 + Secrets Manager

✔ Can be attached to Lambda execution roles

#### 2️⃣ IAM Policies Method - 2 1-2-1 Each Single IAM Policies

#### 1️⃣ Create IAM Policy for  PRODUCER LAMBDA
> **Your API Lambda must be allowed to send messages.**

- **Custom Policy name:** 

```
SendOrderToSQS
```

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

**✔️ Click Create policy**

#### 2️⃣ Create IAM Policy for DynamoDB Access
> **Now Lambda needs permission to read from DynamoDB.**

- **Custom Policy name:** 

```        
CafeMenuDynamoDBReadPolicy
```

#### JSON

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
**✔️ Click Create policy**

#### 3️⃣ Create IAM Policy FOR WORKER LAMBDA
> **Your worker needs 3 permissions**

**AWS IAM Policies:**

```
AmazonDynamoDBFullAccess
AWSSecretsManagerReadOnly
AmazonSQSFullAccess
```

- **Custom Policy name:** 

```
CafeOrderWorkerPermissions
```

#### Add inline policy with:
> **Attach These Permissions**

#### JSON

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

**✔️ Click Create policy**

#### 4️⃣ Create IAM Policy FOR DYNAMODB METRICS TABLE (FULL)

- **Custom Policy name:** 

```
CafeSecretsManagerReadOnly
```

- **Description:**

```
Read-only access to Secrets Manager for Lambda
```

#### Add inline policy with:
> **Attach These Permissions**

#### JSON

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": "*"
    }
  ]
}
```

#### ✅ This allows:

- Read secret value

- Describe secret

- ❌ No delete

- ❌ No update


**✔️ Click Create policy**

#### 5️⃣ Create IAM Policy FOR DYNAMODB METRICS TABLE (FULL)
> **RDS access (same as Worker)**

**AWS IAM Policies:**

```
AmazonDynamoDBReadOnlyAccess
```

**✔️ Click Create policy**

#### 6️⃣ Create IAM Policy FOR CafeAnalyticsLambda

**AWS IAM Policies:**

```
AmazonDynamoDBReadOnlyAccess
CloudWatchLogsFullAccess
```

✅ Without this → Lambda fails silently

✅ With this → Lambda can read DynamoDB + write logs

**✔️ Click Create policy**

#### 7️⃣ Create IAM Policy FOR CashPaymentLambda & AdminMarkPaidLambda
> **⚠️ If this is missing → Lambda WILL FAIL.**

- **Custom Policy name:** 

```
CashPaymentLambda
```

Attach this policy (or ensure it exists):

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:Query",
        "dynamodb:Scan"
      ],
      "Resource": "arn:aws:dynamodb:us-east-1:aaaaaa55564333:table/CafeOrders"
    }
  ]
}
```

**✔️ Click Create policy**

#### 8️⃣ Create IAM Policy FOR HR System
> **If you already have a Lambda role that accesses RDS + CloudWatch, reuse it. If not, follow every step below.**

- Trusted entity type: AWS service

- Service: Lambda

- Click Next

#### Step 3️⃣: Attach Permissions

- Attach exactly these policies:

    - AWSLambdaBasicExecutionRole

    - AmazonRDSDataFullAccess (or your custom RDS policy)

- Click Next

**✔️ Click Create policy**

#### 9️⃣ Create IAM Policy  HR ATTENDANCE DASHBOARD

- Lambda role permissions:

  - AmazonDynamoDBFullAccess

  - CloudWatchLogsFullAccess

#### 🔟 Create IAM Policy Cognito Authorizer

- **Custom Policy name:** 

```
Cognito-Authorizer-IAM
```

Attach this policy (or ensure it exists):

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
```
**✔️ Click Create policy**

- **✔️ Click Create IAM ROLE**

### 3️⃣ IAM Role for Router Lambda

- **IAM Role Name:**

```
charlie-cafe-RouterLambda
```

- **Description:**

```
Allow Lambda invoke permissions for other Lambdas.
```

#### 1️⃣ Create IAM Policy Cognito Authorizer

- **Custom Policy name:** 

```
OrderStatusRouterLambda
```

Attach this policy (or ensure it exists):

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "lambda:InvokeFunction",
            "Resource": [
                "arn:aws:lambda:us-east-1:123456789012:function:GetOrderStatusLambda",
                "arn:aws:lambda:us-east-1:123456789012:function:CafeOrderStatusLambda",
                "arn:aws:lambda:us-east-1:123456789012:function:OrderStatusLambda"
            ]
        }
    ]
}
```
**Replace ARN with  Your Lambda Functions**

**✔️ Click Create policy**

### 6️⃣ EC2 Instance (Amazon Linux 2023)

 * EC2 Name : 
``` 
CafeDevWebServer
```

* AMI: Amazon Linux 2023
* Type: `t2.micro`
* VPC/Subnet: Dev VPC + Public subnet
* Security Group:

  * SSH (22) → Your IP
  * HTTP (80) → 0.0.0.0/0*

### 7️⃣ EC2 USER DATA

### 1️⃣ LAMP Server USER DATA
> **📍 File Location: AWS-LAMP Server-Bash-Script.md**

[AWS-LAMP Server Bash-Script](./☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/☕%20AWS%20CAFE%20—%20EC2%20Lamp%20Server%20Script.sh)

### 2️⃣ Charile Cafe Mega USER DATA
> **📍 File Location: charlie-cafe-mega-setup.sh**

[Charile Cafe Mega Bash-Script](./☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/Charile%20Cafe%20Mega%20Bash-Script/charlie-cafe-mega-setup.sh)


**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---

### ☕ AWS Charlie Café – Test & Verifications

[☕ Charlie CAFE BASIC CONFIGURATIONS](./☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20(Doc)/☕%20AWS%20CAFE%20—%20%20Test%20%26%20Verifications/☕%20Charlie%20CAFE%20BASIC%20CONFIGURATIONS.md)

---
## PHASE 2️⃣ — Development and Delopment LAMP Server 

### 1️⃣ Launch EC2 Instance (Amazon Linux 2023)

```
chmod 400 CafeDevKey.pem
ssh -i CafeDevKey.pem ec2-user@<PUBLIC-IP>
```

### 2️⃣ VERIFY EC2 User Data

#### 1️⃣ VERIFY LAMP + MySQL CLIENT (Amazon Linux 2023)

```
sudo nano lamp-verify.sh
```

[VERIFY LAMP + MySQL CLIENT](./☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/lamp-verify.sh)

```
sudo chmod +x lamp-verify.sh
```

```
sudo ./lamp-verify.sh
```

#### 2️⃣ ✅ CHARLIE CAFE — VERIFICATION BASH SCRIPT

```
sudo nano charlie-cafe-verify.sh
```

[CHARLIE CAFE — VERIFICATION BASH SCRIPT](./☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/Charile%20Cafe%20Mega%20Bash-Script/charlie-cafe-verify.sh)

```
sudo chmod +x charlie-cafe-verify.sh
```

```
sudo ./charlie-cafe-verify.sh
```

**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**

## 📢 SECTION 1️⃣ CAFE BASIC CONFIGURATIONS COMPLETE ✅
---

## 📢 SECTION 2️⃣ CAFE DATABASE CONFIGURATIONS

## PHASE 1️⃣ — Basic RDS CONFIGURATIONS

### 1️⃣ Create DB Subnet Group
AWS Console → RDS → Subnet groups → Create

- Name: CafeRDSSubnetGroup

- VPC: CafeDevVPC

- Subnets: **PRIVATE subnets (2 AZs)**

- **✔️ Create**

### 2️⃣ Create Security Group for RDS
VPC → Security Groups → Create

- Name: CafeRDS-SG

- Inbound:
  - MySQL/Aurora (3306) → Source: Lambda-SG
  - MySQL/Aurora (3306) → Source: EC2-Web-SG
- Outbound: All

- **✔️ Create**

### 3️⃣ Create RDS Instance

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

**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---
## PHASE 2️⃣ — Basic RDS Schema CONFIGURATIONS

### 1️⃣ Create Schema in RDS

- **✔️ Connect from EC2:**

### 2️⃣ — Basic RDS CONFIGURATIONS

#### 1️⃣ Install & Login MySQL Client

```
sudo dnf install -y mariadb105
```

##### Verify mysql

```
mysql --version
```

##### Login to MariaDB:

```
mysql -h <rds-endpoint> -u cafe_user -p
```

or

#### 🛠️ BASH SCRIPT (Safe RDS Connection)
> **📄 connect-rds.sh**


```
sudo nano connect-rds.sh
```

[RDS Credentials to Secrets Manager ](./☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/connect-rds.sh)

#### ▶️ How to Run

```
sudo chmod +x connect-rds.sh
```

```
sudo ./connect-rds.sh
```

---

### 2️⃣ cafe_db

### ✅ Charlie Cafe – Order Processing & HR Schema Setup + Verification

> **File name: setup_charlie_cafe_db_full.sh**

✔️ Pulls DB creds from AWS Secrets Manager

✔️ Connects to RDS MySQL

✔️ Creates database

✔️ Creates orders + HR tables

✔️ Adds indexes

✔️ Inserts test data

✔️ Is idempotent (safe to re-run)

✔️ Ends with clear verification output

```
sudo nano setup_charlie_cafe_db_full.sh
```

[Order Processing & HR Schema Setup + Verification ](./☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/setup_charlie_cafe_db_full.sh)

#### ▶️ How to Run

```
sudo chmod +x setup_charlie_cafe_db_full.sh
```

```
sudo ./setup_charlie_cafe_db_full.sh
```


#### 1️⃣ Create Café Database

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

#### 2️⃣ Use the correct database

```
USE cafe_db;
```

#### 3️⃣ Orders Table

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

### 7️⃣ Verify:

```
DESCRIBE orders;
```

```
SELECT * FROM orders;
```

###### ✅ If you see the row → DB is READY

#### Exit MySQL:

```
EXIT;
```

**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**
---
## PHASE 3️⃣ — Store DB Credentials in Secrets Manager

### 1️⃣ Store DB Credentials in Secrets Manager

- Go to Secrets Manager → Store a new secret

- Type: Other type of secret → Key/Value

- Secret name:

```
CafeDevDBSM
```

| Key      | Value              |
|----------|--------------------|
| username | cafe_user          |
| password | StrongPassword123  |
| host     | RDS endpoint       |
| dbname   | cafe_db            |

- Retrieve Secret ARN for later use in the app

**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**

# 📢 SECTION 2️⃣ CAFE DATABASE CONFIGURATIONS COMPLETE ✅
---
# 📢 SECTION 3️⃣ CAFE File Sharing 

## PHASE 1️⃣ — S3 Bucket

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

**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---
## PHASE 2️⃣ — S3 Bucket


**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**

## 📢 SECTION 3️⃣ CAFE DATABASE CONFIGURATIONS COMPLETE ✅
---
## 📢 SECTION 4️⃣ CAFE FRONTEND CONFIGURATIONS

## ☕ AWS CAFE - PHASE 1️⃣ FRONTEND central FOUNDATION (REUSABLE)

### 1️⃣ Create config.js (NO LOGIC HERE)
> **This file will be reused across all pages.**

This replaces hardcoded config from your old file.

- 📍 Place this in /js/config.js

#### 1️⃣ Command to create the js directory

```
sudo mkdir -p /var/www/html/js
```

#### 2️⃣ Command to create the .js file

```
sudo nano /var/www/html/js/config.js
```

#### 3️⃣ Copy & Paste Script

[config.js](./☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/config.js)



### 2️⃣ Create utils.js (Shared Helpers)

Move all generic helpers here.

[utils.js](./☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/utils.js)



### 3️⃣ Create central-auth.js (COGNITO ONLY)

This file contains ONLY authentication logic.

No API routes inside.

[central-auth.js](./☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/central-auth.js)



### 4️⃣ Create api.js (PUBLIC + PROTECTED FETCH)

This file handles API logic only.

[api.js](./☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/api.js)

### 5️⃣ Create central-printing.js

[central-printing.js](./☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/central-printing.js)


#### ⚠️ Use * to apply it to all files (all extensions) in the directory:

### 6️⃣ Fix File Permissions

```
sudo chown apache:apache /var/www/html/js/*
```
```
sudo chmod 644 /var/www/html/js/*
```

---

### 2️⃣ Create the shared Central-cafe-style (IMPORTANT)

#### 1️⃣ Command to create the css directory

```
sudo mkdir -p /var/www/html/css
```

#### 2️⃣ Create Central-cafe-style

```
sudo nano /var/www/html/css/central_cafe_style.css
```

#### 3️⃣ Copy & Paste CSS

[central_cafe_style.css](./☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Central%20Style%20Css/central_cafe_style.css)

#### 3️⃣ Fix File Permissions

```
sudo chown apache:apache /var/www/html/css/*
```
```
sudo chmod 644 /var/www/html/css/*
```

**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---
## ☕ AWS CAFE - PHASE 2️⃣ FrontEnd Web Pages

### 1️⃣ Charlie Cafe - index.php (IMPORTANT)
> **File Name: index.php**

#### 1️⃣ Create index.php

```
sudo nano /var/www/html/index.php
```

#### 2️⃣ Paste this clean landing page code:

[index.php](.//☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-Index.php/Index.php)

**⚠️ Replace S3_IMAGE_URL_HERE later (next phase)**

#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```

---

### 2️⃣ Charlie Cafe Admin Dashboard Page (IMPORTANT)
> **File Name: cafe-admin-dashboard.html**

### 1️⃣ Create index.php

```
sudo nano /var/www/html/cafe-admin-dashboard.html
```

### 2️⃣ Paste this clean landing page code:

[cafe-admin-dashboard.html](./☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe-%20Admin%20Dashboard%20(Order%2BHR)/cafe-admin-dashboard.html)

#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```

---
### 3️⃣ Charlie Cafe orders.php (IMPORTANT)
> **File Name: orders.php**

###  Modify orders.php (Automation)

* Remove direct DB insert
* Send POST JSON to API Gateway

#### 🌐 Configuration for Insert Data in EC2 MariaDB server / RDS DB ( Recommanded)

#### 1️⃣ Create orders.php

```
sudo nano /var/www/html/orders.php
```
#### 2️⃣ MODERN CAFE-STYLE orders.php (Frontend Only Modified)

[orders.php](./☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order.php/orders.php)

#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```

---
### 4️⃣ Charlie Cafe order-status.html  (IMPORTANT)
> **File Name: order-status.html**

#### 1️⃣ Create File

```
sudo nano /var/www/html/order-status.html
```

#### 2️⃣ CODE

#### 🚨 IMPORTANT:

#### Replace this line ONLY:

```
fetch("https://API_ID.execute-api.region.amazonaws.com/prod/order-status")
```

#### With your real API:

```
fetch("https://abcd1234.execute-api.us-east-1.amazonaws.com/admin/order-status")
```

[order-status.html](./☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order-status/CC%20-%20Order-Status_LIVE%20ADMIN%20DASHBOARD_many%20orders/order-status.html)

#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```
---
### 5️⃣ Charlie Cafe order-status.php  (IMPORTANT)
> **File Name: order-status.php**

#### ☕ FINAL order-receipt.php with print button (CAFE STYLED - Recommanded)

#### 1️⃣ Create File

```
sudo nano /var/www/html/order-receipt.php
```

#### 2️⃣ code

[order-receipt.php](./☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order-status/CC%20-%20Order-Status%20CUSTOMER%20ORDER%20RECEIPT_single%20order/order-receipt.php)

#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```

---

### 6️⃣ Charlie Cafe admin-orders.php  (IMPORTANT)
> **File Name: admin-orders.php**

#### 1️⃣ Create File

```
sudo nano /var/www/html/admin-orders.php
```

#### 2️⃣ code

[admin-orders.php](./☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/admin-orders.php/admin-orders.php)

#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```

---
### 7️⃣ Charlie Cafe payment-status.php  (IMPORTANT)
> **File Name: payment-status.php**

#### 1️⃣ Create File

```
sudo nano /var/www/html/payment-status.php
```

#### 2️⃣ code

[payment-status.php](./☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/payment-status.php/payment-status.php)

#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```

---
### 8️⃣ Charlie Cafe Dedicated Printing HTML  (IMPORTANT)
> **File Name: central-print.html**

#### 1️⃣ Create File

```
sudo nano /var/www/html/central-print.html
```

#### 2️⃣ code

[central-print.html](./☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Printing%20System/central-print.html)

#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```
---
### 9️⃣ Charlie Cafe analytics.html  (IMPORTANT)
> **File Name: analytics.html**

#### 1️⃣ Create File

```
sudo nano /var/www/html/analytics.html
```

#### 2️⃣ code

[analytics.html](./☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-%20Sales%20Analytics/analytics.html)

#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```
### 🔟 login.html

#### 1️⃣ Create File

```
sudo nano /var/www/html/login.html
```

#### 2️⃣ code

[login.html](./☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Cognito%20Hosted%20UI/login.html)

#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```

### 1️⃣1️⃣ price-list.html


#### 1️⃣ Create File

```
sudo nano /var/www/html/price-list.html
```

#### 2️⃣ code

[price-list.html](./☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order.php/price-list.html)

#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```

### 1️⃣2️⃣ logout.php


#### 1️⃣ Create File

```
sudo nano /var/www/html/logout.php
```

#### 2️⃣ code

[logout.php](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Cognito%20Hosted%20UI/logout.php)

#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```

**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**
---
## ☕ AWS CAFE - PHASE 3️⃣ FrontEnd Deployment Final Configurations

### 1️⃣ SECURITY & PERMISSIONS

```
sudo nano apache_permissions.sh
```

```
#!/bin/bash

# ---------------------------------------------
# Charlie Cafe - Set Permissions Script
# ---------------------------------------------

# List of files
FILES=(
"/var/www/html/index.php"
"/var/www/html/cafe-admin-dashboard.html"
"/var/www/html/orders.php"
"/var/www/html/order-status.html"
"/var/www/html/order-receipt.php"
"/var/www/html/admin-orders.php"
"/var/www/html/payment-status.php"
"/var/www/html/central-print.html"
"/var/www/html/analytics.html"
"/var/www/html/login.html"
"/var/www/html/logout.php"
"/var/www/html/price-list.html"
"/var/www/html/js/central-auth-api.js"
"/var/www/html/css/central_cafe_style.css"
)

# List of directories
DIRS=(
"/var/www/html/js"
"/var/www/html/css"
)

echo "---------------------------------------------"
echo "Setting ownership to apache:apache..."
sudo chown apache:apache "${FILES[@]}"
sudo chown -R apache:apache "${DIRS[@]}"

echo "---------------------------------------------"
echo "Setting directory permissions to 755..."
for dir in "${DIRS[@]}"; do
    sudo chmod 755 "$dir"
done

echo "---------------------------------------------"
echo "Setting file permissions to 644..."
for file in "${FILES[@]}"; do
    sudo chmod 644 "$file"
done

echo "---------------------------------------------"
echo "Verifying permissions..."
for file in "${FILES[@]}"; do
    perms=$(ls -l "$file" | awk '{print $1}')
    owner=$(ls -l "$file" | awk '{print $3":"$4}')
    echo "$file : $owner : $perms"
done

for dir in "${DIRS[@]}"; do
    perms=$(ls -ld "$dir" | awk '{print $1}')
    owner=$(ls -ld "$dir" | awk '{print $3":"$4}')
    echo "$dir : $owner : $perms"
done

echo "---------------------------------------------"
echo "All permissions set and verified!"
```

```
sudo chmod +x apache_permissions.sh
```

```
sudo ./apache_permissions.sh
```

### 2️⃣ ALLOW /var/www/html/js IN APACHE

Open Apache main config:

```
sudo nano /etc/httpd/conf/httpd.conf
```

Find this block (or similar):

```
<Directory "/var/www/html">
    AllowOverride None
    Require all denied
</Directory>
```

🔥 CHANGE IT TO:

```
<Directory "/var/www/html">
    AllowOverride All
    Require all granted
</Directory>
```

### 3️⃣ EXPLICITLY ALLOW JS DIRECTORY (BEST PRACTICE)

Add this at the bottom of the file:

```
<Directory "/var/www/html/js">
    Require all granted
</Directory>
```

### 4️⃣ SET PROPER MIME TYPE FOR JS

Still in the same file, add (or ensure exists):

```
AddType application/javascript .js
```

### 5️⃣ Restart Apache (MANDATORY)

```
sudo systemctl restart httpd
```

**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---
## 🔐 PHASE 4️⃣ — Set Up Automatic HTTP → HTTPS Redirection

> **✅ EASY & CORRECT METHOD (RECOMMENDED FOR LAB)**

### 1️⃣  — HTTPS REQUIREMENT (CRITICAL)

**⚠️ Cognito does NOT allow HTTP except localhost.**

So we must add HTTPS.

You have TWO EASY OPTIONS

### 1️⃣  — USE ALB

> **This is the simplest HTTPS solution.**

### STEP 1️⃣ — CREATE APPLICATION LOAD BALANCER

```
EC2 → Load Balancers → Create Load Balancer
```

#### Choose:

```
Application Load Balancer
```

### STEP 2️⃣ — BASIC ALB Configuration


| Setting                  | Value / Selection                                      | Notes / Requirement                          |
|--------------------------|--------------------------------------------------------|----------------------------------------------|
| **Name**                 | charlie-cafe-alb                                       | Unique name for your ALB                     |
| **Scheme**               | Internet-facing                                        | Allows public internet access                |
| **IP address type**      | IPv4                                                   | Standard for most setups                     |
| **VPC**                  | Same VPC as your EC2 instance                          | Must match EC2 placement                     |
| **Subnets**              | Select at least 2 **public** subnets                   | Required for internet-facing ALB; choose different Availability Zones if possible |
| **Availability Zones**   | At least 2 AZs (where public subnets exist)            | Improves high availability                   |


### STEP 3️⃣ — SECURITY GROUP

#### Allow:

```
HTTPS 443  0.0.0.0/0
```

### STEP 4️⃣ — Target Group Configuration (for EC2 registration)


| Setting                  | Value / Selection                          | Notes / Requirement                                      |
|--------------------------|--------------------------------------------|----------------------------------------------------------|
| **Type**                 | Instance                                   | Standard for registering EC2 instances by ID             |
| **Protocol**             | HTTP                                       | Matches your web server on EC2 (use HTTPS only if EC2 already has SSL) |
| **Port**                 | 80                                         | Default HTTP port your web server listens on             |
| **Target registration**  | Register your EC2 instance                 | Select your EC2 instance by name/ID (not IP)             |
| **Health check path**    | / (or /cafe-admin-dashboard.html)                  | Path ALB uses to check if instance is healthy            |

### STEP 5️⃣ — Add Listener to ALB 

#### - Add HTTP listener 

- **Listener:** HTTP 80

- **Target Group:** Select Your Target Group

#### - Add HTTPS listener (Optional)


| Setting                  | Value / Selection                                      | Notes / Requirement                                                                 |
|--------------------------|--------------------------------------------------------|-------------------------------------------------------------------------------------|
| **Listener**             | HTTPS : 443                                            | Standard secure port for HTTPS traffic                                              |
| **Certificate**          | Request or select from ACM (AWS Certificate Manager)   | Must use a valid SSL/TLS certificate; free public certs available via ACM           |
| **Certificate source**   | ACM                                                    | Recommended – free, auto-renewing certificates                                      |
| **Domain name (for ACM request)** | Your domain (e.g., charliecafe.com, *.charliecafe.com) | Required to request certificate; can be:<br>• Real domain you own<br>• Wildcard (*.example.com)<br>• Multiple SANs (Subject Alternative Names) |
| **Validation method**    | DNS validation (preferred) or Email                    | DNS is faster & automatic if using Route 53                                         |
| **Default action**       | Forward to target group (e.g., cafe-target-group)      | Routes HTTPS traffic to your EC2 instance(s)                                        |
| **HTTP → HTTPS redirect** | Add separate HTTP:80 listener with redirect rule       | Recommended: Redirect all HTTP traffic to HTTPS                                     |

### STEP 6️⃣ — GET ALB DNS NAME

Example:

```
https://charlie-cafe-alb-123.us-east-1.elb.amazonaws.com
```

### 2️⃣ — CLOUD FRONT

### 🧱 STEP 1️⃣ — CloudFront Origin (ALB)

#### Go to:

```
AWS Console → CloudFront → Create Distribution
```

- **Distribution name:** Charlie-Cafe

- **Next:**

- **Origin type:** Elastic Load Balancer

#### CloudFront Origin Settings (CRITICAL)

>**Go to:** CloudFront → Distributions → Your Distribution → Origins → Edit

> **Set EXACTLY like this:**

| Setting                | Value                                                   |
| ---------------------- | ------------------------------------------------------- |
| Origin domain          | charlie-cafe-alb-1050813156.us-east-1.elb.amazonaws.com |
| Origin protocol policy | **HTTP only** ✅                                         |
| HTTP port              | 80                                                      |
| Origin SSL protocols   | (doesn’t matter now)                                    |


✅ This is correct

❌ Do NOT select EC2 IP

❌ Do NOT select S3

### 🌐 STEP 2️⃣ — Default Cache Behavior (VERY IMPORTANT)

>**Go to:** Behaviors → Default → Edit


| Setting                | Value                  |
| ---------------------- | ---------------------- |
| Viewer protocol policy | Redirect HTTP to HTTPS |
| Allowed HTTP methods   | GET, HEAD, OPTIONS     |
| Cache policy           | CachingDisabled        |
| Origin request policy  | AllViewer              |


⚠️ Cognito tokens must NOT be cached

#### This ensures:

Authorization headers

Query strings

Cookies
are forwarded correctly.

👉 SAVE

⏳ Wait 5–10 minutes for deployment.

```
Status = Deployed
```

#### You’ll get:

```
xxxxx.cloudfront.net
```

### 🔐 STEP 3️⃣ — CloudFront General Configuration

> **This step finalizes the CloudFront distribution behavior and ensures it works correctly with ALB + Cognito Hosted UI without breaking authentication or routing.**

### 1️⃣ ⚙️ General Configuration

- **Configure the following settings in CloudFront → Distribution → General.**

#### 1️⃣ IPv6

- **Turn OFF IPv6**

✅ Recommended for learning & labs

🔁 Can be enabled later in production

### 2️⃣ Default Root Object (Optional but Recommended)

```
cafe-admin-dashboard.html
```

**⚠️ Do NOT add /order-status.html to Origin Path**
**Origin Path must remain empty.**

### 🧠 Correct CloudFront Path Logic

| Configuration Item   | Value                             |
| -------------------- | --------------------------------- |
| Origin Path          | ❌ Empty                           |
| Default Root Object  | ✅ `cafe-admin-dashboard.html`             |
| File location on EC2 | `/var/www/html/cafe-admin-dashboard.html` |


This ensures:

```
CloudFront → ALB → EC2 Apache → cafe-admin-dashboard.html
```

### 2️⃣ 🔄 CloudFront Invalidations (Admin Dashboard Use Case)

**👉 Invalidation tells CloudFront to delete cached copies immediately.**

#### 1️⃣ Go to:

```
CloudFront → Distributions → Your Distribution
```

#### 2️⃣ Click Invalidations

#### 3️⃣ Click Create invalidation

#### 4️⃣ In Object paths, enter:

invalidation path:

```
/cafe-admin-dashboard.html
```

### 5️⃣ Click Create invalidation

⏳ Status will show:

```
In Progress → Completed
```

Usually completes in 1–3 minutes.

### How to Confirm Invalidation Worked

After status = Completed:

1️⃣ Open browser

2️⃣ Hard refresh:

- Windows/Linux: Ctrl + F5

- Mac: Cmd + Shift + R

3️⃣ Open:

```
https://xxxxx.cloudfront.net/cafe-admin-dashboard.html
```

You should see latest code.

### Common Mistakes (Avoid These)

❌ Invalidating:

```
cafe-admin-dashboard.html
```

(missing leading /)

❌ Invalidating wrong file name

❌ Forgetting invalidation after JS changes

### Important Notes:

✔ /order-status.html is the correct invalidation path

✔ Use invalidation after frontend changes

✔ Do not overuse /*

✔ Required when testing Cognito changes

### 🔐 STEP 4️⃣ — CloudFront SSL Certificate (Optional)
Viewer Certificate

Choose:

```
Default CloudFront certificate (*.cloudfront.net)
```

✅ This is fine

✅ HTTPS works automatically

❌ No ACM needed here


### 5️⃣ CloudFront Validation (VERY IMPORTANT)

> **After configuration, always validate CloudFront before integrating Cognito.**

### 🔍 Validation Checklist

#### 1️⃣ Distribution Status

Status must be:

```
Deployed
```

**⚠️ If status is In Progress, wait 5–10 minutes.**

### 6️⃣ — USE THIS IN COGNITO

```
d2og2zrs47voou.cloudfront.net
```
**This is your Return URL**

**✅ PHASE 4️⃣ STATUS**

> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**
---
### ☕ AWS Charlie Café – Test & Verifications

[☕ Charlie CAFE BASIC CONFIGURATIONS](./☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20(Doc)/☕%20AWS%20CAFE%20—%20%20Test%20%26%20Verifications/☕%20Charlie%20CAFE%20BASIC%20CONFIGURATIONS.md)

## 📢 SECTION 3️⃣ CAFE DATABASE CONFIGURATIONS COMPLETE ✅
---`

## 📢 ☕ Charlie CAFE - Advance System Development & Deployment 

1️⃣ [AWS ☕ Charlie Cafe — Secure Charlie Cafe Dashboard System ](.//☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20(Doc)/☕%20CC-%201%20—Secure%20Charlie%20Cafe%20Dashboard%20System.md)

2️⃣ [☕ AWS CAFE — Order_Async_Processing_Tracking_System ](.//☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20(Doc)/☕%20CC-%202%20—%20Order_Async_Processing_Tracking_System%20.md)

3️⃣ [☕ CAFE LAB – ADVANCED SALES ANALYTICS & REPORTING SYSTEM](.//☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20(Doc)/☕%20CC-%203%20—SALES%20ANALYTICS%20%26%20REPORTING%20SYSTEM.md)

4️⃣ [☕ AWS Charlie Café – Secure HR & Attendance & Employee Management System](.//☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20(Doc)/☕%20CC-%204%20—Secure%20HR%20%26%20Attendance%20System.md)

5️⃣ [☕ AWS Charlie Café – Charile Cafe Printing System](.//☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20(Doc)/☕%20CC-%205%20—%20Charile%20Cafe%20Printing%20System.md)

6️⃣ [☕ AWS Charlie Café – Prod & DevOps](.//☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20(Doc)/☕%20CC-%205%20—%20Prod%20%26%20DevOps.md)

---


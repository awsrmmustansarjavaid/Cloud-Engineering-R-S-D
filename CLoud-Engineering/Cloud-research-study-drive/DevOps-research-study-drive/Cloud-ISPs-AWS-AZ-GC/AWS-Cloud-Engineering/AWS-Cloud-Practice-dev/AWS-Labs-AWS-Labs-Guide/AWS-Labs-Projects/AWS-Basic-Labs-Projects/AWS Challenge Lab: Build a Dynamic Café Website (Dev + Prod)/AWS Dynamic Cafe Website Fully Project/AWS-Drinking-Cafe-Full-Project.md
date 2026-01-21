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

**⚠️ Attach role to EC2 (NO reboot).**

- **✔️ Click Create IAM ROLE**

### 2️⃣ IAM Role for Charlie Cafe

- **IAM Role Name:**

```
CafeAPILambdaRole
```

- **Description:**

```
Allow Lambda to read menu items from DynamoDB
```

- **IAM Role for Charlie Cafe Policies**

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

#### 6️⃣ Create IAM Policy FOR DYNAMODB METRICS TABLE (FULL)



- **✔️ Click Create IAM ROLE**


### 6️⃣ EC2 Instance (Amazon Linux 2023)

* AMI: Amazon Linux 2023
* Type: `t2.micro`
* VPC/Subnet: Dev VPC + Public subnet
* Security Group:

  * SSH (22) → Your IP
  * HTTP (80) → 0.0.0.0/0
* Name tag: `CafeDevWebServer`

#### ✅ EC2 LAMP Server USER DATA
> **📍 File Location: AWS-LAMP Server-Bash-Script.md**

[AWS-LAMP Server-Bash-Script](https://github.com/awsrmmustansarjavaid/Cloud-Engineering-R-S-D/blob/main/CLoud-Engineering/Cloud-research-study-drive/DevOps-research-study-drive/Cloud-ISPs-AWS-AZ-GC/AWS-Cloud-Engineering/AWS-Cloud-Practice-dev/AWS-Labs-Bash-Script/AWS-LAMP%20Server-Bash-Script.md)


**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---
## PHASE 2️⃣ — Development and Delopment LAMP Server 

### 1️⃣ Launch EC2 Instance (Amazon Linux 2023)

```
chmod 400 CafeDevKey.pem
ssh -i CafeDevKey.pem ec2-user@<PUBLIC-IP>
```

### 2️⃣ VERIFY LAMP + MySQL CLIENT (Amazon Linux 2023)


[Development and Delopment LAMP Server ](./AWS%20Cafe%20Project%20Development%20%26%20Depolyment%20Docs/☕%20AWS%20CAFE%20—FrontEnd%20Web%20Development.md)


**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**

# 📢 SECTION 1️⃣ CAFE BASIC CONFIGURATIONS COMPLETE
---

# 📢 SECTION 2️⃣ CAFE DATABASE CONFIGURATIONS

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
---

### 2️⃣ cafe_db

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

### 2️⃣ Keys:

```text
username
password
host
dbname
```

### 3️⃣ Values:

```text
cafe_user
StrongPassword123
RDS endpoint
cafe_db
```

- Retrieve Secret ARN for later use in the app




**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**

# 📢 SECTION 2️⃣ CAFE DATABASE CONFIGURATIONS COMPLETE
---
# 📢 SECTION 2️⃣ CAFE FRONTEND CONFIGURATIONS




## PHASE 3️⃣ — S3 Bucket



**✅ PHASE 4️⃣ STATUS**

> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**
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









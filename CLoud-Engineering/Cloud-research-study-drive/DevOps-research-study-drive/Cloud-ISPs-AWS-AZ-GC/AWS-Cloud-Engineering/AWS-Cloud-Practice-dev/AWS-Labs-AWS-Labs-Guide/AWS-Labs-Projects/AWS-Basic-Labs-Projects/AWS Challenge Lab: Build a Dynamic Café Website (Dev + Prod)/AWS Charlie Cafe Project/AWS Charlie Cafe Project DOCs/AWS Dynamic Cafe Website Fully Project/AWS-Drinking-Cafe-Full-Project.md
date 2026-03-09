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

- Default SG (for general VPC resources)

- RDS SG (for MySQL database)

- Lambda SG (for Lambdas that need RDS access)

### Security Group Overview

| Security Group | Purpose                             | Attached Resources | Inbound Rules                          | Outbound Rules               |
| -------------- | ----------------------------------- | ------------------ | -------------------------------------- | ---------------------------- |
| **Default SG** | General default security group      | RDS, EC2 (if any)  | SSH, HTTP, HTTPS, MySQL, ALL TCP       | All traffic allowed          |
| **RDS SG**     | Protect database                    | RDS instance       | MySQL only from Lambda SG + Default SG | Allow Lambda SG & Default SG |
| **Lambda SG**  | Lambda functions needing VPC access | Lambda (VPC)       | SSH, HTTP, HTTPS, allow RDS MySQL      | Allow all outbound (default) |


### 1️⃣ Default Security Group

- Name: charlie-default-sg

- Attached to: RDS, any EC2/other resources

- Inbound Rules:

| Type         | Protocol | Port Range | Source                                              |
| ------------ | -------- | ---------- | --------------------------------------------------- |
| SSH          | TCP      | 22         | 0.0.0.0/0 (or your IP)                              |
| HTTP         | TCP      | 80         | 0.0.0.0/0                                           |
| HTTPS        | TCP      | 443        | 0.0.0.0/0                                           |
| MySQL/Aurora | TCP      | 3306       | 0.0.0.0/0 (or Lambda SG + RDS SG only for security) |
| ALL TCP      | TCP      | 0-65535    | 0.0.0.0/0                                           |

- Outbound Rules:

  - All traffic allowed (default)

### 2️⃣ RDS Security Group

- Name: charlie-rds-sg

- Attached to: RDS instance

- Inbound Rules:

| Type         | Protocol | Port Range | Source                                  |
| ------------ | -------- | ---------- | --------------------------------------- |
| MySQL/Aurora | TCP      | 3306       | Lambda SG (allow only Lambda functions) |
| MySQL/Aurora | TCP      | 3306       | Default SG (if needed for admin access) |

- Outbound Rules:

  - All traffic allowed (default)

  - Can optionally restrict to Lambda SG only

#### Note: RDS SG is private, only Lambda can access 3306.

### 3️⃣ Lambda Security Group

- Name: charlie-lambda-sg

- Attached to: Lambda functions in VPC

- Inbound Rules:

| Type  | Protocol | Port Range | Source                                |
| ----- | -------- | ---------- | ------------------------------------- |
| SSH   | TCP      | 22         | Default SG (if admin needs)           |
| HTTP  | TCP      | 80         | Default SG (for API testing)          |
| HTTPS | TCP      | 443        | Default SG                            |
| MySQL | TCP      | 3306       | RDS SG (so Lambda can connect to RDS) |

- Outbound Rules:

  - All traffic allowed (default)

#### Notes:

- Lambda in VPC requires SG to allow outbound to RDS SG on 3306

- SSH/HTTP/HTTPS in inbound is optional unless you want Lambda testing/debugging

### 5️⃣ IAM Role & Policies

### 1️⃣ IAM Role for EC2 (Secrets Access)

### 1️⃣ IAM Role Name:

```
EC2-Cafe-Secrets-Role
```

### 2️⃣ Service You Must Select

When creating the IAM role:

- Trusted Entity Type : AWS Service

- Use Case / Service : ✅ EC2

> **This allows the EC2 instance to assume the role and use the permissions defined in your policy.**

#### ✅ Complete IAM Role Creation Steps:

- Go to: AWS Console → IAM → Roles

- Click: Create Role

- Select: Trusted entity type → AWS Service

- Then select: Use case → EC2

- Click: Next

- Attach your custom policy: EC2-Cafe-Secrets-Role

- Role name example: Cafe-EC2-Secrets-Role

- (Optional description): 

```
Role for EC2 to access Lambda, RDS, Secrets Manager, S3 and other services
```

- Click: Create Role

#### ✅ This policy contains permissions for:

- Lambda

- DynamoDB

- SQS

- S3

- Secrets Manager

- RDS

- API Gateway

- CloudWatch

- Elastic Load Balancer

- CloudFront

So this single custom policy replaces many AWS managed policies.

### AWS Managed Policies

In your merged setup you are using 0 AWS Managed Policies.

If you had used AWS managed policies instead of merging, the list would normally be something like:

- AWSLambda_FullAccess

- AmazonDynamoDBFullAccess

- AmazonS3FullAccess

- AmazonSQSFullAccess

- SecretsManagerReadWrite

- AmazonRDSFullAccess

- AmazonAPIGatewayAdministrator

- CloudWatchFullAccess

- ElasticLoadBalancingFullAccess

- CloudFrontFullAccess

### What You Need To Replace

Only ONE value needs to be replaced.

Replace:

```
YOUR_ACCOUNT_ID
```

Example:

```
arn:aws:lambda:us-east-1:123456789012:function:*
```

You can find your account ID here:

AWS Console → Top Right → Account ID

### 1️⃣ Number of AWS Managed Policies

AWS Managed Policies:
These are policies created by Amazon Web Services like:

AmazonS3FullAccess

AWSLambdaFullAccess

AmazonDynamoDBFullAccess

In your case:

You did NOT use any AWS managed policy.

✅ AWS Managed Policies = 0

2️⃣ Number of Custom Policies

You created your own policy JSON and merged everything into one file.

So in IAM it will appear as:


#### COPY-PASTE READY POLICY JSON

You can paste this directly into IAM → Policies → Create policy → JSON

[EC2-Cafe-Secrets-Role](./☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20AWS%20IAM%20Policy%20JSON%20Script/EC2-Cafe-Secrets-Role.json)


**⚠️ Attach role to EC2 (NO reboot).**

- **✔️ Click Create IAM ROLE**

### 2️⃣ IAM Role for Charlie Cafe

- **IAM Role Name:**

```
charlie-cafe-iam-Role
```

- Trusted entity type: AWS service

- Service: Lambda

- Click Next

- **Description:**

```
This IAM Role is designed to support the backend services of the Charlie Cafe system by providing controlled access to AWS resources required for logging, database operations, message queue processing, secrets management, and file storage.
```

- **IAM Role for Charlie Cafe Policies**

#### 1️⃣ IAM Policies Method -1 ✅ Mega Custom IAM Policy

**👉 Paste into IAM → Policies → Create policy → JSON**

- Policy Name: charlie-cafe-iam-policy

- Region: us-east-1

- Account: Your AWS_Account_ID

- **Description:**

```
This IAM policy is designed to support the backend services of the Charlie Cafe system by providing controlled access to AWS resources required for logging, database operations, message queue processing, secrets management, and file storage.
```

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

[charlie-cafe-iam-policy](./☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20AWS%20IAM%20Policy%20JSON%20Script/charlie-cafe-iam-policy.json)

**⚠️ JUST Replace 123456789012 with your real AWS account ID. with your own account ID**

#### ✅ WHY THIS POLICY IS SAFE & CORRECT

✔ No duplicate invalid statements

✔ No conflicting ARNs

✔ Correct AWS service actions

✔ Passes IAM JSON validation

✔ Works for Lambda + DynamoDB + RDS + SQS + S3 + Secrets Manager

✔ Can be attached to Lambda execution roles

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

[AWS-LAMP Server Bash-Script](./☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/Linux%20Lamp%20Server/Lamp%20Server%20Script.sh)


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

[VERIFY LAMP + MySQL CLIENT](./☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/Linux%20Lamp%20Server/lamp-verify.sh)

```
sudo chmod +x lamp-verify.sh
```

```
sudo ./lamp-verify.sh
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

[RDS Credentials to Secrets Manager ](./☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/AWS%20RDS%20Bash%20Scripts/connect-rds.sh)

#### ▶️ How to Run

```
sudo chmod +x connect-rds.sh
```

```
sudo ./connect-rds.sh
```

### 3️⃣ cafe_db

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

[Order Processing & HR Schema Setup + Verification ](./☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/AWS%20RDS%20Bash%20Scripts/Charlie-Cafe_RDS-Full.sh)

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

```
DESCRIBE employees;
```

```
SELECT * FROM employees;
```

```
DESCRIBE attendance;
```

```
SELECT * FROM attendance;
```

```
DESCRIBE holidays;
```

```
SELECT * FROM holidays;
```

```
DESCRIBE leaves;
```

```
SELECT * FROM leaves;
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

- **Type: Other type of secret → Key/Value**


| Key      | Value              |
|----------|--------------------|
| username | cafe_user          |
| password | StrongPassword123  |
| host     | RDS endpoint       |
| dbname   | cafe_db            |

- Retrieve Secret ARN for later use in the app

### ✅ JSON Key/Value

```
{
  "username": "cafe_user",
  "password": "StrongPassword123",
  "host": "your-rds-endpoint.amazonaws.com",
  "dbname": "cafe_db"
}
```

#### ✅  Replace These Values

- username → cafe_user (your DB user)

- password → StrongPassword123 (your real DB password)

- host → your RDS endpoint (example: cafedb.xxxxxx.us-east-1.rds.amazonaws.com)

- dbname → cafe_db

#### Example With Real Format

```
{
  "username": "cafe_user",
  "password": "StrongPassword123",
  "host": "cafedb.abc123xyz.us-east-1.rds.amazonaws.com",
  "dbname": "cafe_db"
}
```

### ✅ Secret Name

```
CafeDevDBSM
```

### ✅ After Creating the Secret

Copy the Secret ARN. It will look like:

```
arn:aws:secretsmanager:us-east-1:123456789012:secret:CafeDevDBSM-xxxxx
```

#### ✅ You will use this ARN inside your AWS Lambda code to retrieve the database credentials.

**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**

## 📢 SECTION 2️⃣ CAFE DATABASE CONFIGURATIONS COMPLETE ✅
---
## 📢 SECTION 3️⃣ CAFE File Sharing

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
## ☕ AWS CAFE - PHASE 2️⃣ Lambda Layer (pymysql)

Read more about Charlie Cafe Lambda Layer (pymysql)

[Lambda Layer (pymysql)](../Charlie%20Cafe%20Lambda%20pymysql-layer.md)

### 1️⃣ - PyMySQL Lambda Layer

### Method 1️⃣ - PyMySQL Lambda Layer (Bash Script)

```
sudo nano upload-pymysql-layer.sh
```

[PyMySQL Lambda Layer](../AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20&%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/☕%20AWS%20CAFE%20—%20PyMySQL%20Lambda%20Layer/upload-pymysql-layer.sh)

```
sudo chmod +x upload-pymysql-layer.sh
```

```
sudo ./upload-pymysql-layer.sh
```

### Method 2️⃣ - PyMySQL Lambda Layer (1-to-1)

#### Verify prerequisites (Optional)

```
aws --version
```

```
python3 --version
```

```
pip3 --version
```

#### 👁‍🗨 You should see:

```
aws-cli/2.x

Python 3.x
```

#### ❗️ If pip3 missing:

#### 1️⃣ Prepare ZIP File (EC2 or Local)

```bash
sudo dnf install -y python3 python3-pip
```

#### 🔹 STEP 1 — Create clean working directory

```
sudo mkdir lambda-layer && cd lambda-layer
```

#### 🔹 STEP 2 — Create required Lambda layer folder structure

⚠️ Lambda REQUIRES this exact structure

```
mkdir python
```

#### 👁‍🗨 You should see:

```
pymysql-layer/
└── python/
```

#### 🔹 STEP 3 — Install PyMySQL INTO python folder

```
pip3 install pymysql -t python/
```

#### 🔄 Verify install:

```
ls python/
```

#### 👁‍🗨 You should see:

```
pymysql/
pymysql-*.dist-info/
```

#### 🔹 STEP 4 — Create ZIP file (VERY IMPORTANT)

```
zip -r pymysql-layer.zip python
```

#### Confirm ZIP exists:

```
ls -lh pymysql-layer.zip
```

#### 👁‍🗨 You should see:

```
pymysql-layer.zip   (few MB)
```

### ✅ METHOD 1 — PyMySQL Lambda Layer via AWS CLI (NO S3)



[PyMySQL Lambda Layer via AWS CLI](../Charlie%20Cafe%20Lambda%20pymysql-layer.md)


### 2️⃣ — S3 Bucket - Upload ZIP

### ✅ METHOD 2 — PyMySQL Lambda Layer via S3

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
aws s3 cp pymysql-layer.zip s3://charlie-cafe-s3-bucket/layers/pymysql-layer.zip
```

#### Expected output:

```
upload: ./pymysql-layer.zip to s3://charlie-cafe-s3-bucket/layers/pymysql-layer.zip
```


##### Option B: Upload via S3 Console

* Open your S3 bucket
* Click **Upload**
* Add file → select `pymysql-layer.zip`
* Click **Upload**

**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**


## 📢 SECTION 3️⃣ CAFE DATABASE CONFIGURATIONS COMPLETE ✅
---
## 📢 SECTION 4️⃣ CAFE FrontEnd Development & Deployment

## ☕ AWS CAFE - PHASE 1️⃣ FRONTEND central FOUNDATION (REUSABLE)

### 1️⃣ Download & Upload Html Directory 

### ⚠️ Read ablout all "FrontEnd Configuration"

[Cafe_FrontEnd_Config](./☕%20AWS%20CAFE%20—%20Front%20&%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Cafe_FrontEnd_Config/Cafe_FrontEnd_Config.md)


[Download & Upload Html Directory ](./☕%20AWS%20CAFE%20—%20Front%20&%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Cafe_FrontEnd_Config/html/)

### 2️⃣ Charlie Cafe Export S3 to HTML Script

### ➡️ Create Folder on S3 

- Create Folder

- **Name: Charlie Cafe Code Drive**

```
sudo nano charlie-cafe-export-s3-to-html.sh
```

[Charlie Cafe Export S3 to HTML Script](./☕%20AWS%20CAFE%20—%20Front%20&%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/charlie-cafe-export-s3-to-html/charlie-cafe-export-s3-to-html.sh)

```
sudo chmod +x charlie-cafe-export-s3-to-html.sh
```

```
sudo ./charlie-cafe-export-s3-to-html.sh
```

### 3️⃣ ALLOW /var/www/html/js IN APACHE

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

### 4️⃣ EXPLICITLY ALLOW JS DIRECTORY (BEST PRACTICE)

Add this at the bottom of the file:

```
<Directory "/var/www/html/js">
    Require all granted
</Directory>
```

### 5️⃣ SET PROPER MIME TYPE FOR JS

Still in the same file, add (or ensure exists):

```
AddType application/javascript .js
```

### 6️⃣ Restart Apache (MANDATORY)

```
sudo systemctl restart httpd
```


**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---
## 🔐 PHASE 2️⃣ — Set Up Automatic HTTP → HTTPS Redirection

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


**⚠️ Cognito tokens must NOT be cached**

### 🚨 GET, HEAD, OPTIONS is NOT enough

You MUST change it to:

```
GET, HEAD, OPTIONS, PUT, POST, PATCH, DELETE
```

**⚠️ (or at minimum include POST)**

### ✅ Correct Setting for Your Case

- Go to: CloudFront → Behaviors → Default → Edit

- Change:

| Setting                | Correct Value                                    |
| ---------------------- | ------------------------------------------------ |
| Viewer protocol policy | Redirect HTTP to HTTPS                           |
| Allowed HTTP methods   | **GET, HEAD, OPTIONS, PUT, POST, PATCH, DELETE** |
| Cache policy           | CachingDisabled                                  |
| Origin request policy  | AllViewer                                        |

**👉 This ensures:**

- POST requests pass through

- Authorization headers pass

- Cognito tokens are not cached

- No 403 / 405 errors

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

- Go to: CloudFront → Distributions → Your Distribution

- Click Invalidations

- Click Create invalidation

- In Object paths, enter:

#### 1️⃣ ✅ invalidation path:

```
/cafe-admin-dashboard.html
```

#### 2️⃣ ✅ /var/www/html/js/

#### Example:

```
/var/www/html/js/config.js
/var/www/html/js/central-auth.js
/var/www/html/js/utils.js
/var/www/html/js/api.js
/var/www/html/js/central-printing.js
/var/www/html/js/role-guard.js
```
#### ✅ From CloudFront perspective, the paths are:

#### Option 1 — Invalidate One-by-One (Best Practice)

```
/js/config.js
/js/central-auth.js
/js/utils.js
/js/api.js
/js/central-printing.js
/js/role-guard.js
```

### ✅ BEST PRACTICE (Better Than Invalidation)

Instead of invalidating every time, use versioning:

#### Change:

```
/js/config.js
/js/central-auth.js
/js/utils.js
/js/api.js
/js/central-printing.js
/js/role-guard.js
```

#### To:

```
/js/config.v2.js
/js/central-auth.v2.js
/js/utils.v2.js
/js/api.v2.js
/js/central-printing.v2.js
/var/www/html/js/role-guard.v2.js
```

#### Or:

```
<script src="/js/config.js?v=2"></script>
<script src="/js/central-auth.js?v=2"></script>
<script src="/js/utils.js?v=2"></script>
<script src="/js/app.js?v=2"></script>
<script src="/js/central-printing.js?v=2"></script>
<script src="/js/role-guard.js?v=2"></script>
```

#### Option 2 — Invalidate Entire JS Folder

```
/js/*
```

✔ This deletes cache for all JS files

⚠ Use only when necessary

#### Option 3 — Invalidate Everything (Heavy)

```
/*
```

⚠ Not recommended often

⚠ Counts toward invalidation limits

**✅ CloudFront treats it as new object → no invalidation needed.**

#### 3️⃣ Very Important — If Using API Gateway

If your JS calls:

```
https://api-id.execute-api.us-east-1.amazonaws.com/prod
```

And that is not routed through ALB,

CloudFront settings won’t affect it.

CloudFront only affects traffic going through:

```
cloudfront.net → ALB → EC2
```

So confirm:

Are you calling API Gateway directly?
Or through ALB reverse proxy?

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

**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**

## 📢 SECTION 3️⃣ CAFE DATABASE CONFIGURATIONS COMPLETE ✅
---`
## SECTION 4️⃣ Secure Admin Order Dashboard

### READ Me About

[☕ CC- 2 —Secure Charlie Cafe Dashboard System](./☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20(Doc)/☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20Readme(Doc)/☕CC-%201%20—Secure%20Charlie%20Cafe%20Dashboard%20System.md)

### AWS Cognito + PHP backend + protected API

[☕ AWS Cognito + PHP backend + protected API](./☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20(Doc)/☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20Readme(Doc)/AWS%20Cognito%20%2B%20PHP%20backend%20%2B%20protected%20API.md)


## 🔐 PHASE 1️⃣ — Cognito Authentication infrastructure 
> **🔐 COGNITO INTEGRATION (PRODUCTION READY)**

Cognito configuration from scratch based on your NEW architecture plan:

✅ Public routes (no login)

✅ Protected routes (Cognito + Groups)

✅ One prod stage

✅ Role-based backend enforcement

✅ SPA for management team

✅ PHP for public ordering

This will be clean, production-ready, and aligned with your new API structure.

We will rebuild Cognito properly using:

- Amazon Cognito

- Amazon API Gateway

- AWS Lambda

### 🔐 FINAL COGNITO DESIGN (BASED ON YOUR NEW PLAN)

We will configure:

- 1 User Pool

- 1 Public App Client (NO client secret)

- Hosted UI login

- Role groups:

    - Admin

    - Manager

    - Employee

- OAuth Authorization Code Grant (NOT implicit anymore)

### 1️⃣ Basic Cognito Configuration — DEFINE YOUR APPLICATION

> **🚀 STEP-BY-STEP — CLEAN NEW COGNITO SETUP**

### 🟢 STEP 1 — Create User Pool (Clean Setup)

- Go to: AWS Console → Cognito → User pools → Create user pool

- Name:

```
CharlieCafeAdminSPA
```


#### 1️⃣ Application Type

- Choose: ✅ Single-page application (SPA)

- Click Next.

#### 2️⃣ Sign-in Options

- Select: ☑ Username

#### DO NOT select:

❌ Email

❌ Phone

This keeps login simple:

```
admin
manager1
employee1
```

- Click Next.

#### 3️⃣ Self Registration

❌ Disable self-registration

(Uncheck enable self-registration)

Production systems never allow public admin registration.

Click Next.

#### 4️⃣ Required Attributes

- Click “Select attributes”

- Choose only: ☑ email

- Do NOT choose anything else.

- Click Save.

- Click Next.

### 🟢 STEP 2 — Security Settings

#### 1️⃣ Password Policy

- Leave default.

- No changes needed.

#### 2️⃣ MFA

- Set: ❌ No MFA (for now)

You can enable later in production.

#### 3️⃣ Account Recovery

- Select: ☑ Email only

- Disable SMS.

- Click Next.

### 🟢 STEP 3 — App Client (CRITICAL)

This is where most mistakes happen.

#### 1️⃣ Client Type

- Choose: ✅ Public client

This disables client secret.

If you accidentally create confidential client → delete and recreate.

#### 2️⃣ App Client Name

Example:

```
CharlieCafeAdminSPA
```

- Click Next.

### 🟢 STEP 4 — OAuth Configuration (IMPORTANT CHANGE)


#### ⚠️ We are NOT using Implicit anymore.

We will use:

✅ Authorization Code Grant (RECOMMENDED)

❌ Do NOT enable Implicit

Because:

- Implicit = older

- Authorization Code = more secure

- Industry standard now

#### 1️⃣ OAuth 2.0 Grant Types

- Select: ☑ Authorization code grant

❌ Do NOT select implicit.

#### 2️⃣ OAuth Scopes

- Select ONLY:

☑ openid

☑ email

☑ profile

Nothing else.

### 🟢 STEP 5 — Callback & Logout URLs

Add EXACT URLs:

### 1️⃣ Callback URL

#### 1️⃣ Callback Login Page 

```
https://YOUR_CLOUDFRONT_DOMAIN/login.html
```

Example:

```
https://dxxxx.cloudfront.net/login.html
```

#### 2️⃣ Callback Admin Dashboard Page 

```
https://YOUR_CLOUDFRONT_DOMAIN/cafe-admin-dashboard.html
```

#### 3️⃣ Callback Order Status Page 

```
https://YOUR_CLOUDFRONT_DOMAIN/order-status.html
```

#### 4️⃣ Callback Admin Order Page 

```
https://YOUR_CLOUDFRONT_DOMAIN/admin-orders.html
```

#### 5️⃣ Callback Analytics Page 

```
https://YOUR_CLOUDFRONT_DOMAIN/analytics.html
```

#### 6️⃣ Callback Employee-portal Page 

```
https://YOUR_CLOUDFRONT_DOMAIN/employee-portal.html
```

#### 7️⃣ Callback hr-attendance Page 

```
https://YOUR_CLOUDFRONT_DOMAIN/hr-attendance.html
```

### 2️⃣ Sign-out URL

```
https://YOUR_CLOUDFRONT_DOMAIN/logout.php?loggedout=true
```

Example:

```
https://dxxxx.cloudfront.net/logout.php?loggedout=true
```

Must match EXACTLY.

- Save.

⌛️ Wait 30–60 seconds.

### 🟢 STEP 6 — Configure Cognito Domain

- Go to: User pool → App integration → Domain

- Create domain prefix:

```
charlie-cafe-auth
```

You will get:

```
charlie-cafe-auth.auth.us-east-1.amazoncognito.com
```

- Copy this.

❌ Do NOT include https.

### 🟢 STEP 7 — App Client Authentication Flows

- Go to: User pool → App clients → Show details

#### Ensure these are enabled:

✔ ALLOW_USER_PASSWORD_AUTH

✔ ALLOW_USER_SRP_AUTH

✔ ALLOW_REFRESH_TOKEN_AUTH

- ❌ Do NOT enable other unnecessary flows.


### 🟢 STEP 8 — Create Groups (FINAL STRUCTURE)

- Go to: User pool → Groups → Create group

| Group     | Group Name | Precedence |
|-----------|------------|------------|
| Group 1   | Admin      | 1          |
| Group 2   | Manager    | 5          |
| Group 3   | Employee   | 10         |

- ❌ No IAM role attached.

### 🟢 STEP 9 — Create Users

Create:

| Username  | Group    | Password            |
|-----------|----------|---------------------|
| cafeadmin | Admin    | ^MyH%H!A4YjD        |
| manager1  | Manager  | jfZvm@^3gTVE        |
| ali       | Employee | *KEXO^C3mjm3        |

- Mark email verified.

- Add each to correct group.

### 🟢 STEP 10 — Create Employee ID Attribute in Cognito

> **To make Employee ID flow correctly from Cognito → Employee Portal → Lambda → RDS, your Cognito configuration must include the Employee ID inside the ID Token.
Below is the complete correct setup step-by-step.**

- Go to : Amazon Cognito Console → User Pools → Your User Pool

- Open Sign-up experience

- Scroll to Custom attributes

- Click Add custom attribute

#### Create:

```
Name: employee_id
Type: String
Mutable: Yes
```

#### Cognito will internally store it as:

```
custom:employee_id
```

#### ⚠️ This is the exact name that will appear inside the JWT token.

### 🟢 STEP 11 — Add attribute to App Client

- Go to: App integration

- Open your App Client

- Find: Attribute read permissions

- Enable: custom:employee_id

> **✔️ Both permissions are enabled:**

  - ✔ Read

  - ✔ Write

> **This is exactly what is required so the App Client can access the attribute and include it in the JWT ID token.**

Save changes.

- Save.


### 🟢 STEP 12 — Add Employee ID to Users

- Go to: User Pools → Users → Create user / select user

- Edit attributes.

- Add:

```
custom:employee_id = 5
```

#### Example:

```
Username: ali
Email: ali@charliecafe.com
custom:employee_id = 5
```

#### Now Cognito stores:

```
custom:employee_id = 5
```

Where 5 must match the employee_id in your RDS employees table.

#### Example users: employees table

| Cognito Username | Employee ID |
| ---------------- | ----------- |
| ali              | 5           |
| ahmed            | 6           |
| sara             | 7           |

- Save.




### 🟢 STEP 13 — Amazon Cognito Hosted UI — Callback + Logout

✅ Updated Login.html (with your Cognito config structure ready)

✅ Proper cognito-callback.php (NEW – required for token handling)

✅ Updated Logout.php (with Cognito global sign-out)

🎨 Café-themed UI (coffee background, icons, logo text, warm styling)

💬 Clear comments inside the code

### 1️⃣ Updated Login Page (Charlie Café Theme)

#### ✅ Replace with your real values:

- YOUR_DOMAIN_PREFIX

- YOUR_REGION

- YOUR_APP_CLIENT_ID

- Cloudfront

[login.html](./☕%20AWS%20CAFE%20—%20Front%20&%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Cognito%20Hosted%20UI/login.html)

### ✅ 2️⃣ Updated logout.php

(Proper Cognito global sign-out + styled logout page option)

⚠️ Important: If you only destroy session locally, the user stays logged into Cognito.
We must redirect to Cognito logout endpoint.

🌟 Recommended Logout (Full Cognito Sign-Out)

Rename file to: logout.php

### 🔹 OPTION A — Global Logout (Recommended)

This:

Destroys PHP session

Logs user out from Cognito Hosted UI

Shows styled logout page

#### ⚠️ Important: When logging out from Cognito, you must redirect to Cognito first.

So the styled page must appear after Cognito redirects back.

That means:

First request → destroy session + redirect to Cognito

Second request → show styled page

We can handle both in ONE FILE using a condition.

### ✅ Single File: logout.php

[logout.php](./☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Cognito%20Hosted%20UI/logout.php)

### 🧠 Why This Works

- First visit: logout.php → destroys session → redirects to Cognito → Cognito logs user out → redirects back to: 

```
logout.php?loggedout=true
```

Now PHP skips redirect and displays styled page.

🔥 Clean. Secure. One file only.

### 🎯 Important Cognito Console Setting

Inside Amazon Cognito:

Set Sign-out URL to:

```
https://YOUR_CLOUDFRONT_DOMAIN/logout.php?loggedout=true
```

Otherwise Cognito will reject the redirect.

### 🚀 Recommendation Level

This single-file approach is:
✔ Professional

✔ Secure

✔ Production-ready

✔ Cleaner file structure

### 🟢 STEP 14 — — central-auth-api

### 🔥 STEP 1 — config.js (NO LOGIC HERE)

This replaces hardcoded config from your old file.

[config.js](./☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/config.js)

#### ✅ Replace with your real values:

- YOUR_DOMAIN_PREFIX

- YOUR_REGION

- YOUR_APP_CLIENT_ID

- Cloudfront

### 🔥 STEP 2 — utils.js (Shared Helpers)

Move all generic helpers here.

[utils.js](./☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/utils.js)


### 🔐 STEP 3 — central-auth.js (COGNITO ONLY)

This file contains ONLY authentication logic.

No API routes inside.

[central-auth.js](./☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/central-auth.js)

### 🌐 STEP 4 — api.js (PUBLIC + PROTECTED FETCH)

This file handles API logic only.

[api.js](./☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/api.js)

### 🌐 STEP 5 — Create central-printing.js

[central-printing.js](./☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/central-printing.js)

### 🌐 STEP 6 — Create role-guard.js

[role-guard.js](./☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/role-guard.js)

#### ✅ After This, You Must Verify

- Login

- Check localStorage

- Confirm access_token exists

- Paste token in jwt.io

- Confirm:

- email

- cognito:groups

- exp

If groups are missing → your Lambda 403 will happen again.

### 🔐 PART 15 — EASIEST WAY TO GET ACCESS TOKEN (Manual Test)

You asked for easiest method.

Here is the clean method.

#### STEP 1️⃣ Open Cognito Hosted UI Login

- Go to AWS Console → Cognito → User Pools → Your pool

- Click App integration → App client settings

#### You will see:

- Domain

- Client ID

- Callback URL

- Allowed OAuth flows

#### STEP 2️⃣ Construct the LOGIN URL

Open browser and paste (replace values):

```
https://YOUR_DOMAIN.auth.us-east-1.amazoncognito.com/login
?client_id=YOUR_CLIENT_ID
&response_type=code
&scope=openid+email+profile
&redirect_uri=https://yourdomain.com/login.html
```

#### 📌 Example:

```
https://charlie-cafe.auth.us-east-1.amazoncognito.com/login
?client_id=YOUR_CLIENT_ID
&response_type=code
&scope=openid+email+profile
&redirect_uri=https://yourdomain.com/login.html
```

- 👉 Press Enter

#### 🌐 Cognito Access Auth Code

```
https://yourdomain.com/login.html?code=ebec6a0a-54e8-49c0-a093-d68150c182b1
```

#### STEP 3️⃣ Login Screen Appears

- Enter username & password

- Click Sign in

If login is successful → browser redirects to:

```
https://yourdomain.com/login.html?code=AUTH_CODE
```

Access token will only appear after your frontend exchanges the code via:

```
POST https://YOUR_DOMAIN/oauth2/token
```

#### STEP 4️⃣ COPY THE ACCESS TOKEN

From the URL bar, copy ONLY this part:

```
?code=...
```

#### ⚠️ Do NOT copy:

- id_token

- expires_in

- token_type

👉 You need access_token

#### STEP 5️⃣ Use Token in API Call (Browser DevTools)

Open Chrome DevTools → Console

Paste:

```
fetch("https://API_ID.execute-api.REGION.amazonaws.com/status/order-status", {
  headers: {
    "Authorization": "Bearer YOUR_ACCESS_TOKEN"
  }
})
.then(res => res.json())
.then(data => console.log(data));
```

#### ✅ EXPECTED RESULT

```
{
  "orders": [...],
  "metrics": {...}
}
```

🎉 DONE — frontend token works.

### 🧪 METHOD 2 — curl (CLI / AWS TESTING)

Use this after you already have the token.

#### STEP 1️⃣ Open Terminal / CMD

#### STEP 2️⃣ Run curl Command

- Make GET request with header:

```
curl -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
https://API_ID.execute-api.REGION.amazonaws.com/status/order-status
```

#### 📌 Example:

```
curl -H "Authorization: Bearer eyJraWQiOiJr..." \
https://abcd123.execute-api.us-east-1.amazonaws.com/status/order-status
```

#### ✅ EXPECTED RESPONSES

```
JSON response with metrics + recent orders
```

#### ✅ SUCCESS (200)

```
{
  "orders": [...],
  "metrics": {...}
}
```

#### ❌ NO TOKEN

```
{"message":"Unauthorized"}
```

#### ❌ INVALID TOKEN

```
401 Unauthorized
```

#### 3️⃣ Date Filter Test

```
curl -H "Authorization: Bearer <access_token>" \
"https://API_ID.execute-api.REGION.amazonaws.com/status/order-status?date=2026-01-17"
```

#### ✅ Expected: 

```
Only orders for 2026-01-17 returned
```

**✅ Metrics counts match filtered orders**

#### 4️⃣ Verify Auto Refresh / Chart in Frontend

- Open order-status.html

- Enter date in filter box

- Click Filter

- Metrics + table + chart should update correctly

- Spinner shows loading

### 📣 Simple & Easy way test 

#### 1️⃣ Login & Token Issued

- Open your Cafe Dashboard frontend (order-status.html).

- Click Login.

- You should be redirected to Cognito Hosted UI.

- Enter Admin credentials.

- After login, you are redirected back to the dashboard.

- Open browser DevTools → Application → Local Storage.

  - **✅ access_token should exist.**

**If no token → STOP, check Cognito setup.**

#### 2️⃣ Dashboard Loads

- After login, the dashboard content should appear (metrics + table).

- Metrics should show Total Orders, Total Items Sold, Customers.

- Orders table should populate with recent orders.

- Spinner should appear while loading, then hide.

- **✅ If dashboard is blank → STOP, check Lambda/API response.**

#### 3️⃣ Auto Refresh Works

- Wait ~10 seconds (or the interval set in frontend).

- Dashboard metrics and table should update automatically.

- Open DevTools → Network tab

  - You should see GET requests to /order-status fired every 10 seconds.

- **✅ If auto refresh doesn’t work → check setInterval(loadData, 10000) in frontend JS.**

#### 4️⃣ Date Filter Works

- On dashboard, select a date in the date picker.

- Click Filter.

- Dashboard metrics + table should update only for that date.

- Network tab → Confirm request URL:

```
https://API_ID.execute-api.REGION.amazonaws.com/prod/order-status?date=YYYY-MM-DD
```

- **✅ If metrics or table show wrong data → check Lambda filter code.**

#### 5️⃣ Chart Works

- Chart below metrics should update matching the filtered data.

- Check bars/lines correspond to orders/items counts.

- Change date → chart updates accordingly.

- **✅ If chart does not update → check frontend chart destroy/create logic.**

**✔ Everything works → Phase Complete**

**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**

## SECTION 4️⃣ Secure Admin Order Dashboard COMPLETE ✅
---


---
### ☕ AWS Charlie Café – Test & Verifications

[☕ Charlie CAFE BASIC CONFIGURATIONS](./☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20(Doc)/☕%20AWS%20CAFE%20—%20%20Test%20%26%20Verifications/☕%20Charlie%20CAFE%20BASIC%20CONFIGURATIONS.md)


## 📢 ☕ Charlie CAFE - Advance System Development & Deployment 

1️⃣ [☕ AWS CAFE — Order_Async_Processing_Tracking_System ](.//☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20(Doc)/☕%20CC-%202%20—%20Order_Async_Processing_Tracking_System%20.md)

2️⃣ [☕ CAFE LAB – ADVANCED SALES ANALYTICS & REPORTING SYSTEM](.//☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20(Doc)/☕%20CC-%203%20—SALES%20ANALYTICS%20%26%20REPORTING%20SYSTEM.md)

3️⃣ [☕ AWS Charlie Café – Secure HR & Attendance & Employee Management System](.//☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20(Doc)/☕%20CC-%204%20—Secure%20HR%20%26%20Attendance%20System.md)

4️⃣ [☕ AWS Charlie Café – Charile Cafe Printing System](.//☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20(Doc)/☕%20CC-%205%20—%20Charile%20Cafe%20Printing%20System.md)

5️⃣ [☕ AWS Charlie Café – Prod & DevOps](.//☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20(Doc)/☕%20CC-%205%20—%20Prod%20%26%20DevOps.md)

---


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

### 2️⃣ Create Public Subnet

* Name: `CafeDevPublicSubnet`
* CIDR: `10.0.1.0/24`
* Auto‑assign public IP: **Enabled**

### 3️⃣ Create TWO private subnets:

- CafeDevPrivateSubnet1 → 10.0.2.0/24 (AZ-a)
- CafeDevPrivateSubnet2 → 10.0.3.0/24 (AZ-b)

### 4️⃣ Internet Access

* Create Internet Gateway → Attach to VPC
* Route table → Add route `0.0.0.0/0 → IGW`

### 5️⃣ Security Group and NACL

#### ✅ Open Security Group (MANDATORY)

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

### 6️⃣ IAM Role & Policies

### 1️⃣ IAM Role for EC2 (Secrets Access)

- **IAM Role Name:**

```
EC2-Cafe-Secrets-Role
```

This policy contains permissions for:

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

#### 1️⃣ Number of AWS Managed Policies

AWS Managed Policies:
These are policies created by Amazon Web Services like:

AmazonS3FullAccess

AWSLambdaFullAccess

AmazonDynamoDBFullAccess

In your case:

You did NOT use any AWS managed policy.

✅ AWS Managed Policies = 0

#### 2️⃣ Number of Custom Policies

You created your own policy JSON and merged everything into one file.

So in IAM it will appear as:

#### ✅ COPY-PASTE READY POLICY JSON

You can paste this directly into IAM → Policies → Create policy → JSON

[EC2-Cafe-Secrets-Role](../AWS%20Charlie%20Cafe%20Project/AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20&%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20AWS%20IAM%20Policy%20JSON%20Script/EC2-Cafe-Secrets-Role.json)

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

### 1️⃣ IAM Policies Method -1 ✅ Mega Custom IAM Policy

**👉 Paste into IAM → Policies → Create policy → JSON**

- Policy Name: charlie-cafe-iam-policy

- Region: us-east-1

- Account: Your AWS_Account_ID

### ✅ This policy includes:

### 1️⃣ AWS Managed Policies (permissions merged)

- AmazonDynamoDBFullAccess

- AmazonDynamoDBFullAccess_v2 (same permissions, safely merged once)

- AWSLambdaBasicExecutionRole

- AWSLambdaVPCAccessExecutionRole

- AmazonRDSDataFullAccess

- CloudWatchLogsFullAccess

### 2️⃣ Custom Policies (ALL merged)

- AWSLambdaBasicExecution (custom logs scope)

- CafeMenuDynamoDBReadPolicy

- CafeOrderWorkerPermissions

- CafeSecretsManagerAccess

- CafeSecretsManagerReadOnly

- CashPaymentLambda

- LambdaCafeSecretsAccess

- S3AppBucketAccessPolicy

- SendOrderToSQS

#### ✅ COPY-PASTE READY POLICY JSON

You can paste this directly into IAM → Policies → Create policy → JSON

[charlie-cafe-iam-policy](../AWS%20Charlie%20Cafe%20Project/AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20&%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20AWS%20IAM%20Policy%20JSON%20Script/charlie-cafe-iam-policy.json)

**⚠️ JUST Replace "Your AWS ACCOUNT ID " with your own account ID**

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

[AWS-LAMP Server Bash-Script](../AWS%20Charlie%20Cafe%20Project/AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20&%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/Linux%20Lamp%20Server/Lamp%20Server%20Script.sh)

### 8️⃣ Development and Delopment LAMP Server 

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

[VERIFY LAMP + MySQL CLIENT](../AWS%20Charlie%20Cafe%20Project/AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20&%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/Linux%20Lamp%20Server/lamp-verify.sh)

```
sudo chmod +x lamp-verify.sh
```

```
sudo ./lamp-verify.sh
```

**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**

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

Read more about Charlie Cafe RDS

[Charlie Cafe RDS](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Charlie%20Cafe%20%20RDS%20Project.md)

### 1️⃣ Create Schema in RDS

- **✔️ Connect from EC2:**

### 2️⃣ — Basic RDS CONFIGURATIONS

#### 1️⃣ Verify mysql

```
mysql --version
```

#### 2️⃣ Login to MariaDB:

> **🛠️ BASH SCRIPT (Safe RDS Connection)**

> **📄 connect-rds.sh**

```
sudo nano connect-rds.sh
```

[RDS Credentials to Secrets Manager ](../AWS%20Charlie%20Cafe%20Project/AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20&%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/AWS%20RDS%20Bash%20Scripts/connect-rds.sh)


```
sudo chmod +x connect-rds.sh
```

```
sudo ./connect-rds.sh
```

### 3️⃣ Create cafe_db & Tables

#### ✅ Charlie Cafe – Order Processing & HR Schema Setup + Verification

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

[Order Processing & HR Schema Setup + Verification ](../AWS%20Charlie%20Cafe%20Project/AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20&%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/AWS%20RDS%20Bash%20Scripts/Charlie-Cafe_RDS-Full.sh)

#### ▶️ Run

```
sudo chmod +x setup_charlie_cafe_db_full.sh
```

```
sudo ./setup_charlie_cafe_db_full.sh
```

### 4️⃣ Verify table exists

```
SHOW TABLES;
```

#### ✅ You should see:

```
orders
employees
attendance
leaves
holidays
```

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

### 1️⃣ - PyMySQL Lambda Layer

### Method 1️⃣ - PyMySQL Lambda Layer (Bash Script)

```
sudo nano upload-pymysql-layer.sh
```

[PyMySQL Lambda Layer](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/upload-pymysql-layer.sh)

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



[PyMySQL Lambda Layer via AWS CLI](./☕%20CC-%206%20—pymysql-layer.md)


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
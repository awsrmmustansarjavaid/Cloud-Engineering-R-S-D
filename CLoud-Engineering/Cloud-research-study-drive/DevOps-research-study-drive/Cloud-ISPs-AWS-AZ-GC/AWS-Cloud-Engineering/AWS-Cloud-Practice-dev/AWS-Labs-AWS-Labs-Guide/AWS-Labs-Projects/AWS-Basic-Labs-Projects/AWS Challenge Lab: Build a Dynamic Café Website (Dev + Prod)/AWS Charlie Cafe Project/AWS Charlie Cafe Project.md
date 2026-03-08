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

Read more about Charlie Cafe Lambda Layer (pymysql)

[Lambda Layer (pymysql)](./AWS%20Charlie%20Cafe%20Project%20DOCs/Charlie%20Cafe%20Lambda%20pymysql-layer.md)

### 1️⃣ - PyMySQL Lambda Layer

> #### Method 1️⃣ - PyMySQL Lambda Layer (Bash Script)

```
sudo nano upload-pymysql-layer.sh
```

[PyMySQL Lambda Layer](../AWS%20Charlie%20Cafe%20Project/AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20&%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/☕%20AWS%20CAFE%20—%20PyMySQL%20Lambda%20Layer/upload-pymysql-layer.sh)

```
sudo chmod +x upload-pymysql-layer.sh
```

```
sudo ./upload-pymysql-layer.sh
```

**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**

## 📢 SECTION 3️⃣ CAFE DATABASE CONFIGURATIONS COMPLETE ✅
---
## 📢 SECTION 4️⃣ CAFE FrontEnd Development & Deployment

## ☕ AWS CAFE - PHASE 1️⃣ FRONTEND central FOUNDATION (REUSABLE)

### 1️⃣ Download & Upload Html Directory 

### ⚠️ Read ablout all "FrontEnd Configuration"

[Cafe_FrontEnd_Config](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20&%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Cafe_FrontEnd_Config/Cafe_FrontEnd_Config.md)


[Download & Upload Html Directory ](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20&%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Cafe_FrontEnd_Config/html/)

### 2️⃣ Charlie Cafe Export S3 to HTML Script

```
sudo nano charlie-cafe-export-s3-to-html.sh
```

[Charlie Cafe Export S3 to HTML Script](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20&%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/charlie-cafe-export-s3-to-html/charlie-cafe-export-s3-to-html.sh)

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

[☕ CC- 2 —Secure Charlie Cafe Dashboard System](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20(Doc)/☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20Readme(Doc)/☕CC-%201%20—Secure%20Charlie%20Cafe%20Dashboard%20System.md)

### AWS Cognito + PHP backend + protected API

[☕ AWS Cognito + PHP backend + protected API](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20(Doc)/☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20Readme(Doc)/AWS%20Cognito%20%2B%20PHP%20backend%20%2B%20protected%20API.md)


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

[login.html](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Cognito%20Hosted%20UI/login.html)

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

[logout.php](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Cognito%20Hosted%20UI/logout.php)

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

[config.js](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/config.js)

#### ✅ Replace with your real values:

- YOUR_DOMAIN_PREFIX

- YOUR_REGION

- YOUR_APP_CLIENT_ID

- Cloudfront

### 🔥 STEP 2 — utils.js (Shared Helpers)

Move all generic helpers here.

[utils.js](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/utils.js)


### 🔐 STEP 3 — central-auth.js (COGNITO ONLY)

This file contains ONLY authentication logic.

No API routes inside.

[central-auth.js](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/central-auth.js)

### 🌐 STEP 4 — api.js (PUBLIC + PROTECTED FETCH)

This file handles API logic only.

[api.js](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/api.js)

### 🌐 STEP 5 — Create central-printing.js

[central-printing.js](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/central-printing.js)

### 🌐 STEP 6 — Create role-guard.js

[role-guard.js](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/role-guard.js)

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
## SECTION 5️⃣ Cafe Order Processor

## PHASE 1️⃣ — SQS/LAMBDA (Producer)

### 1️⃣ Create SQS Queue

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


**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---
## PHASE 2️⃣ — AUTOMATION Lambda Cafe-Order (SERVERLESS)

### 1️⃣ Create Lambda Role

* Name: `Lambda-Cafe-Order-Role`
* Policies:

  * AWSLambdaBasicExecutionRole
  * Secrets Manager custom policy


### 2️⃣ Create Lambda Function

* Name: `CafeOrderProcessor`
* Runtime: Python 3.12
* Role: `Lambda-Cafe-Order-Role`

### 3️⃣ Create Lambda Layer Using S3

#### 1️⃣  Lambda Console

* AWS Console → **Lambda**
* Click **Layers**
* Click **Create layer**

#### 2️⃣  Layer Settings

| Field              | Value                                                          |
| ------------------ | -------------------------------------------------------------- |
| Name               | `pymysql-layer`                                                |
| Description        | PyMySQL dependency layer                                       |
| Code entry type    | **Upload a file from Amazon S3**                               |
| S3 URI             | `s3://cafe-lambda-artifacts-<unique>/layers/pymysql-layer.zip` |
| Compatible runtime | Python 3.12                                                    |

Click **Create**

✅ Lambda Layer created from S3

### 4️⃣ Attach Layer to Lambda Function

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

### 5️⃣ Lambda Payload Code (INSERT INTO MariaDB)

Paste THIS EXACT CODE ⬇️

[CafeOrderProcessor.py](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project//☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/Charlie%20Cafe%20-%20Order%20Backend%20Code/CafeOrderProcessor/CafeOrderProcessor.py)

Save Lambda

Click Deploy (top right)
---- 

### 6️⃣ Move Lambda Into VPC

- AWS Console → Lambda → Your Function

- Go to Configuration

- Open VPC

- Click Edit

- Select:

    - **VPC → same as EC2**

    - **Subnets → PRIVATE subnets (important)**

    - **Security Group → Lambda SG**

    - Save

**⏳ Wait until Lambda status = Active**

### 7️⃣ Increase Lambda Timeout

**Lambda → Configuration → General configuration → Edit**

| Setting | Value          |
| ------- | -------------- |
| Timeout | **15 seconds** |
| Memory  | **512 MB**     |


👉 Why:

- ENI creation

- Cold start

- DB connection

- Memory also improves network performance.

Click Save


#### 8️⃣ Add Environment Variable:

- Configuration → Environment variables

```
SQS_QUEUE_URL = https://sqs.us-east-1.amazonaws.com/xxxxxxxx/CafeOrdersQueue
```

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

**✔️ Everything else remains same.**

### 🧪 LAMBDA TEST EVENT JSON

Use this in Lambda Test:

```
{
  "body": "{\"table_number\":5,\"customer_name\":\"John\",\"item\":\"Coffee\",\"quantity\":2,\"payment_method\":\"CASH\"}"
}
```

OR if paying by card:

```
{
  "body": "{\"table_number\":5,\"customer_name\":\"John\",\"item\":\"Coffee\",\"quantity\":2,\"payment_method\":\"CARD\"}"
}
```

#### ✅ Expected:

- Order inserted in RDS

- DynamoDB updated

- SQS message sent

- StatusCode 200

```
{
  "statusCode": 200,
  "body": "{\"order_id\":\"ORD-20260220-1234\",\"table_number\":5,\"customer_name\":\"John\",\"item\":\"Coffee\",\"quantity\":2,\"total\":6.0,\"status\":\"RECEIVED\",\"created_at\":\"2026-02-20 10:30:00\"}"
}
```

**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**
---
## PHASE 3️⃣ — API Gateway

### Objective:

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

**⚠️ DO NOT attach authorizer**

### 5️⃣ Deploy API

1. Click **Actions → Deploy API**.
2. Configure:
   - Deployment stage: `prod`
   - Stage description: `Development stage`
   - Deployment description: `Initial deployment`
3. Click **Deploy**.

### 6️⃣ Copy API Invoke URL

After deployment, you’ll see an **Invoke URL** at the top of the Stage page, e.g.:

```
https://abcdef123.execute-api.us-east-1.amazonaws.com/prod/orders
```

> This URL will be used in your EC2 PHP web app `curl` requests.

### 2nd Method - ADD API GATEWAY TRIGGER Method

### 1️⃣ ADD API GATEWAY TRIGGER


When you go to:

- CafeOrderProcessor Lambda → Add Trigger → API Gateway

- Choose: Create an API

| Setting  | Value              |
| -------- | ------------------ |
| API Type | REST API           |
| Security | Open (for testing) |

- Click Add

#### ➡️ AWS automatically:

```
- Creates an API

- Creates a resource

- Creates a method (POST/GET)

- Connects it to the Lambda

- Adds permission so API Gateway can invoke the Lambda

- This is the Lambda-centric way.

You start from Lambda and let AWS build the API for you.
```

### 2️⃣ Get Your Endpoint

- Go to API Gateway → Open your new API

- Click: Stages → Prod

#### ✅ You will see:

```
Invoke URL:
https://abc123.execute-api.us-east-1.amazonaws.com/Prod
```

Your final endpoint will be:

```
https://abc123.execute-api.us-east-1.amazonaws.com/Prod
```

If resource path is /orders:

```
https://abc123.execute-api.us-east-1.amazonaws.com/Prod/orders
```

### 3️⃣ — ENABLE CORS

- Inside API Gateway:

- Click Resources

- Select /orders

- Click Actions

- Choose: Enable CORS

- Confirm

- Deploy API again

This prevents browser blocking.

### 4️⃣ — Deploy API

- After any change:

- Click Actions

- Click Deploy API

- Choose: Prod

- Deploy

Without deploy → it will NOT work.

### 5️⃣ — TEST 

#### 1️⃣ Test API Gateway Endpoint (Console Method)

- Go to AWS Console

- Click API Gateway

- Open your API

- Click Resources

- Click /orders

- Click POST

- On the POST method page

- Click the Test button (top right)

- Update Request Body

In Request Body, paste:

```
{
  "table_number": 3,
  "customer_name": "ApiTest",
  "item": "Coffee",
  "quantity": 1,
  "payment_method": "CASH"
}
```

- Leave:

  - Headers empty (unless using auth)

  - Query params empty

- Click “Test” (Blue Button)

- Scroll down to see:

  - Request

  - Response Body

  - Response Headers

  - Logs

#### ✅ Expected Success Response

You should see:

```
{
  "order_id": "...",
  "table_number": 3,
  "customer_name": "ApiTest",
  "item": "Coffee",
  "quantity": 1,
  "total": 3.0,
  "status": "RECEIVED",
  "created_at": "..."
}
```
#### 2️⃣ TEST WITH CURL (Important)

Test outside PHP first.

- Open terminal:

```
curl -X POST https://hihe1z5ci7.execute-api.us-east-1.amazonaws.com/prod/orders \
-H "Content-Type: application/json" \
-d '{"table_number":5,"customer_name":"John","item":"Coffee","quantity":2,"payment_method":"CASH"}'
```

If correct, you get:

```
{
  "message": "Order created successfully",
  "table_number": 5
}
```

#### Then check:

- RDS → new row

- DynamoDB → updated

- SQS → message sent

### 🔹 2️⃣ “Lambda integrated inside API Gateway”

When you go to:

- API Gateway → Create Resource → Create Method → Integration = Lambda

You are:

- Designing API structure first

- Choosing which Lambda to connect

- Controlling stages, routes, throttling, etc.

- This is the API-centric way.

You start from API Gateway and connect Lambda manually.

### 🎯 Technically:

👉 Both result in the exact same architecture.

Internally it always becomes:

```
Client → API Gateway → Lambda
```

There is no architectural difference. The difference is only how you configure it.

### 🚀 Real Differences (Practical)

| Feature             | Add Trigger from Lambda | Integrate from API Gateway |
| ------------------- | ----------------------- | -------------------------- |
| Setup Speed         | Very fast               | Manual setup               |
| Control over routes | Limited                 | Full control               |
| Good for production | ❌ Not ideal             | ✅ Yes                      |
| Multi-endpoint APIs | Hard                    | Easy                       |
| Versioning & stages | Basic                   | Full control               |
| Best for quick test | ✅ Yes                   | ❌ Overkill                 |

### 🔥 When Should You Use Each?

#### ✅ Use “Add Trigger from Lambda” if:

- Quick prototype

- Testing only

- Single endpoint

- Small internal tool

### ✅ Use “Integrate from API Gateway” if:

Production system

Multiple endpoints like:

```
POST /orders
GET /orders
PUT /orders/{id}
GET /serving
POST /payment
```

- Need throttling

- Need authentication

- Need API keys

- Need usage plans

### 💡 Another Important Difference (Permissions)

When you add trigger from Lambda:

AWS automatically adds this permission:

```
{
  "Principal": "apigateway.amazonaws.com"
}
```

When you integrate from API Gateway:

You may need to manually allow Lambda invocation.

So Lambda-trigger method is easier for beginners.

### 🎯 Final Recommendation For You

Since your system is growing (admin, status, metrics, serving, payments):

👉 Use API Gateway as the main controller

👉 Integrate Lambdas inside API Gateway

👉 Don’t rely on “Add Trigger” shortcut

This gives you:

- Cleaner architecture

- Easier scaling

- Better long-term management

- Production-ready structure

### 🏆 Summary

There is no runtime difference.

The difference is:

| Lambda trigger method | Quick & automatic |
| API Gateway integration method | Structured & production-ready |


**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---

## PHASE 4️⃣ — Frontend Development Code

### 💻 MODERN CAFE-STYLE orders.php (Frontend Only Modified)

[orders.php](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order.php/orders.php)

**🔁 Replace with your real API Gateway URL**

**✅ PHASE 4️⃣ STATUS**

> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**
---
## PHASE 5️⃣ — VPC ENDPOINTS (THIS IS WHERE MOST FAIL)

### 1️⃣ Fix Security Groups (MANDATORY)

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


### 2️⃣ Create Secrets Manager Endpoint

- **AWS Console → VPC → Endpoints → Create endpoint**

- **Endpoint Name:** secretsmanager-INT-EP

- **Service category:** AWS services

- **Service name:** com.amazonaws.us-east-1.secretsmanager

- **Type:** Interface

- **VPC:** Select VPC 

- **Subnets:**

**✔ Select the SAME private subnets used by Lambda**

- **Security Group:**

**Allow HTTPS (443) inbound from Lambda SG**

Create endpoint ✅

### 3️⃣ Create SQS Interface Endpoint

**VPC → Endpoints → Create endpoint**

| Field          | Value                         |
| -------------- | ----------------------------- |
| Name           | sqs-INT-EP                    |
| Service        | `com.amazonaws.us-east-1.sqs` |
| Type           | Interface                     |
| VPC            | Same VPC                      |
| Subnets        | Same private subnets          |
| Security group | Lambda-SG                     |
| Private DNS    | ✅ ENABLE                      |

### 4️⃣ Create CloudWatch Logs Interface Endpoint

- **Name:**

```
cloudwatch-INT-EP 
```

- **Service:**

```
com.amazonaws.us-east-1.logs
```

Same settings as above

Private DNS ✅

### 5️⃣ Create DynamoDB Gateway Endpoint (VERY IMPORTANT)

- **Name:**

```
dynamodb-GW-EP 
```


- **Service:**

```
com.amazonaws.us-east-1.dynamodb
```

- **Type:** Gateway

- **Attach to:**

  - ALL private route tables

Click Create

### 6️⃣ Verify Secrets Manager Keys (VERY IMPORTANT)

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

### 7️⃣ Add DEBUG LOGS (TEMPORARY - Optional)

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

**✅ PHASE 5️⃣ STATUS**

> **🟢 PHASE 5️⃣ COMPLETE & VERIFIED**
---
## PHASE 6️⃣ — Test & Verification ( Must)

_ **Please refer to the Test & Verification documentation for detailed procedures.**

**✅ PHASE 6️⃣ STATUS**

> **🟢 PHASE 6️⃣ COMPLETE & VERIFIED**

## 🟢 SECTION 5️⃣ COMPLETE & VERIFIED
---
## SECTION 6️⃣ — AWS Cafe Menu + Cache Layer

## PHASE 1 — AMAZON DYNAMODB (Menu + Cache Layer)

### 1️⃣ Create DynamoDB Table

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

### 2️⃣ Insert Menu Items

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

#### 4️⃣ Create 4th Item (Cappuccino)

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

#### 5️⃣ Create 5th Item (Fresh Juice)

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

#### 4️⃣ Create 4th Item (Cappuccino)

1. Partition key:

- item → Cappuccino

2. Click Add new attribute

- Type: Number

- Attribute name: price

- Value: 8

- ✅ Click Create item

#### 5️⃣ Create 5th Item (Fresh Juice)

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


**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---
## PHASE 2️⃣ — CafeMenuLambda
### 1️⃣ Attach Policy to Lambda Role

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


### 2️⃣ CREATE NEW LAMBDA (MENU API)

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

### 5️⃣ Lambda Code: Read Menu from DynamoDB (Python)

Now we implement the logic.

Use boto3 to fetch menu/prices before processing orders.

[CafeMenuLambda.py](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeMenuLambda.py)

**✔️ Click Deploy**

### 6️⃣ TEST LAMBDA (MANDATORY)

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

**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**

# 🟢 SECTION 6️⃣ COMPLETE & VERIFIED
---
# SECTION 7️⃣ — ORDER STATUS DASHBOARD

## PHASE 1️⃣ — DYNAMODB METRICS TABLE (FULL)

### 1️⃣ Open DynamoDB Console

#### AWS Console → DynamoDB → Tables → Create table

### 2️⃣ CREATE DYNAMODB METRICS TABLE

#### 1️⃣ Table configuration

| Field         | Value              |
| ------------- | ------------------ |
| Table name    | `CafeOrderMetrics` |
| Partition key | `metric` (String)  |
| Sort key      | ❌ None             |
| Table class   | Standard           |
| Capacity      | On-demand          |
| Encryption    | Default            |

#### Sample items:

```
{ "metric": "TOTAL_ORDERS", "count": 120 }
{ "metric": "TODAY_ORDERS", "count": 25 }
```

Click Create table

**🕐 WAIT until status = ACTIVE**

### 3️⃣ Insert initial items (VERY IMPORTANT)

**Click table → Explore table → Create item**

#### Item 1

```
{
  "metric": {
    "S": "TOTAL_ORDERS"
  },
  "count": {
    "N": "0"
  }
}
```

Click Create item

#### Item 2

```
{
  "metric": {
    "S": "TODAY_ORDERS"
  },
  "count": {
    "N": "0"
  }
}
```

Click Create item


**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---
## PHASE 2️⃣ — VERIFICATION (MANDATORY)

- **Please refer to the Test & Verification documentation for detailed procedures.Please refer to the Test & Verification documentation for detailed procedures.**

## PHASE 3️⃣ — Update CafeOrderProcessor
> **⚠️ This step is inside existing Worker Lambda, NOT API Lambda.**

###  1️⃣ Open Worker Lambda

### AWS Console → Lambda → CafeOrderWorker

###  2️⃣ UPDATE Update CafeOrderProcessor

### 1️⃣ Add this code at the TOP

```
metrics_table = dynamodb.Table("CafeOrderMetrics")
```

### 2️⃣ Add this AFTER successful RDS insert

⚠️ Place it AFTER cursor.execute(...) and commit()

#### Inside your SQS CafeOrderProcessor, after DB insert:

```
metrics_table.update_item(
    Key={"metric": "TOTAL_ORDERS"},
    UpdateExpression="ADD #c :inc",
    ExpressionAttributeNames={"#c": "count"},
    ExpressionAttributeValues={":inc": Decimal(1)}
)
```

#### 📢 your current CafeOrderWorker does NOT update CafeOrderMetrics yet.

Right now it only updates:

```
menu_table = dynamodb.Table(DYNAMODB_TABLE)  # CafeMenu
```

It does NOT reference:

```
CafeOrderMetrics
```

### ✅ What You Need To Add 

#### 1️⃣ Add this near your constants:

```
METRICS_TABLE = "CafeOrderMetrics"
metrics_table = dynamodb.Table(METRICS_TABLE)
```

#### 2️⃣ Inside the loop, after the RDS insert, add:

```
# ---------- UPDATE TOTAL ORDERS ----------
metrics_table.update_item(
    Key={"metric": "TOTAL_ORDERS"},
    UpdateExpression="ADD #c :inc",
    ExpressionAttributeNames={"#c": "count"},
    ExpressionAttributeValues={":inc": Decimal(1)}
)

# ---------- UPDATE TODAY ORDERS ----------
metrics_table.update_item(
    Key={"metric": "TODAY_ORDERS"},
    UpdateExpression="ADD #c :inc",
    ExpressionAttributeNames={"#c": "count"},
    ExpressionAttributeValues={":inc": Decimal(1)}
)
```

#### ✅ Place it right after:

```
cursor.execute(...)
```

#### ✅ Your DynamoDB Items Are Now Correct

You now have:

```
{ "metric": "TOTAL_ORDERS", "count": 0 }
{ "metric": "TODAY_ORDERS", "count": 0 }
```

✔ Perfect

✔ No duplicates

✔ Correct partition keys

### 3️⃣ ✅ FINAL WORKER LAMBDA CODE

#### Below is the FINAL, READY-TO-DEPLOY Worker Lambda code with:

[CafeOrderProcessor.py](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project//☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/Charlie%20Cafe%20-%20Order%20Backend%20Code/CafeOrderProcessor/CafeOrderProcessor.py)

**⚠️ Already Updated, So skip this step**

✔️ RDS remains main source

✔️ DynamoDB gives fast counters

### 3️⃣ IAM ROLE CHECK (DO THIS FIRST)

Make sure Worker Lambda Role has:

### 4️⃣ VERIFY THIS STEP

1️⃣ Place one new order

2️⃣ Go to DynamoDB → CafeOrderMetrics

3️⃣ Open TOTAL_ORDERS

✔ Count increased by 1


**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---
## PHASE 4️⃣ — CREATE ORDER STATUS LAMBDA (NEW)
> **📢 This Lambda ONLY READS DATA.**

### 1️⃣ Create Lambda

#### AWS Console → Lambda → Create function

| Setting        | Value                                   |
| -------------- | --------------------------------------- |
| Name           | `GetOrderStatusLambda`                  |
| Runtime        | Python 3.12                             |
| Execution role | Use existing role                       |
| Role           | Same role as Worker (read-only is fine) |


- **✔️ Click Create function**

### 2️⃣ Lambda Status Order Code

[GetOrderStatusLambda.py](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/Charlie%20Cafe%20-%20Order%20Backend%20Code/GetOrderStatusLambda/GetOrderStatusLambda.py)

### 3️⃣ Attach Layer to Lambda Function

####  1️⃣ Open Lambda Function

* Lambda → Functions → `GetOrderStatusLambda`

#### 2️⃣ Add Layer

* Scroll to **Layers** section
* Click **Add a layer**
* Choose **Custom layers**
* Select:

  * Layer: `pymysql-layer`
  * Version: latest

Click **Add**

### 4️⃣ Move Lambda Into VPC

- AWS Console → Lambda → Your Function

- Go to Configuration

- Open VPC

- Click Edit

- Select:

    - **VPC → same as EC2**

    - **Subnets → PRIVATE subnets (important)**

    - **Security Group → Lambda SG**

    - Save

**⏳ Wait until Lambda status = Active**

### 5️⃣ Test Lambda

#### Test Event Name:

```
Test-GetOrderStatusLambda
```

#### Test event:

```
{}
```

#### Expected:

```
{
  "statusCode": 200,
  "headers": {
    "Access-Control-Allow-Origin": "*",
    "Content-Type": "application/json"
  },
  "body": "{\"metrics\": [{\"metric\": \"TOTAL_ORDERS\", \"count\": \"2\"}], \"recent_orders\": ..........."
}
```

✔ Status code: 200

✔ JSON returned

**✅ PHASE 4️⃣ STATUS**

> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**
---
## PHASE 5️⃣ — API GATEWAY ENDPOINT

👉 Use your EXISTING API

👉 Create a NEW METHOD (GET /order-status) on it

❌ Do NOT create a new API

### 🧠 WHY YOU SHOULD USE THE EXISTING API

#### You already have something like:

```
CafeOrdersAPI
https://xxxxx.execute-api.us-east-1.amazonaws.com/prod
```

#### And inside it you probably have:

```
POST /orders       → CreateOrderLambda
```

#### ✔️ This is CORRECT architecture

One API = One backend system
Multiple resources/methods inside it

**Creating multiple APIs would be:**

❌ Hard to manage

❌ Bad practice

❌ Confusing for frontend

### STRUCTURE (VISUAL)

```
CafeOrdersAPI
│
├── POST /orders
│     └── CreateOrderLambda
│
└── GET /get-order-status
      └── GetOrderStatusLambda
```

✔️ SAME API

✔️ DIFFERENT Lambda functions

### 1️⃣ Open API Gateway

#### API Gateway → Open Your Existing API (example: CafeOrdersAPI) → Resources

### 2️⃣ Create Resource

```
Resource name: get-order-status
Resource path: /get-order-status
```

Click Create resource

### 3️⃣ Create NEW METHOD

Select /get-order-status

Click Create Method

```
GET /get-order-status
```

- **Method:** GET

- **Integration:** Lambda

- **Select GetOrderStatusLambda**

- **Lambda name:** GetOrderStatusLambda

✔️ Enable Lambda proxy integration

Click Create method


### 4️⃣ Enable CORS (VERY IMPORTANT)

Select /get-order-status

Actions → Enable CORS

✔️ GET

✔️ OPTIONS

Click Enable CORS and replace existing CORS headers

### 5️⃣ Deploy API (MOST MISSED STEP 🚨)

API Gateway → Actions → Deploy API

| Field            | Value                 |
| ---------------- | --------------------- |
| Deployment stage | Exist stage             |
| Stage name       | Prod               |
| Description      | Order status endpoint |

Click Deploy

### 6️⃣ Test with API Gateway

#### 1️⃣ Test API Gateway Endpoint (Console Method)

- Go to AWS Console

- Click API Gateway

- Open your API

- Click Resources

- Click /get-order-status

- Click GET

- On the GET method page

- Click the Test button (top right)

- Update Request Body

In Request Body, paste:

```
{}
```

#### 🌐 FINAL API URL

```
GET https://xxxxx.execute-api.us-east-1.amazonaws.com/prod/get-order-status
```

#### 🧪 TEST IT (MUST WORK)

```
curl https://xxxxx.execute-api.us-east-1.amazonaws.com/prod/get-order-status
```

#### ✅ You MUST see JSON like:

```
{
  "metrics": [
    {"metric":"Total Orders","count":15}
  ],
  "recent_orders": [
    {
      "customer_name":"Ali",
      "item":"Coffee",
      "quantity":2,
      "created_at":"2026-01-09 12:30:00"
    }
  ]
}
```

❌ If this does not work → STOP. Fix backend first.

#### Open browser:

```
https://API_ID.execute-api.region.amazonaws.com/prod/get-order-status
```

#### Example;

```
https://a1053skr51.execute-api.us-east-1.amazonaws.com/prod/get-order-status
```

✔ JSON visible

**✅ PHASE 5️⃣ STATUS**

> **🟢 PHASE 5️⃣ COMPLETE & VERIFIED**
---
## PHASE 6️⃣ — FRONTEND ORDER STATUS PAGE

[order-status.html](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order-status/CC%20-%20Order-Status_LIVE%20ADMIN%20DASHBOARD_many%20orders/order-status.html)

**🔁 Replace with your real API Gateway URL**

**✅ PHASE 6️⃣ STATUS**

> **🟢 PHASE 6️⃣ COMPLETE & VERIFIED**
---

## PHASE 7️⃣ — FEATURE VERIFICATION (IMPORTANT)

- **Please refer to the Test & Verification documentation for detailed procedures.Please refer to the Test & Verification documentation for detailed procedures.**

# 🟢 SECTION 7️⃣ COMPLETE & VERIFIED
---
# ☕ SECTION 8️⃣ — Customer Order Tracking, Billing & Receipt (Frontend-Only, Zero-Risk)

## 🔔 PHASE 1️⃣ — Customer Order Tracking (Read-Only Backend, Zero-Risk)

### 1️⃣ — CREATE NEW LAMBDA (READ-ONLY)

#### 1️⃣ Open AWS Lambda

AWS Console → Lambda → Create function

#### 2️⃣ Function Settings

| Field         | Value                         |
| ------------- | ----------------------------- |
| Function name | `CafeOrderStatusLambda`       |
| Runtime       | Python 3.12                   |
| Architecture  | x86_64                        |
| Role          | Same role used for RDS access |

Click Create function

Wait until status = Active

### 2️⃣ — ADD PyMySQL LAYER

- Lambda → Layers → Add layer

- Custom layers

- Select PyMySQLLayer

- Latest version

- Click Add

### 3️⃣ — FINAL LAMBDA CODE (READ-ONLY)

> **⚠️ COPY EXACTLY — do NOT modify**

[CafeOrderStatusLambda.py](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeOrderStatusLambda/CafeOrderStatusLambda.py)

Click Deploy

### 4️⃣ — Move Lambda Into VPC

- AWS Console → Lambda → Your Function

- Go to Configuration

- Open VPC

- Click Edit

- Select:

    - **VPC → same as EC2**

    - **Subnets → PRIVATE subnets (important)**

    - **Security Group → Lambda SG**

    - Save

**⏳ Wait until Lambda status = Active**

### 5️⃣ — TEST LAMBDA (MANDATORY)

- **Please refer to the Test & Verification documentation for detailed procedures.Please refer to the Test & Verification documentation for detailed procedures.**

### 6️⃣ — CREATE API GATEWAY (READ-ONLY)

#### 1️⃣ Open API Gateway 

- Open → REST API 

#### 2️⃣ Create Resource

```
/cafe-order-status
```

#### 3️⃣ Create GET Method

#### Integration:

    - Lambda Function

    - CafeOrderStatusLambda

Enable Lambda Proxy Integration

#### 4️⃣ Enable CORS

- **Allow Origin:** *

- **Allow Methods:** GET

- **Allow Headers:** *

#### 5️⃣ Deploy API

#### Stage name:

```
prod
```

**Copy Invoke URL**

#### Example:

```
https://xxxx.execute-api.us-east-1.amazonaws.com/prod/cafe-order-status
```

### 7️⃣ — TEST API (CRITICAL)

- **Please refer to the Test & Verification documentation for detailed procedures.Please refer to the Test & Verification documentation for detailed procedures.**

### 8️⃣ — CREATE order-status.php

This file is frontend-only and SAFE

[order-receipt.php](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order-status/CC%20-%20Order-Status%20CUSTOMER%20ORDER%20RECEIPT_single%20order/order-receipt.php)

#### ✅ WHAT YOU NEED TO REPLACE (VERY CLEAR)

Inside the PHP file, ONLY replace this line:

```
$apiUrl = "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/cafe-order-status?order_id=$orderId";
```

**🔁 Replace with your real API Gateway URL**

### 9️⃣ — END-TO-END TEST

- **Please refer to the Test & Verification documentation for detailed procedures.Please refer to the Test & Verification documentation for detailed procedures.**

**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**
---
## 🔄 PHASE 3️⃣ — Real Order State Machine (RECEIVED → PREPARING → READY → COMPLETED)

### 🧑‍💻 STEP 1 — MODIFY DATABASE (ONE TIME)

#### 1️⃣ Open RDS → Query Editor (or MySQL client)

Connect to your cafe database.

#### 2️⃣ Verify Columns

```
DESCRIBE orders;
```

#### You MUST see:

- order_id

- status

- total_amount

- updated_at

### 🧠 ORDER ID FORMAT (STANDARD)

```
ORD-YYYYMMDD-XXXX
```

#### Example:

```
ORD-20260114-8392
```

### 🧑‍💻 STEP 2 — TEST ORDER CREATION

- **Please refer to the Test & Verification documentation for detailed procedures.Please refer to the Test & Verification documentation for detailed procedures.**

### 🧑‍💻 STEP 3 — CREATE WORKER (KITCHEN) LAMBDA

#### This simulates:

- Barista

- Kitchen staff

- Admin panel

### 1️⃣ Create Lambda

| Setting | Value                   |
| ------- | ----------------------- |
| Name    | `CafeOrderWorkerLambda` |
| Runtime | Python 3.12             |
| Role    | Same RDS role           |


### 2️⃣ Lambda Code (STRICT COPY)

[CafeOrderWorkerLambda.py](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeOrderWorkerLambda/CafeOrderWorkerLambda.py)

### 3️⃣ Move Lambda Into VPC

- AWS Console → Lambda → Your Function

- Go to Configuration

- Open VPC

- Click Edit

- Select:

    - **VPC → same as EC2**

    - **Subnets → PRIVATE subnets (important)**

    - **Security Group → Lambda SG**

    - Save

**⏳ Wait until Lambda status = Active**    

### 4️⃣ Attach Lambda Layer

- same steps 

### 🌐 STEP 5 — CREATE New Resources API GATEWAY FOR WORKER

#### Resources

```
/order-update
```

- API Method: POST

- Integration: CafeOrderWorkerLambda

- Enable CORS

- Check Box : POST

- Deploy stage: order-update

#### Endpoint 

```
POST /order-update
```

### 🧪 STEP 6 — TEST STATUS FLOW (MANDATORY)

#### 1️⃣ RECEIVED → PREPARING

```
{
  "order_id": "ORD-XXXX",
  "status": "PREPARING"
}
```

#### 2️⃣ PREPARING → READY

#### 3️⃣ READY → COMPLETED

❌ Try skipping → must fail

### 🧑‍💻 STEP 7 — UPDATE ORDER STATUS LAMBDA (READ REAL STATUS)

#### Replace SELECT query:

> **🔁 Replace ONLY the SQL + response logic**

> **(keep env vars, VPC, API Gateway exactly as-is)**

```
SELECT order_id, table_number, item, quantity, total_amount, status, created_at
FROM orders
WHERE order_id=%s
```
#### ✅ FINAL — Order Status Lambda

```
import json
import os
import pymysql

def get_connection():
    return pymysql.connect(
        host=os.environ["DB_HOST"],
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASS"],
        database=os.environ["DB_NAME"],
        cursorclass=pymysql.cursors.DictCursor
    )

def lambda_handler(event, context):
    params = event.get("queryStringParameters") or {}
    order_id = params.get("order_id")

    if not order_id:
        return {
            "statusCode": 400,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": "order_id required"})
        }

    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("""
            SELECT
                order_id,
                table_number,
                customer_name,
                item,
                quantity,
                total_amount,
                status,
                created_at
            FROM orders
            WHERE order_id = %s
        """, (order_id,))

        order = cursor.fetchone()

        if not order:
            return {
                "statusCode": 404,
                "headers": {"Access-Control-Allow-Origin": "*"},
                "body": json.dumps({"error": "Order not found"})
            }

        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Content-Type": "application/json"
            },
            "body": json.dumps({
                "order": order
            }, default=str)
        }

    finally:
        cursor.close()
        conn.close()
```
#### ⚠️ Already Added And CafeOrderStatusLambda.py code is updated... Skip this step

[CafeOrderStatusLambda.py](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeOrderStatusLambda.py)

### 🧑‍💻 STEP 8 — order-receipt.php

#### Add billing & live status:

#### 📌 Requirement: Your backend must expose a GET order status API like:

```
GET https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/cafe-order-status?order_id=ORD-XXXX
```

#### 📁 WHERE THIS FILE BELONGS

```
/web
 ├── order.php
 ├── order-receipt.php   ✅ (THIS FILE)
 └── index.html
```

#### Code order-receipt.php

```
<p><strong>Total:</strong> $<?= $data['order']['total_amount'] ?></p>
<p><strong>Status:</strong>
<span class="badge bg-success"><?= $data['order']['status'] ?></span>
</p>
```

**Print button already exists ✅**

**⚠️ STEP 8 is ALREADY implemented in your order-receipt.php.You do NOT need structural changes.**

[order-receipt.php](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order-status/CC%20-%20Order-Status%20CUSTOMER%20ORDER%20RECEIPT_single%20order/order-receipt.php)

**☕ You now have a REAL SaaS-LEVEL CUSTOMER ORDER TRACKING SYSTEM**

**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---
## 🔔 PHASE 4️⃣ — Customer Order Tracking, Billing & Receipt (Frontend-Only, Zero-Risk)

### 🧩 STEP 1 — DATABASE (VERIFY ONLY)

#### 1️⃣ Open RDS → Query Editor (or MySQL client)

#### 2️⃣ Run:

```
use cafe_db;
```

```
DESCRIBE orders;
```

❌ Do NOT drop or modify existing columns

✅ Only verify these exist

#### Required columns in orders table

```
order_id        VARCHAR(40) PRIMARY KEY
customer_name  VARCHAR(100)
table_number   INT
item            VARCHAR(50)
quantity        INT
total_amount   DECIMAL(10,2)
status          VARCHAR(20)
created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
```

✔ If these already exist → DO NOTHING

✔ If order_id exists → must be unique

### 🧩 STEP 2 — BACKEND API (READ-ONLY)

#### Endpoint

```
GET /order-receipt.php?order_id=ORD-XXXX
```

#### Lambda responsibility

- Fetch order by order_id

- Return JSON

- No updates

- No auth

#### Expected JSON response (MANDATORY)

```
{
  "order": {
    "order_id": "ORD-20260114-8392",
    "customer_name": "John",
    "table_number": 4,
    "item": "Latte",
    "quantity": 2,
    "total_amount": 8.00,
    "status": "PREPARING",
    "created_at": "2026-01-14 10:42:00"
  }
}
```

✔ If this API already exists → DO NOTHING

✔ If not → create a new Lambda (read-only)

### 🧩 STEP 3 — ORDER PAGE (MINIMAL CHANGE)

#### File: order.php

After successful order placement, backend already returns order_id.

#### Add this line ONLY (no other change):

```
echo "<a class='btn btn-success mt-2'
      href='order-status.php?order_id={$order_id}'>
      📦 Track Your Order
      </a>";
```

✔ Existing order logic untouched

✔ This only adds a link

**⚠️ STEP 3 is ALREADY implemented in your order.php.You do NOT need structural changes.**

[order.php](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order.php/orders.php)

### 🧩 STEP 4 — CREATE CUSTOMER TRACKING PAGE

#### File name (NEW)

```
order-receipt.php
```

#### Location

```
/web/order-receipt.php
```

### 🧩 STEP 5 — FINAL order-receipt.php (LATEST VERSION)

**⚠️ STEP 5 is ALREADY implemented in your order-receipt.php.You do NOT need structural changes.**

[order-receipt.php](./AWS%20Charlie%20Cafe%20Project%20DOCs/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order-status/CC%20-%20Order-Status%20CUSTOMER%20ORDER%20RECEIPT_single%20order/order-receipt.php)

**✅ PHASE 4️⃣ STATUS**

> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**

# 🟢 SECTION 8️⃣ COMPLETE & VERIFIED
---

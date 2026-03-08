# ☕ AWS CAFE — CloudFront-EC2-API GATEWAY- ALB-DUAL ARchitecture


### 🎯 SECTION GOAL (READ FIRST)

You will run TWO architectures in parallel, both valid in real companies:

### 🔹 Architecture A (Traditional Web / Lift & Shift)

```
User
 ↓
CloudFront
 ↓
Application Load Balancer
 ↓
EC2 (Apache + PHP)
 ↓
API Gateway → Lambda → SQS → Worker → DB
```

### 🔹 Architecture B (Serverless API-First)

```
User
 ↓
CloudFront
 ↓
API Gateway
 ↓
Lambda → SQS → Worker → DB
```

✔ Same backend

✔ Same APIs

✔ Same order flow

✔ Different entry points

This teaches REAL AWS decision-making, not tutorials.


## 🌍 PHASE 1 — PART A — CloudFront + ALB + EC2

#### (Primary Website Architecture)

### 🔐 PREREQUISITES (DO NOT SKIP)

#### Confirm ALL of these exist:

| Resource              | Status         |
| --------------------- | -------------- |
| EC2 instance          | Running        |
| Apache installed      | ✅              |
| PHP installed         | ✅              |
| ALB created           | ✅              |
| Target group attached | ✅              |
| Domain optional       | ❌ not required |

### 🟩 STEP 1 — PREPARE EC2 APACHE APP

#### 1️⃣ SSH into EC2

```
ssh ec2-user@<EC2-PUBLIC-IP>
```

#### 2️⃣ Confirm Apache is running

```
sudo systemctl status httpd
```

#### If stopped:

```
sudo systemctl start httpd
```

```
sudo systemctl enable httpd
```

#### 3️⃣ Web root location

```
cd /var/www/html
```

#### Your files:

```
index.php
order.php
order-status.php
```

### 🟩 STEP 2 — CREATE APPLICATION LOAD BALANCER (ALB)

#### 1️⃣ Go to AWS Console → EC2 → Load Balancers

Click Create load balancer

#### 2️⃣ Select

```
Application Load Balancer
```

#### 3️⃣ Basic configuration

| Field           | Value           |
| --------------- | --------------- |
| Name            | cafe-alb        |
| Scheme          | Internet-facing |
| IP address type | IPv4            |

#### 4️⃣ Network mapping

- VPC → same as EC2

- Subnets → at least 2 public subnets

#### 5️⃣ Security Group

#### Inbound rules:

| Type | Port | Source    |
| ---- | ---- | --------- |
| HTTP | 80   | 0.0.0.0/0 |


#### 6️⃣ Target Group

#### Create new target group:

| Field             | Value        |
| ----------------- | ------------ |
| Target type       | Instance     |
| Protocol          | HTTP         |
| Port              | 80           |
| Health check path | `/index.php` |

Register EC2 instance ✔

#### 7️⃣ Create ALB

#### Wait until:

```
State: Active
Health: Healthy
```

#### 📌 Copy:

```
ALB DNS name
```

### 🟩 STEP 3 — TEST ALB DIRECTLY

#### Open browser:

```
http://<ALB-DNS-NAME>
```

✔ Your café website must load

❌ If not → stop here and fix Apache/SG

---

## 🌍 PHASE 2 — PART B — CLOUDFRONT + ALB (EC2 WEBSITE)

### 🟦 STEP 4 — CREATE CLOUDFRONT DISTRIBUTION (FOR EC2)

### 1️⃣ AWS Console → CloudFront → Create distribution

### 2️⃣ ORIGIN SETTINGS

| Field         | Value            |
| ------------- | ---------------- |
| Origin domain | **ALB DNS NAME** |
| Origin type   | Custom           |
| Protocol      | HTTP only        |

### 3️⃣ DEFAULT CACHE BEHAVIOR

| Field                 | Value                    |
| --------------------- | ------------------------ |
| Viewer protocol       | Redirect HTTP to HTTPS   |
| Allowed methods       | GET, HEAD                |
| Cache policy          | Managed-CachingOptimized |
| Origin request policy | Managed-AllViewer        |


### 4️⃣ Create Distribution

⏳ Wait 10–15 minutes

#### Copy:

```
CloudFront Domain Name
```

### 🟦 STEP 5 — TEST EC2 VIA CLOUDFRONT

#### Open:

```
https://<cloudfront-domain>
```

✔ Page loads

✔ HTTPS enabled

✔ Cached globally

---

## 🌍 PHASE 3 — CLOUDFRONT + API GATEWAY (SERVERLESS API)

### 🟨 STEP 6 — CREATE SECOND CLOUDFRONT ORIGIN (API)

#### Edit existing CloudFront distribution

OR create new one (recommended for learning)

#### Origin configuration

| Field         | Value                                      |
| ------------- | ------------------------------------------ |
| Origin domain | `xxxx.execute-api.us-east-1.amazonaws.com` |
| Origin type   | Custom                                     |
| Protocol      | HTTPS only                                 |

#### Cache behavior (API)

#### Path pattern:

```
/dev/*
```

| Field                 | Value                   |
| --------------------- | ----------------------- |
| Allowed methods       | GET, POST, OPTIONS      |
| Cache policy          | Managed-CachingDisabled |
| Origin request policy | Managed-AllViewer       |
| Viewer protocol       | HTTPS only              |

✔ This ensures POST orders are NOT cached

### 🟨 STEP 7 — DEPLOY CLOUDFRONT CHANGES

#### Wait until:

```
Status: Deployed
```

---

## 🌍 PHASE 4 — UPDATE EC2 WEBSITE TO USE CLOUDFRONT API

### Edit order.php

#### ❌ OLD:

```
$apiUrl = "https://xxxx.execute-api.us-east-1.amazonaws.com/dev/orders";
```

#### ✅ NEW:

```
$apiUrl = "https://<cloudfront-api-domain>/dev/orders";
```

#### Restart Apache:

```
sudo systemctl restart httpd
```

---

## 🌍 PHASE 5 — OPTIONAL API CACHING (GET ONLY)

### Example: /menu

### Create cache behavior:

```
/dev/menu
```

| Setting      | Value                    |
| ------------ | ------------------------ |
| Cache policy | Managed-CachingOptimized |
| TTL          | Default                  |

#### ⚠️ NEVER cache:

- POST

- PUT

- ORDER APIs

### 🧪 FINAL TESTING (MANDATORY)

#### ✅ Test 1 — Website

```
https://<cloudfront-ec2-domain>
```

#### ✅ Test 2 — Order Placement

Submit order → success message

#### ✅ Test 3 — Track Order

```
order-status.php?order_id=ORD-XXXX
```

#### ✅ Test 4 — Backend

- SQS message consumed

- Worker Lambda logs OK

- DB updated

### 🧠 WHY COMPANIES USE BOTH

| Use Case       | Architecture             |
| -------------- | ------------------------ |
| Legacy PHP     | CloudFront + ALB + EC2   |
| Mobile APIs    | CloudFront + API Gateway |
| High traffic   | CloudFront               |
| Cost optimized | API Gateway              |
| Complex logic  | EC2                      |

You now understand enterprise AWS, not tutorials.

---
# AWS CAFE LAB

> **AUTHOR & ARCHITECTURE DESIGNER:** CHARLIE

# 🔒 SECTION 7 — AWS CAFE CI/CD (CodePipeline)

### 🎯 Goal of This Section (Read First)

#### Whenever you push code to GitHub, AWS should:

1️⃣ Automatically build your Lambda code

2️⃣ Package it

3️⃣ Deploy it to Lambda

4️⃣ Without manual ZIP uploads

This is real-world DevOps used in production.

### 🧠 FINAL ARCHITECTURE (MENTAL MODEL)

```
GitHub (Code Push)
      ↓
CodePipeline
      ↓
CodeBuild (zip code)
      ↓
AWS Lambda (deploy)
```



# PHASE 1 — CI/CD (CodePipeline)

## 1️⃣ Create GitHub Repository

### 1.1 Create Repository

- Go to GitHub

- Click New Repository

- Name it:

```
aws-cafe-project
```

- Visibility: Private or Public

- Click Create

### 1.2 Repository Folder Structure (MUST MATCH)

#### Inside your repo, create this exact structure:

```
aws-cafe-project/
│
├── lambda-api/
│   ├── app.py
│   ├── requirements.txt
│
├── lambda-worker/
│   ├── worker.py
│   ├── requirements.txt
│
├── buildspec.yml
```

### 1.3 Example Files (IMPORTANT)

#### lambda-api/app.py

```
def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "body": "API Lambda Deployed Successfully"
    }
```

#### lambda-api/requirements.txt

```
pymysql
```

#### lambda-worker/worker.py

```
def lambda_handler(event, context):
    print("Worker Lambda running")
```

#### lambda-worker/requirements.txt

```

```



## 2️⃣  — CREATE IAM ROLE FOR CODEBUILD (SECURITY)

### 2.1 Go to IAM → Roles → Create role

- Trusted entity: AWS service

- Use case: CodeBuild

- Click Next

### 2.2 Attach Policies

#### Attach these 3 policies:

✅ AWSCodeBuildDeveloperAccess

✅ AWSLambda_FullAccess

✅ AmazonS3FullAccess

  #### 🔐 This allows CodeBuild to:

  - Build code

  - Store artifacts

  - Update Lambda

Click Create role

#### 📌 Name:

```
CodeBuildCafeRole
```

## 3️⃣  — CREATE CODEBUILD PROJECT

### 3.1 Open CodeBuild → Create build project

#### Basic Info

| Field        | Value            |
| ------------ | ---------------- |
| Project name | `cafe-api-build` |
| Description  | Build Lambda API |


#### Source Section

| Field           | Value     |
| --------------- | --------- |
| Source provider | GitHub    |
| Repository      | Your repo |
| Branch          | main      |

Authorize GitHub when asked ✅

#### Environment Section

| Setting           | Value               |
| ----------------- | ------------------- |
| Environment image | Managed             |
| OS                | Amazon Linux        |
| Runtime           | Python              |
| Version           | **3.12**            |
| Privileged        | ❌ Disabled          |
| Service role      | `CodeBuildCafeRole` |

#### Buildspec

Choose:

```
Use a buildspec file
```

File name:

```
buildspec.yml
```

### 3.2 FINAL buildspec.yml (ROOT of repo)

```
version: 0.2

phases:
  install:
    commands:
      - cd lambda-api
      - pip install -r requirements.txt -t .

  build:
    commands:
      - zip -r function.zip .

artifacts:
  files:
    - lambda-api/function.zip
```

**⚠️ This file MUST be in repo root**

## 4️⃣ - CREATE API LAMBDA FUNCTION (ONE TIME)

### 4.1 Lambda → Create function

| Field       | Value             |
| ----------- | ----------------- |
| Name        | `cafe-api-lambda` |
| Runtime     | Python 3.12       |
| Permissions | Default           |

**⚠️ Do NOT upload code manually**


## 5️⃣ - CREATE CODEPIPELINE (MAIN PART)

### 5.1 Go to CodePipeline → Create pipeline

#### Pipeline settings

| Field        | Value               |
| ------------ | ------------------- |
| Name         | `cafe-api-pipeline` |
| Service role | New role            |

### 5.2 Source Stage

| Field            | Value              |
| ---------------- | ------------------ |
| Source provider  | GitHub (Version 2) |
| Repo             | aws-cafe-project   |
| Branch           | main               |
| Change detection | Automatic          |

### 5.3 Build Stage

| Field          | Value            |
| -------------- | ---------------- |
| Build provider | CodeBuild        |
| Project        | `cafe-api-build` |


### 5.4 Deploy Stage

| Field           | Value             |
| --------------- | ----------------- |
| Deploy provider | AWS Lambda        |
| Function name   | `cafe-api-lambda` |
| Input artifact  | BuildArtifact     |

Click Create Pipeline

## 6️⃣ - TEST THE PIPELINE (CRITICAL)

### 6.1 Make a Code Change

#### Edit:

```
lambda-api/app.py
```

#### Change text:

```
"API Lambda Updated via CI/CD"
```

#### Push to GitHub:

```
git add .
git commit -m "Test CI/CD"
git push origin main
```

### 6.2 Watch Pipeline

- Go to CodePipeline

#### You should see:

Source ✅

Build ✅

Deploy ✅

### 6.3 Verify Lambda

- Open cafe-api-lambda

- Click Test

#### Output:

```
API Lambda Updated via CI/CD
```

🎉 CI/CD WORKING

## 7️⃣ - REPEAT FOR WORKER LAMBDA

### Repeat Steps 3 → 6 with changes:

| Item              | Value                |
| ----------------- | -------------------- |
| CodeBuild project | `cafe-worker-build`  |
| Lambda name       | `cafe-worker-lambda` |
| Folder            | `lambda-worker`      |
| buildspec.yml     | adjust cd path       |

---
### 🧠 WHY THIS DESIGN IS CORRECT (REAL WORLD)

✔ Separate pipelines per Lambda

✔ GitHub as source of truth

✔ No manual uploads

✔ Easy rollback

✔ Industry standard

### ✅ FINAL CHECKLIST

| Item                | Status |
| ------------------- | ------ |
| GitHub repo         | ✅      |
| buildspec.yml       | ✅      |
| CodeBuild role      | ✅      |
| CodeBuild project   | ✅      |
| CodePipeline        | ✅      |
| Lambda deploy       | ✅      |
| Auto deploy on push | ✅      |

---
## 📢 SECTION 3 — AWS Cafe PRODUCTION

## PHASE 1 — PRODUCTION (us‑west‑2)

## Create AMI

* Name: `CafeDevWebAMI`

## Launch Prod EC2

* Region: us‑west‑2
* From AMI
* New VPC/Subnet

---

## 📢 SECTION 13 — BILLING ALERTS & BUDGETS

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

## 📢 SECTION 14 — TESTING

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
# AWS Foundations to Advanced Hands-on Lab (Beginner → Advanced)

> **Role**: Wise AWS Trainer
>
> **Student Level**: Beginner (Linux, Bash, Python, AWS)
>
> **Goal**: Build strong fundamentals in Linux, Bash, Python **and** learn real AWS services (Route 53, Secrets Manager, KMS, API Gateway) through **one connected hands-on lab**.

---

## 📘 PART 1: FOUNDATIONAL THEORY (MUST READ BEFORE LAB)

### 1️⃣ Linux Fundamentals (Cloud Engineer View)

Linux is the **operating system of the cloud**. Almost every EC2, container, and serverless backend touches Linux.

**Core Concepts**
- File system: `/`, `/etc`, `/var`, `/home`, `/tmp`
- Users & permissions: `rwx`, `chmod`, `chown`
- Processes & services: `ps`, `top`, `systemctl`
- Networking basics: `ip`, `ss`, `curl`, `ping`

**Why Linux matters in AWS**
- EC2 runs Linux
- Automation scripts run on Linux
- Security hardening happens on Linux

---

### 2️⃣ Bash Scripting (Cloud Automation Brain)

Bash is **glue language** of cloud engineering.

**What Bash does**
- Automates Linux tasks
- Calls AWS CLI commands
- Runs cron jobs
- Manages logs and backups

**Key Concepts**
- Variables: `VAR=value`
- Conditionals: `if`, `else`
- Loops: `for`, `while`
- Command substitution: `$(command)`

**Why Bash before Python?**
- Bash is faster for system-level automation
- AWS CLI integrates naturally with Bash

---

### 3️⃣ Python Fundamentals (Cloud Logic Language)

Python is used when logic becomes complex.

**Used in AWS for**
- Lambda functions
- API backend logic
- Automation with `boto3`

**Key Concepts**
- Variables & data types
- Functions
- Exception handling
- JSON handling

---

## ☁️ PART 2: AWS SERVICES THEORY (SIMPLE & CLEAR)

### 1️⃣ Amazon Route 53 (DNS Service)

**What it is**
- Internet phonebook
- Converts domain → IP

**Key Concepts**
- Hosted Zones
- Record types: A, CNAME, Alias
- Health checks

**Why it matters**
- Controls traffic
- High availability

---

### 2️⃣ AWS Secrets Manager

**Problem it solves**
- Never store passwords in code

**Stores**
- Database passwords
- API keys
- Tokens

**Benefits**
- Automatic rotation
- Encryption
- IAM-controlled access

---

### 3️⃣ AWS KMS (Key Management Service)

**Purpose**
- Encryption key manager

**Used by**
- Secrets Manager
- S3
- EBS
- RDS

**Key Types**
- AWS managed keys
- Customer managed keys

---

### 4️⃣ Amazon API Gateway

**What it does**
- Creates REST APIs
- Front door for backend services

**Supports**
- Lambda
- HTTP endpoints
- Authentication

---

## 🧪 PART 3: ONE COMPLETE HANDS-ON LAB (BASIC → ADVANCED)

### 🎯 LAB GOAL
Build a **secure API-based application** that:
- Runs on Linux EC2
- Uses Bash & Python
- Stores secrets securely
- Uses encryption
- Exposes API via API Gateway
- Uses Route 53 for DNS

---

## 🧩 LAB ARCHITECTURE (AWS OFFICIAL SERVICES)

```
User
  |
  |  (HTTPS)
  v
Amazon Route 53
  |
  v
Amazon API Gateway
  |
  v
AWS Lambda (Python)
  |
  |---> AWS Secrets Manager
  |          |
  |          v
  |        AWS KMS
  |
  v
Amazon EC2 (Linux)
        |
        v
     Bash Scripts
```

*(All services use AWS Official Architecture Symbols conceptually)*

---

## 🔹 STEP 1: EC2 LINUX SETUP (FOUNDATION)

- Launch EC2 (Amazon Linux 2)
- Connect via SSH

```bash
sudo yum update -y
sudo yum install python3 -y
```

Verify:
```bash
python3 --version
```

---

## 🔹 STEP 2: BASH SCRIPT PRACTICE

Create a system info script:

```bash
#!/bin/bash
DATE=$(date)
HOST=$(hostname)
UPTIME=$(uptime)

echo "Date: $DATE"
echo "Host: $HOST"
echo "Uptime: $UPTIME"
```

Make executable:
```bash
chmod +x sysinfo.sh
./sysinfo.sh
```

---

## 🔹 STEP 3: CREATE SECRET (SECURE WAY)

- Go to **Secrets Manager**
- Store DB credentials
- Enable **KMS encryption**

Example secret JSON:
```json
{
  "username": "admin",
  "password": "StrongPassword123"
}
```

---

## 🔹 STEP 4: PYTHON ACCESS SECRET

Install SDK:
```bash
pip3 install boto3
```

Python script:
```python
import boto3, json

client = boto3.client('secretsmanager')
secret = client.get_secret_value(SecretId='my-db-secret')
data = json.loads(secret['SecretString'])
print(data['username'])
```

---

## 🔹 STEP 5: CREATE LAMBDA FUNCTION

- Runtime: Python 3.10
- Role: Access Secrets Manager

Lambda logic:
```python
def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "body": "Secure API Working"
    }
```

---

## 🔹 STEP 6: API GATEWAY

- Create REST API
- Connect to Lambda
- Enable HTTPS
- Deploy stage

Test URL:
```
https://api-id.execute-api.region.amazonaws.com/prod
```

---

## 🔹 STEP 7: ROUTE 53 DNS

- Create hosted zone
- Create **Alias record**
- Point domain → API Gateway

---

## 🔐 SECURITY BEST PRACTICES USED

- No hardcoded secrets
- KMS encryption
- IAM least privilege
- HTTPS only

---

## 🚀 WHAT YOU LEARNED

✔ Linux administration
✔ Bash automation
✔ Python AWS SDK
✔ Secure secrets handling
✔ Encryption with KMS
✔ API creation
✔ DNS routing

---

## 📌 PART 4: ADVANCED SECURITY, LOGGING & AUTOMATION (STEP-BY-STEP, NO SKIPS)

This section **extends the same lab** and shows **exact console navigation + configuration steps**.

---

## 🔐 A. AWS KMS ENCRYPTION (DETAILED)

### A1️⃣ Create Customer Managed KMS Key

**AWS Console → Services → KMS**
1. Click **Create key**
2. Key type: **Symmetric**
3. Key usage: **Encrypt and decrypt**
4. Advanced options: **KMS**
5. Click **Next**

### A2️⃣ Configure Key
1. Alias: `lab-secrets-key`
2. Description: `KMS key for Secrets Manager and Lambda`
3. Click **Next**

### A3️⃣ Key Permissions
- Key administrators: **Your IAM admin user**
- Key users:
  - Lambda execution role
  - EC2 role (if used)

Click **Finish**

---

## 🔐 B. IAM LEAST PRIVILEGE (NO ADMIN ACCESS)

### B1️⃣ Create IAM Policy for Secrets Access

**IAM → Policies → Create policy → JSON**

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "arn:aws:secretsmanager:*:*:secret:my-db-secret*"
    }
  ]
}
```

- Name: `SecretsManagerReadOnlyPolicy`

---

### B2️⃣ Create Lambda IAM Role

**IAM → Roles → Create role**
1. Trusted entity: **AWS service**
2. Use case: **Lambda**
3. Attach policies:
   - `SecretsManagerReadOnlyPolicy`
   - `AWSLambdaBasicExecutionRole`
4. Role name: `LambdaSecureRole`

---

## 🔒 C. HTTPS ONLY (API GATEWAY)

### C1️⃣ Enforce HTTPS

API Gateway **automatically enforces HTTPS**.

### C2️⃣ Disable HTTP Access (Custom Domain)

**API Gateway → Custom domain names**
1. Create domain
2. Attach ACM SSL certificate
3. Security policy: **TLS 1.2**

---

## 📊 D. CLOUDWATCH LOGGING (FULL VISIBILITY)

### D1️⃣ Enable API Gateway Logs

**API Gateway → Your API → Stages → prod**
1. Logs/Tracing tab
2. Enable:
   - CloudWatch Logs
   - Log level: INFO
   - Full request/response logging
3. Save

---

### D2️⃣ Lambda Logging

Inside Lambda code:

```python
import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

logger.info("Lambda started")
```

Logs appear in **CloudWatch → Log groups → /aws/lambda/**

---

## 🔑 E. API AUTHENTICATION (API KEY)

### E1️⃣ Create API Key

**API Gateway → API Keys → Create**
- Name: `lab-api-key`

---

### E2️⃣ Usage Plan

**API Gateway → Usage Plans → Create**
1. Name: `BasicUsagePlan`
2. Throttling: Enable
3. Associate API stage: `prod`
4. Attach API Key

---

### E3️⃣ Enforce API Key on Method

**API → Resources → Method → Method Request**
- API Key Required: **true**

---

## 🔄 F. CI/CD PIPELINE (BASIC)

### F1️⃣ CodeCommit Repository

**AWS Console → CodeCommit → Create repository**
- Name: `lambda-secure-api`

---

### F2️⃣ CodeBuild

**CodeBuild → Create build project**
- Source: CodeCommit
- Environment: Amazon Linux
- Buildspec:

```yaml
version: 0.2
phases:
  build:
    commands:
      - zip function.zip lambda_function.py
artifacts:
  files:
    - function.zip
```

---

### F3️⃣ CodePipeline

**CodePipeline → Create pipeline**
1. Source: CodeCommit
2. Build: CodeBuild
3. Deploy: Lambda

---

## 🔁 G. CONVERT EC2 LOGIC TO LAMBDA (SERVERLESS)

### G1️⃣ Move Bash Logic to Python

Old EC2 Bash logic → Python Lambda logic

Example:

```python
import platform

def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "body": f"Running on {platform.system()}"
    }
```

---

### G2️⃣ Remove EC2 Dependency

- Stop EC2 instance
- Validate Lambda-only flow
- Reduce cost to near-zero

---

## 🧠 FINAL OUTCOME

You now built:
- 🔐 Encrypted system (KMS)
- 👮 Least-privilege IAM
- 🔒 HTTPS-secured API
- 📊 Full logging
- 🔑 Authenticated access
- 🔄 Automated CI/CD
- ☁️ Serverless architecture

---

> **Wisdom**: You didn’t learn AWS services — you learned **how real cloud systems are built**.

---

✍️ *End of complete advanced markdown.md lab guide*


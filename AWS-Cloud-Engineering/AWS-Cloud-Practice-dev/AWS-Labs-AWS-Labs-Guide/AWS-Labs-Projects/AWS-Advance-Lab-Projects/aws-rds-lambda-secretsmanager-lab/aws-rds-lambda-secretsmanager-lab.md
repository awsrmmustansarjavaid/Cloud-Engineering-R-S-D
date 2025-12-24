
# AWS Advanced Hands-On Lab (Beginner → Advanced)
## RDS MySQL + Secrets Manager + Lambda (Python) + CloudWatch

---

## 1. Lab Objective

This lab teaches you **real-world AWS DevOps practices** using:

- Amazon RDS (MySQL)
- AWS Secrets Manager
- AWS Lambda (Python)
- Amazon CloudWatch Logs & Alarms

You will **secure credentials**, **automate database access**, and **monitor your application**.

---

## 2. Architecture Overview

User/Event  
→ AWS Lambda (Python)  
→ AWS Secrets Manager  
→ Amazon RDS MySQL  
→ CloudWatch Logs  
→ CloudWatch Alarms  

### Architecture Diagram

![AWS Architecture Hand-on Lab](./aws-rds-lambda-secretsmanager-lab.jpeg)
---

## 3. Prerequisites

- AWS Account
- Basic AWS Console knowledge
- No prior Python required

---

## 4. Phase 1 – Amazon RDS MySQL

### Step 2: Create Database

1. Go to **RDS → Create database**
2. Engine: **MySQL**
3. Template: **Free Tier**
4. DB Identifier:
   ```
   app-mysql-db
   ```
5. Credentials Settings
    - **Master username:** admin
    - **Credentials management:** Managed in AWS Secrets Manager - most secure
    - **Select the encryption key:** aws/secretsmanager (default)
6. Instance: `db.t3.micro`
7. Storage: 20 GB
8. Public access: **No**
9. Security Group:
   - Allow inbound **3306** from Lambda SG only

---


## 5. Phase 2 – AWS Secrets Manager

### Step 1: Create Secret

#### ✅ METHOD 1 (BEST & RECOMMENDED):
##### Create Secret Using RDS Integration
##### 📌 When to Use

- ✔ Production
- ✔ Beginner friendly
- ✔ Auto-sync with RDS
- ✔ Supports rotation easily

1. Open **AWS Console → Secrets Manager**
2. Click **Store a new secret**
3. Choose **Credentials for RDS database**

##### ✔ This tells AWS:

> **“This secret is for a database”**

4. Enter Credentials

##### Fill in:

```
| Field           | Value              |
| --------------- | ------------------ |
| Username        | admin              |
| Password        | StrongPassword123! |
| Database engine | MySQL              |
```
###### ⚠️ Must match RDS master username/password

5. Select RDS Database

##### ✔ AWS will automatically attach:

- DB endpoint

- Port

- Engine

6. Secret name:

###### Use a clean DevOps-style name:

   ```
   rds/mysql/app/credentials
   ```

7. (Optional) Rotation

For now:

```
Disable automatic rotation
```

8. **Store Secret :** Click Store

#### ✅ Done.

#### 🔎 What AWS Stores Internally (Auto JSON)

```json
{
  "username": "admin",
  "password": "StrongPassword123!",
  "engine": "mysql",
  "host": "app-mysql-db.xxxxxx.region.rds.amazonaws.com",
  "port": 3306,
  "dbname": "appdb"
}
```

###### 📌 This is exactly what Lambda reads.

#### ✅ METHOD 2 (ADVANCED / MANUAL):
##### Create Secret Manually (DevOps-Style)
##### 📌 When to Use

- ✔ Lambda labs
- ✔ Multi-DB environments
- ✔ Custom apps
- ✔ CI/CD pipelines

1. Open **AWS Console → Secrets Manager**
2. **Choose Secret Type:**  Other type of secret
3. Add Key-Value Pairs

##### Paste: 

```
{
  "username": "admin",
  "password": "StrongPassword123!",
  "host": "app-mysql-db.xxxxxx.region.rds.amazonaws.com",
  "port": 3306,
  "dbname": "appdb"
}
```

4. Secret Name:

###### Use a clean DevOps-style name:

```
rds/mysql/app/credentials
```

5. **Store Secret :** Click Store

6. **🧪 VERIFY SECRET (IMPORTANT)**

#### Steps

- Open the secret

- Click Retrieve secret value

- Confirm all fields are correct

**✔ This is what your Lambda code will read.**


#### 🐍 How Lambda Uses This Secret (Python Reminder)

```
response = secrets_client.get_secret_value(
    SecretId='rds/mysql/app/credentials'
)

secret = json.loads(response['SecretString'])
```
##### Then

```
secret['username']
secret['password']
secret['host']
secret['port']
secret['dbname']
```

##### 🚫 COMMON MISTAKES (VERY IMPORTANT)

```
| Mistake              | Result              |
| -------------------- | ------------------- |
| Wrong password       | DB connection fails |
| Wrong endpoint       | Timeout             |
| Lambda no permission | AccessDenied        |
| Port missing         | Connection error    |
| DB name missing      | Query failure       |
```

##### 🔐 IAM PERMISSION REQUIRED

##### Your Lambda must have:

```
{
  "Effect": "Allow",
  "Action": "secretsmanager:GetSecretValue",
  "Resource": "*"
}
```

###### Note: (Or restricted to that secret ARN)

#### ✅ Done.

---

## 6. Phase 3 – IAM Role

### Step 3: Create IAM Role for Lambda

Permissions:
- AWSLambdaBasicExecutionRole
- SecretsManagerReadWrite

Purpose:
- Read secrets
- Write logs
- Access AWS services securely

---

## 7. Phase 4 – AWS Lambda (Python)

### Step 4: Create Lambda Function

- Name: `rds-mysql-automation`
- Runtime: **Python 3.10**
- Execution role: IAM role created earlier

---

## 8. Python Lambda Code

### Full Python Script

```python
import json
import boto3
import pymysql
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

secrets_client = boto3.client('secretsmanager')

def get_secret():
    response = secrets_client.get_secret_value(
        SecretId='rds/mysql/app/credentials'
    )
    secret = json.loads(response['SecretString'])
    return secret

def lambda_handler(event, context):
    secret = get_secret()

    connection = pymysql.connect(
        host=secret['host'],
        user=secret['username'],
        password=secret['password'],
        database=secret['dbname'],
        port=3306
    )

    with connection.cursor() as cursor:
        cursor.execute("SELECT NOW();")
        result = cursor.fetchone()

    logger.info(f"Database Time: {result}")
    connection.close()

    return {
        'statusCode': 200,
        'body': json.dumps('Success')
    }
```

---

## 9. Python Code Explanation

- `boto3`: AWS SDK for Python
- `pymysql`: MySQL client
- Secrets are fetched dynamically
- Logs automatically go to CloudWatch

---

## 10. Phase 5 – CloudWatch Logs

### View Logs

1. Open **CloudWatch → Log Groups**
2. Select:
   ```
   /aws/lambda/rds-mysql-automation
   ```

Logs show:
- DB connection success
- Query output
- Errors

---

## 11. Phase 6 – CloudWatch Alarms

### Create Alarm

Metric:
- Lambda Errors

Condition:
- Errors ≥ 1

Purpose:
- Detect DB failures
- Detect permission issues

---

## 12. Common Errors & Fixes

| Issue | Cause | Fix |
|-----|-----|-----|
| Timeout | Lambda not in VPC | Attach VPC |
| AccessDenied | IAM issue | Add SecretsManager permission |
| DB error | SG blocked | Allow port 3306 |

---

## 13. Advanced Practice Tasks

- Insert records using Lambda
- Enable secret rotation
- Add EventBridge trigger
- Use RDS Proxy
- Encrypt RDS with KMS

---

## 14. Final Notes

This lab represents **real DevOps production patterns**.

Skills gained:
- Secure automation
- Python cloud scripting
- AWS monitoring
- Database security

---

🎯 You are now practicing **professional AWS DevOps engineering**


# AWS Advanced Hands-On Lab (Beginner → Advanced)

> **Author & Arthitecture Designer:** Charlie

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
10. Connect RDS on EC2
[AWS RDS/ Aurora Lab Complete Guide](https://github.com/awsrmmustansarjavaid/Cloud-Engineering-R-S-D/blob/main/AWS-Cloud-Engineering/AWS-Cloud-Practice-dev/AWS-Labs-AWS-Labs-Guide/AWS-Labs-Projects/AWS-Basic-Labs-Projects/AWS%20Individual%20Service%20Complete%20Lab%20Guide/AWS%20RDS.md)


---


## 5. Phase 2 – AWS Secrets Manager

### Step 1: Create Secret

- **Click on Link for Create Secret**

[AWS Secret Manager Hands-On Lab (Beginner → Advanced)](https://github.com/awsrmmustansarjavaid/Cloud-Engineering-R-S-D/blob/main/AWS-Cloud-Engineering/AWS-Cloud-Practice-dev/AWS-Labs-AWS-Labs-Guide/AWS-Labs-Projects/AWS-Basic-Labs-Projects/AWS%20Individual%20Service%20Complete%20Lab%20Guide/AWS%20Secret%20Manager.md)

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

## 10. Basic Lambda Test (Console Test)

### 🔹 Step 1: Create folders (EXACT structure)

#### On your local machine (Windows / Linux / Mac):

```
mkdir pymysql-layer
cd pymysql-layer
mkdir python
```

##### ⚠️ Folder name MUST be python (lowercase)

###### If this is wrong → Lambda will NOT find pymysql.

### 🔹 Step 2: Install PyMySQL into python/

#### Run this inside pymysql-layer directory:

```
pip install pymysql -t python/
```

#### After this, you MUST see:

```
pymysql-layer/
└── python/
    ├── pymysql/
    ├── pymysql-1.x.x.dist-info/
```

##### ✅ If you do NOT see pymysql/ → STOP, it’s wrong.

### 🔹 Step 3: Zip the layer (VERY IMPORTANT)

#### Run:

```
zip -r pymysql-layer.zip python
```

#### ✅ The zip must contain:

```
python/pymysql/...
```

#### ❌ NOT:

```
pymysql/
```

#### ❌ NOT:

```
pymysql-layer/python/pymysql
```

### 🔹 Step 4: Create Lambda Layer in AWS

- **AWS Console → Lambda → Layers**

- **Click Create layer**

- **Name:**

```
pymysql-layer
```

- **Upload:**

```
pymysql-layer.zip
```

- **Runtime:**

```
Python 3.10
```

- **Create layer**

### 🔹 Step 5: ATTACH the Layer to Your Lambda (MOST MISSED STEP)

- **Open your Lambda function**

- **Scroll to Layers**

- **Click Add a layer**

- **Choose:**

```
Custom layers
```

- **Select:**

```
pymysql-layer
```

- **Version: Latest**

- **Save**

###### ⚠️ If the layer is not attached → Lambda WILL FAIL

## 11. Basic Lambda Test (Console Test)

1.  Click Test
2.  Create test event:
    - Event name: test-basic
    - JSON:

```
{}
```

3.  Click Test

##### ✅ Expected Result

```
{
  "statusCode": 200,
  "body": "Success"
}
```

- ✔ Python code works
- ✔ IAM role works
- ✔ Secret fetched successfully


---

## 12. Phase 5 – CloudWatch Logs

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

## 13. Phase 6 – CloudWatch Alarms

### Create Alarm

Metric:
- Lambda Errors

Condition:
- Errors ≥ 1

Purpose:
- Detect DB failures
- Detect permission issues

---

## 14. Common Errors & Fixes

| Issue | Cause | Fix |
|-----|-----|-----|
| Timeout | Lambda not in VPC | Attach VPC |
| AccessDenied | IAM issue | Add SecretsManager permission |
| DB error | SG blocked | Allow port 3306 |

---

## 15. Advanced Practice Tasks

- Insert records using Lambda
- Enable secret rotation
- Add EventBridge trigger
- Use RDS Proxy
- Encrypt RDS with KMS

---

## 16. Final Notes

This lab represents **real DevOps production patterns**.

Skills gained:
- Secure automation
- Python cloud scripting
- AWS monitoring
- Database security

---

🎯 You are now practicing **professional AWS DevOps engineering**

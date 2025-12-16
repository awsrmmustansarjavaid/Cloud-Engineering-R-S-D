
# Advanced AWS Enterprise Hands-On Lab

> **Author:** Charlie
> 
> **Level:** Advanced (Associate → Professional)
>  
> **Purpose:** End‑to‑end enterprise AWS hands‑on lab covering networking, storage, automation, monitoring, and Linux administration.

---

## 🎯 YOUR IDEA (Rephrased Clearly)

> **“I want one Lambda (or set of Lambdas) that checks whether every task in my AWS hands-on lab is correctly configured and working, and then produces a success/failure report.”**


**✅ 100% POSSIBLE**

**✅ Real-world approach**

**✅ Very strong interview topic**

## 🧠 HOW ENTERPRISES DO THIS (Concept First)

##### They use:

```

AWS APIs (Describe / List / Get)

Lambda (serverless validation)

CloudWatch + S3 (logs & reports)

EventBridge (scheduled tests)
```

##### This is called:
```

Infrastructure validation

Cloud compliance checks

Smoke testing
```

## 🏗️ HIGH-LEVEL ARCHITECTURE

```
EventBridge (Manual or Schedule)
        ↓
Validation Lambda
        ↓
AWS APIs (EC2, VPC, EBS, EFS, IAM, RDS, CW)
        ↓
JSON / PDF Report
        ↓
S3
```

## 🧩 DESIGN DECISION (VERY IMPORTANT)

**❌ One huge Lambda = hard to debug**

**✅ Modular checks inside ONE Lambda (best for labs)**

#### We will do:

```
validate_ec2()
validate_ebs()
validate_efs()
validate_cloudwatch()
validate_lambda()
validate_rds()
validate_network()
```

#### Each returns:

```
PASS / FAIL + Reason
```

## 🟢 WHAT CAN BE VERIFIED (REALISTIC LIST)

```
| Service    | What Lambda Can Verify                |
| ---------- | ------------------------------------- |
| EC2        | Running, instance type, IAM role, SG  |
| EBS        | Attached, size, snapshot exists       |
| EFS        | Mount targets, SG rules               |
| CloudWatch | Agent installed (via metrics), alarms |
| IAM        | Role attached, policies present       |
| Lambda     | VPC config, EFS access                |
| RDS        | Status, subnet group                  |
| VPC        | Endpoints, NAT, TGW attached          |
| S3         | Buckets exist, objects written        |
```

**⚠️ Lambda cannot SSH into EC2: It verifies configuration & state via APIs**

### 🟢 STEP 1 — Create IAM Role for Validation Lambda

#### Attach these policies (LAB SAFE):

```
AWSLambdaBasicExecutionRole
AmazonEC2ReadOnlyAccess
AmazonVPCReadOnlyAccess
AmazonElasticFileSystemReadOnlyAccess
AmazonRDSReadOnlyAccess
AmazonS3FullAccess
CloudWatchReadOnlyAccess
IAMReadOnlyAccess
```
#### Role name:

```
Lab-Validation-Lambda-Role
```

### 🟢 STEP 2 — Create Validation Lambda

```
Name: AdvancedLabValidationLambda
Runtime: Python 3.10
Role: Lab-Validation-Lambda-Role
```

### 🟢 STEP 3 — Validation Logic (CORE IDEA)

###### Below is a real but simplified working example.

#### Lambda Code (Starter Version)

```
import boto3
from datetime import datetime

ec2 = boto3.client('ec2')
efs = boto3.client('efs')
rds = boto3.client('rds')
s3 = boto3.client('s3')

REPORT_BUCKET = "lab-validation-reports"

def validate_ec2():
    instances = ec2.describe_instances()
    if not instances['Reservations']:
        return ("EC2", "FAIL", "No EC2 instances found")
    return ("EC2", "PASS", "Instances running")

def validate_efs():
    fs = efs.describe_file_systems()
    if not fs['FileSystems']:
        return ("EFS", "FAIL", "No EFS found")
    return ("EFS", "PASS", "EFS available")

def validate_rds():
    dbs = rds.describe_db_instances()
    if not dbs['DBInstances']:
        return ("RDS", "FAIL", "No RDS instances")
    return ("RDS", "PASS", "RDS running")

def lambda_handler(event, context):

    results = []
    results.append(validate_ec2())
    results.append(validate_efs())
    results.append(validate_rds())

    report = {
        "timestamp": datetime.utcnow().isoformat(),
        "results": [
            {"service": r[0], "status": r[1], "message": r[2]}
            for r in results
        ]
    }

    key = f"validation-report-{datetime.utcnow().strftime('%Y%m%d%H%M%S')}.json"

    s3.put_object(
        Bucket=REPORT_BUCKET,
        Key=key,
        Body=str(report)
    )

    return report
```

### 🟢 STEP 4 — Create S3 Bucket for Reports

```
Bucket name: lab-validation-reports
Block public access: ON
```

### 🟢 STEP 5 — Run and Verify

- **Click Test:** → {}

#### Expected output:

```
{
  "service": "EC2",
  "status": "PASS"
}
```

#### S3 bucket contains:

```
validation-report-20250115.json
```


## 🧠 HOW TO MAKE THIS “100% SUCCESS” CHECK

#### Each check must:


- **Validate existence**

- **Validate configuration**

- **Validate dependency**


#### Example (EFS):


- **Mount targets exist**

- **Security group allows 2049 In same VPC**



#### Example (CloudWatch):


- **Alarm exists**

- **StatusCheckFailed alarm enabled**



## 🧪 EXTENSION (REAL-WORLD LEVEL)

```
| Feature              | How                   |
| -------------------- | --------------------- |
| Scheduled checks     | EventBridge           |
| PDF report           | reportlab layer       |
| Email result         | SNS                   |
| Fail pipeline        | CodeBuild             |
| Tag-based validation | describe with filters |
```

## 🎓 INTERVIEW GOLD STATEMENT

> “We use Lambda-based validation to verify AWS infrastructure via APIs and generate compliance reports stored in S3. This allows automated testing without logging into instances.”

## 🚫 LIMITATIONS (Be Honest)

```
| Thing                  | Possible?           |
| ---------------------- | ------------------- |
| SSH into EC2           | ❌                   |
| Check file content     | ❌                   |
| Run OS commands        | ❌                   |
| Check mount inside EC2 | ❌ (use SSM instead) |
```

## 🧠 TRAINER ADVICE (IMPORTANT)

#### For labs:


- **Lambda = configuration validation**

- **SSM Run Command = OS validation**

- **Combine both for enterprise-grade checks**


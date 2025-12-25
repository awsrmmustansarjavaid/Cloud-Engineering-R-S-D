# AWS S3 Complete Hands-On Lab (Basic to Advanced)

> **Author:** Charlie
> 
> **Level:** Advanced (Associate → Professional)

**Audience:** Beginner to Intermediate AWS learners
**Goal:** Master Amazon S3 concepts from basics to advanced by integrating it with **EC2, CloudFront, CloudWatch, CloudTrail, IAM, DynamoDB, Lambda, VPC (Security Group, NACL), and VPC Endpoints**.

This is a **real-world enterprise-style lab**. Follow steps **exactly in order**. Do **not skip any step**.

---

## LAB ARCHITECTURE OVERVIEW

You will build:

* Public & Private S3 buckets
* Static website hosting on S3
* EC2 accessing S3 using IAM Role
* CloudFront CDN in front of S3
* Monitoring with CloudWatch
* Auditing with CloudTrail
* Event-driven automation with Lambda
* DynamoDB for metadata storage
* Secure access via VPC Endpoint

---

## PREREQUISITES

* AWS Free Tier account
* Region: **us-east-1 (recommended)**
* Basic AWS Console familiarity

---

# SECTION 1 — IAM (FOUNDATION)

### Step 1: Create IAM Policy for S3 + DynamoDB

1. Open **IAM → Policies → Create policy**
2. Select **JSON** tab
3. Paste:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:*",
        "dynamodb:*",
        "logs:*"
      ],
      "Resource": "*"
    }
  ]
}
```

4. Click **Next**
5. Policy name: `S3-DynamoDB-FullAccess-Lab`
6. Create policy

---

### Step 2: Create IAM Role for EC2

1. IAM → Roles → Create role
2. Trusted entity: **AWS service**
3. Use case: **EC2**
4. Attach policy:

   * `S3-DynamoDB-FullAccess-Lab`
5. Role name: `EC2-S3-DynamoDB-Role`
6. Create role

---

# SECTION 2 — S3 BASICS

### Step 3: Create Public S3 Bucket

1. S3 → Create bucket
2. Bucket name: `my-public-s3-demo-<unique>`
3. Region: same as EC2
4. **Uncheck**: Block all public access
5. Acknowledge warning
6. Create bucket

---

### Step 4: Enable Public Access via Bucket Policy

1. Open bucket → **Permissions → Bucket policy**   
2. Replace the S3 ARN URL with your own, and then paste it

##### Example:

```
arn:aws:s3:::advancedlab-secure-bucket
```

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::my-public-s3-demo-<unique>/*"
    }
  ]
}
```

3. Save changes

---

### Step 5: Upload Objects

1. Go to **Objects → Upload**
2. Upload:

   * `index.html`
   * `error.html`
3. Make them public

---

# SECTION 3 — S3 STATIC WEBSITE HOSTING

### Step 6: Enable Static Website

1. Bucket → **Properties**

2. Scroll to **Static website hosting**

3. Enable

4. Index document: `index.html`

5. Error document: `error.html`

6. Save

7. Copy **Website endpoint URL**

8. Open in browser → confirm it works

---

# SECTION 4 — EC2 INTEGRATION

### Step 7: Launch EC2

1. EC2 → Launch instance
2. Name: `S3-Lab-EC2`
3. AMI: **Amazon Linux 2023**
4. Instance type: `t2.micro`
5. IAM Role: `EC2-S3-DynamoDB-Role`
6. Key pair: create/select
7. Security Group:

   * Allow SSH (22) from your IP
8. Launch

---

### Step 8: Access S3 from EC2

#### SSH into EC2:

```bash
aws s3 ls
aws s3 ls s3://my-public-s3-demo-<unique>
```

#### Upload file:

```bash
echo "Hello from EC2" > ec2.txt
aws s3 cp ec2.txt s3://my-public-s3-demo-<unique>/
```

#### Verify AWS CLI on EC2: 

```
aws --version
```

If not installed (Amazon Linux):

```
sudo yum install awscli -y
```


#### List All S3 Buckets:

```
aws s3 ls
```

##### Example output:

```
2024-12-01  my-public-s3-demo
2024-12-02  my-private-s3-bucket
```

#### List Files Inside a Bucket:

```
aws s3 ls s3://my-public-s3-demo
```

#### List a folder (prefix):

```
aws s3 ls s3://my-public-s3-demo/images/
```

#### Upload File to S3

##### Create a test file:

```
echo "Hello S3 from EC2" > test.txt
```

#### Upload:

```
aws s3 cp test.txt s3://my-public-s3-demo/
```

#### Upload to folder:

```
aws s3 cp test.txt s3://my-public-s3-demo/logs/test.txt
```

#### Download File from S3

```
aws s3 cp s3://my-public-s3-demo/test.txt .
```

#### Download from folder:

```
aws s3 cp s3://my-public-s3-demo/logs/test.txt .
```

#### Upload Entire Folder (Recursive)

```
mkdir uploads
echo "file1" > uploads/a.txt
echo "file2" > uploads/b.txt
```

```
aws s3 cp uploads/ s3://my-public-s3-demo/uploads/ --recursive
```

#### Download Entire Folder

```
aws s3 cp s3://my-public-s3-demo/uploads/ ./downloads/ --recursive
```

#### Delete Files from S3

#### Delete single file:

```
aws s3 rm s3://my-public-s3-demo/test.txt
```

#### Delete folder:

```
aws s3 rm s3://my-public-s3-demo/uploads/ --recursive
```

#### Sync Local Folder ↔ S3 (VERY IMPORTANT)

##### Local → S3:

```
aws s3 sync ./website s3://my-public-s3-demo
```

#### S3 → Local:

```
aws s3 sync s3://my-public-s3-demo ./backup
```



# SECTION 5 — CLOUDWATCH MONITORING

### Step 9: Enable S3 Metrics

1. S3 → Bucket → **Metrics**
2. Enable:

   * Request metrics

---

### Step 10: Create CloudWatch Alarm

1. CloudWatch → Alarms → Create alarm
2. Metric:

   * S3 → Bucket Metrics → NumberOfObjects
3. Threshold: > 10
4. Action: None (for lab)
5. Alarm name: `S3-Object-Count-Alarm`

---

# SECTION 6 — CLOUDTRAIL AUDITING

### Step 11: Enable CloudTrail

1. CloudTrail → Create trail
2. Name: `S3-Audit-Trail`
3. Storage location: **Create new S3 bucket**
4. Log events:

   * Management events: **All**
   * Data events: **S3 (Read/Write)**
5. Create trail

---

# SECTION 7 — DYNAMODB + LAMBDA AUTOMATION

### Step 12: Create DynamoDB Table

1. DynamoDB → Create table
2. Table name: `S3ObjectMetadata`
3. Partition key: `objectKey (String)`
4. Create table

---

### Step 13: Create Lambda Function

1. Lambda → Create function
2. Name: `S3-Upload-Logger`
3. Runtime: Python 3.12
4. Execution role: Create new role

Paste code:

```python
import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('S3ObjectMetadata')

def lambda_handler(event, context):
    for record in event['Records']:
        key = record['s3']['object']['key']
        table.put_item(Item={'objectKey': key})
    return {'status': 'success'}
```

---

### Step 14: Configure S3 Event Trigger

1. S3 → Bucket → **Event notifications**
2. Name: `S3-Upload-Trigger`
3. Event type: **PUT**
4. Destination: Lambda → `S3-Upload-Logger`

Upload file → check DynamoDB entry

---

# SECTION 8 — VPC SECURITY

### Step 15: Create VPC Endpoint for S3

1. VPC → Endpoints → Create endpoint
2. Service: **S3**
3. Type: Gateway
4. VPC: your EC2 VPC
5. Route table: select private route table
6. Create endpoint

---

### Step 16: Validate Private Access

From EC2:

```bash
aws s3 ls
```

Traffic now stays inside AWS network

---

# SECTION 9 — CLOUDFRONT CDN

### Step 17: Create CloudFront Distribution

1. CloudFront → Create distribution
2. Origin domain: S3 bucket
3. Viewer protocol: Redirect HTTP to HTTPS
4. Default root object: `index.html`
5. Create distribution

Wait → copy CloudFront URL → test

---

# CLEANUP (IMPORTANT)

Delete in order:

1. CloudFront distribution
2. Lambda
3. DynamoDB table
4. EC2 instance
5. S3 buckets
6. IAM roles & policies
7. CloudTrail

---

## YOU HAVE LEARNED

* S3 Public & Private access
* Static website hosting
* IAM role-based security
* EC2 to S3 integration
* CloudFront CDN
* Monitoring & auditing
* Event-driven automation
* VPC Endpoint security

---







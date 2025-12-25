# AWS Serverless Inventory Processing Lab
**S3 → Lambda → DynamoDB → Lambda → SNS → Cognito**

---

## 📌 Lab Objective

Build a **fully serverless inventory management system** on AWS where:

1. Users authenticate using **Amazon Cognito**
2. Inventory file is uploaded to **Amazon S3**
3. **Lambda function** processes uploaded inventory
4. Inventory is stored in **DynamoDB**
5. Another **Lambda function** detects changes
6. **SNS** sends email/mobile notifications

---

## 🧱 Architecture Overview

**Flow:**

User → Dashboard App → Cognito  
Upload Inventory → S3 → Lambda → DynamoDB → Lambda → SNS → Email/SMS

**AWS Services Used:**
- Amazon S3
- AWS Lambda
- Amazon DynamoDB
- Amazon SNS
- Amazon Cognito
- IAM
- CloudWatch

---

## AWS Architecture Diagram

![AWS Architecture Lab](./Serverless%20Inventory%20Management%20System%20on%20AWS.jpeg)

## 🔐 STEP 1: IAM Role for Lambda

### Create IAM Role
- Service: **Lambda**
- Role name:

```
lambda-inventory-role
```


### Attach Policies
- AmazonS3ReadOnlyAccess
- AmazonDynamoDBFullAccess
- AmazonSNSFullAccess
- CloudWatchLogsFullAccess

---

## 🗂 STEP 2: Create S3 Bucket

### Create Bucket
- Name:

```
inventory-upload-yourname
```

- Region: Same as Lambda
- Block public access: Enabled

(Optional)

```
/uploads
```


---

## 📄 STEP 3: Inventory File Format

### inventory.json
```json
[
  {
    "productId": "P1001",
    "name": "Laptop",
    "quantity": 20,
    "price": 1200
  },
  {
    "productId": "P1002",
    "name": "Mouse",
    "quantity": 100,
    "price": 20
  }
]
```

---

## 🗃 STEP 4: Create DynamoDB Table

### Table name:

```
InventoryTable
```

### Partition Key:

```
productId (String)
```

- Billing mode: On-Demand

---

## ⚙ STEP 5: Lambda #1 – Process Inventory File

### Create Lambda Function

- **Name:**

```
ProcessInventoryFile
```

- Runtime: Python 3.12

- Role: lambda-inventory-role

- Add S3 Trigger

- Bucket: inventory-upload-yourname

- Event type: PUT

### Lambda Code

```
import json
import boto3

s3 = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('InventoryTable')

def lambda_handler(event, context):
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']

    response = s3.get_object(Bucket=bucket, Key=key)
    content = response['Body'].read().decode('utf-8')
    items = json.loads(content)

    for item in items:
        table.put_item(Item=item)

    return {
        'statusCode': 200,
        'body': 'Inventory processed successfully'
    }
```
---

## 🔔 STEP 6: Create SNS Topic

### Create Topic

- Name:

```
inventory-alerts
```

- Create Subscription

- Protocol: Email

- Endpoint: your email

- Confirm email from inbox

---

## 🔄 STEP 7: Lambda #2 – Inventory Notification

### Create Lambda

- Name:

```
NotifyInventoryUpdate
```

- Runtime: Python 3.12

- Role: lambda-inventory-role

- Enable DynamoDB Stream

- Table: InventoryTable

- Stream view: NEW_AND_OLD_IMAGES

### Lambda Code

```
import boto3

sns = boto3.client('sns')
TOPIC_ARN = "arn:aws:sns:REGION:ACCOUNT_ID:inventory-alerts"

def lambda_handler(event, context):
    for record in event['Records']:
        if record['eventName'] == 'INSERT':
            item = record['dynamodb']['NewImage']
            product_name = item['name']['S']

            sns.publish(
                TopicArn=TOPIC_ARN,
                Subject="Inventory Update",
                Message=f"New product added: {product_name}"
            )
```

---

## 🔐 STEP 8: Amazon Cognito Setup

### Create User Pool

- Sign-in method: Email

- MFA: Optional

- Create App Client

- Public client

- No secret

- Enable hosted UI

**Used by Dashboard App for authentication.**

---

## 🧪 STEP 9: Testing & Verification

### Test Steps

- Upload inventory.json to S3

- Check DynamoDB table

- Confirm SNS email received

- Review Lambda logs in CloudWatch

---

## 🐞 Common Errors & Fixes

```
| Issue                | Solution                |
| -------------------- | ----------------------- |
| AccessDenied         | Fix IAM permissions     |
| No SNS email         | Confirm subscription    |
| Lambda not triggered | Check S3 trigger        |
| DynamoDB empty       | Validate JSON           |
| Timeout              | Increase Lambda timeout |
```

## 🎯 Skills Gained

- Serverless architecture

- Event-driven systems

- AWS IAM security

- Real-world AWS workflow

- Cloud-native notifications

## 🏁 Final Notes

- This lab is production-grade and suitable for:

- AWS Cloud Engineer

- DevOps Engineer

- Solutions Architect portfolio

----

---

## ✅ Verification & Testing Guide (Step-by-Step)

This section ensures **100% confirmation** that every AWS service in this lab is working correctly.

---

## 🧪 TEST 1: S3 Upload Trigger Verification

### Objective
Verify that uploading a file to S3 triggers **Lambda #1**.

### Steps
1. Go to **S3 Console**
2. Open bucket:

```
inventory-upload-yourname
```

3. Upload `inventory.json`
4. Upload path (if used):

```
uploads/inventory.json
```


### Expected Result
- File appears in S3
- Lambda function `ProcessInventoryFile` is triggered automatically

### Verification
- Go to: CloudWatch → Logs → Log groups → /aws/lambda/ProcessInventoryFile


✅ You should see new log entries  
❌ No logs = S3 trigger issue

---

## 🧪 TEST 2: Lambda #1 → DynamoDB Data Insert

### Objective
Confirm inventory data is stored in DynamoDB.

### Steps
1. Go to **DynamoDB**
2. Open table: InventoryTable
3. Click **Explore table items**

### Expected Result
| productId | name | quantity | price |
|---------|-----|----------|------|
| P1001 | Laptop | 20 | 1200 |
| P1002 | Mouse | 100 | 20 |

✅ Items present → SUCCESS  
❌ No items → Lambda or JSON issue

---

## 🧪 TEST 3: DynamoDB Stream → Lambda #2 Trigger

### Objective
Verify DynamoDB stream invokes notification Lambda.

### Steps
1. Insert a **new item manually** into DynamoDB
2. Or upload a new inventory file

### Verification
- Go to:CloudWatch → Logs → /aws/lambda/NotifyInventoryUpdate

### Expected Result
- Lambda execution logs visible
- No errors in logs

---

## 🧪 TEST 4: SNS Email Notification

### Objective
Confirm SNS sends email notifications.

### Steps
1. Trigger DynamoDB INSERT
2. Check your email inbox

### Expected Result

```
📧 Email received:
Subject: Inventory Update
Message: New product added: Laptop
```


❌ No email?
- Check SNS subscription confirmation
- Check Lambda permissions

---

## 🧪 TEST 5: End-to-End Flow Validation

### Full Flow Test
1. Upload inventory file
2. Lambda processes file
3. DynamoDB stores data
4. DynamoDB triggers Lambda #2
5. SNS sends email

### SUCCESS CRITERIA
✅ All steps execute without manual intervention

---

## 🐞 Common Bugs & Their Solutions (VERY IMPORTANT)

---

### ❌ BUG 1: Lambda Not Triggered by S3

**Cause**
- S3 trigger not attached
- Wrong bucket name or prefix

**Fix**
- Lambda → Triggers → Add S3
- Ensure correct bucket and event type (`PUT`)
- Check prefix (`uploads/`)

---

### ❌ BUG 2: AccessDenied Error in Lambda

**Error**

```
AccessDeniedException
```


**Cause**
- IAM role missing permissions

**Fix**
Attach policies:
- AmazonS3ReadOnlyAccess
- AmazonDynamoDBFullAccess
- AmazonSNSFullAccess
- CloudWatchLogsFullAccess

---

### ❌ BUG 3: DynamoDB Table Empty

#### Cause
- JSON file format invalid
- Incorrect partition key

#### Fix
Ensure:
```json
"productId": "STRING"
```
- Matches DynamoDB partition key exactly.

### ❌ BUG 4: Lambda Timeout

#### Cause

- Default timeout too low (3 seconds)

#### Fix

- Lambda → Configuration → Timeout

- Increase to:

```
30 seconds
```

### ❌ BUG 5: SNS Email Not Received

#### Cause

- Subscription not confirmed

- Incorrect Topic ARN

#### Fix

- SNS → Subscriptions → Confirmed = YES

- Verify correct ARN in Lambda code

### ❌ BUG 6: DynamoDB Stream Not Triggering Lambda

#### Cause

- Stream disabled

- Wrong stream view type

#### Fix

- DynamoDB → Streams → Enable

- Stream view type:

```
NEW_AND_OLD_IMAGES
```

### ❌ BUG 7: Invalid JSON Error

#### Error
```
JSONDecodeError
```

#### Cause

- Extra comma

- Invalid JSON structure

#### Fix
- Validate JSON using:

- https://jsonlint.com

### ❌ BUG 8: SNS Publish Permission Error

#### Error

```
AuthorizationError
```

#### Fix
- Ensure Lambda IAM role has:

```
AmazonSNSFullAccess
```

## 📊 CloudWatch Monitoring Checklist

```
| Component | What to Check       |
| --------- | ------------------- |
| Lambda #1 | Execution success   |
| Lambda #2 | Trigger from stream |
| SNS       | Delivery status     |
| DynamoDB  | Item count          |
| IAM       | Permission errors   |
```

## 🏁 Verification Status (Checklist)

- S3 upload works

- Lambda triggered

- DynamoDB updated

- SNS email received

- Logs verified

---




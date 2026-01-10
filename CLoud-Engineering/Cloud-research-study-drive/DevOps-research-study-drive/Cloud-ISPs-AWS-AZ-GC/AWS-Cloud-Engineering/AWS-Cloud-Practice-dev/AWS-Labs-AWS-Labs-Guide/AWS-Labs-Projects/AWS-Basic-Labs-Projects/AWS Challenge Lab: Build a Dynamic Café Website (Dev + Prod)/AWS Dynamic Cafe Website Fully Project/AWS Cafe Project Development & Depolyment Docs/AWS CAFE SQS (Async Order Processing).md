# AWS CAFE LAB

> **AUTHOR & ARCHITECTURE DESIGNER:** CHARLIE

# 🔒 SECTION 7 — AWS CAFE SQS (Async Order Processing)

# PHASE 10 — SQS (Async Order Processing)

## 🧠 WHY SQS EXISTS (VERY IMPORTANT)

### ➖ Without SQS:

- API waits for DB insert ❌

- API fails if DB is slow ❌

- Users get errors ❌

### ➕ With SQS:

- API responds instantly ✅

- Orders are processed in background ✅

- System scales safely ✅

---

## 🏁 ARCHITECTURE STATE (SUCCESS)

```
Client
  ↓
API Gateway
  ↓
CafeOrderApiLambda
  ↓
SQS (CafeOrdersQueue)
  ↓
CafeOrderWorker Lambda
  ↓
RDS + DynamoDB
```

✔ Fully asynchronous

✔ Decoupled

✔ Scalable

✔ Production-ready

---
## 📢 PRE-CHECK (DO NOT SKIP)

#### Before starting, confirm:

- Region is same for Lambda + SQS + RDS

- You have IAM role for Lambda

- You are using Standard Queue (NOT FIFO)

## 1️⃣ Create SQS Queue

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


## 2️⃣ IAM PERMISSIONS FOR PRODUCER LAMBDA

**Your API Lambda must be allowed to send messages.**

- **Go to IAM → Policies → Create inline policy**

#### Paste exactly:

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sqs:SendMessage",
      "Resource": "arn:aws:sqs:*:*:CafeOrdersQueue"
    }
  ]
}
```
- Save Policy

- **Name:**

```
SendOrderToSQS
```

**✔️ Click Create policy**


## 3️⃣ CREATE API Lambda Function (Producer)

**(ORDER API → SQS)**

### 🎯 PURPOSE 

This Lambda will:

- Receive HTTP request from API Gateway

- Read order JSON

- Send order to SQS

- Respond immediately (202 Accepted)

### 🧱 ARCHITECTURE POSITION

```
Browser / EC2 PHP App
        ↓
    API Gateway
        ↓
CafeOrderApiLambda   ← (YOU ARE CREATING THIS NOW)
        ↓
   CafeOrdersQueue (SQS)
```

### ✅ PRE-CHECK (DO THIS ONCE)

Make sure SQS Queue already exists:

- AWS Console → SQS

- Queue name: CafeOrdersQueue

- Type: Standard

✔ If exists → Continue

❌ If not → STOP and create it first

### ▶️ Create Lambda Function

- Open Lambda Console

- Click Functions

- Click Create function

#### Basic Information:

| Field         | Value                          |
| ------------- | --------------------           |
| Function name | `CafeOrderApiLambda`           |
| Runtime        | Python 3.12                   |
| Architecture   | x86_64                        |
| Execution role | Use existing role             |
| Role           | Same role with RDS + DynamoDB |

Click Create function

⏳ Wait until status shows Active

## 4️⃣ Update API Lambda (Producer)

### 1️⃣ Open Order API Lambda

- AWS Console → Lambda

- Click your Order API Lambda

### 2️⃣ Add Environment Variable:

- Configuration → Environment variables

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

### 3️⃣ Update Lambda Code (FULL)

#### 1️⃣ Replace your order insert logic with this:

#### 📣 CafeOrderApiLambda  — Production-Ready (Recommended for This Lab)

#### 💻 Code (Recommended for This Lab)

```
import json
import boto3
import os

sqs = boto3.client('sqs')
QUEUE_URL = os.environ['SQS_QUEUE_URL']

def lambda_handler(event, context):
    try:
        # ---------- Parse request body ----------
        body = json.loads(event.get("body", "{}"))

        # ---------- Validate required fields ----------
        required_fields = ["table_number", "item", "quantity"]
        for field in required_fields:
            if field not in body:
                return {
                    "statusCode": 400,
                    "headers": {"Access-Control-Allow-Origin": "*"},
                    "body": json.dumps({
                        "error": f"Missing required field: {field}"
                    })
                }

        # ---------- Validate data ----------
        table_number = int(body["table_number"])
        quantity = int(body["quantity"])

        if table_number <= 0:
            raise ValueError("Invalid table number")

        if quantity <= 0:
            raise ValueError("Quantity must be greater than zero")

        # ---------- Build order payload ----------
        order = {
            "table_number": table_number,
            "customer_name": body.get("customer_name", "Guest"),
            "item": body["item"],
            "quantity": quantity
        }

        # ---------- Send message to SQS ----------
        sqs.send_message(
            QueueUrl=QUEUE_URL,
            MessageBody=json.dumps(order)
        )

        return {
            "statusCode": 202,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({
                "message": "Order accepted",
                "order": order
            })
        }

    except ValueError as e:
        return {
            "statusCode": 400,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": str(e)})
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": str(e)})
        }
```

**✔️ Click Deploy**

#### 2️⃣ CREATE LAMBDA TEST (CONSOLE TEST)

- Click Test

- Select Create new test event

- Event name:

```
ApiOrderTest
```

Event JSON:


```
{
  "body": "{\"table_number\":1,\"customer_name\":\"ConsoleTest\",\"item\":\"Latte\",\"quantity\":2}"
}
```

Click Save

Click Test

#### Expected Result (SUCCESS)

```
{
  "statusCode": 202,
  "body": "{\"message\":\"Order accepted\",\"order\":{\"table_number\":1,\"customer_name\":\"ConsoleTest\",\"item\":\"Latte\",\"quantity\":2}}"
}
```

#### CloudWatch Logs:

```
Order accepted
```

#### SQS:

- Message appears briefly

- Then disappears (worker consumes it)

#### RDS:

```
SELECT * FROM orders ORDER BY id DESC;
```

#### Result:

```
id | table_number | customer_name | item  | quantity | created_at
---------------------------------------------------------------
12 | 1            | ConsoleTest   | Latte | 2        | 2026-01-xx
```



#### 3️⃣ VERIFY MESSAGE IN SQS (CRITICAL)

- AWS Console → SQS

- Click CafeOrdersQueue

- Click Send and receive messages

- Click Poll for messages

#### Expected Output:

You should see message like:

```
{
  "customer_name": "ConsoleTest",
  "item": "Latte",
  "quantity": 2
}
```

✅ If message exists → Producer Lambda WORKS

#### SQS Message Body (Manual Test)

```
{
  "table_number": 2,
  "customer_name": "WorkerTest",
  "item": "Latte",
  "quantity": 2
}
```
---

### 4️⃣ Frontend (orders.php)

You already fixed it ✔
Ensure payload includes:

```
{
  "table_number": 1,
  "customer_name": "Charlie",
  "item": "Tea",
  "quantity": 2
}
```

### 5️⃣ Test with API Gateway or Lambda test

#### Update test body

```
{
  "table_number": 3,
  "customer_name": "ApiTest",
  "item": "Coffee",
  "quantity": 1
}
```
#### curl Test

```
curl -X POST \
  https://svirhyw5a3.execute-api.us-east-1.amazonaws.com/dev/orders \
  -H "Content-Type: application/json" \
  -d '{"table_number":3,"customer_name":"CurlTest","item":"Tea","quantity":2}'
```


### 🔍 METHOD A — TEST USING LAMBDA CONSOLE (EASIEST)

> **This tests only the Lambda logic, not API Gateway.**

#### 🟦 A1 — OPEN THE PRODUCER LAMBDA

- AWS Console → Lambda

- Click your Order API Lambda
(the one sending messages to SQS)

#### 🟦 A2 — CREATE A TEST EVENT

- Click Test

- Click Create new event

**Event configuration:**

| Field      | Value             |
| ---------- | ----------------- |
| Event name | `SqsProducerTest` |
| Template   | `Hello World`     |


#### 🟦 A3 — REPLACE EVENT JSON (IMPORTANT)

#### Delete everything and paste exactly:

```
{
  "body": "{\"customer_name\":\"ConsoleTest\",\"item\":\"Latte\",\"quantity\":2}"
}
```

#### ⚠️ Notice:

- body must be a STRING

- This simulates API Gateway behavior

#### 🟦 A4 — RUN TEST

- Click Save

- Click Test

#### ✅ EXPECTED RESULT (LAMBDA)

**Lambda Response:**

```
{
  "statusCode": 202,
  "body": "{\"message\": \"Order accepted\"}"
}
```

#### 🟦 A5 — VERIFY MESSAGE IN SQS

- AWS Console → SQS

- Click CafeOrdersQueue

- Click Send and receive messages

- Click Poll for messages

#### ✅ You should see:

```
{
  "customer_name": "ApiTestUser",
  "item": "Latte",
  "quantity": 1
}
```

If you see this → Producer Lambda works perfectly ✅

### 🌐 METHOD B — TEST USING API GATEWAY (REAL END-USER TEST)

This tests the full HTTP flow.

#### 🟦 B1 — OPEN API GATEWAY

- AWS Console → search API Gateway

- Click API Gateway

- Click your Order API (REST API)

#### 🟦 B2 — SELECT THE RESOURCE

#### In left panel, expand:

- /orders (or your order path)

- Click POST

#### 🟦 B3 — USE API GATEWAY TEST FEATURE

- Click Test (⚠️ NOT Deploy)

#### In Request Body, paste:

```
{
  "customer_name": "ApiTestUser",
  "item": "Latte",
  "quantity": 1
}
```

- Click Test

#### ✅ EXPECTED API RESPONSE 

#### Status:

```
202
```

#### Body:

```
{"message":"Order accepted"}
```

#### 🟦 B4 — VERIFY SQS MESSAGE

#### Same as before:

- SQS → CafeOrdersQueue

- Send and receive messages

- Poll for messages

#### You should see:

```
{
  "customer_name": "ApiTestUser",
  "item": "Latte",
  "quantity": 1
}
```

### 🌍 METHOD C — TEST USING PUBLIC API URL (OPTIONAL BUT REALISTIC)

#### If API is deployed:

#### 🟦 C1 — GET INVOKE URL

- API Gateway → Stages

- Click your stage (e.g., prod)

- Copy Invoke URL

#### Example:

```
https://abcd1234.execute-api.ap-south-1.amazonaws.com/prod/orders
```

#### 🟦 C2 — TEST USING CURL (OPTIONAL)

```
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{"order_id":"ORD-3001","item":"Tea","quantity":3}' \
  https://abcd1234.execute-api.ap-south-1.amazonaws.com/prod/orders
```

#### 🟦 C3 — VERIFY SQS

- Same verification steps.

### 6️⃣ Worker Lambda

#### Must read:

```
table_number = order["table_number"]
```

#### and insert:

```
INSERT INTO orders (table_number, customer_name, item, quantity)
```

### 🧠 RULE TO REMEMBER (VERY IMPORTANT)

Every layer must send the SAME JSON shape

```
{
  "table_number": INT,
  "customer_name": STRING,
  "item": STRING,
  "quantity": INT
}
```

If one layer misses a field, the pipeline breaks.


---

## 5️⃣ Create Worker Lambda (Consumer)

### 📢 Worker Responsibilities:

- Read message
- Insert into RDS
- Update DynamoDB cache

### 🟡 ARCHITECTURE FLOW:

```
Client
 ↓
API Gateway
 ↓
Order API Lambda
 ↓
SQS Queue
 ↓
Worker Lambda
 ↓
RDS + DynamoDB
```

### 1️⃣ Create Lambda Function

- **Lambda → Create function**

- **Select Author from scratch**

| Field          | Value                         |
| -------------- | ----------------------------- |
| Function name  | `CafeOrderWorker`             |
| Runtime        | Python 3.12                   |
| Architecture   | x86_64                        |
| Execution role | Use existing role             |
| Role           | Same role with RDS + DynamoDB |


**✔️ Click Create function**

### 2️⃣ Add SQS Trigger (VERY IMPORTANT)

- Scroll to Function overview

- Click Add trigger

- Select SQS

```
your SQS arn url
```


#### Trigger settings:

| Field                      | Value         |
| -------------------------- | ------------- |
| Activate trigger           | ✅ Checked     |
| Batch size                 | 1             |
| Batch window               | 0             |
| Maximum concurrency        | (leave empty) |
| Report batch item failures | ❌ unchecked   |


**✔️ Click Add**

#### ⚠️ CRITICAL:

- AWS automatically:

- Creates event source mapping

- Adds ReceiveMessage permissions


### 3️⃣ IAM PERMISSIONS FOR WORKER LAMBDA

> **Your worker needs 3 permissions**

- Attach These Permissions


#### Add inline policy with:



```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ],
      "Resource": "your SQS arn url"
    },
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "your secrets manager arn url*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:GetItem"
      ],
      "Resource": "your DynamoDB arn url"
    }
  ]
}
```
- Name: 

```
CafeOrderWorkerPermissions
```

✅ IAM permissions are now correct


### 4️⃣ WORKER LAMBDA CODE Production Safe (Recommended)

#### 💻 Code:

```
import json
import boto3
import pymysql
from decimal import Decimal

# ---------- AWS CLIENTS ----------
secrets_client = boto3.client('secretsmanager')
dynamodb = boto3.resource('dynamodb')

# ---------- CONSTANTS ----------
SECRET_NAME = "CafeDevDBSM"
DYNAMODB_TABLE = "CafeMenu"

# ---------- GET DB CREDS ----------
def get_db_secret():
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])

# ---------- LAMBDA HANDLER ----------
def lambda_handler(event, context):

    print("📩 Worker Lambda triggered by SQS")
    print("Event:", json.dumps(event))

    secret = get_db_secret()

    connection = pymysql.connect(
        host=secret["host"],
        user=secret["username"],
        password=secret["password"],
        database=secret["dbname"],
        connect_timeout=10,
        autocommit=False
    )

    menu_table = dynamodb.Table(DYNAMODB_TABLE)

    try:
        with connection.cursor() as cursor:
            for record in event["Records"]:
                order = json.loads(record["body"])

                table_number = int(order["table_number"])
                customer_name = order["customer_name"]
                item = order["item"]
                quantity = int(order["quantity"])

                # ---------- INSERT INTO RDS ----------
                cursor.execute(
                    """
                    INSERT INTO orders
                    (table_number, customer_name, item, quantity)
                    VALUES (%s, %s, %s, %s)
                    """,
                    (table_number, customer_name, item, quantity)
                )

                # ---------- UPDATE DYNAMODB ----------
                menu_table.update_item(
                    Key={"item": item},
                    UpdateExpression="ADD orders :inc",
                    ExpressionAttributeValues={
                        ":inc": Decimal(quantity)
                    }
                )

                print("✅ Order processed:", order)

        connection.commit()
        return {"statusCode": 200}

    except Exception as e:
        connection.rollback()
        print("❌ WORKER FAILED:", str(e))
        raise e  # REQUIRED for SQS retry

    finally:
        connection.close()
```

**Click Deploy**

### 5️⃣ Attach Layer to Worker Lambda

- Lambda → CafeOrderWorker

> **Scroll to Layers**

- Click Add a layer

- Choose:

    - ☑ Custom layers

    - Select PyMySQLLayer

    - Version: latest

- Click Add

### 6️⃣ Attach Lambda to VPC (MANDATORY)

#### 1️⃣ Attach Lambda to VPC

- **AWS Console → Lambda → CafeOrderWorker**

1️⃣ Click Configuration

2️⃣ Click VPC

3️⃣ Click Edit

Set EXACTLY like this:

| Field           | Value                                 |
| --------------- | ------------------------------------- |
| VPC             | **Same VPC as RDS**                   |
| Subnets         | **Private subnets (same AZs as RDS)** |
| Security groups | **Lambda-SG (or create new)**         |

4️⃣ Click Save

⏳ Wait 1–2 minutes

#### 2️⃣ Fix Security Groups (MANDATORY)

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


#### 3️⃣ Increase Lambda Timeout

**Lambda → Configuration → General configuration → Edit**

| Setting | Value          |
| ------- | -------------- |
| Timeout | **30 seconds** |
| Memory  | **512 MB**     |


👉 Why:

- ENI creation

- Cold start

- DB connection

- Memory also improves network performance.

Click Save

#### 4️⃣ VPC ENDPOINTS (THIS IS WHERE MOST FAIL)

You already have Secrets Manager endpoint ✅

Now add the remaining REQUIRED endpoints.

#### 1️⃣ Create SQS Interface Endpoint

**VPC → Endpoints → Create endpoint**

| Field          | Value                         |
| -------------- | ----------------------------- |
| Service        | `com.amazonaws.us-east-1.sqs` |
| Type           | Interface                     |
| VPC            | Same VPC                      |
| Subnets        | Same private subnets          |
| Security group | Lambda-SG                     |
| Private DNS    | ✅ ENABLE                      |

#### 2️⃣ Create CloudWatch Logs Interface Endpoint

- **Service:**

```
com.amazonaws.us-east-1.logs
```

Same settings as above

Private DNS ✅

#### 3️⃣ Create DynamoDB Gateway Endpoint (VERY IMPORTANT)

- **Service:**

```
com.amazonaws.us-east-1.dynamodb
```

- **Type:** Gateway

- **Attach to:**

  - ALL private route tables

Click Create

#### 4️⃣ Verify IAM Role (YOU ARE ALREADY OK)

You already have correct policies ✅

Nothing to change here.




#### 5️⃣ Verify Secrets Manager Keys (VERY IMPORTANT)

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

#### 6️⃣ Add DEBUG LOGS (TEMPORARY)

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

### 7️⃣ TEST (MANDATORY)


### 1️⃣ Test manually from Lambda console

#### 1️⃣ You must wrap the test event in Records:

```
{
  "Records": [
    {
      "body": "{\"table_number\": 1, \"customer_name\": \"WorkerTest\", \"item\": \"Coffee\", \"quantity\": 2}"
    }
  ]
}
```

✔ Inserts into RDS

✔ Updates DynamoDB

✔ No retries

✔ No errors

- This mimics SQS event structure

- Now the Lambda code won’t fail with 'Records'


#### ✅ EXPECTED CLOUDWATCH LOGS (SUCCESS)

You should see:

```
DEBUG: Lambda invoked
DEBUG: Event = {...}
DEBUG: Secret fetched
DEBUG: RDS connected
✅ Order processed: {...}
```

#### 2️⃣ Verify RDS

```
mysql -h <rds-endpoint> -u cafe_user -p cafe_db
```

```
SELECT * FROM orders ORDER BY id DESC;
```

#### Expected row:

```
WorkerTest | Coffee | 2
```

#### 3️⃣ Verify DynamoDB

- DynamoDB → CafeMenu → Coffee

- Attribute orders increased


### 2️⃣ TEST END-TO-END (MANDATORY)

#### 🧪 TESTING OVERVIEW

```
API Gateway / Manual SQS
        ↓
CafeOrdersQueue
        ↓
CafeOrderWorker (AUTO)
        ↓
RDS + DynamoDB
```

**We will test in 2 ways:**

1️⃣ Direct SQS test (simplest, safest)

2️⃣ Full end-to-end API test

> **Start with Method 1. Do NOT skip it.**

#### ✅ METHOD 1 — TEST WORKER LAMBDA DIRECTLY VIA SQS (RECOMMENDED FIRST)

This avoids API Gateway confusion.

#### 🟩 STEP 1 — OPEN SQS QUEUE

- AWS Console → SQS

- Click CafeOrdersQueue

- Click Send and receive messages

#### 🟩 STEP 2 — SEND A TEST MESSAGE (MANUAL)
- Click Send message

- Message body (COPY EXACTLY):

```
{
  "table_number": 5,
  "customer_name": "WorkerTest",
  "item": "Coffee",
  "quantity": 2
}
```

Leave everything else default

- Click Send message

✅ Message successfully sent

#### 🟩 STEP 3 — WAIT (IMPORTANT)

⏳ Wait 5–10 seconds

Lambda polls SQS automatically

You do NOT click anything

#### 🟩 STEP 4 — CONFIRM MESSAGE IS CONSUMED

- Still inside CafeOrdersQueue

- Click Send and receive messages

- Click Poll for messages

#### Expected result:

```
No messages available
```

#### ✅ This means:

- Worker Lambda ran

- Message was deleted

- No errors

#### 🟩 STEP 5 — CHECK WORKER LAMBDA LOGS (MANDATORY)

- AWS Console → CloudWatch

- Click Logs → Log groups

#### Open:

```
/aws/lambda/CafeOrderWorker
```

- Click latest log stream

#### You should see lines like:

```
START RequestId:
Order processed: {'customer_name': 'WorkerTest', 'item': 'Coffee', 'quantity': 2}
END RequestId:
REPORT RequestId:
```

#### ✅ This confirms:

- Worker Lambda executed

- JSON parsed

- No retries

#### 🟩 STEP 6 — VERIFY DATABASE (MANDATORY)

#### From EC2 or DB client:

```
mysql -h <rds-endpoint> -u cafe_user -p cafe_db
```

```
SELECT * FROM orders ORDER BY id DESC;
```

or 

```
SELECT * FROM orders ORDER BY created_at DESC;
```

#### Expected:

```
WorkerTest | Coffee | 2
```

table_number ✅

status = RECEIVED ✅

created_at auto-filled ✅

#### 🟩 STEP 7 — VERIFY DYNAMODB (CafeMenu)

- AWS Console → DynamoDB

- Click CafeMenu

- Click Explore table

- Click Coffee

#### Expected:

```
{
  "item": "Coffee",
  "price": 3,
  "orders": 14
}
```

- Attribute orders exists

- Value increased by 2

#### 🟩 STEP 8 — VERIFY CloudWatch Logs

```
✅ Order processed
```

No retries, no DLQ hits.



#### ✅ METHOD 1 COMPLETE

#### At this point:

- Worker Lambda is 100% working

- SQS trigger is correct

- IAM is correct

- VPC access is correct

#### 🚀 METHOD 2 — FULL END-TO-END TEST (API → SQS → WORKER)

Only do this AFTER Method 1 works

#### 🟦 STEP 1 — CALL API GATEWAY

#### From your terminal:

```
curl -X POST \
https://<api-id>.execute-api.us-east-1.amazonaws.com/dev/orders \
-H "Content-Type: application/json" \
-d '{
  "table_number": 2,
  "customer_name": "ApiTest",
  "item": "Latte",
  "quantity": 1
}'
```

#### Expected response:

```
{
  "message": "Order accepted"
}
```

#### 🟦 STEP 2 — CHECK SQS (BRIEFLY)

- Open CafeOrdersQueue

- You may see messages for a few seconds

- They should disappear automatically

#### 🟦 STEP 3 — CHECK WORKER LOGS

- CloudWatch → /aws/lambda/CafeOrderWorker

#### You should see:

```
Order processed: {'customer_name': 'ApiTest', 'item': 'Latte', 'quantity': 1}
```

#### 🟦 STEP 4 — VERIFY DB + DYNAMODB

- Same as Method 1

#### 🔁 FAILURE TEST (OPTIONAL BUT IMPORTANT)

#### To confirm retry behavior:

- Temporarily break worker code

```
raise Exception("FORCE FAIL")
```

- Send SQS message again

#### Observe:

- Message reappears after visibility timeout

- Multiple retries

- Logs show repeated failures

This proves production-grade reliability

### ✅ VERIFY SQS

#### 🟢 Method 1 — CloudWatch Logs (PRIMARY)

**CloudWatch → Logs →  /aws/lambda/CafeOrderWorker**

You should see entries like:

```
Lambda triggered by SQS
Order processed: {'customer_name': 'charlie', 'item': 'Tea', 'quantity': 2}
```

**✅ This is the proof.**

#### 🟢 Method 2 — SQS Metrics (BEST PRACTICE)

**SQS → CafeOrdersQueue → Monitoring**

#### Check these graphs:

| Metric                             | Expected |
| ---------------------------------- | -------- |
| NumberOfMessagesSent               | ↑        |
| NumberOfMessagesReceived           | ↑        |
| NumberOfMessagesDeleted            | ↑        |
| ApproximateNumberOfMessagesVisible | ~0       |

**✅ If Received & Deleted increase, your pipeline is healthy.**

#### 🟢 Method 3 — Disable Trigger (FOR LEARNING ONLY)

#### If you want to see messages again:

1️⃣ Lambda → CafeOrderWorker

2️⃣ Disable SQS trigger

3️⃣ Send message

4️⃣ Poll manually → message appears

Re-enable trigger afterward.

### ⚠️ VERY IMPORTANT AWS RULE (REMEMBER THIS)

> **You NEVER manually poll SQS when Lambda trigger is enabled**

That’s two consumers competing for the same messages.

### 🧠 WHY YOU CANNOT SEE THE MESSAGE IN SQS

**When SQS → Lambda trigger is enabled:**

- Lambda polls SQS automatically

- Message is:

  - Retrieved

  - Processed

  - Deleted immediately on success

- When you click Poll for messages in the console:

  - There is nothing left to poll

So you will see:

```
No messages available
```
**✅ This is SUCCESS, not a failure.**

### 🔄 WHY YOU COULD SEE MESSAGES BEFORE

#### Earlier, when:

- Trigger was disabled

- Lambda failed

- Or Lambda didn’t raise exceptions

Messages stayed in the queue → you could poll them manually.

#### Now:

- Lambda succeeds

- Messages are deleted

- Queue stays empty

---


### 🔥 IMPORTANT CLARIFICATIONS

#### ❓ Why SQS message disappeared?

**Because Lambda DID poll it, but timed out before completing**

- SQS deletes message only after successful invocation, but Lambda retried internally until timeout.

#### ❓ Why no logs before?

**Because:**

- Lambda couldn’t reach RDS

- Timeout occurred before prints

#### ❓ Is your code correct?

✅ YES — your code is PRODUCTION-GRADE

The issue was INFRASTRUCTURE, not logic.

### 🧠 FINAL DIAGNOSIS

| Component          | Status    |
| ------------------ | --------- |
| SQS                | ✅ Working |
| Lambda trigger     | ✅ Working |
| IAM                | ✅ Correct |
| Code               | ✅ Correct |
| **VPC attachment** | ❌ Missing |
| **Timeout**        | ❌ Too low |



### 🔑 COMMON MISTAKES (READ THIS)

❌ Using FIFO queue

❌ Same Lambda for producer + consumer

❌ Visibility timeout too low

❌ No IAM permissions

❌ Batch size > 1 while learning

### 🧠 KEY RULES TO REMEMBER (EXAM + REAL LIFE)

| Rule                      | Truth                    |
| ------------------------- | ------------------------ |
| Worker Lambda Test button | ❌ NOT USED               |
| SQS triggers Lambda       | ✅ AUTOMATIC              |
| Lambda deletes message    | ❌ AWS does after success |
| Exception = retry         | ✅ YES                    |
| No logs = no execution    | ❌ Wrong                  |

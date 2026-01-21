# AWS CAFE LAB

> **AUTHOR & ARCHITECTURE DESIGNER:** CHARLIE

# 🔒 SECTION 7 — AWS CAFE SQS (Async Order Processing)

# PHASE 1 — SQS/LAMBDA (Producer)

## 3️⃣ CREATE API Lambda Function (Producer)

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

# PHASE 3 — SQS/Worker LAMBDA (Consumer)

## 1️⃣ Create Worker Lambda (Consumer)

### 3️⃣ WORKER LAMBDA CODE Production Safe (Recommended)




#### 4️⃣ Verify IAM Role (YOU ARE ALREADY OK)

You already have correct policies ✅

Nothing to change here.


# PHASE 4 — Update Lambda Function Cafe Order Processor

---

# PHASE 5 — Test


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

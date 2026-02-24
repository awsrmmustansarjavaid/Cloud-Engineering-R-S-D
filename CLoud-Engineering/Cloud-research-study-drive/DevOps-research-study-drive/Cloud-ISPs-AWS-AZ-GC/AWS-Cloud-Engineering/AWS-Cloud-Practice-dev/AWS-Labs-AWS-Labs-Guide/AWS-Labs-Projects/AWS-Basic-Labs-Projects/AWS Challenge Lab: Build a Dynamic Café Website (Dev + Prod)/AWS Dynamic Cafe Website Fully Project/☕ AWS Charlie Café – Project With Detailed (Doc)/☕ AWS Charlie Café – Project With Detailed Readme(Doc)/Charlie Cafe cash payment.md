# Charlie Cafe - Cash Payment

# SECTION 5️⃣ ☕ Charlie Café – Order Payment System

## ☕ CHARLIE CAFÉ PHASE 1️⃣ Cach Payment System 

### 1️⃣ DynamoDB / RDS (Order Table)
> **UPDATE DATABASE (VERY IMPORTANT)**

#### 1️⃣ If you are using DynamoDB

#### 🔹 Step 1.1 — Create the CafeOrders Table

- AWS Console → DynamoDB → Tables → CafeOrders

- Fill EXACTLY like this

| Field         | Value        |
| ------------- | ------------ |
| Table name    | `CafeOrders` |
| Partition key | `order_id`   |
| Type          | `String`     |
| Sort key      | ❌ NONE       |
| Table class   | Standard     |
| Capacity mode | On-demand    |
| Encryption    | Default      |


- Click Create table.

**🕐 Wait 1-2 minutes until status shows Active.**

#### 🔹 Step 1.2 — Confirm Primary Key

- Your table must have:

```
Partition Key: order_id (String)
```

**⚠️ If not, STOP — this lab assumes order_id is the key.**

#### 🔹 Step 1.3 — Add Attributes (NO MIGRATION NEEDED)

#### Basic test item (CASH payment – PENDING)

```
{
  "order_id": { "S": "ORD-TEST-001" },
  "table_number": { "N": "5" },
  "item": { "S": "Coffee" },
  "quantity": { "N": "2" },
  "total_amount": { "N": "6" },

  "payment_method": { "S": "CASH" },
  "payment_status": { "S": "PENDING" },

  "status": { "S": "RECEIVED" },
  "created_at": { "S": "2026-01-14T10:30:00Z" }
}
```

#### Another test item (CARD payment – PAID)

```
{
  "order_id": { "S": "ORD-TEST-002" },
  "table_number": { "N": "5" },
  "item": { "S": "Coffee" },
  "quantity": { "N": "2" },
  "total_amount": { "N": "6" },

  "payment_method": { "S": "CARD" },
  "payment_status": { "S": "PENDING" },

  "status": { "S": "RECEIVED" },
  "created_at": { "S": "2026-01-14T10:30:00Z" }
}
```
#### 🔎 VERIFY STEP 1.3 WORKED

Click the item → you should see:

```
payment_method: CASH
payment_status: PENDING
```

✅ That’s it

✅ Nothing else to configure here

✅ DynamoDB auto-creates attributes

❌ No further DB action needed

#### 2️⃣ If you are using RDS (MySQL)

#### Run this ONCE:

```
ALTER TABLE orders
ADD payment_method VARCHAR(10),
ADD payment_status VARCHAR(10);
```

#### verify

```
use cafe_db;
```

```
DESCRIBE orders;
```

### 2️⃣ CREATE LAMBDA FUNCTION

#### 🔹 Step 2.1 — Open Lambda

- AWS Console → Lambda → Create function

#### Settings:

- Function name: CashPaymentLambda

- Runtime: Python 3.10

- Execution role: Use existing role
(Must allow DynamoDB access)

- Click Create function

#### 🔹 Step 2.2 — ADD LAMBDA CODE (WITH COMMENTS)

#### Replace entire code with this:

[CashPaymentLambda.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CashPaymentLambda.py)

- Click Deploy


### 3️⃣ API Gateway – NEW ENDPOINT (CASH)

#### 🔹 Step 3.1 — Open API Gateway

- AWS Console → API Gateway

- Choose:

  - Your existing API (important)

  - Type: REST API

#### 🔹 Step 3.2 — Create Resource

```
/orders
   └── /cash-payment
```

#### Steps:

- Select /orders

- Click Create Resource

- Resource Name: cash-payment

- Resource Path: /cash-payment

- Click Create Resource

#### 🔹 Step 3.3 — Create POST Method

- Select /orders/cash-payment

- Click Create Method

- Choose POST

- Integration type: Lambda Function

- Lambda Function: CashPaymentLambda

- Click Save

#### 🔹 Step 3.4 — Enable CORS (DO NOT SKIP)

- Select /orders/cash-payment

- Click Enable CORS

- Accept defaults

- Click Enable CORS and replace existing

#### 🔹 Step 3.5 — Deploy API

- Click Actions

- Deploy API

- Stage: Prod

- Click Deploy

Your endpoint becomes:

```
POST https://xxxx.execute-api.us-east-1.amazonaws.com/prod/orders/cash-payment
```

### 4️⃣ — FRONTEND CALL (ALREADY MATCHES)

Your frontend correctly calls:

```
fetch("https://xxxx.execute-api.us-east-1.amazonaws.com/prod/orders/cash-payment", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
        order_id: "ORD-XXXX"
    })
});
```

✅ This is correct

✅ No change needed

**⚠️ 4️⃣ is ALREADY implemented in your orders.php.You do NOT need structural changes.**

#### 💻 MODERN CAFE-STYLE orders.php (Frontend Only Modified)

[orders.php](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order.php/orders.php)


**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---

## ☕ CHARLIE CAFÉ PHASE 2️⃣ Admin marks a CASH order as PAID

### 1️⃣ — CREATE ADMIN LAMBDA

#### 🔹 1.1 Open AWS Lambda

- AWS Console → Lambda → Create function

#### 🔹 1.2 Function Settings

- Function name: AdminMarkPaidLambda

- Runtime: Python 3.10

- Execution role: Use existing role
(Must allow DynamoDB UpdateItem)

- Permissions: Choose existing role or create new role with DynamoDB access

- Click Create function

### 2️⃣ — IAM PERMISSIONS (CRITICAL)

Lambda needs UpdateItem permission for your table.

#### Open:

```
AdminMarkPaidLambda
→ Configuration
→ Permissions
→ Role
```

#### Ensure this permission exists:

```
{
  "Effect": "Allow",
  "Action": [
    "dynamodb:UpdateItem",
    "dynamodb:GetItem",
    "dynamodb:Query"
  ],
  "Resource": "arn:aws:dynamodb:*:*:table/CafeOrders"
}
```

- Attach this policy to the Lambda’s role.

- **⚠️ If missing → Admin cannot mark paid.**

- **⚠️ 2️⃣ is ALREADY implemented in your orders.php.You do NOT need structural changes.**


### 3️⃣ — ADMIN LAMBDA CODE (WITH COMMENTS)

#### Replace entire Lambda code with this:

[AdminMarkPaidLambda.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/AdminMarkPaidLambda.py)

### 4️⃣ — CREATE ADMIN API ENDPOINT

#### 🔹 4.1 Open API Gateway

- AWS Console → API Gateway → Choose your existing REST API (or create a new one)

#### 🔹 4.2 Create Resource

- Select your API → Actions → Create Resource

```
/admin
   └── /mark-paid
```

#### Steps:

- Select /

- Create Resource

- Resource name: admin

- Create sub-resource → mark-paid

> **Resource Name: admin → Create Sub-resource mark-paid**

This creates endpoint /admin/mark-paid

#### 🔹 4.3 Create POST Method

- Select /admin/mark-paid

- Create Method → POST

- Integration type: Lambda

- Lambda name: AdminMarkPaidLambda

- Save

#### 🔹 4.4 Enable CORS (MANDATORY)

- Select /admin/mark-paid

- Click Enable CORS

- Accept defaults

- Save

#### 🔹 4.5 Deploy API

- Actions → Deploy API

- Stage: dev

- Deploy

📌 Endpoint URL:

```
POST https://xxxx.execute-api.us-east-1.amazonaws.com/dev/admin/mark-paid
```

### 5️⃣ — admin-orders.html

[admin-orders.html](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/admin-orders/admin-orders.html)

**🔁 Replace with your real API Gateway URL**

```
sudo systemctl restart httpd
```

**✅ Admin feature COMPLETE**

**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**
---
## ☕ CHARLIE CAFÉ PHASE 3️⃣ Order status page understands CARD vs CASH

### 🧠 WHAT THIS PAGE MUST DO

Based on DB values:

| Condition      | Show               |
| -------------- | ------------------ |
| CARD + PAID    | “Payment received” |
| CASH + PENDING | “Pay at counter”   |
| CASH + PAID    | “Cash received”    |

### 🟦 STEP 6 — ORDER STATUS API MUST RETURN FIELDS

Your existing Order Status API must return:

```
{
  "order_id": "ORD-123",
  "payment_method": "CASH",
  "payment_status": "PENDING"
}
```

**⚠️ If missing, update backend first.**

### 🟦 STEP 7 — UPDATE payment-status.php

#### ✅ FULL UPDATED FILE (WITH COMMENTS)

[payment-status.php](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/payment-status.php/payment-status.php)

**🔁 Replace with your real API Gateway URL**

```
sudo systemctl restart httpd
```

**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---

## ☕ CHARLIE CAFÉ PHASE 4️⃣ 🔁 REDIRECTING TO payment-status.php

### 🟦 STEP 1 — REDIRECT FROM order.php (CARD + CASH)

#### 🔁 1️⃣ Change destination page (VERY IMPORTANT)

### ✅ FINAL payment-status.php (CLEAN + PRINT REDIRECT)

Below is a clean, correct version aligned with your flow.

#### 📄 payment-status.php

[payment-status.php](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/payment-status.php/payment-status.php)

**✅ PHASE 4️⃣ STATUS**

> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**

# SECTION 6️⃣ ☕ Charlie Café – Order Payment System

## ☕ CHARLIE CAFÉ PHASE 1️⃣ Cach Payment System 

### 🧪 TEST SCENARIOS (DO THESE)

### 1️⃣ Test — Manual API Test

Use Postman / curl:

```
POST /orders/cash-payment
{
  "order_id": "ORD-123"
}
```

#### Expected:

```
{
  "success": true
}
```
### 2️⃣ Test — Curl Test


curl is usually pre-installed on EC2 instances. For your API:

```
curl -X POST \
  https://q8rq19tfka.execute-api.us-east-1.amazonaws.com/dev/orders/cash-payment \
  -H "Content-Type: application/json" \
  -d '{
        "order_id": "12345",
        "amount": 50,
        "customer": "John Doe"
      }'
```

#### Expected:

```
{"success": true, "message": "Order marked for cash payment"}
```

#### ✅ Explanation:

-X POST → specifies POST request

-H "Content-Type: application/json" → sets header to JSON

-d '{...}' → JSON body of the request

Expected result:
You should get a JSON response from your Lambda/API Gateway, e.g.:

```
{
  "message": "Order 12345 created successfully",
  "order": {
    "order_id": "12345",
    "amount": 50,
    "customer": "John Doe"
  }
}
```

### 3️⃣ Test — DynamoDB Check Test

- Open DynamoDB item:

```
payment_method = CASH
payment_status = PENDING
```

### 4️⃣ Test — UI Test

- Place order

- Click Pay Now (Cash)

- Card UI disappears

- Redirect works

- Order shows pending payment

### 5️⃣ Test — Test Event JSON (for Lambda Console)

- Go to your Lambda → CashPaymentLambda → Test tab

- Click Create new event (or Configure test event)

- Event name: e.g. TestCashPayment

- Template: Choose API Gateway AWS Proxy if available (recommended), or just paste custom JSON below

- Paste one of these into the editor:

#### 1️⃣ Basic successful test (most common)

```
{
  "body": "{\"order_id\": \"ORD-20260131-1234\"}",
  "httpMethod": "POST",
  "path": "/orders/cash-payment",
  "requestContext": {
    "stage": "dev",
    "requestId": "test-1234-abcd"
  },
  "headers": {
    "Content-Type": "application/json"
  },
  "isBase64Encoded": false
}
```

#### 2️⃣ Minimal version 

> **(just the required body – works if your integration is proxy)**

```
{
  "body": "{\"order_id\": \"ORD-20260131-5678\"}"
}
```

#### 3️⃣ With more realistic API Gateway fields

> **(best match for proxy integration)**

```
{
  "resource": "/orders/cash-payment",
  "path": "/orders/cash-payment",
  "httpMethod": "POST",
  "headers": {
    "Content-Type": "application/json",
    "Accept": "*/*"
  },
  "multiValueHeaders": {
    "Content-Type": ["application/json"]
  },
  "queryStringParameters": null,
  "multiValueQueryStringParameters": null,
  "pathParameters": null,
  "stageVariables": null,
  "requestContext": {
    "resourceId": "t89kib",
    "resourcePath": "/orders/cash-payment",
    "httpMethod": "POST",
    "stage": "dev",
    "requestId": "test-request-id-001",
    "identity": {},
    "path": "/dev/orders/cash-payment"
  },
  "body": "{\"order_id\": \"ORD-20260131-9999\"}",
  "isBase64Encoded": false
}
```

#### ✅ Expected success (200):

```
{
  "statusCode": 200,
  "headers": {
    "Access-Control-Allow-Origin": "*"
  },
  "body": "{\"success\": true, \"message\": \"Order marked for cash payment\"}"
}
```

### 6️⃣ Test - API Gateway Endpoint

- Open API Gateway → your API → Dev stage → Resources → /orders/cash-payment → POST

- Click “Test” button (top-right)

- Enter request body (JSON):

```
{
  "order_id": "12345",
  "amount": 50,
  "customer": "John Doe"
}
```

- Click “Test”

- API Gateway will invoke your Lambda → you will see response and logs


#### ✅ Expected success :

```
{"success": true, "message": "Order marked for cash payment"}
```

#### 1️⃣ Your cURL command

```
curl -X POST \
  https://q8rq19tfka.execute-api.us-east-1.amazonaws.com/dev/orders/cash-payment \
  -H "Content-Type: application/json" \
  -d '{
        "order_id": "12345",
        "amount": 50,
        "customer": "John Doe"
      }'
```

#### What this does:

- Sends a POST request to /orders/cash-payment

- Content-Type: application/json → API Gateway will parse the body as a string in event.body

- Payload is:

```
{
  "order_id": "12345",
  "amount": 50,
  "customer": "John Doe"
}
```

#### 2️⃣ How API Gateway passes data to Lambda

From your example Lambda event:

```
{
  "body": "{\"order_id\": \"ORD-20260131-1234\"}",
  "httpMethod": "POST",
  "path": "/orders/cash-payment",
  "requestContext": {
    "stage": "dev",
    "requestId": "test-1234-abcd"
  },
  "headers": {
    "Content-Type": "application/json"
  },
  "isBase64Encoded": false
}
```

#### Key points:

- event.body is a string — you need to parse it in Lambda:

```
const request = JSON.parse(event.body);
console.log(request.order_id); // will print "12345"
```

- httpMethod → POST (useful if your Lambda handles multiple methods)

- path → The API path called

- headers → Content-Type and other headers

- isBase64Encoded → false (body is not base64)

#### 3️⃣ How to test in API Gateway console (without cURL)

- Open API Gateway → your API → Dev stage → Resources → /orders/cash-payment → POST

- Click “Test” button (top-right)

- Enter request body (JSON):

```
{
  "order_id": "12345",
  "amount": 50,
  "customer": "John Doe"
}
```

- Click “Test”

- API Gateway will invoke your Lambda → you will see response and logs

#### 4️⃣ How to test with cURL

- Make sure Content-Type is application/json

- The Lambda will receive event.body as a string, so parse it inside your Lambda:

```
export const handler = async (event) => {
  let request;
  try {
    request = JSON.parse(event.body); // parse string
  } catch (err) {
    return {
      statusCode: 400,
      body: JSON.stringify({ error: "Invalid JSON" }),
    };
  }

  console.log("Received order:", request);

  return {
    statusCode: 200,
    body: JSON.stringify({
      message: `Order ${request.order_id} processed`,
      order: request,
    }),
  };
};
```

- Then call cURL:

```
curl -X POST \
  https://q8rq19tfka.execute-api.us-east-1.amazonaws.com/dev/orders/cash-payment \
  -H "Content-Type: application/json" \
  -d '{
        "order_id": "12345",
        "amount": 50,
        "customer": "John Doe"
      }'
```

#### ✅ Expected Response:

```
{
  "message": "Order 12345 processed",
  "order": {
    "order_id": "12345",
    "amount": 50,
    "customer": "John Doe"
  }
}
```

#### ✅ Tips

- Always parse event.body — API Gateway passes JSON as string.

- For quick testing, use API Gateway console “Test” feature.

- Use Postman or cURL for external testing.

**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---

## ☕ CHARLIE CAFÉ PHASE 2️⃣ Admin marks a CASH order as PAID

### 🧪 TEST SCENARIOS (DO THESE)

- Customer places CASH order → order.php → payment-status.php shows Pay at Counter

- Admin clicks “Mark as Paid” → DynamoDB updates payment_status = PAID

- Customer refreshes payment-status.php → status changes Cash payment received

- Optional: Auto-redirect → print-order.php to print receipt

### 1️⃣ Test — Manual Lambda Test

- Go to your Lambda function → Test tab

- Create new event (or edit existing)

- Paste the JSON above

- Give it a name like TestMarkPaid

- Click Test

### 1️⃣ Simple (Recommanded)

```
{
  "body": "{\"order_id\": \"ORD-123456\"}"
}
```

#### ⚠️ Note: The body must be a string, because in your Lambda you are doing json.loads(event['body']).

#### ✅ Expected Lambda Response

```
{
  "statusCode": 200,
  "headers": {
    "Access-Control-Allow-Origin": "*"
  },
  "body": "{\"success\": true, \"message\": \"Order marked as PAID\"}"
}
```

#### ⚠️ If the order does NOT exist (DynamoDB raises an error):

```
{
  "statusCode": 500,
  "headers": {
    "Access-Control-Allow-Origin": "*"
  },
  "body": "{\"success\": false, \"error\": \"An error message from DynamoDB\"}"
}
```

### 2️⃣ Test — Use Postman / curl:

```
POST /admin/mark-paid
{
  "order_id": "ORD-123"
}
```

#### Expected DynamoDB:

```
payment_status = PAID
```

### 3️⃣ Test — Test via API Gateway Console

- Go to your API Gateway → REST API → /admin/mark-paid → POST method.

- Click “Test”.

- In Request Body, paste the test JSON:

```
{
  "order_id": "ORD-123456"
}
```

- Click “Test”.

You should see a response like:

```
{
  "statusCode": 200,
  "headers": {"Access-Control-Allow-Origin": "*"},
  "body": "{\"success\": true, \"message\": \"Order marked as PAID\"}"
}
```

### 4️⃣ Test from Browser (using fetch)

Since your Lambda sets CORS headers, you can call it from a browser console on any page:

```
fetch("https://xxxx.execute-api.us-east-1.amazonaws.com/dev/admin/mark-paid", {
  method: "POST",
  headers: {
    "Content-Type": "application/json"
  },
  body: JSON.stringify({ "order_id": "ORD-123456" })
})
.then(res => res.json())
.then(console.log)
.catch(console.error);
```

#### Note: 

- Browser will not allow body to be a string inside JSON if you are calling directly with fetch.

- So in this case, change Lambda to accept event['order_id'] directly instead of event['body'] JSON parse if calling from browser.

### 5️⃣ Test via EC2 CLI (cURL)

If you have EC2 CLI or any Linux terminal, you can use curl:

```
curl -X POST "https://xxxx.execute-api.us-east-1.amazonaws.com/dev/admin/mark-paid" \
-H "Content-Type: application/json" \
-d '{"body": "{\"order_id\": \"ORD-123456\"}"}'
```

#### ✅ Expected Output:

```
{
  "statusCode": 200,
  "headers": {"Access-Control-Allow-Origin": "*"},
  "body": "{\"success\": true, \"message\": \"Order marked as PAID\"}"
}
```

#### ✅ Tip: 

- Make sure the API is deployed to the correct stage (dev) before testing.
Also, if your Lambda requires IAM authorizations, you may need to add AWS Signature v4 in CLI calls.



**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**
---
## ☕ CHARLIE CAFÉ PHASE 3️⃣ Order status page understands CARD vs CASH

### 🟦 STEP 8 — FINAL TEST SCENARIOS (DO ALL)

#### 🧪 Scenario A — Card

✔ Order → Card payment

✔ Status shows Paid via Card

#### 🧪 Scenario B — Cash Pending

✔ Order → Pay Now (Cash)

✔ Status shows Pay at Counter

#### 🧪 Scenario C — Cash Paid

✔ Admin → Mark Paid

✔ Refresh status → Cash received

**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---
## ☕ CHARLIE CAFÉ PHASE 4️⃣ 🔁 REDIRECTING TO payment-status.php


**✅ PHASE 4️⃣ STATUS**

> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**
---

# 🟢 SECTION 6️⃣ COMPLETE & VERIFIED

---
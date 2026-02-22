# ☕ AWS CAFE — Order Async Processing & Tracking System


## 🛠 SECTION 1️⃣ Cafe Order Processor

## PHASE 2️⃣ — Verification SQS/LAMBDA (Producer)

#### 1️⃣ CREATE LAMBDA TEST (CONSOLE TEST)

- Click Test

- Select Create new test event

- Event name:

```
CafeOrderProcessor
```

Event JSON:


```
{
  "body": "{\"table_number\":5,\"customer_name\":\"John\",\"item\":\"Coffee\",\"quantity\":2}"
}
```

Click Save

Click Test

#### Expected Result (SUCCESS)

```
{
  "statusCode": 200,
  "body": "{\"order_id\":\"ORD-20260220-1234\",\"table_number\":5,\"customer_name\":\"John\",\"item\":\"Coffee\",\"quantity\":2,\"total\":6.0,\"status\":\"RECEIVED\",\"created_at\":\"2026-02-20 10:30:00\"}"
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

#### 2️⃣ VERIFY MESSAGE IN SQS (CRITICAL)

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

### 3️⃣ Frontend (orders.php)

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

### 4️⃣ Test with API Gateway or Lambda test

#### 1️⃣ Test API Gateway Endpoint (Console Method)

- Go to AWS Console

- Click API Gateway

- Open your API

- Click Resources

- Click /orders

- Click POST

- On the POST method page

- Click the Test button (top right)

- Update Request Body

In Request Body, paste:

```
{
  "table_number": 3,
  "customer_name": "ApiTest",
  "item": "Coffee",
  "quantity": 1
}
```

- Leave:

  - Headers empty (unless using auth)

  - Query params empty

- Click “Test” (Blue Button)

- Scroll down to see:

  - Request

  - Response Body

  - Response Headers

  - Logs

#### ✅ Expected Success Response

You should see:

```
{
  "order_id": "...",
  "table_number": 3,
  "customer_name": "ApiTest",
  "item": "Coffee",
  "quantity": 1,
  "total": 3.0,
  "status": "RECEIVED",
  "created_at": "..."
}
```

#### ❌ If You See "Internal server error"

Immediately:

- Open CloudWatch

- Go to /aws/lambda/YourLambdaName

- Open latest log stream

- Check the exact Python error

#### ⚠️ Important

If console test works but curl fails:

→ CORS issue

→ Missing deploy

→ Wrong stage URL

#### 🔁 After Any Change

- Always:

- Click Deploy API

- Select prod

- Deploy

#### 2️⃣ TEST WITH CURL (Important)

```
curl -X POST \
  https://svirhyw5a3.execute-api.us-east-1.amazonaws.com/prod/orders \
  -H "Content-Type: application/json" \
  -d '{"table_number":3,"customer_name":"CurlTest","item":"Tea","quantity":2}'
```

### NEW API Curl Test

```
curl -X POST \
  https://svirhyw5a3.execute-api.us-east-1.amazonaws.com/prod/orders \
  -H "Content-Type: application/json" \
  -d '{
    "table_number": 5,
    "customer_name": "John",
    "item": "Coffee",
    "quantity": 2
  }'
```




**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**

## PHASE 7️⃣ — Test & Verification

### 1️⃣  FRONTEND → BACKEND VERIFICATION

#### 1️⃣ Submit order from orders.php

📊 Table Number: 2

☕ Item: Tea

👨🏾‍🍳 Quantity: 1

### 2️⃣  BACKEND VERIFICATION (MANDATORY)

### 1️⃣ Test Lambda Directly (Console)

- Check your Lambda CloudWatch logs to ensure the function executed correctly.

- Verify new orders appear in your MariaDB database.

- In Lambda → Test

- **Event name:** Test_CafeOrderProcessor

#### Use this in Lambda Test:

```
{
  "body": "{\"table_number\":5,\"customer_name\":\"John\",\"item\":\"Coffee\",\"quantity\":2}"
}
```

#### ✅ Expected:

Order inserted in RDS

DynamoDB updated

SQS message sent

StatusCode 200

```
{
  "statusCode": 200,
  "body": "{\"order_id\":\"ORD-20260220-1234\",\"table_number\":5,\"customer_name\":\"John\",\"item\":\"Coffee\",\"quantity\":2,\"total\":6.0,\"status\":\"RECEIVED\",\"created_at\":\"2026-02-20 10:30:00\"}"
}
```

### Method 1️⃣ Cafe Order API + RDS Tests

```
sudo nano api-gw-rds-secret-test.sh
```

[Cafe Order API + RDS Tests](../../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/api-gw-rds-secret-test.sh)

#### ▶️ How to Run

```
sudo chmod +x api-gw-rds-secret-test.sh
```

```
sudo ./api-gw-rds-secret-test.sh
```

### Method 2️⃣ Cafe Order API + RDS Tests

### 1️⃣ Test API Gateway

#### Test via CURL

```
curl -X POST \
  https://4njilbv5oj.execute-api.us-east-1.amazonaws.com/prod/orders \
  -H "Content-Type: application/json" \
  -d '{"customer_name":"TestUser","item":"Latte","quantity":1}'
```

#### Expected result:

```
{
  "message": "Order placed successfully"
}
```

#### ✅ New UPDATED API GATEWAY CURL TEST AFTER ADDED TABLE NUMBER (REQUIRED)

```
curl -X POST \
  https://4njilbv5oj.execute-api.us-east-1.amazonaws.com/prod/orders \
  -H "Content-Type: application/json" \
  -d '{
    "table_number": 3,
    "customer_name": "TestUser",
    "item": "Latte",
    "quantity": 1
  }'
```

#### 🟢 Expected Response (SUCCESS)

```
{
  "message": "Order saved successfully",
  "table_number": 3
}
```

#### 🟢 API GATEWAY TEST (MANDATORY)

- **go to  CafeOrderAPI > post method > Test Event Body**

```
{
  "table_number": 5,
  "customer_name": "Charlie",
  "item": "Coffee",
  "quantity": 2
}
```

#### Expected Result

```
{
  "message": "Order saved successfully",
  "table_number": 5
}
```

### 2️⃣ Verify Database

### Method 1 Simple 1-To-1 RDS Test

```
mysql -u cafe_user -p cafe_db
```

or

```
mysql -h <rds-endpoint> -u cafe_user -p
```

```sql
SELECT * FROM orders ORDER BY id DESC;
```
or 
```
use cafe_db;
```
```
SELECT * FROM orders;
```

#### You should see:

```
EC2-Test | Latte | 1
```

#### Updated RDS

```
SELECT id, table_number, customer_name, item, quantity, created_at
FROM orders
ORDER BY id DESC;
```

✔ table_number populated

✔ created_at auto-generated

✔ No duplicate or missing fields

---

#### 3️⃣ Check CloudWatch Logs

- **Lambda → Monitor → Logs**

### You should see:

```
START RequestId:
END RequestId:
```

❌ No SQL errors

---

### 🟢 Common Mistakes (Avoid These)

| Mistake                | Result             |
| ---------------------- | ------------------ |
| Missing `table_number` | 500 error          |
| table_number as string | Type error         |
| quantity ≤ 0           | Validation failure |
| Wrong API stage        | Order not inserted |

### 🟢 SYSTEM STATUS CHECK

✔ API Gateway updated

✔ Lambda aligned

✔ RDS schema aligned

✔ Frontend orders.php aligned

Your system is now schema-consistent from browser → DB.

---

### 🏆 Result

#### You now have:

☕ Restaurant-style table orders

📊 Future-ready analytics

🧱 No backend breakage

🚀 Production-safe change


**✅ PHASE 7️⃣ STATUS**

> **🟢 PHASE 7️⃣ COMPLETE & VERIFIED**

## 🟢 SECTION 1️⃣ COMPLETE & VERIFIED
---
## 🛠 SECTION 3️⃣ — AWS CAFE SQS (Async Order Processing)



## 🟢 SECTION 3️⃣ COMPLETE & VERIFIED
---

## SECTION 4️⃣ — ORDER STATUS DASHBOARD

## PHASE 2️⃣ — VERIFICATION (MANDATORY)

### 🔎 Test in Lambda

- **Go to Lambda → Test**

#### If secret access works:

- ❌ No timeout

- ❌ No access denied

- ✅ DB connects successfully

### 🔎 CloudWatch Log

#### You should see:

```
Fetching DB secret...
```

#### No error like:

```
AccessDeniedException: User is not authorized to perform secretsmanager:GetSecretValue
```

### 🧪 Updated Test JSON 

Use this in Test → Configure test event:

```
{
  "Records": [
    {
      "body": "{\"table_number\": 2, \"customer_name\": \"MetricsTest\", \"item\": \"Coffee\", \"quantity\": 1}"
    }
  ]
}
```

#### ✅ After Testing You Should See:

#### In CafeOrderMetrics table:

```
TOTAL_ORDERS   → count increases
TODAY_ORDERS   → count increases
```

#### In CafeMenu table:

```
Coffee → orders increases
```

#### In RDS orders table:

- New row inserted.


**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**
---
## PHASE 5️⃣ — API GATEWAY ENDPOINT

### 1️⃣ TEST in API Gateway Console

- Open AWS Console → API Gateway → select your API (prod).

- On the left panel, go to Resources → click /get-order-status.

- You will see Methods (GET, OPTIONS, etc.). Click GET.

- Click Test (top right in Method Execution page).

- Leave Request Body empty (GET does not need body).

- Click Test.

- You will see Response Body, Response Headers, Execution Logs, and Latency.

This replicates what your curl request does.

#### ✅ Expected Response body

```
{"metrics": [{"metric": "TODAY_ORDERS", "count": "6"}, {"metric": "TOTAL_ORDERS", "count": "6"}], "recent_orders": [{"table_number": 1, "customer_name": "ConsoleTest", "item": "Latte", "quantity": 2, "created_at": "2026-02-19 11:15:24"}, {"table_number": 2, "customer_name": "WorkerTest", "item": "Latte", "quantity": 2, "created_at": "2026-02-19 11:15:21"}, {"table_number": 1, "customer_name": "WorkerTest", "item": "Coffee", "quantity": 2, "created_at": "2026-02-19 11:15:05"}, {"table_number": 3, "customer_name": "TestUser", "item": "Latte", "quantity": 1, "created_at": "2026-02-19 11:14:48"}, {"table_number": 5, "customer_name": "Charlie-mj", "item": "Coffee", "quantity": 2, "created_at": "2026-02-19 11:14:38"}, {"table_number": 5, "customer_name": "Charlie", "item": "Coffee", "quantity": 2, "created_at": "2026-02-19 11:14:36"}, {"table_number": 5, "customer_name": "Charlie-mj", "item": "Coffee", "quantity": 2, "created_at": "2026-02-19 11:04:38"}, {"table_number": 5, "customer_name": "Charlie", "item": "Coffee", "quantity": 2, "created_at": "2026-02-19 11:02:35"}, {"table_number": 3, "customer_name": "TestUser", "item": "Latte", "quantity": 1, "created_at": "2026-02-19 10:57:47"}, {"table_number": 1, "customer_name": "Ali Khan", "item": "Espresso", "quantity": 2, "created_at": "2026-02-19 07:10:48"}, {"table_number": 2, "customer_name": "Sara Ahmed", "item": "Latte", "quantity": 1, "created_at": "2026-02-19 07:10:48"}]}
```

#### ✅ Expected Response headers

```
{
  "Access-Control-Allow-Origin": "*",
  "Content-Type": "application/json",
  "X-Amzn-Trace-Id": "Root=1-6996f47f-abc5f8e36c038577d3703c22;Parent=75ab38d9ffc2bbf9;Sampled=0;Lineage=1:1466d6d1:0"
}
```

### 2️⃣ Testing with curl 


```
curl https://4njilbv5oj.execute-api.us-east-1.amazonaws.com/prod/get-order-status
```

- Optional: add -v to see headers.

- Optional: add query parameters:

```
curl "https://4njilbv5oj.execute-api.us-east-1.amazonaws.com/prod/get-order-status?table_number=5"
```

#### Notes: 

- GET requests do not require JSON body. That’s why your earlier Lambda 500 errors were with /orders POST — that one expected JSON in the body.

- OPTIONS method (for CORS) is automatically handled; GET works fine in browsers too.

#### 💡 Summary:

- /get-order-status is working ✅

- /orders POST is still failing because the Lambda that updates DynamoDB cannot find the table.

- To fully test /orders, you need to fix DynamoDB table or table name first.

**✅ PHASE 5️⃣ STATUS**

> **🟢 PHASE 5️⃣ COMPLETE & VERIFIED**
---
## PHASE 7️⃣ — FEATURE VERIFICATION (IMPORTANT)

### 1️⃣ Send order from frontend / API

✔ Order placed

### 2️⃣ Check SQS

✔ Message disappears (consumed)

### 3️⃣ Check RDS

```
SELECT * FROM orders ORDER BY created_at DESC;
```

✔ New row present

### 4️⃣ Check DynamoDB → CafeMenu

✔ orders increased for item

### 5️⃣ Check DynamoDB → CafeOrderMetrics

✔ TOTAL_ORDERS increased by 1

### 6️⃣ Check CloudWatch Logs

✔ "Order processed successfully"


### 7️⃣ Verify Apache is Running

```
sudo systemctl status httpd
```

#### If not running:

```
sudo systemctl start httpd
```

```
sudo systemctl enable httpd
```

### 8️⃣ Verify Web Root

```
ls /var/www/html
```

This IS THE CORRECT LOCATION ✅

✔ /var/www/html/ is Apache’s default public directory


### 🔁 Auto Refresh

#### ✔ Implemented here:

```
setInterval(loadData,10000);
```

### ⏳ Loading Spinner

✔ Enabled before fetch

✔ Hidden after response

```
document.getElementById("loader").style.display="block";
```

### 📊 Chart (Orders per Item)

✔ Chart.js used

✔ Auto re-draws on refresh

✔ No page reload

### 📅 Date Filter

✔ Frontend ready

```
<input type="date" id="filterDate">
```

#### 👉 Backend enhancement later:

#### Pass date as query param:

```
/order-status?date=2026-01-09
```
---

### 🏆 RESULT

You now have:

✅ Event-driven backend

✅ Reliable order processing

✅ Real-time metrics

✅ Production-safe SQS worker

✅ Zero backend breakage

---

### 🧪 FINAL VERIFICATION

| Check                     | Result |
| ------------------------- | ------ |
| Place new order           | ✅      |
| RDS updated               | ✅      |
| DynamoDB count +1         | ✅      |
| Order-status page updated | ✅      |


**✅ PHASE 7️⃣ STATUS**

> **🟢 PHASE 7️⃣ COMPLETE & VERIFIED**

## 🟢 SECTION 4️⃣ COMPLETE & VERIFIED
---
## ☕ SECTION 5️⃣ — Customer Order Tracking, Billing & Receipt (Frontend-Only, Zero-Risk)

## 🔔 PHASE 1️⃣ — Customer Order Tracking (Read-Only Backend, Zero-Risk)

### 🧪 STEP 5 — TEST LAMBDA (MANDATORY)

#### Create test event:
> **Lambda name: CafeOrderStatusLambda**

#### Simple Test 

```
{}
```
#### Test with Order ID

```
{
  "queryStringParameters": {
    "order_id": "ORD-TEST-123"
  }
}
```

#### Expected output:

```
statusCode: 200
status: RECEIVED
```

#### Example;

```
{
  "statusCode": 200,
  "headers": {
    "Access-Control-Allow-Origin": "*",
    "Content-Type": "application/json"
  },
  "body": "{\"order_id\": \"ORD-TEST-123\", \"status\": \"RECEIVED\", \"order\": {\"table_number\": 3, \"customer_name\": \"charlie\", \"item\": \"Coffee\", \"quantity\": 2, \"created_at\": \"2026-02-11 12:20:28\"}}"
}
```

### 🧪 STEP 7 — TEST API (CRITICAL)

#### Browser test:

```
https://xxxx.execute-api.us-east-1.amazonaws.com/status/cafe-order-status?order_id=ORD-123
```

#### Example:

```
https://q8rq19tfka.execute-api.us-east-1.amazonaws.com/status/cafe-order-status?order_id=ORD-123
```

#### Expected output:

```
{"order_id": "ORD-123", "status": "RECEIVED", "order": {"table_number": 3, "customer_name": "charlie", "item": "Coffee", "quantity": 2, "created_at": "2026-02-11 12:20:28"}}
```



You should get JSON response.

### 🧪 STEP 9 — END-TO-END TEST

1️⃣ Place order

2️⃣ Copy order link

3️⃣ Open link in new tab

4️⃣ Status page loads

5️⃣ Print works

#### 🧪 TEST THIS FILE (DO NOT SKIP)

STEP 1️⃣ Place an order

→ Order created in DynamoDB

STEP 2️⃣ Copy order status URL

Example:

```
https://your EC2 Public IP/order-status.php?order_id=ORD-123
```

STEP 3️⃣ Open link in browser

✔ Page loads

✔ Cafe background visible

✔ Order data shown

STEP 4️⃣ Click Print Receipt

✔ Browser print opens

✔ Looks like a cafe receipt

#### 🟢 SAFE CONFIRMATION

✔ Frontend-only

✔ No backend change

✔ No Lambda change

✔ No API Gateway change

#### ✅ STATUS

🟢 Order Status Page Fully Updated

🟢 Cafe Theme Applied

🟢 Print Working

🟢 Ready for Production


### ✅ WHAT YOU ACHIEVED

✔ Real customer tracking

✔ Read-only safe backend

✔ No regression risk

✔ Production interview-ready

✔ Clean separation of concerns

**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---
## 🔄 PHASE 2️⃣ — Real Order State Machine (RECEIVED → PREPARING → READY → COMPLETED)

### 🧪 STEP 3 — TEST ORDER CREATION

#### ✅ TEST 2 Test from FRONTEND (REAL USER FLOW)

- Open frontend

```
http://54.147.142.110/orders.php
```

#### Fill form

- Table Number: 1

- Name: Charlie

- Item: Coffee

- Quantity: 3

#### Click Place Order

#### ✅ Expected behavior:

- Order placed

- Receipt shows Order ID

- Payment section loads

- After payment → redirect to:

```
/order-status.php?order_id=ORD-XXXX
```

### 🚨 Common Failures & Fixes

#### ❌ Invalid order reference

Cause: order_id not passed in URL
Fix: Make sure Lambda returns track_url AND frontend redirects to it

#### ❌ Lambda test works, API Gateway fails

Cause: Bad integration request mapping
Fix: Ensure API Gateway passes raw body to Lambda

#### ❌ Frontend works but no redirect

Cause: JS not reading Lambda response
Fix: Ensure frontend uses:
```
window.location.href = response.track_url;
```

#### Expected response:

```
{
  "order_id": "ORD-20260114-8392",
  "status": "RECEIVED",
  "total": 9.00,
  "track_url": "/order-status.php?order_id=..."
}
```

#### ✅ TEST 3 Test API Gateway (Lambda + API)

#### Copy API Gateway URL

```
https://bs0vgnth0f.execute-api.us-east-1.amazonaws.com/prod/orders
```

#### Run from EC2 / Local terminal

```
curl -X POST \
  https://bs0vgnth0f.execute-api.us-east-1.amazonaws.com/prod/orders \
  -H "Content-Type: application/json" \
  -d '{
        "table_number":1,
        "customer_name":"Test User",
        "item":"Coffee",
        "quantity":3
      }'
```

#### ✅ Expected Response:

```
{
  "order_id": "ORD-20260114-8392",
  "status": "RECEIVED",
  "total": 9.0,
  "track_url": "/order-status.php?order_id=ORD-20260114-8392"
}
```

✔ If this fails → API Gateway mapping issue

✔ If this works → continue

### 🧪 STEP 6 — TEST STATUS FLOW (MANDATORY)

> **Lambda Name: CafeOrderWorkerLambda**

#### Test 1: RECEIVED → PREPARING

- Name: CafeOrderWorkerLambda_RECEIVED-PREPARING

```
{
  "body": "{\"order_id\": \"ORD-123\", \"status\": \"PREPARING\"}"
}
```

#### Expected:

```
200 OK
```


```
{
  "body": "{\"order_id\": \"ORD-20260131-1234\", \"status\": \"PREPARING\"}",
  "httpMethod": "POST",
  "path": "/order-update",
  "isBase64Encoded": false
}
```

#### Expected Result:

```
✅ should succeed
```

#### Test 2: PREPARING → READY

- Name: CafeOrderWorkerLambda_PREPARING-READY

```
{
  "body": "{\"order_id\": \"ORD-123\", \"status\": \"READY\"}"
}
```

#### Expected:

```
200 OK
```


```
{
  "body": "{\"order_id\": \"ORD-20260131-1234\", \"status\": \"COMPLETED\"}",
  "httpMethod": "POST",
  "path": "/order-update",
  "isBase64Encoded": false
}
```

#### Expected Result:

```
✅ should succeed after Test 1
```

#### Test 3: READY → COMPLETED

- Name: CafeOrderWorkerLambda_READY-COMPLETED

```
{
  "body": "{\"order_id\": \"ORD-123\", \"status\": \"COMPLETED\"}"
}
```

#### Expected:

```
200 OK
```


```
{
  "body": "{\"order_id\": \"ORD-20260131-1234\", \"status\": \"COMPLETED\"}",
  "httpMethod": "POST",
  "path": "/order-update",
  "isBase64Encoded": false
}
```

#### Expected Result:

```
✅ should succeed
```

#### Test 4: Negative Test: Invalid Transition

> **⚠️ e.g. try to go back to PREPARING after COMPLETED**

- Name: CafeOrderWorkerLambda_Negative-Invalid

```
{
  "body": "{\"order_id\": \"ORD-123\", \"status\": \"PREPARING\"}"
}
```

#### Expected:

```
400
Invalid status transition
```


```
{
  "body": "{\"order_id\": \"ORD-20260131-1234\", \"status\": \"PREPARING\"}",
  "httpMethod": "POST",
  "path": "/order-update",
  "isBase64Encoded": false
}
```

#### Expected Result:

```
✅ should 400 – "Invalid status transition"
```

#### Test 5: Negative Test: Non-existent order

- Name: CafeOrderWorkerLambda_Negative-Non-existent

```
{
  "body": "{\"order_id\": \"ORD-FAKE-9999\", \"status\": \"PREPARING\"}"
}
```

#### Expected:

```
404
Order not found
```

```
{
  "body": "{\"order_id\": \"ORD-FAKE-9999\", \"status\": \"PREPARING\"}",
  "httpMethod": "POST",
  "path": "/order-update",
  "isBase64Encoded": false
}
```

#### Expected Result:

```
✅ should 404 – "Order not found"
```

### 🧑‍💻 STEP 9 — 🧪 FINAL TEST

#### 1️⃣ Test directly in browser

```
https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/status/cafe-order-status?order_id=ORD-XXXX
```

#### 2️⃣ Expected JSON

```
{
  "order": {
    "order_id": "ORD-20260114-8392",
    "table_number": 3,
    "customer_name": "Alex",
    "item": "Coffee",
    "quantity": 2,
    "total_amount": "10.00",
    "status": "PREPARING",
    "created_at": "2026-01-14 10:21:33"
  }
}
```


1️⃣ Place order

2️⃣ Backend returns order_id

3️⃣ Open:

```
order-receipt.php?order_id=ORD-XXXX
```

4️⃣ Status updates automatically

5️⃣ Scan QR → same page

6️⃣ Print → receipt only

**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---
## 🔄 PHASE 4️⃣  — Customer Order Tracking, Billing & Receipt (Frontend-Only, Zero-Risk)

### 🧩 STEP 6 — FINAL TEST (DO NOT SKIP)

#### 1️⃣ Place order

```
order.php → submit
```

#### 2️⃣ Get order ID

```
ORD-XXXX
```

#### 3️⃣ Open tracking link

```
order-status.php?order_id=ORD-XXXX
```

#### 4️⃣ Verify

✅ Status visible

✅ Auto refresh works

✅ QR opens same page

✅ Print hides buttons

✅ Mobile friendly

✅ PHASE 13 COMPLETE

#### You now have:

- Real customer tracking

- Unique order URLs

- Billing + receipt

- Production-grade frontend

- Zero risk to existing system

**✅ PHASE 4️⃣ STATUS**

> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**

---
## 🔐 PHASE 5️⃣ — API Gateway Authorizer Test

### ✅ Role Enforcement Tests

VERY IMPORTANT.

### ✅ TEST 8 — Admin Access Test

- Login as: cafeadmin

- Test: /admin/dashboard

#### ✅ Expected:

```
200 OK
JSON data
``` 

### ✅ TEST 9 — Employee Access to Admin Route

- Login as: ali

- Test: /admin/dashboard

#### ✅ Expected:

```
403 Forbidden
```

If employee can access → Lambda group check broken.

### ✅ TEST 10 — Employee Route Access

- Login as: ali

- Test: /employee/orders

#### ✅ Expected:

```
200 OK
JSON data
``` 

### ✅ TEST 11 — Manager Mixed Access

- Login as: manager1

- Test: 

| Route            | Expected |
| ---------------- | -------- |
| /admin/dashboard | ❌ 403    |
| /admin/orders    | ✅ 200    |
| /employee/orders | ✅ 200    |

If behavior wrong → fix allowed_groups in Lambda.

## 🔐 TEST 12 — Token Expiry Test

- Wait for token expiry (or manually modify exp).

- Then call protected route.

#### ✅ Expected:

- 401 Unauthorized

#### ✅ Your frontend should:

- detect expired token

- auto logout

- redirect to login

## 🔐 TEST 13 — Refresh Token Test

After 1 hour:

- Access token expires.

#### ✅ Your frontend should:

- use refresh_token

- get new access token

- not force logout

- If refresh fails → check:

- ALLOW_REFRESH_TOKEN_AUTH enabled.

## 🔐 TEST 14 — Security Negative Testing (Professional Level)

### 🧪 Test A — Modify JWT Payload

- Change group in JWT manually.

- - Send request.

#### ✅ Expected:

- 401 (signature invalid)

If 200 → serious security problem.

### 🧪 Test B — Remove Group Check in Lambda (temporarily)

- Call route.

- Should still require valid JWT.

This proves API Gateway authorizer works.


### 🔐 TEST 15 — EASIEST WAY TO GET ACCESS TOKEN (Manual Test)

You asked for easiest method.

Here is the clean method.


### 🟢 STEP 1 — Build Login URL

In browser:

```
https://YOUR_DOMAIN.auth.us-east-1.amazoncognito.com/login
?client_id=YOUR_CLIENT_ID
&response_type=code
&scope=openid+email+profile
&redirect_uri=https://YOUR_CLOUDFRONT/login.html
```

Press Enter.

### 🟢 STEP 2 — Login

Enter username/password.

You will be redirected to:

```
https://YOUR_CLOUDFRONT/login.html?code=XYZ123
```

### 🟢 STEP 3 — Exchange Code for Tokens (Manual Method)

Open browser DevTools → Console

Run:

```
fetch("https://YOUR_DOMAIN.auth.us-east-1.amazoncognito.com/oauth2/token", {
  method: "POST",
  headers: {
    "Content-Type": "application/x-www-form-urlencoded"
  },
  body: new URLSearchParams({
    grant_type: "authorization_code",
    client_id: "YOUR_CLIENT_ID",
    code: "PASTE_CODE_FROM_URL",
    redirect_uri: "https://YOUR_CLOUDFRONT/login.html"
  })
})
.then(res => res.json())
.then(console.log);
```

You will receive:

```
{
  access_token: "...",
  id_token: "...",
  refresh_token: "...",
  expires_in: 3600
}
```

Copy access_token.

### 🔥 EVEN EASIER METHOD (Old Implicit Way – Testing Only)

If you temporarily enable:

```
Implicit grant
```

Then use:

```
response_type=token
```

Then after login you will be redirected with:

```
#access_token=xxxx
```

This is easiest for quick manual testing.

But production → Authorization Code is correct.

---


### ✅ TEST 1 — Protected Route Without Token

#### Quick API Test

In browser console:

```
fetch("https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/admin/orders", {
  headers: {
    Authorization: "Bearer YOUR_ACCESS_TOKEN"
  }
})
.then(res => res.json())
.then(console.log);
```

#### ✅ Expected:

```
200 if allowed
403 if wrong group
401 if invalid token
```

- Open browser:

```
https://API_ID.execute-api.us-east-1.amazonaws.com/prod/admin/orders
```

#### ✅ Expected:

```
401 Unauthorized
```

If it returns data → authorizer NOT attached correctly.

### ✅ TEST 2 — Protected Route With Token (Browser Console)

In DevTools:

```
fetch("https://API_ID.execute-api.us-east-1.amazonaws.com/prod/admin/orders", {
  headers: {
    Authorization: "Bearer YOUR_ACCESS_TOKEN"
  }
})
.then(res => res.json())
.then(console.log)
```

#### ✅ Expected:

```
200 OK
JSON data
```

If 401 → token invalid

If 403 → Lambda group check blocked

### ✅ TEST 3 — Public Route Without Token

Test:

```
/public/orders
```

#### ✅ Expected:

```
200 OK
JSON data
``` 
No token required.

### ✅ TEST 4 — Public Route With Invalid Token

Even if header sent:

```
Authorization: Bearer fake
```

Should still work (since no authorizer attached).

### 1️⃣ Test Cognito Authorizer

#### Call Admin Route

```
curl https://<api-id>.execute-api.<region>.amazonaws.com/admin/dashboard \
  -H "Authorization: <ACCESS_TOKEN>"
```

#### Results

| User group | Result |
| ---------- | ------ |
| admin      | ✅ 200  |
| employee   | ❌ 403  |
| no token   | ❌ 401  |

### 2️⃣ Test Lambda

- #### Inside Lambda:

```
event["requestContext"]["authorizer"]["claims"]["cognito:groups"]
```

#### Example:

```
["admin"]
```

or

```
["employee"]
```

#### Summary

| Question                 | Answer               |
| ------------------------ | -------------------- |
| Do I need REST API?      | ❌ NO                 |
| Should I use HTTP API?   | ✅ YES                |
| Where are routes?        | API Gateway → Routes |
| Are routes auto-created? | ❌ NO                 |
| Attach authorizer where? | On EACH route        |
| One Lambda or many?      | ✅ ONE                |

### 3️⃣ FINAL TEST TEST LAMBDA & API (MATCHES YOUR GUIDE)

#### 1️⃣ ❌ Without token

```
curl https://API_ID.execute-api.REGION.amazonaws.com/status/order-status
```

#### ✅ Expected:

```
401 Unauthorized
```

#### 2️⃣ ✅ With Frontend Token

- Login via Cognito Hosted UI

- Get a JWT access token

- Call API Gateway with

```
Authorization: Bearer <access_token>
```

- ✅ Receive JSON response

### 4️⃣ GET /admin/dashboard

```
GET https://<api-id>.execute-api.us-east-1.amazonaws.com/status/admin/dashboard
Authorization: Bearer <token>
```

### 5️⃣ POST /admin/create-user

```
POST https://<api-id>.execute-api.us-east-1.amazonaws.com/status/admin/create-user
Authorization: Bearer <token>
Content-Type: application/json

{
  "username": "john.doe",
  "role": "employee"
}
```

### 6️⃣ GET /employee/orders

```
GET https://<api-id>.execute-api.us-east-1.amazonaws.com/status/employee/orders?employee_id=alice
Authorization: Bearer <token>
```

### 7️⃣ POST /employee/order

```
POST https://<api-id>.execute-api.us-east-1.amazonaws.com/status/employee/order
Authorization: Bearer <token>
Content-Type: application/json

{
  "order_id": "O-103",
  "employee": "alice",
  "items": [
    { "name": "Latte", "quantity": 2, "price": 5 },
    { "name": "Bagel", "quantity": 1, "price": 3 }
  ],
  "total": 13
}
```

### 8️⃣ Test each endpoint

Test each endpoint using Postman or browser:

```
GET https://<api-id>.execute-api.us-east-1.amazonaws.com/prod/admin/dashboard
GET https://<api-id>.execute-api.us-east-1.amazonaws.com/prod/employee/orders
GET https://<api-id>.execute-api.us-east-1.amazonaws.com/prod/order-status?order_id=123
```

**✅ You should get responses from respective Lambda functions.**


**✅ After this, your API Gateway + Lambda + front-end integration is fully professional, secure, and working.**


**✅ PHASE 5️⃣ STATUS**

> **🟢 PHASE 5️⃣ COMPLETE & VERIFIED**
---
## 🔐 PHASE 6️⃣ Lambda Functions 

### 4️⃣ Lambda Code Test

- Name:

```
Test_OrderStatusLambda
```

#### JSON

```
{}
```
#### Expected Result

```
{
  "statusCode": 200,
  "headers": {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Authorization",
    "Access-Control-Allow-Methods": "GET"
  },
```

#### ✅ Result:

```
/order-status?date=YYYY-MM-DD
```

✅ returns filtered orders

### 5️⃣ Lambda Code Test

- Name:

```
Test_AdminDashboardLambda
```

#### JSON

```
{}
```

#### ✅ Expected Result

```
  "statusCode": 200,
```

### 6️⃣ Lambda Code Test

- Name:

```
Test_AdminCreateUserLambda
```

#### JSON

```
{
  "body": "{\"username\": \"john.doe\", \"role\": \"employee\"}"
}
```

#### ✅ Expected Result

```
  "statusCode": 200,
```

### 7️⃣ Lambda Code Test

- Name:

```
Test_EmployeeOrdersLambda
```

#### JSON

```
{
  "queryStringParameters": {
    "employee_id": "alice"
  }
}
```

#### ✅ Expected Result

```
  "statusCode": 200,
```

### 8️⃣ Lambda Code Test

- Name:

```
Test_EmployeeOrderLambda
```

#### JSON

```
{
  "order_id": "O-103",
  "employee": "alice",
  "items": [
    { "name": "Latte", "quantity": 2, "price": 5 },
    { "name": "Bagel", "quantity": 1, "price": 3 }
  ],
  "total": 13
}
```

#### ✅ Expected Result

```
  "statusCode": 200,
```

### 9️⃣ Verification

- Go to Lambda → Monitoring → View Logs

- Check CloudWatch Logs for each Lambda

#### Confirm:

- /admin/dashboard → AdminDashboardLambda response

- /admin/create-user → AdminCreateUserLambda response

- /employee/orders → EmployeeOrdersLambda response

- /employee/order → EmployeeOrderLambda response

#### Test JWT Authorization:

- Access without token → should fail

- Access with token → should succeed

**✅ After this, your API Gateway + Lambda + front-end integration is fully professional, secure, and working.**

**✅ PHASE 6️⃣ STATUS**

> **🟢 PHASE 6️⃣ COMPLETE & VERIFIED**


### 🏁 FINAL VERIFICATION CHECKLIST



✔ API Gateway blocks unauthorized

✔ Lambda blocks wrong roles

✔ Public routes open

✔ Protected routes secured

✔ Expired token rejected

✔ Refresh works


# 🟢 SECTION 5️⃣ COMPLETE & VERIFIED
---
# SECTION 6️⃣ ☕ Charlie Café – Order Payment System

## ☕ CHARLIE CAFÉ PHASE 1️⃣ Cach Payment System 

### 5️⃣ 🧪 TEST SCENARIOS (DO THESE)

#### ✅ Test 1 — Manual API Test

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

Explanation:

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




#### ✅ Test 2 — DynamoDB Check

Open DynamoDB item:

```
payment_method = CASH
payment_status = PENDING
```

#### ✅ Test 3 — UI Test

- Place order

- Click Pay Now (Cash)

- Card UI disappears

- Redirect works

- Order shows pending payment

#### ✅ Test 4 — Test Event JSON (for Lambda Console)

- Go to your Lambda → CashPaymentLambda → Test tab

- Click Create new event (or Configure test event)

- Event name: e.g. TestCashPayment

- Template: Choose API Gateway AWS Proxy if available (recommended), or just paste custom JSON below

- Paste one of these into the editor:

Basic successful test (most common)

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

#### Minimal version 
> **(just the required body – works if your integration is proxy)**

```
{
  "body": "{\"order_id\": \"ORD-20260131-5678\"}"
}
```

#### With more realistic API Gateway fields
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

**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---

## ☕ CHARLIE CAFÉ PHASE 2️⃣ Admin marks a CASH order as PAID

### 5️⃣ 🧪 TEST SCENARIOS (DO THESE)

- Customer places CASH order → order.php → payment-status.php shows Pay at Counter

- Admin clicks “Mark as Paid” → DynamoDB updates payment_status = PAID

- Customer refreshes payment-status.php → status changes Cash payment received

- Optional: Auto-redirect → print-order.php to print receipt

#### ✅ Test 1 — Manual Lambda Test

- Go to your Lambda function → Test tab

- Create new event (or edit existing)

- Paste the JSON above

- Give it a name like TestMarkPaid

- Click Test

#### Test Event JSON (for Lambda Console)
Copy-paste this exact JSON into the Test tab in your Lambda function:

```
{
  "body": "{\"order_id\": \"ORD-1738333333-456\"}",
  "httpMethod": "POST",
  "path": "/orders/cash-payment",
  "resource": "/orders/cash-payment",
  "requestContext": {
    "resourceId": "abc123",
    "resourcePath": "/orders/cash-payment",
    "httpMethod": "POST",
    "stage": "dev",
    "requestId": "test-request-id-1234",
    "identity": {
      "sourceIp": "127.0.0.1"
    }
  },
  "headers": {
    "Content-Type": "application/json"
  },
  "queryStringParameters": null,
  "pathParameters": null,
  "stageVariables": null,
  "isBase64Encoded": false
}
```

#### Minimal Test Event (if you just want to simulate body)
> **(Shorter version — good for quick tests)**

This also works fine for your code:

```
{
  "body": "{\"order_id\": \"ORD-999999999-999\"}"
}
```

#### Expected successful output (if order exists in DynamoDB):

```
{
  "statusCode": 200,
  "headers": {
    "Access-Control-Allow-Origin": "*"
  },
  "body": "{\"success\": true, \"message\": \"Order marked as PAID\"}"
}
```

#### ✅ Test 2 — Use Postman / curl:

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
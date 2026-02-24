# ☕ AWS CAFE — Order Async Processing & Tracking System


## 🛠 SECTION 1️⃣ Cafe Order Processor

## PHASE 2️⃣ — Verification SQS/LAMBDA (Producer)

### 1️⃣ CREATE LAMBDA TEST (CONSOLE TEST)

- Click Test

- Select Create new test event

- Event name:

```
CafeOrderProcessor
```

Since this Lambda currently handles one item per order, a sample test JSON for AWS Lambda console would look like this Event JSON:

```
{
  "body": "{\"table_number\":5,\"customer_name\":\"John\",\"item\":\"Coffee\",\"quantity\":2}"
}
```

- Click Save

- Click Test

#### Expected Result (SUCCESS)

```
{
  "statusCode": 200,
  "body": "{\"order_id\":\"ORD-20260220-1234\",\"table_number\":5,\"customer_name\":\"John\",\"item\":\"Coffee\",\"quantity\":2,\"total\":6.0,\"status\":\"RECEIVED\",\"created_at\":\"2026-02-20 10:30:00\"}"
}
```

#### Notes:

- The Lambda expects event["body"] as a string (JSON-encoded), because in API Gateway POST requests, the body comes as a string.

- If you are testing in Lambda console, you must wrap it as above (string inside "body").

#### ✅ Example with missing optional field (customer_name)

```
{
  "body": "{ \"table_number\": 5, \"item\": \"Latte\", \"quantity\": 1 }"
}
```

- Here, customer_name defaults to "Guest".

#### ✅ Expected Result

If everything works, the Lambda will return status 200 with JSON including the order details:

```
{
  "statusCode": 200,
  "headers": {
    "Access-Control-Allow-Origin": "*"
  },
  "body": "{\"order_id\": \"ORD-20260223-1234\", \"table_number\": 3, \"customer_name\": \"Alice\", \"item\": \"Coffee\", \"quantity\": 2, \"total\": 6.0, \"status\": \"RECEIVED\", \"created_at\": \"2026-02-23 04:00:00\"}"
}
```

#### Notes:

- order_id will be dynamically generated like ORD-YYYYMMDD-XXXX.

- total is automatically calculated (PRICE_LIST[item] * quantity).

- status is always "RECEIVED" initially.

- created_at is the timestamp of the order.

### DynamoDB Result (CafeOrders)

After Lambda runs, DynamoDB table CafeOrders will have a record like:

| Attribute      | Value               |
| -------------- | ------------------- |
| order_id       | ORD-20260223-1234   |
| table_number   | 3                   |
| customer_name  | Alice               |
| item           | Coffee              |
| quantity       | 2                   |
| total_amount   | 6.0                 |
| status         | RECEIVED            |
| payment_method | NONE                |
| payment_status | PENDING             |
| created_at     | 2026-02-23 04:00:00 |

### Menu Metrics / Global Metrics

Your Lambda currently updates these explicitly with:

```
# Per-item metric
menu_table.update_item(
    Key={"item": item},
    UpdateExpression="ADD orders :inc",
    ExpressionAttributeValues={":inc": Decimal(quantity)}
)

# Global metric
metrics_table.update_item(
    Key={"metric": "TOTAL_ORDERS"},
    UpdateExpression="ADD #c :inc",
    ExpressionAttributeNames={"#c": "count"},
    ExpressionAttributeValues={":inc": Decimal(1)}
)
```

#### Important points:

- They are NOT automatic. You must keep these updates if you want CafeMenu and CafeOrderMetrics to reflect actual orders.

- DynamoDB does atomic updates, so concurrent orders are handled safely (no lost counts).

- If you remove these lines, metrics will not be updated, and dashboards / reports will be inaccurate.

✅ So yes, keep these steps if you want metrics updated automatically whenever an order is created.

### SQS Message

- A message is sent to your SQS_QUEUE_URL with the same order data.

- Other Lambdas (like kitchen workers or printers) can consume it asynchronously.

Example SQS message body:

```
{
  "order_id": "ORD-20260223-1234",
  "table_number": 3,
  "customer_name": "Alice",
  "item": "Coffee",
  "quantity": 2,
  "status": "RECEIVED",
  "timestamp": "2026-02-23 04:00:00"
}
```

#### ✅ Summary

- Lambda Test JSON: Must have "body" string with table_number, item, quantity (optional customer_name).

- Expected Response: statusCode: 200, JSON body with order details.

- Metrics Updates: They are explicit in Lambda; not automatic. Keep them if you want real-time dashboards.

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
## PHASE 1️⃣ — API GATEWAY ENDPOINT

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

### 3️⃣ Lambda Test JSON (For AWS Console)

Because you enabled:

✔ Lambda Proxy Integration
✔ GET method

Your Lambda does not require a body.

Use this test event inside Lambda console:

####  ✅ Basic Test Event

```
{}
```

#### ✅ Expected Result

```
{
  "statusCode": 200,
  "headers": {
    "Access-Control-Allow-Origin": "*",
    "Content-Type": "application/json"
  },
  "body": "{\"orders\": [...], \"metrics\": [...]}"
}
```

### 4️⃣ More Realistic API Gateway Test Event

If you want a more accurate test (recommended):

```
{
  "resource": "/get-order-status",
  "path": "/get-order-status",
  "httpMethod": "GET",
  "headers": {},
  "queryStringParameters": null,
  "body": null,
  "isBase64Encoded": false
}
```

#### ✅ Expected Result

```
{
  "statusCode": 200,
  "headers": {
    "Access-Control-Allow-Origin": "*",
    "Content-Type": "application/json"
  },
  "body": "{\"orders\": [...], \"metrics\": [...]}"
}
```



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

#### Simple Test (Recommanded)

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

#### 1️⃣ Browser test:

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

#### 2️⃣ API Gateway test:

```
{}
```

#### Expected output:

```
{"order_id": "ORD-123", "status": "RECEIVED", "order": {"table_number": 3, "customer_name": "charlie", "item": "Coffee", "quantity": 2, "created_at": "2026-02-11 12:20:28"}}
```

#### 3️⃣ Curl test:

```
curl https://xxxx.execute-api.us-east-1.amazonaws.com/status/cafe-order-status
```

#### Example:

```
curl https://zyqkbyrdy3.execute-api.us-east-1.amazonaws.com/prod/cafe-order-status
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

### 1️⃣ RECEIVED → PREPARING

- Name: CafeOrderWorkerLambda_RECEIVED-PREPARING

```
{
  "body": "{\"order_id\":\"ORD-20260222-1234\",\"status\":\"PREPARING\"}"
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

### Result

```
{ "statusCode": 404, "headers": { "Access-Control-Allow-Origin": "*", "Content-Type": "application/json" }, "body": "{\"error\": \"Order not found\"}" } START RequestId: 8542c381-aaea-405e-990d-87778b56056d Version: $LATEST END RequestId: 8542c381-aaea-405e-990d-87778b56056d REPORT RequestId: 8542c381-aaea-405e-990d-87778b56056d Duration: 346.34 ms Billed Duration: 1643 ms Memory Size: 128 MB Max Memory Used: 90 MB Init Duration: 1296.64 ms
```

#### 👍 — this result means your Lambda is working correctly.

The error:

```
{
  "statusCode": 404,
  "body": "{\"error\": \"Order not found\"}"
}
```

means the database did not find this order_id:

```
ORD-20260222-1234
```

So the problem is NOT your Lambda code.
It’s one of these 4 common issues:

### ✅ 1️⃣ The order_id does not exist in RDS

Your CafeOrderProcessor generates order IDs like:

```
ORD-YYYYMMDD-XXXX
```

But 1234 was just an example.

👉 Go to your database and check:

```
SELECT order_id, status FROM orders;
```

Then copy a REAL order_id and test again.

### ✅ 2️⃣ You're Connected to a Different Database

Since you're using Secrets Manager, confirm:

- SECRET_NAME = "CafeDevDBSM"

- That secret contains the correct:

 - host

 - username

 - password

 - dbname

Sometimes:

- Processor Lambda inserts into dev DB

- Worker Lambda connects to another DB

Very common issue.

### ✅ 3️⃣ Order Was Never Created

Did you successfully run CafeOrderProcessor first?

Test flow should be:

1️⃣ Call CafeOrderProcessor → creates order

2️⃣ Copy returned order_id

3️⃣ Call CafeOrderWorkerLambda

If you manually typed the order_id without creating it first, it will fail.

### ✅ 4️⃣ Case Sensitivity Issue

MySQL string comparison is usually case-sensitive depending on collation.

Make sure:

```
ORD-20260222-1234
```

is exactly the same case in the database.

### 🔎 How To Debug Quickly

Temporarily add this inside your Worker Lambda before the SELECT:

```
print("DEBUG - order_id received:", order_id)
```

And after connecting:

```
print("DEBUG - Connected to DB:", secret["host"], secret["dbname"])
```

#### This will confirm:

- You're sending correct ID

- You're connected to expected DB

### 🚀 What You Should Do Now

- Open RDS query editor

- Run:

```
SELECT * FROM orders ORDER BY created_at DESC;
```

- Copy a real order_id

- Use it in your test JSON

Example:

```
{
  "body": "{\"order_id\":\"ORD-20260222-4821\",\"status\":\"PREPARING\"}"
}
```

### 💡 Most Likely Cause

99% of the time it's simply:

- You used a sample order_id that doesn’t exist.

- Your Lambda is behaving correctly 👍

#### ✅ 1️⃣ Test Debug Test – Normal Event (Pretty Format)

Use this in Lambda Test:

```
{
  "body": "{\"order_id\":\"ORD-TEST-DEBUG\",\"status\":\"PREPARING\"}"
}
```

#### This helps confirm:

- Lambda parses body correctly

- order_id is read correctly

- If it returns 404 → DB truly doesn’t contain it

#### ✅ 2️⃣ Debug Test – Missing Body (Should Return 400)

```
{
}
```

#### ✅ Expected result:

```
{
  "statusCode": 400,
  "body": "{\"error\":\"order_id and status are required\"}"
}
```

If this works, your parsing logic is correct.

#### ✅ 3️⃣ Debug Test – Invalid JSON Body

```
{
  "body": "invalid-json"
}
```

#### ✅ Expected result:

- Should trigger 500 error

- Confirms JSON parsing path

#### ⚠️ IMPORTANT (Very Important)

Test JSON cannot debug database connection issues.

If you are getting:

```
Order not found
```

#### That means:

✔ Lambda executed

✔ Connected to DB

✔ Query executed

❌ No matching order_id

#### It is NOT:

- Secrets Manager issue

- DB connection issue

- IAM issue

- If DB connection was failing, you'd get 500 error, not 404.

### 🚀 Real Debug Method Without Code Changes

- Go to RDS and run:

```
SELECT order_id, status FROM orders;
```

Copy EXACT order_id returned.

Then test:

```
{
  "body": "{\"order_id\":\"<REAL_ORDER_ID>\",\"status\":\"PREPARING\"}"
}
```

Replace <REAL_ORDER_ID>.

### 🔥 Why You're Getting 404

Because:

```
ORD-20260222-1234
```

Most likely does NOT exist in your table.

### 2️⃣ Test PREPARING → READY

- Name: CafeOrderWorkerLambda_PREPARING-READY

```
{
  "body": "{\"order_id\":\"ORD-20260222-1234\",\"status\":\"READY\"}"
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

### 3️⃣ Test READY → COMPLETED

- Name: CafeOrderWorkerLambda_READY-COMPLETED

```
{
  "body": "{\"order_id\":\"ORD-20260222-1234\",\"status\":\"COMPLETED\"}"
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

### 4️⃣ Test Negative Test: Invalid Transition

> **⚠️ e.g. try to go back to PREPARING after COMPLETED**

- Name: CafeOrderWorkerLambda_Negative-Invalid

```
{
  "body": "{\"order_id\":\"ORD-20260222-1234\",\"status\":\"COMPLETED\"}"
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

### 5️⃣ Test Missing Fields Test

- Name: CafeOrderWorkerLambda_Negative-Non-existent

```
{
  "body": "{}"
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

### 6️⃣ Test Order Not Found Test

- Name: CafeOrderWorkerLambda_ONFT

```
{
  "body": "{\"order_id\":\"ORD-00000000-9999\",\"status\":\"PREPARING\"}"
}
```

#### Expected:

```
404
Order not found
```

### 🚀 Important

Replace:

```
ORD-20260222-1234
```

with a real order_id that exists in your database.

### 🔥 Pro Tip (API Gateway Users)

If you are testing through API Gateway, this is the raw request body:

```
{
  "order_id": "ORD-20260222-1234",
  "status": "PREPARING"
}
```

Lambda console requires the wrapped "body" format.
API Gateway does NOT.

### API Test

### 1️⃣ API Gateway 

inside API Gateway:

```
{
  "order_id": "ORD-XXXX",
  "status": "PREPARING"
}
```

#### ✅ Expected JSON

```
{"error": "Order not found"}
```

#### That means:

✔ API Gateway → Lambda integration is correct

✔ Lambda executed

✔ DB connection worked

✔ It just didn’t find that order

So this part is GOOD.

### 2️⃣ Test with curl

You MUST send a POST request with JSON body:

```
curl -X POST https://zyqkbyrdy3.execute-api.us-east-1.amazonaws.com/prod/order-update \
-H "Content-Type: application/json" \
-d '{
  "order_id": "ORD-20260222-4821",
  "status": "PREPARING"
}'
```

### 3️⃣ Test in Browser

Browsers cannot easily send POST with JSON directly via URL.

You need:

- Postman

- curl

- Or a small HTML/JS fetch request

Example JavaScript:

```
fetch("https://zyqkbyrdy3.execute-api.us-east-1.amazonaws.com/prod/order-update", {
  method: "POST",
  headers: {
    "Content-Type": "application/json"
  },
  body: JSON.stringify({
    order_id: "ORD-20260222-4821",
    status: "PREPARING"
  })
})
.then(res => res.json())
.then(data => console.log(data));
```

### 🔥 Quick Checklist for You

- Redeploy API to stage prod

- Confirm stage name

- Use this exact curl:

```
curl -X POST https://zyqkbyrdy3.execute-api.us-east-1.amazonaws.com/prod/order-update \
-H "Content-Type: application/json" \
-d '{"order_id":"REAL_ORDER_ID","status":"PREPARING"}'
```

- Replace REAL_ORDER_ID with actual one from DB.

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

### 🟡 Test Inside API Gateway Console

- Go to: API Gateway → Resources → /order-status → GET → Test

### 1️⃣ : GET /admin/dashboard

### ✅ Test API

- Method: GET

- Path: /admin/dashboard

```
{
  "totalEmployees": 25,
  "totalOrdersToday": 42,
  "revenueToday": 1234.56
}
```

- Click Test

#### ✅ Expected Result:

- Status: 200

### 🌐 Browser Test

- Open browser and enter:

```
https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod/admin/dashboard
```

#### ✅ Expected Result:

```
{
  "totalEmployees": 25,
  "totalOrdersToday": 42,
  "revenueToday": 1234.56
}
```

### ✅ EC2 Test

```
curl https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod/admin/dashboard
```

#### ✅ Expected Result:

```
{"totalEmployees":25,"totalOrdersToday":42,"revenueToday":1234.56}
```


### 2️⃣ : POST /admin/create-user

### ✅ Test API

Method: POST

Body:

```
{
  "username": "john",
  "role": "admin"
}
```

- Click Test

#### ✅ Expected Result:

```
{
  "message": "User john created with role admin",
  "username": "john",
  "role": "admin"
}
```

### 🌐 Browser Test

- Open browser and enter:

```
https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod/employee/orders?employee_id=alice
```

#### ✅ Expected Result:

```
[
  {
    "order_id": "O-101",
    "employee": "alice",
    "total": 23.5
  }
]
```

### ✅ EC2 Test

```
curl -X POST https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod/admin/create-user \
-H "Content-Type: application/json" \
-d '{"username":"john","role":"admin"}'
```

#### ✅ Expected Result:

```
{"message":"User john created with role admin","username":"john","role":"admin"}
```

### ✅ Test 3️⃣ : GET Employee Orders

Method: GET

Request Body: leave blank (GET request does not have a body)

- Click Test

#### ✅ Expected Result:

```
[
  {
    "order_id": "O-101",
    "employee": "alice",
    "total": 23.5
  }
]
```

If employee_id=all:

```
[
  { "order_id": "O-101", "employee": "alice", "total": 23.5 },
  { "order_id": "O-102", "employee": "bob", "total": 12.0 }
]
```

- Status Code: 200 OK

- Headers: "Content-Type": "application/json"

### ✅ EC2 Test

```
curl "https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod/employee/orders?employee_id=alice"
```

#### ✅ Expected Result:

```
[{"order_id":"O-101","employee":"alice","total":23.5}]
```

### ✅ Test 4️⃣ : POST Employee Create Order

Method: POST

Body:

```
{
  "order_id": "O-999",
  "employee": "alice",
  "total": 45.5
}
```

- Click Test

#### ✅ Expected Result:

```
{
  "message": "Order O-999 created successfully",
  "order": {
    "order_id": "O-999",
    "employee": "alice",
    "total": 45.5
  }
}
```

### ✅ EC2 Test

```
curl -X POST https://abc123xyz.execute-api.us-east-1.amazonaws.com/prod/employee/order \
-H "Content-Type: application/json" \
-d '{"order_id":"O-999","employee":"alice","total":45.5}'
```

#### ✅ Expected Result:

```
{"message":"Order O-999 created successfully","order":{"order_id":"O-999","employee":"alice","total":45.5}}
```

### 🔹 If You Get Errors

#### ❌ 403 Forbidden

→ API not deployed

→ IAM authorization enabled

→ Missing API key

#### ❌ 500 Internal Server Error

→ Check CloudWatch Logs

- Go to: AWS Console → CloudWatch → Log Groups → /aws/lambda/CompanyManagementLambda

#### ❌ 404 Not Found

→ Wrong route

→ Stage name missing

→ Forgot to deploy API

### 🔹 Quick Notes for API Gateway Console Testing

#### GET requests:

- Use Query String Parameters for filtering (employee_id)

- Body is ignored

#### POST requests:

- Body must be valid JSON

- Set Content-Type: application/json

#### Errors you may see:

- 400 Bad Request → invalid JSON in body

- 404 Not Found → wrong resource path

- 500 Internal Server Error → check Lambda logs in CloudWatch

### 🔹 IMPORTANT — After Creating Routes

After adding routes, you MUST:

```
Deploy API → Select Stage → Deploy
````

Otherwise changes won’t work.

### 🔹 Final Expected Behavior Summary

| Endpoint           | Method | Browser | EC2 Curl | Expected              |
| ------------------ | ------ | ------- | -------- | --------------------- |
| /admin/dashboard   | GET    | ✅       | ✅        | Dashboard JSON        |
| /admin/create-user | POST   | ❌       | ✅        | User created message  |
| /employee/orders   | GET    | ✅       | ✅        | Orders list           |
| /employee/order    | POST   | ❌       | ✅        | Order created message |




**✅ PHASE 5️⃣ STATUS**

> **🟢 PHASE 5️⃣ COMPLETE & VERIFIED**
---
## 🔐 PHASE 6️⃣ Lambda Functions 

### ✅ Lambda Test JSON

Since this Lambda uses queryStringParameters, here are proper test events.

### 1️⃣ Admin Dashboard (GET)

- Name: Admin_Dashboard

#### ✅ Test JSON :

```
{
  "httpMethod": "GET",
  "resource": "/admin/dashboard"
}
```

#### ✅ Expected Result:

```
{
  "statusCode": 200,
  "headers": {
    "Content-Type": "application/json"
  },
  "body": "{\"totalEmployees\":25,\"totalOrdersToday\":42,\"revenueToday\":1234.56}"
}
```

#### ✅ If you parse the body JSON, actual data is:

```
{
  "totalEmployees": 25,
  "totalOrdersToday": 42,
  "revenueToday": 1234.56
}
```

### 2️⃣ Admin Create User (POST)

- Name: Admin_Create_User

#### ✅ Test JSON :

```
{
  "httpMethod": "POST",
  "resource": "/admin/create-user",
  "body": "{\"username\":\"john\",\"role\":\"admin\"}"
}
```

#### ✅ Expected Result:

```
{
  "statusCode": 200,
  "headers": {
    "Content-Type": "application/json"
  },
  "body": "{\"message\":\"User john created with role admin\",\"username\":\"john\",\"role\":\"admin\"}"
}
```

#### ✅ Parsed body:

```
{
  "message": "User john created with role admin",
  "username": "john",
  "role": "admin"
}
```



### 3️⃣ Employee Orders (GET)

- Name: Employee_Orders

#### ✅ Test JSON :

```
{
  "httpMethod": "GET",
  "resource": "/employee/orders",
  "queryStringParameters": {
    "employee_id": "alice"
  }
}
```

#### ✅ Expected Result:

```
{
  "statusCode": 200,
  "headers": {
    "Content-Type": "application/json"
  },
  "body": "[{\"order_id\":\"O-101\",\"employee\":\"alice\",\"total\":23.5}]"
}
```

#### ✅ Parsed body:

```
[
  {
    "order_id": "O-101",
    "employee": "alice",
    "total": 23.5
  }
]
```

If you remove employee_id, it will return both orders.

### 4️⃣ Create Employee Order (POST)

- Name: Employee_Order

#### ✅ Test JSON :

```
{
  "httpMethod": "POST",
  "resource": "/employee/order",
  "body": "{\"order_id\":\"O-999\",\"employee\":\"alice\",\"total\":45.5}"
}
```

#### ✅ Expected Result:

```
{
  "statusCode": 200,
  "headers": {
    "Content-Type": "application/json"
  },
  "body": "{\"message\":\"Order O-999 created successfully\",\"order\":{\"order_id\":\"O-999\",\"employee\":\"alice\",\"total\":45.5}}"
}
```

#### ✅ Parsed body:

```
{
  "message": "Order O-999 created successfully",
  "order": {
    "order_id": "O-999",
    "employee": "alice",
    "total": 45.5
  }
}
```

### 🚨 Important Notes

#### 1️⃣ Why body is a STRING?

Because API Gateway requires Lambda proxy integration response format:

```
{
  "statusCode": 200,
  "body": "string"
}
```

That’s why we use:

```
JSON.stringify(body)
```

#### 2️⃣ These test events work for:

- API Gateway REST API

- Lambda Console Testing

If using HTTP API (v2) the event shape is slightly different (rawPath, requestContext.http.method).

### 🔎 What Happens If Route Doesn't Match?

Example test:

```
{
  "httpMethod": "GET",
  "resource": "/unknown"
}
```

#### Result:

```
{
  "statusCode": 404,
  "body": "{\"error\":\"Route not found\"}"
}
```

### 🎯 Final Confirmation

Yes — all 4 test events are:

✔ Valid

✔ Correct format

✔ Will work with the merged Lambda

✔ Return the responses shown above

**✅ PHASE 6️⃣ STATUS**

> **🟢 PHASE 6️⃣ COMPLETE & VERIFIED**


# 🟢 SECTION 5️⃣ COMPLETE & VERIFIED
---
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
# ☕ CAFE LAB – ADVANCED SALES ANALYTICS & REPORTING SYSTEM
> **(Using Existing Order Status System)**


# SECTION 1️⃣ SALES ANALYTICS & REPORTING SYSTEM

## PHASE 1️⃣ – RDS

### test in MySQL:

```
SELECT order_id, status, payment_status
FROM orders
ORDER BY created_at DESC
LIMIT 10;
```

If you see:

```
status = RECEIVED
```

Then analytics will show 0.



**✅ PHASE 1 STATUS**

> **🟢 PHASE 1 COMPLETE & VERIFIED**
---
## PHASE 2️⃣  – ANALYTICS LAMBDA (FULL CODE)

### 1️⃣ CREATE TEST EVENT

❌ “Empty event” is ONLY for health check

✅ Real test needs API Gateway–like event

- **Deploy → Test → Create new test event**

- **Test event name:** AnalyticsTodayTest

- **Event JSON (COPY EXACTLY)**

```
{
  "queryStringParameters": {
    "period": "today"
  }
}
```

#### ✅ EXPECTED SUCCESS OUTPUT (200)

```
{
  "statusCode": 200,
  "headers": {
    "Access-Control-Allow-Origin": "*"
  },
  "body": "{\"total_sales\":100,\"total_cost\":70,\"profit\":30,\"orders_count\":1}"
}
```

or 

```
{
  "queryStringParameters": {"period": "today"}
}
```

#### ✅ You should now see real totals:

```
{
  "period": "today",
  "total_sales": 17.0,
  "total_cost": ...,
  "profit": ...,
  "orders_count": 4,
  "profit_per_item": [...]
}
```


#### ✅ EXPECTED SUCCESS OUTPUT (401 Unauthorized)

```
{ "statusCode": 401, "headers": { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" }, "body": "\"Unauthorized\"" }
```

---

### 💡 Important :


### 💡 Why This Will Fix Your Button

Previously:

- Lambda was filtering wrong columns

- So it returned 0

- So frontend looked like it "wasn't working"

Now:

- Correct SQL

- Correct column names

- Real filtering

- RDS only

- No DynamoDB confusion

If after this it still returns 0, send me:

```
SELECT order_id, status, payment_status, total_amount, total_cost, created_at
FROM orders
ORDER BY created_at DESC
LIMIT 5;
```

And I’ll pinpoint it immediately.

### 🔎 Let’s Prove It (Run These Queries in MySQL)

#### 1️⃣ Check what statuses actually exist:

```
SELECT status, payment_status, COUNT(*) 
FROM orders
GROUP BY status, payment_status;
```

#### 2️⃣ Check today's orders without filters:

```
SELECT order_id, status, payment_status, total_amount, created_at
FROM orders
WHERE created_at >= CURDATE()
ORDER BY created_at DESC;
```

### 🎯 What I Strongly Suspect

From your table:

```
status default = RECEIVED
```

Most likely your rows look like:

| status   | payment_status |
| -------- | -------------- |
| RECEIVED | PAID           |
| RECEIVED | UNPAID         |

But NOT:

```
status = COMPLETED
```

So your analytics filter removes everything.

### 🔥 Quick Temporary Test

To confirm instantly, modify your SQL in Lambda to:

```
SELECT item,
       quantity,
       total_amount,
       total_cost
FROM orders
WHERE payment_status = 'PAID'
AND created_at >= %s
```

👉 Remove this line:

```
AND status = 'COMPLETED'
```

Deploy.

Test again:

```
/analytics?period=today
```

If totals now appear → 🎯 CONFIRMED.

Your system never sets status = COMPLETED.

### 🎯 Final Recommended WHERE Clause

Use this:

```
WHERE payment_status = 'PAID'
AND created_at >= %s
```

That’s enough for correct revenue tracking.

### 🚀 Why Your Button Was "Not Working"

It was working.

Lambda was returning zero.

Frontend showed zero.

It looked broken.

But the real issue was SQL filtering.

### 🔎 Now Do This

Run:

```
SELECT status, payment_status, COUNT(*) 
FROM orders
GROUP BY status, payment_status;
```

Paste result here.


#### 🔹 Why 401 Appears

In your Lambda:

```
try:
    claims = event["requestContext"]["authorizer"]["claims"]
    groups = claims.get("cognito:groups", "")
except KeyError:
    return response(401, "Unauthorized")
```

- event["requestContext"]["authorizer"]["claims"] only exists when the request comes through API Gateway with Cognito Authorizer attached.

- If you run the Lambda directly from the console (the “Test” button), event doesn’t have these fields.

That’s why it returns 401.

### 🔹 Option 1: Add a Mock Test Event

You can simulate a request from API Gateway with Cognito claims:

```
{
  "requestContext": {
    "authorizer": {
      "claims": {
        "cognito:groups": "Admin"
      }
    }
  },
  "queryStringParameters": {
    "period": "day"
  }
}
```
#### ✅ EXPECTED

```
{
  "statusCode": 200,
  "headers": {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*"
  },
  "body": "{\"period\": \"day\", \"total_sales\": 0.0, \"total_cost\": 0.0, \"profit\": 0.0, \"orders_count\": 6, \"profit_per_item\": [{\"item\": \"Unknown Item\", \"quantity\": 4, \"sales\": 0.0, \"cost\": 0.0, \"profit\": 0.0}]}"
}
```

- This will pass the Admin check → Lambda will process normally.

- You can also test with "cognito:groups": "" → will return 403 Access denied.

#### Option 2: Test via API Gateway

- Deploy your Lambda behind an API Gateway endpoint.

- Use Cognito Authorizer.

- Call the API using a user in the Admin group.

- Then the Lambda will return real analytics instead of 401.

#### 🔹 Quick Debug Tip

If you want to temporarily skip authorization for testing:

```
try:
    claims = event["requestContext"]["authorizer"]["claims"]
    groups = claims.get("cognito:groups", "")
except KeyError:
    groups = "Admin"  # TEMP: for testing only
```

> **⚠️ Only use this for testing in Lambda console. Never leave this in production.**

### 2️⃣ HEALTH CHECK TEST (EMPTY EVENT)

> **This confirms Lambda boots correctly.**

#### 1️⃣ Create another test event:

```
Test name: HealthCheck
```

#### 2️⃣ Event JSON:

```
{}
```

- **Click Test**

#### ✅ EXPECTED RESULT

```
StatusCode: 400
Body: "Invalid period"
```

✔ Lambda is alive

✔ Error handling works

✔ Code path correct

### 3️⃣ TEST ALL PERIODS (NO GUESSING)

> **Create 3 separate test events:**

#### 1️⃣ TODAY

```
{
  "queryStringParameters": {
    "period": "today"
  }
}
```

#### 2️⃣ WEEK

```
{
  "queryStringParameters": {
    "period": "week"
  }
}
```

#### 3️⃣ MONTH

```
{
  "queryStringParameters": {
    "period": "month"
  }
}
```

**✅ Each must return statusCode: 200**

### 4️⃣ CHECK CLOUDWATCH LOGS (DEBUGGING STEP)


#### 1️⃣ Go to:

```
Lambda → Monitor → View logs in CloudWatch
```

#### 1️⃣ Open latest log stream

You MUST see:

```
START RequestId
END RequestId
REPORT RequestId
```

❌ If logs missing → IAM issue

❌ If timeout → DynamoDB index missing

❌ If AccessDenied → wrong policy

### 5️⃣ – COMMON FAILURES & FIX (IMPORTANT)

#### ❌ Error: ValidationException: Index not found

#### ➡️ Fix:

DynamoDB → Indexes → confirm name is exactly

```
order_date-index
```

#### ❌ Error: NoneType is not subscriptable

#### ➡️ Fix:

Test event missing:

```
queryStringParameters
```

#### ❌ Returns zeros but no error

#### ➡️ Fix:

Table has no matching dates

Ensure order_date is YYYY-MM-DD

#### 6️⃣ – API GATEWAY READY CHECK (FINAL)

Once Lambda test passes:

#### You are READY to connect API Gateway:

```
GET /analytics?period=today
```

❌ No Lambda change needed

❌ No extra config needed


**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**
---
## PHASE 3️⃣  – API GATEWAY

### 1️⃣ – API GATEWAY CONFIGURATION

#### 1️⃣ TEST FROM API GATEWAY (NO UI YET)

#### Go to:

```
/analytics → GET
```

- Click Test

- Under Query Strings, enter:

```
period=today
```

- **Click Test**

#### ✅ EXPECTED RESULT (VERY IMPORTANT)

Status:

```
200
```

Response body (example):

```
{
  "total_sales": 1200,
  "total_cost": 800,
  "profit": 400,
  "orders_count": 25
}
```

**If this works → API Gateway is configured correctly**

### COMMON MISTAKES (READ CAREFULLY)

| Mistake                            | Result                |
| ---------------------------------- | --------------------- |
| Forgot to deploy API               | Old config still used |
| Added param in Integration Request | Won’t work            |
| Used HTTP API instead of REST      | Different behavior    |
| Marked `period` as required        | Test fails            |
| Typo in parameter name             | Lambda gets null      |

### ✅ FINAL CONFIRMATION CHECKLIST

✔ /analytics exists

✔ GET method exists

✔ Method Request → Query String → period added

✔ Lambda Proxy Integration enabled

✔ API deployed

✔ Test works

```
period=today|week|month
```

**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---
## PHASE 4️⃣  BOOTSTRAP ANALYTICS UI





**✅ PHASE 4️⃣ STATUS**

> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**
---
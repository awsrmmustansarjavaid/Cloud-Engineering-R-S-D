# AWS CAFE LAB

# 🔒 SECTION 5 — ORDER STATUS DASHBOARD

### 🎯 WHAT YOU WANT (CLARIFIED)

#### You want a new frontend page:

```
/order-status
```

#### That shows:

✅ Total orders count

✅ Orders synced through:

- API Gateway

- Lambda

- SQS

- RDS

- DynamoDB

  ✅ Date & time per order

  ✅ Auto-updated (near real-time)

  ✅ Existing order system remains UNTOUCHED

### 🧠 IMPORTANT REALITY CHECK

**You cannot directly “count” orders from SQS because:**

**🔴 SQS is a temporary transport layer**
**Messages are deleted after processing**

#### So in real systems:

- RDS = Source of truth (orders history)

- DynamoDB = Fast counters / dashboard cache

- SQS = Invisible to users (internal)

✔️ This is NORMAL and CORRECT architecture.



### 🏆 RECOMMENDED DESIGN (PRODUCTION)

✅ RDS = Order Records

✅ DynamoDB = Order Counters + Status

✅ Lambda = Aggregator

✅ API Gateway = Dashboard API

✅ Frontend = Order Status Page

### 📐 FINAL ARCHITECTURE (ORDER STATUS DASHBOARD)

```
Browser (order-status.html)
      |
      |--> API Gateway /order-status
              |
              |--> Lambda (OrderStatusLambda)
                      |
                      |--> RDS (orders table)
                      |--> DynamoDB (order_metrics)
```

##  PHASE 1️⃣ — RDS DATABASE

### 1️⃣ UPDATE DATABASE (SAFE CHANGE)

#### RDS: orders table

```
ALTER TABLE orders
ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
```

✔️ No breaking change

✔️ Automatically tracks date & time

---
##  PHASE 2️⃣ — DYNAMODB

### 1️⃣ CREATE DYNAMODB METRICS TABLE

#### 1️⃣ Table name:

```
CafeOrderMetrics
```

#### 2️⃣ Partition key:

```
metric (String)
```

#### Sample items:

```
{ "metric": "TOTAL_ORDERS", "count": 120 }
{ "metric": "TODAY_ORDERS", "count": 25 }
```

---
##  PHASE 3️⃣ — LAMBDA

###  1️⃣ UPDATE WORKER LAMBDA (SAFE ADDITION)

#### Inside your SQS Worker Lambda, after DB insert:

```
metrics_table = dynamodb.Table("CafeOrderMetrics")

metrics_table.update_item(
    Key={"metric": "TOTAL_ORDERS"},
    UpdateExpression="ADD #c :inc",
    ExpressionAttributeNames={"#c": "count"},
    ExpressionAttributeValues={":inc": Decimal(1)}
)
```

✔️ RDS remains main source

✔️ DynamoDB gives fast counters

### 2️⃣ CREATE ORDER STATUS LAMBDA (NEW)

#### 1️⃣ Lambda Name

```
GetOrderStatusLambda
```

#### 2️⃣ IAM Permissions

- RDS access

- DynamoDB read-only

#### 3️⃣ Lambda Code

```
import pymysql
import json
import boto3

dynamodb = boto3.resource('dynamodb')
metrics_table = dynamodb.Table('CafeOrderMetrics')

def lambda_handler(event, context):

    # ---- Fetch metrics ----
    metrics = metrics_table.scan()["Items"]

    # ---- DB connection (reuse Secrets Manager) ----
    # (use same secret logic as before)

    cursor.execute("""
        SELECT customer_name, item, quantity, created_at
        FROM orders
        ORDER BY created_at DESC
        LIMIT 20
    """)

    orders = cursor.fetchall()

    return {
        "statusCode": 200,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": json.dumps({
            "metrics": metrics,
            "recent_orders": orders
        }, default=str)
    }
```
##  PHASE 4️⃣ — API GATEWAY

### 1️⃣ Create API

```
GET /order-status
```

- Integration: GetOrderStatusLambda

- Enable CORS

- Deploy


##  PHASE 5️⃣ — FRONTEND ORDER STATUS PAGE

Create:




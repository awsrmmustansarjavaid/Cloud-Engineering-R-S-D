# ☕ CAFE LAB – SALES ANALYTICS & REPORTING SYSTEM
> **(Using Existing Order Status System)**

### 🎯 WHAT YOU ARE BUILDING (CLEAR SCOPE)

You will build ONE analytics system that:

✔ Reads data from existing Order Status DynamoDB table

✔ Calculates Today / Weekly / Monthly Sales

✔ Calculates Cost, Profit, Loss

✔ Displays professional Bootstrap analytics dashboard

✔ Generates PDF reports (custom date OR month-end)

✔ Supports manual PDF download

✔ Supports monthly auto-PDF generation

✔ Uses existing API Gateway + Lambda (minimal additions)

### 🧱 ARCHITECTURE (FINAL)

```
Frontend (Bootstrap Analytics Page)
        |
        |--- GET /analytics
        |--- POST /report/pdf
        |
API Gateway
        |
        |--- Analytics Lambda
        |--- PDF Lambda
        |
DynamoDB (Existing Orders Table)
        |
EventBridge (Monthly Trigger)
```

## PHASE 1️⃣ – DYNAMODB DESIGN (NO NEW TABLE)

#### ✅ Existing Orders Table (REQUIRED STRUCTURE)

### 1️⃣ Table Name: 

```        
CafeOrders
```

### 2️⃣ Partition Key (PK):

```
order_id (String)
```

#### Attributes (MUST exist):

```
order_date      (String)  -> "2026-01-17"
order_timestamp (Number)  -> 1705488000
total_amount    (Number)
total_cost      (Number)
order_status    (String)  -> COMPLETED
```

#### 📌 IMPORTANT

- order_timestamp is required for fast filtering

- Use Unix timestamp

---

### 2️⃣ – ADD GSI (VERY IMPORTANT)

#### Create Global Secondary Index

#### 1️⃣ Index Name: 

```
order_date-index
```
#### 2️⃣ Index Configurations: 

| Field         | Value                    |
| ------------- | ------------------------ |
| Partition Key | order_date (String)      |
| Sort Key      | order_timestamp (Number) |
| Projection    | ALL                      |

**👉 AWS Console → DynamoDB → Indexes → Create index**

---

### 3️⃣ – EXACT DYNAMODB QUERY CODE

####  Daily / Weekly / Monthly Query (Python)

```
import boto3
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('CafeOrders')

def query_orders(start_date, end_date):
    response = table.query(
        IndexName='order_date-index',
        KeyConditionExpression='order_date BETWEEN :s AND :e',
        ExpressionAttributeValues={
            ':s': start_date,
            ':e': end_date
        }
    )
    return response['Items']
```

---

## PHASE 2️⃣  – ANALYTICS LAMBDA (FULL CODE)

### 1️⃣ Create Cafe Analytics Lambda

#### 1️⃣ Lambda Name

```
CafeAnalyticsLambda
```

#### 2️⃣ IAM Permissions

```
AmazonDynamoDBReadOnlyAccess
CloudWatchLogsFullAccess
```

#### 3️⃣ FULL PYTHON CODE (COPY-PASTE)

```
import json
import boto3
from datetime import datetime, timedelta
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('CafeOrders')

def lambda_handler(event, context):
    period = event['queryStringParameters']['period']
    today = datetime.utcnow().date()

    if period == 'today':
        start = end = today
    elif period == 'week':
        start = today - timedelta(days=7)
        end = today
    elif period == 'month':
        start = today.replace(day=1)
        end = today
    else:
        return response(400, "Invalid period")

    orders = table.query(
        IndexName='order_date-index',
        KeyConditionExpression='order_date BETWEEN :s AND :e',
        ExpressionAttributeValues={
            ':s': str(start),
            ':e': str(end)
        }
    )['Items']

    total_sales = sum(float(o['total_amount']) for o in orders)
    total_cost = sum(float(o['total_cost']) for o in orders)
    profit = total_sales - total_cost

    return response(200, {
        "total_sales": total_sales,
        "total_cost": total_cost,
        "profit": profit,
        "orders_count": len(orders)
    })

def response(code, body):
    return {
        "statusCode": code,
        "headers": {
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(body)
    }
```


---

## PHASE 3️⃣  – API GATEWAY

### 1️⃣ – API GATEWAY CONFIGURATION

####  1️⃣ Create Resource

```
/analytics
```

####  2️⃣ Method

```
GET
```

####  3️⃣ Integration

```
Lambda Proxy Integration
→ CafeAnalyticsLambda
```

####  4️⃣ Query Parameters

```
period=today|week|month
```

---

## PHASE 3️⃣  BOOTSTRAP ANALYTICS UI

### 1️⃣ analytics.html (FULL CODE)
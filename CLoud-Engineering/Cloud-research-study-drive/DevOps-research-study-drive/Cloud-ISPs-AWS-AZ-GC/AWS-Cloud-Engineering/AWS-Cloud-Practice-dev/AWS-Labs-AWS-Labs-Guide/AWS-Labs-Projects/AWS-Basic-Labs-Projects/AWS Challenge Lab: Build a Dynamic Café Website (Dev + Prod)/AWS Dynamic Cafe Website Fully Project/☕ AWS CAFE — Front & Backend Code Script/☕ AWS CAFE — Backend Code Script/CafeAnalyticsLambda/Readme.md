# Charlie Cafe - CafeAnalyticsLambda

# SECTION 1️⃣  Latest Updated Advance CafeAnalyticsLambda.py

[CafeAnalyticsLambda.py](./CafeAnalyticsLambda.py)

---
# SECTION 2️⃣  Previous Versions CafeAnalyticsLambda.py


```
import os
import json
import boto3
from datetime import datetime, timedelta

# ==========================================================
# ENVIRONMENT VARIABLES
# ==========================================================
# ⚠️ DO NOT hardcode table names here
# You MUST define this key in Lambda → Configuration → Environment variables
#
# Key   : ORDERS_TABLE_NAME
# Value : CafeOrders   (example – replace with your actual table name)
#
ORDERS_TABLE_NAME = os.environ.get("ORDERS_TABLE_NAME")

# ==========================================================
# DYNAMODB CLIENT INITIALIZATION
# ==========================================================
# Uses IAM Role attached to Lambda
# Make sure the role has DynamoDB read permission
#
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(ORDERS_TABLE_NAME)

# ==========================================================
# MAIN LAMBDA HANDLER
# ==========================================================
def lambda_handler(event, context):

    # ------------------------------------------------------
    # READ QUERY PARAMETER (?period=today|week|month)
    # ------------------------------------------------------
    # This comes from API Gateway request:
    # /analytics?period=today
    #
    period = event.get("queryStringParameters", {}).get("period")

    # ------------------------------------------------------
    # USE UTC DATE FOR CONSISTENT REPORTING
    # ------------------------------------------------------
    today = datetime.utcnow().date()

    # ------------------------------------------------------
    # DATE RANGE SELECTION BASED ON PERIOD
    # ------------------------------------------------------
    if period == "today":
        start = end = today

    elif period == "week":
        # Last 7 days including today
        start = today - timedelta(days=7)
        end = today

    elif period == "month":
        # From 1st day of current month to today
        start = today.replace(day=1)
        end = today

    else:
        # Invalid or missing period
        return response(400, {"message": "Invalid period"})

    # ------------------------------------------------------
    # QUERY DYNAMODB USING GSI (order_date-index)
    # ------------------------------------------------------
    # REQUIREMENTS:
    # - GSI name must be exactly: order_date-index
    # - Partition key: order_date (String, YYYY-MM-DD)
    #
    orders = table.query(
        IndexName="order_date-index",
        KeyConditionExpression="order_date BETWEEN :s AND :e",
        ExpressionAttributeValues={
            ":s": str(start),
            ":e": str(end)
        }
    ).get("Items", [])

    # ------------------------------------------------------
    # CALCULATE TOTAL SALES, COST, AND PROFIT
    # ------------------------------------------------------
    # total_amount → selling price (already stored)
    # total_cost   → cost auto-calculated (Phase 10)
    #
    total_sales = sum(float(o.get("total_amount", 0)) for o in orders)
    total_cost = sum(float(o.get("total_cost", 0)) for o in orders)

    # PROFIT = SALES - COST
    profit = total_sales - total_cost

    # ------------------------------------------------------
    # FINAL API RESPONSE
    # ------------------------------------------------------
    return response(200, {
        "total_sales": total_sales,
        "total_cost": total_cost,
        "profit": profit,
        "orders_count": len(orders)
    })

# ==========================================================
# STANDARD API RESPONSE FORMATTER
# ==========================================================
def response(code, body):
    return {
        "statusCode": code,
        "headers": {
            # Allow frontend (CloudFront / browser) access
            "Access-Control-Allow-Origin": "*",
            "Content-Type": "application/json"
        },
        "body": json.dumps(body)
    }
```   

---
### 2️⃣ Updated & ModifiedCafeAnalyticsLambd (2nd Last Updated)

> **PHASE 9️⃣  EXACT LAMBDA RESPONSE FORMAT FOR ANALYTICS**

> **1️⃣ Required DynamoDB Attributes (Orders Table)**

> **3️⃣ – CREATE ANALYTICS LAMBDA**

```
import json
import os
import boto3
from collections import defaultdict
from datetime import datetime, timedelta

# ===============================
# ENVIRONMENT VARIABLES
# ===============================
TABLE_NAME = os.environ['ORDERS_TABLE_NAME']
GSI_NAME = os.environ['ORDERS_GSI_NAME']
ALLOWED_ORIGIN = os.environ.get('ALLOWED_ORIGIN', '*')

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(TABLE_NAME)

def lambda_handler(event, context):

    # ===============================
    # 1. READ QUERY PARAMETER
    # ===============================
    params = event.get('queryStringParameters') or {}
    period = params.get('period')

    if not period:
        return response(400, "Missing period parameter")

    # ===============================
    # 2. CALCULATE DATE RANGE
    # ===============================
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
        return response(400, "Invalid period value")

    # ===============================
    # 3. QUERY DYNAMODB USING GSI
    # ===============================
    db_response = table.query(
        IndexName=GSI_NAME,
        KeyConditionExpression='order_date BETWEEN :s AND :e',
        ExpressionAttributeValues={
            ':s': str(start),
            ':e': str(end)
        }
    )

    items = db_response.get('Items', [])

    # ===============================
    # 4. INITIALIZE CALCULATIONS
    # ===============================
    total_sales = 0
    total_cost = 0

    item_stats = defaultdict(lambda: {
        "quantity": 0,
        "sales": 0,
        "cost": 0
    })

    daily_sales = defaultdict(float)

    # ===============================
    # 5. PROCESS EACH ORDER
    # ===============================
    for o in items:
        qty = int(o['quantity'])
        sale = float(o['item_price']) * qty
        cost = float(o['item_cost']) * qty

        total_sales += sale
        total_cost += cost

        item = o['item_name']
        item_stats[item]['quantity'] += qty
        item_stats[item]['sales'] += sale
        item_stats[item]['cost'] += cost

        daily_sales[o['order_date']] += sale

    # ===============================
    # 6. FORMAT PROFIT PER ITEM
    # ===============================
    profit_items = []
    for item, v in item_stats.items():
        profit_items.append({
            "item": item,
            "quantity": v["quantity"],
            "sales": v["sales"],
            "cost": v["cost"],
            "profit": v["sales"] - v["cost"]
        })

    # ===============================
    # 7. FINAL RESPONSE FORMAT
    # ===============================
    response_body = {
        "period": period,
        "total_sales": total_sales,
        "total_cost": total_cost,
        "profit": total_sales - total_cost,
        "orders_count": len(items),
        "profit_per_item": profit_items,
        "daily_sales": [
            {"date": d, "sales": s}
            for d, s in sorted(daily_sales.items())
        ]
    }

    return response(200, response_body)

# ===============================
# COMMON RESPONSE HANDLER
# ===============================
def response(code, body):
    return {
        "statusCode": code,
        "headers": {
            "Access-Control-Allow-Origin": ALLOWED_ORIGIN,
            "Content-Type": "application/json"
        },
        "body": json.dumps(body)
    }
```


---

### 3️⃣ Updated & ModifiedCafeAnalyticsLambd ( Recommanded)

> **PHASE 1️⃣1️⃣  PROFIT PER ITEM (ALREADY INCLUDED)**

> **3️⃣ – MODIFY ANALYTICS LAMBDA (EXACT LOCATION)**

### 3️⃣ – MODIFY ANALYTICS LAMBDA (EXACT LOCATION)

- **Open CafeAnalyticsLambda**

#### 🔍 Find this line:

```
result = table.query(...)
```

**📢 This returns raw orders**

#### 1️⃣ – Add Aggregation Containers (DO NOT SKIP)

#### Add ABOVE the loop:

```
from collections import defaultdict

item_stats = defaultdict(lambda: {
    "quantity": 0,
    "sales": 0,
    "cost": 0
})
```

#### 2️⃣ Loop Through Orders (EXACT CODE)

Replace / update your loop:

```
for o in result:
    if o['order_status'] != 'COMPLETED':
        continue

    qty = int(o['quantity'])
    sale = float(o['item_price']) * qty
    cost = float(o['item_cost']) * qty

    item = o['item_name']

    item_stats[item]["quantity"] += qty
    item_stats[item]["sales"] += sale
    item_stats[item]["cost"] += cost
```

#### 3️⃣ Build profit_per_item Array

Add AFTER the loop:

```
profit_per_item = []

for item, data in item_stats.items():
    profit_per_item.append({
        "item": item,
        "quantity": data["quantity"],
        "sales": data["sales"],
        "cost": data["cost"],
        "profit": data["sales"] - data["cost"]
    })
```

#### 4️⃣ Add to Lambda Response (MANDATORY)

Update response body:

```
return response(200, {
    "period": period,
    "total_sales": total_sales,
    "total_cost": total_cost,
    "profit": total_sales - total_cost,
    "orders_count": len(result),
    "profit_per_item": profit_per_item
})
```

#### 5️⃣ COPY THIS FULL FINAL CODE (Recommanded)

> **(PHASE 11 + PHASE 12 INCLUDED)**

#### 📌 You will paste this exactly as-is

```
import json
import os
import boto3
from collections import defaultdict
from decimal import Decimal

# ==================================================
# ✅ ENVIRONMENT VARIABLES (DO NOT HARD-CODE)
# ==================================================

DYNAMODB_TABLE_NAME = os.environ["DYNAMODB_TABLE_NAME"]
AWS_REGION = os.environ["AWS_REGION"]

# ==================================================
# DO NOT CHANGE BELOW
# ==================================================

dynamodb = boto3.resource("dynamodb", region_name=AWS_REGION)
table = dynamodb.Table(DYNAMODB_TABLE_NAME)

def response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(body, default=str)
    }

def lambda_handler(event, context):

    # =====================================================
    # 🔐 PHASE 12 — ROLE-BASED ACCESS (ADMIN ONLY)
    # =====================================================

    try:
        claims = event["requestContext"]["authorizer"]["claims"]
        groups = claims.get("cognito:groups", "")
    except KeyError:
        return response(401, "Unauthorized")

    if "Admin" not in groups:
        return response(403, "Access denied")

    # =====================================================
    # 📅 GET PERIOD (day / week / month)
    # =====================================================

    period = "day"
    if event.get("queryStringParameters"):
        period = event["queryStringParameters"].get("period", "day")

    # =====================================================
    # 📦 READ ORDERS FROM DYNAMODB
    # =====================================================

    scan = table.scan()
    orders = scan.get("Items", [])

    # =====================================================
    # 📊 PHASE 11 — PROFIT PER ITEM
    # =====================================================

    total_sales = Decimal("0")
    total_cost = Decimal("0")

    item_stats = defaultdict(lambda: {
        "quantity": 0,
        "sales": Decimal("0"),
        "cost": Decimal("0")
    })

    for o in orders:

        # ✅ Only COMPLETED orders
        if o.get("order_status") != "COMPLETED":
            continue

        qty = int(o["quantity"])
        price = Decimal(str(o["item_price"]))
        cost = Decimal(str(o["item_cost"]))

        item_name = o["item_name"]

        sales_value = price * qty
        cost_value = cost * qty

        total_sales += sales_value
        total_cost += cost_value

        item_stats[item_name]["quantity"] += qty
        item_stats[item_name]["sales"] += sales_value
        item_stats[item_name]["cost"] += cost_value

    profit_per_item = []

    for item, data in item_stats.items():
        profit_per_item.append({
            "item": item,
            "quantity": data["quantity"],
            "sales": float(data["sales"]),
            "cost": float(data["cost"]),
            "profit": float(data["sales"] - data["cost"])
        })

    # =====================================================
    # 📤 FINAL RESPONSE (EXACT FORMAT)
    # =====================================================

    return response(200, {
        "period": period,
        "total_sales": float(total_sales),
        "total_cost": float(total_cost),
        "profit": float(total_sales - total_cost),
        "orders_count": len(orders),
        "profit_per_item": profit_per_item
    })
```

---
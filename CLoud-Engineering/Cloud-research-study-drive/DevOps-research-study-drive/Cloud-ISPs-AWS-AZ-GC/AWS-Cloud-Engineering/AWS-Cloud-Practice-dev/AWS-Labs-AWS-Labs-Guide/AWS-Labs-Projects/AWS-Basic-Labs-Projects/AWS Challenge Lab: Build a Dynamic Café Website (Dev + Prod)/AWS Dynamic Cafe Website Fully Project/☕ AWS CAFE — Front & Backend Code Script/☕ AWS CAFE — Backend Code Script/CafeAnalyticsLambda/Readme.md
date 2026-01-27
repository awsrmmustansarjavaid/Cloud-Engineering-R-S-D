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
### 2️⃣ Updated & ModifiedCafeAnalyticsLambd

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



# Charlie Cafe - CafeAnalyticsLambda


### CafeAnalyticsLambda.py

> **Update Version:1.0**


- Removing the Admin group check completely.

- Keeping the Lambda fully functional for analytics (still calculating profit, orders, etc.).

- Making it safe for public API calls.

#### Here’s the fully final version of your CafeAnalyticsLambda:

```
import json
import os
import boto3
from collections import defaultdict
from decimal import Decimal

# ==================================================
# ✅ ENVIRONMENT VARIABLES (DO NOT HARD-CODE)
# ==================================================
try:
    ORDERS_TABLE_NAME = os.environ["ORDERS_TABLE_NAME"]  # Must match your Lambda env var
except KeyError:
    raise Exception("Environment variable ORDERS_TABLE_NAME is missing!")

AWS_REGION = os.environ.get("AWS_REGION", "us-east-1")  # Default region

# ==================================================
# DO NOT CHANGE BELOW
# ==================================================
dynamodb = boto3.resource("dynamodb", region_name=AWS_REGION)
table = dynamodb.Table(ORDERS_TABLE_NAME)

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
    # 📅 GET PERIOD (day / week / month)
    # =====================================================
    period = "day"
    if event.get("queryStringParameters"):
        period = event["queryStringParameters"].get("period", "day")

    # =====================================================
    # 📦 READ ORDERS FROM DYNAMODB
    # =====================================================
    try:
        scan = table.scan()
        orders = scan.get("Items", [])
    except Exception as e:
        return response(500, f"Error reading DynamoDB table: {str(e)}")

    # =====================================================
    # 📊 PROFIT PER ITEM
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

        qty = int(o.get("quantity", 0))
        price = Decimal(str(o.get("item_price", 0)))
        cost = Decimal(str(o.get("item_cost", 0)))
        item_name = o.get("item_name", "Unknown Item")

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
    # 📤 FINAL RESPONSE
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

### ✅ Key Changes:

- Removed all Cognito/claims checks (401 / 403).

- Now publicly callable via API Gateway without any authorizer.

- Functionality for analytics remains exactly the same.

- Fully compatible with your frontend query (period=today).    
---
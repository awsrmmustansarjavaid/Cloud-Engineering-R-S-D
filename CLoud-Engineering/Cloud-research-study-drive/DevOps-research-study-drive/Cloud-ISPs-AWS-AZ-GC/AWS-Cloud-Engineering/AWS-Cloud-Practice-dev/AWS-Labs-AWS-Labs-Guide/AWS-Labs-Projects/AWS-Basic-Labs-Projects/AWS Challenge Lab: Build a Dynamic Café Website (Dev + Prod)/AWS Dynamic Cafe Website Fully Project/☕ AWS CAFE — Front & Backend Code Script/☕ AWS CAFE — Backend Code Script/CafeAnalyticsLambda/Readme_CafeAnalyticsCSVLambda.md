# Charlie Cafe - CafeAnalyticsCSVLambda

# SECTION 1️⃣  Latest Updated Advance CafeAnalyticsCSVLambda.py

[CafeAnalyticsCSVLambda.py](./CafeAnalyticsCSVLambda.py)

---
# SECTION 2️⃣  Previous Versions CafeAnalyticsCSVLambda.py

> **PHASE 1️⃣3️⃣  CSV EXPORT (PROFESSIONAL)**

> **1️⃣ — Cafe Analytics CSV Lambda**

> **3️⃣ CafeAnalyticsCSVLambda CODE**

#### PASTE FULL FINAL CSV LAMBDA CODE

> **(COPY-PASTE EXACTLY)**

```
import json
import boto3
import csv
import io
from decimal import Decimal
from collections import defaultdict

# ================================
# 🔁 REPLACE ONLY THESE IF NEEDED
# ================================

TABLE_NAME = "CafeOrders"   # 👈 replace if different
REGION = "ap-south-1"       # 👈 replace if different

# ================================
# DO NOT CHANGE BELOW
# ================================

dynamodb = boto3.resource("dynamodb", region_name=REGION)
table = dynamodb.Table(TABLE_NAME)

def lambda_handler(event, context):

    # =========================================
    # 🔐 ADMIN ONLY (Cognito Group Check)
    # =========================================
    try:
        claims = event["requestContext"]["authorizer"]["claims"]
        groups = claims.get("cognito:groups", "")
    except KeyError:
        return {
            "statusCode": 401,
            "body": "Unauthorized"
        }

    if "Admin" not in groups:
        return {
            "statusCode": 403,
            "body": "Access denied"
        }

    # =========================================
    # 📦 READ ORDERS
    # =========================================
    response = table.scan()
    orders = response.get("Items", [])

    # =========================================
    # 📊 CALCULATE PROFIT PER ITEM
    # =========================================
    item_data = defaultdict(lambda: {
        "qty": 0,
        "sales": Decimal("0"),
        "cost": Decimal("0")
    })

    for o in orders:
        if o.get("order_status") != "COMPLETED":
            continue

        qty = int(o["quantity"])
        price = Decimal(str(o["item_price"]))
        cost = Decimal(str(o["item_cost"]))
        name = o["item_name"]

        item_data[name]["qty"] += qty
        item_data[name]["sales"] += price * qty
        item_data[name]["cost"] += cost * qty

    # =========================================
    # 🧾 CREATE CSV
    # =========================================
    output = io.StringIO()
    writer = csv.writer(output)

    writer.writerow(["Item", "Quantity", "Sales", "Cost", "Profit"])

    for item, data in item_data.items():
        profit = data["sales"] - data["cost"]
        writer.writerow([
            item,
            data["qty"],
            float(data["sales"]),
            float(data["cost"]),
            float(profit)
        ])

    # =========================================
    # 📤 RETURN CSV FILE
    # =========================================
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "text/csv",
            "Content-Disposition": "attachment; filename=cafe-analytics.csv",
            "Access-Control-Allow-Origin": "*"
        },
        "body": output.getvalue()
    }
```

---
### CafeAnalyticsLambda.py

> **Update Version: 1.0**

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
### CafeAnalyticsLambda.py

> **Update Version: 1.1**

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
    try:
        scan = table.scan()
        orders = scan.get("Items", [])
    except Exception as e:
        return response(500, f"Error reading DynamoDB table: {str(e)}")

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


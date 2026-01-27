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
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
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
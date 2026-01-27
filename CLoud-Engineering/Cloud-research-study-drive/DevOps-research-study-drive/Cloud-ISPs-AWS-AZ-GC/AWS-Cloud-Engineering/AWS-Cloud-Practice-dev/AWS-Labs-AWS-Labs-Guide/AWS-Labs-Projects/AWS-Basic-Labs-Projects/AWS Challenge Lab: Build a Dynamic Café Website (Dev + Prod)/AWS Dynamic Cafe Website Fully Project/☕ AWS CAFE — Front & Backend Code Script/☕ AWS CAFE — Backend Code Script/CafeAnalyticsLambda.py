import os
import json
import boto3
from datetime import datetime, timedelta

# =======================
# ENVIRONMENT VARIABLE
# =======================
# REPLACE VALUE IN LAMBDA ENV VARIABLES (NOT HERE)
ORDERS_TABLE_NAME = os.environ.get("ORDERS_TABLE_NAME")

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(ORDERS_TABLE_NAME)

def lambda_handler(event, context):

    period = event.get("queryStringParameters", {}).get("period")
    today = datetime.utcnow().date()

    if period == "today":
        start = end = today
    elif period == "week":
        start = today - timedelta(days=7)
        end = today
    elif period == "month":
        start = today.replace(day=1)
        end = today
    else:
        return response(400, {"message": "Invalid period"})

    orders = table.query(
        IndexName="order_date-index",
        KeyConditionExpression="order_date BETWEEN :s AND :e",
        ExpressionAttributeValues={
            ":s": str(start),
            ":e": str(end)
        }
    ).get("Items", [])

    total_sales = sum(float(o.get("total_amount", 0)) for o in orders)
    total_cost = sum(float(o.get("total_cost", 0)) for o in orders)
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
            "Access-Control-Allow-Origin": "*",
            "Content-Type": "application/json"
        },
        "body": json.dumps(body)
    }
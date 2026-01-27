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
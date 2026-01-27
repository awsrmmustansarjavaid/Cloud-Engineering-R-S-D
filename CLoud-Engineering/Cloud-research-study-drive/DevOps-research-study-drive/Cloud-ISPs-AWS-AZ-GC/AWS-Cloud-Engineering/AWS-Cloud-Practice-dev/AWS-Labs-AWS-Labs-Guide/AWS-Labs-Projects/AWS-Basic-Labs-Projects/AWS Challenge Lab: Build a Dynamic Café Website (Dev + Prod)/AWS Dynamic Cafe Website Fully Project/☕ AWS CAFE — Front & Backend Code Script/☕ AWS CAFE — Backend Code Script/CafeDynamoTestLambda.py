import json
import boto3
import os

# ==============================
# ENVIRONMENT VARIABLES
# ==============================
# 🔁 REPLACE in Lambda → Configuration → Environment variables
# TABLE_NAME        = CafeOrders
# DATE_INDEX_NAME   = order_date-index
# DEFAULT_START_DATE = 2026-01-01
# DEFAULT_END_DATE   = 2026-01-31

TABLE_NAME = os.environ.get('TABLE_NAME', 'CafeOrders')
DATE_INDEX = os.environ.get('DATE_INDEX_NAME', 'order_date-index')
START_DATE = os.environ.get('DEFAULT_START_DATE', '2026-01-01')
END_DATE = os.environ.get('DEFAULT_END_DATE', '2026-01-31')

# ==============================
# AWS DYNAMODB RESOURCE
# ==============================
# Uses IAM role attached to Lambda
dynamodb = boto3.resource('dynamodb')

# Connect to CafeOrders table
table = dynamodb.Table(TABLE_NAME)

# ==============================
# LAMBDA HANDLER
# ==============================

def lambda_handler(event, context):
    """
    This Lambda:
    - Queries CafeOrders table
    - Uses order_date GSI
    - Fetches orders between start & end dates
    - Returns order count + items
    """

    # ==============================
    # OPTIONAL: DATE OVERRIDE FROM QUERY STRING
    # ==============================
    # Example:
    # /analytics?start=2026-01-01&end=2026-01-31
    params = event.get('queryStringParameters') or {}

    start_date = params.get('start', START_DATE)
    end_date = params.get('end', END_DATE)

    # ==============================
    # DYNAMODB QUERY
    # ==============================
    result = table.query(
        IndexName=DATE_INDEX,  # GSI on order_date
        KeyConditionExpression='order_date BETWEEN :s AND :e',
        ExpressionAttributeValues={
            ':s': start_date,
            ':e': end_date
        }
    )

    # ==============================
    # RESPONSE
    # ==============================
    return {
        "statusCode": 200,
        "headers": {
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps({
            "count": len(result.get('Items', [])),  # Total orders found
            "start_date": start_date,
            "end_date": end_date,
            "items": result.get('Items', [])
        })
    }
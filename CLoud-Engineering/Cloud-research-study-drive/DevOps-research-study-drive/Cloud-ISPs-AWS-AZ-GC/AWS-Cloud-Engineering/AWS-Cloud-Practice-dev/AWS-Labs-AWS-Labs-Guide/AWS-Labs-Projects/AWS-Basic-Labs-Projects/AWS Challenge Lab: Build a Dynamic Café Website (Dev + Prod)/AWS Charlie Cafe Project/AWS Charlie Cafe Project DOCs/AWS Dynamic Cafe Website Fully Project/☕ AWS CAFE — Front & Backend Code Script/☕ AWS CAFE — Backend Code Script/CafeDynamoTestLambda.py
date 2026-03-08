import json
import boto3
import os
from boto3.dynamodb.conditions import Key, Attr

# ==============================
# ENVIRONMENT VARIABLES
# ==============================
TABLE_NAME = os.environ.get('TABLE_NAME', 'CafeOrders')
DATE_INDEX = os.environ.get('DATE_INDEX_NAME', 'order_date-index')
DEFAULT_START_DATE = os.environ.get('DEFAULT_START_DATE', '2026-01-01')
DEFAULT_END_DATE = os.environ.get('DEFAULT_END_DATE', '2026-01-31')
PARTITION_KEY = os.environ.get('PARTITION_KEY', None)  # Optional: store_id or "all_orders"

# ==============================
# AWS DYNAMODB RESOURCE
# ==============================
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(TABLE_NAME)

# ==============================
# LAMBDA HANDLER
# ==============================
def lambda_handler(event, context):
    """
    Lambda to fetch CafeOrders between start & end dates.
    Uses Query if partition key is provided, otherwise Scan.
    """

    # ==============================
    # GET DATES FROM QUERY STRING
    # ==============================
    params = event.get('queryStringParameters') or {}
    start_date = params.get('start', DEFAULT_START_DATE)
    end_date = params.get('end', DEFAULT_END_DATE)

    # ==============================
    # DYNAMODB QUERY OR SCAN
    # ==============================
    try:
        if PARTITION_KEY:
            # ✅ Use Query with GSI (partition key + sort key)
            result = table.query(
                IndexName=DATE_INDEX,
                KeyConditionExpression=Key(PARTITION_KEY).eq('all_orders') & Key('order_date').between(start_date, end_date)
            )
        else:
            # ⚠️ Use Scan if no partition key (slower)
            result = table.scan(
                FilterExpression=Attr('order_date').between(start_date, end_date)
            )

        items = result.get('Items', [])
        count = len(items)

        return {
            "statusCode": 200,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({
                "count": count,
                "start_date": start_date,
                "end_date": end_date,
                "items": items
            })
        }

    except Exception as e:
        # Catch all errors
        return {
            "statusCode": 500,
            "body": json.dumps({
                "error": str(e)
            })
        }
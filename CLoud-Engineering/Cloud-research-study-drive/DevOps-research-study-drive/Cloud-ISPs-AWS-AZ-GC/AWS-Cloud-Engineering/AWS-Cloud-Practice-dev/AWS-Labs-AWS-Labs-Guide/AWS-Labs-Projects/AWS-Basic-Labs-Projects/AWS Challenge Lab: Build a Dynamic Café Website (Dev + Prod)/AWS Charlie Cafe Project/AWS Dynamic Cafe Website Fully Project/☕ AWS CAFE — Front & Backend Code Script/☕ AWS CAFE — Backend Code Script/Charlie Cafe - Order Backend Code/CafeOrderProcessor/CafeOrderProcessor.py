import json
import boto3
import pymysql
import os
import random
from decimal import Decimal
from datetime import datetime

# ==========================================================
# AWS CLIENTS
# ==========================================================
secrets_client = boto3.client('secretsmanager')  # For fetching DB credentials
dynamodb = boto3.resource('dynamodb')            # DynamoDB for metrics & orders
sqs = boto3.client('sqs')                        # SQS for order queue notifications

# ==========================================================
# ENVIRONMENT VARIABLES
# ==========================================================
SECRET_NAME = "CafeDevDBSM"                       # Name of RDS secret in Secrets Manager
SQS_QUEUE_URL = os.environ['SQS_QUEUE_URL']      # SQS queue URL for order notifications
MENU_TABLE = "CafeMenu"                           # DynamoDB menu table
METRICS_TABLE = "CafeOrderMetrics"               # DynamoDB metrics table
ORDERS_TABLE = "CafeOrders"                       # DynamoDB orders table

# DynamoDB tables
menu_table = dynamodb.Table(MENU_TABLE)
metrics_table = dynamodb.Table(METRICS_TABLE)
orders_table = dynamodb.Table(ORDERS_TABLE)

# ==========================================================
# PRICE LIST (RDS & front-end reference)
# ==========================================================
PRICE_LIST = {
    "Coffee": 3.00,
    "Tea": 2.00,
    "Latte": 4.00,
    "Cappuccino": 4.00,
    "Fresh Juice": 5.00
}

# ==========================================================
# GENERATE UNIQUE ORDER ID
# ==========================================================
def generate_order_id():
    """
    Generates a canonical order ID:
    Format: ORD-YYYYMMDD-XXXX
    Where XXXX is a random 4-digit number
    """
    return f"ORD-{datetime.now().strftime('%Y%m%d')}-{random.randint(1000,9999)}"

# ==========================================================
# GET RDS DATABASE SECRET
# ==========================================================
def get_db_secret():
    """
    Fetch DB credentials from AWS Secrets Manager
    Returns a dictionary with host, username, password, dbname
    """
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])

# ==========================================================
# HELPER FUNCTION: HTTP RESPONSE
# ==========================================================
def response(status_code, body):
    """
    Returns a standardized API Gateway response
    Includes CORS headers for frontend access
    """
    return {
        "statusCode": status_code,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Methods": "OPTIONS,POST"
        },
        "body": json.dumps(body)
    }

# ==========================================================
# LAMBDA HANDLER
# ==========================================================
def lambda_handler(event, context):
    """
    Main Lambda function for processing cafe orders
    Validates input, inserts into RDS & DynamoDB, sends SQS, and returns JSON
    """
    try:

        # -------------------------
        # Handle CORS preflight
        # -------------------------
        if event.get("httpMethod") == "OPTIONS":
            return response(200, {})

        # -------------------------
        # Parse request body
        # -------------------------
        body = json.loads(event.get("body", "{}"))

        # Required fields
        required_fields = ["table_number", "item", "quantity", "payment_method"]
        for field in required_fields:
            if field not in body:
                return response(400, {"error": f"Missing field: {field}"})

        # Extract input
        table_number = int(body["table_number"])
        customer_name = body.get("customer_name", "Guest")
        item = body["item"]
        quantity = int(body["quantity"])
        payment_method = body["payment_method"].upper()

        # -------------------------
        # Validate input
        # -------------------------
        if item not in PRICE_LIST:
            return response(400, {"error": "Invalid menu item"})
        if table_number <= 0 or quantity <= 0:
            return response(400, {"error": "Invalid table number or quantity"})
        if payment_method not in ["CASH", "CARD"]:
            return response(400, {"error": "Invalid payment method"})

        # -------------------------
        # Generate order details
        # -------------------------
        order_id = generate_order_id()                           # Canonical order ID
        total_amount = PRICE_LIST[item] * quantity              # Total price
        status = "RECEIVED"                                     # Order status
        payment_status = "PAID" if payment_method == "CARD" else "PENDING"
        created_at = datetime.now()                              # Timestamp

        # -------------------------
        # Insert into RDS (MySQL)
        # -------------------------
        secret = get_db_secret()
        connection = pymysql.connect(
            host=secret["host"],
            user=secret["username"],
            password=secret["password"],
            database=secret["dbname"],
            connect_timeout=10,
            autocommit=False
        )

        with connection.cursor() as cursor:
            cursor.execute("""
                INSERT INTO orders
                (order_id, table_number, customer_name, item,
                 quantity, total_amount, status, created_at,
                 payment_method, payment_status)
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
            """, (
                order_id, table_number, customer_name, item,
                quantity, total_amount, status, created_at,
                payment_method, payment_status
            ))
        connection.commit()
        connection.close()

        # -------------------------
        # Save order in DynamoDB
        # -------------------------
        orders_table.put_item(
            Item={
                "order_id": order_id,
                "table_number": table_number,
                "customer_name": customer_name,
                "item": item,
                "quantity": quantity,
                "total_amount": Decimal(str(total_amount)),
                "status": status,
                "payment_method": payment_method,
                "payment_status": payment_status,
                "created_at": str(created_at)
            }
        )

        # -------------------------
        # Update menu item orders count
        # -------------------------
        menu_table.update_item(
            Key={"item": item},
            UpdateExpression="ADD orders :inc",
            ExpressionAttributeValues={":inc": Decimal(quantity)}
        )

        # -------------------------
        # Update total orders metric
        # -------------------------
        metrics_table.update_item(
            Key={"metric": "TOTAL_ORDERS"},
            UpdateExpression="ADD #c :inc",
            ExpressionAttributeNames={"#c": "count"},
            ExpressionAttributeValues={":inc": Decimal(1)}
        )

        # -------------------------
        # Send order message to SQS
        # -------------------------
        sqs.send_message(
            QueueUrl=SQS_QUEUE_URL,
            MessageBody=json.dumps({
                "order_id": order_id,
                "item": item,
                "quantity": quantity,
                "payment_method": payment_method
            })
        )

        # -------------------------
        # Return successful response
        # -------------------------
        return response(200, {
            "order_id": order_id,
            "total": total_amount,
            "status": status,
            "payment_status": payment_status
        })

    except Exception as e:
        # -------------------------
        # Catch-all error handler
        # -------------------------
        return response(500, {"error": str(e)})
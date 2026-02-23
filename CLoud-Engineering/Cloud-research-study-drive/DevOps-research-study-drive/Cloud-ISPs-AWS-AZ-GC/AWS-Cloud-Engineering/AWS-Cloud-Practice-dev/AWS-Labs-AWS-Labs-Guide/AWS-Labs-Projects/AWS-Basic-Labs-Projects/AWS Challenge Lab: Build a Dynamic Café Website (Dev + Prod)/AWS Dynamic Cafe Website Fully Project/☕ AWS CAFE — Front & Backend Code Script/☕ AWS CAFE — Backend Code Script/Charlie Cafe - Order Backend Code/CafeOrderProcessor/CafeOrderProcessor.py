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
secrets_client = boto3.client('secretsmanager')
dynamodb = boto3.resource('dynamodb')
sqs = boto3.client('sqs')

# ==========================================================
# ENV VARIABLES
# ==========================================================
SECRET_NAME = "CafeDevDBSM"
SQS_QUEUE_URL = os.environ['SQS_QUEUE_URL']
MENU_TABLE = "CafeMenu"
METRICS_TABLE = "CafeOrderMetrics"
ORDERS_TABLE = "CafeOrders"

menu_table = dynamodb.Table(MENU_TABLE)
metrics_table = dynamodb.Table(METRICS_TABLE)
orders_table = dynamodb.Table(ORDERS_TABLE)

# ==========================================================
# PRICE LIST
# ==========================================================
PRICE_LIST = {
    "Coffee": 3.00,
    "Tea": 2.50,
    "Latte": 4.00,
    "Cappuccino": 4.50,
    "Fresh Juice": 5.00
}

# ==========================================================
def generate_order_id():
    return f"ORD-{datetime.now().strftime('%Y%m%d')}-{random.randint(1000,9999)}"

def get_db_secret():
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])

def response(status_code, body):
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
def lambda_handler(event, context):
    try:

        if event.get("httpMethod") == "OPTIONS":
            return response(200, {})

        body = json.loads(event.get("body", "{}"))

        required_fields = ["table_number", "item", "quantity", "payment_method"]
        for field in required_fields:
            if field not in body:
                return response(400, {"error": f"Missing field: {field}"})

        table_number = int(body["table_number"])
        customer_name = body.get("customer_name", "Guest")
        item = body["item"]
        quantity = int(body["quantity"])
        payment_method = body["payment_method"].upper()

        if item not in PRICE_LIST:
            return response(400, {"error": "Invalid menu item"})

        if table_number <= 0 or quantity <= 0:
            return response(400, {"error": "Invalid table number or quantity"})

        if payment_method not in ["CASH", "CARD"]:
            return response(400, {"error": "Invalid payment method"})

        # Generate Order
        order_id = generate_order_id()
        total_amount = PRICE_LIST[item] * quantity
        status = "RECEIVED"
        payment_status = "PAID" if payment_method == "CARD" else "PENDING"
        created_at = datetime.now()

        # Insert into RDS
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

        # DynamoDB Save
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

        menu_table.update_item(
            Key={"item": item},
            UpdateExpression="ADD orders :inc",
            ExpressionAttributeValues={":inc": Decimal(quantity)}
        )

        metrics_table.update_item(
            Key={"metric": "TOTAL_ORDERS"},
            UpdateExpression="ADD #c :inc",
            ExpressionAttributeNames={"#c": "count"},
            ExpressionAttributeValues={":inc": Decimal(1)}
        )

        sqs.send_message(
            QueueUrl=SQS_QUEUE_URL,
            MessageBody=json.dumps({
                "order_id": order_id,
                "item": item,
                "quantity": quantity,
                "payment_method": payment_method
            })
        )

        return response(200, {
            "order_id": order_id,
            "total": total_amount,
            "status": status,
            "payment_status": payment_status
        })

    except Exception as e:
        return response(500, {"error": str(e)})
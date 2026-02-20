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

menu_table = dynamodb.Table(MENU_TABLE)
metrics_table = dynamodb.Table(METRICS_TABLE)

# ==========================================================
# GENERATE UNIQUE ORDER ID
# ==========================================================
def generate_order_id():
    return f"ORD-{datetime.now().strftime('%Y%m%d')}-{random.randint(1000,9999)}"

# ==========================================================
# GET DB CREDENTIALS FROM SECRETS MANAGER
# ==========================================================
def get_db_secret():
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])

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
# LAMBDA HANDLER
# ==========================================================
def lambda_handler(event, context):

    try:
        # --------------------------------------------------
        # 1️⃣ Parse Request Body
        # --------------------------------------------------
        body = json.loads(event.get("body", "{}"))

        required_fields = ["table_number", "item", "quantity"]

        for field in required_fields:
            if field not in body:
                return response(400, {"error": f"Missing field: {field}"})

        table_number = int(body["table_number"])
        customer_name = body.get("customer_name", "Guest")
        item = body["item"]
        quantity = int(body["quantity"])

        if item not in PRICE_LIST:
            return response(400, {"error": "Invalid menu item"})

        if table_number <= 0 or quantity <= 0:
            return response(400, {"error": "Invalid table number or quantity"})

        # --------------------------------------------------
        # 2️⃣ Generate Order Details
        # --------------------------------------------------
        order_id = generate_order_id()
        total_amount = PRICE_LIST[item] * quantity
        status = "RECEIVED"
        created_at = datetime.now()

        # --------------------------------------------------
        # 3️⃣ Connect to RDS
        # --------------------------------------------------
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
                 quantity, total_amount, status, created_at)
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s)
            """, (
                order_id,
                table_number,
                customer_name,
                item,
                quantity,
                total_amount,
                status,
                created_at
            ))

        connection.commit()
        connection.close()

        # --------------------------------------------------
        # 4️⃣ Update DynamoDB - Item Metrics
        # --------------------------------------------------
        menu_table.update_item(
            Key={"item": item},
            UpdateExpression="ADD orders :inc",
            ExpressionAttributeValues={
                ":inc": Decimal(quantity)
            }
        )

        # --------------------------------------------------
        # 5️⃣ Update Global Metrics
        # --------------------------------------------------
        metrics_table.update_item(
            Key={"metric": "TOTAL_ORDERS"},
            UpdateExpression="ADD #c :inc",
            ExpressionAttributeNames={"#c": "count"},
            ExpressionAttributeValues={
                ":inc": Decimal(1)
            }
        )

        # --------------------------------------------------
        # 6️⃣ Send Message to SQS
        # --------------------------------------------------
        sqs.send_message(
            QueueUrl=SQS_QUEUE_URL,
            MessageBody=json.dumps({
                "order_id": order_id,
                "table_number": table_number,
                "customer_name": customer_name,
                "item": item,
                "quantity": quantity,
                "status": status,
                "timestamp": str(created_at)
            })
        )

        # --------------------------------------------------
        # 7️⃣ Success Response (FULL ORDER JSON)
        # --------------------------------------------------
        return response(200, {
            "order_id": order_id,
            "table_number": table_number,
            "customer_name": customer_name,
            "item": item,
            "quantity": quantity,
            "total": total_amount,
            "status": status,
            "created_at": str(created_at)
        })

    except Exception as e:
        print("❌ ERROR:", str(e))
        return response(500, {"error": str(e)})

# ==========================================================
# STANDARD RESPONSE FORMAT
# ==========================================================
def response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": json.dumps(body)
    }
import json
import boto3
import pymysql
import os
from decimal import Decimal
from datetime import datetime

# ==============================
# AWS CLIENTS
# ==============================
secrets_client = boto3.client('secretsmanager')
dynamodb = boto3.resource('dynamodb')
sqs = boto3.client('sqs')

# ==============================
# ENV VARIABLES
# ==============================
SECRET_NAME = "CafeDevDBSM"
SQS_QUEUE_URL = os.environ['SQS_QUEUE_URL']
MENU_TABLE = "CafeMenu"
METRICS_TABLE = "CafeOrderMetrics"

menu_table = dynamodb.Table(MENU_TABLE)
metrics_table = dynamodb.Table(METRICS_TABLE)

# ==============================
# GET DB CREDENTIALS
# ==============================
def get_db_secret():
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])

# ==============================
# LAMBDA HANDLER
# ==============================
def lambda_handler(event, context):

    try:
        # ---------------------------------
        # 1️⃣ Parse Request Body
        # ---------------------------------
        body = json.loads(event.get("body", "{}"))

        required_fields = ["table_number", "item", "quantity"]

        for field in required_fields:
            if field not in body:
                return {
                    "statusCode": 400,
                    "headers": {"Access-Control-Allow-Origin": "*"},
                    "body": json.dumps({"error": f"Missing field: {field}"})
                }

        table_number = int(body["table_number"])
        customer_name = body.get("customer_name", "Guest")
        item = body["item"]
        quantity = int(body["quantity"])

        if table_number <= 0 or quantity <= 0:
            raise ValueError("Invalid table number or quantity")

        # ---------------------------------
        # 2️⃣ Connect to RDS
        # ---------------------------------
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

            # ---------------------------------
            # 3️⃣ Insert Order into RDS
            # ---------------------------------
            cursor.execute("""
                INSERT INTO orders
                (table_number, customer_name, item, quantity, status, created_at)
                VALUES (%s, %s, %s, %s, %s, %s)
            """, (
                table_number,
                customer_name,
                item,
                quantity,
                "PENDING",
                datetime.now()
            ))

        connection.commit()
        connection.close()

        # ---------------------------------
        # 4️⃣ Update DynamoDB (Item Metrics)
        # ---------------------------------
        menu_table.update_item(
            Key={"item": item},
            UpdateExpression="ADD orders :inc",
            ExpressionAttributeValues={
                ":inc": Decimal(quantity)
            }
        )

        # ---------------------------------
        # 5️⃣ Update Global Metrics
        # ---------------------------------
        metrics_table.update_item(
            Key={"metric": "TOTAL_ORDERS"},
            UpdateExpression="ADD #c :inc",
            ExpressionAttributeNames={"#c": "count"},
            ExpressionAttributeValues={
                ":inc": Decimal(1)
            }
        )

        # ---------------------------------
        # 6️⃣ Send Message to SQS
        # ---------------------------------
        sqs.send_message(
            QueueUrl=SQS_QUEUE_URL,
            MessageBody=json.dumps({
                "table_number": table_number,
                "customer_name": customer_name,
                "item": item,
                "quantity": quantity,
                "timestamp": str(datetime.now())
            })
        )

        # ---------------------------------
        # 7️⃣ Success Response
        # ---------------------------------
        return {
            "statusCode": 200,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({
                "message": "Order created successfully",
                "table_number": table_number
            })
        }

    except ValueError as e:
        return {
            "statusCode": 400,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": str(e)})
        }

    except Exception as e:
        print("❌ ERROR:", str(e))
        return {
            "statusCode": 500,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": str(e)})
        }
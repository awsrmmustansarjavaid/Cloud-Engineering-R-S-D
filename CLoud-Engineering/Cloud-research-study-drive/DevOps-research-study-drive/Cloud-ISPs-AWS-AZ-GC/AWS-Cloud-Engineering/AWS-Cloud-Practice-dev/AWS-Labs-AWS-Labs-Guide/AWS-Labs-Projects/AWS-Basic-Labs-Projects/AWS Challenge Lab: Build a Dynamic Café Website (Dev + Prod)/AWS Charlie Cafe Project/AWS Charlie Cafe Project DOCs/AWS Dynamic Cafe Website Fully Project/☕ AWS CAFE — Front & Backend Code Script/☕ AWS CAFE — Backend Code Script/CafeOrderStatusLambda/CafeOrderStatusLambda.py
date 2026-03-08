import json
import boto3
import pymysql
from datetime import datetime

# ==========================================================
# AWS CLIENTS
# ==========================================================
secrets_client = boto3.client('secretsmanager')

# ==========================================================
# SECRET CONFIG
# ==========================================================
SECRET_NAME = "CafeDevDBSM"  # Your Secrets Manager name

# ==========================================================
# GET DB CREDENTIALS FROM SECRETS MANAGER
# ==========================================================
def get_db_secret():
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])

# ==========================================================
# STANDARD RESPONSE FORMAT
# ==========================================================
def response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Content-Type": "application/json"
        },
        "body": json.dumps(body, default=str)
    }

# ==========================================================
# LAMBDA HANDLER
# ==========================================================
def lambda_handler(event, context):
    try:
        # --------------------------------------------------
        # 1️⃣ Get Query Params
        # --------------------------------------------------
        params = event.get("queryStringParameters") or {}
        order_id = params.get("order_id")

        # --------------------------------------------------
        # 2️⃣ Connect to RDS
        # --------------------------------------------------
        secret = get_db_secret()
        connection = pymysql.connect(
            host=secret["host"],
            user=secret["username"],
            password=secret["password"],
            database=secret["dbname"],
            cursorclass=pymysql.cursors.DictCursor,
            connect_timeout=10
        )

        with connection.cursor() as cursor:
            # --------------------------------------------------
            # 3️⃣ Fetch Latest Order (or by order_id if provided)
            # --------------------------------------------------
            if order_id:
                cursor.execute("""
                    SELECT order_id, table_number, customer_name, item, quantity, total_amount, status, created_at
                    FROM orders
                    WHERE order_id = %s
                    ORDER BY created_at DESC
                    LIMIT 1
                """, (order_id,))
            else:
                cursor.execute("""
                    SELECT order_id, table_number, customer_name, item, quantity, total_amount, status, created_at
                    FROM orders
                    ORDER BY created_at DESC
                    LIMIT 1
                """)

            order = cursor.fetchone()

        connection.close()

        # --------------------------------------------------
        # 4️⃣ Handle Not Found
        # --------------------------------------------------
        if not order:
            return response(404, {"status": "NOT FOUND", "order_id": order_id})

        # --------------------------------------------------
        # 5️⃣ Return Order Details
        # --------------------------------------------------
        return response(200, {
            "order_id": order.get("order_id"),
            "status": order.get("status", "RECEIVED"),
            "order": order
        })

    except Exception as e:
        print("❌ ERROR:", str(e))
        return response(500, {"error": str(e)})
# ===========================================
# AdminMarkPaidLambda (FINAL PRODUCTION VERSION)
# ===========================================
# PURPOSE:
# - Admin marks CASH orders as PAID
# - Updates BOTH:
#     1) DynamoDB (CafeOrders)
#     2) MySQL (RDS orders table)
#
# FEATURES:
# ✔ Handles API Gateway body (string OR dict)
# ✔ Safe error handling
# ✔ Logs for debugging (CloudWatch)
# ✔ Works with frontend + curl + Postman
# ✔ CORS enabled
# ===========================================

import json
import boto3
import pymysql
import os

# -----------------------------
# DynamoDB Setup
# -----------------------------
dynamodb = boto3.resource('dynamodb')
dynamo_table = dynamodb.Table('CafeOrders')

# -----------------------------
# Secrets Manager Setup
# -----------------------------
SECRETS_NAME = os.environ.get('SECRET_NAME', 'CafeDevDBSM')
secrets_client = boto3.client('secretsmanager')

def get_db_secret():
    """
    Fetch DB credentials from AWS Secrets Manager
    Expected keys:
    host, username, password, dbname
    """
    response = secrets_client.get_secret_value(SecretId=SECRETS_NAME)
    return json.loads(response['SecretString'])

# ===========================================
# MAIN HANDLER
# ===========================================
def lambda_handler(event, context):

    print("🔥 EVENT RECEIVED:", json.dumps(event))  # Debug log

    try:
        # ===========================================
        # 1️⃣ Parse Request Body (VERY IMPORTANT FIX)
        # ===========================================
        body = event.get('body', {})

        # Handle both cases:
        # - API Gateway sends string
        # - Direct Lambda test sends dict
        if isinstance(body, str):
            body = json.loads(body)

        print("✅ PARSED BODY:", body)

        order_id = body.get('order_id')

        # Validate input
        if not order_id:
            raise Exception("order_id is missing in request")

        # ===========================================
        # 2️⃣ Update DynamoDB
        # ===========================================
        dynamo_table.update_item(
            Key={'order_id': order_id},
            UpdateExpression="SET payment_status = :ps",
            ExpressionAttributeValues={':ps': 'PAID'}
        )

        print(f"✅ DynamoDB updated for {order_id}")

        # ===========================================
        # 3️⃣ Update MySQL (RDS)
        # ===========================================
        secret = get_db_secret()

        connection = pymysql.connect(
            host=secret['host'],
            user=secret['username'],
            password=secret['password'],
            database=secret['dbname'],
            cursorclass=pymysql.cursors.DictCursor,
            connect_timeout=10
        )

        try:
            with connection.cursor() as cursor:
                sql = "UPDATE orders SET payment_status=%s WHERE order_id=%s"
                cursor.execute(sql, ('PAID', order_id))

            connection.commit()
            print(f"✅ MySQL updated for {order_id}")

        finally:
            connection.close()

        # ===========================================
        # 4️⃣ SUCCESS RESPONSE
        # ===========================================
        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "Content-Type,Authorization",
                "Access-Control-Allow-Methods": "OPTIONS,POST",
                "Content-Type": "application/json"
            },
            "body": json.dumps({
                "success": True,
                "message": f"Order {order_id} marked as PAID successfully"
            })
        }

    except Exception as e:
        # ===========================================
        # 5️⃣ ERROR HANDLING
        # ===========================================
        print("❌ ERROR:", str(e))  # Log error to CloudWatch

        return {
            "statusCode": 500,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "Content-Type,Authorization",
                "Access-Control-Allow-Methods": "OPTIONS,POST",
                "Content-Type": "application/json"
            },
            "body": json.dumps({
                "success": False,
                "error": str(e)
            })
        }
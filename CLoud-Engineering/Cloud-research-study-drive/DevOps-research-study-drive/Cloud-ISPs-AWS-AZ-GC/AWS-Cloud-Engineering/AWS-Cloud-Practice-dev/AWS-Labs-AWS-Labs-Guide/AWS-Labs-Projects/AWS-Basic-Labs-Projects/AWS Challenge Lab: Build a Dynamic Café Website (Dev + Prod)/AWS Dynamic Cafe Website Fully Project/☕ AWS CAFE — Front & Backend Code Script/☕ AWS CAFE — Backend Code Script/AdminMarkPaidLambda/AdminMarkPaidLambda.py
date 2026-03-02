# ===========================================
# AdminMarkPaidLambda (MySQL + DynamoDB)
# Purpose:
# - Used by ADMIN only
# - Marks CASH orders as PAID in both DynamoDB and MySQL
# ===========================================

import json
import boto3
import pymysql
from decimal import Decimal
from datetime import datetime
import os

# -----------------------------
# DynamoDB setup
# -----------------------------
dynamodb = boto3.resource('dynamodb')
dynamo_table = dynamodb.Table('CafeOrders')

# -----------------------------
# Secrets Manager
# -----------------------------
SECRETS_NAME = os.environ.get('SECRET_NAME', 'CafeDevDBSM')
secrets_client = boto3.client('secretsmanager')

def get_db_secret():
    """Fetch DB credentials from Secrets Manager"""
    secret = secrets_client.get_secret_value(SecretId=SECRETS_NAME)
    return json.loads(secret['SecretString'])

def lambda_handler(event, context):
    """
    Expects:
    {
        "order_id": "ORD-123456"
    }
    """
    try:
        body = json.loads(event['body'])
        order_id = body['order_id']

        # -----------------------------
        # 1️⃣ Update DynamoDB
        # -----------------------------
        dynamo_table.update_item(
            Key={'order_id': order_id},
            UpdateExpression="SET payment_status = :ps",
            ExpressionAttributeValues={':ps': 'PAID'}
        )

        # -----------------------------
        # 2️⃣ Update MySQL
        # -----------------------------
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
        finally:
            connection.close()

        # -----------------------------
        # 3️⃣ Return success
        # -----------------------------
        return {
            "statusCode": 200,
            "headers": {"Access-Control-Allow-Origin": "*", "Content-Type": "application/json"},
            "body": json.dumps({"success": True, "message": f"Order {order_id} marked as PAID in DynamoDB & MySQL"})
        }

    except Exception as e:
        # -----------------------------
        # 4️⃣ Error handling
        # -----------------------------
        return {
            "statusCode": 500,
            "headers": {"Access-Control-Allow-Origin": "*", "Content-Type": "application/json"},
            "body": json.dumps({"success": False, "error": str(e)})
        }
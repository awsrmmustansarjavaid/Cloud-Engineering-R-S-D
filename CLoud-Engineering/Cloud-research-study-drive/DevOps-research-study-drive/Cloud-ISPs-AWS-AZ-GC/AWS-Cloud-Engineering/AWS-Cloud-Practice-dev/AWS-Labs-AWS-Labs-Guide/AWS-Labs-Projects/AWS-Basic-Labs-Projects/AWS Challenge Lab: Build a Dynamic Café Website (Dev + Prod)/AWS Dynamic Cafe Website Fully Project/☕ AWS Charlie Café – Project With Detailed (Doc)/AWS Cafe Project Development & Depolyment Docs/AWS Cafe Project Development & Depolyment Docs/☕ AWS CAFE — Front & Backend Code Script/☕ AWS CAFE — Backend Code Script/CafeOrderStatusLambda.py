import json
import os
import pymysql

def get_connection():
    return pymysql.connect(
        host=os.environ["DB_HOST"],
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASS"],
        database=os.environ["DB_NAME"],
        cursorclass=pymysql.cursors.DictCursor
    )

def lambda_handler(event, context):
    params = event.get("queryStringParameters") or {}
    order_id = params.get("order_id")

    if not order_id:
        return {
            "statusCode": 400,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": "order_id required"})
        }

    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("""
            SELECT table_number, customer_name, item, quantity, created_at
            FROM orders
            ORDER BY created_at DESC
            LIMIT 1
        """)
        order = cursor.fetchone()

        if not order:
            return {
                "statusCode": 404,
                "headers": {"Access-Control-Allow-Origin": "*"},
                "body": json.dumps({"status": "NOT FOUND"})
            }

        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Content-Type": "application/json"
            },
            "body": json.dumps({
                "order_id": order_id,
                "status": "RECEIVED",
                "order": order
            }, default=str)
        }

    finally:
        cursor.close()
        conn.close()
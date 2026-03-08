import json
import pymysql
import os
import random
from datetime import datetime

def generate_order_id():
    return f"ORD-{datetime.now().strftime('%Y%m%d')}-{random.randint(1000,9999)}"

def get_connection():
    return pymysql.connect(
        host=os.environ["DB_HOST"],
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASS"],
        database=os.environ["DB_NAME"]
    )

def lambda_handler(event, context):
    data = json.loads(event["body"])

    order_id = generate_order_id()
    table_number = data["table_number"]
    customer_name = data["customer_name"]
    item = data["item"]
    quantity = int(data["quantity"])

    PRICE_LIST = {
        "Coffee": 3.00,
        "Tea": 2.50,
        "Latte": 4.00,
        "Cappuccino": 4.50,
        "Fresh Juice": 5.00
    }

    total_amount = PRICE_LIST[item] * quantity

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        INSERT INTO orders
        (order_id, table_number, customer_name, item, quantity, total_amount, status)
        VALUES (%s,%s,%s,%s,%s,%s,'RECEIVED')
    """, (order_id, table_number, customer_name, item, quantity, total_amount))

    conn.commit()
    cursor.close()
    conn.close()

    return {
        "statusCode": 200,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": json.dumps({
            "message": "Order placed",
            "order_id": order_id,
            "status": "RECEIVED",
            "total": total_amount,
            "track_url": f"/order-status.php?order_id={order_id}"
        })
    }
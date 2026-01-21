import json
import pymysql
import os

VALID_FLOW = {
    "RECEIVED": "PREPARING",
    "PREPARING": "READY",
    "READY": "COMPLETED"
}

def get_connection():
    return pymysql.connect(
        host=os.environ["DB_HOST"],
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASS"],
        database=os.environ["DB_NAME"]
    )

def lambda_handler(event, context):
    data = json.loads(event["body"])
    order_id = data["order_id"]
    new_status = data["status"]

    conn = get_connection()
    cursor = conn.cursor(pymysql.cursors.DictCursor)

    cursor.execute("SELECT status FROM orders WHERE order_id=%s", (order_id,))
    order = cursor.fetchone()

    if not order:
        return {"statusCode":404,"body":"Order not found"}

    current_status = order["status"]

    if VALID_FLOW.get(current_status) != new_status:
        return {"statusCode":400,"body":"Invalid status transition"}

    cursor.execute("""
        UPDATE orders SET status=%s WHERE order_id=%s
    """, (new_status, order_id))

    conn.commit()
    cursor.close()
    conn.close()

    return {
        "statusCode":200,
        "body":json.dumps({
            "order_id": order_id,
            "status": new_status
        })
    }
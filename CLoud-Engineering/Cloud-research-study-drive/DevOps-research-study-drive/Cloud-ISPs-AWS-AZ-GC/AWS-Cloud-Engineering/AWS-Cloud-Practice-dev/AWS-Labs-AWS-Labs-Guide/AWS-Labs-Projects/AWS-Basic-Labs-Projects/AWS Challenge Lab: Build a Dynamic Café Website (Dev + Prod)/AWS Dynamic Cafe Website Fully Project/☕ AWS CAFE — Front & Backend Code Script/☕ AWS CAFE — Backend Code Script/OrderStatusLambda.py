import json
import os
import pymysql

# ================= CONFIG =================
DB_HOST = os.environ['DB_HOST']
DB_USER = os.environ['DB_USER']
DB_PASS = os.environ['DB_PASS']
DB_NAME = os.environ['DB_NAME']

# ================= DB CONNECTION =================
def get_connection():
    return pymysql.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASS,
        db=DB_NAME,
        cursorclass=pymysql.cursors.DictCursor
    )

# ================= LAMBDA HANDLER =================
def lambda_handler(event, context):
    conn = None
    cursor = None

    try:
        params = event.get("queryStringParameters") or {}
        filter_date = params.get("date")

        conn = get_connection()
        cursor = conn.cursor()

        # ---------- RECENT ORDERS ----------
        sql = "SELECT customer_name, item, quantity, created_at FROM orders"
        values = []

        if filter_date:
            sql += " WHERE DATE(created_at) = %s"
            values.append(filter_date)

        sql += " ORDER BY created_at DESC LIMIT 20"
        cursor.execute(sql, values)
        recent_orders = cursor.fetchall()

        # ---------- METRICS (DATE-AWARE) ----------
        metrics = []

        where_clause = ""
        metric_values = []

        if filter_date:
            where_clause = " WHERE DATE(created_at) = %s"
            metric_values.append(filter_date)

        cursor.execute(
            f"SELECT COUNT(*) AS count FROM orders{where_clause}",
            metric_values
        )
        metrics.append({
            "metric": "Total Orders",
            "count": cursor.fetchone()['count']
        })

        cursor.execute(
            f"SELECT SUM(quantity) AS count FROM orders{where_clause}",
            metric_values
        )
        metrics.append({
            "metric": "Total Items Sold",
            "count": cursor.fetchone()['count'] or 0
        })

        cursor.execute(
            f"SELECT COUNT(DISTINCT customer_name) AS count FROM orders{where_clause}",
            metric_values
        )
        metrics.append({
            "metric": "Customers",
            "count": cursor.fetchone()['count']
        })

        # ---------- RESPONSE ----------
        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "Authorization",
                "Access-Control-Allow-Methods": "GET"
            },
            "body": json.dumps({
                "metrics": metrics,
                "recent_orders": recent_orders
            }, default=str)
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({"error": str(e)})
        }

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()
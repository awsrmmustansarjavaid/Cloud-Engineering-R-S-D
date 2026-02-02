import json
import os
import pymysql
from datetime import date, timedelta

# RDS config from environment
DB_HOST = os.environ['DB_HOST']
DB_USER = os.environ['DB_USER']
DB_PASSWORD = os.environ['DB_PASSWORD']
DB_NAME = os.environ['DB_NAME']

def get_connection():
    return pymysql.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME,
        cursorclass=pymysql.cursors.DictCursor
    )

def lambda_handler(event, context):
    query_type = event.get("queryStringParameters", {}).get("type")

    if query_type not in ["daily", "weekly", "monthly"]:
        return response(400, {"message": "Invalid type"})

    conn = get_connection()
    cursor = conn.cursor()

    # Date filters
    today = date.today()

    if query_type == "daily":
        sql = """
        SELECT e.employee_id, e.name, a.date, a.checkin_time, a.checkout_time
        FROM attendance a
        JOIN employees e ON a.employee_id = e.employee_id
        WHERE a.date = CURDATE()
        """

    elif query_type == "weekly":
        sql = """
        SELECT e.employee_id, e.name, a.date, a.checkin_time, a.checkout_time
        FROM attendance a
        JOIN employees e ON a.employee_id = e.employee_id
        WHERE a.date >= CURDATE() - INTERVAL 7 DAY
        """

    else:  # monthly
        sql = """
        SELECT e.employee_id, e.name, a.date, a.checkin_time, a.checkout_time
        FROM attendance a
        JOIN employees e ON a.employee_id = e.employee_id
        WHERE MONTH(a.date) = MONTH(CURDATE())
        AND YEAR(a.date) = YEAR(CURDATE())
        """

    cursor.execute(sql)
    records = cursor.fetchall()

    cursor.close()
    conn.close()

    return response(200, {"attendance": records})

def response(status, body):
    return {
        "statusCode": status,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Authorization,Content-Type",
            "Access-Control-Allow-Methods": "GET"
        },
        "body": json.dumps(body)
    }

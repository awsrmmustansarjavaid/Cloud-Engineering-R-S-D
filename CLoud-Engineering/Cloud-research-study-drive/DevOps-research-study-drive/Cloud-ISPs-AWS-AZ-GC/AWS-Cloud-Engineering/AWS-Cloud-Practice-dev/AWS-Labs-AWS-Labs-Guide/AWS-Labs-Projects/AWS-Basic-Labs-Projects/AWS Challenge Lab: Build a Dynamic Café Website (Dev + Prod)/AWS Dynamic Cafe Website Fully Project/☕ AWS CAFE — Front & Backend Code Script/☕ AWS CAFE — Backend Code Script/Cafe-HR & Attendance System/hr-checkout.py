import json
import os
import pymysql
from datetime import date, datetime

connection = pymysql.connect(
    host=os.environ['DB_HOST'],
    user=os.environ['DB_USER'],
    password=os.environ['DB_PASS'],
    database=os.environ['DB_NAME'],
    cursorclass=pymysql.cursors.DictCursor
)

def lambda_handler(event, context):
    try:
        # -------------------------------
        # AUTHORIZATION — ROLE CHECK
        # -------------------------------
        claims = event["requestContext"]["authorizer"]["claims"]
        groups = claims.get("cognito:groups", [])

        if isinstance(groups, str):
            groups = [groups]

        if "Employee" not in groups:
            return response(403, "Forbidden")

        # -------------------------------
        # BUSINESS LOGIC (UNCHANGED)
        # -------------------------------
        cognito_user_id = claims["sub"]
        today = date.today()
        now = datetime.now().time()

        with connection.cursor() as cursor:
            cursor.execute("""
                UPDATE attendance a
                JOIN employees e ON a.employee_id = e.employee_id
                SET a.checkout_time=%s
                WHERE e.cognito_user_id=%s
                AND a.attendance_date=%s
            """, (now, cognito_user_id, today))

            if cursor.rowcount == 0:
                return response(400, "Check-in required before checkout")

            connection.commit()

        return response(200, "Check-out successful")

    except Exception as e:
        return response(500, str(e))

def response(status, message):
    return {
        "statusCode": status,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Authorization,Content-Type",
            "Access-Control-Allow-Methods": "POST,OPTIONS"
        },
        "body": json.dumps({"message": message})
    }

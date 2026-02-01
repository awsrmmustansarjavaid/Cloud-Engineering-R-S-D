import json
import os
import pymysql
import datetime
from decimal import Decimal

connection = pymysql.connect(
    host=os.environ['DB_HOST'],
    user=os.environ['DB_USER'],
    password=os.environ['DB_PASS'],
    database=os.environ['DB_NAME'],
    cursorclass=pymysql.cursors.DictCursor
)

def json_serializer(obj):
    if isinstance(obj, Decimal):
        return float(obj)
    if isinstance(obj, (datetime.date, datetime.datetime)):
        return obj.isoformat()
    return str(obj)

def lambda_handler(event, context):
    claims = event["requestContext"]["authorizer"]["claims"]
    groups = claims.get("cognito:groups", [])

    if isinstance(groups, str):
        groups = [groups]

    if "Employee" not in groups:
        return forbidden()

    cognito_user_id = claims["sub"]

    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT l.leave_date, l.leave_type
            FROM leaves l
            JOIN employees e ON l.employee_id = e.employee_id
            WHERE e.cognito_user_id=%s
        """, (cognito_user_id,))
        leaves = cursor.fetchall()

        cursor.execute("""
            SELECT holiday_date, description
            FROM holidays
        """)
        holidays = cursor.fetchall()

    return {
        "statusCode": 200,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": json.dumps(
            {"leaves": leaves, "holidays": holidays},
            default=json_serializer
        )
    }

def forbidden():
    return {
        "statusCode": 403,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": json.dumps({"message": "Forbidden"})
    }

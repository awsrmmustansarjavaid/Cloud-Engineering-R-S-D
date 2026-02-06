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

def check_role(event, allowed_role):
    claims = event["requestContext"]["authorizer"]["claims"]
    groups = claims.get("cognito:groups", [])

    if isinstance(groups, str):
        groups = [groups]

    return allowed_role in groups

def json_serializer(obj):
    if isinstance(obj, Decimal):
        return float(obj)
    if isinstance(obj, (datetime.date, datetime.datetime)):
        return obj.isoformat()
    return str(obj)

def lambda_handler(event, context):
    # ----------------------------------------
    # AUTHORIZATION — EMPLOYEE ONLY
    # ----------------------------------------
    ALLOWED_ROLE = "Employee"

    if not check_role(event, ALLOWED_ROLE):
        return forbidden()

    claims = event["requestContext"]["authorizer"]["claims"]
    cognito_user_id = claims["sub"]

    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT name, job_title, salary, start_date
            FROM employees
            WHERE cognito_user_id=%s
        """, (cognito_user_id,))
        employee = cursor.fetchone()

    return {
        "statusCode": 200,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": json.dumps(employee, default=json_serializer)
    }

def forbidden():
    return {
        "statusCode": 403,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": json.dumps({"message": "Forbidden"})
    }

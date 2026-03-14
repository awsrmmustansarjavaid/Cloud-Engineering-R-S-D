import json
import os
import boto3
import pymysql
import datetime
from decimal import Decimal

# ==========================================================
# SECRETS MANAGER CONFIGURATION
# ==========================================================
# AWS Secrets Manager stores RDS credentials securely.
# Replace SECRET_NAME with your actual secret name.
SECRET_NAME = "CafeDevDBSM"
REGION_NAME = os.environ.get("AWS_REGION", "us-east-1")

secrets_client = boto3.client("secretsmanager", region_name=REGION_NAME)

# ==========================================================
# FETCH DATABASE SECRET
# ==========================================================
def get_db_secret():
    """
    Fetch database credentials from AWS Secrets Manager.
    Returns a dictionary with host, username, password, and dbname.
    """
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])

# ==========================================================
# DATABASE CONNECTION (REUSED ACROSS INVOCATIONS)
# ==========================================================
connection = None

def get_connection():
    """
    Reuse a persistent DB connection across Lambda invocations
    to improve performance and reduce cold start latency.
    """
    global connection

    if connection is None:
        secret = get_db_secret()
        connection = pymysql.connect(
            host=secret["host"],
            user=secret["username"],
            password=secret["password"],
            database=secret["dbname"],
            cursorclass=pymysql.cursors.DictCursor,
            connect_timeout=10,
            autocommit=True
        )
    return connection

# ==========================================================
# JSON SERIALIZER
# ==========================================================
def json_serializer(obj):
    """
    Converts non-JSON-serializable types to JSON-friendly types:
    - Decimal -> float
    - datetime.date/datetime -> ISO format string
    """
    if isinstance(obj, Decimal):
        return float(obj)
    if isinstance(obj, (datetime.date, datetime.datetime)):
        return obj.isoformat()
    return str(obj)

# ==========================================================
# STANDARD RESPONSE FORMAT
# ==========================================================
def response(status, body):
    """
    Standard API Gateway response with CORS headers.
    """
    return {
        "statusCode": status,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Methods": "GET,POST,OPTIONS"
        },
        "body": json.dumps(body, default=json_serializer)
    }

# ==========================================================
# LAMBDA HANDLER
# ==========================================================
def lambda_handler(event, context):
    """
    Returns attendance history for a given employee.
    Expects JSON body:
    { "employee_id": 1001 }
    """

    try:
        # Handle CORS preflight request
        if event.get("httpMethod") == "OPTIONS":
            return response(200, {"message": "CORS preflight successful"})

        # Validate request body
        if not event.get("body"):
            return response(400, {"message": "Missing request body"})

        body = json.loads(event["body"])
        employee_id = body.get("employee_id")

        if not employee_id:
            return response(400, {"message": "employee_id is required"})

        # ----------------------------------------
        # DATABASE QUERY
        # ----------------------------------------
        connection = get_connection()
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT attendance_date, checkin_time, checkout_time
                FROM attendance
                WHERE employee_id=%s
                ORDER BY attendance_date DESC
            """, (employee_id,))

            records = cursor.fetchall()

        # Return attendance records
        return response(200, records)

    except Exception as e:
        # Catch-all error handler
        return response(500, {"error": str(e)})
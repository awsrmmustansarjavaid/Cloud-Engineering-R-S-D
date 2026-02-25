import json
import os
import boto3
import pymysql
import datetime
from decimal import Decimal

# ==========================================================
# SECRETS MANAGER CONFIGURATION
# ==========================================================

SECRET_NAME = "CafeDevDBSM"   # Your existing RDS secret
REGION_NAME = os.environ.get("AWS_REGION", "us-east-1")

secrets_client = boto3.client("secretsmanager", region_name=REGION_NAME)

# ==========================================================
# FETCH DATABASE SECRET
# ==========================================================

def get_db_secret():
    """
    Retrieve database credentials from AWS Secrets Manager.

    Expected secret JSON structure:
    {
        "host": "...",
        "username": "...",
        "password": "...",
        "dbname": "..."
    }
    """
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])


# ==========================================================
# DATABASE CONNECTION (REUSED ACROSS INVOCATIONS)
# ==========================================================

connection = None

def get_connection():
    """
    Reuse existing DB connection if open.
    Otherwise create new connection using secret credentials.
    """
    global connection

    if connection is None or not connection.open:
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
# ROLE CHECK (COGNITO GROUP VALIDATION)
# ==========================================================

def check_role(event, allowed_role):
    claims = event["requestContext"]["authorizer"]["claims"]
    groups = claims.get("cognito:groups", [])

    if isinstance(groups, str):
        groups = [groups]

    return allowed_role in groups


# ==========================================================
# JSON SERIALIZER (FOR DECIMAL & DATE)
# ==========================================================

def json_serializer(obj):
    if isinstance(obj, Decimal):
        return float(obj)
    if isinstance(obj, (datetime.date, datetime.datetime)):
        return obj.isoformat()
    return str(obj)


# ==========================================================
# FORBIDDEN RESPONSE
# ==========================================================

def forbidden():
    return {
        "statusCode": 403,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": json.dumps({"message": "Forbidden"})
    }


# ==========================================================
# LAMBDA HANDLER
# ==========================================================

def lambda_handler(event, context):
    """
    Returns logged-in employee profile.
    Only accessible by users in 'Employee' Cognito group.
    """

    try:
        # ----------------------------------------
        # AUTHORIZATION — EMPLOYEE ONLY
        # ----------------------------------------
        ALLOWED_ROLE = "Employee"

        if not check_role(event, ALLOWED_ROLE):
            return forbidden()

        claims = event["requestContext"]["authorizer"]["claims"]
        cognito_user_id = claims["sub"]

        # ----------------------------------------
        # DATABASE QUERY
        # ----------------------------------------
        connection = get_connection()

        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT name, job_title, salary, start_date
                FROM employees
                WHERE cognito_user_id=%s
            """, (cognito_user_id,))

            employee = cursor.fetchone()

        if not employee:
            return {
                "statusCode": 404,
                "headers": {"Access-Control-Allow-Origin": "*"},
                "body": json.dumps({"message": "Employee not found"})
            }

        # ----------------------------------------
        # SUCCESS RESPONSE
        # ----------------------------------------
        return {
            "statusCode": 200,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps(employee, default=json_serializer)
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": str(e)})
        }
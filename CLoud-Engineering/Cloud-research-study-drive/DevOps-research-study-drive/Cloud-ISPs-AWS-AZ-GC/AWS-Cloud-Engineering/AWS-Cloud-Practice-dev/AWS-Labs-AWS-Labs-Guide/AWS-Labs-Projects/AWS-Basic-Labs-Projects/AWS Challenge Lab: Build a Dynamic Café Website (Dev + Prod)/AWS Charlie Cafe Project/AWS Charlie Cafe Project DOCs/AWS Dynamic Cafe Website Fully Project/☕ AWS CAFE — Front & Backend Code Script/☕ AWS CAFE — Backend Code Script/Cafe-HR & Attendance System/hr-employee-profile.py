import json
import os
import boto3
import pymysql
import datetime
from decimal import Decimal

# ==========================================================
# SECRETS MANAGER CONFIGURATION
# ==========================================================

SECRET_NAME = "CafeDevDBSM"
REGION_NAME = os.environ.get("AWS_REGION", "us-east-1")

secrets_client = boto3.client("secretsmanager", region_name=REGION_NAME)


# ==========================================================
# FETCH DATABASE SECRET
# ==========================================================

def get_db_secret():
    """
    Fetch database credentials from AWS Secrets Manager
    """
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])


# ==========================================================
# DATABASE CONNECTION (REUSED ACROSS LAMBDA INVOCATIONS)
# ==========================================================

connection = None

def get_connection():
    """
    Reuse database connection across Lambda executions
    to reduce cold start latency.
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
# JSON SERIALIZER (FOR DECIMAL & DATE TYPES)
# ==========================================================

def json_serializer(obj):
    """
    Convert MySQL data types into JSON serializable format.
    """

    if isinstance(obj, Decimal):
        return float(obj)

    if isinstance(obj, (datetime.date, datetime.datetime)):
        return obj.isoformat()

    return str(obj)


# ==========================================================
# STANDARD API RESPONSE FORMAT
# ==========================================================

def response(status, body):
    """
    Standardized API response with CORS headers
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
    Public API that returns employee profile.

    Expected request body:
    {
        "employee_id": 1001
    }
    """

    try:

        # --------------------------------------------------
        # HANDLE CORS PREFLIGHT REQUEST
        # --------------------------------------------------

        if event.get("httpMethod") == "OPTIONS":
            return response(200, {"message": "CORS preflight successful"})


        # --------------------------------------------------
        # VALIDATE REQUEST BODY
        # --------------------------------------------------

        if not event.get("body"):
            return response(400, {"message": "Missing request body"})


        body = json.loads(event["body"])


        # --------------------------------------------------
        # VALIDATE employee_id (MUST BE NUMERIC)
        # --------------------------------------------------

        try:
            employee_id = int(body.get("employee_id"))
        except:
            return response(400, {"message": "employee_id must be numeric"})


        # --------------------------------------------------
        # DATABASE QUERY
        # --------------------------------------------------

        connection = get_connection()

        with connection.cursor() as cursor:

            cursor.execute("""
                SELECT employee_id, name, job_title, salary, start_date
                FROM employees
                WHERE employee_id=%s
            """, (employee_id,))

            employee = cursor.fetchone()


        # --------------------------------------------------
        # HANDLE EMPLOYEE NOT FOUND
        # --------------------------------------------------

        if not employee:
            return response(404, {"message": "Employee not found"})


        # --------------------------------------------------
        # SUCCESS RESPONSE
        # --------------------------------------------------

        return response(200, employee)


    except Exception as e:

        # --------------------------------------------------
        # SERVER ERROR HANDLING
        # --------------------------------------------------

        return response(500, {"error": str(e)})
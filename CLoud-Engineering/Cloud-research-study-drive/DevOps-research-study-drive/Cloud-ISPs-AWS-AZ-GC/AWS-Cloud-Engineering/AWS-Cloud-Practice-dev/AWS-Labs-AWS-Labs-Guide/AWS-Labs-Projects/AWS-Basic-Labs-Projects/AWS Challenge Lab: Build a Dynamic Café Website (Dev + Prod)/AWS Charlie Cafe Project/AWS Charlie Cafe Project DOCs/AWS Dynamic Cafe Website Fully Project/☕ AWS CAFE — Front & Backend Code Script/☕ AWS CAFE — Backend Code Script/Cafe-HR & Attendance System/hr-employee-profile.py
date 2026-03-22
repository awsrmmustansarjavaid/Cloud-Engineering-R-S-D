import json
import os
import boto3
import pymysql
import datetime
from decimal import Decimal

# ==========================================================
# 🔐 SECRETS MANAGER CONFIGURATION
# ==========================================================

SECRET_NAME = "CafeDevDBSM"
REGION_NAME = os.environ.get("AWS_REGION", "us-east-1")

secrets_client = boto3.client("secretsmanager", region_name=REGION_NAME)


# ==========================================================
# 🔑 FETCH DATABASE SECRET
# ==========================================================

def get_db_secret():
    """
    Fetch database credentials from AWS Secrets Manager
    """
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])


# ==========================================================
# 🔌 DATABASE CONNECTION (REUSE FOR PERFORMANCE)
# ==========================================================

connection = None

def get_connection():
    """
    Reuse DB connection across Lambda executions
    (Improves performance, reduces cold start time)
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
# 🔄 JSON SERIALIZER (Decimal + Date Support)
# ==========================================================

def json_serializer(obj):
    """
    Convert MySQL types → JSON serializable
    """

    if isinstance(obj, Decimal):
        return float(obj)

    if isinstance(obj, (datetime.date, datetime.datetime)):
        return obj.isoformat()

    return str(obj)


# ==========================================================
# 🌐 STANDARD RESPONSE FORMAT (CORS ENABLED)
# ==========================================================

def response(status, body):
    """
    Standard API response with CORS headers
    """

    return {
        "statusCode": status,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type,Authorization",
            "Access-Control-Allow-Methods": "GET,POST,OPTIONS"
        },
        "body": json.dumps(body, default=json_serializer)
    }


# ==========================================================
# 🚀 LAMBDA HANDLER (SECURE VERSION)
# ==========================================================

def lambda_handler(event, context):
    """
    🔐 SECURE API — Employee Profile

    ✔ Uses Cognito Authorizer
    ✔ Extracts employee_id from JWT
    ✔ No request body needed

    Flow:
    Client → API Gateway → Cognito Authorizer → Lambda
    """

    try:

        # --------------------------------------------------
        # 🟡 HANDLE CORS PREFLIGHT
        # --------------------------------------------------

        if event.get("httpMethod") == "OPTIONS":
            return response(200, {"message": "CORS preflight successful"})


        # --------------------------------------------------
        # 🔐 EXTRACT JWT CLAIMS (FROM API GATEWAY AUTHORIZER)
        # --------------------------------------------------

        claims = event.get("requestContext", {}) \
                      .get("authorizer", {}) \
                      .get("claims", {})

        if not claims:
            return response(401, {"message": "Unauthorized - Missing JWT claims"})


        # --------------------------------------------------
        # 🆔 EXTRACT EMPLOYEE ID FROM TOKEN
        # --------------------------------------------------

        try:
            employee_id = int(claims.get("custom:employee_id"))
        except:
            return response(400, {"message": "Invalid employee_id in token"})


        # --------------------------------------------------
        # 🗄️ DATABASE QUERY
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
        # ❌ EMPLOYEE NOT FOUND
        # --------------------------------------------------

        if not employee:
            return response(404, {"message": "Employee not found"})


        # --------------------------------------------------
        # ✅ SUCCESS RESPONSE
        # --------------------------------------------------

        return response(200, employee)


    except Exception as e:

        # --------------------------------------------------
        # 💥 SERVER ERROR
        # --------------------------------------------------

        return response(500, {
            "error": str(e)
        })
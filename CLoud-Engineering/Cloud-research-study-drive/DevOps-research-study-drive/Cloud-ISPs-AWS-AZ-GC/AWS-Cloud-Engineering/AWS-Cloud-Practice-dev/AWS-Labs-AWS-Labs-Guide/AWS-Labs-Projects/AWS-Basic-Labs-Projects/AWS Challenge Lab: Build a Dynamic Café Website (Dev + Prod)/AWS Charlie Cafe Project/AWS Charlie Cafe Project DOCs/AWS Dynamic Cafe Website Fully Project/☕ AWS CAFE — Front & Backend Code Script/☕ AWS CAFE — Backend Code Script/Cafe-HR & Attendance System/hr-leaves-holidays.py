import json
import os
import boto3
import pymysql
import datetime
from decimal import Decimal

# ==========================================================
# 🔐 SECRETS MANAGER CONFIGURATION
# ==========================================================
SECRET_NAME = os.environ.get("SECRET_NAME", "CafeDevDBSM")
REGION_NAME = os.environ.get("AWS_REGION", "us-east-1")

secrets_client = boto3.client("secretsmanager", region_name=REGION_NAME)

# ==========================================================
# 🔑 FETCH DATABASE SECRET
# ==========================================================
def get_db_secret():
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])

# ==========================================================
# 🔌 DATABASE CONNECTION
# ==========================================================
connection = None

def get_connection():
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
# 🔄 JSON SERIALIZER
# ==========================================================
def json_serializer(obj):
    if isinstance(obj, Decimal):
        return float(obj)
    if isinstance(obj, (datetime.date, datetime.datetime)):
        return obj.isoformat()
    return str(obj)

# ==========================================================
# 🌐 STANDARD RESPONSE
# ==========================================================
def response(status, body):
    return {
        "statusCode": status,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type,Authorization",
            "Access-Control-Allow-Methods": "POST,OPTIONS"
        },
        "body": json.dumps(body, default=json_serializer)
    }

# ==========================================================
# 🚀 LAMBDA HANDLER (SECURE VERSION)
# ==========================================================
def lambda_handler(event, context):
    """
    🔐 SECURE: Leaves & Holidays API

    ✔ Uses Cognito Authorizer
    ✔ Extracts employee_id from JWT
    ✔ No request body needed
    """

    try:

        print("EVENT:", json.dumps(event))  # ✅ Logging

        # --------------------------------------------------
        # CORS PREFLIGHT
        # --------------------------------------------------
        if event.get("httpMethod") == "OPTIONS":
            return response(200, {"message": "CORS OK"})

        # --------------------------------------------------
        # 🔐 EXTRACT JWT CLAIMS
        # --------------------------------------------------
        claims = event.get("requestContext", {}) \
                      .get("authorizer", {}) \
                      .get("claims", {})

        if not claims:
            return response(401, {"message": "Unauthorized"})

        # --------------------------------------------------
        # 🆔 GET EMPLOYEE ID FROM TOKEN
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

            # Employee leaves
            cursor.execute("""
                SELECT leave_date, leave_type
                FROM leaves
                WHERE employee_id=%s
                ORDER BY leave_date DESC
            """, (employee_id,))
            leaves = cursor.fetchall()

            # Company holidays
            cursor.execute("""
                SELECT holiday_date, description
                FROM holidays
                ORDER BY holiday_date DESC
            """)
            holidays = cursor.fetchall()

        return response(200, {
            "leaves": leaves,
            "holidays": holidays
        })

    except Exception as e:
        return response(500, {"error": str(e)})
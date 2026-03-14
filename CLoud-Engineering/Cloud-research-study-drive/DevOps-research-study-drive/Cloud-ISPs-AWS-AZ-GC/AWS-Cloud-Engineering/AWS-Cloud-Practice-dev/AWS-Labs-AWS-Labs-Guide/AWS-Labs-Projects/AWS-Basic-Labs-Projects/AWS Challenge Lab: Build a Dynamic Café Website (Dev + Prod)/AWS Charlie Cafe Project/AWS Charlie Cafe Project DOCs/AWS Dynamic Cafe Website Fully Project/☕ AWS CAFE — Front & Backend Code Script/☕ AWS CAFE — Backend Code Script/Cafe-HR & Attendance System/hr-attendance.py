import json
import os
import boto3
import pymysql
from datetime import date, datetime

# ==========================================================
# AWS SECRETS MANAGER CONFIG
# ==========================================================
SECRET_NAME = "CafeDevDBSM"
REGION_NAME = os.environ.get("AWS_REGION", "us-east-1")

secrets_client = boto3.client("secretsmanager", region_name=REGION_NAME)

# ==========================================================
# FETCH DATABASE SECRET
# ==========================================================
def get_db_secret():
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    secret = json.loads(response["SecretString"])
    return secret

# ==========================================================
# CREATE / REUSE DATABASE CONNECTION
# ==========================================================
connection = None
def get_connection():
    global connection

    if connection is None:
        secret = get_db_secret()
        connection = pymysql.connect(
            host=secret["host"],
            user=secret["username"],
            password=secret["password"],
            database=secret["dbname"],
            cursorclass=pymysql.cursors.DictCursor,
            autocommit=False,
            connect_timeout=10
        )
    return connection

# ==========================================================
# STANDARD API RESPONSE
# ==========================================================
def response(status, message):
    return {
        "statusCode": status,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Methods": "GET,POST,OPTIONS"
        },
        "body": json.dumps({"message": message})
    }

# ==========================================================
# LAMBDA HANDLER
# ==========================================================
def lambda_handler(event, context):
    """
    Public API for employee check-in and check-out.
    Expects numeric employee_id in request body.
    """

    try:
        # Handle OPTIONS (CORS preflight)
        if event.get("httpMethod") == "OPTIONS":
            return response(200, "CORS preflight successful")

        # Parse request body
        if not event.get("body"):
            return response(400, "Missing request body")

        body = json.loads(event["body"])
        employee_id = body.get("employee_id")
        action = body.get("action", "").lower()

        # Validate employee_id is numeric
        try:
            employee_id = int(employee_id)
        except (ValueError, TypeError):
            return response(400, "employee_id must be a number")

        today = date.today()
        now = datetime.now().time()
        path = event.get("resource") or event.get("path", "")

        connection = get_connection()

        with connection.cursor() as cursor:
            # Validate employee exists
            cursor.execute(
                "SELECT employee_id FROM employees WHERE employee_id=%s",
                (employee_id,)
            )
            employee = cursor.fetchone()
            if not employee:
                return response(404, "Employee not found")

            # ==================================================
            # CHECK-IN LOGIC
            # ==================================================
            if "checkin" in path.lower() or action == "checkin":
                try:
                    cursor.execute("""
                        INSERT INTO attendance
                        (employee_id, attendance_date, checkin_time)
                        VALUES (%s, %s, %s)
                    """, (employee_id, today, now))
                    connection.commit()
                    return response(200, "Check-in successful")
                except pymysql.err.IntegrityError:
                    return response(400, "Already checked in today")

            # ==================================================
            # CHECK-OUT LOGIC
            # ==================================================
            elif "checkout" in path.lower() or action == "checkout":
                cursor.execute("""
                    UPDATE attendance
                    SET checkout_time=%s
                    WHERE employee_id=%s
                    AND attendance_date=%s
                """, (now, employee_id, today))
                if cursor.rowcount == 0:
                    return response(400, "Check-in required before checkout")
                connection.commit()
                return response(200, "Check-out successful")

            # ==================================================
            # UNKNOWN ROUTE
            # ==================================================
            else:
                return response(404, "Invalid attendance action")

    except Exception as e:
        return response(500, str(e))
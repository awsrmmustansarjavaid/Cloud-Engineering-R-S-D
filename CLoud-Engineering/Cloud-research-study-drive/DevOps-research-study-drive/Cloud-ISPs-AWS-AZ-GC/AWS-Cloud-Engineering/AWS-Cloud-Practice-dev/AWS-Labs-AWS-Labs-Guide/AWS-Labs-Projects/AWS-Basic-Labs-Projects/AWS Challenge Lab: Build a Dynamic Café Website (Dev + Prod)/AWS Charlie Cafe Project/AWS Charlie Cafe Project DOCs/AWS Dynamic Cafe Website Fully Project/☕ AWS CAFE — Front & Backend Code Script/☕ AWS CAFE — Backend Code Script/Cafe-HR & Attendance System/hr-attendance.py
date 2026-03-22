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
    return json.loads(response["SecretString"])


# ==========================================================
# CREATE / REUSE DATABASE CONNECTION
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
    Charlie Café HR Attendance API

    Supports:
    POST /attendance/checkin
    POST /attendance/checkout

    Request body:
    {
        "employee_id": 5,
        "action": "checkin" | "checkout"
    }
    """

    connection = None

    try:

        # --------------------------------------------------
        # HANDLE CORS PREFLIGHT
        # --------------------------------------------------
        if event.get("httpMethod") == "OPTIONS":
            return response(200, "CORS preflight successful")


        # --------------------------------------------------
        # VALIDATE REQUEST BODY
        # --------------------------------------------------
        if not event.get("body"):
            return response(400, "Missing request body")

        body = json.loads(event["body"])

        employee_id = body.get("employee_id")
        action = body.get("action", "").lower()


        # --------------------------------------------------
        # VALIDATE EMPLOYEE ID
        # --------------------------------------------------
        try:
            employee_id = int(employee_id)
        except (ValueError, TypeError):
            return response(400, "employee_id must be a number")


        # --------------------------------------------------
        # REQUEST CONTEXT
        # --------------------------------------------------
        today = date.today()
        now = datetime.now().time()

        # API Gateway path detection
        path = event.get("path", "").lower()


        # --------------------------------------------------
        # CONNECT TO DATABASE
        # --------------------------------------------------
        connection = get_connection()

        with connection.cursor() as cursor:

            # --------------------------------------------------
            # VERIFY EMPLOYEE EXISTS
            # --------------------------------------------------
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
            if "checkin" in path or action == "checkin":

                # Prevent duplicate check-ins
                cursor.execute("""
                    SELECT employee_id
                    FROM attendance
                    WHERE employee_id=%s
                    AND attendance_date=%s
                """, (employee_id, today))

                if cursor.fetchone():
                    return response(400, "Already checked in today")

                cursor.execute("""
                    INSERT INTO attendance
                    (employee_id, attendance_date, checkin_time)
                    VALUES (%s, %s, %s)
                """, (employee_id, today, now))

                connection.commit()

                return response(200, "Check-in successful")


            # ==================================================
            # CHECK-OUT LOGIC
            # ==================================================
            elif "checkout" in path or action == "checkout":

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
            # INVALID ROUTE
            # ==================================================
            else:
                return response(404, "Invalid attendance action")


    # --------------------------------------------------
    # ERROR HANDLING
    # --------------------------------------------------
    except Exception as e:

        if connection:
            connection.rollback()

        return response(500, str(e))
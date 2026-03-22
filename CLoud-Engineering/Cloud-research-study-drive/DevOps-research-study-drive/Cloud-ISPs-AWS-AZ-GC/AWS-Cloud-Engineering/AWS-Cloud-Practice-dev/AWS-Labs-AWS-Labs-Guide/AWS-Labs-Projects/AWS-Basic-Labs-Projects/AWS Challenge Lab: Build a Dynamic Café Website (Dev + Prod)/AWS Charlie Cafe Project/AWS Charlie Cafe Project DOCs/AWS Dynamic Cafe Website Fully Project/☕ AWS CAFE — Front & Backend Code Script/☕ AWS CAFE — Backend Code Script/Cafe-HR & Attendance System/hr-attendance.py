# ==============================================================================
# CHARLIE CAFÉ ☕ — Lambda: hr-attendance
# ==============================================================================
# Purpose  : Handles employee check-in and check-out for today's date.
# Routes   : POST /attendance/checkin
#            POST /attendance/checkout
# Auth     : NO Cognito Authorizer — this endpoint is called by a shared
#            check-in kiosk/device, so employee_id comes from the request body.
# Database : RDS MySQL via PyMySQL (credentials from AWS Secrets Manager)
# ==============================================================================

import json
import os
import boto3
import pymysql
from datetime import date, datetime

# ------------------------------------------------------------------------------
# SECRETS MANAGER — configuration
# The secret name must match exactly what you created in AWS Secrets Manager.
# REGION_NAME is read from the Lambda environment variable AWS_REGION.
# ------------------------------------------------------------------------------
SECRET_NAME = "CafeDevDBSM"
REGION_NAME = os.environ.get("AWS_REGION", "us-east-1")

secrets_client = boto3.client("secretsmanager", region_name=REGION_NAME)


# ------------------------------------------------------------------------------
# get_db_secret()
# Fetches RDS credentials from Secrets Manager at runtime.
# Returns a dict: { host, username, password, dbname }
# Called only when a new DB connection is needed (cold start or reconnect).
# ------------------------------------------------------------------------------
def get_db_secret():
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])


# ------------------------------------------------------------------------------
# Persistent connection — reused across warm Lambda invocations for performance.
#
# IMPORTANT: Named _connection (leading underscore) to prevent any local variable
# named `connection` inside lambda_handler from accidentally shadowing this global.
# That shadowing bug was the original cause of rollback() failing in the except block.
#
# autocommit=False: We commit manually after successful writes so we can
# rollback() on any error and keep the database consistent.
# ------------------------------------------------------------------------------
_connection = None

def get_connection():
    global _connection
    if _connection is None or not _connection.open:
        secret = get_db_secret()
        _connection = pymysql.connect(
            host=secret["host"],
            user=secret["username"],
            password=secret["password"],
            database=secret["dbname"],
            cursorclass=pymysql.cursors.DictCursor,
            autocommit=False,
            connect_timeout=10
        )
    return _connection


# ------------------------------------------------------------------------------
# api_response()
# Builds a standard API Gateway Lambda proxy response.
# Includes CORS headers so the browser's preflight and data requests both work.
# `message` is a plain string — the body is always { "message": "..." }
# ------------------------------------------------------------------------------
def api_response(status, message):
    return {
        "statusCode": status,
        "headers": {
            "Access-Control-Allow-Origin":  "*",
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Methods": "GET,POST,OPTIONS"
        },
        "body": json.dumps({"message": message})
    }


# ------------------------------------------------------------------------------
# lambda_handler()
# Main entry point called by API Gateway for every request.
#
# Flow:
#   1. Handle browser CORS preflight (OPTIONS)
#   2. Parse + validate the JSON body (employee_id, action)
#   3. Open DB connection
#   4. Verify employee exists
#   5. Branch to check-in or check-out logic
#   6. Commit and return success, or rollback and return error
# ------------------------------------------------------------------------------
def lambda_handler(event, context):

    # `conn` is the local reference to the DB connection for THIS invocation.
    # Initialised to None so the except block can safely check `if conn:`
    # before calling rollback() — avoids UnboundLocalError.
    conn = None

    try:

        # ----------------------------------------------------------------------
        # STEP 1 — Handle CORS preflight
        # Browsers send OPTIONS before cross-origin POST requests.
        # We must respond 200 immediately or the actual POST is blocked.
        # ----------------------------------------------------------------------
        if event.get("httpMethod") == "OPTIONS":
            return api_response(200, "CORS preflight successful")


        # ----------------------------------------------------------------------
        # STEP 2 — Parse request body
        # ----------------------------------------------------------------------
        if not event.get("body"):
            return api_response(400, "Missing request body")

        body        = json.loads(event["body"])
        employee_id = body.get("employee_id")
        action      = body.get("action", "").lower()   # expected: "checkin" or "checkout"

        # Validate that employee_id can be cast to an integer
        try:
            employee_id = int(employee_id)
        except (ValueError, TypeError):
            return api_response(400, "employee_id must be a number")


        # ----------------------------------------------------------------------
        # STEP 3 — Capture date/time and determine the requested route
        # today / now are used in both checkin and checkout SQL queries.
        # path routing is a fallback alongside the action field in the body.
        # ----------------------------------------------------------------------
        today = date.today()
        now   = datetime.now().time()
        path  = event.get("path", "").lower()   # e.g. "/attendance/checkin"


        # ----------------------------------------------------------------------
        # STEP 4 — Open DB connection
        # ----------------------------------------------------------------------
        conn = get_connection()

        with conn.cursor() as cursor:

            # ------------------------------------------------------------------
            # Verify employee exists before any attendance write
            # ------------------------------------------------------------------
            cursor.execute(
                "SELECT employee_id FROM employees WHERE employee_id = %s",
                (employee_id,)
            )
            if not cursor.fetchone():
                return api_response(404, "Employee not found")


            # ==================================================================
            # STEP 5a — CHECK-IN
            # Routing: URL path contains "checkin" OR body action == "checkin"
            # ==================================================================
            if "checkin" in path or action == "checkin":

                # Guard: one check-in per employee per calendar day
                cursor.execute("""
                    SELECT employee_id
                    FROM   attendance
                    WHERE  employee_id     = %s
                    AND    attendance_date  = %s
                """, (employee_id, today))

                if cursor.fetchone():
                    return api_response(400, "Already checked in today")

                # Insert attendance row with today's date and current time
                cursor.execute("""
                    INSERT INTO attendance (employee_id, attendance_date, checkin_time)
                    VALUES (%s, %s, %s)
                """, (employee_id, today, now))

                conn.commit()   # Persist the insert
                return api_response(200, "Check-in successful")


            # ==================================================================
            # STEP 5b — CHECK-OUT
            # Routing: URL path contains "checkout" OR body action == "checkout"
            # Updates the existing row — employee must have checked in first.
            # ==================================================================
            elif "checkout" in path or action == "checkout":

                cursor.execute("""
                    UPDATE attendance
                    SET    checkout_time   = %s
                    WHERE  employee_id     = %s
                    AND    attendance_date  = %s
                """, (now, employee_id, today))

                # rowcount == 0 means no matching row was found to update
                # (employee never checked in today)
                if cursor.rowcount == 0:
                    return api_response(400, "Check-in required before checkout")

                conn.commit()   # Persist the update
                return api_response(200, "Check-out successful")


            # ==================================================================
            # STEP 5c — INVALID ACTION
            # ==================================================================
            else:
                return api_response(404, "Invalid attendance action. Use 'checkin' or 'checkout'")


    # --------------------------------------------------------------------------
    # Global error handler
    # Rolls back any partial transaction so the DB stays consistent.
    # Returns a 500 with the exception message for debugging.
    # --------------------------------------------------------------------------
    except Exception as e:
        if conn:
            conn.rollback()
        return api_response(500, f"Internal server error: {str(e)}")
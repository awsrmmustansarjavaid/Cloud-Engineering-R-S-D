# ==============================================================================
# CHARLIE CAFÉ ☕ — Lambda: hr-attendance-history
# ==============================================================================
# Purpose  : Returns the full attendance history for the authenticated employee.
# Route    : POST /attendance-history
# Auth     : Cognito Authorizer — employee_id is extracted from the JWT claims.
#            The frontend sends NO body — the token alone identifies the employee.
#
# FIX (vs original): The original code read employee_id from the POST body,
# but api.js sends no body for this endpoint. Fixed to use JWT claims instead,
# matching the same pattern as hr-employee-profile.
#
# Database : RDS MySQL via PyMySQL (credentials from AWS Secrets Manager)
# ==============================================================================

import json
import os
import boto3
import pymysql
import datetime
from decimal import Decimal

# ------------------------------------------------------------------------------
# SECRETS MANAGER — configuration
# ------------------------------------------------------------------------------
SECRET_NAME = "CafeDevDBSM"
REGION_NAME = os.environ.get("AWS_REGION", "us-east-1")

secrets_client = boto3.client("secretsmanager", region_name=REGION_NAME)


# ------------------------------------------------------------------------------
# get_db_secret()
# Fetches RDS credentials from Secrets Manager.
# Returns a dict: { host, username, password, dbname }
# ------------------------------------------------------------------------------
def get_db_secret():
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])


# ------------------------------------------------------------------------------
# Persistent connection — reused across warm Lambda invocations.
# autocommit=True: this Lambda is read-only, no manual commit/rollback needed.
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
            autocommit=True,
            connect_timeout=10
        )
    return _connection


# ------------------------------------------------------------------------------
# json_serializer()
# Converts MySQL types that json.dumps cannot handle natively:
#   Decimal       → float   (not present here but included for consistency)
#   date/datetime → ISO 8601 string  (attendance_date, checkin_time, checkout_time)
# ------------------------------------------------------------------------------
def json_serializer(obj):
    if isinstance(obj, Decimal):
        return float(obj)
    if isinstance(obj, (datetime.date, datetime.datetime)):
        return obj.isoformat()
    return str(obj)


# ------------------------------------------------------------------------------
# api_response()
# Standard API Gateway Lambda proxy response with CORS headers.
# Authorization is in Allow-Headers because Cognito sends a Bearer token.
# ------------------------------------------------------------------------------
def api_response(status, body):
    return {
        "statusCode": status,
        "headers": {
            "Access-Control-Allow-Origin":  "*",
            "Access-Control-Allow-Headers": "Content-Type,Authorization",
            "Access-Control-Allow-Methods": "GET,POST,OPTIONS"
        },
        "body": json.dumps(body, default=json_serializer)
    }


# ------------------------------------------------------------------------------
# lambda_handler()
# Main entry point called by API Gateway for every request.
#
# Flow:
#   1. Handle browser CORS preflight (OPTIONS)
#   2. Extract employee_id from Cognito JWT claims (no body parsing needed)
#   3. Query attendance table ordered by most recent date first
#   4. Return the records array (empty array [] if no history exists)
# ------------------------------------------------------------------------------
def lambda_handler(event, context):

    try:

        # ----------------------------------------------------------------------
        # STEP 1 — Handle CORS preflight
        # ----------------------------------------------------------------------
        if event.get("httpMethod") == "OPTIONS":
            return api_response(200, {"message": "CORS preflight successful"})


        # ----------------------------------------------------------------------
        # STEP 2 — Extract employee_id from Cognito JWT claims
        #
        # The Cognito Authorizer on API Gateway decodes the Bearer token and
        # injects the claims here. No body is sent by the frontend.
        #
        # Requires: custom attribute "custom:employee_id" set on each Cognito user.
        # ----------------------------------------------------------------------
        claims = (
            event
            .get("requestContext", {})
            .get("authorizer", {})
            .get("claims", {})
        )

        if not claims:
            return api_response(401, {"message": "Unauthorized — missing JWT claims"})

        # Cognito custom attributes are strings — cast to int for the SQL query
        try:
            employee_id = int(claims.get("custom:employee_id"))
        except (TypeError, ValueError):
            return api_response(400, {"message": "Invalid employee_id in token"})


        # ----------------------------------------------------------------------
        # STEP 3 — Query attendance history
        # Returns all rows for this employee, newest date first.
        # checkin_time and checkout_time may be NULL if employee only checked in.
        # ----------------------------------------------------------------------
        conn = get_connection()

        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT attendance_date,
                       checkin_time,
                       checkout_time
                FROM   attendance
                WHERE  employee_id = %s
                ORDER  BY attendance_date DESC
            """, (employee_id,))

            records = cursor.fetchall()


        # ----------------------------------------------------------------------
        # STEP 4 — Return results
        # Returns an empty array [] if the employee has no attendance history.
        # The frontend handles both empty and populated arrays gracefully.
        # ----------------------------------------------------------------------
        return api_response(200, records)


    # --------------------------------------------------------------------------
    # Global error handler
    # --------------------------------------------------------------------------
    except Exception as e:
        return api_response(500, {"error": str(e)})
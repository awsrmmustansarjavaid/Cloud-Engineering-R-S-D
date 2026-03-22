# ==============================================================================
# CHARLIE CAFÉ ☕ — Lambda: hr-employee-profile
# ==============================================================================
# Purpose  : Returns the authenticated employee's profile data.
# Route    : POST /employee-profile
# Auth     : Cognito Authorizer — API Gateway validates the JWT and injects
#            the decoded claims into event["requestContext"]["authorizer"]["claims"].
#            employee_id is extracted from the JWT claim "custom:employee_id".
#            The frontend sends NO body and NO employee_id — it is 100% token-driven.
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
# autocommit=True: this Lambda is read-only (SELECT only), no commits needed.
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
# Custom JSON serializer passed to json.dumps as the `default` argument.
# Handles MySQL types that the standard library cannot serialize:
#   Decimal  → float   (salary fields)
#   date/datetime → ISO 8601 string  (start_date, etc.)
# ------------------------------------------------------------------------------
def json_serializer(obj):
    if isinstance(obj, Decimal):
        return float(obj)
    if isinstance(obj, (datetime.date, datetime.datetime)):
        return obj.isoformat()
    return str(obj)


# ------------------------------------------------------------------------------
# api_response()
# Builds a standard API Gateway Lambda proxy response with CORS headers.
# `body` can be a dict or a list — it is JSON-serialised with json_serializer.
# Authorization is included in Allow-Headers because Cognito sends a Bearer token.
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
#   2. Extract employee_id from Cognito JWT claims (no body needed)
#   3. Query the employees table
#   4. Return the profile or a 404 if the employee is not found
# ------------------------------------------------------------------------------
def lambda_handler(event, context):

    try:

        # ----------------------------------------------------------------------
        # STEP 1 — Handle CORS preflight
        # ----------------------------------------------------------------------
        if event.get("httpMethod") == "OPTIONS":
            return api_response(200, {"message": "CORS preflight successful"})


        # ----------------------------------------------------------------------
        # STEP 2 — Extract JWT claims injected by the Cognito Authorizer
        #
        # API Gateway validates the Bearer token, then populates:
        #   event["requestContext"]["authorizer"]["claims"]
        #
        # The custom attribute "custom:employee_id" must be set on each
        # Cognito user (in User Pool → Users → Attributes).
        # ----------------------------------------------------------------------
        claims = (
            event
            .get("requestContext", {})
            .get("authorizer", {})
            .get("claims", {})
        )

        if not claims:
            return api_response(401, {"message": "Unauthorized — missing JWT claims"})

        # Cast to int — Cognito custom attributes are always stored as strings
        try:
            employee_id = int(claims.get("custom:employee_id"))
        except (TypeError, ValueError):
            return api_response(400, {"message": "Invalid employee_id in token"})


        # ----------------------------------------------------------------------
        # STEP 3 — Query employee profile
        # Only expose the columns the portal needs — never SELECT *
        # ----------------------------------------------------------------------
        conn = get_connection()

        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT employee_id, name, job_title, salary, start_date
                FROM   employees
                WHERE  employee_id = %s
            """, (employee_id,))

            employee = cursor.fetchone()


        # ----------------------------------------------------------------------
        # STEP 4 — Return result or 404
        # ----------------------------------------------------------------------
        if not employee:
            return api_response(404, {"message": "Employee not found"})

        return api_response(200, employee)


    # --------------------------------------------------------------------------
    # Global error handler — returns 500 with the exception message
    # --------------------------------------------------------------------------
    except Exception as e:
        return api_response(500, {"error": str(e)})
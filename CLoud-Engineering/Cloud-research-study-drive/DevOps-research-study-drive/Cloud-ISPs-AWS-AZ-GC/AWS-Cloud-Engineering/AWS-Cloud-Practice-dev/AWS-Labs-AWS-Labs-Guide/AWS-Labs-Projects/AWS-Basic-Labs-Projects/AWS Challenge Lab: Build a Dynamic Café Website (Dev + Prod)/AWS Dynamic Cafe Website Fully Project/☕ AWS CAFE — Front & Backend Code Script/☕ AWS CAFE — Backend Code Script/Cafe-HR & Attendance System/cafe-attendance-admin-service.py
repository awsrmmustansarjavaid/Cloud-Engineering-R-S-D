import json
import os
import boto3
import pymysql
from boto3.dynamodb.conditions import Key

# ==========================================================
# AWS SECRETS MANAGER CONFIGURATION
# ==========================================================

SECRET_NAME = "CafeDevDBSM"
REGION_NAME = os.environ.get("AWS_REGION", "us-east-1")

secrets_client = boto3.client("secretsmanager", region_name=REGION_NAME)

def get_db_secret():
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])


# ==========================================================
# RDS CONNECTION (REUSED ACROSS INVOCATIONS)
# ==========================================================

connection = None

def get_rds_connection():
    global connection

    if connection is None or not connection.open:
        secret = get_db_secret()

        connection = pymysql.connect(
            host=secret["host"],
            user=secret["username"],
            password=secret["password"],
            database=secret["dbname"],
            cursorclass=pymysql.cursors.DictCursor,
            autocommit=True,
            connect_timeout=10
        )

    return connection


# ==========================================================
# DYNAMODB CONFIGURATION
# ==========================================================

DYNAMODB_TABLE = os.environ["DYNAMODB_TABLE"]
dynamodb = boto3.resource("dynamodb")
dynamo_table = dynamodb.Table(DYNAMODB_TABLE)


# ==========================================================
# STANDARD RESPONSE (CORS ENABLED)
# ==========================================================

def make_response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Methods": "GET,OPTIONS"
        },
        "body": json.dumps(body, default=str)
    }


# ==========================================================
# DATE FILTER HELPER
# ==========================================================

def build_date_filter(query_type):
    if query_type == "daily":
        return "a.date = CURDATE()"
    elif query_type == "weekly":
        return "a.date >= CURDATE() - INTERVAL 7 DAY"
    elif query_type == "monthly":
        return "MONTH(a.date) = MONTH(CURDATE()) AND YEAR(a.date) = YEAR(CURDATE())"
    else:
        return None


# ==========================================================
# MAIN LAMBDA HANDLER
# ==========================================================

def lambda_handler(event, context):

    # Handle CORS
    if event.get("httpMethod") == "OPTIONS":
        return make_response(200, {"message": "CORS preflight successful"})

    params = event.get("queryStringParameters") or {}

    query_type = params.get("type", "daily")
    employee_id = params.get("employee_id")
    lookup_date = params.get("date")
    include_summary = params.get("summary", "false").lower() == "true"

    result = {
        "attendance_rds": [],
        "attendance_dynamo": [],
        "summary": {}
    }

    # =====================================================
    # RDS ATTENDANCE QUERY
    # =====================================================

    try:
        conn = get_rds_connection()
        cursor = conn.cursor()

        date_filter = build_date_filter(query_type)

        if not date_filter:
            return make_response(400, {"message": "Invalid type parameter"})

        sql = f"""
            SELECT e.employee_id,
                   e.name,
                   a.date,
                   a.checkin_time,
                   a.checkout_time
            FROM attendance a
            JOIN employees e ON a.employee_id = e.employee_id
            WHERE {date_filter}
        """

        values = []

        if employee_id:
            sql += " AND e.employee_id = %s"
            values.append(employee_id)

        cursor.execute(sql, values)
        result["attendance_rds"] = cursor.fetchall()

        # =====================================================
        # SUMMARY (ALIGNED WITH TYPE)
        # =====================================================

        if include_summary:

            summary_sql = f"""
                SELECT
                    COUNT(DISTINCT CASE WHEN a.checkin_time IS NOT NULL THEN e.employee_id END) AS total_present,
                    COUNT(DISTINCT e.employee_id)
                    - COUNT(DISTINCT CASE WHEN a.checkin_time IS NOT NULL THEN e.employee_id END) AS total_absent,
                    (
                        SELECT COUNT(*)
                        FROM leaves
                        WHERE {date_filter.replace("a.date", "leave_date")}
                    ) AS total_leaves
                FROM employees e
                LEFT JOIN attendance a
                    ON e.employee_id = a.employee_id
                    AND {date_filter}
            """

            cursor.execute(summary_sql)
            result["summary"] = cursor.fetchone()

    except Exception as e:
        return make_response(500, {"error": f"RDS error: {str(e)}"})


    # =====================================================
    # OPTIONAL DYNAMODB LOOKUP
    # =====================================================

    if employee_id:
        try:
            if lookup_date:
                response = dynamo_table.query(
                    KeyConditionExpression=
                        Key("employee_id").eq(employee_id) &
                        Key("date").eq(lookup_date)
                )
            else:
                response = dynamo_table.query(
                    KeyConditionExpression=
                        Key("employee_id").eq(employee_id)
                )

            result["attendance_dynamo"] = response.get("Items", [])

        except Exception as e:
            return make_response(500, {"error": f"DynamoDB error: {str(e)}"})


    # =====================================================
    # FINAL RESPONSE
    # =====================================================

    return make_response(200, result)
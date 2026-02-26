import json
import os
import boto3
import pymysql
from datetime import date
from boto3.dynamodb.conditions import Key

# ==========================================================
# 🔐 AWS SECRETS MANAGER CONFIG
# ==========================================================

SECRET_NAME = "CafeDevDBSM"  # Your Secrets Manager name
REGION_NAME = os.environ.get("AWS_REGION", "us-east-1")

secrets_client = boto3.client("secretsmanager", region_name=REGION_NAME)

# ==========================================================
# 📦 DYNAMODB CONFIG
# ==========================================================

DYNAMODB_TABLE_NAME = os.environ.get("DYNAMODB_TABLE", "CafeAttendance")
dynamodb = boto3.resource("dynamodb")
dynamo_table = dynamodb.Table(DYNAMODB_TABLE_NAME)

# ==========================================================
# 🔑 FETCH DATABASE SECRET
# ==========================================================

def get_db_secret():
    """
    Expected Secret JSON format:
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
# 🔌 CREATE / REUSE RDS CONNECTION
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
# 🔐 ROLE CHECK (COGNITO GROUP)
# ==========================================================

def check_role(event, allowed_role):
    claims = event["requestContext"]["authorizer"]["claims"]
    groups = claims.get("cognito:groups", [])

    if isinstance(groups, str):
        groups = [groups]

    return allowed_role in groups

# ==========================================================
# 🌍 STANDARD API RESPONSE (CORS ENABLED)
# ==========================================================

def make_response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "Authorization,Content-Type",
            "Access-Control-Allow-Methods": "GET,OPTIONS"
        },
        "body": json.dumps(body, default=str)
    }

# ==========================================================
# 🚀 MAIN LAMBDA HANDLER
# ==========================================================

def lambda_handler(event, context):
    """
    Merged Admin Attendance Lambda

    Query Parameters:
      type: daily | weekly | monthly
      employee_id: optional filter
      date: DynamoDB date filter
      summary: true/false
    """

    # 🔐 ADMIN AUTHORIZATION
    if not check_role(event, "Admin"):
        return make_response(403, {"message": "Forbidden"})

    params = event.get("queryStringParameters") or {}
    query_type = params.get("type", "daily")
    employee_id = params.get("employee_id")
    lookup_date = params.get("date")
    summary_flag = params.get("summary", "false").lower() == "true"

    response_data = {
        "attendance_rds": [],
        "attendance_dynamo": [],
        "summary": {}
    }

    # =====================================================
    # 1️⃣ RDS ATTENDANCE QUERY
    # =====================================================

    try:
        conn = get_rds_connection()
        cursor = conn.cursor()

        if query_type == "daily":
            sql = """
                SELECT e.employee_id, e.name, a.date, a.checkin_time, a.checkout_time
                FROM attendance a
                JOIN employees e ON a.employee_id = e.employee_id
                WHERE a.date = CURDATE()
            """
        elif query_type == "weekly":
            sql = """
                SELECT e.employee_id, e.name, a.date, a.checkin_time, a.checkout_time
                FROM attendance a
                JOIN employees e ON a.employee_id = e.employee_id
                WHERE a.date >= CURDATE() - INTERVAL 7 DAY
            """
        elif query_type == "monthly":
            sql = """
                SELECT e.employee_id, e.name, a.date, a.checkin_time, a.checkout_time
                FROM attendance a
                JOIN employees e ON a.employee_id = e.employee_id
                WHERE MONTH(a.date) = MONTH(CURDATE())
                AND YEAR(a.date) = YEAR(CURDATE())
            """
        else:
            return make_response(400, {"message": "Invalid type parameter"})

        if employee_id:
            sql += " AND e.employee_id = %s"
            cursor.execute(sql, (employee_id,))
        else:
            cursor.execute(sql)

        response_data["attendance_rds"] = cursor.fetchall()

        # =====================================================
        # 2️⃣ RDS SUMMARY (OPTIONAL)
        # =====================================================
        if summary_flag:
            summary_sql = """
                SELECT
                    COUNT(DISTINCT CASE WHEN a.checkin_time IS NOT NULL AND a.date = CURDATE() THEN e.employee_id END) AS total_present,
                    COUNT(DISTINCT e.employee_id) - COUNT(DISTINCT CASE WHEN a.checkin_time IS NOT NULL AND a.date = CURDATE() THEN e.employee_id END) AS total_absent,
                    (SELECT COUNT(*) FROM leaves WHERE leave_date = CURDATE()) AS total_leaves
                FROM employees e
                LEFT JOIN attendance a ON e.employee_id = a.employee_id AND a.date = CURDATE()
            """
            cursor.execute(summary_sql)
            response_data["summary"] = cursor.fetchone()

    except Exception as e:
        return make_response(500, {"message": f"RDS error: {str(e)}"})

    # =====================================================
    # 3️⃣ DYNAMODB QUERY (OPTIONAL)
    # =====================================================

    if employee_id:
        try:
            if lookup_date:
                dynamo_response = dynamo_table.query(
                    KeyConditionExpression=Key("employee_id").eq(employee_id) &
                                           Key("date").eq(lookup_date)
                )
            else:
                dynamo_response = dynamo_table.query(
                    KeyConditionExpression=Key("employee_id").eq(employee_id)
                )

            response_data["attendance_dynamo"] = dynamo_response.get("Items", [])

        except Exception as e:
            return make_response(500, {"message": f"DynamoDB error: {str(e)}"})

    # =====================================================
    # 4️⃣ RETURN FINAL UNIFIED RESPONSE
    # =====================================================

    return make_response(200, response_data)
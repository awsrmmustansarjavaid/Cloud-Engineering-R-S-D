import json
import os
import boto3
import pymysql
from datetime import datetime, timedelta
from boto3.dynamodb.conditions import Key

# ==========================================================
# 🌐 CONFIGURATION
# ==========================================================

SECRET_NAME = "CafeDevDBSM"  # RDS Secret in AWS Secrets Manager
REGION_NAME = os.environ.get("AWS_REGION", "us-east-1")

# DynamoDB table name (optional, can be empty)
DYNAMODB_TABLE = os.environ.get("DYNAMODB_TABLE")

# AWS Clients
secrets_client = boto3.client("secretsmanager", region_name=REGION_NAME)

# DynamoDB (if table configured)
if DYNAMODB_TABLE:
    dynamodb = boto3.resource("dynamodb")
    dynamo_table = dynamodb.Table(DYNAMODB_TABLE)
else:
    dynamo_table = None

# ==========================================================
# 🔐 GET DB CREDENTIALS FROM SECRETS MANAGER
# ==========================================================

def get_db_secret():
    """Fetch RDS credentials from Secrets Manager"""
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])

# ==========================================================
# 🗄️ RDS CONNECTION (REUSE FOR PERFORMANCE)
# ==========================================================

connection = None

def get_rds_connection():
    """Return persistent RDS connection"""
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
# 🇵🇰 GET CURRENT DATE IN PAKISTAN TIME (UTC+5)
# ==========================================================

def get_pk_date():
    """Return current date in Pakistan timezone (YYYY-MM-DD)"""
    return (datetime.utcnow() + timedelta(hours=5)).strftime('%Y-%m-%d')

# ==========================================================
# 📅 DATE FILTER BUILDER (RDS attendance_date)
# ==========================================================

def build_date_filter(query_type):
    pk_date = get_pk_date()

    if query_type == "daily":
        return f"a.attendance_date = '{pk_date}'"

    elif query_type == "weekly":
        return f"a.attendance_date >= DATE('{pk_date}') - INTERVAL 7 DAY"

    elif query_type == "monthly":
        return f"""
        MONTH(a.attendance_date) = MONTH('{pk_date}')
        AND YEAR(a.attendance_date) = YEAR('{pk_date}')
        """

    else:
        return None

# ==========================================================
# 🌍 STANDARD RESPONSE (CORS ENABLED)
# ==========================================================

def make_response(status_code, body):
    """Return a standard CORS-enabled response"""
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
# 🚀 MAIN LAMBDA HANDLER
# ==========================================================

def lambda_handler(event, context):

    # ================= CORS PREFLIGHT =================
    if event.get("httpMethod") == "OPTIONS":
        return make_response(200, {"message": "CORS preflight successful"})

    # ================= INPUT PARAMETERS =================
    params = event.get("queryStringParameters") or {}

    query_type = params.get("type", "daily")         # daily / weekly / monthly
    employee_id = params.get("employee_id")         # optional filter
    lookup_date = params.get("date")                # optional date for DynamoDB
    include_summary = params.get("summary", "false").lower() == "true"

    # ================= RESPONSE STRUCTURE =================
    result = {
        "attendance_rds": [],
        "attendance_dynamo": [],
        "summary": {}
    }

    # =====================================================
    # 🗄️ RDS ATTENDANCE QUERY
    # =====================================================
    try:
        conn = get_rds_connection()
        cursor = conn.cursor()

        # Build date filter
        date_filter = build_date_filter(query_type)
        if not date_filter:
            return make_response(400, {"message": "Invalid type parameter"})

        # SQL query
        sql = f"""
            SELECT e.employee_id,
                   e.name,
                   a.attendance_date,
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
        # 📊 SUMMARY (OPTIONAL)
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
                        WHERE {date_filter.replace("a.attendance_date", "leave_date")}
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
    # ⚡ OPTIONAL DYNAMODB LOOKUP
    # =====================================================
    if employee_id and dynamo_table:
        try:
            if lookup_date:
                response = dynamo_table.query(
                    KeyConditionExpression=Key("employee_id").eq(employee_id) & Key("date").eq(lookup_date)
                )
            else:
                response = dynamo_table.query(
                    KeyConditionExpression=Key("employee_id").eq(employee_id)
                )
            result["attendance_dynamo"] = response.get("Items", [])
        except Exception as e:
            return make_response(500, {"error": f"DynamoDB error: {str(e)}"})

    # =====================================================
    # ✅ RETURN FINAL RESPONSE
    # =====================================================
    return make_response(200, result)
import json
import os
import pymysql

# =====================================================
# CONFIG: Database credentials from Lambda Environment
# =====================================================
DB_HOST = os.environ['DB_HOST']
DB_USER = os.environ['DB_USER']
DB_PASS = os.environ['DB_PASS']
DB_NAME = os.environ['DB_NAME']

# =====================================================
# DATABASE CONNECTION
# =====================================================
def get_connection():
    return pymysql.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASS,
        db=DB_NAME,
        cursorclass=pymysql.cursors.DictCursor
    )

# =====================================================
# MAIN LAMBDA HANDLER
# =====================================================
def lambda_handler(event, context):
    """
    Single Lambda handling:
    - Cognito role-based access (admin / employee)
    - Order status dashboard (metrics + recent orders)
    """

    conn = None
    cursor = None

    try:
        # -------------------------------------------------
        # 1️⃣ READ COGNITO CLAIMS (FROM API GATEWAY)
        # -------------------------------------------------
        claims = event["requestContext"]["authorizer"]["claims"]

        username = claims.get("cognito:username")
        groups = claims.get("cognito:groups", "")

        # Cognito may return groups as string
        if isinstance(groups, str):
            groups = groups.split(",")

        is_admin = "admin" in groups
        is_employee = "employee" in groups

        # -------------------------------------------------
        # 2️⃣ IDENTIFY REQUESTED PATH
        # -------------------------------------------------
        path = event.get("path", "")

        # -------------------------------------------------
        # 3️⃣ ROLE-BASED ACCESS CONTROL
        # -------------------------------------------------
        # Order status dashboard → ADMIN ONLY
        if path.startswith("/order-status"):
            if not is_admin:
                return forbidden("Admin access only")

        # (Example future endpoint)
        if path.startswith("/employee"):
            if not (is_admin or is_employee):
                return forbidden("Employee access only")

        # -------------------------------------------------
        # 4️⃣ READ QUERY PARAMETERS
        # -------------------------------------------------
        params = event.get("queryStringParameters") or {}
        filter_date = params.get("date")

        # -------------------------------------------------
        # 5️⃣ DATABASE OPERATIONS
        # -------------------------------------------------
        conn = get_connection()
        cursor = conn.cursor()

        # ---------- RECENT ORDERS ----------
        sql = "SELECT customer_name, item, quantity, created_at FROM orders"
        values = []

        if filter_date:
            sql += " WHERE DATE(created_at) = %s"
            values.append(filter_date)

        sql += " ORDER BY created_at DESC LIMIT 20"
        cursor.execute(sql, values)
        recent_orders = cursor.fetchall()

        # ---------- METRICS ----------
        metrics = []

        where_clause = ""
        metric_values = []

        if filter_date:
            where_clause = " WHERE DATE(created_at) = %s"
            metric_values.append(filter_date)

        cursor.execute(
            f"SELECT COUNT(*) AS count FROM orders{where_clause}",
            metric_values
        )
        metrics.append({
            "metric": "Total Orders",
            "count": cursor.fetchone()['count']
        })

        cursor.execute(
            f"SELECT SUM(quantity) AS count FROM orders{where_clause}",
            metric_values
        )
        metrics.append({
            "metric": "Total Items Sold",
            "count": cursor.fetchone()['count'] or 0
        })

        cursor.execute(
            f"SELECT COUNT(DISTINCT customer_name) AS count FROM orders{where_clause}",
            metric_values
        )
        metrics.append({
            "metric": "Customers",
            "count": cursor.fetchone()['count']
        })

        # -------------------------------------------------
        # 6️⃣ SUCCESS RESPONSE
        # -------------------------------------------------
        return success_response({
            "user": username,
            "role": "admin" if is_admin else "employee",
            "metrics": metrics,
            "recent_orders": recent_orders
        })

    except Exception as e:
        return error_response(str(e))

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()

# =====================================================
# RESPONSE HELPERS
# =====================================================
def success_response(data):
    return {
        "statusCode": 200,
        "headers": cors_headers(),
        "body": json.dumps(data, default=str)
    }

def forbidden(message):
    return {
        "statusCode": 403,
        "headers": cors_headers(),
        "body": json.dumps({"error": message})
    }

def error_response(error):
    return {
        "statusCode": 500,
        "headers": cors_headers(),
        "body": json.dumps({"error": error})
    }

def cors_headers():
    return {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "Authorization",
        "Access-Control-Allow-Methods": "GET"
    }
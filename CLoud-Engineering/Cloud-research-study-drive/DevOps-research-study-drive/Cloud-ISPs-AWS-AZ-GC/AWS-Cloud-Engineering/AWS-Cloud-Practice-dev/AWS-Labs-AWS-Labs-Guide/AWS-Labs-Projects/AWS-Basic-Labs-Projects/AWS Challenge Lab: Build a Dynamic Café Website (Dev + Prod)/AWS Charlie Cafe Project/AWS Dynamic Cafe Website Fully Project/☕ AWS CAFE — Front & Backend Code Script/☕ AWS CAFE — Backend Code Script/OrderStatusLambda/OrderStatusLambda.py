import json
import boto3
import pymysql

# ==========================================================
# AWS CLIENT
# ==========================================================
secrets_client = boto3.client('secretsmanager')

# ==========================================================
# SECRET CONFIGURATION
# ==========================================================
SECRET_NAME = "CafeDevDBSM"  # Same secret used in CafeOrderProcessor

# ==========================================================
# GET DB CREDENTIALS FROM SECRETS MANAGER
# ==========================================================
def get_db_secret():
    """
    Retrieve RDS credentials securely from AWS Secrets Manager
    """
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])

# ==========================================================
# CREATE DATABASE CONNECTION
# ==========================================================
def get_connection():
    """
    Create secure MySQL connection using secret credentials
    """
    secret = get_db_secret()

    return pymysql.connect(
        host=secret["host"],
        user=secret["username"],
        password=secret["password"],
        database=secret["dbname"],
        cursorclass=pymysql.cursors.DictCursor,
        connect_timeout=10
    )

# ==========================================================
# LAMBDA HANDLER
# ==========================================================
def lambda_handler(event, context):

    conn = None
    cursor = None

    try:
        # --------------------------------------------------
        # 1️⃣ Read Query Parameters
        # --------------------------------------------------
        params = event.get("queryStringParameters") or {}
        filter_date = params.get("date")  # Format: YYYY-MM-DD

        # --------------------------------------------------
        # 2️⃣ Connect to Database
        # --------------------------------------------------
        conn = get_connection()
        cursor = conn.cursor()

        # --------------------------------------------------
        # 3️⃣ Fetch Recent Orders (Optional Date Filter)
        # --------------------------------------------------
        sql = "SELECT customer_name, item, quantity, created_at FROM orders"
        values = []

        if filter_date:
            sql += " WHERE DATE(created_at) = %s"
            values.append(filter_date)

        sql += " ORDER BY created_at DESC LIMIT 20"

        cursor.execute(sql, values)
        recent_orders = cursor.fetchall()

        # --------------------------------------------------
        # 4️⃣ Build Date-Aware Metrics
        # --------------------------------------------------
        where_clause = ""
        metric_values = []

        if filter_date:
            where_clause = " WHERE DATE(created_at) = %s"
            metric_values.append(filter_date)

        metrics = []

        # ---- Total Orders
        cursor.execute(
            f"SELECT COUNT(*) AS count FROM orders{where_clause}",
            metric_values
        )
        metrics.append({
            "metric": "Total Orders",
            "count": cursor.fetchone()["count"]
        })

        # ---- Total Items Sold
        cursor.execute(
            f"SELECT SUM(quantity) AS count FROM orders{where_clause}",
            metric_values
        )
        metrics.append({
            "metric": "Total Items Sold",
            "count": cursor.fetchone()["count"] or 0
        })

        # ---- Unique Customers
        cursor.execute(
            f"SELECT COUNT(DISTINCT customer_name) AS count FROM orders{where_clause}",
            metric_values
        )
        metrics.append({
            "metric": "Customers",
            "count": cursor.fetchone()["count"]
        })

        # --------------------------------------------------
        # 5️⃣ Success Response
        # --------------------------------------------------
        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "Authorization",
                "Access-Control-Allow-Methods": "GET"
            },
            "body": json.dumps({
                "filter_date": filter_date,
                "metrics": metrics,
                "recent_orders": recent_orders
            }, default=str)
        }

    except Exception as e:
        print("❌ ERROR:", str(e))
        return {
            "statusCode": 500,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({"error": str(e)})
        }

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()
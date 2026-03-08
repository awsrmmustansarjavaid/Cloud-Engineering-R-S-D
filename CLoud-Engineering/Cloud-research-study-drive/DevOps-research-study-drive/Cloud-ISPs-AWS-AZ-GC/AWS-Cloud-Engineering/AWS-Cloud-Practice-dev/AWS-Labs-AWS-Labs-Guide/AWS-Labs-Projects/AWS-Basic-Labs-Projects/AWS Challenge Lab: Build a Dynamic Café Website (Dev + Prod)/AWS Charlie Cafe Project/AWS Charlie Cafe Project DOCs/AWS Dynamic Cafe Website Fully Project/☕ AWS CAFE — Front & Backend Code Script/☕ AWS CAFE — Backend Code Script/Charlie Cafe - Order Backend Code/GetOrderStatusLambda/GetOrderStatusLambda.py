import json
import boto3
import pymysql

# ============================================================
# CHARLIE CAFE - GET ORDER STATUS LAMBDA
# ------------------------------------------------------------
# This Lambda:
# 1️⃣ Retrieves DB credentials from AWS Secrets Manager
# 2️⃣ Connects to RDS MySQL
# 3️⃣ Fetches last 20 orders (including payment_status!)
# 4️⃣ Reads metrics from DynamoDB
# 5️⃣ Returns combined response to API Gateway
# ============================================================

# ---------------- AWS CLIENTS ----------------
secrets_client = boto3.client('secretsmanager')
dynamodb = boto3.resource('dynamodb')

# ---------------- CONSTANTS ----------------
SECRET_NAME = "CafeDevDBSM"          # Secret in AWS Secrets Manager
METRICS_TABLE = "CafeOrderMetrics"  # DynamoDB metrics table

# DynamoDB table reference
metrics_table = dynamodb.Table(METRICS_TABLE)

# ============================================================
# FUNCTION: Get Database Credentials from Secrets Manager
# ============================================================
def get_db_secret():
    """
    Fetch RDS credentials from AWS Secrets Manager.
    Returns:
        dict: {host, username, password, dbname}
    """
    response = secrets_client.get_secret_value(
        SecretId=SECRET_NAME
    )
    return json.loads(response["SecretString"])


# ============================================================
# MAIN LAMBDA HANDLER
# ============================================================
def lambda_handler(event, context):

    connection = None

    try:
        # ---------------- 1️⃣ Get DB Credentials ----------------
        secret = get_db_secret()

        # ---------------- 2️⃣ Connect to RDS ----------------
        connection = pymysql.connect(
            host=secret["host"],
            user=secret["username"],
            password=secret["password"],
            database=secret["dbname"],
            connect_timeout=5,
            cursorclass=pymysql.cursors.DictCursor
        )

        # ---------------- 3️⃣ Fetch Metrics from DynamoDB ----------------
        metrics = metrics_table.scan().get("Items", [])

        # ---------------- 4️⃣ Fetch Last 20 Orders from RDS ----------------
        # NOTE: Added `payment_status` to fix Mark Paid button issue
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT
                    order_id,
                    table_number,
                    customer_name,
                    item,
                    quantity,
                    total_amount,
                    status,
                    payment_method,
                    payment_status,  -- ✅ crucial for frontend
                    created_at
                FROM orders
                ORDER BY created_at DESC
                LIMIT 20
            """)
            orders = cursor.fetchall()

        # ---------------- 5️⃣ Return Success Response ----------------
        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Content-Type": "application/json"
            },
            "body": json.dumps({
                "orders": orders,
                "metrics": metrics
            }, default=str)
        }

    except Exception as e:
        print("❌ ERROR:", str(e))
        return {
            "statusCode": 500,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": str(e)})
        }

    finally:
        # ---------------- 6️⃣ Close DB Connection Safely ----------------
        if connection:
            connection.close()
import json
import boto3
import pymysql

# ==========================================================
# AWS CLIENT
# ==========================================================
secrets_client = boto3.client('secretsmanager')

# ==========================================================
# SECRET CONFIG
# ==========================================================
SECRET_NAME = "CafeDevDBSM"  # Same secret used in CafeOrderProcessor

# ==========================================================
# VALID ORDER STATUS FLOW
# ==========================================================
# Defines allowed status transitions
VALID_FLOW = {
    "RECEIVED": "PREPARING",
    "PREPARING": "READY",
    "READY": "COMPLETED"
}

# ==========================================================
# GET DB CREDENTIALS FROM SECRETS MANAGER
# ==========================================================
def get_db_secret():
    """
    Retrieve database credentials securely from AWS Secrets Manager
    """
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])

# ==========================================================
# STANDARD RESPONSE FORMAT
# ==========================================================
def response(status_code, body):
    """
    Standardized API response format with CORS support
    """
    return {
        "statusCode": status_code,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Content-Type": "application/json"
        },
        "body": json.dumps(body)
    }

# ==========================================================
# LAMBDA HANDLER
# ==========================================================
def lambda_handler(event, context):
    try:
        # --------------------------------------------------
        # 1️⃣ Parse Request Body
        # --------------------------------------------------
        body = json.loads(event.get("body", "{}"))

        if "order_id" not in body or "status" not in body:
            return response(400, {"error": "order_id and status are required"})

        order_id = body["order_id"]
        new_status = body["status"]

        # --------------------------------------------------
        # 2️⃣ Get Database Credentials Securely
        # --------------------------------------------------
        secret = get_db_secret()

        connection = pymysql.connect(
            host=secret["host"],
            user=secret["username"],
            password=secret["password"],
            database=secret["dbname"],
            cursorclass=pymysql.cursors.DictCursor,
            connect_timeout=10,
            autocommit=False
        )

        with connection.cursor() as cursor:

            # --------------------------------------------------
            # 3️⃣ Fetch Current Order Status
            # --------------------------------------------------
            cursor.execute(
                "SELECT status FROM orders WHERE order_id = %s",
                (order_id,)
            )
            order = cursor.fetchone()

            if not order:
                return response(404, {"error": "Order not found"})

            current_status = order["status"]

            # --------------------------------------------------
            # 4️⃣ Validate Status Transition
            # --------------------------------------------------
            if VALID_FLOW.get(current_status) != new_status:
                return response(400, {
                    "error": "Invalid status transition",
                    "current_status": current_status,
                    "allowed_next_status": VALID_FLOW.get(current_status)
                })

            # --------------------------------------------------
            # 5️⃣ Update Order Status
            # --------------------------------------------------
            cursor.execute(
                "UPDATE orders SET status = %s WHERE order_id = %s",
                (new_status, order_id)
            )

        connection.commit()
        connection.close()

        # --------------------------------------------------
        # 6️⃣ Success Response
        # --------------------------------------------------
        return response(200, {
            "order_id": order_id,
            "previous_status": current_status,
            "new_status": new_status,
            "message": "Order status updated successfully"
        })

    except Exception as e:
        print("❌ ERROR:", str(e))
        return response(500, {"error": str(e)})
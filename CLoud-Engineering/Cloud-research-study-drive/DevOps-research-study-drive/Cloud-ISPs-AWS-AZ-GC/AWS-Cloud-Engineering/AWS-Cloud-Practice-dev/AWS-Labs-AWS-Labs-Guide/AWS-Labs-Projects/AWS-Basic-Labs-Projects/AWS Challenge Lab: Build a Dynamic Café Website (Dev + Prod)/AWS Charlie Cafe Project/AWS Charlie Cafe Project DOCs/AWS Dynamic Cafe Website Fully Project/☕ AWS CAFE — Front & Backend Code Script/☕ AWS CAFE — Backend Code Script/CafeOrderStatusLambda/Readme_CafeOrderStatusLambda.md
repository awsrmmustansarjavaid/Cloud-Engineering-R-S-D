# Charlie Cafe -- CafeOrderStatusLambda

### CafeOrderStatusLambda.py

> **Update Version:1.0**

```
import json
import os
import pymysql

def get_connection():
    return pymysql.connect(
        host=os.environ["DB_HOST"],
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASS"],
        database=os.environ["DB_NAME"],
        cursorclass=pymysql.cursors.DictCursor
    )

def lambda_handler(event, context):
    params = event.get("queryStringParameters") or {}
    order_id = params.get("order_id")

    if not order_id:
        return {
            "statusCode": 400,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": "order_id required"})
        }

    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute("""
            SELECT table_number, customer_name, item, quantity, created_at
            FROM orders
            ORDER BY created_at DESC
            LIMIT 1
        """)
        order = cursor.fetchone()

        if not order:
            return {
                "statusCode": 404,
                "headers": {"Access-Control-Allow-Origin": "*"},
                "body": json.dumps({"status": "NOT FOUND"})
            }

        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Content-Type": "application/json"
            },
            "body": json.dumps({
                "order_id": order_id,
                "status": "RECEIVED",
                "order": order
            }, default=str)
        }

    finally:
        cursor.close()
        conn.close()
```

### ✅ ADD DB ENV VARIABLES

- Lambda → Configuration → Environment variables → Edit

#### Add:

```
DB_HOST = your-rds-endpoint
DB_USER = cafe_user
DB_PASS = password
DB_NAME = cafe_db
```

- Click Save


---
### CafeOrderStatusLambda.py

> **Update Version:1.1**

- Use AWS Secrets Manager instead of environment variables for the RDS credentials.

- Follow the same pattern as CafeOrderProcessor (secure, no hardcoded DB credentials).

- Keep its functionality (fetch the latest order by order_id or most recent if no order_id is passed).

- Keep it simple without adding extra env variables.

#### ✅ Here’s the fully final code:

```
import json
import boto3
import pymysql
from datetime import datetime

# ==========================================================
# AWS CLIENTS
# ==========================================================
secrets_client = boto3.client('secretsmanager')

# ==========================================================
# SECRET CONFIG
# ==========================================================
SECRET_NAME = "CafeDevDBSM"  # Your Secrets Manager name

# ==========================================================
# GET DB CREDENTIALS FROM SECRETS MANAGER
# ==========================================================
def get_db_secret():
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])

# ==========================================================
# STANDARD RESPONSE FORMAT
# ==========================================================
def response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Content-Type": "application/json"
        },
        "body": json.dumps(body, default=str)
    }

# ==========================================================
# LAMBDA HANDLER
# ==========================================================
def lambda_handler(event, context):
    try:
        # --------------------------------------------------
        # 1️⃣ Get Query Params
        # --------------------------------------------------
        params = event.get("queryStringParameters") or {}
        order_id = params.get("order_id")

        # --------------------------------------------------
        # 2️⃣ Connect to RDS
        # --------------------------------------------------
        secret = get_db_secret()
        connection = pymysql.connect(
            host=secret["host"],
            user=secret["username"],
            password=secret["password"],
            database=secret["dbname"],
            cursorclass=pymysql.cursors.DictCursor,
            connect_timeout=10
        )

        with connection.cursor() as cursor:
            # --------------------------------------------------
            # 3️⃣ Fetch Latest Order (or by order_id if provided)
            # --------------------------------------------------
            if order_id:
                cursor.execute("""
                    SELECT order_id, table_number, customer_name, item, quantity, total_amount, status, created_at
                    FROM orders
                    WHERE order_id = %s
                    ORDER BY created_at DESC
                    LIMIT 1
                """, (order_id,))
            else:
                cursor.execute("""
                    SELECT order_id, table_number, customer_name, item, quantity, total_amount, status, created_at
                    FROM orders
                    ORDER BY created_at DESC
                    LIMIT 1
                """)

            order = cursor.fetchone()

        connection.close()

        # --------------------------------------------------
        # 4️⃣ Handle Not Found
        # --------------------------------------------------
        if not order:
            return response(404, {"status": "NOT FOUND", "order_id": order_id})

        # --------------------------------------------------
        # 5️⃣ Return Order Details
        # --------------------------------------------------
        return response(200, {
            "order_id": order.get("order_id"),
            "status": order.get("status", "RECEIVED"),
            "order": order
        })

    except Exception as e:
        print("❌ ERROR:", str(e))
        return response(500, {"error": str(e)})
```

### ✅ Key Updates:

- No environment variables for DB credentials — everything comes from Secrets Manager.

- Returns latest order if order_id is not provided.

- Uses standard JSON response format with proper CORS headers.

- Safe connection handling with with and proper closure.

---


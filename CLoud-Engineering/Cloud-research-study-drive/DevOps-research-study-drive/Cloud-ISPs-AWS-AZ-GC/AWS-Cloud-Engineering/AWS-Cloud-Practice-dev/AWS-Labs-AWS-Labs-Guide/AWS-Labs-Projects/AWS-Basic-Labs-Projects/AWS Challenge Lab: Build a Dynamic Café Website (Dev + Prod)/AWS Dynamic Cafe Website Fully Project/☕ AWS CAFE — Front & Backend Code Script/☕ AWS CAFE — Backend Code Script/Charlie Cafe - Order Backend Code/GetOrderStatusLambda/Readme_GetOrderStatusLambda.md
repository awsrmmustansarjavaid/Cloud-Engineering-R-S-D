# Charlie Cafe - GetOrderStatusLambda

### GetOrderStatusLambda.py

> **Update Version:1.0**

```
import json
import boto3
import pymysql

# ---------- AWS CLIENTS ----------
secrets_client = boto3.client('secretsmanager')
dynamodb = boto3.resource('dynamodb')

# ---------- CONSTANTS ----------
SECRET_NAME = "CafeDevDBSM"
METRICS_TABLE = "CafeOrderMetrics"

metrics_table = dynamodb.Table(METRICS_TABLE)

# ---------- GET DB CREDS ----------
def get_db_secret():
    return json.loads(
        secrets_client.get_secret_value(
            SecretId=SECRET_NAME
        )["SecretString"]
    )

# ---------- LAMBDA HANDLER ----------
def lambda_handler(event, context):

    # ---- Fetch DB credentials ----
    secret = get_db_secret()

    # ---- Connect to RDS ----
    connection = pymysql.connect(
        host=secret["host"],
        user=secret["username"],
        password=secret["password"],
        database=secret["dbname"],
        connect_timeout=5,
        cursorclass=pymysql.cursors.DictCursor
    )

    try:
        # ---- Read metrics from DynamoDB ----
        metrics = metrics_table.scan().get("Items", [])

        # ---- Read recent orders from RDS ----
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT
                    table_number,
                    customer_name,
                    item,
                    quantity,
                    created_at
                FROM orders
                ORDER BY created_at DESC
                LIMIT 20
            """)
            orders = cursor.fetchall()

        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Content-Type": "application/json"
            },
            "body": json.dumps(
                {
                    "metrics": metrics,
                    "recent_orders": orders
                },
                default=str
            )
        }

    except Exception as e:
        print("❌ ERROR:", str(e))
        return {
            "statusCode": 500,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": str(e)})
        }

    finally:
        connection.close()
```

---
### GetOrderStatusLambda.py

> **Update Version:1.1**

fully aligned, clean, final production-ready GetOrderStatusLambda code for:

This version:

✅ Fixes response key mismatch (orders)

✅ Includes all required SQL fields

✅ Handles Lambda Proxy Integration properly

✅ Adds safe error handling

✅ Handles connection cleanup safely

✅ Includes clear comments for lab submission

### ✅ FINAL VERSION — GetOrderStatusLambda

```
import json
import boto3
import pymysql

# ============================================================
# CHARLIE CAFE - GET ORDER STATUS LAMBDA
# ------------------------------------------------------------
# This Lambda:
# 1. Retrieves DB credentials from AWS Secrets Manager
# 2. Connects to RDS MySQL
# 3. Fetches last 20 orders
# 4. Reads metrics from DynamoDB
# 5. Returns combined response to API Gateway
# ============================================================


# ---------------- AWS CLIENTS ----------------
secrets_client = boto3.client('secretsmanager')
dynamodb = boto3.resource('dynamodb')


# ---------------- CONSTANTS ----------------
SECRET_NAME = "CafeDevDBSM"          # Name of secret in AWS Secrets Manager
METRICS_TABLE = "CafeOrderMetrics"  # DynamoDB table name


# DynamoDB table reference
metrics_table = dynamodb.Table(METRICS_TABLE)


# ============================================================
# FUNCTION: Get Database Credentials from Secrets Manager
# ============================================================
def get_db_secret():
    """
    Fetches RDS credentials from AWS Secrets Manager.
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
        # ------------------------------------------------------
        # 1️⃣ Get Database Credentials
        # ------------------------------------------------------
        secret = get_db_secret()

        # ------------------------------------------------------
        # 2️⃣ Connect to RDS MySQL
        # ------------------------------------------------------
        connection = pymysql.connect(
            host=secret["host"],
            user=secret["username"],
            password=secret["password"],
            database=secret["dbname"],
            connect_timeout=5,
            cursorclass=pymysql.cursors.DictCursor
        )

        # ------------------------------------------------------
        # 3️⃣ Fetch Order Metrics from DynamoDB
        # ------------------------------------------------------
        metrics = metrics_table.scan().get("Items", [])

        # ------------------------------------------------------
        # 4️⃣ Fetch Recent Orders from RDS
        # ------------------------------------------------------
        with connection.cursor() as cursor:
            cursor.execute("""
                SELECT
                    order_id,
                    table_number,
                    customer_name,
                    item,
                    quantity,
                    total,
                    status,
                    payment_method,
                    created_at
                FROM orders
                ORDER BY created_at DESC
                LIMIT 20
            """)

            orders = cursor.fetchall()

        # ------------------------------------------------------
        # 5️⃣ Return Success Response (Lambda Proxy Format)
        # ------------------------------------------------------
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
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Content-Type": "application/json"
            },
            "body": json.dumps({
                "error": str(e)
            })
        }

    finally:
        # ------------------------------------------------------
        # 6️⃣ Always Close DB Connection Safely
        # ------------------------------------------------------
        if connection:
            connection.close()
```

### 🎯 After This

You now have:

✅ Secrets Manager integration

✅ RDS MySQL integration

✅ DynamoDB integration

✅ Proper Lambda Proxy response

✅ Fully aligned frontend

✅ Correct CORS handling

✅ Clean production-structured code

---
### GetOrderStatusLambda.py

> **Update Version:1.2**

```
import json
import boto3
import pymysql

# ============================================================
# CHARLIE CAFE - GET ORDER STATUS LAMBDA
# ------------------------------------------------------------
# This Lambda:
# 1. Retrieves DB credentials from AWS Secrets Manager
# 2. Connects to RDS MySQL
# 3. Fetches last 20 orders
# 4. Reads metrics from DynamoDB
# 5. Returns combined response to API Gateway
# ============================================================

# ---------------- AWS CLIENTS ----------------
secrets_client = boto3.client('secretsmanager')
dynamodb = boto3.resource('dynamodb')

# ---------------- CONSTANTS ----------------
SECRET_NAME = "CafeDevDBSM"          # Name of secret in AWS Secrets Manager
METRICS_TABLE = "CafeOrderMetrics"  # DynamoDB table name

# DynamoDB table reference
metrics_table = dynamodb.Table(METRICS_TABLE)

# ============================================================
# FUNCTION: Get Database Credentials from Secrets Manager
# ============================================================
def get_db_secret():
    """
    Fetches RDS credentials from AWS Secrets Manager.
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
```

### GetOrderStatusLambda.py

> **Update Version:1.3**

you must update GetOrderStatusLambda to include the payment_status field in the SQL query. Without it, the frontend will never see PENDING and the Mark Paid button will not appear.

#### Here’s the fully final and corrected GetOrderStatusLambda code with detailed comments for your Charlie Café project:


```
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
```

### ✅ Key Fixes

Added payment_status in SQL SELECT.

Frontend mapping now sees payment_status: "PENDING" for cash orders → Mark Paid button will display.

Everything else remains unchanged.

Once you deploy this Lambda and call GET /get-order-status, the JSON should now include:

```
{
  "order_id": "ORD-20260302-5056",
  "table_number": 5,
  "customer_name": "John Doe",
  "item": "Cappuccino",
  "quantity": 2,
  "total_amount": 8.0,
  "status": "RECEIVED",
  "payment_method": "CASH",
  "payment_status": "PENDING",
  "created_at": "2026-03-02 19:00:00"
}
```

After that, your existing frontend code in admin-orders.html will finally show the Mark Paid button correctly.

---


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


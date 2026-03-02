# Charlie Cafe -- AdminMarkPaidLambda

### AdminMarkPaidLambda.py

> **Update Version:1.0**

```
# ===========================================
# AdminMarkPaidLambda
# Purpose:
# - Used by ADMIN only
# - Marks CASH orders as PAID
# ===========================================

import json
import boto3

# Connect to DynamoDB
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('CafeOrders')

def lambda_handler(event, context):
    """
    Expected request body:
    {
        "order_id": "ORD-123456"
    }
    """

    try:
        # -----------------------------
        # Parse incoming request
        # -----------------------------
        body = json.loads(event['body'])
        order_id = body['order_id']

        # -----------------------------
        # Update payment status to PAID
        # -----------------------------
        table.update_item(
            Key={'order_id': order_id},
            UpdateExpression="SET payment_status = :ps",
            ExpressionAttributeValues={
                ':ps': 'PAID'
            }
        )

        # -----------------------------
        # Success response
        # -----------------------------
        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({
                "success": True,
                "message": "Order marked as PAID"
            })
        }

    except Exception as e:
        # -----------------------------
        # Error handling
        # -----------------------------
        return {
            "statusCode": 500,
            "headers": {
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({
                "success": False,
                "error": str(e)
            })
        }
```

---

### AdminMarkPaidLambda.py

> **Update Version:1.1**

we can absolutely make your MarkCashOrderPaidLambda update both DynamoDB and MySQL at the same time. That way:

DynamoDB stays in sync (if other parts of your system use it)

MySQL stays updated (so GetOrderStatusLambda shows the latest payment_status)

#### Here’s a fully updated version with comments:

```
# ===========================================
# AdminMarkPaidLambda (MySQL + DynamoDB)
# Purpose:
# - Used by ADMIN only
# - Marks CASH orders as PAID in both DynamoDB and MySQL
# ===========================================

import json
import boto3
import pymysql
import os

# -----------------------------
# DynamoDB setup
# -----------------------------
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('CafeOrders')

# -----------------------------
# MySQL setup
# Replace with your actual RDS/MySQL credentials
# -----------------------------
MYSQL_HOST = os.environ.get('MYSQL_HOST', 'your-mysql-host')
MYSQL_USER = os.environ.get('MYSQL_USER', 'your-mysql-user')
MYSQL_PASSWORD = os.environ.get('MYSQL_PASSWORD', 'your-mysql-password')
MYSQL_DB = os.environ.get('MYSQL_DB', 'your-mysql-database')

def lambda_handler(event, context):
    """
    Expected request body:
    {
        "order_id": "ORD-123456"
    }
    """
    try:
        # -----------------------------
        # Parse incoming request
        # -----------------------------
        body = json.loads(event['body'])
        order_id = body['order_id']

        # -----------------------------
        # Update DynamoDB payment_status
        # -----------------------------
        table.update_item(
            Key={'order_id': order_id},
            UpdateExpression="SET payment_status = :ps",
            ExpressionAttributeValues={
                ':ps': 'PAID'
            }
        )

        # -----------------------------
        # Update MySQL payment_status
        # -----------------------------
        connection = pymysql.connect(
            host=MYSQL_HOST,
            user=MYSQL_USER,
            password=MYSQL_PASSWORD,
            database=MYSQL_DB,
            cursorclass=pymysql.cursors.DictCursor
        )

        try:
            with connection.cursor() as cursor:
                sql = "UPDATE orders SET payment_status=%s WHERE order_id=%s"
                cursor.execute(sql, ('PAID', order_id))
            connection.commit()
        finally:
            connection.close()

        # -----------------------------
        # Success response
        # -----------------------------
        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Content-Type": "application/json"
            },
            "body": json.dumps({
                "success": True,
                "message": f"Order {order_id} marked as PAID in DynamoDB & MySQL"
            })
        }

    except Exception as e:
        # -----------------------------
        # Error handling
        # -----------------------------
        return {
            "statusCode": 500,
            "headers": {
                "Access-Control-Allow-Origin": "*",
                "Content-Type": "application/json"
            },
            "body": json.dumps({
                "success": False,
                "error": str(e)
            })
        }
```

### ✅ Key Points

DynamoDB update: stays the same as before.

MySQL update:

Connects to your MySQL database.

Updates payment_status in the orders table.

Commits the change.

Environment variables:

MYSQL_HOST, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DB

Use Lambda environment variables for security instead of hardcoding credentials.

Error handling: If either DynamoDB or MySQL fails, Lambda returns an error.

Response: Confirms both databases were updated.
----
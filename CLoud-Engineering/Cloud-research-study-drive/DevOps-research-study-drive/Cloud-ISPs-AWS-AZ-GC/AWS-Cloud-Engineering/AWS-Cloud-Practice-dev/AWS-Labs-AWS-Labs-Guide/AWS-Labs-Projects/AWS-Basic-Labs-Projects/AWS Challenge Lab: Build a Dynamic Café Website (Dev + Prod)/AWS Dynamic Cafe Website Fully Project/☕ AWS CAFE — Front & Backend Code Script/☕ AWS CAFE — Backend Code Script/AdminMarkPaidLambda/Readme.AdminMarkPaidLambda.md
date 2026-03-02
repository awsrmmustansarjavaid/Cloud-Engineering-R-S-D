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
from decimal import Decimal
from datetime import datetime
import os

# -----------------------------
# DynamoDB setup
# -----------------------------
dynamodb = boto3.resource('dynamodb')
dynamo_table = dynamodb.Table('CafeOrders')

# -----------------------------
# Secrets Manager
# -----------------------------
SECRETS_NAME = os.environ.get('SECRET_NAME', 'CafeDevDBSM')
secrets_client = boto3.client('secretsmanager')

def get_db_secret():
    """Fetch DB credentials from Secrets Manager"""
    secret = secrets_client.get_secret_value(SecretId=SECRETS_NAME)
    return json.loads(secret['SecretString'])

def lambda_handler(event, context):
    """
    Expects:
    {
        "order_id": "ORD-123456"
    }
    """
    try:
        body = json.loads(event['body'])
        order_id = body['order_id']

        # -----------------------------
        # 1️⃣ Update DynamoDB
        # -----------------------------
        dynamo_table.update_item(
            Key={'order_id': order_id},
            UpdateExpression="SET payment_status = :ps",
            ExpressionAttributeValues={':ps': 'PAID'}
        )

        # -----------------------------
        # 2️⃣ Update MySQL
        # -----------------------------
        secret = get_db_secret()
        connection = pymysql.connect(
            host=secret['host'],
            user=secret['username'],
            password=secret['password'],
            database=secret['dbname'],
            cursorclass=pymysql.cursors.DictCursor,
            connect_timeout=10
        )

        try:
            with connection.cursor() as cursor:
                sql = "UPDATE orders SET payment_status=%s WHERE order_id=%s"
                cursor.execute(sql, ('PAID', order_id))
            connection.commit()
        finally:
            connection.close()

        # -----------------------------
        # 3️⃣ Return success
        # -----------------------------
        return {
            "statusCode": 200,
            "headers": {"Access-Control-Allow-Origin": "*", "Content-Type": "application/json"},
            "body": json.dumps({"success": True, "message": f"Order {order_id} marked as PAID in DynamoDB & MySQL"})
        }

    except Exception as e:
        # -----------------------------
        # 4️⃣ Error handling
        # -----------------------------
        return {
            "statusCode": 500,
            "headers": {"Access-Control-Allow-Origin": "*", "Content-Type": "application/json"},
            "body": json.dumps({"success": False, "error": str(e)})
        }
```

### ✅ Key Fixes

Secrets Manager used: Fetches MySQL credentials dynamically (CafeDevDBSM), just like your CafeOrderProcessor.

Removed hardcoded MySQL host/user/password → no more connection failure.

DynamoDB update remains unchanged.

Error handling will now show a real error if MySQL fails.

Connect timeout added to prevent hanging.

### 🔹 Next Steps

Go to your Lambda Configuration → Environment variables:

SECRET_NAME = CafeDevDBSM (or your actual secret name)

Make sure the Lambda has network access to your RDS:

If RDS is in a VPC, attach Lambda to the same VPC + subnets + security group allowing port 3306.

Include pymysql in your Lambda deployment:

Either via a Lambda Layer or package pymysql inside your ZIP deployment.

Test Lambda with this payload in AWS Console → Test:

```
{
  "body": "{\"order_id\": \"ORD-20260302-5056\"}"
}
```

After this, your Mark as Paid button should update both DynamoDB and MySQL, and your frontend will show PAID after refreshing.
----
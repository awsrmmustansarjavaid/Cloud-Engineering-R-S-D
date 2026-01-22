# ☕ AWS CAFE — Backend Code Script README

# SECTION Cafe Order Processor
> **Doc File: ☕ AWS CAFE — Order_Async_Processing_Tracking_System**

## PHASE 6️⃣ — Backend Development Code

### 1️⃣ Lambda Payload Code (INSERT INTO MariaDB)

Paste THIS EXACT CODE ⬇️

```
import json
import pymysql
import boto3

# ---------- GET DB SECRET ----------
def get_db_secret():
    client = boto3.client('secretsmanager')
    response = client.get_secret_value(SecretId='CafeDevDBSM')
    return json.loads(response['SecretString'])

# ---------- LAMBDA HANDLER ----------
def lambda_handler(event, context):
    try:
        # Parse API Gateway body
        body = json.loads(event['body'])

        # NEW: Table Number
        table_number = int(body['table_number'])

        customer_name = body.get('customer_name', None)
        item = body['item']
        quantity = int(body['quantity'])

        # Fetch DB credentials
        secret = get_db_secret()

        # Connect to RDS
        connection = pymysql.connect(
            host=secret['host'],
            user=secret['username'],
            password=secret['password'],
            database=secret['dbname'],
            connect_timeout=5
        )

        # Insert order
        with connection.cursor() as cursor:
            sql = """
                INSERT INTO orders (table_number, customer_name, item, quantity)
                VALUES (%s, %s, %s, %s)
            """
            cursor.execute(
                sql,
                (table_number, customer_name, item, quantity)
            )
            connection.commit()

        connection.close()

        return {
            "statusCode": 200,
            "headers": {
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({
                "message": "Order saved successfully",
                "table_number": table_number
            })
        }

    except Exception as e:
        print("❌ ERROR:", str(e))
        return {
            "statusCode": 500,
            "headers": {
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({"error": str(e)})
        }
```

**✅ PHASE 6️⃣ STATUS**

> **🟢 PHASE 6️⃣ COMPLETE & VERIFIED**
---
## PHASE 2️⃣ — CafeMenuLambda

### 5️⃣ Lambda Code: Read Menu from DynamoDB (Python)

Now we implement the logic.

Use boto3 to fetch menu/prices before processing orders.

[CafeMenuLambda.py](https://github.com/awsrmmustansarjavaid/Cloud-Engineering-R-S-D/blob/main/CLoud-Engineering/Cloud-research-study-drive/DevOps-research-study-drive/Cloud-ISPs-AWS-AZ-GC/AWS-Cloud-Engineering/AWS-Cloud-Practice-dev/AWS-Labs-AWS-Labs-Guide/AWS-Labs-Projects/AWS-Basic-Labs-Projects/AWS%20Challenge%20Lab%3A%20Build%20a%20Dynamic%20Caf%C3%A9%20Website%20(Dev%20%2B%20Prod)/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/AWS%20Cafe%20Project%20Development%20%26%20Depolyment%20Docs/%E2%98%95%20AWS%20CAFE%20%E2%80%94%20Front%20%26%20Backend%20Code%20Script/%E2%98%95%20AWS%20CAFE%20%E2%80%94%20Backend%20Code%20Script/CafeMenuLambda.py)


**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**
---
## PHASE 2️⃣ — CafeMenuLambda



**✅ PHASE 6️⃣ STATUS**

> **🟢 PHASE 6️⃣ COMPLETE & VERIFIED**
---
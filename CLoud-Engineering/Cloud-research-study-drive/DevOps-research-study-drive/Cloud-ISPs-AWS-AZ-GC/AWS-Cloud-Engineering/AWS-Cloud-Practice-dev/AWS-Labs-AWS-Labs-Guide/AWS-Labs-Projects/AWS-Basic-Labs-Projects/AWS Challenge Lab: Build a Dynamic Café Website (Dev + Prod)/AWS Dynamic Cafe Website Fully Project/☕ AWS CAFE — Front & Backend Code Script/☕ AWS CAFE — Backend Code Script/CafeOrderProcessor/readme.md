# ☕ AWS CAFE — CafeOrderProcessor
> **Backend Code Script **

# CafeOrderProcessor Backend Code

## 1️⃣ First Version — Basic Lambda Order Processor

### Previous Created code ( Version 1 - Basic)

> **Created: ☕ CC- 1 — Order_Async_Processing_Tracking_System .md**

> **PHASE 6️⃣ — Backend Development Code**

> **1️⃣ Lambda Payload Code (INSERT INTO MariaDB)**


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

### What it does:

Receives an API Gateway request with JSON body:

```
{
  "table_number": 1,
  "customer_name": "Alice",
  "item": "Coffee",
  "quantity": 2
}
```

- Connects to RDS (MySQL) using credentials stored in AWS Secrets Manager.

- Inserts the order into the orders table.

- Returns a success response to the frontend.

- Handles exceptions by returning a 500 error.

### Key Features:

- Simple, straightforward.

- Saves orders directly to RDS.

- Only deals with relational DB (RDS).

- No messaging, no async processing.

- No SQS, so backend processing is synchronous.

### Limitations:

- Every order goes directly to RDS.

- If you later want to trigger other workflows (like updating inventory, analytics, or DynamoDB), you need to modify this Lambda.

- No queueing → frontend waits for DB insert before receiving response.




---

## 2️⃣ Second Version — Advanced Lambda with SQS

### 2nd version and first update 

> **Created: ☕ CC- 1 — Order_Async_Processing_Tracking_System .md**

> **PHASE 6️⃣ — Backend Development Code**

> **1️⃣ Lambda Payload Code (INSERT INTO MariaDB)**

> **📄 File Name: CafeOrderProcessor(1st-V-1stTime_create_code).py**


```
import json
import pymysql
import boto3
import os  # Added for environment variables

# ---------- GET DB SECRET ----------
def get_db_secret():
    client = boto3.client('secretsmanager')
    response = client.get_secret_value(SecretId='CafeDevDBSM')
    return json.loads(response['SecretString'])

# ---------- SQS CLIENT (outside handler for reuse) ----------
sqs = boto3.client('sqs')
# Load SQS queue URL from Lambda environment variables (already set to https://sqs.us-east-1.amazonaws.com/910599465397/CafeOrdersQueue)
SQS_QUEUE_URL = os.environ['SQS_QUEUE_URL']

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

        # Insert order into RDS
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

        # ────────────────────────────────────────────────
        # NEW: Send message to SQS → triggers Worker Lambda → updates DynamoDB
        # ────────────────────────────────────────────────
        order_data = {
            "source": "web",                    # helps Worker know it's from website
            "table_number": table_number,
            "customer_name": customer_name,
            "item": item,
            "quantity": quantity,
            # Optional: add timestamp, order_id (if you fetch it), etc.
            # "timestamp": str(datetime.now().isoformat())
        }

        sqs.send_message(
            QueueUrl=SQS_QUEUE_URL,
            MessageBody=json.dumps(order_data),
            # Optional: DelaySeconds=2, MessageGroupId="cafe-orders" (if FIFO queue)
        )

        # Return success to API Gateway / frontend
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

### What it does differently:

- Still does everything first version does:

    - Receives API Gateway request.

    - Saves order to RDS.

#### Adds SQS messaging:

- Sends the order to an SQS queue.

- This queue can trigger another Lambda (Worker Lambda) to perform additional tasks, e.g.:

    - Update DynamoDB.

    - Send notification to admin.

    - Process analytics.

- Uses environment variable for SQS_QUEUE_URL instead of hardcoding.

- SQS client is created outside the handler for reuse (more efficient).

### Key Features / Improvements:

- Asynchronous processing: Frontend doesn’t wait for downstream tasks (like updating DynamoDB).

- Decoupled architecture: RDS insert and SQS message are separate → easier to scale.

- Can integrate more features without slowing down the API.

- Modern AWS architecture pattern: RDS + SQS + Lambda Worker → DynamoDB / other services.

- Environment variables: more secure and flexible.

#### Optional / Potential Features in 2nd Version:

- You can include timestamp or order_id in SQS message for tracking.

- Can work with FIFO SQS if you care about order sequence.

### 📢 Major Differences Between Versions

| Feature / Behavior                  | Version 1                        | Version 2                               |
| ----------------------------------- | -------------------------------- | --------------------------------------- |
| **DB Insertion**                    | Yes                              | Yes                                     |
| **SQS Messaging**                   | ❌ No                             | ✅ Yes, sends message to queue           |
| **Async Workflow**                  | ❌ No                             | ✅ Yes (can trigger Worker Lambda)       |
| **Environment Variable**            | ❌ No                             | ✅ Yes (`SQS_QUEUE_URL`)                 |
| **Code Optimization**               | Basic, client created in handler | SQS client created once outside handler |
| **Scalability**                     | Limited (direct RDS insert)      | High (decoupled via SQS)                |
| **Flexibility for future features** | Low                              | High                                    |

### 📢 If You Use the 2nd Version:

#### ✅ Benefits:

- You get modern, scalable architecture.

- Ready for decoupled workflows (like updating DynamoDB or sending notifications).

- Frontend gets faster responses because heavy processing can be done asynchronously.

#### ⚠️ Things to check before deployment:

#### SQS Queue URL environment variable:

    - Make sure SQS_QUEUE_URL is set in Lambda environment variables.

    - Example: https://sqs.us-east-1.amazonaws.com/910599465397/CafeOrdersQueue

#### Worker Lambda:

- You should have another Lambda that triggers from SQS to process further tasks (optional for now, but required if you rely on DynamoDB updates).

#### IAM permissions:

- Lambda must have permission to:

    - Read from Secrets Manager.

    - Connect to RDS.

    - Send messages to SQS (sqs:SendMessage).

Otherwise, it will throw an error during execution.

## 🌐 Recommendation

### Use Version 2.

- It is more professional, scalable, and future-proof.

- Version 1 is fine for testing, but for real-world deployment (especially in your AWS Cafe Lab), Version 2 is better.
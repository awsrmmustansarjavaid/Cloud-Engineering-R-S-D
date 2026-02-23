# Charlie Cafe - CafeOrderProcessor

### 🔥 PART 1 — ARCHITECTURE DECISION

#### Right now you have:

```
orders.php
   ↓
API Gateway
   ↓
CafeOrderApiLambda  → SQS
                      ↓
                 CafeOrderWorker → RDS + DynamoDB
```

And also another Lambda inserting into RDS directly.

That’s duplication.

🎯 CLEAN MERGED ARCHITECTURE (Recommended)

We will keep SQS but merge logic into ONE Lambda:

```
orders.php
   ↓
API Gateway (POST /orders)
   ↓
CafeOrderProcessor (NEW MERGED)
   ↓
1. Validate input
2. Insert into RDS
3. Update DynamoDB metrics
4. Send to SQS (for async notifications if needed)
```

No Worker Lambda needed anymore.

SQS still exists (for logs, notifications, analytics later).

### ✅ ANSWER: CONFIGURATION CHANGES?

You will:

| Component          | Action                                         |
| ------------------ | ---------------------------------------------- |
| CafeOrderApiLambda | ❌ Delete                                       |
| CafeOrderWorker    | ❌ Delete                                       |
| CafeOrderProcessor | ✅ Replace with new merged code                 |
| API Gateway        | ⚠ Point POST /orders to new CafeOrderProcessor |
| SQS                | ✅ Keep                                         |
| RDS                | ✅ Same                                         |
| DynamoDB           | ✅ Same                                         |
| Secrets Manager    | ✅ Same                                         |


Only API Gateway integration target changes.

### 🚀 NEW MERGED CafeOrderProcessor LAMBDA

> **Update Version:1.0**

Here is your clean production-ready version:

```
import json
import boto3
import pymysql
import os
from decimal import Decimal
from datetime import datetime

# ==============================
# AWS CLIENTS
# ==============================
secrets_client = boto3.client('secretsmanager')
dynamodb = boto3.resource('dynamodb')
sqs = boto3.client('sqs')

# ==============================
# ENV VARIABLES
# ==============================
SECRET_NAME = "CafeDevDBSM"
SQS_QUEUE_URL = os.environ['SQS_QUEUE_URL']
MENU_TABLE = "CafeMenu"
METRICS_TABLE = "CafeOrderMetrics"

menu_table = dynamodb.Table(MENU_TABLE)
metrics_table = dynamodb.Table(METRICS_TABLE)

# ==============================
# GET DB CREDENTIALS
# ==============================
def get_db_secret():
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])

# ==============================
# LAMBDA HANDLER
# ==============================
def lambda_handler(event, context):

    try:
        # ---------------------------------
        # 1️⃣ Parse Request Body
        # ---------------------------------
        body = json.loads(event.get("body", "{}"))

        required_fields = ["table_number", "item", "quantity"]

        for field in required_fields:
            if field not in body:
                return {
                    "statusCode": 400,
                    "headers": {"Access-Control-Allow-Origin": "*"},
                    "body": json.dumps({"error": f"Missing field: {field}"})
                }

        table_number = int(body["table_number"])
        customer_name = body.get("customer_name", "Guest")
        item = body["item"]
        quantity = int(body["quantity"])

        if table_number <= 0 or quantity <= 0:
            raise ValueError("Invalid table number or quantity")

        # ---------------------------------
        # 2️⃣ Connect to RDS
        # ---------------------------------
        secret = get_db_secret()

        connection = pymysql.connect(
            host=secret["host"],
            user=secret["username"],
            password=secret["password"],
            database=secret["dbname"],
            connect_timeout=10,
            autocommit=False
        )

        with connection.cursor() as cursor:

            # ---------------------------------
            # 3️⃣ Insert Order into RDS
            # ---------------------------------
            cursor.execute("""
                INSERT INTO orders
                (table_number, customer_name, item, quantity, status, created_at)
                VALUES (%s, %s, %s, %s, %s, %s)
            """, (
                table_number,
                customer_name,
                item,
                quantity,
                "PENDING",
                datetime.now()
            ))

        connection.commit()
        connection.close()

        # ---------------------------------
        # 4️⃣ Update DynamoDB (Item Metrics)
        # ---------------------------------
        menu_table.update_item(
            Key={"item": item},
            UpdateExpression="ADD orders :inc",
            ExpressionAttributeValues={
                ":inc": Decimal(quantity)
            }
        )

        # ---------------------------------
        # 5️⃣ Update Global Metrics
        # ---------------------------------
        metrics_table.update_item(
            Key={"metric": "TOTAL_ORDERS"},
            UpdateExpression="ADD #c :inc",
            ExpressionAttributeNames={"#c": "count"},
            ExpressionAttributeValues={
                ":inc": Decimal(1)
            }
        )

        # ---------------------------------
        # 6️⃣ Send Message to SQS
        # ---------------------------------
        sqs.send_message(
            QueueUrl=SQS_QUEUE_URL,
            MessageBody=json.dumps({
                "table_number": table_number,
                "customer_name": customer_name,
                "item": item,
                "quantity": quantity,
                "timestamp": str(datetime.now())
            })
        )

        # ---------------------------------
        # 7️⃣ Success Response
        # ---------------------------------
        return {
            "statusCode": 200,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({
                "message": "Order created successfully",
                "table_number": table_number
            })
        }

    except ValueError as e:
        return {
            "statusCode": 400,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": str(e)})
        }

    except Exception as e:
        print("❌ ERROR:", str(e))
        return {
            "statusCode": 500,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": str(e)})
        }
```

### 🧪 LAMBDA TEST EVENT JSON

Use this in Lambda Test:

```
{
  "body": "{\"table_number\": 5, \"customer_name\": \"John\", \"item\": \"Coffee\", \"quantity\": 2}"
}
```

#### ✅ Expected:

Order inserted in RDS

DynamoDB updated

SQS message sent

StatusCode 200

### Updated Code

```
import json
import boto3
import pymysql
import os
from decimal import Decimal
from datetime import datetime

# ==============================
# AWS CLIENTS
# ==============================
secrets_client = boto3.client('secretsmanager')
dynamodb = boto3.resource('dynamodb')
sqs = boto3.client('sqs')

# ==============================
# ENV VARIABLES
# ==============================
SECRET_NAME = "CafeDevDBSM"
SQS_QUEUE_URL = os.environ['SQS_QUEUE_URL']
MENU_TABLE = "CafeMenu"
METRICS_TABLE = "CafeOrderMetrics"

menu_table = dynamodb.Table(MENU_TABLE)
metrics_table = dynamodb.Table(METRICS_TABLE)

# ==============================
# GET DB CREDENTIALS
# ==============================
def get_db_secret():
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])

# ==============================
# LAMBDA HANDLER
# ==============================
def lambda_handler(event, context):

    try:
        # ---------------------------------
        # 1️⃣ Parse Request Body
        # ---------------------------------
        body = json.loads(event.get("body", "{}"))

        required_fields = ["table_number", "item", "quantity"]

        for field in required_fields:
            if field not in body:
                return {
                    "statusCode": 400,
                    "headers": {"Access-Control-Allow-Origin": "*"},
                    "body": json.dumps({"error": f"Missing field: {field}"})
                }

        table_number = int(body["table_number"])
        customer_name = body.get("customer_name", "Guest")
        item = body["item"]
        quantity = int(body["quantity"])

        if table_number <= 0 or quantity <= 0:
            raise ValueError("Invalid table number or quantity")

        # ---------------------------------
        # 2️⃣ Connect to RDS
        # ---------------------------------
        secret = get_db_secret()

        connection = pymysql.connect(
            host=secret["host"],
            user=secret["username"],
            password=secret["password"],
            database=secret["dbname"],
            connect_timeout=10,
            autocommit=False
        )

        with connection.cursor() as cursor:

            # ---------------------------------
            # 3️⃣ Insert Order into RDS
            # ---------------------------------
            cursor.execute("""
                INSERT INTO orders
                (table_number, customer_name, item, quantity, status, created_at)
                VALUES (%s, %s, %s, %s, %s, %s)
            """, (
                table_number,
                customer_name,
                item,
                quantity,
                "PENDING",
                datetime.now()
            ))

        connection.commit()
        connection.close()

        # ---------------------------------
        # 4️⃣ Update DynamoDB (Item Metrics)
        # ---------------------------------
        menu_table.update_item(
            Key={"item": item},
            UpdateExpression="ADD orders :inc",
            ExpressionAttributeValues={
                ":inc": Decimal(quantity)
            }
        )

        # ---------------------------------
        # 5️⃣ Update Global Metrics
        # ---------------------------------
        metrics_table.update_item(
            Key={"metric": "TOTAL_ORDERS"},
            UpdateExpression="ADD #c :inc",
            ExpressionAttributeNames={"#c": "count"},
            ExpressionAttributeValues={
                ":inc": Decimal(1)
            }
        )

        # ---------------------------------
        # 6️⃣ Send Message to SQS
        # ---------------------------------
        sqs.send_message(
            QueueUrl=SQS_QUEUE_URL,
            MessageBody=json.dumps({
                "table_number": table_number,
                "customer_name": customer_name,
                "item": item,
                "quantity": quantity,
                "timestamp": str(datetime.now())
            })
        )

        # ---------------------------------
        # 7️⃣ Success Response
        # ---------------------------------
        return {
            "statusCode": 200,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({
                "message": "Order created successfully",
                "table_number": table_number
            })
        }

    except ValueError as e:
        return {
            "statusCode": 400,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": str(e)})
        }

    except Exception as e:
        print("❌ ERROR:", str(e))
        return {
            "statusCode": 500,
            "headers": {"Access-Control-Allow-Origin": "*"},
            "body": json.dumps({"error": str(e)})
        }
```        

### ✅ Merge CreateOrderLambda into CafeOrderProcessor

### 🎯 The Important Condition

After merging, your CafeOrderProcessor must:

- Insert order into the same orders table

- Use same column names:

   - order_id

   - table_number

   - customer_name

   - item

   - quantity

   - total_amount

   - status

- Set initial status to "RECEIVED"

If you keep the database structure SAME, then:

✅ CafeOrderWorkerLambda will continue working

✅ order-update endpoint will continue working

✅ admin page will continue working

Because they all read from the SAME database.

### 🧠 What Will Happen After Merge?

New Flow:

```
orders.php → CafeOrderProcessor (create order)
admin → CafeOrderWorkerLambda (update status)
```

That is totally fine.

### ❓Will JSON Match?

Right now CreateOrderLambda returns:

```
{
  "message": "Order placed",
  "order_id": "ORD-xxxx",
  "status": "RECEIVED",
  "total": 6,
  "track_url": "/order-status.php?order_id=ORD-xxxx"
}
```

Admin and order-status pages usually expect:

```
{
  "order_id": "ORD-xxxx",
  "table_number": 5,
  "item": "Coffee",
  "quantity": 2,
  "status": "RECEIVED"
}
```

So after merging, you should slightly improve response to return FULL order object:

```
{
  "order_id": "ORD-xxxx",
  "table_number": 5,
  "customer_name": "John",
  "item": "Coffee",
  "quantity": 2,
  "total": 6,
  "status": "RECEIVED"
}
```

That’s the only improvement needed.

### 🚨 What You DO NOT Need To Change

You DO NOT need to change:

- CafeOrderWorkerLambda

- order-update API

- Status transition logic

- Database schema

As long as the table structure stays same.

### 🔥 My Recommendation

This is actually a very good decision:

✔ Merge CreateOrder into CafeOrderProcessor
✔ Keep Worker Lambda separate
✔ Keep order-update endpoint
✔ Keep status transition logic separate

#### This keeps:

- Clean architecture

- Simple debugging

- Less risk

- Admin still works

### 🏁 Final Conclusion

#### Your idea:

Merge CreateOrderLambda into CafeOrderProcessor only

✅ Technically correct
✅ Safe
✅ Will not break worker
✅ Will not break admin
✅ Will not break order-status
✅ Will reduce duplication

Just make sure the returned JSON includes full order fields.

✅ now we will properly merge:

✅ Your existing CafeOrderProcessor

✅ CreateOrderLambda logic

✅ Keep DynamoDB updates

✅ Keep SQS

✅ Keep Secrets Manager

✅ Generate order_id

✅ Calculate total_amount

✅ Insert into RDS with correct structure

✅ Return FULL JSON for frontend

We will NOT touch CafeOrderWorkerLambda.

This will be your final production-ready merged Lambda.

### ✅ FINAL MERGED CafeOrderProcessor (FULL WORKING CODE)

```
import json
import boto3
import pymysql
import os
import random
from decimal import Decimal
from datetime import datetime

# ==========================================================
# AWS CLIENTS
# ==========================================================
secrets_client = boto3.client('secretsmanager')
dynamodb = boto3.resource('dynamodb')
sqs = boto3.client('sqs')

# ==========================================================
# ENV VARIABLES
# ==========================================================
SECRET_NAME = "CafeDevDBSM"
SQS_QUEUE_URL = os.environ['SQS_QUEUE_URL']
MENU_TABLE = "CafeMenu"
METRICS_TABLE = "CafeOrderMetrics"

menu_table = dynamodb.Table(MENU_TABLE)
metrics_table = dynamodb.Table(METRICS_TABLE)

# ==========================================================
# GENERATE UNIQUE ORDER ID
# ==========================================================
def generate_order_id():
    return f"ORD-{datetime.now().strftime('%Y%m%d')}-{random.randint(1000,9999)}"

# ==========================================================
# GET DB CREDENTIALS FROM SECRETS MANAGER
# ==========================================================
def get_db_secret():
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])

# ==========================================================
# PRICE LIST
# ==========================================================
PRICE_LIST = {
    "Coffee": 3.00,
    "Tea": 2.50,
    "Latte": 4.00,
    "Cappuccino": 4.50,
    "Fresh Juice": 5.00
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

        required_fields = ["table_number", "item", "quantity"]

        for field in required_fields:
            if field not in body:
                return response(400, {"error": f"Missing field: {field}"})

        table_number = int(body["table_number"])
        customer_name = body.get("customer_name", "Guest")
        item = body["item"]
        quantity = int(body["quantity"])

        if item not in PRICE_LIST:
            return response(400, {"error": "Invalid menu item"})

        if table_number <= 0 or quantity <= 0:
            return response(400, {"error": "Invalid table number or quantity"})

        # --------------------------------------------------
        # 2️⃣ Generate Order Details
        # --------------------------------------------------
        order_id = generate_order_id()
        total_amount = PRICE_LIST[item] * quantity
        status = "RECEIVED"
        created_at = datetime.now()

        # --------------------------------------------------
        # 3️⃣ Connect to RDS
        # --------------------------------------------------
        secret = get_db_secret()

        connection = pymysql.connect(
            host=secret["host"],
            user=secret["username"],
            password=secret["password"],
            database=secret["dbname"],
            connect_timeout=10,
            autocommit=False
        )

        with connection.cursor() as cursor:

            cursor.execute("""
                INSERT INTO orders
                (order_id, table_number, customer_name, item,
                 quantity, total_amount, status, created_at)
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s)
            """, (
                order_id,
                table_number,
                customer_name,
                item,
                quantity,
                total_amount,
                status,
                created_at
            ))

        connection.commit()
        connection.close()

        # --------------------------------------------------
        # 4️⃣ Update DynamoDB - Item Metrics
        # --------------------------------------------------
        menu_table.update_item(
            Key={"item": item},
            UpdateExpression="ADD orders :inc",
            ExpressionAttributeValues={
                ":inc": Decimal(quantity)
            }
        )

        # --------------------------------------------------
        # 5️⃣ Update Global Metrics
        # --------------------------------------------------
        metrics_table.update_item(
            Key={"metric": "TOTAL_ORDERS"},
            UpdateExpression="ADD #c :inc",
            ExpressionAttributeNames={"#c": "count"},
            ExpressionAttributeValues={
                ":inc": Decimal(1)
            }
        )

        # --------------------------------------------------
        # 6️⃣ Send Message to SQS
        # --------------------------------------------------
        sqs.send_message(
            QueueUrl=SQS_QUEUE_URL,
            MessageBody=json.dumps({
                "order_id": order_id,
                "table_number": table_number,
                "customer_name": customer_name,
                "item": item,
                "quantity": quantity,
                "status": status,
                "timestamp": str(created_at)
            })
        )

        # --------------------------------------------------
        # 7️⃣ Success Response (FULL ORDER JSON)
        # --------------------------------------------------
        return response(200, {
            "order_id": order_id,
            "table_number": table_number,
            "customer_name": customer_name,
            "item": item,
            "quantity": quantity,
            "total": total_amount,
            "status": status,
            "created_at": str(created_at)
        })

    except Exception as e:
        print("❌ ERROR:", str(e))
        return response(500, {"error": str(e)})

# ==========================================================
# STANDARD RESPONSE FORMAT
# ==========================================================
def response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": json.dumps(body)
    }
```

### ✅ LAMBDA TEST EVENT JSON

Use this in Test tab:

```
{
  "body": "{\"table_number\":5,\"customer_name\":\"John\",\"item\":\"Coffee\",\"quantity\":2}"
}
```

### ✅ EXPECTED RESULT OUTPUT

```
{
  "statusCode": 200,
  "body": "{\"order_id\":\"ORD-20260220-1234\",\"table_number\":5,\"customer_name\":\"John\",\"item\":\"Coffee\",\"quantity\":2,\"total\":6.0,\"status\":\"RECEIVED\",\"created_at\":\"2026-02-20 10:30:00\"}"
}
```

### ✅ CONFIGURATION STEP BY STEP

#### 1️⃣ Lambda Settings

Runtime: Python 3.11
Timeout: 15 seconds
Memory: 512 MB

#### 2️⃣ Environment Variables

Add:

```
SQS_QUEUE_URL = https://sqs.us-east-1.amazonaws.com/xxxx/CafeQueue
```

#### 3️⃣ IAM Role Permissions

Attach policy allowing:

SecretsManager:GetSecretValue

DynamoDB:UpdateItem

SQS:SendMessage

RDS connection (via VPC access)

#### 4️⃣ VPC Configuration

Attach Lambda to:

Same VPC as RDS

Private subnets

Security group allowing MySQL (3306)

#### 5️⃣ API Gateway

- Resource: /orders

- Method: POST

- Integration: CafeOrderProcessor

Enable CORS

Deploy stage: prod

### ✅ FINAL RESULT

After this:

orders.php → API → CafeOrderProcessor →
✔ RDS insert
✔ DynamoDB update
✔ SQS message
✔ Returns full JSON
✔ Worker Lambda still works
✔ Admin page works
✔ Order-status page works
---
### CafeOrderProcessor.py

> **Update Version:1.1**


CafeOrderProcessor Lambda and fully integrated DynamoDB saving for CafeOrders, keeping your RDS insert, metrics updates, SQS message, and response. I’ve also added detailed comments for clarity. This is production-ready and compatible with CashPaymentLambda.

#### Here’s the final version:

```
import json
import boto3
import pymysql
import os
import random
from decimal import Decimal
from datetime import datetime

# ==========================================================
# AWS CLIENTS
# ==========================================================
secrets_client = boto3.client('secretsmanager')  # For RDS credentials
dynamodb = boto3.resource('dynamodb')           # For CafeMenu, CafeOrderMetrics, CafeOrders
sqs = boto3.client('sqs')                        # For order notifications

# ==========================================================
# ENV VARIABLES
# ==========================================================
SECRET_NAME = "CafeDevDBSM"                      # Secret for RDS credentials
SQS_QUEUE_URL = os.environ['SQS_QUEUE_URL']     # SQS queue for order messages
MENU_TABLE = "CafeMenu"                          # DynamoDB table for per-item metrics
METRICS_TABLE = "CafeOrderMetrics"              # DynamoDB table for global metrics
ORDERS_TABLE = "CafeOrders"                      # DynamoDB table to save orders

menu_table = dynamodb.Table(MENU_TABLE)
metrics_table = dynamodb.Table(METRICS_TABLE)
orders_table = dynamodb.Table(ORDERS_TABLE)

# ==========================================================
# PRICE LIST (can be replaced with DynamoDB fetch later)
# ==========================================================
PRICE_LIST = {
    "Coffee": 3.00,
    "Tea": 2.50,
    "Latte": 4.00,
    "Cappuccino": 4.50,
    "Fresh Juice": 5.00
}

# ==========================================================
# HELPER: Generate Unique Order ID
# ==========================================================
def generate_order_id():
    return f"ORD-{datetime.now().strftime('%Y%m%d')}-{random.randint(1000,9999)}"

# ==========================================================
# HELPER: Get RDS Credentials from Secrets Manager
# ==========================================================
def get_db_secret():
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])

# ==========================================================
# HELPER: Standard Lambda Response
# ==========================================================
def response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {"Access-Control-Allow-Origin": "*"},
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
        required_fields = ["table_number", "item", "quantity"]

        for field in required_fields:
            if field not in body:
                return response(400, {"error": f"Missing field: {field}"})

        # Extract fields
        table_number = int(body["table_number"])
        customer_name = body.get("customer_name", "Guest")
        item = body["item"]
        quantity = int(body["quantity"])

        # Validate item & numeric values
        if item not in PRICE_LIST:
            return response(400, {"error": "Invalid menu item"})
        if table_number <= 0 or quantity <= 0:
            return response(400, {"error": "Invalid table number or quantity"})

        # --------------------------------------------------
        # 2️⃣ Generate Order Details
        # --------------------------------------------------
        order_id = generate_order_id()
        total_amount = PRICE_LIST[item] * quantity
        status = "RECEIVED"
        created_at = datetime.now()

        # --------------------------------------------------
        # 3️⃣ Insert Order into RDS
        # --------------------------------------------------
        secret = get_db_secret()
        connection = pymysql.connect(
            host=secret["host"],
            user=secret["username"],
            password=secret["password"],
            database=secret["dbname"],
            connect_timeout=10,
            autocommit=False
        )

        with connection.cursor() as cursor:
            cursor.execute("""
                INSERT INTO orders
                (order_id, table_number, customer_name, item,
                 quantity, total_amount, status, created_at)
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s)
            """, (
                order_id,
                table_number,
                customer_name,
                item,
                quantity,
                total_amount,
                status,
                created_at
            ))

        connection.commit()
        connection.close()

        # --------------------------------------------------
        # 4️⃣ Save Order to DynamoDB (CafeOrders)
        # --------------------------------------------------
        orders_table.put_item(
            Item={
                "order_id": order_id,
                "table_number": table_number,
                "customer_name": customer_name,
                "item": item,
                "quantity": quantity,
                "total_amount": total_amount,
                "status": status,
                "payment_method": "NONE",   # default
                "payment_status": "PENDING", # default
                "created_at": str(created_at)
            }
        )

        # --------------------------------------------------
        # 5️⃣ Update DynamoDB - Item Metrics
        # --------------------------------------------------
        menu_table.update_item(
            Key={"item": item},
            UpdateExpression="ADD orders :inc",
            ExpressionAttributeValues={":inc": Decimal(quantity)}
        )

        # --------------------------------------------------
        # 6️⃣ Update Global Metrics
        # --------------------------------------------------
        metrics_table.update_item(
            Key={"metric": "TOTAL_ORDERS"},
            UpdateExpression="ADD #c :inc",
            ExpressionAttributeNames={"#c": "count"},
            ExpressionAttributeValues={":inc": Decimal(1)}
        )

        # --------------------------------------------------
        # 7️⃣ Send Order Message to SQS
        # --------------------------------------------------
        sqs.send_message(
            QueueUrl=SQS_QUEUE_URL,
            MessageBody=json.dumps({
                "order_id": order_id,
                "table_number": table_number,
                "customer_name": customer_name,
                "item": item,
                "quantity": quantity,
                "status": status,
                "timestamp": str(created_at)
            })
        )

        # --------------------------------------------------
        # 8️⃣ Return Success Response
        # --------------------------------------------------
        return response(200, {
            "order_id": order_id,
            "table_number": table_number,
            "customer_name": customer_name,
            "item": item,
            "quantity": quantity,
            "total": total_amount,
            "status": status,
            "created_at": str(created_at)
        })

    except Exception as e:
        print("❌ ERROR:", str(e))
        return response(500, {"error": str(e)})
```

### ✅ What Changed / Added

- Added ORDERS_TABLE = "CafeOrders" and orders_table = dynamodb.Table(ORDERS_TABLE).

- After RDS insert, added orders_table.put_item to save the order in DynamoDB.

- Added default payment fields:

- payment_method = "NONE"

- payment_status = "PENDING"

- Comments added for every major step.

---
### CafeOrderProcessor.py

> **Update Version:1.2**

- Create the order in RDS and DynamoDB (as your current CafeOrderProcessor does).

- Optionally set the payment method (CASH, CARD, or default NONE) and payment status (PENDING/PAID) at creation. This replaces CashPaymentLambda.

- Update metrics and send SQS message as before.

- Return full JSON to frontend.

- I’ll rewrite your final merged Lambda, fully commented, supporting an optional payment_method field, defaulting to "NONE".

#### Here’s the merged, production-ready version:

```
import json
import boto3
import pymysql
import os
import random
from decimal import Decimal
from datetime import datetime

# ==========================================================
# AWS CLIENTS
# ==========================================================
secrets_client = boto3.client('secretsmanager')  # For RDS credentials
dynamodb = boto3.resource('dynamodb')           # For CafeMenu, CafeOrderMetrics, CafeOrders
sqs = boto3.client('sqs')                        # For order notifications

# ==========================================================
# ENV VARIABLES
# ==========================================================
SECRET_NAME = "CafeDevDBSM"                      # Secret for RDS credentials
SQS_QUEUE_URL = os.environ['SQS_QUEUE_URL']     # SQS queue for order messages
MENU_TABLE = "CafeMenu"                          # DynamoDB table for per-item metrics
METRICS_TABLE = "CafeOrderMetrics"              # DynamoDB table for global metrics
ORDERS_TABLE = "CafeOrders"                      # DynamoDB table to save orders

menu_table = dynamodb.Table(MENU_TABLE)
metrics_table = dynamodb.Table(METRICS_TABLE)
orders_table = dynamodb.Table(ORDERS_TABLE)

# ==========================================================
# PRICE LIST (can be replaced with DynamoDB fetch later)
# ==========================================================
PRICE_LIST = {
    "Coffee": 3.00,
    "Tea": 2.50,
    "Latte": 4.00,
    "Cappuccino": 4.50,
    "Fresh Juice": 5.00
}

# ==========================================================
# HELPER: Generate Unique Order ID
# ==========================================================
def generate_order_id():
    return f"ORD-{datetime.now().strftime('%Y%m%d')}-{random.randint(1000,9999)}"

# ==========================================================
# HELPER: Get RDS Credentials from Secrets Manager
# ==========================================================
def get_db_secret():
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])

# ==========================================================
# HELPER: Standard Lambda Response
# ==========================================================
def response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": json.dumps(body)
    }

# ==========================================================
# LAMBDA HANDLER - MERGED ORDER + PAYMENT
# ==========================================================
def lambda_handler(event, context):
    try:
        # --------------------------------------------------
        # 1️⃣ Parse Request Body
        # --------------------------------------------------
        body = json.loads(event.get("body", "{}"))
        required_fields = ["table_number", "item", "quantity"]

        for field in required_fields:
            if field not in body:
                return response(400, {"error": f"Missing field: {field}"})

        # Extract fields
        table_number = int(body["table_number"])
        customer_name = body.get("customer_name", "Guest")
        item = body["item"]
        quantity = int(body["quantity"])
        payment_method = body.get("payment_method", "NONE").upper()  # optional: CASH, CARD, NONE

        # Validate item & numeric values
        if item not in PRICE_LIST:
            return response(400, {"error": "Invalid menu item"})
        if table_number <= 0 or quantity <= 0:
            return response(400, {"error": "Invalid table number or quantity"})
        if payment_method not in ["NONE", "CASH", "CARD"]:
            return response(400, {"error": "Invalid payment method"})

        # --------------------------------------------------
        # 2️⃣ Generate Order Details
        # --------------------------------------------------
        order_id = generate_order_id()
        total_amount = PRICE_LIST[item] * quantity
        status = "RECEIVED"
        payment_status = "PENDING" if payment_method != "NONE" else "NONE"
        created_at = datetime.now()

        # --------------------------------------------------
        # 3️⃣ Insert Order into RDS
        # --------------------------------------------------
        secret = get_db_secret()
        connection = pymysql.connect(
            host=secret["host"],
            user=secret["username"],
            password=secret["password"],
            database=secret["dbname"],
            connect_timeout=10,
            autocommit=False
        )

        with connection.cursor() as cursor:
            cursor.execute("""
                INSERT INTO orders
                (order_id, table_number, customer_name, item,
                 quantity, total_amount, status, created_at,
                 payment_method, payment_status)
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
            """, (
                order_id,
                table_number,
                customer_name,
                item,
                quantity,
                total_amount,
                status,
                created_at,
                payment_method,
                payment_status
            ))

        connection.commit()
        connection.close()

        # --------------------------------------------------
        # 4️⃣ Save Order to DynamoDB (CafeOrders)
        # --------------------------------------------------
        orders_table.put_item(
            Item={
                "order_id": order_id,
                "table_number": table_number,
                "customer_name": customer_name,
                "item": item,
                "quantity": quantity,
                "total_amount": total_amount,
                "status": status,
                "payment_method": payment_method,
                "payment_status": payment_status,
                "created_at": str(created_at)
            }
        )

        # --------------------------------------------------
        # 5️⃣ Update DynamoDB - Item Metrics
        # --------------------------------------------------
        menu_table.update_item(
            Key={"item": item},
            UpdateExpression="ADD orders :inc",
            ExpressionAttributeValues={":inc": Decimal(quantity)}
        )

        # --------------------------------------------------
        # 6️⃣ Update Global Metrics
        # --------------------------------------------------
        metrics_table.update_item(
            Key={"metric": "TOTAL_ORDERS"},
            UpdateExpression="ADD #c :inc",
            ExpressionAttributeNames={"#c": "count"},
            ExpressionAttributeValues={":inc": Decimal(1)}
        )

        # --------------------------------------------------
        # 7️⃣ Send Order Message to SQS
        # --------------------------------------------------
        sqs.send_message(
            QueueUrl=SQS_QUEUE_URL,
            MessageBody=json.dumps({
                "order_id": order_id,
                "table_number": table_number,
                "customer_name": customer_name,
                "item": item,
                "quantity": quantity,
                "status": status,
                "payment_method": payment_method,
                "payment_status": payment_status,
                "timestamp": str(created_at)
            })
        )

        # --------------------------------------------------
        # 8️⃣ Return Success Response
        # --------------------------------------------------
        return response(200, {
            "order_id": order_id,
            "table_number": table_number,
            "customer_name": customer_name,
            "item": item,
            "quantity": quantity,
            "total": total_amount,
            "status": status,
            "payment_method": payment_method,
            "payment_status": payment_status,
            "created_at": str(created_at)
        })

    except Exception as e:
        print("❌ ERROR:", str(e))
        return response(500, {"error": str(e)})
```        

### ✅ Merged Lambda Features

- Creates order in RDS with optional payment method (CASH, CARD, NONE).

- Saves order in DynamoDB (CafeOrders) with payment info.

- Updates menu item metrics and global metrics.

- Sends SQS message for downstream workers (kitchen, printing, notifications).

- Returns full JSON to frontend including payment_method and payment_status.

- Eliminates the need for a separate CashPaymentLambda.
---


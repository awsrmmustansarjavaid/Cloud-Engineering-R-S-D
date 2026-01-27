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
# SECTION 2️⃣ — AWS Cafe Menu + Cache Layer
## PHASE 2️⃣ — CafeMenuLambda

### 5️⃣ Lambda Code: Read Menu from DynamoDB (Python)

Now we implement the logic.

Use boto3 to fetch menu/prices before processing orders.

[CafeMenuLambda.py](https://github.com/awsrmmustansarjavaid/Cloud-Engineering-R-S-D/blob/main/CLoud-Engineering/Cloud-research-study-drive/DevOps-research-study-drive/Cloud-ISPs-AWS-AZ-GC/AWS-Cloud-Engineering/AWS-Cloud-Practice-dev/AWS-Labs-AWS-Labs-Guide/AWS-Labs-Projects/AWS-Basic-Labs-Projects/AWS%20Challenge%20Lab%3A%20Build%20a%20Dynamic%20Caf%C3%A9%20Website%20(Dev%20%2B%20Prod)/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/AWS%20Cafe%20Project%20Development%20%26%20Depolyment%20Docs/%E2%98%95%20AWS%20CAFE%20%E2%80%94%20Front%20%26%20Backend%20Code%20Script/%E2%98%95%20AWS%20CAFE%20%E2%80%94%20Backend%20Code%20Script/CafeMenuLambda.py)


**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**

# 🟢 SECTION 2️⃣ COMPLETE & VERIFIED
---
# SECTION 3️⃣ — AWS CAFE SQS (Async Order Processing)

## PHASE 2️⃣ CREATE API Lambda Function (Producer)

#### 1️⃣ Replace your order insert logic with this:

#### 📣 CafeOrderApiLambda  — Production-Ready (Recommended for This Lab)

#### 💻 Code (Recommended for This Lab)

[CafeOrderApiLambda.py](https://github.com/awsrmmustansarjavaid/Cloud-Engineering-R-S-D/blob/main/CLoud-Engineering/Cloud-research-study-drive/DevOps-research-study-drive/Cloud-ISPs-AWS-AZ-GC/AWS-Cloud-Engineering/AWS-Cloud-Practice-dev/AWS-Labs-AWS-Labs-Guide/AWS-Labs-Projects/AWS-Basic-Labs-Projects/AWS%20Challenge%20Lab%3A%20Build%20a%20Dynamic%20Caf%C3%A9%20Website%20(Dev%20%2B%20Prod)/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/AWS%20Cafe%20Project%20Development%20%26%20Depolyment%20Docs/%E2%98%95%20AWS%20CAFE%20%E2%80%94%20Front%20%26%20Backend%20Code%20Script/%E2%98%95%20AWS%20CAFE%20%E2%80%94%20Backend%20Code%20Script/CafeOrderApiLambda.py)

**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**
---
## PHASE 4️⃣ — SQS/Worker LAMBDA (Consumer)

### 3️⃣ WORKER LAMBDA CODE Production Safe (Recommended)

#### 💻 Code:

[CafeOrderWorker.py](https://github.com/awsrmmustansarjavaid/Cloud-Engineering-R-S-D/blob/main/CLoud-Engineering/Cloud-research-study-drive/DevOps-research-study-drive/Cloud-ISPs-AWS-AZ-GC/AWS-Cloud-Engineering/AWS-Cloud-Practice-dev/AWS-Labs-AWS-Labs-Guide/AWS-Labs-Projects/AWS-Basic-Labs-Projects/AWS%20Challenge%20Lab%3A%20Build%20a%20Dynamic%20Caf%C3%A9%20Website%20(Dev%20%2B%20Prod)/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/AWS%20Cafe%20Project%20Development%20%26%20Depolyment%20Docs/%E2%98%95%20AWS%20CAFE%20%E2%80%94%20Front%20%26%20Backend%20Code%20Script/%E2%98%95%20AWS%20CAFE%20%E2%80%94%20Backend%20Code%20Script/CafeOrderWorker.py)

**✅ PHASE 4️⃣ STATUS**

> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**
---
## PHASE 6️⃣ — Update Lambda Function Cafe Order Processor

### 1️⃣ Updated Code 

[CafeOrderProcessor(2nd-V-But-1stTime_update_code).py](https://github.com/awsrmmustansarjavaid/Cloud-Engineering-R-S-D/blob/main/CLoud-Engineering/Cloud-research-study-drive/DevOps-research-study-drive/Cloud-ISPs-AWS-AZ-GC/AWS-Cloud-Engineering/AWS-Cloud-Practice-dev/AWS-Labs-AWS-Labs-Guide/AWS-Labs-Projects/AWS-Basic-Labs-Projects/AWS%20Challenge%20Lab%3A%20Build%20a%20Dynamic%20Caf%C3%A9%20Website%20(Dev%20%2B%20Prod)/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/AWS%20Cafe%20Project%20Development%20%26%20Depolyment%20Docs/%E2%98%95%20AWS%20CAFE%20%E2%80%94%20Front%20%26%20Backend%20Code%20Script/%E2%98%95%20AWS%20CAFE%20%E2%80%94%20Backend%20Code%20Script/CafeOrderProcessor(2nd-V-But-1stTime_update_code).py)


**✅ PHASE 6️⃣ STATUS**

> **🟢 PHASE 6️⃣ COMPLETE & VERIFIED**
# 🟢 SECTION 3️⃣ COMPLETE & VERIFIED
---
# SECTION 4️⃣ — ORDER STATUS DASHBOARD

## PHASE 3️⃣ — UPDATE WORKER LAMBDA (SAFE & EXACT)
> **⚠️ This step is inside existing Worker Lambda, NOT API Lambda.**

###  1️⃣ Open Worker Lambda

### AWS Console → Lambda → CafeOrderWorker

###  2️⃣ UPDATE WORKER LAMBDA (SAFE ADDITION)

### 1️⃣ Add this code at the TOP

```
metrics_table = dynamodb.Table("CafeOrderMetrics")
```

### 2️⃣ Add this AFTER successful RDS insert

⚠️ Place it AFTER cursor.execute(...) and commit()

#### Inside your SQS Worker Lambda, after DB insert:

```
metrics_table.update_item(
    Key={"metric": "TOTAL_ORDERS"},
    UpdateExpression="ADD #c :inc",
    ExpressionAttributeNames={"#c": "count"},
    ExpressionAttributeValues={":inc": Decimal(1)}
)
```

### 3️⃣ ✅ FINAL WORKER LAMBDA CODE

#### Below is the FINAL, READY-TO-DEPLOY Worker Lambda code with:

✅ Your existing logic untouched

✅ Order metrics added safely

✅ Correct placement (TOP + AFTER DB insert)

✅ SQS-safe error handling

[CafeOrderMetrics.py](https://github.com/awsrmmustansarjavaid/Cloud-Engineering-R-S-D/blob/main/CLoud-Engineering/Cloud-research-study-drive/DevOps-research-study-drive/Cloud-ISPs-AWS-AZ-GC/AWS-Cloud-Engineering/AWS-Cloud-Practice-dev/AWS-Labs-AWS-Labs-Guide/AWS-Labs-Projects/AWS-Basic-Labs-Projects/AWS%20Challenge%20Lab%3A%20Build%20a%20Dynamic%20Caf%C3%A9%20Website%20(Dev%20%2B%20Prod)/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/AWS%20Cafe%20Project%20Development%20%26%20Depolyment%20Docs/%E2%98%95%20AWS%20CAFE%20%E2%80%94%20Front%20%26%20Backend%20Code%20Script/%E2%98%95%20AWS%20CAFE%20%E2%80%94%20Backend%20Code%20Script/CafeOrderMetrics.py)

**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---
## PHASE 4️⃣ — CREATE ORDER STATUS LAMBDA (NEW)

### 2️⃣ Lambda Status Order Code

[GetOrderStatusLambda.py](https://github.com/awsrmmustansarjavaid/Cloud-Engineering-R-S-D/blob/main/CLoud-Engineering/Cloud-research-study-drive/DevOps-research-study-drive/Cloud-ISPs-AWS-AZ-GC/AWS-Cloud-Engineering/AWS-Cloud-Practice-dev/AWS-Labs-AWS-Labs-Guide/AWS-Labs-Projects/AWS-Basic-Labs-Projects/AWS%20Challenge%20Lab%3A%20Build%20a%20Dynamic%20Caf%C3%A9%20Website%20(Dev%20%2B%20Prod)/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/AWS%20Cafe%20Project%20Development%20%26%20Depolyment%20Docs/%E2%98%95%20AWS%20CAFE%20%E2%80%94%20Front%20%26%20Backend%20Code%20Script/%E2%98%95%20AWS%20CAFE%20%E2%80%94%20Backend%20Code%20Script/GetOrderStatusLambda.py)

**✅ PHASE 4️⃣ STATUS**

> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**
# 🟢 SECTION 4️⃣ COMPLETE & VERIFIED
---
# ☕ SECTION 5️⃣ — Customer Order Tracking, Billing & Receipt (Frontend-Only, Zero-Risk)

## 🔔 PHASE 2️⃣ — Customer Order Tracking (Read-Only Backend, Zero-Risk)

### 🧑‍💻 STEP 4 — FINAL LAMBDA CODE (READ-ONLY)

> **⚠️ COPY EXACTLY — do NOT modify**

[CafeOrderStatusLambda.py](https://github.com/awsrmmustansarjavaid/Cloud-Engineering-R-S-D/blob/main/CLoud-Engineering/Cloud-research-study-drive/DevOps-research-study-drive/Cloud-ISPs-AWS-AZ-GC/AWS-Cloud-Engineering/AWS-Cloud-Practice-dev/AWS-Labs-AWS-Labs-Guide/AWS-Labs-Projects/AWS-Basic-Labs-Projects/AWS%20Challenge%20Lab%3A%20Build%20a%20Dynamic%20Caf%C3%A9%20Website%20(Dev%20%2B%20Prod)/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/AWS%20Cafe%20Project%20Development%20%26%20Depolyment%20Docs/%E2%98%95%20AWS%20CAFE%20%E2%80%94%20Front%20%26%20Backend%20Code%20Script/%E2%98%95%20AWS%20CAFE%20%E2%80%94%20Backend%20Code%20Script/CafeOrderStatusLambda.py)


**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**
---
## 🔄 PHASE 3️⃣ — Real Order State Machine (RECEIVED → PREPARING → READY → COMPLETED)

#### 2️⃣ Replace Code (100% COPY)

[CreateOrderLambda.py](https://github.com/awsrmmustansarjavaid/Cloud-Engineering-R-S-D/blob/main/CLoud-Engineering/Cloud-research-study-drive/DevOps-research-study-drive/Cloud-ISPs-AWS-AZ-GC/AWS-Cloud-Engineering/AWS-Cloud-Practice-dev/AWS-Labs-AWS-Labs-Guide/AWS-Labs-Projects/AWS-Basic-Labs-Projects/AWS%20Challenge%20Lab%3A%20Build%20a%20Dynamic%20Caf%C3%A9%20Website%20(Dev%20%2B%20Prod)/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/AWS%20Cafe%20Project%20Development%20%26%20Depolyment%20Docs/%E2%98%95%20AWS%20CAFE%20%E2%80%94%20Front%20%26%20Backend%20Code%20Script/%E2%98%95%20AWS%20CAFE%20%E2%80%94%20Backend%20Code%20Script/CreateOrderLambda.py)

### 🧑‍💻 STEP 4 — CREATE WORKER (KITCHEN) LAMBDA

### 2️⃣ Lambda Code (STRICT COPY)

[CafeOrderWorkerLambda.py](https://github.com/awsrmmustansarjavaid/Cloud-Engineering-R-S-D/blob/main/CLoud-Engineering/Cloud-research-study-drive/DevOps-research-study-drive/Cloud-ISPs-AWS-AZ-GC/AWS-Cloud-Engineering/AWS-Cloud-Practice-dev/AWS-Labs-AWS-Labs-Guide/AWS-Labs-Projects/AWS-Basic-Labs-Projects/AWS%20Challenge%20Lab%3A%20Build%20a%20Dynamic%20Caf%C3%A9%20Website%20(Dev%20%2B%20Prod)/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/AWS%20Cafe%20Project%20Development%20%26%20Depolyment%20Docs/%E2%98%95%20AWS%20CAFE%20%E2%80%94%20Front%20%26%20Backend%20Code%20Script/%E2%98%95%20AWS%20CAFE%20%E2%80%94%20Backend%20Code%20Script/CafeOrderWorkerLambda.py)

### 🧑‍💻 STEP 7 — UPDATE ORDER STATUS LAMBDA (READ REAL STATUS)






**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---




**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**

# 🟢 SECTION 5️⃣ COMPLETE & VERIFIED
---
# SECTION 1️⃣ SALES ANALYTICS & REPORTING SYSTEM

## PHASE 1️⃣ – DYNAMODB DESIGN (NO NEW TABLE)

### 3️⃣ – EXACT DYNAMODB QUERY CODE (REQUIRED)

> **This is the canonical query function used by Analytics Lambda.**

#### ✅ Python Query Function (COPY AS-IS)

> **Daily / Weekly / Monthly Query (Python)**

```
import boto3
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('CafeOrders')

def query_orders(start_date, end_date):
    response = table.query(
        IndexName='order_date-index',
        KeyConditionExpression='order_date BETWEEN :s AND :e',
        ExpressionAttributeValues={
            ':s': start_date,
            ':e': end_date
        }
    )
    return response['Items']
```

#### ✅ FINAL UPDATED CODE

> **(Same Logic + Comments)**

```
import boto3
from decimal import Decimal

# Initialize DynamoDB resource using default AWS credentials and region
dynamodb = boto3.resource('dynamodb')

# Reference the DynamoDB table that stores cafe orders
# ⚠️ Replace 'CafeOrders' only if your actual table name is different
table = dynamodb.Table('CafeOrders')


def query_orders(start_date, end_date):
    """
    Query orders from DynamoDB between two dates.

    Parameters:
    - start_date (str): Start date in YYYY-MM-DD format
    - end_date (str): End date in YYYY-MM-DD format

    Returns:
    - List of order items from DynamoDB
    """

    # Perform query operation on DynamoDB
    # Uses Global Secondary Index (GSI): order_date-index
    # This index MUST exist on the CafeOrders table
    response = table.query(
        IndexName='order_date-index',

        # Fetch only items where order_date is between start_date and end_date
        KeyConditionExpression='order_date BETWEEN :s AND :e',

        # Expression values used in KeyConditionExpression
        ExpressionAttributeValues={
            ':s': start_date,   # Start date boundary
            ':e': end_date      # End date boundary
        }
    )

    # Return the list of matching order records
    return response['Items']
```

#### 📌 Notes:

- start_date and end_date must be strings

- Format: "YYYY-MM-DD"

- This code assumes GSI already exists

#### 2️⃣ TEST QUERY USING AWS LAMBDA (TEMP TEST)

#### 2️⃣ Paste Test Code

```
import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('CafeOrders')

def lambda_handler(event, context):
    result = table.query(
        IndexName='order_date-index',
        KeyConditionExpression='order_date BETWEEN :s AND :e',
        ExpressionAttributeValues={
            ':s': '2026-01-01',
            ':e': '2026-01-31'
        }
    )

    return {
        "statusCode": 200,
        "body": json.dumps({
            "count": len(result['Items']),
            "items": result['Items']
        })
    }
```

#### ✅ FINAL UPDATED CODE 

> **(Same Logic + Comments + Env Variables)**

👉 You can copy–paste this directly 

```
import json
import boto3
import os

# ==============================
# ENVIRONMENT VARIABLES
# ==============================
# 🔁 REPLACE in Lambda → Configuration → Environment variables
# TABLE_NAME        = CafeOrders
# DATE_INDEX_NAME   = order_date-index
# DEFAULT_START_DATE = 2026-01-01
# DEFAULT_END_DATE   = 2026-01-31

TABLE_NAME = os.environ.get('TABLE_NAME', 'CafeOrders')
DATE_INDEX = os.environ.get('DATE_INDEX_NAME', 'order_date-index')
START_DATE = os.environ.get('DEFAULT_START_DATE', '2026-01-01')
END_DATE = os.environ.get('DEFAULT_END_DATE', '2026-01-31')

# ==============================
# AWS DYNAMODB RESOURCE
# ==============================
# Uses IAM role attached to Lambda
dynamodb = boto3.resource('dynamodb')

# Connect to CafeOrders table
table = dynamodb.Table(TABLE_NAME)

# ==============================
# LAMBDA HANDLER
# ==============================

def lambda_handler(event, context):
    """
    This Lambda:
    - Queries CafeOrders table
    - Uses order_date GSI
    - Fetches orders between start & end dates
    - Returns order count + items
    """

    # ==============================
    # OPTIONAL: DATE OVERRIDE FROM QUERY STRING
    # ==============================
    # Example:
    # /analytics?start=2026-01-01&end=2026-01-31
    params = event.get('queryStringParameters') or {}

    start_date = params.get('start', START_DATE)
    end_date = params.get('end', END_DATE)

    # ==============================
    # DYNAMODB QUERY
    # ==============================
    result = table.query(
        IndexName=DATE_INDEX,  # GSI on order_date
        KeyConditionExpression='order_date BETWEEN :s AND :e',
        ExpressionAttributeValues={
            ':s': start_date,
            ':e': end_date
        }
    )

    # ==============================
    # RESPONSE
    # ==============================
    return {
        "statusCode": 200,
        "headers": {
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps({
            "count": len(result.get('Items', [])),  # Total orders found
            "start_date": start_date,
            "end_date": end_date,
            "items": result.get('Items', [])
        })
    }
```

**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---

## PHASE 2️⃣ – ANALYTICS LAMBDA (FULL CODE)

### 1️⃣ Create Cafe Analytics Lambda

### 2️⃣ DEPLOY CODE

**FULL CafeAnalyticsLambda PYTHON CODE (COPY-PASTE)**

```
import os
import json
import boto3
from datetime import datetime, timedelta

# =======================
# ENVIRONMENT VARIABLE
# =======================
# REPLACE VALUE IN LAMBDA ENV VARIABLES (NOT HERE)
ORDERS_TABLE_NAME = os.environ.get("ORDERS_TABLE_NAME")

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(ORDERS_TABLE_NAME)

def lambda_handler(event, context):

    period = event.get("queryStringParameters", {}).get("period")
    today = datetime.utcnow().date()

    if period == "today":
        start = end = today
    elif period == "week":
        start = today - timedelta(days=7)
        end = today
    elif period == "month":
        start = today.replace(day=1)
        end = today
    else:
        return response(400, {"message": "Invalid period"})

    orders = table.query(
        IndexName="order_date-index",
        KeyConditionExpression="order_date BETWEEN :s AND :e",
        ExpressionAttributeValues={
            ":s": str(start),
            ":e": str(end)
        }
    ).get("Items", [])

    total_sales = sum(float(o.get("total_amount", 0)) for o in orders)
    total_cost = sum(float(o.get("total_cost", 0)) for o in orders)
    profit = total_sales - total_cost

    return response(200, {
        "total_sales": total_sales,
        "total_cost": total_cost,
        "profit": profit,
        "orders_count": len(orders)
    })

def response(code, body):
    return {
        "statusCode": code,
        "headers": {
            "Access-Control-Allow-Origin": "*",
            "Content-Type": "application/json"
        },
        "body": json.dumps(body)
    }
```

#### ✅ FINAL ANALYTICS LAMBDA (WITH COMMENTS ONLY)

🔒 Logic unchanged

🧠 Architecture unchanged

📝 Only comments added

🌱 Environment variable usage clarified

```
import os
import json
import boto3
from datetime import datetime, timedelta

# ==========================================================
# ENVIRONMENT VARIABLES
# ==========================================================
# ⚠️ DO NOT hardcode table names here
# You MUST define this key in Lambda → Configuration → Environment variables
#
# Key   : ORDERS_TABLE_NAME
# Value : CafeOrders   (example – replace with your actual table name)
#
ORDERS_TABLE_NAME = os.environ.get("ORDERS_TABLE_NAME")

# ==========================================================
# DYNAMODB CLIENT INITIALIZATION
# ==========================================================
# Uses IAM Role attached to Lambda
# Make sure the role has DynamoDB read permission
#
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(ORDERS_TABLE_NAME)

# ==========================================================
# MAIN LAMBDA HANDLER
# ==========================================================
def lambda_handler(event, context):

    # ------------------------------------------------------
    # READ QUERY PARAMETER (?period=today|week|month)
    # ------------------------------------------------------
    # This comes from API Gateway request:
    # /analytics?period=today
    #
    period = event.get("queryStringParameters", {}).get("period")

    # ------------------------------------------------------
    # USE UTC DATE FOR CONSISTENT REPORTING
    # ------------------------------------------------------
    today = datetime.utcnow().date()

    # ------------------------------------------------------
    # DATE RANGE SELECTION BASED ON PERIOD
    # ------------------------------------------------------
    if period == "today":
        start = end = today

    elif period == "week":
        # Last 7 days including today
        start = today - timedelta(days=7)
        end = today

    elif period == "month":
        # From 1st day of current month to today
        start = today.replace(day=1)
        end = today

    else:
        # Invalid or missing period
        return response(400, {"message": "Invalid period"})

    # ------------------------------------------------------
    # QUERY DYNAMODB USING GSI (order_date-index)
    # ------------------------------------------------------
    # REQUIREMENTS:
    # - GSI name must be exactly: order_date-index
    # - Partition key: order_date (String, YYYY-MM-DD)
    #
    orders = table.query(
        IndexName="order_date-index",
        KeyConditionExpression="order_date BETWEEN :s AND :e",
        ExpressionAttributeValues={
            ":s": str(start),
            ":e": str(end)
        }
    ).get("Items", [])

    # ------------------------------------------------------
    # CALCULATE TOTAL SALES, COST, AND PROFIT
    # ------------------------------------------------------
    # total_amount → selling price (already stored)
    # total_cost   → cost auto-calculated (Phase 10)
    #
    total_sales = sum(float(o.get("total_amount", 0)) for o in orders)
    total_cost = sum(float(o.get("total_cost", 0)) for o in orders)

    # PROFIT = SALES - COST
    profit = total_sales - total_cost

    # ------------------------------------------------------
    # FINAL API RESPONSE
    # ------------------------------------------------------
    return response(200, {
        "total_sales": total_sales,
        "total_cost": total_cost,
        "profit": profit,
        "orders_count": len(orders)
    })

# ==========================================================
# STANDARD API RESPONSE FORMATTER
# ==========================================================
def response(code, body):
    return {
        "statusCode": code,
        "headers": {
            # Allow frontend (CloudFront / browser) access
            "Access-Control-Allow-Origin": "*",
            "Content-Type": "application/json"
        },
        "body": json.dumps(body)
    }
```

---

## PHASE 5️⃣  ☕ MULTI-PAGE SUPPORT PDF GENERATION LAMBDA (REPORTLAB)

### 📄 Printing System 2 — Server PDF (Lambda + ReportLab)

> **(PHASE 5 & 6)**

### 1️⃣ Create Cafe PDF Report Lambda

#### 1️⃣ UPDATED CafePDFReportLambda FULL PYTHON CODE (PDF for BOTH PAGES)

```
import os
import boto3
import io
import datetime
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Image, Spacer
from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet

# =======================
# ENVIRONMENT VARIABLES
# =======================
# REPLACE VALUES IN LAMBDA ENV VARIABLES (NOT HERE)
ORDERS_TABLE_NAME = os.environ.get("ORDERS_TABLE_NAME")
REPORTS_BUCKET_NAME = os.environ.get("REPORTS_BUCKET_NAME")
LOGO_FILE_NAME = os.environ.get("LOGO_FILE_NAME", "")

# =======================
# AWS CLIENTS
# =======================
dynamodb = boto3.resource("dynamodb")
orders_table = dynamodb.Table(ORDERS_TABLE_NAME)

s3 = boto3.client("s3")

def lambda_handler(event, context):

    page_type = event.get("queryStringParameters", {}).get("page", "analytics")
    today = datetime.date.today()

    buffer = io.BytesIO()
    doc = SimpleDocTemplate(
        buffer,
        pagesize=A4,
        rightMargin=40,
        leftMargin=40,
        topMargin=40,
        bottomMargin=40
    )

    styles = getSampleStyleSheet()
    elements = []

    # =======================
    # LOGO (OPTIONAL)
    # =======================
    if LOGO_FILE_NAME:
        try:
            elements.append(Image(LOGO_FILE_NAME, width=120, height=60))
            elements.append(Spacer(1, 20))
        except:
            pass

    # =======================
    # ANALYTICS PDF
    # =======================
    if page_type == "analytics":

        elements.append(Paragraph("📊 Cafe Sales Analytics Report", styles["Title"]))
        elements.append(Paragraph(f"Generated: {today}", styles["Normal"]))
        elements.append(Spacer(1, 15))

        # Placeholder analytics (can be replaced later)
        total_sales = 12000
        total_cost = 8000
        profit = total_sales - total_cost

        data = [
            ["Metric", "Amount"],
            ["Total Sales", total_sales],
            ["Total Cost", total_cost],
            ["Profit", profit]
        ]

        table = Table(data, colWidths=[200, 150])
        table.setStyle(TableStyle([
            ("BACKGROUND", (0,0), (-1,0), colors.brown),
            ("TEXTCOLOR", (0,0), (-1,0), colors.whitesmoke),
            ("ALIGN", (0,0), (-1,-1), "CENTER"),
            ("GRID", (0,0), (-1,-1), 1, colors.black),
            ("BACKGROUND", (0,1), (-1,-1), colors.beige)
        ]))

        elements.append(table)

    # =======================
    # ORDER STATUS PDF
    # =======================
    elif page_type == "order-status":

        elements.append(Paragraph("📝 Cafe Order Status Report", styles["Title"]))
        elements.append(Paragraph(f"Generated: {today}", styles["Normal"]))
        elements.append(Spacer(1, 15))

        orders = orders_table.scan().get("Items", [])

        table_data = [["Order ID", "Item", "Qty", "Cost", "Price", "Profit"]]

        for o in orders:
            qty = int(o.get("quantity", 1))
            cost = float(o.get("item_cost", 0)) * qty
            price = float(o.get("item_price", 0)) * qty
            profit = price - cost

            table_data.append([
                o.get("order_id"),
                o.get("item_name"),
                qty,
                cost,
                price,
                profit
            ])

        table = Table(table_data, colWidths=[80, 110, 50, 60, 60, 60])
        table.setStyle(TableStyle([
            ("BACKGROUND", (0,0), (-1,0), colors.darkblue),
            ("TEXTCOLOR", (0,0), (-1,0), colors.whitesmoke),
            ("ALIGN", (0,0), (-1,-1), "CENTER"),
            ("GRID", (0,0), (-1,-1), 0.5, colors.black),
            ("BACKGROUND", (0,1), (-1,-1), colors.lightgrey)
        ]))

        elements.append(table)

    # =======================
    # BUILD PDF
    # =======================
    doc.build(elements)

    buffer.seek(0)

    s3_key = f"{page_type}_report_{today}.pdf"

    s3.put_object(
        Bucket=REPORTS_BUCKET_NAME,
        Key=s3_key,
        Body=buffer.getvalue(),
        ContentType="application/pdf"
    )

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/pdf"},
        "body": buffer.getvalue().decode("latin1"),
        "isBase64Encoded": False
    }
```

---
## PHASE 1️⃣4️⃣  DAILY AUTO PDF WITH TABLES & LOGO

### 8️⃣ REPLACE LAMBDA CODE (FULL FINAL CODE)

> **⚠️ DELETE ALL EXISTING CODE FIRST**

Then PASTE EVERYTHING BELOW
#### 1️⃣ FINAL PDF GENERATION LAMBDA (COPY-PASTE SAFE)

```
import boto3
import datetime
import os
from reportlab.platypus import SimpleDocTemplate, Table, Image, Spacer
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet

# =========================
# 🔹 ENVIRONMENT VARIABLES
# Set these in Lambda console under Configuration → Environment Variables
# KEY                 VALUE
# BUCKET_NAME          charlie-cafe-s3-bucket
# LOGO_KEY             Cafelogo.png
# DYNAMODB_TABLE       CafeOrders
# AWS_REGION           ap-south-1
# =========================

BUCKET_NAME = os.environ.get("BUCKET_NAME", "charlie-cafe-s3-bucket")
LOGO_KEY = os.environ.get("LOGO_KEY", "Cafelogo.png")
DYNAMODB_TABLE = os.environ.get("DYNAMODB_TABLE", "CafeOrders")
AWS_REGION = os.environ.get("AWS_REGION", "ap-south-1")

# =========================
# 🔹 Initialize AWS clients
# =========================
s3 = boto3.client("s3", region_name=AWS_REGION)
dynamodb = boto3.resource("dynamodb", region_name=AWS_REGION)
table = dynamodb.Table(DYNAMODB_TABLE)

def lambda_handler(event, context):
    """
    Lambda handler to generate daily PDF report for Cafe
    Includes: Logo, Table of Sales, Cost, Profit per Item
    Uploads PDF to S3 at: s3://<BUCKET_NAME>/daily_reports/daily_<YYYY-MM-DD>.pdf
    """

    # -------------------------
    # 🔹 Prepare PDF filename
    # Using /tmp folder in Lambda
    # -------------------------
    today = datetime.date.today().isoformat()  # YYYY-MM-DD
    pdf_path = f"/tmp/daily_report_{today}.pdf"

    # -------------------------
    # 🔹 Fetch orders from DynamoDB
    # Only include COMPLETED orders
    # -------------------------
    response = table.scan()  # Full scan (for small datasets)
    items = response.get("Items", [])

    profit_items = []

    for i in items:
        if i.get("order_status") != "COMPLETED":
            continue  # Skip cancelled or pending orders

        qty = int(i["quantity"])  # Order quantity
        sales = float(i["item_price"]) * qty  # Total sales
        cost = float(i["item_cost"]) * qty    # Total cost

        # Append item-level profit details
        profit_items.append({
            "item": i["item_name"],
            "quantity": qty,
            "sales": round(sales, 2),
            "cost": round(cost, 2),
            "profit": round(sales - cost, 2)
        })

    # -------------------------
    # 🔹 Create PDF document
    # -------------------------
    doc = SimpleDocTemplate(pdf_path, pagesize=A4)
    styles = getSampleStyleSheet()  # default styles
    elements = []

    # -------------------------
    # 🔹 Download logo from S3 to /tmp
    # -------------------------
    logo_path = "/tmp/logo.png"
    s3.download_file(BUCKET_NAME, LOGO_KEY, logo_path)

    # Add logo to PDF
    elements.append(Image(logo_path, width=120, height=60))
    elements.append(Spacer(1, 20))  # Space after logo

    # -------------------------
    # 🔹 Prepare table data
    # -------------------------
    table_data = [["Item", "Qty", "Sales", "Cost", "Profit"]]

    for p in profit_items:
        table_data.append([
            p["item"],
            p["quantity"],
            p["sales"],
            p["cost"],
            p["profit"]
        ])

    # Add table to PDF
    elements.append(Table(table_data))

    # Build PDF
    doc.build(elements)

    # -------------------------
    # 🔹 Upload PDF to S3
    # -------------------------
    s3.upload_file(
        pdf_path,
        BUCKET_NAME,
        f"daily_reports/daily_{today}.pdf"
    )

    # -------------------------
    # 🔹 Return success response
    # -------------------------
    return {
        "statusCode": 200,
        "body": f"PDF generated and uploaded: daily_{today}.pdf"
    }
```

---


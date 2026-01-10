# AWS CAFE LAB

# 🔒 SECTION 5 — ORDER STATUS DASHBOARD

### 🎯 WHAT YOU WANT (CLARIFIED)

#### You want a new frontend page:

```
/order-status
```

#### That shows:

✅ Total orders count

✅ Orders synced through:

- API Gateway

- Lambda

- SQS

- RDS

- DynamoDB

  ✅ Date & time per order

  ✅ Auto-updated (near real-time)

  ✅ Existing order system remains UNTOUCHED

### 🧠 IMPORTANT REALITY CHECK

**You cannot directly “count” orders from SQS because:**

**🔴 SQS is a temporary transport layer**
**Messages are deleted after processing**

#### So in real systems:

- RDS = Source of truth (orders history)

- DynamoDB = Fast counters / dashboard cache

- SQS = Invisible to users (internal)

✔️ This is NORMAL and CORRECT architecture.



### 🏆 RECOMMENDED DESIGN (PRODUCTION)

✅ RDS = Order Records

✅ DynamoDB = Order Counters + Status

✅ Lambda = Aggregator

✅ API Gateway = Dashboard API

✅ Frontend = Order Status Page

### 📐 FINAL ARCHITECTURE (ORDER STATUS DASHBOARD)

```
Browser (order-status.html)
      |
      |--> API Gateway /order-status
              |
              |--> Lambda (OrderStatusLambda)
                      |
                      |--> RDS (orders table)
                      |--> DynamoDB (order_metrics)
```

##  PHASE 1️⃣ — RDS DATABASE

### 1️⃣ ADD DATE & TIME TO RDS (NO SKIP)

#### 1️⃣ Connect to RDS

#### From EC2 or local MySQL client:

```
mysql -h <rds-endpoint> -u cafe_user -p cafe_db
```

#### You should see:

```
mysql>
```
#### 2️⃣ Check current table

```
DESCRIBE orders;
```

#### ❗ Look carefully

- If you do NOT see created_at → continue
- If you already see it → skip to Step 2



#### 3️⃣ Add created_at column

```
ALTER TABLE orders
ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
```

✔️ No breaking change

✔️ Automatically tracks date & time

#### 4️⃣ VERIFY (MANDATORY)

```
DESCRIBE orders;
```

#### You MUST see:

```
created_at | timestamp | DEFAULT CURRENT_TIMESTAMP
```

✅ Phase 1 complete

---

##  PHASE 2️⃣ — DYNAMODB METRICS TABLE (FULL)

### 1️⃣ Open DynamoDB Console

#### AWS Console → DynamoDB → Tables → Create table

### 2️⃣ CREATE DYNAMODB METRICS TABLE

#### 1️⃣ Table configuration

| Field         | Value              |
| ------------- | ------------------ |
| Table name    | `CafeOrderMetrics` |
| Partition key | `metric` (String)  |
| Sort key      | ❌ None             |
| Table class   | Standard           |
| Capacity      | On-demand          |
| Encryption    | Default            |

#### Sample items:

```
{ "metric": "TOTAL_ORDERS", "count": 120 }
{ "metric": "TODAY_ORDERS", "count": 25 }
```

Click Create table

**🕐 WAIT until status = ACTIVE**

### 3️⃣ Insert initial items (VERY IMPORTANT)

**Click table → Explore table → Create item**

#### Item 1

```
{
  "metric": {
    "S": "TOTAL_ORDERS"
  },
  "count": {
    "N": "0"
  }
}
```

Click Create item

#### Item 2

```
{
  "metric": {
    "S": "TOTAL_ORDERS"
  },
  "count": {
    "N": "0"
  }
}
```

Click Create item

✅ Phase 2 complete

---

##  PHASE 3️⃣ IAM ROLE CHECK (DO THIS FIRST)

### 1️⃣ Worker Lambda IAM Role

**Make sure Worker Lambda Role has:**

```
AmazonDynamoDBFullAccess
AWSSecretsManagerReadOnly
AmazonSQSFullAccess
```

(or scoped policies if you prefer)

### 2️⃣  IAM Role Policy

- **AWS Console → IAM → Policies**

- Click Create policy

- Select JSON

- Paste EXACTLY THIS (no changes):

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ],
      "Resource": "*"
    }
  ]
}
```

#### ✅ This allows:

- Read secret value

- Describe secret

- ❌ No delete

- ❌ No update

Click Next

### Policy name:

```




---

##  PHASE 4️⃣ — UPDATE WORKER LAMBDA (SAFE & EXACT)

#### ⚠️ This step is inside existing Worker Lambda, NOT API Lambda.

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

### ✅ FINAL WORKER LAMBDA CODE

#### Below is the FINAL, READY-TO-DEPLOY Worker Lambda code with:

✅ Your existing logic untouched

✅ Order metrics added safely

✅ Correct placement (TOP + AFTER DB insert)

✅ SQS-safe error handling

```
import json
import boto3
import pymysql
from decimal import Decimal

# ---------- AWS CLIENTS ----------
secrets_client = boto3.client('secretsmanager')
dynamodb = boto3.resource('dynamodb')

# ---------- CONSTANTS ----------
SECRET_NAME = "CafeDevDBSM"
DYNAMODB_TABLE = "CafeMenu"
METRICS_TABLE = "CafeOrderMetrics"

# ---------- DYNAMODB TABLES ----------
menu_table = dynamodb.Table(DYNAMODB_TABLE)
metrics_table = dynamodb.Table(METRICS_TABLE)   # 👈 (STEP 3.2 — TOP ADDITION)

# ---------- GET DB CREDS ----------
def get_db_secret():
    print("Fetching DB secret...")
    response = secrets_client.get_secret_value(SecretId=SECRET_NAME)
    return json.loads(response["SecretString"])

# ---------- LAMBDA HANDLER ----------
def lambda_handler(event, context):

    print("Lambda triggered by SQS")
    print("Event:", event)

    secret = get_db_secret()

    connection = pymysql.connect(
        host=secret["host"],
        user=secret["username"],
        password=secret["password"],
        database=secret["dbname"],
        connect_timeout=10
    )

    try:
        with connection.cursor() as cursor:
            for record in event["Records"]:

                # ---------- PARSE SQS MESSAGE ----------
                order = json.loads(record["body"])
                customer_name = order["customer_name"]
                item = order["item"]
                quantity = int(order["quantity"])

                # ---------- INSERT INTO RDS ----------
                cursor.execute(
                    "INSERT INTO orders (customer_name, item, quantity) VALUES (%s, %s, %s)",
                    (customer_name, item, quantity)
                )
                connection.commit()

                # ---------- UPDATE DYNAMODB MENU ----------
                menu_table.update_item(
                    Key={"item": item},
                    UpdateExpression="ADD orders :inc",
                    ExpressionAttributeValues={":inc": Decimal(quantity)}
                )

                # ---------- UPDATE ORDER METRICS ----------
                metrics_table.update_item(
                    Key={"metric": "TOTAL_ORDERS"},
                    UpdateExpression="ADD #c :inc",
                    ExpressionAttributeNames={"#c": "count"},
                    ExpressionAttributeValues={":inc": Decimal(1)}
                )

                print("✅ Order processed successfully:", order)

        return {"statusCode": 200}

    except Exception as e:
        print("❌ FATAL ERROR:", str(e))
        raise e   # 🚨 REQUIRED so SQS retries on failure
```


**Click Deploy**

✔️ RDS remains main source

✔️ DynamoDB gives fast counters

### 3️⃣ IAM ROLE CHECK (DO THIS FIRST)

Make sure Worker Lambda Role has:

### 4️⃣ VERIFY THIS STEP

1️⃣ Place one new order

2️⃣ Go to DynamoDB → CafeOrderMetrics

3️⃣ Open TOTAL_ORDERS

✔ Count increased by 1

✅ Step 3 complete

### 4️⃣ CREATE ORDER STATUS LAMBDA (NEW)

#### 📢 This Lambda ONLY READS DATA.

#### 1️⃣ Create Lambda

#### AWS Console → Lambda → Create function

| Setting        | Value                                   |
| -------------- | --------------------------------------- |
| Name           | `GetOrderStatusLambda`                  |
| Runtime        | Python 3.12                             |
| Execution role | Use existing role                       |
| Role           | Same role as Worker (read-only is fine) |


#### Click Create function

#### 2️⃣ Add IAM Permissions (IMPORTANT)

#### IAM → Role → Attach policy

#### Add:

- AmazonDynamoDBReadOnlyAccess

- RDS access (same as Worker)

#### 3️⃣ Lambda Code

```
import json
import boto3
import pymysql

secrets_client = boto3.client('secretsmanager')
dynamodb = boto3.resource('dynamodb')

metrics_table = dynamodb.Table("CafeOrderMetrics")
SECRET_NAME = "CafeDevDBSM"

def get_db_secret():
    return json.loads(
        secrets_client.get_secret_value(SecretId=SECRET_NAME)["SecretString"]
    )

def lambda_handler(event, context):

    secret = get_db_secret()

    connection = pymysql.connect(
        host=secret["host"],
        user=secret["username"],
        password=secret["password"],
        database=secret["dbname"],
        connect_timeout=5,
        cursorclass=pymysql.cursors.DictCursor
    )

    metrics = metrics_table.scan()["Items"]

    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT customer_name, item, quantity, created_at
            FROM orders
            ORDER BY created_at DESC
            LIMIT 20
        """)
        orders = cursor.fetchall()

    return {
        "statusCode": 200,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": json.dumps({
            "metrics": metrics,
            "recent_orders": orders
        }, default=str)
    }
```

#### 4️⃣ Test Lambda

#### Test event:

```
{}
```

✔ Status code: 200

✔ JSON returned

✅ Step 4 complete

---
##  PHASE 4️⃣ — API GATEWAY ENDPOINT

### 1️⃣ Open API Gateway

#### API Gateway → Your API → Resources

### 2️⃣ Create API

```
GET /order-status
```

### 3️⃣ Create method

- **Method:** GET

- **Integration:** Lambda

- **Lambda name:** GetOrderStatusLambda

#### Enable:

✔ Lambda proxy

✔ CORS

### 3️⃣ Deploy API

- **Stage name:** prod

### 4️⃣ VERIFY API

#### Open browser:

```
https://API_ID.execute-api.region.amazonaws.com/prod/order-status
```

✔ JSON visible

✅ Phase 4 complete

---
##  PHASE 5️⃣ — FRONTEND ORDER STATUS PAGE

### 1️⃣ Create File

```
order-status.html
```

### 1️⃣ CODE

Paste EXACT CODE

```
<h2>📊 Cafe Order Status</h2>

<div id="metrics"></div>

<table border="1">
<tr>
  <th>Customer</th>
  <th>Item</th>
  <th>Qty</th>
  <th>Date</th>
</tr>
<tbody id="orders"></tbody>
</table>

<script>
fetch("https://API_ID.execute-api.region.amazonaws.com/prod/order-status")
.then(res => res.json())
.then(data => {
  data.metrics.forEach(m => {
    document.getElementById("metrics").innerHTML +=
      `<p><b>${m.metric}</b>: ${m.count}</p>`;
  });

  data.recent_orders.forEach(o => {
    document.getElementById("orders").innerHTML += `
      <tr>
        <td>${o.customer_name}</td>
        <td>${o.item}</td>
        <td>${o.quantity}</td>
        <td>${o.created_at}</td>
      </tr>`;
  });
});
</script>
```

### 2️⃣ Open page in browser

✔ Orders visible

✔ Counts visible

✔ Date/time visible

✅ Step 5 complete

---

##  PHASE 6️⃣ — VERIFICATION CHECKLIST

### 1️⃣ Send order from frontend / API

✔ Order placed

### 2️⃣ Check SQS

✔ Message disappears (consumed)

### 3️⃣ Check RDS

```
SELECT * FROM orders ORDER BY created_at DESC;
```

✔ New row present

### 4️⃣ Check DynamoDB → CafeMenu

✔ orders increased for item

### 5️⃣ Check DynamoDB → CafeOrderMetrics

✔ TOTAL_ORDERS increased by 1

### 6️⃣ Check CloudWatch Logs

✔ "Order processed successfully"

### 🏆 RESULT

You now have:

✅ Event-driven backend

✅ Reliable order processing

✅ Real-time metrics

✅ Production-safe SQS worker

✅ Zero backend breakage

---

### 🧪 FINAL VERIFICATION

| Check                     | Result |
| ------------------------- | ------ |
| Place new order           | ✅      |
| RDS updated               | ✅      |
| DynamoDB count +1         | ✅      |
| Order-status page updated | ✅      |

---




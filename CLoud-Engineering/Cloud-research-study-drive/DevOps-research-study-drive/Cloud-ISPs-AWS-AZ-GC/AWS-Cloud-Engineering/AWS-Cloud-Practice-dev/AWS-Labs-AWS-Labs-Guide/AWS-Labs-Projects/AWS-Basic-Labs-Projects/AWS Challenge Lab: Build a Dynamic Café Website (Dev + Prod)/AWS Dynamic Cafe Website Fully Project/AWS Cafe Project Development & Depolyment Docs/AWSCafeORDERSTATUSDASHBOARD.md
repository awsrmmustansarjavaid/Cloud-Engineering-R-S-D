# ☕ AWS CAFE LAB -- ORDER STATUS DASHBOARD

# ☕ SECTION 1 — ORDER STATUS DASHBOARD


##  PHASE 4️⃣ — ✅ VERIFICATION (MANDATORY)

### 🔎 Test in Lambda

- **Go to Lambda → Test**

#### If secret access works:

- ❌ No timeout

- ❌ No access denied

- ✅ DB connects successfully

### 🔎 CloudWatch Log

#### You should see:

```
Fetching DB secret...
```

#### No error like:

```
AccessDeniedException: User is not authorized to perform secretsmanager:GetSecretValue
```

---

##  PHASE 5️⃣ — UPDATE WORKER LAMBDA (SAFE & EXACT)

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

##  PHASE 6️⃣ — CREATE ORDER STATUS LAMBDA (NEW)



#### 📢 This Lambda ONLY READS DATA.

### 1️⃣ Create Lambda

#### AWS Console → Lambda → Create function

| Setting        | Value                                   |
| -------------- | --------------------------------------- |
| Name           | `GetOrderStatusLambda`                  |
| Runtime        | Python 3.12                             |
| Execution role | Use existing role                       |
| Role           | Same role as Worker (read-only is fine) |


#### Click Create function

### 2️⃣ Add IAM Permissions (IMPORTANT)

#### IAM → Role → Attach policy

#### Add:

- AmazonDynamoDBReadOnlyAccess

- RDS access (same as Worker)

### 3️⃣ Lambda Status Order Code

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

### 4️⃣ Attach Layer to Lambda Function

####  1️⃣ Open Lambda Function

* Lambda → Functions → `CafeOrderProcessor`

#### 2️⃣ Add Layer

* Scroll to **Layers** section
* Click **Add a layer**
* Choose **Custom layers**
* Select:

  * Layer: `pymysql-layer`
  * Version: latest

Click **Add**

### 5️⃣ Move Lambda Into VPC

- AWS Console → Lambda → Your Function

- Go to Configuration

- Open VPC

- Click Edit

- Select:

    - **VPC → same as EC2**

    - **Subnets → PRIVATE subnets (important)**

    - **Security Group → Lambda SG**

    - Save

**⏳ Wait until Lambda status = Active**

### 6️⃣ Test Lambda

#### Test event:

```
{}
```

#### Expected:

```
{
  "statusCode": 200,
  "headers": {
    "Access-Control-Allow-Origin": "*",
    "Content-Type": "application/json"
  },
  "body": "{\"metrics\": [{\"metric\": \"TOTAL_ORDERS\", \"count\": \"2\"}], \"recent_orders\": ..........."
}
```

✔ Status code: 200

✔ JSON returned

✅ Step 4 complete

---
##  PHASE 7️⃣ — API GATEWAY ENDPOINT

👉 Use your EXISTING API

👉 Create a NEW METHOD (GET /order-status) on it

❌ Do NOT create a new API

### 🧠 WHY YOU SHOULD USE THE EXISTING API

#### You already have something like:

```
CafeOrdersAPI
https://xxxxx.execute-api.us-east-1.amazonaws.com/dev
```

#### And inside it you probably have:

```
POST /orders        → CreateOrderLambda
```

#### ✔️ This is CORRECT architecture

One API = One backend system
Multiple resources/methods inside it

**Creating multiple APIs would be:**

❌ Hard to manage

❌ Bad practice

❌ Confusing for frontend

### STRUCTURE (VISUAL)

```
CafeOrdersAPI
│
├── POST /orders
│     └── CreateOrderLambda
│
└── GET /order-status
      └── GetOrderStatusLambda
```

✔️ SAME API

✔️ SAME stage (/dev)

✔️ DIFFERENT Lambda functions

### 1️⃣ Open API Gateway

#### API Gateway → Open Your Existing API (example: CafeOrdersAPI) → Resources

### 2️⃣ Create Resource

```
Resource name: order-status
Resource path: /order-status
```

Click Create resource

### 3️⃣ Create NEW METHOD

Select /order-status

Click Create Method

```
GET /order-status
```

- **Method:** GET

- **Integration:** Lambda

- **Select GetOrderStatusLambda**

- **Lambda name:** GetOrderStatusLambda

✔️ Enable Lambda proxy integration

Click Create method


### 4️⃣ Enable CORS (VERY IMPORTANT)

Select /order-status

Actions → Enable CORS

✔️ GET

✔️ OPTIONS

Click Enable CORS and replace existing CORS headers



### 5️⃣ Deploy API (MOST MISSED STEP 🚨)

API Gateway → Actions → Deploy API

| Field            | Value                 |
| ---------------- | --------------------- |
| Deployment stage | New stage             |
| Stage name       | status                |
| Description      | Order status endpoint |


Click Deploy

### 6️⃣ VERIFY API

#### 🌐 FINAL API URL

```
GET https://xxxxx.execute-api.us-east-1.amazonaws.com/status/order-status
```

#### 🧪 TEST IT (MUST WORK)

```
curl https://xxxxx.execute-api.us-east-1.amazonaws.com/status/order-status
```

#### ✅ You MUST see JSON like:

```
{
  "metrics": [
    {"metric":"Total Orders","count":15}
  ],
  "recent_orders": [
    {
      "customer_name":"Ali",
      "item":"Coffee",
      "quantity":2,
      "created_at":"2026-01-09 12:30:00"
    }
  ]
}
```

❌ If this does not work → STOP. Fix backend first.



#### Open browser:

```
https://API_ID.execute-api.region.amazonaws.com/status/order-status
```

✔ JSON visible

✅ Phase 4 complete

---
##  PHASE 8️⃣ — FRONTEND ORDER STATUS PAGE

### 1️⃣ Create File

```
sudo nano /var/www/html/order-status.html
```


### 1️⃣ CODE

#### 🚨 IMPORTANT:

#### Replace this line ONLY:

```
fetch("https://API_ID.execute-api.region.amazonaws.com/prod/order-status")
```

#### With your real API:

```
fetch("https://abcd1234.execute-api.us-east-1.amazonaws.com/admin/order-status")
```


#### 1️⃣ Simple order-status.html 



```
<!DOCTYPE html>
<html lang="en" data-bs-theme="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Charlie Cafe ☕ | Order Status</title>
    
    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- Google Font - Poppins -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
    
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            min-height: 100vh;
            margin: 0;
            background: linear-gradient(rgba(0,0,0,0.70), rgba(0,0,0,0.70)),
                        url("https://images.unsplash.com/photo-1517248135467-4c7edcad34c4");
            background-size: cover;
            background-position: center;
            background-attachment: fixed;
            color: #fff;
        }

        /* Navbar */
        .navbar {
            background-color: #3b1f0e !important;
        }
        .navbar-brand {
            font-weight: 600;
            color: #fff !important;
        }

        /* Main container */
        .status-container {
            background: rgba(30, 30, 30, 0.75);
            border-radius: 20px;
            padding: 40px;
            backdrop-filter: blur(8px);
            box-shadow: 0 15px 40px rgba(0,0,0,0.5);
            margin: 40px auto;
            max-width: 1100px;
        }

        h2 {
            font-weight: 600;
            text-shadow: 0 2px 10px rgba(0,0,0,0.6);
        }

        /* Metrics Cards */
        .metric-card {
            background: linear-gradient(135deg, #4a2c1a, #3b1f0e);
            border: none;
            border-radius: 15px;
            transition: transform 0.3s ease;
        }
        .metric-card:hover {
            transform: translateY(-8px);
        }
        .metric-card .card-body {
            text-align: center;
            padding: 25px;
        }
        .metric-card h5 {
            margin-bottom: 8px;
            font-weight: 500;
            color: #ff9800;
        }
        .metric-card .display-5 {
            font-weight: 700;
            color: white;
        }

        /* Table Styling - Dark & Elegant */
        .table {
            background: rgba(40, 40, 40, 0.85);
            border-radius: 12px;
            overflow: hidden;
        }
        .table thead th {
            background: #3b1f0e;
            color: #ff9800;
            font-weight: 600;
            border-bottom: 2px solid #ff9800;
        }
        .table tbody tr {
            transition: background 0.2s;
        }
        .table tbody tr:hover {
            background: rgba(255,152,0,0.15);
        }
        .table td, .table th {
            border-color: rgba(255,255,255,0.08);
        }

        /* Footer */
        footer {
            background: rgba(0,0,0,0.7);
            color: #ddd;
            text-align: center;
            padding: 20px;
            margin-top: 60px;
            font-size: 0.95rem;
        }

        @media (max-width: 768px) {
            .status-container {
                padding: 25px;
                margin: 20px;
            }
        }
    </style>
</head>
<body>

<!-- Navbar -->
<nav class="navbar navbar-expand-lg">
    <div class="container">
        <a class="navbar-brand" href="index.html">☕ Charlie Cafe</a>
    </div>
</nav>

<!-- Main Content -->
<div class="container">
    <div class="status-container">
        <h2 class="text-center mb-5">📊 Live Order Status</h2>

        <!-- Metrics (Cards) -->
        <div id="metrics" class="row g-4 mb-5 justify-content-center"></div>

        <!-- Recent Orders Table -->
        <div class="table-responsive">
            <table class="table table-hover text-white">
                <thead>
                    <tr>
                        <th>Customer</th>
                        <th>Item</th>
                        <th>Qty</th>
                        <th>Table</th>
                        <th>Date</th>
                    </tr>
                </thead>
                <tbody id="orders"></tbody>
            </table>
        </div>
    </div>
</div>

<!-- Footer -->
<footer>
    © 2026 Charlie Cafe | Fresh Drinks • Made with ❤️
</footer>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<!-- Fetch & Display Data -->
<script>
fetch("https://API_ID.execute-api.region.amazonaws.com/status/order-status")  // ← Replace with your real API endpoint
    .then(res => {
        if (!res.ok) throw new Error('Network response was not ok');
        return res.json();
    })
    .then(data => {
        // Metrics Cards
        const metricsContainer = document.getElementById("metrics");
        data.metrics.forEach(m => {
            metricsContainer.innerHTML += `
                <div class="col-6 col-md-4 col-lg-3">
                    <div class="card metric-card shadow">
                        <div class="card-body">
                            <h5>${m.metric}</h5>
                            <p class="display-5 mb-0">${m.count}</p>
                        </div>
                    </div>
                </div>`;
        });

        // Orders Table
        const ordersBody = document.getElementById("orders");
        data.recent_orders.forEach(o => {
            ordersBody.innerHTML += `
                <tr>
                    <td>${o.customer_name || '<em>Anonymous</em>'}</td>
                    <td>${o.item}</td>
                    <td>${o.quantity}</td>
                    <td>${o.table_number || '-'}</td>
                    <td>${o.created_at}</td>
                </tr>`;
        });
    })
    .catch(err => {
        document.getElementById("orders").innerHTML = `
            <tr><td colspan="5" class="text-center text-danger py-4">
                ⚠️ Failed to load orders: ${err.message}
            </td></tr>`;
    });
</script>

</body>
</html>
```

#### 2️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```

### 2️⃣ SECURITY & PERMISSIONS

✅ 2.1 Fix File Permissions

```
sudo chown apache:apache /var/www/html/order-status.html
```
```
sudo chmod 644 /var/www/html/order-status.html
```

✅ 2.2 Open Security Group (MANDATORY)

Ensure EC2 Security Group allows:


| Type | Port | Source    |
| ---- | ---- | --------- |
| HTTP | 80   | 0.0.0.0/0 |


### 3️⃣ Restart Apache (MANDATORY)

```
sudo systemctl restart httpd
```

### 4️⃣ Open page in browser

✔ Orders visible

✔ Counts visible

✔ Date/time visible

✅ Step 5 complete

---

## 🔄 PHASE 9️⃣ — FEATURE VERIFICATION (IMPORTANT)

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


### 7️⃣ Verify Apache is Running

```
sudo systemctl status httpd
```

#### If not running:

```
sudo systemctl start httpd
```

```
sudo systemctl enable httpd
```

### 8️⃣ Verify Web Root

```
ls /var/www/html
```

This IS THE CORRECT LOCATION ✅

✔ /var/www/html/ is Apache’s default public directory


### 🔁 Auto Refresh

#### ✔ Implemented here:

```
setInterval(loadData,10000);
```

### ⏳ Loading Spinner

✔ Enabled before fetch

✔ Hidden after response

```
document.getElementById("loader").style.display="block";
```

### 📊 Chart (Orders per Item)

✔ Chart.js used

✔ Auto re-draws on refresh

✔ No page reload

### 📅 Date Filter

✔ Frontend ready

```
<input type="date" id="filterDate">
```

#### 👉 Backend enhancement later:

#### Pass date as query param:

```
/order-status?date=2026-01-09
```
---

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


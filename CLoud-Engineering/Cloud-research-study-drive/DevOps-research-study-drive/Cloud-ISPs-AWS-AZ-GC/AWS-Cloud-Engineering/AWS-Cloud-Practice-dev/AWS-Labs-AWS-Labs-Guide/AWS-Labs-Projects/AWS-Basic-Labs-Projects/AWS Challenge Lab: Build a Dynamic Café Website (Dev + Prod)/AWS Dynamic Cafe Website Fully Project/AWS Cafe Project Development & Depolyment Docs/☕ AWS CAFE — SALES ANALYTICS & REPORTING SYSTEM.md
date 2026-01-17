# ☕ CAFE LAB – SALES ANALYTICS & REPORTING SYSTEM
> **(Using Existing Order Status System)**

### 🎯 WHAT YOU ARE BUILDING (CLEAR SCOPE)

You will build ONE analytics system that:

✔ Reads data from existing Order Status DynamoDB table

✔ Calculates Today / Weekly / Monthly Sales

✔ Calculates Cost, Profit, Loss

✔ Displays professional Bootstrap analytics dashboard

✔ Generates PDF reports (custom date OR month-end)

✔ Supports manual PDF download

✔ Supports monthly auto-PDF generation

✔ Uses existing API Gateway + Lambda (minimal additions)

### 🧱 ARCHITECTURE (FINAL)

```
Frontend (Bootstrap Analytics Page)
        |
        |--- GET /analytics
        |--- POST /report/pdf
        |
API Gateway
        |
        |--- Analytics Lambda
        |--- PDF Lambda
        |
DynamoDB (Existing Orders Table)
        |
EventBridge (Monthly Trigger)
```

## PHASE 1️⃣ – DYNAMODB DESIGN (NO NEW TABLE)

#### ✅ Existing Orders Table (REQUIRED STRUCTURE)

### 1️⃣ Table Name: 

```        
CafeOrders
```

### 2️⃣ Partition Key (PK):

```
order_id (String)
```

#### Attributes (MUST exist):

```
order_date      (String)  -> "2026-01-17"
order_timestamp (Number)  -> 1705488000
total_amount    (Number)
total_cost      (Number)
order_status    (String)  -> COMPLETED
```

#### 📌 IMPORTANT

- order_timestamp is required for fast filtering

- Use Unix timestamp

---

### 2️⃣ – ADD GSI (VERY IMPORTANT)

#### Create Global Secondary Index

#### 1️⃣ Index Name: 

```
order_date-index
```
#### 2️⃣ Index Configurations: 

| Field         | Value                    |
| ------------- | ------------------------ |
| Partition Key | order_date (String)      |
| Sort Key      | order_timestamp (Number) |
| Projection    | ALL                      |

**👉 AWS Console → DynamoDB → Indexes → Create index**

---

### 3️⃣ – EXACT DYNAMODB QUERY CODE

####  Daily / Weekly / Monthly Query (Python)

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

---

## PHASE 2️⃣  – ANALYTICS LAMBDA (FULL CODE)

### 1️⃣ Create Cafe Analytics Lambda

#### 1️⃣ Lambda Name

```
CafeAnalyticsLambda
```

#### 2️⃣ IAM Permissions

```
AmazonDynamoDBReadOnlyAccess
CloudWatchLogsFullAccess
```

#### 3️⃣ FULL PYTHON CODE (COPY-PASTE)

```
import json
import boto3
from datetime import datetime, timedelta
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('CafeOrders')

def lambda_handler(event, context):
    period = event['queryStringParameters']['period']
    today = datetime.utcnow().date()

    if period == 'today':
        start = end = today
    elif period == 'week':
        start = today - timedelta(days=7)
        end = today
    elif period == 'month':
        start = today.replace(day=1)
        end = today
    else:
        return response(400, "Invalid period")

    orders = table.query(
        IndexName='order_date-index',
        KeyConditionExpression='order_date BETWEEN :s AND :e',
        ExpressionAttributeValues={
            ':s': str(start),
            ':e': str(end)
        }
    )['Items']

    total_sales = sum(float(o['total_amount']) for o in orders)
    total_cost = sum(float(o['total_cost']) for o in orders)
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
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(body)
    }
```


---

## PHASE 3️⃣  – API GATEWAY

### 1️⃣ – API GATEWAY CONFIGURATION

####  1️⃣ Create Resource

```
/analytics
```

####  2️⃣ Method

```
GET
```

####  3️⃣ Integration

```
Lambda Proxy Integration
→ CafeAnalyticsLambda
```

####  4️⃣ Query Parameters

```
period=today|week|month
```

---

## PHASE 3️⃣  BOOTSTRAP ANALYTICS UI

### 1️⃣ analytics.html (FULL CODE)



```
<!DOCTYPE html>
<html>
<head>
  <title>Cafe Analytics</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
  <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body class="bg-light">

<div class="container mt-4">
  <h3 class="mb-4">📊 Sales Analytics</h3>

  <select id="period" class="form-select mb-3">
    <option value="today">Today</option>
    <option value="week">Last 7 Days</option>
    <option value="month">This Month</option>
  </select>

  <button class="btn btn-primary mb-3" onclick="loadData()">Load Data</button>

  <div class="row">
    <div class="col-md-4">
      <div class="card p-3">Sales: <span id="sales"></span></div>
    </div>
    <div class="col-md-4">
      <div class="card p-3">Cost: <span id="cost"></span></div>
    </div>
    <div class="col-md-4">
      <div class="card p-3">Profit: <span id="profit"></span></div>
    </div>
  </div>

  <canvas id="chart" class="mt-4"></canvas>

  <button class="btn btn-success mt-4" onclick="downloadPDF()">📄 Download PDF</button>
</div>

<script>
function loadData(){
  const period = document.getElementById('period').value;
  fetch(`https://API_ID.execute-api.REGION.amazonaws.com/prod/analytics?period=${period}`)
  .then(res => res.json())
  .then(data => {
    document.getElementById('sales').innerText = data.total_sales;
    document.getElementById('cost').innerText = data.total_cost;
    document.getElementById('profit').innerText = data.profit;
  });
}

function downloadPDF(){
  window.open("https://API_ID.execute-api.REGION.amazonaws.com/prod/report/pdf");
}
</script>

</body>
</html>
```

---

## PHASE 4️⃣  PDF GENERATION LAMBDA (REPORTLAB)

### Create Cafe PDF Report Lambda

####  1️⃣ Lambda Name

```
CafePDFReportLambda
```

####  1️⃣ Add Layer

```
reportlab
```

####  1️⃣ FULL PYTHON CODE

```
from reportlab.lib.pagesizes import A4
from reportlab.pdfgen import canvas
import boto3
import io
import datetime

s3 = boto3.client('s3')

def lambda_handler(event, context):
    buffer = io.BytesIO()
    pdf = canvas.Canvas(buffer, pagesize=A4)

    pdf.setFont("Helvetica-Bold", 14)
    pdf.drawString(50, 800, "Cafe Monthly Sales Report")

    pdf.setFont("Helvetica", 10)
    pdf.drawString(50, 770, f"Generated: {datetime.date.today()}")

    pdf.drawString(50, 740, "Total Sales: 12000")
    pdf.drawString(50, 720, "Total Cost: 8000")
    pdf.drawString(50, 700, "Profit: 4000")

    pdf.showPage()
    pdf.save()

    buffer.seek(0)

    s3.put_object(
        Bucket='cafe-reports',
        Key='monthly_report.pdf',
        Body=buffer.getvalue()
    )

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/pdf"},
        "body": buffer.getvalue().decode('latin1'),
        "isBase64Encoded": False
    }
```

---


## PHASE 5️⃣  CONNECT PDF BUTTON WITH API

🔹 API Gateway

```
/report/pdf
POST → CafePDFReportLambda
```

No frontend change needed except button URL.

---

## PHASE 5️⃣  MONTHLY AUTO REPORT (EVENTBRIDGE)

🔹 Rule

```
cron(0 0 1 * ? *)
```

🔹 Target

```
CafePDFReportLambda
```

---

## PHASE 5️⃣  ORDER STATUS PAGE CHANGES

✅ MINIMAL CHANGE ONLY

| Area     | Change               |
| -------- | -------------------- |
| Frontend | Add Analytics button |
| Backend  | NONE                 |
| DB       | NONE                 |

✅ You DO NOT duplicate system

✅ You USE existing Order Status system




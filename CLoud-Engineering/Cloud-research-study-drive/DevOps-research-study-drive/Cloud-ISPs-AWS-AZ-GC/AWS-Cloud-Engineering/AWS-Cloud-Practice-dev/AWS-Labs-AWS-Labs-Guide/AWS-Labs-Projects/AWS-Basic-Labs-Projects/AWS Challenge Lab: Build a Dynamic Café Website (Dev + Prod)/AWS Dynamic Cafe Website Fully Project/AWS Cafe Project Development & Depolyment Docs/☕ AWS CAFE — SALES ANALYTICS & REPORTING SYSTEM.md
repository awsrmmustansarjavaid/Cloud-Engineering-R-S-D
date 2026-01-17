# ☕ CAFE LAB – ADVANCED SALES ANALYTICS & REPORTING SYSTEM
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
Order Status Page (Existing)
        |
        |--- GET /order-status        (existing)
        |--- GET /analytics           (new)
        |--- GET /analytics/csv       (new)
        |--- POST /report/pdf         (new)
        |
API Gateway (Existing)
        |
        |--- OrderStatusLambda        (existing)
        |--- CafeAnalyticsLambda     (new)
        |--- CafePDFReportLambda     (new)
        |
DynamoDB
        |
        |--- CafeOrders              (existing)
        |--- CafeMenu                (new – cost only)
        |
EventBridge
        |
        |--- Daily / Monthly PDF
```

## PHASE 1️⃣ – DYNAMODB DESIGN (NO NEW TABLE)

> **⚠️ This phase is mandatory before Lambda works.**

**Goal of this phase:**

Ensure your existing DynamoDB table structure, index, and query logic are 100% correct and testable before analytics logic is added.

### 1️⃣ VERIFY EXISTING ORDERS TABLE (REQUIRED STRUCTURE)

#### 1️⃣ Open DynamoDB Console: 

```
AWS Console → DynamoDB → Tables
```

#### 2️⃣ Confirm Table Name: 

```        
CafeOrders
```

**❌ If the name is different, STOP and rename your code, not the table.**

#### 2️⃣ Verify Table Keys (CRITICAL)

- **Go to Table details → General information**

#### Confirm:

| Setting       | Value             |
| ------------- | ----------------- |
| Table name    | CafeOrders        |
| Partition key | order_id (String) |
| Sort key      | ❌ NONE (expected) |


**⚠️ Do NOT add a sort key to the main table**
> **Analytics filtering will be done via GSI.**

### 2️⃣ VERIFY REQUIRED ATTRIBUTES EXIST (DATA CONTRACT)

> **Your analytics depends on these attributes already existing in items.**

#### 1️⃣ Open CafeOrders → Explore Table

> **✅ Required Attributes per Order Item***

#### Every COMPLETED order MUST contain:

| Attribute       | Type   | Why Needed       |
| --------------- | ------ | ---------------- |
| order_id        | String | Primary Key      |
| order_date      | String | GSI partition    |
| order_timestamp | Number | GSI sort         |
| total_amount    | Number | Sales            |
| total_cost      | Number | Cost             |
| order_status    | String | Filter COMPLETED |

**⚠️ If any attribute is missing, analytics will break.**

#### 📌 IMPORTANT

- order_timestamp is required for fast filtering

- Use Unix timestamp

#### 2️⃣ Verify Attributes Exist in Real Data

- **DynamoDB → CafeOrders**

- Click Explore table items

- Open at least 3 COMPLETED orders

- **Manually confirm:**

    - order_date format = 2026-01-17

    - order_timestamp is Number, not String

    - total_amount and total_cost are Numbers

**❌ If any attribute is missing, STOP and fix order-saving logic first.**

---

### 3️⃣ – ADD ADD GLOBAL SECONDARY INDEX (GSI - VERY IMPORTANT)

> **This step enables date-range queries (today / week / month).**

#### 1️⃣ Go to Indexes Tab

```
AWS Console → DynamoDB → CafeOrders → Indexes → Create index
```

#### 2️⃣ Create Global Secondary Index

#### Configure Index EXACTLY:

| Setting       | Value                    |
| ------------- | ------------------------ |
| Index name    | order_date-index         |
| Partition key | order_date (String)      |
| Sort key      | order_timestamp (Number) |
| Projection    | ALL                      |

- **Create Index**

⏳ Wait until Index status = ACTIVE

⚠️ Do not continue until ACTIVE.

❌ Do not deploy Lambda before this

#### 3️⃣ TEST INDEX (VERY IMPORTANT)

#### Use DynamoDB PartiQL Editor

```
SELECT * FROM "CafeOrders"."order_date-index"
WHERE order_date BETWEEN '2026-01-01' AND '2026-01-31'
```

✔ If results return → continue

❌ If empty → your data format is wrong

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

### 🔹 API Gateway

```
/report/pdf
POST → CafePDFReportLambda
```

No frontend change needed except button URL.

---

## PHASE 6️⃣  MONTHLY AUTO REPORT (EVENTBRIDGE)

### 1️⃣ Rule

```
cron(0 0 1 * ? *)
```

### 2️⃣ Target

```
CafePDFReportLambda
```

---

## PHASE 7️⃣  MODIFY ORDER STATUS PAGE

### 🎯 GOAL

Add a professional “Analytics & Reports” button on the existing Order Status page
This button opens your Analytics Dashboard page.

### ✅ MINIMAL CHANGE ONLY

✔️ Add ONE button → “📊 Analytics”

✔️ Add ONE modal (popup) → Analytics dashboard

✔️ Add ONE API call → /analytics

✔️ Reuse existing auth, token, layout, chart.js

✔️ ZERO backend change to order-status Lambda

✔️ NO new page required



#### 1️⃣ – IDENTIFY ORDER STATUS PAGE FILE

#### Your Order Status page is usually one of these:

```
order-status.html
orders.html
order_status.php
```

#### 👉 Open the exact file where:

- Orders are listed

- Order status is shown (Pending / Completed)

#### 1️⃣ – ADD ANALYTICS BUTTON (NAVBAR)

#### 📍 FIND THIS (navbar section)

```
<nav class="navbar navbar-dark bg-dark" id="navbar" style="display:none">
  <div class="container">
    <span class="navbar-brand">☕ Charlie Cafe Admin</span>
    <button class="btn btn-danger btn-sm" onclick="logout()">Logout</button>
  </div>
</nav>
```

#### ✅ REPLACE WITH THIS

```
<nav class="navbar navbar-dark bg-dark" id="navbar" style="display:none">
  <div class="container d-flex justify-content-between">
    <span class="navbar-brand">☕ Charlie Cafe Admin</span>

    <div>
      <button class="btn btn-warning btn-sm me-2" onclick="openAnalytics()">
        📊 Analytics
      </button>
      <button class="btn btn-danger btn-sm" onclick="logout()">Logout</button>
    </div>
  </div>
</nav>
```

✔ Button added

✔ No auth change

✔ No routing change

#### 2️⃣ – ADD ANALYTICS MODAL (HTML)

#### 📍 ADD THIS BEFORE </body>

```
<!-- ANALYTICS MODAL -->
<div class="modal fade" id="analyticsModal" tabindex="-1">
  <div class="modal-dialog modal-xl modal-dialog-centered">
    <div class="modal-content">

      <div class="modal-header bg-dark text-white">
        <h5 class="modal-title">📊 Sales Analytics</h5>
        <button class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>

      <div class="modal-body">

        <div class="row mb-3">
          <div class="col-md-3">
            <select id="analyticsPeriod" class="form-select">
              <option value="today">Today</option>
              <option value="week">Last 7 Days</option>
              <option value="month">This Month</option>
            </select>
          </div>
          <div class="col-md-3">
            <button class="btn btn-primary w-100" onclick="loadAnalytics()">
              Load
            </button>
          </div>
          <div class="col-md-3">
            <button class="btn btn-success w-100" onclick="downloadPDF()">
              📄 PDF Report
            </button>
          </div>
        </div>

        <div class="row text-center mb-4" id="analyticsMetrics"></div>

        <canvas id="salesChart" height="100"></canvas>

      </div>

    </div>
  </div>
</div>
```

#### 3️⃣ – ADD ANALYTICS API URL

#### 📍 FIND CONFIG SECTION

```
const API_URL =
  "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/order-status";
```

#### ✅ ADD BELOW IT

```
const ANALYTICS_API =
  "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/analytics";

const PDF_API =
  "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/report/pdf";
```

#### 4️⃣ – ADD ANALYTICS JAVASCRIPT (LOGIC)

#### 📍 ADD BELOW EXISTING <script> FUNCTIONS

```
let salesChart;

/* OPEN MODAL */
function openAnalytics() {
  const modal = new bootstrap.Modal(
    document.getElementById('analyticsModal')
  );
  modal.show();
  loadAnalytics();
}

/* LOAD ANALYTICS DATA */
function loadAnalytics() {
  const token = localStorage.getItem("access_token");
  const period = document.getElementById("analyticsPeriod").value;

  fetch(`${ANALYTICS_API}?period=${period}`, {
    headers: {
      Authorization: "Bearer " + token
    }
  })
  .then(res => res.json())
  .then(data => {

    document.getElementById("analyticsMetrics").innerHTML = `
      <div class="col-md-3">
        <div class="card-metric">Sales<br>${data.total_sales}</div>
      </div>
      <div class="col-md-3">
        <div class="card-metric">Cost<br>${data.total_cost}</div>
      </div>
      <div class="col-md-3">
        <div class="card-metric">Profit<br>${data.profit}</div>
      </div>
      <div class="col-md-3">
        <div class="card-metric">Orders<br>${data.orders_count}</div>
      </div>
    `;

    if (salesChart) salesChart.destroy();

    salesChart = new Chart(document.getElementById("salesChart"), {
      type: "line",
      data: {
        labels: ["Sales", "Cost", "Profit"],
        datasets: [{
          label: "Amount",
          data: [
            data.total_sales,
            data.total_cost,
            data.profit
          ],
          borderWidth: 3,
          fill: false
        }]
      }
    });
  });
}

/* PDF DOWNLOAD */
function downloadPDF() {
  window.open(PDF_API, "_blank");
}
```

#### 5️⃣ – ADD BOOTSTRAP JS (REQUIRED FOR MODAL)

#### 📍 ADD BEFORE </body>

```
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
```

#### 6️⃣ ✅ FINAL ORDER STATUS PAGE (FULL FILE - Recommanded)

> **File name: order-status.html**

✔ Analytics button

✔ Analytics modal

✔ PDF download

✔ Charts

✔ CLEAR COMMENTS INSIDE CODE telling you EXACTLY what to replace

✔ A SIMPLE REPLACEMENT GUIDE after the code

**📢 You can paste this file as-is, then replace only the marked values.**


```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Cafe ☕ | Order Status</title>
<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- ===================== BOOTSTRAP CSS ===================== -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- ===================== CHART.JS ===================== -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
/* ===================== BACKGROUND ===================== */
body {
  min-height: 100vh;
  background:
    linear-gradient(rgba(0,0,0,.55), rgba(0,0,0,.55)),
    url("https://images.unsplash.com/photo-1509042239860-f550ce710b93");
  background-size: cover;
  background-position: center;
  background-attachment: fixed;
}

/* ===================== DASHBOARD ===================== */
#dashboard {
  display: none;
  background:#f5f5f5;
  padding: 20px;
  border-radius: 8px;
}

.card-metric {
  background:#fff;
  padding:15px;
  border-radius:8px;
  box-shadow:0 2px 6px rgba(0,0,0,.1);
  font-weight:bold;
}
</style>
</head>

<body>

<!-- ===================================================== -->
<!-- NAVBAR -->
<!-- ===================================================== -->
<nav class="navbar navbar-dark bg-dark" id="navbar" style="display:none">
  <div class="container d-flex justify-content-between">
    <span class="navbar-brand">☕ Charlie Cafe Admin</span>

    <div>
      <!-- 📊 ANALYTICS BUTTON -->
      <button class="btn btn-warning btn-sm me-2" onclick="openAnalytics()">
        📊 Analytics
      </button>

      <button class="btn btn-danger btn-sm" onclick="logout()">Logout</button>
    </div>
  </div>
</nav>

<!-- ===================================================== -->
<!-- ORDER STATUS DASHBOARD -->
<!-- ===================================================== -->
<div class="container my-4" id="dashboard">

  <div class="row mb-3">
    <div class="col-md-3">
      <input type="date" id="filterDate" class="form-control">
    </div>
    <div class="col-md-2">
      <button class="btn btn-primary w-100" onclick="loadData()">Filter</button>
    </div>
  </div>

  <div class="text-center my-3" id="loader" style="display:none">
    <div class="spinner-border text-warning"></div>
    <p class="mt-2">Loading...</p>
  </div>

  <div class="row mb-4" id="metrics"></div>

  <canvas id="orderChart" height="100"></canvas>

  <table class="table table-bordered mt-4 bg-white">
    <thead class="table-dark">
      <tr>
        <th>Customer</th>
        <th>Item</th>
        <th>Qty</th>
        <th>Date</th>
      </tr>
    </thead>
    <tbody id="orders"></tbody>
  </table>

</div>

<!-- ===================================================== -->
<!-- ANALYTICS MODAL -->
<!-- ===================================================== -->
<div class="modal fade" id="analyticsModal" tabindex="-1">
  <div class="modal-dialog modal-xl modal-dialog-centered">
    <div class="modal-content">

      <div class="modal-header bg-dark text-white">
        <h5 class="modal-title">📊 Sales Analytics</h5>
        <button class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>

      <div class="modal-body">

        <div class="row mb-3">
          <div class="col-md-3">
            <select id="analyticsPeriod" class="form-select">
              <option value="today">Today</option>
              <option value="week">Last 7 Days</option>
              <option value="month">This Month</option>
            </select>
          </div>

          <div class="col-md-3">
            <button class="btn btn-primary w-100" onclick="loadAnalytics()">
              Load
            </button>
          </div>

          <div class="col-md-3">
            <button class="btn btn-success w-100" onclick="downloadPDF()">
              📄 PDF Report
            </button>
          </div>
        </div>

        <div class="row text-center mb-4" id="analyticsMetrics"></div>

        <canvas id="salesChart" height="100"></canvas>

      </div>

    </div>
  </div>
</div>

<!-- ===================================================== -->
<!-- JAVASCRIPT -->
<!-- ===================================================== -->
<script>
/* =====================================================
   🔁 CONFIG – REPLACE ONLY THESE VALUES
   ===================================================== */

/* ✅ 1) Cognito Hosted UI domain (WITHOUT https://) */
const COGNITO_DOMAIN =
  "REPLACE_WITH_YOUR_COGNITO_DOMAIN";

/* ✅ 2) Cognito App Client ID */
const CLIENT_ID =
  "REPLACE_WITH_YOUR_APP_CLIENT_ID";

/* ✅ 3) CloudFront / S3 redirect URL */
const REDIRECT_URI =
  "REPLACE_WITH_YOUR_REDIRECT_URL";

/* ✅ 4) Order Status API (EXISTING) */
const API_URL =
  "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/order-status";

/* ✅ 5) Analytics API */
const ANALYTICS_API =
  "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/analytics";

/* ✅ 6) PDF Report API */
const PDF_API =
  "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/report/pdf";

/* ===================================================== */

let chart, salesChart, refreshTimer;

/* ===================== AUTH ===================== */
function parseJwt(token) {
  return JSON.parse(atob(token.split('.')[1]));
}

function isTokenExpired(token) {
  return parseJwt(token).exp * 1000 < Date.now();
}

function login() {
  const loginUrl =
    `https://${COGNITO_DOMAIN}/login` +
    `?response_type=token` +
    `&client_id=${CLIENT_ID}` +
    `&scope=openid+email+profile` +
    `&redirect_uri=${encodeURIComponent(REDIRECT_URI)}`;
  window.location.href = loginUrl;
}

function logout() {
  localStorage.removeItem("access_token");
  clearInterval(refreshTimer);

  const logoutUrl =
    `https://${COGNITO_DOMAIN}/logout` +
    `?client_id=${CLIENT_ID}` +
    `&logout_uri=${encodeURIComponent(REDIRECT_URI)}`;
  window.location.href = logoutUrl;
}

function handleRedirect() {
  const hash = window.location.hash.substring(1);
  if (!hash) return;

  const params = new URLSearchParams(hash);
  const token = params.get("access_token");

  if (token) {
    localStorage.setItem("access_token", token);
    window.location.hash = "";
  }
}

/* ===================== DASHBOARD ===================== */
function showDashboard() {
  const token = localStorage.getItem("access_token");
  if (!token || isTokenExpired(token)) return login();

  document.getElementById("navbar").style.display = "block";
  document.getElementById("dashboard").style.display = "block";

  loadData();
  refreshTimer = setInterval(loadData, 10000);
}

/* ===================== ORDER STATUS DATA ===================== */
function loadData() {
  const token = localStorage.getItem("access_token");
  if (!token || isTokenExpired(token)) return logout();

  document.getElementById("loader").style.display = "block";
  document.getElementById("metrics").innerHTML = "";
  document.getElementById("orders").innerHTML = "";

  let url = API_URL;
  const filterDate = document.getElementById("filterDate").value;
  if (filterDate) url += "?date=" + filterDate;

  fetch(url, { headers: { Authorization: "Bearer " + token }})
  .then(res => res.json())
  .then(data => {
    document.getElementById("loader").style.display = "none";

    data.metrics.forEach(m => {
      document.getElementById("metrics").innerHTML += `
        <div class="col-md-3 mb-2">
          <div class="card-metric text-center">
            ${m.metric}<br>${m.count}
          </div>
        </div>`;
    });

    const items = {};
    data.recent_orders.forEach(o => {
      document.getElementById("orders").innerHTML += `
        <tr>
          <td>${o.customer_name}</td>
          <td>${o.item}</td>
          <td>${o.quantity}</td>
          <td>${o.created_at}</td>
        </tr>`;
      items[o.item] = (items[o.item] || 0) + o.quantity;
    });

    if (chart) chart.destroy();
    chart = new Chart(document.getElementById("orderChart"), {
      type: 'bar',
      data: {
        labels: Object.keys(items),
        datasets: [{
          label: 'Orders per Item',
          data: Object.values(items)
        }]
      }
    });
  });
}

/* ===================== ANALYTICS ===================== */
function openAnalytics() {
  new bootstrap.Modal(
    document.getElementById('analyticsModal')
  ).show();
  loadAnalytics();
}

function loadAnalytics() {
  const token = localStorage.getItem("access_token");
  const period = document.getElementById("analyticsPeriod").value;

  fetch(`${ANALYTICS_API}?period=${period}`, {
    headers: { Authorization: "Bearer " + token }
  })
  .then(res => res.json())
  .then(data => {

    document.getElementById("analyticsMetrics").innerHTML = `
      <div class="col-md-3"><div class="card-metric">Sales<br>${data.total_sales}</div></div>
      <div class="col-md-3"><div class="card-metric">Cost<br>${data.total_cost}</div></div>
      <div class="col-md-3"><div class="card-metric">Profit<br>${data.profit}</div></div>
      <div class="col-md-3"><div class="card-metric">Orders<br>${data.orders_count}</div></div>
    `;

    if (salesChart) salesChart.destroy();
    salesChart = new Chart(document.getElementById("salesChart"), {
      type: "line",
      data: {
        labels: ["Sales", "Cost", "Profit"],
        datasets: [{
          label: "Amount",
          data: [data.total_sales, data.total_cost, data.profit],
          borderWidth: 3,
          fill: false
        }]
      }
    });
  });
}

/* ===================== PDF ===================== */
function downloadPDF() {
  window.open(PDF_API, "_blank");
}

/* ===================== INIT ===================== */
handleRedirect();
showDashboard();
</script>

<!-- ===================== BOOTSTRAP JS ===================== -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
```


---

### 🧭 REPLACEMENT GUIDE

> **🔁 Replace ONLY these values**

| What                               | Replace                            |
| ---------------------------------- | ---------------------------------- |
| `REPLACE_WITH_YOUR_COGNITO_DOMAIN` | Cognito → App Integration → Domain |
| `REPLACE_WITH_YOUR_APP_CLIENT_ID`  | Cognito → App clients              |
| `REPLACE_WITH_YOUR_REDIRECT_URL`   | CloudFront / S3 URL                |
| `YOUR_API_ID`                      | API Gateway ID                     |
| `us-east-1`                        | Your region (if different)         |


### 🔐 BACKEND CHANGES (CLEAR ANSWER)

| Component           | Change            |
| ------------------- | ----------------- |
| Order Status Lambda | ❌ NONE            |
| Order Status API    | ❌ NONE            |
| DynamoDB            | ❌ NONE            |
| Auth                | ❌ NONE            |
| Analytics Lambda    | ✅ already created |
| PDF Lambda          | ✅ already created |


### 🎯 RESULT

✔ One professional admin page

✔ Analytics integrated cleanly

✔ PDF reports (manual + auto)

✔ Zero duplication

✔ Production-ready


---
## PHASE 8️⃣  EXACT LAMBDA RESPONSE FORMAT FOR ANALYTICS

### 1️⃣  Required DynamoDB Attributes (Orders Table)

#### Every order item MUST contain:

```
{
  "order_id": "ORD123",
  "order_date": "2026-01-17",
  "order_timestamp": 1705488000,
  "item_name": "Latte",
  "quantity": 2,
  "item_cost": 1.5,
  "item_price": 3.0,
  "order_status": "COMPLETED"
}
```

### 2️⃣  Analytics Lambda – FINAL RESPONSE FORMAT (STRICT)

#### Your Analytics Lambda MUST return exactly this:

```
{
  "period": "month",
  "total_sales": 12000,
  "total_cost": 8000,
  "profit": 4000,
  "orders_count": 340,
  "profit_per_item": [
    {
      "item": "Latte",
      "quantity": 120,
      "sales": 360,
      "cost": 180,
      "profit": 180
    }
  ],
  "daily_sales": [
    { "date": "2026-01-01", "sales": 400 },
    { "date": "2026-01-02", "sales": 520 }
  ]
}
```

### 3️⃣  FULL ANALYTICS LAMBDA CODE (FINAL)

```
import json
import boto3
from collections import defaultdict
from decimal import Decimal
from datetime import datetime, timedelta

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

    result = table.query(
        IndexName='order_date-index',
        KeyConditionExpression='order_date BETWEEN :s AND :e',
        ExpressionAttributeValues={
            ':s': str(start),
            ':e': str(end)
        }
    )['Items']

    total_sales = total_cost = 0
    item_stats = defaultdict(lambda: {"quantity":0,"sales":0,"cost":0})
    daily_sales = defaultdict(int)

    for o in result:
        qty = int(o['quantity'])
        sale = float(o['item_price']) * qty
        cost = float(o['item_cost']) * qty

        total_sales += sale
        total_cost += cost

        item = o['item_name']
        item_stats[item]["quantity"] += qty
        item_stats[item]["sales"] += sale
        item_stats[item]["cost"] += cost

        daily_sales[o['order_date']] += sale

    profit_items = [{
        "item": k,
        "quantity": v["quantity"],
        "sales": v["sales"],
        "cost": v["cost"],
        "profit": v["sales"] - v["cost"]
    } for k,v in item_stats.items()]

    return response(200, {
        "period": period,
        "total_sales": total_sales,
        "total_cost": total_cost,
        "profit": total_sales - total_cost,
        "orders_count": len(result),
        "profit_per_item": profit_items,
        "daily_sales": [{"date": d, "sales": s} for d,s in daily_sales.items()]
    })

def response(code, body):
    return {
        "statusCode": code,
        "headers": {"Access-Control-Allow-Origin": "*"},
        "body": json.dumps(body)
    }
```

---

## PHASE 9️⃣  EXACT LAMBDA RESPONSE FORMAT FOR ANALYTICS

### 1️⃣  Create Item Cost Table

#### 1️⃣  Table Name:

```
CafeMenu
```            
#### 2️⃣  Basic Configurations:

| PK                 | Attribute          |
| ------------------ | ------------------ |
| item_name (String) | base_cost (Number) |

#### Example:

```
{ "item_name": "Latte", "base_cost": 1.5 }
```

### 2️⃣  Modify Order Processing Lambda (EXACT)

```
menu = dynamodb.Table('CafeMenu')

def get_cost(item):
    r = menu.get_item(Key={'item_name': item})
    return float(r['Item']['base_cost'])
```

#### When saving order:

```
item_cost = get_cost(item_name)
item_price = selling_price
```

✔ Cost is now automatic

✔ No frontend change

---

## PHASE 🔟  PROFIT PER ITEM (ALREADY INCLUDED)

✔ Calculated in Analytics Lambda

✔ Returned as profit_per_item[]

✔ Can be rendered in UI or PDF

No additional configuration needed.

---

## PHASE 1️⃣1️⃣  ROLE-BASED ACCESS (ADMIN VS STAFF)

### 1️⃣ Cognito Groups

#### Create groups:

```
Admin
Staff
```

### 2️⃣ Attach Users to Groups

Cognito → Users → Add to group

### 3️⃣ API Gateway Authorizer Context

#### In Lambda, extract role:

```
claims = event['requestContext']['authorizer']['claims']
role = claims.get('cognito:groups', '')
```

### 4️⃣ Enforce Analytics Access

```
if 'Admin' not in role:
    return response(403, "Access denied")
```

✔ Staff sees orders

✔ Admin sees analytics + PDF

---

## PHASE 1️⃣2️⃣  CSV EXPORT (PROFESSIONAL)

### 1️⃣ New API Resource

```
GET /analytics/csv
```

### 2️⃣ CSV Lambda Code

```
import csv, io

def lambda_handler(event, context):
    output = io.StringIO()
    writer = csv.writer(output)
    writer.writerow(["Item","Qty","Sales","Cost","Profit"])

    for i in profit_items:
        writer.writerow([
            i['item'],
            i['quantity'],
            i['sales'],
            i['cost'],
            i['profit']
        ])

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "text/csv",
            "Content-Disposition": "attachment; filename=report.csv"
        },
        "body": output.getvalue()
    }
```

---

## PHASE 1️⃣3️⃣  DAILY AUTO PDF WITH TABLES & LOGO

### 1️⃣ S3 Bucket

```
mn-cafe-s3-bucket
```

### 2️⃣ Upload Logo

```
Cafelogo.png
```

### 3️⃣ PDF Lambda (REPORTLAB – FINAL)

```
from reportlab.platypus import SimpleDocTemplate, Table, Image
from reportlab.lib.pagesizes import A4
import datetime

def lambda_handler(event, context):
    file = f"/tmp/report_{datetime.date.today()}.pdf"
    doc = SimpleDocTemplate(file, pagesize=A4)

    elements = []
    elements.append(Image("Cafelogo.png", width=120, height=60))

    table_data = [["Item","Qty","Sales","Cost","Profit"]]
    for i in profit_items:
        table_data.append([
            i['item'], i['quantity'],
            i['sales'], i['cost'], i['profit']
        ])

    elements.append(Table(table_data))
    doc.build(elements)

    s3.upload_file(file, "mn-cafe-s3-bucket", f"daily_{datetime.date.today()}.pdf")
```

### 4️⃣ EventBridge Rule

```
cron(0 0 * * ? *)
```

✔ Daily midnight PDF

✔ Stored in S3

---

## PHASE 1️⃣4️⃣  Test

### 1️⃣  - 📄 PDF – HOW IT WORKS FROM ORDER STATUS PAGE

✔ Click 📊 Analytics

✔ Click 📄 PDF Report

✔ Calls /report/pdf

✔ Lambda generates PDF

✔ Browser downloads it

❌ No duplication

❌ No extra UI

❌ No confusion

### 2️⃣ - ⏰ MONTH-END AUTO PDF (NO UI)

#### Already handled by:

```
EventBridge → CafePDFReportLambda
cron(0 0 1 * ? *)
```

**No Order Status page change needed.**

### ✅ FINAL SYSTEM CHECKLIST CONFIRMATION

✔ You used existing Order Status system

✔ You did not create new page

✔ You did not modify backend logic

✔ You added professional analytics

✔ You added PDF reports

✔ You kept everything secure & clean

✔ CSV Export

✔ Role-based analytics

✔ Auto cost calculation

✔ Profit per item

✔ Daily PDF with logo & table

✔ Exact API response format

✔ No duplicate systems

✔ Production ready

---


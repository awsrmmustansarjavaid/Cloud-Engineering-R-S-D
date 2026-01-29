# ☕ CAFE LAB – ADVANCED SALES ANALYTICS & REPORTING SYSTEM
> **(Using Existing Order Status System)**


# SECTION 1️⃣ SALES ANALYTICS & REPORTING SYSTEM

## PHASE 1️⃣ – DYNAMODB DESIGN (NO NEW TABLE)

> **⚠️ This phase is mandatory before Lambda works.**

**Goal of this phase:**

Ensure your existing DynamoDB table structure, index, and query logic are 100% correct and testable before analytics logic is added.

### 1️⃣ VERIFY EXISTING ORDERS TABLE (REQUIRED STRUCTURE)

#### 2️⃣ Confirm Table Name: 

```        
CafeOrders
```

#### ❌ If table name is:

- cafeorders

- cafe_orders

- Orders

👉 STOP

👉 Either rename Lambda code OR recreate table

👉 Do NOT rename the table randomly

### 2️⃣ VERIFY REQUIRED ATTRIBUTES EXIST (DATA CONTRACT)

#### Why this matters

Analytics requires GSI, not main keys.

#### ⚠️ DO NOT ADD A SORT KEY TO MAIN TABLE

Adding one breaks:

- Existing writes

- Existing Lambdas

- API Gateway

👉 Analytics filtering happens via GSI, not main table.

#### UNDERSTAND THE “DATA CONTRACT”

This is the MOST IMPORTANT CONCEPT you were missing.

❓ What is a Data Contract?

It means:

“Analytics Lambda EXPECTS these attributes to already exist in every COMPLETED order”

- Lambda does not create them

- Lambda does not fix them

- Lambda only reads

#### REQUIRED ATTRIBUTES (NO EXCEPTIONS)

For every COMPLETED order, DynamoDB item must contain:

| Attribute       | Type   | Why                   |
| --------------- | ------ | --------------------- |
| order_id        | String | Primary key           |
| order_date      | String | Used by GSI partition |
| order_timestamp | Number | Used by GSI sort      |
| total_amount    | Number | Sales calculation     |
| total_cost      | Number | Profit calculation    |
| order_status    | String | Filter COMPLETED      |

**⚠️ Missing even ONE → analytics fails silently or returns empty data.**

#### 2️⃣ Verify Attributes Exist in Real Data

Why this step exists

Most bugs come from:

- order_timestamp saved as string

- total_amount saved as "30" instead of 30

Do this EXACTLY:

- DynamoDB → CafeOrders

- Click Explore table items

- Open at least 3 COMPLETED orders

Manually confirm:

✅ order_date = "2026-01-17"

✅ order_timestamp = Number

✅ total_amount = Number

✅ total_cost = Number

❌ If wrong:

👉 STOP

👉 Fix order creation Lambda first

### 3️⃣ – ADD ADD GLOBAL SECONDARY INDEX (GSI - VERY IMPORTANT)

WHY GSI IS REQUIRED (VERY IMPORTANT)

**❓ Why can’t we just scan the table?**

- Scan is slow

- Scan is expensive

- Scan is forbidden in production analytics

**❓ What problem GSI solves?**

We want:

```
All orders between date A and date B
```

DynamoDB cannot query by non-key attributes

➡️ So we CREATE a key → GSI

### 3️⃣ – EXACT DYNAMODB QUERY CODE (REQUIRED)

HOW QUERY ACTUALLY WORKS (MENTAL MODEL)

Let’s say you query:

```
start_date = 2026-01-01
end_date   = 2026-01-31
```

DynamoDB does:

- Go to GSI order_date-index

- Find partitions between dates

- Sort by order_timestamp

- Return matching items FAST ⚡

Without GSI → impossible.

#### ANALYTICS QUERY CODE (EXPLAINED LINE-BY-LINE)

```
import boto3
from decimal import Decimal
```

👉 boto3 = AWS SDK

👉 Decimal = DynamoDB number safety

```
dynamodb = boto3.resource('dynamodb')
```

👉 Creates DynamoDB connection using Lambda IAM role

```
table = dynamodb.Table('CafeOrders')
```

👉 Points to EXACT table name

```
def query_orders(start_date, end_date):
```

👉 Function accepts:

- "2026-01-01"

- "2026-01-31"

```
response = table.query(
```

👉 QUERY, not SCAN (critical)

```
IndexName='order_date-index',
```

👉 Uses GSI

👉 Without this → crash

```
KeyConditionExpression='order_date BETWEEN :s AND :e',
```

👉 DynamoDB syntax:

- Find all orders where date is between two values

```
ExpressionAttributeValues={
    ':s': start_date,
    ':e': end_date
}
```

👉 Injects values safely

```
return response['Items']
```

👉 Returns list of orders → Lambda will calculate totals later

**✅ PHASE 1 STATUS**

> **🟢 PHASE 1 COMPLETE & VERIFIED**
---
## PHASE 5️⃣  ☕ MULTI-PAGE SUPPORT PDF GENERATION LAMBDA (REPORTLAB)

### 📄 Printing System 2 — Server PDF (Lambda + ReportLab)

> **(PHASE 5 & 6)**

#### How it works

✔️ Button → API Gateway

✔️ API → Lambda

✔️ Lambda → ReportLab

✔️ PDF saved in S3

✔️ Browser downloads PDF

#### Best for

✔️ Admin

✔️ Monthly reports

✔️ Accounting

✔️ Audit

#### Automation (EventBridge)

✅ Professional

✅ Consistent layout

✅ Can be automated

❌ Slight delay

❌ AWS cost (small)

| Printing Type    | Where it runs | Technology         | Purpose                           |
| ---------------- | ------------- | ------------------ | --------------------------------- |
| 🖨 Browser Print | Frontend only | `window.print()`   | Quick, instant print / save PDF   |
| 📄 Lambda PDF    | Backend       | ReportLab + Lambda | Official, stored, branded reports |

#### 🧠 SIMPLE MENTAL MODEL

```
STAFF USES → Browser Print
ADMIN USES → Lambda PDF
```

#### ⚠️Why?

#### Browser print:
> **PHASE 7️⃣ **AWS  Charlie Cafe — Secure Admin Order Dashboard**

✔️ Fast

✔️ No backend cost

✔️ No S3

✔️ No permissions

✔️ Good for receipts, daily summaries

#### Lambda PDF:

> **PHASE 5️⃣ & 6️⃣ **☕ AWS CAFE — SALES ANALYTICS & REPORTING SYSTEM**

✔️ Professional layout

✔️ Stored in S3

✔️ Monthly / daily automation

✔️ Logo, tables, profit

✔️ Admin-only (RBAC)

**✅ You are building a REAL PRODUCTION SYSTEM**

**✅ PHASE 5 STATUS**

> **🟢 PHASE 5 COMPLETE & VERIFIED**
---
## PHASE 6️⃣  CONNECT PDF BUTTON WITH API ( API GATEWAY)

### Goal :

> **When you click PDF button from**

    - analytics.html 
    
            OR

    - order-status.html

➡️ API Gateway must call CafePDFReportLambda

➡️ Lambda must know which page requested the PDF

➡️ Browser must download/open the PDF

### 🧠 BEFORE YOU START – VERIFY THESE EXIST

#### STOP and verify ALL of these are already done:

| Item            | Must Exist                 |
| --------------- | -------------------------- |
| Lambda          | `CafePDFReportLambda`      |
| Runtime         | Python 3.10                |
| ReportLab layer | Attached                   |
| API Gateway     | Same API used by analytics |
| Region          | Known (ex: `us-east-1`)    |

**❗ If any item is missing → DO NOT continue**

**✅ PHASE 6 STATUS**

> **🟢 PHASE 6 COMPLETE & VERIFIED**
---
## PHASE 7️⃣  Automation Monthly Auto Report

### 1️⃣ PREREQUISITE CHECK (DO THIS FIRST)

**📢 Before starting, make sure:**

- **Lambda exists:** CafePDFReportLambda & CafeAnalyticsLambda

- Lambda already works in Test Event (manual test passed)

- **Lambda IAM Role includes:**

    - AmazonS3FullAccess OR

    - Custom policy with s3:PutObject

- S3 bucket exists (example):

```
Your S3 Bucket
```
    - CloudWatchLogsFullAccess

- Lambda code is already working when tested manually

**✅ If all above are true → continue.**

**❗ If Lambda test does not work, STOP and fix Lambda first.**

**This will automatically generate PDFs:**

- Daily → Order Status PDF

- Monthly → Analytics PDF



**✅ PHASE 7 STATUS**

> **🟢 PHASE 7 COMPLETE & VERIFIED**
---
## PHASE 8️⃣  MODIFY ORDER STATUS PAGE

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
---
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

**✅ PHASE 8 STATUS**

> **🟢 PHASE 8 COMPLETE & VERIFIED**
---
## PHASE 9️⃣  EXACT LAMBDA RESPONSE FORMAT FOR ANALYTICS

### Goal: 

Build + test ONE analytics Lambda that returns a strict JSON format from DynamoDB.

### 🎯 WHAT THIS PHASE DOES 

By the end of PHASE 9️⃣, you will have:

✅ DynamoDB data verified

✅ GSI verified working

✅ Analytics Lambda created

✅ Lambda returns EXACT JSON format

✅ Lambda tested in console

✅ Lambda tested via API Gateway

❌ NO frontend

❌ NO PDF

❌ NO EventBridge

**✅ PHASE 9 STATUS**

> **🟢 PHASE 9 COMPLETE & VERIFIED**
---
## PHASE 🔟  COST AUTO-CALCULATION USING CafeMenu TABLE

> **(MANDATORY BEFORE PROFIT / ANALYTICS / PDF)**

### 🎯 PURPOSE OF THIS PHASE (VERY CLEAR)

After this phase:

✔ Item cost will be fetched automatically

✔ Order Processing Lambda will NOT hardcode cost

✔ Analytics profit will be accurate

✔ Frontend remains UNCHANGED

✔ You can TEST and VERIFY before moving to next phase

### ARCHITECTURE Project Flow

```
Frontend
  ↓
CafeOrderProcessor Lambda
  ↓
RDS (MySQL)  ✅ ORDERS STORED HERE
  ↓
Order Status Lambda
  ↓
DynamoDB (analytics / reporting)
```

So:

✔ CafeOrderProcessor Lambda is CORRECT

✔ RDS is the source of truth

✔ Cost auto-calculation MUST happen HERE

✔ Later Lambda(s) can read cost from RDS or DynamoDB

You were absolutely correct to question it.
Now let’s fix PHASE 10 properly for YOUR ARCHITECTURE.

### ARCHITECTURE AFTER PHASE 10

```
CafeMenu (DynamoDB)  ← item cost
        ↓
CafeOrderProcessor Lambda
        ↓
orders (RDS MySQL) ← cost saved here
```

### 📌 PRE-REQUISITES (VERIFY BEFORE START)

Before starting this phase, confirm:

✅ DynamoDB service is already used in your project

✅ Order Processing Lambda already exists

✅ Orders are already saved to CafeOrders table

✅ Each order contains item_name

**⚠️ If any one is missing, STOP and fix first.**
---
### 5️⃣ — CONNECT CafeMenu TABLE IN LAMBDA

#### 1️⃣ LOCATE DYNAMODB SETUP CODE

Find existing code like:

```
dynamodb = boto3.resource('dynamodb')
orders_table = dynamodb.Table('CafeOrders')
```

#### 2️⃣ ADD THIS LINE DIRECTLY BELOW

```
menu_table = dynamodb.Table('CafeMenu')
```

**⚠️ Do not rename CafeMenu**

#### 3️⃣ — ADD COST FETCH FUNCTION (EXACT)

#### ADD THIS FUNCTION (COPY-PASTE)

```
def get_item_cost(item_name):
    response = menu_table.get_item(
        Key={'item_name': item_name}
    )

    if 'Item' not in response:
        raise Exception(f"Cost not found for item: {item_name}")

    return float(response['Item']['base_cost'])
```

✔ Handles missing item

✔ Prevents silent errors

#### 4️⃣ — MODIFY ORDER SAVE LOGIC (CRITICAL STEP)

#### 1️⃣ FIND WHERE ORDER IS SAVED

You will see code similar to:

```
item_name = body['item_name']
quantity = int(body['quantity'])
selling_price = float(body['price'])
```

#### 2️⃣ ADD COST CALCULATION IMMEDIATELY AFTER

```
item_cost = get_item_cost(item_name)
```

#### 3️⃣ CALCULATE TOTAL COST (IMPORTANT)

```
total_cost = item_cost * quantity
```

#### 4️⃣ SAVE ORDER WITH COST INCLUDED

Modify DynamoDB put_item:

```
orders_table.put_item(
    Item={
        "order_id": order_id,
        "item_name": item_name,
        "quantity": quantity,
        "item_price": selling_price,
        "item_cost": item_cost,
        "total_cost": total_cost,
        "order_date": order_date,
        "order_timestamp": order_timestamp,
        "order_status": "COMPLETED"
    }
)
```

**⚠️ Do NOT remove existing fields**

---

### 🔟 — FINAL CONFIRMATION FOR THIS PHASE

#### ✅ THIS PHASE IS COMPLETE ONLY IF:

✔ CafeMenu table exists

✔ Items exist with base_cost

✔ Order Processing Lambda fetches cost

✔ Orders store item_cost & total_cost

✔ Test event succeeded

#### 🔒 GUARANTEED RESULTS

✔ Cost auto-calculation

✔ No frontend change

✔ Accurate analytics profit

✔ PDF reports become correct

✔ Production-safe logic

#### ⛔ DO NOT MOVE TO NEXT PHASE UNTIL:

❌ You see item_cost in CafeOrders

❌ You tested Lambda manually

❌ You verified DynamoDB records

**✅ PHASE 10 STATUS**

> **🟢 PHASE 10 COMPLETE & VERIFIED**
---
## PHASE 1️⃣1️⃣  PROFIT PER ITEM (ALREADY INCLUDED)

### 🎯 PHASE 11 GOAL (CLEAR)

You want to:

✔ Calculate profit per item

✔ Use existing CafeOrders table

✔ Do calculation in Analytics Lambda only

✔ Return structured JSON

✔ Use same data for UI + PDF

✔ Test this phase before moving on

---

### 3️⃣ – MODIFY ANALYTICS LAMBDA (EXACT LOCATION)

- **Open CafeAnalyticsLambda**

#### 🔍 Find this line:

```
result = table.query(...)
```

**📢 This returns raw orders**

#### 1️⃣ – Add Aggregation Containers (DO NOT SKIP)

#### Add ABOVE the loop:

```
from collections import defaultdict

item_stats = defaultdict(lambda: {
    "quantity": 0,
    "sales": 0,
    "cost": 0
})
```

#### 2️⃣ Loop Through Orders (EXACT CODE)

Replace / update your loop:

```
for o in result:
    if o['order_status'] != 'COMPLETED':
        continue

    qty = int(o['quantity'])
    sale = float(o['item_price']) * qty
    cost = float(o['item_cost']) * qty

    item = o['item_name']

    item_stats[item]["quantity"] += qty
    item_stats[item]["sales"] += sale
    item_stats[item]["cost"] += cost
```

#### 3️⃣ Build profit_per_item Array

Add AFTER the loop:

```
profit_per_item = []

for item, data in item_stats.items():
    profit_per_item.append({
        "item": item,
        "quantity": data["quantity"],
        "sales": data["sales"],
        "cost": data["cost"],
        "profit": data["sales"] - data["cost"]
    })
```

#### 4️⃣ Add to Lambda Response (MANDATORY)

Update response body:

```
return response(200, {
    "period": period,
    "total_sales": total_sales,
    "total_cost": total_cost,
    "profit": total_sales - total_cost,
    "orders_count": len(result),
    "profit_per_item": profit_per_item
})
```

#### 5️⃣ COPY THIS FULL FINAL CODE (Recommanded)

> **(PHASE 11 + PHASE 12 INCLUDED)**

#### 📌 You will paste this exactly as-is

```
import json
import os
import boto3
from collections import defaultdict
from decimal import Decimal

# ==================================================
# ✅ ENVIRONMENT VARIABLES (DO NOT HARD-CODE)
# ==================================================

DYNAMODB_TABLE_NAME = os.environ["DYNAMODB_TABLE_NAME"]
AWS_REGION = os.environ["AWS_REGION"]

# ==================================================
# DO NOT CHANGE BELOW
# ==================================================

dynamodb = boto3.resource("dynamodb", region_name=AWS_REGION)
table = dynamodb.Table(DYNAMODB_TABLE_NAME)

def response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(body, default=str)
    }

def lambda_handler(event, context):

    # =====================================================
    # 🔐 PHASE 12 — ROLE-BASED ACCESS (ADMIN ONLY)
    # =====================================================

    try:
        claims = event["requestContext"]["authorizer"]["claims"]
        groups = claims.get("cognito:groups", "")
    except KeyError:
        return response(401, "Unauthorized")

    if "Admin" not in groups:
        return response(403, "Access denied")

    # =====================================================
    # 📅 GET PERIOD (day / week / month)
    # =====================================================

    period = "day"
    if event.get("queryStringParameters"):
        period = event["queryStringParameters"].get("period", "day")

    # =====================================================
    # 📦 READ ORDERS FROM DYNAMODB
    # =====================================================

    scan = table.scan()
    orders = scan.get("Items", [])

    # =====================================================
    # 📊 PHASE 11 — PROFIT PER ITEM
    # =====================================================

    total_sales = Decimal("0")
    total_cost = Decimal("0")

    item_stats = defaultdict(lambda: {
        "quantity": 0,
        "sales": Decimal("0"),
        "cost": Decimal("0")
    })

    for o in orders:

        # ✅ Only COMPLETED orders
        if o.get("order_status") != "COMPLETED":
            continue

        qty = int(o["quantity"])
        price = Decimal(str(o["item_price"]))
        cost = Decimal(str(o["item_cost"]))

        item_name = o["item_name"]

        sales_value = price * qty
        cost_value = cost * qty

        total_sales += sales_value
        total_cost += cost_value

        item_stats[item_name]["quantity"] += qty
        item_stats[item_name]["sales"] += sales_value
        item_stats[item_name]["cost"] += cost_value

    profit_per_item = []

    for item, data in item_stats.items():
        profit_per_item.append({
            "item": item,
            "quantity": data["quantity"],
            "sales": float(data["sales"]),
            "cost": float(data["cost"]),
            "profit": float(data["sales"] - data["cost"])
        })

    # =====================================================
    # 📤 FINAL RESPONSE (EXACT FORMAT)
    # =====================================================

    return response(200, {
        "period": period,
        "total_sales": float(total_sales),
        "total_cost": float(total_cost),
        "profit": float(total_sales - total_cost),
        "orders_count": len(orders),
        "profit_per_item": profit_per_item
    })
```

**✅ PHASE 11 STATUS**

> **🟢 PHASE 11 COMPLETE & VERIFIED**
---
## PHASE 1️⃣2️⃣  ROLE-BASED ACCESS (ADMIN VS STAFF)

### 🎯 PHASE 12 GOAL

✔ Staff → Order Status ONLY

✔ Admin → Order Status + Analytics + PDF

✔ Enforced at Lambda level

✔ Uses Cognito Groups

✔ Tested with real users

### PREREQUISITE CHECK

Before proceeding, confirm:

✔ Cognito User Pool already exists

✔ API Gateway already uses Cognito Authorizer

✔ Order Status API already works with login

❌ If NOT → STOP and fix auth first

---
#### 3️⃣ COPY THIS FULL FINAL CODE (Recommanded)

> **(PHASE 11 + PHASE 12 INCLUDED)**

#### 📌 You will paste this exactly as-is

```
import json
import os
import boto3
from collections import defaultdict
from decimal import Decimal

# ==================================================
# ✅ ENVIRONMENT VARIABLES (DO NOT HARD-CODE)
# ==================================================

DYNAMODB_TABLE_NAME = os.environ["DYNAMODB_TABLE_NAME"]
AWS_REGION = os.environ["AWS_REGION"]

# ==================================================
# DO NOT CHANGE BELOW
# ==================================================

dynamodb = boto3.resource("dynamodb", region_name=AWS_REGION)
table = dynamodb.Table(DYNAMODB_TABLE_NAME)

def response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        },
        "body": json.dumps(body, default=str)
    }

def lambda_handler(event, context):

    # =====================================================
    # 🔐 PHASE 12 — ROLE-BASED ACCESS (ADMIN ONLY)
    # =====================================================

    try:
        claims = event["requestContext"]["authorizer"]["claims"]
        groups = claims.get("cognito:groups", "")
    except KeyError:
        return response(401, "Unauthorized")

    if "Admin" not in groups:
        return response(403, "Access denied")

    # =====================================================
    # 📅 GET PERIOD (day / week / month)
    # =====================================================

    period = "day"
    if event.get("queryStringParameters"):
        period = event["queryStringParameters"].get("period", "day")

    # =====================================================
    # 📦 READ ORDERS FROM DYNAMODB
    # =====================================================

    scan = table.scan()
    orders = scan.get("Items", [])

    # =====================================================
    # 📊 PHASE 11 — PROFIT PER ITEM
    # =====================================================

    total_sales = Decimal("0")
    total_cost = Decimal("0")

    item_stats = defaultdict(lambda: {
        "quantity": 0,
        "sales": Decimal("0"),
        "cost": Decimal("0")
    })

    for o in orders:

        # ✅ Only COMPLETED orders
        if o.get("order_status") != "COMPLETED":
            continue

        qty = int(o["quantity"])
        price = Decimal(str(o["item_price"]))
        cost = Decimal(str(o["item_cost"]))

        item_name = o["item_name"]

        sales_value = price * qty
        cost_value = cost * qty

        total_sales += sales_value
        total_cost += cost_value

        item_stats[item_name]["quantity"] += qty
        item_stats[item_name]["sales"] += sales_value
        item_stats[item_name]["cost"] += cost_value

    profit_per_item = []

    for item, data in item_stats.items():
        profit_per_item.append({
            "item": item,
            "quantity": data["quantity"],
            "sales": float(data["sales"]),
            "cost": float(data["cost"]),
            "profit": float(data["sales"] - data["cost"])
        })

    # =====================================================
    # 📤 FINAL RESPONSE (EXACT FORMAT)
    # =====================================================

    return response(200, {
        "period": period,
        "total_sales": float(total_sales),
        "total_cost": float(total_cost),
        "profit": float(total_sales - total_cost),
        "orders_count": len(orders),
        "profit_per_item": profit_per_item
    })
```

**✅ PHASE 12 STATUS**

> **🟢 PHASE 12 COMPLETE & VERIFIED**
---
## PHASE 1️⃣3️⃣  CSV EXPORT (PROFESSIONAL)

### Goal: 

It allows Admin users to download a CSV sales & profit report from the same analytics data.

### 🟥 IMPORTANT RULE (READ CAREFULLY)

✔ We will REUSE the existing Analytics Lambda logic

✔ We will create ONE NEW Lambda for CSV

✔ We will NOT break existing analytics or PDF

✔ You will TEST CSV BEFORE NEXT PHASE

### 🧱 ARCHITECTURE (SIMPLE & SAFE)

```
Browser
   ↓
API Gateway
   ↓
CafeAnalyticsCSVLambda
   ↓
DynamoDB (CafeOrders)
```

**✅ PHASE 13 STATUS**

> **🟢 PHASE 13 COMPLETE & VERIFIED**
---
## PHASE 1️⃣4️⃣  DAILY AUTO PDF WITH TABLES & LOGO

### 🔴 WHAT YOU WILL ACHIEVE (CLEAR GOAL)

At the end of this phase:

✔ A PDF report is generated DAILY

✔ PDF contains
  • Cafe logo

  • Sales table (Item, Qty, Sales, Cost, Profit)

✔ PDF stored automatically in S3 bucket

✔ PDF generated without UI click

✔ Fully tested manually before automation

✔ Then scheduled with EventBridge

### 🧭 PHASE 14 FLOW (UNDERSTAND FIRST)

```
EventBridge (daily) 
        ↓
CafeDailyPDFLambda
        ↓
Fetch analytics data
        ↓
Generate PDF (logo + table)
        ↓
Upload PDF to S3
```

**✅ PHASE 14 STATUS**

> **🟢 PHASE 14 COMPLETE & VERIFIED**
---
## 🖨 PHASE 1️⃣5️⃣ PDF BUTTON INTEGRATION

### ✅ Method 1️⃣ -  FINAL UPDATED order-status.html

### 1️⃣ Order Status Page — PDF Button (ADMIN ONLY)

#### WHERE TO EDIT 

#### 1️⃣ File:

```
/var/www/html/order-status.html
```

#### 2️⃣ — BACKUP YOUR FILE (MANDATORY)

#### Run:

```
sudo cp /var/www/html/order-status.html /var/www/html/order-status-backup.html
```

#### ♻️ RESTORE IF NEEDED (OPTIONAL)

```
sudo cp /var/www/html/order-status-backup.html /var/www/html/order-status.html
```

#### 3️⃣ — ADD BUTTON (TOP RIGHT, NEXT TO PRINT)

#### Find this area (you already have it):

```
<div class="col text-end">
```

#### ⬇️ ADD THIS BUTTON BELOW EXISTING PRINT BUTTONS

```
<!-- ADMIN ONLY PDF -->
<button
  class="btn btn-outline-primary ms-2 admin-only"
  onclick="downloadOrderPDF()">
  📄 Orders PDF
</button>
```

#### 4️⃣ — ADD JS FUNCTION (NO CHANGES TO LAMBDA)

#### 1️⃣ Add inside <script>:

```
function downloadOrderPDF() {
  window.open(
    "https://API_ID.execute-api.REGION.amazonaws.com/prod/report/pdf?page=order-status",
    "_blank"
  );
}
```

#### 2️⃣ Replace:

- API_ID

- REGION

#### 4️⃣ — HIDE FROM STAFF (RBAC UI)

#### 1️⃣ Add CSS:

```
.admin-only {
  display: none;
}
```

#### 2️⃣ Add JS after JWT decode:

```
const token = localStorage.getItem("access_token");
if (token) {
  const claims = parseJwt(token);
  const groups = claims["cognito:groups"] || [];
  if (groups.includes("Admin")) {
    document.querySelectorAll(".admin-only").forEach(b => b.style.display = "inline-block");
  }
}
```

#### ✅ Result:

- Staff → NO PDF button

- Admin → sees PDF button

### 2️⃣ 📊 ANALYTICS LINK BUTTON (FROM ORDER STATUS)

> **This is UI navigation only.**

#### ▶️ — ADD BUTTON

#### Place near top (header area):

```
<a href="analytics.html" class="btn btn-warning btn-sm ms-2 admin-only">
  📊 Analytics Dashboard
</a>
```

✅ Admin-only navigation

❌ Staff never sees analytics

### 3️⃣ 🎨 DARK / LIGHT CAFE THEME (NO BACKEND)

#### WHY THIS IS SAFE

- CSS only

- No API

- No auth change

#### 1️⃣ — ADD THEME TOGGLE BUTTON

```
<button class="btn btn-secondary btn-sm ms-2" onclick="toggleTheme()">
  🌙 / ☀️
</button>
```

#### 2️⃣ — ADD CSS

```
body.dark {
  background:
    linear-gradient(rgba(0,0,0,.75), rgba(0,0,0,.75)),
    url("https://images.unsplash.com/photo-1509042239860-f550ce710b93");
}

body.light {
  background:
    linear-gradient(rgba(255,255,255,.6), rgba(255,255,255,.6)),
    url("https://images.unsplash.com/photo-1509042239860-f550ce710b93");
}
```

#### 3️⃣ — ADD JS

```
function toggleTheme() {
  document.body.classList.toggle("dark");
  document.body.classList.toggle("light");
}
```

#### Default body class:

```
<body class="dark">
```

### 4️⃣ 📱 MOBILE RECEIPT LAYOUT (VERY IMPORTANT)

> **This affects BOTH PRINT & PDF PREVIEW.**

#### ADD THIS CSS (SAFE)

```
@media (max-width: 576px) {
  .cafe-card {
    padding: 15px;
  }

  table {
    font-size: 12px;
  }

  h3 {
    font-size: 18px;
  }
}
```

✅ Mobile-friendly

✅ Print-safe

✅ No backend impact

### 5️⃣ 🖥 ADMIN-ONLY BUTTONS (RBAC UI — FRONTEND ONLY)

> **You already secured backend.**
> **This is visual security.**

####  RULE (VERY IMPORTANT)

> **UI hiding ≠ security**
> **Backend already enforces real security**

#### HOW TO MARK ADMIN BUTTONS

Just add class:

```
class="admin-only"
```

#### Examples:

- PDF

- Analytics

- Monthly report

- CSV export

**JS already handles visibility.**

### ✅ Method 2️⃣ -  FINAL UPDATED order-status.html (Recommanded)

> **You can directly replace your file with this**

✅ Added ADMIN-ONLY controls (RBAC UI)

✅ Added PDF button control (Admin only)

✅ Added Dark / Light Cafe Theme toggle

✅ Added Cafe-style UI polish

✅ Added VERY CLEAR COMMENTS showing WHERE TO REPLACE YOUR OWN VALUES

✅ Did NOT change backend logic

✅ Did NOT jump or skip anything

#### 1️⃣ — CONFIRM FILE YOU WILL MODIFY (NO JUMP)

```
/var/www/html/order-status.html
```

✔ Same file where orders are shown

✔ Same file used by staff/admin

#### 2️⃣ — BACKUP YOUR FILE (MANDATORY)

#### Run:

```
sudo cp /var/www/html/order-status.html /var/www/html/order-status-backup.html
```

#### ♻️ RESTORE IF NEEDED (OPTIONAL)

```
sudo cp /var/www/html/order-status-backup.html /var/www/html/order-status.html
```


#### 3️⃣ — Replace your entire file with this
> **🌐 New PRINT Above All Features (EXACT LOCATION)**

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Cafe ☕ | Order Status</title>
<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- =====================================================
     BOOTSTRAP CSS
===================================================== -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- =====================================================
     CHART.JS
===================================================== -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
/* =====================================================
   🌈 CAFE BACKGROUND THEMES
===================================================== */
body.dark {
  min-height: 100vh;
  background:
    linear-gradient(rgba(0,0,0,.65), rgba(0,0,0,.65)),
    url("https://images.unsplash.com/photo-1509042239860-f550ce710b93");
  background-size: cover;
  background-position: center;
  background-attachment: fixed;
}

body.light {
  min-height: 100vh;
  background:
    linear-gradient(rgba(255,255,255,.7), rgba(255,255,255,.7)),
    url("https://images.unsplash.com/photo-1509042239860-f550ce710b93");
  background-size: cover;
  background-position: center;
  background-attachment: fixed;
}

/* =====================================================
   DASHBOARD CARD STYLES
===================================================== */
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

/* =====================================================
   ADMIN ONLY UI (RBAC VISUAL CONTROL)
===================================================== */
.admin-only {
  display: none;
}

/* =====================================================
   MOBILE FRIENDLY
===================================================== */
@media (max-width: 576px) {
  h5 { font-size: 16px; }
  table { font-size: 12px; }
}
</style>
</head>

<body class="dark">

<!-- =====================================================
     NAVBAR
===================================================== -->
<nav class="navbar navbar-dark bg-dark" id="navbar" style="display:none">
  <div class="container d-flex justify-content-between">

    <span class="navbar-brand">☕ Charlie Cafe</span>

    <div>
      <!-- 🌗 THEME TOGGLE -->
      <button class="btn btn-secondary btn-sm me-2" onclick="toggleTheme()">
        🌙 / ☀️
      </button>

      <!-- 📊 ANALYTICS (ADMIN ONLY) -->
      <button class="btn btn-warning btn-sm me-2 admin-only" onclick="openAnalytics()">
        📊 Analytics
      </button>

      <!-- 📄 PDF REPORT (ADMIN ONLY) -->
      <button class="btn btn-outline-light btn-sm me-2 admin-only" onclick="downloadPDF()">
        📄 PDF
      </button>

      <button class="btn btn-danger btn-sm" onclick="logout()">Logout</button>
    </div>
  </div>
</nav>

<!-- =====================================================
     ORDER STATUS DASHBOARD
===================================================== -->
<div class="container my-4" id="dashboard">

  <!-- FILTER -->
  <div class="row mb-3">
    <div class="col-md-3">
      <input type="date" id="filterDate" class="form-control">
    </div>
    <div class="col-md-2">
      <button class="btn btn-primary w-100" onclick="loadData()">Filter</button>
    </div>
  </div>

  <!-- LOADER -->
  <div class="text-center my-3" id="loader" style="display:none">
    <div class="spinner-border text-warning"></div>
    <p class="mt-2">Loading...</p>
  </div>

  <!-- METRICS -->
  <div class="row mb-4" id="metrics"></div>

  <!-- CHART -->
  <canvas id="orderChart" height="100"></canvas>

  <!-- ORDERS TABLE -->
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

<!-- =====================================================
     ANALYTICS MODAL (ADMIN)
===================================================== -->
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
            <button class="btn btn-primary w-100" onclick="loadAnalytics()">Load</button>
          </div>
        </div>

        <div class="row text-center mb-4" id="analyticsMetrics"></div>
        <canvas id="salesChart" height="100"></canvas>

      </div>
    </div>
  </div>
</div>

<!-- =====================================================
     JAVASCRIPT
===================================================== -->
<script>
/* =====================================================
   🔁 CONFIG — REPLACE ONLY THESE VALUES
===================================================== */

/* 🔴 REPLACE: Cognito Hosted UI Domain */
const COGNITO_DOMAIN = "REPLACE_WITH_YOUR_COGNITO_DOMAIN";

/* 🔴 REPLACE: Cognito App Client ID */
const CLIENT_ID = "REPLACE_WITH_YOUR_APP_CLIENT_ID";

/* 🔴 REPLACE: Redirect URL (CloudFront / S3) */
const REDIRECT_URI = "REPLACE_WITH_YOUR_REDIRECT_URL";

/* 🔴 REPLACE: Order Status API */
const API_URL = "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/order-status";

/* 🔴 REPLACE: Analytics API */
const ANALYTICS_API = "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/analytics";

/* 🔴 REPLACE: PDF API */
const PDF_API = "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/report/pdf";

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
  window.location.href =
    `https://${COGNITO_DOMAIN}/login?response_type=token&client_id=${CLIENT_ID}&scope=openid+email+profile&redirect_uri=${encodeURIComponent(REDIRECT_URI)}`;
}

function logout() {
  localStorage.removeItem("access_token");
  clearInterval(refreshTimer);
  window.location.href =
    `https://${COGNITO_DOMAIN}/logout?client_id=${CLIENT_ID}&logout_uri=${encodeURIComponent(REDIRECT_URI)}`;
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

/* ===================== RBAC UI ===================== */
function applyRBAC() {
  const token = localStorage.getItem("access_token");
  if (!token) return;

  const groups = parseJwt(token)["cognito:groups"] || [];
  if (groups.includes("Admin")) {
    document.querySelectorAll(".admin-only")
      .forEach(el => el.style.display = "inline-block");
  }
}

/* ===================== DASHBOARD ===================== */
function showDashboard() {
  const token = localStorage.getItem("access_token");
  if (!token || isTokenExpired(token)) return login();

  document.getElementById("navbar").style.display = "block";
  document.getElementById("dashboard").style.display = "block";

  applyRBAC();
  loadData();
  refreshTimer = setInterval(loadData, 10000);
}

/* ===================== ORDER DATA ===================== */
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
        metrics.innerHTML += `
          <div class="col-md-3 mb-2">
            <div class="card-metric text-center">${m.metric}<br>${m.count}</div>
          </div>`;
      });

      const items = {};
      data.recent_orders.forEach(o => {
        orders.innerHTML += `
          <tr>
            <td>${o.customer_name}</td>
            <td>${o.item}</td>
            <td>${o.quantity}</td>
            <td>${o.created_at}</td>
          </tr>`;
        items[o.item] = (items[o.item] || 0) + o.quantity;
      });

      if (chart) chart.destroy();
      chart = new Chart(orderChart, {
        type: "bar",
        data: {
          labels: Object.keys(items),
          datasets: [{ label: "Orders", data: Object.values(items) }]
        }
      });
    });
}

/* ===================== ANALYTICS ===================== */
function openAnalytics() {
  new bootstrap.Modal(analyticsModal).show();
  loadAnalytics();
}

function loadAnalytics() {
  const token = localStorage.getItem("access_token");
  const period = analyticsPeriod.value;

  fetch(`${ANALYTICS_API}?period=${period}`, {
    headers: { Authorization: "Bearer " + token }
  })
  .then(res => res.json())
  .then(data => {
    analyticsMetrics.innerHTML = `
      <div class="col-md-3"><div class="card-metric">Sales<br>${data.total_sales}</div></div>
      <div class="col-md-3"><div class="card-metric">Cost<br>${data.total_cost}</div></div>
      <div class="col-md-3"><div class="card-metric">Profit<br>${data.profit}</div></div>
      <div class="col-md-3"><div class="card-metric">Orders<br>${data.orders_count}</div></div>
    `;
  });
}

/* ===================== PDF ===================== */
function downloadPDF() {
  window.open(PDF_API, "_blank");
}

/* ===================== THEME ===================== */
function toggleTheme() {
  document.body.classList.toggle("dark");
  document.body.classList.toggle("light");
}

/* ===================== INIT ===================== */
handleRedirect();
showDashboard();
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
```

#### 4️⃣ ONLY 6 PLACES YOU EVER NEED TO CHANGE

> **You DO NOT touch anything else.**

#### 🧩 PLACE 1️⃣ — Cognito Hosted UI Domain

#### 🔍 Find this in your code:

```
const COGNITO_DOMAIN = "REPLACE_WITH_YOUR_COGNITO_DOMAIN";
```

#### ✏️ Replace with:

```
const COGNITO_DOMAIN = "charlie-cafe.auth.us-east-1.amazoncognito.com";
```

#### 📍 Where to get it

- **AWS Console → Cognito → User Pool → App integration → Domain name**

- **REMOVE https://**

#### 🧩 PLACE 2️⃣ — Cognito App Client ID

#### 🔍 Find:

```
const CLIENT_ID = "REPLACE_WITH_YOUR_APP_CLIENT_ID";
```

#### ✏️ Replace with:

```
const CLIENT_ID = "4f7x9exampleclientid";
```

#### 📍 Where to get it

- **Cognito → App integration → App clients → Copy Client ID**

#### 🧩 PLACE 3️⃣ — Redirect URL (IMPORTANT)

#### 🔍 Find:

```
const REDIRECT_URI = "REPLACE_WITH_YOUR_REDIRECT_URL";
```

#### ✏️ Replace with:

```
const REDIRECT_URI = "https://d123abc.cloudfront.net/order-status.html";
```

#### 📍 Where to get it

- CloudFront domain OR S3 static website URL

- MUST exactly match Cognito callback URL

#### 🧩 PLACE 4️⃣ — Order Status API (EXISTING)

#### 🔍 Find:

```
const API_URL = "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/order-status";
```

#### ✏️ Replace with:

```
const API_URL = "https://abc123.execute-api.us-east-1.amazonaws.com/prod/order-status";
```

#### 📍 Where to get it

- API Gateway → Stages → prod → Invoke URL

- Append /order-status

#### 🧩 PLACE 5️⃣ — Analytics API

#### 🔍 Find:

```
const ANALYTICS_API = "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/analytics";
```

#### ✏️ Replace with:

```
const ANALYTICS_API = "https://abc123.execute-api.us-east-1.amazonaws.com/prod/analytics";
```

#### 📍 Where to get it

- Same API Gateway → analytics resource

#### 🧩 PLACE 6️⃣ — PDF Report API

#### 🔍 Find:

```
const PDF_API = "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/report/pdf";
```

#### ✏️ Replace with:

```
const PDF_API = "https://abc123.execute-api.us-east-1.amazonaws.com/prod/report/pdf";
```

#### 📍 Where to get it

- API Gateway → report → pdf resource

#### ✅ NOTHING ELSE NEEDS CHANGING

#### ❌ Do NOT touch:

- RBAC logic

- Chart.js

- Dashboard HTML

- CSS

- PDF button

- Theme toggle

**✅ PHASE 15 STATUS**

> **🟢 PHASE 15 COMPLETE & VERIFIED**
---

# SECTION 1️⃣ SALES ANALYTICS & REPORTING SYSTEM COMPLETE & VERIFIED ✅
---

## 1️⃣ ☕ Charlie Café – Cach Payment System 

### 🎯 FINAL BEHAVIOR (CONFIRMED)

#### 1️⃣ Customer side

- Customer places order

- Customer sees two payment choices:

  - 💳 Card Payment (Stripe – existing)

  - ☕ Pay Now (Cash at Counter)

- If customer clicks Pay Now (Cash):

  - Card payment UI is disabled

  - Order status becomes AWAITING_CASH_PAYMENT

  - Customer is redirected to order status page

#### 2️⃣ Admin side

- Admin dashboard shows:

  - Orders waiting for cash

- Admin clicks Mark as Paid

- Order status updates to PAID

✔ This matches real cafés

✔ This teaches state machines

✔ This keeps Stripe intact

✔ This is interview-ready architecture

### 🧠 ORDER STATUS FLOW (IMPORTANT)

```
CREATED
   ↓
AWAITING_CASH_PAYMENT   ← (Pay Now - Cash)
   ↓
PAID                   ← (Admin action)

OR

CREATED
   ↓
PAID                   ← (Stripe Card Payment)
```

### 🧠 WHY THIS DESIGN IS EXCELLENT (IMPORTANT)

✔ Real café workflow

✔ Clean separation of concerns

✔ No Stripe dependency for lab

✔ Demonstrates async payments

✔ Interview-grade system design

✔ Scales to QR ordering easily

☕ CHARLIE CAFÉ – CASH PAYMENT FLOW (LAB GUIDE)

This guide covers ONLY CASH PAYMENT, end-to-end.

🧠 FINAL GOAL (KEEP THIS IN MIND)

When customer clicks “Pay Now (Cash)”:

Frontend sends order_id

API Gateway receives request

Lambda updates order:

payment_method = CASH

payment_status = PENDING

Admin later marks order as PAID

🧱 STEP 0 — PRE-REQUISITES (DO NOT SKIP)

You already have:

✅ Orders table (DynamoDB or RDS)

✅ Order creation API

✅ order_id stored in DB

✅ API Gateway working

✅ Lambda execution role exists

If any one of these is missing, stop and fix it first.

## ☕ CHARLIE CAFÉ PHASE 1️⃣ Cach Payment System 

### 3️⃣ API Gateway – NEW ENDPOINT (CASH)

```
POST /orders/cash-payment
```

#### Purpose

- Called when customer clicks Pay Now (Cash)

- Marks order as:

  - payment_method = CASH

  - payment_status = PENDING


### 3️⃣ Lambda – CashPaymentLambda (Python)

```
# ===========================================
# CashPaymentLambda
# ===========================================

import json
import boto3

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('CafeOrders')

def lambda_handler(event, context):
    """
    Triggered when customer selects CASH payment.
    This does NOT mark order as PAID.
    Admin will do that later.
    """

    body = json.loads(event['body'])
    order_id = body['order_id']

    # Update order to waiting-for-cash
    table.update_item(
        Key={'order_id': order_id},
        UpdateExpression="""
            SET payment_method = :pm,
                payment_status = :ps
        """,
        ExpressionAttributeValues={
            ':pm': 'CASH',
            ':ps': 'PENDING'
        }
    )

    return {
        "statusCode": 200,
        "body": json.dumps({
            "success": True,
            "message": "Order marked as cash payment"
        })
    }
```

### 4️⃣ Admin Lambda – Mark Paid (Already Similar to Yours)

```
POST /admin/mark-paid
```

```
# ===========================================
# AdminMarkPaidLambda
# ===========================================

def lambda_handler(event, context):
    body = json.loads(event['body'])
    order_id = body['order_id']

    table.update_item(
        Key={'order_id': order_id},
        UpdateExpression="SET payment_status = :paid",
        ExpressionAttributeValues={':paid': 'PAID'}
    )

    return {
        "statusCode": 200,
        "body": json.dumps({"success": True})
    }
```

### 🎨 FRONTEND – MODIFY YOUR EXISTING order.php

Below are ONLY the additions / changes, so you clearly see what’s new.

#### ✅ 1️⃣ Add CASH button (HTML)

Place this below card payment section:

```
<!-- ===================== CASH PAYMENT ===================== -->
<div class="mt-4">
    <h4>☕ Pay at Counter (Cash)</h4>

    <!-- Cash payment button -->
    <button onclick="payWithCash()"
            class="btn btn-dark w-100 mt-2">
        Pay Now (Cash)
    </button>

    <small class="text-muted d-block mt-2">
        Please pay at the counter. Your order will be prepared after payment.
    </small>
</div>
```

#### ✅ 2️⃣ Disable card payment when cash selected (JS)

Add below your Stripe JS code:

```
<script>
// ===================== CASH PAYMENT =====================

async function payWithCash() {

    // Disable card UI to prevent double payment
    document.getElementById('payment-section').style.display = 'none';

    try {
        const response = await fetch(
            "https://bs0vgnth0f.execute-api.us-east-1.amazonaws.com/dev/orders/cash-payment",
            {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    order_id: "<?= $orderId ?>"
                })
            }
        );

        const result = await response.json();

        if (result.success) {
            alert("☕ Please pay at the counter. Order registered.");
            window.location.href = "<?= $statusUrl ?>";
        } else {
            alert("❌ Failed to set cash payment.");
        }

    } catch (err) {
        console.error(err);
        alert("Cash payment error.");
    }
}
</script>
```

#### ✅ 3️⃣ (Optional but Recommended) UI clarity

You can add this above payment section:

```
<p class="alert alert-info mt-4">
Choose <strong>ONE</strong> payment method only.
</p>
```

### 5️⃣ 🧪 TEST SCENARIOS (DO THESE)

Scenario 1 – Card

✔ Place order
✔ Pay with card
✔ Status → PAID

Scenario 2 – Cash

✔ Place order
✔ Click Pay Now (Cash)
✔ Card UI disappears
✔ Status → AWAITING PAYMENT
✔ Admin → Mark Paid
✔ Status → PAID

**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---
## ☕ CHARLIE CAFÉ PHASE 4️⃣ Redirect

### 🧠 WHY YOU ARE FEELING CONFUSED (VERY NORMAL)

Right now you have two different concepts mixed under the same name:

| Page name                     | Actual responsibility                |
| ----------------------------- | ------------------------------------ |
| `order-status.php` (existing) | Kitchen / preparation / ready status |
| (new page you built)          | Payment result (card or cash)        |


Those are two different stages in the order lifecycle.

So your instinct is 100% right.

### 🧱 CORRECT PAGE RESPONSIBILITY SPLIT (RECOMMENDED)

### ✅ Page 1 — payment-status.php

#### Purpose:
👉 Shown immediately after payment decision

#### Handles:

- Card payment success

- Cash pending

- Cash paid

Nothing else.

### ✅ Page 2 — order-status.php

#### Purpose:
👉 Shown after payment is completed

#### Handles:

- Preparing

- Ready

- Served

Nothing about payment.

#### This separation:

✔ Avoids confusion

✔ Scales well

✔ Matches real apps

✔ Prevents future bugs

### 🔄 FINAL USER FLOW (VERY CLEAR)

```
order.php
   ↓
payment-status.php
   ↓ (after PAID)
order-status.php
   ↓
(print / kitchen / tracking)
```





**✅ PHASE 4️⃣ STATUS**

> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**
---

## ☕ CHARLIE CAFÉ PHASE 4️⃣ Redirect

### 🧠 PART 1 — HOW REDIRECT ACTUALLY WORKS (VERY SIMPLE)

There are only two valid ways to redirect a user in your case:

### ✅ WAY 1 — JavaScript Redirect (BEST FOR PAYMENT)

Used after Stripe or Cash API success

```
window.location.href = "order-status.php?order_id=ORD-123";
```

### 📌 This is what you must use after payment approval, because:

- Payment happens in JavaScript

- PHP has already finished executing

- Headers can’t be changed anymore

**👉 This is the correct method for your case**

### ❌ WAY 2 — PHP header() (NOT usable here)

```
header("Location: order-status.php");
```

❌ This will NOT work after Stripe/cash click

❌ PHP already rendered the page

### 🧠 PART 2 — YOUR EXACT REQUIREMENT

“After payment approved I want:

- order-status page open

- printing page also open”

This is 100% doable, and this is how cafés do it.

### ✅ CORRECT UX PATTERN (IMPORTANT)

You DO NOT redirect to two pages.

Instead:

👉 order-status.php opens

👉 order-status.php triggers print automatically

This avoids popup blockers and chaos.

### 🧩 FINAL FLOW (VERY CLEAR)

```
Payment Success
     ↓
Redirect to order-status.php
     ↓
order-status.php auto-opens print page
```

### 🧾 WHAT WILL PRINT?

By default:

- Order ID

- Payment message

- Status

You can style print-only receipt later.

### 🧪 HOW THIS BEHAVES (IMPORTANT)

#### Case 1 — Card Payment

✔ Pay → Redirect

✔ Order status page opens

✔ Print dialog opens automatically

#### Case 2 — Cash Payment

✔ Click Cash

✔ Redirect

✔ Status page shows “Pay at counter”

✔ Print dialog opens

#### Case 3 — Admin marks paid later

✔ Customer refreshes

✔ No auto-print (unless print=1)

### ⚠️ WHY THIS IS THE RIGHT WAY

❌ Redirecting to 2 pages = browser blocks

❌ Opening new tabs = popup issues

✅ Single redirect

✅ Controlled printing

✅ Clean UX

✅ Mobile-safe

### 🧠 FINAL RULE (REMEMBER THIS)

> **Redirect ONCE → Print INSIDE destination page**




## 2️⃣ ☕ Charlie Café – Online Payment Integration + STRIPE


## 🟦 PHASE 1️⃣ — STRIPE ACCOUNT (ABSOLUTELY BEGINNER SAFE)
> **(Using Existing Place Order Flow)**

### Tech Stack (Your Existing Lab):

- Frontend: EC2 + Apache (HTML / JS)

- Auth: Amazon Cognito (JWT)

- API: API Gateway

- Backend: AWS Lambda (Node.js)

- DB: Amazon RDS (MySQL / PostgreSQL)

- Payment: Stripe (Test Mode)

- Security: HTTPS + JWT + Secrets Manager

### 🧠 FINAL PAYMENT FLOW (REAL WORLD)

```
Customer clicks "Place Order"
↓
Order saved as PAYMENT_PENDING
↓
Stripe payment starts
↓
Payment succeeds
↓
Order updated to PAID
↓
Order visible in dashboard
```

### 🧠 FIRST – WHAT WE ARE ACTUALLY BUILDING (VERY IMPORTANT)

Before touching AWS or code, understand the final behavior:

#### Current (Your Existing System)

```
Customer clicks Place Order
→ Order saved
→ Done
```
#### New (Professional Payment Flow)

```
Customer clicks Place Order
→ Order saved as PAYMENT_PENDING
→ Payment page opens
→ Customer pays
→ Stripe confirms payment
→ Order updated to PAID
```

#### 💡 Rule:
👉 Order is NEVER PAID by frontend

👉 Only Stripe → Backend → DB can mark PAID

### 🟦 PHASE 0 — PREREQUISITES (DO THIS FIRST)

#### STEP 0.1 — Confirm What You Already Have

You MUST already have:

✔ Place Order frontend (HTML/JS)

✔ Place Order backend Lambda

✔ API Gateway endpoint for Place Order

✔ Orders table in RDS

✔ Cognito authentication working

#### ⚠️ If any of these are missing → STOP and fix first

🟦 PHASE 8️⃣ — FRONTEND PAYMENT (FULLY EXPANDED)

🔹 STEP 8.1 — Add Stripe JS SDK (MANDATORY)

📍 Where:
Inside <head> or before </body> of your order page HTML

🔍 Why:
Without this file, Stripe does not exist in browser.

🔹 STEP 8.2 — Create Payment HTML UI (NO JS YET)

📍 Add this inside <body>

🔍 Why this exists:

#card-element → Stripe mounts secure card UI here

#card-errors → Shows validation/payment errors

Button → Triggers your existing order flow

🔹 STEP 8.3 — Initialize Stripe (GLOBAL STEP)

📍 In your JS file or <script> block

❗ Rule

ONLY pk_test_ allowed in frontend

NEVER sk_test_

🔹 STEP 8.4 — Create Stripe Elements Object

🔍 Why:
elements is a Stripe UI factory that creates secure inputs.

🔹 STEP 8.5 — Create Card Input Element (THIS WAS MISSING BEFORE)

✅ NOW cardElement EXISTS
This is what we use later in confirmCardPayment.

🔹 STEP 8.6 — Mount Card Element into HTML

📌 Important

This connects Stripe → HTML

Without this, nothing appears on screen

🔹 STEP 8.7 — Handle Card Input Errors (VERY IMPORTANT)

🔍 Why recruiters like this

Real-time validation

Professional UX

No blind failures

🔹 STEP 8.8 — FINAL placeOrder() FUNCTION (NOW FULLY CORRECT)

This is the COMPLETE FUNCTION, now that cardElement exists.

### 1️⃣ — Add Stripe JS SDK (MANDATORY)

#### 📍 Where:

Inside <head> or before </body> of your order page HTML

```
<!-- Stripe official JavaScript SDK -->
<script src="https://js.stripe.com/v3/"></script>
```

### 2️⃣ — Create Payment HTML UI (NO JS YET)

#### 📍 Add this inside <body>

```
<!-- Payment section -->
<div id="payment-section">

    <h3>Pay with Card</h3>

    <!-- Stripe will inject secure card input here -->
    <div id="card-element"></div>

    <!-- Show card errors here -->
    <div id="card-errors" style="color:red; margin-top:10px;"></div>

    <!-- Submit order + payment -->
    <button onclick="placeOrder()">Place Order & Pay</button>

</div>
```

### 3️⃣ — Initialize Stripe (GLOBAL STEP)

📍 In your JS file or <script> block

```
// Initialize Stripe using TEST publishable key
// This key is SAFE to expose in frontend
const stripe = Stripe("pk_test_xxxxxxxxx");
```
### 4️⃣ — Create Stripe Elements Object

```
// Create Stripe Elements instance
const elements = stripe.elements();
```

### 5️⃣ — Create Card Input Element (THIS WAS MISSING BEFORE)

```
// Create a card input field
const cardElement = elements.create('card', {
    style: {
        base: {
            fontSize: '16px',
            color: '#ffffff',
            '::placeholder': {
                color: '#cccccc'
            }
        },
        invalid: {
            color: '#ff0000'
        }
    }
});
```

### 6️⃣ — Mount Card Element into HTML

```
// Attach Stripe card UI to <div id="card-element">
cardElement.mount('#card-element');
```

### 7️⃣ — Mount Card Element into HTML

```
// Listen for validation errors in real-time
cardElement.on('change', function(event) {

    const displayError = document.getElementById('card-errors');

    if (event.error) {
        displayError.textContent = event.error.message;
    } else {
        displayError.textContent = '';
    }
});
```

### 8️⃣ — FINAL placeOrder() FUNCTION (NOW FULLY CORRECT)

This is the COMPLETE FUNCTION, now that cardElement exists.

```
async function placeOrder() {

    try {

        // 1️⃣ Call EXISTING Place Order backend
        const orderResponse = await fetch('/place-order', {
            method: 'POST',
            headers: {
                'Authorization': localStorage.getItem('token'),
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(cartData)
        });

        const orderResult = await orderResponse.json();
        const orderId = orderResult.orderId;

        // 2️⃣ Calculate total amount (Stripe requires cents)
        const amount = calculateTotalAmount() * 100;

        // 3️⃣ Create Payment Intent (backend)
        const paymentResponse = await fetch('/payment/create-intent', {
            method: 'POST',
            headers: {
                'Authorization': localStorage.getItem('token'),
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                orderId: orderId,
                amount: amount
            })
        });

        const paymentData = await paymentResponse.json();

        // 4️⃣ Confirm card payment using Stripe
        const result = await stripe.confirmCardPayment(
            paymentData.clientSecret,
            {
                payment_method: {
                    card: cardElement
                }
            }
        );

        // 5️⃣ Handle result
        if (result.error) {

            // Payment failed
            alert("Payment failed: " + result.error.message);

        } else {

            // Payment succeeded
            alert("Payment successful! Order confirmed.");

        }

    } catch (error) {
        console.error(error);
        alert("Something went wrong during payment.");
    }
}
```

✅ PHASE 8️⃣ — FINAL STATUS (NOW ACTUALLY COMPLETE)

✔ Stripe SDK loaded
✔ HTML payment UI created
✔ Stripe Elements initialized
✔ cardElement created
✔ cardElement mounted
✔ Errors handled
✔ Payment confirmed securely

> **🟢 PHASE 8️⃣ COMPLETE & VERIFIED**

🟦 PHASE 9️⃣ — STRIPE WEBHOOK
(BACKEND TRUST • FINAL PAYMENT CONFIRMATION)
🧠 WHY THIS PHASE EXISTS (READ FIRST)

Up to now:

Frontend requests payment

Stripe processes payment

Frontend shows success

⚠️ THIS IS NOT TRUSTED

👉 In real systems:

Frontend can be closed

Browser can be hacked

Network can fail

✅ ONLY STRIPE → BACKEND is trusted

That is why webhooks exist.

🔹 STEP 9.1 — What Is a Stripe Webhook?

A webhook is:

Stripe calling YOUR backend URL
and saying:
“Payment really succeeded”

Only after this do we mark order as PAID.

🔹 STEP 9.3 — Why Python Here?

Stripe webhooks are simple JSON

Python is clean and readable

Good for interview explanation

(You can use Node.js too — logic is same)

✅ PHASE 9️⃣ STATUS

🟢 Stripe → Backend confirmation
🟢 No frontend trust
🟢 Real production behavior


> **🟢 PHASE 9️⃣ COMPLETE & VERIFIED**

🟦 PHASE 🔟 — UPDATE ORDER STATUS (DB LOGIC)
🔹 STEP 10.1 — Why Update in Webhook Only?

❌ Frontend success ≠ real payment
✅ Webhook success = real payment

So ONLY webhook updates DB.


> **🟢 PHASE 9️⃣ COMPLETE & VERIFIED**

🧠 FIRST: WHAT IS “DASHBOARD” IN YOUR PROJECT?

In Charlie Café, a Dashboard means:

A page for Admin / Owner / HR
that shows business numbers, not customer orders.

Examples:

How much money did we earn today?

How much this week?

Which orders are actually paid?

👉 This is NOT the customer order page
👉 This is Admin-only view

🧠 WHY YOU ARE CONFUSED (IMPORTANT)

You are thinking:

“I already have orders in DB… why new queries?”

Because:

Orders table contains ALL orders

Business cares ONLY about money

Money comes ONLY from PAID orders

So dashboard = filtered view of orders

🧠 Explained Like You’re Building It for the First Time
🔴 FIRST: WHAT PHASE 13 IS NOT

❌ It is NOT Stripe
❌ It is NOT payment processing
❌ It is NOT customer order page

👉 PHASE 13 = BUSINESS REPORTING

🟢 WHAT PHASE 13 ACTUALLY IS

Think of Charlie Café owner asking:

“How much money did my café make today and this week?”

That is PHASE 13.

🧠 VERY IMPORTANT MENTAL MODEL (READ TWICE)

```
Stripe → confirms payment
↓
Order marked PAID in database
↓
Dashboard reads database
↓
Dashboard shows numbers
```

⚠️ Dashboard does NOT talk to Stripe
⚠️ Dashboard does NOT care about PENDING orders

🟦 STEP 13.0 — WHY YOU FEEL CONFUSED

Because you are mixing these 3 layers:

| Layer                     | Job                |
| ------------------------- | ------------------ |
| Database                  | Stores orders      |
| Backend (Lambda)          | Calculates numbers |
| Frontend (Dashboard page) | Shows numbers      |

We will now separate them one by one.


🔹 STEP 13.2 — Where These SQL Queries Are Used

This is VERY important 👇
You do NOT run these queries in browser.

Correct place:

```
Dashboard Page (HTML)
   ↓ calls
Dashboard API (API Gateway)
   ↓ triggers
Dashboard Lambda
   ↓ runs
SQL Queries on RDS
```

So SQL = backend only

🧠 SIMPLE MENTAL MODEL (REMEMBER THIS)


```
Orders table
 ├── PENDING (ignored)
 ├── FAILED  (ignored)
 └── PAID    → Dashboard numbers
```
Dashboard = filtered math on PAID orders






> **🟢 PHASE 1️⃣3️⃣ COMPLETE & VERIFIED**

# 🟢 SECTION 8️⃣ COMPLETE & VERIFIED






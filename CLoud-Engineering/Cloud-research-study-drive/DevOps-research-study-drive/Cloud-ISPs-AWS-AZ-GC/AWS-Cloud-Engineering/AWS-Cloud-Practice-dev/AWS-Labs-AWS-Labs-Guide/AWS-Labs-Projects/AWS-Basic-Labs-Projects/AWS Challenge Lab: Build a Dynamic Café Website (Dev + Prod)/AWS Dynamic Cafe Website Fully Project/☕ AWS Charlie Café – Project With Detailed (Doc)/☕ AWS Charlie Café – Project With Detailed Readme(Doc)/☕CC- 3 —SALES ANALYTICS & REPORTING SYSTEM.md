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






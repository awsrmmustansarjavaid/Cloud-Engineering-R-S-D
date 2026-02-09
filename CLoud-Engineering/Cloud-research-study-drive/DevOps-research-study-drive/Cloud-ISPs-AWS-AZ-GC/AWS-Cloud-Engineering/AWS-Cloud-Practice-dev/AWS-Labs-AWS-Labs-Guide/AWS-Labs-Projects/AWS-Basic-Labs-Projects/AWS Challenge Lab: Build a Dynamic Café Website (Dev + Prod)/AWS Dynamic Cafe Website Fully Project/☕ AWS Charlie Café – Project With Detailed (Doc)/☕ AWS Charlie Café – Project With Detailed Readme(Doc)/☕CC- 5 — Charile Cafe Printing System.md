# Charile Cafe Printing System

**Dev → Serverless → Secure → Scalable → Cost-Controlled**

**Author & Architecture Designer:** Charlie

**Level:** Beginner → Advanced (Production-grade)

**Approach:** AWS Console First • No Skipped Steps • Exam + Real-World Safe

---

### 🧠 What you’re designing (in real tech terms)

You are creating a:

#### Central Print & Export Gateway (Frontend)

One dedicated HTML page that:

- Loads central CSS (print + thermal)

- Loads central JS

- Accepts data from ANY page

- Can:

    - 🖨️ Print via browser

    - 🧾 Thermal print

    - 📄 Export PDF

    - 📊 Export CSV

- Works for:

    - order.php

    - order-status.html

    - hr.html

    - admin reports

    - future features

This is exactly how enterprise dashboards work.

### 🗂️ Recommended File Structure

```
/print/
│
├── print-hub.html          ✅ THE universal print page
├── central-print.js        ✅ logic (load data, print, export)
├── central-cafe-style.css  ✅ your print + thermal CSS
│
/orders/
│   ├── order.php
│   ├── order-status.html
│
/hr/
│   ├── employee-report.html
```

### 🧾 1️⃣ The Dedicated Printing Page (print-hub.html)

This page:

- Has no business logic

- Only renders + prints what it receives

🔹 How data arrives

We pass data using:

- query params OR

- localStorage OR

- sessionStorage

👉 sessionStorage is best (safe, temporary, clean)

## 🔐 PHASE 1️⃣ Charlie Cafe - PRINTING (FRONTEND ONLY)

### 1️⃣ Create a Dedicated Printing HTML (central-print.html)

This file will:

- Include central-cafe-style.css for all print styles

- Include central-auth-api.js for browser printing functions

- Include optional export functionality (CSV/PDF)

- Be reusable for any page: order.php, order-status.html, HR reports, etc.

- Allow printing or exporting without duplicating code


**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---
## PHASE 2️⃣ Cafe Central Export 

### 1️⃣ What your current Lambda functions are doing (clean breakdown)

Before merging, we need to be very explicit about responsibilities.

#### 🔹 A. CafePDFReportLambda (analytics + order-status)

Purpose

Generates PDF reports

Data source: DynamoDB (orders)

Output:

Returns PDF in API response

Uploads PDF to S3

Controlled by:

?page=analytics
?page=order-status


Problems

Hardcoded analytics values

Mixed concerns (PDF + data logic)

No auth check

Logic duplicated in other Lambdas

#### 🔹 B. CafeAnalyticsCSVLambda

Purpose

Generates CSV analytics

Data source: DynamoDB

Filters only COMPLETED orders

Admin-only via Cognito groups

Output:

CSV download via API Gateway

This is GOOD logic and we’ll reuse it almost as-is.

#### 🔹 C. CafeDailyPDFLambda

Purpose

Generates daily PDF summary

Data source: DynamoDB

Uploads PDF to S3 only

No API response body for browser usage

Problems

Uses /tmp filesystem (fine but inconsistent)

Separate PDF logic

Not connected to frontend printing

#### 🔹 D. CafePDFReportLambda (extended – attendance + RDS)

Purpose

PDF reports for:

Cafe analytics

Order status

HR attendance

Data source:

DynamoDB

RDS (MySQL)

Output:

PDF + S3 upload

This is actually your “core reporting engine” already, just not structured well.

### 2️⃣ The CORRECT merge strategy (no bugs, no API breakage)

#### ❌ Wrong way

One giant if/else mess

Multiple endpoints per Lambda

Mixed auth logic everywhere

### ✅ Right way (what we’ll do)

🔐 ONE Lambda

📌 ONE API Gateway endpoint

🎯 MULTIPLE actions via query parameters

```
GET /reports/export
```

Controlled by:

| Query param | Meaning                                      |
| ----------- | -------------------------------------------- |
| `type`      | `pdf` or `csv`                               |
| `report`    | `analytics`, `orders`, `daily`, `attendance` |
| `date`      | optional (YYYY-MM-DD)                        |

This maps perfectly to your central-auth-api.js and central-printing.html.

### 3️⃣ Final merged Lambda: CafeCentralExportLambda

#### ✅ What this Lambda supports

✔ PDF (ReportLab)
✔ CSV
✔ DynamoDB
✔ RDS
✔ Cognito Admin check
✔ S3 storage
✔ Browser download
✔ Central frontend compatibility

### 2️⃣ How this connects PERFECTLY with central-printing.html

#### 1️⃣ What central-printing.html is doing

Your HTML has a container:

```
<div id="printContainer"></div>
```

And your central-auth-api.js has secureFetch() which is your wrapper for API calls with authentication:

```
secureFetch(url, options)
```

#### 2️⃣ How the new Lambda exposes reports

The merged Lambda has one API Gateway endpoint:

```
GET https://your-api.execute-api.region.amazonaws.com/reports/export
```

It supports query parameters:

| Param  | Example                                         | Meaning                                |
| ------ | ----------------------------------------------- | -------------------------------------- |
| type   | `pdf` / `csv`                                   | The format you want to download/export |
| report | `analytics` / `orders` / `daily` / `attendance` | Which report to generate               |


So if you call:

```
/reports/export?type=pdf&report=daily
```

It will return a PDF of daily orders.

If you call:

```
/reports/export?type=csv
```

It will return a CSV of analytics.

#### 3️⃣ Connecting with central-printing.html

In your HTML you have buttons:

```
<button onclick="centralPrint.exportCSV('orders.csv')">Export CSV</button>
<button onclick="centralPrint.exportPDF('orders.pdf')">Export PDF</button>
```

Currently, these are front-end only exports from HTML tables.
With the new Lambda:

1. You call the Lambda from your JS using secureFetch.

2. You get back the file (PDF or CSV).

3. You can inject it into the browser, or trigger a download.

Example:

```
async function downloadReport(format = 'pdf', report = 'daily') {
    const response = await secureFetch(`${API_BASE}/reports/export?type=${format}&report=${report}`);
    
    if (format === 'csv') {
        const blob = new Blob([await response.text()], { type: 'text/csv' });
        const a = document.createElement('a');
        a.href = URL.createObjectURL(blob);
        a.download = `${report}.${format}`;
        a.click();
    } else if (format === 'pdf') {
        const blob = new Blob([await response.arrayBuffer()], { type: 'application/pdf' });
        const a = document.createElement('a');
        a.href = URL.createObjectURL(blob);
        a.download = `${report}.${format}`;
        a.click();
    }
}
```

Then in your buttons, just call:

```
<button onclick="downloadReport('csv', 'analytics')">Export CSV</button>
<button onclick="downloadReport('pdf', 'daily')">Export PDF</button>
```

#### 4️⃣ Why this is perfect

One Lambda handles all types.

One API endpoint for all exports.

Your front-end doesn’t need to know anything about DynamoDB, RDS, or S3.

Works with central-printing.html or any other page (just call downloadReport()).

---

### API Gateway (REST API)

```
/reports
    └── /export   (GET)
            ↓
     CafeCentralExportLambda
```

That’s it. One resource. One method. One Lambda.

Everything else is controlled by query parameters.

### 🔍 How different reports are handled with ONE endpoint

You are not creating multiple APIs.
You are calling the same API differently.

| What you want  | API call                                     |
| -------------- | -------------------------------------------- |
| Daily PDF      | `/reports/export?type=pdf&report=daily`      |
| Analytics PDF  | `/reports/export?type=pdf&report=analytics`  |
| Orders PDF     | `/reports/export?type=pdf&report=orders`     |
| Attendance PDF | `/reports/export?type=pdf&report=attendance` |
| Analytics CSV  | `/reports/export?type=csv`                   |


Same Lambda. Same API Gateway method.

### 🧠 Why this works (important mental model)

Think of API Gateway like a door
Think of Lambda like a receptionist

You don’t build 10 doors —
you tell the receptionist what you want when you enter.

```
GET /reports/export
        ↑
   query params tell Lambda what to do
```

### ❌ What you should NOT do anymore

❌ Multiple resources like:

```
/pdf-analytics
/pdf-daily
/csv-analytics
/hr-attendance
```

❌ Multiple Lambdas for each export

❌ One Lambda per file type

This causes:

duplication

harder auth control

frontend confusion

higher cost

harder testing

### 🔐 What about security (Cognito)?

Still one place.

```
API Gateway
  → Cognito Authorizer
      → CafeCentralExportLambda
```

Inside Lambda:

Admin check happens once

Applies to ALL reports

### 🧪 Testing becomes EASY
API Gateway test event (same endpoint)

Just change parameters:

```
{
  "queryStringParameters": {
    "type": "pdf",
    "report": "daily"
  },
  "requestContext": {
    "authorizer": {
      "claims": {
        "cognito:groups": "Admin"
      }
    }
  }
}
```

No new method. No new resource.

### 🖥️ Frontend becomes SIMPLE

Your central-printing.html or any page:

```
secureFetch(`${API_BASE}/reports/export?type=pdf&report=daily`)
secureFetch(`${API_BASE}/reports/export?type=csv`)
```

Same function. Same API.

### ⚠️ When would you need multiple resources?

Only if:

Different auth models (public vs admin)

Different throttling rules

Completely different business domains

You do not have that case here.

### 🏁 Final verdict (this is important)

✅ ONE Lambda
✅ ONE API Gateway resource
✅ ONE method (GET)
✅ Query params control behavior

This is clean architecture, not a shortcut.




**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**
---

# SECTION 1️⃣  COMPLETE ✅
---
# SECTION 2️⃣ Central PDF Reporting Lambda (optional)

### 🎯 The Professional Pattern You Want

✅ Single Lambda

✅ Single API Gateway

✅ Multiple systems supported

✅ No duplicate code

✅ Easy to extend later

This pattern is called:

**🟢 Centralized Report Dispatcher (Strategy Pattern)**

**🟢 AWS-style name: Shared Reporting / Document Generation Service**

### 🧠 Core Idea (Simple Explanation)

Instead of:

CafePDFReportLambda

HRPDFReportLambda

AttendancePDFReportLambda ❌

You do this:

#### 🟢 ONE Lambda

#### CentralPDFReportLambda

And you decide WHAT to generate using parameters.

### 🔑 How the Lambda Decides What to Generate

#### Use two query parameters:

```
/system=...
/report=...
```

Examples

```
/report/pdf?system=cafe&report=analytics
/report/pdf?system=cafe&report=order-status

/report/pdf?system=hr&report=employee-list
/report/pdf?system=attendance&report=daily
```

**This is very clean and future-proof.**

### 🧱 Recommended Folder Structure (Inside ONE Lambda)

```
CentralPDFReportLambda/
│
├── handler.py          👈 main Lambda entry
│
├── cafe_reports.py     ☕ cafe PDFs
├── hr_reports.py       👔 HR PDFs
├── attendance_reports.py 🕒 attendance PDFs
│
└── utils/
    ├── pdf_base.py     📄 common PDF helpers
    └── aws_helpers.py  🔌 DynamoDB / S3 helpers
```

This is how real teams do it.

### 🔁 Minimal Changes to Your Existing Code

Your CafePDFReportLambda.py logic stays almost the same — it just moves into a module.

### 🧩 NEW handler.py (Central Dispatcher)

```
from cafe_reports import generate_cafe_pdf
from hr_reports import generate_hr_pdf
from attendance_reports import generate_attendance_pdf

def lambda_handler(event, context):

    params = event.get("queryStringParameters") or {}

    system = params.get("system")
    report = params.get("report")

    if not system or not report:
        return {
            "statusCode": 400,
            "body": "Missing system or report parameter"
        }

    if system == "cafe":
        return generate_cafe_pdf(report)

    elif system == "hr":
        return generate_hr_pdf(report)

    elif system == "attendance":
        return generate_attendance_pdf(report)

    else:
        return {
            "statusCode": 400,
            "body": "Unknown system"
        }
```

### ☕ Cafe Code → Move As-Is (Very Small Change)
cafe_reports.py

```
from CafePDFReportLambda import build_cafe_pdf  # your existing logic

def generate_cafe_pdf(report_type):
    return build_cafe_pdf(report_type)
```

#### Your current CafePDFReportLambda.py becomes:

build_cafe_pdf(page_type)

same ReportLab code

same S3 upload

same response

💡 No rewrite needed

### 👔 HR Example (Later)

```
def generate_hr_pdf(report_type):
    if report_type == "employee-list":
        return build_employee_list_pdf()
    elif report_type == "salary":
        return build_salary_pdf()
```

### 🕒 Attendance Example (Later)

```
def generate_attendance_pdf(report_type):
    if report_type == "daily":
        return build_daily_attendance_pdf()
```

### 🌐 API Gateway (NO CHANGE NEEDED)

You keep:

```
POST /report/pdf
```

Only URLs change:

#### Cafe

```
/report/pdf?system=cafe&report=analytics
```

#### HR

```
/report/pdf?system=hr&report=employee-list
```

#### Attendance

```
/report/pdf?system=attendance&report=daily
```

✅ One endpoint

✅ One Lambda

✅ Infinite reports

### 🔐 IAM Permissions (Still Clean)

You do NOT add new roles.

Just:

- DynamoDB tables (CafeOrders, Employees, Attendance)

- One S3 bucket (or folders inside bucket)

Example S3 keys:

```
reports/cafe/analytics_2026-02-06.pdf
reports/hr/employees_2026-02-06.pdf
reports/attendance/daily_2026-02-06.pdf
```

### 🏆 Why This Is the “Right” Way

✔ No Lambda sprawl
✔ No API sprawl
✔ Easy to maintain
✔ Easy to extend
✔ Looks very professional in interviews
✔ Matches AWS Well-Architected principles

This is exactly how a senior engineer would design it.

### 🚦 Recommendation (Do This Now)

Rename Lambda → CentralPDFReportLambda

Move Cafe code into cafe_reports.py

Add system + report parameters

Keep same API Gateway

Test Cafe first → then add HR → then Attendance







**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**

# SECTION 2️⃣  COMPLETE ✅
---

---
---

## ❌ ❗️❗️ ❌   Start Charlie Cafe Old Printing/ CSV /PDF System ❌ ❗️❗️  ❌

---
---
# SECTION 1️⃣ Charlie Cafe - PRINTING System

## 🔐 PHASE 1️⃣ Charlie Cafe - PRINTING (FRONTEND ONLY)

### 🖨️ Printing System 1 — Browser Print (Frontend-only)

### 1️⃣ Modify central-auth-api.js (MAIN WORK)

Add this ONCE at the BOTTOM of central-auth-api.js
(do NOT put inside auth/token logic)

```
// =======================================================
// 🖨️ CHARLIE CAFE — CENTRAL BROWSER PRINTING SYSTEM
// Used by all admin/staff pages
// =======================================================

window.printAllOrders = function () {
  console.log("🖨️ Printing all orders...");
  window.print();
};

window.printTodaySummary = function () {
  console.log("📄 Printing today's summary...");

  const table = document.querySelector("#ordersTable tbody");

  if (!table) {
    alert("❌ Orders table not found");
    return;
  }

  const rows = table.querySelectorAll("tr");
  const today = new Date().toISOString().split("T")[0];

  let totalOrders = 0;
  let totalAmount = 0;

  rows.forEach(row => {
    const orderDate = row.dataset.date;
    const amount = parseFloat(row.dataset.total || 0);

    if (orderDate === today) {
      totalOrders++;
      totalAmount += amount;
    }
  });

  const summaryHTML = `
    <div style="padding:20px">
      <h3 style="text-align:center">☕ Charlie Cafe — Daily Summary</h3>
      <hr>
      <p><strong>Date:</strong> ${today}</p>
      <p><strong>Total Orders:</strong> ${totalOrders}</p>
      <p><strong>Total Sales:</strong> $${totalAmount.toFixed(2)}</p>
    </div>
  `;

  const originalContent = document.body.innerHTML;
  document.body.innerHTML = summaryHTML;

  window.print();

  // Restore page after print
  document.body.innerHTML = originalContent;
  location.reload(); // ensures JS state restores cleanly
};
```

**⚠️ Skip it because already added**

### 2️⃣ Minimal HTML change (ONE TIME PER PAGE)

#### 🧩 Buttons (NO JS HERE)

Place below <h3>Order Status</h3>

```
<div class="d-flex gap-2 mb-3 no-print">
  <button class="btn btn-outline-dark" onclick="printAllOrders()">
    🖨️ Print All Orders
  </button>

  <button class="btn btn-outline-success" onclick="printTodaySummary()">
    📄 Print Today Summary
  </button>
</div>
```

✔ No script

✔ No duplication

✔ Uses central JS automatically

### 3️⃣ Table row attributes (MANDATORY)

Your table must look like this when rendered:

```
<table id="ordersTable" class="table">
  <tbody>
    <tr data-date="2026-02-05" data-total="15.50">
      ...
    </tr>
  </tbody>
</table>
```

If rows are created in JS:

```
row.dataset.date = order.order_date;        // YYYY-MM-DD
row.dataset.total = order.total_amount;     // number
```

**🚨 Without this → Today Summary WILL NOT WORK**




### Load central-auth-api.js (VERY IMPORTANT)

Make sure every page that prints has:

```
<script src="/js/central-auth-api.js"></script>
```

**🛑 Load it after DOM elements (bottom of page or defer)**

### 🧾 ✅ FINAL UPDATED order-status.html (WITH PRINTING + COMMENTS)

#### 📍 Location:

```
/var/www/html/order-status.html
```

#### 1️⃣ BACKUP order-status.html

```
sudo cp /var/www/html/order-status.html /var/www/html/order-status-backup.html
```

#### ♻️ RESTORE IF NEEDED (OPTIONAL)

```
sudo cp /var/www/html/order-status-backup.html /var/www/html/order-status.html
```

#### 2️⃣ Replace your entire file with this

[order-status.html](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order-status/CC%20-%20Order-Status_LIVE%20ADMIN%20DASHBOARD_many%20orders/order-status.html)

#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```

#### 4️⃣ Fix File Permissions

```
sudo chown apache:apache /var/www/html/order-status.html
```

```
sudo chmod 644 /var/www/html/order-status.html
```

#### 5️⃣ Restart Apache (MANDATORY)

```
sudo systemctl restart httpd
```

#### 6️⃣ Open page in browser

```
http://EC2 Public IP/order-status.html
```



**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**

# SECTION 1️⃣  COMPLETE ✅
---
# SECTION 2️⃣- 🏷️ Order Status – CSV Export

## PHASE 1️⃣ - CSV Export (Backend + Frontend)

### 1️⃣ CSV EXPORT Backend (Lambda)

#### 1️⃣ — Open your Lambda

- **AWS Console → Lambda → GetOrderStatusAdminLambda**

[GetOrderStatusAdminLambda.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/GetOrderStatusAdminLambda.py)

✔ Now the Lambda supports CSV export.

### 2️⃣ CSV EXPORT Frontend

#### 1️⃣ — Add Export Button

[order-status.html](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order-status/CC%20-%20Order-Status_LIVE%20ADMIN%20DASHBOARD_many%20orders/order-status.html)


✔ Users can now download CSV of filtered or all orders.

### 3️⃣ API GATEWAY CONFIGURATION (NO SKIP)

#### 1️⃣ Resource

```
GET /order-status
```

#### 2️⃣ Integration

- Type: Lambda Proxy Integration

- Lambda: order_status_lambda

#### 3️⃣ Cognito Authorizer

- Attach CognitoAuthorizer

- Token source: Authorization

#### 4️⃣ Enable CORS

- Access-Control-Allow-Origin: *

- Access-Control-Allow-Headers: Authorization,Content-Type

### ✅ HOW FRONTEND CALLS THIS (CONFIRMED)

#### 1️⃣ Normal dashboard

```
GET /order-status
Authorization: Bearer <JWT>
```

#### 2️⃣ CSV Export

```
GET /order-status?export=true
Authorization: Bearer <JWT>
```

#### ✅ Browser automatically downloads:

```
orders.csv
```

**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**

# SECTION 2️⃣ Secure Admin Order Dashboard 🟢 COMPLETE ✅
---

## PHASE 2️⃣  ☕ MULTI-PAGE SUPPORT PDF GENERATION LAMBDA (REPORTLAB)

### 📄 Printing System 2 — Server PDF (Lambda + ReportLab)

> **(PHASE 5 & 6)**

### 1️⃣ Create Cafe PDF Report Lambda

#### 📢 ❗️ ❎ Ignore all the old PDF/CSV Lambdas. Use only the new CafeCentralExportLambda for all exports and reports. Replace the old Lambdas in API Gateway with this one.❎ ❗️ 

#### 1️⃣ CREATE LAMBDA

```
Name: CafePDFReportLambda
Runtime: Python 3.10
```

###  2️⃣ ADD REPORTLAB LAYER

- **Lambda → Layers → Create layer**

- **Upload reportlab.zip** (contains reportlab library)

- **Attach layer to:** CafePDFReportLambda

- **Required S3 PERMISSION:**

    - **Attach IAM policy:**

        - **AmazonS3FullAccess**

        - **CloudWatchLogsFullAccess**

        - **AmazonDynamoDBReadOnlyAccess**

** ⚠️ if you want to pull real data from DynamoDB**

###  3️⃣ DEPLOY EXISTING PDF CODE

#### 1️⃣ UPDATED CafePDFReportLambda FULL PYTHON CODE (PDF for BOTH PAGES)

[CafePDFReportLambda.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafePDFReportLambda.py)

#### 📢 ❗️ ❎ Ignore all the old PDF/CSV Lambdas. Use only the new CafeCentralExportLambda for all exports and reports. Replace the old Lambdas in API Gateway with this one.❎ ❗️ 

#### 2️⃣ 🔐 Environment Variables Required

- Open Lambda → Your Function

- Go to Configuration → Environment variables

- Click Edit → Add environment variable

You will configure these in Lambda (steps below):

| Variable Name         | Value (example) |
| --------------------- | --------------- |
| `ORDERS_TABLE_NAME`   | `CafeOrders`    |
| `REPORTS_BUCKET_NAME` | `charlie-cafe-s3-bucket`  |
| `LOGO_FILE_NAME`      | `Cafelogo.png`  |

👉 Click Save

#### 3️⃣ TESTING THE PDF LAMBDA

- **Go to AWS Console → Lambda → CafePDFReportLambda.**

- Click “Test” button on top-right.

- If you haven’t created a test event yet, it will ask you to configure a new test event.

#### 1️⃣ Create Test Event

- **Event Name:** TestAnalyticsPDF

- **Event JSON:**

#### 1️⃣ To test Analytics PDF:

```
{
  "queryStringParameters": {
    "page": "analytics"
  }
}
```

#### 2️⃣ To test Order Status PDF:

```
{
  "queryStringParameters": {
    "page": "order-status"
  }
}
```

> **Explanation: queryStringParameters.page is how our Lambda knows which page to generate.**

- **Click “Create”.**

#### 2️⃣ Run Test

- Click “Test” (top-right).

- Lambda will execute.

- **Scroll down to Execution Result → should see:**

```
{
  "statusCode": 200,
  "headers": { "Content-Type": "application/pdf" },
  "body": "...", 
  "isBase64Encoded": false
}
```

> **☢️ Note: body contains the PDF binary in latin1 encoding. You won’t see the PDF in the console, but the Lambda writes the file to your S3 bucket (cafe-reports) if S3 put_object succeeds.**

#### 3️⃣ Verify S3

- **Go to S3 → your bucket.**

You should see:

```
analytics_report_2026-01-17.pdf
order-status_report_2026-01-17.pdf
```

- Click → Download → Open in PDF viewer.

**✅ You now have both PDFs.**


**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**
---
## PHASE 3️⃣  CONNECT PDF BUTTON WITH API ( API GATEWAY)

### 1️⃣ CONFIGURE API GATEWAY (FOR MULTI-PAGE PDF)

#### 1️⃣ – OPEN API GATEWAY

- Login to AWS Console

- Go to API Gateway

- Click APIs

- Click your existing API
> **(example name: CafeLabAPI)**

**⚠️ You should now see Resources tree on left side**

#### 2️⃣ – CREATE /report RESOURCE (IF NOT EXISTS)

#### 1️⃣  Check if /report already exists

#### Look in resource tree:

- If you see /report → go to STEP 3

- If NOT → create it

#### 2️⃣ Create /report

- Click root /

- Click Create Resource

- **Resource Name:**

```
report
```

- **Resource Path auto-fills:**

```
/report
```

- Click Create Resource

**✅ /report now exists**

#### 3️⃣ – CREATE /pdf RESOURCE (VERY IMPORTANT)

- Click /report

- Click Create Resource

- **Resource Name:**

```
pdf
```

- **Resource Path auto-fills:**

```
/report/pdf
```

- Click Create Resource

**✅ Final path must be exactly:**

#### 4️⃣ – CREATE POST METHOD (DO NOT SKIP)

- Select /report/pdf

- Click Create Method

- **Choose:**

```
POST
```

- Click ✔️

#### 5️⃣ – CONNECT METHOD TO LAMBDA (CRITICAL)

You are now on POST – Setup page

#### 1️⃣ Integration settings (EXACT VALUES)

| Field                    | Value               |
| ------------------------ | ------------------- |
| Integration type         | Lambda Function     |
| Lambda proxy integration | ✅ CHECKED           |
| Lambda function          | CafePDFReportLambda |
| Use default timeout      | ✅                   |

#### 📢 ❗️ ❎ Ignore all the old PDF/CSV Lambdas. Use only the new CafeCentralExportLambda for all exports and reports. Replace the old Lambdas in API Gateway with this one.❎ ❗️ 

#### Replace 

| Lambda function          | CafeCentralExportLambda |

**⚠️ Region must match Lambda region**

#### 2️⃣ Click Save

If AWS asks permission:

> **“Allow API Gateway to invoke Lambda?”**

- ✔️ Click OK

#### 6️⃣ – ENABLE CORS (DO NOT MISS)

- Select /report/pdf

- Click Enable CORS

- **In popup:**

    - Leave default values

- Click Enable CORS and replace existing CORS headers

- Click Yes, replace existing values

**✅ CORS headers added**

#### 7️⃣ – DEPLOY API (MANDATORY)

If you skip this → NOTHING WILL WORK

- Click Deploy API

- **Deployment stage:**

    - **Choose existing stage (example: prod)**

- Click Deploy

#### 8️⃣ – COPY FINAL PDF API URL

#### After deploy, copy this:

```
https://API_ID.execute-api.REGION.amazonaws.com/prod/report/pdf
```

#### ✏️ Replace:

- API_ID

- REGION

SAVE THIS URL – you will use it in frontend

#### 9️⃣ – UNDERSTAND page QUERY PARAMETER (VERY IMPORTANT)

#### Your Lambda reads:

```
event.queryStringParameters.page
```

#### So API expects:

| Page         | URL                  |
| ------------ | -------------------- |
| Analytics    | `?page=analytics`    |
| Order Status | `?page=order-status` |


#### 🔟 – TEST API WITHOUT FRONTEND (DO THIS FIRST)

#### 1️⃣ Test from Browser (FASTEST)

- **Paste in browser:**

```
https://API_ID.execute-api.REGION.amazonaws.com/prod/report/pdf?page=analytics
```

#### EXPECTED RESULT:

- Browser downloads OR opens PDF

- Lambda logs show SUCCESS

- S3 bucket contains:

    ```
    analytics_report_YYYY-MM-DD.pdf
    ```

#### 1️⃣ Test Order Status PDF

- **Paste:**

```
https://API_ID.execute-api.REGION.amazonaws.com/prod/report/pdf?page=order-status
```

#### EXPECTED RESULT:

- PDF opens/downloads

- Order table visible

- S3 object created:

    ```
    order-status_report_YYYY-MM-DD.pdf
    ```

❌ If this fails → STOP

❌ Do NOT touch frontend yet

#### 1️⃣1️⃣ – TEST FROM LAMBDA CONSOLE (MANDATORY)

- Open Lambda → CafePDFReportLambda

- Click Test

- Create test event

- **Name:**

```
AnalyticsPDFTest
```

#### 📢 ❗️ ❎ Ignore all the old PDF/CSV Lambdas. Use only the new CafeCentralExportLambda for all exports and reports. Replace the old Lambdas in API Gateway with this one.❎ ❗️ 

#### Replace 

| Lambda function          | CafeCentralExportLambda |

#### 1️⃣ Test Event JSON (COPY EXACTLY)

```
{
  "queryStringParameters": {
    "page": "analytics"
  }
}
```

- Click Test

#### EXPECT:

- StatusCode: 200

- No errors

- PDF saved to S3

#### 2️⃣ Order Status Lambda Test

Create new test:

```
{
  "queryStringParameters": {
    "page": "order-status"
  }
}
```

#### 1️⃣2️⃣ – CONNECT ANALYTICS PAGE BUTTON

#### 1️⃣ Open analytics.html

#### 2️⃣ Replace downloadPDF() with:

```
function downloadPDF(){
  window.open(
    "https://API_ID.execute-api.REGION.amazonaws.com/prod/report/pdf?page=analytics",
    "_blank"
  );
}
```

#### ⚠️ Replace:

- API_ID

- REGION

#### 1️⃣3️⃣ – CONNECT ORDER STATUS PAGE BUTTON

#### 1️⃣ Open order-status.html

#### 2️⃣ Add / Update function:

```
function downloadOrderPDF(){
  window.open(
    "https://API_ID.execute-api.REGION.amazonaws.com/prod/report/pdf?page=order-status",
    "_blank"
  );
}
```

#### 3️⃣ Attach button:

```
<button class="btn btn-success btn-sm" onclick="downloadOrderPDF()">
  📄 Download Orders PDF
</button>
```

#### 1️⃣4️⃣ – FINAL FULL TEST (DO NOT SKIP)

**✔ Test Matrix**

| Test                         | Result |
| ---------------------------- | ------ |
| Browser direct analytics PDF | ✅      |
| Browser direct order PDF     | ✅      |
| Lambda test analytics        | ✅      |
| Lambda test order-status     | ✅      |
| Analytics page button        | ✅      |
| Order status page button     | ✅      |


#### 1️⃣5️⃣ STATUS: COMPLETE & VERIFIED

✔ API Gateway connected

✔ Lambda receives page parameter

✔ Two pages → one PDF Lambda

✔ Browser downloads PDF

✔ Safe to move to next phase

#### 🔒 IMPORTANT RULE

**❗ DO NOT MOVE TO NEXT PHASE UNTIL ALL TESTS ABOVE PASS**


**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---
## PHASE 4️⃣  Automation Monthly Auto Report

### 2️⃣ METHOD 1- EventBridge Schedule Using Lambda Trigger  (Recommanded)

#### 1️⃣ TASK 1️⃣: ADD DAILY ORDER STATUS PDF (USING LAMBDA TRIGGER)

#### 1️⃣ OPEN LAMBDA

- AWS Console → Lambda

- Click CafePDFReportLambda

#### 📢 ❗️ ❎ Ignore all the old PDF/CSV Lambdas. Use only the new CafeCentralExportLambda for all exports and reports. Replace the old Lambdas in API Gateway with this one.❎ ❗️ 

#### Replace 

| Lambda function          | CafeCentralExportLambda |

#### 2️⃣ OPEN TRIGGERS TAB

- Scroll to Function overview

- Click ➕ Add trigger

#### 3️⃣ SELECT EVENT SOURCE

- Select source: EventBridge (CloudWatch Events)

**⚠️ This opens EventBridge configuration inside Lambda**

#### 4️⃣ CONFIGURE EVENTBRIDGE RULE

- **Rule settings:**

| Field            | Value                           |
| ---------------- | ------------------------------- |
| Rule             | **Create a new rule**           |
| Rule name        | `DailyOrderPDF`                 |
| Rule description | Generate Order Status PDF daily |
| Rule type        | **Schedule expression**         |

#### 📢 ❗️ ❎ Ignore all the old PDF/CSV Lambdas. Use only the new CafeCentralExportLambda for all exports and reports. Replace the old Lambdas in API Gateway with this one.❎ ❗️ 

#### Replace 

| Lambda function          | CafeCentralExportLambda |

#### 5️⃣ ADD CRON SCHEDULE

**Paste exactly this:**

```
cron(0 0 * * ? *)
```
#### 🕐 TEST – EventBridge – Multiple Schedules for Lambda

#### 🕐 TEST – SHORT SCHEDULE (10-Minute Test - Recommanded)
> **Calculate Next 10-Minute Trigger Time (UTC)**

- Suppose your current UTC time is 15:20

- Add 10 minutes → 15:30

- You need cron expression for UTC 15:30 today

```
cron(30 15 * * ? *)
```

#### 💡 Format reminder:

```
cron(Minute Hour Day-of-Month Month Day-of-Week Year)
```

#### 🕐 TEST – Every 10 minutes SCHEDULE
> **Every 10 minutes → quick refresh/testing or frequent updates**

#### Cron expression:

```
cron(0/10 * * * ? *)
```

#### Explanation:

- 0/10 → start at minute 0, repeat every 10 minutes

- * → every hour, every day, every month

- ? → placeholder for day-of-week (required by AWS cron)

- * → every year


#### 🕐 TEST – Every hour SCHEDULE
> **Every hour → summary report**

#### Cron expression:

```
cron(0 0/1 * * ? *)
```

#### Explanation:

- 0 → run at 0th minute

- 0/1 → every 1 hour

- * → every day, every month

- ? → placeholder for day-of-week

- * → every year

#### 🔘 Explanation (DO NOT CHANGE):

- Runs every day

- Time: 00:00 UTC

- **AWS requires ? in day-of-month or day-of-week**

#### 6️⃣ CONFIGURE INPUT (VERY IMPORTANT)

Scroll to Configure input

- Select: Constant (JSON text)

- **Paste EXACT JSON:**

```
{
  "queryStringParameters": {
    "page": "order-status"
  }
}
```

**❗ This JSON is mandatory**

**❗ Without this, Lambda won’t know which PDF to generate**

#### 7️⃣ ADD TRIGGER

- Click Add

- Trigger appears in Lambda diagram

**✅ Daily automation is now ACTIVE**


#### 2️⃣ TASK 2️⃣: ADD MONTHLY ANALYTICS PDF (USING LAMBDA TRIGGER)

#### 1️⃣ ADD SECOND TRIGGER

- In same Lambda

- Click ➕ Add trigger again

#### 2️⃣ SELECT EVENTBRIDGE

- **Source:** EventBridge (CloudWatch Events)

- **Rule:** Create a new rule

#### 3️⃣ CONFIGURE MONTHLY RULE

| Field       | Value                          |
| ----------- | ------------------------------ |
| Rule name   | `MonthlyAnalyticsPDF`          |
| Description | Generate Analytics PDF monthly |
| Rule type   | Schedule expression            |


#### 4️⃣ MONTHLY CRON EXPRESSION

- **Paste:**

```
cron(0 0 1 * ? *)
```

#### 🕐 TEST – EventBridge – Multiple Schedules for Lambda

#### 🕐 TEST – SHORT SCHEDULE (10-Minute Test - Recommanded)
> **Calculate Next 10-Minute Trigger Time (UTC)**

- Suppose your current UTC time is 15:20

- Add 10 minutes → 15:30

- You need cron expression for UTC 15:30 today

```
cron(30 15 * * ? *)
```

#### 💡 Format reminder:

```
cron(Minute Hour Day-of-Month Month Day-of-Week Year)
```

#### 🕐 TEST – Every 10 minutes SCHEDULE
> **Every 10 minutes → quick refresh/testing or frequent updates**

#### Cron expression:

```
cron(0/10 * * * ? *)
```

#### Explanation:

- 0/10 → start at minute 0, repeat every 10 minutes

- * → every hour, every day, every month

- ? → placeholder for day-of-week (required by AWS cron)

- * → every year


#### 🕐 TEST – Every hour SCHEDULE
> **Every hour → summary report**

#### Cron expression:

```
cron(0 0/1 * * ? *)
```

#### Explanation:

- 0 → run at 0th minute

- 0/1 → every 1 hour

- * → every day, every month

- ? → placeholder for day-of-week

- * → every year

#### 🔘 Meaning:

- Runs on 1st day of every month

- At 00:00 UTC

#### 5️⃣ INPUT JSON (VERY IMPORTANT)

- **Select Constant (JSON text) and paste:**

```
{
  "queryStringParameters": {
    "page": "analytics"
  }
}
```

#### 6️⃣ ADD TRIGGER

- Click Add

- Now Lambda has TWO triggers

#### TASK 3️⃣ VERIFY TRIGGERS ARE ATTACHED

#### In Lambda Function overview, you should see:

```
EventBridge (DailyOrderPDF)
EventBridge (MonthlyAnalyticsPDF)
```

**If both appear → ✅ SUCCESS**

#### TASK 4️⃣ TEST TRIGGER WITHOUT WAITING

#### TEMPORARY FAST TEST (OPTIONAL BUT RECOMMENDED)

- Click one trigger name (e.g. DailyOrderPDF)

- Click Edit

- Change schedule to:

```
rate(1 minute)
```

- Save

- Wait 1 minute

- Check S3 bucket

**📄 New PDF appears → Automation works**

> **After testing, change back to cron.**

#### TASK 5️⃣ VERIFY OUTPUT

#### Check S3

- **Bucket:** charlie-cafe-s3-bucket

**Files should look like:**

```
order-status_report_2026-01-17.pdf
analytics_report_2026-01-01.pdf
```

#### TASK 6️⃣ CLOUDWATCH LOG VERIFICATION

- Lambda → Monitor

- Click View logs in CloudWatch

- Open latest log stream

**You should see:**

```
PDF generated successfully
Uploaded to S3: cafe-reports
```

#### ✅ FINAL CONFIRMATION CHECKLIST

| Item                           | Status |
| ------------------------------ | ------ |
| Lambda manual test             | ✅      |
| Daily EventBridge trigger      | ✅      |
| Monthly EventBridge trigger    | ✅      |
| Correct JSON input             | ✅      |
| PDF stored in S3               | ✅      |
| No UI EventBridge setup needed | ✅      |


#### 🎯 WHY THIS METHOD IS BETTER

✔ Faster

✔ Less mistakes

✔ IAM auto-permission

✔ Cleaner setup

✔ Same result as EventBridge console

### 3️⃣ METHOD 2- EVENTBRIDGE

**✅ ADD EVENTBRIDGE TRIGGER TO CafePDFReportLambda**

#### 📢 ❗️ ❎ Ignore all the old PDF/CSV Lambdas. Use only the new CafeCentralExportLambda for all exports and reports. Replace the old Lambdas in API Gateway with this one.❎ ❗️ 

#### Replace 

| Lambda function          | CafeCentralExportLambda |

### 1️⃣ CREATE DAILY ORDER STATUS PDF EVENTBRIDGE RULE

#### 1️⃣ Go to EventBridge

- **Go to EventBridge → Rules → Create rule**

#### 2️⃣ Configure Rule

- **Name:** DailyOrderPDF

- **Description:** “Generate Order Status PDF daily”

- **Event bus:** default

- **Rule type:** Schedule

- **Cron expression for daily midnight:**

```
cron(0 0 * * ? *)
```

**➡️ Runs daily at 00:00 UTC**

**⚠️ If you want local time (Pakistan = UTC+5):**

```
cron(0 19 * * ? *)
```

#### 🕐 TEST – EventBridge – Multiple Schedules for Lambda

#### 🕐 TEST – SHORT SCHEDULE (10-Minute Test - Recommanded)
> **Calculate Next 10-Minute Trigger Time (UTC)**

- Suppose your current UTC time is 15:20

- Add 10 minutes → 15:30

- You need cron expression for UTC 15:30 today

```
cron(30 15 * * ? *)
```

#### 💡 Format reminder:

```
cron(Minute Hour Day-of-Month Month Day-of-Week Year)
```

#### 🕐 TEST – Every 10 minutes SCHEDULE
> **Every 10 minutes → quick refresh/testing or frequent updates**

#### Cron expression:

```
cron(0/10 * * * ? *)
```

#### Explanation:

- 0/10 → start at minute 0, repeat every 10 minutes

- * → every hour, every day, every month

- ? → placeholder for day-of-week (required by AWS cron)

- * → every year


#### 🕐 TEST – Every hour SCHEDULE
> **Every hour → summary report**

#### Cron expression:

```
cron(0 0/1 * * ? *)
```

#### Explanation:

- 0 → run at 0th minute

- 0/1 → every 1 hour

- * → every day, every month

- ? → placeholder for day-of-week

- * → every year

- **Click Next**


> **Explanation:**

> **0 0 * * ? * → triggers at 00:00 UTC every day**

| Field | Meaning     |
| ----- | ----------- |
| 0     | minute      |
| 0     | hour        |
| *     | every day   |
| *     | every month |
| ?     | day of week |
| *     | every year  |

**⚠️ You can adjust hour/minute for your timezone**

#### 3️⃣ Add Target

- **Target:** Lambda function → CafePDFReportLambda

#### 📢 ❗️ ❎ Ignore all the old PDF/CSV Lambdas. Use only the new CafeCentralExportLambda for all exports and reports. Replace the old Lambdas in API Gateway with this one.❎ ❗️ 

#### Replace 

| Lambda function          | CafeCentralExportLambda |

- **Configure input:**

    - **Select Constant (JSON text)**

    - **Paste JSON for Order Status PDF:**

```
{
  "queryStringParameters": {
    "page": "order-status"
  }
}
```

#### 📌 This tells Lambda:

- Generate Order Status PDF

#### 4️⃣ Review & Create Rule

- Review everything

- Click Create rule

**✅ DailyOrderPDF rule is LIVE**

### 2️⃣ CREATE MONTHLY ANALYTICS PDF RULE

> **Repeat steps, but with these changes 👇**

#### 1️⃣ Create Rule

- **EventBridge → Rules → Create rule**

#### 2️⃣ Rule Details

| Field       | Value                          |
| ----------- | ------------------------------ |
| Name        | `MonthlyAnalyticsPDF`          |
| Description | Generate Analytics PDF monthly |
| Rule type   | Schedule                       |

#### 3️⃣ Cron Expression (1st of Month)

```
cron(0 0 1 * ? *)
```

#### 🕐 TEST – EventBridge – Multiple Schedules for Lambda

#### 🕐 TEST – SHORT SCHEDULE (10-Minute Test - Recommanded)
> **Calculate Next 10-Minute Trigger Time (UTC)**

- Suppose your current UTC time is 15:20

- Add 10 minutes → 15:30

- You need cron expression for UTC 15:30 today

```
cron(30 15 * * ? *)
```

#### 💡 Format reminder:

```
cron(Minute Hour Day-of-Month Month Day-of-Week Year)
```

#### 🕐 TEST – Every 10 minutes SCHEDULE
> **Every 10 minutes → quick refresh/testing or frequent updates**

#### Cron expression:

```
cron(0/10 * * * ? *)
```

#### Explanation:

- 0/10 → start at minute 0, repeat every 10 minutes

- * → every hour, every day, every month

- ? → placeholder for day-of-week (required by AWS cron)

- * → every year


#### 🕐 TEST – Every hour SCHEDULE
> **Every hour → summary report**

#### Cron expression:

```
cron(0 0/1 * * ? *)
```

#### Explanation:

- 0 → run at 0th minute

- 0/1 → every 1 hour

- * → every day, every month

- ? → placeholder for day-of-week

- * → every year

**➡️ Runs once per month on the 1st day at 00:00 UTC**

#### 4️⃣ Target Configuration

- **Target:** Lambda function

- **Function:** CafePDFReportLambda

#### 📢 ❗️ ❎ Ignore all the old PDF/CSV Lambdas. Use only the new CafeCentralExportLambda for all exports and reports. Replace the old Lambdas in API Gateway with this one.❎ ❗️ 

#### Replace 

| Lambda function          | CafeCentralExportLambda |

#### 5️⃣ Lambda Input JSON (VERY IMPORTANT)

```
{
  "queryStringParameters": {
    "page": "analytics"
  }
}
```

#### 📌 This tells Lambda:

- **Generate Analytics PDF**

#### 6️⃣ Create Rule

- Click Create rule

**✅ Monthly automation is complete.**

### 3️⃣ TEST EVENTBRIDGE TRIGGER (MANDATORY)

#### 1️⃣ OPTION A: Test via EventBridge

- EventBridge → Rules

- Click DailyOrderPDF

- Click Run now (or Test rule)

**🕘 Wait 5–10 seconds**

#### 2️⃣ OPTION B: Temporary Fast Test (Recommended)

- Edit rule

- Change schedule to:

```
rate(1 minute)
```

- Save

- Wait 1 minute

- Confirm PDF created

- Change cron back to original

### 4️⃣ VERIFY PDF GENERATION

#### 1️⃣  Go to:

```
AWS Console → S3 → your bucket
```

#### You should see files like:

```
order-status_2026-01-17.pdf
analytics_2026-01-01.pdf
```

#### 2️⃣  Open → PDF contains:

- Tables

- Totals

- Logo

- Correct data

### 5️⃣ Confirm Lambda & EventBridge

- Test in Lambda console → works ✅

- EventBridge trigger → works ✅

- PDFs in S3 → accessible ✅

- Both page types supported (analytics & order-status) ✅

### 💡 Tip:For testing purposes, you can temporarily set EventBridge cron to rate(1 minute) to quickly see PDFs being generated before switching to daily/monthly schedules.

### 🎯 FINAL RESULT

#### You now have:

🕒 Fully automated PDF reports

📄 Daily Order Status

📊 Monthly Analytics

☁️ Serverless

💰 Zero manual work

🧠 Enterprise-grade design

**✅ PHASE 4️⃣ STATUS**

> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**
---
## PHASE 5️⃣  CSV EXPORT (PROFESSIONAL)

### 1️⃣ — Cafe Analytics CSV Lambda

- **Go to: AWS Console → Lambda → Create function**

#### 📢 ❗️ ❎ Ignore all the old PDF/CSV Lambdas. Use only the new CafeCentralExportLambda for all exports and reports. Replace the old Lambdas in API Gateway with this one.❎ ❗️ 

#### Replace 

| Lambda function          | CafeCentralExportLambda |

#### 1️⃣ Create new Lambda function

| Field         | Value                  |
| ------------- | ---------------------- |
| Function name | CafeAnalyticsCSVLambda |
| Runtime       | Python 3.10            |
| Architecture  | x86_64                 |

- **Create function**

**✅ Lambda is created**

### 2️⃣ SET LAMBDA PERMISSIONS (VERY IMPORTANT)

- **Go to Configuration → Permissions**
- **Click IAM Role name (blue link)**
- **IAM → Add permissions → Attach policies**

#### Attach ALL:

✔ AmazonDynamoDBReadOnlyAccess

✔ AWSLambdaBasicExecutionRole

- **Click Add permissions**

**✅ Lambda can now read DynamoDB**

### 3️⃣ CafeAnalyticsCSVLambda CODE

[CafeAnalyticsCSVLambda.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeAnalyticsLambda/CafeAnalyticsCSVLambda.py)

#### 📢 ❗️ ❎ Ignore all the old PDF/CSV Lambdas. Use only the new CafeCentralExportLambda for all exports and reports. Replace the old Lambdas in API Gateway with this one.❎ ❗️ 

#### Replace 

| Lambda function          | CafeCentralExportLambda |

#### DEPLOY LAMBDA

- **Click Deploy**
- **Wait for Success message**

**Code is live**

### 4️⃣ CREATE API GATEWAY ENDPOINT

- **Go to: API Gateway → Your API**

- **Select existing /analytics resource**

#### 1️⃣ New API Resource

```
GET /analytics/csv
```

#### Fill:

| Field         | Value |
| ------------- | ----- |
| Resource Name | csv   |
| Resource Path | csv   |

**✔ Click Create Resource**

#### 2️⃣ CREATE GET METHOD

- **Select /analytics/csv**
- **Click Create Method → GET**

#### Method Setup:

| Setting          | Value                  |
| ---------------- | ---------------------- |
| Integration type | Lambda                 |
| Lambda function  | CafeAnalyticsCSVLambda |
| Use Lambda proxy | ✔ Enabled              |

#### 📢 ❗️ ❎ Ignore all the old PDF/CSV Lambdas. Use only the new CafeCentralExportLambda for all exports and reports. Replace the old Lambdas in API Gateway with this one.❎ ❗️ 

#### Replace 

| Lambda function          | CafeCentralExportLambda |

- **Click Save**

#### 3️⃣ ENABLE COGNITO AUTHORIZER

- **Open GET /analytics/csv**
- **Click Method Request**
- **Set:**

```
Authorization → Cognito Authorizer
```

- **Choose same authorizer used for analytics**

- **✔ Save**

#### 4️⃣ — DEPLOY API

- **Click Deploy API**
- **Choose stage:**

```
prod
```

- **Click Deploy**

### 5️⃣ TEST CSV EXPORT (MANDATORY)

#### 1️⃣ TEST AS ADMIN (SUCCESS)

#### Use browser or curl:

```
https://API_ID.execute-api.REGION.amazonaws.com/prod/analytics/csv
```

✔ Logged in as Admin

#### ✅ EXPECTED RESULT:

#### ⬇️ File downloads automatically:

```
cafe-analytics.csv
```

#### 2️⃣ Open file → Should show:

```
Item,Quantity,Sales,Cost,Profit
Latte,10,50,30,20
Espresso,5,25,15,10
```

#### 2️⃣ ❌ TEST AS STAFF (BLOCKED)

- Login as Staff

- Open same URL

#### ✅ EXPECTED RESULT:

```
403 Access denied
```

✔ Security verified

### ✅ PHASE 5️⃣ FINAL STATUS

🟢 PHASE 13 COMPLETE

🟢 TESTED

🟢 ADMIN-ONLY CSV DOWNLOAD

🟢 NO EXISTING SYSTEM BROKEN

**✅ PHASE 5️⃣ STATUS**

> **🟢 PHASE 5️⃣ COMPLETE & VERIFIED**
---
## PHASE 6️⃣  DAILY AUTO PDF WITH TABLES & LOGO

### 1️⃣ CREATE Or Open existing S3 BUCKET

```
charlie-cafe-s3-bucket
```

### 2️⃣ Region:

✔ Same region as Lambda

### 3️⃣ Settings:

✔ Block all public access → ON

✔ Bucket versioning → Optional (OFF is fine)

- **Create bucket**

#### ✅ Bucket created

### 4️⃣ UPLOAD LOGO FILE (VERY IMPORTANT)

```
Cafelogo.png
```

#### ⚠️ Exact name is REQUIRED
> **(Case-sensitive)**

#### ✅ Logo stored in S3

### 5️⃣ CREATE PDF LAMBDA

#### 📢 ❗️ ❎ Ignore all the old PDF/CSV Lambdas. Use only the new CafeCentralExportLambda for all exports and reports. Replace the old Lambdas in API Gateway with this one.❎ ❗️ 

#### Replace 

| Lambda function          | CafeCentralExportLambda |

#### Basic Configuration

| Parameter            | Value                  |
|----------------------|------------------------|
| Creation method      | Author from scratch    |
| Function name        | CafeDailyPDFLambda     |
| Runtime              | Python 3.10            |
| Architecture         | x86_64                 |

- **✔️ Create function**

### 6️⃣ ADD REPORTLAB LAYER (REQUIRED)

#### 1️⃣ Prepare reportlab.zip

Your zip must contain:

```
python/
 └── reportlab/
```

#### 2️⃣ Go to:

```
Lambda → Layers → Create layer
```

#### 3️⃣ Layer name:

```
reportlab-layer
```

#### 4️⃣ Upload ZIP:

```
reportlab.zip
```

#### 5️⃣ Compatible runtime:

```
Python 3.10
```

- **✔️ Create layer**

#### 6️⃣ Attach Layer to Lambda

```
Lambda → CafeDailyPDFLambda → Layers → Add layer
```

#### 📢 ❗️ ❎ Ignore all the old PDF/CSV Lambdas. Use only the new CafeCentralExportLambda for all exports and reports. Replace the old Lambdas in API Gateway with this one.❎ ❗️ 

#### Replace 

| Lambda function          | CafeCentralExportLambda |


✔ Select existing layer

✔ Choose reportlab-layer

✔ Click Add

### 7️⃣ IAM PERMISSIONS (NO MISS)

#### 1️⃣ Open Lambda:

```
Configuration → Permissions
```

#### 2️⃣ Click Role name:

```
CafeDailyPDFLambda-role-xxxx
```

#### 3️⃣ Attach policies:

```
AmazonS3FullAccess
AmazonDynamoDBReadOnlyAccess
```

✔ Save

### 8️⃣ REPLACE LAMBDA CODE (FULL FINAL CODE)

> **⚠️ DELETE ALL EXISTING CODE FIRST**

Then PASTE EVERYTHING BELOW

#### 1️⃣ FINAL PDF GENERATION LAMBDA (COPY-PASTE SAFE)

[CafeDailyPDFLambda.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/CafeDailyPDFLambda.py)

#### 📢 ❗️ ❎ Ignore all the old PDF/CSV Lambdas. Use only the new CafeCentralExportLambda for all exports and reports. Replace the old Lambdas in API Gateway with this one.❎ ❗️ 

#### Replace 

| Lambda function          | CafeCentralExportLambda |


✔ Click Deploy

✔ Wait for success

#### 2️⃣ USE ENVIRONMENT VARIABLES

- Open your CafeDailyPDFLambda → Configuration → Environment variables

- Add the following keys & values exactly:

| Key            | Value                  |
| -------------- | ---------------------- |
| BUCKET_NAME    | charlie-cafe-s3-bucket |
| LOGO_KEY       | Cafelogo.png           |
| DYNAMODB_TABLE | CafeOrders             |
| AWS_REGION     | ap-south-1             |

- Save changes.

- In the code, the Lambda reads these using os.environ.get(...).

**⚡ Benefit: You no longer need to edit code when bucket/table changes.**

#### 3️⃣ MANUAL TEST (MANDATORY BEFORE NEXT PHASE)

- **Lambda → Test → Create test event**
- **Event name:**

```
manual-test
```

- **Event JSON:**

```
{}
```

- **Test**

#### ✅ EXPECTED RESULT

✔ StatusCode: 200

✔ Message:

```
PDF generated and uploaded
```

#### 4️⃣ VERIFY PDF OUTPUT

- **S3 → charlie-cafe-s3-bucket → daily_reports/**

- **File exists:** daily_YYYY-MM-DD.pdf

- **Download & open PDF**

✔ Logo visible

✔ Table visible

✔ Correct profit values


### 9️⃣ EventBridge Rule (AUTOMATION)

- **Amazon EventBridge → Rules → Create rule**

#### 1️⃣ Rule Details

- **Rule name: (optional, but recommended)**

```
DailyCafePDFRule
```

- **Description: (optional, but recommended)**

```
Triggers CafeDailyPDFLambda every day at midnight UTC
```

#### 📢 ❗️ ❎ Ignore all the old PDF/CSV Lambdas. Use only the new CafeCentralExportLambda for all exports and reports. Replace the old Lambdas in API Gateway with this one.❎ ❗️ 

#### Replace 

| Lambda function          | CafeCentralExportLambda |


- **Define pattern:**

- **➡️ Choose Schedule**

#### 2️⃣ Schedule Pattern (CRON)

- Select Cron expression

- Enter exact UTC cron expression:

> **(midnight UTC)**

```
cron(0 0 * * ? *)
```

#### 🕐 TEST – EventBridge – Multiple Schedules for Lambda

#### 🕐 TEST – SHORT SCHEDULE (10-Minute Test - Recommanded)
> **Calculate Next 10-Minute Trigger Time (UTC)**

- Suppose your current UTC time is 15:20

- Add 10 minutes → 15:30

- You need cron expression for UTC 15:30 today

```
cron(30 15 * * ? *)
```

#### 💡 Format reminder:

```
cron(Minute Hour Day-of-Month Month Day-of-Week Year)
```

#### 🕐 TEST – Every 10 minutes SCHEDULE
> **Every 10 minutes → quick refresh/testing or frequent updates**

#### Cron expression:

```
cron(0/10 * * * ? *)
```

#### Explanation:

- 0/10 → start at minute 0, repeat every 10 minutes

- * → every hour, every day, every month

- ? → placeholder for day-of-week (required by AWS cron)

- * → every year


#### 🕐 TEST – Every hour SCHEDULE
> **Every hour → summary report**

#### Cron expression:

```
cron(0 0/1 * * ? *)
```

#### Explanation:

- 0 → run at 0th minute

- 0/1 → every 1 hour

- * → every day, every month

- ? → placeholder for day-of-week

- * → every year

✔ Daily midnight PDF

✔ Stored in S3

#### 💡 Explanation:

| Field        | Value | Meaning                  |
| ------------ | ----- | ------------------------ |
| Minute       | 0     | At 0 minutes             |
| Hour         | 0     | At 0 hour (midnight UTC) |
| Day-of-month | *     | Every day                |
| Month        | *     | Every month              |
| Day-of-week  | ?     | No specific day of week  |
| Year         | *     | Every year               |

> **This will run every day at midnight UTC**

#### 3️⃣ Add Target

- Scroll down to Select targets → Lambda function

- In the dropdown, select:

```
CafeDailyPDFLambda
```

#### 📢 ❗️ ❎ Ignore all the old PDF/CSV Lambdas. Use only the new CafeCentralExportLambda for all exports and reports. Replace the old Lambdas in API Gateway with this one.❎ ❗️ 

#### Replace 

| Lambda function          | CafeCentralExportLambda |


- Click Create a new role for this specific resource (if not using existing)

`- Or choose existing IAM role that allows EventBridge → Lambda invoke

**✔ This IAM role must have permission to invoke your Lambda**

#### 4️⃣ Configure Dead Letter Queue (Optional but recommended)

- Keep default None (for now)

- Or add SQS if you want retries

#### 5️⃣ Tags (Optional)

Add tags like:

```
Environment: Production
Project: CharlieCafeLab
```

#### 6️⃣ Review + Create

- Review all settings carefully

- Click Create rule**

✅ Rule created

✅ You now have EventBridge → Lambda

#### 7️⃣ Verify Lambda Trigger

- **Go to Lambda → CafeDailyPDFLambda → Configuration → Triggers**

#### 📢 ❗️ ❎ Ignore all the old PDF/CSV Lambdas. Use only the new CafeCentralExportLambda for all exports and reports. Replace the old Lambdas in API Gateway with this one.❎ ❗️ 

#### Replace 

| Lambda function          | CafeCentralExportLambda |

- You should see:

```
EventBridge (DailyCafePDFRule)
```

#### 8️⃣ Manual Test (Before waiting for midnight)

- **Go to Lambda → CafeDailyPDFLambda → Test**

- **Event JSON:**

```
{}
```

- **Click Test**

- Verify S3 bucket:

```
charlie-cafe-s3-bucket/daily_reports/
```

- File exists: daily_YYYY-MM-DD.pdf

- Logo + table visible

> **This ensures EventBridge will run correctly at schedule**


**✅ PHASE 6️⃣ STATUS**

> **🟢 PHASE 6️⃣ COMPLETE & VERIFIED**
---
## 🖨 PHASE 7️⃣ PDF BUTTON INTEGRATION

> **FRONTEND → EXISTING LAMBDA**

**🏷 You already did backend correctly ✅ Now we only connect buttons.**

### ✅ Method 1️⃣ -  FINAL UPDATED order-status.html

[order-status.html](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order-status/CC%20-%20Order-Status_LIVE%20ADMIN%20DASHBOARD_many%20orders/order-status.html)

#### 5️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```

#### 6️⃣ Fix File Permissions

```
sudo chown apache:apache /var/www/html/order-status.html
```

```
sudo chmod 644 /var/www/html/order-status.html
```

#### 7️⃣ Restart Apache (MANDATORY)

```
sudo systemctl restart httpd
```

#### 8️⃣ Open page in browser

```
http://EC2 Public IP/order-status.html
```

### 6️⃣ Test (DO NOT SKIP)

#### 1️⃣ Open page

```
https://YOUR_EC2 Public IP/order-status.html
```

#### 2️⃣ You should be redirected to Cognito login

#### 3️⃣ TEST 1️⃣ — STAFF USER (RBAC + ORDER STATUS)

#### 🎯 Purpose

#### Verify:

- Login works

- Order dashboard loads

- Analytics & PDF are hidden

#### Steps

1️⃣ Open order-status.html in browser

2️⃣ You are redirected to Cognito Login

3️⃣ Login using a Staff user (belongs to Staff group)

4️⃣ After login, confirm:

✔ Orders table loads

✔ Metrics cards show

✔ Chart shows

❌ Analytics button NOT visible

❌ PDF button NOT visible

**✅ PASS RESULT**

> **Staff can see orders only**

#### 4️⃣ Logout as STAFF USER

#### 5️⃣ TEST 2️⃣ — ADMIN USER (Analytics + PDF)

#### 🎯 Purpose

#### Verify:

- Admin privileges

- Analytics + PDF access

####  Steps

1️⃣ Logout

2️⃣ Open order-status.html again

3️⃣ Login using an Admin user (belongs to Admin group)

4️⃣ After login, confirm:

✔ Orders dashboard loads

✔ Analytics button visible

✔ PDF button visible

5️⃣ Click 📊 Analytics

  - Metrics load

  - No errors

6️⃣ Click 📄 PDF

  - New tab opens

  - PDF downloads or opens

**✅ PASS RESULT**

> **Admin sees everything**

#### 6️⃣ Logout as Admin USER

#### 7️⃣ 🔴 IF ANYTHING FAILS (Quick Fix)

#### 1️⃣ ❌ Analytics/PDF not showing for Admin?

#### Check:

```
parseJwt(token)["cognito:groups"]
```

**👉 Admin must be in Cognito group Admin**

#### 2️⃣ ❌ Redirect loop?

#### Check:

- Redirect URI exactly matches Cognito App Client

- No trailing slash mismatch

### 🧪 FINAL TEST CHECKLIST (DO NOT SKIP)

✔ Staff cannot see PDF

✔ Admin sees PDF

✔ Admin PDF opens

✔ Staff print works

✔ Mobile view OK

✔ Dark/light toggle works

✔ Analytics link opens

✔ Lambda still works

### ✅ CURRENT STATUS

🟢 Frontend printing — COMPLETE

🟢 Backend PDF — COMPLETE

🟢 RBAC — COMPLETE

🟢 UI professional — COMPLETE


**✅ PHASE 7️⃣ STATUS**

> **🟢 PHASE 7️⃣ COMPLETE & VERIFIED**
---

## PHASE 8️⃣  Test

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
cron(0/10 * * * ? *)
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

**✅ PHASE 8️⃣ STATUS**

> **🟢 PHASE 8️⃣ COMPLETE & VERIFIED**
---
## ☕ Charlie Café PHASE 9️⃣ — Update CafePDFReportLambda for HR & Attendance

### 📃 Research and Development (Just for CaseStudy)

#### 1️⃣ Can we reuse the existing PDF Lambda?

✅ Yes, you can reuse it, because:

- Your current Lambda already:

    - Generates a PDF using ReportLab

    - Uploads it to S3

    - Handles dynamic content based on page_type

- It’s generic enough to handle any tabular report, including attendance or employee reports

- It already has environment variables for S3 bucket and files, so you don’t need a new Lambda for PDF generation unless you want totally separate deployment for HR.

#### 2️⃣ How to integrate HR/Attendance into existing Lambda

#### Step 1: Add a new page_type for HR

#### In your Lambda:

```
page_type = event.get("queryStringParameters", {}).get("page", "analytics")
```

- Right now it checks "analytics" or "order-status"

- We can add "attendance":

#### 📢 ❗️ ❎ Ignore all the old PDF/CSV Lambdas. Use only the new CafeCentralExportLambda for all exports and reports. Replace the old Lambdas in API Gateway with this one.❎ ❗️ 

#### Replace 

| Lambda function          | CafeCentralExportLambda |

```
elif page_type == "attendance":
    elements.append(Paragraph("📋 Employee Attendance Report", styles["Title"]))
    elements.append(Paragraph(f"Generated: {today}", styles["Normal"]))
    elements.append(Spacer(1, 15))

    # Fetch attendance data from RDS
    import pymysql

    connection = pymysql.connect(
        host=os.environ['DB_HOST'],
        user=os.environ['DB_USER'],
        password=os.environ['DB_PASS'],
        database=os.environ['DB_NAME'],
        cursorclass=pymysql.cursors.DictCursor
    )

    with connection.cursor() as cursor:
        cursor.execute("""
            SELECT e.name, e.job_title, a.attendance_date, a.checkin_time, a.checkout_time
            FROM attendance a
            JOIN employees e ON a.employee_id = e.employee_id
            ORDER BY a.attendance_date DESC
        """)
        records = cursor.fetchall()

    table_data = [["Employee", "Job Title", "Date", "Check-In", "Check-Out"]]
    for r in records:
        table_data.append([
            r["name"],
            r["job_title"],
            str(r["attendance_date"]),
            str(r.get("checkin_time") or ""),
            str(r.get("checkout_time") or "")
        ])

    table = Table(table_data, colWidths=[120, 100, 80, 60, 60])
    table.setStyle(TableStyle([
        ("BACKGROUND", (0,0), (-1,0), colors.darkgreen),
        ("TEXTCOLOR", (0,0), (-1,0), colors.whitesmoke),
        ("ALIGN", (0,0), (-1,-1), "CENTER"),
        ("GRID", (0,0), (-1,-1), 0.5, colors.black),
        ("BACKGROUND", (0,1), (-1,-1), colors.lightgrey)
    ]))

    elements.append(table)
```

#### Step 2: Add HR-specific environment variables

- DB_HOST → RDS endpoint

- DB_NAME → cafedb

- DB_USER / DB_PASS → credentials

- S3 bucket can remain the same (or use a new folder hr/attendance/ for organization)

#### Step 3: Use page=attendance in your API call

Example URL from frontend:

```
https://<your-api-gateway>/generate-pdf?page=attendance
```

- Lambda will detect page_type="attendance" and generate Attendance PDF

- No need for new Lambda function

- You save time and resources

#### ✅ My Recommendation (Time-Saving, Professional)

- Do not create a new Lambda for PDF yet

- Use your existing PDF Lambda

- Just add a new page_type branch for "attendance" (and optionally "employee-profile" if needed)

- Hook your HR Lambda data (attendance, leaves, profile) via RDS queries inside this branch

#### This way:

- 1 Lambda handles all PDF generation

- No duplication

- Easy maintenance

---

### 1️⃣ Step 1️⃣ – Update CafePDFReportLambda for HR & Attendance

> *8We are going to add a new page_type branch for HR/Attendance reports.**

#### 📢 ❗️ ❎ Ignore all the old PDF/CSV Lambdas. Use only the new CafeCentralExportLambda for all exports and reports. Replace the old Lambdas in API Gateway with this one.❎ ❗️ 

#### Replace 

| Lambda function          | CafeCentralExportLambda |

#### Updated Lambda Code

```
import os
import boto3
import io
import datetime
import pymysql  # Required for RDS access
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Image, Spacer
from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet

# =======================
# ENVIRONMENT VARIABLES
# =======================
ORDERS_TABLE_NAME = os.environ.get("ORDERS_TABLE_NAME")  # Existing DynamoDB orders table
REPORTS_BUCKET_NAME = os.environ.get("REPORTS_BUCKET_NAME")  # S3 bucket for storing PDFs
LOGO_FILE_NAME = os.environ.get("LOGO_FILE_NAME", "")  # Optional logo file
DB_HOST = os.environ.get("DB_HOST")  # RDS endpoint for HR/Attendance
DB_NAME = os.environ.get("DB_NAME")
DB_USER = os.environ.get("DB_USER")
DB_PASS = os.environ.get("DB_PASS")

# =======================
# AWS CLIENTS
# =======================
dynamodb = boto3.resource("dynamodb")
orders_table = dynamodb.Table(ORDERS_TABLE_NAME)
s3 = boto3.client("s3")

# =======================
# DATABASE CONNECTION
# =======================
def get_db_connection():
    """Return a pymysql connection to RDS"""
    return pymysql.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASS,
        database=DB_NAME,
        cursorclass=pymysql.cursors.DictCursor
    )

def lambda_handler(event, context):
    """Main Lambda Handler"""
    
    # Determine type of report to generate
    page_type = event.get("queryStringParameters", {}).get("page", "analytics")
    today = datetime.date.today()

    # PDF buffer setup
    buffer = io.BytesIO()
    doc = SimpleDocTemplate(buffer, pagesize=A4, rightMargin=40, leftMargin=40, topMargin=40, bottomMargin=40)
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
    # CAFE SALES ANALYTICS PDF
    # =======================
    if page_type == "analytics":
        elements.append(Paragraph("📊 Cafe Sales Analytics Report", styles["Title"]))
        elements.append(Paragraph(f"Generated: {today}", styles["Normal"]))
        elements.append(Spacer(1, 15))
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
    # HR & ATTENDANCE PDF
    # =======================
    elif page_type == "attendance":
        elements.append(Paragraph("📋 Employee Attendance Report", styles["Title"]))
        elements.append(Paragraph(f"Generated: {today}", styles["Normal"]))
        elements.append(Spacer(1, 15))

        # Connect to RDS and fetch attendance & employee data
        conn = get_db_connection()
        with conn.cursor() as cursor:
            cursor.execute("""
                SELECT e.name, e.job_title, a.attendance_date, a.checkin_time, a.checkout_time
                FROM attendance a
                JOIN employees e ON a.employee_id = e.employee_id
                ORDER BY a.attendance_date DESC
            """)
            records = cursor.fetchall()

        # Create table data
        table_data = [["Employee", "Job Title", "Date", "Check-In", "Check-Out"]]
        for r in records:
            table_data.append([
                r["name"],
                r["job_title"],
                str(r["attendance_date"]),
                str(r.get("checkin_time") or ""),
                str(r.get("checkout_time") or "")
            ])

        # Format table
        table = Table(table_data, colWidths=[120, 100, 80, 60, 60])
        table.setStyle(TableStyle([
            ("BACKGROUND", (0,0), (-1,0), colors.darkgreen),
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

    # Upload to S3
    s3_key = f"{page_type}_report_{today}.pdf"
    s3.put_object(
        Bucket=REPORTS_BUCKET_NAME,
        Key=s3_key,
        Body=buffer.getvalue(),
        ContentType="application/pdf"
    )

    # Return PDF as response (for testing)
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/pdf"},
        "body": buffer.getvalue().decode("latin1"),
        "isBase64Encoded": False
    }
```

#### ✅ What changed / added:

- Added elif page_type == "attendance"

    - Queries RDS attendance & employees table

    - Generates a table PDF

- Added pymysql connection inside Lambda (environment variables required)

Fully commented code

- No other code changes, still handles analytics and order-status

**✅ PHASE 9️⃣ STATUS**

> **🟢 PHASE 9️⃣ COMPLETE & VERIFIED**
---
# SECTION 1️⃣  COMPLETE ✅

## ❌ ❗️❗️  ❌   End Charlie Cafe Old Printing/ CSV /PDF System ❌ ❗️❗️  ❌

---
---

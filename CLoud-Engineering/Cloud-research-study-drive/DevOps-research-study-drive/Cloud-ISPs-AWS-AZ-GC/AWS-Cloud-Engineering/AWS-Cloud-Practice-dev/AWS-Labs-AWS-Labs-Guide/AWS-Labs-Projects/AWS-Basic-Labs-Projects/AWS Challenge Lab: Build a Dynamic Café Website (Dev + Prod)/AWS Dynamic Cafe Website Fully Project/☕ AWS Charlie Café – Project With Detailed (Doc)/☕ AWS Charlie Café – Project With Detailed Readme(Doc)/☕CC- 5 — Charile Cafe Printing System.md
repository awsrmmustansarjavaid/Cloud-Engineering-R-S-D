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


---
---

## ❌ ❗️❗️  ❌   End Charlie Cafe Old Printing/ CSV /PDF System ❌ ❗️❗️  ❌

---
---

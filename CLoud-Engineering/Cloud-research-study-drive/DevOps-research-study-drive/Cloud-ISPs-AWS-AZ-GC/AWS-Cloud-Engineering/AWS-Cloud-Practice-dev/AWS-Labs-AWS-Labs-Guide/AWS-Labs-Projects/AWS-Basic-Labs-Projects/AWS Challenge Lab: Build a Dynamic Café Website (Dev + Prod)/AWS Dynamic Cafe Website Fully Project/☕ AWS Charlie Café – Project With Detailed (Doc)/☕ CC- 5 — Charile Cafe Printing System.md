# Charile Cafe Printing System

**Dev → Serverless → Secure → Scalable → Cost-Controlled**

**Author & Architecture Designer:** Charlie

**Level:** Beginner → Advanced (Production-grade)

**Approach:** AWS Console First • No Skipped Steps • Exam + Real-World Safe

### READ Me About

[Charile Cafe Printing System](./☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20Readme(Doc)/☕%20CC-%201%20—%20Order_Async_Processing_Tracking_System.md)

### ☕ AWS Charlie Café – Test & Verifications

[Charile Cafe Printing System](./☕%20AWS%20CAFE%20—%20%20Test%20%26%20Verifications/☕CC-%201%20—%20Order_Async_Processing_Tracking_System%20.md)


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



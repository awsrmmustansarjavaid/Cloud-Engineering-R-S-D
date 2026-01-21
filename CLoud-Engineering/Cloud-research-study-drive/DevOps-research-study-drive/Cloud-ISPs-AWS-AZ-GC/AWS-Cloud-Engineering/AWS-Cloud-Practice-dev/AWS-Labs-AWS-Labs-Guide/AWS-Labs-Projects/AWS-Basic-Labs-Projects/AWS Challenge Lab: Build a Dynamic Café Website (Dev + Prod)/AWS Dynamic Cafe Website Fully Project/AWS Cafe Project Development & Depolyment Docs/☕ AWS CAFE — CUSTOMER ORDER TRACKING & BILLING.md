# ☕ AWS CAFE — Customer Order Tracking, Billing & Receipt (Frontend-Only, Zero-Risk)

#### (FRONTEND EXTENSION LAB)

> **Lab Type:** Add-on / Enhancement

> **Risk Level:** Zero (No existing backend changes)

> **Purpose:** Improve customer experience with order tracking, billing, unique URLs, and printable receipts



---




---

## 🔔 PHASE 4 — Customer Order Tracking, Billing & Receipt (Frontend-Only, Zero-Risk)

### Goal:
> Allow customers to:

- Track their own order status

- View billing details

- Use a unique order URL

- Print receipt

- Auto-refresh status

- Scan QR code to reopen order

- No modification to existing order flow

### 🧱 ARCHITECTURE (IMPORTANT — READ FIRST)

#### ✅ What already exists (UNCHANGED)

- order.php → places order

- API Gateway → /orders

- Lambda → inserts order

- Database → orders table

### 🆕 What this phase adds

- New read-only page: order-status.php

- New read-only API: /order-status

- No breaking changes

- No auth required (public tracking link)

### 🧩 STEP 1 — DATABASE (VERIFY ONLY)

❌ Do NOT drop or modify existing columns

✅ Only verify these exist

#### Required columns in orders table

```
order_id        VARCHAR(40) PRIMARY KEY
customer_name  VARCHAR(100)
table_number   INT
item            VARCHAR(50)
quantity        INT
total_amount   DECIMAL(10,2)
status          VARCHAR(20)
created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
```

✔ If these already exist → DO NOTHING

✔ If order_id exists → must be unique

### 🧩 STEP 2 — BACKEND API (READ-ONLY)

#### Endpoint

```
GET /order-status?order_id=ORD-XXXX
```

#### Lambda responsibility

- Fetch order by order_id

- Return JSON

- No updates

- No auth

#### Expected JSON response (MANDATORY)

```
{
  "order": {
    "order_id": "ORD-20260114-8392",
    "customer_name": "John",
    "table_number": 4,
    "item": "Latte",
    "quantity": 2,
    "total_amount": 8.00,
    "status": "PREPARING",
    "created_at": "2026-01-14 10:42:00"
  }
}
```

✔ If this API already exists → DO NOTHING

✔ If not → create a new Lambda (read-only)

### 🧩 STEP 3 — ORDER PAGE (MINIMAL CHANGE)

#### File: order.php

After successful order placement, backend already returns order_id.

#### Add this line ONLY (no other change):

```
echo "<a class='btn btn-success mt-2'
      href='order-status.php?order_id={$order_id}'>
      📦 Track Your Order
      </a>";
```

✔ Existing order logic untouched

✔ This only adds a link

### 🧩 STEP 4 — CREATE CUSTOMER TRACKING PAGE

#### File name (NEW)

```
order-status.php
```

#### Location

```
/web/order-status.php
```

### 🧩 STEP 5 — FINAL order-status.php (LATEST VERSION)

✅ Includes ALL required features

✅ Copy–paste ready

✅ No backend changes required

#### ✅ FULL FILE — COPY & PASTE

```
<?php
$apiBaseUrl = "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/order-status";

if (!isset($_GET['order_id']) || empty($_GET['order_id'])) {
    die("❌ Invalid order reference");
}

$orderId = $_GET['order_id'];

function fetchOrder($url, $orderId) {
    $ch = curl_init($url . "?order_id=" . urlencode($orderId));
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    $res = curl_exec($ch);
    curl_close($ch);
    return json_decode($res, true);
}

$data = fetchOrder($apiBaseUrl, $orderId);
if (!isset($data['order'])) {
    die("❌ Order not found");
}

$order = $data['order'];
?>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Order Status | Charlie Cafe ☕</title>
<meta name="viewport" content="width=device-width, initial-scale=1">

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/qrcodejs/qrcode.min.js"></script>

<style>
body { background:#f4f6f9; }
.receipt {
  max-width:520px;
  margin:20px auto;
  background:#fff;
  padding:25px;
  border-radius:15px;
  box-shadow:0 15px 30px rgba(0,0,0,.15);
}
@media print {
  button, #qrBox { display:none; }
}
</style>
</head>

<body>

<div class="receipt">

<h4 class="text-center">☕ Charlie Cafe</h4>
<p class="text-center text-muted">Order Receipt</p>
<hr>

<p><b>Order ID:</b> <?= $order['order_id'] ?></p>
<p><b>Customer:</b> <?= $order['customer_name'] ?></p>
<p><b>Table:</b> <?= $order['table_number'] ?></p>
<p><b>Date:</b> <?= $order['created_at'] ?></p>

<hr>

<p><b>Item:</b> <?= $order['item'] ?></p>
<p><b>Quantity:</b> <?= $order['quantity'] ?></p>

<hr>

<p><b>Status:</b>
<span class="badge bg-info"><?= $order['status'] ?></span>
</p>

<hr>

<p class="fw-bold">Total: $<?= number_format($order['total_amount'],2) ?></p>

<div id="qrBox" class="text-center my-3">
  <div id="qrcode"></div>
  <small class="text-muted">Scan to reopen this order</small>
</div>

<button onclick="window.print()" class="btn btn-dark w-100">
🖨️ Print Receipt
</button>

</div>

<script>
new QRCode(document.getElementById("qrcode"), {
  text: window.location.href,
  width:120,
  height:120
});

// Auto refresh every 10 seconds
setInterval(() => {
  fetch(window.location.href, { cache:'no-store' })
    .then(r => r.text())
    .then(html => {
      document.open(); document.write(html); document.close();
    });
}, 10000);
</script>

</body>
</html>
```

### 🧩 STEP 6 — FINAL TEST (DO NOT SKIP)

#### 1️⃣ Place order

```
order.php → submit
```

#### 2️⃣ Get order ID

```
ORD-XXXX
```

#### 3️⃣ Open tracking link

```
order-status.php?order_id=ORD-XXXX
```

#### 4️⃣ Verify

✅ Status visible

✅ Auto refresh works

✅ QR opens same page

✅ Print hides buttons

✅ Mobile friendly

✅ PHASE 13 COMPLETE

#### You now have:

- Real customer tracking

- Unique order URLs

- Billing + receipt

- Production-grade frontend

- Zero risk to existing system

---



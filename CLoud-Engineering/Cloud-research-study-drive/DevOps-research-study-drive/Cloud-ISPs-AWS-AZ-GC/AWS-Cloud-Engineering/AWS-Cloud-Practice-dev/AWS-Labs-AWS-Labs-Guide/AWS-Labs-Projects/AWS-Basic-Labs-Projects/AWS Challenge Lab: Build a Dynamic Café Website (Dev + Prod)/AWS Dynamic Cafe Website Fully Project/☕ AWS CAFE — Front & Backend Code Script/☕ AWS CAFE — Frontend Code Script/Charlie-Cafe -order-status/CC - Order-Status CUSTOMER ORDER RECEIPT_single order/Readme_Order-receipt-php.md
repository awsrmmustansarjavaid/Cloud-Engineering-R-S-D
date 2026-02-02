# Charlie Cafe - order-receipt.php

### 🎯 Purpose

Customer-facing order receipt + live tracking

### 🔧 Features

#### ✅ Backend robustness

- Uses cURL (industry standard)

- Validates order_id

- Gracefully fails if order not found

- Sanitizes output (htmlspecialchars)

#### ✅ Complete order data

- Displays:

    - Order ID

    - Customer name

    - Table number

    - Date & time

    - Item & quantity

    - Total amount

    - Order status

#### ✅ Status lifecycle awareness

- Handles:

    - RECEIVED

    - PREPARING

    - READY

    - COMPLETED

- Each status has visual meaning (badge colors)

#### ✅ QR Code (Very Important)

- Allows:

    - Mobile scanning

    - Quick re-open order status

    - Future expansion (POS / KDS)

#### ✅ Auto refresh (Live updates)

- Page refreshes every 10 seconds

- Customer sees status change without reloading manually

#### ✅ Print-friendly receipt

- Clean invoice layout

- Print button hidden on print

- Looks professional on thermal printers

### 🧠 Real-World Use

✔ Customer confirmation page

✔ QR receipt

✔ Mobile order tracking

✔ POS receipt screen

### 🧠 ARCHITECTURAL

```
Customer → Place Order → Receipt + Live Tracking → Print / QR
```

# SECTION 1️⃣  Latest Updated Advance order-receipt.php


[order-receipt.php](./order-receipt.php)

---
# SECTION 2️⃣  Previous Versions order-receipt.php

### 1️⃣ ☕ order-receipt.php (FINAL VERSION)

#### ✅ FULL Final order-status.php FILE

```
<?php
// ================= CONFIG =================
$apiBaseUrl = "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/order-status";

// ================= GET ORDER ID =================
if (!isset($_GET['order_id']) || empty($_GET['order_id'])) {
    die("❌ Invalid order reference.");
}

$orderId = $_GET['order_id'];

// ================= CALL API =================
$apiUrl = $apiBaseUrl . "?order_id=" . urlencode($orderId);

$ch = curl_init($apiUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$response = curl_exec($ch);

if ($response === false) {
    die("❌ Failed to fetch order status.");
}

curl_close($ch);
$data = json_decode($response, true);

if (!isset($data['order'])) {
    die("❌ Order not found.");
}

$order = $data['order'];
?>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Order Status | Charlie Cafe ☕</title>
<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- Bootstrap -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
body {
    background: #f4f6f9;
}
.receipt {
    max-width: 520px;
    margin: 40px auto;
    background: #ffffff;
    padding: 30px;
    border-radius: 15px;
    box-shadow: 0 15px 30px rgba(0,0,0,0.15);
}
.status-badge {
    font-size: 14px;
    padding: 6px 12px;
}
@media print {
    button {
        display: none;
    }
}
</style>
</head>

<body>

<div class="receipt">

    <h4 class="text-center mb-3">☕ Charlie Cafe</h4>
    <p class="text-center text-muted">Order Receipt</p>

    <hr>

    <p><strong>Order ID:</strong> <?= htmlspecialchars($order['order_id']) ?></p>
    <p><strong>Customer:</strong> <?= htmlspecialchars($order['customer_name']) ?></p>
    <p><strong>Table:</strong> <?= htmlspecialchars($order['table_number']) ?></p>
    <p><strong>Date:</strong> <?= htmlspecialchars($order['created_at']) ?></p>

    <hr>

    <p><strong>Item:</strong> <?= htmlspecialchars($order['item']) ?></p>
    <p><strong>Quantity:</strong> <?= htmlspecialchars($order['quantity']) ?></p>

    <hr>

    <p>
        <strong>Status:</strong>
        <?php
        $status = $order['status'];
        $badge = "secondary";

        if ($status === "RECEIVED") $badge = "info";
        if ($status === "PREPARING") $badge = "warning";
        if ($status === "READY") $badge = "primary";
        if ($status === "COMPLETED") $badge = "success";
        ?>
        <span class="badge bg-<?= $badge ?> status-badge">
            <?= $status ?>
        </span>
    </p>

    <hr>

    <p><strong>Total Amount:</strong> $<?= number_format($order['total_amount'], 2) ?></p>

    <div class="d-grid mt-4">
        <button onclick="window.print()" class="btn btn-dark">
            🖨️ Print Receipt
        </button>
    </div>

</div>

</body>
</html>
```

#### 🔍 EXPECTED API RESPONSE FORMAT

Your backend MUST return this structure:

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
### 2️⃣ ☕ order-receipt.php — FINAL VERSION with below ALL FEATURES (Clean, documented, production-ready - Recommanded)
> **Version 1**

🔄 Auto-refresh status every 10 sec

📱 Mobile receipt layout

📦 QR code on receipt

🔔 WebSocket live updates

> **📌 Backend requirement (unchanged):**

```
GET /order-status?order_id=ORD-XXXX
```

#### 📁 FILE LOCATION

```
/web
 ├── order.php
 ├── order-status.php   ✅ (THIS FILE)
```

#### 🔽 COPY & PASTE — FULL FILE

```
<?php
// ================= CONFIG =================
$apiBaseUrl = "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/order-status";

// ================= VALIDATE INPUT =================
if (!isset($_GET['order_id']) || empty($_GET['order_id'])) {
    die("❌ Invalid order reference.");
}

$orderId = $_GET['order_id'];

// ================= FETCH ORDER =================
function fetchOrder($apiBaseUrl, $orderId) {
    $url = $apiBaseUrl . "?order_id=" . urlencode($orderId);
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    $res = curl_exec($ch);
    curl_close($ch);
    return json_decode($res, true);
}

$data = fetchOrder($apiBaseUrl, $orderId);

if (!isset($data['order'])) {
    die("❌ Order not found.");
}

$order = $data['order'];
?>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Order Receipt | Charlie Cafe ☕</title>
<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- Bootstrap -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- QR Code -->
<script src="https://cdn.jsdelivr.net/npm/qrcodejs/qrcode.min.js"></script>

<style>
body {
    background: #f4f6f9;
}
.receipt {
    max-width: 520px;
    margin: 20px auto;
    background: #ffffff;
    padding: 25px;
    border-radius: 16px;
    box-shadow: 0 15px 30px rgba(0,0,0,0.15);
}
.status-badge {
    font-size: 14px;
    padding: 6px 12px;
}
@media print {
    button, #qrBox {
        display: none;
    }
}
</style>
</head>

<body>

<div class="receipt">

    <h4 class="text-center mb-2">☕ Charlie Cafe</h4>
    <p class="text-center text-muted">Order Receipt</p>

    <hr>

    <p><strong>Order ID:</strong> <?= htmlspecialchars($order['order_id']) ?></p>
    <p><strong>Customer:</strong> <?= htmlspecialchars($order['customer_name']) ?></p>
    <p><strong>Table:</strong> <?= htmlspecialchars($order['table_number']) ?></p>
    <p><strong>Date:</strong> <?= htmlspecialchars($order['created_at']) ?></p>

    <hr>

    <p><strong>Item:</strong> <?= htmlspecialchars($order['item']) ?></p>
    <p><strong>Quantity:</strong> <?= htmlspecialchars($order['quantity']) ?></p>

    <hr>

    <?php
    $status = $order['status'];
    $badge = "secondary";
    if ($status === "RECEIVED") $badge = "info";
    if ($status === "PREPARING") $badge = "warning";
    if ($status === "READY") $badge = "primary";
    if ($status === "COMPLETED") $badge = "success";
    ?>

    <p>
        <strong>Status:</strong>
        <span id="statusBadge" class="badge bg-<?= $badge ?> status-badge">
            <?= htmlspecialchars($status) ?>
        </span>
    </p>

    <hr>

    <p class="fw-bold">
        Total Amount: $<?= number_format($order['total_amount'], 2) ?>
    </p>

    <!-- QR CODE -->
    <div id="qrBox" class="text-center my-3">
        <div id="qrcode"></div>
        <small class="text-muted">Scan to track order</small>
    </div>

    <div class="d-grid gap-2 mt-3">
        <button onclick="window.print()" class="btn btn-dark">
            🖨️ Print Receipt
        </button>
    </div>

</div>

<script>
// ================= QR CODE =================
new QRCode(document.getElementById("qrcode"), {
    text: window.location.href,
    width: 120,
    height: 120
});

// ================= AUTO REFRESH (10s) =================
setInterval(() => {
    fetch(window.location.href, { cache: "no-store" })
        .then(res => res.text())
        .then(html => {
            document.open();
            document.write(html);
            document.close();
        });
}, 10000);
</script>

</body>
</html>
```
#### ✅ FEATURES IMPLEMENTED (CONFIRMED)

| Feature             | Status                        |
| ------------------- | ----------------------------- |
| Auto-refresh        | ✅ 10 seconds                  |
| Mobile-friendly     | ✅ Responsive                  |
| QR code             | ✅ Live tracking link          |
| Live status updates | ✅ Polling (no backend change) |
| Print receipt       | ✅ Clean print view            |
| Backend untouched   | ✅ 100% safe                   |



---


### 🧩 STEP 5 — FINAL order-receipt.php (LATEST VERSION - Simplified, early-stage / learning version)
> **Version 2**


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

---
### 🔍 High-Level Summary (Version 1 VS > Version 2)

| Aspect           | Version 1 (FIRST)             | Version 2 (SECOND)            |
| ---------------- | ----------------------------- | ----------------------------- |
| Core purpose     | Order receipt + live tracking | Order receipt + live tracking |
| Business logic   | ✅ Same                        | ✅ Same                        |
| Code quality     | 🟢 High                       | 🟡 Medium                     |
| Readability      | 🟢 Excellent                  | 🟡 OK                         |
| Security hygiene | 🟢 Better                     | 🟡 Basic                      |
| UI polish        | 🟢 Better                     | 🟡 Basic                      |
| Maintainability  | 🟢 High                       | 🟡 Lower                      |


**👉 They do the same job, but Version 1 is more professional and future-proof.**

### 🧠 Detailed Differences (Section by Section)

#### 1️⃣ Structure & Readability

#### ✅ Version 1

```
// ================= CONFIG =================
// ================= VALIDATE INPUT =================
// ================= FETCH ORDER =================
```

✔ Clearly separated logic

✔ Easy for another developer to understand

✔ Looks professional on GitHub / LinkedIn

#### ⚠️ Version 2

```
$apiBaseUrl = "...";
if (!isset($_GET['order_id'])) { ... }
function fetchOrder(...) { ... }
```

✖ No logical sectioning

✖ Harder to scan quickly

**📌 Winner: Version 1**

#### 2️⃣ Input Validation & Safety

#### Version 1

```
if (!isset($_GET['order_id']) || empty($_GET['order_id'])) {
    die("❌ Invalid order reference.");
}
```

✔ Clear error message

✔ Proper validation

#### Version 2

```
if (!isset($_GET['order_id']) || empty($_GET['order_id'])) {
    die("❌ Invalid order reference");
}
```

✔ Works

✖ Less consistent messaging

**📌 Slight edge to Version 1**

#### 3️⃣ Output Security (XSS Protection)

#### Version 1

```
<?= htmlspecialchars($order['customer_name']) ?>
```

✔ Protects against XSS

✔ Production-safe

#### Version 2

```
<?= $order['customer_name'] ?>
```

❌ Unsafe if malicious data enters DB

📌 Big win for Version 1

#### 4️⃣ Status Handling (UX Logic)

#### Version 1 (Smart UI)

```
if ($status === "READY") $badge = "primary";
if ($status === "COMPLETED") $badge = "success";
```

✔ Status-based color logic

✔ Easy to extend later

#### Version 2 (Static)

```
<span class="badge bg-info"><?= $order['status'] ?></span>
```

✖ All statuses look the same

**📌 Version 1 is clearly more advanced**

#### 5️⃣ UI & UX Polish

#### Version 1

Print-specific CSS

Better spacing

Clear hierarchy

Looks like a POS receipt

#### Version 2

Basic layout

Functional but minimal

**📌 Version 1 feels production-grade**

#### 6️⃣ Comments & Documentation

#### Version 1

```
// ================= AUTO REFRESH (10s) =================
```

✔ Teachable

✔ Easy for future you

#### Version 2

```
// Auto refresh every 10 seconds
```

✔ Works

✖ Less structured

**📌 Version 1 again wins**

#### 7️⃣ Maintainability & Scaling
#### Version 1 is ready for:

Payment status

Refund flag

Staff/admin view

Logging

Security enhancements

#### Version 2 will need refactoring before scaling

### 🏆 Final Verdict

#### ✅ Are both doing the same thing?

- YES – same primary task:

- Fetch order → display receipt → auto refresh → print → QR code

### 🟢 Which one is better and why?

#### ⭐ Version 1 (FIRST) is STRONGLY RECOMMENDED

Because it is:

✔ Cleaner

✔ Safer

✔ Better UX

✔ Easier to maintain

✔ Looks professional in portfolio

### 🎯 How You Should Use Them

| Use Case                   | Recommended  |
| -------------------------- | ------------ |
| Production / live project  | ✅ Version 1  |
| Learning / quick demo      | ⚠️ Version 2 |
| GitHub / LinkedIn showcase | ✅ Version 1  |
| Future expansion           | ✅ Version 1  |


----

### ✅ FINAL order-receipt.php

```
<?php
// =======================================================
// CHARLIE CAFE — ORDER RECEIPT (LIVE STATUS + BILLING)
// STEP 8 IMPLEMENTATION
// =======================================================

// 🔴 IMPORTANT: Replace YOUR_API_ID with real API Gateway ID
// Example:
// https://bs0vgnth0f.execute-api.us-east-1.amazonaws.com/prod/order-status
$apiBaseUrl = "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/order-status";

// ================= VALIDATE INPUT =================
if (!isset($_GET['order_id']) || empty($_GET['order_id'])) {
    die("❌ Invalid order reference.");
}

$orderId = $_GET['order_id'];

// ================= FETCH ORDER FROM BACKEND =================
// Calls:
// GET /order-status?order_id=ORD-XXXX
function fetchOrder($apiBaseUrl, $orderId) {
    $url = $apiBaseUrl . "?order_id=" . urlencode($orderId);
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    $res = curl_exec($ch);
    curl_close($ch);
    return json_decode($res, true);
}

$data = fetchOrder($apiBaseUrl, $orderId);

if (!isset($data['order'])) {
    die("❌ Order not found.");
}

$order = $data['order'];
?>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Order Receipt | Charlie Cafe ☕</title>
<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- Bootstrap -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- QR Code -->
<script src="https://cdn.jsdelivr.net/npm/qrcodejs/qrcode.min.js"></script>

<style>
body {
    background: #f4f6f9;
}
.receipt {
    max-width: 520px;
    margin: 20px auto;
    background: #ffffff;
    padding: 25px;
    border-radius: 16px;
    box-shadow: 0 15px 30px rgba(0,0,0,0.15);
}
.status-badge {
    font-size: 14px;
    padding: 6px 12px;
}
@media print {
    button, #qrBox {
        display: none;
    }
}
</style>
</head>

<body>

<div class="receipt">

    <h4 class="text-center mb-2">☕ Charlie Cafe</h4>
    <p class="text-center text-muted">Order Receipt</p>

    <hr>

    <!-- ORDER META -->
    <p><strong>Order ID:</strong> <?= htmlspecialchars($order['order_id']) ?></p>
    <p><strong>Customer:</strong> <?= htmlspecialchars($order['customer_name']) ?></p>
    <p><strong>Table:</strong> <?= htmlspecialchars($order['table_number']) ?></p>
    <p><strong>Date:</strong> <?= htmlspecialchars($order['created_at']) ?></p>

    <hr>

    <!-- ORDER ITEMS -->
    <p><strong>Item:</strong> <?= htmlspecialchars($order['item']) ?></p>
    <p><strong>Quantity:</strong> <?= htmlspecialchars($order['quantity']) ?></p>

    <hr>

    <!-- LIVE STATUS BADGE -->
    <?php
    $status = $order['status'];
    $badge = "secondary";
    if ($status === "RECEIVED")   $badge = "info";
    if ($status === "PREPARING")  $badge = "warning";
    if ($status === "READY")      $badge = "primary";
    if ($status === "COMPLETED")  $badge = "success";
    ?>

    <p>
        <strong>Status:</strong>
        <span id="statusBadge" class="badge bg-<?= $badge ?> status-badge">
            <?= htmlspecialchars($status) ?>
        </span>
    </p>

    <hr>

    <!-- BILLING (STEP 8 REQUIREMENT) -->
    <p class="fw-bold">
        Total Amount: $<?= number_format($order['total_amount'], 2) ?>
    </p>

    <!-- QR CODE FOR LIVE TRACKING -->
    <div id="qrBox" class="text-center my-3">
        <div id="qrcode"></div>
        <small class="text-muted">Scan to track order</small>
    </div>

    <!-- PRINT -->
    <div class="d-grid gap-2 mt-3">
        <button onclick="window.print()" class="btn btn-dark">
            🖨️ Print Receipt
        </button>
    </div>

</div>

<script>
// ================= QR CODE =================
new QRCode(document.getElementById("qrcode"), {
    text: window.location.href,
    width: 120,
    height: 120
});

// ================= AUTO STATUS REFRESH (10s) =================
// Reloads page to fetch latest order status from backend
setInterval(() => {
    fetch(window.location.href, { cache: "no-store" })
        .then(res => res.text())
        .then(html => {
            document.open();
            document.write(html);
            document.close();
        });
}, 10000);
</script>

</body>
</html>
```

---

### Updated order-receipt.php

> **Updated Version: 5.0**

```
<?php
// ================= CONFIG =================
$apiBaseUrl = "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/order-status";

// ================= VALIDATE INPUT =================
if (!isset($_GET['order_id']) || empty($_GET['order_id'])) {
    die("❌ Invalid order reference.");
}

$orderId = $_GET['order_id'];

// ================= FETCH ORDER =================
function fetchOrder($apiBaseUrl, $orderId) {
    $url = $apiBaseUrl . "?order_id=" . urlencode($orderId);
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    $res = curl_exec($ch);
    curl_close($ch);
    return json_decode($res, true);
}

$data = fetchOrder($apiBaseUrl, $orderId);

if (!isset($data['order'])) {
    die("❌ Order not found.");
}

$order = $data['order'];
?>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Order Receipt | Charlie Cafe ☕</title>
<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- Bootstrap -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- QR Code -->
<script src="https://cdn.jsdelivr.net/npm/qrcodejs/qrcode.min.js"></script>

<style>
body {
    background: #f4f6f9;
}
.receipt {
    max-width: 520px;
    margin: 20px auto;
    background: #ffffff;
    padding: 25px;
    border-radius: 16px;
    box-shadow: 0 15px 30px rgba(0,0,0,0.15);
}
.status-badge {
    font-size: 14px;
    padding: 6px 12px;
}
@media print {
    button, #qrBox {
        display: none;
    }
}
</style>
</head>

<body>

<div class="receipt">

    <h4 class="text-center mb-2">☕ Charlie Cafe</h4>
    <p class="text-center text-muted">Order Receipt</p>

    <hr>

    <p><strong>Order ID:</strong> <?= htmlspecialchars($order['order_id']) ?></p>
    <p><strong>Customer:</strong> <?= htmlspecialchars($order['customer_name']) ?></p>
    <p><strong>Table:</strong> <?= htmlspecialchars($order['table_number']) ?></p>
    <p><strong>Date:</strong> <?= htmlspecialchars($order['created_at']) ?></p>

    <hr>

    <p><strong>Item:</strong> <?= htmlspecialchars($order['item']) ?></p>
    <p><strong>Quantity:</strong> <?= htmlspecialchars($order['quantity']) ?></p>

    <hr>

    <?php
    $status = $order['status'];
    $badge = "secondary";
    if ($status === "RECEIVED") $badge = "info";
    if ($status === "PREPARING") $badge = "warning";
    if ($status === "READY") $badge = "primary";
    if ($status === "COMPLETED") $badge = "success";
    ?>

    <p>
        <strong>Status:</strong>
        <span id="statusBadge" class="badge bg-<?= $badge ?> status-badge">
            <?= htmlspecialchars($status) ?>
        </span>
    </p>

    <hr>

    <p class="fw-bold">
        Total Amount: $<?= number_format($order['total_amount'], 2) ?>
    </p>

    <!-- QR CODE -->
    <div id="qrBox" class="text-center my-3">
        <div id="qrcode"></div>
        <small class="text-muted">Scan to track order</small>
    </div>

    <div class="d-grid gap-2 mt-3">
        <button onclick="window.print()" class="btn btn-dark">
            🖨️ Print Receipt
        </button>
    </div>

</div>

<script>
// ================= QR CODE =================
new QRCode(document.getElementById("qrcode"), {
    text: window.location.href,
    width: 120,
    height: 120
});

// ================= AUTO REFRESH (10s) =================
setInterval(() => {
    fetch(window.location.href, { cache: "no-store" })
        .then(res => res.text())
        .then(html => {
            document.open();
            document.write(html);
            document.close();
        });
}, 10000);
</script>

</body>
</html>
```

---

### Updated order-receipt.php

> **Updated Version: 5.1**

Fully Bootstrap responsive

Cafe-related icons everywhere

Transparent buttons with cafe-themed icons

Background cafe image with dark overlay

Bootstrap grid & utilities for mobile responsiveness

Sidebar added with cafe icons

Metrics & receipt card visually appealing

Clear comments throughout

```
<?php 
// ================= CONFIG =================
$apiBaseUrl = "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/order-status";

// ================= VALIDATE INPUT =================
if (!isset($_GET['order_id']) || empty($_GET['order_id'])) {
    die("❌ Invalid order reference.");
}

$orderId = $_GET['order_id'];

// ================= FETCH ORDER =================
function fetchOrder($apiBaseUrl, $orderId) {
    $url = $apiBaseUrl . "?order_id=" . urlencode($orderId);
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    $res = curl_exec($ch);
    curl_close($ch);
    return json_decode($res, true);
}

$data = fetchOrder($apiBaseUrl, $orderId);

if (!isset($data['order'])) {
    die("❌ Order not found.");
}

$order = $data['order'];
?>

<!DOCTYPE html>
<html lang="en" data-bs-theme="dark">
<head>
<meta charset="UTF-8">
<title>Order Receipt | Charlie Cafe ☕</title>
<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- ================= BOOTSTRAP ================= -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- ================= GOOGLE FONT ================= -->
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">

<!-- ================= BOOTSTRAP ICONS ================= -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">

<!-- ================= QR CODE ================= -->
<script src="https://cdn.jsdelivr.net/npm/qrcodejs/qrcode.min.js"></script>

<style>
/* ================= BODY + BACKGROUND ================= */
body {
    font-family: 'Poppins', sans-serif;
    min-height: 100vh;
    margin: 0;
    background: linear-gradient(rgba(0,0,0,0.65), rgba(0,0,0,0.65)),
                url("https://images.unsplash.com/photo-1517248135467-4c7edcad34c4");
    background-size: cover;
    background-position: center;
    background-attachment: fixed;
    color: #fff;
}

/* ================= SIDEBAR ================= */
.sidebar {
    width: 220px;
    height: 100vh;
    background: #2b160a;
    position: fixed;
    top: 0;
    left: 0;
    padding-top: 80px;
    z-index: 1000;
}
.sidebar a {
    display: flex;
    align-items: center;
    padding: 12px 20px;
    color: #ddd;
    text-decoration: none;
    font-weight: 500;
    transition: 0.2s;
}
.sidebar a i {
    margin-right: 10px;
    color: #ff9800;
}
.sidebar a:hover, .sidebar a.active {
    background: #3b1f0e;
    color: #fff;
    border-left: 4px solid #ff9800;
}
.sidebar a.logout-btn i {
    color: #ff4d4d;
}

/* ================= NAVBAR ================= */
.navbar {
    background-color: rgba(59, 31, 14, 0.9) !important;
    position: fixed;
    width: 100%;
    z-index: 1100;
}
.navbar .navbar-brand {
    font-weight: bold;
    color: #ff9800 !important;
}

/* ================= MAIN CONTENT ================= */
.main-content {
    margin-left: 220px;
    padding-top: 100px;
    padding-bottom: 50px;
}

/* ================= RECEIPT CARD ================= */
.receipt-card {
    background: rgba(30,30,30,0.85);
    border-radius: 20px;
    padding: 30px;
    max-width: 600px;
    margin: auto;
    box-shadow: 0 10px 30px rgba(0,0,0,0.5);
}

/* ================= BUTTONS ================= */
.btn-transparent {
    background: rgba(255,255,255,0.1);
    border: 1px solid #ff9800;
    color: #ff9800;
    display: flex;
    align-items: center;
    justify-content: center;
}
.btn-transparent i {
    margin-right: 8px;
}

/* ================= TABLE ================= */
.table th, .table td {
    vertical-align: middle;
}
.table-hover tbody tr:hover {
    background-color: rgba(255, 152, 0, 0.2);
}

/* ================= STATUS BADGE ================= */
.status-badge {
    font-size: 14px;
    padding: 6px 12px;
}

/* ================= RESPONSIVE ================= */
@media (max-width:768px){
    .main-content { margin-left: 0; padding-top: 120px; }
    .sidebar { width: 100%; height: auto; position: relative; padding-top: 20px; }
}
</style>
</head>

<body style="display:none">

<!-- ================= NAVBAR ================= -->
<nav class="navbar navbar-dark">
    <div class="container-fluid">
        <a class="navbar-brand" href="index.php">☕ Charlie Cafe</a>
    </div>
</nav>

<!-- ================= SIDEBAR ================= -->
<div class="sidebar">
    <a href="dashboard.html"><i class="bi bi-house-door-fill"></i> Main Dashboard</a>
    <a href="analytics.html"><i class="bi bi-graph-up-arrow"></i> Analytics</a>
    <a href="order-receipt.php?order_id=<?= $orderId ?>" class="active"><i class="bi bi-cup-fill"></i> Receipt</a>
    <hr class="text-secondary">
    <a class="logout-btn" style="cursor:pointer"><i class="bi bi-door-open-fill"></i> Logout</a>
</div>

<!-- ================= MAIN CONTENT ================= -->
<div class="main-content">
    <div class="container">
        <div class="receipt-card">

            <!-- ================= HEADER ================= -->
            <h4 class="text-center mb-2"><i class="bi bi-cup-straw-fill"></i> Charlie Cafe</h4>
            <p class="text-center text-muted">Order Receipt</p>
            <hr>

            <!-- ================= ORDER DETAILS ================= -->
            <p><i class="bi bi-upc-scan"></i> <strong>Order ID:</strong> <?= htmlspecialchars($order['order_id']) ?></p>
            <p><i class="bi bi-person-fill"></i> <strong>Customer:</strong> <?= htmlspecialchars($order['customer_name']) ?></p>
            <p><i class="bi bi-table"></i> <strong>Table:</strong> <?= htmlspecialchars($order['table_number']) ?></p>
            <p><i class="bi bi-calendar-event-fill"></i> <strong>Date:</strong> <?= htmlspecialchars($order['created_at']) ?></p>
            <hr>
            <p><i class="bi bi-cup-fill"></i> <strong>Item:</strong> <?= htmlspecialchars($order['item']) ?></p>
            <p><i class="bi bi-hash"></i> <strong>Quantity:</strong> <?= htmlspecialchars($order['quantity']) ?></p>
            <hr>

            <!-- ================= STATUS BADGE ================= -->
            <?php
            $status = $order['status'];
            $badge = "secondary";
            if ($status === "RECEIVED") $badge = "info";
            if ($status === "PREPARING") $badge = "warning";
            if ($status === "READY") $badge = "primary";
            if ($status === "COMPLETED") $badge = "success";
            ?>
            <p>
                <strong>Status:</strong>
                <span id="statusBadge" class="badge bg-<?= $badge ?> status-badge">
                    <?= htmlspecialchars($status) ?>
                </span>
            </p>
            <hr>

            <p class="fw-bold"><i class="bi bi-currency-dollar"></i> Total Amount: $<?= number_format($order['total_amount'], 2) ?></p>

            <!-- ================= QR CODE ================= -->
            <div id="qrBox" class="text-center my-3">
                <div id="qrcode"></div>
                <small class="text-muted">Scan to track order</small>
            </div>

            <!-- ================= BUTTONS ================= -->
            <div class="d-grid gap-2 mt-3">
                <button onclick="window.print()" class="btn btn-transparent">
                    <i class="bi bi-printer-fill"></i> Print Receipt
                </button>
            </div>

        </div>
    </div>
</div>

<!-- ================= BOOTSTRAP JS ================= -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<!-- ================= CENTRAL AUTH ================= -->
<script src="/js/central-auth-api.js"></script>
<script>
/* =========================================================
   PROTECT PAGE — redirect to login if not authenticated
   ========================================================= */
CHARLIE.auth.protectPage();

/* =========================================================
   LOGOUT HANDLER
   ========================================================= */
document.querySelector(".logout-btn").onclick = () => {
    CHARLIE.auth.logout();
};

/* =========================================================
   QR CODE GENERATION
   ========================================================= */
new QRCode(document.getElementById("qrcode"), {
    text: window.location.href,
    width: 120,
    height: 120
});

/* =========================================================
   AUTO REFRESH (10s)
   ========================================================= */
setInterval(() => {
    fetch(window.location.href, { cache: "no-store" })
        .then(res => res.text())
        .then(html => {
            document.open();
            document.write(html);
            document.close();
        });
}, 10000);
</script>

</body>
</html>
```

----


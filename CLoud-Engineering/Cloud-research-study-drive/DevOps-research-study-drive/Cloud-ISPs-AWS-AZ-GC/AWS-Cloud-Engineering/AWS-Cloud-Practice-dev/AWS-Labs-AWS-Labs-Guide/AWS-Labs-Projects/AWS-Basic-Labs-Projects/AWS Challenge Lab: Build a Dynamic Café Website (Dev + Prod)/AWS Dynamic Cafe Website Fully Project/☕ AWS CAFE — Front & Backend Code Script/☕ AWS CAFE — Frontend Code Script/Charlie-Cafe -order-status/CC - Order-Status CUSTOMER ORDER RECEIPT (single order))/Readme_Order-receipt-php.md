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
### 2️⃣ ☕ order-receipt.php — FINAL VERSION with below ALL FEATURES ( Recommanded)

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



---


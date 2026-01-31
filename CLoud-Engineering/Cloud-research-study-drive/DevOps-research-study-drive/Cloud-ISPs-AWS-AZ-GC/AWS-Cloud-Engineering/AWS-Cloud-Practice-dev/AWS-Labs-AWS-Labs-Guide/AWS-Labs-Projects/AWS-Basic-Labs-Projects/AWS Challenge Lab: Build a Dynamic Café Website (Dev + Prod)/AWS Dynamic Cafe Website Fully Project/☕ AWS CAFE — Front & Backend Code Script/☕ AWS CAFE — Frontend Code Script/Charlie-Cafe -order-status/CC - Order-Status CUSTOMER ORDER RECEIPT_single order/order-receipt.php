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
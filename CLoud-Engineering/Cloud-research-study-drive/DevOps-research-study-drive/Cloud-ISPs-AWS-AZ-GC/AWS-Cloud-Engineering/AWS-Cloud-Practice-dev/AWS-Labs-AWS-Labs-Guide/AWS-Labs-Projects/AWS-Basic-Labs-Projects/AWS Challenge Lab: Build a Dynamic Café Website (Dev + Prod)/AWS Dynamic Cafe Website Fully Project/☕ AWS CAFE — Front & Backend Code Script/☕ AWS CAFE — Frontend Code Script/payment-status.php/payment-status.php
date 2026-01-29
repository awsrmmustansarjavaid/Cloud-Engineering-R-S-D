<?php
// ===========================================
// CHARLIE CAFE - PAYMENT STATUS PAGE
// Handles CARD + CASH payment result
// ===========================================

$apiBaseUrl = "https://xxxx.execute-api.us-east-1.amazonaws.com/dev/order-status";

// Validate order ID
if (!isset($_GET['order_id'])) {
    die("Invalid Order ID");
}

$orderId = $_GET['order_id'];

// Call backend API
$ch = curl_init($apiBaseUrl . "?order_id=" . urlencode($orderId));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$response = curl_exec($ch);
curl_close($ch);

$data = json_decode($response, true);
?>

<!DOCTYPE html>
<html>
<head>
<title>Payment Status</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>

<body class="bg-dark text-white">

<div class="container mt-5">
<div class="card p-4">

<h3>💳 Payment Status</h3>
<p><strong>Order ID:</strong> <?= $orderId ?></p>

<?php if ($data['payment_method'] === 'CARD'): ?>

    <div class="alert alert-success">
        ✅ Card payment successful
    </div>

    <a href="order-status.php?order_id=<?= $orderId ?>"
       class="btn btn-primary mt-3">
       📦 Track Order
    </a>

<?php elseif ($data['payment_method'] === 'CASH' && $data['payment_status'] === 'PENDING'): ?>

    <div class="alert alert-warning">
        ☕ Please pay at the counter
    </div>

<?php elseif ($data['payment_method'] === 'CASH' && $data['payment_status'] === 'PAID'): ?>

    <div class="alert alert-success">
        ✅ Cash payment received
    </div>

    <a href="order-status.php?order_id=<?= $orderId ?>"
       class="btn btn-primary mt-3">
       📦 Track Order
    </a>

<?php else: ?>

    <div class="alert alert-secondary">
        ⏳ Order created, awaiting payment
    </div>

<?php endif; ?>

</div>
</div>

</body>
</html>

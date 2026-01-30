# Charlie Cafe -- payment-status.php

### 🟦 STEP 7 — UPDATE payment-status.php

#### ✅ FULL UPDATED FILE (WITH COMMENTS)

```
<?php
// ===========================================
// CHARLIE CAFE - PAYMENT STATUS PAGE
// Shows CARD / CASH payment result ONLY
// ===========================================

// API endpoint to fetch order status
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
        ✅ Payment received via CARD
    </div>

<?php elseif ($data['payment_method'] === 'CASH' && $data['payment_status'] === 'PENDING'): ?>

    <div class="alert alert-warning">
        ☕ Please pay at the counter
    </div>

<?php elseif ($data['payment_method'] === 'CASH' && $data['payment_status'] === 'PAID'): ?>

    <div class="alert alert-success">
        ✅ Cash payment received
    </div>

<?php else: ?>

    <div class="alert alert-secondary">
        ⏳ Order created, waiting for payment
    </div>

<?php endif; ?>

</div>
</div>

</body>
</html>
```

---


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
#### Step 3.1 – admin-orders.php

This page is for admin only, shows all orders, and provides the “Mark as Paid” button for pending CASH orders.

```
<?php
// ===============================
// CHARLIE CAFE - ADMIN ORDERS PAGE
// ===============================

// Fetch all orders from API
$apiUrl = "https://xxxx.execute-api.us-east-1.amazonaws.com/dev/admin/orders";

$ch = curl_init($apiUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$response = curl_exec($ch);
curl_close($ch);

$orders = json_decode($response, true);
?>

<!DOCTYPE html>
<html>
<head>
<title>Admin Orders</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>

<body class="bg-dark text-white">
<div class="container mt-5">

<h3>📊 Admin Orders</h3>

<table class="table table-dark table-bordered">
<thead>
<tr>
    <th>Order ID</th>
    <th>Table</th>
    <th>Item</th>
    <th>Payment</th>
    <th>Status</th>
    <th>Action</th>
</tr>
</thead>
<tbody>
<?php foreach ($orders as $order): ?>
<tr>
    <td><?= $order['order_id'] ?></td>
    <td><?= $order['table_number'] ?></td>
    <td><?= $order['item'] ?></td>
    <td><?= $order['payment_method'] ?></td>
    <td><?= $order['payment_status'] ?></td>
    <td>
        <?php if ($order['payment_method'] === 'CASH' && $order['payment_status'] === 'PENDING'): ?>
            <button class="btn btn-success btn-sm"
                onclick="markPaid('<?= $order['order_id'] ?>')">
                ✅ Mark as Paid
            </button>
        <?php else: ?>
            —
        <?php endif; ?>
    </td>
</tr>
<?php endforeach; ?>
</tbody>
</table>

</div>

<script>
function markPaid(orderId) {
    fetch("https://xxxx.execute-api.us-east-1.amazonaws.com/dev/admin/mark-paid", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ order_id: orderId })
    })
    .then(res => res.json())
    .then(data => {
        if (data.success) {
            alert("Payment marked as PAID");
            location.reload();
        } else {
            alert("Failed: " + data.error);
        }
    });
}
</script>

</body>
</html>
```

### 4️⃣ UPDATE payment-status.php FOR CUSTOMER REDIRECT

Add a button to print / track order after payment is confirmed:

```
<?php if ($data['payment_status'] === 'PAID'): ?>
    <a href="print-order.php?order_id=<?= $orderId ?>"
       class="btn btn-primary mt-3">
       🖨 Print Order / View Receipt
    </a>
<?php endif; ?>
```

### 5️⃣ OPTIONAL AUTO-REDIRECT TO PRINT PAGE

Replace button logic with:

```
<?php if ($data['payment_status'] === 'PAID'): ?>
<script>
    setTimeout(() => {
        window.location.href = "print-order.php?order_id=<?= $orderId ?>";
    }, 2000); // Redirect 2 seconds after payment confirmed
</script>
<?php endif; ?>
```
---


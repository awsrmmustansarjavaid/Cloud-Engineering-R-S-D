<?php
// ===================================================
// CHARLIE CAFE ☕ - ADMIN ORDERS DASHBOARD
// Cashier "Mark as Paid" Panel
// ===================================================

// Admin Orders API (GET all orders)
$ordersApi = "https://xxxx.execute-api.us-east-1.amazonaws.com/dev/admin/orders";

// Fetch all orders
$ch = curl_init($ordersApi);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$response = curl_exec($ch);
curl_close($ch);

// Decode response safely
$orders = json_decode($response, true) ?? [];
?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Café ☕ | Orders Dashboard</title>
<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- Bootstrap 5 -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- Google Fonts -->
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&family=Playfair+Display:wght@500;700&display=swap" rel="stylesheet">

<style>
/* ===== SAME CAFE THEME (UNCHANGED) ===== */
:root {
    --cafe-bg:#1a110b;--cafe-surface:#2c1b12;--cafe-card:#3a251c;
    --cafe-cream:#f5e9d4;--cafe-text:#e8d9c0;--cafe-accent:#c97b44;
    --cafe-accent-dark:#a15f32;--cafe-success:#6b9e78;
    --cafe-pending:#d9a66d;--cafe-shadow:0 12px 40px rgba(0,0,0,0.55);
}
body{
    font-family:'Poppins',sans-serif;color:var(--cafe-text);
    min-height:100vh;background:var(--cafe-bg)
    url('https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&q=80&w=1920')
    center/cover fixed no-repeat;
}
body::before{
    content:"";position:fixed;inset:0;
    background:rgba(26,17,11,.68);
    backdrop-filter:blur(3.5px);z-index:-1;
}
.container{max-width:1400px;padding:3rem 1rem;}
h3{font-family:'Playfair Display',serif;color:var(--cafe-cream);}
.dashboard-card{
    background:rgba(58,37,28,.82);
    border-radius:24px;padding:2.2rem;
    box-shadow:var(--cafe-shadow);
}
.badge-paid{background:var(--cafe-success);}
.badge-pending{background:var(--cafe-pending);color:#1a110b;}
.badge-card{background:#6b829e;}
.btn-paid{
    background:linear-gradient(135deg,var(--cafe-accent),var(--cafe-accent-dark));
    border:none;border-radius:50px;color:#fff;
}
</style>
</head>

<body>

<div class="container">
    <!-- HEADER -->
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h3>☕ Charlie Café – Orders Dashboard</h3>
        <span class="text-muted">Cashier Panel</span>
    </div>

    <!-- MAIN CARD -->
    <div class="dashboard-card">
        <div class="table-responsive">
            <table class="table table-hover align-middle text-white">
                <thead>
                <tr>
                    <th>Order ID</th>
                    <th>Table</th>
                    <th>Item</th>
                    <th>Qty</th>
                    <th>Payment</th>
                    <th>Status</th>
                    <th>Action</th>
                </tr>
                </thead>
                <tbody>

                <?php if (empty($orders)): ?>
                    <tr>
                        <td colspan="7" class="text-center py-5 text-muted">
                            No orders yet ☕
                        </td>
                    </tr>
                <?php endif; ?>

                <?php foreach ($orders as $order): ?>
                <tr>
                    <td><?= htmlspecialchars($order['order_id']) ?></td>
                    <td><?= (int)$order['table_number'] ?></td>
                    <td><?= htmlspecialchars($order['item']) ?></td>
                    <td><?= (int)$order['quantity'] ?></td>

                    <!-- Payment Method -->
                    <td>
                        <?php if ($order['payment_method'] === 'CARD'): ?>
                            <span class="badge badge-card">CARD</span>
                        <?php else: ?>
                            <span class="badge bg-secondary">CASH</span>
                        <?php endif; ?>
                    </td>

                    <!-- Payment Status -->
                    <td>
                        <?php if ($order['payment_status'] === 'PAID'): ?>
                            <span class="badge badge-paid">PAID</span>
                        <?php else: ?>
                            <span class="badge badge-pending">PENDING</span>
                        <?php endif; ?>
                    </td>

                    <!-- ACTION COLUMN -->
                    <td>
                        <?php if ($order['payment_method'] === 'CASH' && $order['payment_status'] === 'PENDING'): ?>
                            <!-- Cashier confirms cash payment -->
                            <button class="btn btn-paid btn-sm"
                                onclick="markAsPaid('<?= $order['order_id'] ?>')">
                                ✅ Mark Paid
                            </button>

                        <?php elseif ($order['payment_status'] === 'PAID'): ?>
                            <!-- Optional: print receipt after payment -->
                            <a href="print-order.php?order_id=<?= $order['order_id'] ?>"
                               class="btn btn-outline-light btn-sm">
                                🖨 Print
                            </a>
                        <?php else: ?>
                            —
                        <?php endif; ?>
                    </td>
                </tr>
                <?php endforeach; ?>

                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- ===================== JS ===================== -->
<script>
// Cashier confirms CASH payment
function markAsPaid(orderId) {
    if (!confirm("Confirm CASH payment for order " + orderId + "?")) return;

    fetch("https://xxxx.execute-api.us-east-1.amazonaws.com/dev/admin/mark-paid", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ order_id: orderId })
    })
    .then(res => res.json())
    .then(data => {
        if (data.success) {
            alert("☕ Payment marked as PAID");
            location.reload(); // refresh dashboard
        } else {
            alert("❌ Failed to update payment");
        }
    })
    .catch(() => alert("Server error"));
}

// Auto-refresh dashboard every 30 seconds (LAB SAFE)
setInterval(() => location.reload(), 30000);
</script>

</body>
</html>

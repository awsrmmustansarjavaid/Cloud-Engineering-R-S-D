<?php
// ===================================================
// CHARLIE CAFÉ ☕ - ADMIN ORDERS DASHBOARD (Updated with Cognito & UI/UX + Central Print)
// ===================================================

// API endpoints
$ordersApi    = "https://a1053skr51.execute-api.us-east-1.amazonaws.com/dev/orders";
$markPaidApi  = "https://a1053skr51.execute-api.us-east-1.amazonaws.com/dev/admin/mark-paid";

// Fetch orders
$ch = curl_init($ordersApi);
curl_setopt_array($ch, [
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_TIMEOUT        => 10,
    CURLOPT_FOLLOWLOCATION => true
]);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$curlError = curl_error($ch);
curl_close($ch);

// Decode JSON safely
$orders = [];
if ($response !== false && $httpCode === 200) {
    $decoded = json_decode($response, true);
    if (is_array($decoded)) $orders = $decoded;
} else {
    $fetchError = $curlError ?: "HTTP $httpCode - API returned invalid response";
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Charlie Café ☕ | Orders Dashboard</title>

<!-- ===================== BOOTSTRAP CSS ===================== -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- ===================== BOOTSTRAP ICONS ===================== -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">

<!-- Google Fonts -->
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&family=Playfair+Display:wght@500;700&display=swap" rel="stylesheet">

<style>
:root {
    --cafe-bg:#1a110b; --cafe-surface:#2c1b12; --cafe-card:#3a251c;
    --cafe-cream:#f5e9d4; --cafe-text:#e8d9c0; --cafe-accent:#c97b44;
    --cafe-accent-dark:#a15f32; --cafe-success:#6b9e78;
    --cafe-pending:#d9a66d; --cafe-shadow:0 12px 40px rgba(0,0,0,0.55);
}
body {
    font-family:'Poppins',sans-serif; color:var(--cafe-text);
    min-height:100vh; background:var(--cafe-bg)
    url('https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&q=80&w=1920')
    center/cover fixed no-repeat;
}
body::before {
    content:""; position:fixed; inset:0;
    background:rgba(26,17,11,.68); backdrop-filter:blur(3.5px); z-index:-1;
}

/* Container and card */
.container { max-width:1400px; padding:3rem 1rem; }
h3 { font-family:'Playfair Display',serif; color:var(--cafe-cream); }
.dashboard-card {
    background:rgba(58,37,28,.82); border-radius:24px; padding:2.2rem;
    box-shadow:var(--cafe-shadow);
}

/* Badges */
.badge-paid { background:var(--cafe-success); color:#fff; }
.badge-pending { background:var(--cafe-pending); color:#1a110b; }
.badge-card { background:#6b829e; color:#fff; }

/* Buttons */
.btn-paid {
    background:linear-gradient(135deg,var(--cafe-accent),var(--cafe-accent-dark));
    border:none; border-radius:50px; color:#fff; display:flex; align-items:center; gap:6px;
}
.btn-paid:disabled { opacity:0.6; cursor:not-allowed; }

/* Login button */
.btn-login {
    background: linear-gradient(135deg, #ff5722, #ff9800);
    border:none; border-radius:50px; color:#fff; display:flex; align-items:center; gap:6px;
}

/* Central Print Button */
.btn-print {
    margin-bottom: 15px;
}

/* Responsive Table */
.table-hover tbody tr:hover { background: rgba(255,221,170,0.1); }
@media(max-width:768px){
    .container { padding:2rem 0.5rem; }
    .dashboard-card { padding:1.5rem; }
    .btn-paid, .btn-login { width:100%; justify-content:center; }
}
</style>
</head>
<body>

<div class="container">
    <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap">
        <h3><i class="bi bi-speedometer2"></i> Charlie Café – Orders Dashboard</h3>
        <div class="d-flex gap-2 align-items-center">
            <span class="text-muted">Cashier Panel • Auto-refresh 30s</span>
            <button class="btn btn-login" id="loginBtn"><i class="bi bi-person-circle"></i> Login</button>
        </div>
    </div>

    <?php if (isset($fetchError)): ?>
        <div class="alert alert-warning text-center">
            ⚠️ <?= htmlspecialchars($fetchError) ?> — Please check API or try refreshing.
        </div>
    <?php endif; ?>

    <div class="dashboard-card">
        <div class="table-responsive">

            <!-- ===================== CENTRAL PRINT BUTTON ===================== -->
            <button class="btn btn-outline-dark btn-print" onclick="openCentralPrint('#ordersTable')">
                🖨️ Print / Export
            </button>

            <!-- ===================== ORDERS TABLE ===================== -->
            <table class="table table-hover align-middle text-white" id="ordersTable">
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
                                No orders found yet ☕<br><small>(New orders appear automatically)</small>
                            </td>
                        </tr>
                    <?php else: ?>
                        <?php foreach ($orders as $order): ?>
                            <tr>
                                <td><?= htmlspecialchars($order['order_id'] ?? '—') ?></td>
                                <td><?= (int)($order['table_number'] ?? 0) ?></td>
                                <td><?= htmlspecialchars($order['item'] ?? '—') ?></td>
                                <td><?= (int)($order['quantity'] ?? 0) ?></td>

                                <!-- Payment method badges -->
                                <td>
                                    <?php $method=$order['payment_method']??'UNKNOWN';
                                    if($method==='CARD'): ?>
                                        <span class="badge badge-card"><i class="bi bi-credit-card-2-front-fill"></i> CARD</span>
                                    <?php elseif($method==='CASH'): ?>
                                        <span class="badge bg-secondary"><i class="bi bi-cash-stack"></i> CASH</span>
                                    <?php else: ?>
                                        <span class="badge bg-dark"><?= htmlspecialchars($method) ?></span>
                                    <?php endif; ?>
                                </td>

                                <!-- Payment status badges -->
                                <td>
                                    <?php $status=$order['payment_status']??'UNKNOWN';
                                    if($status==='PAID'): ?>
                                        <span class="badge badge-paid"><i class="bi bi-check-circle-fill"></i> PAID</span>
                                    <?php else: ?>
                                        <span class="badge badge-pending"><i class="bi bi-clock-fill"></i> PENDING</span>
                                    <?php endif; ?>
                                </td>

                                <!-- Actions -->
                                <td>
                                    <?php if($method==='CASH' && $status==='PENDING'): ?>
                                        <button class="btn btn-paid btn-sm mark-paid-btn"
                                            data-order-id="<?= htmlspecialchars($order['order_id']) ?>"
                                            onclick="markAsPaid(this)">
                                            <i class="bi bi-check2-circle"></i> Mark Paid
                                        </button>
                                    <?php elseif($status==='PAID'): ?>
                                        <a href="print-order.php?order_id=<?= urlencode($order['order_id']??'') ?>"
                                           class="btn btn-outline-light btn-sm">
                                           <i class="bi bi-printer-fill"></i> Print
                                        </a>
                                    <?php else: ?>
                                        — 
                                    <?php endif; ?>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </tbody>
            </table>

        </div>
    </div>
</div>

<!-- ===================== JS ===================== -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="central-auth-api.js"></script>

<script>
document.addEventListener("DOMContentLoaded", async () => {
    // Protect page – redirect to login if not authenticated
    await protectPage();

    // Bind Cognito login button
    document.getElementById("loginBtn").addEventListener("click", () => {
        cognitoLogin(); // Opens hosted UI
    });

    // Auto-refresh every 30s
    setInterval(() => location.reload(), 30000);
});

// Mark CASH orders as PAID
async function markAsPaid(button){
    const orderId = button.getAttribute('data-order-id');
    if(!confirm(`Confirm CASH payment for order ${orderId}?`)) return;

    button.disabled = true;
    button.innerHTML = `<i class="bi bi-hourglass-split"></i> Processing...`;

    try{
        const res = await fetch("<?= $markPaidApi ?>", {
            method:"POST",
            headers:{"Content-Type":"application/json"},
            body:JSON.stringify({order_id:orderId})
        });
        const data = await res.json();
        if(data.success){
            alert("☕ Payment marked as PAID successfully!");
            location.reload();
        } else alert("❌ Failed: "+(data.error||data.message||"Unknown error"));
    }catch(err){
        console.error(err);
        alert("Server error, try again.");
    }finally{
        button.disabled=false;
        button.innerHTML=`<i class="bi bi-check2-circle"></i> Mark Paid`;
    }
}

/* ===================== CENTRAL PRINT FUNCTION ===================== */
/* Works for any table or section using #selector */
function openCentralPrint(selector) {
    const target = document.querySelector(selector);
    if (!target) {
        alert('Print section not found!');
        return;
    }
    const content = target.outerHTML;
    const printWindow = window.open('/central-print.html', '_blank');

    // Wait until centralPrint object is ready
    const timer = setInterval(() => {
        if (printWindow && printWindow.centralPrint) {
            printWindow.centralPrint.loadContent(content);
            clearInterval(timer);
        }
    }, 100);
}
</script>
</body>
</html>

<?php 
// ================= CONFIG =================
$apiBaseUrl = "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/status/order-status";

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
    display: flex;
    align-items: center;
}
.navbar .navbar-brand i {
    margin-right: 10px;
    font-size: 1.5rem;
}

/* ================= MAIN CONTENT ================= */
.main-content {
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

/* ================= STATUS BADGE ================= */
.status-badge {
    font-size: 14px;
    padding: 6px 12px;
}

/* ================= QR CODE BOX ================= */
#qrBox {
    background: rgba(255,255,255,0.05);
    padding: 15px;
    border-radius: 12px;
    display: flex;
    flex-direction: column;
    align-items: center;
}

/* ================= RESPONSIVE ================= */
@media (max-width:768px){
    .main-content { padding-top: 120px; }
}
</style>
</head>

<body style="display:none">

<!-- ================= NAVBAR ================= -->
<nav class="navbar navbar-dark">
    <div class="container-fluid">
        <a class="navbar-brand" href="index.php">
            <i class="bi bi-cup-straw-fill"></i> Charlie Cafe
        </a>
    </div>
</nav>

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
            <div id="qrBox" class="my-3">
                <div id="qrcode"></div>
                <small class="text-muted mt-2">Scan to track order</small>
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
CHARLIE.auth.protectPage().then(() => {
    // Show body after auth passed
    document.body.style.display = "block";

    /* =========================================================
       QR CODE GENERATION
    ========================================================= */
    new QRCode(document.getElementById("qrcode"), {
        text: window.location.href,
        width: 140,
        height: 140
    });
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
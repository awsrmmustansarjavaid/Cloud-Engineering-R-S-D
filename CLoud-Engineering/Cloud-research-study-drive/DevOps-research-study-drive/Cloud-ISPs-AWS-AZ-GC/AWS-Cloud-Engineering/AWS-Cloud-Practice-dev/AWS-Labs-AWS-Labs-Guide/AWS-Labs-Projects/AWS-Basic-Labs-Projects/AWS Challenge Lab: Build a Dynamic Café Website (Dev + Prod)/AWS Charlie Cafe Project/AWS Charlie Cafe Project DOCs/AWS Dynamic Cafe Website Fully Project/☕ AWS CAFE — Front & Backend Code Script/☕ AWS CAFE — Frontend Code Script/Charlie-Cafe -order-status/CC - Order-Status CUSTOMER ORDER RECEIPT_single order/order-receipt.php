<?php 
// ==========================================================
// CHARLIE CAFE — ORDER RECEIPT PAGE (PUBLIC)
// ----------------------------------------------------------
// ✔ No Cognito Required
// ✔ Uses Production API Gateway (/prod)
// ✔ Public Endpoint: /prod/order-status
// ✔ Live Auto Refresh
// ✔ QR Code Tracking
// ==========================================================

// ================= VALIDATE ORDER ID =================
if (!isset($_GET['order_id']) || empty($_GET['order_id'])) {
    die("❌ Invalid order reference.");
}

$orderId = htmlspecialchars($_GET['order_id']); // sanitize
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

<!-- ================= QR CODE LIBRARY ================= -->
<script src="https://cdn.jsdelivr.net/npm/qrcodejs/qrcode.min.js"></script>

<!-- ================= CONFIG & UTILITIES ================= -->
<script src="/js/config.js"></script>
<script src="/js/utils.js"></script>

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
.navbar .navbar-brand i { margin-right: 10px; font-size: 1.5rem; }

/* ================= MAIN CONTENT ================= */
.main-content { padding-top: 100px; padding-bottom: 50px; }

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
.btn-transparent i { margin-right: 8px; }

/* ================= STATUS BADGE ================= */
.status-badge { font-size: 14px; padding: 6px 12px; }

/* ================= QR CODE BOX ================= */
#qrBox {
    background: rgba(255,255,255,0.05);
    padding: 15px;
    border-radius: 12px;
    display: flex;
    flex-direction: column;
    align-items: center;
}

/* ================= TRACKING TIMELINE ================= */
.timeline {
    display: flex;
    justify-content: space-between;
    position: relative;
    margin-top: 20px;
}

.timeline::before {
    content: '';
    position: absolute;
    top: 20px;
    width: 100%;
    height: 5px;
    background: #555;
    z-index: 0;
}

.progress {
    position: absolute;
    top: 20px;
    left: 0;
    height: 5px;
    background: #28a745;
    width: 0%;
    z-index: 1;
    transition: width 0.8s ease;
}

.container-step {
    text-align: center;
    z-index: 2;
}

.step {
    width: 45px;
    height: 45px;
    border-radius: 50%;
    border: 3px solid #777;
    display: flex;
    align-items: center;
    justify-content: center;
    background: #222;
    color: #777;
    transition: all 0.4s ease;
}

.step.active {
    border-color: #28a745;
    color: #28a745;
    transform: scale(1.2);
}

/* Pulse on final step */
.step.active:last-child {
    animation: pulse 1s infinite;
}

@keyframes pulse {
    0% { transform: scale(1.2); }
    50% { transform: scale(1.35); }
    100% { transform: scale(1.2); }
}

/* ================= RESPONSIVE ================= */
@media (max-width:768px){ .main-content { padding-top: 120px; } }
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
            <h4 class="text-center mb-2">
                <i class="bi bi-cup-straw-fill"></i> Charlie Cafe
            </h4>
            <p class="text-center text-muted">Order Receipt</p>
            <hr>

            <!-- ================= ORDER DETAILS ================= -->
            <p><i class="bi bi-upc-scan"></i> <strong>Order ID:</strong> <span id="orderId"><?= $orderId ?></span></p>
            <p><i class="bi bi-person-fill"></i> <strong>Customer:</strong> <span id="customerName">Loading...</span></p>
            <p><i class="bi bi-table"></i> <strong>Table:</strong> <span id="tableNumber">Loading...</span></p>
            <p><i class="bi bi-calendar-event-fill"></i> <strong>Date:</strong> <span id="orderDate">Loading...</span></p>
            <hr>
            <p><i class="bi bi-cup-fill"></i> <strong>Item:</strong> <span id="itemName">Loading...</span></p>
            <p><i class="bi bi-hash"></i> <strong>Quantity:</strong> <span id="quantity">Loading...</span></p>
            <hr>

            <!-- ================= STATUS BADGE ================= -->
            <p>
                <strong>Status:</strong>
                <span id="statusBadge" class="badge bg-secondary status-badge">Loading...</span>
            </p>

            <!-- ================= ORDER TRACKING ================= -->
            <div class="mt-4">
                <h6 class="text-center mb-3">Order Progress</h6>

                <div class="timeline">
                    <div class="progress" id="progressBar"></div>

                    <div class="container-step">
                        <div class="step" id="step0">✔</div>
                        <small>Received</small>
                    </div>

                    <div class="container-step">
                        <div class="step" id="step1">👨‍🍳</div>
                        <small>Preparing</small>
                    </div>

                    <div class="container-step">
                        <div class="step" id="step2">📦</div>
                        <small>Ready</small>
                    </div>

                    <div class="container-step">
                        <div class="step" id="step3">🏁</div>
                        <small>Completed</small>
                    </div>
                </div>
            </div>
            <hr>

            <p class="fw-bold">
                <i class="bi bi-currency-dollar"></i>
                Total Amount: $<span id="totalAmount">0.00</span>
            </p>

            <!-- ================= QR CODE ================= -->
            <div id="qrBox" class="my-3">
                <div id="qrcode"></div>
                <small class="text-muted mt-2">Scan to track order</small>
            </div>

            <!-- ================= PRINT BUTTON ================= -->
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

<!-- ================= ORDER FETCH & LIVE REFRESH ================= -->
<script>
document.body.style.display = "block"; // show page

// =========================================================
// USE CONFIG.JS API BASE (from CHARLIE_CONFIG)
// =========================================================
const apiBase = `${window.CHARLIE_CONFIG.API_BASE}/cafe-order-status`;
const orderId = document.getElementById('orderId').textContent;

// ================= TRACKING FLOW =================
const trackingSteps = ["RECEIVED", "PREPARING", "READY", "COMPLETED"];

function updateTrackingUI(status) {
    const index = trackingSteps.indexOf(status);

    trackingSteps.forEach((step, i) => {
        const el = document.getElementById("step" + i);
        if (i <= index) {
            el.classList.add("active");
        } else {
            el.classList.remove("active");
        }
    });

    // progress bar %
    const percent = ((index + 1) / trackingSteps.length) * 100;
    document.getElementById("progressBar").style.width = percent + "%";
}

// Fetch order from API
async function fetchOrder() {
    try {
        const res = await fetch(`${apiBase}?order_id=${encodeURIComponent(orderId)}`);
        if (!res.ok) throw new Error("Failed to fetch order");
        const data = await res.json();
        const order = data.order;

        if (!order) throw new Error("Order not found");

        // Fill HTML dynamically
        document.getElementById('customerName').textContent = order.customer_name;
        document.getElementById('tableNumber').textContent = order.table_number;
        document.getElementById('orderDate').textContent = order.created_at;
        document.getElementById('itemName').textContent = order.item;
        document.getElementById('quantity').textContent = order.quantity;
        document.getElementById('totalAmount').textContent = Number(order.total_amount).toFixed(2);

        // Status badge
        const statusBadge = document.getElementById('statusBadge');
        let badge = "secondary";
        switch(order.status) {
            case "RECEIVED": badge = "info"; break;
            case "PREPARING": badge = "warning"; break;
            case "READY": badge = "primary"; break;
            case "COMPLETED": badge = "success"; break;
        }
        statusBadge.textContent = order.status;
        statusBadge.className = `badge bg-${badge} status-badge`;

        // Update tracking timeline
        updateTrackingUI(order.status);

        // QR code with order URL
        new QRCode(document.getElementById("qrcode"), {
            text: window.location.href,
            width: 140,
            height: 140
        });

    } catch (err) {
        console.error(err);
    }
}

// Initial fetch
fetchOrder();

// Live refresh every 10 seconds
setInterval(fetchOrder, 10000);
</script>

</body>
</html>
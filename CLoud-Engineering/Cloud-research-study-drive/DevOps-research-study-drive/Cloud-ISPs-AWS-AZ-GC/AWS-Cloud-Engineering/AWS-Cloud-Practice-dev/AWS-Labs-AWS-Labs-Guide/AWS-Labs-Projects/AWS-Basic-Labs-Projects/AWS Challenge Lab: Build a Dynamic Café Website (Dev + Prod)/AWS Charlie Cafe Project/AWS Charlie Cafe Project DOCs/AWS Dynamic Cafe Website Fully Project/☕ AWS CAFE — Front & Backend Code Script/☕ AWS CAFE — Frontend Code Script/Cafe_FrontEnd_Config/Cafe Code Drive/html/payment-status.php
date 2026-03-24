<?php
// ==========================================================
// CHARLIE CAFE — PAYMENT STATUS PAGE (PUBLIC)
// ----------------------------------------------------------
// ✔ Public customer frontend
// ✔ Uses CHARLIE_API.public endpoints
// ✔ No Cognito required
// ✔ Displays CARD or CASH payment status
// ✔ Fully responsive and mobile-friendly
// ==========================================================

// Validate order ID
if (!isset($_GET['order_id'])) {
    die("❌ Invalid Order ID");
}

$orderId = htmlspecialchars($_GET['order_id']);
?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Charlie Cafe ☕ | Payment Status</title>

<!-- Bootstrap CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- Bootstrap Icons -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">

<style>
/* ==================== GLOBAL STYLES ==================== */
body {
    font-family: 'Poppins', sans-serif;
    min-height: 100vh;
    color: #fff;
    background: 
        linear-gradient(rgba(26,17,11,0.75), rgba(26,17,11,0.75)),
        url('https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=1920');
    background-size: cover;
    background-position: center;
}

/* ==================== NAVBAR ==================== */
.navbar {
    background-color: rgba(58,37,28,0.9);
    box-shadow: 0 4px 15px rgba(0,0,0,0.5);
}
.navbar-brand {
    font-weight: 600;
    display: flex;
    align-items: center;
    gap: 8px;
}
.btn-login {
    background: linear-gradient(135deg, #ff5722, #ff9800);
    border-radius: 50px;
    color: #fff;
    display: flex;
    align-items: center;
    gap: 6px;
}

/* ==================== CARD ==================== */
.card {
    background: rgba(58,37,28,0.85);
    backdrop-filter: blur(4px);
    border-radius: 20px;
    padding: 2rem;
    max-width: 600px;
    margin: auto;
    box-shadow: 0 12px 30px rgba(0,0,0,0.5);
}

/* ==================== ALERTS ==================== */
.alert {
    display: flex;
    align-items: center;
    gap: 8px;
    font-weight: 500;
}

/* ==================== BUTTONS ==================== */
.btn-primary {
    border-radius: 50px;
    font-weight: bold;
    display: flex;
    align-items: center;
    gap: 6px;
}

/* ==================== RESPONSIVE ==================== */
@media(max-width:576px){
    .card { padding: 1.5rem; }
    .btn-primary, .btn-login { width: 100%; justify-content: center; }
}
</style>
</head>

<body>

<!-- ==================== NAVBAR ==================== -->
<nav class="navbar navbar-expand-lg navbar-dark">
  <div class="container">
    <a class="navbar-brand" href="index.php">
        <i class="bi bi-cup-fill"></i> Charlie Cafe
    </a>
    <div class="ms-auto">
        <!-- Optional Cognito login button (can be left for admin) -->
        <button class="btn btn-login" id="loginBtn">
            <i class="bi bi-person-circle"></i> Login
        </button>
    </div>
  </div>
</nav>

<!-- ==================== PAYMENT STATUS CARD ==================== -->
<div class="container my-5 pt-5">
    <div class="card text-center">
        <h3><i class="bi bi-cash-stack"></i> Payment Status</h3>
        <p><strong>Order ID:</strong> <?= $orderId ?></p>

        <!-- Placeholder for payment status -->
        <div id="paymentStatus">
            <div class="alert alert-info">
                <i class="bi bi-hourglass-split"></i> ⏳ Checking payment status...
            </div>
        </div>

        <!-- Track Order Button -->
        <a href="order-status.php?order_id=<?= $orderId ?>" 
           class="btn btn-primary mt-3" id="trackOrderBtn" style="display:none;">
           <i class="bi bi-box-seam"></i> Track Order
        </a>
    </div>
</div>

<!-- ==================== BOOTSTRAP JS ==================== -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<!-- ==================== CENTRAL PUBLIC API MODULES ==================== -->
<script src="/js/config.js"></script>
<script src="/js/utils.js"></script>
<script src="/js/api.js"></script>

<script>
// ==========================================================
// CHARLIE CAFE — PAYMENT STATUS SCRIPT
// Uses CHARLIE_API.public endpoints
// ==========================================================
document.addEventListener("DOMContentLoaded", async () => {

    const paymentStatusDiv = document.getElementById("paymentStatus");
    const trackBtn = document.getElementById("trackOrderBtn");

    try {
        // 1️⃣ Fetch order status from PUBLIC API
        const data = await CHARLIE_API.public.getOrderStatus("<?= $orderId ?>");

        // 2️⃣ Render status based on payment method
        if (data.payment_method === "CARD") {
            paymentStatusDiv.innerHTML = `
                <div class="alert alert-success">
                    <i class="bi bi-credit-card-2-front-fill"></i> ✅ Card payment successful
                </div>
            `;
            trackBtn.style.display = "inline-block";

        } else if (data.payment_method === "CASH" && data.payment_status === "PENDING") {
            paymentStatusDiv.innerHTML = `
                <div class="alert alert-warning">
                    <i class="bi bi-clock-fill"></i> ☕ Please pay at the counter
                </div>
            `;

        } else if (data.payment_method === "CASH" && data.payment_status === "PAID") {
            paymentStatusDiv.innerHTML = `
                <div class="alert alert-success">
                    <i class="bi bi-check-circle-fill"></i> ✅ Cash payment received
                </div>
            `;
            trackBtn.style.display = "inline-block";

        } else {
            paymentStatusDiv.innerHTML = `
                <div class="alert alert-secondary">
                    <i class="bi bi-hourglass-split"></i> ⏳ Order created, awaiting payment
                </div>
            `;
        }

    } catch (err) {
        console.error("Error fetching payment status:", err);
        paymentStatusDiv.innerHTML = `
            <div class="alert alert-danger">
                <i class="bi bi-exclamation-triangle-fill"></i> ❌ Failed to fetch payment status
            </div>
        `;
    }

    // 3️⃣ Optional Cognito login (for staff/admin)
    document.getElementById("loginBtn").addEventListener("click", () => {
        CHARLIE.auth.login(); // opens hosted UI (if configured)
    });
});
</script>
</body>
</html>
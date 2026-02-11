<?php
// ===========================================
// CHARLIE CAFE - PAYMENT STATUS PAGE
// Handles CARD + CASH payment result
// Features added:
// ✅ Navbar with Charlie Cafe brand & login button
// ✅ Cafe background image
// ✅ Fully responsive & mobile-friendly
// ✅ Cafe-related icons
// ✅ Inline comments explaining each change
// ===========================================

$apiBaseUrl = "https://xxxx.execute-api.us-east-1.amazonaws.com/dev/order-status";

// Validate order ID
if (!isset($_GET['order_id'])) {
    die("❌ Invalid Order ID");
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
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Charlie Cafe ☕ | Payment Status</title>

<!-- Bootstrap CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- Bootstrap Icons for cafe-related icons -->
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
        <!-- Login button (can be linked to Cognito hosted UI) -->
        <button class="btn btn-login" id="loginBtn">
            <i class="bi bi-person-circle"></i> Login
        </button>
    </div>
  </div>
</nav>

<!-- ==================== PAYMENT STATUS CARD ==================== -->
<div class="container my-5 pt-5">
    <div class="card text-center">

        <!-- Header with cafe icon -->
        <h3><i class="bi bi-cash-stack"></i> Payment Status</h3>
        <p><strong>Order ID:</strong> <?= htmlspecialchars($orderId) ?></p>

        <!-- CARD payment success -->
        <?php if (isset($data['payment_method']) && $data['payment_method'] === 'CARD'): ?>
            <div class="alert alert-success">
                <i class="bi bi-credit-card-2-front-fill"></i> ✅ Card payment successful
            </div>
            <a href="order-status.php?order_id=<?= htmlspecialchars($orderId) ?>"
               class="btn btn-primary mt-3">
               <i class="bi bi-box-seam"></i> Track Order
            </a>

        <!-- CASH payment pending -->
        <?php elseif (isset($data['payment_method']) && $data['payment_method'] === 'CASH' && $data['payment_status'] === 'PENDING'): ?>
            <div class="alert alert-warning">
                <i class="bi bi-clock-fill"></i> ☕ Please pay at the counter
            </div>

        <!-- CASH payment completed -->
        <?php elseif (isset($data['payment_method']) && $data['payment_method'] === 'CASH' && $data['payment_status'] === 'PAID'): ?>
            <div class="alert alert-success">
                <i class="bi bi-check-circle-fill"></i> ✅ Cash payment received
            </div>
            <a href="order-status.php?order_id=<?= htmlspecialchars($orderId) ?>"
               class="btn btn-primary mt-3">
               <i class="bi bi-box-seam"></i> Track Order
            </a>

        <!-- Unknown status -->
        <?php else: ?>
            <div class="alert alert-secondary">
                <i class="bi bi-hourglass-split"></i> ⏳ Order created, awaiting payment
            </div>
        <?php endif; ?>

    </div>
</div>

<!-- ==================== BOOTSTRAP JS ==================== -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<!-- ==================== CENTRAL AUTH (Optional Cognito login) ==================== -->
<script src="central-auth-api.js?v=2"></script>
<script>
document.addEventListener("DOMContentLoaded", () => {
    // Bind Cognito login button
    document.getElementById("loginBtn").addEventListener("click", () => {
        cognitoLogin(); // Opens Cognito hosted UI
    });
});
</script>

</body>
</html>
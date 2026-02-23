<?php
// ==========================================================
// CHARLIE CAFE — PLACE ORDER PAGE (PUBLIC)
// ----------------------------------------------------------
// ✔ Includes Navbar
// ✔ Premium UI: glass card, background image
// ✔ Dark/Light Mode
// ✔ Animated coffee steam
// ✔ Stripe + Cash payment integration (API call)
// ==========================================================

$orderSuccess = false;
$errorMessage = "";

// ==========================================================
// PROCESS FORM SUBMISSION
// ==========================================================
if ($_SERVER["REQUEST_METHOD"] === "POST") {

    // 1️⃣ Local Price List (for receipt)
    $prices = [
        "Coffee"      => 3,
        "Tea"         => 2,
        "Latte"       => 4,
        "Cappuccino"  => 4,
        "Fresh Juice" => 5
    ];

    // 2️⃣ Sanitize Input
    $tableNumber  = (int)$_POST["table_number"];
    $customerName = htmlspecialchars($_POST["name"]);
    $item         = $_POST["item"];
    $quantity     = (int)$_POST["quantity"];

    if ($tableNumber <= 0 || $quantity <= 0) {
        $errorMessage = "Invalid table number or quantity.";
    } else {
        $total = $prices[$item] * $quantity;
        $orderSuccess = true;

        // ❌ Removed PHP-generated order ID entirely
        // $statusUrl = "payment-status.php?order_id=$orderId"; // Not needed anymore
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Cafe ☕ | Place Order</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- ===================== BOOTSTRAP + ICONS ===================== -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">

<!-- Stripe JS -->
<script src="https://js.stripe.com/v3/"></script>

<style>
/* ==========================================================
   THEME VARIABLES, BACKGROUND, NAVBAR, GLASS CARD, STEAM
   (UNCHANGED — YOUR ORIGINAL STYLES)
========================================================== */
:root { --overlay: rgba(0,0,0,0.65); --card-bg: rgba(255,255,255,0.95); --text-color:#222; --primary:#ff9800; }
body.dark-mode { --overlay: rgba(0,0,0,0.85); --card-bg: rgba(25,25,25,0.95); --text-color:#fff; }
body { font-family:'Poppins', sans-serif; background: linear-gradient(var(--overlay),var(--overlay)), url("https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb"); background-size: cover; background-position: center; background-attachment: fixed; transition: 0.4s ease; padding-top:80px; }
.navbar-custom { background: rgba(0,0,0,0.85); backdrop-filter: blur(8px); }
.navbar-custom .navbar-brand { font-weight:bold; font-size:1.3rem; color: var(--primary)!important; }
.navbar-custom .nav-link { color:#fff!important; transition:0.3s; }
.navbar-custom .nav-link:hover { color:#ff9800!important; }
.navbar-custom .nav-link.active { color:#ff5722!important; font-weight:bold; }
.order-card { background: var(--card-bg); color: var(--text-color); padding:40px; border-radius:25px; box-shadow:0 15px 45px rgba(0,0,0,0.6); backdrop-filter:blur(12px); transition:0.4s ease; }
.btn-warning { background: linear-gradient(45deg,#ff9800,#ff5722); border:none; font-weight:bold; transition:0.3s; }
.btn-warning:hover { transform:scale(1.05); }
#card-element { padding:12px; border-radius:10px; border:1px solid #ccc; background:#000; color:#fff; }
.steam { width:8px; height:40px; background:rgba(255,255,255,0.7); position:absolute; top:-40px; left:50%; border-radius:50%; animation: steam 3s infinite ease-in-out; }
@keyframes steam { 0% { transform:translateX(-50%) translateY(0); opacity:0; } 50% { opacity:1; } 100% { transform:translateX(-50%) translateY(-60px); opacity:0; } }
</style>
</head>
<body>

<!-- =======================================================
     NAVBAR (KEPT EXACTLY AS ORIGINAL)
======================================================= -->
<nav class="navbar navbar-expand-lg navbar-custom fixed-top">
  <div class="container">
    <a class="navbar-brand" href="index.php">☕ Charlie Cafe</a>
    <button class="navbar-toggler bg-light" type="button" data-bs-toggle="collapse" data-bs-target="#navbarContent">
        <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarContent">
        <ul class="navbar-nav ms-auto">
            <li class="nav-item"><a class="nav-link" href="index.php">🏠 Home</a></li>
            <li class="nav-item"><a class="nav-link active" href="orders.php">🛒 Place Order</a></li>
            <li class="nav-item"><a class="nav-link" href="https://d1e3k1a40fw7la.cloudfront.net/order-status.html">📦 Track Order</a></li>
            <li class="nav-item"><a class="nav-link" href="https://d1e3k1a40fw7la.cloudfront.net/price-list.html">📋 Menu</a></li>
        </ul>
    </div>
  </div>
</nav>

<!-- =======================================================
     ORDER FORM CARD
======================================================= -->
<div class="container d-flex justify-content-center align-items-center" style="min-height:80vh;">
<div class="col-md-6">
<div class="order-card">

<!-- Theme Toggle -->
<div class="text-end mb-3">
    <button onclick="toggleTheme()" class="btn btn-sm btn-dark">🌙 Toggle Theme</button>
</div>

<!-- Header + Steam Animation -->
<div class="text-center position-relative mb-4">
    <div class="steam"></div>
    <h2>☕ Welcome to Charlie Cafe</h2>
</div>

<!-- ORDER FORM -->
<form method="POST">
    <div class="mb-3 input-group">
        <span class="input-group-text"><i class="bi bi-table"></i></span>
        <input type="number" name="table_number" class="form-control" placeholder="Table Number" required>
    </div>
    <div class="mb-3 input-group">
        <span class="input-group-text"><i class="bi bi-person"></i></span>
        <input type="text" name="name" class="form-control" placeholder="Your Name">
    </div>
    <div class="mb-3 input-group">
        <span class="input-group-text"><i class="bi bi-cup-straw"></i></span>
        <select name="item" class="form-select">
            <option>Coffee</option>
            <option>Tea</option>
            <option>Latte</option>
            <option>Cappuccino</option>
            <option>Fresh Juice</option>
        </select>
    </div>
    <div class="mb-3 input-group">
        <span class="input-group-text"><i class="bi bi-hash"></i></span>
        <input type="number" name="quantity" value="1" min="1" class="form-control">
    </div>
    <button type="submit" class="btn btn-warning w-100 mt-3">☕ Place Order</button>
</form>

<!-- ERROR MESSAGE -->
<?php if (!empty($errorMessage)): ?>
<div class="alert alert-danger mt-3"><?= htmlspecialchars($errorMessage) ?></div>
<?php endif; ?>

<!-- ================= RECEIPT + PAYMENT ================= -->
<?php if ($orderSuccess): ?>
<hr class="my-4">
<h5>🧾 Order Receipt</h5>

<!-- ❌ PHP-generated order ID removed, replaced with JS placeholder -->
<p id="order-id-display" class="fw-bold text-primary">Processing order...</p>

<p><strong>Total:</strong> $<?= number_format($total,2) ?></p>

<p class="alert alert-info text-center">Choose ONE payment method</p>

<!-- CARD PAYMENT -->
<div id="payment-section">
    <h4 class="mt-4">💳 Pay with Card</h4>
    <div id="card-element"></div>
    <button onclick="payWithCard()" class="btn btn-success w-100 mt-3">
        Pay $<?= number_format($total,2) ?>
    </button>
</div>

<!-- CASH PAYMENT -->
<div class="mt-4">
    <h4>☕ Pay at Counter (Cash)</h4>
    <button onclick="payWithCash()" class="btn btn-dark w-100">Pay Now (Cash)</button>
</div>

<!-- TRACK ORDER -->
<div class="mt-4 text-center">
    <a id="track-order-btn" class="btn btn-success mt-2" href="#">📦 Track Your Order</a>
</div>
<?php endif; ?>

</div>
</div>
</div>

<!-- =======================================================
     JAVASCRIPT
======================================================= -->
<script src="/js/config.js"></script>
<script src="/js/utils.js"></script>
<script src="/js/api.js"></script>

<script>
// ------------------------
// THEME TOGGLE
// ------------------------
function toggleTheme(){
    document.body.classList.toggle("dark-mode");
    localStorage.setItem("theme",
        document.body.classList.contains("dark-mode") ? "dark":"light");
}
window.onload = function(){
    if(localStorage.getItem("theme")==="dark"){
        document.body.classList.add("dark-mode");
    }
}

// ------------------------
// STRIPE SETUP
// ------------------------
const stripe = Stripe("pk_test_xxxxxxxxx");
const elements = stripe.elements();
const card = elements.create("card",{style:{base:{color:"#fff"}}});
card.mount("#card-element");

// ------------------------
// SEND ORDER TO BACKEND
// ------------------------
async function sendOrderToBackend(paymentMethod){
    const API_URL = window.CHARLIE_CONFIG.API_BASE + "/orders";

    const orderData = {
        table_number: <?= $tableNumber ?? 0 ?>,
        customer_name: "<?= $customerName ?? '' ?>",
        item: "<?= $item ?? '' ?>",
        quantity: <?= $quantity ?? 0 ?>,
        payment_method: paymentMethod
    };

    try {
        const res = await fetch(API_URL, {
            method: "POST",
            headers: {"Content-Type":"application/json"},
            body: JSON.stringify(orderData)
        });

        const result = await res.json();

        if(res.ok){
            // ✅ Display Lambda-generated order_id
            document.getElementById("order-id-display").innerText = "Order ID: " + result.order_id;
            document.getElementById("track-order-btn").href = "order-status.php?order_id=" + result.order_id;
        } else {
            alert("Error: " + result.error);
        }

    } catch(e){
        alert("Network error. Please try again.");
        console.error(e);
    }
}

// ------------------------
// PAYMENT BUTTONS
// ------------------------
function payWithCard(){ alert("Stripe payment successful (simulation)."); sendOrderToBackend("CARD"); }
function payWithCash(){ alert("☕ Please pay at the counter."); sendOrderToBackend("CASH"); }
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
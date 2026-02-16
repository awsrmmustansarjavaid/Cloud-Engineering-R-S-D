<?php
// ==========================================================
// CHARLIE CAFE — PLACE ORDER PAGE (PUBLIC)
// ----------------------------------------------------------
// ✔ No Cognito Required
// ✔ Uses CHARLIE_API.public (api.js)
// ✔ Orders sent via JavaScript
// ✔ Premium UI + Dark Mode + Animation
// ==========================================================

$orderSuccess = false;
$errorMessage = "";

// ==========================================================
// PROCESS FORM SUBMISSION
// ==========================================================
if ($_SERVER["REQUEST_METHOD"] === "POST") {

    // 1️⃣ Generate Unique Order ID
    $orderId = "ORD-" . time() . "-" . rand(100,999);

    // 2️⃣ Local Price List (frontend only)
    $prices = [
        "Coffee"      => 3,
        "Tea"         => 2,
        "Latte"       => 4,
        "Cappuccino"  => 4,
        "Fresh Juice" => 5
    ];

    // 3️⃣ Sanitize Input
    $tableNumber  = (int)$_POST["table_number"];
    $customerName = htmlspecialchars($_POST["name"]);
    $item         = $_POST["item"];
    $quantity     = (int)$_POST["quantity"];

    // 4️⃣ Calculate Total
    $total = $prices[$item] * $quantity;

    // 5️⃣ Prepare API Payload
    $payload = [
        "order_id"      => $orderId,
        "table_number"  => $tableNumber,
        "customer_name" => $customerName,
        "item"          => $item,
        "quantity"      => $quantity
    ];

    // 6️⃣ Redirect URL after payment
    $statusUrl = "payment-status.php?order_id=$orderId";

    $orderSuccess = true;
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Cafe ☕ | Place Order</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- =======================================================
     BOOTSTRAP + ICONS
======================================================= -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">

<!-- Stripe JS -->
<script src="https://js.stripe.com/v3/"></script>

<style>
/* ==========================================================
   THEME VARIABLES (LIGHT & DARK MODE)
========================================================== */
:root {
    --overlay: rgba(0,0,0,0.65);
    --card-bg: rgba(255,255,255,0.95);
    --text-color: #222;
}

body.dark-mode {
    --overlay: rgba(0,0,0,0.85);
    --card-bg: rgba(25,25,25,0.95);
    --text-color: #fff;
}

/* ==========================================================
   BACKGROUND IMAGE + OVERLAY
========================================================== */
body {
    font-family: 'Poppins', sans-serif;
    background:
        linear-gradient(var(--overlay), var(--overlay)),
        url("https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb");
    background-size: cover;
    background-position: center;
    background-attachment: fixed;
    transition: 0.4s ease;
}

/* ==========================================================
   GLASS CARD DESIGN
========================================================== */
.order-card {
    background: var(--card-bg);
    color: var(--text-color);
    padding: 40px;
    border-radius: 25px;
    box-shadow: 0 15px 45px rgba(0,0,0,0.6);
    backdrop-filter: blur(12px);
    transition: 0.4s ease;
}

/* Premium Button */
.btn-warning {
    background: linear-gradient(45deg,#ff9800,#ff5722);
    border:none;
    font-weight:bold;
    transition:0.3s;
}
.btn-warning:hover {
    transform: scale(1.05);
}

/* Stripe Card Element */
#card-element {
    padding:12px;
    border-radius:10px;
    border:1px solid #ccc;
    background:#000;
    color:#fff;
}

/* ==========================================================
   COFFEE STEAM ANIMATION
========================================================== */
.steam {
    width:8px;
    height:40px;
    background:rgba(255,255,255,0.7);
    position:absolute;
    top:-40px;
    left:50%;
    border-radius:50%;
    animation: steam 3s infinite ease-in-out;
}

@keyframes steam {
    0%   { transform:translateX(-50%) translateY(0); opacity:0; }
    50%  { opacity:1; }
    100% { transform:translateX(-50%) translateY(-60px); opacity:0; }
}
</style>
</head>
<body>

<div class="container d-flex justify-content-center align-items-center" style="min-height:100vh;">
<div class="col-md-6">
<div class="order-card">

<!-- =======================================================
     THEME TOGGLE BUTTON
======================================================= -->
<div class="text-end mb-3">
    <button onclick="toggleTheme()" class="btn btn-sm btn-dark">
        🌙 Toggle Theme
    </button>
</div>

<!-- =======================================================
     HEADER WITH STEAM ANIMATION
======================================================= -->
<div class="text-center position-relative mb-4">
    <div class="steam"></div>
    <h2>☕ Welcome to Charlie Cafe</h2>
</div>

<!-- =======================================================
     ORDER FORM
======================================================= -->
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

    <button type="submit" class="btn btn-warning w-100 mt-3">
        ☕ Place Order
    </button>
</form>

<?php if ($orderSuccess): ?>
<hr class="my-4">

<!-- =======================================================
     ORDER RECEIPT
======================================================= -->
<h5 class="text-center">🧾 Order Receipt</h5>
<p><strong>Order ID:</strong> <?= $orderId ?></p>
<p><strong>Total:</strong> $<?= number_format($total,2) ?></p>

<p class="alert alert-info text-center">
    Choose ONE payment method
</p>

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
    <button onclick="payWithCash()" class="btn btn-dark w-100">
        Pay Now (Cash)
    </button>
</div>

<!-- TRACK ORDER -->
<div class="mt-4 text-center">
    <a class="btn btn-success mt-2"
       href="order-status.php?order_id=<?= $orderId ?>">
       📦 Track Your Order
    </a>
</div>

<?php endif; ?>

</div>
</div>
</div>

<!-- =======================================================
     JAVASCRIPT SECTION
======================================================= -->
<script src="config.js"></script>
<script src="utils.js"></script>
<script src="api.js"></script>

<script>
// ==========================================================
// DARK / LIGHT MODE TOGGLE
// ==========================================================
function toggleTheme(){
    document.body.classList.toggle("dark-mode");
    localStorage.setItem("theme",
        document.body.classList.contains("dark-mode") ? "dark":"light");
}

// Load saved theme
window.onload = function(){
    if(localStorage.getItem("theme")==="dark"){
        document.body.classList.add("dark-mode");
    }
}

// ==========================================================
// STRIPE SIMULATION SETUP
// ==========================================================
const stripe = Stripe("pk_test_xxxxxxxxx");
const elements = stripe.elements();
const card = elements.create("card",{style:{base:{color:"#fff"}}});
card.mount("#card-element");

// ==========================================================
// PAYMENT SIMULATION
// ==========================================================
function payWithCard(){
    alert("Stripe payment successful (simulation).");
    window.location.href = "<?= $statusUrl ?? '' ?>";
}

async function payWithCash(){
    alert("☕ Please pay at the counter.");
    window.location.href = "<?= $statusUrl ?? '' ?>";
}
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

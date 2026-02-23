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

    // 1️⃣ Generate Temporary Order ID (for UI tracking)
    $orderId = "ORD-" . time() . "-" . rand(100,999);

    // 2️⃣ Local Price List (for receipt)
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

    if ($tableNumber <= 0 || $quantity <= 0) {
        $errorMessage = "Invalid table number or quantity.";
    } else {
        $total = $prices[$item] * $quantity;
        $orderSuccess = true;

        // 4️⃣ Prepare Redirect URL after payment (temporary, will be replaced by Lambda order_id)
        $statusUrl = "payment-status.php?order_id=$orderId";
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
/* --- STYLES UNTOUCHED --- */
</style>
</head>
<body>

<!-- --- NAVBAR + ORDER FORM UNTOUCHED --- -->

<!-- ================= RECEIPT + PAYMENT ================= -->
<?php if ($orderSuccess): ?>
<hr class="my-4">
<h5>🧾 Order Receipt</h5>
<p><strong>Order ID:</strong> <?= $orderId ?></p>
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
    <a class="btn btn-success mt-2" href="order-status.php?order_id=<?= $orderId ?>">📦 Track Your Order</a>
</div>
<?php endif; ?>

<!-- =======================================================
     JAVASCRIPT
======================================================= -->
<script src="/js/config.js"></script>
<script src="/js/utils.js"></script>
<script src="/js/api.js"></script>

<script>
// ==========================================================
// DARK / LIGHT MODE TOGGLE
// ==========================================================
function toggleTheme(){
    document.body.classList.toggle("dark-mode");
    localStorage.setItem("theme", document.body.classList.contains("dark-mode") ? "dark":"light");
}

// Load saved theme
window.onload = function(){
    if(localStorage.getItem("theme")==="dark"){
        document.body.classList.add("dark-mode");
    }
}

// ==========================================================
// STRIPE SIMULATION
// ==========================================================
const stripe = Stripe("pk_test_xxxxxxxxx");
const elements = stripe.elements();
const card = elements.create("card",{style:{base:{color:"#fff"}}});
card.mount("#card-element");

// ==========================================================
// PAYMENT FUNCTIONS
// ==========================================================

// ------------------------
async function sendOrderToBackend(paymentMethod){
    const API_URL = window.CHARLIE_CONFIG.API_BASE + "/orders";

    // ✅ Added payment_method to match Lambda expectation
    const orderData = {
        table_number: <?= $tableNumber ?? 0 ?>,
        customer_name: "<?= $customerName ?? '' ?>",
        item: "<?= $item ?? '' ?>",
        quantity: <?= $quantity ?? 0 ?>,
        payment_method: paymentMethod.toUpperCase() // "CASH" or "CARD"
    };

    try {
        const res = await fetch(API_URL, {
            method: "POST",
            headers: {"Content-Type":"application/json"},
            body: JSON.stringify(orderData)
        });

        const result = await res.json();
        if(res.ok){
            // ✅ Use Lambda-generated order_id for redirect
            window.location.href = "payment-status.php?order_id=" + result.order_id;
        } else {
            alert("Error: " + result.error);
        }
    } catch(e){
        alert("Network error. Please try again.");
        console.error(e);
    }
}

// ------------------------
function payWithCard(){ sendOrderToBackend("CARD"); }
function payWithCash(){ sendOrderToBackend("CASH"); }
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
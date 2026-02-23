<?php
$orderSuccess = false;
$errorMessage = "";

if ($_SERVER["REQUEST_METHOD"] === "POST") {

    $prices = [
        "Coffee"      => 3,
        "Tea"         => 2,
        "Latte"       => 4,
        "Cappuccino"  => 4,
        "Fresh Juice" => 5
    ];

    $tableNumber  = (int)$_POST["table_number"];
    $customerName = htmlspecialchars($_POST["name"]);
    $item         = $_POST["item"];
    $quantity     = (int)$_POST["quantity"];

    if ($tableNumber <= 0 || $quantity <= 0) {
        $errorMessage = "Invalid table number or quantity.";
    } else {
        $total = $prices[$item] * $quantity;
        $orderSuccess = true;
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Cafe ☕ | Place Order</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">
<script src="https://js.stripe.com/v3/"></script>

<style>
/* ==== YOUR ORIGINAL STYLES UNTOUCHED ==== */
:root {
    --overlay: rgba(0,0,0,0.65);
    --card-bg: rgba(255,255,255,0.95);
    --text-color: #222;
    --primary: #ff9800;
}
body.dark-mode {
    --overlay: rgba(0,0,0,0.85);
    --card-bg: rgba(25,25,25,0.95);
    --text-color: #fff;
}
body {
    font-family:'Poppins', sans-serif;
    background:
        linear-gradient(var(--overlay), var(--overlay)),
        url("https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb");
    background-size: cover;
    background-position: center;
    background-attachment: fixed;
    transition: 0.4s ease;
    padding-top: 80px;
}
.navbar-custom {
    background: rgba(0,0,0,0.85);
    backdrop-filter: blur(8px);
}
.navbar-custom .navbar-brand {
    font-weight: bold;
    font-size: 1.3rem;
    color: var(--primary) !important;
}
.navbar-custom .nav-link {
    color: #fff !important;
    transition: 0.3s;
}
.navbar-custom .nav-link:hover {
    color: #ff9800 !important;
}
.navbar-custom .nav-link.active {
    color: #ff5722 !important;
    font-weight: bold;
}
.order-card {
    background: var(--card-bg);
    color: var(--text-color);
    padding: 40px;
    border-radius: 25px;
    box-shadow: 0 15px 45px rgba(0,0,0,0.6);
    backdrop-filter: blur(12px);
    transition: 0.4s ease;
}
.btn-warning {
    background: linear-gradient(45deg,#ff9800,#ff5722);
    border:none;
    font-weight:bold;
    transition:0.3s;
}
.btn-warning:hover { transform: scale(1.05); }
#card-element {
    padding:12px;
    border-radius:10px;
    border:1px solid #ccc;
    background:#000;
    color:#fff;
}
</style>
</head>
<body>

<!-- ===== NAVBAR UNTOUCHED ===== -->
<nav class="navbar navbar-expand-lg navbar-custom fixed-top">
  <div class="container">
    <a class="navbar-brand" href="index.php">☕ Charlie Cafe</a>
    <button class="navbar-toggler bg-light" type="button"
            data-bs-toggle="collapse" data-bs-target="#navbarContent">
        <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarContent">
        <ul class="navbar-nav ms-auto">
            <li class="nav-item">
                <a class="nav-link" href="index.php">🏠 Home</a>
            </li>
            <li class="nav-item">
                <a class="nav-link active" href="orders.php">🛒 Place Order</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="order-status.html">📦 Track Order</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="price-list.html">📋 Menu</a>
            </li>
        </ul>
    </div>
  </div>
</nav>

<div class="container d-flex justify-content-center align-items-center" style="min-height:80vh;">
<div class="col-md-6">
<div class="order-card">

<h2 class="text-center mb-4">☕ Welcome to Charlie Cafe</h2>

<form method="POST">
    <input type="number" name="table_number" class="form-control mb-3" placeholder="Table Number" required>
    <input type="text" name="name" class="form-control mb-3" placeholder="Your Name">
    <select name="item" class="form-select mb-3">
        <option>Coffee</option>
        <option>Tea</option>
        <option>Latte</option>
        <option>Cappuccino</option>
        <option>Fresh Juice</option>
    </select>
    <input type="number" name="quantity" value="1" min="1" class="form-control mb-3">
    <button type="submit" class="btn btn-warning w-100">☕ Place Order</button>
</form>

<?php if ($orderSuccess): ?>
<hr>
<h5>🧾 Order Receipt</h5>

<!-- UPDATED: Order ID will come from Lambda -->
<p><strong>Order ID:</strong> <span id="lambda-order-id">Processing...</span></p>
<p><strong>Total:</strong> $<?= number_format($total,2) ?></p>

<div class="mt-3">
    <button onclick="payWithCard()" class="btn btn-success w-100">Pay with Card</button>
</div>

<div class="mt-3">
    <button onclick="payWithCash()" class="btn btn-dark w-100">Pay with Cash</button>
</div>
<?php endif; ?>

</div>
</div>
</div>

<script src="/js/config.js"></script>

<script>
// ------------------------
// DO NOT TOUCH (as requested)
async function sendOrderToBackend(paymentMethod){
    const API_URL = window.CHARLIE_CONFIG.API_BASE + "/orders";

    // Updated JSON to include payment_method
    const orderData = {
        table_number: <?= $tableNumber ?? 0 ?>,
        customer_name: "<?= $customerName ?? '' ?>",
        item: "<?= $item ?? '' ?>",
        quantity: <?= $quantity ?? 0 ?>,
        payment_method: paymentMethod   // ✅ REQUIRED by Lambda
    };

    try {
        const res = await fetch(API_URL, {
            method: "POST",
            headers: {"Content-Type":"application/json"},
            body: JSON.stringify(orderData)
        });

        const result = await res.json();

        if(res.ok){

            // ✅ Immediately show REAL Lambda order_id
            document.getElementById("lambda-order-id").innerText = result.order_id;

            // Optional redirect after short delay
            setTimeout(()=>{
                window.location.href = "order-status.php?order_id=" + result.order_id;
            },1500);

        } else {
            alert("Error: " + result.error);
        }

    } catch(e){
        alert("Network error. Please try again.");
        console.error(e);
    }
}

// Payment buttons now correctly pass method
function payWithCard(){
    sendOrderToBackend("CARD");
}
function payWithCash(){
    sendOrderToBackend("CASH");
}
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
<?php
// ===========================================
// CHARLIE CAFE - PLACE ORDER PAGE
// Handles order form submission, generates order ID,
// sends order to backend API, shows receipt + payment options
// ===========================================

// Flag to check if order was successfully placed
$orderSuccess = false;

// Check if the form was submitted via POST
if ($_SERVER["REQUEST_METHOD"] === "POST") {
    
    // Generate a unique order ID (format: ORD-timestamp-random3digits)
    $orderId = "ORD-" . time() . "-" . rand(100,999);
    
    // Static price list for menu items (demo purposes)
    $prices = [
        "Coffee"      => 3,
        "Tea"         => 2,
        "Latte"       => 4,
        "Cappuccino"  => 4,
        "Fresh Juice" => 5
    ];
    
    // Sanitize and fetch form data
    $tableNumber   = (int)$_POST["table_number"];
    $customerName  = htmlspecialchars($_POST["name"]);
    $item          = $_POST["item"];
    $quantity      = (int)$_POST["quantity"];
    
    // Calculate total
    $total = $prices[$item] * $quantity;
    
    // Prepare JSON payload for backend
    $payload = json_encode([
        "order_id"       => $orderId,
        "table_number"   => $tableNumber,
        "customer_name"  => $customerName,
        "item"           => $item,
        "quantity"       => $quantity
    ]);
    
    $apiUrl = "https://a1053skr51.execute-api.us-east-1.amazonaws.com/dev/orders";
    
    // Send POST request via cURL
    $ch = curl_init($apiUrl);
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_POST           => true,
        CURLOPT_HTTPHEADER     => ["Content-Type: application/json"],
        CURLOPT_POSTFIELDS     => $payload
    ]);
    
    $response = curl_exec($ch);
    curl_close($ch);
    
    if ($response !== false) {
        $result = json_decode($response, true);
        if (isset($result['success']) && $result['success'] === true) {
            $orderSuccess = true;
        }
    }

    // Payment status redirect
    $statusUrl = "payment-status.php?order_id=$orderId";
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Cafe ☕ | Place Your Order</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- ===================== BOOTSTRAP + ICONS ===================== -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">

<!-- Google Font for modern cafe vibe -->
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">

<!-- Stripe JS SDK -->
<script src="https://js.stripe.com/v3/"></script>

<style>
/* ===================== BODY + BACKGROUND ===================== */
body {
    font-family: 'Poppins', sans-serif;
    background: url('images/cafe-background.jpg') no-repeat center center fixed;
    background-size: cover;
    min-height: 100vh;
}

/* ===================== NAVBAR ===================== */
.navbar-custom {
    background-color: rgba(0,0,0,0.85);
}
.navbar-custom .navbar-brand,
.navbar-custom .nav-link {
    color: #fff;
}
.navbar-custom .nav-link:hover {
    color: #ff9800;
}

/* ===================== ORDER CARD ===================== */
.order-card {
    background: rgba(255,255,255,0.95);
    border-radius: 22px;
    padding: 35px;
    box-shadow: 0 10px 30px rgba(0,0,0,0.5);
}

/* ===================== STRIPE ELEMENT ===================== */
#card-element {
    padding: 12px;
    border-radius: 10px;
    border: 1px solid #ccc;
    background: #000;
    color: #fff;
}

/* ===================== FORM ICONS ===================== */
.input-group-text i {
    color: #ff9800;
}

/* ===================== RESPONSIVE ===================== */
@media (max-width:768px){
    .order-card { padding: 25px; }
}
</style>
</head>
<body>

<!-- ===================== NAVBAR ===================== -->
<nav class="navbar navbar-expand-lg navbar-dark navbar-custom">
    <div class="container">
        <a class="navbar-brand fw-bold" href="#">☕ Charlie Cafe</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse justify-content-end" id="navbarNav">
            <ul class="navbar-nav">
                <li class="nav-item"><a class="nav-link" href="index.php">Home</a></li>
                <li class="nav-item"><a class="nav-link" href="trackorder.php">Track Order</a></li>
                <li class="nav-item"><a class="nav-link" href="cafe-admin-dashboard.html">Price List</a></li>
            </ul>
        </div>
    </div>
</nav>

<!-- ===================== ORDER FORM ===================== -->
<div class="container d-flex justify-content-center align-items-center" style="min-height:85vh;">
    <div class="col-md-6">
        <div class="order-card">
            <h2 class="text-center mb-4">☕ Place Your Order</h2>

            <form method="POST">
                <!-- Table Number -->
                <div class="mb-3 input-group">
                    <span class="input-group-text"><i class="bi bi-table"></i></span>
                    <input type="number" name="table_number" class="form-control" placeholder="Table Number" required>
                </div>

                <!-- Customer Name -->
                <div class="mb-3 input-group">
                    <span class="input-group-text"><i class="bi bi-person"></i></span>
                    <input type="text" name="name" class="form-control" placeholder="Your Name">
                </div>

                <!-- Select Item -->
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

                <!-- Quantity -->
                <div class="mb-3 input-group">
                    <span class="input-group-text"><i class="bi bi-hash"></i></span>
                    <input type="number" name="quantity" value="1" min="1" class="form-control">
                </div>

                <button type="submit" class="btn btn-warning w-100 mt-3">
                    ☕ Place Order
                </button>
            </form>

            <!-- ===================== RECEIPT & PAYMENT ===================== -->
            <?php if ($orderSuccess): ?>
                <hr class="my-4">
                <h5 class="text-center">🧾 Order Receipt</h5>
                <p><strong>Order ID:</strong> <?= $orderId ?></p>
                <p><strong>Total:</strong> $<?= number_format($total,2) ?></p>

                <p class="alert alert-info text-center">
                    Choose <strong>ONE</strong> payment method
                </p>

                <!-- Card Payment -->
                <div id="payment-section">
                    <h4 class="mt-4">💳 Pay with Card</h4>
                    <div id="card-element"></div>
                    <div id="card-errors" class="text-danger mt-2"></div>
                    <button onclick="payWithCard()" class="btn btn-success w-100 mt-3">
                        Pay $<?= number_format($total,2) ?>
                    </button>
                </div>

                <!-- Cash Payment -->
                <div class="mt-4">
                    <h4>☕ Pay at Counter (Cash)</h4>
                    <button onclick="payWithCash()" class="btn btn-dark w-100">
                        Pay Now (Cash)
                    </button>
                    <small class="text-muted d-block mt-2 text-center">
                        Pay at the counter. Order will be prepared after payment.
                    </small>
                </div>

                <!-- Track Order -->
                <div class="mt-4 text-center">
                    <a class="btn btn-success mt-2" href="order-status.php?order_id=<?= $orderId ?>">
                        📦 Track Your Order
                    </a>
                </div>
            <?php endif; ?>
        </div>
    </div>
</div>

<!-- ===================== STRIPE PAYMENT LOGIC ===================== -->
<script>
const stripe = Stripe("pk_test_xxxxxxxxx"); // REPLACE with your real key
const elements = stripe.elements();
const card = elements.create("card", { style: { base: { color: "#fff" } } });
card.mount("#card-element");

async function payWithCard() {
    alert("Stripe payment successful (LAB simulation).");
    window.location.href = "<?= $statusUrl ?>";
}

async function payWithCash() {
    document.getElementById("payment-section").style.display = "none";

    try {
        const response = await fetch(
            "https://bs0vgnth0f.execute-api.us-east-1.amazonaws.com/dev/orders/cash-payment",
            {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ order_id: "<?= $orderId ?>" })
            }
        );
        const result = await response.json();
        if (result.success) {
            alert("☕ Please pay at the counter.");
            window.location.href = "<?= $statusUrl ?>";
        } else {
            alert("Cash payment failed.");
        }
    } catch(err) {
        console.error("Cash payment error:", err);
        alert("Server error. Please try again.");
    }
}
</script>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
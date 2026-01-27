<?php
// ===========================================
// CHARLIE CAFE - PLACE ORDER PAGE (FINAL)
// ===========================================

$orderSuccess = false;

if ($_SERVER["REQUEST_METHOD"] === "POST") {

    $orderId = "ORD-" . time() . "-" . rand(100,999);

    $prices = [
        "Coffee" => 3,
        "Tea" => 2,
        "Latte" => 4,
        "Cappuccino" => 4,
        "Fresh Juice" => 5
    ];

    $tableNumber = (int)$_POST["table_number"];
    $customerName = htmlspecialchars($_POST["name"]);
    $item = $_POST["item"];
    $quantity = (int)$_POST["quantity"];
    $total = $prices[$item] * $quantity;

    $payload = json_encode([
        "table_number"  => $tableNumber,
        "customer_name" => $customerName,
        "item"          => $item,
        "quantity"      => $quantity
    ]);

    $apiUrl = "https://svirhyw5a3.execute-api.us-east-1.amazonaws.com/dev/orders";

    $ch = curl_init($apiUrl);
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_POST => true,
        CURLOPT_HTTPHEADER => ["Content-Type: application/json"],
        CURLOPT_POSTFIELDS => $payload
    ]);

    $response = curl_exec($ch);
    curl_close($ch);

    if ($response !== false) {
        $result = json_decode($response, true);
        if (isset($result['success']) && $result['success'] === true) {
            $orderSuccess = true;
        }
    }

    $statusUrl = "order-status.php?order_id=$orderId";
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Cafe ☕ | Place Order</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- Bootstrap -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- Google Font -->
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">

<!-- Stripe JS SDK (MANDATORY) -->
<script src="https://js.stripe.com/v3/"></script>

<style>
/* Existing styles untouched */
body {
    font-family: 'Poppins', sans-serif;
    min-height: 100vh;
    background: linear-gradient(rgba(0,0,0,0.65), rgba(0,0,0,0.65)),
                url("https://images.unsplash.com/photo-1517248135467-4c7edcad34c4");
    background-size: cover;
}
.order-card {
    background: #fff;
    border-radius: 22px;
    padding: 35px;
}
#card-element {
    padding: 12px;
    border-radius: 10px;
    border: 1px solid #ccc;
    background: #000;
}
</style>
</head>

<body>

<div class="container d-flex justify-content-center align-items-center" style="min-height:85vh;">
<div class="col-md-6">
<div class="order-card">

<h2 class="text-center">Place Your Order</h2>

<form method="POST">
    <label>Table Number</label>
    <input type="number" name="table_number" class="form-control" required>

    <label>Customer Name</label>
    <input type="text" name="name" class="form-control">

    <label>Select Item</label>
    <select name="item" class="form-select">
        <option>Coffee</option>
        <option>Tea</option>
        <option>Latte</option>
        <option>Cappuccino</option>
        <option>Fresh Juice</option>
    </select>

    <label>Quantity</label>
    <input type="number" name="quantity" value="1" class="form-control">

    <button type="submit" class="btn btn-warning w-100 mt-4">☕ Place Order</button>
</form>

<?php if ($_SERVER["REQUEST_METHOD"] === "POST"): ?>

<!-- ===================== RECEIPT ===================== -->
<div class="mt-4">
    <h5>🧾 Order Receipt</h5>
    <p><strong>Order ID:</strong> <?= $orderId ?></p>
    <p><strong>Total:</strong> $<?= $total ?></p>
</div>

<!-- ===================== PAYMENT SECTION (NEW) ===================== -->
<div id="payment-section" class="mt-4">

    <h4>💳 Pay with Card</h4>

    <!-- Stripe Card Element -->
    <div id="card-element"></div>

    <!-- Card errors -->
    <div id="card-errors" class="text-danger mt-2"></div>

    <!-- Payment button -->
    <button onclick="placeOrder()" class="btn btn-success w-100 mt-3">
        Pay $<?= $total ?>
    </button>

</div>

<?php endif; ?>

</div>
</div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script>
// ===================== STRIPE INITIALIZATION =====================

// Initialize Stripe with TEST publishable key
const stripe = Stripe("pk_test_xxxxxxxxx");

// Create Stripe Elements instance
const elements = stripe.elements();

// Create card input element
const cardElement = elements.create('card', {
    style: {
        base: {
            fontSize: '16px',
            color: '#ffffff',
            '::placeholder': { color: '#cccccc' }
        },
        invalid: { color: '#ff0000' }
    }
});

// Mount card element
cardElement.mount('#card-element');

// Handle real-time validation errors
cardElement.on('change', function(event) {
    document.getElementById('card-errors').textContent =
        event.error ? event.error.message : '';
});

// ===================== PLACE ORDER + PAY =====================
async function placeOrder() {

    try {
        // Create payment intent (backend)
        const response = await fetch('/payment/create-intent', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                orderId: "<?= $orderId ?>",
                amount: <?= $total * 100 ?>
            })
        });

        const data = await response.json();

        // Confirm card payment
        const result = await stripe.confirmCardPayment(
            data.clientSecret,
            { payment_method: { card: cardElement } }
        );

        if (result.error) {
            alert("❌ Payment Failed: " + result.error.message);
        } else {
            alert("✅ Payment Successful! Order Confirmed.");
            window.location.href = "<?= $statusUrl ?>";
        }

    } catch (err) {
        alert("Payment error occurred.");
        console.error(err);
    }
}
</script>

</body>
</html>
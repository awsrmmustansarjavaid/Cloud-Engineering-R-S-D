<?php
// ===========================================
// CHARLIE CAFE - PLACE ORDER PAGE
// Card + Cash Payment (LAB VERSION)
// ===========================================

$orderSuccess = false;

if ($_SERVER["REQUEST_METHOD"] === "POST") {

    // Generate unique order ID
    $orderId = "ORD-" . time() . "-" . rand(100,999);

    // Static price list (LAB ONLY)
    $prices = [
        "Coffee" => 3,
        "Tea" => 2,
        "Latte" => 4,
        "Cappuccino" => 4,
        "Fresh Juice" => 5
    ];

    // Collect form data
    $tableNumber  = (int)$_POST["table_number"];
    $customerName = htmlspecialchars($_POST["name"]);
    $item         = $_POST["item"];
    $quantity     = (int)$_POST["quantity"];
    $total        = $prices[$item] * $quantity;

    // Prepare payload for backend order API
    $payload = json_encode([
        "order_id"      => $orderId,
        "table_number"  => $tableNumber,
        "customer_name" => $customerName,
        "item"          => $item,
        "quantity"      => $quantity
    ]);

    // Centralized Orders API
    $apiUrl = "https://bs0vgnth0f.execute-api.us-east-1.amazonaws.com/dev/orders";

    // Send order to backend
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

    // Order status page
    // $statusUrl = "order-status.php?order_id=$orderId";

    // Payment status page (after payment decision)
       $statusUrl = "payment-status.php?order_id=$orderId";

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

<!-- Stripe SDK -->
<script src="https://js.stripe.com/v3/"></script>

<style>
body {
    font-family: 'Poppins', sans-serif;
    background: #111;
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

<div class="container d-flex justify-content-center align-items-center" style="min-height:90vh;">
<div class="col-md-6">
<div class="order-card">

<h2 class="text-center mb-4">☕ Place Your Order</h2>

<!-- ===================== ORDER FORM ===================== -->
<form method="POST">
    <label>Table Number</label>
    <input type="number" name="table_number" class="form-control" required>

    <label class="mt-2">Customer Name</label>
    <input type="text" name="name" class="form-control">

    <label class="mt-2">Select Item</label>
    <select name="item" class="form-select">
        <option>Coffee</option>
        <option>Tea</option>
        <option>Latte</option>
        <option>Cappuccino</option>
        <option>Fresh Juice</option>
    </select>

    <label class="mt-2">Quantity</label>
    <input type="number" name="quantity" value="1" class="form-control">

    <button type="submit" class="btn btn-warning w-100 mt-4">
        ☕ Place Order
    </button>
</form>

<?php if ($orderSuccess): ?>

<!-- ===================== RECEIPT ===================== -->
<hr class="my-4">
<h5>🧾 Order Receipt</h5>
<p><strong>Order ID:</strong> <?= $orderId ?></p>
<p><strong>Total:</strong> $<?= $total ?></p>

<p class="alert alert-info">
Choose <strong>ONE</strong> payment method
</p>

<!-- ===================== CARD PAYMENT ===================== -->
<div id="payment-section">
    <h4>💳 Pay with Card</h4>
    <div id="card-element"></div>
    <div id="card-errors" class="text-danger mt-2"></div>

    <button onclick="payWithCard()" class="btn btn-success w-100 mt-3">
        Pay $<?= $total ?>
    </button>
</div>

<!-- ===================== CASH PAYMENT ===================== -->
<div class="mt-3">
    <h4>☕ Pay at Counter (Cash)</h4>
    <button onclick="payWithCash()" class="btn btn-dark w-100">
        Pay Now (Cash)
    </button>
    <small class="text-muted d-block mt-2">
        Pay at the counter. Order will be prepared after payment.
    </small>
</div>

<?php endif; ?>

</div>
</div>
</div>

<!-- ===================== STRIPE JS ===================== -->
<script>
// Initialize Stripe
const stripe = Stripe("pk_test_xxxxxxxxx");
const elements = stripe.elements();

// Create card element
const card = elements.create("card", {
    style: {
        base: { color: "#fff" }
    }
});
card.mount("#card-element");

// Handle card payment
async function payWithCard() {

    // ⚠️ Your existing Stripe logic stays here    
    alert("Stripe payment successful (LAB simulation).");

    // Redirect to payment status page
    window.location.href = "<?= $statusUrl ?>";
}

// Handle CASH payment
async function payWithCash() {

    // Disable card payment UI to avoid double payment
    document.getElementById("payment-section").style.display = "none";

    try {
        const response = await fetch(
            "https://bs0vgnth0f.execute-api.us-east-1.amazonaws.com/dev/orders/cash-payment",
            {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    order_id: "<?= $orderId ?>"
                })
            }
        );

        const result = await response.json();

        if (result.success) {
            alert("☕ Please pay at the counter.");
            window.location.href = "<?= $statusUrl ?>";
        } else {
            alert("Cash payment failed.");
        }

    } catch (err) {
        console.error(err);
        alert("Server error.");
    }
}
</script>

</body>
</html>
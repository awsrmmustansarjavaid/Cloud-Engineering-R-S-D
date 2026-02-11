<?php
// ===========================================
// CHARLIE CAFE - PLACE ORDER PAGE (Simplified)
// No Cognito / Auth headers needed
// ===========================================

$orderSuccess = false;
$errorMessage = "";

// Run only when form is submitted
if ($_SERVER["REQUEST_METHOD"] === "POST") {

    // 1️⃣ Generate unique order ID
    $orderId = "ORD-" . time() . "-" . rand(100,999);

    // 2️⃣ Price list
    $prices = [
        "Coffee"      => 3,
        "Tea"         => 2,
        "Latte"       => 4,
        "Cappuccino"  => 4,
        "Fresh Juice" => 5
    ];

    // 3️⃣ Fetch and sanitize form data
    $tableNumber  = (int)$_POST["table_number"];
    $customerName = htmlspecialchars($_POST["name"]);
    $item         = $_POST["item"];
    $quantity     = (int)$_POST["quantity"];

    // 4️⃣ Calculate total
    $total = $prices[$item] * $quantity;

    // 5️⃣ Prepare API payload
    $payload = json_encode([
        "order_id"      => $orderId,
        "table_number"  => $tableNumber,
        "customer_name" => $customerName,
        "item"          => $item,
        "quantity"      => $quantity
    ]);

    // 6️⃣ API Endpoint (Authorization removed)
    $apiUrl = "https://q8rq19tfka.execute-api.us-east-1.amazonaws.com/dev/orders";

    // 7️⃣ Send POST request via cURL
    $ch = curl_init($apiUrl);
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_POST           => true,
        CURLOPT_HTTPHEADER     => ["Content-Type: application/json"],
        CURLOPT_POSTFIELDS     => $payload,
        CURLOPT_TIMEOUT        => 10
    ]);

    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);

    if (curl_errno($ch)) {
        $errorMessage = "CURL Error: " . curl_error($ch);
    }

    curl_close($ch);

    // 8️⃣ Check API response
    if ($httpCode === 200 && $response) {
        $result = json_decode($response, true);
        if (isset($result["message"]) && $result["message"] === "Order saved successfully") {
            $orderSuccess = true;
        } else {
            $errorMessage = "Unexpected API response: $response";
        }
    } else {
        $errorMessage = "HTTP Error $httpCode: $response";
    }

    // Payment status page
    $statusUrl = "payment-status.php?order_id=$orderId";
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Cafe ☕ | Place Order</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- Bootstrap + Icons -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">

<!-- Stripe JS -->
<script src="https://js.stripe.com/v3/"></script>

<style>
body { font-family:'Poppins', sans-serif; background:#f4f4f4; }
.order-card { background:#fff; padding:35px; border-radius:22px; box-shadow:0 10px 30px rgba(0,0,0,0.5); }
#card-element { padding:12px; border-radius:10px; border:1px solid #ccc; background:#000; color:#fff; }
.input-group-text i { color:#ff9800; }
@media (max-width:768px){ .order-card { padding:25px; } }
</style>
</head>
<body>

<div class="container d-flex justify-content-center align-items-center" style="min-height:85vh;">
<div class="col-md-6">
<div class="order-card">

<h2 class="text-center mb-4">☕ Place Your Order</h2>

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

<?php if (!empty($errorMessage)): ?>
<div class="alert alert-danger mt-3"><?= htmlspecialchars($errorMessage) ?></div>
<?php endif; ?>

<?php if ($orderSuccess): ?>
<hr class="my-4">
<h5 class="text-center">🧾 Order Receipt</h5>
<p><strong>Order ID:</strong> <?= $orderId ?></p>
<p><strong>Total:</strong> $<?= number_format($total,2) ?></p>

<p class="alert alert-info text-center">Choose <strong>ONE</strong> payment method</p>

<!-- Card Payment -->
<div id="payment-section">
    <h4 class="mt-4">💳 Pay with Card</h4>
    <div id="card-element"></div>
    <div id="card-errors" class="text-danger mt-2"></div>
    <button onclick="payWithCard()" class="btn btn-success w-100 mt-3">Pay $<?= number_format($total,2) ?></button>
</div>

<!-- Cash Payment -->
<div class="mt-4">
    <h4>☕ Pay at Counter (Cash)</h4>
    <button onclick="payWithCash()" class="btn btn-dark w-100">Pay Now (Cash)</button>
    <small class="text-muted d-block mt-2 text-center">Pay at the counter. Order will be prepared after payment.</small>
</div>

<div class="mt-4 text-center">
    <a class="btn btn-success mt-2" href="order-status.php?order_id=<?= $orderId ?>">📦 Track Your Order</a>
</div>
<?php endif; ?>

</div>
</div>
</div>

<script>
// Stripe Elements setup
const stripe = Stripe("pk_test_xxxxxxxxx"); // replace with your key
const elements = stripe.elements();
const card = elements.create("card", { style: { base: { color:"#fff" } } });
card.mount("#card-element");

// Card payment (simulation)
function payWithCard() {
    alert("Stripe payment successful (simulation).");
    window.location.href = "<?= $statusUrl ?>";
}

// Cash payment API call (no auth)
async function payWithCash() {
    document.getElementById("payment-section").style.display = "none";

    try {
        const response = await fetch(
            "https://q8rq19tfka.execute-api.us-east-1.amazonaws.com/dev/orders/cash-payment",
            {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ order_id: "<?= $orderId ?>" })
            }
        );
        const result = await response.json();
        if (result.success || result.message) {
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

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
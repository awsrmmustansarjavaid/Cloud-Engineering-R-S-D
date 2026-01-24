<?php
// -------------------------------
// PROCESS ORDER SUBMISSION
// -------------------------------
$orderSuccess = false;

if ($_SERVER["REQUEST_METHOD"] === "POST") {

    // Prepare JSON payload to send to Lambda API
    $payload = json_encode([
        "table_number"  => (int) $_POST['table_number'],
        "customer_name" => htmlspecialchars($_POST['name']),
        "item"          => $_POST['item'],
        "quantity"      => (int) $_POST['quantity']
    ]);

    $apiUrl = "https://svirhyw5a3.execute-api.us-east-1.amazonaws.com/dev/orders";

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

        // ✅ SHOW SUCCESS TOAST ONLY IF RDS INSERT SUCCEEDED
        if (isset($result['success']) && $result['success'] === true) {
            $orderSuccess = true;
        }
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Charlie Cafe ☕ | Place Order</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            min-height: 100vh;
            background:
                linear-gradient(rgba(0,0,0,0.65), rgba(0,0,0,0.65)),
                url("https://images.unsplash.com/photo-1517248135467-4c7edcad34c4");
            background-size: cover;
            background-position: center;
        }
        .navbar { background-color: #3b1f0e; }
        .navbar-brand { font-weight: 600; color: #fff !important; }
        .order-card { background: #fff; border-radius: 22px; padding: 35px; box-shadow: 0 20px 40px rgba(0,0,0,0.35); animation: fadeUp 0.9s ease; }
        .order-card h2 { font-weight: 600; }
        label { font-weight: 500; margin-top: 15px; }
        input, select { border-radius: 10px; padding: 10px; }
        .btn-order { background-color: #ff9800; color: #000; font-weight: 600; border-radius: 30px; padding: 12px; border: none; transition: all 0.3s ease; }
        .btn-order:hover { background-color: #e68900; transform: translateY(-2px); }
        footer { color: #fff; text-align: center; padding: 15px; margin-top: 40px; font-size: 14px; }
        @keyframes fadeUp { from { opacity: 0; transform: translateY(30px); } to { opacity: 1; transform: translateY(0); } }
    </style>
</head>
<body>

<nav class="navbar navbar-dark">
    <div class="container">
        <a class="navbar-brand" href="index.php">☕ Charlie Cafe</a>
    </div>
</nav>

<div class="container d-flex justify-content-center align-items-center" style="min-height: 85vh;">
    <div class="col-md-6">
        <div class="order-card">
            <h2 class="text-center">Place Your Order</h2>
            <p class="text-center text-muted">Fresh • Hot • Made with Love</p>

            <form method="POST" id="orderForm">
                <label>Table Number</label>
                <input type="number" name="table_number" min="1" class="form-control" required>
                <label>Customer Name</label>
                <input type="text" name="name" class="form-control" maxlength="50">
                <label>Select Item</label>
                <select name="item" class="form-select">
                    <option>Coffee</option>
                    <option>Tea</option>
                    <option>Latte</option>
                    <option>Cappuccino</option>
                    <option>Fresh Juice</option>
                </select>
                <label>Quantity</label>
                <input type="number" name="quantity" min="1" value="1" class="form-control">
                <button type="submit" class="btn btn-order w-100 mt-4">☕ Place Order</button>
            </form>
        </div>
    </div>
</div>

<!-- TOASTS -->
<div class="toast-container position-fixed top-0 end-0 p-3">
    <div id="welcomeToast" class="toast">
        <div class="toast-header">
            <strong class="me-auto">☕ Charlie Cafe</strong>
            <button class="btn-close" data-bs-dismiss="toast"></button>
        </div>
        <div class="toast-body">Welcome to the Charlie Cafe order page!</div>
    </div>
</div>

<div class="toast-container position-fixed bottom-0 end-0 p-3">
    <div id="successToast" class="toast">
        <div class="toast-header bg-success text-white">
            <strong class="me-auto">Order Placed</strong>
            <button class="btn-close btn-close-white" data-bs-dismiss="toast"></button>
        </div>
        <div class="toast-body">✅ Your order has been sent to the kitchen!</div>
    </div>
</div>

<footer>© 2026 Charlie Cafe | Serverless Orders ☁️</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
document.addEventListener("DOMContentLoaded", () => {
    // Show welcome toast
    new bootstrap.Toast(document.getElementById('welcomeToast'), { delay: 2500 }).show();

    // Show success toast if backend confirmed order
    <?php if ($orderSuccess): ?>
        new bootstrap.Toast(document.getElementById('successToast')).show();
    <?php endif; ?>
});
</script>
</body>
</html>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Charlie Cafe ☕ | Place Order</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">

    <style>
        body {
            font-family: 'Poppins', sans-serif;
            min-height: 100vh;
            background: linear-gradient(rgba(0,0,0,0.65), rgba(0,0,0,0.65)),
                        url("https://images.unsplash.com/photo-1517248135467-4c7edcad34c4");
            background-size: cover;
        }
        .navbar { background-color: #3b1f0e; }
        .navbar-brand { color: #fff !important; font-weight: 600; }
        .order-card {
            background: white;
            border-radius: 20px;
            padding: 35px;
            box-shadow: 0 15px 30px rgba(0,0,0,0.3);
        }
        .btn-order {
            background-color: #ff9800;
            font-weight: 600;
            border-radius: 30px;
        }
        .receipt {
            background: #f8f9fa;
            border-radius: 15px;
            padding: 20px;
            margin-top: 25px;
        }
        .status-badge {
            background: #0d6efd;
            color: white;
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 13px;
        }
    </style>
</head>

<body>

<nav class="navbar navbar-dark">
    <div class="container">
        <a class="navbar-brand" href="index.html">☕ Charlie Cafe</a>
    </div>
</nav>

<div class="container d-flex justify-content-center align-items-center" style="min-height: 85vh;">
<div class="col-md-6">
<div class="order-card">

<h2 class="text-center">Place Your Order</h2>
<p class="text-center text-muted">Fresh • Hot • Made with Love</p>

<form method="POST">
<label>Table Number</label>
<input type="number" name="table_number" min="1" class="form-control" required>

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
<input type="number" name="quantity" min="1" value="1" class="form-control">

<button type="submit" class="btn btn-order w-100 mt-4">☕ Place Order</button>
</form>

<?php
if ($_SERVER["REQUEST_METHOD"] === "POST") {

$orderId = "ORD-" . time() . "-" . rand(100,999);

$prices = [
"Coffee"=>3,"Tea"=>2,"Latte"=>4,"Cappuccino"=>4,"Fresh Juice"=>5
];

$item = $_POST["item"];
$qty = (int)$_POST["quantity"];
$total = $prices[$item] * $qty;

$apiUrl = "https://svirhyw5a3.execute-api.us-east-1.amazonaws.com/dev/orders";

$payload = json_encode([
"table_number"=>(int)$_POST["table_number"],
"customer_name"=>$_POST["name"],
"item"=>$item,
"quantity"=>$qty
]);

$ch = curl_init($apiUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, ["Content-Type: application/json"]);
curl_setopt($ch, CURLOPT_POSTFIELDS, $payload);
curl_exec($ch);
curl_close($ch);

$statusUrl = "order-status.php?order_id=$orderId";
?>

<div class="receipt">
<h5>🧾 Order Receipt</h5>
<p><strong>Order ID:</strong> <?= $orderId ?></p>
<p><strong>Status:</strong> <span class="status-badge">RECEIVED</span></p>
<hr>
<p><strong>Item:</strong> <?= $item ?></p>
<p><strong>Quantity:</strong> <?= $qty ?></p>
<p><strong>Total:</strong> $<?= $total ?></p>
<hr>
<p><strong>Order Status Link:</strong><br>
<a href="<?= $statusUrl ?>" target="_blank"><?= $statusUrl ?></a></p>

<button onclick="window.print()" class="btn btn-outline-dark w-100 mt-3">🖨️ Print Receipt</button>
</div>

<?php } ?>

</div>
</div>
</div>

<footer class="text-center text-white mt-4">
© 2026 Charlie Cafe | Serverless Orders ☁️
</footer>

</body>
</html>
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
    // time() gives current timestamp, rand(100,999) adds randomness
    $orderId = "ORD-" . time() . "-" . rand(100,999);
    
    // Static price list for menu items (used only in lab/demo version)
    // In real app, this should come from database or backend
    $prices = [
        "Coffee"      => 3,
        "Tea"         => 2,
        "Latte"       => 4,
        "Cappuccino"  => 4,
        "Fresh Juice" => 5
    ];
    
    // Get and sanitize form data
    $tableNumber   = (int)$_POST["table_number"];           // Convert to integer
    $customerName  = htmlspecialchars($_POST["name"]);      // Prevent XSS
    $item          = $_POST["item"];                        // Selected menu item
    $quantity      = (int)$_POST["quantity"];               // Convert to integer
    
    // Calculate total price
    $total = $prices[$item] * $quantity;
    
    // Prepare JSON payload to send to backend (API Gateway → CreateOrderLambda)
    $payload = json_encode([
        "order_id"       => $orderId,
        "table_number"   => $tableNumber,
        "customer_name"  => $customerName,
        "item"           => $item,
        "quantity"       => $quantity
    ]);
    
    // API Gateway endpoint for creating orders (dev stage)
    $apiUrl = "https://a1053skr51.execute-api.us-east-1.amazonaws.com/dev/orders";
    
    // Send POST request to backend using cURL
    $ch = curl_init($apiUrl);
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,      // Return response as string
        CURLOPT_POST           => true,      // Use POST method
        CURLOPT_HTTPHEADER     => ["Content-Type: application/json"],
        CURLOPT_POSTFIELDS     => $payload   // Send JSON data
    ]);
    
    $response = curl_exec($ch);              // Execute the request
    curl_close($ch);                         // Close cURL session
    
    // Check if request was successful
    if ($response !== false) {
        $result = json_decode($response, true); // Decode JSON response
        
        // Check if backend confirmed success
        if (isset($result['success']) && $result['success'] === true) {
            $orderSuccess = true; // Show receipt & payment options
        }
    }

    // ===========================================   
    // Change destination page    
    // ===========================================

    // Order status page
    // $statusUrl = "order-status.php?order_id=$orderId";


    // URL for payment status page (after user chooses payment method)
    $statusUrl = "payment-status.php?order_id=$orderId";
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Charlie Cafe ☕ | Place Your Order</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    
    <!-- Bootstrap 5 CSS for responsive design and components -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- Google Font: Poppins for modern cafe vibe -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
    
    <!-- Stripe JavaScript SDK for card payments -->
    <script src="https://js.stripe.com/v3/"></script>

    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background: #111; /* Dark background for cafe feel */
        }
        .order-card {
            background: #fff;
            border-radius: 22px;
            padding: 35px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.5); /* Soft shadow */
        }
        #card-element {
            padding: 12px;
            border-radius: 10px;
            border: 1px solid #ccc;
            background: #000;
            color: #fff;
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
                    <div class="mb-3">
                        <label class="form-label">Table Number</label>
                        <input type="number" name="table_number" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Customer Name</label>
                        <input type="text" name="name" class="form-control">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Select Item</label>
                        <select name="item" class="form-select">
                            <option>Coffee</option>
                            <option>Tea</option>
                            <option>Latte</option>
                            <option>Cappuccino</option>
                            <option>Fresh Juice</option>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Quantity</label>
                        <input type="number" name="quantity" value="1" min="1" class="form-control">
                    </div>
                    <button type="submit" class="btn btn-warning w-100 mt-3">
                        ☕ Place Order
                    </button>
                </form>

                <!-- Show receipt and payment options only after successful order -->
                <?php if ($orderSuccess): ?>
                    <!-- ===================== RECEIPT ===================== -->
                    <hr class="my-4">
                    <h5 class="text-center">🧾 Order Receipt</h5>
                    <p><strong>Order ID:</strong> <?= $orderId ?></p>
                    <p><strong>Total:</strong> $<?= number_format($total, 2) ?></p>
                    
                    <p class="alert alert-info text-center">
                        Choose <strong>ONE</strong> payment method
                    </p>

                    <!-- ===================== CARD PAYMENT SECTION ===================== -->
                    <div id="payment-section">
                        <h4 class="mt-4">💳 Pay with Card</h4>
                        <div id="card-element"></div> <!-- Stripe card input will mount here -->
                        <div id="card-errors" class="text-danger mt-2"></div>
                        <button onclick="payWithCard()" class="btn btn-success w-100 mt-3">
                            Pay $<?= number_format($total, 2) ?>
                        </button>
                    </div>

                    <!-- ===================== CASH PAYMENT SECTION ===================== -->
                    <div class="mt-4">
                        <h4>☕ Pay at Counter (Cash)</h4>
                        <button onclick="payWithCash()" class="btn btn-dark w-100">
                            Pay Now (Cash)
                        </button>
                        <small class="text-muted d-block mt-2 text-center">
                            Pay at the counter. Order will be prepared after payment.
                        </small>
                    </div>

                    <!-- ===================== TRACK ORDER BUTTON ===================== -->
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

    <!-- ===================== STRIPE JAVASCRIPT LOGIC ===================== -->
    <script>
        // Initialize Stripe with your public test key (replace in production!)
        const stripe = Stripe("pk_test_xxxxxxxxx"); // ← REPLACE WITH YOUR REAL KEY

        const elements = stripe.elements();

        // Create and mount the card input field
        const card = elements.create("card", {
            style: {
                base: { color: "#fff" }
            }
        });
        card.mount("#card-element");

    // ===========================================   
    // CARD PAYMENT REDIRECT    
    // ===========================================

        // Handle card payment (currently simulated)
        async function payWithCard() {
            // ⚠️ In real app: call stripe.confirmCardPayment() here
            alert("Stripe payment successful (LAB simulation).");
            // Redirect to payment status page
            window.location.href = "<?= $statusUrl ?>";
        }

        // Handle cash payment (calls backend API)
        async function payWithCash() {
            // Hide card payment section to prevent double payment
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
                console.error("Cash payment error:", err);
                alert("Server error. Please try again.");
            }
        }
    </script>
</body>
</html>
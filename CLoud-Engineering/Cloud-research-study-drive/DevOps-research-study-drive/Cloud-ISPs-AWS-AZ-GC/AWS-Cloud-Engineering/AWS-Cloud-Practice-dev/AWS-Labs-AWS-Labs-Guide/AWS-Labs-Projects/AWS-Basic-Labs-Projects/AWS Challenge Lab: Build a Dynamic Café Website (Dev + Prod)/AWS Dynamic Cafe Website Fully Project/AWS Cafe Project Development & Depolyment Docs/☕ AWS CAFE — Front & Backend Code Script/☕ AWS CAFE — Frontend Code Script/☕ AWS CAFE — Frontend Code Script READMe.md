# ☕ AWS CAFE — Backend Code Script README


### 2️⃣ Restart Apache (MANDATORY)

```
sudo systemctl restart httpd
```


---

# SECTION 1️⃣ Cafe Order Processor
> **Doc File: ☕ AWS CAFE — Order_Async_Processing_Tracking_System**

## PHASE 5️⃣ — Frontend Development Code

### 1️⃣ Update EC2 PHP App to Use API Gateway

```
sudo nano /var/www/html/orders.php
```

#### In your `orders.php`:

You can copy-paste this entire file safely 👇

```php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $data = json_encode([
        "name" => $_POST['name'],
        "item" => $_POST['item'],
        "quantity" => $_POST['quantity']
    ]);

    $ch = curl_init("https://abcdef123.execute-api.us-east-1.amazonaws.com/dev/orders");
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, $data);

    $response = curl_exec($ch);
    curl_close($ch);

    echo "<p>✅ Order sent to serverless backend!</p>";
}
```

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Charlie Cafe ☕ | Place Order</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Google Font -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">

    <style>
        body {
            font-family: 'Poppins', sans-serif;
            margin: 0;
            min-height: 100vh;
            background: linear-gradient(rgba(0,0,0,0.65), rgba(0,0,0,0.65)),
                        url("https://images.unsplash.com/photo-1517248135467-4c7edcad34c4");
            background-size: cover;
            background-position: center;
        }

        .navbar {
            background-color: #3b1f0e;
        }

        .navbar-brand {
            color: #fff !important;
            font-weight: 600;
        }

        .order-card {
            background: #ffffff;
            border-radius: 20px;
            padding: 35px;
            box-shadow: 0 15px 30px rgba(0,0,0,0.3);
        }

        .order-card h2 {
            font-weight: 600;
            margin-bottom: 20px;
        }

        label {
            font-weight: 500;
            margin-top: 15px;
        }

        input, select {
            border-radius: 10px;
            padding: 10px;
        }

        .btn-order {
            background-color: #ff9800;
            color: #000;
            font-weight: 600;
            border-radius: 30px;
            padding: 12px;
            border: none;
            transition: 0.3s;
        }

        .btn-order:hover {
            background-color: #e68900;
        }

        footer {
            color: #fff;
            text-align: center;
            padding: 15px;
            margin-top: 40px;
            font-size: 14px;
        }

        .response-box {
            margin-top: 20px;
            font-size: 14px;
        }
    </style>
</head>

<body>

<!-- Navbar -->
<nav class="navbar navbar-dark">
    <div class="container">
        <a class="navbar-brand" href="index.html">☕ Charlie Cafe</a>
    </div>
</nav>

<!-- Order Section -->
<div class="container d-flex justify-content-center align-items-center" style="min-height: 85vh;">
    <div class="col-md-6">
        <div class="order-card">

            <h2 class="text-center">Place Your Order</h2>
            <p class="text-center text-muted">Fresh • Hot • Made with Love</p>

            <form method="POST">

                <!-- NEW: TABLE NUMBER -->
                <label>Table Number</label>
                <input type="number" name="table_number" min="1" class="form-control" required>

                <label>Customer Name</label>
                <input type="text" name="name" class="form-control">

                <label>Select Item</label>
                <select name="item" class="form-select">
                    <option value="Coffee">Coffee</option>
                    <option value="Tea">Tea</option>
                    <option value="Latte">Latte</option>
                    <option value="Cappuccino">Cappuccino</option>
                    <option value="Fresh Juice">Fresh Juice</option>
                </select>

                <label>Quantity</label>
                <input type="number" name="quantity" min="1" value="1" class="form-control">

                <button type="submit" class="btn btn-order w-100 mt-4">
                    ☕ Place Order
                </button>
            </form>

            <!-- Backend Response (UNCHANGED FLOW) -->
            <div class="response-box">
                <?php
                if ($_SERVER["REQUEST_METHOD"] === "POST") {

                    $apiUrl = "https://svirhyw5a3.execute-api.us-east-1.amazonaws.com/dev/orders";

                    $payload = json_encode([
                        "table_number"  => (int)$_POST['table_number'],
                        "customer_name" => $_POST['name'],
                        "item"          => $_POST['item'],
                        "quantity"      => (int)$_POST['quantity']
                    ]);

                    $ch = curl_init($apiUrl);
                    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
                    curl_setopt($ch, CURLOPT_POST, true);
                    curl_setopt($ch, CURLOPT_HTTPHEADER, [
                        "Content-Type: application/json"
                    ]);
                    curl_setopt($ch, CURLOPT_POSTFIELDS, $payload);

                    $response = curl_exec($ch);

                    if ($response === false) {
                        echo "<p class='text-danger'>❌ CURL Error: " . curl_error($ch) . "</p>";
                    } else {
                        echo "<p class='text-success fw-bold'>✅ Order sent successfully</p>";
                        echo "<pre class='bg-light p-2 rounded'>$response</pre>";
                    }

                    curl_close($ch);
                }
                ?>
            </div>

        </div>
    </div>
</div>

<!-- Footer -->
<footer>
    © 2026 Charlie Cafe | Serverless Orders ☁️
</footer>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
```

**✅ PHASE 5️⃣ STATUS**

> **🟢 PHASE 5️⃣ COMPLETE & VERIFIED**
# 🟢 SECTION 1️⃣ COMPLETE & VERIFIED
---
# SECTION 4️⃣ — ORDER STATUS DASHBOARD

## PHASE 6️⃣ — FRONTEND ORDER STATUS PAGE

#### 1️⃣ Simple order-status.html 

[order-status.html](https://github.com/awsrmmustansarjavaid/Cloud-Engineering-R-S-D/blob/main/CLoud-Engineering/Cloud-research-study-drive/DevOps-research-study-drive/Cloud-ISPs-AWS-AZ-GC/AWS-Cloud-Engineering/AWS-Cloud-Practice-dev/AWS-Labs-AWS-Labs-Guide/AWS-Labs-Projects/AWS-Basic-Labs-Projects/AWS%20Challenge%20Lab%3A%20Build%20a%20Dynamic%20Caf%C3%A9%20Website%20(Dev%20%2B%20Prod)/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/AWS%20Cafe%20Project%20Development%20%26%20Depolyment%20Docs/%E2%98%95%20AWS%20CAFE%20%E2%80%94%20Front%20%26%20Backend%20Code%20Script/%E2%98%95%20AWS%20CAFE%20%E2%80%94%20Frontend%20Code%20Script/order-status.html%20)

**✅ PHASE 6️⃣ STATUS**

> **🟢 PHASE 6️⃣ COMPLETE & VERIFIED**
# 🟢 SECTION 4️⃣ COMPLETE & VERIFIED
---
# ☕ SECTION 5️⃣ — Customer Order Tracking, Billing & Receipt (Frontend-Only, Zero-Risk)

## 🔔 PHASE 1️⃣ — Customer Order Tracking, Billing & Receipt (Frontend-Only, Zero-Risk)

### 🧑‍💻 STEP 2 — CREATE UPDATED ORDER FILE

#### 📌 Copy-paste exactly as is

[place-order.php](https://github.com/awsrmmustansarjavaid/Cloud-Engineering-R-S-D/blob/main/CLoud-Engineering/Cloud-research-study-drive/DevOps-research-study-drive/Cloud-ISPs-AWS-AZ-GC/AWS-Cloud-Engineering/AWS-Cloud-Practice-dev/AWS-Labs-AWS-Labs-Guide/AWS-Labs-Projects/AWS-Basic-Labs-Projects/AWS%20Challenge%20Lab%3A%20Build%20a%20Dynamic%20Caf%C3%A9%20Website%20(Dev%20%2B%20Prod)/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/AWS%20Cafe%20Project%20Development%20%26%20Depolyment%20Docs/%E2%98%95%20AWS%20CAFE%20%E2%80%94%20Front%20%26%20Backend%20Code%20Script/%E2%98%95%20AWS%20CAFE%20%E2%80%94%20Frontend%20Code%20Script/place-order.php)


**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
# 🟢 SECTION 5️⃣ COMPLETE & VERIFIED
---
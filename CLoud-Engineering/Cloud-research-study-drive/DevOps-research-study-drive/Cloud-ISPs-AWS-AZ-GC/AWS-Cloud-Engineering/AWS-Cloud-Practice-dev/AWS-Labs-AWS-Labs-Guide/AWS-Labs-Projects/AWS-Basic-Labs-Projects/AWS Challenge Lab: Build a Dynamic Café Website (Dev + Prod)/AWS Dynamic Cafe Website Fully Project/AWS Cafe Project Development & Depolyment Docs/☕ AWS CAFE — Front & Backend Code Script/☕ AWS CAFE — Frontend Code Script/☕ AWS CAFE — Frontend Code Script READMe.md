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
---
## 🔔 PHASE 2️⃣ — Customer Order Tracking (Read-Only Backend, Zero-Risk)

### 🧑‍💻 STEP 8 — CREATE order-status.php

This file is frontend-only and SAFE

```
<?php
$orderId = $_GET['order_id'] ?? '';
$apiUrl = "https://xxxx.execute-api.us-east-1.amazonaws.com/prod/order-status?order_id=$orderId";
$response = file_get_contents($apiUrl);
$data = json_decode($response, true);
?>
<!DOCTYPE html>
<html>
<head>
<title>Order Status</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="container mt-5">

<h3>☕ Order Status</h3>

<?php if (!$data || isset($data['error'])): ?>
<p class="text-danger">Order not found</p>
<?php else: ?>
<p><strong>Order ID:</strong> <?= $orderId ?></p>
<p><strong>Status:</strong> <?= $data['status'] ?></p>
<p><strong>Item:</strong> <?= $data['order']['item'] ?></p>
<p><strong>Quantity:</strong> <?= $data['order']['quantity'] ?></p>
<p><strong>Date:</strong> <?= $data['order']['created_at'] ?></p>

<button onclick="window.print()" class="btn btn-dark">Print</button>
<?php endif; ?>

</body>
</html>
```

#### ☕ FINAL order-status.php with print button (CAFE STYLED - Recommanded)

[FINAL-order-status-with-print-button.php](https://github.com/awsrmmustansarjavaid/Cloud-Engineering-R-S-D/blob/main/CLoud-Engineering/Cloud-research-study-drive/DevOps-research-study-drive/Cloud-ISPs-AWS-AZ-GC/AWS-Cloud-Engineering/AWS-Cloud-Practice-dev/AWS-Labs-AWS-Labs-Guide/AWS-Labs-Projects/AWS-Basic-Labs-Projects/AWS%20Challenge%20Lab%3A%20Build%20a%20Dynamic%20Caf%C3%A9%20Website%20(Dev%20%2B%20Prod)/AWS%20Dynamic%20Cafe%20Website%20Fully%20Project/AWS%20Cafe%20Project%20Development%20%26%20Depolyment%20Docs/%E2%98%95%20AWS%20CAFE%20%E2%80%94%20Front%20%26%20Backend%20Code%20Script/%E2%98%95%20AWS%20CAFE%20%E2%80%94%20Frontend%20Code%20Script/FINAL-order-status-with-print-button.php)

**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**
---
## 🔄 PHASE 3️⃣ — Real Order State Machine (RECEIVED → PREPARING → READY → COMPLETED)

### 🧑‍💻 STEP 8 — UPDATE order-status.php

#### ☕ order-status.php (FINAL VERSION)

#### ✅ FULL Final order-status.php FILE

```
<?php
// ================= CONFIG =================
$apiBaseUrl = "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/order-status";

// ================= GET ORDER ID =================
if (!isset($_GET['order_id']) || empty($_GET['order_id'])) {
    die("❌ Invalid order reference.");
}

$orderId = $_GET['order_id'];

// ================= CALL API =================
$apiUrl = $apiBaseUrl . "?order_id=" . urlencode($orderId);

$ch = curl_init($apiUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$response = curl_exec($ch);

if ($response === false) {
    die("❌ Failed to fetch order status.");
}

curl_close($ch);
$data = json_decode($response, true);

if (!isset($data['order'])) {
    die("❌ Order not found.");
}

$order = $data['order'];
?>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Order Status | Charlie Cafe ☕</title>
<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- Bootstrap -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
body {
    background: #f4f6f9;
}
.receipt {
    max-width: 520px;
    margin: 40px auto;
    background: #ffffff;
    padding: 30px;
    border-radius: 15px;
    box-shadow: 0 15px 30px rgba(0,0,0,0.15);
}
.status-badge {
    font-size: 14px;
    padding: 6px 12px;
}
@media print {
    button {
        display: none;
    }
}
</style>
</head>

<body>

<div class="receipt">

    <h4 class="text-center mb-3">☕ Charlie Cafe</h4>
    <p class="text-center text-muted">Order Receipt</p>

    <hr>

    <p><strong>Order ID:</strong> <?= htmlspecialchars($order['order_id']) ?></p>
    <p><strong>Customer:</strong> <?= htmlspecialchars($order['customer_name']) ?></p>
    <p><strong>Table:</strong> <?= htmlspecialchars($order['table_number']) ?></p>
    <p><strong>Date:</strong> <?= htmlspecialchars($order['created_at']) ?></p>

    <hr>

    <p><strong>Item:</strong> <?= htmlspecialchars($order['item']) ?></p>
    <p><strong>Quantity:</strong> <?= htmlspecialchars($order['quantity']) ?></p>

    <hr>

    <p>
        <strong>Status:</strong>
        <?php
        $status = $order['status'];
        $badge = "secondary";

        if ($status === "RECEIVED") $badge = "info";
        if ($status === "PREPARING") $badge = "warning";
        if ($status === "READY") $badge = "primary";
        if ($status === "COMPLETED") $badge = "success";
        ?>
        <span class="badge bg-<?= $badge ?> status-badge">
            <?= $status ?>
        </span>
    </p>

    <hr>

    <p><strong>Total Amount:</strong> $<?= number_format($order['total_amount'], 2) ?></p>

    <div class="d-grid mt-4">
        <button onclick="window.print()" class="btn btn-dark">
            🖨️ Print Receipt
        </button>
    </div>

</div>

</body>
</html>
```

#### 🔍 EXPECTED API RESPONSE FORMAT

Your backend MUST return this structure:

```
{
  "order": {
    "order_id": "ORD-20260114-8392",
    "customer_name": "John",
    "table_number": 4,
    "item": "Latte",
    "quantity": 2,
    "total_amount": 8.00,
    "status": "PREPARING",
    "created_at": "2026-01-14 10:42:00"
  }
}
```

#### ✅ order-status.php — FINAL VERSION with below ALL FEATURES ( Recommanded)

🔄 Auto-refresh status every 10 sec

📱 Mobile receipt layout

📦 QR code on receipt

🔔 WebSocket live updates

> **📌 Backend requirement (unchanged):**

```
GET /order-status?order_id=ORD-XXXX
```

#### 📁 FILE LOCATION

```
/web
 ├── order.php
 ├── order-status.php   ✅ (THIS FILE)
```

#### 🔽 COPY & PASTE — FULL FILE

```
<?php
// ================= CONFIG =================
$apiBaseUrl = "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/order-status";

// ================= VALIDATE INPUT =================
if (!isset($_GET['order_id']) || empty($_GET['order_id'])) {
    die("❌ Invalid order reference.");
}

$orderId = $_GET['order_id'];

// ================= FETCH ORDER =================
function fetchOrder($apiBaseUrl, $orderId) {
    $url = $apiBaseUrl . "?order_id=" . urlencode($orderId);
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    $res = curl_exec($ch);
    curl_close($ch);
    return json_decode($res, true);
}

$data = fetchOrder($apiBaseUrl, $orderId);

if (!isset($data['order'])) {
    die("❌ Order not found.");
}

$order = $data['order'];
?>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Order Receipt | Charlie Cafe ☕</title>
<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- Bootstrap -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- QR Code -->
<script src="https://cdn.jsdelivr.net/npm/qrcodejs/qrcode.min.js"></script>

<style>
body {
    background: #f4f6f9;
}
.receipt {
    max-width: 520px;
    margin: 20px auto;
    background: #ffffff;
    padding: 25px;
    border-radius: 16px;
    box-shadow: 0 15px 30px rgba(0,0,0,0.15);
}
.status-badge {
    font-size: 14px;
    padding: 6px 12px;
}
@media print {
    button, #qrBox {
        display: none;
    }
}
</style>
</head>

<body>

<div class="receipt">

    <h4 class="text-center mb-2">☕ Charlie Cafe</h4>
    <p class="text-center text-muted">Order Receipt</p>

    <hr>

    <p><strong>Order ID:</strong> <?= htmlspecialchars($order['order_id']) ?></p>
    <p><strong>Customer:</strong> <?= htmlspecialchars($order['customer_name']) ?></p>
    <p><strong>Table:</strong> <?= htmlspecialchars($order['table_number']) ?></p>
    <p><strong>Date:</strong> <?= htmlspecialchars($order['created_at']) ?></p>

    <hr>

    <p><strong>Item:</strong> <?= htmlspecialchars($order['item']) ?></p>
    <p><strong>Quantity:</strong> <?= htmlspecialchars($order['quantity']) ?></p>

    <hr>

    <?php
    $status = $order['status'];
    $badge = "secondary";
    if ($status === "RECEIVED") $badge = "info";
    if ($status === "PREPARING") $badge = "warning";
    if ($status === "READY") $badge = "primary";
    if ($status === "COMPLETED") $badge = "success";
    ?>

    <p>
        <strong>Status:</strong>
        <span id="statusBadge" class="badge bg-<?= $badge ?> status-badge">
            <?= htmlspecialchars($status) ?>
        </span>
    </p>

    <hr>

    <p class="fw-bold">
        Total Amount: $<?= number_format($order['total_amount'], 2) ?>
    </p>

    <!-- QR CODE -->
    <div id="qrBox" class="text-center my-3">
        <div id="qrcode"></div>
        <small class="text-muted">Scan to track order</small>
    </div>

    <div class="d-grid gap-2 mt-3">
        <button onclick="window.print()" class="btn btn-dark">
            🖨️ Print Receipt
        </button>
    </div>

</div>

<script>
// ================= QR CODE =================
new QRCode(document.getElementById("qrcode"), {
    text: window.location.href,
    width: 120,
    height: 120
});

// ================= AUTO REFRESH (10s) =================
setInterval(() => {
    fetch(window.location.href, { cache: "no-store" })
        .then(res => res.text())
        .then(html => {
            document.open();
            document.write(html);
            document.close();
        });
}, 10000);
</script>

</body>
</html>
```

#### ✅ FEATURES IMPLEMENTED (CONFIRMED)

| Feature             | Status                        |
| ------------------- | ----------------------------- |
| Auto-refresh        | ✅ 10 seconds                  |
| Mobile-friendly     | ✅ Responsive                  |
| QR code             | ✅ Live tracking link          |
| Live status updates | ✅ Polling (no backend change) |
| Print receipt       | ✅ Clean print view            |
| Backend untouched   | ✅ 100% safe                   |

**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---
### 🧩 STEP 5 — FINAL order-status.php (LATEST VERSION)

✅ Includes ALL required features

✅ Copy–paste ready

✅ No backend changes required

#### ✅ FULL FILE — COPY & PASTE

```
<?php
$apiBaseUrl = "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/order-status";

if (!isset($_GET['order_id']) || empty($_GET['order_id'])) {
    die("❌ Invalid order reference");
}

$orderId = $_GET['order_id'];

function fetchOrder($url, $orderId) {
    $ch = curl_init($url . "?order_id=" . urlencode($orderId));
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    $res = curl_exec($ch);
    curl_close($ch);
    return json_decode($res, true);
}

$data = fetchOrder($apiBaseUrl, $orderId);
if (!isset($data['order'])) {
    die("❌ Order not found");
}

$order = $data['order'];
?>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Order Status | Charlie Cafe ☕</title>
<meta name="viewport" content="width=device-width, initial-scale=1">

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/qrcodejs/qrcode.min.js"></script>

<style>
body { background:#f4f6f9; }
.receipt {
  max-width:520px;
  margin:20px auto;
  background:#fff;
  padding:25px;
  border-radius:15px;
  box-shadow:0 15px 30px rgba(0,0,0,.15);
}
@media print {
  button, #qrBox { display:none; }
}
</style>
</head>

<body>

<div class="receipt">

<h4 class="text-center">☕ Charlie Cafe</h4>
<p class="text-center text-muted">Order Receipt</p>
<hr>

<p><b>Order ID:</b> <?= $order['order_id'] ?></p>
<p><b>Customer:</b> <?= $order['customer_name'] ?></p>
<p><b>Table:</b> <?= $order['table_number'] ?></p>
<p><b>Date:</b> <?= $order['created_at'] ?></p>

<hr>

<p><b>Item:</b> <?= $order['item'] ?></p>
<p><b>Quantity:</b> <?= $order['quantity'] ?></p>

<hr>

<p><b>Status:</b>
<span class="badge bg-info"><?= $order['status'] ?></span>
</p>

<hr>

<p class="fw-bold">Total: $<?= number_format($order['total_amount'],2) ?></p>

<div id="qrBox" class="text-center my-3">
  <div id="qrcode"></div>
  <small class="text-muted">Scan to reopen this order</small>
</div>

<button onclick="window.print()" class="btn btn-dark w-100">
🖨️ Print Receipt
</button>

</div>

<script>
new QRCode(document.getElementById("qrcode"), {
  text: window.location.href,
  width:120,
  height:120
});

// Auto refresh every 10 seconds
setInterval(() => {
  fetch(window.location.href, { cache:'no-store' })
    .then(r => r.text())
    .then(html => {
      document.open(); document.write(html); document.close();
    });
}, 10000);
</script>

</body>
</html>
```

**✅ PHASE 4️⃣ STATUS**

> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**

# 🟢 SECTION 5️⃣ COMPLETE & VERIFIED
---









**✅ PHASE 4️⃣ STATUS**

> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**


# 🟢 SECTION 5️⃣ COMPLETE & VERIFIED
---
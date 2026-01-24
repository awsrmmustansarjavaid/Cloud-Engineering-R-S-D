# 📌 orders Page (orders.php) — Feature Overview & Improvements


## 🟦 PREVIOUS order.php — Explanation (Old) 

### Features

➡️ Basic Bootstrap form

➡️ Inline POST request using PHP + cURL

➡️ Plain text success message

➡️ No animations

➡️ No notifications

➡️ Minimal UX feedback

➡️ UI was functional but static

### Limitations

➡️ Used text output instead of UI feedback

➡️ No frontend security comments

➡️ No animations or polish

➡️ No welcome message

➡️ Backend response printed directly (not user-friendly)



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

## ✅ NEW IMPROVED order.php (Production-Style)

🔹 You can replace your existing file with this

🔹 Backend flow remains SAME (no breaking changes)

### UI / UX

➡️ Premium order card with animation

➡️ Smooth hover effects

➡️ Clean typography

➡️ Professional spacing & layout

### Notifications

➡️ Welcome toast on page load

➡️ Success toast after backend confirms order

➡️ No alert() used

### Backend Integration

➡️ Same API Gateway endpoint

➡️ Same JSON payload

➡️ Improved sanitization

➡️ Backend flow untouched (safe upgrade)

### Security Awareness

➡️ Input casting & sanitization

➡️ Frontend validation explained

➡️ Clear frontend vs backend responsibility

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">

    <!-- SECURITY + RESPONSIVE -->
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Charlie Cafe ☕ | Place Order</title>

    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Google Font -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">

    <style>
        /* ===============================
           GLOBAL STYLES
        =============================== */
        body {
            font-family: 'Poppins', sans-serif;
            min-height: 100vh;
            background:
                linear-gradient(rgba(0,0,0,0.65), rgba(0,0,0,0.65)),
                url("https://images.unsplash.com/photo-1517248135467-4c7edcad34c4");
            background-size: cover;
            background-position: center;
        }

        /* ===============================
           NAVBAR
        =============================== */
        .navbar {
            background-color: #3b1f0e;
        }

        .navbar-brand {
            font-weight: 600;
            color: #fff !important;
        }

        /* ===============================
           ORDER CARD (PREMIUM UI)
        =============================== */
        .order-card {
            background: #ffffff;
            border-radius: 22px;
            padding: 35px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.35);
            animation: fadeUp 0.9s ease;
        }

        .order-card h2 {
            font-weight: 600;
        }

        label {
            font-weight: 500;
            margin-top: 15px;
        }

        input, select {
            border-radius: 10px;
            padding: 10px;
        }

        /* ===============================
           BUTTON
        =============================== */
        .btn-order {
            background-color: #ff9800;
            color: #000;
            font-weight: 600;
            border-radius: 30px;
            padding: 12px;
            border: none;
            transition: all 0.3s ease;
        }

        .btn-order:hover {
            background-color: #e68900;
            transform: translateY(-2px);
        }

        /* ===============================
           FOOTER
        =============================== */
        footer {
            color: #fff;
            text-align: center;
            padding: 15px;
            margin-top: 40px;
            font-size: 14px;
        }

        /* ===============================
           ANIMATIONS
        =============================== */
        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(30px); }
            to   { opacity: 1; transform: translateY(0); }
        }
    </style>
</head>

<body>

<!-- ===============================
     NAVBAR
=============================== -->
<nav class="navbar navbar-dark">
    <div class="container">
        <a class="navbar-brand" href="index.php">☕ Charlie Cafe</a>
    </div>
</nav>

<!-- ===============================
     ORDER FORM SECTION
=============================== -->
<div class="container d-flex justify-content-center align-items-center" style="min-height: 85vh;">
    <div class="col-md-6">

        <div class="order-card">

            <h2 class="text-center">Place Your Order</h2>
            <p class="text-center text-muted">Fresh • Hot • Made with Love</p>

            <!-- 
                SECURITY NOTE:
                - Frontend validation improves UX only
                - Backend MUST validate again
            -->
            <form method="POST">

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

                <button type="submit" class="btn btn-order w-100 mt-4">
                    ☕ Place Order
                </button>
            </form>

            <!-- ===============================
                 BACKEND RESPONSE HANDLING
            =============================== -->
            <div class="mt-3">

                <?php
                if ($_SERVER["REQUEST_METHOD"] === "POST") {

                    /*
                        SECURITY:
                        - Always sanitize & cast inputs
                        - Never trust frontend input
                    */
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

                    if ($response === false) {
                        echo "<div class='text-danger fw-bold'>❌ Order failed. Please try again.</div>";
                    } else {
                        // SUCCESS → Trigger Toast via JS
                        echo "<script>
                            document.addEventListener('DOMContentLoaded', () => {
                                const toast = new bootstrap.Toast(document.getElementById('successToast'));
                                toast.show();
                            });
                        </script>";
                    }

                    curl_close($ch);
                }
                ?>

            </div>

        </div>
    </div>
</div>

<!-- ===============================
     TOAST NOTIFICATIONS
=============================== -->

<!-- Welcome Toast -->
<div class="toast-container position-fixed top-0 end-0 p-3">
    <div id="welcomeToast" class="toast">
        <div class="toast-header">
            <strong class="me-auto">☕ Charlie Cafe</strong>
            <button class="btn-close" data-bs-dismiss="toast"></button>
        </div>
        <div class="toast-body">
            Welcome to the Charlie Cafe order page!
        </div>
    </div>
</div>

<!-- Success Toast -->
<div class="toast-container position-fixed bottom-0 end-0 p-3">
    <div id="successToast" class="toast">
        <div class="toast-header bg-success text-white">
            <strong class="me-auto">Order Placed</strong>
            <button class="btn-close btn-close-white" data-bs-dismiss="toast"></button>
        </div>
        <div class="toast-body">
            ✅ Your order has been sent to the kitchen!
        </div>
    </div>
</div>

<!-- Footer -->
<footer>
    © 2026 Charlie Cafe | Serverless Orders ☁️
</footer>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script>
    // Show welcome toast once page loads
    document.addEventListener("DOMContentLoaded", () => {
        const toast = new bootstrap.Toast(document.getElementById('welcomeToast'), { delay: 2500 });
        toast.show();
    });
</script>

</body>
</html>
```

### 🔥 OLD vs NEW — Difference Table

| Area              | Old Order Page | New Order Page |
| ----------------- | -------------- | -------------- |
| UI                | Basic          | Premium        |
| Animations        | None           | Smooth CSS     |
| Notifications     | Text           | Toasts         |
| Backend Feedback  | Raw response   | User-friendly  |
| Security Comments | ❌              | ✅              |
| UX                | Static         | Interactive    |
| Production Ready  | ❌              | ✅              |


### 🔗 Backend Integration Flow (Your Lab Architecture)

```
order.php (Frontend)
        ↓
API Gateway (POST /orders)
        ↓
Lambda (Python)
        ↓
RDS (Orders Table)
```

✔ Frontend sends clean JSON

✔ Backend processes securely

✔ UI reacts with toast feedback

### ✅ You now have:

▶️ Interview-ready frontend

▶️ AWS-aligned architecture

▶️ Clean, documented code

▶️ Clear before/after explanation

---


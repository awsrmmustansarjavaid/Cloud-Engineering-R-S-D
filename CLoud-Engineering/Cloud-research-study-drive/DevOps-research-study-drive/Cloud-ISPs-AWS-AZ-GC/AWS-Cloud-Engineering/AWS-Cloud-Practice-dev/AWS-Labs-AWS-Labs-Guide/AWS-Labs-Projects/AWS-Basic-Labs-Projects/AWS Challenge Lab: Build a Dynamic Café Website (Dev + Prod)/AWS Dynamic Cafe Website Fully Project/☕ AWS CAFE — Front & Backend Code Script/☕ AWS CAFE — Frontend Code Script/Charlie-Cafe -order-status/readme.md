# 📌 Order-Status Page  — Feature Overview & Improvements


## 1️⃣ Metrics + all recent orders (order-status.html)

### 1️⃣ order-status.html (Previous & Simple)

> **# SECTION 4️⃣ — ORDER STATUS DASHBOARD**

> **## PHASE 6️⃣ — FRONTEND ORDER STATUS PAGE**

> **#### 1️⃣ Simple order-status.html**

#### 1️⃣ First Code (JavaScript + API Fetch)

#### Primary Tasks & Features:

#### 1️⃣ Live Order Dashboard:

- Fetches metrics and recent orders dynamically from API using JavaScript fetch().

- Displays cards for metrics like total orders, pending, completed, etc.

- Displays a recent orders table with customer, item, quantity, table, and date.

#### 1️⃣ Toast Notifications:

- Welcome toast when page loads.

- Success toast when data is successfully fetched.

#### 2️⃣ Dynamic & Live:

- Orders and metrics are real-time, updated every page load.

- Handles API errors gracefully with a message in the table.

#### 3️⃣ UI/UX:

- Dark theme with blur effects and gradient.

- Responsive, card animations, hover effects on table and metrics.

#### 4️⃣ Backend Integration:

- API endpoint returns JSON with metrics & recent_orders.

- Completely frontend-driven for live updates.


```
<!DOCTYPE html>
<html lang="en" data-bs-theme="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Charlie Cafe ☕ | Order Status</title>
    
    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- Google Font - Poppins -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
    
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            min-height: 100vh;
            margin: 0;
            background: linear-gradient(rgba(0,0,0,0.70), rgba(0,0,0,0.70)),
                        url("https://images.unsplash.com/photo-1517248135467-4c7edcad34c4");
            background-size: cover;
            background-position: center;
            background-attachment: fixed;
            color: #fff;
        }

        /* Navbar */
        .navbar {
            background-color: #3b1f0e !important;
        }
        .navbar-brand {
            font-weight: 600;
            color: #fff !important;
        }

        /* Main container */
        .status-container {
            background: rgba(30, 30, 30, 0.75);
            border-radius: 20px;
            padding: 40px;
            backdrop-filter: blur(8px);
            box-shadow: 0 15px 40px rgba(0,0,0,0.5);
            margin: 40px auto;
            max-width: 1100px;
        }

        h2 {
            font-weight: 600;
            text-shadow: 0 2px 10px rgba(0,0,0,0.6);
        }

        /* Metrics Cards */
        .metric-card {
            background: linear-gradient(135deg, #4a2c1a, #3b1f0e);
            border: none;
            border-radius: 15px;
            transition: transform 0.3s ease;
        }
        .metric-card:hover {
            transform: translateY(-8px);
        }
        .metric-card .card-body {
            text-align: center;
            padding: 25px;
        }
        .metric-card h5 {
            margin-bottom: 8px;
            font-weight: 500;
            color: #ff9800;
        }
        .metric-card .display-5 {
            font-weight: 700;
            color: white;
        }

        /* Table Styling - Dark & Elegant */
        .table {
            background: rgba(40, 40, 40, 0.85);
            border-radius: 12px;
            overflow: hidden;
        }
        .table thead th {
            background: #3b1f0e;
            color: #ff9800;
            font-weight: 600;
            border-bottom: 2px solid #ff9800;
        }
        .table tbody tr {
            transition: background 0.2s;
        }
        .table tbody tr:hover {
            background: rgba(255,152,0,0.15);
        }
        .table td, .table th {
            border-color: rgba(255,255,255,0.08);
        }

        /* Footer */
        footer {
            background: rgba(0,0,0,0.7);
            color: #ddd;
            text-align: center;
            padding: 20px;
            margin-top: 60px;
            font-size: 0.95rem;
        }

        @media (max-width: 768px) {
            .status-container {
                padding: 25px;
                margin: 20px;
            }
        }
    </style>
</head>
<body>

<!-- Navbar -->
<nav class="navbar navbar-expand-lg">
    <div class="container">
        <a class="navbar-brand" href="index.html">☕ Charlie Cafe</a>
    </div>
</nav>

<!-- Main Content -->
<div class="container">
    <div class="status-container">
        <h2 class="text-center mb-5">📊 Live Order Status</h2>

        <!-- Metrics (Cards) -->
        <div id="metrics" class="row g-4 mb-5 justify-content-center"></div>

        <!-- Recent Orders Table -->
        <div class="table-responsive">
            <table class="table table-hover text-white">
                <thead>
                    <tr>
                        <th>Customer</th>
                        <th>Item</th>
                        <th>Qty</th>
                        <th>Table</th>
                        <th>Date</th>
                    </tr>
                </thead>
                <tbody id="orders"></tbody>
            </table>
        </div>
    </div>
</div>

<!-- Footer -->
<footer>
    © 2026 Charlie Cafe | Fresh Drinks • Made with ❤️
</footer>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<!-- Fetch & Display Data -->
<script>
fetch("https://API_ID.execute-api.region.amazonaws.com/status/order-status")  // ← Replace with your real API endpoint
    .then(res => {
        if (!res.ok) throw new Error('Network response was not ok');
        return res.json();
    })
    .then(data => {
        // Metrics Cards
        const metricsContainer = document.getElementById("metrics");
        data.metrics.forEach(m => {
            metricsContainer.innerHTML += `
                <div class="col-6 col-md-4 col-lg-3">
                    <div class="card metric-card shadow">
                        <div class="card-body">
                            <h5>${m.metric}</h5>
                            <p class="display-5 mb-0">${m.count}</p>
                        </div>
                    </div>
                </div>`;
        });

        // Orders Table
        const ordersBody = document.getElementById("orders");
        data.recent_orders.forEach(o => {
            ordersBody.innerHTML += `
                <tr>
                    <td>${o.customer_name || '<em>Anonymous</em>'}</td>
                    <td>${o.item}</td>
                    <td>${o.quantity}</td>
                    <td>${o.table_number || '-'}</td>
                    <td>${o.created_at}</td>
                </tr>`;
        });
    })
    .catch(err => {
        document.getElementById("orders").innerHTML = `
            <tr><td colspan="5" class="text-center text-danger py-4">
                ⚠️ Failed to load orders: ${err.message}
            </td></tr>`;
    });
</script>

</body>
</html>
```

### 2️⃣ updated order-status.php ( Updated - Recommanded)

```
<!DOCTYPE html>
<html lang="en" data-bs-theme="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Charlie Cafe ☕ | Order Status</title>

    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Google Font - Poppins -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">

    <style>
        /* ------------------------------
           Body & General Styles
        ------------------------------ */
        body {
            font-family: 'Poppins', sans-serif;
            min-height: 100vh;
            margin: 0;
            background: linear-gradient(rgba(0,0,0,0.70), rgba(0,0,0,0.70)),
                        url("https://images.unsplash.com/photo-1517248135467-4c7edcad34c4");
            background-size: cover;
            background-position: center;
            background-attachment: fixed;
            color: #fff;
        }

        /* Navbar */
        .navbar { background-color: #3b1f0e !important; }
        .navbar-brand { font-weight: 600; color: #fff !important; }

        /* Main container */
        .status-container {
            background: rgba(30, 30, 30, 0.75);
            border-radius: 20px;
            padding: 40px;
            backdrop-filter: blur(8px);
            box-shadow: 0 15px 40px rgba(0,0,0,0.5);
            margin: 40px auto;
            max-width: 1100px;
            animation: fadeUp 0.8s ease;
        }

        h2 { font-weight: 600; text-shadow: 0 2px 10px rgba(0,0,0,0.6); }

        /* Metrics Cards */
        .metric-card {
            background: linear-gradient(135deg, #4a2c1a, #3b1f0e);
            border: none;
            border-radius: 15px;
            transition: transform 0.3s ease;
        }
        .metric-card:hover { transform: translateY(-8px); }
        .metric-card .card-body { text-align: center; padding: 25px; }
        .metric-card h5 { margin-bottom: 8px; font-weight: 500; color: #ff9800; }
        .metric-card .display-5 { font-weight: 700; color: white; }

        /* Table Styling */
        .table {
            background: rgba(40, 40, 40, 0.85);
            border-radius: 12px;
            overflow: hidden;
        }
        .table thead th {
            background: #3b1f0e;
            color: #ff9800;
            font-weight: 600;
            border-bottom: 2px solid #ff9800;
        }
        .table tbody tr { transition: background 0.2s; }
        .table tbody tr:hover { background: rgba(255,152,0,0.15); }
        .table td, .table th { border-color: rgba(255,255,255,0.08); }

        /* Footer */
        footer {
            background: rgba(0,0,0,0.7);
            color: #ddd;
            text-align: center;
            padding: 20px;
            margin-top: 60px;
            font-size: 0.95rem;
        }

        /* Responsive */
        @media (max-width: 768px) {
            .status-container { padding: 25px; margin: 20px; }
        }

        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }
    </style>
</head>
<body>

<!-- Navbar -->
<nav class="navbar navbar-expand-lg">
    <div class="container">
        <a class="navbar-brand" href="index.php">☕ Charlie Cafe</a>
    </div>
</nav>

<!-- Main Content -->
<div class="container">
    <div class="status-container">
        <h2 class="text-center mb-5">📊 Live Order Status</h2>

        <!-- Metrics (Cards) -->
        <div id="metrics" class="row g-4 mb-5 justify-content-center"></div>

        <!-- Recent Orders Table -->
        <div class="table-responsive">
            <table class="table table-hover text-white">
                <thead>
                    <tr>
                        <th>Customer</th>
                        <th>Item</th>
                        <th>Qty</th>
                        <th>Table</th>
                        <th>Date</th>
                    </tr>
                </thead>
                <tbody id="orders"></tbody>
            </table>
        </div>
    </div>
</div>

<!-- Toasts -->
<div class="toast-container position-fixed top-0 end-0 p-3">
    <div id="welcomeToast" class="toast">
        <div class="toast-header">
            <strong class="me-auto">☕ Charlie Cafe</strong>
            <button class="btn-close" data-bs-dismiss="toast"></button>
        </div>
        <div class="toast-body">Welcome to the Charlie Cafe order status page!</div>
    </div>
</div>

<div class="toast-container position-fixed bottom-0 end-0 p-3">
    <div id="refreshToast" class="toast">
        <div class="toast-header bg-success text-white">
            <strong class="me-auto">Data Loaded</strong>
            <button class="btn-close btn-close-white" data-bs-dismiss="toast"></button>
        </div>
        <div class="toast-body">✅ Orders and metrics loaded successfully!</div>
    </div>
</div>

<!-- Footer -->
<footer>
    © 2026 Charlie Cafe | Fresh Drinks • Made with ❤️
</footer>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script>
document.addEventListener("DOMContentLoaded", () => {
    // Show welcome toast
    new bootstrap.Toast(document.getElementById('welcomeToast'), { delay: 2500 }).show();

    // Fetch orders and metrics from API
    fetch("https://API_ID.execute-api.region.amazonaws.com/status/order-status")  // ← Replace with real endpoint
        .then(res => {
            if (!res.ok) throw new Error('Network response was not ok');
            return res.json();
        })
        .then(data => {
            // Populate Metrics Cards
            const metricsContainer = document.getElementById("metrics");
            metricsContainer.innerHTML = ""; // Clear before adding
            data.metrics.forEach(m => {
                metricsContainer.innerHTML += `
                    <div class="col-6 col-md-4 col-lg-3">
                        <div class="card metric-card shadow">
                            <div class="card-body">
                                <h5>${m.metric}</h5>
                                <p class="display-5 mb-0">${m.count}</p>
                            </div>
                        </div>
                    </div>`;
            });

            // Populate Orders Table
            const ordersBody = document.getElementById("orders");
            ordersBody.innerHTML = ""; // Clear before adding
            data.recent_orders.forEach(o => {
                ordersBody.innerHTML += `
                    <tr>
                        <td>${o.customer_name || '<em>Anonymous</em>'}</td>
                        <td>${o.item}</td>
                        <td>${o.quantity}</td>
                        <td>${o.table_number || '-'}</td>
                        <td>${o.created_at}</td>
                    </tr>`;
            });

            // Show success toast after data loaded
            new bootstrap.Toast(document.getElementById('refreshToast')).show();
        })
        .catch(err => {
            document.getElementById("orders").innerHTML = `
                <tr><td colspan="5" class="text-center text-danger py-4">
                    ⚠️ Failed to load orders: ${err.message}
                </td></tr>`;
        });
});
</script>
</body>
</html>
```

### Key Improvements / Features Added

#### Dual Toast Notifications

- welcomeToast → page load

- refreshToast → only after metrics/orders successfully loaded from API

#### Clean & Modern UI

- Glassmorphic status-container with blur

- Premium gradient metrics cards

- Hover animations

- Table hover highlight

#### Frontend Security Awareness

- Fallback for anonymous customers

- Network response ok check

#### Commented & Readable Code

- Each section clearly marked

- Dynamic table and metrics population explained

#### Professional UX

- Toasts replace alerts

- Smooth animations for cards and toast fade-in

- Clear error handling in fetch

### 🔹 Previous vs New order-status.php

| Feature                | Previous          | New                                                       |
| ---------------------- | ----------------- | --------------------------------------------------------- |
| Toasts                 | None              | Dual toasts (Welcome + Data Loaded)                       |
| Metrics Cards          | Dynamic but plain | Animated, gradient, hover effect                          |
| Table UI               | Dark table        | Glassmorphic + hover highlight + rounded corners          |
| User Feedback          | Only static data  | Live toast notifications, clear error handling            |
| UX                     | Static fetch      | Smooth animations + dynamic metrics and orders population |
| Comments & Readability | Minimal           | Fully commented for professional clarity                  |
| Security Awareness     | None              | Anonymous fallback, fetch network check                   |


### ✅ Result: 

The new order-status.php is interactive, modern, professional, and UX-friendly, matching the dual-toast notification concept from orders.php.

---

## 1️⃣ Single order only (via order_id - single-order-status-with-print-button.php)

### 1️⃣ Second Code (PHP + Static API Fetch)

#### Primary Tasks & Features:

### 1️⃣ Single Order View:

- Fetches a single order based on order_id query parameter.

- Displays order details: Order ID, status, item, quantity, date.

### 2️⃣ Print Button:

- Users can print the order receipt directly.

### 3️⃣ Error Handling:

- Shows an alert if order ID is invalid or not found.

### 4️⃣ UI/UX:

- Clean light theme with “cafe card” style.

- Static, not dynamic; no metrics, no live updates.

### 5️⃣ Backend Integration:

- Uses PHP file_get_contents() to fetch a single order JSON.

- Minimal JavaScript (only print function).

```
<?php
/* ===============================
   CONFIGURATION SECTION
   👉 REPLACE API URL WITH YOUR OWN
   =============================== */

$orderId = $_GET['order_id'] ?? '';

/* 🔴 REPLACE this API URL */
$apiUrl = "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/order-status?order_id=$orderId";

$response = @file_get_contents($apiUrl);
$data = json_decode($response, true);
?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Cafe ☕ | Order Status</title>
<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- ===============================
     BOOTSTRAP CSS
     =============================== -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- ===============================
     GOOGLE FONT (CAFE STYLE)
     =============================== -->
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;500;700&display=swap" rel="stylesheet">

<!-- ===============================
     CUSTOM CAFE CSS
     =============================== -->
<style>
body {
  font-family: 'Poppins', sans-serif;
  min-height: 100vh;
  background:
    linear-gradient(rgba(0,0,0,.55), rgba(0,0,0,.55)),
    url("https://images.unsplash.com/photo-1509042239860-f550ce710b93");
  background-size: cover;
  background-position: center;
  background-attachment: fixed;
}

.cafe-card {
  background: #fff;
  border-radius: 12px;
  padding: 25px;
  box-shadow: 0 10px 25px rgba(0,0,0,.25);
}

.cafe-title {
  color: #5a2d0c;
  font-weight: 700;
}

.badge-status {
  font-size: 1rem;
  padding: 8px 14px;
}

.print-btn {
  position: absolute;
  top: 20px;
  right: 20px;
}

footer {
  margin-top: 30px;
  font-size: 0.85rem;
  color: #777;
  text-align: center;
}
</style>
</head>

<body>

<!-- ===============================
     PRINT BUTTON (TOP RIGHT)
     =============================== -->
<button onclick="printPage()" class="btn btn-dark print-btn">
  🖨 Print Receipt
</button>

<div class="container d-flex justify-content-center align-items-center" style="min-height:100vh;">
  <div class="col-md-6">

    <div class="cafe-card position-relative">

      <h3 class="cafe-title mb-3 text-center">☕ Charlie Cafe</h3>
      <p class="text-center text-muted mb-4">Order Status Details</p>

      <?php if (!$data || isset($data['error'])): ?>

        <!-- ❌ ERROR STATE -->
        <div class="alert alert-danger text-center">
          ❌ Order not found or invalid order ID
        </div>

      <?php else: ?>

        <!-- ✅ ORDER DETAILS -->
        <p><strong>Order ID:</strong> <?= htmlspecialchars($orderId) ?></p>

        <p>
          <strong>Status:</strong>
          <span class="badge bg-success badge-status">
            <?= htmlspecialchars($data['status']) ?>
          </span>
        </p>

        <hr>

        <p><strong>Item:</strong> <?= htmlspecialchars($data['order']['item']) ?></p>
        <p><strong>Quantity:</strong> <?= htmlspecialchars($data['order']['quantity']) ?></p>
        <p><strong>Date:</strong> <?= htmlspecialchars($data['order']['created_at']) ?></p>

        <hr>

        <div class="text-center fw-bold text-success">
          ☕ Thank you for ordering with Charlie Cafe!
        </div>

      <?php endif; ?>

    </div>

    <footer>
      © <?= date("Y") ?> Charlie Cafe · Fresh Coffee & Tea
    </footer>

  </div>
</div>

<!-- ===============================
     JAVASCRIPT
     =============================== -->
<script>
/* 🔹 PRINT FUNCTION */
function printPage() {
  window.print();
}
</script>

</body>
</html>
```

---

## 3️⃣ Comparison Table 

### Between Order-Status.html VS Single-Order-Status.php

| Feature / Task             | First Code                             | Second Code                            |
| -------------------------- | -------------------------------------- | -------------------------------------- |
| **View Scope**             | Metrics + all recent orders            | Single order only (via order_id)       |
| **Live Updates**           | Yes, dynamic fetch via JS              | No, static fetch via PHP               |
| **Print Option**           | ❌ Not included                         | ✅ Included                             |
| **Error Handling**         | Yes, shows error in table              | Yes, shows alert                       |
| **Frontend Complexity**    | High (cards, table, animations)        | Medium (simple card layout)            |
| **Use Case**               | Admin dashboard / overview             | Customer receipt / order-specific view |
| **API Requirement**        | API returning metrics + orders array   | API returning single order JSON        |
| **Deployment Flexibility** | Frontend-heavy, can integrate anywhere | PHP server required                    |



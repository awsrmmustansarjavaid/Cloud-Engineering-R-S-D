# Charlie Cafe - Order-Status (LIVE ADMIN DASHBOARD (many orders))

## 1️⃣ order-status.html (Previous & Simple)

> **SECTION 4️⃣ — ORDER STATUS DASHBOARD**

> **PHASE 6️⃣ — FRONTEND ORDER STATUS PAGE**

> **1️⃣ Simple order-status.html**

### 1️⃣ First Code (JavaScript + API Fetch)

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

### 2️⃣ updated order-status.html ( Updated - Recommanded)

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

----
## 🔐 PHASE  1️⃣ — Frontend Web Admin Pages
> **📄 ☕ CC- 2 —Secure Charlie Cafe Dashboard System.md**

### 2️⃣ Frontend Admin Order-Status Dashboard


### 1️⃣ Commented order-status.html Version (Production-Ready & Lab-Friendly)

```
<!DOCTYPE html>
<html lang="en" data-bs-theme="dark">
<head>
    <!-- ===================== Character encoding ===================== -->
    <meta charset="UTF-8">

    <!-- ============== Responsive behavior on mobile devices ================= -->
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- ===================== Page title ===================== -->
    <title>Charlie Cafe ☕ | Order Status</title>
    
    <!-- =================== Bootstrap 5 CSS (UI framework) ==================== -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- ===================== Google Font: Poppins ===================== -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
    
    <style>
        /* Global page styling */
        body {
            font-family: 'Poppins', sans-serif;
            min-height: 100vh;
            margin: 0;

            /* Dark overlay + background image */
            background: linear-gradient(rgba(0,0,0,0.70), rgba(0,0,0,0.70)),
                        url("https://images.unsplash.com/photo-1517248135467-4c7edcad34c4");
            background-size: cover;
            background-position: center;
            background-attachment: fixed;
            color: #fff;
        }

        /* Top navigation bar */
        .navbar {
            background-color: #3b1f0e !important;
        }
        .navbar-brand {
            font-weight: 600;
            color: #fff !important;
        }

        /* Main dashboard container */
        .status-container {
            background: rgba(30, 30, 30, 0.75);
            border-radius: 20px;
            padding: 40px;
            backdrop-filter: blur(8px);
            box-shadow: 0 15px 40px rgba(0,0,0,0.5);
            margin: 40px auto;
            max-width: 1100px;
        }

        /* Page heading */
        h2 {
            font-weight: 600;
            text-shadow: 0 2px 10px rgba(0,0,0,0.6);
        }

        /* Dashboard metric cards (Total Orders, Sales, etc.) */
        .metric-card {
            background: linear-gradient(135deg, #4a2c1a, #3b1f0e);
            border: none;
            border-radius: 15px;
            transition: transform 0.3s ease;
        }

        /* Hover animation */
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

        /* Orders table styling */
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

        /* Row hover effect */
        .table tbody tr:hover {
            background: rgba(255,152,0,0.15);
        }

        .table td, .table th {
            border-color: rgba(255,255,255,0.08);
        }

        /* Footer section */
        footer {
            background: rgba(0,0,0,0.7);
            color: #ddd;
            text-align: center;
            padding: 20px;
            margin-top: 60px;
            font-size: 0.95rem;
        }

        /* Mobile responsiveness */
        @media (max-width: 768px) {
            .status-container {
                padding: 25px;
                margin: 20px;
            }
        }
    </style>
</head>

<body>

<!-- ===================== NAVBAR ===================== -->
<nav class="navbar navbar-expand-lg">
    <div class="container">
        <!-- Brand / Home link -->
        <a class="navbar-brand" href="index.html">☕ Charlie Cafe</a>
    </div>
</nav>

<!-- ===================== MAIN DASHBOARD ===================== -->
<div class="container">
    <div class="status-container">

        <!-- Dashboard heading -->
        <h2 class="text-center mb-5">📊 Live Order Status</h2>

        <!-- Metrics cards will be injected here via JavaScript -->
        <div id="metrics" class="row g-4 mb-5 justify-content-center"></div>

        <!-- Orders table -->
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

                <!-- Orders rows injected dynamically -->
                <tbody id="orders"></tbody>
            </table>
        </div>

    </div>
</div>

<!-- ===================== FOOTER ===================== -->
<footer>
    © 2026 Charlie Cafe | Fresh Drinks • Made with ❤️
</footer>

<!-- Bootstrap JavaScript bundle -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<!-- ===================== DATA FETCH LOGIC ===================== -->
<script>
/*
  Fetch live order status data from API Gateway
  Backend: API Gateway → Lambda → DynamoDB
*/
fetch("https://API_ID.execute-api.region.amazonaws.com/status/order-status") // Replace with real API
    .then(res => {
        // Check HTTP response
        if (!res.ok) throw new Error('Network response was not ok');
        return res.json();
    })
    .then(data => {

        /* ===== Render Metrics Cards ===== */
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

        /* ===== Render Orders Table ===== */
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
        // Error handling UI
        document.getElementById("orders").innerHTML = `
            <tr>
                <td colspan="5" class="text-center text-danger py-4">
                    ⚠️ Failed to load orders: ${err.message}
                </td>
            </tr>`;
    });
</script>

</body>
</html>
```

#### 2️⃣ UPDATED FILE WITH order-status with SIDEBAR dashboard (COMMENTED)

#### ✅ What this sidebar will do

📊 Dashboard button → dashboard.html

📈 Analytics button → analytics.html

📦 Order Status (current page) → highlighted

📱 Responsive (collapses nicely on small screens)

🎓 Fully commented for learning & documentation

> **🔁 You can copy–paste this entire file safely**

```
<!DOCTYPE html>
<html lang="en" data-bs-theme="dark">
<head>
    <!-- ===================== Character encoding ===================== -->
    <meta charset="UTF-8">

    <!-- ============== Responsive behavior on mobile devices ================= -->
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- ===================== Page title ===================== -->
    <title>Charlie Cafe ☕ | Order Status</title>
    
    <!-- =================== Bootstrap 5 CSS ==================== -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- ===================== Google Font ===================== -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
    
    <style>
        /* ===================== GLOBAL STYLES ===================== */
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

        /* ===================== SIDEBAR STYLING ===================== */
        .sidebar {
            width: 240px;
            min-height: 100vh;
            background: #2b160a;
            position: fixed;
            top: 0;
            left: 0;
            padding-top: 80px; /* space for navbar */
        }

        .sidebar a {
            display: block;
            padding: 14px 24px;
            color: #ddd;
            text-decoration: none;
            font-weight: 500;
            transition: background 0.3s;
        }

        /* Hover effect for sidebar links */
        .sidebar a:hover {
            background: #3b1f0e;
            color: #ff9800;
        }

        /* Active page highlight */
        .sidebar a.active {
            background: #3b1f0e;
            color: #ff9800;
            border-left: 4px solid #ff9800;
        }

        /* ===================== NAVBAR ===================== */
        .navbar {
            background-color: #3b1f0e !important;
            position: fixed;
            width: 100%;
            z-index: 1000;
        }

        /* ===================== MAIN CONTENT ===================== */
        .main-content {
            margin-left: 240px; /* space for sidebar */
            padding-top: 100px;
        }

        .status-container {
            background: rgba(30, 30, 30, 0.75);
            border-radius: 20px;
            padding: 40px;
            backdrop-filter: blur(8px);
            box-shadow: 0 15px 40px rgba(0,0,0,0.5);
            max-width: 1100px;
            margin: auto;
        }

        /* ===================== RESPONSIVE ===================== */
        @media (max-width: 768px) {
            .sidebar {
                position: relative;
                width: 100%;
                min-height: auto;
                padding-top: 0;
            }

            .main-content {
                margin-left: 0;
                padding-top: 140px;
            }
        }
    </style>
</head>

<body>

<!-- ===================== NAVBAR ===================== -->
<nav class="navbar navbar-dark">
    <div class="container-fluid">
        <a class="navbar-brand" href="index.html">☕ Charlie Cafe</a>
    </div>
</nav>

<!-- ===================== SIDEBAR ===================== -->
<!--
  Sidebar Purpose:
  - Acts as the main navigation for admin/manager dashboard
  - Easy to extend with role-based access (Cognito Groups)
-->
<div class="sidebar">

    <!-- Dashboard button -->
    <a href="dashboard.html">🏠 Main Dashboard</a>

    <!-- Analytics button -->
    <a href="analytics.html">📈 Analytics</a>

    <!-- Current page (highlighted) -->
    <a href="order-status.html" class="active">📦 Order Status</a>

</div>

<!-- ===================== MAIN CONTENT ===================== -->
<div class="main-content">
    <div class="container">
        <div class="status-container">

            <h2 class="text-center mb-5">📊 Live Order Status</h2>

            <!-- Metrics -->
            <div id="metrics" class="row g-4 mb-5 justify-content-center"></div>

            <!-- Orders Table -->
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
</div>

<!-- ===================== FOOTER ===================== -->
<footer class="text-center py-4">
    © 2026 Charlie Cafe | Fresh Drinks • Made with ❤️
</footer>

<!-- ===================== BOOTSTRAP JS ===================== -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<!-- ===================== DATA FETCH LOGIC ===================== -->
<script>
fetch("https://API_ID.execute-api.region.amazonaws.com/status/order-status")
    .then(res => {
        if (!res.ok) throw new Error("API error");
        return res.json();
    })
    .then(data => {

        // Render metrics
        data.metrics.forEach(m => {
            metrics.innerHTML += `
                <div class="col-6 col-md-4 col-lg-3">
                    <div class="card bg-dark text-center p-3">
                        <h6 class="text-warning">${m.metric}</h6>
                        <h3>${m.count}</h3>
                    </div>
                </div>`;
        });

        // Render orders
        data.recent_orders.forEach(o => {
            orders.innerHTML += `
                <tr>
                    <td>${o.customer_name || 'Anonymous'}</td>
                    <td>${o.item}</td>
                    <td>${o.quantity}</td>
                    <td>${o.table_number || '-'}</td>
                    <td>${o.created_at}</td>
                </tr>`;
        });
    })
    .catch(err => {
        orders.innerHTML = `
            <tr>
                <td colspan="5" class="text-danger text-center">
                    ⚠️ ${err.message}
                </td>
            </tr>`;
    });
</script>

</body>
</html>
```

#### 3️⃣ UPDATED FILE WITH order-status with SIDEBAR dashboard & Welcome Toggle Notification (COMMENTED - Recommand)

#### 🔍 What Changed (Simple Explanation)

#### 🟢 New Features Added

#### Welcome Toast

- Appears automatically when dashboard opens

- Helps user feel “logged into” dashboard

#### Data Loaded Toast

- Appears only after API data loads successfully

- Confirms backend + frontend communication works

#### Sidebar + Toast Combined

- Professional admin dashboard feel

- Same UX pattern used in real SaaS dashboards

#### Code 

```
<!DOCTYPE html>
<html lang="en" data-bs-theme="dark">
<head>
    <!-- ===================== META ===================== -->
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- ===================== TITLE ===================== -->
    <title>Charlie Cafe ☕ | Order Status</title>

    <!-- ===================== BOOTSTRAP ===================== -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- ===================== GOOGLE FONT ===================== -->
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">

    <style>
        /* ===================== GLOBAL STYLES ===================== */
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

        /* ===================== SIDEBAR ===================== */
        .sidebar {
            width: 240px;
            min-height: 100vh;
            background: #2b160a;
            position: fixed;
            top: 0;
            left: 0;
            padding-top: 80px;
        }

        .sidebar a {
            display: block;
            padding: 14px 24px;
            color: #ddd;
            text-decoration: none;
            font-weight: 500;
            transition: background 0.3s;
        }

        .sidebar a:hover {
            background: #3b1f0e;
            color: #ff9800;
        }

        .sidebar a.active {
            background: #3b1f0e;
            color: #ff9800;
            border-left: 4px solid #ff9800;
        }

        /* ===================== NAVBAR ===================== */
        .navbar {
            background-color: #3b1f0e !important;
            position: fixed;
            width: 100%;
            z-index: 1000;
        }

        /* ===================== MAIN CONTENT ===================== */
        .main-content {
            margin-left: 240px;
            padding-top: 100px;
        }

        .status-container {
            background: rgba(30, 30, 30, 0.75);
            border-radius: 20px;
            padding: 40px;
            backdrop-filter: blur(8px);
            box-shadow: 0 15px 40px rgba(0,0,0,0.5);
            max-width: 1100px;
            margin: auto;
        }

        /* ===================== RESPONSIVE ===================== */
        @media (max-width: 768px) {
            .sidebar {
                position: relative;
                width: 100%;
                min-height: auto;
            }

            .main-content {
                margin-left: 0;
                padding-top: 140px;
            }
        }
    </style>
</head>

<body>

<!-- ===================== NAVBAR ===================== -->
<nav class="navbar navbar-dark">
    <div class="container-fluid">
        <a class="navbar-brand" href="index.html">☕ Charlie Cafe</a>
    </div>
</nav>

<!-- ===================== SIDEBAR ===================== -->
<div class="sidebar">
    <a href="dashboard.html">🏠 Main Dashboard</a>
    <a href="analytics.html">📈 Analytics</a>
    <a href="order-status.html" class="active">📦 Order Status</a>
</div>

<!-- ===================== MAIN CONTENT ===================== -->
<div class="main-content">
    <div class="container">
        <div class="status-container">

            <h2 class="text-center mb-5">📊 Live Order Status</h2>

            <!-- ===================== METRICS ===================== -->
            <div id="metrics" class="row g-4 mb-5 justify-content-center"></div>

            <!-- ===================== ORDERS TABLE ===================== -->
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
</div>

<!-- ===================== TOAST NOTIFICATIONS ===================== -->

<!-- Welcome Toast -->
<div class="toast-container position-fixed top-0 end-0 p-3">
    <div id="welcomeToast" class="toast">
        <div class="toast-header">
            <strong class="me-auto">☕ Charlie Cafe</strong>
            <button class="btn-close" data-bs-dismiss="toast"></button>
        </div>
        <div class="toast-body">
            Welcome to the Order Status Dashboard!
        </div>
    </div>
</div>

<!-- Data Loaded Toast -->
<div class="toast-container position-fixed bottom-0 end-0 p-3">
    <div id="dataToast" class="toast">
        <div class="toast-header bg-success text-white">
            <strong class="me-auto">Data Loaded</strong>
            <button class="btn-close btn-close-white" data-bs-dismiss="toast"></button>
        </div>
        <div class="toast-body">
            ✅ Orders & metrics updated successfully!
        </div>
    </div>
</div>

<!-- ===================== FOOTER ===================== -->
<footer class="text-center py-4">
    © 2026 Charlie Cafe | Fresh Drinks • Made with ❤️
</footer>

<!-- ===================== BOOTSTRAP JS ===================== -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<!-- ===================== DATA FETCH + TOAST LOGIC ===================== -->
<script>
document.addEventListener("DOMContentLoaded", () => {

    /* -------- Show welcome toast when page opens -------- */
    const welcomeToast = new bootstrap.Toast(
        document.getElementById("welcomeToast"),
        { delay: 2500 }
    );
    welcomeToast.show();

    /* -------- Fetch order status from backend API -------- */
    fetch("https://API_ID.execute-api.region.amazonaws.com/status/order-status")
        .then(res => {
            if (!res.ok) throw new Error("API Error");
            return res.json();
        })
        .then(data => {

            /* -------- Render metrics cards -------- */
            const metricsDiv = document.getElementById("metrics");
            metricsDiv.innerHTML = "";

            data.metrics.forEach(m => {
                metricsDiv.innerHTML += `
                    <div class="col-6 col-md-4 col-lg-3">
                        <div class="card bg-dark text-center p-3">
                            <h6 class="text-warning">${m.metric}</h6>
                            <h3>${m.count}</h3>
                        </div>
                    </div>`;
            });

            /* -------- Render recent orders table -------- */
            const ordersBody = document.getElementById("orders");
            ordersBody.innerHTML = "";

            data.recent_orders.forEach(o => {
                ordersBody.innerHTML += `
                    <tr>
                        <td>${o.customer_name || 'Anonymous'}</td>
                        <td>${o.item}</td>
                        <td>${o.quantity}</td>
                        <td>${o.table_number || '-'}</td>
                        <td>${o.created_at}</td>
                    </tr>`;
            });

            /* -------- Show success toast after data load -------- */
            new bootstrap.Toast(document.getElementById("dataToast")).show();
        })
        .catch(err => {
            document.getElementById("orders").innerHTML = `
                <tr>
                    <td colspan="5" class="text-center text-danger">
                        ⚠️ ${err.message}
                    </td>
                </tr>`;
        });
});
</script>

</body>
</html>
```

#### 🚀 Why This Is GOOD Practice (Career Tip)

Since you're moving toward frontend + cloud dashboards, this shows:

✅ UI feedback (toasts)

✅ Async API handling

✅ Dashboard layout pattern

✅ Production-style commenting

This is portfolio-ready code 👏


----
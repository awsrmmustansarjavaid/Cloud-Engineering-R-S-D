# Charlie Cafe - Order-Status (LIVE ADMIN DASHBOARD (many orders))

# SECTION 1️⃣  Latest Updated Advance order-status.html

[order-status.html](./order-status.html)

---
# SECTION 2️⃣  Previous Versions order-status.html

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

---
#### 2️⃣ Code order-status.html

👉 Copy-paste this FULL file

👉 Replace ONLY the values marked with 🔁 REPLACE

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Cafe ☕ | Order Status</title>
<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- Bootstrap -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
body {
  min-height: 100vh;
  background:
    linear-gradient(rgba(0,0,0,.55), rgba(0,0,0,.55)),
    url("https://images.unsplash.com/photo-1509042239860-f550ce710b93");
  background-size: cover;
  background-position: center;
  background-attachment: fixed;
}

#dashboard {
  display: none;
  background:#f5f5f5;
  padding: 20px;
  border-radius: 8px;
}

.card-metric {
  background:#fff;
  padding:15px;
  border-radius:8px;
  box-shadow:0 2px 6px rgba(0,0,0,.1);
}
</style>
</head>

<body>

<!-- NAVBAR -->
<nav class="navbar navbar-dark bg-dark" id="navbar" style="display:none">
  <div class="container">
    <span class="navbar-brand">☕ Charlie Cafe Admin</span>
    <button class="btn btn-danger btn-sm" onclick="logout()">Logout</button>
  </div>
</nav>

<!-- DASHBOARD -->
<div class="container my-4" id="dashboard">

<div class="row mb-3">
  <div class="col-md-3">
    <input type="date" id="filterDate" class="form-control">
  </div>
  <div class="col-md-2">
    <button class="btn btn-primary w-100" onclick="loadData()">Filter</button>
  </div>
</div>

<div class="text-center my-3" id="loader" style="display:none">
  <div class="spinner-border text-warning"></div>
  <p class="mt-2">Loading...</p>
</div>

<div class="row mb-4" id="metrics"></div>

<canvas id="orderChart" height="100"></canvas>

<table class="table table-bordered mt-4 bg-white">
  <thead class="table-dark">
    <tr>
      <th>Customer</th>
      <th>Item</th>
      <th>Qty</th>
      <th>Date</th>
    </tr>
  </thead>
  <tbody id="orders"></tbody>
</table>

</div>

<script>
/* ================== CONFIG ================== */

/* ✅ Cognito Hosted UI domain (WITHOUT https://) */
const COGNITO_DOMAIN = "us-east-1qxbqjnjww.auth.us-east-1.amazoncognito.com";

/* ✅ App Client ID from Cognito → App integration → App clients */
const CLIENT_ID = "393ld7o96bt7qlv0shp124osh5";

/* 🔁 CloudFront URL — MUST exactly match Cognito callback */
const REDIRECT_URI =
  "https://d2og2zrs47voou.cloudfront.net/order-status.html";

/* 🔁 Replace later when API Gateway is ready */
const API_URL =
  "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/order-status";

let chart, refreshTimer;



/* ================== AUTH ================== */

// Decode JWT
function parseJwt(token) {
  return JSON.parse(atob(token.split('.')[1]));
}

function isTokenExpired(token) {
  return parseJwt(token).exp * 1000 < Date.now();
}

// Redirect to Cognito login
function login() {
  const loginUrl =
    `https://${COGNITO_DOMAIN}/login` +
    `?response_type=token` +
    `&client_id=${CLIENT_ID}` +
    `&scope=openid+email+profile` +
    `&redirect_uri=${encodeURIComponent(REDIRECT_URI)}`;

  window.location.href = loginUrl;
}

// Logout
function logout() {
  localStorage.removeItem("access_token");
  clearInterval(refreshTimer);

  const logoutUrl =
    `https://${COGNITO_DOMAIN}/logout` +
    `?client_id=${CLIENT_ID}` +
    `&logout_uri=${encodeURIComponent(REDIRECT_URI)}`;

  window.location.href = logoutUrl;
}

// Handle redirect from Cognito
function handleRedirect() {
  const hash = window.location.hash.substring(1);
  if (!hash) return;

  const params = new URLSearchParams(hash);
  const accessToken = params.get("access_token");

  if (accessToken) {
    localStorage.setItem("access_token", accessToken);
    window.location.hash = "";
  }
}

/* ================== DASHBOARD ================== */
function showDashboard() {
  const token = localStorage.getItem("access_token");

  if (!token || isTokenExpired(token)) {
    login();
    return;
  }

  document.getElementById("navbar").style.display = "block";
  document.getElementById("dashboard").style.display = "block";

  loadData();
  refreshTimer = setInterval(loadData, 10000);
}

/* ================== DATA ================== */
function loadData() {
  const token = localStorage.getItem("access_token");
  if (!token || isTokenExpired(token)) return logout();

  document.getElementById("loader").style.display = "block";
  document.getElementById("metrics").innerHTML = "";
  document.getElementById("orders").innerHTML = "";

  let url = API_URL;
  const filterDate = document.getElementById("filterDate").value;
  if (filterDate) url += "?date=" + filterDate;

  fetch(url, {
    headers: {
      Authorization: "Bearer " + token
    }
  })
  .then(res => {
    if (res.status === 401) logout();
    return res.json();
  })
  .then(data => {
    document.getElementById("loader").style.display = "none";

    data.metrics.forEach(m => {
      document.getElementById("metrics").innerHTML += `
        <div class="col-md-3 mb-2">
          <div class="card-metric text-center fw-bold">
            ${m.metric}<br>${m.count}
          </div>
        </div>`;
    });

    const items = {};
    data.recent_orders.forEach(o => {
      document.getElementById("orders").innerHTML += `
        <tr>
          <td>${o.customer_name}</td>
          <td>${o.item}</td>
          <td>${o.quantity}</td>
          <td>${o.created_at}</td>
        </tr>`;
      items[o.item] = (items[o.item] || 0) + o.quantity;
    });

    if (chart) chart.destroy();
    chart = new Chart(document.getElementById("orderChart"), {
      type: 'bar',
      data: {
        labels: Object.keys(items),
        datasets: [{
          label: 'Orders per Item',
          data: Object.values(items),
          backgroundColor: 'rgba(255, 152, 0, 0.7)'
        }]
      }
    });
  });
}

/* ================== INIT ================== */
handleRedirect();
showDashboard();
</script>

</body>
</html>
```
#### 7️⃣ Final REQUIRED changes in your order-status.html

#### 1️⃣ Replace these with your real values:

```
/* ================== CONFIG ================== */

/* ✅ Cognito Hosted UI domain (WITHOUT https://) */
const COGNITO_DOMAIN = "us-east-1qxbqjnjww.auth.us-east-1.amazoncognito.com";

/* ✅ App Client ID from Cognito → App integration → App clients */
const CLIENT_ID = "393ld7o96bt7qlv0shp124osh5";

/* 🔁 CloudFront URL — MUST exactly match Cognito callback */
const REDIRECT_URI =
  "https://d2og2zrs47voou.cloudfront.net/order-status.html";

/* 🔁 Replace later when API Gateway is ready */
const API_URL =
  "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/order-status";

let chart, refreshTimer;
```

⚠️ DO NOT change anything else in the file

⚠️ DO NOT add trailing slash

⚠️ http vs https must match Cognito exactly

Your HTML + JS logic is already correct and production-grade ✅

Save file.

**✅ Page now captures Cognito token**

#### ✅ FINAL CHECKLIST

✔ Cognito App Client

- Implicit grant enabled

- Callback URL = ALB/order-status.html

- Logout URL = ALB/order-status.html

✔ ALB

- HTTPS listener (443)

✔ API Gateway

- Cognito Authorizer

- Uses Access Token

✔ Browser

- No old token in localStorage (clear once)


----
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

## 🔐 2️⃣ — DEPLOY FINAL FRONTEND Cognito Protection (WRITE ONCE ✅)

### 1️⃣ ✅ Updated order-status.html (Cognito-secured)

Below is your UPDATED order-status.html with:

✅ Page hidden until Cognito auth

✅ protectPage() enforced

✅ authFetch() replacing insecure fetch()

✅ JWT automatically sent to API Gateway

✅ Clean comments (lab / interview ready)

✅ Works behind CloudFront + ALB + HTTP/2

#### Code

```
<!DOCTYPE html>
<html lang="en" data-bs-theme="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
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
            display: none; /* 🔐 Hidden until Cognito auth passes */
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
            max-width: 1100px;
            margin: auto;
        }

        @media (max-width: 768px) {
            .sidebar {
                position: relative;
                width: 100%;
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

            <!-- KPI Metrics -->
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

<!-- =================================================
     🔐 AUTHENTICATION LAYER (Cognito)
     ================================================= -->

<!-- 1️⃣ Central authentication logic -->
<script src="assets/auth.js"></script>

<script>
/* =================================================
   PAGE PROTECTION
   - Redirects to Cognito Hosted UI if user not logged in
   - Validates JWT
   - Shows page only after success
   ================================================= */
protectPage();

/* =================================================
   SECURE DATA FETCH
   - authFetch() automatically attaches JWT
   - API Gateway protected by Cognito Authorizer
   ================================================= */
authFetch("https://API_ID.execute-api.region.amazonaws.com/status/order-status")
    .then(res => {
        if (!res.ok) throw new Error("API error");
        return res.json();
    })
    .then(data => {

        // Render KPI metrics
        data.metrics.forEach(m => {
            metrics.innerHTML += `
                <div class="col-6 col-md-4 col-lg-3">
                    <div class="card bg-dark text-center p-3">
                        <h6 class="text-warning">${m.metric}</h6>
                        <h3>${m.count}</h3>
                    </div>
                </div>`;
        });

        // Render recent orders
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

#### ✅ What This Page Now Demonstrates (Interview-Level)

✔ Zero unauthenticated access

✔ JWT → API Gateway → Lambda (real production flow)

✔ Same auth.js reused (clean architecture)

✔ Ready for Admin / Manager Cognito Groups

✔ CloudFront + ALB compatible


###  2️⃣ ✅ UPDATED order-status.html (SECURE-READY - Recommanded)

✅ Secure container wrapper

✅ Central auth layer (secure-dashboard.js)

✅ Page hidden until Cognito auth succeeds

✅ No auth logic duplicated

✅ Clear comments showing ONLY what was added/changed

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

<!-- =================================================
     🔐 SECURE ORDER STATUS CONTAINER
     Everything inside this div will:
     ✅ stay hidden until Cognito auth succeeds
     ✅ become visible after protectPage()
     (controlled by secure-dashboard.js)
================================================= -->
<div id="dashboard-container">

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

    <hr class="text-secondary">

    <!-- 🔐 SECURE LOGOUT
         secure-dashboard.js attaches Cognito logout -->
    <a class="logout-btn" style="cursor:pointer">🚪 Logout</a>
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

</div>
<!-- 🔐 END SECURE ORDER STATUS CONTAINER -->

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

<!-- =================================================
     🔐 CENTRAL AUTH & SECURITY LAYER
     This ONE file enables:
     ✅ Page hidden until auth success
     ✅ auth.js auto-loaded
     ✅ protectPage()
     ✅ authFetch()
     ✅ Cognito logout
================================================= -->
<script src="secure-dashboard.js"></script>

</body>
</html>
```

#### ✅ FINAL STATE OF YOUR PROJECT (IMPORTANT)

You now have ALL THREE ADMIN PAGES using:

✔ One central security layer

✔ One Cognito auth system

✔ One logout mechanism

✔ Zero duplicated auth code

✔ Clean, scalable architecture

This is exactly how real production admin panels are built.

---

last old 28-1-2026

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

<!-- =================================================
     🔐 SECURE ORDER STATUS CONTAINER
     Everything inside this div will:
     ✅ stay hidden until Cognito auth succeeds
     ✅ become visible after protectPage()
     (controlled by secure-dashboard.js)
================================================= -->
<div id="dashboard-container">

<!-- ===================== NAVBAR ===================== -->
<nav class="navbar navbar-dark">
    <div class="container-fluid">
        <a class="navbar-brand" href="index.php">☕ Charlie Cafe</a>
    </div>
</nav>

<!-- ===================== SIDEBAR ===================== -->
<div class="sidebar">
    <a href="dashboard.html">🏠 Main Dashboard</a>
    <a href="analytics.html">📈 Analytics</a>
    <a href="order-status.html" class="active">📦 Order Status</a>

    <hr class="text-secondary">

    <!-- 🔐 SECURE LOGOUT
         secure-dashboard.js attaches Cognito logout -->
    <a class="logout-btn" style="cursor:pointer">🚪 Logout</a>
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

</div>
<!-- 🔐 END SECURE ORDER STATUS CONTAINER -->

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

<!-- =================================================
     🔐 CENTRAL AUTH & SECURITY LAYER
     This ONE file enables:
     ✅ Page hidden until auth success
     ✅ auth.js auto-loaded
     ✅ protectPage()
     ✅ authFetch()
     ✅ Cognito logout
================================================= -->
<script src="secure-dashboard.js"></script>

</body>
</html>
```



last updated


```
<!DOCTYPE html>
<html lang="en" data-bs-theme="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Charlie Cafe ☕ | Order Status</title>

    <!-- BOOTSTRAP -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- GOOGLE FONT -->
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
        }

        .sidebar a.active {
            background: #3b1f0e;
            color: #ff9800;
            border-left: 4px solid #ff9800;
        }

        .navbar {
            background-color: #3b1f0e !important;
            position: fixed;
            width: 100%;
            z-index: 1000;
        }

        .main-content {
            margin-left: 240px;
            padding-top: 100px;
        }

        .status-container {
            background: rgba(30, 30, 30, 0.75);
            border-radius: 20px;
            padding: 40px;
            max-width: 1100px;
            margin: auto;
        }
    </style>
</head>

<body style="display:none">

<div id="dashboard-container">

<nav class="navbar navbar-dark">
    <div class="container-fluid">
        <a class="navbar-brand" href="index.php">☕ Charlie Cafe</a>
    </div>
</nav>

<div class="sidebar">
    <a href="dashboard.html">🏠 Main Dashboard</a>
    <a href="analytics.html">📈 Analytics</a>
    <a href="order-status.html" class="active">📦 Order Status</a>
    <hr class="text-secondary">
    <a class="logout-btn" style="cursor:pointer">🚪 Logout</a>
</div>

<div class="main-content">
    <div class="container">
        <div class="status-container">

            <h2 class="text-center mb-5">📊 Live Order Status</h2>

            <div id="metrics" class="row g-4 mb-5 justify-content-center"></div>

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

</div>

<!-- BOOTSTRAP JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<!-- 🔐 CENTRAL AUTH (REQUIRED) -->
<script src="/js/central-auth-api.js"></script>

<script>
/* ================= PROTECT PAGE ================= */
CHARLIE.auth.protectPage();

/* ================= LOGOUT ================= */
document.querySelector(".logout-btn").onclick = () => {
    CHARLIE.auth.logout();
};

/* ================= FETCH DATA ================= */
document.addEventListener("DOMContentLoaded", () => {

    CHARLIE.authFetch(
        `${CHARLIE.CONFIG.API_BASE}/order-status`
    )
    .then(res => {
        if (!res.ok) throw new Error("Failed to fetch");
        return res.json();
    })
    .then(data => {

        const metricsDiv = document.getElementById("metrics");
        const ordersBody = document.getElementById("orders");

        metricsDiv.innerHTML = "";
        ordersBody.innerHTML = "";

        data.metrics.forEach(m => {
            metricsDiv.innerHTML += `
                <div class="col-6 col-md-3">
                    <div class="card bg-dark text-center p-3">
                        <h6 class="text-warning">${m.metric}</h6>
                        <h3>${m.count}</h3>
                    </div>
                </div>`;
        });

        data.recent_orders.forEach(o => {
            ordersBody.innerHTML += `
                <tr>
                    <td>${o.customer_name || "Anonymous"}</td>
                    <td>${o.item}</td>
                    <td>${o.quantity}</td>
                    <td>${o.table_number || "-"}</td>
                    <td>${o.created_at}</td>
                </tr>`;
        });
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

---

### Updated Order-Status.html

> **Update Version : 5.0**


```
<!DOCTYPE html>
<html lang="en" data-bs-theme="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Charlie Cafe ☕ | Order Status</title>

    <!-- ================= BOOTSTRAP ================= -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- ================= GOOGLE FONT ================= -->
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
        }

        .sidebar a.active {
            background: #3b1f0e;
            color: #ff9800;
            border-left: 4px solid #ff9800;
        }

        .navbar {
            background-color: #3b1f0e !important;
            position: fixed;
            width: 100%;
            z-index: 1000;
        }

        .main-content {
            margin-left: 240px;
            padding-top: 100px;
        }

        .status-container {
            background: rgba(30, 30, 30, 0.75);
            border-radius: 20px;
            padding: 40px;
            max-width: 1100px;
            margin: auto;
        }
    </style>
</head>

<body style="display:none">

<div id="dashboard-container">

<!-- ================= NAVBAR ================= -->
<nav class="navbar navbar-dark">
    <div class="container-fluid">
        <a class="navbar-brand" href="index.php">☕ Charlie Cafe</a>
    </div>
</nav>

<!-- ================= SIDEBAR ================= -->
<div class="sidebar">
    <a href="dashboard.html">🏠 Main Dashboard</a>
    <a href="analytics.html">📈 Analytics</a>
    <a href="order-status.html" class="active">📦 Order Status</a>
    <hr class="text-secondary">
    <a class="logout-btn" style="cursor:pointer">🚪 Logout</a>
</div>

<!-- ================= MAIN CONTENT ================= -->
<div class="main-content">
    <div class="container">
        <div class="status-container">

            <h2 class="text-center mb-4">📊 Live Order Status</h2>

            <!-- ================= CSV EXPORT BUTTON ================= -->
            <div class="d-flex justify-content-end mb-4">
                <button class="btn btn-success" onclick="exportCSV()">
                    ⬇ Export CSV
                </button>
            </div>

            <!-- ================= METRICS ================= -->
            <div id="metrics" class="row g-4 mb-5 justify-content-center"></div>

            <!-- ================= ORDERS TABLE ================= -->
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

</div>

<!-- ================= BOOTSTRAP JS ================= -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<!-- ================= CENTRAL AUTH (REQUIRED) ================= -->
<script src="/js/central-auth-api.js"></script>

<script>
/* =========================================================
   PROTECT PAGE — redirect to login if not authenticated
   ========================================================= */
CHARLIE.auth.protectPage();

/* =========================================================
   LOGOUT HANDLER
   ========================================================= */
document.querySelector(".logout-btn").onclick = () => {
    CHARLIE.auth.logout();
};

/* =========================================================
   FETCH DASHBOARD DATA (METRICS + ORDERS)
   ========================================================= */
document.addEventListener("DOMContentLoaded", () => {

    CHARLIE.authFetch(
        `${CHARLIE.CONFIG.API_BASE}/order-status`
    )
    .then(res => {
        if (!res.ok) throw new Error("Failed to fetch order status");
        return res.json();
    })
    .then(data => {

        const metricsDiv = document.getElementById("metrics");
        const ordersBody = document.getElementById("orders");

        metricsDiv.innerHTML = "";
        ordersBody.innerHTML = "";

        // Render metrics cards
        data.metrics.forEach(m => {
            metricsDiv.innerHTML += `
                <div class="col-6 col-md-3">
                    <div class="card bg-dark text-center p-3">
                        <h6 class="text-warning">${m.metric}</h6>
                        <h3>${m.count}</h3>
                    </div>
                </div>`;
        });

        // Render recent orders
        data.recent_orders.forEach(o => {
            ordersBody.innerHTML += `
                <tr>
                    <td>${o.customer_name || "Anonymous"}</td>
                    <td>${o.item}</td>
                    <td>${o.quantity}</td>
                    <td>${o.table_number || "-"}</td>
                    <td>${o.created_at}</td>
                </tr>`;
        });
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

/* =========================================================
   CSV EXPORT FUNCTION (ADMIN ONLY)
   ========================================================= */
function exportCSV() {

    // Build API URL with export flag
    const url = `${CHARLIE.CONFIG.API_BASE}/order-status?export=true`;

    // Use authenticated fetch (adds Bearer token automatically)
    CHARLIE.authFetch(url)
        .then(res => {
            if (!res.ok) {
                throw new Error("CSV export failed");
            }
            return res.blob(); // CSV file comes as a blob
        })
        .then(blob => {
            // Create temporary download link
            const link = document.createElement("a");
            link.href = window.URL.createObjectURL(blob);
            link.download = "orders.csv";

            // Trigger download
            document.body.appendChild(link);
            link.click();

            // Cleanup
            document.body.removeChild(link);
        })
        .catch(err => {
            alert("❌ " + err.message);
            console.error(err);
        });
}
</script>

</body>
</html>
```

----
### Updated Order-Status.html

> **Update Version: 5.1**

Bootstrap fully responsive, background cafe image

Cafe-related icons everywhere (metrics, buttons, sidebar, live order status)

Transparent buttons with matching cafe icons

Sidebar icons updated to match cafe theme

Clear comments throughout for easy modification

```
<!DOCTYPE html>
<html lang="en" data-bs-theme="dark">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Charlie Cafe ☕ | Order Status</title>

<!-- ================= BOOTSTRAP ================= -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- ================= GOOGLE FONT ================= -->
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">

<!-- ================= BOOTSTRAP ICONS ================= -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">

<style>
/* ================= BODY + BACKGROUND ================= */
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

/* ================= SIDEBAR ================= */
.sidebar {
    width: 240px;
    min-height: 100vh;
    background: #2b160a;
    position: fixed;
    top: 0;
    left: 0;
    padding-top: 80px;
    z-index: 1000;
}
.sidebar a {
    display: flex;
    align-items: center;
    padding: 14px 24px;
    color: #ddd;
    text-decoration: none;
    font-weight: 500;
}
.sidebar a i {
    margin-right: 10px;
    font-size: 1.2rem;
    color: #ff9800;
}
.sidebar a.active {
    background: #3b1f0e;
    color: #fff;
    border-left: 4px solid #ff9800;
}
.sidebar a.logout-btn i {
    color: #ff4d4d;
}

/* ================= NAVBAR ================= */
.navbar {
    background-color: rgba(59, 31, 14, 0.9) !important;
    position: fixed;
    width: 100%;
    z-index: 1100;
}
.navbar .navbar-brand {
    font-weight: bold;
    color: #ff9800 !important;
}

/* ================= MAIN CONTENT ================= */
.main-content {
    margin-left: 240px;
    padding-top: 100px;
    padding-bottom: 50px;
}

/* ================= STATUS CONTAINER ================= */
.status-container {
    background: rgba(30, 30, 30, 0.85);
    border-radius: 20px;
    padding: 40px;
    max-width: 1100px;
    margin: auto;
}

/* ================= METRICS CARDS ================= */
.card-metric {
    background: rgba(59, 31, 14, 0.85);
    border-radius: 15px;
    padding: 20px;
    text-align: center;
    transition: transform 0.2s;
}
.card-metric:hover {
    transform: scale(1.05);
}
.card-metric h6 {
    color: #ff9800;
}

/* ================= BUTTONS ================= */
.btn-transparent {
    background: rgba(255,255,255,0.1);
    border: 1px solid #ff9800;
    color: #ff9800;
    display: flex;
    align-items: center;
}
.btn-transparent i {
    margin-right: 8px;
}

/* ================= TABLE ================= */
.table th, .table td {
    vertical-align: middle;
}
.table-hover tbody tr:hover {
    background-color: rgba(255, 152, 0, 0.2);
}

/* ================= RESPONSIVE ================= */
@media (max-width:768px){
    .main-content { margin-left: 0; padding-top: 120px; }
    .sidebar { width: 100%; height: auto; position: relative; padding-top: 20px;}
}
</style>
</head>

<body style="display:none">

<div id="dashboard-container">

<!-- ================= NAVBAR ================= -->
<nav class="navbar navbar-dark">
    <div class="container-fluid">
        <a class="navbar-brand" href="index.php">☕ Charlie Cafe</a>
    </div>
</nav>

<!-- ================= SIDEBAR ================= -->
<div class="sidebar">
    <a href="dashboard.html"><i class="bi bi-house-door-fill"></i> Main Dashboard</a>
    <a href="analytics.html"><i class="bi bi-graph-up-arrow"></i> Analytics</a>
    <a href="order-status.html" class="active"><i class="bi bi-cup-fill"></i> Live Orders</a>
    <hr class="text-secondary">
    <a class="logout-btn" style="cursor:pointer"><i class="bi bi-door-open-fill"></i> Logout</a>
</div>

<!-- ================= MAIN CONTENT ================= -->
<div class="main-content">
    <div class="container">
        <div class="status-container">

            <h2 class="text-center mb-4"><i class="bi bi-cup-straw"></i> Live Order Status</h2>

            <!-- ================= CSV EXPORT BUTTON ================= -->
            <div class="d-flex justify-content-end mb-4">
                <button class="btn btn-transparent" onclick="exportCSV()">
                    <i class="bi bi-download"></i> Export CSV
                </button>
            </div>

            <!-- ================= METRICS ================= -->
            <div id="metrics" class="row g-4 mb-5 justify-content-center"></div>

            <!-- ================= ORDERS TABLE ================= -->
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

</div>

<!-- ================= BOOTSTRAP JS ================= -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<!-- ================= CENTRAL AUTH (REQUIRED) ================= -->
<script src="/js/central-auth-api.js"></script>

<script>
/* =========================================================
   PROTECT PAGE — redirect to login if not authenticated
   ========================================================= */
CHARLIE.auth.protectPage();

/* =========================================================
   LOGOUT HANDLER
   ========================================================= */
document.querySelector(".logout-btn").onclick = () => {
    CHARLIE.auth.logout();
};

/* =========================================================
   FETCH DASHBOARD DATA (METRICS + ORDERS)
   ========================================================= */
document.addEventListener("DOMContentLoaded", () => {

    CHARLIE.authFetch(`${CHARLIE.CONFIG.API_BASE}/order-status`)
    .then(res => {
        if (!res.ok) throw new Error("Failed to fetch order status");
        return res.json();
    })
    .then(data => {

        const metricsDiv = document.getElementById("metrics");
        const ordersBody = document.getElementById("orders");

        metricsDiv.innerHTML = "";
        ordersBody.innerHTML = "";

        // Render metrics cards with cafe icon
        data.metrics.forEach(m => {
            metricsDiv.innerHTML += `
                <div class="col-6 col-md-3">
                    <div class="card-metric">
                        <i class="bi bi-cup-straw-fill fs-3 mb-2"></i>
                        <h6>${m.metric}</h6>
                        <h3>${m.count}</h3>
                    </div>
                </div>`;
        });

        // Render recent orders
        data.recent_orders.forEach(o => {
            ordersBody.innerHTML += `
                <tr>
                    <td>${o.customer_name || "Anonymous"}</td>
                    <td>${o.item}</td>
                    <td>${o.quantity}</td>
                    <td>${o.table_number || "-"}</td>
                    <td>${o.created_at}</td>
                </tr>`;
        });
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

/* =========================================================
   CSV EXPORT FUNCTION (ADMIN ONLY)
   ========================================================= */
function exportCSV() {
    const url = `${CHARLIE.CONFIG.API_BASE}/order-status?export=true`;
    CHARLIE.authFetch(url)
        .then(res => {
            if (!res.ok) throw new Error("CSV export failed");
            return res.blob();
        })
        .then(blob => {
            const link = document.createElement("a");
            link.href = window.URL.createObjectURL(blob);
            link.download = "orders.csv";
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        })
        .catch(err => {
            alert("❌ " + err.message);
            console.error(err);
        });
}
</script>

</body>
</html>
```
---





# AWS  ☕ Charlie Cafe — Secure Charlie Cafe Dashboard System

### READ Me About

[☕ CC- 2 —Secure Charlie Cafe Dashboard System.md](./☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20Readme(Doc)/☕CC-%202%20—Secure%20Charlie%20Cafe%20Dashboard%20System.md)

### Goal: Production-ready Admin Dashboard

#### Secure, auto-refreshing, printable, Cognito-protected



# SECTION 2️⃣ Secure Admin Order Dashboard


## 🔐 PHASE  1️⃣ — PREREQUISITES (CHECK ONLY)



### 1️⃣ Frontend dashboard 
> **📄 File: dashboard.html**

#### 1️⃣ Create dashboard.html

```
sudo nano /var/www/html/dashboard.html
```

#### 2️⃣ Paste Code

#### ✅ Frontend-only dashboard

❌ NO backend calls

❌ NO Cognito yet

🎨 Just layout + cafe branding

☕ Charlie Cafe (Drinks Cafe, not food)

🧪 Easy to test UI first

🔜 Later → we will plug Cognito + APIs + PDF

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Cafe ☕ | Admin Dashboard</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- ================= BOOTSTRAP ================= -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- ================= ICONS ================= -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">

<style>
/* =================================================
   GLOBAL THEME (DARK CAFE STYLE)
   ================================================= */
body {
    background-color: #0f0f10;
    color: #ffffff;
    font-family: 'Segoe UI', sans-serif;
}

/* =================================================
   SIDEBAR
   ================================================= */
.sidebar {
    width: 250px;
    background: #151515;
    min-height: 100vh;
    position: fixed;
    padding: 20px;
}

.sidebar h4 {
    font-weight: 700;
}

.sidebar a {
    display: block;
    color: #bbb;
    padding: 12px;
    border-radius: 10px;
    text-decoration: none;
    margin-bottom: 8px;
}

.sidebar a.active,
.sidebar a:hover {
    background: #ff9800;
    color: #000;
}

/* =================================================
   MAIN CONTENT
   ================================================= */
.main {
    margin-left: 260px;
    padding: 25px;
}

/* =================================================
   HEADER BAR
   ================================================= */
.top-bar {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.search-box input {
    background: #222;
    border: none;
    border-radius: 30px;
    padding: 10px 20px;
    color: white;
}

/* =================================================
   KPI CARDS
   ================================================= */
.kpi-card {
    border-radius: 20px;
    padding: 20px;
    color: white;
}

.bg-green { background: #1abc9c; }
.bg-purple { background: #9b59b6; }
.bg-blue { background: #3498db; }
.bg-orange { background: #e67e22; }

/* =================================================
   CONTENT CARDS
   ================================================= */
.card-dark {
    background: #1c1c1e;
    border-radius: 20px;
    padding: 20px;
}

/* =================================================
   TRENDING DRINKS
   ================================================= */
.drink-card {
    background: #1c1c1e;
    border-radius: 20px;
    padding: 15px;
    text-align: center;
}

.drink-card img {
    width: 100%;
    border-radius: 15px;
}
</style>
</head>

<body>

<!-- =================================================
     SIDEBAR
     ================================================= -->
<div class="sidebar">
    <h4>☕ Charlie Cafe</h4>
    <p class="text-muted">Admin Dashboard</p>

    <!-- Navigation -->
    <a class="active"><i class="bi bi-speedometer2"></i> Dashboard</a>
    <a href="#"><i class="bi bi-cup-hot"></i> Menu</a>
    <a href="#"><i class="bi bi-bag-check"></i> Orders</a>
    <a href="#"><i class="bi bi-graph-up"></i> Analytics</a>
    <a href="#"><i class="bi bi-gear"></i> Settings</a>

    <hr>

    <!-- Logout (placeholder) -->
    <a onclick="logout()" style="cursor:pointer">
        <i class="bi bi-box-arrow-left"></i> Logout
    </a>
</div>

<!-- =================================================
     MAIN CONTENT
     ================================================= -->
<div class="main">

<!-- ================= HEADER ================= -->
<div class="top-bar mb-4">
    <h5>Welcome, Admin 👋</h5>

    <div class="search-box">
        <input type="text" placeholder="🔍 Search orders, drinks">
    </div>

    <div>
        <i class="bi bi-bell"></i>
        <span class="ms-3">Charlie Cafe</span>
        <small class="text-muted">Admin</small>
    </div>
</div>

<!-- ================= KPI ROW ================= -->
<div class="row g-4 mb-4">

    <div class="col-md-3">
        <div class="kpi-card bg-green">
            <h6>Today's Sales</h6>
            <h3>$1,250</h3>
        </div>
    </div>

    <div class="col-md-3">
        <div class="kpi-card bg-purple">
            <h6>Total Orders</h6>
            <h3>86</h3>
        </div>
    </div>

    <div class="col-md-3">
        <div class="kpi-card bg-blue">
            <h6>Drinks Sold</h6>
            <h3>142</h3>
        </div>
    </div>

    <div class="col-md-3">
        <div class="kpi-card bg-orange">
            <h6>Avg Order Value</h6>
            <h3>$14.50</h3>
        </div>
    </div>

</div>

<!-- ================= CHART PLACEHOLDERS ================= -->
<div class="row g-4">

    <div class="col-md-6">
        <div class="card-dark">
            <h5>Sales Overview</h5>
            <p class="text-muted">Daily / Weekly / Monthly</p>
            <p class="text-muted">
                (Chart will be connected to Analytics API later)
            </p>
        </div>
    </div>

    <div class="col-md-6">
        <div class="card-dark">
            <h5>Orders Trend</h5>
            <p class="text-muted">
                (Bar chart placeholder)
            </p>
        </div>
    </div>

</div>

<!-- ================= TRENDING DRINKS ================= -->
<div class="mt-5">
    <h5>🔥 Trending Drinks</h5>

    <div class="row g-4 mt-2">

        <div class="col-md-4">
            <div class="drink-card">
                <img src="https://images.unsplash.com/photo-1509042239860-f550ce710b93">
                <h6 class="mt-2">Cappuccino</h6>
                <p>$5.00</p>
            </div>
        </div>

        <div class="col-md-4">
            <div class="drink-card">
                <img src="https://images.unsplash.com/photo-1511920170033-f8396924c348">
                <h6 class="mt-2">Latte</h6>
                <p>$4.50</p>
            </div>
        </div>

        <div class="col-md-4">
            <div class="drink-card">
                <img src="https://images.unsplash.com/photo-1571072793434-1a3b2e7a0f8a">
                <h6 class="mt-2">Fresh Juice</h6>
                <p>$6.00</p>
            </div>
        </div>

    </div>
</div>

</div>

<!-- =================================================
     JS (NO BACKEND – PLACEHOLDERS ONLY)
     ================================================= -->
<script>
/* Placeholder logout
   Later → Cognito logout will replace this */
function logout() {
    alert("Logout clicked (Cognito will be added later)");
}
</script>

</body>
</html>
```

#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```

#### 4️⃣ Fix File Permissions

```
sudo chown apache:apache /var/www/html/dashboard.html
```

```
sudo chmod 644 /var/www/html/dashboard.html
```


#### 5️⃣ Restart Apache (MANDATORY)

```
sudo systemctl restart httpd
```

#### 6️⃣ Open page in browser (MANDATORY)

```
http:// Your EC2 Public IP/dashboard.html
```


**✅ PHASE 1 STATUS**

> **🟢 PHASE 1 COMPLETE & VERIFIED**

---

## 🔐 PHASE 2️⃣ — DEPLOY FINAL FRONTEND (WRITE ONCE ✅)

#### (ONE FILE ONLY)

### 🎯 What this frontend already includes

| Feature             | Status |
| ------------------- | ------ |
| Login UI            | ✅      |
| Cognito Hosted UI   | ✅      |
| JWT storage         | ✅      |
| Spinner             | ✅      |
| Auto refresh (10s)  | ✅      |
| Metrics             | ✅      |
| Orders table        | ✅      |
| Chart               | ✅      |
| Date filter         | ✅      |
| Print orders        | ✅      |
| Print today summary | ✅      |

### 📄 FINAL FRONTEND FILE (ONLY ONCE)

#### 📍 Location:

> **dashboard.html (Recommanded)**

```
/var/www/html/dashboard.html
```

> **order-status.html**

```
/var/www/html/order-status.html
```

> **You NEVER modify this file again except 4 config values**

### 🔧 ONLY CHANGE THESE 4 VALUES

```
const USER_POOL_ID = "CHANGE_ME";
const CLIENT_ID = "CHANGE_ME";
const COGNITO_DOMAIN = "CHANGE_ME.auth.ap-south-1.amazoncognito.com";
const API_URL = "https://xxxxx.execute-api.ap-south-1.amazonaws.com/admin/order-status";
```

#### ✅ Everything else stays unchanged forever

#### ✅ Code (Login + Dashboard fully integrated & Recommanded )

- Cognito Hosted UI redirect login (login() & handleRedirect())

- Access Token stored in localStorage

- Bearer prefix added in Authorization header

- Token expiry check implemented

- Navbar hidden until login

- Spinner, chart, metrics, and table all intact

- Auto-refresh every 10s maintained

#### 1️⃣ Updated Frontend (Order.html )

#### Here’s the updated HTML/JS code:

### ✅ What We Added / Changed

- Sidebar & main content initially hidden → display:none until login.

- Cognito config → COGNITO_DOMAIN, CLIENT_ID, REDIRECT_URI.

- Login function → redirects to Cognito Hosted UI.

- Logout function → clears token + redirect to Cognito logout.

- handleRedirect → extracts JWT from URL hash after login.

- Token validation → isTokenExpired() ensures user cannot access dashboard with expired token.

- Fetch dashboard data with Authorization header → secure API calls.

- Auto-refresh every 10 seconds → charts and KPI cards update dynamically.


> **dashboard.html (Recommanded)**

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Cafe ☕ | Admin Dashboard</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- ================= BOOTSTRAP ================= -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- ================= ICONS ================= -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">

<!-- ================= CHART.JS ================= -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
/* =================================================
   GLOBAL THEME (DARK CAFE STYLE)
   ================================================= */
body {
    background-color: #0f0f10;
    color: #ffffff;
    font-family: 'Segoe UI', sans-serif;
}

/* =================================================
   SIDEBAR
   ================================================= */
.sidebar {
    width: 250px;
    background: #151515;
    min-height: 100vh;
    position: fixed;
    padding: 20px;
    display: none; /* Hidden until login */
}

.sidebar h4 {
    font-weight: 700;
}

.sidebar a {
    display: block;
    color: #bbb;
    padding: 12px;
    border-radius: 10px;
    text-decoration: none;
    margin-bottom: 8px;
}

.sidebar a.active,
.sidebar a:hover {
    background: #ff9800;
    color: #000;
}

/* =================================================
   MAIN CONTENT
   ================================================= */
.main {
    margin-left: 260px;
    padding: 25px;
    display: none; /* Hidden until login */
}

/* =================================================
   HEADER BAR
   ================================================= */
.top-bar {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.search-box input {
    background: #222;
    border: none;
    border-radius: 30px;
    padding: 10px 20px;
    color: white;
}

/* =================================================
   KPI CARDS
   ================================================= */
.kpi-card {
    border-radius: 20px;
    padding: 20px;
    color: white;
}

.bg-green { background: #1abc9c; }
.bg-purple { background: #9b59b6; }
.bg-blue { background: #3498db; }
.bg-orange { background: #e67e22; }

/* =================================================
   CONTENT CARDS
   ================================================= */
.card-dark {
    background: #1c1c1e;
    border-radius: 20px;
    padding: 20px;
}

/* =================================================
   TRENDING DRINKS
   ================================================= */
.drink-card {
    background: #1c1c1e;
    border-radius: 20px;
    padding: 15px;
    text-align: center;
}

.drink-card img {
    width: 100%;
    border-radius: 15px;
}
</style>
</head>

<body>

<!-- =================================================
     SIDEBAR (Hidden until login)
     ================================================= -->
<div class="sidebar" id="sidebar">
    <h4>☕ Charlie Cafe</h4>
    <p class="text-muted">Admin Dashboard</p>

    <!-- Navigation -->
    <a class="active"><i class="bi bi-speedometer2"></i> Dashboard</a>
    <a href="#"><i class="bi bi-cup-hot"></i> Menu</a>
    <a href="#"><i class="bi bi-bag-check"></i> Orders</a>
    <a href="#"><i class="bi bi-graph-up"></i> Analytics</a>
    <a href="#"><i class="bi bi-gear"></i> Settings</a>

    <hr>

    <!-- Logout -->
    <a onclick="logout()" style="cursor:pointer">
        <i class="bi bi-box-arrow-left"></i> Logout
    </a>
</div>

<!-- =================================================
     MAIN CONTENT (Hidden until login)
     ================================================= -->
<div class="main" id="mainContent">

<!-- ================= HEADER ================= -->
<div class="top-bar mb-4">
    <h5>Welcome, Admin 👋</h5>

    <div class="search-box">
        <input type="text" placeholder="🔍 Search orders, drinks">
    </div>

    <div>
        <i class="bi bi-bell"></i>
        <span class="ms-3">Charlie Cafe</span>
        <small class="text-muted">Admin</small>
    </div>
</div>

<!-- ================= KPI ROW ================= -->
<div class="row g-4 mb-4" id="kpiRow">
    <!-- KPI Cards will be dynamically updated from API -->
</div>

<!-- ================= CHART PLACEHOLDERS ================= -->
<div class="row g-4" id="chartRow">
    <div class="col-md-6">
        <div class="card-dark">
            <h5>Sales Overview</h5>
            <p class="text-muted">Daily / Weekly / Monthly</p>
            <canvas id="salesChart"></canvas>
        </div>
    </div>

    <div class="col-md-6">
        <div class="card-dark">
            <h5>Orders Trend</h5>
            <canvas id="ordersChart"></canvas>
        </div>
    </div>
</div>

<!-- ================= TRENDING DRINKS ================= -->
<div class="mt-5">
    <h5>🔥 Trending Drinks</h5>
    <div class="row g-4 mt-2" id="trendingDrinks">
        <!-- Cards remain static for now -->
    </div>
</div>

</div>

<!-- =================================================
     JAVASCRIPT: COGNITO + DASHBOARD LOGIC
     ================================================= -->
<script>
/* ================== CONFIG ================== */
const COGNITO_DOMAIN = "YOUR_COGNITO_DOMAIN.auth.region.amazoncognito.com";
const CLIENT_ID = "YOUR_APP_CLIENT_ID";
const REDIRECT_URI = window.location.origin;
const API_URL = "https://API_ID.execute-api.region.amazonaws.com/STAGE/dashboard";

let salesChart, ordersChart, refreshTimer;

/* ================== AUTH ================== */
function parseJwt(token) {
    return JSON.parse(atob(token.split('.')[1]));
}

function isTokenExpired(token) {
    const payload = parseJwt(token);
    return payload.exp * 1000 < Date.now();
}

function login() {
    const loginUrl = `https://${COGNITO_DOMAIN}/login?response_type=token&client_id=${CLIENT_ID}&redirect_uri=${REDIRECT_URI}`;
    window.location.href = loginUrl;
}

function logout() {
    localStorage.removeItem("token");
    clearInterval(refreshTimer);
    const logoutUrl = `https://${COGNITO_DOMAIN}/logout?client_id=${CLIENT_ID}&logout_uri=${REDIRECT_URI}`;
    window.location.href = logoutUrl;
}

function handleRedirect() {
    const hash = window.location.hash.substr(1);
    const params = new URLSearchParams(hash);
    const token = params.get("access_token");
    if (token) {
        localStorage.setItem("token", token);
        window.location.hash = "";
    }
}

/* ================== DASHBOARD ================== */
function showDashboard() {
    const token = localStorage.getItem("token");
    if (!token || isTokenExpired(token)) {
        login();
        return;
    }

    document.getElementById("sidebar").style.display = "block";
    document.getElementById("mainContent").style.display = "block";

    loadData();
    refreshTimer = setInterval(loadData, 10000);
}

/* ================== DATA FETCH ================== */
function loadData() {
    const token = localStorage.getItem("token");
    if (!token || isTokenExpired(token)) return logout();

    fetch(API_URL, {
        headers: { Authorization: `Bearer ${token}` }
    })
    .then(res => {
        if (res.status === 401) logout();
        return res.json();
    })
    .then(data => {
        // Populate KPI Cards
        const kpiRow = document.getElementById("kpiRow");
        kpiRow.innerHTML = "";
        data.metrics.forEach(m => {
            kpiRow.innerHTML += `
                <div class="col-md-3">
                    <div class="kpi-card ${m.bgClass}">
                        <h6>${m.metric}</h6>
                        <h3>${m.count}</h3>
                    </div>
                </div>`;
        });

        // Sales Chart
        if (salesChart) salesChart.destroy();
        salesChart = new Chart(document.getElementById("salesChart"), {
            type: 'line',
            data: {
                labels: data.sales.labels,
                datasets: [{ label: 'Sales', data: data.sales.values, backgroundColor:'rgba(255,152,0,0.3)', borderColor:'orange', fill:true }]
            }
        });

        // Orders Chart
        if (ordersChart) ordersChart.destroy();
        ordersChart = new Chart(document.getElementById("ordersChart"), {
            type: 'bar',
            data: {
                labels: data.orders.labels,
                datasets: [{ label: 'Orders', data: data.orders.values, backgroundColor:'rgba(0,123,255,0.7)' }]
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

> **order-status.html**
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
/* ===== BACKGROUND ===== */
body {
  min-height: 100vh;
  background:
    linear-gradient(rgba(0,0,0,.55), rgba(0,0,0,.55)),
    url("https://images.unsplash.com/photo-1509042239860-f550ce710b93");
  background-size: cover;
  background-position: center;
  background-attachment: fixed;
}

/* ===== DASHBOARD ===== */
#dashboard {
  display: none;
  background:#f5f5f5;
  padding: 20px;
  border-radius: 8px;
}

/* Metrics card */
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

<!-- FILTER -->
<div class="row mb-3">
  <div class="col-md-3">
    <input type="date" id="filterDate" class="form-control">
  </div>
  <div class="col-md-2">
    <button class="btn btn-primary w-100" onclick="loadData()">Filter</button>
  </div>
</div>

<!-- LOADER -->
<div class="text-center my-3" id="loader" style="display:none">
  <div class="spinner-border text-warning"></div>
  <p class="mt-2">Loading...</p>
</div>

<!-- METRICS -->
<div class="row mb-4" id="metrics"></div>

<!-- CHART -->
<canvas id="orderChart" height="100"></canvas>

<!-- TABLE -->
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
const COGNITO_DOMAIN = "YOUR_COGNITO_DOMAIN.auth.region.amazoncognito.com";
const CLIENT_ID = "YOUR_APP_CLIENT_ID";
const REDIRECT_URI = window.location.origin;
const API_URL = "https://API_ID.execute-api.region.amazonaws.com/STAGE/order-status";

let chart, refreshTimer;

/* ================== AUTH ================== */
function getQueryParam(name) {
  const params = new URLSearchParams(window.location.search);
  return params.get(name);
}

// Decode JWT payload
function parseJwt(token) {
  return JSON.parse(atob(token.split('.')[1]));
}

function isTokenExpired(token) {
  const payload = parseJwt(token);
  return payload.exp * 1000 < Date.now();
}

// Redirect to Cognito Hosted UI
function login() {
  const loginUrl = `https://${COGNITO_DOMAIN}/login?response_type=token&client_id=${CLIENT_ID}&redirect_uri=${REDIRECT_URI}`;
  window.location.href = loginUrl;
}

function logout() {
  localStorage.removeItem("token");
  clearInterval(refreshTimer);
  const logoutUrl = `https://${COGNITO_DOMAIN}/logout?client_id=${CLIENT_ID}&logout_uri=${REDIRECT_URI}`;
  window.location.href = logoutUrl;
}

// Extract Access Token from URL hash
function handleRedirect() {
  const hash = window.location.hash.substr(1);
  const params = new URLSearchParams(hash);
  const token = params.get("access_token");

  if (token) {
    localStorage.setItem("token", token);
    window.location.hash = "";
  }
}

/* ================== DASHBOARD ================== */
function showDashboard() {
  if (!localStorage.getItem("token") || isTokenExpired(localStorage.getItem("token"))) {
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
  const token = localStorage.getItem("token");
  if (!token || isTokenExpired(token)) return logout();

  document.getElementById("loader").style.display = "block";
  document.getElementById("metrics").innerHTML = "";
  document.getElementById("orders").innerHTML = "";

  let url = API_URL;
  const filterDate = document.getElementById("filterDate").value;
  if (filterDate) url += "?date=" + filterDate;

  fetch(url, {
    headers: {
      Authorization: `Bearer ${token}`
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

#### 2️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```

### 2️⃣ SECURITY & PERMISSIONS

✅ 2.1 Fix File Permissions

```
sudo chown apache:apache /var/www/html/order-status.html
```
```
sudo chmod 644 /var/www/html/order-status.html
```

✅ 2.2 Open Security Group (MANDATORY)

Ensure EC2 Security Group allows:


| Type | Port | Source    |
| ---- | ---- | --------- |
| HTTP | 80   | 0.0.0.0/0 |



### 3️⃣ Restart Apache (MANDATORY)

```
sudo systemctl restart httpd
```

### 4️⃣ Open page in browser

```
http://EC2 Public IP/order-status.html
```

#### Example:

```
http://54.226.96.235/order-status.html
```

✔ Orders visible

✔ Counts visible

✔ Date/time visible

#### 🔧 OPTIONAL (YOU CAN CHANGE LATER)

Replace background image URL with your own S3 / CloudFront image

#### Adjust opacity:

```
rgba(0,0,0,.55)
```


#### ✅ Result:

- Login screen

- Spinner

- Auto refresh (10s)

- Chart

- Date filter

- Print buttons

- JWT ready

**✅ PHASE 2 STATUS**

> **🟢 PHASE 2 COMPLETE & VERIFIED**

---

## 🔐 PHASE 3️⃣ — Set Up Automatic HTTP → HTTPS Redirection

> **✅ EASY & CORRECT METHOD (RECOMMENDED FOR LAB)**

### 1️⃣  — USE EC2 PUBLIC IP (BEST FOR LAB)

> **This is 100% acceptable for labs and Cognito testing**

#### STEP 1️⃣ — CONFIRM EC2 IS PUBLIC

#### 1️⃣ Go to:

```
EC2 → Instances
```

#### 2️⃣ Select your instance

#### 3️⃣ Copy:

```
Public IPv4 address
```

Example:

```
54.183.22.10
```

#### ⚠️ If you do NOT see a public IP:

- Instance must be in a public subnet

- Must have Internet Gateway

#### STEP 2️⃣ — CONFIRM APACHE IS RUNNING

#### SSH into EC2:

```
sudo systemctl status httpd
```

#### If not running:

```
sudo systemctl start httpd
```

```
sudo systemctl enable httpd
```

#### STEP 3️⃣ — TEST PAGE DIRECTLY

#### Open browser:

```
http://54.183.22.10/order-status.html
```

✅ If page opens → PERFECT

❌ If not → check Security Group


#### STEP 4️⃣ — FIX SECURITY GROUP (VERY IMPORTANT)

#### 1️⃣ Go to:

```
EC2 → Security Groups → Your SG
```

#### 2️⃣ Inbound rules:

```
HTTP   TCP   80   0.0.0.0/0
```

Save

#### STEP 5️⃣ — USE THIS AS RETURN URL IN COGNITO

Now you FINALLY have a valid Return URL.

#### Use:

```
http://54.183.22.10/order-status.html
```

**⚠️ BUT Cognito REQUIRES HTTPS**

> **So for Cognito we must do ONE SMALL CHANGE**

### 2️⃣  — HTTPS REQUIREMENT (CRITICAL)

**⚠️ Cognito does NOT allow HTTP except localhost.**

So we must add HTTPS.

You have TWO EASY OPTIONS

### 2️⃣  — USE ALB

> **This is the simplest HTTPS solution.**

#### STEP 1️⃣ — CREATE APPLICATION LOAD BALANCER

```
EC2 → Load Balancers → Create Load Balancer
```

#### Choose:

```
Application Load Balancer
```

#### STEP 2️⃣ — BASIC ALB Configuration


| Setting                  | Value / Selection                                      | Notes / Requirement                          |
|--------------------------|--------------------------------------------------------|----------------------------------------------|
| **Name**                 | charlie-cafe-alb                                       | Unique name for your ALB                     |
| **Scheme**               | Internet-facing                                        | Allows public internet access                |
| **IP address type**      | IPv4                                                   | Standard for most setups                     |
| **VPC**                  | Same VPC as your EC2 instance                          | Must match EC2 placement                     |
| **Subnets**              | Select at least 2 **public** subnets                   | Required for internet-facing ALB; choose different Availability Zones if possible |
| **Availability Zones**   | At least 2 AZs (where public subnets exist)            | Improves high availability                   |


#### STEP 3️⃣ — SECURITY GROUP

#### Allow:

```
HTTPS 443  0.0.0.0/0
```

#### STEP 4️⃣ — Target Group Configuration (for EC2 registration)


| Setting                  | Value / Selection                          | Notes / Requirement                                      |
|--------------------------|--------------------------------------------|----------------------------------------------------------|
| **Type**                 | Instance                                   | Standard for registering EC2 instances by ID             |
| **Protocol**             | HTTP                                       | Matches your web server on EC2 (use HTTPS only if EC2 already has SSL) |
| **Port**                 | 80                                         | Default HTTP port your web server listens on             |
| **Target registration**  | Register your EC2 instance                 | Select your EC2 instance by name/ID (not IP)             |
| **Health check path**    | / (or /order-status.html)                  | Path ALB uses to check if instance is healthy            |

#### STEP 5️⃣ — Add Listener to ALB 

#### - Add HTTP listener 

- **Listener:** HTTP 80

- **Target Group:** Select Your Target Group

#### - Add HTTPS listener (Optional)


| Setting                  | Value / Selection                                      | Notes / Requirement                                                                 |
|--------------------------|--------------------------------------------------------|-------------------------------------------------------------------------------------|
| **Listener**             | HTTPS : 443                                            | Standard secure port for HTTPS traffic                                              |
| **Certificate**          | Request or select from ACM (AWS Certificate Manager)   | Must use a valid SSL/TLS certificate; free public certs available via ACM           |
| **Certificate source**   | ACM                                                    | Recommended – free, auto-renewing certificates                                      |
| **Domain name (for ACM request)** | Your domain (e.g., charliecafe.com, *.charliecafe.com) | Required to request certificate; can be:<br>• Real domain you own<br>• Wildcard (*.example.com)<br>• Multiple SANs (Subject Alternative Names) |
| **Validation method**    | DNS validation (preferred) or Email                    | DNS is faster & automatic if using Route 53                                         |
| **Default action**       | Forward to target group (e.g., cafe-target-group)      | Routes HTTPS traffic to your EC2 instance(s)                                        |
| **HTTP → HTTPS redirect** | Add separate HTTP:80 listener with redirect rule       | Recommended: Redirect all HTTP traffic to HTTPS                                     |

**⚠️ ACM is FREE**

#### STEP 6️⃣ — Optional - Request SSL Certificate (ACM) 

> **⚠️ Try when do not want to use cloudFront**

#### 1️⃣ Go to:

```
AWS Console → Certificate Manager (ACM)
```

> **⚠️ Make sure region is us-east-1 (same as ALB)**

#### 2️⃣ Click:

- Request a certificate

#### 3️⃣ Choose:

- Public certificate → Next

#### 4️⃣ Domain name:

You have two choices:

✅ EASIEST (Recommended for lab)

```
*.us-east-1.elb.amazonaws.com
```

OR (more strict, also works):

```
charlie-cafe-alb-1050813156.us-east-1.elb.amazonaws.com
```

#### 5️⃣ Validation:

- DNS validation (default)

- Click Request

**👉 ACM will auto-validate (for ELB domains it’s fast)**

Wait until status shows:

```
Issued ✅
```

#### 6️⃣ Add HTTPS Listener to ALB

#### 1️⃣ Go to:

```
EC2 → Load Balancers → Your ALB
```

#### 2️⃣ Listeners → Add listener

| Setting        | Value                        |
| -------------- | ---------------------------- |
| Protocol       | **HTTPS**                    |
| Port           | **443**                      |
| Default action | Forward to same Target Group |


#### 3️⃣ Certificate:

- Choose ACM certificate

- Select the certificate you just created

👉 Save

#### 🟡 Now your ALB supports:

- HTTP : 80

- HTTPS : 443 ✅

#### 7️⃣ (Optional but Recommended) Redirect HTTP → HTTPS

#### Still inside ALB:

- Edit HTTP (80) listener

- Change action to:

```
Redirect to HTTPS : 443
```

#### 🟡 This ensures:

- Users always end up on HTTPS

- Cognito stays happy


#### STEP 7️⃣ — GET ALB DNS NAME

Example:

```
https://charlie-cafe-alb-123.us-east-1.elb.amazonaws.com
```

#### STEP 8️⃣  — TEST PAGE

Open:

```
https://ALB-DNS/order-status.html
```

✅ Works → DONE


### 3️⃣ — CLOUD FRONT

#### 🧱 STEP 1️⃣ — CloudFront Origin (ALB)

#### Go to:

```
AWS Console → CloudFront → Create Distribution
```

- **Distribution name:** Charlie-Cafe

- **Next:**

- **Origin type:** Elastic Load Balancer

#### CloudFront Origin Settings (CRITICAL)

>**Go to:** CloudFront → Distributions → Your Distribution → Origins → Edit

> **Set EXACTLY like this:**

| Setting                | Value                                                   |
| ---------------------- | ------------------------------------------------------- |
| Origin domain          | charlie-cafe-alb-1050813156.us-east-1.elb.amazonaws.com |
| Origin protocol policy | **HTTP only** ✅                                         |
| HTTP port              | 80                                                      |
| Origin SSL protocols   | (doesn’t matter now)                                    |


✅ This is correct

❌ Do NOT select EC2 IP

❌ Do NOT select S3

#### 🌐 STEP 2️⃣ — Default Cache Behavior (VERY IMPORTANT)

>**Go to:** Behaviors → Default → Edit


| Setting                | Value                  |
| ---------------------- | ---------------------- |
| Viewer protocol policy | Redirect HTTP to HTTPS |
| Allowed HTTP methods   | GET, HEAD, OPTIONS     |
| Cache policy           | CachingDisabled        |
| Origin request policy  | AllViewer              |


⚠️ Cognito tokens must NOT be cached

#### This ensures:

Authorization headers

Query strings

Cookies
are forwarded correctly.

👉 SAVE

⏳ Wait 5–10 minutes for deployment.

```
Status = Deployed
```

#### You’ll get:

```
xxxxx.cloudfront.net
```

#### 🔐 STEP 3️⃣ — CloudFront General Configuration

> **This step finalizes the CloudFront distribution behavior and ensures it works correctly with ALB + Cognito Hosted UI without breaking authentication or routing.**

#### 1️⃣ ⚙️ General Configuration

- **Configure the following settings in CloudFront → Distribution → General.**

#### 1️⃣ IPv6

- **Turn OFF IPv6**

#### Why

- ALB and EC2 work perfectly on IPv4

- Avoids DNS and routing edge-case issues during labs

- Keeps troubleshooting simple

✅ Recommended for learning & labs

🔁 Can be enabled later in production

#### 2️⃣ Default Root Object (Optional but Recommended)

```
order-status.html
```

#### What this does

When users open the root URL:

```
https://xxxxx.cloudfront.net/
```

CloudFront automatically serves:

```
order-status.html
```

#### Benefits

- Cleaner URL

- Better user experience

- No impact on Cognito authentication

**⚠️ Do NOT add /order-status.html to Origin Path**
**Origin Path must remain empty.**

#### 🧠 Correct CloudFront Path Logic

| Configuration Item   | Value                             |
| -------------------- | --------------------------------- |
| Origin Path          | ❌ Empty                           |
| Default Root Object  | ✅ `order-status.html`             |
| File location on EC2 | `/var/www/html/order-status.html` |


This ensures:

```
CloudFront → ALB → EC2 Apache → order-status.html
```

#### 2️⃣ 🔄 CloudFront Invalidations (Admin Dashboard Use Case)

> **CloudFront caches content at edge locations worldwide.
When you update a file on EC2 (like order-status.html), CloudFront may still serve the old cached version.**

**👉 Invalidation tells CloudFront to delete cached copies immediately.**

#### 1️⃣ Go to:

```
CloudFront → Distributions → Your Distribution
```

#### 2️⃣ Click Invalidations

#### 3️⃣ Click Create invalidation

#### 4️⃣ In Object paths, enter:

invalidation path:

```
/order-status.html
```

#### 5️⃣ Click Create invalidation

⏳ Status will show:

```
In Progress → Completed
```

Usually completes in 1–3 minutes.

#### When to Use Invalidation

Use invalidation only when you change frontend files, such as:

| Change               | Invalidate? |
| -------------------- | ----------- |
| HTML changes         | ✅ Yes       |
| JS logic             | ✅ Yes       |
| Cognito redirect URL | ✅ Yes       |
| API Gateway backend  | ❌ No        |
| DynamoDB data        | ❌ No        |

#### Best Practice for Your Project

For admin dashboards like Charlie Cafe:

- Invalidate specific files

- Avoid /* unless necessary

✅ Recommended invalidation paths

```
/order-status.html
/login.html
/css/*
/js/*
```

#### ❌ Avoid unless emergency

```
/*
```

(Uses more invalidation quota)

#### Cost & Limits (Important to Know)

- First 1,000 invalidation paths/month → FREE

- After that → small cost per path

Your usage:

```
/order-status.html → 1 path ✅
```

Perfect.

#### How to Confirm Invalidation Worked

After status = Completed:

1️⃣ Open browser

2️⃣ Hard refresh:

- Windows/Linux: Ctrl + F5

- Mac: Cmd + Shift + R

3️⃣ Open:

```
https://xxxxx.cloudfront.net/order-status.html
```

You should see latest code.

#### Common Mistakes (Avoid These)

❌ Invalidating:

```
order-status.html
```

(missing leading /)

❌ Invalidating wrong file name

❌ Forgetting invalidation after JS changes

#### Important Notes:

✔ /order-status.html is the correct invalidation path

✔ Use invalidation after frontend changes

✔ Do not overuse /*

✔ Required when testing Cognito changes

#### 🔐 STEP 4️⃣ — CloudFront SSL Certificate (Optional)
Viewer Certificate

Choose:

```
Default CloudFront certificate (*.cloudfront.net)
```

✅ This is fine

✅ HTTPS works automatically

❌ No ACM needed here


#### 5️⃣ CloudFront Validation (VERY IMPORTANT)

> **After configuration, always validate CloudFront before integrating Cognito.**

#### 🔍 Validation Checklist

#### 1️⃣ Distribution Status

Status must be:

```
Deployed
```

**⚠️ If status is In Progress, wait 5–10 minutes.**

#### 2️⃣ Basic Connectivity Test

Open in browser:

```
https://xxxxx.cloudfront.net/
```

#### Expected result:

```
order-status.html loads
OR

Cafe homepage loads (if root object not set)
```

#### 3️⃣ Direct File Test

Open:

```
https://xxxxx.cloudfront.net/order-status.html
```

#### Expected:

```
Page loads successfully

No 403 / 504 / timeout errors
```

#### 4️⃣ Backend Health Verification

If CloudFront fails:

Test ALB directly:

```
http://ALB-DNS-NAME/order-status.html
```

#### Ensure:

- ALB target group = Healthy

- EC2 Apache is running

- Security Groups allow ALB → EC2 (port 80)

### 6️⃣ — USE THIS IN COGNITO

```
d2og2zrs47voou.cloudfront.net
```

This is your Return URL

#### ✅ FINAL RECOMMENDED PATH

| Step       | Do this                        |
| ---------- | ------------------------------ |
| Host page  | EC2 Apache                     |
| HTTPS      | ALB                            |
| Return URL | ALB DNS + `/order-status.html` |
| CloudFront | Later (optional)               |


### 🧠 WHY THIS IS THE CORRECT APPROACH

- Matches real AWS projects

- Works with Cognito HTTPS rule

- Simple & debuggable

- No unnecessary complexity

**✅ PHASE 3 STATUS**

> **🟢 PHASE 3 COMPLETE & VERIFIED**

---

## 🔐 PHASE 4️⃣ — COGNITO INTEGRATION (PRODUCTION READY)

This phase is used to secure the Admin Order Dashboard of your Charlie Cafe project.

### Goal 

- Only admin users can access the admin dashboard

- Login handled by Amazon Cognito

- Frontend receives a JWT token

- Backend (API Gateway + Lambda) validates the token

### Charlie Café Admin Login (SPA-based)

#### You are on this page:

> **Amazon Cognito → Set up resources for your application**

#### This wizard creates BOTH:

- User Pool

- App Client

- Hosted UI

- in one flow


### 🧭 BIG PICTURE (IMPORTANT)

| Old Guide Term | New Cognito UI Equivalent    |
| -------------- | ---------------------------- |
| User Pool      | Created automatically        |
| App Client     | “Application”                |
| Public client  | SPA / Web app                |
| Auth flows     | Selected by Application type |
| Hosted UI      | “Managed login pages”        |
| Callback URL   | Return URL                   |

---
### ▶️ Part 1️⃣ Cognito Authentication infrastructure 

### ✅ STEP 1️⃣ — DEFINE YOUR APPLICATION

#### 1️⃣ Application type

> **👉 SELECT THIS (CORRECT FOR YOUR PROJECT)**

```
✅ Single-page application (SPA)
```

#### Why?

- Your admin dashboard is HTML + JS

- Runs in browser

- No client secret allowed (correct)

#### ❌ Do NOT choose:

- Traditional web app

- Machine-to-machine


#### 2️⃣ Name your application

Example:

```
CharlieCafeAdminSPA
```

**❕ (Name doesn’t matter technically)**

### ⚙️ STEP 2️⃣ — CONFIGURE OPTIONS (VERY IMPORTANT)

#### 1️⃣ Options for sign-in identifiers

#### SELECT:

```
☑ Username
```

#### DO NOT select:

❌ Email

❌ Phone number

#### 📌 This matches your requirement:

**🔴 Username: admin**

#### 2️⃣ Self-registration (CRITICAL)

❌ DISABLE self-registration

👉 UNCHECK

```
☐ Enable self-registration (DISABLED)
```

#### Why?

Your Charlie Café Admin Dashboard must be:

🔐 Admin-only

❌ No public sign-up

👤 Users created manually by you

> **So: Unchecking self-registration is 100% correct and production-ready**

#### 🔍 What Happens After Disabling Self-Registration

| Feature                  | Result        |
| ------------------------ | ------------- |
| Public sign-up page      | ❌ Disabled    |
| “Create account” link    | ❌ Hidden      |
| Admin-created users      | ✅ Allowed     |
| Temporary password login | ✅ Allowed     |
| Hosted UI login          | ✅ Still works |

#### 3️⃣ Required attributes for sign-up

Click Select attributes

```
email   ← OK (this is fine)
```

#### ❌ Do NOT select:

- Phone number

- Any other attributes

#### 4️⃣ Return URL

```
d2og2zrs47voou.cloudfront.net
```

#### For Example:

```
https://d2og2zrs47voou.cloudfront.net/order-status.html
```

#### 🎯 WHAT “Return URL” REALLY MEANS (IN SIMPLE WORDS)

> **Return URL = the web page where Cognito sends the user AFTER login**

#### So after admin logs in:

```
Cognito Login → SUCCESS → redirect to order-status.html
```

**📢 Cognito does NOT host your page**

**👉 YOU must host order-status.html somewhere public**

#### 🧠 YOUR CURRENT SITUATION (BASED ON YOUR MESSAGE)

#### You said:

✅ You already have EC2

✅ Apache HTTP is running

❌ No ALB yet

❌ No CloudFront yet

#### 👉 GOOD NEWS:

**💯 You DO NOT NEED ALB or CloudFront right now**

> **We will do this in the EASIEST possible way first (You can add ALB + CloudFront later)**

#### Now click the button at bottom-right:

```
🟠 Create user directory
```

### ✅ STEP 2️⃣ — OPEN THE ACTUAL USER POOL (THIS IS THE MISSING STEP)

> **📢 After creation completes:**

#### Go to:

```
Amazon Cognito → User pools
```

> **You will now see a new User Pool created automatically**
> **(example name similar to your application)**

#### 👉 CLICK the User Pool name

**⚠️ This is the step everyone misses**

### 🔐 NOW — THIS IS WHERE “STEP 3 — SECURITY” REALLY LIVES

**You are now INSIDE the User Pool, not the app wizard.**

#### 1️⃣  PASSWORD POLICY 

#### Path:

```
User pool → Authentication → Authentication methods
```

#### Then look for:

```
Password policy
```

**⚠️ If you don’t see it yet:**

- Click Authentication methods

- Scroll down

✅ Default password policy is already applied

✅ This satisfies your lab requirement

👉 You do NOT need to change anything

**✔ Password policy = OK**

#### 2️⃣ Multi-factor authentication (MFA)

#### 1️⃣ Path:

```
User pool → Sign-in experience → Account recovery
```

#### 2️⃣ Select:

> **YOU ALREADY CONFIGURED IT CORRECTLY**

```
❌ Off
```

Click Save changes

#### 2️⃣ ACCOUNT RECOVERY 

#### 1️⃣ Path:

```
User pool → Sign-in experience → Account recovery
```

#### 2️⃣ Select:

```
☑ Email only
```

#### 3️⃣ Disable:

```
☐ SMS
```

Click Save changes

#### ✅ SUMMARY

| Requirement      | Status              |
| ---------------- | ------------------- |
| Password policy  | ✅ Default (OK)      |
| MFA              | ✅ No MFA            |
| Account recovery | ⚠ Fix to Email only |

**✔ Now your account recovery matches the lab**

### ❗  PASSWORD IS “INACTIVE” + SNS ERROR (Optional)

> **This is a REAL AWS SERVICE ISSUE, not a mistake.**

#### 🚨 ERROR YOU GOT

```
[UserError] Failed to get SNS sandbox status for account
```

### ❓ Why this happens

#### Cognito depends on Amazon SNS for:

- SMS

- MFA

- Some passwordless / choice-based sign-in features

#### Your AWS account:

❌ SNS sandbox not initialized

❌ SMS not approved

❌ Region mismatch possible

**🔐 So AWS disables choice-based sign-in → password**


### 🔴 IMPORTANT CLARIFICATION

> **❗ You do NOT need “Options for choice-based sign-in” for your project**

#### Your lab uses:

```
Username + Password
Hosted UI
OAuth tokens
```

#### NOT:

- Passwordless

- Passkeys

- SMS login

**🔐 So this section is NOT REQUIRED**

### ✅ WHAT YOU SHOULD DO (CORRECT ACTION)

### 🔹 OPTION 1 — IGNORE IT (RECOMMENDED)

#### ✔ Leave:

```
Options for choice-based sign-in
Passwordless status: Inactive
```

**👉 Your Cognito login WILL STILL WORK**

#### This setting does NOT affect:

- Hosted UI login

- Username/password

- Token generation

- API Gateway authorizer

### 🔹 OPTION 2 — FIX SNS (ONLY IF YOU WANT)

> **This is advanced and NOT needed for your lab, but for completeness:**

#### 1️⃣ Go to:

```
Amazon SNS → Text messaging (SMS)
```

#### 2️⃣ Request:

```
Exit SMS sandbox
```

#### 3️⃣ Add billing details

#### 4️⃣ Wait for AWS approval (hours/days)

**⚠️ Not recommended for labs**

### ✅ FINAL VERDICT (IMPORTANT)

#### ✅ You should do THIS:

✔ Ignore choice-based sign-in

✔ Keep password inactive there

✔ Use Hosted UI login

✔ Continue with Cognito login URL

#### ✅ Your setup is 100% valid for:

- Charlie Café lab

- Admin dashboard

- Production-style auth

- API Gateway + Lambda

### ▶️ Part 2️⃣ Admin Authentication Using Amazon Cognito (Hosted UI + JWT Tokens)

### ✅ WHAT YOU HAVE DONE (CONFIRMED)

#### You already have:

✔ Cognito User Pool created

✔ Application (SPA) created

✔ ALB created and HTTPS working

✔ ALB DNS added as Return URL

✔ Password policy configured

✔ Account recovery configured

#### That means:

**👉 Authentication infrastructure is READY**

### 🎯 NOW WHAT IS THE GOAL?

#### For your Café Lab, the remaining goals are:

✔ Admin can log in

✔ Cognito returns a JWT token

✔ Admin dashboard (order-status.html) receives token

✔ API Gateway accepts requests only with valid token

✔ Admin can see orders (RDS / DynamoDB)

### 🟢 STEP 1️⃣ — CREATE ADMIN USER (MANDATORY)

#### 1️⃣ Where:

```
Cognito → User pools → Your user pool → Users
```

#### 2️⃣ Click:

```
Create user
```

#### 3️⃣ Fill:

| Setting                  | Value / Recommendation                                 | Notes / Action Required                              |
|--------------------------|--------------------------------------------------------|------------------------------------------------------|
| **Username**             | cafeadmin                                              | Use this exact username for consistency (case-sensitive in some flows) |
| **Temporary password**   | Auto-generated (recommended) or Manual                 | If manual: Use a strong one like `C@fe@dmin$` (must meet password policy) |
| **Suggested manual temp password** | C@fe@dmin$1                                            | Meets default policy: 8+ chars, upper/lower/number/special |
| **Email**                | your-email@example.com                                 | Replace with your real email (used for verification & recovery) |
| **Mark email as verified** | ✓ Yes (check the box)                                  | Critical: Enables immediate login without email verification step |
| **Message delivery**     | Email (default)                                        | Temporary password sent to the provided email        |
| **Additional attributes** | Optional: name = "Cafe Admin" (if required by your app) | Add if your required attributes include name         |

Click Create user

✅ Admin account created

### 🟢 STEP 2️⃣ — TEST HOSTED UI LOGIN (VERY IMPORTANT)

> **This confirms Cognito + ALB + Return URL are working.**

#### Flow summary:

- Admin opens the dashboard via ALB URL

- Browser redirects to Cognito Hosted UI login

- After login, Cognito redirects back to order-status.html

- Access Token is stored in browser

- Token is sent to API Gateway (Cognito Authorizer)

- Dashboard loads securely

> **This approach uses OAuth 2.0 Implicit Flow, which is ideal for plain HTML + JavaScript applications hosted on EC2 / Apache.**

#### 1️⃣ Login Page Configuration Tab:

```
Cognito → User pools → Your user pool → App clients → Your App → Login pages  
```

#### 2️⃣ Construct LOGIN URL:

```
https://YOUR_COGNITO_DOMAIN/login
?client_id=CLIENT_ID
&response_type=token
&scope=openid+email+profile
&redirect_uri=https://ALB-DNS/order-status.html
```

#### Example:

```
https://charlie-cafe-admin.auth.us-east-1.amazoncognito.com/login
```

#### 3️⃣ Test

- Open it in browser.

#### 4️⃣ Login with:

- Username: admin

- Temporary password

- Set new password

#### ✅ EXPECTED RESULT

After login, browser redirects to:

```
https://cloudfront/order-status.html#id_token=xxxxx&access_token=xxxxx
```

🎉 THIS MEANS SUCCESS

#### 5️⃣ Callback / Return URL (MOST IMPORTANT STEP)

> **Audio the ❌ HTTP ERROR 400

#### This error happens only for ONE reason in Cognito:

> **The redirect (callback) URL used in the browser does NOT exactly match the Callback URL configured in the App Client***

**🟠 Cognito is extremely strict.**

#### 🔎 What URL is your order-status.html really loaded from?

You said:

- EC2

- Apache

- ALB DNS name

- Cloudfront

So your real URL is something like:

```
http://<cloudfront>/order-status.html
```

Example:

```
https://d2og2zrs47voou.cloudfront.net/order-status.html
```

#### 1️⃣ Path (new UI):

```
Cognito
→ User pools
→ Your user pool
→ App integration
→ App clients
→ Click your App Client
→ Edit
```

#### 2️⃣ Callback URLs (VERY IMPORTANT)

#### Add EXACTLY:

```
http://<cloudfront>/order-status.html
```

✔ Must match character by character

✔ http vs https must match

✔ trailing slash matters

#### Example:

```
https://d2og2zrs47voou.cloudfront.net/order-status.html
```

#### 3️⃣ Sign-out URLs (recommended)

#### Add the same:

```
https://d2og2zrs47voou.cloudfront.net/order-status.html
```

> **Cognito is strict: must be HTTPS + exact path, no trailing slash.**

**👉 Save changes**

**⏳ Wait 30–60 seconds (Cognito propagation delay)**

#### 4️⃣ ✅ OAuth Settings 

Make sure these are enabled:

#### 1️⃣ OAuth 2.0 grant types Settings 

✔ Implicit grant (Recommanded)

OR 

✔ Authorization code grant (optional)

Because you are using:

```
response_type=token
```


#### 2️⃣ OpenID Connect scopes Settings 

✔ OpenID

✔ Email

✔ Profile

**If missing → Invalid request.**

**👉 Save changes**

**⏳ Wait 30–60 seconds (Cognito propagation delay)**

> **✅ This is correct for login with response_type=token.**

**Tip:** Only select these 3 scopes for now: openid, email, profile — leave phone optional if not needed.

#### 3️⃣ Check App Client Auth Flows (REFRESH_TOKEN_AUTH)

#### Path in AWS Console :

- AWS Console → Cognito → User Pools → select your pool

- App clients (left menu) → click Show details for your App Client

- Scroll to Authentication flows section

#### You should see exactly these 4 checked boxes:

✔ Choice-based sign-in → ALLOW_USER_AUTH

✔ Sign in with username and password → ALLOW_USER_PASSWORD_AUTH

✔ Sign in with secure remote password (SRP) → ALLOW_USER_SRP_AUTH

✔ Get new user tokens from existing authenticated sessions → ALLOW_REFRESH_TOKEN_AUTH

✅ These 4 are correct. No other boxes should be checked.

💡 This is exactly what Cognito needs to allow your front-end response_type=token flow.

**👉 Save changes**

**⏳ Wait 30–60 seconds (Cognito propagation delay)**

#### 4️⃣ Check App Client settings

- AWS Console → Cognito → User Pools → App clients → click Show details

- Ensure Client secret is Disabled ✅

In App Client settings:

| Setting       | Value             |
| ------------- | ----------------- |
| App type      | **Public client** |
| Client secret | ❌ Disabled        |

**If client secret is enabled → Invalid request**

> **If the secret is enabled, the browser flow cannot work and will throw “Invalid request”.**

**👉 Save changes**

**⏳ Wait 30–60 seconds (Cognito propagation delay)**

#### 5️⃣ Where to COPY your Cognito Domain (exact path)

You asked this directly, so here is the exact path 👇

#### 1️⃣ AWS Console path:

```
Cognito
→ User pools
→ Your user pool
→ App integration
→ Domain
```

#### 2️⃣ You will see something like:

```
Domain:
us-east-1qxbqjnjww.auth.us-east-1.amazoncognito.com
```

👉 Copy ONLY this part

❌ Do NOT include https://

❌ Do NOT include /login

**⚠️ Simple words: Do NOT add https:// inside the variable (your code already adds it)**


#### Example:

```
const COGNITO_DOMAIN = "charlie-cafe-admin.auth.us-east-1.amazoncognito.com";
```

**📌 Copy ONLY this part (no https, no /login)**

#### 3️⃣ Test the Login URL Directly

Once the above is confirmed:

```
https://us-east-1qxbqjnjww.auth.us-east-1.amazoncognito.com/login?response_type=token&client_id=393ld7o96bt7qlv0shp124osh5&scope=openid+email+profile&redirect_uri=https://d2og2zrs47voou.cloudfront.net/order-status.html
```

- Expected: Cognito login page shows

- Login → redirect → CloudFront /order-status.html

**✔️ If this works → frontend code will work too.**

#### ✅ Must Know Before Next Step

- OAuth Scopes: openid, email, profile

- OAuth Grant Type: Implicit grant enabled

- Auth flows: Only 4 boxes checked ✅

- Client secret: Disabled ✅

- Callback + sign-out URLs: Exact CloudFront URL ✅

#### 6️⃣ ✅ FINAL WORKING Frontend File(READY TO USE)

#### 1️⃣ dashboard.html File (Recommanded)

```
sudo nano /var/www/html/dashboard.html
```

#### 2️⃣ Code order-status.html

👉 Copy-paste this FULL file

👉 Replace ONLY the values marked with 🔁 REPLACE

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Cafe ☕ | Admin Dashboard</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- ================= BOOTSTRAP ================= -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- ================= ICONS ================= -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">

<!-- ================= CHART.JS ================= -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
/* =================================================
   GLOBAL THEME (DARK CAFE STYLE)
   ================================================= */
body {
    background-color: #0f0f10;
    color: #ffffff;
    font-family: 'Segoe UI', sans-serif;
}

/* =================================================
   SIDEBAR
   ================================================= */
.sidebar {
    width: 250px;
    background: #151515;
    min-height: 100vh;
    position: fixed;
    padding: 20px;
    display: none; /* Hidden until login */
}

.sidebar h4 {
    font-weight: 700;
}

.sidebar a {
    display: block;
    color: #bbb;
    padding: 12px;
    border-radius: 10px;
    text-decoration: none;
    margin-bottom: 8px;
}

.sidebar a.active,
.sidebar a:hover {
    background: #ff9800;
    color: #000;
}

/* =================================================
   MAIN CONTENT
   ================================================= */
.main {
    margin-left: 260px;
    padding: 25px;
    display: none; /* Hidden until login */
}

/* =================================================
   HEADER BAR
   ================================================= */
.top-bar {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.search-box input {
    background: #222;
    border: none;
    border-radius: 30px;
    padding: 10px 20px;
    color: white;
}

/* =================================================
   KPI CARDS
   ================================================= */
.kpi-card {
    border-radius: 20px;
    padding: 20px;
    color: white;
}

.bg-green { background: #1abc9c; }
.bg-purple { background: #9b59b6; }
.bg-blue { background: #3498db; }
.bg-orange { background: #e67e22; }

/* =================================================
   CONTENT CARDS
   ================================================= */
.card-dark {
    background: #1c1c1e;
    border-radius: 20px;
    padding: 20px;
}

/* =================================================
   TRENDING DRINKS
   ================================================= */
.drink-card {
    background: #1c1c1e;
    border-radius: 20px;
    padding: 15px;
    text-align: center;
}

.drink-card img {
    width: 100%;
    border-radius: 15px;
}

/* ================= DASHBOARD TABLE ================= */
.table-white {
    background: #fff;
    border-radius: 12px;
    overflow: hidden;
}
</style>
</head>

<body>

<!-- =================================================
     SIDEBAR (Hidden until login)
     ================================================= -->
<div class="sidebar" id="sidebar">
    <h4>☕ Charlie Cafe</h4>
    <p class="text-muted">Admin Dashboard</p>

    <!-- Navigation -->
    <a class="active"><i class="bi bi-speedometer2"></i> Dashboard</a>
    <a href="#"><i class="bi bi-cup-hot"></i> Menu</a>
    <a href="#"><i class="bi bi-bag-check"></i> Orders</a>
    <a href="#"><i class="bi bi-graph-up"></i> Analytics</a>
    <a href="#"><i class="bi bi-gear"></i> Settings</a>

    <hr>

    <!-- Logout -->
    <a onclick="logout()" style="cursor:pointer">
        <i class="bi bi-box-arrow-left"></i> Logout
    </a>
</div>

<!-- =================================================
     MAIN CONTENT (Hidden until login)
     ================================================= -->
<div class="main" id="mainContent">

<!-- ================= HEADER ================= -->
<div class="top-bar mb-4">
    <h5>Welcome, Admin 👋</h5>

    <div class="search-box">
        <input type="text" placeholder="🔍 Search orders, drinks">
    </div>

    <div>
        <i class="bi bi-bell"></i>
        <span class="ms-3">Charlie Cafe</span>
        <small class="text-muted">Admin</small>
    </div>
</div>

<!-- ================= KPI ROW ================= -->
<div class="row g-4 mb-4" id="kpiRow">
    <!-- KPI Cards dynamically populated -->
</div>

<!-- ================= CHART PLACEHOLDERS ================= -->
<div class="row g-4" id="chartRow">
    <div class="col-md-6">
        <div class="card-dark">
            <h5>Sales Overview</h5>
            <canvas id="salesChart"></canvas>
        </div>
    </div>

    <div class="col-md-6">
        <div class="card-dark">
            <h5>Orders Trend</h5>
            <canvas id="ordersChart"></canvas>
        </div>
    </div>
</div>

<!-- ================= ORDERS TABLE ================= -->
<div class="mt-5 card-dark p-3">
    <h5>📊 Recent Orders</h5>
    <div class="table-responsive">
        <table class="table table-bordered table-white">
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
</div>

<!-- ================= TRENDING DRINKS ================= -->
<div class="mt-5">
    <h5>🔥 Trending Drinks</h5>
    <div class="row g-4 mt-2" id="trendingDrinks">
        <!-- Static cards for now -->
    </div>
</div>

</div>

<!-- =================================================
     JAVASCRIPT: COGNITO + DASHBOARD LOGIC
     ================================================= -->
<script>
/* ================== CONFIG ================== */
const COGNITO_DOMAIN = "us-east-1qxbqjnjww.auth.us-east-1.amazoncognito.com";
const CLIENT_ID = "393ld7o96bt7qlv0shp124osh5";
const REDIRECT_URI = window.location.origin + "/dashboard.html";
const API_URL = "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/dashboard";

let salesChart, ordersChart, refreshTimer;

/* ================== AUTH ================== */
function parseJwt(token) {
    return JSON.parse(atob(token.split('.')[1]));
}

function isTokenExpired(token) {
    return parseJwt(token).exp * 1000 < Date.now();
}

function login() {
    const loginUrl =
        `https://${COGNITO_DOMAIN}/login?response_type=token&client_id=${CLIENT_ID}&scope=openid+email+profile&redirect_uri=${encodeURIComponent(REDIRECT_URI)}`;
    window.location.href = loginUrl;
}

function logout() {
    localStorage.removeItem("access_token");
    clearInterval(refreshTimer);
    const logoutUrl =
        `https://${COGNITO_DOMAIN}/logout?client_id=${CLIENT_ID}&logout_uri=${encodeURIComponent(REDIRECT_URI)}`;
    window.location.href = logoutUrl;
}

function handleRedirect() {
    const hash = window.location.hash.substring(1);
    if (!hash) return;
    const params = new URLSearchParams(hash);
    const token = params.get("access_token");
    if (token) {
        localStorage.setItem("access_token", token);
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

    document.getElementById("sidebar").style.display = "block";
    document.getElementById("mainContent").style.display = "block";

    loadData();
    refreshTimer = setInterval(loadData, 10000);
}

/* ================== DATA FETCH ================== */
function loadData() {
    const token = localStorage.getItem("access_token");
    if (!token || isTokenExpired(token)) return logout();

    fetch(API_URL, {
        headers: { Authorization: `Bearer ${token}` }
    })
    .then(res => {
        if (res.status === 401) logout();
        return res.json();
    })
    .then(data => {
        // Populate KPI Cards
        const kpiRow = document.getElementById("kpiRow");
        kpiRow.innerHTML = "";
        data.metrics.forEach(m => {
            kpiRow.innerHTML += `
                <div class="col-md-3">
                    <div class="kpi-card ${m.bgClass}">
                        <h6>${m.metric}</h6>
                        <h3>${m.count}</h3>
                    </div>
                </div>`;
        });

        // Populate Sales Chart
        if (salesChart) salesChart.destroy();
        salesChart = new Chart(document.getElementById("salesChart"), {
            type: 'line',
            data: {
                labels: data.sales.labels,
                datasets: [{
                    label: 'Sales',
                    data: data.sales.values,
                    backgroundColor:'rgba(255,152,0,0.3)',
                    borderColor:'orange',
                    fill:true
                }]
            }
        });

        // Populate Orders Chart
        if (ordersChart) ordersChart.destroy();
        ordersChart = new Chart(document.getElementById("ordersChart"), {
            type: 'bar',
            data: {
                labels: data.orders.labels,
                datasets: [{
                    label: 'Orders',
                    data: data.orders.values,
                    backgroundColor:'rgba(0,123,255,0.7)'
                }]
            }
        });

        // Populate Orders Table
        const ordersBody = document.getElementById("orders");
        ordersBody.innerHTML = "";
        data.recent_orders.forEach(o => {
            ordersBody.innerHTML += `
                <tr>
                    <td>${o.customer_name || '<em>Anonymous</em>'}</td>
                    <td>${o.item}</td>
                    <td>${o.quantity}</td>
                    <td>${o.created_at}</td>
                </tr>`;
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



#### 1️⃣ Edit file on EC2:

```
sudo nano /var/www/html/order-status.html
```

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



#### 8️⃣ Restart Apache (MANDATORY)

```
sudo systemctl restart httpd
```

#### 9️⃣ 🧪 HOW TO TEST

- 1️⃣ Open Incognito window

- 2️⃣ Open:

```
https://ALB-DNS/order-status.html
```

#### Example: 

```
http://charlie-cafe-alb-1050813156.us-east-1.elb.amazonaws.com/order-status.html
```

- 3️⃣ You should be redirected to:

```
https://us-east-1qxbqjnjww.auth.us-east-1.amazoncognito.com/login
```

- 4️⃣ Login with:

  - Username: 	cafeadmin

  - Password: (your permanent password)

- 5️⃣ After login:

  - ✅ Redirects back

  - ✅ Dashboard appears

  - ✅ No HTTP 400

**👍 This is production-style SPA + Cognito + API Gateway security.**

## Task 2️⃣ - Cognito Hosted UI Customize Design

> **⚠️ Note: Yes can change the Cognito Hosted UI design, but with limits.**

### ▶️ What Cognito Hosted UI DOES ALLOW

✔️ Change logo

✔️ Change background color

✔️ Change button color

✔️ Change brand color

✔️ Change favicon

✔️ Use light or dark theme

**👉 This is done via Cognito → App integration → Hosted UI → Customization**

### ▶️ What Cognito Hosted UI DOES NOT ALLOW

❌ Fully redesign layout with Bootstrap

❌ Add custom cards, sections, or animations

❌ Embed Cognito login inside your own page using HTML forms

❌ Add your own JS logic inside the Hosted UI

**👉 Cognito Hosted UI is not a normal HTML page you can edit.**

### ❓ Cognito login form INSIDE your own page

#### ❌ NO (Directly)

**AWS Cognito does not allow username/password submission from your own HTML for security reasons.**

**👉 This is by design.**

### 1️⃣ The CORRECT & PROFESSIONAL approach (used in real projects)

#### 1️⃣ Option A (RECOMMENDED – what you’re already using)

> **Use Cognito Hosted UI for login, then redirect back to your frontend page.**

#### Flow:

```
Your Cafe Frontend Page
   ↓
Redirect to Cognito Hosted UI
   ↓
Login
   ↓
Redirect back with JWT
```

#### This is:

- Secure

- AWS-recommended

- Production-ready

- Simple to maintain

#### 2️⃣ Option B (Advanced – NOT needed now)

- Use Cognito + Custom Auth + Amplify / SDK

- More complex

- More backend work

- Not required for your use case

**👉 My professional advice:**
**Stick with Hosted UI + redirect (Option A).**

**✅ PHASE 4 STATUS**

> **🟢 PHASE 4 COMPLETE & VERIFIED**

---

## 🔐 PHASE 5️⃣ — SECURE API GATEWAY AUTH (MOST IMPORTANT) 

### 1️⃣ Create Cognito Authorizer

- Go to AWS Console → API Gateway → REST API → YOUR_API

- On left panel → Authorizers → Create Authorizer

- Fill the form:

| Field             | Value                              |
| ----------------- | ---------------------------------- |
| Name              | `CognitoAuthorizer`                |
| Type              | **Cognito**                        |
| Cognito User Pool | Select your Cafe Cognito User Pool |
| Token Source      | `Authorization`                    |
| Token Validation  | Leave blank or optional            |

**✅ Create authorizer**

> **✅ This authorizer will validate JWTs automatically.**

### 2️⃣ CONFIGURE API GATEWAY

- **AWS Console → API Gateway → REST API → /order-status**

#### 1️⃣ Resource & Method

- Go to Resources → /order-status

- If GET method does not exist → click Actions → Create Method → GET

```
GET /order-status
```

- Select Lambda Proxy Integration

- Lambda function → OrderStatusLambda

#### 2️⃣ Cognito Authorizer (JWT validation)

- **Go to: API Gateway → Your API → Authorizers → Create**

- **Name:** CognitoAuthorizer

- **Type:** Cognito

- Select your Cafe Cognito User Pool

- **Token source:** Authorization

- Save ✅

> **This does NOT enable CORS — this only validates JWT.**

#### 3️⃣ Attach Authorizer to GET Method

- **Go to Resources → /order-status → GET → Method Request**

- **Find Authorization → select CognitoAuthorizer**

- Select CognitoAuthorizer from the dropdown

- Save ✅

> **This ensures all GET requests require a valid JWT.**

#### 4️⃣ Enable CORS (Cross-Origin Resource Sharing)

> **These are two separate things — enabling CORS is for frontend browser calls.**

- Click GET → Actions → Enable CORS

- A popup appears:

  - Check “Replace existing CORS headers” ✅

- Click Enable CORS

- Confirm popup: “Yes, replace existing headers” ✅

> **This allows your frontend JS (from CloudFront) to call API Gateway without CORS errors.**


#### 5️⃣ Deploy API

- **Click Actions → Deploy API**

- **Stage: prod (or admin if you created a new stage)**

- **Save Invoke URL**

#### 📌 Copy new endpoint API URL:

```
https://API_ID.execute-api.REGION.amazonaws.com/prod/order-status
```
> **OR**

```
https://xxx.execute-api.region.amazonaws.com/admin/order-status
```

#### 👉 Paste this into frontend once

#### 🔁 Update frontend:

```
API_URL = ".../prod/order-status"
```

> **OR**

```
API_URL = ".../admin/order-status"
```

#### ✅ Result:

- ❌ No login → 401


- ✅ Login → data loads

### ✅ KEY POINTS

| Task                     | Done? | Notes                             |
| ------------------------ | ----- | --------------------------------- |
| Cognito authorizer       | ✅     | Validates JWT                     |
| Attach authorizer to GET | ✅     | Required for /order-status        |
| Enable CORS              | ✅     | Needed for frontend browser calls |
| Deploy API               | ✅     | Required after changes            |
| Update frontend API_URL  | ✅     | Matches the stage URL             |


**✅ PHASE 5 STATUS**

> **🟢 PHASE 5 COMPLETE & VERIFIED**

---

## 🔐 PHASE 6️⃣ — BACKEND DATE FILTER (LAMBDA)

### 🎯 Goal

- Validate JWT token via API Gateway.

- Filter orders by date in Lambda.

- Return metrics and recent orders.

- Ensure no frontend hacks are needed.

- Fully test before moving to next phase.

### 1️⃣ CREATE OR UPDATE LAMBDA

- **AWS Console → Lambda → Create Function → Author from scratch**

- **Function name:** OrderStatusLambda

- **Runtime:** Python 3.12

- **Permissions:** Create new role with basic Lambda permissions

### 2️⃣ FINAL LAMBDA LOGIC

```
params = event.get("queryStringParameters") or {}
filter_date = params.get("date")

sql = """
SELECT customer_name, item, quantity, table_number, created_at
FROM orders
"""
values = []

if filter_date:
    sql += " WHERE DATE(created_at) = %s"
    values.append(filter_date)

sql += " ORDER BY created_at DESC LIMIT 20"

cursor.execute(sql, values)
orders = cursor.fetchall()
```

> **🚫 No more backend changes needed**

#### ✅ Result:

```
/order-status?date=YYYY-MM-DD
```

✅ returns filtered orders


### ✅ FINAL LAMBDA CODE (Python 3.12)

> 🔁 This is a drop-in replacement
> Nothing else needs to change

```
import json
import os
import pymysql

# ================= CONFIG =================
DB_HOST = os.environ['DB_HOST']
DB_USER = os.environ['DB_USER']
DB_PASS = os.environ['DB_PASS']
DB_NAME = os.environ['DB_NAME']

# ================= DB CONNECTION =================
def get_connection():
    return pymysql.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASS,
        db=DB_NAME,
        cursorclass=pymysql.cursors.DictCursor
    )

# ================= LAMBDA HANDLER =================
def lambda_handler(event, context):
    conn = None
    cursor = None

    try:
        params = event.get("queryStringParameters") or {}
        filter_date = params.get("date")

        conn = get_connection()
        cursor = conn.cursor()

        # ---------- RECENT ORDERS ----------
        sql = "SELECT customer_name, item, quantity, created_at FROM orders"
        values = []

        if filter_date:
            sql += " WHERE DATE(created_at) = %s"
            values.append(filter_date)

        sql += " ORDER BY created_at DESC LIMIT 20"
        cursor.execute(sql, values)
        recent_orders = cursor.fetchall()

        # ---------- METRICS (DATE-AWARE) ----------
        metrics = []

        where_clause = ""
        metric_values = []

        if filter_date:
            where_clause = " WHERE DATE(created_at) = %s"
            metric_values.append(filter_date)

        cursor.execute(
            f"SELECT COUNT(*) AS count FROM orders{where_clause}",
            metric_values
        )
        metrics.append({
            "metric": "Total Orders",
            "count": cursor.fetchone()['count']
        })

        cursor.execute(
            f"SELECT SUM(quantity) AS count FROM orders{where_clause}",
            metric_values
        )
        metrics.append({
            "metric": "Total Items Sold",
            "count": cursor.fetchone()['count'] or 0
        })

        cursor.execute(
            f"SELECT COUNT(DISTINCT customer_name) AS count FROM orders{where_clause}",
            metric_values
        )
        metrics.append({
            "metric": "Customers",
            "count": cursor.fetchone()['count']
        })

        # ---------- RESPONSE ----------
        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "Authorization",
                "Access-Control-Allow-Methods": "GET"
            },
            "body": json.dumps({
                "metrics": metrics,
                "recent_orders": recent_orders
            }, default=str)
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({"error": str(e)})
        }

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()
```

### 3️⃣ 🔐 Add Environment Variables

```
DB_HOST = <your-rds-endpoint>
DB_USER = admin
DB_PASS = <your-db-password>
DB_NAME = cafe
```

> **⚠️ Make sure DB_HOST points to your RDS MySQL/MariaDB instance.**

### 4️⃣ FINAL TEST TEST LAMBDA & API (MATCHES YOUR GUIDE)

#### 1️⃣ ❌ Without token

```
curl https://API_ID.execute-api.REGION.amazonaws.com/prod/order-status
```

#### ✅ Expected:

```
401 Unauthorized
```

#### 2️⃣ ✅ With Frontend Token

- Login via Cognito Hosted UI

- Get access_token

- Make GET request with header:

```
curl -H "Authorization: Bearer <access_token>" \
https://API_ID.execute-api.REGION.amazonaws.com/prod/order-status
```

#### ✅ Expected:

```
JSON response with metrics + recent orders
```

#### 3️⃣ Date Filter Test

```
curl -H "Authorization: Bearer <access_token>" \
"https://API_ID.execute-api.REGION.amazonaws.com/prod/order-status?date=2026-01-17"
```

#### ✅ Expected: 

```
Only orders for 2026-01-17 returned
```

**✅ Metrics counts match filtered orders**

#### 4️⃣ Verify Auto Refresh / Chart in Frontend

- Open order-status.html

- Enter date in filter box

- Click Filter

- Metrics + table + chart should update correctly

- Spinner shows loading

### 📣 Simple & Easy way test 

#### 1️⃣ Login & Token Issued

- Open your Cafe Dashboard frontend (order-status.html).

- Click Login.

- You should be redirected to Cognito Hosted UI.

- Enter Admin credentials.

- After login, you are redirected back to the dashboard.

- Open browser DevTools → Application → Local Storage.

  - **✅ access_token should exist.**

**If no token → STOP, check Cognito setup.**

#### 2️⃣ Dashboard Loads

- After login, the dashboard content should appear (metrics + table).

- Metrics should show Total Orders, Total Items Sold, Customers.

- Orders table should populate with recent orders.

- Spinner should appear while loading, then hide.

- **✅ If dashboard is blank → STOP, check Lambda/API response.**

#### 3️⃣ Auto Refresh Works

- Wait ~10 seconds (or the interval set in frontend).

- Dashboard metrics and table should update automatically.

- Open DevTools → Network tab

  - You should see GET requests to /order-status fired every 10 seconds.

- **✅ If auto refresh doesn’t work → check setInterval(loadData, 10000) in frontend JS.**

#### 4️⃣ Date Filter Works

- On dashboard, select a date in the date picker.

- Click Filter.

- Dashboard metrics + table should update only for that date.

- Network tab → Confirm request URL:

```
https://API_ID.execute-api.REGION.amazonaws.com/prod/order-status?date=YYYY-MM-DD
```

- **✅ If metrics or table show wrong data → check Lambda filter code.**

#### 5️⃣ Chart Works

- Chart below metrics should update matching the filtered data.

- Check bars/lines correspond to orders/items counts.

- Change date → chart updates accordingly.

- **✅ If chart does not update → check frontend chart destroy/create logic.**

**✔ Everything works → Phase Complete**

### ✅ PHASE 6 COMPLETION CHECKLIST

✔️ Lambda created/updated

✔️ Environment variables set correctly

✔️ JWT validation works (401 if missing)

✔️ Date filter works (?date=YYYY-MM-DD)

✔️ Metrics calculated correctly

✔️ Recent orders table updates

✔️ Frontend chart + auto-refresh works

✔️ Tested manually via API & frontend


**✅ PHASE 6 STATUS**

> **🟢 PHASE 6 COMPLETE & VERIFIED**

---

## 🔐 PHASE 7️⃣ PRINTING (FRONTEND ONLY)

### 🖨️ Printing System 1 — Browser Print (Frontend-only)

#### How it works

✔️ Uses window.print()

✔️ Browser converts HTML → PDF / Printer

✔️ No Lambda

✔️ No API call

✔️ Instant

#### Best for

✔️ Staff

✔️ Quick receipt

✔️ Daily summary

✔️ Ad-hoc printing

✅ Fast

✅ No AWS cost

❌ Not automated

❌ Not official report

| Printing Type    | Where it runs | Technology         | Purpose                           |
| ---------------- | ------------- | ------------------ | --------------------------------- |
| 🖨 Browser Print | Frontend only | `window.print()`   | Quick, instant print / save PDF   |
| 📄 Lambda PDF    | Backend       | ReportLab + Lambda | Official, stored, branded reports |

#### 🧠 SIMPLE MENTAL MODEL

```
STAFF USES → Browser Print
ADMIN USES → Lambda PDF
```

#### ⚠️Why?

#### Browser print:
> **PHASE 7️⃣ **AWS  Charlie Cafe — Secure Admin Order Dashboard**

✔️ Fast

✔️ No backend cost

✔️ No S3

✔️ No permissions

✔️ Good for receipts, daily summaries

#### Lambda PDF:

> **PHASE 5️⃣ & 6️⃣ **☕ AWS CAFE — SALES ANALYTICS & REPORTING SYSTEM**

✔️ Professional layout

✔️ Stored in S3

✔️ Monthly / daily automation

✔️ Logo, tables, profit

✔️ Admin-only (RBAC)

**✅ You are building a REAL PRODUCTION SYSTEM**

### 🧭 WHAT THIS PHASE DOES (CLEAR SCOPE)

This phase allows:

✅ Print all orders

✅ Print today summary

✅ Print using browser PDF / printer

✅ Uses existing order-status data

✅ NO backend changes



### 1️⃣ — CONFIRM FILE YOU WILL MODIFY (NO JUMP)

#### You must edit this file:

```
/var/www/html/order-status.html
```

✔ Same file where orders are shown

✔ Same file used by staff/admin

### 2️⃣ — BACKUP YOUR FILE (MANDATORY)

#### Run:

```
sudo cp /var/www/html/order-status.html /var/www/html/order-status-backup.html
```

### 3️⃣ — ADD PRINT BUTTONS (EXACT LOCATION)

#### 🔍 FIND THIS IN YOUR FILE:

```
<h3>Order Status</h3>
```

#### ⬇️ IMMEDIATELY BELOW IT, PASTE THIS:

```
<div class="d-flex gap-2 mb-3">
  <button class="btn btn-outline-dark" onclick="printAllOrders()">
    🖨️ Print All Orders
  </button>

  <button class="btn btn-outline-success" onclick="printTodaySummary()">
    📄 Print Today Summary
  </button>
</div>
```

❌ Do NOT remove anything

❌ Do NOT rename functions

### 4️⃣ — ADD PRINT-ONLY CSS (VERY IMPORTANT)

#### 🔍 FIND:

```
</head>
```

#### ⬆️ JUST ABOVE IT, PASTE:

```
<style>
@media print {

  body {
    background: #fff !important;
  }

  button,
  select,
  .no-print {
    display: none !important;
  }

  table {
    width: 100%;
    border-collapse: collapse;
  }

  th, td {
    border: 1px solid #000;
    padding: 6px;
    font-size: 12px;
  }

  h3 {
    text-align: center;
  }
}
</style>
```

✔ Ensures clean PDF

✔ Hides buttons automatically

### 5️⃣ — ADD JAVASCRIPT PRINT LOGIC

#### 🔍 FIND THE END OF YOUR <script> TAG

> **🔴 (OR CREATE ONE IF NOT EXISTS)**

#### ⬇️ PASTE THIS FULL CODE:

```
<script>
function printAllOrders() {
  window.print();
}

function printTodaySummary() {

  const rows = document.querySelectorAll("#ordersTable tbody tr");
  let today = new Date().toISOString().split("T")[0];

  let totalOrders = 0;
  let totalAmount = 0;

  rows.forEach(row => {
    const orderDate = row.dataset.date;
    const amount = parseFloat(row.dataset.total);

    if (orderDate === today) {
      totalOrders++;
      totalAmount += amount;
    }
  });

  const summaryHTML = `
    <h3>☕ Cafe Daily Summary</h3>
    <p><strong>Date:</strong> ${today}</p>
    <p><strong>Total Orders:</strong> ${totalOrders}</p>
    <p><strong>Total Sales:</strong> ${totalAmount}</p>
  `;

  const original = document.body.innerHTML;
  document.body.innerHTML = summaryHTML;
  window.print();
  document.body.innerHTML = original;
}
</script>
```

❌ Do NOT change function names

❌ Do NOT move code

### 6️⃣ — ENSURE TABLE HAS REQUIRED ATTRIBUTES

#### 🔍 FIND YOUR ORDERS TABLE ROW LOOP

Example:

```
<tr>
```

#### 🔁 REPLACE WITH THIS:

```
<tr data-date="2026-01-17" data-total="15">
```

#### ⚠️ IMPORTANT

- These values must already exist in JS when rendering rows.

Example in JS:

```
row.dataset.date = order.order_date;
row.dataset.total = order.total_amount;
```

✔ Required for today summary print

### 🧾 ✅ FINAL UPDATED order-status.html (WITH PRINTING + COMMENTS)

#### 📍 Location:

```
/var/www/html/order-status.html
```

#### 1️⃣ BACKUP order-status.html

```
sudo cp /var/www/html/order-status.html /var/www/html/order-status-backup.html
```

#### ♻️ RESTORE IF NEEDED (OPTIONAL)

```
sudo cp /var/www/html/order-status-backup.html /var/www/html/order-status.html
```

#### 2️⃣ Replace your entire file with this

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Cafe ☕ | Order Status</title>
<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- ================== BOOTSTRAP ================== -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- ================== CHART.JS ================== -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
/* ================== MAIN BACKGROUND ================== */
body {
  min-height: 100vh;
  background:
    linear-gradient(rgba(0,0,0,.55), rgba(0,0,0,.55)),
    url("https://images.unsplash.com/photo-1509042239860-f550ce710b93");
  background-size: cover;
  background-position: center;
  background-attachment: fixed;
}

/* ================== DASHBOARD ================== */
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

/* ================== PRINT CSS (PHASE 7) ================== */
@media print {

  body {
    background: #fff !important;
  }

  nav,
  button,
  input,
  canvas {
    display: none !important;
  }

  table {
    width: 100%;
    border-collapse: collapse;
  }

  th, td {
    border: 1px solid #000;
    padding: 6px;
    font-size: 12px;
  }

  h3 {
    text-align: center;
  }
}
</style>
</head>

<body>

<!-- ================== NAVBAR ================== -->
<nav class="navbar navbar-dark bg-dark" id="navbar" style="display:none">
  <div class="container">
    <span class="navbar-brand">☕ Charlie Cafe Admin</span>
    <button class="btn btn-danger btn-sm" onclick="logout()">Logout</button>
  </div>
</nav>

<!-- ================== DASHBOARD ================== -->
<div class="container my-4" id="dashboard">

<!-- ================== FILTER ROW ================== -->
<div class="row mb-3">
  <div class="col-md-3">
    <input type="date" id="filterDate" class="form-control">
  </div>
  <div class="col-md-2">
    <button class="btn btn-primary w-100" onclick="loadData()">Filter</button>
  </div>
</div>

<!-- ================== PRINT BUTTONS (PHASE 7) ================== -->
<div class="row mb-3">
  <div class="col text-end">
    <button class="btn btn-outline-dark me-2" onclick="printAllOrders()">
      🖨️ Print All Orders
    </button>
    <button class="btn btn-outline-success" onclick="printTodaySummary()">
      📄 Print Today Summary
    </button>
  </div>
</div>

<!-- ================== LOADER ================== -->
<div class="text-center my-3" id="loader" style="display:none">
  <div class="spinner-border text-warning"></div>
  <p class="mt-2">Loading...</p>
</div>

<!-- ================== METRICS ================== -->
<div class="row mb-4" id="metrics"></div>

<!-- ================== CHART ================== -->
<canvas id="orderChart" height="100"></canvas>

<!-- ================== ORDERS TABLE ================== -->
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

/* 🔁 REPLACE WITH YOUR OWN VALUES IF CHANGED */
const COGNITO_DOMAIN = "us-east-1qxbqjnjww.auth.us-east-1.amazoncognito.com";
const CLIENT_ID = "393ld7o96bt7qlv0shp124osh5";
const REDIRECT_URI = "https://d2og2zrs47voou.cloudfront.net/order-status.html";

/* 🔴 REPLACE API ID WHEN READY */
const API_URL = "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/order-status";

let chart, refreshTimer;

/* ================== AUTH ================== */
function parseJwt(token) {
  return JSON.parse(atob(token.split('.')[1]));
}

function isTokenExpired(token) {
  return parseJwt(token).exp * 1000 < Date.now();
}

function login() {
  window.location.href =
    `https://${COGNITO_DOMAIN}/login?response_type=token&client_id=${CLIENT_ID}&scope=openid+email+profile&redirect_uri=${encodeURIComponent(REDIRECT_URI)}`;
}

function logout() {
  localStorage.removeItem("access_token");
  clearInterval(refreshTimer);
  window.location.href =
    `https://${COGNITO_DOMAIN}/logout?client_id=${CLIENT_ID}&logout_uri=${encodeURIComponent(REDIRECT_URI)}`;
}

function handleRedirect() {
  const hash = window.location.hash.substring(1);
  if (!hash) return;
  const token = new URLSearchParams(hash).get("access_token");
  if (token) {
    localStorage.setItem("access_token", token);
    window.location.hash = "";
  }
}

/* ================== DASHBOARD ================== */
function showDashboard() {
  const token = localStorage.getItem("access_token");
  if (!token || isTokenExpired(token)) return login();

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
  const date = document.getElementById("filterDate").value;
  if (date) url += "?date=" + date;

  fetch(url, { headers: { Authorization: "Bearer " + token }})
  .then(r => r.json())
  .then(data => {

    document.getElementById("loader").style.display = "none";

    data.metrics.forEach(m => {
      metrics.innerHTML += `
        <div class="col-md-3 mb-2">
          <div class="card-metric text-center fw-bold">${m.metric}<br>${m.count}</div>
        </div>`;
    });

    const items = {};
    data.recent_orders.forEach(o => {
      orders.innerHTML += `
        <tr>
          <td>${o.customer_name}</td>
          <td>${o.item}</td>
          <td>${o.quantity}</td>
          <td>${o.created_at}</td>
        </tr>`;
      items[o.item] = (items[o.item] || 0) + o.quantity;
    });

    if (chart) chart.destroy();
    chart = new Chart(orderChart, {
      type: 'bar',
      data: { labels: Object.keys(items), datasets: [{ label: 'Orders per Item', data: Object.values(items) }] }
    });
  });
}

/* ================== PRINTING (PHASE 7) ================== */
function printAllOrders() {
  window.print();
}

function printTodaySummary() {
  let today = new Date().toISOString().split("T")[0];
  let totalQty = 0;

  document.querySelectorAll("#orders tr").forEach(row => {
    if (row.children[3].innerText.startsWith(today)) {
      totalQty += parseInt(row.children[2].innerText);
    }
  });

  const html = `
    <h3>☕ Charlie Cafe – Daily Summary</h3>
    <p><strong>Date:</strong> ${today}</p>
    <p><strong>Total Items Sold:</strong> ${totalQty}</p>
  `;

  const original = document.body.innerHTML;
  document.body.innerHTML = html;
  window.print();
  document.body.innerHTML = original;
  location.reload();
}

/* ================== INIT ================== */
handleRedirect();
showDashboard();
</script>

</body>
</html>
```

#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```

#### 4️⃣ Fix File Permissions

```
sudo chown apache:apache /var/www/html/order-status.html
```

```
sudo chmod 644 /var/www/html/order-status.html
```

#### 5️⃣ Restart Apache (MANDATORY)

```
sudo systemctl restart httpd
```

#### 6️⃣ Open page in browser

```
http://EC2 Public IP/order-status.html
```

### 7️⃣ — TEST PRINT ALL ORDERS (MANDATORY)

1️⃣ Open browser

2️⃣ Go to Order Status Page

3️⃣ Click 🖨️ Print All Orders

#### EXPECTED RESULT:

✔ Browser print dialog opens

✔ Orders table visible

✔ Buttons hidden

✔ Can save as PDF

### 8️⃣ — TEST TODAY SUMMARY PRINT (MANDATORY)

- **1️⃣ Click 📄 Print Today Summary**

#### EXPECTED RESULT:

✔ Only summary visible

✔ Correct date

✔ Correct totals

✔ Clean PDF layout

**❌ If totals = 0 → your data-date missing**

### 🧪  FINAL CONFIRMATION CHECKLIST

| Item                    | Status |
| ----------------------- | ------ |
| No backend used         | ✅      |
| Print dialog opens      | ✅      |
| PDF save works          | ✅      |
| Buttons hidden in print | ✅      |
| Today summary accurate  | ✅      |


### 🟢 PHASE 7 FINAL STATUS

✅ PHASE 7 COMPLETE

✅ FULLY TESTED

✅ NO SKIPPED STEPS

✅ SAFE TO MOVE FORWARD


**✅ PHASE 7 STATUS**

> **🟢 PHASE 7 COMPLETE & VERIFIED**

---

## 🔐 PHASE 8️⃣ — FINAL SECURITY FLOW (MENTAL MODEL)

### 🖊 Goal

Secure your APIs using Cognito JWT, so:

❌ No token → blocked

❌ Invalid token → blocked

✅ Admin → allowed

✅ Staff → allowed/blocked based on Lambda logic

### 🧠 WHAT YOU ARE BUILDING (MENTAL MODEL)

```
Browser
  ↓
User logs in (Cognito Hosted UI or Custom UI)
  ↓
Cognito returns JWT (ID token)
  ↓
Frontend sends JWT in Authorization header
  ↓
API Gateway Cognito Authorizer validates JWT
  ↓
Lambda receives verified claims
```

### 🧱 PREREQUISITES (DO NOT SKIP)

Before starting PHASE 8, you MUST already have:

✔ Cognito User Pool

✔ At least one user created

✔ API Gateway already created

✔ Lambda already connected to API

If ANY of these are missing, STOP and tell me.

### 🔐 1️⃣  — VERIFY COGNITO USER POOL (NO CONFIG YET)

#### 1️⃣ Open AWS Console

- Go to:

```
AWS Console → Cognito → User Pools
```

#### 2️⃣ Click your User Pool

- Example name:

```
CafeUserPool
```

#### 3️⃣ Verify these EXIST (do not change yet)

- Users tab → at least 1 user

- App integration tab → App client exists

- Domain → configured (for Hosted UI)

✔ If all exist → continue

❌ If missing → STOP

### 🔐 2️⃣ — CREATE COGNITO GROUPS (VERY IMPORTANT)

- **Inside User Pool → Click Groups**

- **Click Create group**

#### Create FIRST group:

```
Group name: Admin
Description: Cafe administrators
```

- **Click Create group**

✔ Groups created
❌ Do not skip

### 👤 3️⃣ — ADD USERS TO GROUPS (MANDATORY)

- **Cognito → Users**

- Click a user (your email/username)

- Click Add to group

- Select:

```
Admin
```

- Click Add

> **You must have at least one Admin user**

### 🌐 4️⃣ — CONFIGURE APP CLIENT (JWT ISSUED HERE)

- Cognito → App integration

- Click App clients

- Click your app client

- VERIFY THESE SETTINGS (DO NOT GUESS)

✔ Enable sign-in API for server-based authentication

✔ OAuth 2.0 enabled

Under OAuth flows:

```
✔ Authorization code grant
```

#### Under OAuth scopes:

```
✔ openid
✔ email
✔ profile
```

- Click Save changes

### 🌐 5️⃣ — CONFIGURE HOSTED UI (FOR LOGIN TEST)

- Cognito → App integration → Domain

- Verify domain exists like:

```
https://cafe-auth.auth.ap-south-1.amazoncognito.com
```

**✔️ Copy this domain — you will use it.**

### 🔑 6️⃣ — GET JWT TOKEN (MANDATORY TEST)

#### 1️⃣ Open browser (new tab)

#### Paste this (replace values):

```
https://YOUR_DOMAIN/login?
response_type=token&
client_id=YOUR_CLIENT_ID&
redirect_uri=https://jwt.io
```

#### Example:

```
https://cafe-auth.auth.ap-south-1.amazoncognito.com/login?response_type=token&client_id=abc123&redirect_uri=https://jwt.io
```

#### 2️⃣ Login with Admin user

You will be redirected to jwt.io

#### 3️⃣ COPY ID TOKEN (IMPORTANT)

It looks like: 

```
eyJraWQiOiJLT...
```

**⚠️ Copy ONLY the id_token, not access_token.**

> **STOP here if token is not received.**

### 🧪 7️⃣ — VERIFY TOKEN CONTENT (NO SKIP)

- On jwt.io

- Paste ID token

#### Verify payload contains:

```
{
  "email": "...",
  "cognito:groups": ["Admin"],
  "iss": "https://cognito-idp..."
}
```

✔ If cognito:groups exists → continue

❌ If missing → user NOT in group → FIX STEP 3

#### 🚪 8️⃣ — CREATE API GATEWAY COGNITO AUTHORIZER
> **If you did not create then follow this step... otherwisse leave it**

- API Gateway → Your API

- Click Authorizers

- Click Create authorizer

#### Fill EXACTLY:

```
Name: CafeCognitoAuthorizer
Type: Cognito
Cognito User Pool: CafeUserPool
Token source: Authorization
```

- Click Create

### 🔗 9️⃣ — ATTACH AUTHORIZER TO API METHOD

- **API Gateway → Resources**

- **Select endpoint:**

```
GET /analytics
```

- **Click Method Request**

- **Authorization:**

```
Cognito User Pool Authorizer
```

- **Select:**

```
CafeCognitoAuthorizer
```

- Click Save

### 🚀 🔟 — DEPLOY API (DO NOT SKIP)

- **API Gateway → Deploy API**

- **Stage:**

```
prod
```

- Click Deploy

### 🧪 1️⃣1️⃣ — TEST ❌ NO JWT (EXPECTED FAIL)

#### CURL / Postman / Browser test

#### Request:

```
GET https://API_ID.execute-api.REGION.amazonaws.com/prod/analytics
```

#### EXPECTED RESULT:

```
401 Unauthorized
```

✔ Correct → continue

❌ If allowed → authorizer NOT attached

### 🧪 1️⃣2️⃣ — TEST ❌ INVALID JWT

#### Add header:

```
Authorization: invalidtoken123
```

#### EXPECTED:

```
401 Unauthorized
```

✔ Correct → continue

### 🧪 1️⃣3️⃣ — TEST ✅ ADMIN JWT (EXPECTED SUCCESS)

#### Add header:

```
Authorization: Bearer YOUR_ID_TOKEN
```

#### EXPECTED:

```
200 OK
```

✔ Lambda executes
✔ Data returned

### 🧪 1️⃣4️⃣ — TEST STAFF USER (SECURITY VALIDATION)

Login as Staff user, get ID token again.

#### Call API with:

```
Authorization: Bearer STAFF_TOKEN
```

#### RESULT DEPENDS ON LAMBDA:

- Analytics Lambda → ❌ 403

- Orders Lambda → ✅ 200

**✔ This proves end-to-end security**

### 🧠 FINAL SECURITY FLOW (CONFIRMED)

```
No token        → API Gateway blocks (401)
Invalid token   → API Gateway blocks (401)
Valid token     → Claims injected
Admin group     → Lambda allows
Staff group     → Lambda restricted
```

### 🧪 PHASE 8 TEST CHECKLIST (ALL MUST PASS)

✔ Token issued

✔ Groups inside JWT

✔ Authorizer attached

✔ No token blocked

✔ Invalid token blocked

✔ Admin allowed

✔ Staff restricted

### ✅ PHASE 8 STATUS

🟢 PHASE 8 COMPLETE

🟢 PHASE 8 FULLY TESTED

🟢 SAFE TO MOVE NEXT


**✅ PHASE 8 STATUS**

> **🟢 PHASE 8 COMPLETE & VERIFIED**

---

## 🔐 PHASE 9️⃣ — VERIFICATION (DO NOT SKIP)


### Test 1 — API Direct (NO LOGIN)

#### Open:

```
https://xxxxx.execute-api.region.amazonaws.com/admin/order-status
```

#### ✅ Result:

```
401 Unauthorized
```

### Test 2 — Dashboard

- Open order-status.html

- Click Login

- Cognito page opens

- Login as admin

- Redirect back

- Orders load

✅ SUCCESS


**✅ PHASE 9 STATUS**

> **🟢 PHASE 9 COMPLETE & VERIFIED**

---

### 🏁 FINAL SUMMARY

| Area             | Status         |
| ---------------- | -------------- |
| Frontend code    | ✅ Written once |
| Backend code     | ✅ Written once |
| Cognito          | ✅ Config only  |
| API Security     | ✅ Enforced     |
| Date filter      | ✅ Backend      |
| Printing         | ✅ Frontend     |
| Repetition       | ❌ Removed      |
| Confusion        | ❌ Removed      |
| Production-ready | ✅ YES          |

---
---



# SECTION 2️⃣- 🏷️ Order Status – Advanced Features Guide

#### Includes:

#### 1️⃣ CSV Export (Backend + Frontend)


#### 2️⃣ Admin vs Staff Roles (Cognito + Lambda + Frontend)


---

## PHASE 1️⃣ - CSV Export (Backend + Frontend)

### 1️⃣ CSV EXPORT (Backend + Frontend)

#### 🎯 Goal: Allow admin to export all order data or filtered by date to a CSV file.

### 🔹 Backend Steps (Lambda)

#### Step 1 — Open your Lambda

- **AWS Console → Lambda → GetOrderStatusAdminLambda**

#### Step 2 — Install CSV library (Python)

#### If using Python:

```
# Use Lambda Layer for pandas or csv
```

#### Step 3 — Modify Lambda to add CSV output

#### Add query parameter:

```
params = event.get("queryStringParameters") or {}
export_csv = params.get("export") == "true"
```

#### Fetch orders (with date filter if needed):

```
filter_date = params.get("date")
# Apply filter logic as shown in Task 3
```

#### If export_csv == True, generate CSV:

```
import csv
import io

if export_csv:
    output = io.StringIO()
    writer = csv.writer(output)
    writer.writerow(["Customer", "Item", "Quantity", "Table", "Date"])
    for o in orders:
        writer.writerow([o["customer_name"], o["item"], o["quantity"], o["table_number"], o["created_at"]])
    
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "text/csv",
            "Content-Disposition": "attachment; filename=orders.csv",
            "Access-Control-Allow-Origin": "*"
        },
        "body": output.getvalue()
    }
```

✔ Now the Lambda supports CSV export.

### 🔹 Frontend Steps

#### Step 1 — Add Export Button

#### Inside dashboard HTML:

```
<button class="btn btn-success mt-3" onclick="exportCSV()">Export CSV</button>
```

#### Step 2 — Add JS function

```
function exportCSV(){
  let url = API_URL + "?export=true";
  const date = filterDate.value;
  if(date) url += "&date=" + date;

  const token = localStorage.getItem("token");
  fetch(url, {
    headers:{ Authorization: "Bearer " + token }
  })
  .then(res => res.blob())
  .then(blob => {
    const link = document.createElement("a");
    link.href = window.URL.createObjectURL(blob);
    link.download = "orders.csv";
    link.click();
  });
}
```

✔ Users can now download CSV of filtered or all orders.


**✅ PHASE 1 STATUS**

> **🟢 PHASE 1 COMPLETE & VERIFIED**

---

## PHASE 2️⃣ - Admin vs Staff Roles (Cognito + Lambda + Frontend)

### 2️⃣ ADMIN VS STAFF ROLES

### 🎯 Goal

- **Admin → Full access (metrics + orders + export)**

- **Staff → Limited access (orders only, no export, no metrics)**

### 🔹 AWS Cognito Steps

#### Step 1 — Create Groups

```
Cognito → User Pool → Groups → Create Group
```

- Group 1: Admin

- Group 2: Staff

#### Step 2 — Assign Users to Groups

```
Users → select user → Add to group → Admin/Staff
```

#### Step 3 — Update Lambda for Role Check

```
# After JWT validation
user_groups = user.get("cognito:groups", [])

if "Admin" in user_groups:
    role = "Admin"
elif "Staff" in user_groups:
    role = "Staff"
else:
    return {"statusCode": 403, "body": "Access denied"}
```

### 🔹 Lambda – Role-Based Permissions

#### Admin

- View metrics

- View orders

- Export CSV

#### Staff

- View orders only

- Cannot export CSV

#### Modify Lambda:

```
if export_csv and "Admin" not in user_groups:
    return {"statusCode": 403, "body": "Admins only"}
```

### 🔹 Frontend – Role-Based UI

#### Step 1 — Hide Buttons for Staff

```
if(!userGroups.includes("Admin")){
    document.querySelector("#exportCSVButton").style.display = "none";
    document.querySelector("#metrics").style.display = "none";
}
```

✔ Now Staff only sees orders table.

### ✅ Verification

1️⃣ Admin user logs in → sees metrics + orders + CSV export → can download CSV

2️⃣ Staff user logs in → sees only orders → cannot download CSV → metrics hidden

--

### 🏆 Summary of Features Added

| Feature              | Status |
| -------------------- | ------ |
| CSV Export Backend   | ✅ Done |
| CSV Export Frontend  | ✅ Done |
| Admin vs Staff Roles | ✅ Done |
| Role-Based UI        | ✅ Done |


**✅ PHASE 2 STATUS**

> **🟢 PHASE 2 COMPLETE & VERIFIED**

# SECTION 1️⃣ Secure Admin Order Dashboard 🟢 COMPLETE ✅
---
# SECTION 2️⃣ Secure & Security ARCHITECTURE Dashboard

## ## 🔐 PHASE  1️⃣ Secure Admin Pages

### 1️⃣ Centralize Authentication -  auth.js template (reusable)
> **🧠 OPTION 1 (RECOMMENDED): auth.js (All logic in one file)**

### 1️⃣ 📄 /admin/assets/auth.js

[auth.js](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/auth.js)

### 2️⃣  🔧 Auth.js Minimal Configuration Replacement

```
/* ================= CONFIG ================= */
const USER_POOL_ID = "YOUR_COGNITO_USER_POOL_ID";   // Replace with your Cognito User Pool ID
const CLIENT_ID = "YOUR_APP_CLIENT_ID";             // Replace with your App Client ID (no secret)
const COGNITO_DOMAIN = "YOUR_DOMAIN.auth.ap-south-1.amazoncognito.com"; // Replace with your Cognito Hosted UI domain
const REDIRECT_URI = window.location.origin + window.location.pathname; // Usually fine as-is
```

#### ✅ Notes:

- USER_POOL_ID → from AWS Cognito → User Pool → General settings → Pool ID

- CLIENT_ID → from App client inside your Cognito User Pool → App client ID

- COGNITO_DOMAIN → Cognito Hosted UI domain you set up (e.g., charliecafe-admin.auth.ap-south-1.amazoncognito.com)

- REDIRECT_URI → usually leave as-is, unless you are using a custom domain or CloudFront URL.

- No other changes are required in your existing auth.js. This will fully connect it to your own lab environment.

### 3️⃣  How to use it in ALL admin pages

#### 🔐 STEP 1 — Hide page until auth passes

At top of every admin HTML file:

```
<body style="display:none">
```

#### 🔐 STEP 2 — Load auth.js

Before your page’s own JS:

```
<script src="assets/auth.js"></script>
```

#### 🔐 STEP 3 — Protect page

At the bottom:

```
<script>
protectPage();
</script>
```

**✅ That’s it. Page is secured.**

#### 🧪 Example: order-status.html

```
<body style="display:none">

<script src="assets/auth.js"></script>

<script>
protectPage();

authFetch(API_URL)
    .then(res => res.json())
    .then(data => console.log(data));
</script>
```

#### 🧪 Example: analytics.html

```
<body style="display:none">

<script src="assets/auth.js"></script>

<script>
protectPage();

authFetch("https://api.example.com/admin/analytics")
    .then(res => res.json())
    .then(data => console.log(data));
</script>
```

### 🔒 EXTRA SECURITY (OPTIONAL BUT IMPRESSIVE)

#### 🔐 1. Protect APIs (MANDATORY)

- API Gateway → Cognito Authorizer

- Reject requests without valid JWT

#### 🔐 2. Cognito Groups

- Admin

- Staff

- Manager

Then in auth.js: 

```
parseJwt(token)["cognito:groups"]
```

#### 🔐 3. CloudFront

- HTTPS only

- Disable directory listing

- Add security headers


### 2️⃣ SECURE DASHBOARD AUTH MODULE (Cognito Protection - secure-dashboard.js)
> **DEPLOY FINAL FRONTEND Cognito Protection (WRITE ONCE ✅)**

### 🧩 STEP 1 — Create secure-dashboard.js

Create a new file:

```
secure-dashboard.js
```

**📌 This file becomes the security engine for all dashboards.**


### 🧩 STEP 2 — Add Full Secure Dashboard Module Code
> **📄 /admin/assets/secure-dashboard.js**

[secure-dashboard.js](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/secure-dashboard.js)


### 🧩 STEP 3 — Update Dashboard HTML (Minimal Change)

#### ⚠️ All these changes have already been made in all the admin files, so there is no need to follow these steps of phase 1.

####  Frontend Web Admin Pages

#### 1️⃣ Frontend Admin Dashboard 
> **📄 File: dashboard.html**

#### 1️⃣ Create dashboard.html

```
sudo nano /var/www/html/dashboard.html
```

#### 2️⃣ Paste Code

[dashboard.html](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-admin%20dashboard%20page/dashboard.html)

#### 3️⃣ Save File

```
CTRL + O → ENTER
CTRL + X
```

#### 4️⃣ Fix File Permissions

```
sudo chown apache:apache /var/www/html/dashboard.html
```

```
sudo chmod 644 /var/www/html/dashboard.html
```


#### 5️⃣ Restart Apache (MANDATORY)

```
sudo systemctl restart httpd
```

#### 6️⃣ Open page in browser (MANDATORY)

```
http:// Your EC2 Public IP/dashboard.html
```

#### 2️⃣ Frontend Admin Order-Status Dashboard

```
sudo nano /var/www/html/order-status.html
```

[order-status.html](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order-status/CC%20-%20Order-Status_LIVE%20ADMIN%20DASHBOARD_many%20orders/order-status.html)


#### 3️⃣ Frontend Admin Analytics Dashboard

```
sudo nano /var/www/html/analytics.html
```

[analytics.html](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-%20Sales%20Analytics/analytics.html)


#### 🏆 FINAL RESULT (Big Picture)

You now have enterprise-grade frontend security:

✅ One auth.js for all pages

✅ Cognito Hosted UI login

✅ JWT → API Gateway Authorizer → Lambda

✅ CloudFront + ALB compatible

✅ Clean architecture (no inline hacks)

✅ Admin dashboard, order status, analytics fully secured


**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**

# SECTION 2️⃣ Secure Admin Order Dashboard 🟢 COMPLETE ✅

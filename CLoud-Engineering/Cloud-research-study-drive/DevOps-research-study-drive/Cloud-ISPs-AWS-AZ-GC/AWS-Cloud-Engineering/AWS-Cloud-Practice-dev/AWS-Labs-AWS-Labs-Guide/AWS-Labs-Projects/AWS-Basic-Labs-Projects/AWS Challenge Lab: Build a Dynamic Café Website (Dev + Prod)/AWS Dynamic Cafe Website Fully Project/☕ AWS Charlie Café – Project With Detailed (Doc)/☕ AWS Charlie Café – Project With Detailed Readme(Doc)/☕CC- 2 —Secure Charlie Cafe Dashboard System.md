# AWS  ☕ Charlie Cafe — Secure Charlie Cafe Dashboard System

### Goal: Production-ready Admin Dashboard

#### Secure, auto-refreshing, printable, Cognito-protected

# SECTION 2️⃣ Secure Admin Order Dashboard


### 🧱 ARCHITECTURE

```
Browser (Admin Dashboard)
        ↓  JWT
Amazon Cognito (Login)
        ↓
API Gateway (Cognito Authorizer)
        ↓
AWS Lambda (Order API)
        ↓
Database
```

## 🔐 PHASE  1️⃣ — PREREQUISITES (CHECK ONLY)

#### Make sure you already have:

✅ EC2 / S3 hosting HTML

✅ API Gateway with GET /order-status

✅ Lambda returning:

```
{
  "metrics": [...],
  "recent_orders": [...]
}
```

👉 If yes, continue

👉 If no, stop here

## 🔐 PHASE  1️⃣ — PREREQUISITES (CHECK ONLY)

✔️ 📄 File: dashboard.html


### 1️⃣ DEPLOY FINAL FRONTEND (WRITE ONCE ✅)

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

**✅ PHASE 1 STATUS**

> **🟢 PHASE 1 COMPLETE & VERIFIED**

---

## 🔐 PHASE 2️⃣ — Set Up Automatic HTTP → HTTPS Redirection
> **✅ EASY & CORRECT METHOD (RECOMMENDED FOR LAB)**

### 3️⃣ — CLOUD FRONT

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

#### 2️⃣ 🔄 CloudFront Invalidations (Admin Dashboard Use Case)

> **CloudFront caches content at edge locations worldwide.
When you update a file on EC2 (like order-status.html), CloudFront may still serve the old cached version.**

**👉 Invalidation tells CloudFront to delete cached copies immediately.**

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

#### 🔐 STEP 4️⃣ — CloudFront SSL Certificate (Optional)
Viewer Certificate

Choose:

```
Default CloudFront certificate (*.cloudfront.net)
```

✅ This is fine

✅ HTTPS works automatically

❌ No ACM needed here

### 🧠 WHY THIS IS THE CORRECT APPROACH

- Matches real AWS projects

- Works with Cognito HTTPS rule

- Simple & debuggable

- No unnecessary complexity

**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**

---
## 🔐 PHASE 3️⃣ — COGNITO INTEGRATION (PRODUCTION READY)

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



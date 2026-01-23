# AWS  ☕ Charlie Cafe — Secure & Security ARCHITECTURE Dashboard

### Goal: Production-ready Admin Dashboard

#### Secure, auto-refreshing, printable, Cognito-protected


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

### PREREQUISITES (CHECK ONLY)

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

## 🔐 PHASE R&D  — Secure & Security ARCHITECTURE Model
> **Research & Development Phase**

### 🔐 — Secure Web Pages

### 1️⃣ Centralize Authentication

#### ▶️ What it is: 

The concept and implementation of creating one reusable authentication script (auth.js) that contains all the login/logout/validation logic.

#### ▶️ Purpose: 

Avoid repeating the same code on every page.

#### ▶️ What it includes:

✔️ Create one authentication script (auth.js) for all admin pages.

✔️ It handles:

- ✔️ Login redirect to Cognito

- ✔️ Token extraction (access_token)

- ✔️ Token validation (isTokenExpired)

- ✔️ Conditional display of page (display:block only if valid)

- ✔️ Logout redirect

#### ▶️ Outcome: 

One centralized script that any page can include.

#### ▶️ Benefit:
You don’t have to rewrite login logic for every page. It makes your architecture professional.

#### ▶️ auth.js template (reusable)

```
const COGNITO_DOMAIN = "YOUR_COGNITO_DOMAIN.auth.region.amazoncognito.com";
const CLIENT_ID = "YOUR_APP_CLIENT_ID";
const REDIRECT_URI = window.location.origin;

function parseJwt(token) {
  return JSON.parse(atob(token.split('.')[1]));
}

function isTokenExpired(token) {
  return parseJwt(token).exp * 1000 < Date.now();
}

function login() {
  window.location.href = `https://${COGNITO_DOMAIN}/login?response_type=token&client_id=${CLIENT_ID}&scope=openid+email+profile&redirect_uri=${REDIRECT_URI}`;
}

function logout() {
  localStorage.removeItem("access_token");
  window.location.href = `https://${COGNITO_DOMAIN}/logout?client_id=${CLIENT_ID}&logout_uri=${REDIRECT_URI}`;
}

function handleRedirect() {
  const hash = window.location.hash.substring(1);
  const params = new URLSearchParams(hash);
  const token = params.get("access_token");
  if (token) localStorage.setItem("access_token", token);
  window.location.hash = "";
}

function securePage() {
  handleRedirect();
  const token = localStorage.getItem("access_token");
  if (!token || isTokenExpired(token)) login();
  else document.body.style.display = "block";
}
```

- Include this script in dashboard.html, order-status.html, analytics.html.

- Wrap body content with display:none to hide until auth passes.

### 2️⃣ Secure Your Admin Pages

#### ▶️ What it is: 

The practical application of auth.js to every individual HTML page.

#### ▶️ Purpose: 

Actually protect each page (dashboard, order-status, analytics) so nobody can view it without logging in.

#### ▶️ Steps for each page:

1️⃣ Add at the top:

```
<body style="display:none">
<script src="auth.js"></script>
<script>securePage();</script>
```

2️⃣ Replace manual logout functions with the logout() from auth.js.

3️⃣ For all API calls, include the token:

```
fetch(API_URL, {
  headers: { Authorization: `Bearer ${localStorage.getItem("access_token")}` }
})
```

4️⃣ Now, even if someone knows the URL of order-status.html or analytics.html, they can’t access data without login.

### ✅ In short

**✅ They are related but not the same.**

- **Centralize Authentication:** the reusable code/tool (auth.js)

- **Secure Your Admin Pages:** the practical steps to use that tool on every page

#### Think of it like:

- **Centralize Authentication:**  = “Here’s the key.”

- **Secure Your Admin Pages:**= “Here’s how to lock each door with the key.”

### 🔐 Big Picture (Very Important)

#### 1️⃣ ALB / CloudFront / HTTP/2

👉 Handle network-level access & delivery

#### 2️⃣ auth.js (Cognito JS)

👉 Handles application-level authentication

**They live at different layers and work together, not against each other.**

### 🧱 Layered Security Model (Professional Way)

#### Think in layers, like real production systems:

```
User Browser
   │
   ▼
CloudFront (HTTPS + HTTP/2 + Cache + WAF)
   │
   ▼
ALB (optional auth / routing)
   │
   ▼
Static Files (dashboard.html, auth.js)
   │
   ▼
JavaScript Auth (Cognito tokens)
   │
   ▼
API Gateway (Cognito Authorizer)
   │
   ▼
Lambda / DynamoDB
```

**⚠️ Each layer has its own job.**

### ❓ Your Core Confusion — Answered Directly

> **“I already protected order-status.html using ALB + Cognito, so how does auth.js work?”**

#### ✅ Short answer:

**ALB and auth.js do NOT replace each other. They complement each other.**

###  🌐 What ALB Cognito Authentication Does

#### When you enabled ALB + Cognito:

✔ Blocks unauthenticated HTTP requests

✔ Forces login before the HTML is served

✔ Works at network / load balancer level

**📌 But…**

❌ ALB does not manage frontend state

❌ ALB does not protect JavaScript navigation

❌ ALB does not secure API calls

❌ ALB does not help when using CloudFront SPA routing

### 🌐 What auth.js Does (Different Role)

#### auth.js runs inside the browser and:

✔ Controls page-to-page navigation

✔ Protects all admin pages consistently

✔ Stores & validates JWT tokens

✔ Attaches tokens to API requests

✔ Handles logout cleanly

✔ Works perfectly with CloudFront + HTTP/2

**📌 So:**

> **✔️ ALB protects delivery**
> **✔️ auth.js protects behavior**

### 🔁 Real-World Example (Important)

#### Scenario WITHOUT auth.js

- User logs in via ALB

- User opens dashboard.html

- User copies URL of analytics.html

-  Browser opens it directly
 ❌ Page loads without frontend check

 ❌ API may still be called

#### Scenario WITH auth.js

- User opens ANY admin page

- auth.js runs first

- Token missing or expired?

    ➡ Redirect to Cognito login

    ✔ Fully protected

### 🌐 CloudFront + HTTP/2 — No Conflict at All

This is important:

- auth.js is just a static JS file

- CloudFront serves it over HTTPS / HTTP2

- Browser executes it locally

➡ Zero impact on HTTP/2

➡ Zero impact on caching

➡ Zero impact on ALB

**📌 In fact:**

> **Most modern SPAs work exactly like this**

### 🏆 Professional Recommendation (Best Practice)

#### ✅ Best architecture for your lab:

| Layer          | Responsibility          |
| -------------- | ----------------------- |
| CloudFront     | HTTPS, HTTP/2, caching  |
| WAF (optional) | Block bad traffic       |
| ALB            | Routing / optional auth |
| auth.js        | Frontend auth guard     |
| API Gateway    | JWT verification        |
| Lambda         | Business logic          |
| DynamoDB       | Data                    |

This is textbook cloud architecture.

### ⚠️ One Important Rule (Please remember)

#### If you use ALB Cognito auth:

✔ Good for protecting static files

❌ Not enough alone for multi-page admin apps

#### If you use auth.js:

✔ Required for SPA-like navigation

✔ Required for API security

✔ Required for professional UX

👉 Use both if you want enterprise-grade

👉 Use auth.js minimum if you want clean architecture

### 🧭 My Honest Advice

#### Because this is a learning lab:

🔹 Keep CloudFront

🔹 Keep Cognito

🔹 Use auth.js as your primary auth logic

🔹 Document ALB auth as optional enhancement

#### This keeps:

✔ Your docs clean

✔ Your architecture understandable

✔ Your lab impressive

**✅ You are doing the RIGHT thing**

> **You didn’t make a mistake.**
> **You’re leveling up your design.**


**✅ A professional admin dashboard uses one shared auth module that all admin pages load.**

**Below is the clean, scalable, industry-style solution 👇**

### ✅ BEST & PROFESSIONAL WAY

#### 👉 Create a shared auth.js (Single Source of Truth)

#### 📁 Recommended folder structure

```
/var/www/html/
│
├── admin/
│   ├── dashboard.html
│   ├── order-status.html
│   ├── analytics.html
│   └── assets/
│       ├── auth.js        👈 ONE FILE FOR ALL AUTH
│       └── config.js     👈 OPTIONAL (constants only)
```

### 🧠 OPTION 1 (RECOMMENDED): auth.js (All logic in one file)

#### 1️⃣ 📄 /admin/assets/auth.js

```
<script>
/* ================= CONFIG ================= */
const USER_POOL_ID = "CHANGE_ME";
const CLIENT_ID = "CHANGE_ME";
const COGNITO_DOMAIN = "CHANGE_ME.auth.ap-south-1.amazoncognito.com";
const REDIRECT_URI = window.location.origin + window.location.pathname;

/* ================= TOKEN HELPERS ================= */
function parseJwt(token) {
    return JSON.parse(atob(token.split('.')[1]));
}

function isTokenExpired(token) {
    return parseJwt(token).exp * 1000 < Date.now();
}

/* ================= AUTH ACTIONS ================= */
function login() {
    const url =
        `https://${COGNITO_DOMAIN}/login` +
        `?response_type=token` +
        `&client_id=${CLIENT_ID}` +
        `&scope=openid+email+profile` +
        `&redirect_uri=${encodeURIComponent(REDIRECT_URI)}`;
    window.location.href = url;
}

function logout() {
    localStorage.removeItem("access_token");

    const url =
        `https://${COGNITO_DOMAIN}/logout` +
        `?client_id=${CLIENT_ID}` +
        `&logout_uri=${encodeURIComponent(REDIRECT_URI)}`;
    window.location.href = url;
}

/* ================= HANDLE REDIRECT ================= */
function handleAuthRedirect() {
    if (!window.location.hash) return;

    const params = new URLSearchParams(window.location.hash.substring(1));
    const token = params.get("access_token");

    if (token) {
        localStorage.setItem("access_token", token);
        window.location.hash = "";
    }
}

/* ================= PAGE GUARD ================= */
function protectPage() {
    handleAuthRedirect();

    const token = localStorage.getItem("access_token");
    if (!token || isTokenExpired(token)) {
        login();
        return;
    }

    // page is safe now
    document.body.style.display = "block";
}

/* ================= API FETCH HELPER ================= */
function authFetch(url, options = {}) {
    const token = localStorage.getItem("access_token");
    if (!token || isTokenExpired(token)) logout();

    return fetch(url, {
        ...options,
        headers: {
            ...(options.headers || {}),
            Authorization: "Bearer " + token
        }
    });
}
</script>
```

#### 2️⃣  How to use it in ALL admin pages

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

#### 🏆 WHY THIS IS PROFESSIONAL

✅ Single source of truth

✅ No duplicated auth logic

✅ Easy maintenance

✅ Enterprise-style page guard

✅ Looks exactly like real SaaS dashboards

**This is how production dashboards work.**

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



**✅ PHASE R&D STATUS**

> **🟢 PHASE R&D COMPLETE & VERIFIED**

---

## 🔐 PHASE  1️⃣ — Frontend Web Admin Pages

### 1️⃣ Frontend Admin Dashboard 
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

### 2️⃣ Frontend Admin Order-Status Dashboard

```
sudo nano /var/www/html/order-status.html
```

#### ✅ Commented order-status.html Version (Production-Ready & Lab-Friendly)

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

#### ✅ UPDATED FILE WITH SIDEBAR (COMMENTED - Recommanded)

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


### 3️⃣ Frontend Admin Analytics Dashboard

```
sudo nano /var/www/html/analytics.html
```

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Cafe Analytics ☕</title>

<!-- ===================== BOOTSTRAP CSS ===================== -->
<!-- CDN used to avoid local file management -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- ===================== CHART.JS ===================== -->
<!-- Used for sales / cost / profit visualization -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
/* ===================== BODY & BACKGROUND ===================== */
/* Cafe-style dark coffee theme background */
body {
  min-height: 100vh;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;

  /* Coffee-style overlay + image */
  background:
    linear-gradient(rgba(58,44,31,0.75), rgba(58,44,31,0.75)),
    url('https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=1400&q=80');

  background-size: cover;
  background-position: center;
  color: #fff;
}

/* ===================== MAIN CONTAINER ===================== */
/* Glassmorphism effect */
.container {
  backdrop-filter: blur(6px);
  background-color: rgba(0,0,0,0.45);
  padding: 30px;
  border-radius: 12px;
  box-shadow: 0 8px 20px rgba(0,0,0,0.4);
}

/* ===================== HEADINGS ===================== */
h3 {
  text-align: center;
  font-weight: bold;
  color: #ffddaa;
  text-shadow: 1px 1px 2px #000;
}

/* ===================== INPUTS & BUTTONS ===================== */
.form-select, .btn {
  border-radius: 50px;
  font-weight: bold;
}

/* Load Data button */
.btn-primary {
  background: linear-gradient(45deg, #a0522d, #d2b48c);
  border: none;
}

/* PDF button – top right corner */
.btn-success {
  background: linear-gradient(45deg, #8b4513, #f4a460);
  border: none;
  font-weight: bold;
  position: absolute;
  top: 20px;
  right: 20px; /* PDF button location */
  z-index: 10;
}

/* ===================== METRIC CARDS ===================== */
.card {
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.1);
  color: #fff;
  font-weight: bold;
  text-align: center;
  box-shadow: 0 4px 15px rgba(0,0,0,0.3);
  transition: transform 0.2s;
}

/* Hover animation */
.card:hover {
  transform: translateY(-5px);
}

/* ===================== CHART CANVAS ===================== */
canvas {
  background: rgba(0,0,0,0.1);
  border-radius: 12px;
  padding: 15px;
}

/* ===================== PDF BUTTON HOVER ===================== */
.btn-success:hover {
  background: linear-gradient(45deg, #d2691e, #ffcc99);
}
</style>
</head>

<body>

<!-- ===================== PAGE CONTAINER ===================== -->
<div class="container mt-4 position-relative">

  <!-- Page Title -->
  <h3>☕ Cafe Sales Analytics</h3>

  <!-- ===================== PERIOD SELECT ===================== -->
  <div class="d-flex justify-content-center align-items-center mt-4 gap-3 flex-wrap">

    <!-- Time filter (used by Analytics Lambda) -->
    <select id="period" class="form-select w-auto">
      <option value="today">Today</option>
      <option value="week">Last 7 Days</option>
      <option value="month">This Month</option>
    </select>

    <!-- Trigger analytics API -->
    <button class="btn btn-primary" onclick="loadData()">Load Data</button>
  </div>

  <!-- ===================== METRICS ===================== -->
  <div class="row mt-4 g-4">
    <div class="col-md-4">
      <div class="card p-3">Sales: <span id="sales">0</span></div>
    </div>
    <div class="col-md-4">
      <div class="card p-3">Cost: <span id="cost">0</span></div>
    </div>
    <div class="col-md-4">
      <div class="card p-3">Profit: <span id="profit">0</span></div>
    </div>
  </div>

  <!-- ===================== CHART ===================== -->
  <!-- Visual summary of Sales vs Cost vs Profit -->
  <canvas id="chart" class="mt-4" height="120"></canvas>

  <!-- ===================== PDF DOWNLOAD ===================== -->
  <!-- Calls PDF Lambda via API Gateway -->
  <button class="btn btn-success" onclick="downloadPDF()">📄 Download PDF</button>

</div>

<script>
/* ============================================================
   ENVIRONMENT STYLE CONFIGURATION (REPLACE ONLY THESE VALUES)
   ============================================================ */

// 🔁 REPLACE with your real API Gateway base URL
const API_BASE_URL = "https://API_ID.execute-api.REGION.amazonaws.com/prod";

// Analytics endpoint
const ANALYTICS_API = `${API_BASE_URL}/analytics`;

// PDF report endpoint
const PDF_API = `${API_BASE_URL}/report/pdf`;

/* ============================================================
   LOAD ANALYTICS DATA
   ============================================================ */
function loadData() {

  // Selected period (today / week / month)
  const period = document.getElementById('period').value;

  // Call Analytics Lambda
  fetch(`${ANALYTICS_API}?period=${period}`)
    .then(res => res.json())
    .then(data => {

      // Populate metrics
      document.getElementById('sales').innerText = data.total_sales;
      document.getElementById('cost').innerText = data.total_cost;
      document.getElementById('profit').innerText = data.profit;

      // ===================== RENDER CHART =====================
      const ctx = document.getElementById('chart').getContext('2d');

      // Destroy old chart before re-render
      if (window.salesChart) window.salesChart.destroy();

      // Create new chart
      window.salesChart = new Chart(ctx, {
        type: 'line',
        data: {
          labels: ['Sales', 'Cost', 'Profit'],
          datasets: [{
            label: 'Amount',
            data: [
              data.total_sales,
              data.total_cost,
              data.profit
            ],
            borderColor: '#ffddaa',
            backgroundColor: 'rgba(255, 221, 170, 0.3)',
            borderWidth: 3,
            tension: 0.3,
            fill: true
          }]
        },
        options: {
          plugins: {
            legend: { display: false }
          },
          scales: {
            y: {
              beginAtZero: true,
              grid: { color: 'rgba(255,255,255,0.2)' }
            },
            x: {
              grid: { color: 'rgba(255,255,255,0.2)' }
            }
          }
        }
      });
    });
}

/* ============================================================
   DOWNLOAD PDF REPORT
   ============================================================ */
function downloadPDF() {
  // Opens PDF Lambda in new tab
  window.open(PDF_API);
}
</script>

<!-- ===================== BOOTSTRAP JS ===================== -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
```

#### ✅ analytics.html — WITH SHARED SIDEBAR (FULLY COMMENTED  - Recommanded)

> **🔁 You can copy–paste this entire file safely**

```
<!DOCTYPE html>
<html lang="en" data-bs-theme="dark">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Charlie Cafe ☕ | Analytics</title>

<!-- ===================== BOOTSTRAP CSS ===================== -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- ===================== CHART.JS ===================== -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
/* ===================== GLOBAL BACKGROUND ===================== */
body {
  min-height: 100vh;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;

  background:
    linear-gradient(rgba(58,44,31,0.75), rgba(58,44,31,0.75)),
    url('https://images.unsplash.com/photo-1509042239860-f550ce710b93');

  background-size: cover;
  background-position: center;
  background-attachment: fixed;
  color: #fff;
}

/* ===================== NAVBAR ===================== */
.navbar {
  background-color: #3b1f0e !important;
  position: fixed;
  width: 100%;
  z-index: 1000;
}

/* ===================== SIDEBAR ===================== */
/*
  Sidebar Purpose:
  - Persistent navigation for admin / manager users
  - Same sidebar reused across dashboard, analytics & order-status
*/
.sidebar {
  width: 240px;
  min-height: 100vh;
  background: #2b160a;
  position: fixed;
  top: 0;
  left: 0;
  padding-top: 80px; /* Space for fixed navbar */
}

.sidebar a {
  display: block;
  padding: 14px 24px;
  color: #ddd;
  text-decoration: none;
  font-weight: 500;
  transition: background 0.3s;
}

/* Hover effect */
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

/* ===================== MAIN CONTENT ===================== */
.main-content {
  margin-left: 240px; /* Sidebar width */
  padding-top: 100px;
}

/* ===================== ANALYTICS CONTAINER ===================== */
.analytics-container {
  backdrop-filter: blur(6px);
  background-color: rgba(0,0,0,0.45);
  padding: 30px;
  border-radius: 12px;
  box-shadow: 0 8px 20px rgba(0,0,0,0.4);
  max-width: 1100px;
  margin: auto;
}

/* ===================== METRIC CARDS ===================== */
.card {
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.1);
  color: #fff;
  font-weight: bold;
  text-align: center;
  box-shadow: 0 4px 15px rgba(0,0,0,0.3);
  transition: transform 0.2s;
}

.card:hover {
  transform: translateY(-5px);
}

/* ===================== BUTTONS ===================== */
.btn-primary {
  background: linear-gradient(45deg, #a0522d, #d2b48c);
  border: none;
  border-radius: 50px;
  font-weight: bold;
}

.btn-success {
  background: linear-gradient(45deg, #8b4513, #f4a460);
  border: none;
  font-weight: bold;
  position: absolute;
  top: 20px;
  right: 20px;
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
<div class="sidebar">

  <!-- Main dashboard navigation -->
  <a href="dashboard.html">🏠 Main Dashboard</a>

  <!-- Analytics page (current) -->
  <a href="analytics.html" class="active">📈 Analytics</a>

  <!-- Order status navigation -->
  <a href="order-status.html">📦 Order Status</a>

</div>

<!-- ===================== MAIN CONTENT ===================== -->
<div class="main-content">
  <div class="analytics-container position-relative">

    <h3 class="text-center mb-4">☕ Cafe Sales Analytics</h3>

    <!-- ===================== FILTER ===================== -->
    <div class="d-flex justify-content-center gap-3 flex-wrap mb-4">
      <select id="period" class="form-select w-auto">
        <option value="today">Today</option>
        <option value="week">Last 7 Days</option>
        <option value="month">This Month</option>
      </select>

      <button class="btn btn-primary" onclick="loadData()">Load Data</button>
    </div>

    <!-- ===================== METRICS ===================== -->
    <div class="row g-4 mb-4">
      <div class="col-md-4">
        <div class="card p-3">Sales: <span id="sales">0</span></div>
      </div>
      <div class="col-md-4">
        <div class="card p-3">Cost: <span id="cost">0</span></div>
      </div>
      <div class="col-md-4">
        <div class="card p-3">Profit: <span id="profit">0</span></div>
      </div>
    </div>

    <!-- ===================== CHART ===================== -->
    <canvas id="chart" height="120"></canvas>

    <!-- ===================== PDF DOWNLOAD ===================== -->
    <button class="btn btn-success" onclick="downloadPDF()">📄 Download PDF</button>

  </div>
</div>

<!-- ===================== JS LOGIC ===================== -->
<script>
const API_BASE_URL = "https://API_ID.execute-api.REGION.amazonaws.com/prod";
const ANALYTICS_API = `${API_BASE_URL}/analytics`;
const PDF_API = `${API_BASE_URL}/report/pdf`;

function loadData() {
  const period = document.getElementById('period').value;

  fetch(`${ANALYTICS_API}?period=${period}`)
    .then(res => res.json())
    .then(data => {

      document.getElementById('sales').innerText = data.total_sales;
      document.getElementById('cost').innerText = data.total_cost;
      document.getElementById('profit').innerText = data.profit;

      const ctx = document.getElementById('chart').getContext('2d');

      if (window.salesChart) window.salesChart.destroy();

      window.salesChart = new Chart(ctx, {
        type: 'line',
        data: {
          labels: ['Sales', 'Cost', 'Profit'],
          datasets: [{
            data: [data.total_sales, data.total_cost, data.profit],
            borderColor: '#ffddaa',
            backgroundColor: 'rgba(255,221,170,0.3)',
            borderWidth: 3,
            tension: 0.3,
            fill: true
          }]
        },
        options: {
          plugins: { legend: { display: false } },
          scales: {
            y: { beginAtZero: true },
            x: {}
          }
        }
      });
    });
}

function downloadPDF() {
  window.open(PDF_API);
}
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
```

**✅ PHASE 1 STATUS**

> **🟢 PHASE 1 COMPLETE & VERIFIED**

---
## 🔐 PHASE 2️⃣ — DEPLOY FINAL FRONTEND Cognito Protection (WRITE ONCE ✅)

### 1️⃣ ✅ Updated dashboard.html (with Cognito protection)

Below is your UPDATED dashboard.html with:

✅ Page hidden until auth success

✅ auth.js loaded

✅ protectPage() applied

✅ Secure API call placeholder

✅ Cognito-ready logout()

✅ Comments explaining why each part exists

#### Code

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
    display: none; /* 🔐 Hidden until Cognito auth passes */
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

/* KPI + cards */
.kpi-card { border-radius: 20px; padding: 20px; }
.bg-green { background: #1abc9c; }
.bg-purple { background: #9b59b6; }
.bg-blue { background: #3498db; }
.bg-orange { background: #e67e22; }

.card-dark {
    background: #1c1c1e;
    border-radius: 20px;
    padding: 20px;
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

    <a class="active"><i class="bi bi-speedometer2"></i> Dashboard</a>
    <a href="#"><i class="bi bi-cup-hot"></i> Menu</a>
    <a href="#"><i class="bi bi-bag-check"></i> Orders</a>
    <a href="#"><i class="bi bi-graph-up"></i> Analytics</a>
    <a href="#"><i class="bi bi-gear"></i> Settings</a>

    <hr>

    <!-- 🔐 Secure Logout -->
    <a onclick="logout()" style="cursor:pointer">
        <i class="bi bi-box-arrow-left"></i> Logout
    </a>
</div>

<!-- =================================================
     MAIN CONTENT
     ================================================= -->
<div class="main">

<div class="top-bar mb-4">
    <h5>Welcome, Admin 👋</h5>
</div>

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

<div class="row g-4">
    <div class="col-md-6">
        <div class="card-dark">
            <h5>Sales Overview</h5>
            <p class="text-muted">(Connected to Analytics API later)</p>
        </div>
    </div>

    <div class="col-md-6">
        <div class="card-dark">
            <h5>Orders Trend</h5>
            <p class="text-muted">(Bar chart placeholder)</p>
        </div>
    </div>
</div>

</div>

<!-- =================================================
     🔐 AUTHENTICATION LAYER (Cognito)
     ================================================= -->

<!-- 1️⃣ Central auth logic -->
<script src="assets/auth.js"></script>

<script>
/* =================================================
   PAGE PROTECTION
   - Redirects to Cognito Hosted UI if not logged in
   - Decodes JWT
   - Shows page only after validation
   ================================================= */
protectPage();

/* =================================================
   SECURE API CALL EXAMPLE
   - JWT automatically added by authFetch()
   - API Gateway must have Cognito Authorizer
   ================================================= */
authFetch(API_URL)
    .then(res => res.json())
    .then(data => {
        console.log("Secure dashboard data:", data);
        // Later → update KPIs dynamically
    })
    .catch(err => console.error("API error:", err));

/* =================================================
   LOGOUT
   - Clears tokens
   - Redirects to Cognito logout endpoint
   ================================================= */
function logout() {
    cognitoLogout();
}
</script>

</body>
</html>
```

#### ✅ What You Achieved (Important)

✔ Same auth.js works for CloudFront + ALB + HTTP/2

✔ Dashboard cannot be viewed without Cognito login

✔ JWT automatically sent to API Gateway

✔ Professional real-world architecture

✔ Ready for Admin / Manager role checks next

### 2️⃣ ✅ Updated order-status.html (Cognito-secured)

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

### 3️⃣ ✅ Updated analytics.html (Cognito-secured & production-ready)

Below is your UPDATED analytics.html with:

✅ Page hidden until Cognito auth

✅ auth.js loaded once

✅ protectPage() enforced

✅ authFetch() replacing insecure fetch()

✅ JWT attached to Analytics API + PDF API

✅ Clean lab-ready comments

✅ Same architecture across all 3 pages

#### Code

```
<!DOCTYPE html>
<html lang="en" data-bs-theme="dark">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Charlie Cafe ☕ | Analytics</title>

<!-- ===================== BOOTSTRAP CSS ===================== -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- ===================== CHART.JS ===================== -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
/* ===================== GLOBAL BACKGROUND ===================== */
body {
  min-height: 100vh;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  background:
    linear-gradient(rgba(58,44,31,0.75), rgba(58,44,31,0.75)),
    url('https://images.unsplash.com/photo-1509042239860-f550ce710b93');
  background-size: cover;
  background-position: center;
  background-attachment: fixed;
  color: #fff;
  display: none; /* 🔐 Hidden until Cognito auth passes */
}

/* ===================== NAVBAR ===================== */
.navbar {
  background-color: #3b1f0e !important;
  position: fixed;
  width: 100%;
  z-index: 1000;
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

/* ===================== MAIN CONTENT ===================== */
.main-content {
  margin-left: 240px;
  padding-top: 100px;
}

/* ===================== ANALYTICS CONTAINER ===================== */
.analytics-container {
  backdrop-filter: blur(6px);
  background-color: rgba(0,0,0,0.45);
  padding: 30px;
  border-radius: 12px;
  max-width: 1100px;
  margin: auto;
}

/* ===================== RESPONSIVE ===================== */
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
  <a href="analytics.html" class="active">📈 Analytics</a>
  <a href="order-status.html">📦 Order Status</a>
</div>

<!-- ===================== MAIN CONTENT ===================== -->
<div class="main-content">
  <div class="analytics-container position-relative">

    <h3 class="text-center mb-4">☕ Cafe Sales Analytics</h3>

    <!-- ===================== FILTER ===================== -->
    <div class="d-flex justify-content-center gap-3 flex-wrap mb-4">
      <select id="period" class="form-select w-auto">
        <option value="today">Today</option>
        <option value="week">Last 7 Days</option>
        <option value="month">This Month</option>
      </select>

      <button class="btn btn-primary" onclick="loadData()">Load Data</button>
    </div>

    <!-- ===================== METRICS ===================== -->
    <div class="row g-4 mb-4">
      <div class="col-md-4">
        <div class="card p-3">Sales: <span id="sales">0</span></div>
      </div>
      <div class="col-md-4">
        <div class="card p-3">Cost: <span id="cost">0</span></div>
      </div>
      <div class="col-md-4">
        <div class="card p-3">Profit: <span id="profit">0</span></div>
      </div>
    </div>

    <!-- ===================== CHART ===================== -->
    <canvas id="chart" height="120"></canvas>

    <!-- ===================== PDF DOWNLOAD ===================== -->
    <button class="btn btn-success" onclick="downloadPDF()">📄 Download PDF</button>

  </div>
</div>

<!-- =================================================
     🔐 AUTHENTICATION LAYER (Cognito)
     ================================================= -->

<!-- 1️⃣ Central auth logic (shared across all pages) -->
<script src="assets/auth.js"></script>

<script>
/* =================================================
   PAGE PROTECTION
   - Redirects unauthenticated users to Cognito Hosted UI
   - Validates JWT
   - Shows page only after success
   ================================================= */
protectPage();

/* =================================================
   API ENDPOINTS (Protected by Cognito Authorizer)
   ================================================= */
const API_BASE_URL = "https://API_ID.execute-api.REGION.amazonaws.com/prod";
const ANALYTICS_API = `${API_BASE_URL}/analytics`;
const PDF_API = `${API_BASE_URL}/report/pdf`;

/* =================================================
   LOAD ANALYTICS DATA (JWT attached automatically)
   ================================================= */
function loadData() {
  const period = document.getElementById('period').value;

  authFetch(`${ANALYTICS_API}?period=${period}`)
    .then(res => res.json())
    .then(data => {

      document.getElementById('sales').innerText = data.total_sales;
      document.getElementById('cost').innerText = data.total_cost;
      document.getElementById('profit').innerText = data.profit;

      const ctx = document.getElementById('chart').getContext('2d');
      if (window.salesChart) window.salesChart.destroy();

      window.salesChart = new Chart(ctx, {
        type: 'line',
        data: {
          labels: ['Sales', 'Cost', 'Profit'],
          datasets: [{
            data: [data.total_sales, data.total_cost, data.profit],
            borderColor: '#ffddaa',
            backgroundColor: 'rgba(255,221,170,0.3)',
            borderWidth: 3,
            tension: 0.3,
            fill: true
          }]
        },
        options: {
          plugins: { legend: { display: false } },
          scales: { y: { beginAtZero: true } }
        }
      });
    })
    .catch(err => alert("Analytics API error"));
}

/* =================================================
   PDF DOWNLOAD (JWT protected)
   ================================================= */
function downloadPDF() {
  authFetch(PDF_API)
    .then(res => res.blob())
    .then(blob => {
      const url = URL.createObjectURL(blob);
      window.open(url);
    });
}
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
```

#### 🏆 FINAL RESULT (Big Picture)

You now have enterprise-grade frontend security:

✅ One auth.js for all pages

✅ Cognito Hosted UI login

✅ JWT → API Gateway Authorizer → Lambda

✅ CloudFront + ALB compatible

✅ Clean architecture (no inline hacks)

✅ Admin dashboard, order status, analytics fully secured


**✅ PHASE 2 STATUS**

> **🟢 PHASE 2 COMPLETE & VERIFIED**
---
## 🔐 PHASE 3️⃣ — DEPLOY FINAL FRONTEND (WRITE ONCE ✅)

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

#### 1️⃣ Updated Frontend Pages

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









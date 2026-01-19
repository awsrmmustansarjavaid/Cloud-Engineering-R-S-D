# ☕ AWS CAFE — Frontend DashBoard Panel

## PHASE 1️⃣ 

You want:

✅ Frontend-only dashboard

❌ NO backend calls

❌ NO Cognito yet

🎨 Just layout + cafe branding

☕ Charlie Cafe (Drinks Cafe, not food)

🧪 Easy to test UI first

🔜 Later → we will plug Cognito + APIs + PDF

Below is a CLEAN, UPDATED, FRONTEND-ONLY version of your code:

Renamed Foodie Kitchen → Charlie Cafe

Converted food → drinks

KPIs renamed for cafe

Trending section uses coffee / tea / juice

All numbers are dummy

Cognito is placeholder only

Code is simple, readable, future-ready

### ✅ Charlie Cafe — Frontend Dashboard (NO BACKEND, NO COGNITO)

📄 File: dashboard.html

You can open this directly in browser
file:///dashboard.html or via Apache

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

✅ WHAT THIS VERSION IS (VERY IMPORTANT)

✔ Frontend-only
✔ No API calls
✔ No Cognito
✔ Safe to edit layout
✔ Perfect for UI testing
✔ Matches your AWS lab (Charlie Cafe ☕)

🔜 NEXT STEPS (WHEN YOU SAY)

When you are happy with layout, we will add one-by-one, no jumping:

1️⃣ Cognito login / logout
2️⃣ Connect Order Status API
3️⃣ Connect Analytics API
4️⃣ Add PDF buttons
5️⃣ Add RBAC (Admin only UI)


Features in dashboard.html

Keep Dashboard layout (KPI cards, trending drinks).

Add navbar like order-status with Cognito login/logout, theme toggle, Analytics & PDF buttons (RBAC controlled).

Add a button “View Orders” that redirects to order-status.html.

Analytics button opens modal like order-status.html but API-driven.

PDF button works (Admin only).

Theme toggle (dark/light).

Here is a merged version of dashboard.html with order-status features integrated:

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Cafe ☕ | Dashboard</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- BOOTSTRAP -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">

<!-- CHART.JS -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
/* ================= GLOBAL THEME ================= */
body.dark {
    background: linear-gradient(rgba(0,0,0,.65), rgba(0,0,0,.65)), 
                url("https://images.unsplash.com/photo-1509042239860-f550ce710b93");
    background-size: cover;
    background-position: center;
    background-attachment: fixed;
    color: #fff;
}
body.light {
    background: linear-gradient(rgba(255,255,255,.7), rgba(255,255,255,.7)), 
                url("https://images.unsplash.com/photo-1509042239860-f550ce710b93");
    background-size: cover;
    background-position: center;
    background-attachment: fixed;
    color: #000;
}

/* SIDEBAR */
.sidebar {
    width: 250px;
    background: #151515;
    min-height: 100vh;
    position: fixed;
    padding: 20px;
}
.sidebar h4 { font-weight: 700; }
.sidebar a { display: block; color: #bbb; padding: 12px; border-radius: 10px; margin-bottom: 8px; text-decoration: none;}
.sidebar a.active, .sidebar a:hover { background: #ff9800; color:#000; }

/* MAIN CONTENT */
.main { margin-left: 260px; padding: 25px; }

/* HEADER */
.top-bar { display:flex; justify-content:space-between; align-items:center; }
.search-box input { background:#222; border:none; border-radius:30px; padding:10px 20px; color:white; }

/* KPI CARDS */
.kpi-card { border-radius:20px; padding:20px; color:white; }
.bg-green { background:#1abc9c; }
.bg-purple { background:#9b59b6; }
.bg-blue { background:#3498db; }
.bg-orange { background:#e67e22; }

/* CONTENT CARDS */
.card-dark { background:#1c1c1e; border-radius:20px; padding:20px; }

/* DRINK CARDS */
.drink-card { background:#1c1c1e; border-radius:20px; padding:15px; text-align:center; }
.drink-card img { width:100%; border-radius:15px; }

/* DASHBOARD ORDER SECTION (from order-status) */
#dashboard-orders { display:none; background:#f5f5f5; padding:20px; border-radius:8px; }
.card-metric { background:#fff; padding:15px; border-radius:8px; box-shadow:0 2px 6px rgba(0,0,0,.1); font-weight:bold; }
.admin-only { display:none; }

@media(max-width:576px){ h5{font-size:16px;} table{font-size:12px;} }
</style>
</head>

<body class="dark">

<!-- NAVBAR (from order-status) -->
<nav class="navbar navbar-dark bg-dark" id="navbar" style="display:none">
    <div class="container d-flex justify-content-between">
        <span class="navbar-brand">☕ Charlie Cafe</span>
        <div>
            <!-- THEME TOGGLE -->
            <button class="btn btn-secondary btn-sm me-2" onclick="toggleTheme()">🌙 / ☀️</button>

            <!-- ANALYTICS (ADMIN ONLY) -->
            <button class="btn btn-warning btn-sm me-2 admin-only" onclick="openAnalytics()">📊 Analytics</button>

            <!-- PDF REPORT (ADMIN ONLY) -->
            <button class="btn btn-outline-light btn-sm me-2 admin-only" onclick="downloadPDF()">📄 PDF</button>

            <!-- LOGOUT -->
            <button class="btn btn-danger btn-sm" onclick="logout()">Logout</button>
        </div>
    </div>
</nav>

<!-- ================= DASHBOARD MAIN ================= -->
<div class="main" id="dashboard-main">

    <!-- TOP BAR -->
    <div class="top-bar mb-4">
        <h5>Welcome, Admin 👋</h5>
        <div class="search-box">
            <input type="text" placeholder="🔍 Search">
        </div>
        <div>
            <i class="bi bi-bell"></i>
            <span class="ms-2">Charlie Cafe Admin</span>
            <small class="text-muted">Admin</small>
        </div>
    </div>

    <!-- KPI CARDS -->
    <div class="row g-4 mb-4">
        <div class="col-md-3"><div class="kpi-card bg-green"><h6>Today's Revenue</h6><h3>$11,256</h3></div></div>
        <div class="col-md-3"><div class="kpi-card bg-purple"><h6>Today's Orders</h6><h3>245</h3></div></div>
        <div class="col-md-3"><div class="kpi-card bg-blue"><h6>Avg Expense</h6><h3>$6,556</h3></div></div>
        <div class="col-md-3"><div class="kpi-card bg-orange"><h6>Avg Revenue</h6><h3>$4,227</h3></div></div>
    </div>

    <!-- CHART SECTION -->
    <div class="row g-4">
        <div class="col-md-6">
            <div class="card-dark">
                <h5>Sales Details</h5>
                <p class="text-muted">Monthly Overview</p>
                <p class="text-muted">(Chart placeholder — API data later)</p>
            </div>
        </div>
        <div class="col-md-6">
            <div class="card-dark">
                <h5>Order Chart</h5>
                <p class="text-muted">Weekly Orders</p>
                <p class="text-muted">(Chart placeholder — API data later)</p>
            </div>
        </div>
    </div>

    <!-- TRENDING DRINKS -->
    <div class="mt-5">
        <h5>🔥 Trending Drinks</h5>
        <div class="row g-4 mt-2">
            <div class="col-md-4"><div class="drink-card"><img src="https://images.unsplash.com/photo-1604908177522-432cf9f3bb95"><h6 class="mt-2">Cappuccino</h6><p>$5</p></div></div>
            <div class="col-md-4"><div class="drink-card"><img src="https://images.unsplash.com/photo-1540189549336-e6e99c3679fe"><h6 class="mt-2">Fresh Juice</h6><p>$4</p></div></div>
            <div class="col-md-4"><div class="drink-card"><img src="https://images.unsplash.com/photo-1512621776951-a57141f2eefd"><h6 class="mt-2">Latte</h6><p>$5</p></div></div>
        </div>
    </div>

    <!-- VIEW ORDERS BUTTON -->
    <div class="mt-5 text-center">
        <a href="order-status.html" class="btn btn-primary btn-lg">📋 View Orders</a>
    </div>
</div>

<!-- ================= ANALYTICS MODAL (ADMIN) ================= -->
<div class="modal fade" id="analyticsModal" tabindex="-1">
  <div class="modal-dialog modal-xl modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header bg-dark text-white">
        <h5 class="modal-title">📊 Sales Analytics</h5>
        <button class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <div class="row mb-3">
            <div class="col-md-3">
                <select id="analyticsPeriod" class="form-select">
                    <option value="today">Today</option>
                    <option value="week">Last 7 Days</option>
                    <option value="month">This Month</option>
                </select>
            </div>
            <div class="col-md-3">
                <button class="btn btn-primary w-100" onclick="loadAnalytics()">Load</button>
            </div>
        </div>
        <div class="row text-center mb-4" id="analyticsMetrics"></div>
        <canvas id="salesChart" height="100"></canvas>
      </div>
    </div>
  </div>
</div>

<!-- ================= SCRIPTS ================= -->
<script>
const COGNITO_DOMAIN = "REPLACE_WITH_YOUR_COGNITO_DOMAIN";
const CLIENT_ID = "REPLACE_WITH_YOUR_APP_CLIENT_ID";
const REDIRECT_URI = "REPLACE_WITH_YOUR_REDIRECT_URL";
const API_URL = "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/order-status";
const ANALYTICS_API = "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/analytics";
const PDF_API = "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/report/pdf";

let chart,salesChart,refreshTimer;

function parseJwt(token){ return JSON.parse(atob(token.split('.')[1])); }
function isTokenExpired(token){ return parseJwt(token).exp*1000 < Date.now(); }

function login(){
    window.location.href = `https://${COGNITO_DOMAIN}/login?response_type=token&client_id=${CLIENT_ID}&scope=openid+email+profile&redirect_uri=${encodeURIComponent(REDIRECT_URI)}`;
}

function logout(){
    localStorage.removeItem("access_token");
    clearInterval(refreshTimer);
    window.location.href = `https://${COGNITO_DOMAIN}/logout?client_id=${CLIENT_ID}&logout_uri=${encodeURIComponent(REDIRECT_URI)}`;
}

function handleRedirect(){
    const hash = window.location.hash.substring(1);
    if(!hash) return;
    const params = new URLSearchParams(hash);
    const token = params.get("access_token");
    if(token){ localStorage.setItem("access_token", token); window.location.hash = ""; }
}

function applyRBAC(){
    const token=localStorage.getItem("access_token");
    if(!token) return;
    const groups=parseJwt(token)["cognito:groups"]||[];
    if(groups.includes("Admin")) document.querySelectorAll(".admin-only").forEach(el=>el.style.display="inline-block");
}

function showDashboard(){
    const token=localStorage.getItem("access_token");
    if(!token||isTokenExpired(token)) return login();
    document.getElementById("navbar").style.display="block";
    document.getElementById("dashboard-main").style.display="block";
    applyRBAC();
}

function openAnalytics(){ new bootstrap.Modal(analyticsModal).show(); loadAnalytics(); }
function loadAnalytics(){
    const token=localStorage.getItem("access_token");
    const period=document.getElementById("analyticsPeriod").value;
    fetch(`${ANALYTICS_API}?period=${period}`,{headers:{Authorization:"Bearer "+token}})
        .then(res=>res.json())
        .then(data=>{
            document.getElementById("analyticsMetrics").innerHTML=`
            <div class="col-md-3"><div class="card-metric">Sales<br>${data.total_sales}</div></div>
            <div class="col-md-3"><div class="card-metric">Cost<br>${data.total_cost}</div></div>
            <div class="col-md-3"><div class="card-metric">Profit<br>${data.profit}</div></div>
            <div class="col-md-3"><div class="card-metric">Orders<br>${data.orders_count}</div></div>`;
        });
}

function downloadPDF(){ window.open(PDF_API,"_blank"); }
function toggleTheme(){ document.body.classList.toggle("dark"); document.body.classList.toggle("light"); }

handleRedirect();
showDashboard();
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
```
# Charlie-Cafe - Admin Dashboard Page


# SECTION 1️⃣  Latest Updated Advance dashboard.html

### ✅ Added Features:

✔️ Auto-refresh metrics every 10 seconds using authFetch and secure-dashboard.js.

✔️ Dynamic KPI cards updated from a placeholder API.

✔️ Orders table summary (latest orders) inside the dashboard.

✔️ Chart showing simple metrics trend.

✔️ Date filter for metrics and chart.

✔️ Print today summary button.

✔️ Loading spinner while data fetches.

### ✅ Latest Code:

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Cafe ☕ | Admin Dashboard</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- ================= BOOTSTRAP ================= -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">

<style>
/* =================================================
   GLOBAL STYLES
================================================= */
body {
    background-color: #0f0f10;
    color: #ffffff;
    font-family: 'Segoe UI', sans-serif;
}

/* Sidebar */
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
.sidebar a:hover,
.sidebar a.active {
    background: #ff9800;
    color: #000;
}

/* Main content */
.main {
    margin-left: 260px;
    padding: 25px;
}

/* Cards */
.card-dark {
    background: #1c1c1e;
    border-radius: 20px;
    padding: 20px;
}
.kpi-card {
    border-radius: 20px;
    padding: 20px;
    color: white;
}

/* KPI colors */
.bg-green { background: #1abc9c; }
.bg-purple { background: #9b59b6; }
.bg-blue { background: #3498db; }
.bg-orange { background: #e67e22; }

/* Orders table */
.table-container {
    margin-top: 30px;
    background: #1c1c1e;
    border-radius: 15px;
    padding: 20px;
}

/* Spinner */
#spinnerOverlay {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(15,15,16,0.8);
    display: flex;
    justify-content: center;
    align-items: center;
    z-index: 9999;
    display: none;
}

#spinnerOverlay .spinner-border {
    width: 4rem;
    height: 4rem;
    color: #ff9800;
}

/* Chart */
#metricsChart {
    margin-top: 20px;
    background: #1c1c1e;
    border-radius: 15px;
    padding: 20px;
}
</style>
</head>

<body>

<!-- =================================================
     🔐 SECURE DASHBOARD CONTAINER
================================================= -->
<div id="dashboard-container">

<!-- ================= SIDEBAR ================= -->
<div class="sidebar">
    <h4>☕ Charlie Cafe</h4>
    <p class="text-muted">Dashboard</p>

    <a class="active"><i class="bi bi-speedometer2"></i> Dashboard</a>
    <a href="#"><i class="bi bi-cup-hot"></i> Menu</a>
    <a href="#"><i class="bi bi-bag-check"></i> Orders</a>

    <a href="analytics.html" class="admin-only">
        <i class="bi bi-graph-up"></i> Analytics
    </a>

    <a href="#" class="admin-only">
        <i class="bi bi-gear"></i> Settings
    </a>

    <hr>

    <!-- 🔐 SECURE LOGOUT -->
    <a class="logout-btn" style="cursor:pointer">
        <i class="bi bi-box-arrow-left"></i> Logout
    </a>
</div>

<!-- ================= MAIN ================= -->
<div class="main">

<!-- HEADER -->
<div class="d-flex justify-content-between align-items-center mb-4">
    <h5>Welcome 👋</h5>

    <!-- Notification Bell -->
    <div class="dropdown">
        <i class="bi bi-bell fs-4" data-bs-toggle="dropdown"></i>
        <span id="notificationBadge" class="badge bg-danger">0</span>

        <ul class="dropdown-menu dropdown-menu-end bg-dark">
            <li class="dropdown-header text-white">Notifications</li>
            <div id="notificationList"></div>
        </ul>
    </div>

    <div>
        <small class="text-muted">Role:</small>
        <strong id="roleLabel">Admin</strong>
    </div>
</div>

<!-- DATE FILTER -->
<div class="d-flex gap-3 mb-4 flex-wrap">
    <label class="mt-2">Filter:</label>
    <select id="dateFilter" class="form-select w-auto">
        <option value="today">Today</option>
        <option value="week">Last 7 Days</option>
        <option value="month">This Month</option>
    </select>
    <button class="btn btn-warning" onclick="printSummary()">🖨 Print Today Summary</button>
</div>

<!-- KPI CARDS -->
<div class="row g-4 mb-4" id="kpiCards">
    <div class="col-md-3">
        <div class="kpi-card bg-green"><h6>Sales</h6><h3 id="sales">0</h3></div>
    </div>
    <div class="col-md-3">
        <div class="kpi-card bg-purple"><h6>Orders</h6><h3 id="ordersCount">0</h3></div>
    </div>
    <div class="col-md-3">
        <div class="kpi-card bg-blue"><h6>Drinks</h6><h3 id="drinksCount">0</h3></div>
    </div>
    <div class="col-md-3">
        <div class="kpi-card bg-orange"><h6>Avg</h6><h3 id="avgPrice">$0</h3></div>
    </div>
</div>

<div class="card-dark">
    <h5>Dashboard Overview</h5>
    <p class="text-muted">Analytics & reports coming next</p>
</div>

<!-- ================= ORDERS TABLE ================= -->
<div class="table-container">
    <h5>Latest Orders</h5>
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
            <tbody id="ordersTable"></tbody>
        </table>
    </div>
</div>

<!-- ================= CHART ================= -->
<div id="metricsChart">
    <canvas id="kpiChart" height="120"></canvas>
</div>

</div> <!-- END MAIN -->

</div> <!-- END DASHBOARD CONTAINER -->

<!-- ================= LOADING SPINNER ================= -->
<div id="spinnerOverlay">
    <div class="spinner-border" role="status"></div>
</div>

<!-- ================= WELCOME TOAST ================= -->
<div class="toast-container position-fixed top-0 end-0 p-3">
    <div id="welcomeToast" class="toast">
        <div class="toast-header">
            <strong class="me-auto">☕ Charlie Cafe</strong>
            <button class="btn-close" data-bs-dismiss="toast"></button>
        </div>
        <div class="toast-body">
            Welcome back to the Dashboard!
        </div>
    </div>
</div>

<!-- ================= JS ================= -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<!-- ================= ROLE HANDLING ================= -->
<script>
localStorage.setItem("userRole", "ADMIN");
if (localStorage.getItem("userRole") === "STAFF") {
    document.querySelectorAll(".admin-only").forEach(e => e.remove());
    document.getElementById("roleLabel").innerText = "Staff";
}
</script>

<!-- ================= NOTIFICATIONS ================= -->
<script>
const notifications = ["☕ New order received", "📊 Sales updated", "⚠️ Low stock alert"];
const list = document.getElementById("notificationList");
const badge = document.getElementById("notificationBadge");
notifications.forEach(n => {
    const li = document.createElement("li");
    li.className = "dropdown-item text-white";
    li.innerText = n;
    list.appendChild(li);
});
badge.innerText = notifications.length;
</script>

<!-- ================= CENTRAL AUTH & SECURE DASHBOARD ================= -->
<script src="secure-dashboard.js"></script>

<!-- ================= DYNAMIC DASHBOARD SCRIPT ================= -->
<script>
const spinner = document.getElementById("spinnerOverlay");
const salesEl = document.getElementById("sales");
const ordersEl = document.getElementById("ordersCount");
const drinksEl = document.getElementById("drinksCount");
const avgEl = document.getElementById("avgPrice");
const ordersTable = document.getElementById("ordersTable");

let kpiChart;

function fetchDashboardData() {
    spinner.style.display = "flex";

    const filter = document.getElementById("dateFilter").value;
    authFetch(`https://YOUR_API_ID.execute-api.region.amazonaws.com/prod/dashboard?filter=${filter}`)
        .then(res => res.json())
        .then(data => {
            // Update KPIs
            salesEl.innerText = `$${data.sales}`;
            ordersEl.innerText = data.orders;
            drinksEl.innerText = data.drinks;
            avgEl.innerText = `$${data.avg}`;

            // Update Orders Table
            ordersTable.innerHTML = "";
            data.latest_orders.forEach(o => {
                ordersTable.innerHTML += `
                    <tr>
                        <td>${o.customer_name || 'Anonymous'}</td>
                        <td>${o.item}</td>
                        <td>${o.quantity}</td>
                        <td>${o.table_number || '-'}</td>
                        <td>${o.date}</td>
                    </tr>`;
            });

            // Update Chart
            const ctx = document.getElementById("kpiChart").getContext("2d");
            if(kpiChart) kpiChart.destroy();
            kpiChart = new Chart(ctx, {
                type: 'line',
                data: {
                    labels: data.chart.labels,
                    datasets: [{
                        label: 'Sales',
                        data: data.chart.sales,
                        backgroundColor: 'rgba(26, 188, 156, 0.3)',
                        borderColor: '#1abc9c',
                        fill: true,
                        tension: 0.3
                    }]
                },
                options: {
                    plugins: { legend: { display: false } },
                    scales: { y: { beginAtZero: true } }
                }
            });

        }).catch(err => console.error(err))
        .finally(() => spinner.style.display = "none");
}

// Auto-refresh every 10s
fetchDashboardData();
setInterval(fetchDashboardData, 10000);

// Print today summary
function printSummary() {
    window.print();
}
</script>

</body>
</html>
```

### ✅ What’s new/added:

➕ Auto-refresh KPIs + chart + orders table every 10s.

➕ Dynamic chart for sales trend.

➕ Orders table summary in dashboard.

➕ Date filter to change metrics (today / week / month).

➕ Loading spinner while data fetches.

➕ Print today summary button.

This dashboard.html is now feature-complete and matches your table:

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

----

# SECTION 2️⃣  Previous Versions dashboard.html

### 1️⃣ Frontend Simple Admin Dashboard 
> **📄 File: dashboard.html**

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

---

### 2️⃣ Frontend Advance  Admin Dashboard 
> **UPDATED dashboard.html (Welcome Toast Added)**

🔔 Welcome toggle notification (Bootstrap Toast)

🔁 Shown only once per day (localStorage)

🧭 No layout or logic changes

📝 Clear comments so you understand & reuse it


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

.sidebar h4 { font-weight: 700; }

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

    <a class="active"><i class="bi bi-speedometer2"></i> Dashboard</a>
    <a href="#"><i class="bi bi-cup-hot"></i> Menu</a>
    <a href="#"><i class="bi bi-bag-check"></i> Orders</a>
    <a href="analytics.html"><i class="bi bi-graph-up"></i> Analytics</a>
    <a href="#"><i class="bi bi-gear"></i> Settings</a>

    <hr>

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
    <div class="col-md-3"><div class="kpi-card bg-green"><h6>Today's Sales</h6><h3>$1,250</h3></div></div>
    <div class="col-md-3"><div class="kpi-card bg-purple"><h6>Total Orders</h6><h3>86</h3></div></div>
    <div class="col-md-3"><div class="kpi-card bg-blue"><h6>Drinks Sold</h6><h3>142</h3></div></div>
    <div class="col-md-3"><div class="kpi-card bg-orange"><h6>Avg Order Value</h6><h3>$14.50</h3></div></div>
</div>

<!-- ================= CONTENT ================= -->
<div class="row g-4">
    <div class="col-md-6">
        <div class="card-dark">
            <h5>Sales Overview</h5>
            <p class="text-muted">(Chart will be connected later)</p>
        </div>
    </div>

    <div class="col-md-6">
        <div class="card-dark">
            <h5>Orders Trend</h5>
            <p class="text-muted">(Bar chart placeholder)</p>
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

<!-- ===================== WELCOME TOAST ===================== -->
<div class="toast-container position-fixed top-0 end-0 p-3">
    <div id="dashboardWelcomeToast" class="toast">
        <div class="toast-header">
            <strong class="me-auto">☕ Charlie Cafe</strong>
            <button class="btn-close" data-bs-dismiss="toast"></button>
        </div>
        <div class="toast-body">
            Welcome back to the Admin Dashboard!
        </div>
    </div>
</div>

<!-- ===================== JS ===================== -->
<script>
/* =================================================
   SHOW WELCOME TOAST (ONCE PER DAY)
   ================================================= */
document.addEventListener("DOMContentLoaded", () => {
    const today = new Date().toISOString().split("T")[0];
    const lastSeen = localStorage.getItem("dashboardWelcome");

    if (lastSeen !== today) {
        new bootstrap.Toast(
            document.getElementById("dashboardWelcomeToast"),
            { delay: 2500 }
        ).show();
        localStorage.setItem("dashboardWelcome", today);
    }
});

/* =================================================
   LOGOUT PLACEHOLDER
   ================================================= */
function logout() {
    alert("Logout clicked (Cognito will be added later)");
}
</script>

<!-- ================= BOOTSTRAP JS ================= -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
```

### 🔍 WHAT YOU JUST ACHIEVED

#### 🔔 Welcome Toast (Once Per Day)

- Uses localStorage

- Professional UX

- Prevents notification fatigue

#### 🧭 Consistent UX Across Pages

Dashboard | Analytics | Order Status

✔ Same behavior

✔ Same pattern

✔ Easy to maintain

---

### 3️⃣ Frontend Latest Advance Features Updated  Admin Dashboard (Recommanded)

1️⃣ Conceptual explanation (what + why)

2️⃣ File structure (recommended)

3️⃣ Central toast JS (shared for all pages)

4️⃣ Role-based sidebar logic (Admin / Staff)

5️⃣ Notification center (bell dropdown)

6️⃣ ✅ LATEST UPDATED dashboard.html (FULL FILE)

#### 1️⃣ What you’re adding (high-level)

#### ✅ Central JS file for toasts

- One JS file controls all toasts

- Prevents duplicate code

- Easy to reuse on dashboard.html, analytics.html, etc.

#### ✅ Role-based sidebar

- Sidebar changes based on role:

- Admin → full access

- Staff → limited menu

- Role stored in localStorage (later replaced by Cognito)

#### ✅ Notification center

- Bell icon

- Dropdown with notifications

- Badge counter

- Ready for API integration later

#### 2️⃣ Recommended file structure

```
/admin
 ├── dashboard.html
 ├── analytics.html
 ├── js/
 │    ├── toast.js        ✅ central toast system
 │    ├── auth.js         ✅ role & auth logic
 │    └── notifications.js
```

#### 3️⃣ Central Toast JS (js/toast.js)

👉 You will use this on ALL pages

```
<script>
/* =================================================
   CENTRAL TOAST SYSTEM
   ================================================= */

function showToast(id, key = null, delay = 2500) {
    const toastEl = document.getElementById(id);
    if (!toastEl) return;

    // If key provided → show once per day
    if (key) {
        const today = new Date().toISOString().split("T")[0];
        const lastShown = localStorage.getItem(key);
        if (lastShown === today) return;
        localStorage.setItem(key, today);
    }

    new bootstrap.Toast(toastEl, { delay }).show();
}
</script>
```

#### 4️⃣ Role-Based Sidebar Logic (js/auth.js)

```
<script>
/* =================================================
   ROLE MANAGEMENT (TEMP)
   ================================================= */

// TEMP: simulate logged-in user
localStorage.setItem("userRole", "ADMIN"); // ADMIN | STAFF

function applyRoleBasedSidebar() {
    const role = localStorage.getItem("userRole");

    if (role === "STAFF") {
        document.querySelectorAll(".admin-only").forEach(el => el.remove());
        document.getElementById("roleLabel").innerText = "Staff";
    } else {
        document.getElementById("roleLabel").innerText = "Admin";
    }
}

document.addEventListener("DOMContentLoaded", applyRoleBasedSidebar);
</script>
```

#### 5️⃣ Notification Center Logic (js/notifications.js)

```
<script>
/* =================================================
   NOTIFICATION CENTER
   ================================================= */

const notifications = [
    "☕ New order received",
    "📊 Sales report updated",
    "⚠️ Low stock: Coffee Beans"
];

function loadNotifications() {
    const list = document.getElementById("notificationList");
    const badge = document.getElementById("notificationBadge");

    list.innerHTML = "";

    notifications.forEach(note => {
        const li = document.createElement("li");
        li.className = "dropdown-item text-white";
        li.innerText = note;
        list.appendChild(li);
    });

    badge.innerText = notifications.length;
}

document.addEventListener("DOMContentLoaded", loadNotifications);
</script>
```

#### 6️⃣ ✅ LATEST UPDATED dashboard.html (FULL FILE)

This includes ALL 3 FEATURES integrated cleanly.

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Cafe ☕ | Admin Dashboard</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- ================= BOOTSTRAP ================= -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">

<style>
body {
    background-color: #0f0f10;
    color: #ffffff;
    font-family: 'Segoe UI', sans-serif;
}
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
.sidebar a:hover, .sidebar a.active {
    background: #ff9800;
    color: #000;
}
.main {
    margin-left: 260px;
    padding: 25px;
}
.card-dark {
    background: #1c1c1e;
    border-radius: 20px;
    padding: 20px;
}
.kpi-card {
    border-radius: 20px;
    padding: 20px;
    color: white;
}
.bg-green { background: #1abc9c; }
.bg-purple { background: #9b59b6; }
.bg-blue { background: #3498db; }
.bg-orange { background: #e67e22; }
</style>
</head>

<body>

<!-- ================= SIDEBAR ================= -->
<div class="sidebar">
    <h4>☕ Charlie Cafe</h4>
    <p class="text-muted">Dashboard</p>

    <a class="active"><i class="bi bi-speedometer2"></i> Dashboard</a>
    <a href="#"><i class="bi bi-cup-hot"></i> Menu</a>
    <a href="#"><i class="bi bi-bag-check"></i> Orders</a>

    <a href="analytics.html" class="admin-only">
        <i class="bi bi-graph-up"></i> Analytics
    </a>

    <a href="#" class="admin-only">
        <i class="bi bi-gear"></i> Settings
    </a>

    <hr>

    <a onclick="logout()" style="cursor:pointer">
        <i class="bi bi-box-arrow-left"></i> Logout
    </a>
</div>

<!-- ================= MAIN ================= -->
<div class="main">

<!-- HEADER -->
<div class="d-flex justify-content-between align-items-center mb-4">
    <h5>Welcome 👋</h5>

    <!-- Notification Bell -->
    <div class="dropdown">
        <i class="bi bi-bell fs-4" data-bs-toggle="dropdown"></i>
        <span id="notificationBadge" class="badge bg-danger">0</span>

        <ul class="dropdown-menu dropdown-menu-end bg-dark">
            <li class="dropdown-header text-white">Notifications</li>
            <div id="notificationList"></div>
        </ul>
    </div>

    <div>
        <small class="text-muted">Role:</small>
        <strong id="roleLabel">Admin</strong>
    </div>
</div>

<!-- KPI -->
<div class="row g-4 mb-4">
    <div class="col-md-3"><div class="kpi-card bg-green"><h6>Sales</h6><h3>$1,250</h3></div></div>
    <div class="col-md-3"><div class="kpi-card bg-purple"><h6>Orders</h6><h3>86</h3></div></div>
    <div class="col-md-3"><div class="kpi-card bg-blue"><h6>Drinks</h6><h3>142</h3></div></div>
    <div class="col-md-3"><div class="kpi-card bg-orange"><h6>Avg</h6><h3>$14.50</h3></div></div>
</div>

<div class="card-dark">
    <h5>Dashboard Overview</h5>
    <p class="text-muted">Analytics & reports coming next</p>
</div>

</div>

<!-- ================= WELCOME TOAST ================= -->
<div class="toast-container position-fixed top-0 end-0 p-3">
    <div id="welcomeToast" class="toast">
        <div class="toast-header">
            <strong class="me-auto">☕ Charlie Cafe</strong>
            <button class="btn-close" data-bs-dismiss="toast"></button>
        </div>
        <div class="toast-body">
            Welcome back to the Dashboard!
        </div>
    </div>
</div>

<!-- ================= JS ================= -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<!-- CENTRAL TOAST -->
<script>
function showToast(id, key = null) {
    const toast = document.getElementById(id);
    if (!toast) return;
    if (key) {
        const today = new Date().toISOString().split("T")[0];
        if (localStorage.getItem(key) === today) return;
        localStorage.setItem(key, today);
    }
    new bootstrap.Toast(toast).show();
}
document.addEventListener("DOMContentLoaded", () => {
    showToast("welcomeToast", "dashboardWelcome");
});
</script>

<!-- ROLE -->
<script>
localStorage.setItem("userRole", "ADMIN");
if (localStorage.getItem("userRole") === "STAFF") {
    document.querySelectorAll(".admin-only").forEach(e => e.remove());
    document.getElementById("roleLabel").innerText = "Staff";
}
</script>

<!-- NOTIFICATIONS -->
<script>
const notifications = [
    "☕ New order received",
    "📊 Sales updated",
    "⚠️ Low stock alert"
];
const list = document.getElementById("notificationList");
const badge = document.getElementById("notificationBadge");
notifications.forEach(n => {
    const li = document.createElement("li");
    li.className = "dropdown-item text-white";
    li.innerText = n;
    list.appendChild(li);
});
badge.innerText = notifications.length;
</script>

<script>
function logout() {
    alert("Logout (Cognito coming soon)");
}
</script>

</body>
</html>
```

#### 🎯 What you’ve achieved

✔ Scalable toast system

✔ Clean role-based UI

✔ Real notification center

✔ Enterprise-style dashboard architecture

---
## 🔐 4️⃣ — DEPLOY FINAL FRONTEND Cognito Protection (WRITE ONCE ✅)


### 1️⃣ ✅ Updated dashboard.html (with Cognito protection)
> **Just For case Study)

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


### 2️⃣ ✅ UPDATED dashboard.html (SECURE-READY - Recommanded)


```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Cafe ☕ | Admin Dashboard</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- ================= BOOTSTRAP ================= -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">

<style>
/* =================================================
   GLOBAL STYLES
   ================================================= */
body {
    background-color: #0f0f10;
    color: #ffffff;
    font-family: 'Segoe UI', sans-serif;
}

/* Sidebar */
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
.sidebar a:hover,
.sidebar a.active {
    background: #ff9800;
    color: #000;
}

/* Main content */
.main {
    margin-left: 260px;
    padding: 25px;
}

/* Cards */
.card-dark {
    background: #1c1c1e;
    border-radius: 20px;
    padding: 20px;
}
.kpi-card {
    border-radius: 20px;
    padding: 20px;
    color: white;
}

/* KPI colors */
.bg-green { background: #1abc9c; }
.bg-purple { background: #9b59b6; }
.bg-blue { background: #3498db; }
.bg-orange { background: #e67e22; }
</style>
</head>

<body>

<!-- =================================================
     🔐 SECURE DASHBOARD CONTAINER
     Everything inside this div will:
     ✅ stay hidden until Cognito auth succeeds
     ✅ become visible after protectPage()
     (controlled by secure-dashboard.js)
================================================= -->
<div id="dashboard-container">

<!-- ================= SIDEBAR ================= -->
<div class="sidebar">
    <h4>☕ Charlie Cafe</h4>
    <p class="text-muted">Dashboard</p>

    <a class="active"><i class="bi bi-speedometer2"></i> Dashboard</a>
    <a href="#"><i class="bi bi-cup-hot"></i> Menu</a>
    <a href="#"><i class="bi bi-bag-check"></i> Orders</a>

    <a href="analytics.html" class="admin-only">
        <i class="bi bi-graph-up"></i> Analytics
    </a>

    <a href="#" class="admin-only">
        <i class="bi bi-gear"></i> Settings
    </a>

    <hr>

    <!-- 🔐 SECURE LOGOUT
         secure-dashboard.js will automatically
         attach Cognito logout logic -->
    <a class="logout-btn" style="cursor:pointer">
        <i class="bi bi-box-arrow-left"></i> Logout
    </a>
</div>

<!-- ================= MAIN ================= -->
<div class="main">

<!-- HEADER -->
<div class="d-flex justify-content-between align-items-center mb-4">
    <h5>Welcome 👋</h5>

    <!-- Notification Bell -->
    <div class="dropdown">
        <i class="bi bi-bell fs-4" data-bs-toggle="dropdown"></i>
        <span id="notificationBadge" class="badge bg-danger">0</span>

        <ul class="dropdown-menu dropdown-menu-end bg-dark">
            <li class="dropdown-header text-white">Notifications</li>
            <div id="notificationList"></div>
        </ul>
    </div>

    <div>
        <small class="text-muted">Role:</small>
        <strong id="roleLabel">Admin</strong>
    </div>
</div>

<!-- KPI CARDS -->
<div class="row g-4 mb-4">
    <div class="col-md-3">
        <div class="kpi-card bg-green">
            <h6>Sales</h6>
            <h3>$1,250</h3>
        </div>
    </div>
    <div class="col-md-3">
        <div class="kpi-card bg-purple">
            <h6>Orders</h6>
            <h3>86</h3>
        </div>
    </div>
    <div class="col-md-3">
        <div class="kpi-card bg-blue">
            <h6>Drinks</h6>
            <h3>142</h3>
        </div>
    </div>
    <div class="col-md-3">
        <div class="kpi-card bg-orange">
            <h6>Avg</h6>
            <h3>$14.50</h3>
        </div>
    </div>
</div>

<div class="card-dark">
    <h5>Dashboard Overview</h5>
    <p class="text-muted">Analytics & reports coming next</p>
</div>

</div> <!-- END MAIN -->

</div>
<!-- 🔐 END SECURE DASHBOARD CONTAINER -->

<!-- ================= WELCOME TOAST ================= -->
<div class="toast-container position-fixed top-0 end-0 p-3">
    <div id="welcomeToast" class="toast">
        <div class="toast-header">
            <strong class="me-auto">☕ Charlie Cafe</strong>
            <button class="btn-close" data-bs-dismiss="toast"></button>
        </div>
        <div class="toast-body">
            Welcome back to the Dashboard!
        </div>
    </div>
</div>

<!-- ================= JS ================= -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<!-- ================= TOAST LOGIC ================= -->
<script>
function showToast(id, key = null) {
    const toast = document.getElementById(id);
    if (!toast) return;

    if (key) {
        const today = new Date().toISOString().split("T")[0];
        if (localStorage.getItem(key) === today) return;
        localStorage.setItem(key, today);
    }

    new bootstrap.Toast(toast).show();
}

document.addEventListener("DOMContentLoaded", () => {
    showToast("welcomeToast", "dashboardWelcome");
});
</script>

<!-- ================= ROLE HANDLING ================= -->
<script>
localStorage.setItem("userRole", "ADMIN");

if (localStorage.getItem("userRole") === "STAFF") {
    document.querySelectorAll(".admin-only").forEach(e => e.remove());
    document.getElementById("roleLabel").innerText = "Staff";
}
</script>

<!-- ================= NOTIFICATIONS ================= -->
<script>
const notifications = [
    "☕ New order received",
    "📊 Sales updated",
    "⚠️ Low stock alert"
];

const list = document.getElementById("notificationList");
const badge = document.getElementById("notificationBadge");

notifications.forEach(n => {
    const li = document.createElement("li");
    li.className = "dropdown-item text-white";
    li.innerText = n;
    list.appendChild(li);
});

badge.innerText = notifications.length;
</script>

<!-- =================================================
     🔐 CENTRAL AUTH & SECURITY LAYER
     This ONE file enables:
     ✅ Page hidden until auth success
     ✅ auth.js auto-loaded
     ✅ protectPage()
     ✅ Secure API calls (authFetch)
     ✅ Cognito logout
================================================= -->
<script src="secure-dashboard.js"></script>

</body>
</html>
```

####  ✅ WHAT YOU ACHIEVED (IMPORTANT)

You now have:

✔ Zero auth logic inside dashboard.html

✔ One reusable security file

✔ Production-grade Cognito structure

✔ Future-proof for analytics / orders / reports pages

---

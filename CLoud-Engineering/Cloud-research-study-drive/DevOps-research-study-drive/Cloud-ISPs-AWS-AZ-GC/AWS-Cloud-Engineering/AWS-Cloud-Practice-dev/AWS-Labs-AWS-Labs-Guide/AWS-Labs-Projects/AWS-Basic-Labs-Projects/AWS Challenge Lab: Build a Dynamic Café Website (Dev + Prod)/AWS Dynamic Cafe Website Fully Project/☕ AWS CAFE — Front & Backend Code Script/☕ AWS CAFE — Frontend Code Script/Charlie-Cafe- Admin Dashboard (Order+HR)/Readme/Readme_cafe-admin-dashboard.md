# Charlie Cafe - cafe-admin-dashboard


### cafe-admin-dashboard.html

> **Update Version:1.0**

- Load only the necessary JS modules (config.js + central-auth.js) instead of the old monolithic file.

- Use the new CHARLIE object from central-auth.js.

- Keep all UI/styling untouched.

- Ensure the redirect after login still works.

### ✅ UPDATED dashboard-login.html

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Café ☕ | Login</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- Bootstrap CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
body {
    background: #0f0f10;
    color: white;
    font-family: 'Segoe UI', sans-serif;
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
}
.card {
    background: #1c1c1e;
    border-radius: 15px;
    padding: 30px;
    width: 350px;
    text-align: center;
}
</style>
</head>

<body>

<div class="card">
    <h3>☕ Charlie Café</h3>
    <p class="text-muted">Admin & Staff Login</p>

    <!-- Cognito Hosted UI Login Button -->
    <button class="btn btn-warning w-100 mt-3" onclick="login()">
        Login with Cognito
    </button>
</div>

<!-- ================= NEW JS MODULES ================= -->
<script src="config.js"></script>
<script src="central-auth.js"></script>

<script>
// ==========================================================
// CHARLIE CAFÉ — LOGIN PAGE SCRIPT
// Uses separated central-auth.js module
// ==========================================================
function login() {
    // Redirect to dashboard after successful Cognito login
    const redirectUrl = `${window.location.origin}/cafe-admin-dashboard.html`;

    // Call centralized login function
    CHARLIE.auth.login(redirectUrl);
}
</script>

</body>
</html>
```

### ✅ WHAT CHANGED

- Removed old central-auth-api.js reference.

- Added config.js + central-auth.js as separate modules.

- Login button still works exactly the same.

- UI, styling, colors untouched.

- Redirect after login remains to cafe-admin-dashboard.html.

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Café ☕ | Admin Dashboard</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- ================= BOOTSTRAP + ICONS ================= -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">

<style>
/* ================= BODY & LAYOUT ================= */
body {
    background-color: #0f0f10;
    color: #fff;
    font-family: 'Segoe UI', sans-serif;
    display: none; /* Hidden until authentication succeeds */
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
    cursor: pointer;
}
.sidebar a:hover,
.sidebar a.active {
    background: #ff9800;
    color: #000;
}
.main { margin-left: 260px; padding: 25px; }
.kpi-card { border-radius: 20px; padding: 20px; color: white; }
.bg-green { background: #1abc9c; }
.bg-purple { background: #9b59b6; }
.bg-blue { background: #3498db; }
.bg-orange { background: #e67e22; }
.table-container { margin-top: 30px; background: #1c1c1e; border-radius: 15px; padding: 20px; }
.section { display: none; }
.section.active { display: block; }
.print-btn { display: inline-block; margin-bottom: 15px; }
</style>
</head>
<body>

<!-- ================= SIDEBAR ================= -->
<div class="sidebar">
    <h4>☕ Charlie Café</h4>
    <p class="text-muted">Admin Dashboard</p>

    <a class="active" onclick="showSection(event,'orders')">
        <i class="bi bi-bag-check"></i> Orders
    </a>

    <a onclick="showSection(event,'hr')">
        <i class="bi bi-people"></i> HR / Attendance
    </a>

    <a id="logoutBtn">
        <i class="bi bi-box-arrow-left"></i> Logout
    </a>
</div>

<!-- ================= MAIN CONTENT ================= -->
<div class="main">

    <!-- ORDERS SECTION -->
    <div id="orders" class="section active">
        <h4>Orders Dashboard</h4>

        <div class="row g-4 mb-4">
            <div class="col-md-3"><div class="kpi-card bg-green"><h6>Sales</h6><h3 id="sales">$0</h3></div></div>
            <div class="col-md-3"><div class="kpi-card bg-purple"><h6>Orders</h6><h3 id="ordersCount">0</h3></div></div>
            <div class="col-md-3"><div class="kpi-card bg-blue"><h6>Drinks</h6><h3 id="drinksCount">0</h3></div></div>
            <div class="col-md-3"><div class="kpi-card bg-orange"><h6>Avg</h6><h3 id="avgPrice">$0</h3></div></div>
        </div>

        <div class="table-container">
            <h5>Latest Orders</h5>
            <button class="btn btn-outline-dark print-btn"
                    onclick="openCentralPrint('#ordersTable')">
                🖨️ Print / Export
            </button>

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

    <!-- HR SECTION -->
    <div id="hr" class="section">
        <h4>HR & Attendance Dashboard</h4>

        <div class="row mb-4">
            <div class="col-md-4">
                <div class="card bg-success text-white p-3">
                    <h6>Total Present</h6>
                    <h3 id="cardPresent">0</h3>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card bg-danger text-white p-3">
                    <h6>Total Absent</h6>
                    <h3 id="cardAbsent">0</h3>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card bg-warning text-dark p-3">
                    <h6>Total Leaves</h6>
                    <h3 id="cardLeaves">0</h3>
                </div>
            </div>
        </div>

        <button class="btn btn-outline-primary" onclick="loadHR('daily')">Daily</button>
        <button class="btn btn-outline-primary" onclick="loadHR('weekly')">Weekly</button>
        <button class="btn btn-outline-primary" onclick="loadHR('monthly')">Monthly</button>
    </div>

</div>

<!-- ================= SCRIPTS ================= -->
<script src="/js/config.js"></script>
<script src="/js/utils.js"></script>
<script src="/js/central-auth.js"></script>
<script src="/js/role-guard.js"></script> <!-- ADD THIS LINE -->
<script src="/js/api.js"></script>
<script src="/js/central-printing.js"></script>

<script>

/* ================= SECTION SWITCHING ================= */
function showSection(e,id){
    document.querySelectorAll(".section").forEach(s=>s.classList.remove("active"));
    document.getElementById(id).classList.add("active");
    document.querySelectorAll(".sidebar a").forEach(a=>a.classList.remove("active"));
    if(e) e.currentTarget.classList.add("active");
}

/* ================= ORDERS DASHBOARD ================= */
async function loadOrdersDashboard(){
    try{
        const data=await CHARLIE_API.adminDashboard.fetchData();

        document.getElementById("sales").innerText=`$${data.sales||0}`;
        document.getElementById("ordersCount").innerText=data.orders||0;
        document.getElementById("drinksCount").innerText=data.drinks||0;
        document.getElementById("avgPrice").innerText=`$${data.avg||0}`;

        const table=document.getElementById("ordersTable");
        table.innerHTML="";

        (data.latest_orders||[]).forEach(o=>{
            table.innerHTML+=`<tr>
                <td>${o.customer_name||"Anonymous"}</td>
                <td>${o.item}</td>
                <td>${o.quantity}</td>
                <td>${o.table_number||"-"}</td>
                <td>${o.date}</td>
            </tr>`;
        });

    }catch(e){
        console.error("Orders Dashboard Error:",e);
    }
}

/* ================= HR DASHBOARD (FIXED summary=true) ================= */
async function loadHR(type){
    try{
        const url=`${CHARLIE_CONFIG.API_BASE}/admin/analytics?type=${type}&summary=true`;

        const response=await fetch(url);
        if(!response.ok){
            throw new Error(await response.text());
        }

        const data=await response.json();

        document.getElementById("cardPresent").innerText=data.summary?.total_present||0;
        document.getElementById("cardAbsent").innerText=data.summary?.total_absent||0;
        document.getElementById("cardLeaves").innerText=data.summary?.total_leaves||0;

    }catch(e){
        console.error("HR Dashboard Error:",e);
    }
}

/* ================= AUTHENTICATION (FULLY FIXED) ================= */
async function initPage(){
    try{
        await CHARLIE_AUTH.protectPage();
        CHARLIE_AUTH.startAutoLogoutWatcher();

        // Show dashboard after auth success
        document.body.style.display='block';

        // Load dashboards
        loadOrdersDashboard();
        loadHR('daily');

        // Logout handler
        document.getElementById('logoutBtn')
            .addEventListener('click',e=>{
                e.preventDefault();
                CHARLIE_AUTH.logout();
            });

    }catch(e){
        console.error("Authentication failed:",e);
        window.location.href='/login.html';
    }
}

initPage();

</script>

</body>
</html>
```
---
### cafe-admin-dashboard.html

> **Update Version;1.1**

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Café ☕ | Admin Dashboard</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- ================= BOOTSTRAP + ICONS ================= -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">

<style>
/* ================= BODY & LAYOUT ================= */
body {
    background-color: #0f0f10;
    color: #fff;
    font-family: 'Segoe UI', sans-serif;
    display: none; /* Hidden until authentication succeeds */
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
    cursor: pointer;
}
.sidebar a:hover,
.sidebar a.active {
    background: #ff9800;
    color: #000;
}
.main { margin-left: 260px; padding: 25px; }
.kpi-card { border-radius: 20px; padding: 20px; color: white; }
.bg-green { background: #1abc9c; }
.bg-purple { background: #9b59b6; }
.bg-blue { background: #3498db; }
.bg-orange { background: #e67e22; }
.table-container { margin-top: 30px; background: #1c1c1e; border-radius: 15px; padding: 20px; }
.section { display: none; }
.section.active { display: block; }
.print-btn { display: inline-block; margin-bottom: 15px; }
</style>
</head>
<body>

<!-- ================= SIDEBAR ================= -->
<div class="sidebar">
    <h4>☕ Charlie Café</h4>
    <p class="text-muted">Admin Dashboard</p>

    <!-- Orders Section Link -->
    <a class="active" onclick="showSection(event,'orders')">
        <i class="bi bi-bag-check"></i> Orders
    </a>

    <!-- HR Section Link -->
    <a onclick="showSection(event,'hr')">
        <i class="bi bi-people"></i> HR / Attendance
    </a>

    <!-- Logout -->
    <a id="logoutBtn">
        <i class="bi bi-box-arrow-left"></i> Logout
    </a>
</div>

<!-- ================= MAIN CONTENT ================= -->
<div class="main">

    <!-- ORDERS SECTION -->
    <div id="orders" class="section active">
        <h4>Orders Dashboard</h4>

        <!-- KPI Cards -->
        <div class="row g-4 mb-4">
            <div class="col-md-3"><div class="kpi-card bg-green"><h6>Sales</h6><h3 id="sales">$0</h3></div></div>
            <div class="col-md-3"><div class="kpi-card bg-purple"><h6>Orders</h6><h3 id="ordersCount">0</h3></div></div>
            <div class="col-md-3"><div class="kpi-card bg-blue"><h6>Drinks</h6><h3 id="drinksCount">0</h3></div></div>
            <div class="col-md-3"><div class="kpi-card bg-orange"><h6>Avg</h6><h3 id="avgPrice">$0</h3></div></div>
        </div>

        <!-- Latest Orders Table -->
        <div class="table-container">
            <h5>Latest Orders</h5>
            <button class="btn btn-outline-dark print-btn"
                    onclick="openCentralPrint('#ordersTable')">
                🖨️ Print / Export
            </button>

            <table class="table table-hover text-white" id="ordersTable">
                <thead>
                    <tr>
                        <th>Customer</th>
                        <th>Item</th>
                        <th>Qty</th>
                        <th>Table</th>
                        <th>Date</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>
    </div>

    <!-- HR SECTION -->
    <div id="hr" class="section">
        <h4>HR & Attendance Dashboard</h4>

        <!-- HR KPI Cards -->
        <div class="row mb-4">
            <div class="col-md-4">
                <div class="card bg-success text-white p-3">
                    <h6>Total Present</h6>
                    <h3 id="cardPresent">0</h3>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card bg-danger text-white p-3">
                    <h6>Total Absent</h6>
                    <h3 id="cardAbsent">0</h3>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card bg-warning text-dark p-3">
                    <h6>Total Leaves</h6>
                    <h3 id="cardLeaves">0</h3>
                </div>
            </div>
        </div>

        <!-- HR Filter Buttons -->
        <button class="btn btn-outline-primary" onclick="loadHR('daily')">Daily</button>
        <button class="btn btn-outline-primary" onclick="loadHR('weekly')">Weekly</button>
        <button class="btn btn-outline-primary" onclick="loadHR('monthly')">Monthly</button>
    </div>

</div>

<!-- ================= SCRIPTS ================= -->
<script src="/js/config.js"></script>
<script src="/js/utils.js"></script>
<script src="/js/central-auth.js"></script>
<script src="/js/role-guard.js"></script> <!-- Admin Role Guard -->
<script src="/js/api.js"></script>
<script src="/js/central-printing.js"></script>

<script>
/* ================= SECTION SWITCHING ================= */
function showSection(e,id){
    document.querySelectorAll(".section").forEach(s=>s.classList.remove("active"));
    document.getElementById(id).classList.add("active");
    document.querySelectorAll(".sidebar a").forEach(a=>a.classList.remove("active"));
    if(e) e.currentTarget.classList.add("active");
}

/* ================= ORDERS DASHBOARD ================= */
async function loadOrdersDashboard(){
    try{
        // Ensure only admins can fetch orders
        await CHARLIE_ROLE_GUARD.adminOnly();

        const data = await CHARLIE_API.adminDashboard.fetchData();

        // Update KPI Cards
        document.getElementById("sales").innerText = `$${data.sales||0}`;
        document.getElementById("ordersCount").innerText = data.orders||0;
        document.getElementById("drinksCount").innerText = data.drinks||0;
        document.getElementById("avgPrice").innerText = `$${data.avg||0}`;

        // Populate orders table
        const table = document.getElementById("ordersTable");
        table.innerHTML = "";
        (data.latest_orders||[]).forEach(o=>{
            table.innerHTML += `<tr>
                <td>${o.customer_name||"Anonymous"}</td>
                <td>${o.item}</td>
                <td>${o.quantity}</td>
                <td>${o.table_number||"-"}</td>
                <td>${o.date}</td>
            </tr>`;
        });

    }catch(e){
        console.error("Orders Dashboard Error:", e);
    }
}

/* ================= HR DASHBOARD ================= */
async function loadHR(type){
    try{
        // Ensure admin role before fetching HR data
        await CHARLIE_ROLE_GUARD.adminOnly();

        const url = `${CHARLIE_CONFIG.API_BASE}/admin/analytics?type=${type}&summary=true`;
        const response = await fetch(url);

        if(!response.ok) throw new Error(await response.text());

        const data = await response.json();

        document.getElementById("cardPresent").innerText = data.summary?.total_present || 0;
        document.getElementById("cardAbsent").innerText  = data.summary?.total_absent || 0;
        document.getElementById("cardLeaves").innerText  = data.summary?.total_leaves || 0;

    }catch(e){
        console.error("HR Dashboard Error:", e);
    }
}

/* ================= CENTRAL PRINT ================= */
function openCentralPrint(selector){
    const target = document.querySelector(selector);
    if(!target) return;
    const win = window.open("central-printing.html", "_blank");
    if(!win) return alert("Popup blocked");
    win.onload = () => {
        const container = win.document.getElementById("printContent");
        if(container) container.innerHTML = target.outerHTML;
    };
}

/* ================= PAGE INITIALIZATION ================= */
async function initPage(){
    try{
        // Protect page for authenticated users
        await CHARLIE_AUTH.protectPage();

        // Ensure only admin can access
        await CHARLIE_ROLE_GUARD.adminOnly();

        // Start auto logout watcher
        CHARLIE_AUTH.startAutoLogoutWatcher();

        // Show page content
        document.body.style.display='block';

        // Load dashboards
        loadOrdersDashboard();
        loadHR('daily');

        // Logout button handler
        document.getElementById('logoutBtn').addEventListener('click', e=>{
            e.preventDefault();
            CHARLIE_AUTH.logout();
        });

    }catch(e){
        console.error("Authentication / Role Error:", e);
        // Redirect non-admin users
        window.location.href='/login.html';
    }
}

initPage();
</script>

</body>
</html>
```

### ✅ What’s New / Fixed

Admin Role Guard Added:

- CHARLIE_ROLE_GUARD.adminOnly() called before loading Orders or HR dashboards.

- Ensures only admins can view / fetch sensitive data.

Page Hidden Until Auth Success:

- Prevents unauthorized users from seeing the UI flash.

Logout Handler:

- Properly clears session via CHARLIE_AUTH.logout().

Central Print Ready:

- Works for orders table.

Comments Added:

- Every function now has a descriptive comment for clarity and maintainability.

Error Handling:

- Dashboard and HR fetches now log detailed errors in console.
---


```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Café ☕ | Admin Dashboard</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- ================= BOOTSTRAP + ICONS ================= -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">

<style>
/* ================= BODY & LAYOUT ================= */
body {
    background-color: #0f0f10;
    color: #fff;
    font-family: 'Segoe UI', sans-serif;
    display: none; /* Hidden until authentication succeeds */
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
    cursor: pointer;
}
.sidebar a:hover,
.sidebar a.active {
    background: #ff9800;
    color: #000;
}
.main { margin-left: 260px; padding: 25px; }
.kpi-card { border-radius: 20px; padding: 20px; color: white; }
.bg-green { background: #1abc9c; }
.bg-purple { background: #9b59b6; }
.bg-blue { background: #3498db; }
.bg-orange { background: #e67e22; }
.table-container { margin-top: 30px; background: #1c1c1e; border-radius: 15px; padding: 20px; }
.section { display: none; }
.section.active { display: block; }
.print-btn { display: inline-block; margin-bottom: 15px; }
</style>
</head>
<body>

<!-- ================= SIDEBAR ================= -->
<div class="sidebar">
    <h4>☕ Charlie Café</h4>
    <p class="text-muted">Admin Dashboard</p>

    <!-- Orders Section Link -->
    <a class="active" onclick="showSection(event,'orders')">
        <i class="bi bi-bag-check"></i> Orders
    </a>

    <!-- HR Section Link -->
    <a onclick="showSection(event,'hr')">
        <i class="bi bi-people"></i> HR / Attendance
    </a>

    <!-- Logout -->
    <a id="logoutBtn">
        <i class="bi bi-box-arrow-left"></i> Logout
    </a>
</div>

<!-- ================= MAIN CONTENT ================= -->
<div class="main">

    <!-- ORDERS SECTION -->
    <div id="orders" class="section active">
        <h4>Orders Dashboard</h4>

        <!-- KPI Cards -->
        <div class="row g-4 mb-4">
            <div class="col-md-3"><div class="kpi-card bg-green"><h6>Sales</h6><h3 id="sales">$0</h3></div></div>
            <div class="col-md-3"><div class="kpi-card bg-purple"><h6>Orders</h6><h3 id="ordersCount">0</h3></div></div>
            <div class="col-md-3"><div class="kpi-card bg-blue"><h6>Drinks</h6><h3 id="drinksCount">0</h3></div></div>
            <div class="col-md-3"><div class="kpi-card bg-orange"><h6>Avg</h6><h3 id="avgPrice">$0</h3></div></div>
        </div>

        <!-- Latest Orders Table -->
        <div class="table-container">
            <h5>Latest Orders</h5>
            <button class="btn btn-outline-dark print-btn"
                    onclick="openCentralPrint('#ordersTable')">
                🖨️ Print / Export
            </button>

            <table class="table table-hover text-white" id="ordersTable">
                <thead>
                    <tr>
                        <th>Customer</th>
                        <th>Item</th>
                        <th>Qty</th>
                        <th>Table</th>
                        <th>Total ($)</th>
                        <th>Status</th>
                        <th>Payment</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>
    </div>

    <!-- HR SECTION -->
    <div id="hr" class="section">
        <h4>HR & Attendance Dashboard</h4>

        <!-- HR KPI Cards -->
        <div class="row mb-4">
            <div class="col-md-4">
                <div class="card bg-success text-white p-3">
                    <h6>Total Present</h6>
                    <h3 id="cardPresent">0</h3>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card bg-danger text-white p-3">
                    <h6>Total Absent</h6>
                    <h3 id="cardAbsent">0</h3>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card bg-warning text-dark p-3">
                    <h6>Total Leaves</h6>
                    <h3 id="cardLeaves">0</h3>
                </div>
            </div>
        </div>

        <!-- HR Filter Buttons -->
        <button class="btn btn-outline-primary" onclick="loadHR('daily')">Daily</button>
        <button class="btn btn-outline-primary" onclick="loadHR('weekly')">Weekly</button>
        <button class="btn btn-outline-primary" onclick="loadHR('monthly')">Monthly</button>
    </div>

</div>

<!-- ================= SCRIPTS ================= -->
<script src="/js/config.js"></script>
<script src="/js/utils.js"></script>
<script src="/js/central-auth.js"></script>
<script src="/js/role-guard.js"></script>
<script src="/js/api.js"></script>
<script src="/js/central-printing.js"></script>

<script>
/* ================= SECTION SWITCHING ================= */
function showSection(e,id){
    document.querySelectorAll(".section").forEach(s=>s.classList.remove("active"));
    document.getElementById(id).classList.add("active");
    document.querySelectorAll(".sidebar a").forEach(a=>a.classList.remove("active"));
    if(e) e.currentTarget.classList.add("active");
}

/* ================= ORDERS DASHBOARD ================= */
async function loadOrdersDashboard(){
    try{
        // ✅ Only admin users
        await CHARLIE_ROLE_GUARD.adminOnly();

        // ✅ Fetch orders from API
        const response = await CHARLIE_API.getOrders();
        const orders = response.orders || [];

        // Calculate KPI cards
        let totalSales = 0, totalDrinks = 0;
        orders.forEach(o=>{
            totalSales += parseFloat(o.total_amount||0);
            totalDrinks += o.quantity || 0;
        });
        const avgPrice = orders.length ? (totalSales/orders.length).toFixed(2) : 0;

        document.getElementById("sales").innerText = `$${totalSales.toFixed(2)}`;
        document.getElementById("ordersCount").innerText = orders.length;
        document.getElementById("drinksCount").innerText = totalDrinks;
        document.getElementById("avgPrice").innerText = `$${avgPrice}`;

        // Populate orders table
        const tbody = document.querySelector('#ordersTable tbody');
        if(orders.length === 0){
            tbody.innerHTML = '<tr><td colspan="7" class="text-center py-5">No orders found ☕</td></tr>';
            return;
        }

        tbody.innerHTML = orders.map(o=>{
            const statusBadge = (o.status==='PAID')
                ? `<span class="badge bg-success">PAID</span>`
                : `<span class="badge bg-warning text-dark">PENDING</span>`;
            const paymentBadge = (o.payment_method==='CARD')
                ? `<span class="badge bg-primary">CARD</span>`
                : `<span class="badge bg-secondary">CASH</span>`;
            return `<tr>
                <td>${o.customer_name||"Anonymous"}</td>
                <td>${o.item}</td>
                <td>${o.quantity}</td>
                <td>${o.table_number||"-"}</td>
                <td>${o.total_amount||0}</td>
                <td>${statusBadge}</td>
                <td>${paymentBadge}</td>
            </tr>`;
        }).join('');

    }catch(e){
        console.error("Orders Dashboard Error:", e);
    }
}

/* ================= HR DASHBOARD ================= */
async function loadHR(type){
    try{
        await CHARLIE_ROLE_GUARD.adminOnly();

        const url = `${CHARLIE_CONFIG.API_BASE}/admin/analytics?type=${type}&summary=true`;
        const response = await fetch(url);
        if(!response.ok) throw new Error(await response.text());

        const data = await response.json();
        document.getElementById("cardPresent").innerText = data.summary?.total_present || 0;
        document.getElementById("cardAbsent").innerText  = data.summary?.total_absent || 0;
        document.getElementById("cardLeaves").innerText  = data.summary?.total_leaves || 0;

    }catch(e){
        console.error("HR Dashboard Error:", e);
    }
}

/* ================= CENTRAL PRINT ================= */
function openCentralPrint(selector){
    const target = document.querySelector(selector);
    if(!target) return;
    const win = window.open("central-printing.html", "_blank");
    if(!win) return alert("Popup blocked");
    win.onload = () => {
        const container = win.document.getElementById("printContent");
        if(container) container.innerHTML = target.outerHTML;
    };
}

/* ================= PAGE INITIALIZATION ================= */
async function initPage(){
    try{
        await CHARLIE_AUTH.protectPage();
        await CHARLIE_ROLE_GUARD.adminOnly();
        CHARLIE_AUTH.startAutoLogoutWatcher();
        document.body.style.display='block';

        // ✅ Load orders and HR
        loadOrdersDashboard();
        loadHR('daily');

        document.getElementById('logoutBtn').addEventListener('click', e=>{
            e.preventDefault();
            CHARLIE_AUTH.logout();
        });

        // Refresh orders every 30 seconds
        setInterval(loadOrdersDashboard, 30000);

    }catch(e){
        console.error("Authentication / Role Error:", e);
        window.location.href='/login.html';
    }
}

initPage();
</script>

</body>
</html>
```

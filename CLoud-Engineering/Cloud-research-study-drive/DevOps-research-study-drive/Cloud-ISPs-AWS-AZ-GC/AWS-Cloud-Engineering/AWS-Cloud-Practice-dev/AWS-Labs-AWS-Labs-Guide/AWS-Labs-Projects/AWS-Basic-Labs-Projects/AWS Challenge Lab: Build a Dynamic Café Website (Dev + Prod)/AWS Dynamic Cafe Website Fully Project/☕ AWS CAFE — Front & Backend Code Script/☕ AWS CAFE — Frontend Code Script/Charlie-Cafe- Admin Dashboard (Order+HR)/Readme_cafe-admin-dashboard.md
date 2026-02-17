# Charlie Cafe - cafe-admin-dashboard

### cafe-admin-dashboard.html

> **Update Version:1.0**

### ✅ Key updates:

- Connected to CHARLIE.initProtectedPage() from central-auth.js

- Uses CHARLIE_API modular calls for Admin Dashboard and HR

- Logout button hooked via central-auth.js

- Clean comments for all sections

- No styling or layout changes


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

<!-- ================= STYLES ================= -->
<style>
/* -----------------------------------------------------
   IMPORTANT:
   Page stays hidden until Cognito auth passes to prevent
   unauthenticated users from seeing dashboard content.
----------------------------------------------------- */
body {
    background-color: #0f0f10; /* Dark background for admin dashboard */
    color: #fff; /* White text */
    font-family: 'Segoe UI', sans-serif;
    display: none; /* Hidden until auth validated */
}

/* ===== SIDEBAR ===== */
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

/* ===== MAIN CONTENT ===== */
.main {
    margin-left: 260px; /* leave space for sidebar */
    padding: 25px;
}

/* ===== KPI CARDS ===== */
.kpi-card {
    border-radius: 20px;
    padding: 20px;
    color: white;
}
.bg-green { background: #1abc9c; }
.bg-purple { background: #9b59b6; }
.bg-blue { background: #3498db; }
.bg-orange { background: #e67e22; }

/* ===== TABLE CONTAINER ===== */
.table-container {
    margin-top: 30px;
    background: #1c1c1e;
    border-radius: 15px;
    padding: 20px;
}

/* ===== SECTION TOGGLING ===== */
.section { display: none; } /* default hidden */
.section.active { display: block; } /* show active section */

/* ===== PRINT BUTTON ===== */
.print-btn {
    display: inline-block;
    margin-bottom: 15px;
}
</style>
</head>

<body>

<!-- ================= SIDEBAR ================= -->
<div class="sidebar">
    <h4>☕ Charlie Café</h4>
    <p class="text-muted">Admin Dashboard</p>

    <!-- Orders menu item -->
    <a class="active" onclick="showSection(event,'orders')">
        <i class="bi bi-bag-check"></i> Orders
    </a>

    <!-- HR / Attendance menu item -->
    <a onclick="showSection(event,'hr')">
        <i class="bi bi-people"></i> HR / Attendance
    </a>

    <hr>

    <!-- Logout button hooked via central-auth.js -->
    <a id="logoutBtn">
        <i class="bi bi-box-arrow-left"></i> Logout
    </a>
</div>

<!-- ================= MAIN CONTENT ================= -->
<div class="main">

<!-- ================= ORDERS SECTION ================= -->
<div id="orders" class="section active">
    <h4>Orders Dashboard</h4>

    <!-- KPI cards row -->
    <div class="row g-4 mb-4">
        <!-- Sales KPI -->
        <div class="col-md-3">
            <div class="kpi-card bg-green">
                <h6>Sales</h6>
                <h3 id="sales">$0</h3>
            </div>
        </div>
        <!-- Orders KPI -->
        <div class="col-md-3">
            <div class="kpi-card bg-purple">
                <h6>Orders</h6>
                <h3 id="ordersCount">0</h3>
            </div>
        </div>
        <!-- Drinks KPI -->
        <div class="col-md-3">
            <div class="kpi-card bg-blue">
                <h6>Drinks</h6>
                <h3 id="drinksCount">0</h3>
            </div>
        </div>
        <!-- Avg Price KPI -->
        <div class="col-md-3">
            <div class="kpi-card bg-orange">
                <h6>Avg</h6>
                <h3 id="avgPrice">$0</h3>
            </div>
        </div>
    </div>

    <!-- Latest orders table -->
    <div class="table-container">
        <h5>Latest Orders</h5>

        <!-- Central print/export button -->
        <button class="btn btn-outline-dark print-btn" onclick="openCentralPrint('#ordersTable')">
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
            <tbody id="ordersTable">
                <!-- Latest orders loaded dynamically via JS -->
            </tbody>
        </table>
    </div>
</div>

<!-- ================= HR SECTION ================= -->
<div id="hr" class="section">
    <h4>HR & Attendance Dashboard</h4>

    <!-- HR KPI cards -->
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

    <!-- HR filter buttons -->
    <button class="btn btn-outline-primary" onclick="loadHR('daily')">Daily</button>
    <button class="btn btn-outline-primary" onclick="loadHR('weekly')">Weekly</button>
    <button class="btn btn-outline-primary" onclick="loadHR('monthly')">Monthly</button>
</div>

</div>

<!-- ================= CENTRALIZED SCRIPTS ================= -->
<!-- Modular JS files for config, utils, authentication, API, and printing -->
<script src="config.js"></script>
<script src="utils.js"></script>
<script src="central-auth.js"></script>
<script src="api.js"></script>
<script src="central-printing.js"></script>

<script>
/* =====================================================
   🔐 AUTH INITIALIZATION
   - Protect page via Cognito
   - Show page after token is valid
   - Enable logout button
===================================================== */
CHARLIE.initProtectedPage({
    requireAuth: true,           // Must be logged in to access page
    enableLogout: true,          // Attach logout functionality
    logoutButtonId: 'logoutBtn'  // Logout button ID in sidebar
});

/* =====================================================
   🧭 SECTION SWITCHING FUNCTION
   - Handles sidebar clicks to show/hide sections
===================================================== */
function showSection(e, id) {
    // Hide all sections
    document.querySelectorAll(".section").forEach(s => s.classList.remove("active"));
    // Show selected section
    document.getElementById(id).classList.add("active");
    // Remove active class from all sidebar links
    document.querySelectorAll(".sidebar a").forEach(a => a.classList.remove("active"));
    // Add active class to clicked link
    e.currentTarget.classList.add("active");
}

/* =====================================================
   🚀 LOAD ORDERS DASHBOARD
   - Fetches data via CHARLIE_API.adminDashboard
   - Updates KPI cards and latest orders table dynamically
===================================================== */
async function loadOrdersDashboard() {
    if (!CHARLIE.isAdmin()) return; // Only for admin users

    try {
        const data = await CHARLIE_API.adminDashboard.fetchData();

        // Update KPI cards
        document.getElementById("sales").innerText = `$${data.sales || 0}`;
        document.getElementById("ordersCount").innerText = data.orders || 0;
        document.getElementById("drinksCount").innerText = data.drinks || 0;
        document.getElementById("avgPrice").innerText = `$${data.avg || 0}`;

        // Populate latest orders table
        const table = document.getElementById("ordersTable");
        table.innerHTML = "";
        (data.latest_orders || []).forEach(o => {
            table.innerHTML += `
                <tr>
                    <td>${o.customer_name || "Anonymous"}</td>
                    <td>${o.item}</td>
                    <td>${o.quantity}</td>
                    <td>${o.table_number || "-"}</td>
                    <td>${o.date}</td>
                </tr>
            `;
        });

    } catch (err) {
        console.error("Orders dashboard error:", err);
    }
}

/* =====================================================
   👥 LOAD HR DASHBOARD
   - Fetches HR attendance data via CHARLIE_API.adminAttendance
   - Updates KPI cards dynamically
===================================================== */
async function loadHR(type) {
    if (!CHARLIE.isAdmin()) return; // Only for admin users

    try {
        // Dynamic function call based on type: daily, weekly, monthly
        const fn = CHARLIE_API.adminAttendance[
            `get${type.charAt(0).toUpperCase() + type.slice(1)}Summary`
        ];

        const data = await fn();

        // Update HR KPI cards
        document.getElementById("cardPresent").innerText = data.summary.total_present;
        document.getElementById("cardAbsent").innerText = data.summary.total_absent;
        document.getElementById("cardLeaves").innerText = data.summary.total_leaves;

    } catch (err) {
        console.error("HR dashboard error:", err);
    }
}

/* =====================================================
   🔹 CENTRAL PRINT FUNCTION
   - Works for any table or section
   - Uses central-printing.js
===================================================== */
function openCentralPrint(selector) {
    const target = document.querySelector(selector);
    if (!target) {
        alert('Print section not found!');
        return;
    }
    const content = target.outerHTML;
    const printWindow = window.open('/central-print.html', '_blank');

    // Wait until centralPrint is ready in the print window
    const timer = setInterval(() => {
        if (printWindow && printWindow.centralPrint) {
            printWindow.centralPrint.loadContent(content);
            clearInterval(timer);
        }
    }, 100);
}

/* =====================================================
   🚀 INITIAL DATA LOAD AFTER AUTH
   - Loads dashboard and HR data once page is authenticated
===================================================== */
window.addEventListener("load", () => {
    loadOrdersDashboard();
    loadHR("daily"); // default HR view
});
</script>

</body>
</html>
```

### ✅ Summary of Changes

- Replaced old central-auth-api.js with separated:

    - central-auth.js

    - api.js

    - central-printing.js

    - CHARLIE_API.adminDashboard and CHARLIE_API.adminAttendance used instead of old calls.

    - Logout hooked to central-auth.js.

- Page remains hidden until Cognito auth passes.

- Clean, production-ready comments for every section.

---

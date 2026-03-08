# Charlie Cafe - analytics.html

### analytics.html

> **Update Version:1.0**

☕ Since all APIs are now public and Cognito is only used to protect admin access, we just need to:

- Replace CHARLIE_API.protected.adminDashboard with CHARLIE_API.public.adminDashboard.

- Keep Cognito logic for page protection (CHARLIE_AUTH.protectPage() + CHARLIE_AUTH.requireAdmin()).

- Keep all features (charts, PDF/Print, metrics).

- Add comments for clarity.

#### Here’s the fully updated analytics.html:

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Cafe Analytics ☕</title>

<!-- ===================== BOOTSTRAP CSS ===================== -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- ===================== BOOTSTRAP ICONS ===================== -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">

<!-- ===================== CHART.JS ===================== -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
/* ===================== GLOBAL ===================== */
body {
  display: none; /* Hide until authentication */
  min-height: 100vh;
  margin: 0;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  background:
    linear-gradient(rgba(58,44,31,0.75), rgba(58,44,31,0.75)),
    url('https://images.unsplash.com/photo-1509042239860-f550ce710b93');
  background-size: cover;
  background-position: center;
  color: #fff;
}

/* ===================== NAVBAR ===================== */
.navbar { background-color: #3b1f0e !important; position: fixed; width: 100%; z-index: 1000; }

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
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 14px 24px;
  color: #ddd;
  text-decoration: none;
}
.sidebar a.active,
.sidebar a:hover { background: #3b1f0e; color: #ff9800; }

/* ===================== MAIN CONTENT ===================== */
.main-content {
  margin-left: 240px;
  padding-top: 100px;
  padding-left: 20px;
  padding-right: 20px;
}

/* ===================== CONTAINER BOX ===================== */
.container-box {
  max-width: 1100px;
  margin: auto;
  padding: 30px;
  border-radius: 12px;
  background: rgba(0,0,0,0.45);
  backdrop-filter: blur(6px);
  position: relative;
}

/* ===================== CARDS ===================== */
.card { background: rgba(255,255,255,0.1); color: #fff; text-align: center; border-radius: 12px; }

/* ===================== BUTTONS ===================== */
.btn-success { position: absolute; top: 20px; right: 20px; }

/* ===================== RESPONSIVE ===================== */
@media (max-width: 768px) {
  .sidebar { position: relative; width: 100%; }
  .main-content { margin-left: 0; padding-top: 140px; }
  .btn-success { position: relative; width: 100%; }
}
</style>
</head>

<body>

<!-- ===================== NAVBAR ===================== -->
<nav class="navbar navbar-dark">
  <div class="container-fluid">
    <a class="navbar-brand" href="cafe-admin-dashboard.html">
      <i class="bi bi-cup-fill"></i> Charlie Cafe
    </a>
  </div>
</nav>

<!-- ===================== SIDEBAR ===================== -->
<div class="sidebar">
  <a href="cafe-admin-dashboard.html"><i class="bi bi-house-fill"></i> Dashboard</a>
  <a href="admin-orders.html"><i class="bi bi-list-check"></i> Orders Admin</a>
  <a href="order-status.html"><i class="bi bi-box-seam"></i> Order Status</a>
  <a class="active" href="analytics.html"><i class="bi bi-graph-up"></i> Analytics</a>
  <hr class="text-secondary">
  <a id="logoutBtn" style="cursor:pointer"><i class="bi bi-door-closed-fill"></i> Logout</a>
</div>

<!-- ===================== MAIN CONTENT ===================== -->
<div class="main-content">
  <div class="container-box">

    <h3 class="text-center mb-4">📊 Cafe Sales Analytics</h3>

    <!-- FILTER -->
    <div class="d-flex justify-content-center gap-3 flex-wrap">
      <select id="period" class="form-select w-auto">
        <option value="today">Today</option>
        <option value="week">Last 7 Days</option>
        <option value="month">This Month</option>
      </select>

      <button class="btn btn-primary" onclick="loadData()">Load Data</button>
      <button class="btn btn-outline-light" onclick="openCentralPrint('.container-box')">
        🖨️ Print / Export
      </button>
    </div>

    <!-- METRICS -->
    <div class="row mt-4 g-4">
      <div class="col-md-4"><div class="card p-3">💰 Sales: <span id="sales">0</span></div></div>
      <div class="col-md-4"><div class="card p-3">💳 Cost: <span id="cost">0</span></div></div>
      <div class="col-md-4"><div class="card p-3">📈 Profit: <span id="profit">0</span></div></div>
    </div>

    <!-- CHART -->
    <canvas id="chart" class="mt-4" height="120"></canvas>

    <!-- DOWNLOAD PDF -->
    <button class="btn btn-success" onclick="downloadPDF()">
      <i class="bi bi-file-earmark-pdf-fill"></i> Download PDF
    </button>

  </div>
</div>

<!-- ===================== LOAD CENTRAL MODULES ===================== -->
<script src="/js/config.js"></script>
<script src="/js/utils.js"></script>
<script src="/js/central-auth.js"></script>
<script src="/js/role-guard.js"></script> <!-- ADD THIS LINE -->
<script src="/js/api.js"></script>
<script src="/js/central-printing.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script>
document.addEventListener("DOMContentLoaded", async () => {

  // 🔐 Protect page: Only admin users can access
  CHARLIE_AUTH.protectPage();
  CHARLIE_AUTH.requireAdmin();
  CHARLIE_AUTH.startAutoLogoutWatcher();

  // Show body after authentication
  document.body.style.display = "block";

  // 🚪 Logout
  document.getElementById("logoutBtn")?.addEventListener("click", () => {
    CHARLIE_AUTH.logout();
  });

  // Initial load
  await loadData();
});

/* =========================================================
   LOAD ANALYTICS DATA
   - Uses PUBLIC API only
========================================================= */
async function loadData() {
  try {
    CHARLIE_AUTH.requireAdmin(); // ensure admin

    const period = document.getElementById("period").value;

    // ✅ PUBLIC API call
    const data = await CHARLIE_API.public.adminDashboard(period);

    document.getElementById("sales").textContent  = data.total_sales ?? 0;
    document.getElementById("cost").textContent   = data.total_cost ?? 0;
    document.getElementById("profit").textContent = data.profit ?? 0;

    // Destroy old chart if exists
    if (window.salesChart) window.salesChart.destroy();

    // Create new chart
    window.salesChart = new Chart(document.getElementById("chart"), {
      type: "bar",
      data: {
        labels: ["Sales", "Cost", "Profit"],
        datasets: [{
          data: [data.total_sales ?? 0, data.total_cost ?? 0, data.profit ?? 0],
          backgroundColor: ["#ffcc80","#ffab91","#c5e1a5"]
        }]
      },
      options: { plugins: { legend: { display: false } } }
    });

  } catch (err) {
    console.error("Analytics load error:", err);
    alert("Failed to load analytics data");
  }
}

/* =========================================================
   DOWNLOAD PDF (placeholder)
========================================================= */
function downloadPDF() {
  CHARLIE_AUTH.requireAdmin();
  alert("Connect to public PDF export endpoint.");
}

/* =========================================================
   CENTRAL PRINT
========================================================= */
function openCentralPrint(selector) {
  const target = document.querySelector(selector);
  if (!target) return;

  const win = window.open("central-printing.html", "_blank");
  if (!win) return alert("Popup blocked");

  win.onload = () => {
    const container = win.document.getElementById("printContent");
    if (container) container.innerHTML = target.outerHTML;
  };
}
</script>

</body>
</html>
```

---
### analytics.html

> **Update Version:1.1**

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Cafe Analytics ☕</title>

<!-- ===================== BOOTSTRAP CSS ===================== -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- ===================== BOOTSTRAP ICONS ===================== -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">

<!-- ===================== CHART.JS ===================== -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
/* ===================== GLOBAL ===================== */
body {
  display: none; /* Hide until authentication */
  min-height: 100vh;
  margin: 0;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  background:
    linear-gradient(rgba(58,44,31,0.75), rgba(58,44,31,0.75)),
    url('https://images.unsplash.com/photo-1509042239860-f550ce710b93');
  background-size: cover;
  background-position: center;
  color: #fff;
}

/* ===================== NAVBAR ===================== */
.navbar { background-color: #3b1f0e !important; position: fixed; width: 100%; z-index: 1000; }

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
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 14px 24px;
  color: #ddd;
  text-decoration: none;
}
.sidebar a.active,
.sidebar a:hover { background: #3b1f0e; color: #ff9800; }

/* ===================== MAIN CONTENT ===================== */
.main-content {
  margin-left: 240px;
  padding-top: 100px;
  padding-left: 20px;
  padding-right: 20px;
}

/* ===================== CONTAINER BOX ===================== */
.container-box {
  max-width: 1100px;
  margin: auto;
  padding: 30px;
  border-radius: 12px;
  background: rgba(0,0,0,0.45);
  backdrop-filter: blur(6px);
  position: relative;
}

/* ===================== CARDS ===================== */
.card { background: rgba(255,255,255,0.1); color: #fff; text-align: center; border-radius: 12px; }

/* ===================== BUTTONS ===================== */
.btn-success { position: absolute; top: 20px; right: 20px; }

/* ===================== RESPONSIVE ===================== */
@media (max-width: 768px) {
  .sidebar { position: relative; width: 100%; }
  .main-content { margin-left: 0; padding-top: 140px; }
  .btn-success { position: relative; width: 100%; margin-top: 10px; }
}
</style>
</head>

<body>

<!-- ===================== NAVBAR ===================== -->
<nav class="navbar navbar-dark">
  <div class="container-fluid">
    <a class="navbar-brand" href="cafe-admin-dashboard.html">
      <i class="bi bi-cup-fill"></i> Charlie Cafe
    </a>
  </div>
</nav>

<!-- ===================== SIDEBAR ===================== -->
<div class="sidebar">
  <a href="cafe-admin-dashboard.html"><i class="bi bi-house-fill"></i> Dashboard</a>
  <a href="admin-orders.html"><i class="bi bi-list-check"></i> Orders Admin</a>
  <a href="order-status.html"><i class="bi bi-box-seam"></i> Order Status</a>
  <a class="active" href="analytics.html"><i class="bi bi-graph-up"></i> Analytics</a>
  <hr class="text-secondary">
  <a id="logoutBtn" style="cursor:pointer"><i class="bi bi-door-closed-fill"></i> Logout</a>
</div>

<!-- ===================== MAIN CONTENT ===================== -->
<div class="main-content">
  <div class="container-box">

    <h3 class="text-center mb-4">📊 Cafe Sales Analytics</h3>

    <!-- FILTER -->
    <div class="d-flex justify-content-center gap-3 flex-wrap">
      <select id="period" class="form-select w-auto">
        <option value="today">Today</option>
        <option value="week">Last 7 Days</option>
        <option value="month">This Month</option>
      </select>

      <button class="btn btn-primary" onclick="loadData()">Load Data</button>
      <button class="btn btn-outline-light" onclick="openCentralPrint('.container-box')">
        🖨️ Print / Export
      </button>
    </div>

    <!-- METRICS -->
    <div class="row mt-4 g-4">
      <div class="col-md-4"><div class="card p-3">💰 Sales: <span id="sales">0</span></div></div>
      <div class="col-md-4"><div class="card p-3">💳 Cost: <span id="cost">0</span></div></div>
      <div class="col-md-4"><div class="card p-3">📈 Profit: <span id="profit">0</span></div></div>
    </div>

    <!-- CHART -->
    <canvas id="chart" class="mt-4" height="120"></canvas>

    <!-- DOWNLOAD PDF -->
    <button class="btn btn-success" onclick="downloadPDF()">
      <i class="bi bi-file-earmark-pdf-fill"></i> Download PDF
    </button>

  </div>
</div>

<!-- ===================== LOAD CENTRAL MODULES ===================== -->
<script src="/js/config.js"></script>
<script src="/js/utils.js"></script>
<script src="/js/central-auth.js"></script>
<script src="/js/role-guard.js"></script>
<script src="/js/api.js"></script>
<script src="/js/central-printing.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script>
document.addEventListener("DOMContentLoaded", async () => {

  // 🔐 Protect page: Only admin users can access
  await CHARLIE_ROLE_GUARD.adminOnly(); // checks if user is admin, blocks otherwise
  CHARLIE_AUTH.startAutoLogoutWatcher();

  // Show body after authentication
  document.body.style.display = "block";

  // 🚪 Logout
  document.getElementById("logoutBtn")?.addEventListener("click", () => {
    CHARLIE_AUTH.logout();
  });

  // Initial load of analytics
  await loadData();
});

/* =========================================================
   LOAD ANALYTICS DATA
   - Uses PUBLIC API only
   - Updates metrics and chart dynamically
========================================================= */
async function loadData() {
  try {
    // Ensure only admin can trigger
    CHARLIE_ROLE_GUARD.adminOnly();

    const period = document.getElementById("period").value;

    // ✅ PUBLIC API call to get analytics
    const data = await CHARLIE_API.public.adminDashboard(period);

    // Update metrics
    document.getElementById("sales").textContent  = data.total_sales ?? 0;
    document.getElementById("cost").textContent   = data.total_cost ?? 0;
    document.getElementById("profit").textContent = data.profit ?? 0;

    // Destroy old chart if exists
    if (window.salesChart) window.salesChart.destroy();

    // Create new chart
    window.salesChart = new Chart(document.getElementById("chart"), {
      type: "bar",
      data: {
        labels: ["Sales", "Cost", "Profit"],
        datasets: [{
          data: [data.total_sales ?? 0, data.total_cost ?? 0, data.profit ?? 0],
          backgroundColor: ["#ffcc80","#ffab91","#c5e1a5"]
        }]
      },
      options: { plugins: { legend: { display: false } } }
    });

  } catch (err) {
    console.error("Analytics load error:", err);
    alert("Failed to load analytics data");
  }
}

/* =========================================================
   DOWNLOAD PDF (placeholder)
   - Extend with real PDF export API
========================================================= */
function downloadPDF() {
  CHARLIE_ROLE_GUARD.adminOnly();
  alert("Connect to public PDF export endpoint.");
}

/* =========================================================
   CENTRAL PRINT
   - Opens new window to print the container
========================================================= */
function openCentralPrint(selector) {
  const target = document.querySelector(selector);
  if (!target) return;

  const win = window.open("central-printing.html", "_blank");
  if (!win) return alert("Popup blocked");

  win.onload = () => {
    const container = win.document.getElementById("printContent");
    if (container) container.innerHTML = target.outerHTML;
  };
}
</script>

</body>
</html>
```

### ✅ Features in This Final Version

- Admin Role Guard: CHARLIE_ROLE_GUARD.adminOnly() ensures only admin users can access.

- Body Hidden Until Auth: Prevents page flash for unauthorized users.

- Logout Button: Fully functional via CHARLIE_AUTH.logout().

- Metrics & Chart: Dynamically updates based on API data.

- Print & PDF: Central print works; PDF placeholder ready for integration.

- Responsive & Modern UI: Sidebar + navbar + container box styled.

- Comments: Every function and critical section explained for maintenance or interview.
---
### analytics.html


```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Cafe Analytics ☕</title>

<!-- ===================== BOOTSTRAP CSS ===================== -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- ===================== BOOTSTRAP ICONS ===================== -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">

<!-- ===================== CHART.JS ===================== -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
/* ===================== GLOBAL ===================== */
body {
  display: none; /* Hide until authentication */
  min-height: 100vh;
  margin: 0;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  background:
    linear-gradient(rgba(58,44,31,0.75), rgba(58,44,31,0.75)),
    url('https://images.unsplash.com/photo-1509042239860-f550ce710b93');
  background-size: cover;
  background-position: center;
  color: #fff;
}

/* ===================== NAVBAR ===================== */
.navbar { background-color: #3b1f0e !important; position: fixed; width: 100%; z-index: 1000; }

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
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 14px 24px;
  color: #ddd;
  text-decoration: none;
}
.sidebar a.active,
.sidebar a:hover { background: #3b1f0e; color: #ff9800; }

/* ===================== MAIN CONTENT ===================== */
.main-content {
  margin-left: 240px;
  padding-top: 100px;
  padding-left: 20px;
  padding-right: 20px;
}

/* ===================== CONTAINER BOX ===================== */
.container-box {
  max-width: 1100px;
  margin: auto;
  padding: 30px;
  border-radius: 12px;
  background: rgba(0,0,0,0.45);
  backdrop-filter: blur(6px);
  position: relative;
}

/* ===================== CARDS ===================== */
.card { background: rgba(255,255,255,0.1); color: #fff; text-align: center; border-radius: 12px; }

/* ===================== BUTTONS ===================== */
.btn-success { position: absolute; top: 20px; right: 20px; }

/* ===================== RESPONSIVE ===================== */
@media (max-width: 768px) {
  .sidebar { position: relative; width: 100%; }
  .main-content { margin-left: 0; padding-top: 140px; }
  .btn-success { position: relative; width: 100%; margin-top: 10px; }
}
</style>
</head>

<body>

<!-- ===================== NAVBAR ===================== -->
<nav class="navbar navbar-dark">
  <div class="container-fluid">
    <a class="navbar-brand" href="cafe-admin-dashboard.html">
      <i class="bi bi-cup-fill"></i> Charlie Cafe
    </a>
  </div>
</nav>

<!-- ===================== SIDEBAR ===================== -->
<div class="sidebar">
  <a href="https://dyoqxkx8bd8d7.cloudfront.net/cafe-admin-dashboard.html"><i class="bi bi-house-fill"></i> Dashboard</a>
  <a href="https://dyoqxkx8bd8d7.cloudfront.net/admin-orders.html"><i class="bi bi-list-check"></i> Orders Admin</a>
  <a href="https://dyoqxkx8bd8d7.cloudfront.net/order-status.html"><i class="bi bi-box-seam"></i> Order Status</a>
  <a class="active" href="https://dyoqxkx8bd8d7.cloudfront.net/analytics.html"><i class="bi bi-graph-up"></i> Analytics</a>
  <hr class="text-secondary">
  <a id="logoutBtn" style="cursor:pointer"><i class="bi bi-door-closed-fill"></i> Logout</a>
</div>

<!-- ===================== MAIN CONTENT ===================== -->
<div class="main-content">
  <div class="container-box">

    <h3 class="text-center mb-4">📊 Cafe Sales Analytics</h3>

    <!-- FILTER -->
    <div class="d-flex justify-content-center gap-3 flex-wrap">
      <select id="period" class="form-select w-auto">
        <option value="today">Today</option>
        <option value="week">Last 7 Days</option>
        <option value="month">This Month</option>
      </select>

      <button class="btn btn-primary" onclick="loadData()">Load Data</button>
      <button class="btn btn-outline-light" onclick="openCentralPrint('.container-box')">
        🖨️ Print / Export
      </button>
    </div>

    <!-- METRICS -->
    <div class="row mt-4 g-4">
      <div class="col-md-4"><div class="card p-3">💰 Sales: <span id="sales">0</span></div></div>
      <div class="col-md-4"><div class="card p-3">💳 Cost: <span id="cost">0</span></div></div>
      <div class="col-md-4"><div class="card p-3">📈 Profit: <span id="profit">0</span></div></div>
    </div>

    <!-- CHART -->
    <canvas id="chart" class="mt-4" height="120"></canvas>

    <!-- DOWNLOAD PDF -->
    <button class="btn btn-success" onclick="downloadPDF()">
      <i class="bi bi-file-earmark-pdf-fill"></i> Download PDF
    </button>

  </div>
</div>

<!-- ===================== LOAD CENTRAL MODULES ===================== -->
<script src="/js/config.js"></script>
<script src="/js/utils.js"></script>
<script src="/js/central-auth.js"></script>
<script src="/js/role-guard.js"></script>
<script src="/js/api.js"></script>
<script src="/js/central-printing.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script>
document.addEventListener("DOMContentLoaded", async () => {

  // 🔐 Protect page: Only admin users can access
  await CHARLIE_ROLE_GUARD.adminOnly();
  CHARLIE_AUTH.startAutoLogoutWatcher();

  // Show body after authentication
  document.body.style.display = "block";

  // 🚪 Logout button
  document.getElementById("logoutBtn")?.addEventListener("click", () => {
    CHARLIE_AUTH.logout();
  });

  // Initial load of analytics
  await loadData();
});

/* =========================================================
   LOAD ANALYTICS DATA — CORRECTED
   - Uses CHARLIE_API.getAnalytics(period)
   - Updates metrics and chart dynamically
   - Fully admin-protected
========================================================= */
async function loadData() {
    try {
        // 🔒 Admin-only guard
        await CHARLIE_ROLE_GUARD.adminOnly();

        // 📅 Read selected period from dropdown
        const periodDropdown = document.getElementById("period");
        const period = periodDropdown ? periodDropdown.value : "today";

        // 🔹 Map frontend period to API expected values
        const periodMap = { today: "today", week: "week", month: "month" };
        const apiPeriod = periodMap[period] || "today";

        // ✅ Fetch analytics data from backend
        const data = await CHARLIE_API.getAnalytics(apiPeriod);

        // 📊 Update dashboard metrics
        document.getElementById("sales").textContent  = data.total_sales ?? 0;
        document.getElementById("cost").textContent   = data.total_cost ?? 0;
        document.getElementById("profit").textContent = data.profit ?? 0;

        // 📉 Destroy previous chart if exists
        if (window.salesChart) window.salesChart.destroy();

        // 📈 Create new Chart.js bar chart
        const ctx = document.getElementById("chart").getContext("2d");
        window.salesChart = new Chart(ctx, {
            type: "bar",
            data: {
                labels: ["Sales", "Cost", "Profit"],
                datasets: [{
                    data: [data.total_sales ?? 0, data.total_cost ?? 0, data.profit ?? 0],
                    backgroundColor: ["#ffcc80", "#ffab91", "#c5e1a5"]
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: { display: false },
                    tooltip: { mode: 'index', intersect: false }
                },
                scales: { y: { beginAtZero: true } }
            }
        });

    } catch (err) {
        // ❌ Error handling
        console.error("Analytics load error:", err);
        alert("Failed to load analytics data. Check console for details.");
    }
}

/* =========================================================
   DOWNLOAD PDF (placeholder)
   - Extend with real PDF export endpoint
========================================================= */
function downloadPDF() {
    CHARLIE_ROLE_GUARD.adminOnly();
    alert("Connect to public PDF export endpoint.");
}

/* =========================================================
   CENTRAL PRINT
   - Opens new window to print the container
========================================================= */
function openCentralPrint(selector) {
    const target = document.querySelector(selector);
    if (!target) return;

    const win = window.open("central-printing.html", "_blank");
    if (!win) return alert("Popup blocked");

    win.onload = () => {
        const container = win.document.getElementById("printContent");
        if (container) container.innerHTML = target.outerHTML;
    };
}
</script>

</body>
</html>
```

### ✅ Changes made:

- loadData() now correctly calls CHARLIE_API.getAnalytics(apiPeriod).

- Added mapping for period to backend expected values.

- Maintains old chart destruction and creates a fresh Chart.js bar chart.

- Fully commented for clarity.

- Admin-only guard enforced at all key points.
---
### analytics.html

✅ Load Data button works anytime, even after 10 minutes or 1 hour.

✅ Auto-refresh every 10 minutes (optional, can adjust).

✅ Admin-only protection intact.

✅ Cache-busting ensures fresh Lambda data.

✅ Fully commented for clarity.

#### Here’s the final ready-to-deploy version:

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Cafe Analytics ☕</title>

<!-- ===================== BOOTSTRAP CSS ===================== -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- ===================== BOOTSTRAP ICONS ===================== -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">

<!-- ===================== CHART.JS ===================== -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
/* ===================== GLOBAL ===================== */
body {
  display: none; /* Hide until authentication */
  min-height: 100vh;
  margin: 0;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  background:
    linear-gradient(rgba(58,44,31,0.75), rgba(58,44,31,0.75)),
    url('https://images.unsplash.com/photo-1509042239860-f550ce710b93');
  background-size: cover;
  background-position: center;
  color: #fff;
}

/* ===================== NAVBAR ===================== */
.navbar { background-color: #3b1f0e !important; position: fixed; width: 100%; z-index: 1000; }

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
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 14px 24px;
  color: #ddd;
  text-decoration: none;
}
.sidebar a.active,
.sidebar a:hover { background: #3b1f0e; color: #ff9800; }

/* ===================== MAIN CONTENT ===================== */
.main-content {
  margin-left: 240px;
  padding-top: 100px;
  padding-left: 20px;
  padding-right: 20px;
}

/* ===================== CONTAINER BOX ===================== */
.container-box {
  max-width: 1100px;
  margin: auto;
  padding: 30px;
  border-radius: 12px;
  background: rgba(0,0,0,0.45);
  backdrop-filter: blur(6px);
  position: relative;
}

/* ===================== CARDS ===================== */
.card { background: rgba(255,255,255,0.1); color: #fff; text-align: center; border-radius: 12px; }

/* ===================== BUTTONS ===================== */
.btn-success { position: absolute; top: 20px; right: 20px; }

/* ===================== RESPONSIVE ===================== */
@media (max-width: 768px) {
  .sidebar { position: relative; width: 100%; }
  .main-content { margin-left: 0; padding-top: 140px; }
  .btn-success { position: relative; width: 100%; margin-top: 10px; }
}
</style>
</head>

<body>

<!-- ===================== NAVBAR ===================== -->
<nav class="navbar navbar-dark">
  <div class="container-fluid">
    <a class="navbar-brand" href="cafe-admin-dashboard.html">
      <i class="bi bi-cup-fill"></i> Charlie Cafe
    </a>
  </div>
</nav>

<!-- ===================== SIDEBAR ===================== -->
<div class="sidebar">
  <a href="cafe-admin-dashboard.html"><i class="bi bi-house-fill"></i> Dashboard</a>
  <a href="admin-orders.html"><i class="bi bi-list-check"></i> Orders Admin</a>
  <a href="order-status.html"><i class="bi bi-box-seam"></i> Order Status</a>
  <a class="active" href="analytics.html"><i class="bi bi-graph-up"></i> Analytics</a>
  <hr class="text-secondary">
  <a id="logoutBtn" style="cursor:pointer"><i class="bi bi-door-closed-fill"></i> Logout</a>
</div>

<!-- ===================== MAIN CONTENT ===================== -->
<div class="main-content">
  <div class="container-box">

    <h3 class="text-center mb-4">📊 Cafe Sales Analytics</h3>

    <!-- ===================== FILTER ===================== -->
    <div class="d-flex justify-content-center gap-3 flex-wrap">
      <select id="period" class="form-select w-auto">
        <option value="today">Today</option>
        <option value="week">Last 7 Days</option>
        <option value="month">This Month</option>
      </select>

      <button id="loadDataBtn" class="btn btn-primary">Load Data</button>

      <button class="btn btn-outline-light" onclick="openCentralPrint('.container-box')">
        🖨️ Print / Export
      </button>
    </div>

    <!-- ===================== METRICS ===================== -->
    <div class="row mt-4 g-4">
      <div class="col-md-4"><div class="card p-3">💰 Sales: <span id="sales">0</span></div></div>
      <div class="col-md-4"><div class="card p-3">💳 Cost: <span id="cost">0</span></div></div>
      <div class="col-md-4"><div class="card p-3">📈 Profit: <span id="profit">0</span></div></div>
    </div>

    <!-- ===================== CHART ===================== -->
    <canvas id="chart" class="mt-4" height="120"></canvas>

    <!-- ===================== DOWNLOAD PDF ===================== -->
    <button class="btn btn-success" onclick="downloadPDF()">
      <i class="bi bi-file-earmark-pdf-fill"></i> Download PDF
    </button>

  </div>
</div>

<!-- ===================== LOAD CENTRAL MODULES ===================== -->
<script src="/js/config.js"></script>
<script src="/js/utils.js"></script>
<script src="/js/central-auth.js"></script>
<script src="/js/role-guard.js"></script>
<script src="/js/api.js"></script>
<script src="/js/central-printing.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script>
/* =========================================================
   PAGE INIT — RUN ON DOM CONTENT LOADED
   - Protect admin-only access
   - Show body only after auth
   - Setup Load Data button
========================================================= */
document.addEventListener("DOMContentLoaded", async () => {
    await CHARLIE_ROLE_GUARD.adminOnly();
    CHARLIE_AUTH.startAutoLogoutWatcher();
    document.body.style.display = "block";

    // Logout button
    document.getElementById("logoutBtn")?.addEventListener("click", () => {
        CHARLIE_AUTH.logout();
    });

    // Load Data button click listener
    document.getElementById("loadDataBtn")?.addEventListener("click", () => {
        loadData(true); // force fresh fetch
    });

    // Initial load of data
    await loadData(true);

    // Auto-refresh every 10 minutes (600000 ms)
    setInterval(() => loadData(true), 10 * 60 * 1000);
});

/* =========================================================
   LOAD ANALYTICS DATA
   - `forceReload` ensures fresh data every fetch
   - Updates metrics and chart dynamically
   - Works anytime after page load, even after hours
========================================================= */
async function loadData(forceReload = false) {
    try {
        await CHARLIE_ROLE_GUARD.adminOnly();

        const periodDropdown = document.getElementById("period");
        const period = periodDropdown ? periodDropdown.value : "today";
        const periodMap = { today: "today", week: "week", month: "month" };
        const apiPeriod = periodMap[period] || "today";

        // Add cache-busting query to prevent stale data
        const cacheBuster = forceReload ? `&_ts=${Date.now()}` : "";
        const url = `${window.CHARLIE_CONFIG.API_BASE}/analytics?period=${encodeURIComponent(apiPeriod)}${cacheBuster}`;

        const data = await fetch(url, { headers: { "Content-Type": "application/json" } })
            .then(res => {
                if (!res.ok) throw new Error(`HTTP ${res.status}`);
                return res.json();
            });

        // Update metrics
        document.getElementById("sales").textContent  = data.total_sales ?? 0;
        document.getElementById("cost").textContent   = data.total_cost ?? 0;
        document.getElementById("profit").textContent = data.profit ?? 0;

        // Update chart
        if (window.salesChart) window.salesChart.destroy();
        const ctx = document.getElementById("chart").getContext("2d");
        window.salesChart = new Chart(ctx, {
            type: "bar",
            data: {
                labels: ["Sales", "Cost", "Profit"],
                datasets: [{
                    data: [data.total_sales ?? 0, data.total_cost ?? 0, data.profit ?? 0],
                    backgroundColor: ["#ffcc80", "#ffab91", "#c5e1a5"]
                }]
            },
            options: { 
                responsive: true,
                plugins: { legend: { display: false }, tooltip: { mode: 'index', intersect: false } },
                scales: { y: { beginAtZero: true } }
            }
        });

    } catch (err) {
        console.error("Analytics load error:", err);
        alert("Failed to load analytics data. See console for details.");
    }
}

/* =========================================================
   DOWNLOAD PDF PLACEHOLDER
   - Extend with real export logic if needed
========================================================= */
function downloadPDF() {
    CHARLIE_ROLE_GUARD.adminOnly();
    alert("Connect to public PDF export endpoint.");
}

/* =========================================================
   CENTRAL PRINTING — PRINT SPECIFIC CONTAINER
========================================================= */
function openCentralPrint(selector) {
    const target = document.querySelector(selector);
    if (!target) return;

    const win = window.open("central-printing.html", "_blank");
    if (!win) return alert("Popup blocked");

    win.onload = () => {
        const container = win.document.getElementById("printContent");
        if (container) container.innerHTML = target.outerHTML;
    };
}
</script>

</body>
</html>
```

### ✅ Highlights of Fixes:

loadData(true) with cache-busting ensures fresh analytics every time.

Load Data button properly triggers data fetch anytime.

Auto-refresh every 10 minutes for live data monitoring.

Chart.js refresh ensures old charts are destroyed before rendering new.

Fully admin-protected using CHARLIE_ROLE_GUARD.adminOnly().

Comments added for clarity and future maintenance.

---



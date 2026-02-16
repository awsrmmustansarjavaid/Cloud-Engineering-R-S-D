# Charlie Cafe - order-status.html


### order-status.html

> **Update Version:1.0**

You now have:

config.js

utils.js

central-auth.js

api.js

central-printing.js

So we must:

### ✅ WHAT WILL CHANGE

1. ❌ Remove old:

```
<script src="/js/central-auth-api.js"></script>
```

2. ✅ Load new separated files in correct order

3. ✅ Replace:

```
CHARLIE.auth.protectPage()
CHARLIE.authFetch()
CHARLIE.CONFIG
```

With:

```
CHARLIE_AUTH.protectPage()
CHARLIE_API.protected
CHARLIE_CONFIG
```

4. ✅ Use /prod stage (already handled in config.js)

5. ✅ Keep design, background, layout untouched

🔥 FULLY UPDATED — order-status.html

(Only logic updated. UI untouched.)

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
/* ✅ DESIGN UNCHANGED */
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

.main-content {
    margin-left: 240px;
    padding-top: 100px;
    padding-bottom: 50px;
}

.status-container {
    background: rgba(30, 30, 30, 0.85);
    border-radius: 20px;
    padding: 40px;
    max-width: 1100px;
    margin: auto;
}

.card-metric {
    background: rgba(59, 31, 14, 0.85);
    border-radius: 15px;
    padding: 20px;
    text-align: center;
}

.btn-transparent {
    background: rgba(255,255,255,0.1);
    border: 1px solid #ff9800;
    color: #ff9800;
    display: flex;
    align-items: center;
}

.btn-transparent i { margin-right: 8px; }

@media (max-width:768px){
    .main-content { margin-left: 0; padding-top: 120px; }
    .sidebar { width: 100%; position: relative; }
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
    <a href="cafe-admin-dashboard.html"><i class="bi bi-house-door-fill"></i> Main Dashboard</a>
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

<!-- ================= ACTION BUTTONS ================= -->
<div class="d-flex justify-content-end gap-2 mb-4">

    <button class="btn btn-transparent" onclick="window.print()">
        <i class="bi bi-printer"></i> Print
    </button>

    <button class="btn btn-transparent" onclick="exportCSV()">
        <i class="bi bi-download"></i> Export CSV
    </button>

</div>

<!-- ================= METRICS ================= -->
<div id="metrics" class="row g-4 mb-5 justify-content-center"></div>

<!-- ================= ORDERS TABLE ================= -->
<div id="ordersPrintArea" class="table-responsive">
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

<!-- =========================================================
     LOAD NEW MODULAR ARCHITECTURE (ORDER MATTERS)
========================================================= -->
<script src="config.js"></script>
<script src="utils.js"></script>
<script src="central-auth.js"></script>
<script src="api.js"></script>

<script>
/* =========================================================
   🔐 AUTH PROTECTION (COGNITO REQUIRED PAGE)
========================================================= */
CHARLIE_AUTH.protectPage();
CHARLIE_AUTH.startAutoLogoutWatcher();

/* ================= LOGOUT BUTTON ================= */
document.querySelector(".logout-btn").onclick = () => {
    CHARLIE_AUTH.logout();
};

/* =========================================================
   📊 LOAD ORDER STATUS DATA (PROTECTED ENDPOINT)
========================================================= */
document.addEventListener("DOMContentLoaded", async () => {

    try {

        const data = await CHARLIE_API.protected.getOrderStatus?.() 
            || await fetch(`${CHARLIE_CONFIG.API_BASE}/order-status`, {
                headers: {
                    Authorization: "Bearer " + localStorage.getItem("access_token")
                }
            }).then(res => res.json());

        const metricsDiv = document.getElementById("metrics");
        const ordersBody = document.getElementById("orders");

        metricsDiv.innerHTML = "";
        ordersBody.innerHTML = "";

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

    } catch (err) {

        document.getElementById("orders").innerHTML = `
            <tr>
                <td colspan="5" class="text-center text-danger">
                    ⚠️ ${err.message}
                </td>
            </tr>`;
    }
});

/* =========================================================
   📄 CSV EXPORT (PROTECTED)
========================================================= */
function exportCSV() {

    fetch(`${CHARLIE_CONFIG.API_BASE}/order-status?export=true`, {
        headers: {
            Authorization: "Bearer " + localStorage.getItem("access_token")
        }
    })
    .then(res => {
        if (!res.ok) throw new Error("CSV export failed");
        return res.blob();
    })
    .then(blob => {
        const link = document.createElement("a");
        link.href = URL.createObjectURL(blob);
        link.download = "orders.csv";
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    })
    .catch(err => alert("❌ " + err.message));
}
</script>

</body>
</html>
```


---



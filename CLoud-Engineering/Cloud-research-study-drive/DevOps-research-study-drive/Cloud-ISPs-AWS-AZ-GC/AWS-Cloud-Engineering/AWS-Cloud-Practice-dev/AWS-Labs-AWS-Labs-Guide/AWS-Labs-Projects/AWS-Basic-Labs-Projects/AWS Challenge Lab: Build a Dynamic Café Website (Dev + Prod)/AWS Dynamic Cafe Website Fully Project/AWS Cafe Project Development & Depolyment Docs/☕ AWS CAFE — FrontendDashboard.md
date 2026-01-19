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
# ☕ Charlie Cafe Sales Analytics


### 3️⃣ Frontend Admin Analytics Dashboard

```
sudo nano /var/www/html/analytics.html
```

#### 1️⃣ Charlie Cafe Sales - Simple analytics.html

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
---
#### 2️⃣ analytics.html — WITH SHARED SIDEBAR (FULLY COMMENTED)

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
---
#### 3️⃣ analytics.html — WITH SHARED SIDEBAR & Welcome Toggle Notification (FULLY COMMENTED)

#### 🔍 What You Gained

| Feature              | Why it matters                          |
| -------------------- | --------------------------------------- |
| Welcome toast        | Better UX + professional dashboard feel |
| Reusable toggle flag | Easy future **enable/disable**          |
| Clean comments       | Portfolio & learning ready              |
| Same design language | Matches Order-Status dashboard          |

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Cafe Analytics ☕</title>

<!-- ===================== BOOTSTRAP CSS ===================== -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- ===================== CHART.JS ===================== -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
/* ===================== BODY & BACKGROUND ===================== */
body {
  min-height: 100vh;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  background:
    linear-gradient(rgba(58,44,31,0.75), rgba(58,44,31,0.75)),
    url('https://images.unsplash.com/photo-1509042239860-f550ce710b93');
  background-size: cover;
  background-position: center;
  color: #fff;
}

/* ===================== MAIN CONTAINER ===================== */
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

/* PDF button */
.btn-success {
  background: linear-gradient(45deg, #8b4513, #f4a460);
  border: none;
  position: absolute;
  top: 20px;
  right: 20px;
}

/* ===================== METRIC CARDS ===================== */
.card {
  border-radius: 12px;
  background: rgba(255,255,255,0.1);
  color: #fff;
  text-align: center;
  font-weight: bold;
  transition: transform 0.2s;
}
.card:hover { transform: translateY(-5px); }

/* ===================== CHART ===================== */
canvas {
  background: rgba(0,0,0,0.1);
  border-radius: 12px;
  padding: 15px;
}
</style>
</head>

<body>

<!-- ===================== MAIN PAGE ===================== -->
<div class="container mt-4 position-relative">

  <!-- Page Title -->
  <h3>☕ Cafe Sales Analytics</h3>

  <!-- ===================== PERIOD SELECT ===================== -->
  <div class="d-flex justify-content-center align-items-center mt-4 gap-3 flex-wrap">
    <select id="period" class="form-select w-auto">
      <option value="today">Today</option>
      <option value="week">Last 7 Days</option>
      <option value="month">This Month</option>
    </select>

    <button class="btn btn-primary" onclick="loadData()">Load Data</button>
  </div>

  <!-- ===================== METRICS ===================== -->
  <div class="row mt-4 g-4">
    <div class="col-md-4"><div class="card p-3">Sales: <span id="sales">0</span></div></div>
    <div class="col-md-4"><div class="card p-3">Cost: <span id="cost">0</span></div></div>
    <div class="col-md-4"><div class="card p-3">Profit: <span id="profit">0</span></div></div>
  </div>

  <!-- ===================== CHART ===================== -->
  <canvas id="chart" class="mt-4" height="120"></canvas>

  <!-- ===================== PDF DOWNLOAD ===================== -->
  <button class="btn btn-success" onclick="downloadPDF()">📄 Download PDF</button>

</div>

<!-- ===================== WELCOME TOAST ===================== -->
<!-- Shows once when analytics page is opened -->
<div class="toast-container position-fixed top-0 end-0 p-3">
  <div id="analyticsWelcomeToast" class="toast">
    <div class="toast-header">
      <strong class="me-auto">📊 Analytics Dashboard</strong>
      <button class="btn-close" data-bs-dismiss="toast"></button>
    </div>
    <div class="toast-body">
      Welcome to Cafe Analytics! Select a period to view performance insights.
    </div>
  </div>
</div>

<script>
/* ============================================================
   ENVIRONMENT CONFIG
   ============================================================ */
const API_BASE_URL = "https://API_ID.execute-api.REGION.amazonaws.com/prod";
const ANALYTICS_API = `${API_BASE_URL}/analytics`;
const PDF_API = `${API_BASE_URL}/report/pdf`;

/* ============================================================
   SHOW WELCOME TOAST ON PAGE LOAD
   ============================================================ */
document.addEventListener("DOMContentLoaded", () => {

  // Toggle flag (future use: localStorage / user preferences)
  const showWelcomeToast = true;

  if (showWelcomeToast) {
    new bootstrap.Toast(
      document.getElementById("analyticsWelcomeToast"),
      { delay: 2500 }
    ).show();
  }
});

/* ============================================================
   LOAD ANALYTICS DATA
   ============================================================ */
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

/* ============================================================
   DOWNLOAD PDF REPORT
   ============================================================ */
function downloadPDF() {
  window.open(PDF_API);
}
</script>

<!-- ===================== BOOTSTRAP JS ===================== -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
```

---
#### 4️⃣ analytics.html — WITH SHARED SIDEBAR & Welcome Toggle Notification (FULLY COMMENTED - Recommanded)

✅ Welcome toast → only once per day (localStorage)

✅ “Data Loaded” toast → after clicking Load Data

✅ Sidebar navigation → SAME pattern as your dashboard & order-status

✅ Very clear comments (learning + future reference)

✅ Nothing breaks your existing analytics / chart / PDF logic



```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Cafe Analytics ☕</title>

<!-- ===================== BOOTSTRAP CSS ===================== -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- ===================== CHART.JS ===================== -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
/* ===================== GLOBAL BODY ===================== */
body {
  min-height: 100vh;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  margin: 0;
  background:
    linear-gradient(rgba(58,44,31,0.75), rgba(58,44,31,0.75)),
    url('https://images.unsplash.com/photo-1509042239860-f550ce710b93');
  background-size: cover;
  background-position: center;
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

/* ===================== CONTAINER ===================== */
.container-box {
  backdrop-filter: blur(6px);
  background-color: rgba(0,0,0,0.45);
  padding: 30px;
  border-radius: 12px;
  box-shadow: 0 8px 20px rgba(0,0,0,0.4);
  max-width: 1100px;
  margin: auto;
}

/* ===================== HEADINGS ===================== */
h3 {
  text-align: center;
  font-weight: bold;
  color: #ffddaa;
}

/* ===================== BUTTONS ===================== */
.form-select, .btn {
  border-radius: 50px;
  font-weight: bold;
}

.btn-primary {
  background: linear-gradient(45deg, #a0522d, #d2b48c);
  border: none;
}

.btn-success {
  background: linear-gradient(45deg, #8b4513, #f4a460);
  border: none;
  position: absolute;
  top: 20px;
  right: 20px;
}

/* ===================== METRIC CARDS ===================== */
.card {
  border-radius: 12px;
  background: rgba(255,255,255,0.1);
  color: #fff;
  font-weight: bold;
  text-align: center;
  transition: transform 0.2s;
}
.card:hover { transform: translateY(-5px); }

/* ===================== RESPONSIVE ===================== */
@media (max-width: 768px) {
  .sidebar {
    position: relative;
    width: 100%;
    min-height: auto;
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
  <div class="container-box position-relative">

    <h3>☕ Cafe Sales Analytics</h3>

    <!-- ===================== FILTER ===================== -->
    <div class="d-flex justify-content-center gap-3 mt-4 flex-wrap">
      <select id="period" class="form-select w-auto">
        <option value="today">Today</option>
        <option value="week">Last 7 Days</option>
        <option value="month">This Month</option>
      </select>
      <button class="btn btn-primary" onclick="loadData()">Load Data</button>
    </div>

    <!-- ===================== METRICS ===================== -->
    <div class="row mt-4 g-4">
      <div class="col-md-4"><div class="card p-3">Sales: <span id="sales">0</span></div></div>
      <div class="col-md-4"><div class="card p-3">Cost: <span id="cost">0</span></div></div>
      <div class="col-md-4"><div class="card p-3">Profit: <span id="profit">0</span></div></div>
    </div>

    <!-- ===================== CHART ===================== -->
    <canvas id="chart" class="mt-4" height="120"></canvas>

    <!-- ===================== PDF ===================== -->
    <button class="btn btn-success" onclick="downloadPDF()">📄 Download PDF</button>
  </div>
</div>

<!-- ===================== TOASTS ===================== -->

<!-- Welcome (Once Per Day) -->
<div class="toast-container position-fixed top-0 end-0 p-3">
  <div id="welcomeToast" class="toast">
    <div class="toast-header">
      <strong class="me-auto">📊 Analytics</strong>
      <button class="btn-close" data-bs-dismiss="toast"></button>
    </div>
    <div class="toast-body">
      Welcome to the Analytics Dashboard!
    </div>
  </div>
</div>

<!-- Data Loaded -->
<div class="toast-container position-fixed bottom-0 end-0 p-3">
  <div id="dataToast" class="toast">
    <div class="toast-header bg-success text-white">
      <strong class="me-auto">Data Loaded</strong>
      <button class="btn-close btn-close-white" data-bs-dismiss="toast"></button>
    </div>
    <div class="toast-body">
      ✅ Analytics updated successfully!
    </div>
  </div>
</div>

<!-- ===================== SCRIPTS ===================== -->
<script>
/* ===================== API CONFIG ===================== */
const API_BASE_URL = "https://API_ID.execute-api.REGION.amazonaws.com/prod";
const ANALYTICS_API = `${API_BASE_URL}/analytics`;
const PDF_API = `${API_BASE_URL}/report/pdf`;

/* ===================== WELCOME TOAST (ONCE PER DAY) ===================== */
document.addEventListener("DOMContentLoaded", () => {
  const today = new Date().toISOString().split("T")[0];
  const lastSeen = localStorage.getItem("analyticsWelcome");

  if (lastSeen !== today) {
    new bootstrap.Toast(document.getElementById("welcomeToast"), {
      delay: 2500
    }).show();
    localStorage.setItem("analyticsWelcome", today);
  }
});

/* ===================== LOAD ANALYTICS DATA ===================== */
function loadData() {
  const period = document.getElementById("period").value;

  fetch(`${ANALYTICS_API}?period=${period}`)
    .then(res => res.json())
    .then(data => {

      document.getElementById("sales").innerText = data.total_sales;
      document.getElementById("cost").innerText = data.total_cost;
      document.getElementById("profit").innerText = data.profit;

      const ctx = document.getElementById("chart").getContext("2d");
      if (window.salesChart) window.salesChart.destroy();

      window.salesChart = new Chart(ctx, {
        type: "line",
        data: {
          labels: ["Sales", "Cost", "Profit"],
          datasets: [{
            data: [data.total_sales, data.total_cost, data.profit],
            borderColor: "#ffddaa",
            backgroundColor: "rgba(255,221,170,0.3)",
            fill: true,
            tension: 0.3
          }]
        },
        options: {
          plugins: { legend: { display: false } },
          scales: { y: { beginAtZero: true } }
        }
      });

      /* ---- Show success toast AFTER data loads ---- */
      new bootstrap.Toast(document.getElementById("dataToast")).show();
    });
}

/* ===================== DOWNLOAD PDF ===================== */
function downloadPDF() {
  window.open(PDF_API);
}
</script>

<!-- ===================== BOOTSTRAP JS ===================== -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
```

### 🔍 FEATURE BREAKDOWN (VERY IMPORTANT)

#### 🔁 Toast Once Per Day

```
localStorage.getItem("analyticsWelcome")
```

✔ Prevents annoying repeat notifications

✔ Real dashboards use this pattern

#### 📊 Data Loaded Toast

```
new bootstrap.Toast(document.getElementById("dataToast")).show();
```

✔ Confirms API success

✔ Great UX feedback

#### 🧭 Sidebar Navigation

✔ Same structure as dashboard + order-status

✔ Easy to secure later using Cognito groups

----

### 5️⃣ ✅ UPDATED analytics.html (SECURE-READY)

✅ Secure container wrapper

✅ Central auth layer (secure-dashboard.js)

✅ Page hidden until Cognito auth succeeds

✅ No auth logic duplicated

✅ Clear comments showing ONLY what was added/changed

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Cafe Analytics ☕</title>

<!-- ===================== BOOTSTRAP CSS ===================== -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- ===================== CHART.JS ===================== -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
/* ===================== GLOBAL BODY ===================== */
body {
  min-height: 100vh;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  margin: 0;
  background:
    linear-gradient(rgba(58,44,31,0.75), rgba(58,44,31,0.75)),
    url('https://images.unsplash.com/photo-1509042239860-f550ce710b93');
  background-size: cover;
  background-position: center;
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

/* ===================== CONTAINER ===================== */
.container-box {
  backdrop-filter: blur(6px);
  background-color: rgba(0,0,0,0.45);
  padding: 30px;
  border-radius: 12px;
  box-shadow: 0 8px 20px rgba(0,0,0,0.4);
  max-width: 1100px;
  margin: auto;
}

/* ===================== HEADINGS ===================== */
h3 {
  text-align: center;
  font-weight: bold;
  color: #ffddaa;
}

/* ===================== BUTTONS ===================== */
.form-select, .btn {
  border-radius: 50px;
  font-weight: bold;
}

.btn-primary {
  background: linear-gradient(45deg, #a0522d, #d2b48c);
  border: none;
}

.btn-success {
  background: linear-gradient(45deg, #8b4513, #f4a460);
  border: none;
  position: absolute;
  top: 20px;
  right: 20px;
}

/* ===================== METRIC CARDS ===================== */
.card {
  border-radius: 12px;
  background: rgba(255,255,255,0.1);
  color: #fff;
  font-weight: bold;
  text-align: center;
  transition: transform 0.2s;
}
.card:hover { transform: translateY(-5px); }

/* ===================== RESPONSIVE ===================== */
@media (max-width: 768px) {
  .sidebar {
    position: relative;
    width: 100%;
    min-height: auto;
  }
  .main-content {
    margin-left: 0;
    padding-top: 140px;
  }
}
</style>
</head>

<body>

<!-- =================================================
     🔐 SECURE ANALYTICS CONTAINER
     Everything inside this div will:
     ✅ stay hidden until Cognito auth succeeds
     ✅ become visible after protectPage()
     (controlled by secure-dashboard.js)
================================================= -->
<div id="dashboard-container">

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

  <hr class="text-secondary">

  <!-- 🔐 SECURE LOGOUT
       secure-dashboard.js attaches Cognito logout -->
  <a class="logout-btn" style="cursor:pointer">🚪 Logout</a>
</div>

<!-- ===================== MAIN CONTENT ===================== -->
<div class="main-content">
  <div class="container-box position-relative">

    <h3>☕ Cafe Sales Analytics</h3>

    <!-- ===================== FILTER ===================== -->
    <div class="d-flex justify-content-center gap-3 mt-4 flex-wrap">
      <select id="period" class="form-select w-auto">
        <option value="today">Today</option>
        <option value="week">Last 7 Days</option>
        <option value="month">This Month</option>
      </select>
      <button class="btn btn-primary" onclick="loadData()">Load Data</button>
    </div>

    <!-- ===================== METRICS ===================== -->
    <div class="row mt-4 g-4">
      <div class="col-md-4"><div class="card p-3">Sales: <span id="sales">0</span></div></div>
      <div class="col-md-4"><div class="card p-3">Cost: <span id="cost">0</span></div></div>
      <div class="col-md-4"><div class="card p-3">Profit: <span id="profit">0</span></div></div>
    </div>

    <!-- ===================== CHART ===================== -->
    <canvas id="chart" class="mt-4" height="120"></canvas>

    <!-- ===================== PDF ===================== -->
    <button class="btn btn-success" onclick="downloadPDF()">📄 Download PDF</button>
  </div>
</div>

</div>
<!-- 🔐 END SECURE ANALYTICS CONTAINER -->

<!-- ===================== TOASTS ===================== -->

<!-- Welcome (Once Per Day) -->
<div class="toast-container position-fixed top-0 end-0 p-3">
  <div id="welcomeToast" class="toast">
    <div class="toast-header">
      <strong class="me-auto">📊 Analytics</strong>
      <button class="btn-close" data-bs-dismiss="toast"></button>
    </div>
    <div class="toast-body">
      Welcome to the Analytics Dashboard!
    </div>
  </div>
</div>

<!-- Data Loaded -->
<div class="toast-container position-fixed bottom-0 end-0 p-3">
  <div id="dataToast" class="toast">
    <div class="toast-header bg-success text-white">
      <strong class="me-auto">Data Loaded</strong>
      <button class="btn-close btn-close-white" data-bs-dismiss="toast"></button>
    </div>
    <div class="toast-body">
      ✅ Analytics updated successfully!
    </div>
  </div>
</div>

<!-- ===================== SCRIPTS ===================== -->
<script>
/* ===================== API CONFIG ===================== */
const API_BASE_URL = "https://API_ID.execute-api.REGION.amazonaws.com/prod";
const ANALYTICS_API = `${API_BASE_URL}/analytics`;
const PDF_API = `${API_BASE_URL}/report/pdf`;

/* ===================== WELCOME TOAST ===================== */
document.addEventListener("DOMContentLoaded", () => {
  const today = new Date().toISOString().split("T")[0];
  const lastSeen = localStorage.getItem("analyticsWelcome");

  if (lastSeen !== today) {
    new bootstrap.Toast(document.getElementById("welcomeToast"), {
      delay: 2500
    }).show();
    localStorage.setItem("analyticsWelcome", today);
  }
});

/* ===================== LOAD ANALYTICS DATA ===================== */
function loadData() {
  const period = document.getElementById("period").value;

  fetch(`${ANALYTICS_API}?period=${period}`)
    .then(res => res.json())
    .then(data => {

      document.getElementById("sales").innerText = data.total_sales;
      document.getElementById("cost").innerText = data.total_cost;
      document.getElementById("profit").innerText = data.profit;

      const ctx = document.getElementById("chart").getContext("2d");
      if (window.salesChart) window.salesChart.destroy();

      window.salesChart = new Chart(ctx, {
        type: "line",
        data: {
          labels: ["Sales", "Cost", "Profit"],
          datasets: [{
            data: [data.total_sales, data.total_cost, data.profit],
            borderColor: "#ffddaa",
            backgroundColor: "rgba(255,221,170,0.3)",
            fill: true,
            tension: 0.3
          }]
        },
        options: {
          plugins: { legend: { display: false } },
          scales: { y: { beginAtZero: true } }
        }
      });

      new bootstrap.Toast(document.getElementById("dataToast")).show();
    });
}

/* ===================== DOWNLOAD PDF ===================== */
function downloadPDF() {
  window.open(PDF_API);
}
</script>

<!-- ===================== BOOTSTRAP JS ===================== -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<!-- =================================================
     🔐 CENTRAL AUTH & SECURITY LAYER
     This ONE file enables:
     ✅ Page hidden until auth success
     ✅ auth.js auto-loaded
     ✅ protectPage()
     ✅ authFetch()
     ✅ Cognito logout
================================================= -->
<script src="secure-dashboard.js"></script>

</body>
</html>
```

#### ✅ YOU NOW HAVE

🔐 Same security model across Dashboard & Analytics

🧱 One reusable auth layer

🚀 Production-ready multi-page admin panel

🧠 Zero duplicate Cognito logic

---


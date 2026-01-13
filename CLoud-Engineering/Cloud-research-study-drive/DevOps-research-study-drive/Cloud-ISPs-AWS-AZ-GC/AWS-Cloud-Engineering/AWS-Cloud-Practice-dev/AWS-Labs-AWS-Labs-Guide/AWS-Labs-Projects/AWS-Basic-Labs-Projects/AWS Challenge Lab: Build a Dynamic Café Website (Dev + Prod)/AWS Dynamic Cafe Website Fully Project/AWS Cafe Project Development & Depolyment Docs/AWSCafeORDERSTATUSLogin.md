# AWS CAFE LAB -- ORDER STATUS DASHBOARD (Login)

# 🔒 SECTION 2 — Cognito, JWT, API Gateway



## Method 1 ( Recommanded)

### ✅ FINAL ORDER STATUS FRONTEND

#### (Login + Spinner + Auto Refresh + Chart + Date Filter)

COGNITO-READY (no backend change required now)

#### 📍 File location (CORRECT)

```
sudo nano /var/www/html/order-status.html
```

#### Paste Code

```
<!DOCTYPE html>
<html lang="en" data-bs-theme="dark">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Charlie Cafe ☕ | Admin Order Status</title>

<!-- Bootstrap -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<!-- Google Font -->
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">

<style>
body{
    font-family:'Poppins',sans-serif;
    background:linear-gradient(rgba(0,0,0,.7),rgba(0,0,0,.7)),
    url("https://images.unsplash.com/photo-1517248135467-4c7edcad34c4");
    background-size:cover;
    background-attachment:fixed;
    color:#fff;
}

.navbar{background:#3b1f0e;}
.status-container{
    background:rgba(30,30,30,.8);
    border-radius:20px;
    padding:40px;
    margin:40px auto;
    max-width:1200px;
}

.metric-card{
    background:linear-gradient(135deg,#4a2c1a,#3b1f0e);
    border-radius:15px;
    text-align:center;
}

#dashboard{display:none;}
#loader{display:none;}
</style>
</head>

<body>

<!-- NAVBAR -->
<nav class="navbar navbar-dark">
<div class="container">
<span class="navbar-brand">☕ Charlie Cafe Admin</span>
<button class="btn btn-danger btn-sm" onclick="logout()">Logout</button>
</div>
</nav>

<!-- LOGIN -->
<div class="container mt-5" id="loginBox">
<div class="col-md-4 mx-auto bg-dark p-4 rounded shadow">
<h4 class="text-center mb-3">Admin Login</h4>
<input id="username" class="form-control mb-2" placeholder="Username">
<input id="password" type="password" class="form-control mb-3" placeholder="Password">
<button class="btn btn-warning w-100 fw-bold" onclick="login()">Login</button>
<p class="text-center text-muted mt-2 small">Cognito Ready</p>
</div>
</div>

<!-- DASHBOARD -->
<div class="container">
<div class="status-container" id="dashboard">

<h2 class="text-center mb-4">📊 Live Order Status</h2>

<!-- FILTER -->
<div class="row mb-3">
<div class="col-md-4">
<input type="date" id="filterDate" class="form-control">
</div>
<div class="col-md-3">
<button class="btn btn-warning w-100 fw-bold" onclick="loadData()">Apply Filter</button>
</div>
</div>

<!-- LOADER -->
<div class="text-center my-3" id="loader">
<div class="spinner-border text-warning"></div>
<p>Loading orders...</p>
</div>

<!-- METRICS -->
<div class="row g-4 mb-4 justify-content-center" id="metrics"></div>

<!-- CHART -->
<canvas id="orderChart" height="100"></canvas>

<!-- TABLE -->
<div class="table-responsive mt-4">
<table class="table table-hover text-white">
<thead class="table-dark">
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

<footer class="text-center text-muted py-4">
© 2026 Charlie Cafe | Serverless Analytics ☁️
</footer>

<script>
/* ================= CONFIG ================= */
const API_URL="https://API_ID.execute-api.region.amazonaws.com/status/order-status"; 
let chart;
let autoRefresh;

/* ================= LOGIN (TEMP) ================= */
function login(){
    if(username.value && password.value){
        loginBox.style.display="none";
        dashboard.style.display="block";
        loadData();
        autoRefresh=setInterval(loadData,10000);
    }
}

function logout(){
    clearInterval(autoRefresh);
    location.reload();
}

/* ================= LOAD DATA ================= */
function loadData(){
    loader.style.display="block";
    metrics.innerHTML="";
    orders.innerHTML="";

    let url=API_URL;
    if(filterDate.value){
        url+="?date="+filterDate.value;
    }

    fetch(url)
    .then(res=>res.json())
    .then(data=>{
        loader.style.display="none";

        /* METRICS */
        data.metrics.forEach(m=>{
            metrics.innerHTML+=`
            <div class="col-6 col-md-3">
            <div class="metric-card p-3 shadow">
                <h5 class="text-warning">${m.metric}</h5>
                <h2>${m.count}</h2>
            </div>
            </div>`;
        });

        /* TABLE + CHART DATA */
        const items={};
        data.recent_orders.forEach(o=>{
            orders.innerHTML+=`
            <tr>
            <td>${o.customer_name||'Guest'}</td>
            <td>${o.item}</td>
            <td>${o.quantity}</td>
            <td>${o.table_number||'-'}</td>
            <td>${o.created_at}</td>
            </tr>`;
            items[o.item]=(items[o.item]||0)+o.quantity;
        });

        /* CHART */
        if(chart) chart.destroy();
        chart=new Chart(orderChart,{
            type:'bar',
            data:{
                labels:Object.keys(items),
                datasets:[{
                    label:'Orders per Item',
                    data:Object.values(items),
                    backgroundColor:'#ff9800'
                }]
            }
        });
    })
    .catch(err=>{
        loader.style.display="none";
        orders.innerHTML=`
        <tr><td colspan="5" class="text-center text-danger">
        Failed to load data
        </td></tr>`;
    });
}
</script>

</body>
</html>
```

#### ✅ WHAT THIS FILE ALREADY DOES

| Feature                       | Status                               |
| ----------------------------- | ------------------------------------ |
| Login screen                  | ✅ Working (temporary, Cognito-ready) |
| Dashboard hidden before login | ✅                                    |
| Loading spinner               | ✅                                    |
| Auto refresh (10s)            | ✅                                    |
| Metrics cards                 | ✅                                    |
| Orders table                  | ✅                                    |
| Chart (orders per item)       | ✅                                    |
| Date filter (frontend)        | ✅                                    |
| Backend untouched             | ✅                                    |

### 🔁 ONLY THINGS YOU MUST CHANGE

#### 1️⃣ Replace API URL

```
const API_URL="https://API_ID.execute-api.region.amazonaws.com/status/order-status";
```

#### 2️⃣ (Later) Replace login logic with Cognito

NO need now

---

## Method 2

## PHASE 1️⃣ load Order Status 

### 🟢 BASELINE (STARTING POINT – DO THIS FIRST)

#### STEP 0.1 — Open your file

```
sudo nano /var/www/html/order-status.html
```

#### STEP 0.2 — Paste this MINIMAL BASE FILE (NO FEATURES YET)

```
<!DOCTYPE html>
<html>
<head>
  <title>Order Status</title>
</head>
<body>

<h2>Order Status</h2>

<button onclick="loadData()">Load Orders</button>

<div id="output"></div>

<script>
function loadData() {
  document.getElementById("output").innerHTML = "Loading...";
}
</script>

</body>
</html>
```

#### STEP 0.3 — Save & test

```
CTRL + O → ENTER → CTRL + X
```

#### Open browser:

```
http://EC2_PUBLIC_IP/order-status.html
```

✅ If you see “Order Status” + button, continue

❌ If not, STOP and fix Apache first

### 🟣 TASK 1 — LOADING SPINNER (NO API YET)

#### 🎯 GOAL

Show spinner when loading starts
Hide spinner when loading ends

#### STEP 1.1 — ADD SPINNER HTML (WHERE EXACTLY)

Inside <body>, below the button, add:

```
<div id="loader" style="display:none">
  Loading...
</div>
```

Your body now looks like:

```
<button onclick="loadData()">Load Orders</button>

<div id="loader" style="display:none">
  Loading...
</div>

<div id="output"></div>
```

#### STEP 1.2 — SHOW SPINNER (WHAT LINE)

Modify loadData():

```
<script>
function loadData() {
  document.getElementById("loader").style.display = "block";
}
</script>
```

#### STEP 1.3 — VERIFY

Refresh page → click Load Orders

✅ You see Loading…

❌ If not, STOP

#### STEP 1.4 — HIDE SPINNER (SIMULATE END)

#### Update function:

```
function loadData() {
  document.getElementById("loader").style.display = "block";

  setTimeout(() => {
    document.getElementById("loader").style.display = "none";
    document.getElementById("output").innerHTML = "Loaded!";
  }, 2000);
}
```

#### STEP 1.5 — VERIFY

#### Click button:

Spinner shows

After 2 sec → disappears

“Loaded!” appears

**✅ TASK 1 COMPLETE**

**❌ Do NOT continue if this fails**


### 🟣 TASK 2 — AUTO REFRESH (NO API STILL)

#### 🎯 GOAL

Run loadData() every 10 seconds automatically

#### STEP 2.1 — ADD INTERVAL (WHERE)

At bottom of <script>, add:

```
setInterval(loadData, 10000);
```

#### STEP 2.2 — VERIFY

Open page

**Every 10 seconds:**

Spinner appears

Spinner disappears

**✅ TASK 2 COMPLETE**

### 🟣 TASK 3 — FETCH REAL DATA (FIRST API USE)

#### 🎯 GOAL

Replace fake data with real API response

#### STEP 3.1 — REPLACE loadData()

```
function loadData() {
  document.getElementById("loader").style.display = "block";

  fetch("https://YOUR_API_URL/order-status")
    .then(res => res.json())
    .then(data => {
      document.getElementById("loader").style.display = "none";
      document.getElementById("output").innerHTML =
        JSON.stringify(data, null, 2);
    });
}
```

#### STEP 3.2 — VERIFY

Open page

Spinner shows

JSON appears

**✅ TASK 3 COMPLETE**

Now API + spinner + auto refresh are working together

### 🟣 TASK 4 — TABLE (NO CHART YET)

#### 🎯 GOAL

Show orders in a table

#### STEP 4.1 — ADD TABLE HTML

Above <div id="output">, add:

```
<table border="1">
  <thead>
    <tr>
      <th>Customer</th>
      <th>Item</th>
      <th>Qty</th>
      <th>Date</th>
    </tr>
  </thead>
  <tbody id="orders"></tbody>
</table>
```

STEP 4.2 — UPDATE JS

Replace .then(data => { ... }) with:

```
.then(data => {
  document.getElementById("loader").style.display = "none";
  document.getElementById("orders").innerHTML = "";

  data.recent_orders.forEach(o => {
    document.getElementById("orders").innerHTML += `
      <tr>
        <td>${o.customer_name}</td>
        <td>${o.item}</td>
        <td>${o.quantity}</td>
        <td>${o.created_at}</td>
      </tr>
    `;
  });
});
```

#### STEP 4.3 — VERIFY

✅ Orders appear in table

✅ Auto refresh still works

### 🟣 TASK 5 — CHART (ONLY NOW)

#### 🎯 GOAL

Visualize orders per item

#### STEP 5.1 — ADD CHART.JS

Inside <head>:

```
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
```

#### STEP 5.2 — ADD CANVAS

Above table:

```
<canvas id="chart"></canvas>
```

#### STEP 5.3 — ADD JS LOGIC

At top of script:

```
let chart;
```

Inside fetch success:

```
const items = {};
data.recent_orders.forEach(o => {
  items[o.item] = (items[o.item] || 0) + o.quantity;
});

if (chart) chart.destroy();

chart = new Chart(document.getElementById("chart"), {
  type: "bar",
  data: {
    labels: Object.keys(items),
    datasets: [{
      label: "Orders per item",
      data: Object.values(items)
    }]
  }
});
```

#### STEP 5.4 — VERIFY

✅ Chart renders

✅ Chart updates every 10s

### 🟣 TASK 6 — DATE FILTER (FRONTEND ONLY)

#### STEP 6.1 — ADD INPUT

```
<input type="date" id="filterDate">
```

#### STEP 6.2 — USE IT

Inside loadData():

```
const date = document.getElementById("filterDate").value;
let url = "https://YOUR_API_URL/order-status";
if (date) url += "?date=" + date;
```

### 🟣 TASK 7 — LOGIN (UI ONLY – NO COGNITO YET)

#### STEP 7.1 — HIDE DASHBOARD

Wrap dashboard:

```
<div id="dashboard" style="display:none">
  <!-- all dashboard html -->
</div>
```
#### STEP 7.2 — LOGIN FORM

```
<input id="user">
<input id="pass" type="password">
<button onclick="login()">Login</button>
```

#### STEP 7.3 — LOGIN FUNCTION

```
function login() {
  if(user.value && pass.value) {
    dashboard.style.display = "block";
  }
}
```
---

# 🔒 SECTION 3 —  Cognito Hosted UI (industry standard)

**COGNITO → real login**

✅ Real AWS Cognito login

✅ JWT ID token stored in browser

✅ Auto-protect your dashboard

✅ Ready for API Gateway Authorizer later

### 🧠 HOW THIS WILL WORK 

#### Flow:

```
User clicks Login
→ Redirect to Cognito Hosted UI
→ User signs in
→ Cognito redirects back with JWT
→ Frontend stores token
→ Dashboard unlocks
```

→ NO username/password handling in frontend

→ NO security risk

→ NO extra libraries

###  1️⃣ — AWS COGNITO (CONSOLE ONLY)

#### STEP 1: Create User Pool

- **AWS Console → Cognito → User Pools**

• Create user pool

• Sign-in option: Username

• Password policy: default

• MFA: OFF (for now)

✅ Create pool

#### STEP 2: Create App Client (VERY IMPORTANT)

- **User pool → App integration → App clients**

• Create app client

• ❌ Disable client secret (REQUIRED)

• Enable:

✔ Authorization code grant

✔ Implicit grant

Save.

#### STEP 3: Configure Hosted UI

- **User pool → App integration → Hosted UI**

#### Domain

• Create Cognito domain

#### Example:

```
charlie-cafe-admin.auth.ap-south-1.amazoncognito.com
```

#### Callback URL

```
https://YOUR-DOMAIN/order-status.html
```

#### Sign-out URL

```
https://YOUR-DOMAIN/order-status.html
```

#### Scopes

✔ openid

✔ email

✔ profile

Save changes.

#### STEP 4: Create Admin User

- **User pool → Users → Create user**

• Username: admin

• Password: auto-generate

• Mark email verified

### PART 2️⃣ — FRONTEND (FINAL CODE CHANGE)

**🔥 REPLACE ONLY THE <script> SECTION**

##### (HTML + CSS stay SAME)

#### ✅ COPY & PASTE THIS SCRIPT (100%)

```
<script>
/* ================= CONFIG ================= */
const REGION = "ap-south-1";
const USER_POOL_ID = "ap-south-1_XXXXXXX";
const CLIENT_ID = "XXXXXXXXXXXXXXXXXXXX";
const DOMAIN = "charlie-cafe-admin.auth.ap-south-1.amazoncognito.com";

const API_URL = "https://API_ID.execute-api.region.amazonaws.com/status/order-status";

/* ================= AUTH ================= */
function login() {
    const loginUrl =
        `https://${DOMAIN}/login?` +
        `client_id=${CLIENT_ID}` +
        `&response_type=token` +
        `&scope=openid+email+profile` +
        `&redirect_uri=${encodeURIComponent(window.location.href)}`;
    window.location.href = loginUrl;
}

function logout() {
    localStorage.removeItem("id_token");
    const logoutUrl =
        `https://${DOMAIN}/logout?` +
        `client_id=${CLIENT_ID}` +
        `&logout_uri=${encodeURIComponent(window.location.href)}`;
    window.location.href = logoutUrl;
}

/* ================= TOKEN HANDLING ================= */
function getTokenFromUrl() {
    if (window.location.hash) {
        const params = new URLSearchParams(window.location.hash.substring(1));
        const token = params.get("id_token");
        if (token) {
            localStorage.setItem("id_token", token);
            window.location.hash = "";
        }
    }
}

/* ================= LOAD DATA ================= */
function loadData() {
    loader.style.display = "block";
    metrics.innerHTML = "";
    orders.innerHTML = "";

    fetch(API_URL, {
        headers: {
            Authorization: localStorage.getItem("id_token")
        }
    })
    .then(res => res.json())
    .then(data => {
        loader.style.display = "none";

        /* METRICS */
        data.metrics.forEach(m => {
            metrics.innerHTML += `
            <div class="col-6 col-md-3">
                <div class="metric-card p-3 shadow">
                    <h5 class="text-warning">${m.metric}</h5>
                    <h2>${m.count}</h2>
                </div>
            </div>`;
        });

        /* TABLE + CHART */
        const items = {};
        data.recent_orders.forEach(o => {
            orders.innerHTML += `
            <tr>
                <td>${o.customer_name || "Guest"}</td>
                <td>${o.item}</td>
                <td>${o.quantity}</td>
                <td>${o.table_number || "-"}</td>
                <td>${o.created_at}</td>
            </tr>`;
            items[o.item] = (items[o.item] || 0) + o.quantity;
        });

        if (chart) chart.destroy();
        chart = new Chart(orderChart, {
            type: "bar",
            data: {
                labels: Object.keys(items),
                datasets: [{
                    label: "Orders per Item",
                    data: Object.values(items),
                    backgroundColor: "#ff9800"
                }]
            }
        });
    });
}

/* ================= INIT ================= */
getTokenFromUrl();

if (localStorage.getItem("id_token")) {
    loginBox.style.display = "none";
    dashboard.style.display = "block";
    loadData();
    autoRefresh = setInterval(loadData, 10000);
}
</script>
```

### ✅ FINAL order-status.html


```
<!DOCTYPE html>
<html lang="en" data-bs-theme="dark">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Charlie Cafe ☕ | Order Status</title>

<!-- Bootstrap -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- Google Font -->
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">

<style>
body {
    font-family: 'Poppins', sans-serif;
    min-height: 100vh;
    background: linear-gradient(rgba(0,0,0,0.70), rgba(0,0,0,0.70)),
                url("https://images.unsplash.com/photo-1517248135467-4c7edcad34c4");
    background-size: cover;
    background-position: center;
    background-attachment: fixed;
}

/* Navbar */
.navbar { background:#3b1f0e; }
.navbar-brand { font-weight:600; }

/* Container */
.status-container {
    background: rgba(30,30,30,.75);
    border-radius: 20px;
    padding: 40px;
    box-shadow: 0 15px 40px rgba(0,0,0,.5);
    max-width: 1100px;
    margin: 40px auto;
}

/* Metrics */
.metric-card {
    background: linear-gradient(135deg,#4a2c1a,#3b1f0e);
    border-radius: 15px;
    text-align:center;
    padding:25px;
}
.metric-card h5 { color:#ff9800; }
.metric-card h2 { color:white; }

/* Spinner */
#loader { display:none; }

/* Hide dashboard until login */
#dashboard { display:none; }
</style>
</head>

<body>

<!-- NAVBAR -->
<nav class="navbar navbar-dark">
<div class="container">
    <span class="navbar-brand">☕ Charlie Cafe Admin</span>
    <button class="btn btn-warning btn-sm" onclick="login()">Login</button>
    <button class="btn btn-danger btn-sm ms-2" onclick="logout()">Logout</button>
</div>
</nav>

<!-- LOGIN MESSAGE -->
<div class="container text-center text-white mt-5" id="loginBox">
<h3>Please login to access order dashboard</h3>
</div>

<!-- DASHBOARD -->
<div class="container" id="dashboard">
<div class="status-container">

<h2 class="text-center mb-4">📊 Live Order Status</h2>

<!-- Loader -->
<div class="text-center" id="loader">
<div class="spinner-border text-warning"></div>
<p>Loading...</p>
</div>

<!-- Metrics -->
<div id="metrics" class="row g-4 mb-4 justify-content-center"></div>

<!-- Orders Table -->
<div class="table-responsive">
<table class="table table-dark table-hover">
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

<footer class="text-center text-white py-3">
© 2026 Charlie Cafe | Secure Admin Dashboard
</footer>

<!-- ================= JAVASCRIPT ================= -->
<script>
/* ===== CONFIG (CHANGE THESE) ===== */
const REGION = "ap-south-1";
const USER_POOL_ID = "CHANGE_ME";
const CLIENT_ID = "CHANGE_ME";
const DOMAIN = "CHANGE_ME.auth.ap-south-1.amazoncognito.com";

const API_URL = "https://API_ID.execute-api.region.amazonaws.com/status/order-status";

/* ===== LOGIN ===== */
function login() {
    const url =
        `https://${DOMAIN}/login?` +
        `client_id=${CLIENT_ID}` +
        `&response_type=token` +
        `&scope=openid+email+profile` +
        `&redirect_uri=${encodeURIComponent(window.location.href)}`;
    window.location.href = url;
}

function logout() {
    localStorage.removeItem("id_token");
    const url =
        `https://${DOMAIN}/logout?` +
        `client_id=${CLIENT_ID}` +
        `&logout_uri=${encodeURIComponent(window.location.href)}`;
    window.location.href = url;
}

/* ===== TOKEN HANDLING ===== */
function handleToken() {
    if (window.location.hash) {
        const params = new URLSearchParams(window.location.hash.substring(1));
        const token = params.get("id_token");
        if (token) {
            localStorage.setItem("id_token", token);
            window.location.hash = "";
        }
    }
}

/* ===== LOAD DATA ===== */
function loadData() {
    loader.style.display = "block";
    metrics.innerHTML = "";
    orders.innerHTML = "";

    fetch(API_URL, {
        headers: {
            Authorization: localStorage.getItem("id_token")
        }
    })
    .then(res => res.json())
    .then(data => {
        loader.style.display = "none";

        data.metrics.forEach(m => {
            metrics.innerHTML += `
            <div class="col-6 col-md-3">
                <div class="metric-card">
                    <h5>${m.metric}</h5>
                    <h2>${m.count}</h2>
                </div>
            </div>`;
        });

        data.recent_orders.forEach(o => {
            orders.innerHTML += `
            <tr>
                <td>${o.customer_name || "Guest"}</td>
                <td>${o.item}</td>
                <td>${o.quantity}</td>
                <td>${o.table_number || "-"}</td>
                <td>${o.created_at}</td>
            </tr>`;
        });
    });
}

/* ===== INIT ===== */
handleToken();

if (localStorage.getItem("id_token")) {
    loginBox.style.display = "none";
    dashboard.style.display = "block";
    loadData();
    setInterval(loadData, 10000);
}
</script>

</body>
</html>
```
### 1️⃣ USER_POOL_ID — WHERE TO FIND IT

#### Steps

- Open AWS Console

- Go to Cognito

- Click User pools

- Click your user pool

#### On Overview page → copy:

```
User pool ID
```

#### Example

```
ap-south-1_aBcDe1234
```

#### Paste here

```
const USER_POOL_ID = "ap-south-1_aBcDe1234";
```

### 2️⃣ CLIENT_ID — WHERE TO FIND IT

#### Steps

- Inside the same User Pool

- Go to App integration

- Scroll to App clients

- Click your App client

#### Copy:

```
Client ID
```

#### Example

```
6h8k9mopq123abcxyz
```

#### Paste here

```
const CLIENT_ID = "6h8k9mopq123abcxyz";
```

### 3️⃣ DOMAIN — WHERE TO FIND IT

#### Steps

- Cognito → User pools

- Select your pool

- Go to App integration

- Click Domain

- Copy Domain prefix

#### Example

If domain shows:

```
charlie-cafe-admin
```

and region is ap-south-1

#### Final domain becomes

```
charlie-cafe-admin.auth.ap-south-1.amazoncognito.com
```

#### Paste here

```
const DOMAIN = "charlie-cafe-admin.auth.ap-south-1.amazoncognito.com";
```

**🚨 Do NOT include https://**

### 4️⃣ API_URL — WHERE TO FIND IT
#### Steps

- Go to API Gateway

- Select your API

- Click Stages

- Choose your stage (status, prod, etc.)

- Copy Invoke URL

- Append your resource path

#### Example

Invoke URL:

```
https://abc123.execute-api.ap-south-1.amazonaws.com/status
```

#### Resource:

```
GET /order-status
```

#### Final API URL

```
https://abc123.execute-api.ap-south-1.amazonaws.com/status/order-status
```

#### Paste here

```
const API_URL = "https://abc123.execute-api.ap-south-1.amazonaws.com/status/order-status";
```

### ✅ FINAL EXAMPLE (REALISTIC)

```
const REGION = "ap-south-1";
const USER_POOL_ID = "ap-south-1_aBcDe1234";
const CLIENT_ID = "6h8k9mopq123abcxyz";
const DOMAIN = "charlie-cafe-admin.auth.ap-south-1.amazoncognito.com";
const API_URL = "https://abc123.execute-api.ap-south-1.amazonaws.com/status/order-status";
```
### 🧪 HOW TO VERIFY (IMPORTANT)

- Open order-status.html in browser

- Click Login

- Cognito login page opens

- Login with admin user

- Redirect back

- Dashboard appears

- Orders load every 10 seconds

- If any value is wrong → login loop or blank page.


---

### ✅ WHAT YOU NOW HAVE (REAL WORLD)

| Feature                          | Status |
| -------------------------------- | ------ |
| AWS Cognito real login           | ✅      |
| Hosted UI (secure)               | ✅      |
| JWT stored                       | ✅      |
| Dashboard protected              | ✅      |
| Ready for API Gateway Authorizer | ✅      |
| Production-grade flow            | ✅      |


---

# 🔒 SECTION 4 —  TASK — SECURE API GATEWAY USING COGNITO AUTHORIZER

(MANDATORY – REAL LOGIN SECURITY)

🧠 WHAT YOU ARE DOING (VERY IMPORTANT)

You will:

```
Frontend (Cognito Login)
        ↓ JWT Token
API Gateway (Cognito Authorizer) ✅
        ↓
Lambda (Protected)
```

❌ No JWT → API blocked

❌ Invalid user → API blocked

✅ Only logged-in Cognito users allowed

🟢 PREREQUISITES (CHECK BEFORE START)

Make sure you already have:

✅ Cognito User Pool

✅ Cognito App Client (NO client secret)

✅ API Gateway with GET /order-status

✅ Lambda connected to that method

If YES → continue

If NO → stop and tell me

🟣 STEP 1 — OPEN API GATEWAY

1️⃣ AWS Console

2️⃣ Search API Gateway

3️⃣ Click APIs

4️⃣ Click your API name

(Example: CharlieCafeAPI)

🟣 STEP 2 — CREATE COGNITO AUTHORIZER

2.1 Go to Authorizers

1️⃣ Left menu → click Authorizers

2️⃣ Click Create authorizer

2.2 Fill Authorizer Settings (VERY CAREFUL)

| Field                 | Value                    |
| --------------------- | ------------------------ |
| **Authorizer name**   | `CognitoAdminAuthorizer` |
| **Authorizer type**   | `Cognito`                |
| **Cognito user pool** | ✅ Select your User Pool  |
| **Token source**      | `Authorization`          |
| **Token validation**  | *(leave empty)*          |

⚠️ Token source MUST be exactly:

```
Authorization
```

❌ Not Bearer

❌ Not Auth

❌ Not lowercase

2.3 Save Authorizer

Click Create authorizer

✅ Authorizer created

🟣 STEP 3 — ATTACH AUTHORIZER TO API METHOD

This is the MOST IMPORTANT STEP.

3.1 Open Your Resource

1️⃣ Left menu → Resources

2️⃣ Click your resource:

```
/order-status
```

3️⃣ Click method:

```
GET
```

3.2 Edit Method Request

1️⃣ Click Method Request

2️⃣ Click Edit

3.3 Configure Authorization

Set exactly:

| Setting          | Value                    |
| ---------------- | ------------------------ |
| Authorization    | `CognitoAdminAuthorizer` |
| API Key Required | `false`                  |

Click Save

✅ Now API is protected

🟣 STEP 4 — ENABLE CORS AGAIN (MANDATORY)

Authorizer breaks CORS if not re-enabled.

4.1 Enable CORS

1️⃣ Select GET /order-status

2️⃣ Click Enable CORS

3️⃣ Keep defaults

4️⃣ Click Enable CORS and replace existing CORS headers

✅ CORS fixed

🟣 STEP 5 — DEPLOY API (DO NOT SKIP)

⚠️ Changes do NOT work until deployed

5.1 Deploy

1️⃣ Click Deploy API

2️⃣ Stage:

Select existing stage (example: status)
OR

Create new stage (example: admin)

👉 I recommend:

```
admin
```

3️⃣ Click Deploy

5.2 Copy Invoke URL

After deploy:

```
https://xxxxx.execute-api.region.amazonaws.com/admin
```

Your full endpoint:

```
https://xxxxx.execute-api.region.amazonaws.com/admin/order-status
```

🟣 STEP 6 — UPDATE FRONTEND API_URL

In order-status.html:

```
const API_URL = "https://xxxxx.execute-api.ap-south-1.amazonaws.com/admin/order-status";
```

✅ Done

🟣 STEP 7 — HOW AUTHORIZATION WORKS NOW
Browser Flow

```
User logs in (Cognito)
↓
JWT stored in localStorage
↓
Frontend sends:
Authorization: Bearer eyJhbGciOi...
↓
API Gateway validates JWT
↓
Lambda executes
```

🟣 STEP 8 — TEST (VERY IMPORTANT)

8.1 Test WITHOUT Login (Expected ❌)

1️⃣ Open browser

2️⃣ Open:

```
https://xxxxx.execute-api.region.amazonaws.com/admin/order-status
```

✅ You should see:

```
401 Unauthorized
```

✔️ THIS IS CORRECT

8.2 Test WITH Login (Expected ✅)

1️⃣ Open:

```
http://YOUR_EC2_IP/order-status.html
```

2️⃣ Login using Cognito admin

3️⃣ Dashboard loads

4️⃣ Orders visible

✔️ SUCCESS

🟢 COMMON ERRORS (READ THIS)

❌ 401 Unauthorized after login

✔ Token not sent

✔ Wrong API_URL

✔ Wrong authorizer attached

❌ CORS error

✔ You forgot Enable CORS again

✔ Or forgot Deploy API

❌ Blank page

✔ Check browser DevTools → Network → Authorization header

🏆 FINAL SECURITY STATUS


| Security Layer         | Status |
| ---------------------- | ------ |
| Cognito Login          | ✅      |
| JWT Issued             | ✅      |
| API Gateway Validation | ✅      |
| Unauthorized Blocked   | ✅      |
| Lambda Protected       | ✅      |
| Production-grade       | ✅      |


---

# 🔒 SECTION 5 —   JWT → SECURE API (END-TO-END)

This task answers ONE QUESTION ONLY:

> **❓ How does API Gateway + Lambda accept requests ONLY from logged-in Cognito users?**

### 🧠 FINAL FLOW 

```
Browser Login (Cognito)
        ↓
JWT Token (ID token)
        ↓
Frontend sends Authorization header
        ↓
API Gateway (Cognito Authorizer) ✅
        ↓
Lambda executes
```

❌ No JWT → API Gateway BLOCKS

❌ Fake JWT → API Gateway BLOCKS

✅ Valid Cognito user → Lambda runs

### 🟢 STEP 1 — CONFIRM COGNITO USER POOL EXISTS

1️⃣ AWS Console

2️⃣ Open Amazon Cognito

3️⃣ Click User pools

#### You MUST see:

A User Pool name

A User Pool ID like:

```
ap-south-1_xxxxx
```

👉 If not created, STOP and tell me.

### 🟢 STEP 2 — CONFIRM APP CLIENT EXISTS (VERY IMPORTANT)

1️⃣ Open your User Pool

2️⃣ Click App integration

3️⃣ Click App clients

#### Confirm:

❌ Client secret = DISABLED

✅ USER_PASSWORD_AUTH enabled

#### Save:

```
USER_POOL_ID
APP_CLIENT_ID
REGION
```

### 🟢 STEP 3 — FRONTEND MUST SEND JWT (MANDATORY)

In your order-status.html, your fetch MUST look like this:

```
fetch(API_URL, {
  headers: {
    Authorization: "Bearer " + localStorage.getItem("token")
  }
})
```

📌 This is NON-NEGOTIABLE

### 🟢 STEP 4 — CREATE COGNITO AUTHORIZER (API GATEWAY)

1️⃣ AWS Console → API Gateway

2️⃣ Open your API

3️⃣ Left menu → Authorizers

4️⃣ Click Create authorizer

#### Fill EXACTLY:

| Field        | Value               |
| ------------ | ------------------- |
| Name         | `CognitoAuthorizer` |
| Type         | Cognito             |
| User pool    | SELECT YOUR POOL    |
| Token source | `Authorization`     |

👉 Click Create

### 🟢 STEP 5 — ATTACH AUTHORIZER TO METHOD

1️⃣ API Gateway → Resources

2️⃣ Click:

```
GET /order-status
```

3️⃣ Click Method Request

4️⃣ Click Edit

#### Set:

```
Authorization → CognitoAuthorizer
```

Click Save

### 🟢 STEP 6 — ENABLE CORS AGAIN (DO NOT SKIP)

1️⃣ Select GET /order-status

2️⃣ Click Enable CORS

3️⃣ Click Enable CORS and replace existing

### 🟢 STEP 7 — DEPLOY API (MANDATORY)

1️⃣ Click Deploy API

2️⃣ Stage → admin (recommended)

3️⃣ Click Deploy

📌 Copy final URL:

```
https://xxxx.execute-api.region.amazonaws.com/admin/order-status
```

### 🟢 STEP 8 — TEST SECURITY

❌ Without Token

Open API URL in browser

#### Result:

```
401 Unauthorized
```

✅ CORRECT

✅ With Login

1️⃣ Open order-status.html

2️⃣ Login

3️⃣ Dashboard loads

🎉 JWT SECURITY DONE

### ✅ TASK 2 — BACKEND DATE FILTER (LAMBDA) STEP BY STEP

Now we filter orders by date from backend, not frontend hacks.

### 🧠 WHAT THIS DOES

#### Frontend:

```
GET /order-status?date=2026-01-12
```

#### Lambda:

```
SELECT ... WHERE DATE(created_at) = '2026-01-12'
```

### 🟢 STEP 1 — CONFIRM FRONTEND SENDS DATE

#### Your frontend URL must become:

```
let url = API_URL;
const date = document.getElementById("filterDate").value;
if (date) {
  url += "?date=" + date;
}
```

### 🟢 STEP 2 — API GATEWAY PASSES QUERY PARAMS (DEFAULT)

✅ API Gateway automatically passes query params

❌ No config required

#### Lambda receives:

```
event["queryStringParameters"]
```

### 🟢 STEP 3 — MODIFY LAMBDA CODE (CORE STEP)

#### 3.1 Read date from request

Add inside lambda_handler:

```
params = event.get("queryStringParameters") or {}
filter_date = params.get("date")
```

#### 3.2 Build SQL safely

#### Replace your SQL with:

```
sql = """
SELECT customer_name, item, quantity, table_number, created_at
FROM orders
"""

values = []

if filter_date:
    sql += " WHERE DATE(created_at) = %s"
    values.append(filter_date)

sql += " ORDER BY created_at DESC LIMIT 20"
```

#### 3.3 Execute query

```
cursor.execute(sql, values)
orders = cursor.fetchall()
```

### 🟢 STEP 4 — FULL MINIMAL LAMBDA LOGIC (FILTER PART)

```
params = event.get("queryStringParameters") or {}
filter_date = params.get("date")

sql = """
SELECT customer_name, item, quantity, table_number, created_at
FROM orders
"""

values = []

if filter_date:
    sql += " WHERE DATE(created_at) = %s"
    values.append(filter_date)

sql += " ORDER BY created_at DESC LIMIT 20"

cursor.execute(sql, values)
orders = cursor.fetchall()
```

### 🟢 STEP 5 — DEPLOY & TEST

#### Test 1 — No date

```
/order-status
```

✅ All orders

#### Test 2 — With date

```
/order-status?date=2026-01-12
```

✅ Only that day’s orders

### 🏁 FINAL VERIFICATION CHECKLIST

| Item                        | Status |
| --------------------------- | ------ |
| JWT enforced by API Gateway | ✅      |
| Unauthorized users blocked  | ✅      |
| Lambda protected            | ✅      |
| Backend date filter works   | ✅      |
| Frontend filter connected   | ✅      |
| Production-grade            | ✅      |


### 🧠 IMPORTANT 

#### You now have:

Authentication → Cognito

Authorization → API Gateway

Filtering logic → Lambda

Clean architecture → Real-world

---

# 🔒 SECTION 6 —  Print orders 

### 🎯 GOAL 

You want TWO PRINT OPTIONS:

1️⃣ Print all visible orders (table print)

2️⃣ Print today’s total orders count (summary print)

This is exactly how restaurants, POS systems, cafés do it.

### 🧠 FINAL RESULT YOU WILL GET

✔ A Print Orders button

✔ A Print Today Summary button

✔ Print works in browser → printer / PDF

✔ No backend change required (uses existing data)

✔ Free-tier safe

### 🧩 OVERALL FLOW 

```
API → Orders Loaded
        ↓
JS counts today's orders
        ↓
User clicks PRINT
        ↓
Browser print dialog opens
```

### 🟢 PART 1 — ADD PRINT BUTTONS (HTML)

👉 NO JS YET

### STEP 1️⃣ — Open your order-status.html

#### Scroll to inside this container (IMPORTANT):

```
<div class="status-container">
```

STEP 2️⃣ — Add Print Buttons (COPY EXACTLY)

Paste this below the <h2> heading:

```
<div class="d-flex justify-content-end gap-2 mb-4">
    <button class="btn btn-warning fw-bold" onclick="printOrders()">
        🖨️ Print Orders
    </button>
    <button class="btn btn-success fw-bold" onclick="printTodaySummary()">
        📊 Print Today Summary
    </button>
</div>
```

✅ Buttons added

❌ No logic yet (that comes next)

🟢 PART 2 — STORE ORDERS DATA (MANDATORY)

To print, we must store API response.

STEP 3️⃣ — Declare a global variable

Find your <script> section
Add this at the TOP of script:

```
let allOrders = [];
```

STEP 4️⃣ — Save orders after API fetch

Find this code in your file:

```
data.recent_orders.forEach(o => {
```

REPLACE it with this (VERY IMPORTANT):

```
allOrders = data.recent_orders;

allOrders.forEach(o => {
```

📌 This stores orders for printing.

🟢 PART 3 — PRINT ALL ORDERS (STEP BY STEP)
STEP 5️⃣ — Add Print Orders Function

Scroll to bottom of <script>

Paste this FULL FUNCTION:

```
function printOrders() {
    if (allOrders.length === 0) {
        alert("No orders to print");
        return;
    }

    let html = `
        <h2>Charlie Cafe ☕ - Orders</h2>
        <table border="1" cellspacing="0" cellpadding="8" width="100%">
            <tr>
                <th>Customer</th>
                <th>Item</th>
                <th>Qty</th>
                <th>Table</th>
                <th>Date</th>
            </tr>
    `;

    allOrders.forEach(o => {
        html += `
            <tr>
                <td>${o.customer_name || "Anonymous"}</td>
                <td>${o.item}</td>
                <td>${o.quantity}</td>
                <td>${o.table_number || "-"}</td>
                <td>${o.created_at}</td>
            </tr>
        `;
    });

    html += `</table>`;

    openPrintWindow(html);
}
```

🟢 PART 4 — PRINT TODAY TOTAL (STEP BY STEP)
STEP 6️⃣ — Understand Today Logic (IMPORTANT)

We compare:

```
order_date === TODAY
```

Browser date format:

```
YYYY-MM-DD
```

STEP 7️⃣ — Add Today Summary Function

Paste this below printOrders():

```
function printTodaySummary() {
    const today = new Date().toISOString().split("T")[0];

    let todayOrders = allOrders.filter(o =>
        o.created_at.startsWith(today)
    );

    let totalQty = todayOrders.reduce((sum, o) => sum + o.quantity, 0);

    let html = `
        <h2>Charlie Cafe ☕</h2>
        <h3>📅 Today's Order Summary</h3>
        <p><strong>Date:</strong> ${today}</p>
        <p><strong>Total Orders:</strong> ${todayOrders.length}</p>
        <p><strong>Total Items Sold:</strong> ${totalQty}</p>
    `;

    openPrintWindow(html);
}
```

🟢 PART 5 — PRINT HELPER FUNCTION (MANDATORY)

This function actually opens the printer.

STEP 8️⃣ — Add Print Helper (DO NOT SKIP)

Paste this ONCE at bottom of script:

```
function openPrintWindow(content) {
    const win = window.open("", "", "width=900,height=650");
    win.document.write(`
        <html>
        <head>
            <title>Print</title>
            <style>
                body { font-family: Arial; padding: 20px; }
                table { border-collapse: collapse; }
                th { background: #3b1f0e; color: white; }
                th, td { border: 1px solid #333; }
            </style>
        </head>
        <body>
            ${content}
        </body>
        </html>
    `);
    win.document.close();
    win.print();
}
```

🟢 PART 6 — FINAL TESTING (DO NOT SKIP)
STEP 9️⃣ — Load the page

1️⃣ Open order-status.html
2️⃣ Wait for orders to load

STEP 🔟 — Test Print Orders

Click:

```
🖨️ Print Orders
```

✅ Printer opens

✅ Full table visible

✅ Can save as PDF

STEP 1️⃣1️⃣ — Test Today Summary

Click:

```
📊 Print Today Summary
```

✅ Shows:

Today date

Total orders

Total items sold

---

🏁 FINAL CHECKLIST

| Feature             | Status |
| ------------------- | ------ |
| Print all orders    | ✅      |
| Print today summary | ✅      |
| No backend changes  | ✅      |
| Works on browser    | ✅      |
| Restaurant-ready    | ✅      |
| PDF supported       | ✅      |


🏆 WHAT YOU JUST BUILT (REAL WORLD)

This is used in:

✔ Cafés
✔ POS systems
✔ Billing counters
✔ Daily closing reports

---

# 🔒 SECTION 7 —  JWT → SECURE API (API GATEWAY + COGNITO)

🎯 Goal

Only logged-in admins can call your API
Public users ❌ blocked

🟢 STEP 1 — CREATE COGNITO USER POOL

Open AWS Console

Go to Amazon Cognito

Click Create user pool

Select Cognito User Pool

Click Next

Configure sign-in

Sign-in options → ✅ Username

Password policy → Leave default

MFA → ❌ Disabled

Click Next

Create pool

Pool name: CharlieCafeAdminPool

Click Create user pool

📌 SAVE

User Pool ID

Region (example: us-east-1)

🟢 STEP 2 — CREATE APP CLIENT (VERY IMPORTANT)

Open your User Pool

Go to App integration

Click Create app client

App type → Public client

App client name → admin-dashboard-client

IMPORTANT SETTINGS

❌ Disable Client Secret

Enable:

✅ USER_PASSWORD_AUTH

Click Create app client

📌 SAVE

App Client ID

🟢 STEP 3 — CREATE ADMIN USER

User Pool → Users

Click Create user

Username: admin

Temporary password: set one

Email verified → ✅ Yes

Click Create

➡️ Login once and change password

🟢 STEP 4 — CREATE API GATEWAY AUTHORIZER

Go to API Gateway

Select your API

Click Authorizers

Click Create authorizer

Settings

Type → Cognito

Name → AdminAuthorizer

User Pool → select CharlieCafeAdminPool

Token source → Authorization

Click Create

🟢 STEP 5 — ATTACH AUTHORIZER TO API METHOD

API Gateway → Resources

Select GET /order-status

Click Method Request

Authorization → AdminAuthorizer

Save

🟢 STEP 6 — DEPLOY API

Click Deploy API

Stage name → admin

Deploy

✅ API is now JWT-secured

✅ CONFIGURATION 2 — FILTER-BACKEND (DATE FILTER IN LAMBDA)
🎯 Goal

Filter orders by date from backend, not frontend

🟢 STEP 1 — READ DATE FROM API REQUEST

In Lambda event:

API Gateway passes query string:

```
?date=2026-01-13
```

🟢 STEP 2 — MODIFY LAMBDA CODE

Add this inside lambda_handler:

```
query = event.get("queryStringParameters") or {}
filter_date = query.get("date")
```

🟢 STEP 3 — MODIFY SQL QUERY
If date is provided:

```
SELECT *
FROM orders
WHERE DATE(created_at) = %s
ORDER BY created_at DESC
```

Else:

```
SELECT *
FROM orders
ORDER BY created_at DESC
LIMIT 20
```

🟢 STEP 4 — EXECUTE QUERY SAFELY

```
if filter_date:
    cursor.execute(sql, (filter_date,))
else:
    cursor.execute(sql)
```

🟢 STEP 5 — TEST

Open browser

Call:

```
/order-status?date=2026-01-13
```

✅ Only that day’s orders returned

✅ CONFIGURATION 3 — PRINT EACH ORDER (FRONTEND)
🎯 Goal

Print all visible orders like POS systems

🟢 STEP 1 — STORE ORDERS IN JS

```
let allOrders = [];
```

After API load:

```
allOrders = data.recent_orders;
```

🟢 STEP 2 — ADD PRINT BUTTON

```
<button onclick="printOrders()">🖨 Print Orders</button>
```

🟢 STEP 3 — PRINT FUNCTION

```
function printOrders() {
  let html = "<h2>Orders</h2><table border='1'>";
  allOrders.forEach(o => {
    html += `<tr>
      <td>${o.customer_name}</td>
      <td>${o.item}</td>
      <td>${o.quantity}</td>
      <td>${o.created_at}</td>
    </tr>`;
  });
  html += "</table>";
  openPrint(html);
}
```

🟢 STEP 4 — OPEN PRINT WINDOW

```
function openPrint(html) {
  const w = window.open("");
  w.document.write(html);
  w.print();
}
```

✅ CONFIGURATION 4 — PRINT TODAY TOTAL SUMMARY
🎯 Goal

Print today’s order count + total quantity

🟢 STEP 1 — GET TODAY DATE

```
const today = new Date().toISOString().split("T")[0];
```

🟢 STEP 2 — FILTER TODAY ORDERS

```
const todayOrders = allOrders.filter(o =>
  o.created_at.startsWith(today)
);
```

🟢 STEP 3 — CALCULATE TOTALS

```
const totalOrders = todayOrders.length;
const totalQty = todayOrders.reduce((s,o)=>s+o.quantity,0);
```

🟢 STEP 4 — PRINT SUMMARY

```
function printTodaySummary() {
  let html = `
    <h2>Today's Summary</h2>
    <p>Total Orders: ${totalOrders}</p>
    <p>Total Items: ${totalQty}</p>
  `;
  openPrint(html);
}
```

🏁 FINAL CHECKLIST (ALL 4)

| Feature             | Status |
| ------------------- | ------ |
| JWT Secure API      | ✅      |
| Backend Date Filter | ✅      |
| Print Orders        | ✅      |
| Print Today Summary | ✅      |


🏆 WHAT YOU NOW HAVE

✔ Enterprise-grade Admin Dashboard

✔ Secure API

✔ Backend filtering

✔ POS-style printing

✔ Free-tier safe
---

# 🔒 SECTION 8 —  🟢 FINAL order-status.html (PRODUCTION READY)

✔ Real Cognito login (JWT ready)

✔ Secure API call (Authorization header)

✔ Loading spinner

✔ Auto refresh (10s)

✔ Chart (orders per item)

✔ Backend date filter support

✔ Print all orders

✔ Print today summary

✔ NO broken logic / NO skipped wiring

You only change 4 values (clearly marked).

🟢 FINAL order-status.html (PRODUCTION READY)

📍 Correct file location

```
/var/www/html/order-status.html
```

✅ ONLY CHANGE THESE 4 VALUES (SEARCH & REPLACE LATER)

```
USER_POOL_ID
CLIENT_ID
COGNITO_DOMAIN
API_URL
```

📄 FINAL FULL FILE (COPY 100%)

```
<!DOCTYPE html>
<html lang="en" data-bs-theme="dark">
<head>
<meta charset="UTF-8">
<title>Charlie Cafe ☕ | Admin Order Status</title>
<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- Bootstrap -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<!-- Cognito SDK -->
<script src="https://cdn.jsdelivr.net/npm/amazon-cognito-identity-js@6.3.3/dist/amazon-cognito-identity.min.js"></script>

<style>
body {
  background: linear-gradient(rgba(0,0,0,.75), rgba(0,0,0,.75)),
  url("https://images.unsplash.com/photo-1517248135467-4c7edcad34c4");
  background-size: cover;
  background-attachment: fixed;
  color: #fff;
  font-family: 'Poppins', sans-serif;
}
#dashboard { display:none; }
.metric-card {
  background:#3b1f0e;
  border-radius:15px;
}
</style>
</head>

<body>

<nav class="navbar navbar-dark bg-dark px-3">
<span class="navbar-brand">☕ Charlie Cafe Admin</span>
<button class="btn btn-danger btn-sm" onclick="logout()">Logout</button>
</nav>

<!-- LOGIN -->
<div class="container mt-5" id="loginBox">
<div class="col-md-4 mx-auto card p-4">
<h4 class="text-center">Admin Login</h4>
<input id="username" class="form-control mb-2" placeholder="Username">
<input id="password" type="password" class="form-control mb-3" placeholder="Password">
<button class="btn btn-warning w-100" onclick="login()">Login</button>
<p class="text-center small mt-2 text-muted">AWS Cognito Secure</p>
</div>
</div>

<!-- DASHBOARD -->
<div class="container my-4" id="dashboard">

<div class="d-flex gap-2 mb-3">
<input type="date" id="filterDate" class="form-control w-25">
<button class="btn btn-warning" onclick="loadData()">Filter</button>
<button class="btn btn-outline-light" onclick="printOrders()">🖨 Print Orders</button>
<button class="btn btn-outline-warning" onclick="printToday()">📄 Today Summary</button>
</div>

<!-- Loader -->
<div id="loader" class="text-center my-3" style="display:none">
<div class="spinner-border text-warning"></div>
<p>Loading...</p>
</div>

<!-- Metrics -->
<div class="row g-3 mb-4" id="metrics"></div>

<!-- Chart -->
<canvas id="orderChart" height="90"></canvas>

<!-- Table -->
<table class="table table-dark table-striped mt-4">
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

<script>
/* ========== CONFIG (CHANGE ONLY THESE 4) ========== */
const USER_POOL_ID = "YOUR_USER_POOL_ID";
const CLIENT_ID = "YOUR_CLIENT_ID";
const COGNITO_DOMAIN = "https://your-domain.auth.us-east-1.amazoncognito.com";
const API_URL = "https://API_ID.execute-api.us-east-1.amazonaws.com/admin/order-status";

/* ========== COGNITO SETUP ========== */
const pool = new AmazonCognitoIdentity.CognitoUserPool({
  UserPoolId: USER_POOL_ID,
  ClientId: CLIENT_ID
});

let chart;
let allOrders = [];

/* ========== LOGIN ========== */
function login(){
  const auth = new AmazonCognitoIdentity.AuthenticationDetails({
    Username: username.value,
    Password: password.value
  });

  const user = new AmazonCognitoIdentity.CognitoUser({
    Username: username.value,
    Pool: pool
  });

  user.authenticateUser(auth,{
    onSuccess:(res)=>{
      localStorage.setItem("token",res.getIdToken().getJwtToken());
      loginBox.style.display="none";
      dashboard.style.display="block";
      loadData();
      setInterval(loadData,10000);
    },
    onFailure:(err)=>alert(err.message)
  });
}

function logout(){
  localStorage.clear();
  location.reload();
}

/* ========== LOAD DATA ========== */
function loadData(){
loader.style.display="block";
metrics.innerHTML="";
orders.innerHTML="";

let url = API_URL;
const date = filterDate.value;
if(date) url += "?date=" + date;

fetch(url,{
  headers:{ Authorization:"Bearer "+localStorage.getItem("token") }
})
.then(r=>r.json())
.then(data=>{
loader.style.display="none";
allOrders = data.recent_orders;

data.metrics.forEach(m=>{
metrics.innerHTML += `
<div class="col-md-3">
<div class="metric-card p-3 text-center">
<b>${m.metric}</b><br>
<span class="fs-3">${m.count}</span>
</div></div>`;
});

const items={};
allOrders.forEach(o=>{
orders.innerHTML+=`
<tr>
<td>${o.customer_name}</td>
<td>${o.item}</td>
<td>${o.quantity}</td>
<td>${o.table_number || "-"}</td>
<td>${o.created_at}</td>
</tr>`;
items[o.item]=(items[o.item]||0)+o.quantity;
});

if(chart) chart.destroy();
chart=new Chart(orderChart,{
type:'bar',
data:{
labels:Object.keys(items),
datasets:[{
label:'Orders per Item',
data:Object.values(items),
backgroundColor:'#ff9800'
}]
}
});
});
}

/* ========== PRINT FUNCTIONS ========== */
function printOrders(){
let html="<h2>Orders</h2><table border='1'>";
allOrders.forEach(o=>{
html+=`<tr><td>${o.customer_name}</td><td>${o.item}</td>
<td>${o.quantity}</td><td>${o.created_at}</td></tr>`;
});
html+="</table>";
openPrint(html);
}

function printToday(){
const today=new Date().toISOString().split("T")[0];
const todayOrders=allOrders.filter(o=>o.created_at.startsWith(today));
const qty=todayOrders.reduce((s,o)=>s+o.quantity,0);
openPrint(`<h2>Today's Summary</h2>
<p>Total Orders: ${todayOrders.length}</p>
<p>Total Items: ${qty}</p>`);
}

function openPrint(html){
const w=window.open("");
w.document.write(html);
w.print();
}
</script>

</body>
</html>
```

✅ WHAT YOU NOW HAVE (CLEAR & FINAL)

| Feature             | Status |
| ------------------- | ------ |
| Cognito real login  | ✅      |
| JWT-secured API     | ✅      |
| Loading spinner     | ✅      |
| Auto refresh        | ✅      |
| Chart analytics     | ✅      |
| Backend date filter | ✅      |
| Print orders        | ✅      |
| Print today summary | ✅      |


🎯 NEXT (OPTIONAL – NOT REQUIRED NOW)

API Gateway Authorizer test

Receipt printing

CSV export

Admin vs Staff roles

🚀 COMPLETE ORDER STATUS SYSTEM – FINAL CONFIGURATION GUIDE

This guide covers ALL remaining tasks end-to-end:

1️⃣ JWT → Secure API (Cognito + Authorizer)

2️⃣ API Gateway Authorizer (Mandatory)

3️⃣ Backend Date Filter (Lambda)

4️⃣ Print Each Order + Today Summary (Backend Ready)

🟩 TASK 1 — JWT → Secure API (Cognito Token Flow)

🔹 What this does

Only logged-in Cognito users can access /order-status.

STEP 1️⃣ — User logs in (Frontend)

✔ Already implemented in order-status.html

✔ Cognito returns ID Token (JWT)

```
localStorage.setItem("token", res.getIdToken().getJwtToken());
```

STEP 2️⃣ — Frontend sends JWT to API

Every API call sends:

```
Authorization: Bearer <JWT_TOKEN>
```

✔ Already added in fetch:

```
headers:{
  Authorization: "Bearer " + localStorage.getItem("token")
}
```

STEP 3️⃣ — API Gateway validates JWT

⛔ Lambda should NOT validate token

✅ API Gateway does it automatically (Authorizer)

➡️ Move to Task 2

🟩 TASK 2 — API Gateway Authorizer (MANDATORY SECURITY)

🔹 What this does

Blocks ALL unauthenticated access at API Gateway level.

STEP 1️⃣ — Open API Gateway

```
AWS Console → API Gateway → Your API
```

STEP 2️⃣ — Create Authorizer

```
Authorizers → Create authorizer
```

Settings

Authorizer type: Cognito

Name: CafeCognitoAuth

User pool: select your pool

Token source:

```
Authorization
```

Click Create

STEP 3️⃣ — Attach Authorizer to GET /order-status

```
Resources → /order-status → GET → Method Request
```

Set:

Authorization: CafeCognitoAuth

✔ Save

STEP 4️⃣ — Deploy to NEW Stage

```
Actions → Deploy API
```

Stage name: admin

Deploy

✅ Your endpoint becomes:

```
/admin/order-status
```

STEP 5️⃣ — Update Frontend API URL

```
const API_URL = "https://API_ID.execute-api.region.amazonaws.com/admin/order-status";
```

STEP 6️⃣ — Test Security

❌ Open API in browser → 403 Unauthorized

✅ Open after login → SUCCESS

🟩 TASK 3 — FILTER-BACKEND → Date Filter in Lambda

🔹 What this does

Fetch orders by date:

```
?date=2026-01-13
```

STEP 1️⃣ — Open Lambda

```
AWS Console → Lambda → order-status-function
```

STEP 2️⃣ — Read query parameter

Add this at top:

```
params = event.get("queryStringParameters") or {}
filter_date = params.get("date")
```

STEP 3️⃣ — Apply DynamoDB filter

Example (Python):

```
from boto3.dynamodb.conditions import Attr

scan_kwargs = {}

if filter_date:
    scan_kwargs["FilterExpression"] = Attr("created_at").begins_with(filter_date)

response = table.scan(**scan_kwargs)
items = response["Items"]
```

STEP 4️⃣ — Return filtered response

Ensure response structure stays SAME:

```
{
  "metrics": [...],
  "recent_orders": [...]
}
```

✅ Frontend already supports this

🟩 TASK 4 — PRINT EACH ORDER + TODAY SUMMARY
🔹 What this does

Print all orders

Print today’s total orders & quantity

STEP 1️⃣ — Backend must send created_at

Your DynamoDB item must include:

```
"created_at": "2026-01-13T14:22:11"
```

✔ Already required

STEP 2️⃣ — Frontend stores all orders

Already done:

```
let allOrders = [];
```

STEP 3️⃣ — Print ALL Orders

Button:


```
<button onclick="printOrders()">🖨 Print Orders</button>
```

Logic:

```
function printOrders(){
  let html="<h2>Orders</h2><table border='1'>";
  allOrders.forEach(o=>{
    html+=`<tr>
      <td>${o.customer_name}</td>
      <td>${o.item}</td>
      <td>${o.quantity}</td>
      <td>${o.created_at}</td>
    </tr>`;
  });
  html+="</table>";
  openPrint(html);
}
```

STEP 4️⃣ — Print TODAY Summary

Button:

```
<button onclick="printToday()">📄 Today Summary</button>
```

Logic:

```
function printToday(){
  const today = new Date().toISOString().split("T")[0];
  const todayOrders = allOrders.filter(o =>
    o.created_at.startsWith(today)
  );

  const totalQty = todayOrders.reduce(
    (sum,o)=>sum+o.quantity,0
  );

  openPrint(`
    <h2>Today's Summary</h2>
    <p>Total Orders: ${todayOrders.length}</p>
    <p>Total Items: ${totalQty}</p>
  `);
}
```

🟩 FINAL SYSTEM FLOW (REAL-WORLD)

```
Admin → Login (Cognito)
      → JWT issued
      → API Gateway Authorizer validates JWT
      → Lambda fetches filtered data
      → Dashboard auto-refresh + print
```

✅ YOU HAVE BUILT A REAL PRODUCTION SYSTEM

✔ Enterprise authentication

✔ Secure API Gateway

✔ Backend filtering

✔ Admin dashboard

✔ Printing & reporting

✔ Zero shortcuts

---

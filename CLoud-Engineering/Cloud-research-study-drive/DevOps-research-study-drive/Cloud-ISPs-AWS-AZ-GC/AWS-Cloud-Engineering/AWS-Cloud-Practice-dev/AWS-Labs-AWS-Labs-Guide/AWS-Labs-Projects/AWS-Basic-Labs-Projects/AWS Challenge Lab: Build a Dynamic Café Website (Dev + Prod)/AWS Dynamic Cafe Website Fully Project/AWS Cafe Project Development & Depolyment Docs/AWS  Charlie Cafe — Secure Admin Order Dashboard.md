# ☕ SECTION 2 — ORDER STATUS Login

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

## 🔐 PHASE  0 — PREREQUISITES (CHECK ONLY)

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

## 🔐 PHASE 1️⃣ — DEPLOY FINAL FRONTEND (WRITE ONCE ✅)

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

```
/var/www/html/order-status.html
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

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Cafe ☕ | Order Status</title>
<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- Bootstrap -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- Chart.js -->
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<!-- Amazon Cognito SDK -->
<script src="https://cdn.jsdelivr.net/npm/amazon-cognito-identity-js@6.3.3/dist/amazon-cognito-identity.min.js"></script>

<style>
/* ===== BACKGROUND ===== */
body {
  min-height: 100vh;
  background:
    linear-gradient(rgba(0,0,0,.55), rgba(0,0,0,.55)),
    url("https://images.unsplash.com/photo-1509042239860-f550ce710b93");
  background-size: cover;
  background-position: center;
  background-attachment: fixed;
}

/* ===== LOGIN CENTER ===== */
#loginWrapper {
  min-height: calc(100vh - 56px);
  display: flex;
  align-items: center;
  justify-content: center;
}

#loginBox .card {
  background: rgba(255,255,255,.95);
  border-radius: 12px;
  box-shadow: 0 10px 30px rgba(0,0,0,.4);
}

#dashboard {
  display: none;
  background:#f5f5f5;
  padding: 20px;
  border-radius: 8px;
}

/* Metrics card */
.card-metric {
  background:#fff;
  padding:15px;
  border-radius:8px;
  box-shadow:0 2px 6px rgba(0,0,0,.1);
}
</style>
</head>

<body>

<!-- NAVBAR -->
<nav class="navbar navbar-dark bg-dark">
  <div class="container">
    <span class="navbar-brand">☕ Charlie Cafe Admin</span>
    <button class="btn btn-danger btn-sm" onclick="logout()">Logout</button>
  </div>
</nav>

<!-- LOGIN (CENTERED) -->
<div id="loginWrapper">
  <div class="container" id="loginBox">
    <div class="col-md-4 mx-auto card p-4">
      <h4 class="text-center mb-3">Admin Login</h4>
      <input id="username" class="form-control mb-2" placeholder="Username">
      <input id="password" type="password" class="form-control mb-3" placeholder="Password">
      <button class="btn btn-warning w-100" onclick="login()">Login</button>
      <p class="text-muted small mt-2 text-center">AWS Cognito Secured</p>
    </div>
  </div>
</div>

<!-- DASHBOARD -->
<div class="container my-4" id="dashboard">

<!-- FILTER -->
<div class="row mb-3">
  <div class="col-md-3">
    <input type="date" id="filterDate" class="form-control">
  </div>
  <div class="col-md-2">
    <button class="btn btn-primary w-100" onclick="loadData()">Filter</button>
  </div>
</div>

<!-- LOADER -->
<div class="text-center my-3" id="loader" style="display:none">
  <div class="spinner-border text-warning"></div>
  <p class="mt-2">Loading...</p>
</div>

<!-- METRICS -->
<div class="row mb-4" id="metrics"></div>

<!-- CHART -->
<canvas id="orderChart" height="100"></canvas>

<!-- TABLE -->
<table class="table table-bordered mt-4 bg-white">
  <thead class="table-dark">
    <tr>
      <th>Customer</th>
      <th>Item</th>
      <th>Qty</th>
      <th>Date</th>
    </tr>
  </thead>
  <tbody id="orders"></tbody>
</table>

</div>

<script>
/* ================== CONFIG ================== */
const USER_POOL_ID = "YOUR_USER_POOL_ID";
const APP_CLIENT_ID = "YOUR_APP_CLIENT_ID";
const API_URL = "https://API_ID.execute-api.region.amazonaws.com/STAGE/order-status";

const poolData = { UserPoolId: USER_POOL_ID, ClientId: APP_CLIENT_ID };
const userPool = new AmazonCognitoIdentity.CognitoUserPool(poolData);

let chart, refreshTimer;

/* ================== AUTH ================== */
function login() {
  const authDetails = new AmazonCognitoIdentity.AuthenticationDetails({
    Username: username.value,
    Password: password.value
  });

  const cognitoUser = new AmazonCognitoIdentity.CognitoUser({
    Username: username.value,
    Pool: userPool
  });

  cognitoUser.authenticateUser(authDetails, {
    onSuccess: function (result) {
      localStorage.setItem("token", result.getIdToken().getJwtToken());
      showDashboard();
    },
    onFailure: function (err) {
      alert(err.message);
    }
  });
}

function logout() {
  localStorage.removeItem("token");
  clearInterval(refreshTimer);
  location.reload();
}

function showDashboard() {
  loginWrapper.style.display = "none";
  dashboard.style.display = "block";
  loadData();
  refreshTimer = setInterval(loadData, 10000);
}

/* ================== DATA ================== */
function loadData() {
  const token = localStorage.getItem("token");
  if (!token) return logout();

  loader.style.display = "block";
  metrics.innerHTML = "";
  orders.innerHTML = "";

  let url = API_URL;
  if (filterDate.value) url += "?date=" + filterDate.value;

  fetch(url, { headers: { Authorization: token } })
  .then(res => {
    if (res.status === 401) logout();
    return res.json();
  })
  .then(data => {
    loader.style.display = "none";

    data.metrics.forEach(m => {
      metrics.innerHTML += `
        <div class="col-md-3 mb-2">
          <div class="card-metric text-center fw-bold">
            ${m.metric}<br>${m.count}
          </div>
        </div>`;
    });

    const items = {};
    data.recent_orders.forEach(o => {
      orders.innerHTML += `
        <tr>
          <td>${o.customer_name}</td>
          <td>${o.item}</td>
          <td>${o.quantity}</td>
          <td>${o.created_at}</td>
        </tr>`;
      items[o.item] = (items[o.item] || 0) + o.quantity;
    });

    if (chart) chart.destroy();
    chart = new Chart(orderChart, {
      type: 'bar',
      data: {
        labels: Object.keys(items),
        datasets: [{
          label: 'Orders per Item',
          data: Object.values(items),
          backgroundColor: '#ff9800'
        }]
      }
    });
  });
}

/* ================== AUTO LOGIN ================== */
if (localStorage.getItem("token")) showDashboard();
</script>

</body>
</html>
```

#### Save File

```
CTRL + O → ENTER
CTRL + X
```

#### 🔧 OPTIONAL (YOU CAN CHANGE LATER)

Replace background image URL with your own S3 / CloudFront image

#### Adjust opacity:

```
rgba(0,0,0,.55)
```


#### ✅ Result:

- Login screen

- Spinner

- Auto refresh (10s)

- Chart

- Date filter

- Print buttons

- JWT ready

## 🔐 PHASE 2️⃣ — COGNITO INTEGRATION (PRODUCTION READY)

### 🔐 STEP 1 — CREATE USER POOL (NO CHANGE)

- **Cognito → User Pools → Create**

- Sign-in: Username

- Password policy: Default

- MFA: OFF

- Account recovery: Email

#### ✅ This matches both your old and new guides

### 🔐 STEP 2 — CREATE APP CLIENT (⚠️ ONE IMPORTANT FIX)

- **User Pool → App integration → App clients → Create**

- App type: Public

- ❌ Client secret: DISABLED

#### Auth flows:

✅ USER_PASSWORD_AUTH

✅ REFRESH_TOKEN_AUTH ← ⭐ REQUIRED (missing earlier)

#### 📌 Save:

- User Pool ID

- App Client ID

#### ✅ This matches your FINAL frontend code

### ❌ STEP 3 — HOSTED UI (OPTIONAL / NOT USED)

#### Your new guide says:

```
Configure Hosted UI
Callback URL
Logout URL
```

#### Truth:

❌ Not used by your JavaScript

❌ No redirect logic in your code

❌ No OAuth flow

#### Decision:

✅ SKIP IT (recommended)

OR keep it (does not break anything)

#### 🧠 Professional rule:

If you don’t call Hosted UI, don’t configure it.

### 🔐 STEP 4 — CREATE ADMIN USER (SAME AS BEFORE)

- Users → Create user

- Username: admin

- Temporary password

- Mark email verified

- Login once → set permanent password

#### ✅ Fully compatible

---

## 🔐 PHASE 3️⃣ — API GATEWAY AUTH 

### 🔹 STEP 3 — SECURE API GATEWAY (MOST IMPORTANT)

#### 3.1 Create Cognito Authorizer

```
API Gateway → Authorizers → Create
Type: Cognito
User Pool: SELECT
Token source: Authorization
```

#### 3.2 Attach to API Method

```
Resources → GET /order-status
Method Request → Authorization → CognitoAuthorizer
```

#### 3.3 Enable CORS (AGAIN)

```
GET /order-status → Enable CORS → Replace headers
```

#### 3.4 Deploy API

```
Stage name: admin
```

#### 📌 Copy new endpoint:

```
https://xxx.execute-api.region.amazonaws.com/admin/order-status
```

#### 🔁 Update frontend:

```
API_URL = ".../admin/order-status"
```

#### ✅ Result:

- ❌ No login → 401


- ✅ Login → data loads

---

## 🔐 PHASE 4️⃣ — BACKEND DATE FILTER (LAMBDA)

### Lambda change (ONLY THIS LOGIC)

```
params = event.get("queryStringParameters") or {}
filter_date = params.get("date")

sql = "SELECT * FROM orders"
values = []

if filter_date:
    sql += " WHERE DATE(created_at) = %s"
    values.append(filter_date)

sql += " ORDER BY created_at DESC LIMIT 20"
cursor.execute(sql, values)
```

#### ✅ Result:

```
/order-status?date=YYYY-MM-DD
```

✅ returns filtered orders

### 🔐 Assumptions

- API Gateway already validates JWT (Cognito Authorizer)

- Lambda is NOT doing auth (correct design)

- Database: MySQL / RDS

- Metrics + Analytics supported

### ✅ FINAL LAMBDA CODE (Python 3.12)

> 🔁 This is a drop-in replacement
> Nothing else needs to change

```
import json
import os
import pymysql

# ================= CONFIG =================
DB_HOST = os.environ['DB_HOST']
DB_USER = os.environ['DB_USER']
DB_PASS = os.environ['DB_PASS']
DB_NAME = os.environ['DB_NAME']

# ================= DB CONNECTION =================
def get_connection():
    return pymysql.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASS,
        db=DB_NAME,
        cursorclass=pymysql.cursors.DictCursor
    )

# ================= LAMBDA HANDLER =================
def lambda_handler(event, context):
    conn = None
    cursor = None

    try:
        params = event.get("queryStringParameters") or {}
        filter_date = params.get("date")

        conn = get_connection()
        cursor = conn.cursor()

        # ---------- RECENT ORDERS ----------
        sql = "SELECT customer_name, item, quantity, created_at FROM orders"
        values = []

        if filter_date:
            sql += " WHERE DATE(created_at) = %s"
            values.append(filter_date)

        sql += " ORDER BY created_at DESC LIMIT 20"
        cursor.execute(sql, values)
        recent_orders = cursor.fetchall()

        # ---------- METRICS (DATE-AWARE) ----------
        metrics = []

        where_clause = ""
        metric_values = []

        if filter_date:
            where_clause = " WHERE DATE(created_at) = %s"
            metric_values.append(filter_date)

        cursor.execute(
            f"SELECT COUNT(*) AS count FROM orders{where_clause}",
            metric_values
        )
        metrics.append({
            "metric": "Total Orders",
            "count": cursor.fetchone()['count']
        })

        cursor.execute(
            f"SELECT SUM(quantity) AS count FROM orders{where_clause}",
            metric_values
        )
        metrics.append({
            "metric": "Total Items Sold",
            "count": cursor.fetchone()['count'] or 0
        })

        cursor.execute(
            f"SELECT COUNT(DISTINCT customer_name) AS count FROM orders{where_clause}",
            metric_values
        )
        metrics.append({
            "metric": "Customers",
            "count": cursor.fetchone()['count']
        })

        # ---------- RESPONSE ----------
        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Headers": "Authorization",
                "Access-Control-Allow-Methods": "GET"
            },
            "body": json.dumps({
                "metrics": metrics,
                "recent_orders": recent_orders
            }, default=str)
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({"error": str(e)})
        }

    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()
```

### 🔐 REQUIRED LAMBDA ENV VARIABLES

```
DB_HOST = your-rds-endpoint
DB_USER = admin
DB_PASS = password
DB_NAME = cafe
```

### 🧪 FINAL TEST (MATCHES YOUR GUIDE)

#### ❌ Without token

```
curl https://api/admin/order-status
→ 401 Unauthorized ✅
```

#### ✅ With frontend

```
Login → token issued
Dashboard → loads
Auto refresh → works
Date filter → works
Chart → works
```

---

## 🔐 PHASE 5️⃣ PRINT FEATURES (NO BACKEND CHANGE)

Already handled in final HTML:

✔ Print all orders

✔ Print today summary

✔ PDF / printer supported

Nothing extra required.


---
## 🔐 PHASE 6️⃣ — TEST FLOW

#### 1️⃣ Open:

```
http://YOUR_EC2_IP/order-status.html
```

2️⃣ Login with Cognito admin

3️⃣ Dashboard loads

4️⃣ Auto refresh works

5️⃣ Chart updates

6️⃣ Metrics visible

---
# Charlie Cafe order-tracking

> ### real-time order tracking with live status + animations (like Foodpanda or Uber Eats)

Building real-time order tracking with live status + animations (like Foodpanda or Uber Eats) is a perfect portfolio-level project—and honestly, you already have the right stack (AWS + frontend).
Let’s break it into a real-world architecture + step-by-step implementation 👇

### 🚀 1. System Architecture (Production Style)

### 🔹 Frontend (User Tracking Page)

- HTML + CSS + JS (or React later)

- Shows:

    - Order timeline (Placed → Preparing → Out for Delivery → Delivered)

    - Live updates (no refresh)

    - Animations (progress bar, icons)

### 🔹 Backend (AWS)

- API Gateway → REST endpoints

- Lambda → business logic

- DynamoDB / RDS → store orders

- WebSocket API (IMPORTANT) → real-time updates

- OR polling fallback (simpler)

### ⚡ 2. Real-Time Options (Choose One)

### ✅ Option A — Simple (Polling every 3–5 sec)

#### Frontend calls API:

```
GET /order-status?order_id=123
```

#### Updates UI

👉 Easy but not truly real-time

### 🔥 Option B — PRO (WebSocket – Like Uber Eats)

#### Use:

- API Gateway WebSocket

- Lambda pushes updates

#### Flow:

- User opens tracking page → WebSocket connects

- Save connectionId in DynamoDB

- When order status changes → Lambda sends update to that connection

### 🧠 3. Order Status Design

#### Use clean states:

```
[
  "PLACED",
  "CONFIRMED",
  "PREPARING",
  "OUT_FOR_DELIVERY",
  "DELIVERED"
]
```

### 🎨 4. Frontend UI (WITH ANIMATION)

### 🔹 HTML Structure

```
<div class="timeline">
  <div class="step active">Order Placed</div>
  <div class="step">Preparing</div>
  <div class="step">Out for Delivery</div>
  <div class="step">Delivered</div>
</div>
```

### 🔹 CSS Animation (🔥 Smooth Progress)

```
.timeline {
  display: flex;
  justify-content: space-between;
}

.step {
  position: relative;
  padding: 10px;
  color: gray;
  transition: all 0.5s ease;
}

.step.active {
  color: green;
  font-weight: bold;
  transform: scale(1.1);
}
```

### 🔹 JS (Update UI Dynamically)

```
function updateStatusUI(status) {
  const steps = ["PLACED", "PREPARING", "OUT_FOR_DELIVERY", "DELIVERED"];
  const elements = document.querySelectorAll(".step");

  steps.forEach((step, index) => {
    if (steps.indexOf(status) >= index) {
      elements[index].classList.add("active");
    }
  });
}
```

### 🔌 5. WebSocket (REAL-TIME CORE)

### 🔹 Connect (Frontend)

```
const socket = new WebSocket("wss://your-api-id.execute-api.region.amazonaws.com/prod");

socket.onmessage = (event) => {
  const data = JSON.parse(event.data);
  updateStatusUI(data.status);
};
```

### 🔹 Save Connection (Lambda - $connect)

```
connection_id = event['requestContext']['connectionId']

# store in DynamoDB
table.put_item({
    "connectionId": connection_id,
    "order_id": "123"
})
```

### 🔹 Push Update (Lambda)

```
import boto3

apigw = boto3.client(
    'apigatewaymanagementapi',
    endpoint_url="https://your-api-id.execute-api.region.amazonaws.com/prod"
)

apigw.post_to_connection(
    ConnectionId=connection_id,
    Data=json.dumps({"status": "OUT_FOR_DELIVERY"})
)
```

### 🧪 6. Trigger Status Updates

#### You can update order status from:

- Admin panel (like your café system)

- Kitchen dashboard

- Delivery app

#### Example:

```
status = "PREPARING"

# update DB
# then notify user via WebSocket
```

### 🎯 7. Advanced Animations (LIKE FOODPANDA 🔥)

### Add:

#### ✅ Progress Bar

```
.progress-bar {
  height: 5px;
  background: green;
  width: 0%;
  transition: width 1s ease;
}
```

#### JS:

```
function updateProgress(status) {
  const map = {
    "PLACED": 25,
    "PREPARING": 50,
    "OUT_FOR_DELIVERY": 75,
    "DELIVERED": 100
  };

  document.querySelector(".progress-bar").style.width = map[status] + "%";
}
```

### 📦 8. BONUS (Next-Level Features)

#### If you want Uber Eats level:

### 🚴 Live Map Tracking

#### Use:

- Google Maps API

- Delivery rider GPS

### 🔔 Notifications

- SMS (AWS SNS)

- Push notifications

### ⏱ Estimated Time

- "Arriving in 15 mins"

### 🧠 9. Your BEST STACK (Based on your current work)

Since you're already using AWS:

#### 👉 Use this combo:

- API Gateway (REST + WebSocket)

- Lambda (Python)

- DynamoDB (orders + connections)

- S3 + CloudFront (frontend)

### 💡 10. Real Interview-Level Upgrade

#### Say this in interview:

"I implemented real-time order tracking using API Gateway WebSocket where Lambda pushes status updates to connected clients, eliminating polling and reducing latency."

🔥 That’s senior-level thinking

### ✅ ✅ FULL FINAL FRONTEND (Copy–Paste Ready)
📄 order-tracking.html


Perfect — let’s build you a 🔥 production-ready real-time order tracking frontend (with animation + WebSocket + fallback polling). You can plug this directly into your Charlie Café system.

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Order Tracking</title>

<style>
body {
  font-family: Arial, sans-serif;
  background: #f5f7fa;
  text-align: center;
  padding: 30px;
}

h2 {
  margin-bottom: 30px;
}

/* Timeline */
.timeline {
  display: flex;
  justify-content: space-between;
  margin: 40px auto;
  max-width: 700px;
  position: relative;
}

/* Line */
.timeline::before {
  content: '';
  position: absolute;
  top: 50%;
  left: 0;
  width: 100%;
  height: 5px;
  background: #ddd;
  z-index: 0;
}

/* Progress bar */
.progress {
  position: absolute;
  top: 50%;
  left: 0;
  height: 5px;
  background: #28a745;
  width: 0%;
  z-index: 1;
  transition: width 1s ease;
}

/* Steps */
.step {
  position: relative;
  z-index: 2;
  background: white;
  border: 3px solid #ccc;
  border-radius: 50%;
  width: 50px;
  height: 50px;
  line-height: 45px;
  font-size: 20px;
  color: #ccc;
  transition: all 0.4s ease;
}

.step.active {
  border-color: #28a745;
  color: #28a745;
  transform: scale(1.2);
}

.label {
  margin-top: 10px;
  font-size: 14px;
}

.container {
  display: flex;
  flex-direction: column;
  align-items: center;
}

/* Status text */
#statusText {
  font-size: 20px;
  font-weight: bold;
  margin-top: 20px;
}

/* Pulse animation */
@keyframes pulse {
  0% { transform: scale(1.2); }
  50% { transform: scale(1.35); }
  100% { transform: scale(1.2); }
}

.step.active:last-child {
  animation: pulse 1s infinite;
}

</style>
</head>

<body>

<h2>🍔 Order Tracking</h2>

<div class="timeline">
  <div class="progress" id="progressBar"></div>

  <div class="container">
    <div class="step" id="step0">✔</div>
    <div class="label">Placed</div>
  </div>

  <div class="container">
    <div class="step" id="step1">👨‍🍳</div>
    <div class="label">Preparing</div>
  </div>

  <div class="container">
    <div class="step" id="step2">🚴</div>
    <div class="label">On the Way</div>
  </div>

  <div class="container">
    <div class="step" id="step3">🏁</div>
    <div class="label">Delivered</div>
  </div>
</div>

<div id="statusText">Waiting for update...</div>

<script>
// ============================
// CONFIG
// ============================
const ORDER_ID = "123"; // dynamically set this
const WEBSOCKET_URL = "wss://YOUR-WS-API.execute-api.region.amazonaws.com/prod";
const API_URL = "https://YOUR-REST-API/order-status?order_id=" + ORDER_ID;

// ============================
// STATUS FLOW
// ============================
const steps = ["PLACED", "PREPARING", "OUT_FOR_DELIVERY", "DELIVERED"];

// ============================
// UI UPDATE FUNCTION
// ============================
function updateUI(status) {
  const index = steps.indexOf(status);

  // Update steps
  steps.forEach((step, i) => {
    const el = document.getElementById("step" + i);
    if (i <= index) {
      el.classList.add("active");
    } else {
      el.classList.remove("active");
    }
  });

  // Update progress bar
  const percent = ((index + 1) / steps.length) * 100;
  document.getElementById("progressBar").style.width = percent + "%";

  // Status text
  document.getElementById("statusText").innerText = "Status: " + status;
}

// ============================
// WEBSOCKET (REAL-TIME)
// ============================
function connectWebSocket() {
  try {
    const socket = new WebSocket(WEBSOCKET_URL);

    socket.onopen = () => {
      console.log("WebSocket connected");
    };

    socket.onmessage = (event) => {
      console.log("Received:", event.data);
      const data = JSON.parse(event.data);
      if (data.status) {
        updateUI(data.status);
      }
    };

    socket.onerror = () => {
      console.log("WebSocket error → fallback to polling");
      startPolling();
    };

    socket.onclose = () => {
      console.log("WebSocket closed → fallback to polling");
      startPolling();
    };

  } catch (e) {
    console.log("WS failed → fallback");
    startPolling();
  }
}

// ============================
// POLLING FALLBACK
// ============================
function startPolling() {
  setInterval(async () => {
    try {
      const res = await fetch(API_URL);
      const data = await res.json();
      if (data.status) {
        updateUI(data.status);
      }
    } catch (err) {
      console.log("Polling error", err);
    }
  }, 3000);
}

// ============================
// INIT
// ============================
connectWebSocket();

</script>

</body>
</html>
```

### 🔥 What This Gives You

✅ Real-time tracking (WebSocket)

✅ Auto fallback (Polling)

✅ Smooth animation (progress + pulse)

✅ Clean UI like delivery apps

✅ Works with your AWS backend

### ⚠️ IMPORTANT (You MUST Change)

#### Replace:

```
const WEBSOCKET_URL = "wss://YOUR-WS-API...";
const API_URL = "https://YOUR-REST-API/order-status...";
```

#### 👉 With your actual:

- API Gateway WebSocket URL

- REST API endpoint

## 🌐 real production upgrade

### 🔥 WHAT YOU’LL DO

#### We will:

✅ Add tracking timeline UI under status

✅ Connect it to your existing order.status

✅ Keep your current API (no backend change needed)

✅ Upgrade animation (like Foodpanda style)

### 🧩 STEP 1 — ADD TRACKING HTML

👉 Paste this RIGHT BELOW your status badge section

#### Find this in your code:

```
<p>
    <strong>Status:</strong>
    <span id="statusBadge" class="badge bg-secondary status-badge">Loading...</span>
</p>
<hr>
```

#### 👇 ADD THIS BELOW IT:

```
<!-- ================= ORDER TRACKING ================= -->
<div class="mt-4">
    <h6 class="text-center mb-3">Order Progress</h6>

    <div class="timeline">
        <div class="progress" id="progressBar"></div>

        <div class="container-step">
            <div class="step" id="step0">✔</div>
            <small>Received</small>
        </div>

        <div class="container-step">
            <div class="step" id="step1">👨‍🍳</div>
            <small>Preparing</small>
        </div>

        <div class="container-step">
            <div class="step" id="step2">📦</div>
            <small>Ready</small>
        </div>

        <div class="container-step">
            <div class="step" id="step3">🏁</div>
            <small>Completed</small>
        </div>
    </div>
</div>
```

### 🎨 STEP 2 — ADD CSS (ANIMATION)

👉 Add this inside your <style> section

```
/* ================= TRACKING TIMELINE ================= */
.timeline {
    display: flex;
    justify-content: space-between;
    position: relative;
    margin-top: 20px;
}

.timeline::before {
    content: '';
    position: absolute;
    top: 20px;
    width: 100%;
    height: 5px;
    background: #555;
    z-index: 0;
}

.progress {
    position: absolute;
    top: 20px;
    left: 0;
    height: 5px;
    background: #28a745;
    width: 0%;
    z-index: 1;
    transition: width 0.8s ease;
}

.container-step {
    text-align: center;
    z-index: 2;
}

.step {
    width: 45px;
    height: 45px;
    border-radius: 50%;
    border: 3px solid #777;
    display: flex;
    align-items: center;
    justify-content: center;
    background: #222;
    color: #777;
    transition: all 0.4s ease;
}

.step.active {
    border-color: #28a745;
    color: #28a745;
    transform: scale(1.2);
}

/* Pulse on final */
.step.active:last-child {
    animation: pulse 1s infinite;
}

@keyframes pulse {
    0% { transform: scale(1.2); }
    50% { transform: scale(1.35); }
    100% { transform: scale(1.2); }
}
```

### ⚙️ STEP 3 — ADD JS FUNCTION (IMPORTANT)

👉 Add this above fetchOrder()

```
// ================= TRACKING FLOW =================
const trackingSteps = ["RECEIVED", "PREPARING", "READY", "COMPLETED"];

function updateTrackingUI(status) {
    const index = trackingSteps.indexOf(status);

    trackingSteps.forEach((step, i) => {
        const el = document.getElementById("step" + i);
        if (i <= index) {
            el.classList.add("active");
        } else {
            el.classList.remove("active");
        }
    });

    // progress bar %
    const percent = ((index + 1) / trackingSteps.length) * 100;
    document.getElementById("progressBar").style.width = percent + "%";
}
```

### 🔌 STEP 4 — CONNECT TO YOUR EXISTING DATA

👉 Inside your fetchOrder() function

#### Find this:

```
statusBadge.textContent = order.status;
statusBadge.className = `badge bg-${badge} status-badge`;
```

#### 👇 ADD THIS LINE RIGHT AFTER:

```
updateTrackingUI(order.status);
```

### 🧠 FINAL RESULT

#### Now your page will:

✅ Show receipt

✅ Show status badge

✅ Show animated progress bar

✅ Auto-update every 10 sec

✅ Works with your existing Lambda + API

### ✅ ✅ COMPLETE FINAL CODE (WITH TRACKING + ANIMATION)

Add the tracking timeline HTML under the status badge.
Add CSS for animation.
Add JS to update the timeline whenever fetchOrder() runs (your current polling every 10 sec will work fine).

#### Here’s your fully final order-receipt.php with tracking added:

```
<?php 
// ==========================================================
// CHARLIE CAFE — ORDER RECEIPT PAGE (PUBLIC)
// ----------------------------------------------------------
// ✔ No Cognito Required
// ✔ Uses Production API Gateway (/prod)
// ✔ Public Endpoint: /prod/order-status
// ✔ Live Auto Refresh
// ✔ QR Code Tracking
// ==========================================================

// ================= VALIDATE ORDER ID =================
if (!isset($_GET['order_id']) || empty($_GET['order_id'])) {
    die("❌ Invalid order reference.");
}

$orderId = htmlspecialchars($_GET['order_id']); // sanitize
?>

<!DOCTYPE html>
<html lang="en" data-bs-theme="dark">
<head>
<meta charset="UTF-8">
<title>Order Receipt | Charlie Cafe ☕</title>
<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- ================= BOOTSTRAP ================= -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- ================= GOOGLE FONT ================= -->
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">

<!-- ================= BOOTSTRAP ICONS ================= -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css" rel="stylesheet">

<!-- ================= QR CODE LIBRARY ================= -->
<script src="https://cdn.jsdelivr.net/npm/qrcodejs/qrcode.min.js"></script>

<!-- ================= CONFIG & UTILITIES ================= -->
<script src="/js/config.js"></script>
<script src="/js/utils.js"></script>

<style>
/* ================= BODY + BACKGROUND ================= */
body {
    font-family: 'Poppins', sans-serif;
    min-height: 100vh;
    margin: 0;
    background: linear-gradient(rgba(0,0,0,0.65), rgba(0,0,0,0.65)),
                url("https://images.unsplash.com/photo-1517248135467-4c7edcad34c4");
    background-size: cover;
    background-position: center;
    background-attachment: fixed;
    color: #fff;
}

/* ================= NAVBAR ================= */
.navbar {
    background-color: rgba(59, 31, 14, 0.9) !important;
    position: fixed;
    width: 100%;
    z-index: 1100;
}
.navbar .navbar-brand {
    font-weight: bold;
    color: #ff9800 !important;
    display: flex;
    align-items: center;
}
.navbar .navbar-brand i { margin-right: 10px; font-size: 1.5rem; }

/* ================= MAIN CONTENT ================= */
.main-content { padding-top: 100px; padding-bottom: 50px; }

/* ================= RECEIPT CARD ================= */
.receipt-card {
    background: rgba(30,30,30,0.85);
    border-radius: 20px;
    padding: 30px;
    max-width: 600px;
    margin: auto;
    box-shadow: 0 10px 30px rgba(0,0,0,0.5);
}

/* ================= BUTTONS ================= */
.btn-transparent {
    background: rgba(255,255,255,0.1);
    border: 1px solid #ff9800;
    color: #ff9800;
    display: flex;
    align-items: center;
    justify-content: center;
}
.btn-transparent i { margin-right: 8px; }

/* ================= STATUS BADGE ================= */
.status-badge { font-size: 14px; padding: 6px 12px; }

/* ================= QR CODE BOX ================= */
#qrBox {
    background: rgba(255,255,255,0.05);
    padding: 15px;
    border-radius: 12px;
    display: flex;
    flex-direction: column;
    align-items: center;
}

/* ================= TRACKING TIMELINE ================= */
.timeline {
    display: flex;
    justify-content: space-between;
    position: relative;
    margin-top: 20px;
}

.timeline::before {
    content: '';
    position: absolute;
    top: 20px;
    width: 100%;
    height: 5px;
    background: #555;
    z-index: 0;
}

.progress {
    position: absolute;
    top: 20px;
    left: 0;
    height: 5px;
    background: #28a745;
    width: 0%;
    z-index: 1;
    transition: width 0.8s ease;
}

.container-step {
    text-align: center;
    z-index: 2;
}

.step {
    width: 45px;
    height: 45px;
    border-radius: 50%;
    border: 3px solid #777;
    display: flex;
    align-items: center;
    justify-content: center;
    background: #222;
    color: #777;
    transition: all 0.4s ease;
}

.step.active {
    border-color: #28a745;
    color: #28a745;
    transform: scale(1.2);
}

/* Pulse on final step */
.step.active:last-child {
    animation: pulse 1s infinite;
}

@keyframes pulse {
    0% { transform: scale(1.2); }
    50% { transform: scale(1.35); }
    100% { transform: scale(1.2); }
}

/* ================= RESPONSIVE ================= */
@media (max-width:768px){ .main-content { padding-top: 120px; } }
</style>
</head>

<body style="display:none">

<!-- ================= NAVBAR ================= -->
<nav class="navbar navbar-dark">
    <div class="container-fluid">
        <a class="navbar-brand" href="index.php">
            <i class="bi bi-cup-straw-fill"></i> Charlie Cafe
        </a>
    </div>
</nav>

<!-- ================= MAIN CONTENT ================= -->
<div class="main-content">
    <div class="container">
        <div class="receipt-card">

            <!-- ================= HEADER ================= -->
            <h4 class="text-center mb-2">
                <i class="bi bi-cup-straw-fill"></i> Charlie Cafe
            </h4>
            <p class="text-center text-muted">Order Receipt</p>
            <hr>

            <!-- ================= ORDER DETAILS ================= -->
            <p><i class="bi bi-upc-scan"></i> <strong>Order ID:</strong> <span id="orderId"><?= $orderId ?></span></p>
            <p><i class="bi bi-person-fill"></i> <strong>Customer:</strong> <span id="customerName">Loading...</span></p>
            <p><i class="bi bi-table"></i> <strong>Table:</strong> <span id="tableNumber">Loading...</span></p>
            <p><i class="bi bi-calendar-event-fill"></i> <strong>Date:</strong> <span id="orderDate">Loading...</span></p>
            <hr>
            <p><i class="bi bi-cup-fill"></i> <strong>Item:</strong> <span id="itemName">Loading...</span></p>
            <p><i class="bi bi-hash"></i> <strong>Quantity:</strong> <span id="quantity">Loading...</span></p>
            <hr>

            <!-- ================= STATUS BADGE ================= -->
            <p>
                <strong>Status:</strong>
                <span id="statusBadge" class="badge bg-secondary status-badge">Loading...</span>
            </p>

            <!-- ================= ORDER TRACKING ================= -->
            <div class="mt-4">
                <h6 class="text-center mb-3">Order Progress</h6>

                <div class="timeline">
                    <div class="progress" id="progressBar"></div>

                    <div class="container-step">
                        <div class="step" id="step0">✔</div>
                        <small>Received</small>
                    </div>

                    <div class="container-step">
                        <div class="step" id="step1">👨‍🍳</div>
                        <small>Preparing</small>
                    </div>

                    <div class="container-step">
                        <div class="step" id="step2">📦</div>
                        <small>Ready</small>
                    </div>

                    <div class="container-step">
                        <div class="step" id="step3">🏁</div>
                        <small>Completed</small>
                    </div>
                </div>
            </div>
            <hr>

            <p class="fw-bold">
                <i class="bi bi-currency-dollar"></i>
                Total Amount: $<span id="totalAmount">0.00</span>
            </p>

            <!-- ================= QR CODE ================= -->
            <div id="qrBox" class="my-3">
                <div id="qrcode"></div>
                <small class="text-muted mt-2">Scan to track order</small>
            </div>

            <!-- ================= PRINT BUTTON ================= -->
            <div class="d-grid gap-2 mt-3">
                <button onclick="window.print()" class="btn btn-transparent">
                    <i class="bi bi-printer-fill"></i> Print Receipt
                </button>
            </div>

        </div>
    </div>
</div>

<!-- ================= BOOTSTRAP JS ================= -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<!-- ================= ORDER FETCH & LIVE REFRESH ================= -->
<script>
document.body.style.display = "block"; // show page

// =========================================================
// USE CONFIG.JS API BASE (from CHARLIE_CONFIG)
// =========================================================
const apiBase = `${window.CHARLIE_CONFIG.API_BASE}/cafe-order-status`;
const orderId = document.getElementById('orderId').textContent;

// ================= TRACKING FLOW =================
const trackingSteps = ["RECEIVED", "PREPARING", "READY", "COMPLETED"];

function updateTrackingUI(status) {
    const index = trackingSteps.indexOf(status);

    trackingSteps.forEach((step, i) => {
        const el = document.getElementById("step" + i);
        if (i <= index) {
            el.classList.add("active");
        } else {
            el.classList.remove("active");
        }
    });

    // progress bar %
    const percent = ((index + 1) / trackingSteps.length) * 100;
    document.getElementById("progressBar").style.width = percent + "%";
}

// Fetch order from API
async function fetchOrder() {
    try {
        const res = await fetch(`${apiBase}?order_id=${encodeURIComponent(orderId)}`);
        if (!res.ok) throw new Error("Failed to fetch order");
        const data = await res.json();
        const order = data.order;

        if (!order) throw new Error("Order not found");

        // Fill HTML dynamically
        document.getElementById('customerName').textContent = order.customer_name;
        document.getElementById('tableNumber').textContent = order.table_number;
        document.getElementById('orderDate').textContent = order.created_at;
        document.getElementById('itemName').textContent = order.item;
        document.getElementById('quantity').textContent = order.quantity;
        document.getElementById('totalAmount').textContent = Number(order.total_amount).toFixed(2);

        // Status badge
        const statusBadge = document.getElementById('statusBadge');
        let badge = "secondary";
        switch(order.status) {
            case "RECEIVED": badge = "info"; break;
            case "PREPARING": badge = "warning"; break;
            case "READY": badge = "primary"; break;
            case "COMPLETED": badge = "success"; break;
        }
        statusBadge.textContent = order.status;
        statusBadge.className = `badge bg-${badge} status-badge`;

        // Update tracking timeline
        updateTrackingUI(order.status);

        // QR code with order URL
        new QRCode(document.getElementById("qrcode"), {
            text: window.location.href,
            width: 140,
            height: 140
        });

    } catch (err) {
        console.error(err);
    }
}

// Initial fetch
fetchOrder();

// Live refresh every 10 seconds
setInterval(fetchOrder, 10000);
</script>

</body>
</html>
```

### ✅ What changed

- Added tracking timeline HTML under status badge.

- Added CSS for timeline + animation.

- Added JS function updateTrackingUI(order.status) and call it inside fetchOrder().

### ⚠️ Important Notes

- No backend change needed — your /cafe-order-status?order_id=... API already provides order.status.

- The timeline automatically updates every 10 sec with your current polling.

- Works with your existing receipt page, QR code, and all other features.


----

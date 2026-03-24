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


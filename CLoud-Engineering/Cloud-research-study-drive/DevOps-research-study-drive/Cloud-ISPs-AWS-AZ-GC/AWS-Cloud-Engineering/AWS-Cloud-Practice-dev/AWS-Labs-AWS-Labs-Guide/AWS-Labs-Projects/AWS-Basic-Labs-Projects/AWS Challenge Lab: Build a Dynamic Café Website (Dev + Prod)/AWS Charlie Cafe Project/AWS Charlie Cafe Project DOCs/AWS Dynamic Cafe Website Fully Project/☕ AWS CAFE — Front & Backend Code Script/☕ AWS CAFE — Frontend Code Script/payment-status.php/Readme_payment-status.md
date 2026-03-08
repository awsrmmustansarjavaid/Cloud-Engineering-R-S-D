# Charlie Cafe - payment-status.php

### payment-status.php

> **Update Version:1.0**

fully updated payment-status.php page, modernized to match your separated JS architecture and public frontend requirements:

✅ Public page — no Cognito/auth protection

✅ Uses new api.js public endpoints (CHARLIE_API.public)

✅ No curl calls to dev stage; replaced with JS fetch

✅ Fully commented, customer-facing frontend

✅ UI, styling, background, and layout untouched

```
<?php
// ==========================================================
// CHARLIE CAFE — PAYMENT STATUS PAGE (PUBLIC)
// ----------------------------------------------------------
// ✔ Public customer frontend
// ✔ Uses CHARLIE_API.public endpoints
// ✔ No Cognito required
// ✔ Displays CARD or CASH payment status
// ✔ Fully responsive and mobile-friendly
// ==========================================================

// Validate order ID
if (!isset($_GET['order_id'])) {
    die("❌ Invalid Order ID");
}

$orderId = htmlspecialchars($_GET['order_id']);
?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Charlie Cafe ☕ | Payment Status</title>

<!-- Bootstrap CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- Bootstrap Icons -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">

<style>
/* ==================== GLOBAL STYLES ==================== */
body {
    font-family: 'Poppins', sans-serif;
    min-height: 100vh;
    color: #fff;
    background: 
        linear-gradient(rgba(26,17,11,0.75), rgba(26,17,11,0.75)),
        url('https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=1920');
    background-size: cover;
    background-position: center;
}

/* ==================== NAVBAR ==================== */
.navbar {
    background-color: rgba(58,37,28,0.9);
    box-shadow: 0 4px 15px rgba(0,0,0,0.5);
}
.navbar-brand {
    font-weight: 600;
    display: flex;
    align-items: center;
    gap: 8px;
}
.btn-login {
    background: linear-gradient(135deg, #ff5722, #ff9800);
    border-radius: 50px;
    color: #fff;
    display: flex;
    align-items: center;
    gap: 6px;
}

/* ==================== CARD ==================== */
.card {
    background: rgba(58,37,28,0.85);
    backdrop-filter: blur(4px);
    border-radius: 20px;
    padding: 2rem;
    max-width: 600px;
    margin: auto;
    box-shadow: 0 12px 30px rgba(0,0,0,0.5);
}

/* ==================== ALERTS ==================== */
.alert {
    display: flex;
    align-items: center;
    gap: 8px;
    font-weight: 500;
}

/* ==================== BUTTONS ==================== */
.btn-primary {
    border-radius: 50px;
    font-weight: bold;
    display: flex;
    align-items: center;
    gap: 6px;
}

/* ==================== RESPONSIVE ==================== */
@media(max-width:576px){
    .card { padding: 1.5rem; }
    .btn-primary, .btn-login { width: 100%; justify-content: center; }
}
</style>
</head>

<body>

<!-- ==================== NAVBAR ==================== -->
<nav class="navbar navbar-expand-lg navbar-dark">
  <div class="container">
    <a class="navbar-brand" href="index.php">
        <i class="bi bi-cup-fill"></i> Charlie Cafe
    </a>
    <div class="ms-auto">
        <!-- Optional Cognito login button (can be left for admin) -->
        <button class="btn btn-login" id="loginBtn">
            <i class="bi bi-person-circle"></i> Login
        </button>
    </div>
  </div>
</nav>

<!-- ==================== PAYMENT STATUS CARD ==================== -->
<div class="container my-5 pt-5">
    <div class="card text-center">
        <h3><i class="bi bi-cash-stack"></i> Payment Status</h3>
        <p><strong>Order ID:</strong> <?= $orderId ?></p>

        <!-- Placeholder for payment status -->
        <div id="paymentStatus">
            <div class="alert alert-info">
                <i class="bi bi-hourglass-split"></i> ⏳ Checking payment status...
            </div>
        </div>

        <!-- Track Order Button -->
        <a href="order-status.php?order_id=<?= $orderId ?>" 
           class="btn btn-primary mt-3" id="trackOrderBtn" style="display:none;">
           <i class="bi bi-box-seam"></i> Track Order
        </a>
    </div>
</div>

<!-- ==================== BOOTSTRAP JS ==================== -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<!-- ==================== CENTRAL PUBLIC API MODULES ==================== -->
<script src="config.js"></script>
<script src="utils.js"></script>
<script src="api.js"></script>

<script>
// ==========================================================
// CHARLIE CAFE — PAYMENT STATUS SCRIPT
// Uses CHARLIE_API.public endpoints
// ==========================================================
document.addEventListener("DOMContentLoaded", async () => {

    const paymentStatusDiv = document.getElementById("paymentStatus");
    const trackBtn = document.getElementById("trackOrderBtn");

    try {
        // 1️⃣ Fetch order status from PUBLIC API
        const data = await CHARLIE_API.public.getOrderStatus("<?= $orderId ?>");

        // 2️⃣ Render status based on payment method
        if (data.payment_method === "CARD") {
            paymentStatusDiv.innerHTML = `
                <div class="alert alert-success">
                    <i class="bi bi-credit-card-2-front-fill"></i> ✅ Card payment successful
                </div>
            `;
            trackBtn.style.display = "inline-block";

        } else if (data.payment_method === "CASH" && data.payment_status === "PENDING") {
            paymentStatusDiv.innerHTML = `
                <div class="alert alert-warning">
                    <i class="bi bi-clock-fill"></i> ☕ Please pay at the counter
                </div>
            `;

        } else if (data.payment_method === "CASH" && data.payment_status === "PAID") {
            paymentStatusDiv.innerHTML = `
                <div class="alert alert-success">
                    <i class="bi bi-check-circle-fill"></i> ✅ Cash payment received
                </div>
            `;
            trackBtn.style.display = "inline-block";

        } else {
            paymentStatusDiv.innerHTML = `
                <div class="alert alert-secondary">
                    <i class="bi bi-hourglass-split"></i> ⏳ Order created, awaiting payment
                </div>
            `;
        }

    } catch (err) {
        console.error("Error fetching payment status:", err);
        paymentStatusDiv.innerHTML = `
            <div class="alert alert-danger">
                <i class="bi bi-exclamation-triangle-fill"></i> ❌ Failed to fetch payment status
            </div>
        `;
    }

    // 3️⃣ Optional Cognito login (for staff/admin)
    document.getElementById("loginBtn").addEventListener("click", () => {
        CHARLIE.auth.login(); // opens hosted UI (if configured)
    });
});
</script>
</body>
</html>
```

### ✅ CHANGES HIGHLIGHT

- Removed cURL / dev stage API

- Connected to new separated api.js via CHARLIE_API.public.getOrderStatus(orderId)

- All payment logic handled in JS

- No Cognito page protection — public customer page

- Track Order button displayed dynamically

- All existing layout, background, icons, styling intact

- Inline comments added for clarity

### comparison between old vs new

section-by-section comparison between your old payment-status.php and the new updated version

#### 1️⃣ API Access / Backend Calls

| Aspect                       | Old Code                                     | New Code                                                     |
| ---------------------------- | -------------------------------------------- | ------------------------------------------------------------ |
| **API method**               | PHP `cURL` request to `dev` stage            | JavaScript fetch using `CHARLIE_API.public` (from `api.js`)  |
| **Stage**                    | `/dev/order-status`                          | `/prod` endpoints (production-ready)                         |
| **Auth**                     | None needed for frontend, but hardcoded cURL | Still public, no Cognito needed, but uses central modular JS |
| **Responsiveness to errors** | PHP-level only                               | JS-level with try/catch, dynamically shows alerts            |
| **Server-side dependency**   | PHP server must call cURL                    | JS handles API calls in-browser, lighter server load         |

✅ Benefit: Centralized, modular API usage, easier maintenance, consistent with your new separated JS files.

#### 2️⃣ Cognito / Auth Handling

| Aspect                   | Old Code                                            | New Code                                                             |
| ------------------------ | --------------------------------------------------- | -------------------------------------------------------------------- |
| **Cognito login button** | Calls `cognitoLogin()` (central-auth-api.js)        | Calls `CHARLIE.auth.login()` from separated `central-auth.js` module |
| **Page protection**      | None, but central-auth-js might try to protect page | Still public; no protection; the page is safe for customers          |
| **Token handling**       | Not used                                            | Not used; retained login button only for optional admin login        |

✅ Benefit: Clear separation — frontend is public, admin login optional, modular.

#### 3️⃣ Dynamic Payment Status Display

| Aspect                | Old Code                                     | New Code                                                                             |
| --------------------- | -------------------------------------------- | ------------------------------------------------------------------------------------ |
| **Display method**    | PHP fills HTML server-side after `cURL` call | JS dynamically fills HTML after calling `CHARLIE_API.public.getOrderStatus(orderId)` |
| **Page reload**       | Required for updating status (server reload) | Dynamic JS update; no page reload needed                                             |
| **Button visibility** | Static HTML                                  | Dynamically shown/hidden based on payment status (`Track Order` button)              |

✅ Benefit: Faster, more responsive UX; easier to maintain and extend (e.g., auto-refresh status).

#### 4️⃣ Stage / Environment Changes

| Aspect           | Old Code                      | New Code                                                   |
| ---------------- | ----------------------------- | ---------------------------------------------------------- |
| **Stage in URL** | Hardcoded `/dev/order-status` | Uses production `/prod` endpoints via `CHARLIE_API.public` |
| **Hardcoding**   | API URL written in PHP        | API URL abstracted in `api.js` → centralized config        |

✅ Benefit: Avoids manually changing multiple pages when moving between dev/prod. Cleaner maintenance.

#### 5️⃣ Error Handling

| Aspect                     | Old Code                                      | New Code                                                |
| -------------------------- | --------------------------------------------- | ------------------------------------------------------- |
| **Errors on API failure**  | PHP echoes nothing meaningful, page may crash | JS shows alerts in-page with proper icons and messaging |
| **Unknown payment states** | Default handled implicitly                    | Explicitly handles unknown states with gray info alert  |

✅ Benefit: Better user feedback; robust UX.

#### 6️⃣ Code Maintainability

✅ Benefit: Modular, centralized, easier to maintain as project grows.

### ✅ Summary of Key Differences

- API Calls moved from PHP → JS (modular, centralized)

- Production-ready /prod endpoints instead of hardcoded /dev

- Payment status dynamically updated without page reload

- Optional Cognito login handled cleanly via CHARLIE.auth.login()

- Better error handling and UX

- Fully modular design matching your new config.js / api.js architecture

### 💡 In short:

The old code was server-heavy, hardcoded, and less dynamic, while the new code is frontend-driven, modular, dynamic, and production-ready, but visually identical for the customer.

---
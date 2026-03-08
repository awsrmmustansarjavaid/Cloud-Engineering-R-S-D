# Charlie Cafe - Advance Web Features


### 1️⃣ Central JS File for All Toasts
> **(One file → used by Dashboard, Analytics, Order Status)**


#### 🎯 Problem Today

- Toast logic is duplicated in every HTML file

- Hard to maintain

- Not scalable

#### ✅ Solution

Create ONE reusable JS file:

```
/assets/js/toasts.js
```

#### ✅ Step 1: Create toasts.js

```
/* =====================================================
   GLOBAL TOAST UTILITY (USED ACROSS DASHBOARD)
   ===================================================== */

/**
 * Show a toast only once per day
 * @param {string} toastId - HTML element ID
 * @param {string} storageKey - localStorage key
 * @param {number} delay - auto close delay
 */
function showToastOncePerDay(toastId, storageKey, delay = 2500) {
    const today = new Date().toISOString().split("T")[0];
    const lastShown = localStorage.getItem(storageKey);

    if (lastShown !== today) {
        const toastEl = document.getElementById(toastId);
        if (toastEl) {
            new bootstrap.Toast(toastEl, { delay }).show();
            localStorage.setItem(storageKey, today);
        }
    }
}

/**
 * Show toast immediately (used after API success)
 */
function showToast(toastId) {
    const toastEl = document.getElementById(toastId);
    if (toastEl) {
        new bootstrap.Toast(toastEl).show();
    }
}
```

#### ✅ Step 2: Include it in ALL pages

At the bottom of each HTML file:

```
<script src="assets/js/toasts.js"></script>
```

#### ✅ Step 3: Use it Anywhere

Example: Dashboard

```
document.addEventListener("DOMContentLoaded", () => {
    showToastOncePerDay("dashboardWelcomeToast", "dashboardWelcome");
});
```

Example: Analytics (after data load)

```
showToast("dataToast");
```

#### 📌 Result:

✔ Clean

✔ Reusable

✔ Professional

### 2️⃣ Role-Based Sidebar (Admin / Staff)

#### 🎯 Goal

- Admin sees Analytics, Settings

- Staff sees Orders only

- Same HTML → different menus

#### ✅ Step 1: Define User Role (TEMP – Later Cognito)

For now, simulate role:

```
// Later this comes from Cognito token
const USER_ROLE = "ADMIN"; // or "STAFF"
```

#### ✅ Step 2: Sidebar HTML (Role Tags)

```
<a href="dashboard.html" data-role="ADMIN,STAFF">🏠 Dashboard</a>
<a href="order-status.html" data-role="ADMIN,STAFF">📦 Orders</a>
<a href="analytics.html" data-role="ADMIN">📈 Analytics</a>
<a href="settings.html" data-role="ADMIN">⚙ Settings</a>
```

#### ✅ Step 3: Role Filter Script

Create:

```
/assets/js/roles.js
```

```
function applyRoleBasedSidebar(role) {
    document.querySelectorAll("[data-role]").forEach(link => {
        const allowedRoles = link.dataset.role.split(",");
        if (!allowedRoles.includes(role)) {
            link.style.display = "none";
        }
    });
}
```

#### ✅ Step 4: Activate It

```
applyRoleBasedSidebar(USER_ROLE);
```

#### 📌 Result:
✔ One sidebar

✔ Multiple roles

✔ Cognito-ready

### 3️⃣ Notification Center (Bell Icon 🔔)

This is HUGE in real dashboards.

#### 🎯 What We’ll Build

- 🔔 Bell icon

- Badge counter

- Dropdown notifications

- Connected to API later

#### ✅ Step 1: Bell Icon (Header)

```
<div class="dropdown">
  <i class="bi bi-bell fs-4 dropdown-toggle"
     data-bs-toggle="dropdown"
     style="cursor:pointer">
     <span class="badge bg-danger" id="notifCount">2</span>
  </i>

  <ul class="dropdown-menu dropdown-menu-end">
    <li class="dropdown-header">Notifications</li>
    <li><a class="dropdown-item">🆕 New Order Received</a></li>
    <li><a class="dropdown-item">💳 Payment Completed</a></li>
  </ul>
</div>
```

#### ✅ Step 2: Central Notification JS

Create:

```
/assets/js/notifications.js
```

```
const notifications = [
    "🆕 New order placed",
    "💳 Payment completed"
];

function loadNotifications() {
    const menu = document.querySelector(".dropdown-menu");
    const count = document.getElementById("notifCount");

    menu.innerHTML = `<li class="dropdown-header">Notifications</li>`;
    notifications.forEach(n => {
        menu.innerHTML += `<li><a class="dropdown-item">${n}</a></li>`;
    });

    count.innerText = notifications.length;
}
```

#### ✅ Step 3: Call It

```
loadNotifications();
```

#### 📌 Later (Advanced):

- Connect to /notifications API

- Poll every 30s

- Mark as read

- Push via WebSocket

### 🧠 ARCHITECTURE SUMMARY (IMPORTANT)

```
assets/
 ├── js/
 │   ├── toasts.js        ← all toast logic
 │   ├── roles.js         ← role-based UI
 │   ├── notifications.js← bell center
```

Your HTML files become:

Smaller

Cleaner

Professional

#### 🚀 What You’ve Just Reached

You are now building:

✅ SaaS dashboards

✅ Admin panels

✅ Cloud-ready UIs

✅ Cognito-ready architecture



### Solution: Create a single secure-dashboard.js file

#### This JS file will handle:

- Hiding the page until authentication succeeds.

- Loading and using auth.js.

- Running protectPage().

- Providing a secure API call helper (authFetch()).

- Adding a secure logout button functionality (cognitoLogout()).

- Logging and placeholder for dynamic KPI updates.

- All comments explaining why each part exists.

#### Then, in your new dashboard HTML, you only need:

```
<div id="secure-dashboard"></div>
<script src="secure-dashboard.js"></script>
```

…and it will automatically handle everything.

Example secure-dashboard.js

```
/* =================================================
   SECURE DASHBOARD MODULE
   =================================================
   This JS file packages:
   ✅ Page hidden until auth success
   ✅ auth.js loaded
   ✅ protectPage() applied
   ✅ Secure API call placeholder
   ✅ Cognito-ready logout()
   ✅ Comments explaining each step
================================================= */

(function() {
    // ================== PAGE HIDDEN INITIALLY ==================
    document.body.style.display = "none"; // Hide until auth

    // ================== LOAD AUTH.JS ==================
    const authScript = document.createElement('script');
    authScript.src = 'assets/auth.js'; // Make sure path is correct
    authScript.onload = () => initSecureDashboard();
    document.head.appendChild(authScript);

    // ================== INIT FUNCTION ==================
    function initSecureDashboard() {
        // Protect the page
        protectPage();

        // Show body only after auth success
        document.body.style.display = "block";

        // Example secure API call placeholder
        const API_URL = "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/dashboard";
        authFetch(API_URL)
            .then(res => res.json())
            .then(data => {
                console.log("Secure dashboard data:", data);
                // TODO: update KPI cards dynamically
            })
            .catch(err => console.error("API error:", err));

        // Attach logout functionality to all buttons with class .logout-btn
        document.querySelectorAll('.logout-btn').forEach(btn => {
            btn.addEventListener('click', () => cognitoLogout());
        });
    }

})();
```

### How to use in your new HTML

#### Add a logout button wherever you want:

```
<button class="logout-btn">Logout</button>
```

#### Include the script:

```
<script src="secure-dashboard.js"></script>
```

#### Optional: Wrap your dashboard in a <div> if you want:

```
<div id="dashboard-container">
   <!-- All dashboard content -->
</div>
```

No other changes needed. ✅

#### ✅ Benefits

- Only one JS file to maintain auth logic.

- Can be reused across multiple dashboard pages.

- Keeps your new dashboard clean.

- Automatically shows/hides page based on Cognito auth.

- Secure API call placeholders included.

- Logout works anywhere you add .logout-btn.

✅ Keep your existing dashboard.html mostly untouched

✅ Add ONE reusable security layer

✅ Use one JS file (secure-dashboard.js)

✅ No copy-pasting auth logic everywhere

✅ Cognito-ready

### ✅ WHAT YOU WILL ADD (SUMMARY)

You will add ONLY 3 SMALL THINGS to dashboard.html:

- Wrap your dashboard UI inside ONE container

- Mark logout button with a class

- Include secure-dashboard.js at the bottom

That’s it. No other refactoring.

### 1️⃣ Wrap your dashboard UI (ONE DIV ONLY)

#### 🔧 Why?

So secure-dashboard.js can:

- Hide everything until auth succeeds

- Show everything after protectPage() passes

#### ✅ Change this:

```
<body>
```

#### ✅ To this (ADD COMMENT):

```
<body>

<!-- 🔐 SECURE DASHBOARD WRAPPER
     Everything inside this div will:
     - stay hidden until Cognito auth passes
     - automatically show after protectPage() -->
<div id="dashboard-container">
```

#### ✅ Then CLOSE it just before </body>

```
</div> <!-- 🔐 END secure dashboard container -->
```

**✅ Nothing else inside needs to change**

### 2️⃣ Mark Logout Button (NO LOGIC CHANGE)

You already have this:

```
<a onclick="logout()" style="cursor:pointer">
    <i class="bi bi-box-arrow-left"></i> Logout
</a>
```

#### 🔧 Change it to THIS (only class added + comment):

```
<!-- 🔐 Secure logout
     secure-dashboard.js will automatically attach Cognito logout -->
<a class="logout-btn" style="cursor:pointer">
    <i class="bi bi-box-arrow-left"></i> Logout
</a>
```

🚫 Remove onclick="logout()"

✅ Logout will now be centrally managed

### 3️⃣ Add Secure Loader (ONE SCRIPT)

Scroll to the VERY BOTTOM, just before </body>

#### ✅ ADD THIS (with comments):

```
<!-- =================================================
     🔐 CENTRAL AUTH & SECURITY LAYER
     This single file enables:
     ✅ Page hidden until auth success
     ✅ auth.js auto-loaded
     ✅ protectPage() applied
     ✅ Secure API access (authFetch)
     ✅ Cognito-ready logout
================================================= -->
<script src="secure-dashboard.js"></script>
```

🚫 Do NOT load auth.js directly anymore

🚫 Do NOT call protectPage() manually

### 4️⃣ Remove Old Fake Logout (IMPORTANT)

You currently have:

```
<script>
function logout() {
    alert("Logout (Cognito coming soon)");
}
</script>
```

#### ❌ DELETE THIS SCRIPT COMPLETELY

Because:

- secure-dashboard.js handles logout

- Cognito logout will replace alerts

- Prevents duplicate logic

### ✅ FINAL RESULT (MENTAL MODEL)

After this setup:


| Feature                        | Where it lives          |
| ------------------------------ | ----------------------- |
| Page hidden before login       | `secure-dashboard.js`   |
| Cognito auth check             | `secure-dashboard.js`   |
| JWT handling                   | `auth.js` (auto-loaded) |
| Secure API calls               | `authFetch()`           |
| Logout                         | `.logout-btn`           |
| Dashboard UI                   | `dashboard.html`        |
| Roles / toasts / notifications | unchanged               |


### 🧠 WHY THIS ARCHITECTURE IS PROFESSIONAL

You are now using:

- Separation of concerns

- Reusable security layer

- Production-grade pattern (used in real SaaS dashboards)

You can now protect:

- dashboard.html

- analytics.html

- orders.html

By adding ONLY THIS:

```
<div id="dashboard-container">
<script src="secure-dashboard.js"></script>
```


# Charlie CaFe - central-auth-api

- Public API (no Cognito)

- Protected API (Cognito authorizer)

- PHP for public

- Frontend JS for protected

- One prod stage

- Route-based separation

### 🏗 FINAL ARCHITECTURE STRUCTURE

```
/js
 ├── config.js
 ├── utils.js
 ├── central-auth.js
 ├── api.js
 ├── central-printing.js   ✅ NEW
```

#### Public pages:

- Use: config.js + api.js

- DO NOT load central-auth.js

#### Protected pages:

- Use: config.js + utils.js + central-auth.js + api.js

### 🔥 STEP 1 — config.js (NO LOGIC HERE)

This replaces hardcoded config from your old file.

```
/* =========================================================
   CONFIGURATION FILE
   Never hardcode values inside logic files
========================================================= */

export const CONFIG = {

    // AWS Region
    REGION: "us-east-1",

    // Cognito
    USER_POOL_ID: "us-east-1_oeMWJar3T",
    CLIENT_ID: "42haggs0jctmq5rnaajfi3hmqu",
    COGNITO_DOMAIN: "us-east-1oemwjar3t.auth.us-east-1.amazoncognito.com",

    // API Gateway (Single prod stage)
    API_BASE: "https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/prod",

    // CloudFront
    CLOUDFRONT_BASE: "https://d163j9zwndcxgl.cloudfront.net"
};
```

✔ No functions

✔ Only configuration

✔ Used by all files

### 🔥 STEP 2 — utils.js (Shared Helpers)

Move all generic helpers here.

```
/* =========================================================
   SHARED UTILITIES
========================================================= */

export function parseJwt(token) {
    try {
        return JSON.parse(atob(token.split(".")[1]));
    } catch {
        return {};
    }
}

export function isTokenExpired(token) {
    try {
        return parseJwt(token).exp * 1000 < Date.now();
    } catch {
        return true;
    }
}

export function formatCurrency(amount) {
    return "$" + Number(amount).toFixed(2);
}
```

### 🔐 STEP 3 — central-auth.js (COGNITO ONLY)

This file contains ONLY authentication logic.

No API routes inside.

```
/* =========================================================
   CENTRAL AUTH MODULE
   Handles ONLY Cognito authentication
========================================================= */

import { CONFIG } from "./config.js";
import { parseJwt, isTokenExpired } from "./utils.js";

const TOKEN_KEY = "access_token";

/* ===============================
   TOKEN HELPERS
================================= */

function getToken() {
    return localStorage.getItem(TOKEN_KEY);
}

function saveToken(token) {
    localStorage.setItem(TOKEN_KEY, token);
}

function clearToken() {
    localStorage.removeItem(TOKEN_KEY);
}

/* ===============================
   LOGIN
================================= */

function login() {

    const redirectUrl = `${CONFIG.CLOUDFRONT_BASE}/login.html`;

    const url =
        `https://${CONFIG.COGNITO_DOMAIN}/login` +
        `?response_type=token` +
        `&client_id=${CONFIG.CLIENT_ID}` +
        `&scope=openid+email+profile` +
        `&redirect_uri=${encodeURIComponent(redirectUrl)}`;

    window.location.href = url;
}

/* ===============================
   LOGOUT
================================= */

function logout() {

    clearToken();

    const redirectUrl = `${CONFIG.CLOUDFRONT_BASE}/logout.html`;

    const url =
        `https://${CONFIG.COGNITO_DOMAIN}/logout` +
        `?client_id=${CONFIG.CLIENT_ID}` +
        `&logout_uri=${encodeURIComponent(redirectUrl)}`;

    window.location.href = url;
}

/* ===============================
   HANDLE REDIRECT
================================= */

function handleRedirect() {

    if (!window.location.hash) return;

    const params = new URLSearchParams(window.location.hash.substring(1));
    const token = params.get("access_token");

    if (token) {
        saveToken(token);
        window.location.hash = "";
    }
}

/* ===============================
   PAGE PROTECTION
================================= */

function protectPage() {

    handleRedirect();

    const token = getToken();

    if (!token || isTokenExpired(token)) {
        login();
        return;
    }

    document.body.style.display = "block";
}

/* ===============================
   ROLE HANDLING
================================= */

function getUserRoles() {

    const token = getToken();
    if (!token) return [];

    const payload = parseJwt(token);
    const groups = payload["cognito:groups"] || [];

    return Array.isArray(groups)
        ? groups.map(g => g.toLowerCase())
        : [String(groups).toLowerCase()];
}

function requireRole(allowedRoles) {

    const roles = getUserRoles();

    const allowed = allowedRoles.some(role =>
        roles.includes(role.toLowerCase())
    );

    if (!allowed) {
        alert("Access denied");
        logout();
        throw new Error("Unauthorized role");
    }
}

/* ===============================
   AUTO LOGOUT WATCHER
================================= */

function startAutoLogoutWatcher() {

    setInterval(() => {

        const token = getToken();
        if (!token) return;

        if (isTokenExpired(token)) {
            alert("Session expired");
            logout();
        }

    }, 30000);
}

/* ===============================
   EXPORT
================================= */

export const Auth = {
    login,
    logout,
    protectPage,
    getToken,
    requireRole,
    startAutoLogoutWatcher
};
```

### 🌐 STEP 4 — api.js (PUBLIC + PROTECTED FETCH)

This file handles API logic only.

```
/* =========================================================
   API MODULE
   Handles ONLY API requests
========================================================= */

import { CONFIG } from "./config.js";
import { Auth } from "./central-auth.js";

/* ===============================
   PUBLIC FETCH (No token)
================================= */

export async function publicFetch(path, options = {}) {

    return fetch(`${CONFIG.API_BASE}${path}`, {
        method: options.method || "GET",
        headers: {
            "Content-Type": "application/json",
            ...(options.headers || {})
        },
        ...options
    });
}

/* ===============================
   PROTECTED FETCH
================================= */

export async function protectedFetch(path, options = {}) {

    const token = Auth.getToken();

    if (!token) {
        Auth.logout();
        return;
    }

    return fetch(`${CONFIG.API_BASE}${path}`, {
        method: options.method || "GET",
        headers: {
            Authorization: "Bearer " + token,
            "Content-Type": "application/json",
            ...(options.headers || {})
        },
        ...options
    });
}
```

### 📌 HOW FILES ARE USED
Public page example:

```
<script type="module">
import { publicFetch } from "./js/api.js";

publicFetch("/public/orders", {
    method: "POST",
    body: JSON.stringify({ item: "Coffee" })
});
</script>
```

No Cognito loaded.

### 📌 Protected page example:

```
<script type="module">
import { Auth } from "./js/central-auth.js";
import { protectedFetch } from "./js/api.js";

Auth.protectPage();
Auth.startAutoLogoutWatcher();
Auth.requireRole(["Admin"]);

protectedFetch("/admin/dashboard")
    .then(res => res.json())
    .then(console.log);
</script>
```

### 🎯 DO YOU NEED TWO central-auth.js FILES?

❌ No.

Only protected pages load central-auth.js.

Public pages do not include it.

So architecture stays clean.

### 🏆 FINAL RESULT

You now have:

- Public API → used by PHP or public pages

- Protected API → Cognito authorizer

- Clean separation

- No mixed responsibilities

- No hardcoded config

- Role-based protection

- Production-grade structure

### 🌐 STEP 5 — 
✔ Handles PDF / CSV download
✔ Works with protectedFetch
✔ No Cognito logic inside
✔ No hardcoded config

Clean. Modular. Production-ready.

📁 FINAL FILE STRUCTURE (UPDATED)

```
/js
 ├── config.js
 ├── utils.js
 ├── central-auth.js
 ├── api.js
 ├── central-printing.js   ✅ NEW
```

### 🖨 central-printing.js (FULL VERSION)

```
/* =========================================================
   CENTRAL PRINTING MODULE
   Handles:
   ✔ Browser printing
   ✔ CSV export
   ✔ PDF export
   ✔ Protected downloads
   ✔ Public downloads
========================================================= */

import { protectedFetch, publicFetch } from "./api.js";
import { formatCurrency } from "./utils.js";

/* =====================================================
   1️⃣ BROWSER PRINT FUNCTIONS
===================================================== */

/**
 * Print entire current page
 */
export function printPage() {
    window.print();
}

/**
 * Print daily summary from table
 * Table rows must contain:
 *   data-date
 *   data-total
 */
export function printTodaySummary(tableSelector = "#ordersTable") {

    const table = document.querySelector(`${tableSelector} tbody`);
    if (!table) {
        alert("Orders table not found");
        return;
    }

    const today = new Date().toISOString().split("T")[0];
    let totalOrders = 0;
    let totalSales = 0;

    table.querySelectorAll("tr").forEach(row => {

        const orderDate = row.dataset.date;
        const amount = parseFloat(row.dataset.total || 0);

        if (orderDate === today) {
            totalOrders++;
            totalSales += amount;
        }
    });

    const summaryHTML = `
        <div style="padding:20px">
            <h2>Charlie Cafe — Daily Summary</h2>
            <hr>
            <p><strong>Date:</strong> ${today}</p>
            <p><strong>Total Orders:</strong> ${totalOrders}</p>
            <p><strong>Total Sales:</strong> ${formatCurrency(totalSales)}</p>
        </div>
    `;

    const original = document.body.innerHTML;
    document.body.innerHTML = summaryHTML;
    window.print();
    document.body.innerHTML = original;
    location.reload();
}

/* =====================================================
   2️⃣ FILE DOWNLOAD HELPER
===================================================== */

async function downloadBlob(response, filename) {

    if (!response || !response.ok) {
        alert("Download failed");
        return;
    }

    const blob = await response.blob();

    const link = document.createElement("a");
    link.href = URL.createObjectURL(blob);
    link.download = filename;

    document.body.appendChild(link);
    link.click();

    URL.revokeObjectURL(link.href);
    document.body.removeChild(link);
}

/* =====================================================
   3️⃣ PROTECTED EXPORT (Admin / Employee)
===================================================== */

/**
 * Export protected report (PDF or CSV)
 * Example:
 *   /admin/export?type=pdf
 */
export async function exportProtectedReport(path, filename) {

    const response = await protectedFetch(path, {
        method: "GET"
    });

    await downloadBlob(response, filename);
}

/* =====================================================
   4️⃣ PUBLIC EXPORT (No Cognito)
===================================================== */

/**
 * Export public report
 * Example:
 *   /public/invoice?order_id=123
 */
export async function exportPublicReport(path, filename) {

    const response = await publicFetch(path, {
        method: "GET"
    });

    await downloadBlob(response, filename);
}

/* =====================================================
   5️⃣ CSV FROM TABLE (Client-Side)
===================================================== */

export function exportTableToCSV(tableSelector, filename = "export.csv") {

    const table = document.querySelector(tableSelector);
    if (!table) {
        alert("Table not found");
        return;
    }

    let csv = [];

    const rows = table.querySelectorAll("tr");

    rows.forEach(row => {
        const cols = row.querySelectorAll("th, td");
        const rowData = [];

        cols.forEach(col => {
            rowData.push(`"${col.innerText.replace(/"/g, '""')}"`);
        });

        csv.push(rowData.join(","));
    });

    const blob = new Blob([csv.join("\n")], {
        type: "text/csv"
    });

    const link = document.createElement("a");
    link.href = URL.createObjectURL(blob);
    link.download = filename;

    document.body.appendChild(link);
    link.click();

    document.body.removeChild(link);
}
```

### 🔥 HOW TO USE central-printing.js

#### ✅ Protected Admin Export Example

```
<script type="module">
import { Auth } from "./js/central-auth.js";
import { exportProtectedReport } from "./js/central-printing.js";

Auth.protectPage();
Auth.requireRole(["Admin"]);

document.getElementById("exportPdfBtn")
    .addEventListener("click", () => {

        exportProtectedReport(
            "/admin/export?type=pdf",
            "admin-report.pdf"
        );
    });
</script>
```

#### ✅ Public Invoice Download Example

```
<script type="module">
import { exportPublicReport } from "./js/central-printing.js";

document.getElementById("downloadInvoice")
    .addEventListener("click", () => {

        exportPublicReport(
            "/public/invoice?order_id=123",
            "invoice-123.pdf"
        );
    });
</script>
```

#### ✅ Client-Side CSV Export

```
import { exportTableToCSV } from "./js/central-printing.js";

exportTableToCSV("#ordersTable", "orders.csv");
```

### 🏆 WHY THIS IS CORRECT ARCHITECTURE

| File                | Responsibility         |
| ------------------- | ---------------------- |
| config.js           | Config only            |
| utils.js            | Shared helpers         |
| central-auth.js     | Cognito only           |
| api.js              | API calls only         |
| central-printing.js | Printing + Export only |


No mixing.
No circular dependencies.
No hardcoded logic inside auth.

### 🚀 PRODUCTION BENEFITS

✔ Public and protected completely separated
✔ No Cognito loaded on public pages
✔ Easy to test
✔ Easy to scale
✔ Easy to maintain
✔ Clean for real SaaS

### 🖨 What central-printing.js Actually Means (In Plain English)

If someone clicks:

"Download Invoice"

This file handles it.

If someone clicks:

"Export Admin Report"

This file handles it.

If someone clicks:

"Print Today Summary"

This file handles it.

That’s all.

### 🔐 Example (Super Simple)

#### Public page (no login required)

Only load:

```
import { exportPublicReport } from "./js/central-printing.js";
```

Done.

No Cognito.
No auth.

#### Protected admin page

Load:

```
import { Auth } from "./js/central-auth.js";
import { exportProtectedReport } from "./js/central-printing.js";
```

Then:

```
Auth.protectPage();
Auth.requireRole(["Admin"]);
```

That’s it.

### 🎯 The Rule You Must Remember

Every file answers one question:

| File                | Question it answers                |
| ------------------- | ---------------------------------- |
| config.js           | What are my settings?              |
| utils.js            | What small helper tools do I have? |
| central-auth.js     | Who is the user?                   |
| api.js              | How do I call backend?             |
| central-printing.js | How do I print or download files?  |

If a file answers more than one question → wrong design.


---



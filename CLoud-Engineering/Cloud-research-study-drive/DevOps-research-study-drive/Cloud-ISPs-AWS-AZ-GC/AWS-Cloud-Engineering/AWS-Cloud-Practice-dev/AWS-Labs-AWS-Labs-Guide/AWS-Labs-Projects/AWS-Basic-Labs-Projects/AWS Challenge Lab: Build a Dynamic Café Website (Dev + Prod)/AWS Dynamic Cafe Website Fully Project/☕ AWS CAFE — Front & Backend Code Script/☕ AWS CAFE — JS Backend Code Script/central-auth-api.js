/* =========================================================
   CHARLIE CAFE — CENTRAL AUTH + API CONFIG (STABLE FINAL)
   ---------------------------------------------------------
   ✔ Cognito Hosted UI Login / Logout
   ✔ Token Handling (Access Token)
   ✔ Page Protection (No White Screen)
   ✔ Central Logout Button
   ✔ Role-Based Access Control (Admin / Employee)
   ✔ Secure API Gateway Calls
   ✔ Auto Logout on Token Expiry
   ✔ All API Gateway Endpoints Preserved
========================================================= */

const CHARLIE = (() => {

    /* =====================================================
       1️⃣ GLOBAL CONFIG
    ===================================================== */
    const CONFIG = {
        REGION: "us-east-1",

        // Cognito
        USER_POOL_ID: "us-east-1_HDcwDJqVz",
        CLIENT_ID: "3hcigucn7fmd11gvo9uuqud6fi",
        COGNITO_DOMAIN: "us-east-1hdcwdjqvz.auth.us-east-1.amazonaws.com",

        // API Gateway
        API_BASE: "https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com",

        // CloudFront
        CLOUDFRONT_BASE: "https://d159bqc5pw64hn.cloudfront.net"
    };

    /* =====================================================
       2️⃣ TOKEN HELPERS (SAFE)
    ===================================================== */
    function parseJwt(token) {
    try {
        return JSON.parse(atob(token.split(".")[1]));
    } catch (e) {
        return {};
    }
}

    function isTokenExpired(token) {
        try {
            return parseJwt(token).exp * 1000 < Date.now();
        } catch {
            return true;
        }
    }

    function getToken() {
        return localStorage.getItem("access_token");
    }

    /* =====================================================
       3️⃣ AUTH MODULE (No White Screen, Safe Redirect)
    ===================================================== */
    const auth = {

        login(redirectUrl = `${CONFIG.CLOUDFRONT_BASE}/cafe-admin-dashboard.html`) {
            const url =
                `https://${CONFIG.COGNITO_DOMAIN}/login` +
                `?response_type=token` +
                `&client_id=${CONFIG.CLIENT_ID}` +
                `&scope=openid+email+profile` +
                `&redirect_uri=${encodeURIComponent(redirectUrl)}`;
            window.location.href = url;
        },

        logout(redirectUrl = `${CONFIG.CLOUDFRONT_BASE}/index.html`) {
            localStorage.removeItem("access_token");
            const url =
                `https://${CONFIG.COGNITO_DOMAIN}/logout` +
                `?client_id=${CONFIG.CLIENT_ID}` +
                `&logout_uri=${encodeURIComponent(redirectUrl)}`;
            window.location.href = url;
        },

        /* Handle redirect after Cognito login */
        handleRedirect() {
            if (!window.location.hash) return;
            const params = new URLSearchParams(window.location.hash.substring(1));
            const token = params.get("access_token");
            if (token) {
                localStorage.setItem("access_token", token);
                window.location.hash = "";
            }
        },

        /* Protect page — only shows content if logged in */
        protectPage() {
            this.handleRedirect();
            const token = getToken();
            if (!token || isTokenExpired(token)) {
                this.login();
                return;
            }
            // Show content after auth passes
            document.body.style.display = "block";
        },

        /* Setup logout button with optional redirect */
```````setupLogoutButton(buttonId = "logoutBtn", redirectUrl = "dashboard-login.html") {
    ```const btn = document.getElementById(buttonId);
    ```if (!btn) return;
    ```btn.addEventListener("click", () => this.logout(redirectUrl));
```````}
    };

    /* =====================================================
       4️⃣ AUTH FETCH (BASE)
       ✔ JWT attached
       ✔ DOES NOT force Content-Type (important for PDF/CSV)
    ===================================================== */
    async function authFetch(url, options = {}) {
        const token = getToken();
        if (!token || isTokenExpired(token)) {
            auth.logout();
            return;
        }

        const headers = {
            Authorization: "Bearer " + token,
            ...(options.headers || {})
        };

        return fetch(url, {
            method: options.method || "GET",
            ...options,
            headers
        });
    }

    /* =====================================================
       4️⃣1️⃣ SECURE FETCH (JSON ONLY)
       ⚠ NEVER use this for file downloads
    ===================================================== */
    async function secureFetch(url, options = {}) {
        const res = await authFetch(url, options);
        if (!res) return;

        // Safety: ensure JSON response
        const contentType = res.headers.get("content-type") || "";
        if (!contentType.includes("application/json")) {
            throw new Error("secureFetch received non-JSON response");
        }

        return res.json();
    }

    /* =====================================================
       4️⃣2️⃣ FILE EXPORT (PDF / CSV)
    ===================================================== */
    async function downloadReport(type, report = "") {

        let url = `${CONFIG.API_BASE}/reports/export?type=${type}`;
        if (report) url += `&report=${report}`;

        const response = await authFetch(url, { method: "GET" });

        if (!response || !response.ok) {
            alert("❌ Failed to download report");
            return;
        }

        const filename = report ? `${report}.${type}` : `export.${type}`;
        const blob = await response.blob();

        const a = document.createElement("a");
        a.href = URL.createObjectURL(blob);
        a.download = filename;
        document.body.appendChild(a);
        a.click();

        URL.revokeObjectURL(a.href);
        document.body.removeChild(a);
    }

    /* =====================================================
       5️⃣ ROLE & ACCESS CONTROL
    ===================================================== */
    function getUserRoles() {
        const token = getToken();
        if (!token) return [];
        const payload = parseJwt(token);
        const groups = payload["cognito:groups"] || [];
        return Array.isArray(groups)
            ? groups.map(r => r.toLowerCase())
            : [String(groups).toLowerCase()];
    }

    function isAdmin() {
        return getUserRoles().includes("admin");
    }

    function isEmployee() {
        return getUserRoles().includes("employee");
    }

    function requireAdmin() {
        if (!isAdmin()) {
            alert("❌ Admin access only");
            auth.logout();
            throw new Error("Admin access required");
        }
    }

    function requireEmployee() {
        if (!isEmployee() && !isAdmin()) {
            alert("❌ Employee access only");
            auth.logout();
            throw new Error("Employee access required");
        }
    }

    /* =====================================================
       6️⃣ AUTO LOGOUT ON TOKEN EXPIRY
    ===================================================== */
    let logoutTriggered = false;
let logoutWatcherStarted = false;

function startAutoLogoutWatcher() {
    if (logoutWatcherStarted) return;
    logoutWatcherStarted = true;

    setInterval(() => {
        if (logoutTriggered) return;

        const token = getToken();
        if (!token) return;

        if (isTokenExpired(token)) {
            logoutTriggered = true;
            alert("🔐 Session expired");
            auth.logout();
        }
    }, 30000);
}


    /* =====================================================
       7️⃣ API GATEWAY ENDPOINTS (FULL)
    ===================================================== */
      // ⚠️ NOTE:
// This project intentionally mixes /dev and non-stage endpoints.
// Ensure API Gateway stage mapping & CloudFront behaviors are aligned.

    const api = {

        placeOrder(payload) {
    return secureFetch(`${CONFIG.API_BASE}/dev/orders`, {
        method: "POST",
        body: JSON.stringify(payload)
    });
},

        updateOrder(payload) {
            return secureFetch(`${CONFIG.API_BASE}/dev/order-update`, {
                method: "POST",
                body: JSON.stringify(payload)
            });
        },

        getOrderStatus(orderId) {
            return secureFetch(`${CONFIG.API_BASE}/status/order-status?order_id=${encodeURIComponent(orderId)}`);
        },

        getCafeOrderStatus(orderId) {
            return secureFetch(`${CONFIG.API_BASE}/status/cafe-order-status?order_id=${encodeURIComponent(orderId)}`);
        },

        getGetOrderStatus(orderId) {
            return secureFetch(`${CONFIG.API_BASE}/status/get-order-status?order_id=${encodeURIComponent(orderId)}`);
        },

        /* 🧑‍🍳 HR — Employee + Admin */
        recordAttendance(payload) {
            requireEmployee();
            return secureFetch(`${CONFIG.API_BASE}/dev/hr/attendance`, {
                method: "POST",
                body: JSON.stringify(payload)
            });
        },

        getAttendance(employeeId) {
            requireEmployee();
            return secureFetch(`${CONFIG.API_BASE}/dev/hr/attendance?employee_id=${encodeURIComponent(employeeId)}`);
        },

        /* 👨‍💼 HR — Admin Only */
        getAllEmployees() {
            requireAdmin();
            return secureFetch(`${CONFIG.API_BASE}/dev/hr/employees`);
        },

        /* 📊 Admin Attendance Analytics */
        adminAttendance: {
            getDailySummary() {
                requireAdmin();
                return secureFetch(`${CONFIG.API_BASE}/admin/attendance?type=daily`);
            },
            getWeeklySummary() {
                requireAdmin();
                return secureFetch(`${CONFIG.API_BASE}/admin/attendance?type=weekly`);
            },
            getMonthlySummary() {
                requireAdmin();
                return secureFetch(`${CONFIG.API_BASE}/admin/attendance?type=monthly`);
            }
        },

        /* 📈 Admin Dashboard */
        adminDashboard: {
            fetchData(employeeId = "") {
                requireAdmin();
                let url = `${CONFIG.API_BASE}/admin/dashboard`;
                if (employeeId) url += `?employee_id=${employeeId}`;
                return secureFetch(url);
            },
            fetchEmployees() {
                requireAdmin();
                return secureFetch(`${CONFIG.API_BASE}/admin/employees`);
            }
        }
    };

    /* =====================================================
       8️⃣ CLOUDFRONT ASSETS
    ===================================================== */
    const assets = {
        url(path) {
            return `${CONFIG.CLOUDFRONT_BASE}/${path}`;
        }
    };

    /* =====================================================
       9️⃣ PAGE INITIALIZER
    ===================================================== */
    function initProtectedPage(options = {}) {
        const { requireAuth = true, enableLogout = true, logoutButtonId = "logoutBtn" } = options;
        if (requireAuth) auth.protectPage();
        if (enableLogout) auth.setupLogoutButton(logoutButtonId);
        startAutoLogoutWatcher();
    }

    /* =====================================================
       🔟 BROWSER PRINT FUNCTIONS (OPTIONAL)
    ===================================================== */
    window.printAllOrders = function () {
        console.log("🖨️ Printing all orders...");
        window.print();
    };

    window.printTodaySummary = function () {
        const table = document.querySelector("#ordersTable tbody");
        if (!table) return alert("❌ Orders table not found");

        const rows = table.querySelectorAll("tr");
        const today = new Date().toISOString().split("T")[0];
        let totalOrders = 0, totalAmount = 0;

        rows.forEach(row => {
            const orderDate = row.dataset.date;
            const amount = parseFloat(row.dataset.total || 0);
            if (orderDate === today) {
                totalOrders++;
                totalAmount += amount;
            }
        });

        const summaryHTML = `
            <div style="padding:20px">
                <h3 style="text-align:center">☕ Charlie Cafe — Daily Summary</h3>
                <hr>
                <p><strong>Date:</strong> ${today}</p>
                <p><strong>Total Orders:</strong> ${totalOrders}</p>
                <p><strong>Total Sales:</strong> $${totalAmount.toFixed(2)}</p>
            </div>
        `;

        const originalContent = document.body.innerHTML;
        document.body.innerHTML = summaryHTML;
        window.print();
        document.body.innerHTML = originalContent;
        location.reload();
    };

    /* =====================================================
       1️⃣1️⃣ EXPORT MODULE
    ===================================================== */
    return {
        CONFIG,
        auth,
        api,
        assets,
        secureFetch,
        downloadReport,   // ✅ ADD THIS
        initProtectedPage,
        getUserRoles,
        isAdmin,
        isEmployee,
        requireAdmin,
        requireEmployee
    };

})();
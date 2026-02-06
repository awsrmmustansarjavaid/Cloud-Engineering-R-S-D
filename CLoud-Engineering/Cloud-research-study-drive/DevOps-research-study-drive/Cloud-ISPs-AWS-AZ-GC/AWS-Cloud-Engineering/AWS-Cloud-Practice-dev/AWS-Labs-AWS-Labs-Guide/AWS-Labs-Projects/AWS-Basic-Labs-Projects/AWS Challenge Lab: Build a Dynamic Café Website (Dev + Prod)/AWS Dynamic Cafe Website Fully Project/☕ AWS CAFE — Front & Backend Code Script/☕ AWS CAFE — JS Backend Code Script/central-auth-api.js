/* =========================================================
   CHARLIE CAFE — CENTRAL AUTH + API CONFIG (FINAL)
   ---------------------------------------------------------
   ✔ Cognito Hosted UI Login / Logout
   ✔ Token Handling (Access Token)
   ✔ Page Protection (Auto Redirect)
   ✔ Logout Button (Centralized)
   ✔ Role-Based Access (Admin / Employee)
   ✔ Secure API Gateway Calls
   ✔ AUTO LOGOUT ON TOKEN EXPIRY (CENTRALIZED)
   ✔ UNIVERSAL RBAC (CENTRALIZED)
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
        API_BASE: "https://a1053skr51.execute-api.us-east-1.amazonaws.com",

        // CloudFront
        CLOUDFRONT_BASE: "https://d159bqc5pw64hn.cloudfront.net"
    };

    /* =====================================================
       2️⃣ TOKEN HELPERS
    ===================================================== */
    function parseJwt(token) {
        return JSON.parse(atob(token.split(".")[1]));
    }

    function isTokenExpired(token) {
        return parseJwt(token).exp * 1000 < Date.now();
    }

    function getToken() {
        return localStorage.getItem("access_token");
    }

    /* =====================================================
       3️⃣ AUTH MODULE
    ===================================================== */
    const auth = {

        login(
            redirectUrl = `${CONFIG.CLOUDFRONT_BASE}/cafe-admin-dashboard.html`
        ) {
            const url =
                `https://${CONFIG.COGNITO_DOMAIN}/login` +
                `?response_type=token` +
                `&client_id=${CONFIG.CLIENT_ID}` +
                `&scope=openid+email+profile` +
                `&redirect_uri=${encodeURIComponent(redirectUrl)}`;
            window.location.href = url;
        },

        logout(redirectUrl = window.location.origin) {
            localStorage.removeItem("access_token");
            const url =
                `https://${CONFIG.COGNITO_DOMAIN}/logout` +
                `?client_id=${CONFIG.CLIENT_ID}` +
                `&logout_uri=${encodeURIComponent(redirectUrl)}`;
            window.location.href = url;
        },

        handleRedirect() {
            if (!window.location.hash) return;
            const params = new URLSearchParams(window.location.hash.substring(1));
            const token = params.get("access_token");
            if (token) {
                localStorage.setItem("access_token", token);
                window.location.hash = "";
            }
        },

        protectPage() {
            this.handleRedirect();
            const token = getToken();
            if (!token || isTokenExpired(token)) {
                this.login();
                return;
            }
            document.body.style.display = "block";
        },

        setupLogoutButton(buttonId = "logoutBtn", redirectUrl = "index.html") {
            const btn = document.getElementById(buttonId);
            if (!btn) return;
            btn.addEventListener("click", () => {
                this.logout(redirectUrl);
            });
        }
    };

    /* =====================================================
       4️⃣ SECURE FETCH (JWT AUTO ATTACH)
    ===================================================== */
    async function authFetch(url, options = {}) {
        const token = getToken();

        if (!token || isTokenExpired(token)) {
            auth.logout();
            return; // 🔐 intentionally return undefined
        }

        return fetch(url, {
            ...options,
            headers: {
                ...(options.headers || {}),
                Authorization: "Bearer " + token,
                "Content-Type": "application/json"
            }
        });
    }

    // 🔧 FIX #1: Prevent crash when authFetch returns undefined
    async function secureFetch(url, options = {}) {
        const res = await authFetch(url, options);
        if (!res) return; // ✅ prevents `.then()` crash
        return res.json();
    }

    /* =====================================================
       5️⃣ ROLE & ACCESS CONTROL (NORMALIZED + SAFE)
    ===================================================== */
    // 🔧 FIX #2: Harden group extraction (missing / string / array)
    function getUserRoles() {
        const token = getToken();
        if (!token) return [];

        const payload = parseJwt(token);
        const groups = payload["cognito:groups"];

        if (!groups) return [];

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
       🔐 AUTO LOGOUT ON TOKEN EXPIRY (CENTRALIZED)
    ===================================================== */
    let logoutTriggered = false;

    function startAutoLogoutWatcher() {
        setInterval(() => {
            if (logoutTriggered) return;

            const token = getToken();
            if (!token) return;

            try {
                if (isTokenExpired(token)) {
                    logoutTriggered = true;
                    alert("🔐 Session expired");
                    auth.logout();
                }
            } catch {
                logoutTriggered = true;
                auth.logout();
            }
        }, 30000);
    }

    /* =====================================================
       6️⃣ API GATEWAY ENDPOINTS
    ===================================================== */
    const api = {
        /* unchanged */
    };

    /* =====================================================
       7️⃣ CLOUDFRONT ASSETS
    ===================================================== */
    const assets = {
        url(path) {
            return `${CONFIG.CLOUDFRONT_BASE}/${path}`;
        }
    };

    /* =====================================================
       8️⃣ PAGE INITIALIZER (UPDATED)
       🔹 Accepts options for flexible setup
       🔹 Centralizes auth, logout, auto-logout
    ===================================================== */
    function initProtectedPage(options = {}) {
        const {
            requireAuth = true,        // 🔐 protect page by default
            enableLogout = true,       // ✅ setup logout button by default
            logoutButtonId = "logoutBtn" // default logout button
        } = options;

        // Step 1: Protect page if required
        if (requireAuth) {
            auth.protectPage();
        }

        // Step 2: Setup logout button if required
        if (enableLogout) {
            auth.setupLogoutButton(logoutButtonId);
        }

        // Step 3: Start auto logout watcher (centralized)
        startAutoLogoutWatcher();
    }

    /* =====================================================
       9️⃣ 🖨️ CHARLIE CAFE — CENTRAL BROWSER PRINTING SYSTEM
       Used by all admin/staff pages
    ===================================================== */
    window.printAllOrders = function () {
        console.log("🖨️ Printing all orders...");
        window.print();
    };

    window.printTodaySummary = function () {
        console.log("📄 Printing today's summary...");

        const table = document.querySelector("#ordersTable tbody");

        if (!table) {
            alert("❌ Orders table not found");
            return;
        }

        const rows = table.querySelectorAll("tr");
        const today = new Date().toISOString().split("T")[0];

        let totalOrders = 0;
        let totalAmount = 0;

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

        // Restore page after print
        document.body.innerHTML = originalContent;
        location.reload(); // ensures JS state restores cleanly
    };

    /* =====================================================
       🔟 EXPORT (PUBLIC API)
    ===================================================== */
    return {
        CONFIG,
        apiBase: CONFIG.API_BASE,
        auth,
        api,
        assets,
        secureFetch,
        initProtectedPage,   // ✅ fully enhanced
        getUserRoles,
        isAdmin,
        isEmployee,
        requireAdmin,
        requireEmployee
    };

})();
/* =========================================================
   CHARLIE CAFE — CENTRAL AUTH + API CONFIG (FINAL)
   - Cognito Auth
   - Token Handling
   - Page Protection
   - Role Based Access (Admin / Employee)
   - Orders + HR REST APIs (SECURED)
========================================================= */

const CHARLIE = (() => {

    /* =====================================================
       1️⃣ GLOBAL CONFIG
    ===================================================== */
    const CONFIG = {
        REGION: "us-east-1",

        // Cognito
        USER_POOL_ID: "us-east-1_1wxssmoiqi",
        CLIENT_ID: "3a4uchovr497k8v3gl52e2j5d8",
        COGNITO_DOMAIN: "us-east-1wxssmoiqi.auth.us-east-1.amazoncognito.com",

        // API Gateway
        API_BASE: "https://a1053skr51.execute-api.us-east-1.amazonaws.com",

        // CloudFront
        CLOUDFRONT_BASE: "https://d3lnkgtsj0uwlu.cloudfront.net"
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
       3️⃣ AUTH (LOGIN / LOGOUT / PAGE PROTECT)
    ===================================================== */
    const auth = {

        login(redirectUrl = window.location.href) {
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
       4️⃣ AUTHENTICATED FETCH
    ===================================================== */
    async function authFetch(url, options = {}) {
        const token = getToken();

        if (!token || isTokenExpired(token)) {
            auth.logout();
            return;
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

    async function secureFetch(url, options = {}) {
        return authFetch(url, options).then(res => res.json());
    }

    /* =====================================================
       5️⃣ ROLE & ACCESS CONTROL
    ===================================================== */
    function getUserRoles() {
        const token = getToken();
        if (!token) return [];
        const payload = parseJwt(token);
        return payload["cognito:groups"] || [];
    }

    function isAdmin() {
        return getUserRoles().includes("Admin");
    }

    function isEmployee() {
        return getUserRoles().includes("Employee");
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
       6️⃣ API GATEWAY ENDPOINTS (ORDERS + HR)
    ===================================================== */
    const api = {

        /* -------- ORDERS -------- */

        placeOrder(payload) {
            return fetch(`${CONFIG.API_BASE}/dev/orders`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(payload)
            }).then(res => res.json());
        },

        getOrderStatus(orderId) {
            return fetch(
                `${CONFIG.API_BASE}/status/order-status?order_id=${encodeURIComponent(orderId)}`
            ).then(res => res.json());
        },

        cashPayment(orderId) {
            return fetch(`${CONFIG.API_BASE}/dev/orders/cash-payment`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ order_id: orderId })
            }).then(res => res.json());
        },

        updateOrder(payload) {
            return secureFetch(`${CONFIG.API_BASE}/dev/order-update`, {
                method: "POST",
                body: JSON.stringify(payload)
            });
        },

        /* -------- HR (ADMIN ONLY) -------- */

        getAllEmployees() {
            requireAdmin();
            return secureFetch(`${CONFIG.API_BASE}/dev/hr/employees`);
        },

        addEmployee(payload) {
            requireAdmin();
            return secureFetch(`${CONFIG.API_BASE}/dev/hr/employee/add`, {
                method: "POST",
                body: JSON.stringify(payload)
            });
        },

        updateEmployee(payload) {
            requireAdmin();
            return secureFetch(`${CONFIG.API_BASE}/dev/hr/employee/update`, {
                method: "POST",
                body: JSON.stringify(payload)
            });
        },

        deleteEmployee(employeeId) {
            requireAdmin();
            return secureFetch(`${CONFIG.API_BASE}/dev/hr/employee/delete`, {
                method: "POST",
                body: JSON.stringify({ employee_id: employeeId })
            });
        },

        /* -------- HR (EMPLOYEE + ADMIN) -------- */

        recordAttendance(payload) {
            requireEmployee();
            return secureFetch(`${CONFIG.API_BASE}/dev/hr/attendance`, {
                method: "POST",
                body: JSON.stringify(payload)
            });
        },

        getAttendance(employeeId) {
            requireEmployee();
            return secureFetch(
                `${CONFIG.API_BASE}/dev/hr/attendance?employee_id=${encodeURIComponent(employeeId)}`
            );
        }
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
       8️⃣ EXPORT
    ===================================================== */
    return {
        CONFIG,
        apiBase: CONFIG.API_BASE,
        auth,
        api,
        assets,
        secureFetch,
        getUserRoles,
        isAdmin,
        isEmployee
    };

})();

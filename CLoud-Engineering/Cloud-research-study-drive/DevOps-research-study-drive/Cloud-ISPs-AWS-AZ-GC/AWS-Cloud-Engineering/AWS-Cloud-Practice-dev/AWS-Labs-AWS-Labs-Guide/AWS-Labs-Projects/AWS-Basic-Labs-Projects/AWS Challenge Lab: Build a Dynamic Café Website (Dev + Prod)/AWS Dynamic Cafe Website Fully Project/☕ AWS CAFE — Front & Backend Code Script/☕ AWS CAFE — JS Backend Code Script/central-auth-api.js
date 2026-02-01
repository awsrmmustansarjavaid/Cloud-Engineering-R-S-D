/* =========================================================
   CHARLIE CAFE — CENTRAL AUTH + API CONFIG
   Single source of truth for ALL frontend pages
   SAFE FOR BROWSER USE
========================================================= */

const CHARLIE = (() => {

    /* =====================================================
       1️⃣ GLOBAL CONFIG (UNCHANGED)
    ===================================================== */

    const CONFIG = {
        REGION: "us-east-1",

        // -------- Cognito --------
        USER_POOL_ID: "us-east-1_1wxssmoiqi",
        CLIENT_ID: "3a4uchovr497k8v3gl52e2j5d8",
        COGNITO_DOMAIN: "us-east-1wxssmoiqi.auth.us-east-1.amazoncognito.com",

        // -------- API Gateway --------
        API_BASE: "https://a1053skr51.execute-api.us-east-1.amazonaws.com",

        // -------- CloudFront --------
        CLOUDFRONT_BASE: "https://d3lnkgtsj0uwlu.cloudfront.net"
    };

    /* =====================================================
       2️⃣ TOKEN HELPERS (UNCHANGED)
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
       3️⃣ COGNITO AUTH (UNCHANGED)
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
        }
    };

    /* =====================================================
       4️⃣ AUTHENTICATED FETCH (UNCHANGED)
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

    /* =====================================================
       🆕 4️⃣A SECURE FETCH (PHASE 5)
       Alias for Phase-5 naming
    ===================================================== */

    async function secureFetch(url, options = {}) {
        return authFetch(url, options).then(res => res.json());
    }

    /* =====================================================
       🆕 4️⃣B ROLE & ACCESS CONTROL (PHASE 5)
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

    function enforceAdminAccess() {
        if (!isAdmin()) {
            alert("Admin access only");
            auth.logout();
        }

        const adminSection = document.getElementById("admin-section");
        if (adminSection) adminSection.style.display = "block";
    }

    function enforceEmployeeAccess() {
        if (!isEmployee()) {
            alert("Employee access only");
            auth.logout();
        }
    }

    /* =====================================================
       5️⃣ API GATEWAY ENDPOINTS (UNCHANGED)
    ===================================================== */

    const api = {

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
            return authFetch(`${CONFIG.API_BASE}/dev/order-update`, {
                body: JSON.stringify(payload)
            }).then(res => res.json());
        }
    };

    /* =====================================================
       6️⃣ CLOUDFRONT ASSETS (UNCHANGED)
    ===================================================== */

    const assets = {
        url(path) {
            return `${CONFIG.CLOUDFRONT_BASE}/${path}`;
        }
    };

    /* =====================================================
       EXPORT (PHASE-5 EXTENDED)
    ===================================================== */

    return {
        CONFIG,
        apiBase: CONFIG.API_BASE,   // ✅ Phase-5 requirement
        auth,
        api,
        assets,

        // Phase-5 exports
        secureFetch,
        enforceAdminAccess,
        enforceEmployeeAccess,
        getUserRoles
    };

})();

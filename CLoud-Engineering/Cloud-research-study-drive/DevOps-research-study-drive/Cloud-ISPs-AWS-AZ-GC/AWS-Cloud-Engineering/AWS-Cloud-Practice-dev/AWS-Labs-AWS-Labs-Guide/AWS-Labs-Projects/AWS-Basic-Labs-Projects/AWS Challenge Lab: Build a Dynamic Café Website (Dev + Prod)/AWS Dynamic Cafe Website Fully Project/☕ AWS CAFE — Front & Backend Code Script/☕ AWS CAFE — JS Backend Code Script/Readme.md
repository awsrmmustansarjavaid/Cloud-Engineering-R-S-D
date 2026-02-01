#  ☕ AWS CAFE — JS Backend Code Script

Below is a single, clean, centralized file that replaces all 4 files.

✅ FINAL DECISION

❌ Remove: auth.js, config.js, auth-api.js, secure-dashboard.js

✅ Use ONE FILE ONLY

✅ New file name (clear & professional):

```
central-auth-api.js
```

#### You will include this one file in:

orders.php

order-status.html

dashboard.html

any admin page

### ✅ WHAT THIS FILE HANDLES

| Section     | Purpose                 |
| ----------- | ----------------------- |
| Cognito     | Login / Logout / Token  |
| Page Guard  | Protect dashboard pages |
| API Gateway | Orders, Status, Worker  |
| CloudFront  | Static assets           |
| JWT         | Token parsing & expiry  |


❌ NO RDS

❌ NO Secrets Manager

❌ NO AWS SDK in browser

### ✅ central-auth-api.js (FINAL – COPY 100%)
> **Update Version: 1.0**

```
/* =========================================================
   CHARLIE CAFE — CENTRAL AUTH + API CONFIG
   Single source of truth for ALL frontend pages
   SAFE FOR BROWSER USE
========================================================= */

const CHARLIE = (() => {

    /* =====================================================
       1️⃣ GLOBAL CONFIG
    ===================================================== */

    const CONFIG = {
        REGION: "us-east-1",

        // -------- Cognito --------
        USER_POOL_ID: "us-east-1_1wxssmoiqi",
        CLIENT_ID: "3a4uchovr497k8v3gl52e2j5d8",
        COGNITO_DOMAIN: "us-east-1wxssmoiqi.auth.us-east-1.amazoncognito.com",

        // -------- API Gateway --------
        API_BASE: "https://bs0vgnth0f.execute-api.us-east-1.amazonaws.com/dev",

        // -------- CloudFront --------
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
       3️⃣ COGNITO AUTH (Hosted UI)
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

            // Page is safe
            document.body.style.display = "block";
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

    /* =====================================================
       5️⃣ API GATEWAY ENDPOINTS
    ===================================================== */

    const api = {

        // ---------- ORDERS ----------
        placeOrder(payload) {
            return fetch(`${CONFIG.API_BASE}/orders`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(payload)
            }).then(res => res.json());
        },

        // ---------- ORDER STATUS ----------
        getOrderStatus(orderId) {
            return fetch(
                `${CONFIG.API_BASE}/order-status?order_id=${encodeURIComponent(orderId)}`
            ).then(res => res.json());
        },

        // ---------- WORKER / ADMIN ----------
        updateOrder(payload) {
            return authFetch(`${CONFIG.API_BASE}/order-update`, {
                method: "POST",
                body: JSON.stringify(payload)
            }).then(res => res.json());
        }
    };

    /* =====================================================
       6️⃣ CLOUDFRONT ASSETS
    ===================================================== */

    const assets = {
        url(path) {
            return `${CONFIG.CLOUDFRONT_BASE}/${path}`;
        }
    };

    /* =====================================================
       EXPORT
    ===================================================== */

    return {
        CONFIG,
        auth,
        api,
        assets
    };

})();
```

### ✅ HOW TO USE (IMPORTANT)

### 🔹 dashboard.html

```
<script src="/js/central-auth-api.js"></script>
<script>
document.body.style.display = "none";
CHARLIE.auth.protectPage();
</script>
```

### 🔹 orders.php

```
<script src="/js/central-auth-api.js"></script>
```

```
CHARLIE.api.placeOrder(orderPayload);
```

### 🔹 order-status.html
> **Update Version: 1.1**

```
CHARLIE.api.getOrderStatus(orderId);
```

```
/* =========================================================
   CHARLIE CAFE — CENTRAL AUTH + API CONFIG
   Single source of truth for ALL frontend pages
   SAFE FOR BROWSER USE
========================================================= */

const CHARLIE = (() => {

    /* =====================================================
       1️⃣ GLOBAL CONFIG
    ===================================================== */

    const CONFIG = {
        REGION: "us-east-1",

        // -------- Cognito --------
        USER_POOL_ID: "us-east-1_1wxssmoiqi",
        CLIENT_ID: "3a4uchovr497k8v3gl52e2j5d8",
        COGNITO_DOMAIN: "us-east-1wxssmoiqi.auth.us-east-1.amazoncognito.com",

        // -------- API Gateway --------
        API_BASE: "https://bs0vgnth0f.execute-api.us-east-1.amazonaws.com/dev",

        // -------- CloudFront --------
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
       3️⃣ COGNITO AUTH (Hosted UI)
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

            // Page is safe
            document.body.style.display = "block";
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

    /* =====================================================
       5️⃣ API GATEWAY ENDPOINTS
    ===================================================== */

    const api = {

        // ---------- ORDERS ----------
        placeOrder(payload) {
            return fetch(`${CONFIG.API_BASE}/orders`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(payload)
            }).then(res => res.json());
        },

        // ---------- ORDER STATUS ----------
        getOrderStatus(orderId) {
            return fetch(
                `${CONFIG.API_BASE}/order-status?order_id=${encodeURIComponent(orderId)}`
            ).then(res => res.json());
        },

        // ---------- WORKER / ADMIN ----------
        updateOrder(payload) {
            return authFetch(`${CONFIG.API_BASE}/order-update`, {
                method: "POST",
                body: JSON.stringify(payload)
            }).then(res => res.json());
        }
    };

    /* =====================================================
       6️⃣ CLOUDFRONT ASSETS
    ===================================================== */

    const assets = {
        url(path) {
            return `${CONFIG.CLOUDFRONT_BASE}/${path}`;
        }
    };

    /* =====================================================
       EXPORT
    ===================================================== */

    return {
        CONFIG,
        auth,
        api,
        assets
    };

})();
```

### ✅ UPDATED central-auth-api.js
> **Update Version: 1.2**


```
/* =========================================================
   CHARLIE CAFE — CENTRAL AUTH + API CONFIG
   Single source of truth for ALL frontend pages
   SAFE FOR BROWSER USE
========================================================= */

const CHARLIE = (() => {

    /* =====================================================
       1️⃣ GLOBAL CONFIG
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
       3️⃣ COGNITO AUTH (Hosted UI)
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

    /* =====================================================
       5️⃣ API GATEWAY ENDPOINTS
    ===================================================== */

    const api = {

        // ---------- PLACE ORDER ----------
        placeOrder(payload) {
            return fetch(`${CONFIG.API_BASE}/dev/orders`, {  // ← add /dev/ (or your current stage)
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(payload)
            }).then(res => res.json());
        },

        // ---------- ORDER STATUS ----------
        getOrderStatus(orderId) {
            return fetch(
                `${CONFIG.API_BASE}/status/order-status?order_id=${encodeURIComponent(orderId)}`
            ).then(res => res.json());
        },

        // ---------- CASH PAYMENT ----------
        // ✅ NEW: Centralized cash payment endpoint
        cashPayment(orderId) {
            return fetch(`${CONFIG.API_BASE}/dev/orders/cash-payment`, {  // ← assuming this is also under /dev/
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ order_id: orderId })
            }).then(res => res.json());
        },

        // ---------- ADMIN ----------
        updateOrder(payload) {
            return authFetch(`${CONFIG.API_BASE}/dev/order-update`, {  // ← add stage here too
                body: JSON.stringify(payload)
            }).then(res => res.json());
        }
    };
    /* =====================================================
       6️⃣ CLOUDFRONT ASSETS
    ===================================================== */

    const assets = {
        url(path) {
            return `${CONFIG.CLOUDFRONT_BASE}/${path}`;
        }
    };

    /* =====================================================
       EXPORT
    ===================================================== */

    return {
        CONFIG,
        auth,
        api,
        assets
    };

})();
```

### ✅ UPDATED central-auth-api.js
> **Update Version: 1.3**

```
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
```

### ✅ UPDATED central-auth-api.js
> **Update Version: 1.4**

```
/* =========================================================
   CHARLIE CAFE — CENTRAL AUTH + API CONFIG (UPDATED)
   Single source of truth for ALL frontend pages
   Includes logout button handling, page protection, and role checks
========================================================= */

const CHARLIE = (() => {

    /* =====================================================
       1️⃣ GLOBAL CONFIG
       - Cognito, API Gateway, CloudFront
    ===================================================== */
    const CONFIG = {
        REGION: "us-east-1",

        // Cognito User Pool
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
       - Parse JWT, check expiration, get token from storage
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
       3️⃣ COGNITO AUTH
       - Login, Logout, Redirect handling, Page protection
    ===================================================== */
    const auth = {

        // 🔹 Login redirect to Cognito
        login(redirectUrl = window.location.href) {
            const url =
                `https://${CONFIG.COGNITO_DOMAIN}/login` +
                `?response_type=token` +
                `&client_id=${CONFIG.CLIENT_ID}` +
                `&scope=openid+email+profile` +
                `&redirect_uri=${encodeURIComponent(redirectUrl)}`;

            window.location.href = url;
        },

        // 🔹 Logout user
        logout(redirectUrl = window.location.origin) {
            // Remove token from localStorage
            localStorage.removeItem("access_token");

            // Redirect to Cognito logout endpoint (optional redirect after logout)
            const url =
                `https://${CONFIG.COGNITO_DOMAIN}/logout` +
                `?client_id=${CONFIG.CLIENT_ID}` +
                `&logout_uri=${encodeURIComponent(redirectUrl)}`;

            window.location.href = url;
        },

        // 🔹 Handle redirect after Cognito login
        handleRedirect() {
            if (!window.location.hash) return;

            const params = new URLSearchParams(window.location.hash.substring(1));
            const token = params.get("access_token");

            if (token) {
                localStorage.setItem("access_token", token); // Save token
                window.location.hash = ""; // Clean URL
            }
        },

        // 🔹 Protect page for logged-in users
        protectPage() {
            this.handleRedirect();

            const token = getToken();
            if (!token || isTokenExpired(token)) {
                this.login(); // Redirect to login if no valid token
                return;
            }

            // Show page content only if authenticated
            document.body.style.display = "block";
        },

        // 🔹 Logout button integration
        setupLogoutButton(buttonId = "logoutBtn", redirectUrl = "index.html") {
            const btn = document.getElementById(buttonId);
            if (!btn) return;

            btn.addEventListener("click", () => {
                this.logout(redirectUrl); // Call logout function
            });
        }
    };

    /* =====================================================
       4️⃣ AUTHENTICATED FETCH
       - Include token in headers for API calls
    ===================================================== */
    async function authFetch(url, options = {}) {
        const token = getToken();

        if (!token || isTokenExpired(token)) {
            auth.logout(); // Auto logout if token expired
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
       4️⃣A SECURE FETCH (Alias for Phase-5)
    ===================================================== */
    async function secureFetch(url, options = {}) {
        return authFetch(url, options).then(res => res.json());
    }

    /* =====================================================
       4️⃣B ROLE & ACCESS CONTROL
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
       5️⃣ API GATEWAY ENDPOINTS
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
       6️⃣ CLOUDFRONT ASSETS
    ===================================================== */
    const assets = {
        url(path) {
            return `${CONFIG.CLOUDFRONT_BASE}/${path}`;
        }
    };

    /* =====================================================
       7️⃣ EXPORT
       - Expose all functions and config for pages
    ===================================================== */
    return {
        CONFIG,
        apiBase: CONFIG.API_BASE,
        auth,
        api,
        assets,
        secureFetch,
        enforceAdminAccess,
        enforceEmployeeAccess,
        getUserRoles
    };

})();
```
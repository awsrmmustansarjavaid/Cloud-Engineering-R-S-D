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

#### ✅ What is already present in your code

#### 1️⃣ Cognito Login

- auth.login() handles redirecting the user to Cognito login page.

- Accepts optional redirectUrl.

- #### ✅ Works fine.

#### 2️⃣ Cognito Logout

- auth.logout() exists and:

    - Removes access_token from localStorage.

    - Redirects user to Cognito logout page using logout_uri.

- #### ✅ This is correct and works.

#### 3️⃣ Token Handling

- getToken(), parseJwt(), isTokenExpired() exist.

- Tokens are stored in localStorage and checked for expiration.

- #### ✅ Works properly.

#### 4️⃣ Redirect Handling After Login

- auth.handleRedirect() parses the URL hash after Cognito login.

- Stores access_token in localStorage.

- #### ✅ Works fine.

#### 5️⃣ Page Protection

- auth.protectPage():

    - Calls handleRedirect() to process token.

    - Checks token existence and expiration.

    - Redirects to login if invalid.

    - Displays page if token is valid.

- #### ✅ Works perfectly for “protected pages”.

#### 6️⃣ Role-Based Access

- getUserRoles(), isAdmin(), isEmployee(), enforceAdminAccess(), enforceEmployeeAccess() exist.

- #### ✅ Handles restricting pages by roles.

-  Calls auth.logout() if unauthorized.

- #### ✅ Correct.

#### 7️⃣ Authenticated API Calls

- authFetch() adds token to Authorization header.

- Calls auth.logout() if token invalid.

- #### ✅ Correct.

### ⚠️ What’s missing / you may need to add

#### 1️⃣ Logout Button Event Handler

- Your JS handles logout functionally, but no actual button is wired to call auth.logout().

- You need to add this in your page:

```
document.getElementById("logoutBtn").addEventListener("click", () => {
    CHARLIE.auth.logout("index.html"); // or "login.html" after logout
});
```

- And in HTML:

```
<button id="logoutBtn">Logout</button>
```

#### 2️⃣ Protect All Pages

- You have auth.protectPage(), but it’s not automatically called anywhere.

- On every protected page, at the top of your JS:

```
document.addEventListener("DOMContentLoaded", () => {
    CHARLIE.auth.protectPage();
});
```

#### 3️⃣ Optional: Show/hide page elements after login

- document.body.style.display = "block"; is already in protectPage().

- ✅ That’s fine; nothing to change.

#### 4️⃣ Optional: Better Logout UX

- Right now auth.logout() goes to Cognito logout and then redirects.

- If you want immediate local logout and redirect, you could optionally:

```
auth.logoutImmediate = (redirectUrl = "index.html") => {
    localStorage.removeItem("access_token");
    window.location.href = redirectUrl;
};
```

- Not necessary, but sometimes improves UX.

✅ Summary

| Feature                 | Status in your code | Action needed                                     |
| ----------------------- | ------------------- | ------------------------------------------------- |
| Login via Cognito       | ✅ Yes               | None                                              |
| Logout via Cognito      | ✅ Yes               | Just add button event handler                     |
| Token storage & parsing | ✅ Yes               | None                                              |
| Page protection         | ✅ Yes               | Must call `protectPage()` on every protected page |
| Role-based access       | ✅ Yes               | None                                              |
| Authenticated fetch     | ✅ Yes               | None                                              |
| Logout button in HTML   | ❌ No                | Add `<button id="logoutBtn">Logout</button>`      |
| Call logout button      | ❌ No                | Add JS event listener                             |

#### ✅ Updated Code

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

### ✅ What’s new/updated

#### 1️⃣ Logout button integration

- Call CHARLIE.auth.setupLogoutButton(); in your page JS after page loads.

- Default button ID: logoutBtn

- Default redirect after logout: index.html

#### 2️⃣ Page protection

- protectPage() should be called on every protected page to check token and show content.

#### 3️⃣ Full comments

- Every section explains what it does for beginners.

#### Example usage in a page (dashboard.html)

```
<body style="display:none">
    <button id="logoutBtn">Logout</button>

    <script src="js/central-auth-api.js"></script>
    <script>
        // Protect page and show content only if logged in
        CHARLIE.auth.protectPage();

        // Setup logout button
        CHARLIE.auth.setupLogoutButton("logoutBtn", "index.html");
    </script>
</body>
```

---

### ✅ UPDATED central-auth-api.js
> **Update Version: 1.5**

### ✅ Updated REST API section with HR endpoints

```
/* =====================================================
   5️⃣ API GATEWAY ENDPOINTS
   - Orders + HR APIs
===================================================== */
const api = {

    // -------- Existing Orders APIs --------
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
    },

    // -------- NEW HR APIs --------
    // Get all employees (admin only)
    getAllEmployees() {
        // Use authFetch to include access token
        return authFetch(`${CONFIG.API_BASE}/dev/hr/employees`).then(res => res.json());
    },

    // Get specific employee by ID
    getEmployee(employeeId) {
        return authFetch(`${CONFIG.API_BASE}/dev/hr/employee?employee_id=${encodeURIComponent(employeeId)}`)
            .then(res => res.json());
    },

    // Add new employee (admin only)
    addEmployee(payload) {
        return authFetch(`${CONFIG.API_BASE}/dev/hr/employee/add`, {
            method: "POST",
            body: JSON.stringify(payload)
        }).then(res => res.json());
    },

    // Update employee details
    updateEmployee(payload) {
        return authFetch(`${CONFIG.API_BASE}/dev/hr/employee/update`, {
            method: "POST",
            body: JSON.stringify(payload)
        }).then(res => res.json());
    },

    // Delete employee (admin only)
    deleteEmployee(employeeId) {
        return authFetch(`${CONFIG.API_BASE}/dev/hr/employee/delete`, {
            method: "POST",
            body: JSON.stringify({ employee_id: employeeId })
        }).then(res => res.json());
    },

    // Record attendance
    recordAttendance(payload) {
        return authFetch(`${CONFIG.API_BASE}/dev/hr/attendance`, {
            method: "POST",
            body: JSON.stringify(payload)
        }).then(res => res.json());
    },

    // Get attendance of employee
    getAttendance(employeeId) {
        return authFetch(`${CONFIG.API_BASE}/dev/hr/attendance?employee_id=${encodeURIComponent(employeeId)}`)
            .then(res => res.json());
    }
};
```

### ✅ How to integrate in central-auth-api.js

- Replace the existing const api = { ... } block with the updated one above.

- Everything else (auth, protectPage, logout) remains unchanged.

- Use the HR APIs anywhere in your pages via:

```
// Example: fetch all employees
CHARLIE.api.getAllEmployees().then(data => console.log(data));

// Example: record attendance
CHARLIE.api.recordAttendance({ employee_id: "123", check_in: "08:00" })
    .then(res => console.log(res));
```

### ✅ UPDATED central-auth-api.js (WITH HR ROLE SECURITY)

> **📌 You can COPY-PASTE this whole file safely**

```
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
```

### 🧠 BEGINNER MENTAL MODEL (IMPORTANT)

🔐 Auth logic → auth.*

🎭 Role security → requireAdmin() / requireEmployee()

🔗 All APIs → CHARLIE.api.*

🚪 Logout → works everywhere automatically

🧱 Protection → frontend + backend aligned

### ✅ How YOU will use HR APIs now

```
// Admin only
CHARLIE.api.getAllEmployees();

// Employee / Admin
CHARLIE.api.recordAttendance({
    employee_id: "E123",
    check_in: "09:00"
});
```

**⚠️ If a wrong role tries → ❌ auto logout + blocked**

---




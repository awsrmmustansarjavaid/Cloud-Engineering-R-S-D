# Charlie cafe - central-auth.js

### central-auth.js

> **Update Version:1.0**

```
/* =========================================================
   CHARLIE CAFE — CENTRAL AUTH MODULE
   ---------------------------------------------------------
   ✔ Cognito Hosted UI Login (No login.html needed)
   ✔ Authorization Code Flow
   ✔ Auto Token Exchange
   ✔ Role-Based UI Control
   ✔ Auto Logout on Expiry
========================================================= */

window.CHARLIE_AUTH = (() => {

    const CONFIG = window.CHARLIE_CONFIG;
    const { getToken, isTokenExpired, parseJwt } = window.CHARLIE_UTILS;

    /* =====================================================
       🔐 REDIRECT TO COGNITO HOSTED UI
    ===================================================== */
    function redirectToHostedLogin() {

        const redirectUrl = window.location.origin + window.location.pathname;

        const loginUrl =
            `https://${CONFIG.COGNITO_DOMAIN}/login` +
            `?response_type=code` +
            `&client_id=${CONFIG.CLIENT_ID}` +
            `&scope=openid+email+profile` +
            `&redirect_uri=${encodeURIComponent(redirectUrl)}`;

        window.location.replace(loginUrl);
    }

    /* =====================================================
       🚪 LOGOUT
    ===================================================== */
    function logout() {

        localStorage.removeItem("access_token");

        const logoutRedirect = window.location.origin;

        const logoutUrl =
            `https://${CONFIG.COGNITO_DOMAIN}/logout` +
            `?client_id=${CONFIG.CLIENT_ID}` +
            `&logout_uri=${encodeURIComponent(logoutRedirect)}`;

        window.location.replace(logoutUrl);
    }

    /* =====================================================
       🔁 HANDLE AUTHORIZATION CODE → TOKEN
    ===================================================== */
    async function handleRedirect() {

        const params = new URLSearchParams(window.location.search);
        const code = params.get("code");

        if (!code) return;

        try {

            const redirectUrl = window.location.origin + window.location.pathname;

            const response = await fetch(
                `https://${CONFIG.COGNITO_DOMAIN}/oauth2/token`,
                {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded"
                    },
                    body: new URLSearchParams({
                        grant_type: "authorization_code",
                        client_id: CONFIG.CLIENT_ID,
                        code: code,
                        redirect_uri: redirectUrl
                    })
                }
            );

            if (!response.ok) {
                throw new Error("Token exchange failed");
            }

            const data = await response.json();

            if (data.access_token) {
                localStorage.setItem("access_token", data.access_token);

                // Clean URL
                window.history.replaceState(
                    {},
                    document.title,
                    window.location.pathname
                );
            }

        } catch (err) {
            console.error("Authentication error:", err);
            logout();
        }
    }

    /* =====================================================
       🛡 PROTECT PAGE (AUTO LOGIN MODE)
       - No login.html required
       - Automatically redirects to Hosted UI
    ===================================================== */
    async function protectPage() {

        // Hide page until auth completes
        document.body.style.display = "none";

        await handleRedirect();

        const token = getToken();

        if (!token || isTokenExpired(token)) {
            redirectToHostedLogin();
            return;
        }

        // Token valid → show page
        document.body.style.display = "block";
    }

    /* =====================================================
       👤 ROLE MANAGEMENT (UI ONLY)
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
            alert("Admin access only");
            logout();
        }
    }

    function requireEmployee() {
        if (!isEmployee() && !isAdmin()) {
            alert("Employee access only");
            logout();
        }
    }

    /* =====================================================
       🔄 AUTO LOGOUT WATCHER
    ===================================================== */
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

    return {
        protectPage,
        logout,
        getUserRoles,
        isAdmin,
        isEmployee,
        requireAdmin,
        requireEmployee,
        startAutoLogoutWatcher
    };

})();
```


---
### central-auth.js

> **Update Version:1.1**

```
/* =========================================================
   CHARLIE CAFE — CENTRAL AUTH MODULE (FIXED)
   ---------------------------------------------------------
   ✔ Cognito Hosted UI Login (No login.html needed)
   ✔ Authorization Code Flow
   ✔ Auto Token Exchange
   ✔ Role-Based UI Control
   ✔ Auto Logout on Expiry
   ✔ Fixed "https://" duplication bug
========================================================= */

window.CHARLIE_AUTH = (() => {

    const CONFIG = window.CHARLIE_CONFIG;
    const { getToken, isTokenExpired, parseJwt } = window.CHARLIE_UTILS;

    /* =====================================================
       🔐 HELPER — Build Cognito Login URL
       -----------------------------------------------------
       Ensures no double "https://" in URL
    ===================================================== */
    function buildCognitoLoginUrl() {
        // Remove https:// if user accidentally included it
        let domain = CONFIG.COGNITO_DOMAIN.replace(/^https?:\/\//, "");
        const redirectUrl = window.location.origin + window.location.pathname;

        return `https://${domain}/login` +
            `?response_type=code` +
            `&client_id=${CONFIG.CLIENT_ID}` +
            `&scope=openid+email+profile` +
            `&redirect_uri=${encodeURIComponent(redirectUrl)}`;
    }

    /* =====================================================
       🔐 REDIRECT TO COGNITO HOSTED UI
    ===================================================== */
    function redirectToHostedLogin() {
        window.location.replace(buildCognitoLoginUrl());
    }

    /* =====================================================
       🚪 LOGOUT
    ===================================================== */
    function logout() {
        localStorage.removeItem("access_token");

        const logoutRedirect = window.location.origin;
        let domain = CONFIG.COGNITO_DOMAIN.replace(/^https?:\/\//, "");

        const logoutUrl =
            `https://${domain}/logout` +
            `?client_id=${CONFIG.CLIENT_ID}` +
            `&logout_uri=${encodeURIComponent(logoutRedirect)}`;

        window.location.replace(logoutUrl);
    }

    /* =====================================================
       🔁 HANDLE AUTHORIZATION CODE → TOKEN
    ===================================================== */
    async function handleRedirect() {
        const params = new URLSearchParams(window.location.search);
        const code = params.get("code");

        if (!code) return;

        try {
            const redirectUrl = window.location.origin + window.location.pathname;
            let domain = CONFIG.COGNITO_DOMAIN.replace(/^https?:\/\//, "");

            const response = await fetch(
                `https://${domain}/oauth2/token`,
                {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded"
                    },
                    body: new URLSearchParams({
                        grant_type: "authorization_code",
                        client_id: CONFIG.CLIENT_ID,
                        code: code,
                        redirect_uri: redirectUrl
                    })
                }
            );

            if (!response.ok) throw new Error("Token exchange failed");

            const data = await response.json();

            if (data.access_token) {
                localStorage.setItem("access_token", data.access_token);

                // Clean URL (remove code query param)
                window.history.replaceState({}, document.title, window.location.pathname);
            }

        } catch (err) {
            console.error("Authentication error:", err);
            logout();
        }
    }

    /* =====================================================
       🛡 PROTECT PAGE (AUTO LOGIN MODE)
       - No login.html needed
       - Automatically redirects to Hosted UI
    ===================================================== */
    async function protectPage() {
        // Hide page until auth completes
        document.body.style.display = "none";

        await handleRedirect();

        const token = getToken();

        if (!token || isTokenExpired(token)) {
            redirectToHostedLogin();
            return;
        }

        // Token valid → show page
        document.body.style.display = "block";
    }

    /* =====================================================
       👤 ROLE MANAGEMENT (UI ONLY)
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
            alert("Admin access only");
            logout();
        }
    }

    function requireEmployee() {
        if (!isEmployee() && !isAdmin()) {
            alert("Employee access only");
            logout();
        }
    }

    /* =====================================================
       🔄 AUTO LOGOUT WATCHER
    ===================================================== */
    function startAutoLogoutWatcher() {
        setInterval(() => {
            const token = getToken();
            if (!token) return;

            if (isTokenExpired(token)) {
                alert("Session expired");
                logout();
            }
        }, 30000); // check every 30 seconds
    }

    return {
        protectPage,
        logout,
        getUserRoles,
        isAdmin,
        isEmployee,
        requireAdmin,
        requireEmployee,
        startAutoLogoutWatcher
    };

})();
```

---
### central-auth.js

> **Update Version:1.2**

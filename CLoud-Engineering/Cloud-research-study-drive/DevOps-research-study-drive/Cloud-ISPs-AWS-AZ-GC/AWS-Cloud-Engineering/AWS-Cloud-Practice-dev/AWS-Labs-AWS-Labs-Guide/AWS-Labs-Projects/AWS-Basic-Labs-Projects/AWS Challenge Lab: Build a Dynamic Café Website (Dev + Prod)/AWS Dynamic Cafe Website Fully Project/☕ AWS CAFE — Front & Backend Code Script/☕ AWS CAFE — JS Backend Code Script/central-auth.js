/* =========================================================
   CHARLIE CAFE — CENTRAL AUTH MODULE
   ---------------------------------------------------------
   ✔ Cognito Hosted UI Login
   ✔ Logout
   ✔ Token Redirect Handling
   ✔ Role-Based Access
   ✔ Auto Logout Watcher
========================================================= */

window.CHARLIE_AUTH = (() => {

    const CONFIG = window.CHARLIE_CONFIG;
    const { getToken, isTokenExpired, parseJwt } = window.CHARLIE_UTILS;

    /* ===============================
       🔐 LOGIN
    =============================== */
    function login(redirectUrl = `${CONFIG.CLOUDFRONT_BASE}/cafe-admin-dashboard.html`) {

        const url =
            `https://${CONFIG.COGNITO_DOMAIN}/login` +
            `?response_type=token` +
            `&client_id=${CONFIG.CLIENT_ID}` +
            `&scope=openid+email+profile` +
            `&redirect_uri=${encodeURIComponent(redirectUrl)}`;

        window.location.href = url;
    }

    /* ===============================
       🚪 LOGOUT
    =============================== */
    function logout(redirectUrl = `${CONFIG.CLOUDFRONT_BASE}/dashboard-login.html`) {

        localStorage.removeItem("access_token");

        const url =
            `https://${CONFIG.COGNITO_DOMAIN}/logout` +
            `?client_id=${CONFIG.CLIENT_ID}` +
            `&logout_uri=${encodeURIComponent(redirectUrl)}`;

        window.location.href = url;
    }

    /* ===============================
       🔁 HANDLE REDIRECT
    =============================== */
    function handleRedirect() {
        if (!window.location.hash) return;

        const params = new URLSearchParams(window.location.hash.substring(1));
        const token = params.get("access_token");

        if (token) {
            localStorage.setItem("access_token", token);
            window.location.hash = "";
        }
    }

    /* ===============================
       🛡 PROTECT PAGE
    =============================== */
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
       👤 ROLE CONTROL
    =============================== */
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
            logout();
            throw new Error("Admin access required");
        }
    }

    function requireEmployee() {
        if (!isEmployee() && !isAdmin()) {
            alert("❌ Employee access only");
            logout();
            throw new Error("Employee access required");
        }
    }

    /* ===============================
       🔄 AUTO LOGOUT WATCHER
    =============================== */
    function startAutoLogoutWatcher() {

        setInterval(() => {
            const token = getToken();
            if (!token) return;

            if (isTokenExpired(token)) {
                alert("🔐 Session expired");
                logout();
            }
        }, 30000);
    }

    return {
        login,
        logout,
        protectPage,
        getUserRoles,
        isAdmin,
        isEmployee,
        requireAdmin,
        requireEmployee,
        startAutoLogoutWatcher
    };

})();

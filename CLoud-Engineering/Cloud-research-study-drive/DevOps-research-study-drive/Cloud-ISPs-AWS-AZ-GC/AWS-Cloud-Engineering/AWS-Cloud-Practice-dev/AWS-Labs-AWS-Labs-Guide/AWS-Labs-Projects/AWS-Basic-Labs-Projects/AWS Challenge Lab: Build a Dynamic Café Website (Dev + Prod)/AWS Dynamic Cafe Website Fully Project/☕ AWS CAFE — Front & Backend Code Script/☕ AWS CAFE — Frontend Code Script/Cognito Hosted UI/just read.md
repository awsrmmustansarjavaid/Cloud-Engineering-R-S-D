
```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Café ☕ | Login</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- =========================================================
     UI Styling (Bootstrap + Google Font)
========================================================= -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;500;700&display=swap" rel="stylesheet">

<style>
body {
    font-family: 'Poppins', sans-serif;
    background: url('https://images.unsplash.com/photo-1509042239860-f550ce710b93') no-repeat center center/cover;
    height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
}
.overlay {
    background: rgba(0,0,0,0.6);
    position: absolute;
    width: 100%;
    height: 100%;
}
.login-card {
    position: relative;
    background: rgba(58,37,28,0.95);
    padding: 40px;
    border-radius: 20px;
    box-shadow: 0 15px 35px rgba(0,0,0,0.6);
    width: 350px;
    text-align: center;
    color: #fff;
    z-index: 2;
}
.logo { font-size: 40px; margin-bottom: 10px; }
.cafe-title { font-size: 26px; font-weight: 700; margin-bottom: 25px; }
.btn-login {
    background: linear-gradient(135deg,#ff5722,#ff9800);
    border: none;
    border-radius: 50px;
    padding: 12px;
    font-weight: 600;
    width: 100%;
    color: #fff;
    transition: 0.3s;
}
.btn-login:hover { transform: scale(1.05); }
</style>
</head>

<body>

<div class="overlay"></div>

<div class="login-card">
    <div class="logo">☕</div>
    <div class="cafe-title">Charlie Café</div>
    <p class="mb-4">Welcome back! Please login to continue.</p>
    <button id="loginBtn" class="btn btn-login">
        Login with Cognito
    </button>
</div>

<!-- =========================================================
     SCRIPTS
     - Load config, utils, and central-auth
     - Call CHARLIE_AUTH.login() on button click
========================================================= -->
<script src="/js/config.js"></script>
<script src="/js/utils.js"></script>
<script src="/js/central-auth.js"></script>

<script>
// ===========================================================
// SIMPLE LOGIN PAGE
// This page only triggers login via central-auth.js
// The redirect back to original page is handled there
// ===========================================================

document.getElementById("loginBtn").addEventListener("click", function () {
    // 🔑 Call central-auth login function
    CHARLIE_AUTH.login();
});
</script>

</body>
</html>
```

fully final ✅ Fully Final central-auth.js

```
/* =========================================================
   CHARLIE CAFE — CENTRAL AUTH MODULE
   ---------------------------------------------------------
   Features:
   ✔ Authorization Code Flow (Cognito Hosted UI)
   ✔ Dynamic redirect to original page after login
   ✔ Page protection
   ✔ Role-based access (admin/employee)
   ✔ Auto logout watcher
   ✔ Handles token expiration
========================================================= */

window.CHARLIE_AUTH = (() => {

    const CONFIG = window.CHARLIE_CONFIG; // Your config.js
    const { parseJwt } = window.CHARLIE_UTILS; // JWT parsing utility

    /* =====================================================
       🔐 LOGIN FUNCTION
       - Saves current page to redirect after login
       - Redirects to Cognito Hosted UI login
    ===================================================== */
    function login() {

        // Store the page user is trying to access
        const currentPage = window.location.pathname + window.location.search;
        sessionStorage.setItem("post_login_redirect", currentPage);

        // Cognito redirect back to login.html
        const redirectUrl = window.location.origin + "/login.html";

        // Build Cognito login URL
        const url = 
            `https://${CONFIG.COGNITO_DOMAIN}/login` +
            `?response_type=code` +
            `&client_id=${CONFIG.CLIENT_ID}` +
            `&scope=openid+email+profile` +
            `&redirect_uri=${encodeURIComponent(redirectUrl)}`;

        window.location.href = url;
    }

    /* =====================================================
       🚪 LOGOUT FUNCTION
       - Clears local storage/session storage
       - Redirects to Cognito logout endpoint
    ===================================================== */
    function logout() {

        localStorage.removeItem("access_token");
        sessionStorage.removeItem("post_login_redirect");

        const logoutRedirect = window.location.origin + "/login.html";

        const url =
            `https://${CONFIG.COGNITO_DOMAIN}/logout` +
            `?client_id=${CONFIG.CLIENT_ID}` +
            `&logout_uri=${encodeURIComponent(logoutRedirect)}`;

        window.location.href = url;
    }

    /* =====================================================
       🔁 HANDLE REDIRECT AFTER COGNITO LOGIN
       - Exchanges authorization code for access token
       - Redirects user to the original requested page
    ===================================================== */
    async function handleRedirect() {

        const params = new URLSearchParams(window.location.search);
        const code = params.get("code");

        if (!code) return; // No code, nothing to do

        try {
            const redirectUrl = window.location.origin + "/login.html";

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

            if (!response.ok) throw new Error("Token exchange failed");

            const data = await response.json();

            if (data.access_token) {
                localStorage.setItem("access_token", data.access_token);

                // Retrieve stored redirect page
                const redirectPage = sessionStorage.getItem("post_login_redirect") || "/cafe-admin-dashboard.html";

                // Clear stored redirect
                sessionStorage.removeItem("post_login_redirect");

                // Redirect to the page user originally requested
                window.location.href = redirectPage;
            }

        } catch (error) {
            console.error("Auth error:", error);
            logout();
        }
    }

    /* =====================================================
       🛡 PROTECT PAGE
       - Ensures user is logged in
       - Checks token expiration
       - Redirects to login if not authenticated
    ===================================================== */
    async function protectPage() {

        // Handle Cognito redirect if user just logged in
        await handleRedirect();

        const token = getToken();

        if (!token || isTokenExpired(token)) {
            login(); // Redirect to Cognito login
            return;
        }

        // If logged in, show the page
        document.body.style.display = "block";
    }

    /* =====================================================
       👤 ROLE MANAGEMENT
       - Returns roles from Cognito JWT
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

    /* =====================================================
       🔄 AUTO LOGOUT WATCHER
       - Checks token expiration every 30 seconds
       - Logs out automatically if expired
    ===================================================== */
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

    /* =====================================================
       🔑 HELPER FUNCTIONS
    ===================================================== */
    function getToken() {
        return localStorage.getItem("access_token");
    }

    function isTokenExpired(token) {
        if (!token) return true;

        const payload = parseJwt(token);
        const exp = payload.exp || 0;

        // Token expired if current time > expiration
        return Date.now() / 1000 > exp;
    }

    /* =====================================================
       EXPORT PUBLIC API
    ===================================================== */
    return {
        login,
        logout,
        protectPage,
        getUserRoles,
        isAdmin,
        isEmployee,
        requireAdmin,
        requireEmployee,
        startAutoLogoutWatcher,
        getToken,
        isTokenExpired
    };

})();
```

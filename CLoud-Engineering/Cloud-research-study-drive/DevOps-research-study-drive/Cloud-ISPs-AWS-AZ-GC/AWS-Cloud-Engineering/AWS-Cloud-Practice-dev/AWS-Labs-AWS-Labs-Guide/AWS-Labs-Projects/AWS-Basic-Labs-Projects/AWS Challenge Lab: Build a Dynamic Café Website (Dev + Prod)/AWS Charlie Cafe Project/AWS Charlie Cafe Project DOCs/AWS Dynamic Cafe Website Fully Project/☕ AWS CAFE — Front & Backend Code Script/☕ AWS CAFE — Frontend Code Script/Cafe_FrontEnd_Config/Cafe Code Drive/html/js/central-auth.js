/* =========================================================
   CHARLIE CAFE — CENTRAL AUTH MODULE (FIXED HTTPS ISSUE)
   ---------------------------------------------------------
   ✔ Works even if COGNITO_DOMAIN includes https:// or has typo
   ✔ Authorization Code Flow
   ✔ Auto Token Exchange
   ✔ Role-Based UI Control
   ✔ Auto Logout on Expiry
========================================================= */

window.CHARLIE_AUTH = (() => {

    const CONFIG = window.CHARLIE_CONFIG;
    const { getToken, isTokenExpired, parseJwt } = window.CHARLIE_UTILS;

    /* =====================================================
       🔐 HELPER — Normalize Cognito Domain
       -----------------------------------------------------
       Ensures the domain does NOT have http:// or https://
       and removes accidental double slashes.
    ===================================================== */
    function normalizeDomain(domain) {
        if (!domain) return "";

        domain = domain.trim();

        // Fix common typo: https// → https://
        if (/^https\/\/.*/i.test(domain)) {
            domain = domain.replace(/^https\/\/+/i, "");
        }

        // Remove any http:// or https://
        domain = domain.replace(/^https?:\/\//i, "");

        // Remove trailing slash if present
        domain = domain.replace(/\/$/, "");

        return domain;
    }

    /* =====================================================
       🔐 BUILD COGNITO LOGIN URL
       -----------------------------------------------------
       - Uses normalized domain
       - Adds https:// prefix
       - Adds query parameters
    ===================================================== */
    function buildCognitoLoginUrl() {
        const domain = normalizeDomain(CONFIG.COGNITO_DOMAIN);
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

        const domain = normalizeDomain(CONFIG.COGNITO_DOMAIN);
        const logoutRedirect = window.location.origin;

        const logoutUrl = `https://${domain}/logout` +
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
            const domain = normalizeDomain(CONFIG.COGNITO_DOMAIN);
            const redirectUrl = window.location.origin + window.location.pathname;

            const response = await fetch(`https://${domain}/oauth2/token`, {
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
            });

            if (!response.ok) throw new Error("Token exchange failed");

            const data = await response.json();

            if (data.access_token) {
                localStorage.setItem("access_token", data.access_token);

                // Clean URL (remove code param)
                window.history.replaceState({}, document.title, window.location.pathname);
            }

        } catch (err) {
            console.error("Authentication error:", err);
            logout();
        }
    }

    /* =====================================================
       🛡 PROTECT PAGE (AUTO LOGIN MODE)
    ===================================================== */
    async function protectPage() {
        document.body.style.display = "none";

        await handleRedirect();

        const token = getToken();

        if (!token || isTokenExpired(token)) {
            redirectToHostedLogin();
            return;
        }

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
        return Array.isArray(groups) ? groups.map(r => r.toLowerCase()) : [String(groups).toLowerCase()];
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
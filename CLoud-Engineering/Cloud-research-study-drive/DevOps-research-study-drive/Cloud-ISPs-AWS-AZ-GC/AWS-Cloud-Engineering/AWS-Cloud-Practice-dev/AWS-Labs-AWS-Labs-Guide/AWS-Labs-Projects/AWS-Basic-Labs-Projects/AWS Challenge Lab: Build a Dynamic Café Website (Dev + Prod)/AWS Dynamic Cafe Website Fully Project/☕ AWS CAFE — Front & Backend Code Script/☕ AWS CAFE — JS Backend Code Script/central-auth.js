/* =========================================================
   CENTRAL AUTH MODULE
   Handles ONLY Cognito authentication
========================================================= */

import { CONFIG } from "./config.js";
import { parseJwt, isTokenExpired } from "./utils.js";

const TOKEN_KEY = "access_token";

/* ===============================
   TOKEN HELPERS
================================= */

function getToken() {
    return localStorage.getItem(TOKEN_KEY);
}

function saveToken(token) {
    localStorage.setItem(TOKEN_KEY, token);
}

function clearToken() {
    localStorage.removeItem(TOKEN_KEY);
}

/* ===============================
   LOGIN
================================= */

function login() {

    const redirectUrl = `${CONFIG.CLOUDFRONT_BASE}/login.html`;

    const url =
        `https://${CONFIG.COGNITO_DOMAIN}/login` +
        `?response_type=token` +
        `&client_id=${CONFIG.CLIENT_ID}` +
        `&scope=openid+email+profile` +
        `&redirect_uri=${encodeURIComponent(redirectUrl)}`;

    window.location.href = url;
}

/* ===============================
   LOGOUT
================================= */

function logout() {

    clearToken();

    const redirectUrl = `${CONFIG.CLOUDFRONT_BASE}/logout.html`;

    const url =
        `https://${CONFIG.COGNITO_DOMAIN}/logout` +
        `?client_id=${CONFIG.CLIENT_ID}` +
        `&logout_uri=${encodeURIComponent(redirectUrl)}`;

    window.location.href = url;
}

/* ===============================
   HANDLE REDIRECT
================================= */

function handleRedirect() {

    if (!window.location.hash) return;

    const params = new URLSearchParams(window.location.hash.substring(1));
    const token = params.get("access_token");

    if (token) {
        saveToken(token);
        window.location.hash = "";
    }
}

/* ===============================
   PAGE PROTECTION
================================= */

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
   ROLE HANDLING
================================= */

function getUserRoles() {

    const token = getToken();
    if (!token) return [];

    const payload = parseJwt(token);
    const groups = payload["cognito:groups"] || [];

    return Array.isArray(groups)
        ? groups.map(g => g.toLowerCase())
        : [String(groups).toLowerCase()];
}

function requireRole(allowedRoles) {

    const roles = getUserRoles();

    const allowed = allowedRoles.some(role =>
        roles.includes(role.toLowerCase())
    );

    if (!allowed) {
        alert("Access denied");
        logout();
        throw new Error("Unauthorized role");
    }
}

/* ===============================
   AUTO LOGOUT WATCHER
================================= */

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

/* ===============================
   EXPORT
================================= */

export const Auth = {
    login,
    logout,
    protectPage,
    getToken,
    requireRole,
    startAutoLogoutWatcher
};

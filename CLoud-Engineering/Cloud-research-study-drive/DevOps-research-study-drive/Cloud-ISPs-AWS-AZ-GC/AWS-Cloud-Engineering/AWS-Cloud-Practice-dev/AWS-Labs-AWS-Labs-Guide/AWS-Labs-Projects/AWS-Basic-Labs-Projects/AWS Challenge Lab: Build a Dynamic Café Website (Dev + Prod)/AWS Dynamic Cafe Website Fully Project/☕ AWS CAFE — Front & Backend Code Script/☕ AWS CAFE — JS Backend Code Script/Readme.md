# Charlie CaFe - central-auth-api

- Public API (no Cognito)

- Protected API (Cognito authorizer)

- PHP for public

- Frontend JS for protected

- One prod stage

- Route-based separation

### 🏗 FINAL ARCHITECTURE STRUCTURE

```
/js
 ├── config.js
 ├── utils.js
 ├── central-auth.js          (Cognito ONLY)
 ├── api.js                   (API calls ONLY)
 ├── central-printing.js
```

#### Public pages:

- Use: config.js + api.js

- DO NOT load central-auth.js

#### Protected pages:

- Use: config.js + utils.js + central-auth.js + api.js

### 🔥 STEP 1 — config.js (NO LOGIC HERE)

This replaces hardcoded config from your old file.

```
/* =========================================================
   CONFIGURATION FILE
   Never hardcode values inside logic files
========================================================= */

export const CONFIG = {

    // AWS Region
    REGION: "us-east-1",

    // Cognito
    USER_POOL_ID: "us-east-1_oeMWJar3T",
    CLIENT_ID: "42haggs0jctmq5rnaajfi3hmqu",
    COGNITO_DOMAIN: "us-east-1oemwjar3t.auth.us-east-1.amazoncognito.com",

    // API Gateway (Single prod stage)
    API_BASE: "https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/prod",

    // CloudFront
    CLOUDFRONT_BASE: "https://d163j9zwndcxgl.cloudfront.net"
};
```

✔ No functions

✔ Only configuration

✔ Used by all files

### 🔥 STEP 2 — utils.js (Shared Helpers)

Move all generic helpers here.

```
/* =========================================================
   SHARED UTILITIES
========================================================= */

export function parseJwt(token) {
    try {
        return JSON.parse(atob(token.split(".")[1]));
    } catch {
        return {};
    }
}

export function isTokenExpired(token) {
    try {
        return parseJwt(token).exp * 1000 < Date.now();
    } catch {
        return true;
    }
}

export function formatCurrency(amount) {
    return "$" + Number(amount).toFixed(2);
}
```

### 🔐 STEP 3 — central-auth.js (COGNITO ONLY)

This file contains ONLY authentication logic.

No API routes inside.

```
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
```

### 🌐 STEP 4 — api.js (PUBLIC + PROTECTED FETCH)

This file handles API logic only.

```
/* =========================================================
   API MODULE
   Handles ONLY API requests
========================================================= */

import { CONFIG } from "./config.js";
import { Auth } from "./central-auth.js";

/* ===============================
   PUBLIC FETCH (No token)
================================= */

export async function publicFetch(path, options = {}) {

    return fetch(`${CONFIG.API_BASE}${path}`, {
        method: options.method || "GET",
        headers: {
            "Content-Type": "application/json",
            ...(options.headers || {})
        },
        ...options
    });
}

/* ===============================
   PROTECTED FETCH
================================= */

export async function protectedFetch(path, options = {}) {

    const token = Auth.getToken();

    if (!token) {
        Auth.logout();
        return;
    }

    return fetch(`${CONFIG.API_BASE}${path}`, {
        method: options.method || "GET",
        headers: {
            Authorization: "Bearer " + token,
            "Content-Type": "application/json",
            ...(options.headers || {})
        },
        ...options
    });
}
```

### 📌 HOW FILES ARE USED
Public page example:

```
<script type="module">
import { publicFetch } from "./js/api.js";

publicFetch("/public/orders", {
    method: "POST",
    body: JSON.stringify({ item: "Coffee" })
});
</script>
```

No Cognito loaded.

### 📌 Protected page example:

```
<script type="module">
import { Auth } from "./js/central-auth.js";
import { protectedFetch } from "./js/api.js";

Auth.protectPage();
Auth.startAutoLogoutWatcher();
Auth.requireRole(["Admin"]);

protectedFetch("/admin/dashboard")
    .then(res => res.json())
    .then(console.log);
</script>
```

### 🎯 DO YOU NEED TWO central-auth.js FILES?

❌ No.

Only protected pages load central-auth.js.

Public pages do not include it.

So architecture stays clean.

### 🏆 FINAL RESULT

You now have:

- Public API → used by PHP or public pages

- Protected API → Cognito authorizer

- Clean separation

- No mixed responsibilities

- No hardcoded config

- Role-based protection

- Production-grade structure

---



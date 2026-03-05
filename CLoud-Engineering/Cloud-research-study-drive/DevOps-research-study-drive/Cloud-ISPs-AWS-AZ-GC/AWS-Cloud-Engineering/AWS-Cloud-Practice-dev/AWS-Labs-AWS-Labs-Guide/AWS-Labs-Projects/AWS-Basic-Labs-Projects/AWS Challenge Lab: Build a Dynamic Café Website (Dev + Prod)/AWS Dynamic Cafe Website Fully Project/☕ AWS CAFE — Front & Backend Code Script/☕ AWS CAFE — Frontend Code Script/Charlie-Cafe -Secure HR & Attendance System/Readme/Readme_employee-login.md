

### employee-login.html

Got it! ✅ I can clean this up so your employee login properly uses config.js values for Cognito and CloudFront, and fixes the redirect issue. Here’s the fully final working code for employee-login.html:

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Café ☕ | Employee Login</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- Bootstrap & Google Fonts -->
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
    position: relative;
    color: #fff;
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
    <div class="cafe-title">Charlie Café Employee</div>
    <p class="mb-4">Welcome back! Please login to access the employee portal.</p>
    
    <button id="loginBtn" class="btn btn-login">Login with Cognito</button>
</div>

<script src="config.js"></script>
<script src="utils.js"></script>
<script src="central-auth.js"></script>
<script src="api.js"></script>
<script src="central-printing.js"></script>

<script>
/* ============================================================
   CHARLIE CAFÉ EMPLOYEE LOGIN
   Using Amazon Cognito Hosted UI
   ✅ Fully uses config.js values
============================================================ */

const DOMAIN = window.CHARLIE_CONFIG.COGNITO_DOMAIN;
const CLIENT_ID = window.CHARLIE_CONFIG.CLIENT_ID;
const REDIRECT_URI = `${window.CHARLIE_CONFIG.CLOUDFRONT_BASE}/employee-portal.html`;

// Build Hosted UI login URL
const loginUrl = `${DOMAIN}/login?response_type=token&client_id=${CLIENT_ID}&redirect_uri=${encodeURIComponent(REDIRECT_URI)}&scope=email+openid`;

// Redirect to Cognito Hosted UI when login button clicked
document.getElementById("loginBtn").addEventListener("click", () => {
    if (typeof utils !== "undefined") utils.log("Redirecting to Cognito Hosted UI...");
    window.location.href = loginUrl;
});

// Detect Cognito tokens in URL after login
if (window.location.hash) {
    const hash = window.location.hash.substring(1);
    const params = new URLSearchParams(hash);
    const accessToken = params.get("access_token");
    const idToken = params.get("id_token");
    
    if (accessToken && idToken && typeof CHARLIE_AUTH !== "undefined") {
        CHARLIE_AUTH.storeTokens({ accessToken, idToken });
        // Redirect to employee portal using CloudFront base
        window.location.href = `${window.CHARLIE_CONFIG.CLOUDFRONT_BASE}/employee-portal.html`;
    }
}
</script>
</body>
</html>
```

### ✅ employee-login.html

> **Update Version:1.1**

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Café ☕ | Employee Login</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- ===================================================
     Bootstrap CSS
=================================================== -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- ===================================================
     Google Font
=================================================== -->
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;500;700&display=swap" rel="stylesheet">

<style>
/* ===================================================
   Global Styles
=================================================== */
body {
    font-family: 'Poppins', sans-serif;
    background: url('https://images.unsplash.com/photo-1509042239860-f550ce710b93') no-repeat center center/cover;
    height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
    position: relative;
    color: #fff;
}

/* Dark overlay over background image */
.overlay {
    background: rgba(0,0,0,0.6);
    position: absolute;
    width: 100%;
    height: 100%;
}

/* Login card styles */
.login-card {
    position: relative;
    background: rgba(58,37,28,0.95);
    padding: 40px;
    border-radius: 20px;
    box-shadow: 0 15px 35px rgba(0,0,0,0.6);
    width: 350px;
    text-align: center;
    z-index: 2;
}

/* Logo and titles */
.logo {
    font-size: 40px;
    margin-bottom: 10px;
}

.cafe-title {
    font-size: 26px;
    font-weight: 700;
    margin-bottom: 25px;
}

/* Cognito login button */
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

.btn-login:hover {
    transform: scale(1.05);
}
</style>
</head>

<body>

<!-- ===================================================
     Overlay for dark effect
=================================================== -->
<div class="overlay"></div>

<!-- ===================================================
     Employee Login Card
=================================================== -->
<div class="login-card">
    <div class="logo">☕</div>
    <div class="cafe-title">Charlie Café Employee</div>
    <p class="mb-4">Welcome back! Please login to access the employee portal.</p>
    
    <!-- Cognito Login Button -->
    <button id="loginBtn" class="btn btn-login">Login with Cognito</button>
</div>

<!-- ===================================================
     Modular JS Files
     - config.js: Contains app settings like Cognito domain, client ID
     - utils.js: Helper functions
     - central-auth.js: Login / Logout functions
     - api.js: Backend API calls
     - central-printing.js: Printing and downloads
=================================================== -->
<script src="config.js"></script>
<script src="utils.js"></script>
<script src="central-auth.js"></script>
<script src="api.js"></script>
<script src="central-printing.js"></script>

<script>
/* ============================================================
   CHARLIE CAFÉ EMPLOYEE LOGIN
   Using Amazon Cognito Hosted UI
   Integrated with modular JS files
============================================================ */

// 🔹 Use config.js variables if you already define them there
// Example: config.COGNITO_DOMAIN, config.CLIENT_ID
const DOMAIN = typeof config !== "undefined" ? config.COGNITO_DOMAIN : "https://YOUR_DOMAIN.auth.us-east-1.amazoncognito.com";
const CLIENT_ID = typeof config !== "undefined" ? config.CLIENT_ID : "YOUR_CLIENT_ID";

// Redirect URI after successful login (employee portal)
const REDIRECT_URI = window.location.origin + "/employee-portal.html";

// Build Hosted UI login URL
const loginUrl = `${DOMAIN}/login?response_type=token&client_id=${CLIENT_ID}&redirect_uri=${encodeURIComponent(REDIRECT_URI)}&scope=email+openid`;

// ============================================================
// Redirect to Cognito Hosted UI when login button clicked
// ============================================================
document.getElementById("loginBtn").addEventListener("click", () => {
    // Optional: log attempt using utils.js
    if (typeof utils !== "undefined") {
        utils.log("Redirecting to Cognito Hosted UI...");
    }

    window.location.href = loginUrl;
});

// ============================================================
// Optional: detect Cognito tokens in URL after login
// Store them using central-auth.js for session handling
// ============================================================
if (window.location.hash) {
    const hash = window.location.hash.substring(1); // remove #
    const params = new URLSearchParams(hash);
    const accessToken = params.get("access_token");
    const idToken = params.get("id_token");
    
    if (accessToken && idToken) {
        if (typeof CHARLIE_AUTH !== "undefined") {
            CHARLIE_AUTH.storeTokens({ accessToken, idToken }); // Save tokens in local/session storage
            // Redirect to employee portal after storing tokens
            window.location.href = "/employee-portal.html";
        }
    }
}
</script>

</body>
</html>
```

---
### ✅ employee-login.html

> **Update Version:1.2**

Got it! You want employee-login.html to fully rely on config.js for Cognito and CloudFront settings, so you don’t have to hardcode or manually update links every time. I’ve cleaned up your code, added comments, ensured it uses config.js, and handles login + redirect properly. Here’s the fully final version:

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Café ☕ | Employee Login</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- ================= BOOTSTRAP & GOOGLE FONTS ================= -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;500;700&display=swap" rel="stylesheet">

<style>
/* ===================== BODY & BACKGROUND ===================== */
body {
    font-family: 'Poppins', sans-serif;
    background: url('https://images.unsplash.com/photo-1509042239860-f550ce710b93') no-repeat center center/cover;
    height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
    color: #fff;
    position: relative;
}
.overlay {
    background: rgba(0,0,0,0.6);
    position: absolute;
    width: 100%;
    height: 100%;
}

/* ===================== LOGIN CARD ===================== */
.login-card {
    position: relative;
    background: rgba(58,37,28,0.95);
    padding: 40px;
    border-radius: 20px;
    width: 350px;
    text-align: center;
    z-index: 2;
    box-shadow: 0 15px 35px rgba(0,0,0,0.6);
}
.logo { font-size: 40px; margin-bottom: 10px; }
.cafe-title { font-size: 26px; font-weight: 700; margin-bottom: 25px; }

/* ===================== LOGIN BUTTON ===================== */
.btn-login {
    background: linear-gradient(135deg,#ff5722,#ff9800);
    border: none; 
    border-radius: 50px;
    padding: 12px; 
    font-weight: 600;
    width: 100%; 
    color: #fff; 
    cursor: pointer;
    transition: 0.3s;
}
.btn-login:hover { transform: scale(1.05); }
</style>
</head>

<body>
<div class="overlay"></div>

<div class="login-card">
    <div class="logo">☕</div>
    <div class="cafe-title">Charlie Café Employee</div>
    <p class="mb-4">Welcome back! Please login to access the portal.</p>
    
    <!-- Login Button -->
    <button id="loginBtn" class="btn btn-login">Login with Cognito</button>
</div>

<!-- ===================== CONFIG + LOGIN SCRIPT ===================== -->
<script src="config.js"></script>
<script>
// ============================================================
// 🔹 Employee Login using Cognito Hosted UI
// ============================================================

// Load Cognito & CloudFront config from config.js
const DOMAIN = window.CHARLIE_CONFIG.COGNITO_DOMAIN;
const CLIENT_ID = window.CHARLIE_CONFIG.CLIENT_ID;
const REDIRECT_URI = window.CHARLIE_CONFIG.CLOUDFRONT_BASE + "/employee-portal.html";

/**
 * Build Cognito Hosted UI login URL
 * Implicit Flow: returns access_token & id_token in URL hash
 */
const loginUrl = `${DOMAIN}/login?response_type=token&client_id=${CLIENT_ID}&redirect_uri=${encodeURIComponent(REDIRECT_URI)}&scope=email+openid+profile`;

// Redirect user to Cognito login when button clicked
document.getElementById("loginBtn").addEventListener("click", () => {
    window.location.href = loginUrl;
});

// ============================================================
// 🔹 Handle redirect back from Cognito after login
// ============================================================

function handleCognitoRedirect() {
    if (window.location.hash) {
        const hash = window.location.hash.substring(1); // remove '#'
        const params = new URLSearchParams(hash);
        const accessToken = params.get("access_token");
        const idToken = params.get("id_token");

        if (accessToken && idToken) {
            // Store tokens securely in sessionStorage
            sessionStorage.setItem("access_token", accessToken);
            sessionStorage.setItem("id_token", idToken);

            // Clear URL hash to prevent re-processing
            window.history.replaceState({}, document.title, window.location.pathname);

            // Redirect to Employee Portal
            window.location.href = REDIRECT_URI;
        }
    }
}

// Execute redirect handling on page load
handleCognitoRedirect();
</script>
</body>
</html>
```

### ✅ What’s fixed & improved:

Fully uses config.js for:

- Cognito domain

- Client ID

- CloudFront base URL

- Login button redirects to Cognito Hosted UI dynamically.

- After Cognito login, tokens (access_token & id_token) are stored in sessionStorage.

- URL hash is cleared after processing to prevent re-login loops.

- Comments added for clarity.
---
### ✅ employee-login.html

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Café ☕ | Employee Login</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- ================= BOOTSTRAP & GOOGLE FONTS ================= -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;500;700&display=swap" rel="stylesheet">

<style>
/* ================= BODY & OVERLAY ================= */
body {
    font-family: 'Poppins', sans-serif;
    background: url('https://images.unsplash.com/photo-1509042239860-f550ce710b93') no-repeat center center/cover;
    height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
    color: #fff;
    position: relative;
}
.overlay {
    background: rgba(0,0,0,0.6);
    position: absolute;
    width: 100%;
    height: 100%;
}

/* ================= LOGIN CARD ================= */
.login-card {
    position: relative;
    background: rgba(58,37,28,0.95);
    padding: 40px;
    border-radius: 20px;
    width: 350px;
    text-align: center;
    z-index: 2;
    box-shadow: 0 15px 35px rgba(0,0,0,0.6);
}
.logo { font-size: 40px; margin-bottom: 10px; }
.cafe-title { font-size: 26px; font-weight: 700; margin-bottom: 25px; }

/* ================= LOGIN BUTTON ================= */
.btn-login {
    background: linear-gradient(135deg,#ff5722,#ff9800);
    border: none; 
    border-radius: 50px;
    padding: 12px; 
    font-weight: 600;
    width: 100%; 
    color: #fff; 
    cursor: pointer;
    transition: 0.3s;
}
.btn-login:hover { transform: scale(1.05); }
</style>
</head>

<body>
<div class="overlay"></div>

<div class="login-card">
    <div class="logo">☕</div>
    <div class="cafe-title">Charlie Café Employee</div>
    <p class="mb-4">Welcome back! Please login to access the portal.</p>
    
    <!-- ================= LOGIN BUTTON ================= -->
    <button id="loginBtn" class="btn btn-login">Login with Cognito</button>
</div>

<!-- ================= CONFIG + LOGIN SCRIPT ================= -->
<script src="/js/config.js"></script>
<script>
/* =========================================================
   🔹 CHARLIE CAFÉ — COGNITO LOGIN
   ---------------------------------------------------------
   This script handles:
   1️⃣ Redirecting users to Cognito Hosted UI (Authorization Code Flow)
   2️⃣ Receiving the authorization code on redirect
   3️⃣ Storing the code in sessionStorage for backend token exchange
========================================================= */

// ======= Cognito config from config.js =======
const DOMAIN = window.CHARLIE_CONFIG.COGNITO_DOMAIN; // e.g., https://us-east-11hpdn6h7f.auth.us-east-1.amazoncognito.com
const CLIENT_ID = window.CHARLIE_CONFIG.CLIENT_ID;    // App Client ID
const REDIRECT_URI = window.CHARLIE_CONFIG.CLOUDFRONT_BASE + "/employee-portal.html"; // must match Cognito App Client
const SCOPE = encodeURIComponent("openid email profile"); // ⚠️ Space-separated, URL-encoded

// ======= Build Cognito Login URL =======
const loginUrl = `${DOMAIN}/login?client_id=${CLIENT_ID}&response_type=code&scope=${SCOPE}&redirect_uri=${encodeURIComponent(REDIRECT_URI)}`;

// ======= Redirect to Cognito Hosted UI on button click =======
document.getElementById("loginBtn").addEventListener("click", () => {
    window.location.href = loginUrl;
});

// ======= Handle redirect back from Cognito with code =======
function handleCognitoCode() {
    const urlParams = new URLSearchParams(window.location.search);
    const code = urlParams.get("code");

    if (code) {
        // ✅ Store code temporarily for backend token exchange
        sessionStorage.setItem("auth_code", code);
        console.log("Authorization code received:", code);

        // OPTIONAL: Call your backend API to exchange code for tokens
        // fetch("/api/exchange-code", { method: "POST", body: JSON.stringify({ code }) })

        // ✅ Clean URL to remove ?code=... from browser
        window.history.replaceState({}, document.title, window.location.pathname);

        // OPTIONAL: Redirect automatically to portal page if needed
        // window.location.href = REDIRECT_URI;
    }
}

// Execute on page load
handleCognitoCode();
</script>
</body>
</html>
```

---
### ✅ employee-login.html



Perfect! I’ve rewritten your employee-login.html with a fully working Cognito login button. This version includes detailed comments, proper Authorization Code Flow, and scope encoding, and handles the redirect back from Cognito.

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Café ☕ | Employee Login</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- ================= BOOTSTRAP & GOOGLE FONTS ================= -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;500;700&display=swap" rel="stylesheet">

<style>
/* ================= BODY & OVERLAY ================= */
body {
    font-family: 'Poppins', sans-serif;
    background: url('https://images.unsplash.com/photo-1509042239860-f550ce710b93') no-repeat center center/cover;
    height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
    color: #fff;
    position: relative;
}
.overlay {
    background: rgba(0,0,0,0.6);
    position: absolute;
    width: 100%;
    height: 100%;
}

/* ================= LOGIN CARD ================= */
.login-card {
    position: relative;
    background: rgba(58,37,28,0.95);
    padding: 40px;
    border-radius: 20px;
    width: 350px;
    text-align: center;
    z-index: 2;
    box-shadow: 0 15px 35px rgba(0,0,0,0.6);
}
.logo { font-size: 40px; margin-bottom: 10px; }
.cafe-title { font-size: 26px; font-weight: 700; margin-bottom: 25px; }

/* ================= LOGIN BUTTON ================= */
.btn-login {
    background: linear-gradient(135deg,#ff5722,#ff9800);
    border: none; 
    border-radius: 50px;
    padding: 12px; 
    font-weight: 600;
    width: 100%; 
    color: #fff; 
    cursor: pointer;
    transition: 0.3s;
}
.btn-login:hover { transform: scale(1.05); }
</style>
</head>

<body>
<div class="overlay"></div>

<div class="login-card">
    <div class="logo">☕</div>
    <div class="cafe-title">Charlie Café Employee</div>
    <p class="mb-4">Welcome back! Please login to access the portal.</p>
    
    <!-- ================= LOGIN BUTTON ================= -->
    <button id="loginBtn" class="btn btn-login">Login with Cognito</button>
</div>

<!-- ================= CONFIG + LOGIN SCRIPT ================= -->
<script src="config.js"></script>
<script>
/* =========================================================
   🔹 CHARLIE CAFÉ — COGNITO LOGIN
   ---------------------------------------------------------
   This script handles:
   1️⃣ Redirecting users to Cognito Hosted UI (Authorization Code Flow)
   2️⃣ Receiving the authorization code on redirect
   3️⃣ Storing the code in sessionStorage for backend token exchange
========================================================= */

// ======= Cognito config from config.js =======
const DOMAIN = window.CHARLIE_CONFIG.COGNITO_DOMAIN; // e.g., https://us-east-11hpdn6h7f.auth.us-east-1.amazoncognito.com
const CLIENT_ID = window.CHARLIE_CONFIG.CLIENT_ID;    // App Client ID
const REDIRECT_URI = window.CHARLIE_CONFIG.CLOUDFRONT_BASE + "/employee-portal.html"; // must match Cognito App Client
const SCOPE = encodeURIComponent("openid email profile"); // ⚠️ Space-separated, URL-encoded

// ======= Build Cognito Login URL =======
const loginUrl = `${DOMAIN}/login?client_id=${CLIENT_ID}&response_type=code&scope=${SCOPE}&redirect_uri=${encodeURIComponent(REDIRECT_URI)}`;

// ======= Redirect to Cognito Hosted UI on button click =======
document.getElementById("loginBtn").addEventListener("click", () => {
    window.location.href = loginUrl;
});

// ======= Handle redirect back from Cognito with code =======
function handleCognitoCode() {
    const urlParams = new URLSearchParams(window.location.search);
    const code = urlParams.get("code");

    if (code) {
        // ✅ Store code temporarily for backend token exchange
        sessionStorage.setItem("auth_code", code);
        console.log("Authorization code received:", code);

        // OPTIONAL: Call your backend API to exchange code for tokens
        // fetch("/api/exchange-code", { method: "POST", body: JSON.stringify({ code }) })

        // ✅ Clean URL to remove ?code=... from browser
        window.history.replaceState({}, document.title, window.location.pathname);

        // OPTIONAL: Redirect automatically to portal page if needed
        // window.location.href = REDIRECT_URI;
    }
}

// Execute on page load
handleCognitoCode();
</script>
</body>
</html>
```

### ✅ Key Points

- Scope Encoding Fixed

```
encodeURIComponent("openid email profile")
```

    - Cognito requires space-separated scopes (not +).

- Redirect URI

    - Must exactly match Cognito App Client’s allowed callback URLs.

- Authorization Code Flow

    - Code is stored in sessionStorage for backend exchange.

    - Exchange must happen server-side to obtain access & ID tokens.

vButton Click

    - Simple window.location.href = loginUrl; redirects to Cognito login page.
---


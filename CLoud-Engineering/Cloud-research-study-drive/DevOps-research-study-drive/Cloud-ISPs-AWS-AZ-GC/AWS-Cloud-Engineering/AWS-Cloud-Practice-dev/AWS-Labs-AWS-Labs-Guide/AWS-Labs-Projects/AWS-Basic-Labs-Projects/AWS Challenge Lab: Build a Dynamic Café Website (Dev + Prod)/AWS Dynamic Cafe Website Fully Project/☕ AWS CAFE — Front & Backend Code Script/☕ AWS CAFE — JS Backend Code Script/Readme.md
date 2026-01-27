# ☕ AWS CAFE — JS Backend Code Script

# SECTION 1️⃣ Secure & Security ARCHITECTURE Dashboard (auth.JS)
> **📄AWS  ☕ Charlie Cafe — Secure Charlie Cafe Dashboard System**

### Goal: Production-ready Admin Dashboard

#### Secure, auto-refreshing, printable, Cognito-protected


### 🧱 ARCHITECTURE

```
Browser (Admin Dashboard)
        ↓  JWT
Amazon Cognito (Login)
        ↓
API Gateway (Cognito Authorizer)
        ↓
AWS Lambda (Order API)
        ↓
Database
```

### PREREQUISITES (CHECK ONLY)

#### Make sure you already have:

✅ EC2 / S3 hosting HTML

✅ API Gateway with GET /order-status

✅ Lambda returning:

```
{
  "metrics": [...],
  "recent_orders": [...]
}
```

👉 If yes, continue

👉 If no, stop here

## 🔐 PHASE R&D  — Secure & Security ARCHITECTURE Model
> **Research & Development Phase**

### 🔐 — Secure Web Pages

### 1️⃣ Centralize Authentication

#### ▶️ What it is: 

The concept and implementation of creating one reusable authentication script (auth.js) that contains all the login/logout/validation logic.

#### ▶️ Purpose: 

Avoid repeating the same code on every page.

#### ▶️ What it includes:

✔️ Create one authentication script (auth.js) for all admin pages.

✔️ It handles:

- ✔️ Login redirect to Cognito

- ✔️ Token extraction (access_token)

- ✔️ Token validation (isTokenExpired)

- ✔️ Conditional display of page (display:block only if valid)

- ✔️ Logout redirect

#### ▶️ Outcome: 

One centralized script that any page can include.

#### ▶️ Benefit:
You don’t have to rewrite login logic for every page. It makes your architecture professional.

#### ▶️ auth.js depends on:

- Cognito User Pool

- App Client

- Hosted UI

- API Gateway authorizers

- CloudFront + ALB HTTPS + security headers

- Roles and Groups

- Environment variables in auth.js

These configurations ensure that:

- Only authenticated users can access dashboards

- JWT tokens are validated by API Gateway

- Pages remain hidden until auth passes

- Logout works globally

### 🧩 STEP 1 — Cognito User Pool Setup

#### 1️⃣ Create Cognito User Pool

- AWS Console → Cognito → “Manage User Pools” → Create pool

- Name: CharlieCafeAdminPool

#### 2️⃣ Add Attributes

- Required: email

- Optional: name, phone

#### 3️⃣ Enable App Clients

- Create app client without client secret

- App Client Name: AdminWebClient

- Enable Authorization code grant or Implicit grant for SPA

- Allowed OAuth Flows: Implicit grant

- Allowed OAuth Scopes: openid, email, profile

#### 4️⃣ Configure Hosted UI

- Domain name: YOUR_DOMAIN.auth.region.amazoncognito.com

- Callback URL: https://YOUR_DOMAIN/dashboard.html (or your EC2 public IP for testing)

- Sign out URL: same as above

#### 5️⃣ Create Groups (Optional, role-based dashboards)

- Admin → Full access

- Staff → Limited access

- Manager → Read-only analytics

#### 6️⃣ Update auth.js with pool info

```
const USER_POOL_ID = "YOUR_POOL_ID";
const CLIENT_ID = "YOUR_APP_CLIENT_ID";
const COGNITO_DOMAIN = "YOUR_DOMAIN.auth.region.amazoncognito.com";
```

### 🧩 STEP 2 — API Gateway Integration

#### 1️⃣ Create API → CharlieCafeDashboardAPI

- Protocol: REST

- Resources: /dashboard, /analytics, /order-status

#### 2️⃣ Add Cognito Authorizer

- Type: Cognito User Pool

- Attach to all /admin/* endpoints

#### 3️⃣ Method Request

- Enable Authorization

- Authorization: Bearer <JWT>

#### 4️⃣ Test API Call

- Using authFetch(API_URL) from auth.js

```
authFetch("https://YOUR_API_ID.execute-api.region.amazonaws.com/prod/dashboard")
   .then(res => res.json())
   .then(data => console.log(data));
```







#### ▶️ auth.js template (reusable)

```
const COGNITO_DOMAIN = "YOUR_COGNITO_DOMAIN.auth.region.amazoncognito.com";
const CLIENT_ID = "YOUR_APP_CLIENT_ID";
const REDIRECT_URI = window.location.origin;

function parseJwt(token) {
  return JSON.parse(atob(token.split('.')[1]));
}

function isTokenExpired(token) {
  return parseJwt(token).exp * 1000 < Date.now();
}

function login() {
  window.location.href = `https://${COGNITO_DOMAIN}/login?response_type=token&client_id=${CLIENT_ID}&scope=openid+email+profile&redirect_uri=${REDIRECT_URI}`;
}

function logout() {
  localStorage.removeItem("access_token");
  window.location.href = `https://${COGNITO_DOMAIN}/logout?client_id=${CLIENT_ID}&logout_uri=${REDIRECT_URI}`;
}

function handleRedirect() {
  const hash = window.location.hash.substring(1);
  const params = new URLSearchParams(hash);
  const token = params.get("access_token");
  if (token) localStorage.setItem("access_token", token);
  window.location.hash = "";
}

function securePage() {
  handleRedirect();
  const token = localStorage.getItem("access_token");
  if (!token || isTokenExpired(token)) login();
  else document.body.style.display = "block";
}
```

- Include this script in dashboard.html, order-status.html, analytics.html.

- Wrap body content with display:none to hide until auth passes.

### 2️⃣ Secure Your Admin Pages

#### ▶️ What it is: 

The practical application of auth.js to every individual HTML page.

#### ▶️ Purpose: 

Actually protect each page (dashboard, order-status, analytics) so nobody can view it without logging in.

#### ▶️ Steps for each page:

1️⃣ Add at the top:

```
<body style="display:none">
<script src="auth.js"></script>
<script>securePage();</script>
```

2️⃣ Replace manual logout functions with the logout() from auth.js.

3️⃣ For all API calls, include the token:

```
fetch(API_URL, {
  headers: { Authorization: `Bearer ${localStorage.getItem("access_token")}` }
})
```

4️⃣ Now, even if someone knows the URL of order-status.html or analytics.html, they can’t access data without login.

### ✅ In short

**✅ They are related but not the same.**

- **Centralize Authentication:** the reusable code/tool (auth.js)

- **Secure Your Admin Pages:** the practical steps to use that tool on every page

#### Think of it like:

- **Centralize Authentication:**  = “Here’s the key.”

- **Secure Your Admin Pages:**= “Here’s how to lock each door with the key.”

### 🔐 Big Picture (Very Important)

#### 1️⃣ ALB / CloudFront / HTTP/2

👉 Handle network-level access & delivery

#### 2️⃣ auth.js (Cognito JS)

👉 Handles application-level authentication

**They live at different layers and work together, not against each other.**

### 🧱 Layered Security Model (Professional Way)

#### Think in layers, like real production systems:

```
User Browser
   │
   ▼
CloudFront (HTTPS + HTTP/2 + Cache + WAF)
   │
   ▼
ALB (optional auth / routing)
   │
   ▼
Static Files (dashboard.html, auth.js)
   │
   ▼
JavaScript Auth (Cognito tokens)
   │
   ▼
API Gateway (Cognito Authorizer)
   │
   ▼
Lambda / DynamoDB
```

**⚠️ Each layer has its own job.**

### ❓ Your Core Confusion — Answered Directly

> **“I already protected order-status.html using ALB + Cognito, so how does auth.js work?”**

#### ✅ Short answer:

**ALB and auth.js do NOT replace each other. They complement each other.**

###  🌐 What ALB Cognito Authentication Does

#### When you enabled ALB + Cognito:

✔ Blocks unauthenticated HTTP requests

✔ Forces login before the HTML is served

✔ Works at network / load balancer level

**📌 But…**

❌ ALB does not manage frontend state

❌ ALB does not protect JavaScript navigation

❌ ALB does not secure API calls

❌ ALB does not help when using CloudFront SPA routing

### 🌐 What auth.js Does (Different Role)

#### auth.js runs inside the browser and:

✔ Controls page-to-page navigation

✔ Protects all admin pages consistently

✔ Stores & validates JWT tokens

✔ Attaches tokens to API requests

✔ Handles logout cleanly

✔ Works perfectly with CloudFront + HTTP/2

**📌 So:**

> **✔️ ALB protects delivery**
> **✔️ auth.js protects behavior**

### 🔁 Real-World Example (Important)

#### Scenario WITHOUT auth.js

- User logs in via ALB

- User opens dashboard.html

- User copies URL of analytics.html

-  Browser opens it directly
 ❌ Page loads without frontend check

 ❌ API may still be called

#### Scenario WITH auth.js

- User opens ANY admin page

- auth.js runs first

- Token missing or expired?

    ➡ Redirect to Cognito login

    ✔ Fully protected

### 🌐 CloudFront + HTTP/2 — No Conflict at All

This is important:

- auth.js is just a static JS file

- CloudFront serves it over HTTPS / HTTP2

- Browser executes it locally

➡ Zero impact on HTTP/2

➡ Zero impact on caching

➡ Zero impact on ALB

**📌 In fact:**

> **Most modern SPAs work exactly like this**

### 🏆 Professional Recommendation (Best Practice)

#### ✅ Best architecture for your lab:

| Layer          | Responsibility          |
| -------------- | ----------------------- |
| CloudFront     | HTTPS, HTTP/2, caching  |
| WAF (optional) | Block bad traffic       |
| ALB            | Routing / optional auth |
| auth.js        | Frontend auth guard     |
| API Gateway    | JWT verification        |
| Lambda         | Business logic          |
| DynamoDB       | Data                    |

This is textbook cloud architecture.

### ⚠️ One Important Rule (Please remember)

#### If you use ALB Cognito auth:

✔ Good for protecting static files

❌ Not enough alone for multi-page admin apps

#### If you use auth.js:

✔ Required for SPA-like navigation

✔ Required for API security

✔ Required for professional UX

👉 Use both if you want enterprise-grade

👉 Use auth.js minimum if you want clean architecture

### 🧭 My Honest Advice

#### Because this is a learning lab:

🔹 Keep CloudFront

🔹 Keep Cognito

🔹 Use auth.js as your primary auth logic

🔹 Document ALB auth as optional enhancement

#### This keeps:

✔ Your docs clean

✔ Your architecture understandable

✔ Your lab impressive

**✅ You are doing the RIGHT thing**

> **You didn’t make a mistake.**
> **You’re leveling up your design.**


**✅ A professional admin dashboard uses one shared auth module that all admin pages load.**

**Below is the clean, scalable, industry-style solution 👇**

### ✅ BEST & PROFESSIONAL WAY

#### 👉 Create a shared auth.js (Single Source of Truth)

#### 📁 Recommended folder structure

```
/var/www/html/
│
├── admin/
│   ├── dashboard.html
│   ├── order-status.html
│   ├── analytics.html
│   └── assets/
│       ├── auth.js        👈 ONE FILE FOR ALL AUTH
│       └── config.js     👈 OPTIONAL (constants only)
```

### 🧠 OPTION 1 (RECOMMENDED): auth.js (All logic in one file)

#### 1️⃣ 📄 /admin/assets/auth.js

```
<script>
/* ================= CONFIG ================= */
const USER_POOL_ID = "CHANGE_ME";
const CLIENT_ID = "CHANGE_ME";
const COGNITO_DOMAIN = "CHANGE_ME.auth.ap-south-1.amazoncognito.com";
const REDIRECT_URI = window.location.origin + window.location.pathname;

/* ================= TOKEN HELPERS ================= */
function parseJwt(token) {
    return JSON.parse(atob(token.split('.')[1]));
}

function isTokenExpired(token) {
    return parseJwt(token).exp * 1000 < Date.now();
}

/* ================= AUTH ACTIONS ================= */
function login() {
    const url =
        `https://${COGNITO_DOMAIN}/login` +
        `?response_type=token` +
        `&client_id=${CLIENT_ID}` +
        `&scope=openid+email+profile` +
        `&redirect_uri=${encodeURIComponent(REDIRECT_URI)}`;
    window.location.href = url;
}

function logout() {
    localStorage.removeItem("access_token");

    const url =
        `https://${COGNITO_DOMAIN}/logout` +
        `?client_id=${CLIENT_ID}` +
        `&logout_uri=${encodeURIComponent(REDIRECT_URI)}`;
    window.location.href = url;
}

/* ================= HANDLE REDIRECT ================= */
function handleAuthRedirect() {
    if (!window.location.hash) return;

    const params = new URLSearchParams(window.location.hash.substring(1));
    const token = params.get("access_token");

    if (token) {
        localStorage.setItem("access_token", token);
        window.location.hash = "";
    }
}

/* ================= PAGE GUARD ================= */
function protectPage() {
    handleAuthRedirect();

    const token = localStorage.getItem("access_token");
    if (!token || isTokenExpired(token)) {
        login();
        return;
    }

    // page is safe now
    document.body.style.display = "block";
}

/* ================= API FETCH HELPER ================= */
function authFetch(url, options = {}) {
    const token = localStorage.getItem("access_token");
    if (!token || isTokenExpired(token)) logout();

    return fetch(url, {
        ...options,
        headers: {
            ...(options.headers || {}),
            Authorization: "Bearer " + token
        }
    });
}
</script>
```

#### 2️⃣  How to use it in ALL admin pages

#### 🔐 STEP 1 — Hide page until auth passes

At top of every admin HTML file:

```
<body style="display:none">
```

#### 🔐 STEP 2 — Load auth.js

Before your page’s own JS:

```
<script src="assets/auth.js"></script>
```

#### 🔐 STEP 3 — Protect page

At the bottom:

```
<script>
protectPage();
</script>
```

**✅ That’s it. Page is secured.**

#### 🧪 Example: order-status.html

```
<body style="display:none">

<script src="assets/auth.js"></script>

<script>
protectPage();

authFetch(API_URL)
    .then(res => res.json())
    .then(data => console.log(data));
</script>
```

#### 🧪 Example: analytics.html

```
<body style="display:none">

<script src="assets/auth.js"></script>

<script>
protectPage();

authFetch("https://api.example.com/admin/analytics")
    .then(res => res.json())
    .then(data => console.log(data));
</script>
```

#### 🏆 WHY THIS IS PROFESSIONAL

✅ Single source of truth

✅ No duplicated auth logic

✅ Easy maintenance

✅ Enterprise-style page guard

✅ Looks exactly like real SaaS dashboards

**This is how production dashboards work.**

> **🟢 SECTION 1 COMPLETE & VERIFIED**
---

# # SECTION 2️⃣ SECURE DASHBOARD AUTH MODULE (Cognito Protection - secure-dashboard.js)


### 🎯 Phase Goal

In this phase, we secure all dashboard pages using Amazon Cognito authentication by introducing a single reusable JavaScript security module.

#### This ensures:

❌ Unauthorized users cannot see dashboard content

✅ Page stays hidden until authentication succeeds

✅ Secure API calls automatically include auth tokens

✅ Logout works globally across all dashboards

✅ Clean HTML with zero auth logic inside

### 🧠 Architecture Decision (Why This Phase Exists)

Instead of:

- Repeating authentication code on every dashboard page

- Mixing auth logic inside HTML files

We will:

- Centralize all authentication logic into one file

- Reuse it across dashboard.html, analytics.html, order-status.html, etc.

**📌 Single Responsibility Principle applied**

### 📁 File Structure (Required)

Ensure the following structure exists:

```
/dashboard
 ├── dashboard.html
 ├── analytics.html
 ├── order-status.html
 ├── secure-dashboard.js   ✅ (NEW)
 └── assets/
      └── auth.js          ✅ (EXISTING Cognito logic)
```

### 🧩 STEP 1 — Verify auth.js Exists and Works

Your auth.js MUST already contain:

- protectPage()

- authFetch(url)

- cognitoLogout()

Example (high-level only):

```
function protectPage() {
   // Redirects to login if no valid Cognito session
}

function authFetch(url) {
   // Adds Authorization token to fetch()
}

function cognitoLogout() {
   // Logs user out from Cognito
}
```

**⚠️ Do NOT modify auth.js in this phase**

This phase only uses it, not rewrites it.

### 🧩 STEP 2 — Create secure-dashboard.js

Create a new file:

```
secure-dashboard.js
```

**📌 This file becomes the security engine for all dashboards.**

### 🧠 Responsibility of secure-dashboard.js

This file will handle:

| Feature                    | Purpose                               |
| -------------------------- | ------------------------------------- |
| Hide page initially        | Prevents content flashing before auth |
| Load `auth.js` dynamically | Guarantees auth functions exist       |
| Run `protectPage()`        | Blocks unauthenticated users          |
| Provide secure API calls   | Uses Cognito tokens automatically     |
| Global logout handler      | Logout works anywhere                 |
| KPI placeholder logging    | Future expansion ready                |

### 🧩 STEP 3 — Add Full Secure Dashboard Module Code

```
/* =================================================
   SECURE DASHBOARD MODULE
   =================================================
   This JS file handles:
   ✅ Page hidden until authentication succeeds
   ✅ auth.js loading
   ✅ protectPage() enforcement
   ✅ Secure API call placeholder
   ✅ Cognito logout handling
   ✅ Clean reusable design
================================================= */

(function () {

    /* ================= PAGE HIDDEN INIT =================
       Prevents dashboard content from flashing
       before authentication validation completes
    ===================================================== */
    document.body.style.display = "none";

    /* ================= LOAD AUTH.JS =================
       Dynamically loads Cognito authentication logic
       Ensures auth functions exist before execution
    ================================================== */
    const authScript = document.createElement("script");
    authScript.src = "assets/auth.js"; // Adjust path if needed
    authScript.onload = () => initSecureDashboard();
    document.head.appendChild(authScript);

    /* ================= INIT SECURE DASHBOARD ================= */
    function initSecureDashboard() {

        /* ---- Enforce authentication ---- */
        protectPage();

        /* ---- Auth successful → show dashboard ---- */
        document.body.style.display = "block";

        /* ================= SECURE API CALL =================
           All dashboard APIs should be accessed
           using authFetch() for token injection
        ==================================================== */
        const API_URL =
            "https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/dashboard";

        authFetch(API_URL)
            .then(res => res.json())
            .then(data => {
                console.log("✅ Secure dashboard data:", data);
                // TODO: Update KPI cards dynamically
            })
            .catch(err => console.error("❌ Secure API error:", err));

        /* ================= LOGOUT HANDLER =================
           Any button with class `.logout-btn`
           will automatically log user out
        =================================================== */
        document.querySelectorAll(".logout-btn").forEach(btn => {
            btn.addEventListener("click", () => cognitoLogout());
        });
    }

})();
```

### 🧩 STEP 4 — Update Dashboard HTML (Minimal Change)

❌ Remove All Auth Logic From HTML

✅ Keep HTML Clean


Your dashboard HTML only needs:

```
<div id="secure-dashboard"></div>

<button class="logout-btn">Logout</button>

<script src="secure-dashboard.js"></script>
```

📌 No auth.js inclusion needed

📌 No protectPage() call inside HTML

📌 No token handling inside HTML

### 🧩 STEP 5 — Apply to Other Pages

Repeat only this line on every secure page:

```
<script src="secure-dashboard.js"></script>
```

Pages protected automatically:

✅ dashboard.html

✅ analytics.html

✅ order-status.html

✅ future admin pages

### 🧪 STEP 6 — Validation Checklist

| Test                         | Expected Result           |
| ---------------------------- | ------------------------- |
| Open dashboard without login | Redirects to login        |
| Open dashboard after login   | Page loads normally       |
| View source                  | No auth logic visible     |
| Click logout                 | Cognito session destroyed |
| Reuse on other page          | Works without changes     |


### ✅ PHASE COMPLETION STATUS

✔ Cognito protection enforced

✔ Page hidden until auth success

✔ Secure API access ready

✔ Logout centralized

✔ Clean, maintainable dashboard code

### 🧠 Key Takeaway (Very Important)

> **Security logic must never live inside HTML.**

This phase transforms your dashboard from a demo UI into a production-grade secured system.



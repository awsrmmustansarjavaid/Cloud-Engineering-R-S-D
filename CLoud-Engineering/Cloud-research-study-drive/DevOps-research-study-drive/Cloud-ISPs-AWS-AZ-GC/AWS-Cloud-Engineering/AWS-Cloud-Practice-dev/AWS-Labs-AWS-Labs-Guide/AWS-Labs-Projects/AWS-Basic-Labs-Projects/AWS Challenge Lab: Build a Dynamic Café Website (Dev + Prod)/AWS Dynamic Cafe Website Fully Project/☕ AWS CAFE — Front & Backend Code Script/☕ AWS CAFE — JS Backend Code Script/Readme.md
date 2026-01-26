# ☕ AWS CAFE — JS Backend Code Script

# SECTION 1️⃣ Secure & Security ARCHITECTURE Dashboard
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
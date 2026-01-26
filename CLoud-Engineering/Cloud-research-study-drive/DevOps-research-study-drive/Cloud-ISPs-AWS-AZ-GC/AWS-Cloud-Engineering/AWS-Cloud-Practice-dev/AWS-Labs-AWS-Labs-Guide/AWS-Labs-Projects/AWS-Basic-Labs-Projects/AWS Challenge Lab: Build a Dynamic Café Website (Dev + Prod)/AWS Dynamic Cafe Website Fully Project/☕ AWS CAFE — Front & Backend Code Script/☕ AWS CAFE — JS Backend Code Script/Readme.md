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



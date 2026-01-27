# AWS  ☕ Charlie Cafe — Secure Charlie Cafe Dashboard System

### Goal: Production-ready Admin Dashboard

#### Secure, auto-refreshing, printable, Cognito-protected

# SECTION 2️⃣ Secure Admin Order Dashboard


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

## 🔐 PHASE  1️⃣ — PREREQUISITES (CHECK ONLY)

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


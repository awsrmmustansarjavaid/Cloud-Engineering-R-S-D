# Charlie Cafe - Central Auth API 

### 🧠 BIG PICTURE (READ THIS FIRST)

You now have TWO central auth systems, each with a clear job:

### 🖥️ Frontend — central-auth-api.js

Responsible for:

Login / Logout

Storing token

Attaching token to API calls

Hiding pages from wrong users (UX)

#### ❌ Frontend does NOT enforce security
#### ✅ It only helps user experience

### ☁️ Backend — rbac.py

Responsible for:

Reading Cognito claims (from API Gateway)

Deciding who can access which API

Blocking access (REAL security)

#### ✅ Backend is the final authority

### 🔒 API Gateway (THE BRIDGE)

Validates JWT with Cognito

Passes user info to Lambda

Calls your Lambda

### 🧩 FINAL FLOW (THIS IS THE KEY)

```
Browser
  ↓
central-auth-api.js
  ↓ Authorization: Bearer <JWT>
API Gateway
  ↓ (Cognito Authorizer validates token)
Lambda
  ↓
rbac.py → ALLOW or DENY
```


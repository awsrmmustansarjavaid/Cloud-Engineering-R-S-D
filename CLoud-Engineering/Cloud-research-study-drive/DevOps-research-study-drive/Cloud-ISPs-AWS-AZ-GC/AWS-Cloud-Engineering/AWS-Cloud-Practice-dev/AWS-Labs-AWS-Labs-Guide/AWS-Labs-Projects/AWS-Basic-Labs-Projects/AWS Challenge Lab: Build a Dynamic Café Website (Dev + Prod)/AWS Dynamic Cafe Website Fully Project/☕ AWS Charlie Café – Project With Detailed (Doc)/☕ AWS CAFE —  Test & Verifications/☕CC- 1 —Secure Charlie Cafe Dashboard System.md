# AWS  ☕ Charlie Cafe — Secure Charlie Cafe Dashboard System

FULL PROFESSIONAL VERIFICATION CHECKLIST for new Cognito + API architecture.

# SECTION 1️⃣ Secure Admin Order Dashboard



### ✅ Role Enforcement Tests

VERY IMPORTANT.

### ✅ TEST 8 — Admin Access Test

- Login as: cafeadmin

- Test: /admin/dashboard

#### ✅ Expected:

```
200 OK
JSON data
``` 

### ✅ TEST 9 — Employee Access to Admin Route

- Login as: ali

- Test: /admin/dashboard

#### ✅ Expected:

```
403 Forbidden
```

If employee can access → Lambda group check broken.

### ✅ TEST 10 — Employee Route Access

- Login as: ali

- Test: /employee/orders

#### ✅ Expected:

```
200 OK
JSON data
``` 

### ✅ TEST 11 — Manager Mixed Access

- Login as: manager1

- Test: 

| Route            | Expected |
| ---------------- | -------- |
| /admin/dashboard | ❌ 403    |
| /admin/orders    | ✅ 200    |
| /employee/orders | ✅ 200    |

If behavior wrong → fix allowed_groups in Lambda.

## 🔐 TEST 12 — Token Expiry Test

- Wait for token expiry (or manually modify exp).

- Then call protected route.

#### ✅ Expected:

- 401 Unauthorized

#### ✅ Your frontend should:

- detect expired token

- auto logout

- redirect to login

## 🔐 TEST 13 — Refresh Token Test

After 1 hour:

- Access token expires.

#### ✅ Your frontend should:

- use refresh_token

- get new access token

- not force logout

- If refresh fails → check:

- ALLOW_REFRESH_TOKEN_AUTH enabled.

## 🔐 TEST 14 — Security Negative Testing (Professional Level)

### 🧪 Test A — Modify JWT Payload

- Change group in JWT manually.

- - Send request.

#### ✅ Expected:

- 401 (signature invalid)

If 200 → serious security problem.

### 🧪 Test B — Remove Group Check in Lambda (temporarily)

- Call route.

- Should still require valid JWT.

This proves API Gateway authorizer works.


### 🔐 TEST 15 — EASIEST WAY TO GET ACCESS TOKEN (Manual Test)

You asked for easiest method.

Here is the clean method.


### 🟢 STEP 1 — Build Login URL

In browser:

```
https://YOUR_DOMAIN.auth.us-east-1.amazoncognito.com/login
?client_id=YOUR_CLIENT_ID
&response_type=code
&scope=openid+email+profile
&redirect_uri=https://YOUR_CLOUDFRONT/login.html
```

Press Enter.

### 🟢 STEP 2 — Login

Enter username/password.

You will be redirected to:

```
https://YOUR_CLOUDFRONT/login.html?code=XYZ123
```

### 🟢 STEP 3 — Exchange Code for Tokens (Manual Method)

Open browser DevTools → Console

Run:

```
fetch("https://YOUR_DOMAIN.auth.us-east-1.amazoncognito.com/oauth2/token", {
  method: "POST",
  headers: {
    "Content-Type": "application/x-www-form-urlencoded"
  },
  body: new URLSearchParams({
    grant_type: "authorization_code",
    client_id: "YOUR_CLIENT_ID",
    code: "PASTE_CODE_FROM_URL",
    redirect_uri: "https://YOUR_CLOUDFRONT/login.html"
  })
})
.then(res => res.json())
.then(console.log);
```

You will receive:

```
{
  access_token: "...",
  id_token: "...",
  refresh_token: "...",
  expires_in: 3600
}
```

Copy access_token.

### 🔥 EVEN EASIER METHOD (Old Implicit Way – Testing Only)

If you temporarily enable:

```
Implicit grant
```

Then use:

```
response_type=token
```

Then after login you will be redirected with:

```
#access_token=xxxx
```

This is easiest for quick manual testing.

But production → Authorization Code is correct.

**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---
## 🔐 PHASE 2️⃣ — API Gateway Authorizer Test

### ✅ TEST 1 — Protected Route Without Token

#### Quick API Test

In browser console:

```
fetch("https://YOUR_API_ID.execute-api.us-east-1.amazonaws.com/prod/admin/orders", {
  headers: {
    Authorization: "Bearer YOUR_ACCESS_TOKEN"
  }
})
.then(res => res.json())
.then(console.log);
```

#### ✅ Expected:

```
200 if allowed
403 if wrong group
401 if invalid token
```

- Open browser:

```
https://API_ID.execute-api.us-east-1.amazonaws.com/prod/admin/orders
```

#### ✅ Expected:

```
401 Unauthorized
```

If it returns data → authorizer NOT attached correctly.

### ✅ TEST 2 — Protected Route With Token (Browser Console)

In DevTools:

```
fetch("https://API_ID.execute-api.us-east-1.amazonaws.com/prod/admin/orders", {
  headers: {
    Authorization: "Bearer YOUR_ACCESS_TOKEN"
  }
})
.then(res => res.json())
.then(console.log)
```

#### ✅ Expected:

```
200 OK
JSON data
```

If 401 → token invalid

If 403 → Lambda group check blocked

### ✅ TEST 3 — Public Route Without Token

Test:

```
/public/orders
```

#### ✅ Expected:

```
200 OK
JSON data
``` 
No token required.

### ✅ TEST 4 — Public Route With Invalid Token

Even if header sent:

```
Authorization: Bearer fake
```

Should still work (since no authorizer attached).

### 1️⃣ Test Cognito Authorizer

#### Call Admin Route

```
curl https://<api-id>.execute-api.<region>.amazonaws.com/admin/dashboard \
  -H "Authorization: <ACCESS_TOKEN>"
```

#### Results

| User group | Result |
| ---------- | ------ |
| admin      | ✅ 200  |
| employee   | ❌ 403  |
| no token   | ❌ 401  |

### 2️⃣ Test Lambda

- #### Inside Lambda:

```
event["requestContext"]["authorizer"]["claims"]["cognito:groups"]
```

#### Example:

```
["admin"]
```

or

```
["employee"]
```

#### Summary

| Question                 | Answer               |
| ------------------------ | -------------------- |
| Do I need REST API?      | ❌ NO                 |
| Should I use HTTP API?   | ✅ YES                |
| Where are routes?        | API Gateway → Routes |
| Are routes auto-created? | ❌ NO                 |
| Attach authorizer where? | On EACH route        |
| One Lambda or many?      | ✅ ONE                |

### 3️⃣ FINAL TEST TEST LAMBDA & API (MATCHES YOUR GUIDE)

#### 1️⃣ ❌ Without token

```
curl https://API_ID.execute-api.REGION.amazonaws.com/status/order-status
```

#### ✅ Expected:

```
401 Unauthorized
```

#### 2️⃣ ✅ With Frontend Token

- Login via Cognito Hosted UI

- Get a JWT access token

- Call API Gateway with

```
Authorization: Bearer <access_token>
```

- ✅ Receive JSON response

### 4️⃣ GET /admin/dashboard

```
GET https://<api-id>.execute-api.us-east-1.amazonaws.com/status/admin/dashboard
Authorization: Bearer <token>
```

### 5️⃣ POST /admin/create-user

```
POST https://<api-id>.execute-api.us-east-1.amazonaws.com/status/admin/create-user
Authorization: Bearer <token>
Content-Type: application/json

{
  "username": "john.doe",
  "role": "employee"
}
```

### 6️⃣ GET /employee/orders

```
GET https://<api-id>.execute-api.us-east-1.amazonaws.com/status/employee/orders?employee_id=alice
Authorization: Bearer <token>
```

### 7️⃣ POST /employee/order

```
POST https://<api-id>.execute-api.us-east-1.amazonaws.com/status/employee/order
Authorization: Bearer <token>
Content-Type: application/json

{
  "order_id": "O-103",
  "employee": "alice",
  "items": [
    { "name": "Latte", "quantity": 2, "price": 5 },
    { "name": "Bagel", "quantity": 1, "price": 3 }
  ],
  "total": 13
}
```

### 8️⃣ Test each endpoint

Test each endpoint using Postman or browser:

```
GET https://<api-id>.execute-api.us-east-1.amazonaws.com/prod/admin/dashboard
GET https://<api-id>.execute-api.us-east-1.amazonaws.com/prod/employee/orders
GET https://<api-id>.execute-api.us-east-1.amazonaws.com/prod/order-status?order_id=123
```

**✅ You should get responses from respective Lambda functions.**


**✅ After this, your API Gateway + Lambda + front-end integration is fully professional, secure, and working.**


**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**
---
## 🔐 PHASE 3️⃣ Lambda Functions 

### 4️⃣ Lambda Code Test

- Name:

```
Test_OrderStatusLambda
```

#### JSON

```
{}
```
#### Expected Result

```
{
  "statusCode": 200,
  "headers": {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Authorization",
    "Access-Control-Allow-Methods": "GET"
  },
```

#### ✅ Result:

```
/order-status?date=YYYY-MM-DD
```

✅ returns filtered orders

### 5️⃣ Lambda Code Test

- Name:

```
Test_AdminDashboardLambda
```

#### JSON

```
{}
```

#### ✅ Expected Result

```
  "statusCode": 200,
```

### 6️⃣ Lambda Code Test

- Name:

```
Test_AdminCreateUserLambda
```

#### JSON

```
{
  "body": "{\"username\": \"john.doe\", \"role\": \"employee\"}"
}
```

#### ✅ Expected Result

```
  "statusCode": 200,
```

### 7️⃣ Lambda Code Test

- Name:

```
Test_EmployeeOrdersLambda
```

#### JSON

```
{
  "queryStringParameters": {
    "employee_id": "alice"
  }
}
```

#### ✅ Expected Result

```
  "statusCode": 200,
```

### 8️⃣ Lambda Code Test

- Name:

```
Test_EmployeeOrderLambda
```

#### JSON

```
{
  "order_id": "O-103",
  "employee": "alice",
  "items": [
    { "name": "Latte", "quantity": 2, "price": 5 },
    { "name": "Bagel", "quantity": 1, "price": 3 }
  ],
  "total": 13
}
```

#### ✅ Expected Result

```
  "statusCode": 200,
```

### 9️⃣ Verification

- Go to Lambda → Monitoring → View Logs

- Check CloudWatch Logs for each Lambda

#### Confirm:

- /admin/dashboard → AdminDashboardLambda response

- /admin/create-user → AdminCreateUserLambda response

- /employee/orders → EmployeeOrdersLambda response

- /employee/order → EmployeeOrderLambda response

#### Test JWT Authorization:

- Access without token → should fail

- Access with token → should succeed

**✅ After this, your API Gateway + Lambda + front-end integration is fully professional, secure, and working.**

**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---


### 🏁 FINAL VERIFICATION CHECKLIST

✔ User pool correct

✔ Public client

✔ Authorization code flow

✔ Groups assigned

✔ Hosted UI works

✔ Token stored

✔ JWT contains groups

✔ API Gateway blocks unauthorized

✔ Lambda blocks wrong roles

✔ Public routes open

✔ Protected routes secured

✔ Expired token rejected

✔ Refresh works

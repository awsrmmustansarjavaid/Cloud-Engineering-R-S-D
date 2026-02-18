# AWS  ☕ Charlie Cafe — Secure Charlie Cafe Dashboard System

FULL PROFESSIONAL VERIFICATION CHECKLIST for new Cognito + API architecture.

# SECTION 1️⃣ Secure Admin Order Dashboard

This is exactly how a real production deployment is validated.

We will test:

- Cognito infrastructure

- Hosted UI login

- JWT token correctness

- API Gateway authorizer

- Lambda role enforcement

- Public vs Protected separation

- Failure scenarios (VERY important)

All based on:

- Amazon Cognito

- Amazon API Gateway

- AWS Lambda

## 🔐 PHASE 1️⃣ — Cognito Authentication infrastructure 

### ✅ TEST 1 — User Pool Exists

- Go to: Cognito → User Pools

#### ✅ Verify:

✔ Your pool exists

✔ Region correct (us-east-1)

✔ Status = Active

### ✅ TEST 2 — App Client Configuration

- Go to: User Pool → App clients → Show details

Verify:

| Setting                  | Must Be                |
| ------------------------ | ---------------------- |
| App type                 | Public client          |
| Client secret            | ❌ Disabled             |
| Authorization code grant | ✅ Enabled              |
| Implicit grant           | ❌ Disabled             |
| Scopes                   | openid, email, profile |

If any mismatch → fix before continuing.

### ✅ TEST 3 — Callback & Logout URLs

- Go to: User Pool → App integration → App client → Edit

#### ✅ Verify EXACT match:

```
https://YOUR_CLOUDFRONT/login.html
https://YOUR_CLOUDFRONT/logout.html
```

⚠ Must match character by character

⚠ https required

⚠ No trailing slash difference

- Save → wait 60 seconds.

### ✅ TEST 4 — Groups & Users

- Go to: User Pool → Groups

#### ✅ Verify:

✔ Admin

✔ Manager

✔ Employee

#### ✅ Now check:

- User Pool → Users

- Open each user → Groups tab

#### ✅ Verify:

| User      | Group    |
| --------- | -------- |
| cafeadmin | Admin    |
| manager1  | Manager  |
| ali       | Employee |


If group missing → JWT will not contain cognito:groups.

### ✅ TEST 5 — Manual Login URL

#### ✅ Construct this in browser:

```
https://YOUR_DOMAIN.auth.us-east-1.amazoncognito.com/login
?client_id=YOUR_CLIENT_ID
&response_type=code
&scope=openid+email+profile
&redirect_uri=https://YOUR_CLOUDFRONT/login.html
```

- Open in browser.

#### ✅ Expected:

✔ Cognito login page appears

✔ Enter credentials

✔ Redirects to:

```
https://YOUR_CLOUDFRONT/login.html?code=XYZ123
```

If you see error:

"invalid_request" → check callback URL

"unauthorized_client" → wrong OAuth flow

redirect mismatch → fix exact URL

### 🔐 TEST 6 — Token Exchange Verification

- Now your frontend must exchange code → tokens.

- After exchange, verify:

- Open DevTools → Application → Local Storage

You must see:

```
access_token
id_token
refresh_token
```

If missing → your frontend token exchange is wrong.

### ✅ TEST 7 — Decode Token

> **Verify Token Is Valid**

- Copy access_token.

- Go to [jwt.io](https://jwt.io)

- Paste access_token.

#### ✅ Verify:

- Payload contains:

You see:

```
"cognito:groups"
"email"
"sub"
"exp"
```

If cognito:groups missing → user not assigned to group.


**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---
## 🔐 PHASE 4 — API Gateway Authorizer Test

### ✅ TEST 7 — Protected Route Without Token

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

### ✅ TEST 8 — Protected Route With Token (Browser Console)

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

## 🔐 PHASE 5 — Role Enforcement Tests

VERY IMPORTANT.

### ✅ TEST 9 — Admin Access Test

- Login as: cafeadmin

- Test: /admin/dashboard

#### ✅ Expected:

```
200 OK
JSON data
``` 

### ✅ TEST 10 — Employee Access to Admin Route

- Login as: ali

- Test: /admin/dashboard

#### ✅ Expected:

```
403 Forbidden
```

If employee can access → Lambda group check broken.

### ✅ TEST 11 — Employee Route Access

- Login as: ali

- Test: /employee/orders

#### ✅ Expected:

```
200 OK
JSON data
``` 

### ✅ TEST 12 — Manager Mixed Access

- Login as: manager1

- Test: 

| Route            | Expected |
| ---------------- | -------- |
| /admin/dashboard | ❌ 403    |
| /admin/orders    | ✅ 200    |
| /employee/orders | ✅ 200    |

If behavior wrong → fix allowed_groups in Lambda.

## 🔐 PHASE 6 — Public Routes Verification

### ✅ TEST 13 — Public Route Without Token

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

### ✅ TEST 14 — Public Route With Invalid Token

Even if header sent:

```
Authorization: Bearer fake
```

Should still work (since no authorizer attached).

## 🔐 PHASE 7 — Token Expiry Test

- Wait for token expiry (or manually modify exp).

- Then call protected route.

#### ✅ Expected:

- 401 Unauthorized

#### ✅ Your frontend should:

- detect expired token

- auto logout

- redirect to login

## 🔐 PHASE 8 — Refresh Token Test

After 1 hour:

- Access token expires.

#### ✅ Your frontend should:

- use refresh_token

- get new access token

- not force logout

- If refresh fails → check:

- ALLOW_REFRESH_TOKEN_AUTH enabled.

## 🔐 PHASE 9 — Security Negative Testing (Professional Level)

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


### 🔐 PART 12 — EASIEST WAY TO GET ACCESS TOKEN (Manual Test)

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

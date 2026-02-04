# AWS  ☕ Charlie Cafe — Secure Charlie Cafe Dashboard System



# SECTION 1️⃣ Secure Admin Order Dashboard

## 🔐 PHASE 1️⃣ — Set Up Automatic HTTP → HTTPS Redirection

### 1️⃣  — USE EC2 PUBLIC IP (BEST FOR LAB)

> **This is 100% acceptable for labs and Cognito testing**

#### STEP 1️⃣ — CONFIRM EC2 IS PUBLIC

#### 1️⃣ Go to:

```
EC2 → Instances
```

#### 2️⃣ Select your instance

#### 3️⃣ Copy:

```
Public IPv4 address
```

Example:

```
54.183.22.10
```

#### ⚠️ If you do NOT see a public IP:

- Instance must be in a public subnet

- Must have Internet Gateway

#### STEP 2️⃣ — CONFIRM APACHE IS RUNNING

#### SSH into EC2:

```
sudo systemctl status httpd
```

#### If not running:

```
sudo systemctl start httpd
```

```
sudo systemctl enable httpd
```

#### STEP 3️⃣ — TEST PAGE DIRECTLY

#### Open browser:

```
http://54.183.22.10/cafe-admin-dashboard.html
```

✅ If page opens → PERFECT

❌ If not → check Security Group


#### STEP 4️⃣ — FIX SECURITY GROUP (VERY IMPORTANT)

#### 1️⃣ Go to:

```
EC2 → Security Groups → Your SG
```

#### 2️⃣ Inbound rules:

```
HTTP   TCP   80   0.0.0.0/0
```

Save

#### STEP 5️⃣ — USE THIS AS RETURN URL IN COGNITO

Now you FINALLY have a valid Return URL.

#### Use:

```
http://54.183.22.10/cafe-admin-dashboard.html
```

**⚠️ BUT Cognito REQUIRES HTTPS**

> **So for Cognito we must do ONE SMALL CHANGE**

#### STEP 6️⃣  — TEST ALB DNS WEB PAGE

Open:

```
https://ALB-DNS/cafe-admin-dashboard.html
```

✅ Works → DONE

#### STEP 6️⃣  — TEST cloudfront

#### 1️⃣ Basic Connectivity Test

Open in browser:

```
https://xxxxx.cloudfront.net/
```

#### Expected result:

```
order-status.html loads
OR

Cafe homepage loads (if root object not set)
```

#### 2️⃣ Direct File Test

Open:

```
https://xxxxx.cloudfront.net/cafe-admin-dashboard.html
```

#### Expected:

```
Page loads successfully

No 403 / 504 / timeout errors
```

#### 3️⃣ Backend Health Verification

If CloudFront fails:

Test ALB directly:

```
http://ALB-DNS-NAME/cafe-admin-dashboard.html
```

#### Ensure:

- ALB target group = Healthy

- EC2 Apache is running

- Security Groups allow ALB → EC2 (port 80)

#### ✅ FINAL RECOMMENDED PATH

| Step       | Do this                        |
| ---------- | ------------------------------ |
| Host page  | EC2 Apache                     |
| HTTPS      | ALB                            |
| Return URL | ALB DNS + `/cafe-admin-dashboard.html` |
| CloudFront | Later (optional)               |

**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---
## 🔐 PHASE 2️⃣ — Cognito Authentication infrastructure 
> **🔐 COGNITO INTEGRATION (PRODUCTION READY)**

### ❗  PASSWORD IS “INACTIVE” + SNS ERROR (Optional)

> **This is a REAL AWS SERVICE ISSUE, not a mistake.**

#### 🚨 ERROR YOU GOT

```
[UserError] Failed to get SNS sandbox status for account
```

### ❓ Why this happens

#### Cognito depends on Amazon SNS for:

- SMS

- MFA

- Some passwordless / choice-based sign-in features

#### Your AWS account:

❌ SNS sandbox not initialized

❌ SMS not approved

❌ Region mismatch possible

**🔐 So AWS disables choice-based sign-in → password**


### 🔴 IMPORTANT CLARIFICATION

> **❗ You do NOT need “Options for choice-based sign-in” for your project**

#### Your lab uses:

```
Username + Password
Hosted UI
OAuth tokens
```

#### NOT:

- Passwordless

- Passkeys

- SMS login

**🔐 So this section is NOT REQUIRED**

### ✅ WHAT YOU SHOULD DO (CORRECT ACTION)

### 🔹 OPTION 1 — IGNORE IT (RECOMMENDED)

#### ✔ Leave:

```
Options for choice-based sign-in
Passwordless status: Inactive
```

**👉 Your Cognito login WILL STILL WORK**

#### This setting does NOT affect:

- Hosted UI login

- Username/password

- Token generation

- API Gateway authorizer

### 🔹 OPTION 2 — FIX SNS (ONLY IF YOU WANT)

> **This is advanced and NOT needed for your lab, but for completeness:**

#### 1️⃣ Go to:

```
Amazon SNS → Text messaging (SMS)
```

#### 2️⃣ Request:

```
Exit SMS sandbox
```

#### 3️⃣ Add billing details

#### 4️⃣ Wait for AWS approval (hours/days)

**⚠️ Not recommended for labs**

### 🌐 AWS Cognito Callback URL – Step-by-Step (Fix HTTP 400)

#### 1️⃣ Find the REAL page URL

Open your admin page in the browser and copy the exact full URL from the address bar.

Example:

```
https://d2og2zrs47voou.cloudfront.net/cafe-admin-dashboard.html
```

#### ⚠️ Must include:

- https vs http

- domain

- file name

- NO extra slash

#### 2️⃣ Go to Cognito App Client

- AWS Console → Cognito → User Pools

→ Select your pool

→ App integration

→ App clients and analytics

→ Click your App Client

#### 3️⃣ Update Callback URL (MOST IMPORTANT)

In Hosted UI / OAuth settings:

#### Callback URL(s)

Paste the exact same URL you copied:

```
https://d2og2zrs47voou.cloudfront.net/cafe-admin-dashboard.html
```

✔ Exact match only

❌ No wildcards

❌ No different file name

❌ No trailing /

#### 4️⃣ Update Sign-out URL (Recommended)

Use the same URL or your login page:

```
https://d2og2zrs47voou.cloudfront.net/index.html
```

#### 5️⃣ Save changes

Click Save changes
⏳ Wait 30–60 seconds (Cognito needs time to propagate)

#### 6️⃣ Verify OAuth Settings

Make sure these are enabled:

✅ Authorization code grant

✅ openid

✅ email (or profile)

#### 7️⃣ Test Login Again

Open:

```
https://<your-domain>/index.html
```

- Click Login → should redirect back without HTTP 400 ✅

### 🚨 Common Mistakes (99% failures)

- http instead of https

- /dashboard vs /dashboard.html

- CloudFront URL vs ALB URL mismatch

- Trailing slash /

- Old cached URL in JS

### 🧪 Quick Debug Tip

- If error persists:

- Open DevTools → Network

- Look for redirect_uri=

- Compare it character by character with Cognito callback URL


### ✅ FINAL VERDICT (IMPORTANT)

#### ✅ You should do THIS:

✔ Ignore choice-based sign-in

✔ Keep password inactive there

✔ Use Hosted UI login

✔ Continue with Cognito login URL

#### ✅ Your setup is 100% valid for:

- Charlie Café lab

- Admin dashboard

- Production-style auth

- API Gateway + Lambda

**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**
---
## 🔐 PHASE 3️⃣ — Admin Authentication Using Amazon Cognito (Hosted UI + JWT Tokens)
> **🔐 COGNITO INTEGRATION (PRODUCTION READY)**

### 🟢 STEP 2️⃣ — TEST HOSTED UI LOGIN (VERY IMPORTANT)

#### 1️⃣ Login Page Configuration Tab:

```
Cognito → User pools → Your user pool → App clients → Your App → Login pages  
```

#### 2️⃣ Construct LOGIN URL:

```
https://YOUR_COGNITO_DOMAIN/login
?client_id=CLIENT_ID
&response_type=token
&scope=openid+email+profile
&redirect_uri=https://cloudfront/cafe-admin-dashboard.html
```

#### Example:

```
https://us-east-1hdcwdjqvz.auth.us-east-1.amazoncognito.com/login
?response_type=token
&client_id=3hcigucn7fmd11gvo9uuqud6fi
&scope=openid+email+profile
&redirect_uri=https://d159bqc5pw64hn.cloudfront.net/cafe-admin-dashboard.html
```

#### 3️⃣ Test

- Open it in browser.

#### 4️⃣ Login with:

- Username: admin

- Temporary password

- Set new password

#### ✅ EXPECTED RESULT

After login, browser redirects to:

```
https://cloudfront/cafe-admin-dashboard.html#id_token=xxxxx&access_token=xxxxx
```

🎉 THIS MEANS SUCCESS

#### 3️⃣ Test the Login URL Directly

Once the above is confirmed:

```
https://us-east-1qxbqjnjww.auth.us-east-1.amazoncognito.com/login?response_type=token&client_id=393ld7o96bt7qlv0shp124osh5&scope=openid+email+profile&redirect_uri=https://d2og2zrs47voou.cloudfront.net/cafe-admin-dashboard.html
```

- Expected: Cognito login page shows

- Login → redirect → CloudFront /cafe-admin-dashboard.html

**✔️ If this works → frontend code will work too.**

#### ✅ Must Know Before Next Step

- OAuth Scopes: openid, email, profile

- OAuth Grant Type: Implicit grant enabled

- Auth flows: Only 4 boxes checked ✅

- Client secret: Disabled ✅

- Callback + sign-out URLs: Exact CloudFront URL ✅

#### 9️⃣ 🧪 HOW TO TEST

- 1️⃣ Open Incognito window

- 2️⃣ Open:

```
https://ALB-DNS/cafe-admin-dashboard.html
```

#### Example: 

```
http://charlie-cafe-alb-1050813156.us-east-1.elb.amazonaws.com/cafe-admin-dashboard.html
```

- 3️⃣ You should be redirected to:

```
https://us-east-1qxbqjnjww.auth.us-east-1.amazoncognito.com/login
```

- 4️⃣ Login with:

  - Username: 	cafeadmin

  - Password: (your permanent password)

- 5️⃣ After login:

  - ✅ Redirects back

  - ✅ Dashboard appears

  - ✅ No HTTP 400

**👍 This is production-style SPA + Cognito + API Gateway security.**

### 2️⃣ Backend - Cognito Role Base Access and Permission 

#### STEP 1️⃣ API Gateway – Enable Cognito Authorizer

#### 1️⃣ Test Cognito Authorizer

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

#### 2️⃣ Test Lambda

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

**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---
## 🔐 PHASE 4️⃣ — BACKEND DATE FILTER (LAMBDA)





**✅ PHASE 4️⃣ STATUS**

> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**
---
## 🔐 PHASE 5️⃣ — BACKEND DATE FILTER (LAMBDA)

### 1️⃣ CREATE OR UPDATE LAMBDA

### 1️⃣ CREATE OR UPDATE LAMBDA
> **🔖 CafeOrderStatusRBACLambda**

### 🧪 LAMBDA TEST JSON (ADMIN USER)

Use this in Lambda → Test

```
{
  "path": "/order-status",
  "queryStringParameters": {
    "date": "2026-01-17"
  },
  "requestContext": {
    "authorizer": {
      "claims": {
        "cognito:username": "admin_user",
        "cognito:groups": "admin"
      }
    }
  }
}
```

#### ✅ Expected:

- statusCode: 200

- Metrics + recent orders returned

### 🧪 LAMBDA TEST JSON (EMPLOYEE USER – SHOULD FAIL)

```
{
  "path": "/order-status",
  "queryStringParameters": null,
  "requestContext": {
    "authorizer": {
      "claims": {
        "cognito:username": "employee_user",
        "cognito:groups": "employee"
      }
    }
  }
}
```

#### ❌ Expected:

```
{
  "error": "Admin access only"
}
```

### 🧪 LAMBDA TEST JSON (NO ROLE / MISCONFIG)

```
{
  "path": "/order-status",
  "requestContext": {
    "authorizer": {
      "claims": {
        "cognito:username": "unknown_user"
      }
    }
  }
}
```

#### ❌ Expected:

- 403 Forbidden

### ✅ Test 1 — No token

```
curl https://API_ID.execute-api.REGION.amazonaws.com/status/order-status
```

#### Expected:

```
401 Unauthorized
```

✔ API Gateway working

✅ Test 2 — Employee token

```

{
  "path": "/order-status",
  "requestContext": {
    "authorizer": {
      "claims": {
        "cognito:username": "employee_user",
        "cognito:groups": "employee"
      }
    }
  }
}
```

Expected:

```
403 Admin access only
```

✔ RBAC working

✅ Test 3 — Admin token

```
{
  "path": "/order-status",
  "queryStringParameters": {
    "date": "2026-01-17"
  },
  "requestContext": {
    "authorizer": {
      "claims": {
        "cognito:username": "admin_user",
        "cognito:groups": "admin"
      }
    }
  }
}
```

#### Expected:

Metrics

Recent orders

statusCode 200

✔ Everything correct

✅ Test 4 — Browser (REAL WORLD)

1️⃣ Login via Cognito Hosted UI
2️⃣ Access token in localStorage
3️⃣ Frontend loads dashboard
4️⃣ Network tab shows:

```
Authorization: Bearer eyJraWQiOi...
```

5️⃣ /order-status returns data

✔ Production-ready

🟢 FINAL VERDICT (VERY IMPORTANT)

✅ Your configuration is NOW CORRECT
✅ You are using best-practice RBAC
✅ One Lambda is the right choice
✅ No wasted work
✅ No rewrite needed

What you built is exactly how a senior backend engineer would do it under time pressure.


**✅ PHASE 5️⃣ STATUS**

> **🟢 PHASE 5️⃣ COMPLETE & VERIFIED**
---

### Cognito Errors 1 - Invalid request

> **The “Invalid request” error means one (or more) OAuth parameters don’t match Cognito’s App Client settings**


### 🔥 ROOT CAUSE (the real problem)

#### ❌ You are mixing login parameters incorrectly

#### You opened this URL:

```
/login?client_id=...&logout_uri=...
```

**🚫 logout_uri is NOT valid on /login**

#### ⚠️ For login, Cognito REQUIRES:

```
redirect_uri
```

> **So Cognito throws:**

> **Invalid request – Please check your input**

### ✅ CORRECT LOGIN URL (IMPORTANT)

#### Use redirect_uri, not logout_uri

```
https://us-east-1hdcwdjqvz.auth.us-east-1.amazoncognito.com/login
?response_type=token
&client_id=3hcigucn7fmd11gvo9uuqud6fi
&scope=openid+email+profile
&redirect_uri=https://d159bqc5pw64hn.cloudfront.net/cafe-admin-dashboard.html
```

**👉 Open this exact URL in browser**

### 🧠 WHY THIS HAPPENS (Cognito rules)

| Action | Required Param                        |
| ------ | ------------------------------------- |
| Login  | `redirect_uri`                        |
| Logout | `logout_uri`                          |
| Both   | Must be **pre-allowed** in App Client |

- You passed a logout parameter during login → OAuth spec violation → Cognito blocks it.

### 🔧 REQUIRED COGNITO CONSOLE SETTINGS (CRITICAL)

- Go to: Cognito → User Pool → App integration → App client settings

#### ✅ Allowed OAuth Flows

✔ Implicit grant

✔ (Optional later) Authorization code grant

#### ✅ Allowed OAuth Scopes

✔ openid

✔ email

✔ profile

#### ✅ Allowed Callback URLs (LOGIN)

- Add EXACTLY (no typos, https matters):

```
https://d159bqc5pw64hn.cloudfront.net/cafe-admin-dashboard.html
```

- You may also add:

```
https://d159bqc5pw64hn.cloudfront.net/
```

#### ✅ Allowed Sign-out URLs (LOGOUT)

```
https://d159bqc5pw64hn.cloudfront.net/
```

#### ⚠️ Cognito is EXTREMELY strict

- http ≠ https

- trailing / matters

- CloudFront domain must match exactly

### ✅ YOUR central-auth-api.js (GOOD NEWS)

Your code is mostly correct 💪
Only one thing to be aware of:

#### ✔ Login function is correct

```
login(redirectUrl = window.location.href) {
    const url =
        `https://${CONFIG.COGNITO_DOMAIN}/login` +
        `?response_type=token` +
        `&client_id=${CONFIG.CLIENT_ID}` +
        `&scope=openid+email+profile` +
        `&redirect_uri=${encodeURIComponent(redirectUrl)}`;
    window.location.href = url;
}
```

**➡️ Just make sure:**

- redirectUrl is one of the allowed callback URLs

- For admin dashboard, explicitly do:

```
CHARLIE.auth.login(
  "https://d159bqc5pw64hn.cloudfront.net/cafe-admin-dashboard.html"
);
```

### 🧪 QUICK DEBUG CHECKLIST (DO THIS)

1️⃣ Fix login URL → use redirect_uri
2️⃣ Confirm callback URL exists in Cognito
3️⃣ Confirm logout URL exists in Cognito
4️⃣ Ensure Implicit Grant is enabled
5️⃣ Clear browser cache (Cognito is sticky)
6️⃣ Retry in incognito window

### 🟢 FINAL VERDICT

✅ Cognito is healthy
✅ Your domain is correct
✅ Your JS auth architecture is solid
❌ One wrong OAuth parameter caused the failure

**Once you fix this → login will work instantly**

----
### Cognito Errors 2 - access token

### ✅ Step 1: Use Hosted UI login (already in your JS)

- You do not manually get the token — your central-auth-api.js already handles it:

```
auth.login(); // redirects user to Cognito Hosted UI
```

- After login, Cognito redirects back to your CloudFront page (your cafe-admin-dashboard.html)

- The access token is automatically in the URL hash: #access_token=...

- Your JS handleRedirect() extracts it and stores it in localStorage.

> **No need to manually copy token from jwt.io — that’s only for debugging.**

### ✅ Step 2: Ensure your Cognito App Client settings are correct

- Allowed Callback URLs → must include:

```
https://d159bqc5pw64hn.cloudfront.net/cafe-admin-dashboard.html
```

- Allowed Logout URLs → include your CloudFront origin (e.g., home page)

- OAuth Flows → enable:

  - Implicit grant → Access token and ID token (this is what your JS uses)

- Scopes → enable at least: openid email profile

> **These are already required for your central-auth-api.js.**

### ✅ Step 3: Testing it the fast way

- Open your CloudFront page:

```
https://d159bqc5pw64hn.cloudfront.net/cafe-admin-dashboard.html
```

- Click “Login” (your login() function triggers Hosted UI)

- Login as Admin/Employee

- If successful, page reloads and your JS automatically stores access_token

You can check in browser DevTools → Application → Local Storage → access_token

> **If it’s there, your token is valid and API calls will work. No need to manually paste anything.**

### ✅ Step 4: Avoid token expiration issues

- Your startAutoLogoutWatcher() already logs out users automatically after 30 sec check.

- No manual token refresh needed for now, just re-login when expired.

### 💡 Shortcut for you:

Do not manually touch token.

- Just make sure your Cognito App Client settings (callback URL, implicit grant, scopes) are correct.

- Let your central-auth-api.js handle everything automatically.

> **This is the industry standard / production-ready approach.**

---



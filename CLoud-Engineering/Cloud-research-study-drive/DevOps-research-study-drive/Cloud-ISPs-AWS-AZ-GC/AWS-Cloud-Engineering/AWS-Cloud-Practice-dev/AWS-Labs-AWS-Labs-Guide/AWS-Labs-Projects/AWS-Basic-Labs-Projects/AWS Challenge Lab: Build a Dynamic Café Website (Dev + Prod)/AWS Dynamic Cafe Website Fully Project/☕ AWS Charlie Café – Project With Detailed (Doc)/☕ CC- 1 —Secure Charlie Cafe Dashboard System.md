# AWS  ☕ Charlie Cafe — Secure Charlie Cafe Dashboard System

### READ Me About

[☕ CC- 2 —Secure Charlie Cafe Dashboard System](./☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20Readme(Doc)/☕CC-%201%20—Secure%20Charlie%20Cafe%20Dashboard%20System.md)

### AWS Cognito + PHP backend + protected API

[☕ AWS Cognito + PHP backend + protected API](./☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20Readme(Doc)/AWS%20Cognito%20%2B%20PHP%20backend%20%2B%20protected%20API.md)


### ☕ AWS Charlie Café – Test & Verifications

[Secure Charlie Cafe Dashboard System](./☕%20AWS%20CAFE%20—%20%20Test%20%26%20Verifications/☕CC-%201%20—Secure%20Charlie%20Cafe%20Dashboard%20System.md)


---
# SECTION 1️⃣ Secure Admin Order Dashboard

## 🔐 PHASE 1️⃣ — Cognito Authentication infrastructure 
> **🔐 COGNITO INTEGRATION (PRODUCTION READY)**

Cognito configuration from scratch based on your NEW architecture plan:

✅ Public routes (no login)

✅ Protected routes (Cognito + Groups)

✅ One prod stage

✅ Role-based backend enforcement

✅ SPA for management team

✅ PHP for public ordering

This will be clean, production-ready, and aligned with your new API structure.

We will rebuild Cognito properly using:

- Amazon Cognito

- Amazon API Gateway

- AWS Lambda

### 🔐 FINAL COGNITO DESIGN (BASED ON YOUR NEW PLAN)

We will configure:

- 1 User Pool

- 1 Public App Client (NO client secret)

- Hosted UI login

- Role groups:

    - Admin

    - Manager

    - Employee

- OAuth Authorization Code Grant (NOT implicit anymore)

### 1️⃣ Basic Cognito Configuration — DEFINE YOUR APPLICATION

> **🚀 STEP-BY-STEP — CLEAN NEW COGNITO SETUP**

### 🟢 STEP 1 — Create User Pool (Clean Setup)

- Go to: AWS Console → Cognito → User pools → Create user pool

#### 1️⃣ Application Type

- Choose: ✅ Single-page application (SPA)

- Click Next.

#### 2️⃣ Sign-in Options

- Select: ☑ Username

#### DO NOT select:

❌ Email

❌ Phone

This keeps login simple:

```
admin
manager1
employee1
```

- Click Next.

#### 3️⃣ Self Registration

❌ Disable self-registration

(Uncheck enable self-registration)

Production systems never allow public admin registration.

Click Next.

#### 4️⃣ Required Attributes

- Click “Select attributes”

- Choose only: ☑ email

- Do NOT choose anything else.

- Click Save.

- Click Next.

### 🟢 STEP 2 — Security Settings

#### 1️⃣ Password Policy

- Leave default.

- No changes needed.

#### 2️⃣ MFA

- Set: ❌ No MFA (for now)

You can enable later in production.

#### 3️⃣ Account Recovery

- Select: ☑ Email only

- Disable SMS.

- Click Next.

### 🟢 STEP 3 — App Client (CRITICAL)

This is where most mistakes happen.

#### 1️⃣ Client Type

- Choose: ✅ Public client

This disables client secret.

If you accidentally create confidential client → delete and recreate.

#### 2️⃣ App Client Name

Example:

```
CharlieCafeAdminSPA
```

- Click Next.

### 🟢 STEP 4 — OAuth Configuration (IMPORTANT CHANGE)


#### ⚠️ We are NOT using Implicit anymore.

We will use:

✅ Authorization Code Grant (RECOMMENDED)

❌ Do NOT enable Implicit

Because:

- Implicit = older

- Authorization Code = more secure

- Industry standard now

#### 1️⃣ OAuth 2.0 Grant Types

- Select: ☑ Authorization code grant

❌ Do NOT select implicit.

#### 2️⃣ OAuth Scopes

- Select ONLY:

☑ openid

☑ email

☑ profile

Nothing else.

### 🟢 STEP 5 — Callback & Logout URLs

Add EXACT URLs:

#### 1️⃣ Callback URL

```
https://YOUR_CLOUDFRONT_DOMAIN/login.html
```

Example:

```
https://dxxxx.cloudfront.net/login.html
```

#### 2️⃣ Sign-out URL

```
https://YOUR_CLOUDFRONT_DOMAIN/logout.html
```

Example:

```
https://dxxxx.cloudfront.net/logout.html
```

Must match EXACTLY.

- Save.

⌛️ Wait 30–60 seconds.

### 🟢 STEP 6 — Configure Cognito Domain

- Go to: User pool → App integration → Domain

- Create domain prefix:

```
charlie-cafe-auth
```

You will get:

```
charlie-cafe-auth.auth.us-east-1.amazoncognito.com
```

- Copy this.

❌ Do NOT include https.

### 🟢 STEP 7 — Create Groups (FINAL STRUCTURE)

- Go to: User pool → Groups → Create group

| Group     | Group Name | Precedence |
|-----------|------------|------------|
| Group 1   | Admin      | 1          |
| Group 2   | Manager    | 5          |
| Group 3   | Employee   | 10         |

- ❌ No IAM role attached.

### 🟢 STEP 8 — Create Users

Create:

| Username  | Group    | Password            |
|-----------|----------|---------------------|
| cafeadmin | Admin    | ^MyH%H!A4YjD        |
| manager1  | Manager  | jfZvm@^3gTVE        |
| ali       | Employee | *KEXO^C3mjm3        |

- Mark email verified.

- Add each to correct group.

### 🟢 STEP 9 — App Client Authentication Flows

- Go to: User pool → App clients → Show details

#### Ensure these are enabled:

✔ ALLOW_USER_PASSWORD_AUTH

✔ ALLOW_USER_SRP_AUTH

✔ ALLOW_REFRESH_TOKEN_AUTH

- ❌ Do NOT enable other unnecessary flows.

### 🟢 STEP 10 — Attach Cognito Authorizer in API Gateway

- Go to: API Gateway → Authorizers → Create new

- Type: Cognito

- Select your User Pool.

- Token source: Authorization

- Save.

- Now attach this authorizer ONLY to:

```
/admin/*
/employee/*
```

- ❌ Do NOT attach to:

```
/public/*
```

### 🔥 FINAL ARCHITECTURE RESULT

```
/public/orders                → No authorizer
/public/order-status          → No authorizer

/admin/dashboard              → Cognito authorizer
/admin/orders                 → Cognito authorizer
/admin/mark-paid              → Cognito authorizer

/employee/orders              → Cognito authorizer
/employee/order               → Cognito authorizer
```

Then inside Lambda:

- Validate group

- Enforce authorization

### ❓ IMPORTANT CHANGE FROM YOUR OLD SETUP

OLD:

```
response_type=token
Implicit grant
```

NEW (recommended):

```
response_type=code
Authorization code grant
```

#### ⚠️ You must update your central-auth-api.js accordingly.

### 🔐 PART 11 — EASIEST WAY TO GET ACCESS TOKEN (Manual Test)

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
## 🔐 PHASE 2️⃣ — Amazon Cognito Hosted UI — Callback + Logout

✅ Updated Login.html (with your Cognito config structure ready)

✅ Proper cognito-callback.php (NEW – required for token handling)

✅ Updated Logout.php (with Cognito global sign-out)

🎨 Café-themed UI (coffee background, icons, logo text, warm styling)

💬 Clear comments inside the code

### ✅ 1️⃣ Updated Login Page (Charlie Café Theme)

Replace with your real values:

YOUR_DOMAIN_PREFIX

YOUR_REGION

YOUR_APP_CLIENT_ID

[login.html](./☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20Readme(Doc)/☕CC-%201%20—Secure%20Charlie%20Cafe%20Dashboard%20System.md)




**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**
---
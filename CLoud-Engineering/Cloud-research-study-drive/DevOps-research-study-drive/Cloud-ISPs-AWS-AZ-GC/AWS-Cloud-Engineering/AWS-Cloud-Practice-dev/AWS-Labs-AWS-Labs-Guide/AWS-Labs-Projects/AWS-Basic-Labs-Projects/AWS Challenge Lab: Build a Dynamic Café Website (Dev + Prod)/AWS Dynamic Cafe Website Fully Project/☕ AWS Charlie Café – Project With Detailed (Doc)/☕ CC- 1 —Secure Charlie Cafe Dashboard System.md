# AWS  ☕ Charlie Cafe — Secure Charlie Cafe Dashboard System

### READ Me About

[☕ CC- 2 —Secure Charlie Cafe Dashboard System](./☕%20AWS%20Charlie%20Café%20–%20Project%20With%20Detailed%20Readme(Doc)/☕CC-%201%20—Secure%20Charlie%20Cafe%20Dashboard%20System.md)

### ☕ AWS Charlie Café – Test & Verifications

[Secure Charlie Cafe Dashboard System](./☕%20AWS%20CAFE%20—%20%20Test%20%26%20Verifications/☕CC-%201%20—Secure%20Charlie%20Cafe%20Dashboard%20System.md)


---
# SECTION 1️⃣ Secure Admin Order Dashboard

## 🔐 PHASE 1️⃣ — Set Up Automatic HTTP → HTTPS Redirection

> **✅ EASY & CORRECT METHOD (RECOMMENDED FOR LAB)**

### 1️⃣  — HTTPS REQUIREMENT (CRITICAL)

**⚠️ Cognito does NOT allow HTTP except localhost.**

So we must add HTTPS.

You have TWO EASY OPTIONS

### 1️⃣  — USE ALB

> **This is the simplest HTTPS solution.**

### STEP 1️⃣ — CREATE APPLICATION LOAD BALANCER

```
EC2 → Load Balancers → Create Load Balancer
```

#### Choose:

```
Application Load Balancer
```

### STEP 2️⃣ — BASIC ALB Configuration


| Setting                  | Value / Selection                                      | Notes / Requirement                          |
|--------------------------|--------------------------------------------------------|----------------------------------------------|
| **Name**                 | charlie-cafe-alb                                       | Unique name for your ALB                     |
| **Scheme**               | Internet-facing                                        | Allows public internet access                |
| **IP address type**      | IPv4                                                   | Standard for most setups                     |
| **VPC**                  | Same VPC as your EC2 instance                          | Must match EC2 placement                     |
| **Subnets**              | Select at least 2 **public** subnets                   | Required for internet-facing ALB; choose different Availability Zones if possible |
| **Availability Zones**   | At least 2 AZs (where public subnets exist)            | Improves high availability                   |


### STEP 3️⃣ — SECURITY GROUP

#### Allow:

```
HTTPS 443  0.0.0.0/0
```

### STEP 4️⃣ — Target Group Configuration (for EC2 registration)


| Setting                  | Value / Selection                          | Notes / Requirement                                      |
|--------------------------|--------------------------------------------|----------------------------------------------------------|
| **Type**                 | Instance                                   | Standard for registering EC2 instances by ID             |
| **Protocol**             | HTTP                                       | Matches your web server on EC2 (use HTTPS only if EC2 already has SSL) |
| **Port**                 | 80                                         | Default HTTP port your web server listens on             |
| **Target registration**  | Register your EC2 instance                 | Select your EC2 instance by name/ID (not IP)             |
| **Health check path**    | / (or /cafe-admin-dashboard.html)                  | Path ALB uses to check if instance is healthy            |

### STEP 5️⃣ — Add Listener to ALB 

#### - Add HTTP listener 

- **Listener:** HTTP 80

- **Target Group:** Select Your Target Group

#### - Add HTTPS listener (Optional)


| Setting                  | Value / Selection                                      | Notes / Requirement                                                                 |
|--------------------------|--------------------------------------------------------|-------------------------------------------------------------------------------------|
| **Listener**             | HTTPS : 443                                            | Standard secure port for HTTPS traffic                                              |
| **Certificate**          | Request or select from ACM (AWS Certificate Manager)   | Must use a valid SSL/TLS certificate; free public certs available via ACM           |
| **Certificate source**   | ACM                                                    | Recommended – free, auto-renewing certificates                                      |
| **Domain name (for ACM request)** | Your domain (e.g., charliecafe.com, *.charliecafe.com) | Required to request certificate; can be:<br>• Real domain you own<br>• Wildcard (*.example.com)<br>• Multiple SANs (Subject Alternative Names) |
| **Validation method**    | DNS validation (preferred) or Email                    | DNS is faster & automatic if using Route 53                                         |
| **Default action**       | Forward to target group (e.g., cafe-target-group)      | Routes HTTPS traffic to your EC2 instance(s)                                        |
| **HTTP → HTTPS redirect** | Add separate HTTP:80 listener with redirect rule       | Recommended: Redirect all HTTP traffic to HTTPS                                     |

### STEP 6️⃣ — GET ALB DNS NAME

Example:

```
https://charlie-cafe-alb-123.us-east-1.elb.amazonaws.com
```

### 2️⃣ — CLOUD FRONT

### 🧱 STEP 1️⃣ — CloudFront Origin (ALB)

#### Go to:

```
AWS Console → CloudFront → Create Distribution
```

- **Distribution name:** Charlie-Cafe

- **Next:**

- **Origin type:** Elastic Load Balancer

#### CloudFront Origin Settings (CRITICAL)

>**Go to:** CloudFront → Distributions → Your Distribution → Origins → Edit

> **Set EXACTLY like this:**

| Setting                | Value                                                   |
| ---------------------- | ------------------------------------------------------- |
| Origin domain          | charlie-cafe-alb-1050813156.us-east-1.elb.amazonaws.com |
| Origin protocol policy | **HTTP only** ✅                                         |
| HTTP port              | 80                                                      |
| Origin SSL protocols   | (doesn’t matter now)                                    |


✅ This is correct

❌ Do NOT select EC2 IP

❌ Do NOT select S3

### 🌐 STEP 2️⃣ — Default Cache Behavior (VERY IMPORTANT)

>**Go to:** Behaviors → Default → Edit


| Setting                | Value                  |
| ---------------------- | ---------------------- |
| Viewer protocol policy | Redirect HTTP to HTTPS |
| Allowed HTTP methods   | GET, HEAD, OPTIONS     |
| Cache policy           | CachingDisabled        |
| Origin request policy  | AllViewer              |


⚠️ Cognito tokens must NOT be cached

#### This ensures:

Authorization headers

Query strings

Cookies
are forwarded correctly.

👉 SAVE

⏳ Wait 5–10 minutes for deployment.

```
Status = Deployed
```

#### You’ll get:

```
xxxxx.cloudfront.net
```

### 🔐 STEP 3️⃣ — CloudFront General Configuration

> **This step finalizes the CloudFront distribution behavior and ensures it works correctly with ALB + Cognito Hosted UI without breaking authentication or routing.**

### 1️⃣ ⚙️ General Configuration

- **Configure the following settings in CloudFront → Distribution → General.**

#### 1️⃣ IPv6

- **Turn OFF IPv6**

✅ Recommended for learning & labs

🔁 Can be enabled later in production

### 2️⃣ Default Root Object (Optional but Recommended)

```
cafe-admin-dashboard.html
```

**⚠️ Do NOT add /order-status.html to Origin Path**
**Origin Path must remain empty.**

### 🧠 Correct CloudFront Path Logic

| Configuration Item   | Value                             |
| -------------------- | --------------------------------- |
| Origin Path          | ❌ Empty                           |
| Default Root Object  | ✅ `cafe-admin-dashboard.html`             |
| File location on EC2 | `/var/www/html/cafe-admin-dashboard.html` |


This ensures:

```
CloudFront → ALB → EC2 Apache → cafe-admin-dashboard.html
```

### 2️⃣ 🔄 CloudFront Invalidations (Admin Dashboard Use Case)

**👉 Invalidation tells CloudFront to delete cached copies immediately.**

#### 1️⃣ Go to:

```
CloudFront → Distributions → Your Distribution
```

#### 2️⃣ Click Invalidations

#### 3️⃣ Click Create invalidation

#### 4️⃣ In Object paths, enter:

invalidation path:

```
/cafe-admin-dashboard.html
```

### 5️⃣ Click Create invalidation

⏳ Status will show:

```
In Progress → Completed
```

Usually completes in 1–3 minutes.

### How to Confirm Invalidation Worked

After status = Completed:

1️⃣ Open browser

2️⃣ Hard refresh:

- Windows/Linux: Ctrl + F5

- Mac: Cmd + Shift + R

3️⃣ Open:

```
https://xxxxx.cloudfront.net/cafe-admin-dashboard.html
```

You should see latest code.

### Common Mistakes (Avoid These)

❌ Invalidating:

```
cafe-admin-dashboard.html
```

(missing leading /)

❌ Invalidating wrong file name

❌ Forgetting invalidation after JS changes

### Important Notes:

✔ /order-status.html is the correct invalidation path

✔ Use invalidation after frontend changes

✔ Do not overuse /*

✔ Required when testing Cognito changes

### 🔐 STEP 4️⃣ — CloudFront SSL Certificate (Optional)
Viewer Certificate

Choose:

```
Default CloudFront certificate (*.cloudfront.net)
```

✅ This is fine

✅ HTTPS works automatically

❌ No ACM needed here


### 5️⃣ CloudFront Validation (VERY IMPORTANT)

> **After configuration, always validate CloudFront before integrating Cognito.**

### 🔍 Validation Checklist

#### 1️⃣ Distribution Status

Status must be:

```
Deployed
```

**⚠️ If status is In Progress, wait 5–10 minutes.**

### 6️⃣ — USE THIS IN COGNITO

```
d2og2zrs47voou.cloudfront.net
```
**This is your Return URL**

**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---
## 🔐 PHASE 2️⃣ — Cognito Authentication infrastructure 
> **🔐 COGNITO INTEGRATION (PRODUCTION READY)**

### 1️⃣ Basic Cognito Configuration — DEFINE YOUR APPLICATION

### ✅ STEP 1️⃣ Application type

> **👉 SELECT THIS (CORRECT FOR YOUR PROJECT)**

```
✅ Single-page application (SPA)
```

### ✅ STEP 2️⃣ Name your application

Example:

```
CharlieCafeAdminSPA
```

**❕ (Name doesn’t matter technically)**

### ✅ STEP 3️⃣ — CONFIGURE OPTIONS (VERY IMPORTANT)

#### 1️⃣ Options for sign-in identifiers

#### SELECT:

```
☑ Username
```

#### DO NOT select:

❌ Email

❌ Phone number

#### 📌 This matches your requirement:

**🔴 Username: admin**

#### 2️⃣ Self-registration (CRITICAL)

❌ DISABLE self-registration

👉 UNCHECK

```
☐ Enable self-registration (DISABLED)
```

> **So: Unchecking self-registration is 100% correct and production-ready**

#### 3️⃣ Required attributes for sign-up

Click Select attributes

```
email   ← OK (this is fine)
```

#### ❌ Do NOT select:

- Phone number

- Any other attributes

#### 4️⃣ Return URL

```
https://YOUR_CLOUDFRONT_DOMAIN/
```

#### For Example:

```
https://YOUR_CLOUDFRONT_DOMAIN/cafe-admin-dashboard.html
```

#### Now click the button at bottom-right:

```
🟠 Create user directory
```
### 2️⃣ — How to Disable / Avoid Cognito Client Secret

- In Cognito, the client secret is created at the App Client level, not at the User Pool level.

- You cannot disable a client secret after the app client is created.

> **If it was created with a secret, you must create a new app client without one.**

#### 📍 Where to configure it (New Cognito Layout)

#### Step-by-step:

- Go to Amazon Cognito

- Click User pools

- Select your User Pool

- Go to App integration tab

- Under App clients and analytics

- Click Create app client

#### Now you’ll see:

- “Client type”

#### Choose:

- Public client → ❌ NO client secret (Recommended for SPA / Mobile apps)

- Confidential client → ✅ Creates client secret (For backend/server apps)

#### 👉 To disable client secret:

- Choose Public client

That’s it.




### 3️⃣ — OPEN THE ACTUAL USER POOL (THIS IS THE MISSING STEP)

> **📢 After creation completes:**

#### Go to:

```
Amazon Cognito → User pools
```

> **You will now see a new User Pool created automatically**
> **(example name similar to your application)**

#### 👉 CLICK the User Pool name

**⚠️ This is the step everyone misses**

### 3️⃣ PASSWORD POLICY 

> **🔐 NOW — THIS IS WHERE “STEP 3 — SECURITY” REALLY LIVES**

**You are now INSIDE the User Pool, not the app wizard.**

### ✅ STEP 1️⃣  PASSWORD POLICY 

#### Path:

```
User pool → Authentication → Authentication methods
```

#### Then look for:

```
Password policy
```

**⚠️ If you don’t see it yet:**

- Click Authentication methods

- Scroll down

✅ Default password policy is already applied

✅ This satisfies your lab requirement

👉 You do NOT need to change anything

**✔ Password policy = OK**

### ✅ STEP 2️⃣ Multi-factor authentication (MFA)

#### 1️⃣ Path:

```
User pool → Authentication → Sign-in experience → Account recovery
```

#### 2️⃣ Select:

> **YOU ALREADY CONFIGURED IT CORRECTLY**

```
❌ Off
```

Click Save changes

### ✅ STEP 3️⃣ ACCOUNT RECOVERY 

#### 1️⃣ Path:

```
User pool → Sign-in experience → Account recovery
```

#### 2️⃣ Select:

```
☑ Email only
```

#### 3️⃣ Disable:

```
☐ SMS
```

Click Save changes

### ✅ SUMMARY

| Requirement      | Status              |
| ---------------- | ------------------- |
| Password policy  | ✅ Default (OK)      |
| MFA              | ✅ No MFA            |
| Account recovery | ⚠ Fix to Email only |

**✔ Now your account recovery matches the lab**

### 4️⃣ Callback / Return URL (MOST IMPORTANT STEP)

### 🟢 STEP 1️⃣ Path (new UI):

```
Cognito
→ User pools
→ Your user pool
→ App integration
→ App clients
→ Click your App Client
→ Edit
```

### 🟢 STEP 2️⃣ Callback URLs (VERY IMPORTANT)

#### Add EXACTLY:

```
http://<cloudfront>/cafe-admin-dashboard.html
```

✔ Must match character by character

✔ http vs https must match

✔ trailing slash matters

#### Example:

```
https://d2og2zrs47voou.cloudfront.net/cafe-admin-dashboard.html
```

### 🟢 STEP 3️⃣ Sign-out URLs (recommended)

#### Add the same:

```
https://d2og2zrs47voou.cloudfront.net/dashboard-login.html
```

> **Cognito is strict: must be HTTPS + exact path, no trailing slash.**

**👉 Save changes**

**⏳ Wait 30–60 seconds (Cognito propagation delay)**

### 🟢 STEP 4️⃣ ✅ OAuth Settings 

Make sure these are enabled:

#### 1️⃣ OAuth 2.0 grant types Settings 

✔ Implicit grant (Recommanded)

OR 

✔ Authorization code grant (optional)

Because you are using:

```
response_type=token
```

#### 2️⃣ OpenID Connect scopes Settings 

✔ OpenID

✔ Email

✔ Profile

**If missing → Invalid request.**

**👉 Save changes**

**⏳ Wait 30–60 seconds (Cognito propagation delay)**

> **✅ This is correct for login with response_type=token.**

**Tip:** Only select these 3 scopes for now: openid, email, profile — leave phone optional if not needed.

#### 3️⃣ Check App Client Auth Flows (REFRESH_TOKEN_AUTH)

#### Path in AWS Console :

- AWS Console → Cognito → User Pools → select your pool

- App clients (left menu) → click Show details for your App Client

- Scroll to Authentication flows section

#### You should see exactly these 4 checked boxes:

✔ Choice-based sign-in → ALLOW_USER_AUTH

✔ Sign in with username and password → ALLOW_USER_PASSWORD_AUTH

✔ Sign in with secure remote password (SRP) → ALLOW_USER_SRP_AUTH

✔ Get new user tokens from existing authenticated sessions → ALLOW_REFRESH_TOKEN_AUTH

✅ These 4 are correct. No other boxes should be checked.

💡 This is exactly what Cognito needs to allow your front-end response_type=token flow.

**👉 Save changes**

**⏳ Wait 30–60 seconds (Cognito propagation delay)**

#### 4️⃣ Check App Client settings

- AWS Console → Cognito → User Pools → App clients → click Show details

- Ensure Client secret is Disabled ✅

In App Client settings:

| Setting       | Value             |
| ------------- | ----------------- |
| App type      | **Public client** |
| Client secret | ❌ Disabled        |

**If client secret is enabled → Invalid request**

> **If the secret is enabled, the browser flow cannot work and will throw “Invalid request”.**

**👉 Save changes**

**⏳ Wait 30–60 seconds (Cognito propagation delay)**

### 5️⃣ Where to COPY your Cognito Domain (exact path)

You asked this directly, so here is the exact path 👇

### 🟢 STEP 1️⃣ AWS Console path:

```
Cognito
→ User pools
→ Your user pool
→ App integration
→ Domain
```

### 🟢 STEP 2️⃣ You will see something like:

```
Domain:
us-east-1qxbqjnjww.auth.us-east-1.amazoncognito.com
```

👉 Copy ONLY this part

❌ Do NOT include https://

❌ Do NOT include /login

**⚠️ Simple words: Do NOT add https:// inside the variable (your code already adds it)**

#### Example:

```
const COGNITO_DOMAIN = "charlie-cafe-admin.auth.us-east-1.amazoncognito.com";
```

**📌 Copy ONLY this part (no https, no /login)**

### 6️⃣ - Cognito Hosted UI Customize Design

> **⚠️ Note: Yes can change the Cognito Hosted UI design, but with limits.**

### 1️⃣ The CORRECT & PROFESSIONAL approach (used in real projects)

#### 1️⃣ Option A (RECOMMENDED – what you’re already using)

> **Use Cognito Hosted UI for login, then redirect back to your frontend page.**

#### Flow:

```
Your Cafe Frontend Page
   ↓
Redirect to Cognito Hosted UI
   ↓
Login
   ↓
Redirect back with JWT
```

#### This is:

- Secure

- AWS-recommended

- Production-ready

- Simple to maintain

#### 2️⃣ Option B (Advanced – NOT needed now)

- Use Cognito + Custom Auth + Amplify / SDK

- More complex

- More backend work

- Not required for your use case

**👉 My professional advice:**
**Stick with Hosted UI + redirect (Option A).**

### 7️⃣ ✅ FINAL WORKING Frontend File(READY TO USE)

### 🟢 STEP 1️⃣ cafe-admin-dashboard.html File (Recommanded)

[cafe-admin-dashboard.html](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe-%20Admin%20Dashboard%20(Order%2BHR)/cafe-admin-dashboard.html)

### 🟢 STEP 2️⃣ Edit file on EC2:

```
sudo nano /var/www/html/order-status.html
```

[order-status.html](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order-status/CC%20-%20Order-Status_LIVE%20ADMIN%20DASHBOARD_many%20orders/order-status.html)


### 🟢 STEP 3️⃣ Restart Apache (MANDATORY)

```
sudo systemctl restart httpd
```

**✅ PHASE 2️⃣ STATUS**

> **🟢 PHASE 2️⃣ COMPLETE & VERIFIED**
---
## 🔐 PHASE 3️⃣ — Admin Authentication Using Amazon Cognito (Hosted UI + JWT Tokens)
> **🔐 COGNITO INTEGRATION (PRODUCTION READY)**

### 1️⃣ — CREATE USER & Groups (MANDATORY)

### 🟢 STEP 1️⃣ — CREATE ADMIN USER (MANDATORY)

#### 1️⃣ Where:

```
Cognito → User pools → Your user pool → Users
```

#### 2️⃣ Click:

```
Create user
```

#### 3️⃣ Fill:

| Setting                  | Value / Recommendation                                 | Notes / Action Required                              |
|--------------------------|--------------------------------------------------------|------------------------------------------------------|
| **Username**             | cafeadmin                                              | Use this exact username for consistency (case-sensitive in some flows) |
| **Temporary password**   | Auto-generated (recommended) or Manual                 | If manual: Use a strong one like `C@fe@dmin$` (must meet password policy) |
| **Suggested manual temp password** | C@fe@dmin$1                                            | Meets default policy: 8+ chars, upper/lower/number/special |
| **Email**                | your-email@example.com                                 | Replace with your real email (used for verification & recovery) |
| **Mark email as verified** | ✓ Yes (check the box)                                  | Critical: Enables immediate login without email verification step |
| **Message delivery**     | Email (default)                                        | Temporary password sent to the provided email        |
| **Additional attributes** | Optional: name = "Cafe Admin" (if required by your app) | Add if your required attributes include name         |

Click Create user

✅ Admin account created

### 🟢 STEP 2️⃣ — CREATE Employee USER (MANDATORY)

```
Create user
```

| Setting                  | Value / Recommendation                                 | Notes / Action Required                              |
|--------------------------|--------------------------------------------------------|------------------------------------------------------|
| **Username**             | Ali                                              | Use this exact username for consistency (case-sensitive in some flows) |
| **Temporary password**   | Auto-generated (recommended) or Manual                 | If manual: Use a strong one like `C@fe@dmin$` (must meet password policy) |
| **Suggested manual temp password** | C@fe@li$1                                            | Meets default policy: 8+ chars, upper/lower/number/special |
| **Email**                | your-email@example.com                                 | Replace with your real email (used for verification & recovery) |
| **Mark email as verified** | ✓ Yes (check the box)                                  | Critical: Enables immediate login without email verification step |
| **Message delivery**     | Email (default)                                        | Temporary password sent to the provided email        |
| **Additional attributes** | Optional: name = "Cafe Admin" (if required by your app) | Add if your required attributes include name  

### 🟢 STEP 3️⃣ — CREATE Admin Group (MANDATORY)

#### 1️⃣ Where:

```
Cognito → User pools → Your user pool → groups → Create group
```

#### 1️⃣ Create Admin Group

- Group name: 

```
Cafe-Admin
```

- Description:

```
Cafe administrators
```

- Precedence:

```
1
```

- IAM role:

```
👉 Leave empty for now (we’ll attach later if needed)
```

- **Click Create group**

#### 2️⃣ Create Employee Group

- Group name: 

```
Cafe-Employee
```

- Description:

```
Cafe employees
```

- Precedence:

```
10
```

- IAM role:

```
👉 Leave empty for now (we’ll attach later if needed)
```

- **Click Create group**

**✅ Both Groups created**

### 🟢 STEP 4️⃣ — Assign Users to Groups (MANDATORY)

#### 1️⃣ Where:

```
Cognito → User pools → Your user pool → Users
```

#### 1️⃣ Add Admin User to Admin Group

- Click Admin user

- Go to Groups

- Click Add to group

- Select Admin

- Save

#### 2️⃣ Add Employee User to Employee Group

- Click Employee user

- Go to Groups

- Add to Employee

- Save

### 🧠 IMPORTANT: What Cognito Does Now

When user logs in, Cognito adds this to JWT token:

```
"cognito:groups": ["Admin"]
```
or
```
"cognito:groups": ["Employee"]
```

This is 🔥 gold for authorization.


**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---
## 🔐 PHASE 4️⃣ — Backend - Cognito Role Base Access and Permission 

### 1️⃣ Central UNIVERSAL Backend RBAC

### 1️⃣ Create Lambda Layer (RBAC)

#### 1️⃣ Create the folder structure

```
sudo mkdir -p cafe-rbac-layer/python
```
> **📌 python/ folder name is MANDATORY for Lambda layers**
**⚠️ If you miss this → Lambda will not find rbac.py**

#### 2️⃣ Create permissions.json

```
sudo nano cafe-rbac-layer/python/permissions.json
```
[permissions.json](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/Central%20Backend%20RBAC%20Script/permissions.json)

- Save and exit.

#### 🔐 Rule:

- If path matches → check roles

- If no rule → DENY by default (secure)

#### 3️⃣ Create UNIVERSAL backend RBAC file
> **📄 rbac.py (THIS IS YOUR BACKEND central-auth-api)**

```
sudo nano cafe-rbac-layer/python/rbac.py
```
- Paste your existing rbac.py code

[rbac.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/Central%20Backend%20RBAC%20Script/rbac.py)

- Save and exit (CTRL + O, ENTER, CTRL + X)

#### 4️⃣ RBAC Layer Setup

#### Method 1- Bash Script Charlie Cafe RBAC Layer Setup & Verification

#### Bash Script Charlie Cafe RBAC Layer Setup (S3)

```
sudo nano charlie_cafe_rbac_layer_S3_test_verify.sh
```

[charlie_cafe_rbac_layer_S3_test_verify.sh](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/charlie_cafe_rbac_layer_S3_test_verify.sh)


#### Bash Script Charlie Cafe RBAC Layer Setup (AWS EC2 CLI)

```
sudo nano charlie_cafe_rbac_layer_test_verify.sh
```

[charlie_cafe_rbac_layer_test_verify.sh](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/charlie_cafe_rbac_layer_test_verify.sh)

#### 🧪 How to run

```
sudo chmod +x charlie_cafe_rbac_layer_test_verify.sh
```
```
sudo ./charlie_cafe_rbac_layer_test_verify.sh
```

#### Method 2 Manual 1 T0 1

#### 1️⃣ Create the ZIP (Layer package)

Run this inside the folder that contains python/:

```
cd cafe-rbac-layer
zip -r cafe-rbac-layer.zip python
```

#### 2️⃣ Publish Lambda Layer using AWS CLI

Make sure AWS CLI is configured

```
aws configure
```
**(Access key, secret, region, output)**

Create the layer (Amazon Linux 2023 compatible)

```
aws lambda publish-layer-version \
  --layer-name cafe-rbac-layer \
  --description "Charlie Cafe Universal RBAC Layer" \
  --zip-file fileb://cafe-rbac-layer.zip \
  --compatible-runtimes python3.12 python3.11 python3.10
```

#### ✅ Expected output includes:

```
{
  "LayerVersionArn": "arn:aws:lambda:us-east-1:XXXX:layer:cafe-rbac-layer:1",
  "Version": 1
}
```

#### 3️⃣ Attach Layer to a Lambda (CLI)

Example: attach to order-status Lambda

```
aws lambda update-function-configuration \
  --function-name CafeOrderStatusLambda \
  --layers arn:aws:lambda:us-east-1:XXXX:layer:cafe-rbac-layer:1
```

#### 📌 Replace:

- CafeOrderStatusLambda

- Account ID

- Region

- Layer version if newer

### 2️⃣ CLI SCRIPT TO UPDATE ALL LAMBDAS

#### 1️⃣ Create update script

```
sudo nano update_all_lambdas.sh
```

#### ✅ COPY THIS SCRIPT (SAFE VERSION)

[update_all_lambdas.sh](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Bash%20Script/update_all_lambdas.sh)

#### 🧪 How to run

```
sudo chmod +x update_all_lambdas.sh
```
```
sudo ./update_all_lambdas.sh
```

#### Expected output:

```
Updating OrderStatusLambda ...
Updating PaymentLambda ...
Updating AttendanceLambda ...
✅ All Lambdas updated successfully
```

### 3️⃣ USING RBAC IN EACH LAMBDA
> **(ONE LINE)**

Inside every Lambda handler:

```
from rbac import authorize

def lambda_handler(event, context):
    authorize(event)   # ⬅ RBAC + audit log
    
    return {
        "statusCode": 200,
        "body": "OK"
    }
```

❌ No duplication

❌ No IAM mess

❌ No multiple Lambdas for roles

---

### 4️⃣ CREATE New Lambda Functions 

### 1️⃣ CREATE OrderStatusLambda

- **AWS Console → Lambda → Create Function → Author from scratch**

- **Function name:** OrderStatusLambda

- **Runtime:** Python 3.12

- **Permissions:** Create new role with basic Lambda permissions

#### 1️⃣ ✅ FINAL LAMBDA CODE (Python 3.12)

> 🔁 This is a drop-in replacement
> Nothing else needs to change

[OrderStatusLambda.py](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/OrderStatusLambda.py)

#### 3️⃣ 🔐 Add Environment Variables

```
DB_HOST = <your-rds-endpoint>
DB_USER = cafe_user
DB_PASS = <your-db-password>
DB_NAME = cafe_db
```

#### 4️⃣ 🔐 Attach Lambda Layer

- Same 

#### 5️⃣ 🔐 Edit VPC

- Same 

> **⚠️ Make sure DB_HOST points to your RDS MySQL/MariaDB instance.**

### 2️⃣ CREATE AdminDashboardLambda

- **Function name:** AdminDashboardLambda

- **Runtime:** Node.js 18.x

[AdminDashboardLambda.js](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/AdminDashboardLambda.js)

### 3️⃣ CREATE AdminCreateUserLambda

- **Function name:** AdminCreateUserLambda

- **Runtime:** Node.js 18.x

[AdminCreateUserLambda.js](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/AdminCreateUserLambda.js)

### 4️⃣ CREATE EmployeeOrdersLambda

- **Function name:** EmployeeOrdersLambda

- **Runtime:** Node.js 18.x

[EmployeeOrdersLambda.js](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/EmployeeOrdersLambda.js)


### 5️⃣ CREATE EmployeeOrderLambda

- **Function name:** EmployeeOrderLambda

- **Runtime:** Node.js 18.x

[EmployeeOrderLambda.js](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Backend%20Code%20Script/EmployeeOrderLambda.js)

---


### 5️⃣ 🟢 METHOD 1 — BROWSER (EASIEST, REAL-WORLD)

#### STEP 1️⃣ Open Cognito Hosted UI Login

- Go to AWS Console → Cognito → User Pools → Your pool

- Click App integration → App client settings

#### You will see:

- Domain

- Client ID

- Callback URL

- Allowed OAuth flows

#### STEP 2️⃣ Construct the LOGIN URL

Open browser and paste (replace values):

```
https://YOUR_DOMAIN.auth.us-east-1.amazoncognito.com/login
?client_id=YOUR_CLIENT_ID
&response_type=token
&scope=email+openid
&redirect_uri=https://example.com
```

#### 📌 Example:

```
https://charlie-cafe.auth.us-east-1.amazoncognito.com/login
?client_id=4abc123xyz
&response_type=token
&scope=email+openid
&redirect_uri=https://example.com
```

- 👉 Press Enter

#### STEP 3️⃣ Login Screen Appears

- Enter username & password

- Click Sign in

If login is successful → browser redirects to:

```
https://example.com/#access_token=eyJraWQiOiJr...
```

#### STEP 4️⃣ COPY THE ACCESS TOKEN

From the URL bar, copy ONLY this part:

```
access_token=eyJraWQiOiJr...
```

#### ⚠️ Do NOT copy:

- id_token

- expires_in

- token_type

👉 You need access_token

#### STEP 5️⃣ Use Token in API Call (Browser DevTools)

Open Chrome DevTools → Console

Paste:

```
fetch("https://API_ID.execute-api.REGION.amazonaws.com/status/order-status", {
  headers: {
    "Authorization": "Bearer YOUR_ACCESS_TOKEN"
  }
})
.then(res => res.json())
.then(data => console.log(data));
```

#### ✅ EXPECTED RESULT

```
{
  "orders": [...],
  "metrics": {...}
}
```

🎉 DONE — frontend token works.

### 🧪 METHOD 2 — curl (CLI / AWS TESTING)

Use this after you already have the token.

#### STEP 1️⃣ Open Terminal / CMD

#### STEP 2️⃣ Run curl Command

- Make GET request with header:

```
curl -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
https://API_ID.execute-api.REGION.amazonaws.com/status/order-status
```

#### 📌 Example:

```
curl -H "Authorization: Bearer eyJraWQiOiJr..." \
https://abcd123.execute-api.us-east-1.amazonaws.com/status/order-status
```

#### ✅ EXPECTED RESPONSES

```
JSON response with metrics + recent orders
```

#### ✅ SUCCESS (200)

```
{
  "orders": [...],
  "metrics": {...}
}
```

#### ❌ NO TOKEN

```
{"message":"Unauthorized"}
```

#### ❌ INVALID TOKEN

```
401 Unauthorized
```

#### 3️⃣ Date Filter Test

```
curl -H "Authorization: Bearer <access_token>" \
"https://API_ID.execute-api.REGION.amazonaws.com/status/order-status?date=2026-01-17"
```

#### ✅ Expected: 

```
Only orders for 2026-01-17 returned
```

**✅ Metrics counts match filtered orders**

#### 4️⃣ Verify Auto Refresh / Chart in Frontend

- Open order-status.html

- Enter date in filter box

- Click Filter

- Metrics + table + chart should update correctly

- Spinner shows loading

### 📣 Simple & Easy way test 

#### 1️⃣ Login & Token Issued

- Open your Cafe Dashboard frontend (order-status.html).

- Click Login.

- You should be redirected to Cognito Hosted UI.

- Enter Admin credentials.

- After login, you are redirected back to the dashboard.

- Open browser DevTools → Application → Local Storage.

  - **✅ access_token should exist.**

**If no token → STOP, check Cognito setup.**

#### 2️⃣ Dashboard Loads

- After login, the dashboard content should appear (metrics + table).

- Metrics should show Total Orders, Total Items Sold, Customers.

- Orders table should populate with recent orders.

- Spinner should appear while loading, then hide.

- **✅ If dashboard is blank → STOP, check Lambda/API response.**

#### 3️⃣ Auto Refresh Works

- Wait ~10 seconds (or the interval set in frontend).

- Dashboard metrics and table should update automatically.

- Open DevTools → Network tab

  - You should see GET requests to /order-status fired every 10 seconds.

- **✅ If auto refresh doesn’t work → check setInterval(loadData, 10000) in frontend JS.**

#### 4️⃣ Date Filter Works

- On dashboard, select a date in the date picker.

- Click Filter.

- Dashboard metrics + table should update only for that date.

- Network tab → Confirm request URL:

```
https://API_ID.execute-api.REGION.amazonaws.com/prod/order-status?date=YYYY-MM-DD
```

- **✅ If metrics or table show wrong data → check Lambda filter code.**

#### 5️⃣ Chart Works

- Chart below metrics should update matching the filtered data.

- Check bars/lines correspond to orders/items counts.

- Change date → chart updates accordingly.

- **✅ If chart does not update → check frontend chart destroy/create logic.**

**✔ Everything works → Phase Complete**

### ✅ PHASE 4️⃣ COMPLETION CHECKLIST

✔️ Lambda created/updated

✔️ Environment variables set correctly

✔️ JWT validation works (401 if missing)

✔️ Date filter works (?date=YYYY-MM-DD)

✔️ Metrics calculated correctly

✔️ Recent orders table updates

✔️ Frontend chart + auto-refresh works

✔️ Tested manually via API & frontend


**✅ PHASE 4️⃣ STATUS**

> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**
---
## 🔐 PHASE 5️⃣ — BACKEND DATE FILTER (LAMBDA)

### 1️⃣ API Gateway – SECURE Cognito AUTH Authorizer (MOST IMPORTANT) 

- **AWS Console → API Gateway → REST API → /order-status**

### 1️⃣ Resource & Method

- Go to Resources → /order-status

- If GET method does not exist → click Actions → Create Method → GET

```
GET /order-status
```

- Select Lambda Proxy Integration

- Lambda function → OrderStatusLambda

### 2️⃣ Create Resource
> **You MUST manually create routes.
> **API Gateway does NOT auto-create /admin/*.**

#### Overview of your resources and Lambda mapping

| Resource Path        | Method | Lambda Function        | Notes               |
| -------------------- | ------ | ---------------------- | ------------------- |
| `/admin/dashboard`   | GET    | AdminDashboardLambda*  | Admin only          |
| `/admin/create-user` | POST   | AdminCreateUserLambda* | Admin only          |
| `/employee/orders`   | GET    | EmployeeOrdersLambda*  | Employee + Admin    |
| `/employee/order`    | POST   | EmployeeOrderLambda*   | Employee + Admin    |
| `/order-status`      | GET    | OrderStatusLambda      | Order status checks |

**You’ll need to create separate Lambdas for admin/employee if not already done.**

- Go to: API Gateway → Resource → Click Create

| Resource               | Method | Auth    |
| -------------------- | ------ | ------- |
| `/order-status`      | GET    | Cognito |
| `/admin/dashboard`   | GET    | Cognito |
| `/admin/create-user` | POST   | Cognito |
| `/employee/orders`   | GET    | Cognito |
| `/employee/order`    | POST   | Cognito |

> **✔ Attach CafeCognitoAuthorizer to ALL protected Resource**

#### Admin Resource 1

- Method: GET

- Path: /admin/dashboard

- Integration: AdminDashboardLambda

- Authorization: cafe-cognito-authorizer

- Click Create

#### Admin Resource 2

- Method: POST

- Path: /admin/create-user

- Integration: AdminCreateUserLambda

- Authorization: cafe-cognito-authorizer

- Click Create

> **💡 This is how /admin/* works**

**📢 You manually create Resource that start with /admin/**

#### Employee Resource 1

- Method: GET

- Path: /employee/orders

- Integration: EmployeeOrdersLambda

- Authorization: cafe-cognito-authorizer

- Click Create

#### Employee Resource 2

- Method: POST

- Path: /employee/order

- Integration: EmployeeOrderLambda

- Authorization: cafe-cognito-authorizer

- Click Create

#### order-status Resource 1

- Method: GET

- Path: /order-status

- Integration: OrderStatusLambda

- Authorization: cafe-cognito-authorizer

- Click Create


#### Attach this authorizer to your Resource

/admin/*

/employee/*

or /api/*

**✔ Now API Gateway blocks unauthenticated users**

### 3️⃣ Enable Cognito Authorizer

- Go to AWS Console → API Gateway → REST API → YOUR_API

- On left panel → Authorizers → Create Authorizer

- Fill the form:

| Field             | Value                              |
| ----------------- | ---------------------------------- |
| Name              | `CafeCognitoAuthorizer`                |
| Type              | **Cognito**                        |
| Cognito User Pool | Select your Cafe Cognito User Pool |
| Token Source      | `Authorization`                    |
| Token Validation  | Leave blank or optional            |

**✅ Create authorizer**

> **✔ This authorizer will validate JWTs automatically.**
> **✔ Now API Gateway blocks unauthenticated users**

### 4️⃣ Cognito Authorizer (JWT validation)

- **Go to: API Gateway → Your API → Authorizers → Create**

- **Name:** CognitoAuthorizer

- **Type:** Cognito

- Select your Cafe Cognito User Pool

- **Token source:** Authorization

- Save ✅

> **This does NOT enable CORS — this only validates JWT.**

### 5️⃣ Attach Authorizer to GET Method

- **Go to Resources → /order-status → GET → Method Request**

- **Find Authorization → select CognitoAuthorizer**

- Select CognitoAuthorizer from the dropdown

- Save ✅

> **This ensures all GET requests require a valid JWT.**

### 6️⃣ Enable CORS (Cross-Origin Resource Sharing)

> **These are two separate things — enabling CORS is for frontend browser calls.**

- Click GET → Actions → Enable CORS

- A popup appears:

  - Check “Replace existing CORS headers” ✅

- Click Enable CORS

- Confirm popup: “Yes, replace existing headers” ✅

> **This allows your frontend JS (from CloudFront) to call API Gateway without CORS errors.**

✔ Enable CORS on each method

✔ Especially for GET /order-status

### 7️⃣ Deploy API

- **Click Actions → Deploy API**

- **Stage: status (or admin if you created a new stage)**

- **Save Invoke URL**

✔ Deploy after every change

✔ Stage can be status or admin

✔ Frontend URL must match stage

#### 📌 Copy new endpoint API URL:

```
https://API_ID.execute-api.REGION.amazonaws.com/status/order-status
```
> **OR**

```
https://xxx.execute-api.region.amazonaws.com/admin/order-status
```

#### 👉 Paste this into frontend once

#### 🔁 Update frontend:

```
API_URL = ".../status/order-status"
```

> **OR**

```
API_URL = ".../admin/order-status"
```

#### ✅ Result:

- ❌ No login → 401


- ✅ Login → data loads

### ✅ KEY POINTS

| Task                     | Done? | Notes                             |
| ------------------------ | ----- | --------------------------------- |
| Cognito authorizer       | ✅     | Validates JWT                     |
| Attach authorizer to GET | ✅     | Required for /order-status        |
| Enable CORS              | ✅     | Needed for frontend browser calls |
| Deploy API               | ✅     | Required after changes            |
| Update frontend API_URL  | ✅     | Matches the stage URL             |


**✅ PHASE 5️⃣ STATUS**

> **🟢 PHASE 5️⃣ COMPLETE & VERIFIED**
---

## 🔐 PHASE 6️⃣ — FINAL SECURITY FLOW (MENTAL MODEL)

### 🔐 1️⃣  — ADD DENY ALERTS (CloudWatch Alarms)

- AWS Console → CloudWatch → Logs → Log groups

- Choose:

```
/aws/lambda/<ANY lambda using RBAC>
```

#### Create Metric Filter

- Click Actions → Create metric filter

- Filter pattern:

```
{ $.decision = "DENY" }
```

- Metric namespace:

```
CafeRBAC
```

- Metric name:

```
DeniedRequests
```

- Metric value:

```
1
```

**✅ Create filter**

#### Create Alarm

- Go to CloudWatch → Alarms

- Create alarm on metric:

```
CafeRBAC / DeniedRequests
```

- Condition:

```
>= 3 in 5 minutes
```

- Action:

    - Send SNS email

    - (Optional) Slack webhook later

#### 📌 Result:

> **You get alerted when someone is denied access repeatedly.**

**🔥 Security teams LOVE this.**

### 🔐 2️⃣  — ADD ROLE HIERARCHY

- Add hierarchy map

In rbac.py, near the top:

```
ROLE_HIERARCHY = {
    "admin": ["admin", "employee"],
    "employee": ["employee"],
    "guest": ["guest"]
}
```

- Expand user roles

Replace this line:

```
groups = groups.split(",")
```

With:

```
expanded_roles = set()

for role in groups:
    expanded_roles.update(ROLE_HIERARCHY.get(role, []))

groups = list(expanded_roles)
```

📌 Now:

- Admin can access employee APIs automatically

- You don’t duplicate permissions

### 3️⃣ — ADD READ / WRITE PERMISSIONS permissions.json

- Old (simple)

```
{
  "path": "/admin",
  "roles": ["admin"]
}
```

- New (read / write aware)

```
[
  {
    "path": "/admin",
    "methods": ["GET", "POST", "PUT", "DELETE"],
    "roles": ["admin"]
  },
  {
    "path": "/orders",
    "methods": ["GET"],
    "roles": ["admin", "employee"]
  },
  {
    "path": "/orders",
    "methods": ["POST"],
    "roles": ["employee"]
  }
]
```

- Enforce method in RBAC

In rbac.py, add:

```
method = event.get("requestContext", {}).get("http", {}).get("method")
```

Change rule check:

```
if path.startswith(rule["path"]) and method in rule["methods"]:
```

📌 Result:

✔️ Same endpoint

✔️ Different permissions

✔️ No extra Lambdas

✔️ No IAM mess

### 🌐 4️⃣ — CONFIGURE APP CLIENT (JWT ISSUED HERE)

- Cognito → App integration

- Click App clients

- Click your app client

- VERIFY THESE SETTINGS (DO NOT GUESS)

✔ Enable sign-in API for server-based authentication

✔ OAuth 2.0 enabled

Under OAuth flows:

```
✔ Authorization code grant
```

#### Under OAuth scopes:

```
✔ openid
✔ email
✔ profile
```

- Click Save changes

### 🌐 5️⃣ — CONFIGURE HOSTED UI (FOR LOGIN TEST)

- Go to:

```
AWS Console → Cognito → User Pools → YOUR POOL
→ App integration → Domain
```

- Verify domain exists like:

```
https://cafe-auth.auth.ap-south-1.amazoncognito.com
```

✅ If domain exists → good

❌ If not → create it (Amazon Cognito domain is fine)

📌 **✔️ Copy this domain — you will use it.**

### 🔑 6️⃣ — GET JWT TOKEN (MANDATORY TEST)

#### 1️⃣ Open browser (new tab)

#### Paste this (replace values):

```
https://YOUR_DOMAIN/login
?response_type=token
&client_id=YOUR_CLIENT_ID
&scope=email+openid
&redirect_uri=https://jwt.io
```

#### Example:

```
https://cafe-auth.auth.ap-south-1.amazoncognito.com/login
?response_type=token
&client_id=abc123
&scope=email+openid
&redirect_uri=https://jwt.io
```
#### 2️⃣ Login with Admin user

You will be redirected to jwt.io

- Login with Admin user

- After success → browser redirects to jwt.io

The URL bar will look like this:

```
https://jwt.io/#access_token=eyJraWQiOiJr...
&id_token=eyJraWQiOiJr...
&expires_in=3600
```

#### 3️⃣ COPY ID TOKEN (IMPORTANT)

👉 Copy access_token ONLY

❌ Do NOT use id_token

❌ Do NOT copy the whole URL

It looks like: 

```
eyJraWQiOiJLT...
```

**⚠️ Copy ONLY the id_token, not access_token.**

> **STOP here if token is not received.**

### 🧪 7️⃣ — VERIFY TOKEN CONTENT (NO SKIP)

What you SHOULD verify on jwt.io

- Paste the access_token into jwt.io

You should see payload like:

```
{
  "iss": "https://cognito-idp.ap-south-1.amazonaws.com/...",
  "client_id": "abc123",
  "scope": "email openid",
  "token_use": "access"
}
```

✅ token_use = access → CORRECT

❌ If token_use = id → wrong token

#### ⚠️ About cognito:groups

Important clarity:

- cognito:groups usually appears in id_token

- API Gateway does NOT require it

- For your current lab → ignore groups

Groups matter later for:

- Admin-only Lambdas

- Role-based access

Not for basic auth testing.

#### ✅ FINAL STEP — CALL API GATEWAY (THIS IS THE GOAL)

Now run:

```
curl -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
https://API_ID.execute-api.REGION.amazonaws.com/status/order-status
```

#### ✅ EXPECTED RESULTS

#### ✅ Success

```
{
  "orders": [...],
  "metrics": {...}
}
```

#### ❌ Missing / wrong token

```
401 Unauthorized
```

#### 🚪 8️⃣ — CREATE API GATEWAY COGNITO AUTHORIZER
> **If you did not create then follow this step... otherwisse leave it**

- API Gateway → Your API

- Click Authorizers

- Click Create authorizer

#### Fill EXACTLY:

```
Name: CafeCognitoAuthorizer
Type: Cognito
Cognito User Pool: CafeUserPool
Token source: Authorization
```

- Click Create

### 🔗 9️⃣ — ATTACH AUTHORIZER TO API METHOD

- **API Gateway → Resources**

- **Select endpoint:**

```
GET /analytics
```

- **Click Method Request**

- **Authorization:**

```
Cognito User Pool Authorizer
```

- **Select:**

```
CafeCognitoAuthorizer
```

- Click Save

### 🚀 🔟 — DEPLOY API (DO NOT SKIP)

- **API Gateway → Deploy API**

- **Stage:**

```
prod
```

- Click Deploy


**✅ PHASE 6️⃣ STATUS**

> **🟢 PHASE 6️⃣ COMPLETE & VERIFIED**

---
## 🔐 PHASE 7️⃣ Secure & Security ARCHITECTURE Dashboard — Secure Admin Pages

### 1️⃣ Centralize Authentication -  central-auth-api.js template (reusable)
> **🧠 OPTION 1 (RECOMMENDED): central-auth-api.js (All logic in one file)**

### 1️⃣ 📄 /admin/assets/central-auth-api.js

[central-auth-api.js](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20JS%20Backend%20Code%20Script/central-auth-api.js)

### 2️⃣  🔧 central-auth-api.js Minimal Configuration Replacement

```
/* ================= CONFIG ================= */
const USER_POOL_ID = "YOUR_COGNITO_USER_POOL_ID";   // Replace with your Cognito User Pool ID
const CLIENT_ID = "YOUR_APP_CLIENT_ID";             // Replace with your App Client ID (no secret)
const COGNITO_DOMAIN = "YOUR_DOMAIN.auth.ap-south-1.amazoncognito.com"; // Replace with your Cognito Hosted UI domain
const REDIRECT_URI = window.location.origin + window.location.pathname; // Usually fine as-is
```
### 🧩 STEP 3 — Update Dashboard HTML (Minimal Change)

#### ⚠️ All these changes have already been made in all the admin files, so there is no need to follow these steps of phase 1.

####  Frontend Web Admin Pages

#### 1️⃣ Frontend Admin Dashboard 
> **📄 File: dashboard.html**

#### 1️⃣ Create dashboard.html

```
sudo nano /var/www/html/dashboard.html
```

#### 2️⃣ Paste Code

[dashboard.html](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-admin%20dashboard%20page/dashboard.html)

#### 5️⃣ Restart Apache (MANDATORY)

```
sudo systemctl restart httpd
```

#### 6️⃣ Open page in browser (MANDATORY)

```
http:// Your EC2 Public IP/dashboard.html
```

#### 2️⃣ Frontend Admin Order-Status Dashboard

```
sudo nano /var/www/html/order-status.html
```

[order-status.html](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-order-status/CC%20-%20Order-Status_LIVE%20ADMIN%20DASHBOARD_many%20orders/order-status.html)


#### 3️⃣ Frontend Admin Analytics Dashboard

```
sudo nano /var/www/html/analytics.html
```

[analytics.html](../☕%20AWS%20CAFE%20—%20Front%20%26%20Backend%20Code%20Script/☕%20AWS%20CAFE%20—%20Frontend%20Code%20Script/Charlie-Cafe%20-%20Sales%20Analytics/analytics.html)


#### 🏆 FINAL RESULT (Big Picture)

You now have enterprise-grade frontend security:

✅ One auth.js for all pages

✅ Cognito Hosted UI login

✅ JWT → API Gateway Authorizer → Lambda

✅ CloudFront + ALB compatible

✅ Clean architecture (no inline hacks)

✅ Admin dashboard, order status, analytics fully secured

**✅ PHASE 7️⃣ STATUS**

> **🟢 PHASE 7️⃣ COMPLETE & VERIFIED**

# SECTION 1️⃣  COMPLETE ✅
---
# SECTION 2️⃣ Cognito + FrontEnd Advance Features

### ✅ What you already have (important)

In central-auth-api.js you already implemented working Cognito logout:

```
logout(redirectUrl = window.location.origin) {
    localStorage.removeItem("access_token");
    const url =
        `https://${CONFIG.COGNITO_DOMAIN}/logout` +
        `?client_id=${CONFIG.CLIENT_ID}` +
        `&logout_uri=${encodeURIComponent(redirectUrl)}`;
    window.location.href = url;
}
```

#### ✅ This:

- Clears token

- Calls Cognito Hosted UI logout

- Redirects safely

So logic is correct and production-ready 👍

### ❌ What was missing in admin-dashboard.html

You have the button:

```
<button class="btn btn-warning btn-sm w-100" id="logoutBtn">🔒 Logout</button>
```

But ❌ you never attached it to Cognito logout.

### ✅ THE FIX (this is all you need)

### 1️⃣ Keep the button (Already Added)

```
<button class="btn btn-warning btn-sm w-100" id="logoutBtn">🔒 Logout</button>
```

### 2️⃣ Add this JS AFTER central-auth-api.js (Already Added)

Replace this part in admin-dashboard.html:

```
CHARLIE.auth.protectPage();          // login required
CHARLIE.auth.setupLogoutButton();    // logout button
```

#### ✅ This line is the key

It binds the button to Cognito sign-out.

### 3️⃣ (Optional but recommended) Explicit redirect (Already Added)

If you want logout → index.html instead of homepage:

```
CHARLIE.auth.setupLogoutButton("logoutBtn", "index.html");
```

### 🔁 What happens now (working flow)

- User clicks Logout

- access_token removed from localStorage

- Browser redirects to:

```
https://<your-cognito-domain>/logout
```

- Cognito session is destroyed

- User redirected to index.html

- Protected pages → auto redirect to login again

✅ 100% correct Cognito behavior

### ✅ Final Verdict (no confusion)

| Question                                  | Answer                      |
| ----------------------------------------- | --------------------------- |
| Is Cognito logout implemented?            | ✅ YES                       |
| Is logout button present?                 | ✅ YES                       |
| Was it wired correctly before?            | ❌ NO                        |
| Will it work after `setupLogoutButton()`? | ✅ YES                       |
| Is this best practice?                    | ✅ YES (centralized & clean) |


---
### 3️⃣ AUTO LOGOUT ON TOKEN EXPIRY (IMPORTANT)

Add this ONCE in admin-dashboard.js:

```
// ⏱ Auto logout every 30 seconds if token expired
setInterval(() => {
    const token = localStorage.getItem("access_token");
    if (!token) return;

    try {
        const payload = JSON.parse(atob(token.split(".")[1]));
        if (payload.exp * 1000 < Date.now()) {
            alert("🔐 Session expired");
            CHARLIE.auth.logout();
        }
    } catch {
        CHARLIE.auth.logout();
    }
}, 30000);
```

### 4️⃣ ORDERS + CSV EXPORT

```
async function loadOrders() {
    const data = await CHARLIE.api.adminDashboard.fetchData();
    renderOrdersTable(data.orders || []);
}

function renderOrdersTable(orders) {
    let html = `<table class="table table-dark">
        <tr><th>ID</th><th>Status</th><th>Total</th></tr>`;

    orders.forEach(o => {
        html += `<tr>
            <td>${o.order_id}</td>
            <td>${o.status}</td>
            <td>${o.total}</td>
        </tr>`;
    });

    html += `</table>`;
    document.getElementById("ordersTable").innerHTML = html;
}

function exportOrdersCSV() {
    const rows = document.querySelectorAll("#ordersTable tr");
    let csv = [];

    rows.forEach(row => {
        const cols = row.querySelectorAll("td, th");
        csv.push([...cols].map(c => `"${c.innerText}"`).join(","));
    });

    const blob = new Blob([csv.join("\n")], { type: "text/csv" });
    const a = document.createElement("a");
    a.href = URL.createObjectURL(blob);
    a.download = "orders.csv";
    a.click();
}
```

### 5️⃣ HR — EMPLOYEE LIST (ADMIN)

```
async function loadEmployees() {
    const employees = await CHARLIE.api.getAllEmployees();
    let html = "<ul class='list-group'>";

    employees.forEach(e => {
        html += `<li class="list-group-item bg-dark text-light">
            ${e.name} (${e.role})
        </li>`;
    });

    html += "</ul>";
    document.getElementById("employeeList").innerHTML = html;
}
```

### 6️⃣ STAFF — OWN ATTENDANCE

```
async function loadMyAttendance() {
    const user = CHARLIE.getUserRoles(); // or sub from token
    const data = await CHARLIE.api.getAttendance("me");

    let html = "<ul>";
    data.forEach(a => {
        html += `<li>${a.date} — ${a.check_in} → ${a.check_out}</li>`;
    });
    html += "</ul>";

    document.getElementById("myAttendance").innerHTML = html;
}
```

### 7️⃣ ANALYTICS + CHARTS (ADMIN ONLY)

```
async function loadAnalytics() {
    CHARLIE.requireAdmin();

    const data = await CHARLIE.api.adminAttendance.getMonthlySummary();

    const ctx = document.getElementById("attendanceChart");
    new Chart(ctx, {
        type: "bar",
        data: {
            labels: data.labels,
            datasets: [{
                label: "Attendance",
                data: data.values
            }]
        }
    });
}
```

---

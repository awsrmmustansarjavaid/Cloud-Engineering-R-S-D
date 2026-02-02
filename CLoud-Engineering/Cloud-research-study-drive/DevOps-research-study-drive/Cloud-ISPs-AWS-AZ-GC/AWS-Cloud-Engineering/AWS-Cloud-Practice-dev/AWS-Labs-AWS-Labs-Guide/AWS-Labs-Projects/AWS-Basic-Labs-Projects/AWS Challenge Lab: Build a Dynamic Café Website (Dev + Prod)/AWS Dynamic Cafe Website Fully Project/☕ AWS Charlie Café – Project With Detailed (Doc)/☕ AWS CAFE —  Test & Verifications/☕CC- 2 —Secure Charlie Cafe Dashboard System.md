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
https://charlie-cafe-admin.auth.us-east-1.amazoncognito.com/login
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

**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---

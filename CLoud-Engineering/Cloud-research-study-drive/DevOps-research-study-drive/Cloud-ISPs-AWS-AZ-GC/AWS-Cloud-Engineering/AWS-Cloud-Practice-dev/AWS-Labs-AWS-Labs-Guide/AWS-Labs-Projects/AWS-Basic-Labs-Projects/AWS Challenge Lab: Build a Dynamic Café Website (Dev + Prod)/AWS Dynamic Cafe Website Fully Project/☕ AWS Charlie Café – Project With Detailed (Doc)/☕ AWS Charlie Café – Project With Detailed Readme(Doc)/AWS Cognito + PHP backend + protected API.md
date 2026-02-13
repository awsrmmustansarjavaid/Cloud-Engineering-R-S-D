# Charlie Cafe - AWS Cognito + PHP backend + protected API

## ✅ Correct Cognito Protected API Flow

### 1️⃣ User Login (Frontend / Mobile App)

User logs in via Cognito → Cognito returns:

-    id_token

-    access_token

-    refresh_token

### ⚠️ IMPORTANT: 

For calling protected APIs → Use access_token
NOT id_token.

### 2️⃣ Client Calls Your PHP Backend

#### Client must send:

```
Authorization: Bearer ACCESS_TOKEN
```

#### Example:

```
GET /api/profile
Authorization: Bearer eyJraWQiOiJLT...
```

### 3️⃣ PHP Backend Must Verify JWT Token

#### Your PHP server must:

-    Extract token from header

-    Decode JWT

-    Verify signature using Cognito public keys

#### Validate:

-    issuer (iss)

-    audience (client_id)

-    expiration (exp)

-    token_use = access

### ✅ Correct PHP JWT Verification (Production Way)

#### Install Firebase JWT:

```
composer require firebase/php-jwt
```

#### Example PHP Code

```
require 'vendor/autoload.php';

use Firebase\JWT\JWT;
use Firebase\JWT\JWK;

$headers = getallheaders();

if (!isset($headers['Authorization'])) {
    http_response_code(401);
    exit("No authorization header");
}

$token = str_replace('Bearer ', '', $headers['Authorization']);

// Get Cognito public keys
$jwks = file_get_contents('https://cognito-idp.YOUR_REGION.amazonaws.com/YOUR_USER_POOL_ID/.well-known/jwks.json');
$jwks = json_decode($jwks, true);

try {
    $keys = JWK::parseKeySet($jwks);
    $decoded = JWT::decode($token, $keys);

    // Validate token_use
    if ($decoded->token_use !== 'access') {
        throw new Exception('Invalid token use');
    }

    // Token valid
    print_r($decoded);

} catch (Exception $e) {
    http_response_code(401);
    echo "Unauthorized: " . $e->getMessage();
}
```
---
### 🚨 Most Common Cognito Access Token Issues

### ❌ 1. Using ID Token Instead of Access Token

#### Access token has:

```
"token_use": "access"
```

#### ID token has:

```
"token_use": "id"
```

If you validate wrong one → it fails.

### ❌ 2. Wrong Issuer Check

#### Issuer must match exactly:

```
https://cognito-idp.YOUR_REGION.amazonaws.com/YOUR_USER_POOL_ID
```

Even a small mismatch = invalid token.

### ❌ 3. Token Expired

Access token expires in 1 hour by default.

#### Check:

```
exp
```

If expired → use refresh token.

### ❌ 4. API Gateway Cognito Authorizer Misconfigured

#### If using API Gateway:

- Authorizer must use User Pool

- Token Source: Authorization

- Must send Bearer <token>

### ❌ 5. Wrong App Client (No Secret vs With Secret)

If your app client has a secret and you're using public frontend login, it will fail unless you implement secret hash.

##### For mobile/web apps:

- Disable "Generate client secret"

### 🔎 Debugging Checklist For You

#### Since you suspect access token issue, check:

#### Decode token at:
https://jwt.io

#### Verify:

    - token_use = access

    - correct iss

    - correct client_id

    - not expired

- Make sure PHP verifies using Cognito JWKS.

### 🏗 Recommended Clean Architecture (Best Practice)

Frontend → Cognito
Frontend → API (with Access Token)
PHP backend → verifies JWT only
NO session handling required

Stateless + secure.

### 💡 If You Want Stronger Enterprise Setup

#### You can:

- Use API Gateway + Cognito Authorizer

- Then PHP doesn’t verify token manually

- API Gateway sends user claims to PHP

This is more scalable.

### 🎯 I Need From You To Diagnose Exactly

#### Tell me:

Are you using API Gateway or direct PHP server?

What error are you getting?

401?

Invalid signature?

Token expired?

Are you using ID token or access token?

Is your app client configured with secret?

---
## 📢 Exactly how to get Cognito tokens


### ✅ METHOD 1 — From Frontend (Most Common – Recommended)

#### If you are using:

    - Web app (React / Angular / Vue / HTML JS)

    - Mobile app

    - Hosted UI

You authenticate user → Cognito returns tokens.

### 🔹 Option A: Using Cognito Hosted UI (Easiest)

#### Step 1 – Redirect user to login URL


```
https://YOUR_DOMAIN.auth.YOUR_REGION.amazoncognito.com/login?
client_id=YOUR_CLIENT_ID
&response_type=code
&scope=email+openid+profile
&redirect_uri=https://yourapp.com/callback
```

#### After login → Cognito redirects to:

```
https://yourapp.com/callback?code=AUTH_CODE
```

#### Step 2 – Exchange Code for Tokens

#### Send POST request to:

```
https://YOUR_DOMAIN.auth.YOUR_REGION.amazoncognito.com/oauth2/token
```

#### Example (PHP CURL):

```
$ch = curl_init();

curl_setopt($ch, CURLOPT_URL, "https://YOUR_DOMAIN.auth.YOUR_REGION.amazoncognito.com/oauth2/token");
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query([
    'grant_type' => 'authorization_code',
    'client_id' => 'YOUR_CLIENT_ID',
    'code' => $_GET['code'],
    'redirect_uri' => 'https://yourapp.com/callback'
]));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

$response = curl_exec($ch);
curl_close($ch);

echo $response;
```

#### You Will Receive:

```
{
  "access_token": "eyJraWQiOiJLT...",
  "id_token": "eyJraWQiOiJLT...",
  "refresh_token": "eyJjdHkiOiJKV1Qi...",
  "expires_in": 3600,
  "token_type": "Bearer"
}
```

Use access_token for API calls.

### ✅ METHOD 2 — Using USERNAME + PASSWORD (Direct API Call)

If you want server-side login (no hosted UI).

#### Send request to:

```
https://cognito-idp.YOUR_REGION.amazonaws.com/
```

#### Headers:

```
X-Amz-Target: AWSCognitoIdentityProviderService.InitiateAuth
Content-Type: application/x-amz-json-1.1
```

#### Example PHP

```
$data = [
    "AuthFlow" => "USER_PASSWORD_AUTH",
    "ClientId" => "YOUR_CLIENT_ID",
    "AuthParameters" => [
        "USERNAME" => "user@email.com",
        "PASSWORD" => "userpassword"
    ]
];

$ch = curl_init("https://cognito-idp.YOUR_REGION.amazonaws.com/");
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    "Content-Type: application/x-amz-json-1.1",
    "X-Amz-Target: AWSCognitoIdentityProviderService.InitiateAuth"
]);
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

$response = curl_exec($ch);
curl_close($ch);

echo $response;
```

#### You will get:

```
{
  "AuthenticationResult": {
    "AccessToken": "...",
    "IdToken": "...",
    "RefreshToken": "...",
    "ExpiresIn": 3600
  }
}
```

### ⚠️ IMPORTANT:

#### For this to work:

#### In App Client settings:

- Enable ALLOW_USER_PASSWORD_AUTH

- Disable client secret (if public app)

### Steps Method 2 (USERNAME + PASSWORD login directly from PHP).

### ✅ STEP 1 — Configure Cognito Correctly (Very Important)

- Go to: AWS Console → Cognito → User Pools → Your Pool → App clients

#### 🔹 1. Create / Edit App Client

#### Make sure:

#### ✅ DO NOT enable "Generate client secret"
(If secret is enabled, login will fail unless you calculate secret hash.)

#### 🔹 2. Enable Auth Flow

- Go to: App client → Authentication flows

#### Enable:

✅ ALLOW_USER_PASSWORD_AUTH

✅ ALLOW_REFRESH_TOKEN_AUTH

Save changes.

### ✅ STEP 2 — PHP Login Code (USERNAME + PASSWORD)

This will call Cognito directly.

- Replace:

- YOUR_REGION

- YOUR_CLIENT_ID

#### ✅ Working PHP Example

```
<?php

$region = "us-east-1"; // change
$clientId = "YOUR_CLIENT_ID";

$username = "user@email.com";
$password = "UserPassword123!";

$data = [
    "AuthFlow" => "USER_PASSWORD_AUTH",
    "ClientId" => $clientId,
    "AuthParameters" => [
        "USERNAME" => $username,
        "PASSWORD" => $password
    ]
];

$ch = curl_init("https://cognito-idp.$region.amazonaws.com/");

curl_setopt($ch, CURLOPT_HTTPHEADER, [
    "Content-Type: application/x-amz-json-1.1",
    "X-Amz-Target: AWSCognitoIdentityProviderService.InitiateAuth"
]);

curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

$response = curl_exec($ch);

if (curl_errno($ch)) {
    echo 'Curl error: ' . curl_error($ch);
}

curl_close($ch);

$result = json_decode($response, true);

print_r($result);
```

### ✅ Successful Response Example

#### If login correct:

```
{
  "AuthenticationResult": {
    "AccessToken": "eyJraWQiOiJLT...",
    "IdToken": "eyJraWQiOiJLT...",
    "RefreshToken": "eyJjdHkiOiJKV1Qi...",
    "ExpiresIn": 3600,
    "TokenType": "Bearer"
  }
}
```

#### Use:

```
$accessToken = $result['AuthenticationResult']['AccessToken'];
```

#### Send this to your protected API:

```
Authorization: Bearer ACCESS_TOKEN
```

### 🚨 Common Errors & Fix

### ❌ Error: NotAuthorizedException

#### Reason:

- Wrong password

- User not confirmed

- App client secret enabled

### ❌ Error: InvalidParameterException: USER_PASSWORD_AUTH is not enabled

#### Fix:

- Enable ALLOW_USER_PASSWORD_AUTH in app client.

### ❌ Error: SECRET_HASH missing

#### This means:
- You enabled client secret.

#### Either:

- Disable client secret (recommended)

OR

- Implement secret hash (I can give code if needed)

### ✅ STEP 3 — Refresh Token (After 1 Hour)

#### When access token expires:

```
$data = [
    "AuthFlow" => "REFRESH_TOKEN_AUTH",
    "ClientId" => $clientId,
    "AuthParameters" => [
        "REFRESH_TOKEN" => $refreshToken
    ]
];
```

Call same endpoint.

### 🔐 IMPORTANT SECURITY NOTE

- Method 2 means:

    - You are handling raw passwords in PHP backend.

- Best practice:

    - Use HTTPS only

    - Never log passwords

    - Do not store passwords

### 🏗 Recommended Architecture For Production

#### Better approach:

Frontend login → Cognito
Frontend sends access token → PHP
PHP only verifies token

More secure + scalable.



### ✅ METHOD 3 — Using AWS Amplify (Frontend Only)

#### If using JavaScript:

```
import { Auth } from 'aws-amplify';

const user = await Auth.signIn(email, password);

const session = await Auth.currentSession();

const accessToken = session.getAccessToken().getJwtToken();
const idToken = session.getIdToken().getJwtToken();
```

### 🔥 Which One Should You Use?

#### For your PHP backend project:

#### Best Architecture:

Frontend → Cognito login
Frontend → Send access_token to PHP
PHP → Verify JWT

Do NOT login from PHP unless absolutely required.

### 🎯 Quick Checklist For You

- Go to: AWS Console → Cognito → User Pool → App Clients

#### Check:

- App client has NO secret (if web app)

- ALLOW_USER_PASSWORD_AUTH enabled (if using API login)

- OAuth flows enabled (if using Hosted UI)

---

## Cognito Client Secret

1️⃣ How to check if client secret is enabled
2️⃣ How to disable it
3️⃣ What to do if it cannot be disabled

### ✅ How To Check If Client Secret Is Enabled

- Go to: AWS Console → Cognito → User Pools → Your User Pool → App integration → App clients

- Click on your App Client.

- Look for this field:

```
Client secret
```

#### If you see:

```
Client secret: ***************
```

👉 That means secret IS enabled.

#### If you see:

```
No client secret
```

👉 That means secret is disabled (this is what you want for web/mobile apps).

### ❗ Important AWS Rule

- You CANNOT disable client secret on an existing app client.

- AWS does NOT allow editing this after creation.

So if secret is enabled → you must create a new app client.

### ✅ How To Disable Client Secret (Correct Way)

You must create a NEW app client.

### Step-by-step

- Go to: User Pool → App integration → App clients

#### Click:

- ➕ Create app client

#### Now:

#### 🔹 VERY IMPORTANT

#### When creating:

- UNSELECT / DO NOT CHECK:

```
Generate client secret
```

This must be unchecked.

#### 🔹 Enable Authentication Flow

After creation:

- Go to: App client → Authentication flows

#### Enable:

✅ ALLOW_USER_PASSWORD_AUTH

✅ ALLOW_REFRESH_TOKEN_AUTH

- Save.

✅ After That

#### Use the NEW client ID in your PHP code:

```
$clientId = "NEW_CLIENT_ID";
```

Now your USER_PASSWORD_AUTH will work without SECRET_HASH error.

### 🚨 If You Keep Using Client With Secret Enabled

#### You will get this error:

```
SECRET_HASH was not received
```

If for some reason you MUST use secret-enabled client, then you must calculate secret hash.

#### Example:

```
function calculateSecretHash($username, $clientId, $clientSecret) {
    return base64_encode(
        hash_hmac(
            'sha256',
            $username . $clientId,
            $clientSecret,
            true
        )
    );
}
```

#### Then add:

```
"SECRET_HASH" => calculateSecretHash($username, $clientId, $clientSecret)
```

But this is NOT recommended for public apps.

### 🎯 Best Practice For Your PHP Backend

#### If this is:

- Web app

- Mobile app

- API backend

👉 Create new App Client WITHOUT secret.

- Cleaner.
- Safer.
- Easier.

### 🎯 When to Use Public vs Confidential

| Application Type                  | Recommended Client Type |
| --------------------------------- | ----------------------- |
| React / Angular SPA               | ✅ Public (No Secret)    |
| Mobile App                        | ✅ Public                |
| Backend Server (Node, .NET, Java) | ✅ Confidential          |
| Machine-to-machine                | ✅ Confidential          |

If you’re building a frontend app → Always choose Public client

---

### ✅ 2️⃣ OAuth Grant Type — Which Is Recommended?

You asked:

#### Option 1: ✔ Implicit grant (Recommended)

#### Option 2: ✔ Authorization code grant (Optional)

⚠️ The UI is misleading.

### 🔥 The REAL Recommendation (2026 Security Standard)

#### ✅ Authorization Code Grant (WITH PKCE) → Highly Recommended

### ❌ Implicit Grant → Not Recommended anymore

Why?

#### ❌ Implicit Grant

- Tokens returned in browser URL

- Less secure

- Considered legacy

- Being phased out in modern OAuth security best practices

### ✅ Authorization Code Grant (with PKCE)

- More secure

- Industry standard

- Recommended by OAuth 2.1

#### Used by:

- Google

- Microsoft

- Auth0

- Okta

- AWS Amplify

### 📍 Where to configure OAuth in new UI

- Go to User Pool

- Open App integration

- Click your App client

- Go to Login pages / Hosted UI

- Click Edit

- Under OAuth 2.0 grant types

#### Choose:

✅ Authorization code grant

❌ Do NOT select Implicit grant (unless legacy reason)

### 🎯 Final Recommendation Summary

If you're building:

#### 🔹 SPA (React, Angular, Vue)

- Client type → Public

- Grant type → Authorization Code Grant

- Enable PKCE (automatic for public clients)

#### 🔹 Backend Server App

- Client type → Confidential

- Grant type → Authorization Code Grant

### 🚀 Clean Best-Practice Setup (Modern Secure Setup)

- Public Client

- Authorization Code Grant

- PKCE enabled

- No Implicit grant

- Use HTTPS callback URL

- Enable only required scopes (openid, email, profile)
---

## 🚨 FIRST: Your Current Problem

```
CloudFront → SPA (HTML/JS)
↓
Cognito Hosted UI
↓
API Gateway (Cognito Authorizer)
↓
Lambda
↓
RDS + DynamoDB
```

You are mixing:

- SPA (browser login)

- PHP backend (curl)

- Cognito protected API Gateway

That combination changes what grant type you should use.

So let’s fix the confusion.

### 🔥 CRITICAL CORRECTION

Earlier configuration used:

```
response_type=token
Implicit Grant
```

⚠️ That is NOT ideal for your setup anymore.

### ✅ WHAT YOU SHOULD USE (FOR CHARLIE CAFE)

Since:

- You are using SPA (CloudFront frontend)

- API Gateway protected by Cognito Authorizer

- Sometimes testing via curl

- No real server-side session handling

You should use:

✅ Authorization Code Grant (NOT Implicit)

✅ Public Client (NO client secret)

✅ PKCE (automatic for SPA)

### ❌ Why Implicit Is Causing Problems

#### Implicit:

- Returns token in URL fragment (#access_token=...)

- Harder to debug

- Doesn’t issue refresh token reliably

- Not recommended by OAuth 2.1

- Can cause 400 if scopes or config mismatch

#### If you get:

- 400 Bad Request from Cognito login

- “invalid_request”

- white screen after redirect

- curl failing with 401

#### Most of the time it’s:

✔ wrong redirect URI

✔ wrong response_type

✔ client secret enabled

✔ mismatch grant type

### 🎯 FINAL RECOMMENDED CONFIG FOR YOU

- Go to: Cognito → User Pool → App Integration → App Client → Edit

#### 1️⃣ App Client

| Setting       | Value         |
| ------------- | ------------- |
| App type      | Public client |
| Client secret | ❌ Disabled    |
If secret exists → DELETE this app client → recreate as Public.

#### 2️⃣ OAuth 2.0 Grant Types

✔ Authorization code grant

❌ DO NOT enable Implicit grant

#### 3️⃣ Scopes

✔ openid

✔ email

✔ profile

Nothing else.

#### 4️⃣ Change Your Login URL

##### Instead of:

```
response_type=token
```

##### Use:

```
response_type=code
```

##### Example:

```
https://YOUR_DOMAIN.auth.us-east-1.amazoncognito.com/login
?client_id=YOUR_CLIENT_ID
&response_type=code
&scope=openid+email+profile
&redirect_uri=https://yourcloudfront/cafe-admin-dashboard.html
```

### ⚠️ VERY IMPORTANT

#### When using Authorization Code Flow:

##### Cognito will redirect like:

```
https://yourcloudfront/cafe-admin-dashboard.html?code=abc123
```

NOT with access_token.

Your frontend must then exchange that code for tokens.

### 💡 SIMPLE OPTION (Best for Your Lab)

Since you’re not using Amplify and not building a complex auth SDK…

#### You have two clean options:

#### OPTION A (Cleanest for Lab – Recommended)

Keep SPA simple.
Use Authorization Code flow.
Use JavaScript to exchange code for tokens.

OR

#### OPTION B (Simplest Debugging Mode)

Temporarily remove Cognito authorizer from API Gateway.
Test Lambda directly.
Make sure backend works.
Then re-enable authorizer.

Because right now you don't know if issue is:

- Cognito

- API Gateway

- Lambda

- RDS query

- CORS

- PHP curl

- wrong stage URL

You must isolate layers.

### 🔍 About Your PHP + curl Issue

#### Here is likely what happened:

#### If your API is protected by Cognito Authorizer:

#### API Gateway expects:

```
Authorization: Bearer ACCESS_TOKEN
```

#### But:

If you used Authorization Code grant,
You might accidentally be sending ID token instead of access token.

#### ⚠️ API Gateway authorizer validates ACCESS TOKEN, not ID token.

Very common mistake.

### 🧪 Debug Checklist (Follow Exactly)

#### STEP 1

Disable authorizer temporarily.
Call API.
If Lambda works → backend OK.

#### STEP 2

Re-enable authorizer.

Login via browser.

Copy ACCESS TOKEN only.

#### Test:

```
curl -H "Authorization: Bearer ACCESS_TOKEN" \
https://api-url/status/order-status
```

If that works → Cognito is OK.

If not → token mismatch.

### 🚨 Most Common Charlie Cafe Mistakes I See

- Using ID token instead of access token

- Client secret accidentally enabled

- Implicit + Authorization Code both enabled causing confusion

- Callback URL mismatch (http vs https)

- API stage mismatch (/prod vs /status)

- Not redeploying API after authorizer change

- CORS not enabled

- PHP sending header wrong format

#### Correct header must be EXACT:

```
Authorization: Bearer eyJraWQiOiJr...
```

Not:

```
Authorization: eyJraWQiOiJr...
```

Not:

```
Bearer: eyJraWQiOiJr...
```

### 🧠 My Professional Suggestion For You

Since this is a lab but you want production-style architecture:

#### 🔐 Use:

- Public client

- Authorization Code grant

- No Implicit

- PKCE

- Access token for API

- Cognito Authorizer

This is modern 2026 best practice.

### 🎯 Direct Answer To Your Original Question

#### Between:

1️⃣ Implicit grant

2️⃣ Authorization code grant

#### For Charlie Cafe:

✅ Authorization Code Grant is highly recommended

❌ Implicit grant should not be used anymore

---
## Charlie Cafe production New Architecture Design 

You’re trying to make Charlie Cafe production-ready, and that means we must:

- Remove configuration conflicts

- Standardize ONE OAuth flow

- Make frontend ↔ Cognito ↔ API Gateway clean

- Ensure backend security is correct

- Eliminate 400 / white screen / curl confusion

And the only way to properly fix this is to look at your actual code.

### ✅ What I Need From You

Please share:

### 1️⃣ central-auth-api.js

This is critical because:

- It probably handles login redirect

- Parses tokens from URL

- Stores tokens

- Attaches Authorization header

- May still be using response_type=token

### 2️⃣ One protected frontend page

Example:

- order-status.html

OR

- cafe-admin-dashboard.html

I need to see:

- How it checks login

- How it loads token

- How it calls API

- How it handles redirect

### 3️⃣ (Optional but helpful)

The login button code or login redirect logic.

### 🎯 What I Will Do After You Share

I will:

- Analyze if you're using Implicit or Authorization Code

- Detect if you're using ID token instead of access token

- Check if token parsing is broken

- Fix header attachment

- Standardize your OAuth flow

- Give you corrected, production-ready version

- Remove all misleading configurations

We will simplify everything.

### 🔥 Important: Before You Paste Code

Tell me:

Currently your Cognito App Client has:

✔ Public client?

✔ Client secret disabled?

✔ Authorization Code grant enabled?

❌ Implicit disabled?

Or are you still on Implicit?

Just answer that quickly first.

### 🏗 Your Goal (And I Agree With It)

You want:

“A real cafe owner could deploy this system professionally.”

That means:

- Secure API

- No exposed secrets

- JWT validated at API Gateway

- Proper OAuth flow

- Refresh tokens working

- Clean architecture

We will get there.

### 🚨 ROOT PROBLEM IN YOUR Previous Architecture PROJECT

You currently have TWO completely different architectures mixed together:

### 🟢 Architecture A (Secure SPA + Cognito)

#### Used in:

- central-auth-api.js

- CloudFront frontend

- API_BASE = p4vrr4b60c.execute-api...

- Cognito Authorizer attached

- JWT required

### 🔴 Architecture B (Old Public PHP + No Auth)

#### Used in:

- orders.php

- admin-orders.php

- API = q8rq19tfka.execute-api...

- No Authorization header

- No Cognito protection

You are literally calling two different APIs:

```
JS SPA → https://p4vrr4b60c.execute-api...
PHP pages → https://q8rq19tfka.execute-api...
```

#### That alone explains:

- 400 errors

- Unauthorized

- curl failing

- data not loading

- confusion about Cognito

You are debugging two systems at once.

### 🎯 FIRST DECISION YOU MUST MAKE

Do you want:

### OPTION 1️⃣ Public customer ordering (no login)

Customers place orders without Cognito

AND

### OPTION 2️⃣ Admin / Employee dashboard protected by Cognito

👉 This is the correct real-world café architecture.

Customers do NOT login.
Staff login.

### 🔥 PROFESSIONAL ARCHITECTURE FOR CHARLIE CAFE

Here is what a real café production system would look like:

### 🟢 Public APIs (NO Cognito)

#### Used by:

- orders.php

- payment

- order-status

#### Example:

```
POST /public/orders
POST /public/orders/cash-payment
GET  /public/order-status
```

- No JWT.
- No Cognito.
- Open but validated in Lambda.

### 🔐 Protected APIs (Cognito Required)

#### Used by:

- Admin dashboard

- HR

- Attendance

- Reports

- Mark paid

- Analytics

#### Example:

```
GET  /admin/orders
POST /admin/mark-paid
GET  /admin/dashboard
GET  /admin/attendance
```

#### Protected by:
- Cognito Authorizer

### 🧠 WHY YOUR CURRENT PHP IS WRONG

#### In admin-orders.php you are doing:

```
curl_init($ordersApi);
```

No Authorization header.

If you attach Cognito Authorizer to that endpoint,
it will return:

401 Unauthorized

That is correct behavior.

### ⚠️ SECOND MAJOR ISSUE IN YOUR JS

Your central-auth-api.js is using:

```
response_type=token
```

That is Implicit Flow.

Earlier I told you to move to Authorization Code,
but your code is clearly still Implicit.

Your entire token handling logic:

```
window.location.hash
access_token
```

ONLY works with Implicit flow.

So if you switch Cognito to Authorization Code
without changing JS,
your login will break.

### 🎯 WHAT I RECOMMEND FOR YOU (FINAL ARCHITECTURE)

Since this is a lab but you want production style:

#### ✅ KEEP IMPLICIT FLOW (For Now)

Yes — I am overriding earlier advice for your specific situation.

#### Why?

#### Because:

- You are not using Amplify

- You are not exchanging auth code

- Your JS already works with hash tokens

- Simpler for your lab

#### But:

Use Implicit ONLY for Admin SPA.
Not for PHP.

### 🏗 CLEAN ARCHITECTURE PLAN

### STEP 1 — Separate APIs Properly

#### In API Gateway:

Public Stage (No Cognito Authorizer)

```
/public/orders
/public/orders/cash-payment
/public/order-status
```

#### Used by:

- orders.php

- payment

- tracking page

- Protected Stage (With Cognito Authorizer)

```
/admin/orders
/admin/mark-paid
/admin/dashboard
/admin/hr/*
```

#### Used by:

- CloudFront SPA

- central-auth-api.js

### 🔥 STEP 2 — Stop Using PHP For Admin

This is critical.

Your admin-orders.php should NOT exist anymore.

#### Replace it with:

- CloudFront admin-orders.html

- Using central-auth-api.js

- Using secureFetch()

- PHP + Cognito browser auth = messy architecture.

### 🔥 STEP 3 — Fix Your API_BASE Confusion

You currently have:

#### JS:

```
p4vrr4b60c.execute-api...
```

#### PHP:

```
q8rq19tfka.execute-api...
```

- Choose ONE API Gateway.

- Delete the other.

- Deploy clean.

### 🧩 WHY YOU GOT 400 ERRORS

#### Because you likely:

- Enabled Cognito authorizer on /dev/orders

- But PHP didn’t send JWT

- So API Gateway rejected

- So curl returned 401 or 400

- So white screen

That is correct behavior.

### 🎯 FINAL PROFESSIONAL STRUCTURE

#### Customer side:

```
orders.php  → public API (no auth)
```

#### Admin side:

```
CloudFront SPA
central-auth-api.js
Cognito login
Protected API
```

Do NOT mix them.

### 🔍 Now Let’s Fix Your Project Properly

#### Answer these 3 things:

1️⃣ Do you want customers to login? (Yes/No)

2️⃣ Do you want to keep PHP admin dashboard? (Yes/No)

3️⃣ Are you ready to delete one of the API Gateways and standardize?

### 💬 My Honest Professional Advice

For a real café:

✔ Customers do NOT login

✔ Staff login via Cognito

✔ Admin dashboard is SPA

✔ API Gateway has public + protected routes

✔ No PHP for protected routes

---

### Charlie Cafe Business System Architect 

✅ Customers → NO login → public APIs

🔐 Staff (Admin / Employee / Manager / CEO) → Cognito login → protected APIs

That part is correct.

Now let’s clean the technical conflicts.

### 🚨 PART 1 — ALL CURRENT CONFLICTS IN YOUR PROJECT

Here is your full conflict audit:

### 🔴 1️⃣ Two Different API Gateways

You are using:

#### JS (protected):

```
https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com
```

#### PHP (public):

```
https://q8rq19tfka.execute-api.us-east-1.amazonaws.com
```

#### ⚠️ Conflict:

- Different API IDs

- Possibly different stages

- Possibly different authorizers

- Impossible to debug consistently

#### ✅ FIX:

Use ONE API Gateway.

Structure it like:

```
/public/*
/admin/*
/employee/*
/hr/*
```

Attach Cognito authorizer ONLY to protected routes.

### 🔴 2️⃣ Implicit Flow vs Authorization Code Confusion

#### Your JS uses:

```
response_type=token
window.location.hash
access_token
```

That means: Implicit flow

If in Cognito you enabled:

    - Authorization Code only

    - Or both

You can create mismatch errors.

#### ✅ FIX:

Since your JS is built for Implicit flow,
for now:

✔ Enable Implicit grant

✔ Keep response_type=token

✔ Public client (NO secret)

Do NOT switch to Authorization Code until you refactor JS.

### 🔴 3️⃣ PHP Admin Dashboard Bypasses Cognito

Your admin-orders.php:

    - Calls /dev/orders

    - No Authorization header

    - No JWT

If that route is protected → 401

That is expected.

#### ✅ FIX:

Admin dashboard should NOT be PHP anymore.

Move admin pages to:

CloudFront static HTML + central-auth-api.js

Delete admin PHP dashboard.

Keep PHP only for customer public ordering if needed.

### 🔴 4️⃣ Stage Confusion (/dev vs /status vs /admin)

#### You are mixing:

```
/dev/orders
/status/order-status
/admin/dashboard
```

Without consistency.

#### ✅ FIX:

Use ONE stage:

#### Example:

```
https://api-id.execute-api.us-east-1.amazonaws.com/prod/
```

#### Inside it:

```
/public/orders
/public/order-status
/admin/dashboard
/admin/orders
/employee/orders
```

Do NOT mix stage names in path logic.

### 🔴 5️⃣ central-auth-api.js Contains Too Much

#### Right now it handles:

- Auth

- Role control

- Protected fetch

- Public fetch (indirectly)

- Printing

- Asset paths

- API routing

- HR logic

- Dashboard logic

It’s becoming monolithic.

That will create long-term bugs.

### 🧠 PART 2 — Should You Create Two central-auth-api.js Files?

#### You suggested:

One for public
One for protected
And a third for shared utilities

That is VERY good thinking.

But we must do it cleanly.

### ✅ PROFESSIONAL STRUCTURE RECOMMENDED

#### Do NOT create:

```
central-auth-api-public.js
central-auth-api-protected.js
```

Instead create:

### 🔹 1️⃣ auth.js (ONLY Cognito logic)

#### Contains:

- login()

- logout()

- handleRedirect()

- protectPage()

- getToken()

- isTokenExpired()

- role checking

- auto logout watcher

ONLY authentication logic.

Nothing about API routes.

### 🔹 2️⃣ api.js (ONLY API logic)

#### Contains:

- publicFetch()

- protectedFetch()

- API_BASE

- all endpoints

#### Example:

```
function publicFetch(url, options = {}) {
    return fetch(url, options);
}

function protectedFetch(url, options = {}) {
    const token = Auth.getToken();
    return fetch(url, {
        ...options,
        headers: {
            ...options.headers,
            Authorization: "Bearer " + token
        }
    });
}
```

#### And routes:

```
const API = {
    public: {
        placeOrder: ...
        trackOrder: ...
    },
    admin: {
        dashboard: ...
        markPaid: ...
    }
}
```

### 🔹 3️⃣ utils.js (Shared functions)

#### Contains:

- parseJwt()

- date helpers

- print helpers

- DOM helpers

- formatCurrency()

etc.

### 🔹 4️⃣ config.js (VERY IMPORTANT)

#### Move ALL config into:

```
export const CONFIG = {
   API_BASE: "...",
   REGION: "...",
   CLIENT_ID: "...",
   COGNITO_DOMAIN: "...",
   CLOUDFRONT_BASE: "..."
}
```

Never hardcode config inside logic file again.

### 🏗 FINAL STRUCTURE

```
/js/
   config.js
   auth.js
   api.js
   utils.js
```

### 🌐 Frontend pages:

#### ✅ Public page:

```
orders.php
    → loads api.js only (public section)
```

#### ✅ Protected page:

```
admin-dashboard.html
    → loads config.js
    → loads auth.js
    → loads api.js
    → calls Auth.protectPage()
```

### 🔐 API Gateway Structure

Single API Gateway:

#### Stage:

```
prod
```

#### Routes:

#### Public (NO authorizer):

```
POST /public/orders
POST /public/orders/cash-payment
GET  /public/order-status
```

#### Protected (Cognito authorizer attached):

```
GET  /admin/orders
POST /admin/mark-paid
GET  /admin/dashboard
GET  /employee/orders
POST /employee/order
```

### 🎯 FINAL ANSWER TO YOUR QUESTIONS

#### Q1: List of conflicts?

✔ Two API gateways

✔ Stage confusion

✔ Mixed auth + no-auth endpoints

✔ Admin PHP bypassing Cognito

✔ Monolithic JS file

✔ Grant type mismatch risk

#### Q2: Two central-auth files?

❌ Not recommended.

Instead:

✔ Separate by responsibility (auth.js, api.js, utils.js, config.js)

That is professional architecture.

### 🧠 Important Strategic Advice

Do NOT try to debug everything at once.

#### First:

- Merge to ONE API Gateway

- Separate public vs protected routes

- Remove admin PHP

- Refactor JS into modules

- Test public endpoints

- Then test protected endpoints

Layer by layer.

---

## Charlie Cafe New Architecture Plan

👉 Your architecture plan is now clean, professional, and production-ready.
This is how a real café SaaS system would be structured.

Now let’s go through it carefully and answer the important part:

Do you need to modify Lambda Python backend code?

### ✅ FIRST — Your Architecture Review

Everything you listed is correct. Let me confirm each key decision:

#### ✅ 1. Cognito Callback → login.html

✔ Correct

#### ✅ 2. Cognito Sign-out → logout.html

✔ Correct

Just make sure both URLs are registered in:
Cognito → App Client → Hosted UI → Callback / Sign-out URLs

### ⚠️ 3 & 4. Two API Gateway stages (Public + Private)

#### You wrote:

One Public API Gateway endpoint Stage — Public
One Private API Gateway endpoint Stage — Private Protected

#### 🚨 I would NOT create two stages.

Do this instead:

✅ ONE API Gateway

✅ ONE stage → prod

✅ Different route paths

Like this:

```
prod/public/*
prod/admin/*
prod/employee/*
```

Why?

- Easier deployment

- Easier monitoring

- No duplication

- Cleaner architecture

O- ne base URL in config.js

So remove the idea of separate stages.
Keep one stage.

### ✅ Your Route Structure — PERFECT

```
POST /public/orders
POST /public/orders/cash-payment
GET  /public/order-status
```

No authorizer.

And:

```
GET  /admin/orders
POST /admin/mark-paid
GET  /admin/dashboard
GET  /employee/orders
POST /employee/order
```

Attach Cognito Authorizer ONLY here.

That is exactly correct.

### ✅ Your JS Separation — VERY GOOD

You are now thinking like a senior engineer.

#### Structure:

```
config.js
central-auth-api.js   (auth only)
api.js                (API only)
central-printing.js
utils.js
```

This is correct.

Very clean.

### 🔥 NOW — IMPORTANT QUESTION - Do You Need to Modify Lambda Python Backend?

Answer: 👉 YES — but only small structural changes.

Not major.

Let’s break it down.

### 🧠 What Changes in Backend When Using Cognito?

When you attach a Cognito Authorizer to a route:

#### API Gateway will:

- Validate JWT

- If valid → forward request to Lambda

- Include user info in:

```
event["requestContext"]["authorizer"]["claims"]
```

That means:

Inside your Lambda for protected routes,
you should extract user info like this:

```
def lambda_handler(event, context):

    claims = event["requestContext"]["authorizer"]["claims"]
    
    user_email = claims.get("email")
    user_sub = claims.get("sub")
    user_groups = claims.get("cognito:groups")

    # Now use role logic
```

### ✅ For PUBLIC routes

Nothing changes.

Your existing Lambda logic for:

```
/public/orders
/public/order-status
```

Can remain exactly the same.

### 🔐 For PROTECTED routes

You should:

### 1️⃣ Remove manual token validation (if any)

Do NOT manually decode JWT in Lambda.
API Gateway already validated it.

### 2️⃣ Add Role-Based Logic (VERY IMPORTANT)

#### For example:

```
groups = claims.get("cognito:groups", "")

if "Admin" not in groups:
    return {
        "statusCode": 403,
        "body": "Forbidden"
    }
```

This protects:

/admin/*

/employee/*

Even if someone manipulates frontend.

### 🎯 Example: /admin/orders Lambda

```
def lambda_handler(event, context):

    claims = event["requestContext"]["authorizer"]["claims"]
    groups = claims.get("cognito:groups", "")

    if "Admin" not in groups:
        return {
            "statusCode": 403,
            "body": "Access denied"
        }

    # continue fetching orders
```

This is professional security.

### 🚨 CRITICAL SECURITY NOTE

Never trust:

- Role from frontend

- Role from request body

- Role from query param

Only trust:

```
event["requestContext"]["authorizer"]["claims"]
```

### 🔥 Summary: Backend Modifications Needed?

| Route Type        | Lambda Changes Needed  |
| ----------------- | ---------------------- |
| Public            | ❌ No                   |
| Protected         | ✅ Extract claims       |
| Role-based routes | ✅ Check cognito:groups |


That’s it.

No massive rewrite needed.

### 🧠 Now Let’s Talk About central-auth-api.js Changes

You WILL need to:

- Remove API_BASE from it

- Remove endpoint logic

- Keep only:

    - login

    - logout

    - token handling

    - protectPage

    - role check

And move all fetch logic to api.js.

### 💬 Important Question For You

Are you currently using:

- Cognito Groups? (Admin, Employee, Manager)

OR

- Just one generic login?

Because if you want:

```
/admin/*
/employee/*
```

You MUST use Cognito Groups.

Otherwise role control is impossible.

### 🎯 Final Professional Evaluation

Your architecture plan now:

✔ Clean

✔ Industry standard

✔ Scalable

✔ Secure

✔ Real café deployable

You are no longer building a lab project.
You are building production architecture.

---
## Charlie Cafe Cognito Security Foundation Structure

### 🔐 PART 1 — Final Cognito Groups Structure (Professional Design)

For a café business like Charlie Café, keep it simple but scalable.

### 🎯 Recommended Groups in Amazon Cognito

Create these groups inside your User Pool:

### 1️⃣ Admin

- Full system access

- Can mark paid

- Can see dashboard

- Can manage employees

- Can see financial reports

### 2️⃣ Manager

- Can view dashboard

- Can view orders

- Can mark paid

- Cannot manage system settings

### 3️⃣ Employee

- Can view assigned orders

- Can update order status

- Cannot access dashboard analytics

- Cannot mark paid

### 📌 Why Only 3 Groups?

Because:

- CEO → belongs to Admin

- Owner → belongs to Admin

- Supervisor → belongs to Manager

Do NOT overcomplicate with 10 roles.

Keep it:

```
Admin
Manager
Employee
```

Simple = secure + maintainable.

### 🔧 How To Assign

Cognito → User Pool → Groups → Create groups

Then assign users to groups manually (or later via admin panel).

### 🔐 PART 2 — Final Lambda Protected Route Template

This is the MOST important part of backend security.

Never trust frontend.

### 🏗 How API Gateway Works With Cognito

When route has Cognito Authorizer:

API Gateway validates JWT.

Then Lambda receives:

```
event["requestContext"]["authorizer"]["claims"]
```

### 🔒 Universal Protected Lambda Template

Use this for ALL protected routes.

```
import json

def get_user_claims(event):
    return event.get("requestContext", {}) \
                .get("authorizer", {}) \
                .get("claims", {})


def check_group_access(claims, allowed_groups):
    user_groups = claims.get("cognito:groups", "")

    if not user_groups:
        return False

    # groups may come as comma separated string
    user_groups_list = user_groups.split(",")

    for group in allowed_groups:
        if group in user_groups_list:
            return True

    return False


def lambda_handler(event, context):

    claims = get_user_claims(event)

    # Route example: /admin/orders
    if not check_group_access(claims, ["Admin", "Manager"]):
        return {
            "statusCode": 403,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"message": "Forbidden"})
        }

    # SAFE ZONE BELOW
    user_email = claims.get("email")
    user_id = claims.get("sub")

    # Your business logic here
    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Success",
            "user": user_email
        })
    }
```

### 🎯 Access Rules Example

| Route            | Allowed Groups           |
| ---------------- | ------------------------ |
| /admin/dashboard | Admin only               |
| /admin/orders    | Admin, Manager           |
| /admin/mark-paid | Admin only               |
| /employee/orders | Admin, Manager, Employee |


### 🔥 IMPORTANT

Even though API Gateway validates token,
you MUST check group access inside Lambda.

Because:

Someone could try calling route directly.

JWT may be valid but wrong role.

Security must exist in backend.

### 🧠 PART 3 — Refactor central-auth-api.js Step-by-Step

Now we clean it.

Your current file mixes:

- Auth

- API calls

- Route definitions

- Printing

- UI logic

We will reduce it to AUTH ONLY.

### STEP 1 — Remove API_BASE from central-auth-api.js

Delete:

```
const API_BASE = ...
```

That goes to config.js.

### STEP 2 — Create config.js

```
export const CONFIG = {
    REGION: "us-east-1",
    CLIENT_ID: "xxxxxxxx",
    COGNITO_DOMAIN: "your-domain.auth.us-east-1.amazoncognito.com",
    API_BASE: "https://your-api-id.execute-api.us-east-1.amazonaws.com/prod",
    CLOUDFRONT_BASE: "https://your-cloudfront-url"
};
```

No logic inside.

### STEP 3 — central-auth-api.js (FINAL VERSION STRUCTURE)

This file should ONLY contain:

✔ login()

✔ logout()

✔ handleRedirect()

✔ getToken()

✔ isTokenExpired()

✔ protectPage()

✔ getUserGroups()

✔ hasRole()

### 🏗 Clean Auth Structure

```
import { CONFIG } from "./config.js";

const Auth = {

    login() {
        const loginUrl =
            `https://${CONFIG.COGNITO_DOMAIN}/login?` +
            `response_type=token&` +
            `client_id=${CONFIG.CLIENT_ID}&` +
            `redirect_uri=${CONFIG.CLOUDFRONT_BASE}/login.html`;

        window.location.href = loginUrl;
    },

    logout() {
        localStorage.removeItem("access_token");

        const logoutUrl =
            `https://${CONFIG.COGNITO_DOMAIN}/logout?` +
            `client_id=${CONFIG.CLIENT_ID}&` +
            `logout_uri=${CONFIG.CLOUDFRONT_BASE}/logout.html`;

        window.location.href = logoutUrl;
    },

    handleRedirect() {
        const hash = window.location.hash;

        if (hash.includes("access_token")) {
            const params = new URLSearchParams(hash.substring(1));
            const token = params.get("access_token");
            localStorage.setItem("access_token", token);
            window.location.hash = "";
        }
    },

    getToken() {
        return localStorage.getItem("access_token");
    },

    parseJwt(token) {
        return JSON.parse(atob(token.split('.')[1]));
    },

    getUserGroups() {
        const token = this.getToken();
        if (!token) return [];

        const payload = this.parseJwt(token);
        return payload["cognito:groups"] || [];
    },

    hasRole(role) {
        const groups = this.getUserGroups();
        return groups.includes(role);
    },

    protectPage(allowedRoles = []) {
        const token = this.getToken();

        if (!token) {
            this.login();
            return;
        }

        if (allowedRoles.length > 0) {
            const hasAccess = allowedRoles.some(role =>
                this.hasRole(role)
            );

            if (!hasAccess) {
                alert("Access denied");
                window.location.href = "/unauthorized.html";
            }
        }
    }
};

export default Auth;
```

### STEP 4 — api.js

Now protected fetch:

```
import { CONFIG } from "./config.js";
import Auth from "./central-auth-api.js";

export function protectedFetch(endpoint, options = {}) {
    const token = Auth.getToken();

    return fetch(`${CONFIG.API_BASE}${endpoint}`, {
        ...options,
        headers: {
            ...options.headers,
            Authorization: `Bearer ${token}`,
            "Content-Type": "application/json"
        }
    });
}

export function publicFetch(endpoint, options = {}) {
    return fetch(`${CONFIG.API_BASE}${endpoint}`, {
        ...options,
        headers: {
            ...options.headers,
            "Content-Type": "application/json"
        }
    });
}
```

### 🔥 On Protected Page Example

```
import Auth from "./central-auth-api.js";

Auth.protectPage(["Admin", "Manager"]);
```

### 🎯 FINAL RESULT

After this:

✔ One API Gateway

✔ One stage

✔ Public routes open

✔ Protected routes secured

✔ Lambda checks groups

✔ Clean frontend separation

✔ Professional architecture

You are now building:

Production-ready secure café SaaS system..

## Lambda security pattern

👉 You do NOT need a new Lambda function just for role checking.
You use your existing Lambda functions.

The “Universal Protected Lambda Template” is not a new Lambda.
It is a security pattern you add inside your existing Lambdas.

### 🔐 Why This Exists (Very Important)

When you attach a Cognito Authorizer in Amazon API Gateway:

✔ API Gateway verifies the JWT signature

✔ API Gateway checks token is valid

✔ API Gateway checks token not expired

But ❗

API Gateway does NOT check:

- Is user Admin?

- Is user Employee?

- Is user allowed for THIS route?

It only validates identity — not authorization logic.

That’s why Lambda must check roles.

### 🏗 You Have Two Architecture Choices

Let’s compare them clearly.

### OPTION A — One Lambda Per Route (Recommended for You)

Example:

```
AdminDashboardLambda
AdminOrdersLambda
EmployeeOrdersLambda
OrderStatusLambda
```

Each Lambda:

Is mapped to one route

Has its own business logic

Includes role check at top

Example:

```
def lambda_handler(event, context):

    claims = get_user_claims(event)

    # This lambda is ONLY for admin dashboard
    if not check_group_access(claims, ["Admin"]):
        return forbidden()

    # Business logic below
```

#### ✅ Benefits

✔ Clean separation

✔ Easier debugging

✔ Safer permissions

✔ Clear responsibility

✔ Scales better

#### ❌ Downside

More Lambdas (but that is normal in production systems)

### OPTION B — One Big Lambda Handling All Routes (NOT Recommended For You)

Example:

```
MainLambda handles:
/admin/dashboard
/admin/orders
/employee/orders
```

Inside:

```
path = event["resource"]

if path == "/admin/dashboard":
    check_group_access(claims, ["Admin"])
elif path == "/employee/orders":
    check_group_access(claims, ["Employee", "Admin"])
```

#### ❌ Problems

Harder to maintain

Harder to debug

Harder to scale

Becomes messy quickly

### 🎯 So What Should YOU Do?

Since you already have separate Lambdas per route:

👉 KEEP THEM

👉 Do NOT create a new Lambda

👉 Just add role-check logic at the top of each existing protected Lambda

### 🔥 Why You Cannot Rely Only on API Gateway

Even if route has Cognito authorizer:

If you do NOT check group inside Lambda:

Then:

- Any authenticated user (even Employee)

- Can call /admin/mark-paid

- If JWT is valid → API Gateway lets it pass

- Lambda runs business logic

- Employee can mark paid ❌❌❌

That is a serious security hole.

### 🧠 Important Distinction

| Layer                  | What It Does                 |
| ---------------------- | ---------------------------- |
| Cognito                | Identity Provider            |
| API Gateway Authorizer | JWT validation               |
| Lambda                 | Business authorization logic |

Think of it like:

Cognito → Who are you?
API Gateway → Is your token real?
Lambda → Are you allowed to do this action?

### 🔐 What You Actually Need To Do

Inside each PROTECTED Lambda:

#### 1️⃣ Add these helper functions (can reuse everywhere)

```
def get_user_claims(event):
    return event.get("requestContext", {}) \
                .get("authorizer", {}) \
                .get("claims", {})

def check_group_access(claims, allowed_groups):
    user_groups = claims.get("cognito:groups", "")

    if not user_groups:
        return False

    user_groups_list = user_groups.split(",")

    return any(group in user_groups_list for group in allowed_groups)

def forbidden():
    return {
        "statusCode": 403,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"message": "Forbidden"})
    }
```

#### 2️⃣ At top of Lambda:

```
claims = get_user_claims(event)

if not check_group_access(claims, ["Admin"]):
    return forbidden()
```

Then continue business logic.

### 🚀 Real Professional Benefit

If one day:

- You build mobile app

- You build desktop app

- Someone bypasses frontend

- Someone calls API directly

Your backend remains secure.

That is how real SaaS systems are built.

### 🧩 Do You Need To Modify Public Lambdas?

No.

For:

```
POST /public/orders
GET  /public/order-status
```

Do NOT attach Cognito authorizer.

Do NOT check groups.

Keep them public.

### 🧠 Final Clear Answer

Should I create new Lambda?

❌ No.

Should I modify existing protected Lambdas?

✅ Yes — add role checking at top.

Why?

Because API Gateway only validates token, not authorization logic.

## security pattern of each existing Lambda

> **add the security pattern at the top of each existing Lambda**

### 🔐 What You Are Actually Doing

For every route like:

```
/admin/dashboard
/admin/orders
/admin/mark-paid
/employee/orders
```

You already have:

- API Gateway method

- Cognito Authorizer attached

- Lambda integration

Now you only add this at the top of those Lambdas:

### ✅ Step 1 — Add Security Helpers (inside each protected Lambda)

```
import json

def get_user_claims(event):
    return event.get("requestContext", {}) \
                .get("authorizer", {}) \
                .get("claims", {})

def check_group_access(claims, allowed_groups):
    user_groups = claims.get("cognito:groups", "")

    if not user_groups:
        return False

    user_groups_list = user_groups.split(",")

    return any(group in user_groups_list for group in allowed_groups)

def forbidden():
    return {
        "statusCode": 403,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"message": "Forbidden"})
    }
```

### ✅ Step 2 — Add Role Check at Top of lambda_handler

Example: AdminDashboardLambda

```
def lambda_handler(event, context):

    claims = get_user_claims(event)

    if not check_group_access(claims, ["Admin"]):
        return forbidden()

    # SAFE ZONE — Admin only
    return {
        "statusCode": 200,
        "body": json.dumps({"message": "Admin dashboard data"})
    }
```

Example: EmployeeOrdersLambda

```
if not check_group_access(claims, ["Admin", "Manager", "Employee"]):
    return forbidden()
```

### 🧠 Why This Is Correct

Because now security works in 3 layers:

1️⃣ Cognito → verifies identity

2️⃣ API Gateway → validates JWT

3️⃣ Lambda → verifies authorization (role-based access)

That is professional backend security architecture.

### 🚫 What You Should NOT Do

❌ Do not rely only on frontend role check

❌ Do not rely only on API Gateway authorizer

❌ Do not create a new Lambda just for checking roles

### 🔥 Final Confirmation

Yes — you just:

✔ Keep your existing Lambdas
✔ Add security pattern at top of each protected Lambda
✔ Leave public Lambdas untouched

---
## Old Wrong Configurations 

# SECTION 1️⃣ Secure Admin Order Dashboard

## 🔐 PHASE 1️⃣ — Cognito Authentication infrastructure 
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

**✅ PHASE 1️⃣ STATUS**

> **🟢 PHASE 1️⃣ COMPLETE & VERIFIED**
---
## 🔐 PHASE 2️⃣ — Admin Authentication Using Amazon Cognito (Hosted UI + JWT Tokens)
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
## ☕ AWS CAFE —  Old Cognito Configurations Test & Verifications

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

### 3️⃣ CloudFront ALB & Central-Auth-Api Troubleshooting

[CloudFront ALB & Central-Auth-Api Troubleshooting](./CloudFront_ALB_Central-Auth-Api.md)

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

**✅ PHASE 3️⃣ STATUS**

> **🟢 PHASE 3️⃣ COMPLETE & VERIFIED**
---

## 🔐 PHASE 4️⃣ — Backend - Cognito Role Base Access and Permission 

### 1️⃣ Test - Verify files (RBAC)

```
sudo tree cafe-rbac-layer
```

#### Expected output:

```
cafe-rbac-layer
└── python
    ├── rbac.py
    └── permissions.json
```

**If this does NOT match → STOP and fix**

### 2️⃣ Test - Verify zip contents:

```
unzip -l cafe-rbac-layer.zip
```

You MUST see:

```
python/rbac.py
python/permissions.json
```

### 3️⃣ Test - Verify Layer (RBAC)
> **Verify Layer is attached**

```
aws lambda get-function-configuration \
  --function-name CafeOrderStatusLambda
```

Look for:

```
"Layers": [
  {
    "Arn": "arn:aws:lambda:us-east-1:XXXX:layer:cafe-rbac-layer:1"
  }
]
```

#### 🧠 COMMON MISTAKES (AVOID THESE)

❌ Zipping rbac.py directly

❌ Missing python/ folder

❌ Wrong runtime version

❌ Forgetting to attach layer to Lambda

❌ Using uppercase role names in permissions.json

#### ✅ FINAL CHECKLIST

✔ Folder structure correct

✔ ZIP contains python/rbac.py

✔ Layer published successfully

✔ Layer attached to Lambda

✔ Lambda imports from rbac import authorize

### 3️⃣ Verify CLI SCRIPT TO UPDATE ALL LAMBDAS (spot check)

```
aws lambda get-function-configuration \
  --function-name OrderStatusLambda
```

#### Look for:

```
"Layers": [
  {
    "Arn": "arn:aws:lambda:us-east-1:XXXX:layer:cafe-rbac-layer:2"
  }
]
```

### 3️⃣ VIEW AUDIT LOGS Test

- Go to: CloudWatch → Log groups → /aws/lambda/<LambdaName>

#### You’ll see logs like:

```
{
  "timestamp": "2026-02-04T18:32:11",
  "username": "charlie.admin",
  "groups": ["admin"],
  "path": "/admin/dashboard",
  "decision": "ALLOW"
}
```

**This is enterprise-grade RBAC auditing.**

#### ✅ FINAL ARCHITECTURE

```
Cognito (Groups)
     ↓
API Gateway (Authorizer)
     ↓
Lambda
     ↓
RBAC Layer
     ↓
Audit Logs (CloudWatch)
```

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


**✅ PHASE 4️⃣ STATUS**

> **🟢 PHASE 4️⃣ COMPLETE & VERIFIED**
---
## 🔐 PHASE 5️⃣ — BACKEND DATE FILTER (LAMBDA)

### 1️⃣ API Gateway – Enable Cognito Authorizer

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


**✅ PHASE 5️⃣ STATUS**

> **🟢 PHASE 5️⃣ COMPLETE & VERIFIED**
---
## 🔐 PHASE 6️⃣ — FINAL SECURITY FLOW (MENTAL MODEL)

### 🧪 1️⃣ — TEST ❌ NO JWT (EXPECTED FAIL)

#### CURL / Postman / Browser test

#### Request:

```
GET https://API_ID.execute-api.REGION.amazonaws.com/prod/analytics
```

#### EXPECTED RESULT:

```
401 Unauthorized
```

✔ Correct → continue

❌ If allowed → authorizer NOT attached

### 🧪 2️⃣ — TEST ❌ INVALID JWT

#### Add header:

```
Authorization: invalidtoken123
```

#### EXPECTED:

```
401 Unauthorized
```

✔ Correct → continue

### 🧪 3️⃣ — TEST ✅ ADMIN JWT (EXPECTED SUCCESS)

#### Add header:

```
Authorization: Bearer YOUR_ID_TOKEN
```

#### EXPECTED:

```
200 OK
```

✔ Lambda executes
✔ Data returned

### 🧪 4️⃣ — TEST STAFF USER (SECURITY VALIDATION)

Login as Staff user, get ID token again.

#### Call API with:

```
Authorization: Bearer STAFF_TOKEN
```

#### RESULT DEPENDS ON LAMBDA:

- Analytics Lambda → ❌ 403

- Orders Lambda → ✅ 200

**✔ This proves end-to-end security**

### 🧠 FINAL SECURITY FLOW (CONFIRMED)

```
No token        → API Gateway blocks (401)
Invalid token   → API Gateway blocks (401)
Valid token     → Claims injected
Admin group     → Lambda allows
Staff group     → Lambda restricted
```

### 🧪 PHASE 6️⃣ TEST CHECKLIST (ALL MUST PASS)

✔ Token issued

✔ Groups inside JWT

✔ Authorizer attached

✔ No token blocked

✔ Invalid token blocked

✔ Admin allowed

✔ Staff restricted

### ✅ PHASE 6️⃣ STATUS

🟢 PHASE 6️⃣ COMPLETE

🟢 PHASE 6️⃣ FULLY TESTED

🟢 SAFE TO MOVE NEXT

**✅ PHASE 6️⃣ STATUS**

> **🟢 PHASE 6️⃣ COMPLETE & VERIFIED**
# SECTION 1️⃣  COMPLETE ✅
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

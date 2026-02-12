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

---




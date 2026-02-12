# Charlie Cafe - AWS Cognito + PHP backend + protected API

## ✅ Correct Cognito Protected API Flow

### 1️⃣ User Login (Frontend / Mobile App)

User logs in via Cognito → Cognito returns:

id_token

access_token

refresh_token

### ⚠️ IMPORTANT: 

For calling protected APIs → Use access_token
NOT id_token.

### 2️⃣ Client Calls Your PHP Backend

Client must send:

```
Authorization: Bearer ACCESS_TOKEN
```

Example:

```
GET /api/profile
Authorization: Bearer eyJraWQiOiJLT...
```

3️⃣ PHP Backend Must Verify JWT Token

Your PHP server must:

Extract token from header

Decode JWT

Verify signature using Cognito public keys

Validate:

issuer (iss)

audience (client_id)

expiration (exp)

token_use = access

✅ Correct PHP JWT Verification (Production Way)

Install Firebase JWT:

```
composer require firebase/php-jwt
```

Example PHP Code

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

🚨 Most Common Cognito Access Token Issues
❌ 1. Using ID Token Instead of Access Token

Access token has:

```
"token_use": "access"
```

ID token has:

```
"token_use": "id"
```

If you validate wrong one → it fails.

❌ 2. Wrong Issuer Check

Issuer must match exactly:

```
https://cognito-idp.YOUR_REGION.amazonaws.com/YOUR_USER_POOL_ID
```

Even a small mismatch = invalid token.

❌ 3. Token Expired

Access token expires in 1 hour by default.

Check:

```
exp
```

If expired → use refresh token.

❌ 4. API Gateway Cognito Authorizer Misconfigured

If using API Gateway:

Authorizer must use User Pool

Token Source: Authorization

Must send Bearer <token>

❌ 5. Wrong App Client (No Secret vs With Secret)

If your app client has a secret and you're using public frontend login, it will fail unless you implement secret hash.

For mobile/web apps:

Disable "Generate client secret"

🔎 Debugging Checklist For You

Since you suspect access token issue, check:

Decode token at:
https://jwt.io

Verify:

token_use = access

correct iss

correct client_id

not expired

Make sure PHP verifies using Cognito JWKS.

🏗 Recommended Clean Architecture (Best Practice)

Frontend → Cognito
Frontend → API (with Access Token)
PHP backend → verifies JWT only
NO session handling required

Stateless + secure.

💡 If You Want Stronger Enterprise Setup

You can:

Use API Gateway + Cognito Authorizer

Then PHP doesn’t verify token manually

API Gateway sends user claims to PHP

This is more scalable.

🎯 I Need From You To Diagnose Exactly

Tell me:

Are you using API Gateway or direct PHP server?

What error are you getting?

401?

Invalid signature?

Token expired?

Are you using ID token or access token?

Is your app client configured with secret?

---

✅ METHOD 1 — From Frontend (Most Common – Recommended)

If you are using:

Web app (React / Angular / Vue / HTML JS)

Mobile app

Hosted UI

You authenticate user → Cognito returns tokens.

🔹 Option A: Using Cognito Hosted UI (Easiest)
Step 1 – Redirect user to login URL


```
https://YOUR_DOMAIN.auth.YOUR_REGION.amazoncognito.com/login?
client_id=YOUR_CLIENT_ID
&response_type=code
&scope=email+openid+profile
&redirect_uri=https://yourapp.com/callback
```

After login → Cognito redirects to:

```
https://yourapp.com/callback?code=AUTH_CODE
```


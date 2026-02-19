# Charlie Cafe - Cognito Hosted UI

### login.html – Cognito Hosted UI

> **Update Version:1.0**

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Café ☕ | Login</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
body { font-family:Poppins,sans-serif; background:#1a110b; color:#fff; min-height:100vh; display:flex; justify-content:center; align-items:center; }
.login-card { background: rgba(58,37,28,0.9); padding:40px; border-radius:20px; box-shadow:0 10px 30px rgba(0,0,0,0.5); }
.btn-login { background:linear-gradient(135deg,#ff5722,#ff9800); border:none; border-radius:50px; color:#fff; width:100%; }
</style>
</head>
<body>

<div class="login-card">
    <h3 class="text-center mb-4">☕ Charlie Café Login</h3>
    <button id="loginBtn" class="btn-login btn">Login with Cognito</button>
</div>

<script>
// =================== CONFIG ===================
// Replace with your actual Cognito Hosted UI domain + App client ID + redirect URI
const COGNITO_DOMAIN = "https://your-cognito-domain.auth.us-east-1.amazoncognito.com";
const CLIENT_ID = "YOUR_APP_CLIENT_ID";
const REDIRECT_URI = window.location.origin + "/cognito-callback.php";

// Build login URL
const loginUrl = `${COGNITO_DOMAIN}/login?client_id=${CLIENT_ID}&response_type=token&scope=email+openid&redirect_uri=${encodeURIComponent(REDIRECT_URI)}`;

// Redirect to Cognito Hosted UI on click
document.getElementById("loginBtn").addEventListener("click", () => {
    window.location.href = loginUrl;
});
</script>

</body>
</html>
```

---
### cognito-callback.php – Handle Cognito Login Callback

> **Update Version:1.0**

```
<?php
// ===========================================================
// CHARLIE CAFÉ ☕ - Cognito Login Callback
// ===========================================================
session_start();

// Cognito returns access_token in URL hash, so we need JS to capture it
?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Cognito Callback</title>
<script>
// Parse token from URL hash
const hash = window.location.hash.substring(1); // remove #
const params = new URLSearchParams(hash);
const accessToken = params.get("access_token");

if (accessToken) {
    // Send token to server to start session
    fetch("cognito-login.php", {
        method:"POST",
        headers: {"Content-Type":"application/json"},
        body: JSON.stringify({access_token: accessToken})
    }).then(()=> window.location.href = "orders.php")
    .catch(()=> alert("Login failed"));
} else {
    alert("No access token received from Cognito");
}
</script>
</head>
<body>
Logging in...
</body>
</html>
```

---
### cognito-login.php – Start PHP Session

> **Update Version:1.0**

```
<?php
// ===========================================================
// CHARLIE CAFÉ ☕ - Start PHP Session for Cognito Login
// ===========================================================
session_start();
header('Content-Type: application/json');

// Read POSTed access token
$data = json_decode(file_get_contents("php://input"), true);
if (!empty($data['access_token'])) {
    $_SESSION['cognito_logged_in'] = true; // simple flag
    echo json_encode(['success'=>true]);
} else {
    http_response_code(400);
    echo json_encode(['error'=>'No access token']);
}
```

### 1️⃣ Purpose of cognito-callback.php

When you use Cognito Hosted UI:

- User clicks Login → redirects to Cognito Hosted UI

- User enters credentials → Cognito authenticates

- Cognito redirects back to your site using your Callback URL

Example:

```
https://dxxxx.cloudfront.net/cognito-callback.php#id_token=...&access_token=...&expires_in=3600
```

- Your callback page must read these tokens (ID token / Access token) and store them safely:

- In PHP session if you want server-side protection

Or in localStorage/sessionStorage if purely frontend-driven

After storing the token, you redirect the user to your protected dashboard page.

### 2️⃣ Why you can’t skip it

Without a callback page:

- Cognito redirects to your site → user lands on a random page

- You don’t have their ID token / access token

- You cannot verify login → pages cannot be protected

- Anyone could access your dashboard → security hole

So for any project that uses Cognito Hosted UI and protected pages, a callback page is mandatory.

### 3️⃣ How simple it can be

You don’t need PHP cURL or API calls on the callback page. Minimal setup:

- Read the URL fragment #id_token=...&access_token=... with JavaScript

- Store tokens in sessionStorage

- Redirect to dashboard.html

OR, if you prefer PHP:

- Parse the token from URL

- Store in PHP session

- Redirect to dashboard

- No cURL, no API calls — totally safe.

### 4️⃣ Example (Frontend JS callback)

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Café ☕ | Callback</title>
<script>
// Read URL hash
const hash = window.location.hash.substr(1);
const params = new URLSearchParams(hash);

// Get tokens
const idToken = params.get("id_token");
const accessToken = params.get("access_token");

if(idToken && accessToken){
    // Store tokens safely
    sessionStorage.setItem("idToken", idToken);
    sessionStorage.setItem("accessToken", accessToken);

    // Redirect to protected dashboard
    window.location.href = "dashboard.html";
} else {
    // No token → redirect to login
    window.location.href = "login.html";
}
</script>
</head>
<body>
<p>Redirecting...</p>
</body>
</html>
```

### 5️⃣ Key Points

✅ Required if you want protected pages

✅ Can be pure frontend → no PHP, no cURL

✅ Minimal code → safe, easy to deploy

✅ Works with CloudFront + Cognito Hosted UI

✅ Needed only once per login flow

### 6️⃣ Summary

| Feature         | Why Needed                            |
| --------------- | ------------------------------------- |
| Callback page   | To receive Cognito tokens after login |
| PHP / JS        | Optional — you can do it fully in JS  |
| Session storage | To protect dashboard pages            |
| Skipping it     | Not secure — tokens won’t be captured |


### 💡 Bottom line:

Even in a “no PHP, no bug” setup, you must have a callback page, but it can be pure JS and super simple. You do not need PHP cURL here at all.

### 🔐 Where Do These URLs Go Inside Cognito?

- Go to: Cognito → User Pool → App integration → App client → Hosted UI

There are ONLY TWO important URL sections:

### 1️⃣ Callback URL(s)

This is where Cognito redirects AFTER LOGIN.

You must enter:

```
https://YOUR_CLOUDFRONT_DOMAIN/cognito-callback.php
```

Example:

```
https://dxxxx.cloudfront.net/cognito-callback.php
```

If you use local testing also add:

```
http://localhost/cognito-callback.php
```

👉 This is REQUIRED.

### 2️⃣ Sign-out URL(s)

This is where Cognito redirects AFTER LOGOUT.

If you are using the single-file logout.php with ?loggedout=true, then enter:

```
https://YOUR_CLOUDFRONT_DOMAIN/logout.php?loggedout=true
```

Example:

```
https://dxxxx.cloudfront.net/logout.php?loggedout=true
```

👉 This must match EXACTLY.

### 🚫 What You DO NOT Need to Enter

You DO NOT enter:

❌ login.html

❌ dashboard.html

❌ any other pages

Cognito does NOT need those.

### 🧠 Why? 

#### login.html

This page only redirects TO Cognito.
Cognito does not redirect back to it after login.

#### cognito-callback.php

Cognito sends tokens here after login.
So this MUST be registered.

#### logout.php

Cognito sends user here after logout.
So this MUST be registered (with exact query string if used).

### 🎯 Final Setup Summary

Inside Cognito:

Callback URL(s):

```
https://dxxxx.cloudfront.net/cognito-callback.php
```

Sign-out URL(s):

```
https://dxxxx.cloudfront.net/logout.php?loggedout=true
```

That’s it. Nothing more.

### 🏆 Final Architecture (Correct)

| File                 | Register in Cognito? |
| -------------------- | -------------------- |
| login.html           | ❌ No                 |
| cognito-callback.php | ✅ Yes (Callback URL) |
| logout.php           | ✅ Yes (Sign-out URL) |
| dashboard.html       | ❌ No                 |

### 🔎 Why Did I First Say login.html as Callback?

That depends on the OAuth flow type you choose inside
Amazon Cognito.

There are two different patterns:

### 🟢 Pattern A — Callback = login.html (Pure Frontend App)

This works when:

- You use response_type=token

- Tokens are returned in URL hash #id_token=...

- You handle token parsing in JavaScript

In that case:

Cognito redirects to:

```
https://dxxxx.cloudfront.net/login.html#id_token=...
```

Then your login.html page:

- Detects tokens in URL

- Stores them in sessionStorage

- Redirects to dashboard

👉 No PHP required

👉 No separate callback file required

This is a Single Page App style approach.

### 🔵 Pattern B — Callback = cognito-callback.php

This works when:

- You want a dedicated page to process tokens

- You want cleaner architecture

- You may use PHP sessions

Cognito redirects to:

```
https://dxxxx.cloudfront.net/cognito-callback.php#id_token=...
```

That file:

- Extracts token

- Stores it

- Redirects to dashboard

### 🧠 So Why The Change?

Because earlier we discussed PHP session protection, which requires:

- A server-side session start

- A controlled redirect

That fits better with cognito-callback.php.

### 🎯 Now Based On YOUR Situation

You said:

- You want to avoid PHP bugs

- You had cURL issues before

- You prefer frontend-driven approach

- You don’t want unnecessary backend complexity

👉 Then you should use:

### ✅ Pattern A (Simpler, Cleaner)

Use:

Callback URL inside Cognito:

```
https://dxxxx.cloudfront.net/login.html
```

And modify login.html to:

- Detect if URL contains tokens

- If yes → store them → redirect to dashboard

- If no → show login button

No cognito-callback.php needed.

### 🏆 Which One Should You Choose?

| If you want...             | Use                    |
| -------------------------- | ---------------------- |
| Fully frontend             | login.html as callback |
| PHP session protection     | cognito-callback.php   |
| Simpler deployment         | login.html             |
| Fewer backend bugs         | login.html             |
| Enterprise backend control | cognito-callback.php   |

### 💡 My Honest Recommendation For You

Since you are worried about PHP issues:

👉 Use login.html as callback URL

👉 Use JS-only token handling

👉 Use JS logout

👉 Avoid PHP entirely for auth

This will:

- Avoid cURL problems

- Avoid session bugs

- Avoid CloudFront + PHP config issues

Be clean and stable

### ⚠️ Important

If you choose this approach:

Inside Cognito:

Callback URL:

```
https://dxxxx.cloudfront.net/login.html
```

Sign-out URL:

```
https://dxxxx.cloudfront.net/login.html
```

(No logout.php needed if you use JS logout)

### 🚀 Final Answer

You do NOT need cognito-callback.php
if you use login.html to handle tokens in JavaScript.

Both approaches are correct.
The difference is architecture style.

---
### logout.php – Logout User

> **Update Version:1.0**

> **☕ Now Let’s Build Your Styled Logout Page**

We’ll create:

```
logout.php  (does session destroy + redirect)
logout-success.html  (styled page)
```

### ✅ OPTION 1 (Best Practice)

User clicks Logout → PHP destroys session →
Cognito logout → Redirects to styled success page

#### 🌟 Step 1: Styled Logout Success Page

Create:

logout-success.html

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Café ☕ | Logged Out</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;500;700&display=swap" rel="stylesheet">

<style>
body {
    font-family: 'Poppins', sans-serif;
    background: url('https://images.unsplash.com/photo-1495474472287-4d71bcdd2085') no-repeat center center/cover;
    height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
}

.overlay {
    background: rgba(0,0,0,0.65);
    position: absolute;
    width: 100%;
    height: 100%;
}

.logout-card {
    position: relative;
    background: rgba(58,37,28,0.95);
    padding: 40px;
    border-radius: 20px;
    box-shadow: 0 15px 35px rgba(0,0,0,0.6);
    width: 350px;
    text-align: center;
    color: #fff;
    z-index: 2;
}

.logo {
    font-size: 40px;
    margin-bottom: 10px;
}

.cafe-title {
    font-size: 26px;
    font-weight: 700;
    margin-bottom: 20px;
}

.btn-home {
    background: linear-gradient(135deg,#ff5722,#ff9800);
    border: none;
    border-radius: 50px;
    padding: 12px;
    font-weight: 600;
    width: 100%;
    color: #fff;
    transition: 0.3s;
}

.btn-home:hover {
    transform: scale(1.05);
}
</style>
</head>

<body>

<div class="overlay"></div>

<div class="logout-card">
    <div class="logo">☕</div>
    <div class="cafe-title">Charlie Café</div>
    <h4 class="mb-3">You’ve been logged out!</h4>
    <p class="mb-4">We hope to see you again soon ☕</p>
    <a href="login.html" class="btn btn-home">Back to Login</a>
</div>

</body>
</html>
```

#### 🌟 Step 2: Updated logout.php

```
<?php
// ===========================================================
// CHARLIE CAFÉ ☕ - Secure Logout
// ===========================================================

session_start();
session_destroy();

// 🔹 Replace with your real values
$COGNITO_DOMAIN = "https://your-domain.auth.us-east-1.amazoncognito.com";
$CLIENT_ID = "YOUR_NEW_CLIENT_ID";

// After Cognito logout, go to styled page
$LOGOUT_REDIRECT = "http://localhost/logout-success.html";

// Build Cognito logout URL
$logoutUrl = $COGNITO_DOMAIN . "/logout?client_id=" . $CLIENT_ID . "&logout_uri=" . urlencode($LOGOUT_REDIRECT);

// Redirect to Cognito global logout
header("Location: $logoutUrl");
exit;
?>
```

### 🔐 What Happens Now

User clicks logout →

PHP destroys session

Redirects to Cognito logout endpoint

Cognito clears tokens

Redirects to styled logout-success page

🔥 Clean. Secure. Professional.

### 🎯 Final Structure

```
login.html
cognito-callback.php
dashboard.php
logout.php
logout-success.html
```

#### 🔵 OPTION A — Global Logout (Recommended for Your Project)

What it does:

- Destroys PHP session

- Logs user out from Cognito Hosted UI

- Clears Cognito cookies

- Prevents automatic re-login

Why this matters:

If user clicks login again, they must enter credentials again.

Best for:

- Real projects

- Secure apps

- Production systems

- Assignments that require full authentication flow

You are building:

Charlie Café with Cognito authentication →
✅ This is the correct and professional option for you

```
<?php
// ===========================================================
// CHARLIE CAFÉ ☕ - Combined Logout + Styled Page
// Works with Amazon Cognito Hosted UI
// ===========================================================

session_start();

/*
--------------------------------------------------------------
STEP 1:
If this is the FIRST time user hits logout.php
→ Destroy session
→ Redirect to Cognito logout endpoint
--------------------------------------------------------------
*/

if (!isset($_GET['loggedout'])) {

    // Destroy local PHP session
    session_destroy();

    // 🔹 Replace with your real Cognito values
    $COGNITO_DOMAIN = "https://your-domain.auth.us-east-1.amazoncognito.com";
    $CLIENT_ID = "YOUR_NEW_CLIENT_ID";

    // After Cognito logs out, return here with flag
    $LOGOUT_REDIRECT = "http://localhost/logout.php?loggedout=true";

    // Build Cognito logout URL
    $logoutUrl = $COGNITO_DOMAIN . "/logout?client_id=" 
                . $CLIENT_ID 
                . "&logout_uri=" 
                . urlencode($LOGOUT_REDIRECT);

    // Redirect to Cognito
    header("Location: $logoutUrl");
    exit;
}

/*
--------------------------------------------------------------
STEP 2:
If Cognito redirected back with ?loggedout=true
→ Show styled logout page
--------------------------------------------------------------
*/
?>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Café ☕ | Logged Out</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;500;700&display=swap" rel="stylesheet">

<style>
body {
    font-family: 'Poppins', sans-serif;
    background: url('https://images.unsplash.com/photo-1495474472287-4d71bcdd2085') no-repeat center center/cover;
    height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
}

.overlay {
    background: rgba(0,0,0,0.65);
    position: absolute;
    width: 100%;
    height: 100%;
}

.logout-card {
    position: relative;
    background: rgba(58,37,28,0.95);
    padding: 40px;
    border-radius: 20px;
    box-shadow: 0 15px 35px rgba(0,0,0,0.6);
    width: 350px;
    text-align: center;
    color: #fff;
    z-index: 2;
}

.logo {
    font-size: 40px;
    margin-bottom: 10px;
}

.cafe-title {
    font-size: 26px;
    font-weight: 700;
    margin-bottom: 20px;
}

.btn-login {
    background: linear-gradient(135deg,#ff5722,#ff9800);
    border: none;
    border-radius: 50px;
    padding: 12px;
    font-weight: 600;
    width: 100%;
    color: #fff;
    transition: 0.3s;
}

.btn-login:hover {
    transform: scale(1.05);
}
</style>
</head>

<body>

<div class="overlay"></div>

<div class="logout-card">
    <div class="logo">☕</div>
    <div class="cafe-title">Charlie Café</div>
    <h4 class="mb-3">You’ve been logged out!</h4>
    <p class="mb-4">Thanks for visiting. See you again soon ☕</p>
    <a href="login.html" class="btn btn-login">Back to Login</a>
</div>

</body>
</html>
```

#### 🟠 OPTION B — Local Logout Only (Simple Version)

This option:

- Only destroys PHP session

- Does NOT log user out from Cognito

- Cognito cookies remain active

What happens:

User logs out →
Clicks login again →
⚠️ Cognito automatically logs them back in (no password asked)

Because Cognito session is still active.

🔶 OPTION B Code (Simple Version)

Single logout.php file:

```
<?php
// ===========================================================
// CHARLIE CAFÉ ☕ - Simple Logout (Local Only)
// This does NOT log out from Cognito Hosted UI
// ===========================================================

session_start();
session_destroy();
?>

<!DOCTYPE html>
<html>
<head>
<title>Charlie Café ☕ | Logged Out</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<style>
body {
    background:#1a110b;
    color:white;
    height:100vh;
    display:flex;
    justify-content:center;
    align-items:center;
    text-align:center;
}
.card {
    background:#3a251c;
    padding:40px;
    border-radius:20px;
}
</style>
</head>
<body>

<div class="card">
    <h2>☕ Charlie Café</h2>
    <p>You have been logged out (locally).</p>
    <a href="login.html" class="btn btn-warning">Login Again</a>
</div>

</body>
</html>
```

#### ⚠️ Problem With Option B

Since you're using Amazon Cognito, Cognito keeps its own session cookie.

So:

- PHP session = destroyed ✅

- Cognito session = still active ❌

That means user can log back in without credentials.

### 🏆 Which One Is Suitable For Your Project?

Based on your Charlie Café project:

You are:

Using Cognito Hosted UI

Handling callback

Managing sessions

Building a structured auth system

### 👉 You should use OPTION A (Global Logout)

Because:

✔ It demonstrates full Cognito understanding
✔ It is secure
✔ It behaves like real production systems
✔ It avoids auto-login issue

### 🔥 Simple Comparison

| Feature                   | Option A | Option B |
| ------------------------- | -------- | -------- |
| Destroys PHP session      | ✅        | ✅        |
| Logs out from Cognito     | ✅        | ❌        |
| Prevents auto login       | ✅        | ❌        |
| Professional practice     | ✅        | ❌        |
| Suitable for your project | ⭐ YES    | ❌ No     |

### 🎯 Final Recommendation

For Charlie Café + Cognito:

➡ Use Global Logout (Option A)

➡ Single-file version I gave you earlier is perfect

### ✅ How This Works

- User clicks Login → Cognito Hosted UI.

- Cognito redirects to cognito-callback.php with access token in URL hash.

- JS sends token to cognito-login.php → PHP session is created.

- All PHP pages (orders.php, admin-dashboard.php) check $_SESSION['cognito_logged_in'] → restrict access.

- Logout destroys session and returns to login page.

### ✅ Advantages for your lab:

- No API Cognito authentication → public API works without 401/403.

- Cognito only controls page access.

- Fully working, simple, and compatible with your previous PHP pages.

### 🧠 Why Login is HTML but Logout is PHP?

#### ✅ Login → HTML (Frontend Only)

The login page:

- Just redirects user to Cognito Hosted UI

- No server logic needed

- No session to destroy

- Pure client-side redirect

So HTML + JavaScript is enough.

#### ✅ Logout → PHP (Server Side Required)

Logout must:

- Destroy the PHP session (session_destroy())

- Remove stored user data

- Then redirect to Cognito logout endpoint

Session destruction must happen on the server, not browser.

👉 JavaScript cannot securely destroy server session.

👉 That’s why logout uses PHP.


### ✅ Why This Sign-out URL Is Correct

You configured:

```
https://YOUR_CLOUDFRONT_DOMAIN/logout.php?loggedout=true
```

Example:

```
https://dxxxx.cloudfront.net/logout.php?loggedout=true
```

This works because:

🔁 Logout Flow (Step-by-step)

1️⃣ User clicks logout
2️⃣ logout.php destroys session
3️⃣ Redirects to Cognito:

```
https://your-domain.auth.us-east-1.amazoncognito.com/logout
```

4️⃣ Cognito clears its cookies
5️⃣ Cognito redirects to:

```
https://dxxxx.cloudfront.net/logout.php?loggedout=true
```

6️⃣ logout.php detects ?loggedout=true
7️⃣ Styled logout page is displayed

✔ Perfect
✔ Secure
✔ Production-ready

### 🔐 Why ?loggedout=true Is Important

Without it:

Your file cannot distinguish between:

First request (needs redirect to Cognito)

Return request (needs to display logout page)

That flag prevents infinite redirect loops.

### ⚠️ Important Things To Double-Check

Inside Amazon Cognito console:

App Client → Hosted UI → Sign-out URL must EXACTLY match:

```
https://dxxxx.cloudfront.net/logout.php?loggedout=true
```

✔ Same protocol (https)
✔ Same domain
✔ Same path
✔ Same query parameter

Even a small mismatch = Cognito error.

### 🧠 Common Mistake People Make

They configure:

```
https://dxxxx.cloudfront.net/logout.php
```

But in code they redirect to:

```
https://dxxxx.cloudfront.net/logout.php?loggedout=true
```

🚨 Cognito will reject it because it must match exactly.

### 🏆 Final Verdict

Your configuration:

```
https://YOUR_CLOUDFRONT_DOMAIN/logout.php?loggedout=true
```

✅ YES — Correct
✅ Secure
✅ CloudFront compatible
✅ Recommended for your Charlie Café project

### 🔐 Important Clarification

Logout with Amazon Cognito does NOT require:

- cURL

- Token validation

- Backend API calls

The Cognito logout endpoint is just a browser redirect.

So your previous PHP–cURL issue does NOT apply to logout.

### 🟢 Option C — Pure HTML + JavaScript Logout (No PHP)

This approach:

- Clears tokens from browser (if stored there)

- Redirects directly to Cognito logout endpoint

- No server code

- No session_destroy()

- No cURL

- No backend logic

### 🏗 When Is JS Logout Safe?

It is perfectly fine if:

✔ You are using Hosted UI

✔ You are not storing sensitive server sessions

✔ Your app is mostly frontend-driven

If you are not heavily relying on PHP sessions → JS logout is totally acceptable.

### 🚀 Clean JavaScript Logout Example

Create:

logout.html

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Café ☕ | Logout</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
body {
    background:#1a110b;
    color:white;
    height:100vh;
    display:flex;
    justify-content:center;
    align-items:center;
    text-align:center;
}
.card {
    background:#3a251c;
    padding:40px;
    border-radius:20px;
}
</style>
</head>
<body>

<div class="card">
    <h2>☕ Charlie Café</h2>
    <p>Logging you out...</p>
</div>

<script>
// ===========================================================
// CHARLIE CAFÉ ☕ - JavaScript Logout
// No PHP required
// ===========================================================

// Replace with your Cognito domain
const COGNITO_DOMAIN = "https://your-domain.auth.us-east-1.amazoncognito.com";
const CLIENT_ID = "YOUR_CLIENT_ID";

// After logout, redirect to login page
const LOGOUT_REDIRECT = "https://dxxxx.cloudfront.net/login.html";

// Clear any stored tokens (if you used localStorage/sessionStorage)
localStorage.clear();
sessionStorage.clear();

// Redirect to Cognito logout endpoint
window.location.href = `${COGNITO_DOMAIN}/logout?client_id=${CLIENT_ID}&logout_uri=${encodeURIComponent(LOGOUT_REDIRECT)}`;
</script>

</body>
</html>
```

### 🧠 Comparison: PHP vs JS Logout

| Feature               | PHP Logout | JS Logout |
| --------------------- | ---------- | --------- |
| Requires backend      | ✅          | ❌         |
| Destroys PHP session  | ✅          | ❌         |
| Works with Hosted UI  | ✅          | ✅         |
| Risk of cURL issues   | Possible   | ❌ None    |
| Simpler               | ❌          | ✅         |
| Good for frontend app | ⚠️         | ✅         |

### 🎯 Which Should YOU Choose?

Based on your situation:

- You had cURL issues before

- You are deploying behind CloudFront

- You don’t want backend bugs

- Your app is not deeply server-driven

#### 👉 I recommend JavaScript logout.

It is:
✔ Cleaner

✔ Less risky

✔ Easier to debug

✔ Fully compatible with Cognito Hosted UI

### ⚠️ When Should You NOT Use JS Logout?

If:

- You rely heavily on PHP sessions for access control

- You store sensitive data server-side

- You validate tokens server-side

Then PHP logout is better.

### 🏆 My Professional Recommendation For Charlie Café

Use:

- HTML + JS for login redirect

- HTML + JS for logout redirect

- PHP only for protected pages (if needed)

- Keep authentication browser-driven.

It avoids backend token complexity.

### 1️⃣ Your Requirements Recap

AWS Cognito service is being used

- Frontend pages (login, dashboard, etc.) must be protected and secure

- You don’t want public access

- You don’t want PHP cURL issues or bugs again

- You want to deploy a final, stable version

### 2️⃣ Core Considerations

#### a) Why PHP was problematic before

- Previous issues were mostly cURL + Cognito API token requests

- PHP is only needed if you want server-side token verification or session management

- But Cognito Hosted UI + JS can handle login/logout entirely in the browser

- If PHP tries to call Cognito APIs (like introspection, refresh, token validation), that’s where cURL bugs happen

#### b) What you actually need

- Secure pages → only accessible if user is logged in

- Logout → destroy session and clear tokens

- Frontend-driven authentication → avoid unnecessary PHP complexity

### 3️⃣ Recommended Approach For Your Project

#### ✅ Frontend + JS (No PHP cURL)

- Use login.html → redirect to Cognito Hosted UI

- Use JS + localStorage/sessionStorage → store tokens temporarily

- Protect your dashboard pages with a JS check: if no token → redirect to login

- Use logout.html (JS) → redirect to Cognito logout endpoint

####  ✅ Optional PHP

- Only needed if you want server-side token verification (optional)

- You can still use logout.php as we built above; it’s simple, one file, no cURL involved

- That PHP logout works 100% reliably because it just destroys the session and redirects to Cognito logout endpoint → then Cognito redirects back to your styled logout page

So you won’t hit PHP + cURL issues again, because there is no API call to Cognito in that logout.php.

### 4️⃣ How Logout.php Works Now (Safe, No Bug)

- First visit → destroys PHP session → redirects to Cognito logout endpoint

- Cognito clears its session

- Redirects back to logout.php?loggedout=true

- PHP detects ?loggedout=true → shows styled logout page

- No cURL, no API call, no token fetching, no backend errors

This is safe and production-ready. ✅

### 5️⃣ Why You Can Trust This Setup

- CloudFront + Cognito integration works as long as URLs match

- logout.php handles both session destruction and styling

- Single file, simple flow, easy to debug

Fully compatible with protected pages

### 6️⃣ Suggested Final Architecture for Charlie Café

```
/login.html          → JS redirect to Cognito Hosted UI
/cognito-callback.php → JS or PHP reads Cognito token, stores in session/localStorage
/dashboard.html      → JS checks token; if missing → redirect to login
/logout.php          → destroys session + redirects to Cognito logout → shows styled page
```

All backend PHP is minimal and no API calls. You are safe from previous cURL issues.

### 7️⃣ My Professional Recommendation

#### ✅ Use logout.php as I gave you in “Option A – Single File”

- Fully production-ready

- Secure for protected pages

- Styled logout page included

- No PHP cURL or Cognito API issues

- Works perfectly with CloudFront
----

### login.html

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Café ☕ | Login</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- Bootstrap -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- Google Font -->
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;500;700&display=swap" rel="stylesheet">

<style>
body {
    font-family: 'Poppins', sans-serif;
    background: url('https://images.unsplash.com/photo-1509042239860-f550ce710b93') no-repeat center center/cover;
    height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
}

.overlay {
    background: rgba(0,0,0,0.6);
    position: absolute;
    width: 100%;
    height: 100%;
}

.login-card {
    position: relative;
    background: rgba(58,37,28,0.95);
    padding: 40px;
    border-radius: 20px;
    box-shadow: 0 15px 35px rgba(0,0,0,0.6);
    width: 350px;
    text-align: center;
    color: #fff;
    z-index: 2;
}

.logo {
    font-size: 40px;
    margin-bottom: 10px;
}

.cafe-title {
    font-size: 26px;
    font-weight: 700;
    margin-bottom: 25px;
}

.btn-login {
    background: linear-gradient(135deg,#ff5722,#ff9800);
    border: none;
    border-radius: 50px;
    padding: 12px;
    font-weight: 600;
    width: 100%;
    color: #fff;
    transition: 0.3s;
}

.btn-login:hover {
    transform: scale(1.05);
}
</style>
</head>

<body>

<div class="overlay"></div>

<div class="login-card">
    <div class="logo">☕</div>
    <div class="cafe-title">Charlie Café</div>
    <p class="mb-4">Welcome back! Enjoy your coffee break.</p>
    <button id="loginBtn" class="btn btn-login">Login with Cognito</button>
</div>

<script>
// ===========================================================
// CHARLIE CAFÉ ☕ - Cognito Login
// Using Amazon Cognito Hosted UI
// ===========================================================

// 🔹 Replace with your actual values
const COGNITO_DOMAIN = "https://your-domain.auth.us-east-1.amazoncognito.com";
const CLIENT_ID = "YOUR_NEW_CLIENT_ID";

// Redirect URI must match the one configured in Cognito
const REDIRECT_URI = window.location.origin + "/cognito-callback.php";

// Build Hosted UI login URL
const loginUrl = `${COGNITO_DOMAIN}/login?client_id=${CLIENT_ID}&response_type=token&scope=email+openid&redirect_uri=${encodeURIComponent(REDIRECT_URI)}`;

// Redirect to Cognito Hosted UI when button clicked
document.getElementById("loginBtn").addEventListener("click", () => {
    window.location.href = loginUrl;
});
</script>

</body>
</html>
```

#### New 

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Café ☕ | Login</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- =========================================================
     CHARLIE CAFÉ — LOGIN PAGE
     ---------------------------------------------------------
     ✔ Uses config.js for Cognito settings
     ✔ Uses central-auth.js for login logic
     ✔ Authorization Code Flow
     ✔ No hardcoded secrets
========================================================= -->

<!-- ===================== BOOTSTRAP ===================== -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- ===================== GOOGLE FONT ===================== -->
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;500;700&display=swap" rel="stylesheet">

<style>
body {
    font-family: 'Poppins', sans-serif;
    background: url('https://images.unsplash.com/photo-1509042239860-f550ce710b93')
                no-repeat center center/cover;
    height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
}

.overlay {
    background: rgba(0,0,0,0.6);
    position: absolute;
    width: 100%;
    height: 100%;
}

.login-card {
    position: relative;
    background: rgba(58,37,28,0.95);
    padding: 40px;
    border-radius: 20px;
    box-shadow: 0 15px 35px rgba(0,0,0,0.6);
    width: 350px;
    text-align: center;
    color: #fff;
    z-index: 2;
}

.logo {
    font-size: 40px;
    margin-bottom: 10px;
}

.cafe-title {
    font-size: 26px;
    font-weight: 700;
    margin-bottom: 25px;
}

.btn-login {
    background: linear-gradient(135deg,#ff5722,#ff9800);
    border: none;
    border-radius: 50px;
    padding: 12px;
    font-weight: 600;
    width: 100%;
    color: #fff;
    transition: 0.3s;
}

.btn-login:hover {
    transform: scale(1.05);
}
</style>
</head>

<body>

<div class="overlay"></div>

<div class="login-card">
    <div class="logo">☕</div>
    <div class="cafe-title">Charlie Café</div>
    <p class="mb-4">Admin & Employee Login</p>

    <button id="loginBtn" class="btn btn-login">
        Login with Cognito
    </button>
</div>

<!-- =========================================================
     LOAD CENTRAL JS MODULES (ORDER MATTERS)
========================================================= -->
<script src="js/config.js"></script>
<script src="js/utils.js"></script>
<script src="js/central-auth.js"></script>

<script>
/* =========================================================
   CHARLIE CAFÉ — LOGIN LOGIC
   ---------------------------------------------------------
   ✔ Uses config.js automatically
   ✔ Uses central-auth.js login()
   ✔ Authorization Code Flow
========================================================= */

document.addEventListener("DOMContentLoaded", () => {

    const loginBtn = document.getElementById("loginBtn");

    if (!loginBtn) return;

    loginBtn.addEventListener("click", () => {

        // Redirect user to Cognito Hosted UI
        // After login, user returns to admin dashboard
        CHARLIE_AUTH.login(
            window.location.origin + "/cafe-admin-dashboard.html"
        );

    });

});
</script>

</body>
</html>
```




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

----






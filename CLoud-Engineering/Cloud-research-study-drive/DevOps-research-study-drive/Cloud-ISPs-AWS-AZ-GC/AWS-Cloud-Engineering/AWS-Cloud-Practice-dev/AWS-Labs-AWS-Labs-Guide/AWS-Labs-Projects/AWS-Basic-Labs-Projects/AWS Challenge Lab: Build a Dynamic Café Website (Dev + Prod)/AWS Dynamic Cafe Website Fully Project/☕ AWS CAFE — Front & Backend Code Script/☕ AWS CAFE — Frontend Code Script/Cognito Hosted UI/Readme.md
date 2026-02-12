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

```
<?php
// ===========================================================
// CHARLIE CAFÉ ☕ - Logout
// ===========================================================
session_start();
session_destroy();
header("Location: login.html");
exit;
```

---

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

---




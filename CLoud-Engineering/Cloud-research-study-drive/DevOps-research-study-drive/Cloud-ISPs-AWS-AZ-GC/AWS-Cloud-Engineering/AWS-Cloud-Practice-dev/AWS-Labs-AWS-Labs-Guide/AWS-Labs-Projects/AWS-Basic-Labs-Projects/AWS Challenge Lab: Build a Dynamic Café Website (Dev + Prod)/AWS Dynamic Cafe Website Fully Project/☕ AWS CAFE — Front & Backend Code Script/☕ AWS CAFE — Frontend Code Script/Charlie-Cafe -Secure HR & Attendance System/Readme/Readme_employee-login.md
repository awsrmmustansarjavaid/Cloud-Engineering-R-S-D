

### employee-login.html

Got it! ✅ I can clean this up so your employee login properly uses config.js values for Cognito and CloudFront, and fixes the redirect issue. Here’s the fully final working code for employee-login.html:

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Café ☕ | Employee Login</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- Bootstrap & Google Fonts -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;500;700&display=swap" rel="stylesheet">

<style>
body {
    font-family: 'Poppins', sans-serif;
    background: url('https://images.unsplash.com/photo-1509042239860-f550ce710b93') no-repeat center center/cover;
    height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
    position: relative;
    color: #fff;
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
    z-index: 2;
}

.logo { font-size: 40px; margin-bottom: 10px; }
.cafe-title { font-size: 26px; font-weight: 700; margin-bottom: 25px; }

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
.btn-login:hover { transform: scale(1.05); }
</style>
</head>

<body>
<div class="overlay"></div>

<div class="login-card">
    <div class="logo">☕</div>
    <div class="cafe-title">Charlie Café Employee</div>
    <p class="mb-4">Welcome back! Please login to access the employee portal.</p>
    
    <button id="loginBtn" class="btn btn-login">Login with Cognito</button>
</div>

<script src="config.js"></script>
<script src="utils.js"></script>
<script src="central-auth.js"></script>
<script src="api.js"></script>
<script src="central-printing.js"></script>

<script>
/* ============================================================
   CHARLIE CAFÉ EMPLOYEE LOGIN
   Using Amazon Cognito Hosted UI
   ✅ Fully uses config.js values
============================================================ */

const DOMAIN = window.CHARLIE_CONFIG.COGNITO_DOMAIN;
const CLIENT_ID = window.CHARLIE_CONFIG.CLIENT_ID;
const REDIRECT_URI = `${window.CHARLIE_CONFIG.CLOUDFRONT_BASE}/employee-portal.html`;

// Build Hosted UI login URL
const loginUrl = `${DOMAIN}/login?response_type=token&client_id=${CLIENT_ID}&redirect_uri=${encodeURIComponent(REDIRECT_URI)}&scope=email+openid`;

// Redirect to Cognito Hosted UI when login button clicked
document.getElementById("loginBtn").addEventListener("click", () => {
    if (typeof utils !== "undefined") utils.log("Redirecting to Cognito Hosted UI...");
    window.location.href = loginUrl;
});

// Detect Cognito tokens in URL after login
if (window.location.hash) {
    const hash = window.location.hash.substring(1);
    const params = new URLSearchParams(hash);
    const accessToken = params.get("access_token");
    const idToken = params.get("id_token");
    
    if (accessToken && idToken && typeof CHARLIE_AUTH !== "undefined") {
        CHARLIE_AUTH.storeTokens({ accessToken, idToken });
        // Redirect to employee portal using CloudFront base
        window.location.href = `${window.CHARLIE_CONFIG.CLOUDFRONT_BASE}/employee-portal.html`;
    }
}
</script>
</body>
</html>
```


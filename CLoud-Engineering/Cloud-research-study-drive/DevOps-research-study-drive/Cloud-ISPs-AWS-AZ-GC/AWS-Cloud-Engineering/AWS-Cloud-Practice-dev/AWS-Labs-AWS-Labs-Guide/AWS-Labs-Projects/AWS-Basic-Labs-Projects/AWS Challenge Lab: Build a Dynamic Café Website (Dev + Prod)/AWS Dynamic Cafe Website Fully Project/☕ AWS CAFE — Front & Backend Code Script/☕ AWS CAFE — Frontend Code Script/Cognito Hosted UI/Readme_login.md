# Charlie Cafe - login.html

### login.html

> **Update Version:1.0**

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Café ☕ | Login</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- Bootstrap & Font -->
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
    <div class="cafe-title">Charlie Café</div>
    <p class="mb-4">Welcome back! Enjoy your coffee break.</p>
    <button id="loginBtn" class="btn btn-login">Login with Cognito</button>
</div>

<script>
// ===========================================================
// CHARLIE CAFÉ ☕ - Cognito Login (Authorization Code Flow)
// ===========================================================

// 1️⃣ Cognito Hosted UI info
const COGNITO_DOMAIN = "https://us-east-1bzr7fplam.auth.us-east-1.amazoncognito.com";
const CLIENT_ID = "4b2l8vd8ss4shmlk0pbg8rbiob";

// 2️⃣ Your admin dashboard after login
const AFTER_LOGIN = "https://dgexi85ya6bx7.cloudfront.net/cafe-admin-dashboard.html";

// 3️⃣ Redirect URI (must exactly match Cognito app client callback)
const REDIRECT_URI = "https://dgexi85ya6bx7.cloudfront.net/login.html";

// 4️⃣ Build Hosted UI login URL (Authorization Code Flow)
const loginUrl = `${COGNITO_DOMAIN}/login?client_id=${CLIENT_ID}&response_type=code&scope=openid+email+profile&redirect_uri=${encodeURIComponent(REDIRECT_URI)}`;

// 5️⃣ Handle login button click
document.getElementById("loginBtn").addEventListener("click", () => {
    window.location.href = loginUrl;
});

// 6️⃣ On page load: check for `code` in URL
const urlParams = new URLSearchParams(window.location.search);
const code = urlParams.get("code");

if (code) {
    // Exchange code for tokens using Cognito OAuth2 /token endpoint
    async function exchangeCode() {
        const tokenUrl = `${COGNITO_DOMAIN}/oauth2/token`;
        const data = new URLSearchParams();
        data.append("grant_type", "authorization_code");
        data.append("client_id", CLIENT_ID);
        data.append("code", code);
        data.append("redirect_uri", REDIRECT_URI);

        try {
            const res = await fetch(tokenUrl, {
                method: "POST",
                headers: {
                    "Content-Type": "application/x-www-form-urlencoded"
                },
                body: data.toString()
            });

            if (!res.ok) throw new Error("Token exchange failed");

            const tokens = await res.json();
            // Save access token in session storage
            sessionStorage.setItem("cognitoAccessToken", tokens.access_token);

            // Redirect to admin dashboard
            window.location.href = AFTER_LOGIN;
        } catch (err) {
            console.error(err);
            alert("Login failed: " + err.message);
        }
    }

    exchangeCode();
}
</script>
</body>
</html>
```

---
### login.html

> **Update Version:1.1**



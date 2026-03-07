<?php
// ===========================================================
// CHARLIE CAFÉ ☕ - Cognito Logout Page
// Uses config.js values for Cognito Domain and Client ID
// ===========================================================

session_start();

/*
--------------------------------------------------------------
STEP 1
If Cognito already redirected back with ?loggedout=true
→ Show logout confirmation page
--------------------------------------------------------------
*/

if (isset($_GET['loggedout'])) {
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

body{
    font-family:'Poppins',sans-serif;
    background:url('https://images.unsplash.com/photo-1495474472287-4d71bcdd2085') no-repeat center center/cover;
    height:100vh;
    display:flex;
    justify-content:center;
    align-items:center;
}

.overlay{
    background:rgba(0,0,0,0.65);
    position:absolute;
    width:100%;
    height:100%;
}

.logout-card{
    position:relative;
    background:rgba(58,37,28,0.95);
    padding:40px;
    border-radius:20px;
    width:350px;
    text-align:center;
    color:#fff;
    z-index:2;
    box-shadow:0 15px 35px rgba(0,0,0,0.6);
}

.logo{
    font-size:40px;
    margin-bottom:10px;
}

.cafe-title{
    font-size:26px;
    font-weight:700;
    margin-bottom:20px;
}

.btn-login{
    background:linear-gradient(135deg,#ff5722,#ff9800);
    border:none;
    border-radius:50px;
    padding:12px;
    font-weight:600;
    width:100%;
    color:#fff;
    transition:0.3s;
}

.btn-login:hover{
    transform:scale(1.05);
}

</style>
</head>

<body>

<div class="overlay"></div>

<div class="logout-card">

<div class="logo">☕</div>
<div class="cafe-title">Charlie Café</div>

<h4 class="mb-3">You’ve been logged out!</h4>

<p class="mb-4">
Thanks for visiting. See you again soon ☕
</p>

<a href="login.html" class="btn btn-login">
Back to Login
</a>

</div>

</body>
</html>

<?php
exit;
}

/*
--------------------------------------------------------------
STEP 2
First visit to logout.php
→ Destroy PHP session
→ JS will redirect to Cognito logout
--------------------------------------------------------------
*/

session_destroy();

?>

<!DOCTYPE html>
<html>
<head>
<title>Logging out...</title>

<!-- Load global config -->
<script src="/js/config.js"></script>

<script>

/* =========================================================
   CHARLIE CAFÉ COGNITO LOGOUT SCRIPT
========================================================= */

/*
config.js example

window.CHARLIE_CONFIG = {
   REGION: "us-east-1",
   CLIENT_ID: "xxxxxxxx",
   COGNITO_DOMAIN: "https://xxxxx.auth.us-east-1.amazoncognito.com",
   CLOUDFRONT_BASE: "https://xxxx.cloudfront.net"
}
*/


// =========================================================
// 1️⃣ Read values from config.js
// =========================================================

const DOMAIN = window.CHARLIE_CONFIG.COGNITO_DOMAIN;
const CLIENT_ID = window.CHARLIE_CONFIG.CLIENT_ID;


// =========================================================
// 2️⃣ Build redirect URL after logout
// =========================================================

const LOGOUT_REDIRECT =
window.location.origin + "/logout.php?loggedout=true";


// =========================================================
// 3️⃣ Build Cognito Logout URL
// =========================================================

const logoutUrl =
`${DOMAIN}/logout?client_id=${CLIENT_ID}&logout_uri=${encodeURIComponent(LOGOUT_REDIRECT)}`;


// =========================================================
// 4️⃣ Redirect to Cognito logout
// =========================================================

window.location.href = logoutUrl;

</script>

</head>

<body>

<p style="text-align:center;margin-top:100px;font-family:Arial">
Logging out from Charlie Café...
</p>

</body>
</html>

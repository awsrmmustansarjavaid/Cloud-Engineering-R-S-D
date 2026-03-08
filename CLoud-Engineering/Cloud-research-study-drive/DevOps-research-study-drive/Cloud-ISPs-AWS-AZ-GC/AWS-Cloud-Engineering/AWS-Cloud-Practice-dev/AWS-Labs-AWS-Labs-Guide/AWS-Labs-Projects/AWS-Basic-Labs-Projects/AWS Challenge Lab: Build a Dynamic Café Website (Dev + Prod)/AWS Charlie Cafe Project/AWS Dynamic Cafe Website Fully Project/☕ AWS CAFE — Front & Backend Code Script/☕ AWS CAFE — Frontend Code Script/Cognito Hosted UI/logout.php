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
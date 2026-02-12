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

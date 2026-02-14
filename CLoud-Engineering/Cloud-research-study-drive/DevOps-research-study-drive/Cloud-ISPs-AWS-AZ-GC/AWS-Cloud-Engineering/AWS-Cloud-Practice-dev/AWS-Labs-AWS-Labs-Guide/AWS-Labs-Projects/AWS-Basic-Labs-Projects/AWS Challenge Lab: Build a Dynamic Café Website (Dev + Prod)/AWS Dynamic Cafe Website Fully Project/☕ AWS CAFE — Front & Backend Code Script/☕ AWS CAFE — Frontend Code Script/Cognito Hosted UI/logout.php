<?php
// ===========================================================
// CHARLIE CAFÉ ☕ - Cognito Logout
// Properly logs user out from both local session
// AND Amazon Cognito Hosted UI
// ===========================================================

session_start();
session_destroy();

// 🔹 Replace with your values
$COGNITO_DOMAIN = "https://your-domain.auth.us-east-1.amazoncognito.com";
$CLIENT_ID = "YOUR_NEW_CLIENT_ID";

// After logout redirect back to login page
$LOGOUT_REDIRECT = "http://localhost/login.html";

// Build logout URL
$logoutUrl = $COGNITO_DOMAIN . "/logout?client_id=" . $CLIENT_ID . "&logout_uri=" . urlencode($LOGOUT_REDIRECT);

// Redirect to Cognito logout endpoint
header("Location: $logoutUrl");
exit;
?>
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

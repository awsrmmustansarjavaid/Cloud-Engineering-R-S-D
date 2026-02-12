<?php
// ===========================================================
// CHARLIE CAFÉ ☕ - Logout
// ===========================================================
session_start();
session_destroy();
header("Location: login.html");
exit;

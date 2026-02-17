# Charlie Cafe - cafe-admin-dashboard


### cafe-admin-dashboard.html

> **Update Version:1.0**

- Load only the necessary JS modules (config.js + central-auth.js) instead of the old monolithic file.

- Use the new CHARLIE object from central-auth.js.

- Keep all UI/styling untouched.

- Ensure the redirect after login still works.

### ✅ UPDATED dashboard-login.html

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Café ☕ | Login</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- Bootstrap CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
body {
    background: #0f0f10;
    color: white;
    font-family: 'Segoe UI', sans-serif;
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
}
.card {
    background: #1c1c1e;
    border-radius: 15px;
    padding: 30px;
    width: 350px;
    text-align: center;
}
</style>
</head>

<body>

<div class="card">
    <h3>☕ Charlie Café</h3>
    <p class="text-muted">Admin & Staff Login</p>

    <!-- Cognito Hosted UI Login Button -->
    <button class="btn btn-warning w-100 mt-3" onclick="login()">
        Login with Cognito
    </button>
</div>

<!-- ================= NEW JS MODULES ================= -->
<script src="config.js"></script>
<script src="central-auth.js"></script>

<script>
// ==========================================================
// CHARLIE CAFÉ — LOGIN PAGE SCRIPT
// Uses separated central-auth.js module
// ==========================================================
function login() {
    // Redirect to dashboard after successful Cognito login
    const redirectUrl = `${window.location.origin}/cafe-admin-dashboard.html`;

    // Call centralized login function
    CHARLIE.auth.login(redirectUrl);
}
</script>

</body>
</html>
```

### ✅ WHAT CHANGED

- Removed old central-auth-api.js reference.

- Added config.js + central-auth.js as separate modules.

- Login button still works exactly the same.

- UI, styling, colors untouched.

- Redirect after login remains to cafe-admin-dashboard.html.
---

# Charlie-Cafe FrontEnd DashBoard


### cafe-admin-dashboard.html

✔ Served from CloudFront / S3 / HTTPS
✔ Cognito Hosted UI configured correctly
✔ Redirect URI matches the page URL
✔ central-auth-api.js is loaded from the same origin

### 1️⃣ WHAT “BUTTON-BASED LOGIN” REALLY MEANS

With Cognito Hosted UI, you never embed a login form.

Instead:

User opens a public page (index.html)

User clicks Login

JavaScript redirects the browser to Cognito Hosted UI

Cognito shows its own login page

After success, Cognito redirects back to your dashboard

So the login button is just a redirect trigger.

### 2️⃣ WHERE DOES THE COGNITO HOSTED UI URL GO?

👉 NOT in HTML
👉 NOT hardcoded in a <form>
👉 NOT visible to the user

It lives inside JavaScript, and you already have it in:

```
CONFIG.COGNITO_DOMAIN
```

The button simply calls:

```
CHARLIE.auth.login()
```

That function builds this internally:

```
https://YOUR_DOMAIN.auth.us-east-1.amazonaws.com/login
```

So you never paste the Hosted UI URL directly into index.html.

3️⃣ VISUAL FLOW (IMPORTANT)

```
index.html
   ↓ (click button)
JavaScript redirect
   ↓
Cognito Hosted UI (login page)
   ↓
Redirect back
   ↓
cafe-admin-dashboard.html
```

### 4️⃣ FINAL, CORRECT index.html (LOGIN PAGE)

This page:

Is public

Shows a Login button

Does nothing else

No auth checks

No white screen

No auto redirects

✅ COPY THIS EXACTLY

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Café ☕ | Login</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
body {
    background: #0f0f10;
    color: white;
    font-family: 'Segoe UI', sans-serif;
    height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
}

.card {
    background: #1c1c1e;
    border-radius: 15px;
    padding: 30px;
    width: 340px;
    text-align: center;
}
</style>
</head>

<body>

<div class="card">
    <h3>☕ Charlie Café</h3>
    <p class="text-muted">Admin & Staff Login</p>

    <!-- Button-based login -->
    <button class="btn btn-warning w-100 mt-3" onclick="login()">
        Login with Cognito
    </button>
</div>

<!-- Central Auth -->
<script src="js/central-auth-api.js"></script>

<script>
/*
  Clicking the button simply redirects the browser
  to Cognito Hosted UI using central-auth-api.js
*/
function login() {
    CHARLIE.auth.login(
        `${window.location.origin}/cafe-admin-dashboard.html`
    );
}
</script>

</body>
</html>
```

### 5️⃣ WHAT YOU MUST CONFIGURE IN COGNITO (THIS MAKES IT WORK)
Cognito → App client → Hosted UI

Callback URLs

```
https://YOUR_CLOUDFRONT_DOMAIN/cafe-admin-dashboard.html
```

Logout URLs

```
https://YOUR_CLOUDFRONT_DOMAIN/index.html
```

OAuth
✔ Implicit grant (token)
✔ openid
✔ email
✔ profile

### 6️⃣ WHAT HAPPENS WHEN YOU TEST (REAL WORLD)

First test:

Open:

```
https://d159bqc5pw64hn.cloudfront.net/index.html
```

You see:

```
☕ Charlie Café
[ Login with Cognito ]
```

Click login

Cognito login page opens

Login

Redirect to:

```
/cafe-admin-dashboard.html
```

White page disappears

Dashboard shows 🎉

### 7️⃣ COMMON MISTAKES (AVOID THESE)

❌ Pasting Hosted UI URL into HTML
❌ Trying to embed login form
❌ Testing on livecode.io
❌ Removing display:none
❌ Opening dashboard directly before login

### 8️⃣ FINAL CONFIDENCE CHECK

❓ “Where do I insert Cognito Hosted UI URL?”

Answer:
👉 You don’t.
👉 It lives inside central-auth-api.js.
👉 The button just calls CHARLIE.auth.login().


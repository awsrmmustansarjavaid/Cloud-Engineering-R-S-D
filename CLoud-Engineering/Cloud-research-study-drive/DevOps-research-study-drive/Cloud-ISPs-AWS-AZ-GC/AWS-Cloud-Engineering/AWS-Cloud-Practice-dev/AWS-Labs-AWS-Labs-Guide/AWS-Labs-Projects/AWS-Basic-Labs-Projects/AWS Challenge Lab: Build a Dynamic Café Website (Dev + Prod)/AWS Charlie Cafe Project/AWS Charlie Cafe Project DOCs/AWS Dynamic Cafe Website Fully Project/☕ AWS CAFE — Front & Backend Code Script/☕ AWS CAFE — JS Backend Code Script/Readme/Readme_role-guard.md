# Charlie Cafe  --- role-guard

A frontend-only role guard file that:

- Reads Cognito access token

- Checks cognito:groups

- Allows / blocks page access

- Redirects unauthorized users

This is 100% possible and correct.

### ✅ What You Want

| Role            | Allowed Pages                                    |
| --------------- | ------------------------------------------------ |
| Admin / Manager | cafe-admin-dashboard.html, cafe-order-admin.html |
| Employee        | order-status.html, employee-portal.html          |


We will enforce this entirely in frontend JS.

### ✅ Create New File: role-guard.js

This file will:

- Integrate with central-auth.js

- Use getUserRoles()

- Automatically protect page

- Redirect if unauthorized

### 📄 role-guard.js

```
/* =========================================================
   CHARLIE CAFE — ROLE GUARD MODULE
   ---------------------------------------------------------
   ✔ Protects pages based on Cognito Groups
   ✔ Works with central-auth.js
   ✔ No Lambda required
   ✔ No API Gateway required
========================================================= */

window.CHARLIE_ROLE_GUARD = (() => {

    const AUTH = window.CHARLIE_AUTH;

    /* =====================================================
       🔐 ADMIN / MANAGER ONLY
    ===================================================== */
    async function adminOnly() {

        // Ensure user is logged in
        await AUTH.protectPage();

        const roles = AUTH.getUserRoles();

        const allowedRoles = ["admin", "manager"];

        const hasAccess = roles.some(role =>
            allowedRoles.includes(role)
        );

        if (!hasAccess) {
            alert("Access denied. Admin or Manager only.");
            AUTH.logout();
        }
    }

    /* =====================================================
       👨‍🍳 EMPLOYEE ONLY
    ===================================================== */
    async function employeeOnly() {

        await AUTH.protectPage();

        const roles = AUTH.getUserRoles();

        const allowedRoles = ["employee", "admin", "manager"];

        const hasAccess = roles.some(role =>
            allowedRoles.includes(role)
        );

        if (!hasAccess) {
            alert("Access denied. Employees only.");
            AUTH.logout();
        }
    }

    return {
        adminOnly,
        employeeOnly
    };

})();
```

### ✅ How To Use It In Pages

### 🔹 1️⃣ In cafe-admin-dashboard.html

Add at bottom before </body>:

```
<script src="config.js"></script>
<script src="utils.js"></script>
<script src="central-auth.js"></script>
<script src="role-guard.js"></script>

<script>
    CHARLIE_ROLE_GUARD.adminOnly();
</script>
```

### 🔹 2️⃣ In cafe-order-admin.html

```
<script>
    CHARLIE_ROLE_GUARD.adminOnly();
</script>
```

### 🔹 3️⃣ In employee-portal.html

```
<script>
    CHARLIE_ROLE_GUARD.employeeOnly();
</script>
```

### 🔹 4️⃣ In order-status.html

```
<script>
    CHARLIE_ROLE_GUARD.employeeOnly();
</script>
```

### ✅ How It Works

Flow:

```
User opens page
      ↓
role-guard.js runs
      ↓
central-auth.js validates token
      ↓
Reads Cognito groups
      ↓
If role allowed → show page
If not → logout + redirect
```

### ✅ What This Uses From Your Existing Files

From central-auth.js:

- protectPage()

- getUserRoles()

- logout()

From utils.js:

- parseJwt()

- getToken()

- isTokenExpired()

From config.js:

- Cognito domain

- Client ID

No Lambda needed.
No API Gateway needed.

### ⚠️ IMPORTANT SECURITY NOTE

This protects UI only.

If your API endpoints are public:

- Someone could still call them directly.

For full security:

- Use Cognito Authorizer in API Gateway

- Send Authorization header

But for frontend page access control, this is perfectly fine.

### ✅ Optional Upgrade (Cleaner UX)

Instead of logout, you can redirect:

```
window.location.replace("unauthorized.html");
```

### 🏆 Final Result

Now your system has:

- Cognito login/logout

- Role-based page access

- No Lambda needed

- No API Gateway needed

- Clean architecture

- Fully frontend-controlled page protection

### Indirectly Connect with Config.js

Your role-guard.js is connected to config.js, but through central-auth.js, not directly.

### 🧠 How the Connection Actually Works

Here is the real flow:

```
config.js
    ↓
central-auth.js
    ↓
role-guard.js
```

### 🔹 1️⃣ config.js (Your Configuration Source)

This file stores:

- Cognito domain

- Client ID

- API base URL

- Other environment settings

Example:

```
window.CHARLIE_CONFIG = {
    COGNITO_DOMAIN: "your-domain.auth.us-east-1.amazoncognito.com",
    CLIENT_ID: "xxxxxxxxxxxx",
    API_BASE: "https://api-id.execute-api.us-east-1.amazonaws.com/prod"
};
```

### 🔹 2️⃣ central-auth.js Uses config.js

Inside central-auth.js:

```
const CONFIG = window.CHARLIE_CONFIG;
```

It uses:

- CONFIG.COGNITO_DOMAIN

- CONFIG.CLIENT_ID

For:

- Login redirect

- Token exchange

- Logout redirect

So central-auth depends on config.js directly.

### 🔹 3️⃣ role-guard.js Uses central-auth.js

Inside your role guard:

```
const AUTH = window.CHARLIE_AUTH;
```

And it calls:

```
AUTH.protectPage();
AUTH.getUserRoles();
AUTH.logout();
```

Those functions internally use config.js.

### ✅ So Final Answer:

Does role-guard.js connect with config.js?

✔ Yes — but indirectly.

It does NOT read config.js itself.

It depends on central-auth.js,
and central-auth.js depends on config.js.

### 🔗 Full Dependency Chain

```
config.js
   ↓
utils.js
   ↓
central-auth.js
   ↓
role-guard.js
   ↓
Your HTML page
```

### ⚠️ VERY IMPORTANT

The script loading order in HTML must be:

```
<script src="config.js"></script>
<script src="utils.js"></script>
<script src="central-auth.js"></script>
<script src="role-guard.js"></script>
```

If you change order, it will break.

Because:

- role-guard needs central-auth

- central-auth needs config

- central-auth needs utils

### 🚀 How to Make It EVEN Cleaner (Optional Improvement)

If you want stronger integration, you could modify role-guard.js like this:

```
const CONFIG = window.CHARLIE_CONFIG;
const AUTH = window.CHARLIE_AUTH;
```

Even if you don’t use CONFIG now, it makes the dependency explicit.

### 🏁 Final Conclusion

✔ Yes — your configuration in config.js is being used

✔ No Lambda needed

✔ No API Gateway needed

✔ Fully frontend-based role control

✔ Clean modular structure
---


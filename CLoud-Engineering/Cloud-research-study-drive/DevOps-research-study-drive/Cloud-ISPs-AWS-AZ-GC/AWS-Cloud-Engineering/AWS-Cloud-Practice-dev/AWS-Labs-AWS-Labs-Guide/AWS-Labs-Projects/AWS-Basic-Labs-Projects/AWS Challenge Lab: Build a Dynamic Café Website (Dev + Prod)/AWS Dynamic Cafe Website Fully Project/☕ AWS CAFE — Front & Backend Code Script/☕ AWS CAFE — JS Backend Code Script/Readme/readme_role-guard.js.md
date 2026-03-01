# Charlie Cafe -role-guard.js

### role-guard.js

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

### ✅ 1️⃣ Place the file correctly

Save the file here:

```
/public/js/role-guard.js
```

(or whatever folder your other JS files are in — looks like /js/)

### ✅ 2️⃣ Add It To Your Front Page

Add this AFTER central-auth.js:

```
<script src="/js/config.js"></script>
<script src="/js/utils.js"></script>
<script src="/js/central-auth.js"></script>
<script src="/js/role-guard.js"></script> <!-- ADD THIS LINE -->
<script src="/js/api.js"></script>
<script src="/js/central-printing.js"></script>
```

#### ⚠️ Important:

- role-guard.js must load after central-auth.js because it uses:

```
const AUTH = window.CHARLIE_AUTH;
```

### ✅ 3️⃣ How To Use It On A Page

#### 🔐 Admin Page Example

At the top of your admin.html:

```
<script>
    window.CHARLIE_ROLE_GUARD.adminOnly();
</script>
```

#### 👨‍🍳 Employee Page Example

```
<script>
    window.CHARLIE_ROLE_GUARD.employeeOnly();
</script>
```

### ✅ 4️⃣ What Happens When Page Loads

- protectPage() checks login

- Reads Cognito groups from token

- If not allowed → logs user out

- Shows alert

No backend required.
No Lambda needed.
100% frontend role protection.

### ✅ 5️⃣ After This — Verify Token (Very Important)

After login:

#### Step 1 — Open Browser DevTools

Application → Local Storage

Confirm:

```
access_token
```

exists

#### Step 2 — Copy token

Paste it into:

👉 https://jwt.io

#### Step 3 — Confirm token contains:

```
{
  "email": "user@email.com",
  "cognito:groups": ["admin"],
  "exp": 1234567890
}
```

If cognito:groups is missing:

❌ Your Lambda will return 403
❌ Role guard will fail
❌ API Gateway will deny access

### ✅ exact file, you should replace this part:

```
// ================== Cognito Admin Protection ==================
CHARLIE_AUTH.protectPage();
CHARLIE_AUTH.requireAdmin();
document.body.style.display = "block";
```

Because now you are using:

```
window.CHARLIE_ROLE_GUARD.adminOnly();
```

### ✅ ✅ EXACTLY Where To Put It

Go to the bottom of your HTML where this script starts:

```
<script>
```

Then replace the first section inside it with this:

```
<script>
// ================== ADMIN ROLE GUARD ==================
window.addEventListener("DOMContentLoaded", async () => {
    await window.CHARLIE_ROLE_GUARD.adminOnly();
    document.body.style.display = "block";
});
```

### ✅ Your Final Structure Will Look Like This

```
<script src="/js/config.js"></script>
<script src="/js/utils.js"></script>
<script src="/js/central-auth.js"></script>
<script src="/js/role-guard.js"></script>
<script src="/js/api.js"></script>
<script src="/js/central-printing.js"></script>

<script>
// ================== ADMIN ROLE GUARD ==================
window.addEventListener("DOMContentLoaded", async () => {
    await window.CHARLIE_ROLE_GUARD.adminOnly();
    document.body.style.display = "block";
});

// ================== Sidebar Collapsible ==================
const sidebar = document.getElementById('sidebar');
document.getElementById('sidebarToggle').addEventListener('click', () => {
    sidebar.classList.toggle('collapsed');
});
```

Everything else stays exactly the same.

### 🚨 Why This Is Better

Instead of:

```
CHARLIE_AUTH.protectPage();
CHARLIE_AUTH.requireAdmin();
```

You now use:

```
CHARLIE_ROLE_GUARD.adminOnly();
```

Which:

✔ checks login
✔ checks Cognito groups
✔ blocks non-admins
✔ logs them out automatically

Cleaner + centralized control.

### ⚠️ VERY IMPORTANT

Make sure:

```
<body style="display:none;">
```

stays there.

That prevents flashing the page before role validation.

---
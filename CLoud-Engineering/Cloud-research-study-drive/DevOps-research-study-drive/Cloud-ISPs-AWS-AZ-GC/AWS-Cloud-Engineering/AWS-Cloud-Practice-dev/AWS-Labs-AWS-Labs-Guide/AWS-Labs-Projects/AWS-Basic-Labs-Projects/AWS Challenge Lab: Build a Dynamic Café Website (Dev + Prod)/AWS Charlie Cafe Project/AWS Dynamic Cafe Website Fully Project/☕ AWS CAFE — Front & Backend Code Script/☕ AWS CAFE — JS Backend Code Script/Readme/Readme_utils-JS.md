# Charlie Cafe -- utils.js

### utils.js

> **Update Version:1.0**

```
/* =========================================================
   CHARLIE CAFE — UTILITIES
   ---------------------------------------------------------
   ✔ JWT Parsing
   ✔ Token Expiry Check
   ✔ LocalStorage Token Helper
========================================================= */

window.CHARLIE_UTILS = (() => {

    function parseJwt(token) {
        try {
            return JSON.parse(atob(token.split(".")[1]));
        } catch {
            return {};
        }
    }

    function isTokenExpired(token) {
        try {
            return parseJwt(token).exp * 1000 < Date.now();
        } catch {
            return true;
        }
    }

    function getToken() {
        return localStorage.getItem("access_token");
    }

    return {
        parseJwt,
        isTokenExpired,
        getToken
    };

})();
```

---
### utils.js

> **Update Version:1.1**

### ✅ link-builder logic inside utils.js


Excellent question 👌 — this is exactly how a real frontend developer thinks.

Yes ✅ you absolutely CAN add the link-builder logic inside utils.js.
In fact, it is cleaner because:

- You already load utils.js on all pages

- You avoid creating extra files

- You keep shared helper logic in one place

So let’s upgrade your utils.js properly — clean, structured, and professional.

### ✅ WHY It’s Safe To Add It Inside utils.js

Your current utils.js:

- Is already global

- Uses window.CHARLIE_UTILS

- Loads on all pages

We’ll simply:

- Add a new function: initCloudFrontLinks()

- Auto-run it when DOM loads

- No conflict. No complexity.

### 🚀 FULLY FINAL utils.js (With CloudFront Auto Link Builder)

Replace your entire utils.js with this:

```
/* =========================================================
   CHARLIE CAFE — UTILITIES
   ---------------------------------------------------------
   ✔ JWT Parsing
   ✔ Token Expiry Check
   ✔ LocalStorage Token Helper
   ✔ Automatic CloudFront Link Builder
========================================================= */

window.CHARLIE_UTILS = (() => {

    /* =====================================================
       🔐 Parse JWT Token
       -----------------------------------------------------
       Converts JWT payload into JSON object
    ===================================================== */
    function parseJwt(token) {
        try {
            return JSON.parse(atob(token.split(".")[1]));
        } catch {
            return {};
        }
    }

    /* =====================================================
       ⏳ Check if Token is Expired
    ===================================================== */
    function isTokenExpired(token) {
        try {
            return parseJwt(token).exp * 1000 < Date.now();
        } catch {
            return true;
        }
    }

    /* =====================================================
       🔑 Get Access Token from LocalStorage
    ===================================================== */
    function getToken() {
        return localStorage.getItem("access_token");
    }

    /* =====================================================
       ☁ Automatic CloudFront Link Builder
       -----------------------------------------------------
       Updates all elements with data-page attribute
       Example:
       <a data-page="orders.html">
    ===================================================== */
    function initCloudFrontLinks() {

        if (!window.CHARLIE_CONFIG || !window.CHARLIE_CONFIG.CLOUDFRONT_BASE) {
            console.warn("CLOUDFRONT_BASE not found in config.js");
            return;
        }

        const base = window.CHARLIE_CONFIG.CLOUDFRONT_BASE;

        document.querySelectorAll("[data-page]").forEach(element => {

            const page = element.getAttribute("data-page");

            if (page) {
                element.href = `${base}/${page}`;
            }

        });
    }

    /* =====================================================
       🚀 Auto-run when page loads
    ===================================================== */
    document.addEventListener("DOMContentLoaded", () => {
        initCloudFrontLinks();
    });

    return {
        parseJwt,
        isTokenExpired,
        getToken,
        initCloudFrontLinks
    };

})();
```

### ✅ How To Use It (Very Simple)

On any page:

```
<script src="/js/config.js"></script>
<script src="/js/utils.js"></script>
```

Then your sidebar:

```
<ul>
  <li><a data-page="cafe-admin-dashboard.html">Dashboard</a></li>
  <li><a data-page="orders.html">Orders</a></li>
  <li><a data-page="analytics.html">Analytics</a></li>
</ul>
```

That’s it.

No extra JS needed anywhere.


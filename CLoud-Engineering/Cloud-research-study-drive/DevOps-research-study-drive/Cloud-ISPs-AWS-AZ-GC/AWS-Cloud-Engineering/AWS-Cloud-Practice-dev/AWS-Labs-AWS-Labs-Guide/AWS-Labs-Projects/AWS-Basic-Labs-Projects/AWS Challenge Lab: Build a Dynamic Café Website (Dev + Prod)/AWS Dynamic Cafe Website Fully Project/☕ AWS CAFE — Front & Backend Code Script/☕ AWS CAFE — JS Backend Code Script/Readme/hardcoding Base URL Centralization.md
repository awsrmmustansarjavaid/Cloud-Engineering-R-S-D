# Charlie Cafe - hardcoding Base URL Centralization

Good 👌 this is exactly the kind of problem real production apps face.

Right now your issue is:

You are hardcoding:

```
https://dyoqxkx8bd8d7.cloudfront.net/cafe-admin-dashboard.html
```

inside multiple .html and .php files.

When CloudFront changes → you must open every file and replace URL manually ❌

We will fix this properly using config.js so you NEVER hardcode CloudFront again.

### 🎯 GOAL

Instead of this:

```
window.location.href = "https://dyoqxkx8bd8d7.cloudfront.net/cafe-admin-dashboard.html";
```

You will use:

```
window.location.href = CHARLIE_CONFIG.CLOUDFRONT_BASE + "/cafe-admin-dashboard.html";
```

So when CloudFront changes → only edit config.js.

### ✅ STEP 1 — Make Sure config.js Is Correct

Your config.js already has:

```
CLOUDFRONT_BASE: "https://d163j9zwndcxgl.cloudfront.net"
```

Good 👍

That is your single source of truth.

### ✅ STEP 2 — Create a Navigation Helper (BEST PRACTICE)

Instead of writing long paths everywhere, create reusable functions.

Open utils.js and add this:

```
/* =========================================================
   CHARLIE CAFE — NAVIGATION UTILITIES
========================================================= */

// Base URL from config
const BASE_URL = window.CHARLIE_CONFIG.CLOUDFRONT_BASE;

/**
 * Redirect to any frontend page safely
 * @param {string} page - file name (example: cafe-admin-dashboard.html)
 */
function goTo(page) {
    window.location.href = `${BASE_URL}/${page}`;
}

/**
 * Open page in new tab
 */
function openPage(page) {
    window.open(`${BASE_URL}/${page}`, "_blank");
}
```

Now you never write full URLs again.

### ✅ STEP 3 — Use It Inside Sidebar

Instead of this:

```
<a href="https://dyoqxkx8bd8d7.cloudfront.net/cafe-admin-dashboard.html">
```

Use this:

```
<a href="#" onclick="goTo('cafe-admin-dashboard.html')">
```

OR even better (cleaner):

```
<a href="cafe-admin-dashboard.html">
```

Because when using CloudFront, relative paths are better than absolute URLs.

### 🔥 BEST SOLUTION (You Probably Don’t Need CloudFront URL At All)

If ALL your frontend files are inside the SAME CloudFront distribution:

You don’t need this:

```
https://dyoqxkx8bd8d7.cloudfront.net/
```

You can simply use:

```
<a href="cafe-admin-dashboard.html">
```

or

```
window.location.href = "cafe-admin-dashboard.html";
```

Because the browser already knows the base domain.

Example:

If user is on:

```
https://dyoqxkx8bd8d7.cloudfront.net/login.html
```

And you do:

```
window.location.href = "cafe-admin-dashboard.html";
```

It automatically becomes:

```
https://dyoqxkx8bd8d7.cloudfront.net/cafe-admin-dashboard.html
```

No need to hardcode domain at all.

### 🧠 When Do You Actually Need CLOUDFRONT_BASE?

You only need full URL when:

- Redirecting from external domain

- Building OAuth redirect URI

- Calling API on another domain

- Generating absolute share links

- For internal navigation → ALWAYS use relative paths.

### ✅ FOR PHP FILES

Inside PHP:

Instead of:

```
header("Location: https://dyoqxkx8bd8d7.cloudfront.net/cafe-admin-dashboard.html");
```

Use:

```
header("Location: cafe-admin-dashboard.html");
exit();
```

If PHP runs on same domain.

### 🏆 PROFESSIONAL STRUCTURE (Recommended for You)

Since you're building Charlie Café production app, best structure is:

#### ✅ For navigation inside frontend:

Use relative links only

```
href="analytics.html"
href="orders.html"
href="cafe-admin-dashboard.html"
```

#### ✅ For API calls:

Use:

```
CHARLIE_CONFIG.API_BASE
```

#### ✅ For Cognito:

Use:

```
CHARLIE_CONFIG.COGNITO_DOMAIN
```

#### ✅ For CloudFront base (only when required):

Use:

```
CHARLIE_CONFIG.CLOUDFRONT_BASE
```

### 🚨 WHY YOUR CURRENT PROBLEM HAPPENS

Because you are mixing:

- Hardcoded absolute URLs

- Config-based URLs

- Relative URLs

That creates maintenance nightmare.

### 🎯 FINAL ANSWER FOR YOU

If all files are inside same CloudFront distribution:

👉 Stop using:

```
https://dyoqxkx8bd8d7.cloudfront.net/
```

👉 Just use:

```
cafe-admin-dashboard.html
```

And your problem disappears completely.

Since you're transitioning into front-end architecture (as you mentioned before), this is an important concept:

Absolute URL = external resources
Relative URL = internal navigation

###  utils.js

Perfect 👌 I will merge your existing JWT utilities + professional navigation helper into one clean, production-ready utils.js.

This version:

✔ Keeps your JWT parsing
✔ Keeps token expiry check
✔ Keeps token getter
✔ Adds centralized navigation helper
✔ Safely handles missing config.js
✔ Avoids global pollution
✔ Production-ready structure

### ✅ FULLY FINAL utils.js (With Navigation + JWT Utilities)

Replace your entire utils.js with this:

```
/* =========================================================
   CHARLIE CAFE — GLOBAL UTILITIES
   ---------------------------------------------------------
   ✔ JWT Parsing
   ✔ Token Expiry Check
   ✔ LocalStorage Token Helper
   ✔ Centralized Navigation Helper
   ✔ Safe Base URL Handling
========================================================= */

window.CHARLIE_UTILS = (() => {

    /* =====================================================
       🔐 JWT PARSER
       -----------------------------------------------------
       Decodes JWT payload (Base64)
    ===================================================== */
    function parseJwt(token) {
        try {
            if (!token) return {};
            return JSON.parse(atob(token.split(".")[1]));
        } catch (error) {
            console.error("Invalid JWT token:", error);
            return {};
        }
    }

    /* =====================================================
       ⏳ TOKEN EXPIRY CHECK
       -----------------------------------------------------
       Returns true if token is expired
    ===================================================== */
    function isTokenExpired(token) {
        try {
            const payload = parseJwt(token);
            if (!payload.exp) return true;

            return payload.exp * 1000 < Date.now();
        } catch (error) {
            console.error("Token expiry check failed:", error);
            return true;
        }
    }

    /* =====================================================
       💾 TOKEN STORAGE HELPERS
    ===================================================== */

    // Get stored access token
    function getToken() {
        return localStorage.getItem("access_token");
    }

    // Set access token
    function setToken(token) {
        localStorage.setItem("access_token", token);
    }

    // Remove token (logout helper)
    function clearToken() {
        localStorage.removeItem("access_token");
    }

    /* =====================================================
       🌍 BASE URL DETECTION
       -----------------------------------------------------
       Uses config.js if available
       Falls back to current origin if not
    ===================================================== */
    function getBaseUrl() {
        if (window.CHARLIE_CONFIG && window.CHARLIE_CONFIG.CLOUDFRONT_BASE) {
            return window.CHARLIE_CONFIG.CLOUDFRONT_BASE;
        }

        // Fallback: current domain (best for same-origin apps)
        return window.location.origin;
    }

    /* =====================================================
       🚀 NAVIGATION HELPERS
       -----------------------------------------------------
       Centralized routing to avoid hardcoded URLs
    ===================================================== */

    /**
     * Redirect to page in same tab
     * Example: goTo('cafe-admin-dashboard.html')
     */
    function goTo(page) {
        if (!page) return;
        window.location.href = `${getBaseUrl()}/${page}`;
    }

    /**
     * Open page in new browser tab
     */
    function openPage(page) {
        if (!page) return;
        window.open(`${getBaseUrl()}/${page}`, "_blank");
    }

    /**
     * Reload current page
     */
    function reload() {
        window.location.reload();
    }

    /* =====================================================
       📦 PUBLIC METHODS
    ===================================================== */
    return {
        parseJwt,
        isTokenExpired,
        getToken,
        setToken,
        clearToken,
        goTo,
        openPage,
        reload
    };

})();
```

### ✅ HOW TO USE NOW (Everywhere)

Instead of this ❌

```
window.location.href = "https://dyoqxkx8bd8d7.cloudfront.net/cafe-admin-dashboard.html";
```

Use this ✅

```
CHARLIE_UTILS.goTo("cafe-admin-dashboard.html");
```

### ✅ Sidebar Example

```
<a href="#" onclick="CHARLIE_UTILS.goTo('analytics.html')">
    Analytics
</a>
```

### 🧠 Why This Is Advanced & Clean

✔ No more hardcoded CloudFront URLs
✔ Only edit config.js if domain changes
✔ Works even if config.js fails (fallback to current origin)
✔ Centralized routing logic
✔ Cleaner architecture

----
### Simple Base URL Centralication 

### ✅ 1️⃣ Keep a Central config.js

Make sure your config.js lives in /var/www/html/js/config.js:

```
/* =========================================================
   CHARLIE CAFE — GLOBAL CONFIGURATION
========================================================= */
window.CHARLIE_CONFIG = {
    CLOUDFRONT_BASE: "https://dyoqxkx8bd8d7.cloudfront.net",
    COGNITO_DOMAIN: "us-east-1oemwjar3t.auth.us-east-1.amazoncognito.com",
    CLIENT_ID: "42haggs0jctmq5rnaajfi3hmqu",
    API_BASE: "https://p4vrr4b60c.execute-api.us-east-1.amazonaws.com/prod",
    REGION: "us-east-1",
};
```

#### ✅ You only update this once whenever your CloudFront URL changes.

### ✅ 2️⃣ Use CLOUDFRONT_BASE Dynamically in HTML / JS

Instead of hardcoding:

```
<a href="https://dyoqxkx8bd8d7.cloudfront.net/cafe-admin-dashboard.html">Dashboard</a>
```

Do this:

```
<a id="sidebar-dashboard" href="#">Dashboard</a>

<script src="/js/config.js"></script>
<script>
document.getElementById("sidebar-dashboard").href =
    `${window.CHARLIE_CONFIG.CLOUDFRONT_BASE}/cafe-admin-dashboard.html`;
</script>
```

- No matter how many pages you have, the URL will always come from config.js.

- Easy, one-time change for CloudFront URL.

### ✅ 3️⃣ Dynamic Redirects Anywhere

If you have JS code or buttons that redirect:

```
// Old hardcoded redirect
window.location.href = "https://dyoqxkx8bd8d7.cloudfront.net/cafe-admin-dashboard.html";

// New dynamic redirect
window.location.href = `${window.CHARLIE_CONFIG.CLOUDFRONT_BASE}/cafe-admin-dashboard.html`;
```

### ✅ 4️⃣ Use it in PHP Pages

Even in PHP files, you can use a small inline JS snippet:

```
<script src="/js/config.js"></script>
<script>
let dashboardUrl = `${window.CHARLIE_CONFIG.CLOUDFRONT_BASE}/cafe-admin-dashboard.html`;
// Example redirect
document.getElementById("dashboard-btn").onclick = () => {
    window.location.href = dashboardUrl;
};
</script>
```

- PHP only generates the HTML; the URL is always taken from config.js.

- No need to replace PHP code when CloudFront changes.

### ✅ 5️⃣ Optional: Auto-Update All Sidebar Links

If you have multiple links in the sidebar:

```
<ul id="sidebar-menu">
  <li><a data-page="cafe-admin-dashboard.html" href="#">Dashboard</a></li>
  <li><a data-page="analytics.html" href="#">Analytics</a></li>
  <li><a data-page="orders.html" href="#">Orders</a></li>
</ul>

<script src="/js/config.js"></script>
<script>
document.querySelectorAll("#sidebar-menu a").forEach(link => {
    const page = link.dataset.page;
    if (page) {
        link.href = `${window.CHARLIE_CONFIG.CLOUDFRONT_BASE}/${page}`;
    }
});
</script>
```

- Now all sidebar links automatically use the current CloudFront base URL.

- If the CloudFront URL changes, just update config.js → all pages instantly updated.

### ✅ Advantages of This Approach

- One central file (config.js) for all environment URLs.

- Works for HTML, PHP, JS pages.

- No need to manually change dozens of files on deployment.

- Lightweight, no complex build system required.

- Simple and easy to maintain.

Good 👌 now I’ll explain this in very practical Charlie Café way, based on your setup:

- All files in:
/var/www/html/

- JS files in:
/var/www/html/js/

- You already load:

```
<script src="/js/config.js"></script>
<script src="/js/utils.js"></script>
<script src="/js/api.js"></script>
<script src="/js/central-auth.js"></script>
```

You want:

❌ No more hardcoding CloudFront URL

❌ No editing 20 files when URL changes

✅ Only update config.js once

### 🟢 BEST & SIMPLEST METHOD (Professional + Clean)

Instead of manually writing JS in every page like:

```
document.getElementById("sidebar-dashboard").href = ...
```

We will create ONE small reusable JS file that automatically updates links on ALL pages.

### ✅ STEP 1 — Update Your HTML Links (Very Important)

Instead of:

```
<a href="https://dyoqxkx8bd8d7.cloudfront.net/cafe-admin-dashboard.html">
  Dashboard
</a>
```

Change to this format:

```
<a data-page="cafe-admin-dashboard.html" href="#">
  Dashboard
</a>
```

For multiple links:

```
<ul id="sidebar-menu">
  <li><a data-page="cafe-admin-dashboard.html" href="#">Dashboard</a></li>
  <li><a data-page="analytics.html" href="#">Analytics</a></li>
  <li><a data-page="orders.html" href="#">Orders</a></li>
</ul>
```

### 🚨 Important:

- Remove full URL

- Use only file name in data-page

- Do this once in your sidebar template.

### ✅ STEP 2 — Create One Small File

Create new file:

```
/var/www/html/js/link-builder.js
```

Put this inside:

```
/* =========================================================
   CHARLIE CAFE — Automatic CloudFront Link Builder
   This script updates ALL links that have data-page attribute
   ========================================================= */

document.addEventListener("DOMContentLoaded", function () {

    if (!window.CHARLIE_CONFIG || !window.CHARLIE_CONFIG.CLOUDFRONT_BASE) {
        console.error("CLOUDFRONT_BASE not found in config.js");
        return;
    }

    const base = window.CHARLIE_CONFIG.CLOUDFRONT_BASE;

    // Select all elements that have data-page attribute
    document.querySelectorAll("[data-page]").forEach(function (element) {

        const page = element.getAttribute("data-page");

        if (page) {
            element.href = base + "/" + page;
        }

    });

});
```

That’s it. Nothing complex.

### ✅ STEP 3 — Load It On All Pages

At bottom of every page (after config.js):

```
<script src="/js/config.js"></script>
<script src="/js/link-builder.js"></script>
```

That’s all.

### 🔥 WHAT HAPPENS NOW?

If your config.js contains:

```
CLOUDFRONT_BASE: "https://dyoqxkx8bd8d7.cloudfront.net"
```

Then this:

```
<a data-page="orders.html">
```

Automatically becomes:

```
https://dyoqxkx8bd8d7.cloudfront.net/orders.html
```

If tomorrow you change CloudFront to:

```
https://newcloudfront123.cloudfront.net
```

You ONLY update:

```
config.js
```

Everything updates automatically.

### ✅ Dynamic Redirect Anywhere (Same Concept)

Instead of hardcoding:

```
window.location.href = "https://dyoqxkx8bd8d7.cloudfront.net/cafe-admin-dashboard.html";
```

Use:

```
window.location.href =
    window.CHARLIE_CONFIG.CLOUDFRONT_BASE + "/cafe-admin-dashboard.html";
```

#### Works in:

- HTML pages

- PHP pages

- JS files

- Button clicks

- Logout redirects

### ✅ PHP Example (Very Simple)

Inside your PHP page:

```
<script src="/js/config.js"></script>
<script src="/js/link-builder.js"></script>
```

And use:

```
<a data-page="cafe-admin-dashboard.html">Dashboard</a>
```

No PHP editing required when URL changes.

### 🚀 BIG BENEFIT of "One Small JS Snippet"

Without this system:

If CloudFront changes:

- You edit 15 HTML files

- 8 JS files

- 4 PHP files

- Risk of missing one

- Production errors

With this system:

You edit:

Only config.js

That’s it.

### 🧠 Even Better (Advanced Tip for You)

Since you’re moving toward professional frontend development:

You can later:

- Move sidebar into one reusable component

- Load sidebar via JS include

- Make your project modular

- Turn it into SPA-style app

But for now, this solution is:

✔ Simple
✔ Clean
✔ Production safe
✔ No framework required
✔ Works with EC2 + CloudFront
✔ No complex scripting

---
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

### 🔥 What Happens Now?

If config.js has:

```
CLOUDFRONT_BASE: "https://dyoqxkx8bd8d7.cloudfront.net"
```

Then:

```
<a data-page="orders.html">
```

Automatically becomes:

```
https://dyoqxkx8bd8d7.cloudfront.net/orders.html
```

If tomorrow CloudFront changes:

You update ONLY:

```
config.js
```

Everything updates automatically across all pages.

### 🧠 Professional Architecture You Just Built

You now have:

- config.js → environment config

- utils.js → reusable helpers + global logic

- central-auth.js → authentication

- api.js → API calls

This is clean modular frontend structure — very good for someone transitioning into front-end development 👏

### ⚡ BONUS (Even Cleaner Redirect Usage)

Anywhere in your code:

```
window.location.href =
    window.CHARLIE_CONFIG.CLOUDFRONT_BASE + "/cafe-admin-dashboard.html";
```

OR cleaner:

```
function goTo(page) {
    window.location.href =
        window.CHARLIE_CONFIG.CLOUDFRONT_BASE + "/" + page;
}

goTo("orders.html");
```

If you want next, I can show you something even better:

👉 How to completely remove CloudFront base and use relative paths so you NEVER need CloudFront URL in frontend again.

That is actually the most professional solution.
---
# Charlie Cafe - Base URL Centralization

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

----
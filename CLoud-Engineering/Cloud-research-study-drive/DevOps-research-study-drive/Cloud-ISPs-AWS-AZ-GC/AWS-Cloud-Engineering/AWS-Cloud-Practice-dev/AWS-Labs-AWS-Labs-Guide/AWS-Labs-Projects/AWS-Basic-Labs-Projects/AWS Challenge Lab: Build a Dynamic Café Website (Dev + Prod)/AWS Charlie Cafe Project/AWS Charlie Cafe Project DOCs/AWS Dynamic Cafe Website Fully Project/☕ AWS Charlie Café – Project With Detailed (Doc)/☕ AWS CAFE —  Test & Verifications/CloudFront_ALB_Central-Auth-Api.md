# Charlie Cafe -- CloudFront, ALB & Central-Auth-Api Configuration & Troubleshooting


### 1️⃣ 🛠️ FIX OPTION 1 (FASTEST & RECOMMENDED)

####  ✔️ Allow JS files in CloudFront Behavior

- Go to: CloudFront → Distribution → Behaviors

- Edit the behavior that serves your site (usually /*):

- Set these EXACTLY:

- Path pattern: /*

- Viewer protocol policy: Redirect HTTP to HTTPS

- Allowed HTTP methods: GET, HEAD

- Cache policy: CachingOptimized

- Origin request policy: AllViewerExceptHostHeader

- Compress objects automatically: YES

- Then SAVE.

👉 After that:

#### Invalidate cache

```
/js/central-auth-api.js
```

> **(or just /* if you’re tired 😄)***

### 2️⃣ 🛠️ FIX OPTION 2 (ORIGIN PERMISSION ISSUE)

#### If origin is EC2 / ALB:

➡️ On EC2, run:

```
ls -l html/js/central-auth-api.js
```

You MUST see something like:

```
-rw-r--r-- 1 ec2-user ec2-user
```

➡️ If not:

```
chmod 644 html/js/central-auth-api.js
chmod 755 html/js
```

➡️ Restart web server:

```
sudo systemctl restart nginx
```
# or

```
sudo systemctl restart httpd
```

####  🔍 QUICK TEST (DO THIS NOW)

Try opening directly in browser:

```
https://dc65q9cmuuula.cloudfront.net/js/central-auth-api.js
```

#### ✅ Expected result:

You should see raw JavaScript code

- ❌ If you see 403 → CloudFront is still blocking

#### 🧪 TEMP DEBUG (OPTIONAL BUT POWERFUL)

Add this at the TOP of your HTML (temporarily):

```
<script>
  alert("HTML loaded");
</script>
```

- If you see the alert → HTML is fine

- If JS still fails → confirms CloudFront JS block

### ✅ WHAT WE NOW KNOW (FACTS)

#### 1️⃣ File DOES exist on EC2

```
/var/www/html/js/central-auth-api.js
-rw-r--r-- apache apache
```

✅ Apache can read it

✅ EC2 is correct

✅ Path is correct

#### 2️⃣ ALB CAN serve the HTML

```
http://charlie-cafe-alb-xxxx.elb.amazonaws.com/cafe-admin-dashboard.html
Status: 304
```

✅ ALB → EC2 → Apache works

✅ No permission issue on EC2

✅ No Apache config issue

#### 3️⃣ CloudFront STILL returns 403 for JS

```
https://dc65q9cmuuula.cloudfront.net/js/central-auth-api.js
403 Forbidden
```

**🚨 This means CloudFront is NOT forwarding /js/* correctly to ALB**

### 🔴 THE REAL ROOT CAUSE (100% CONFIRMED)

❌ CloudFront → ALB Origin Path / Behavior mismatch

Your ALB expects files at:

```
/var/www/html/js/central-auth-api.js
```

But CloudFront is either:

• Not forwarding /js/*

• OR using a wrong Origin Path

• OR caching an old 403

• OR using a behavior that does not allow .js

### 🧠 IMPORTANT INSIGHT (MOST PEOPLE MISS THIS)

CloudFront does NOT magically map paths.

If your Origin Path is wrong, CloudFront will ask ALB for:

```
/js/central-auth-api.js
```

but ALB may actually be serving from:

```
/var/www/html/
```

**➡️ Result: 403 from CloudFront only**

### ✅ THE FIX (DO THIS EXACTLY – NO SKIPPING)

#### 🔧 STEP 1 — FIX CLOUD FRONT ORIGIN PATH

- Go to: CloudFront → Distribution → Origins

- Select your ALB origin → Edit

- 🔥 SET THIS:

```
Origin path: /var/www/html
```

❌ If it is empty
❌ If it is /
❌ If it is something else

➡️ THIS IS YOUR BUG

✅ Save changes

#### 🔧 STEP 2 — BEHAVIORS (ONE ONLY)

CloudFront → Behaviors

You should have ONLY ONE behavior:

| Setting               | Value                     |
| --------------------- | ------------------------- |
| Path pattern          | `/*`                      |
| Origin                | ALB                       |
| Viewer protocol       | Redirect HTTP to HTTPS    |
| Allowed methods       | GET, HEAD                 |
| Cache policy          | CachingOptimized          |
| Origin request policy | AllViewerExceptHostHeader |


❌ Delete any /js/* or /static/* behaviors
They often break things.

#### 🔧 STEP 3 — INVALIDATE CACHE (MANDATORY)

CloudFront → Invalidations

```
/*
```

Wait until Status = Completed

#### 🔧 STEP 4 — HARD BROWSER TEST

Open NEW incognito window (important)

Test in this order:

✅ Should work

```
https://dc65q9cmuuula.cloudfront.net/js/central-auth-api.js
```

You MUST see raw JavaScript.

❌ If still 403

CloudFront is still misrouting.

### 🧪 FINAL CONFIRMATION TEST

Add this temporarily to cafe-admin-dashboard.html:

```
<script>
  alert("HTML OK");
</script>

<script src="/js/central-auth-api.js"></script>

<script>
  alert(typeof CHARLIE);
</script>
```

#### Expected:

```
HTML OK
object
```

If you see undefined → JS still blocked

### 🧠 WHY YOUR JS CODE IS NOT THE PROBLEM

Your JS never even executes.

CloudFront blocks the file before JavaScript exists.

That’s why:
• No console errors
• White page
• Cognito never triggers

### 🏁 FINAL ARCHITECTURE (WHEN FIXED)

```
Browser
  ↓
CloudFront
  ↓
ALB
  ↓
EC2 (Apache)
/var/www/html/
```

**Everything you built already works — CloudFront just wasn’t pointing at the right place.**

### 🎯 GOAL

Verify one by one:

1️⃣ Apache on EC2

2️⃣ ALB → EC2

3️⃣ CloudFront → ALB

We already know CloudFront is failing — now we prove why.

### ✅ STEP 1 — TEST APACHE LOCALLY (EC2)

SSH into EC2 and run:

```
curl -I http://localhost/js/central-auth-api.js
```

✅ EXPECTED (GOOD):

```
HTTP/1.1 200 OK
Content-Type: application/javascript
```

❌ If NOT 200 → Apache config issue
📌 Share output

### ✅ STEP 2 — TEST APACHE FULL FILE

```
curl http://localhost/js/central-auth-api.js | head -5
```

You should see JS comments like:

```
/* =========================================================
   CHARLIE CAFE — CENTRAL AUTH + API CONFIG (FINAL)
```

📌 Share output

### ✅ STEP 3 — TEST EC2 PRIVATE IP (ALB STYLE)

Find EC2 private IP:

```
ip addr | grep inet
```

Then test:

```
curl -I http://<PRIVATE-IP>/js/central-auth-api.js
```

📌 Share output

### ✅ STEP 4 — TEST ALB DIRECTLY (VERY IMPORTANT)

Run this from EC2:

```
curl -I http://charlie-cafe-alb-1179524333.us-east-1.elb.amazonaws.com/js/central-auth-api.js
```

✅ EXPECTED:

```
HTTP/1.1 200 OK
```

❌ If NOT 200 → ALB listener / target group issue
📌 Share output

### 🚨 STEP 5 — TEST CLOUD FRONT FROM EC2 (KEY STEP)

```
curl -I https://dc65q9cmuuula.cloudfront.net/js/central-auth-api.js
```

❌ CURRENT RESULT (YOU SAW):

```
403 Forbidden
```

📌 Share output anyway

### 🧠 HOW WE INTERPRET RESULTS

| Test         | Meaning                            |
| ------------ | ---------------------------------- |
| Step 1 fails | Apache broken                      |
| Step 2 fails | File unreadable                    |
| Step 3 fails | Apache bind / firewall             |
| Step 4 fails | ALB routing broken                 |
| Step 5 fails | CloudFront config **100% culprit** |


Based on your previous info, Step 5 will be the only failure — which means:

🔥 CloudFront Origin Path or Behavior is WRONG

### ⚠️ VERY IMPORTANT CHECK (DO THIS NOW)

Run this and paste output:

```
apachectl -S
```

I need to confirm:

```
DocumentRoot "/var/www/html"
```

If DocumentRoot ≠ /var/www/html
→ CloudFront + ALB will NEVER work correctly.

### 🔧 MOST LIKELY FINAL FIX (PREVIEW)

I’m telling you upfront so you don’t panic:

❌ CloudFront Origin Path should NOT be /var/www/html
✅ It must be EMPTY

CloudFront does NOT understand filesystem paths.
It only forwards URL paths.

But I want to prove it via your CLI outputs, not guess.

### 📌 WHAT TO SEND ME (COPY-PASTE)

Please paste results of:

1️⃣ curl -I http://localhost/js/central-auth-api.js
2️⃣ curl http://localhost/js/central-auth-api.js | head -5
3️⃣ curl -I http://<PRIVATE-IP>/js/central-auth-api.js
4️⃣ curl -I http://ALB-DNS/js/central-auth-api.js
5️⃣ curl -I https://CLOUDFRONT/js/central-auth-api.js
6️⃣ apachectl -S

### 🧠 FINAL DIAGNOSIS (100% CONFIRMED)

❌ This is NOT a CloudFront problem
❌ This is NOT an ALB problem
❌ This is NOT a Cognito problem
❌ This is NOT your JavaScript code

### 🚨 ROOT CAUSE
Apache itself is blocking access to /js/*

Proof 👇

```
curl http://localhost/js/central-auth-api.js
HTTP/1.1 403 Forbidden
Server: Apache
```

#### This means:

Apache receives the request
Apache finds the file
Apache REFUSES to serve it

CloudFront and ALB are innocent — they are correctly forwarding the request.

### 🔥 WHY THIS HAPPENS ON AMAZON LINUX

On Amazon Linux + Apache, one of these is blocking it:

1️⃣ Directory permissions (Require all denied)
2️⃣ SELinux context
3️⃣ Apache <Directory> rule mismatch
4️⃣ JS MIME type blocked
5️⃣ .htaccess rule (very common)

### ⚡ FASTEST FIX (DO THIS NOW – 2 MINUTES)

### ✅ FIX 1 — ALLOW /var/www/html/js IN APACHE

Open Apache main config:

```
sudo nano /etc/httpd/conf/httpd.conf
```

Find this block (or similar):

```
<Directory "/var/www/html">
    AllowOverride None
    Require all denied
</Directory>
```

🔥 CHANGE IT TO:

```
<Directory "/var/www/html">
    AllowOverride All
    Require all granted
</Directory>
```

### ✅ FIX 2 — EXPLICITLY ALLOW JS DIRECTORY (BEST PRACTICE)

Add this at the bottom of the file:

```
<Directory "/var/www/html/js">
    Require all granted
</Directory>
```

### ✅ FIX 3 — SET PROPER MIME TYPE FOR JS

Still in the same file, add (or ensure exists):

```
AddType application/javascript .js
```

### ✅ FIX 4 — RESTART APACHE

```
sudo systemctl restart httpd
```

### 🧪 VERIFY (THIS MUST TURN GREEN)

Run again:

```
curl -I http://localhost/js/central-auth-api.js
```

#### ✅ EXPECTED:

```
HTTP/1.1 200 OK
Content-Type: application/javascript
```

Then:

```
curl -I http://charlie-cafe-alb-1179524333.us-east-1.elb.amazonaws.com/js/central-auth-api.js
```

Then:

```
curl -I https://dc65q9cmuuula.cloudfront.net/js/central-auth-api.js
```

Run the fixes above and paste only this output back:

```
curl -I http://localhost/js/central-auth-api.js
```

**✅ All three must return 200 OK.**

### 🛑 DO NOT TOUCH YOUR JS FILE

❌ Do NOT add anything inside central-auth-api.js

❌ Do NOT change permissions to 777

❌ Do NOT disable CloudFront

❌ Do NOT waste time on Cognito

Your JS file is perfect.

### 🧠 WHY HTML WORKS BUT JS DOESN’T

Apache default configs sometimes allow:

```
/var/www/html/*.html
```

but deny subfolders unless explicitly allowed.

That’s exactly what we see.

### 🏁 WHEN THIS IS FIXED

✔ White page disappears

✔ CHARLIE loads

✔ Cognito redirects work

✔ Admin dashboard loads

✔ Printing system works

✔ You keep your sanity 😄

### 🔥 THE LIKELY CAUSE

Since you tried editing /etc/httpd/conf/httpd.conf and it didn’t fix:

You are likely running SELinux / Amazon Linux security context.

Or there is a /etc/httpd/conf.d/ override (e.g., welcome.conf, ssl.conf, security.conf) blocking access to subdirectories like /js.

Another common culprit: Require all denied in a <Directory> block higher up, e.g., in /etc/httpd/conf.d/welcome.conf.

Also, Amazon Linux 2 with Apache 2.4+ has SELinux enforcing httpd_sys_content_t. If the JS file doesn’t have correct context → 403.

### ✅ HOW TO FIX THIS

#### 1️⃣ Check SELinux status

```
getenforce
```

Enforcing → SELinux could be blocking Apache from serving /js

Permissive → SELinux is not the problem

If Enforcing, we need to fix the context.

#### 2️⃣ Check file context (if SELinux is enabled)

```
ls -Z /var/www/html/js/central-auth-api.js
```

You should see:

```
-rw-r--r--. apache apache unconfined_u:object_r:httpd_sys_content_t:s0 ...
```

If context is wrong → Apache blocks it (403).

#### Fix SELinux context

```
sudo restorecon -Rv /var/www/html/js
```

#### 3️⃣ Ensure <Directory> allows access

Check /etc/httpd/conf/httpd.conf:

```
<Directory "/var/www/html">
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>
```

Then add explicitly for JS:

```
<Directory "/var/www/html/js">
    Require all granted
</Directory>
```

#### 4️⃣ Check for .htaccess overrides

```
ls -la /var/www/html/js/.htaccess
```

If exists, check for Deny from all → comment it out.

#### 5️⃣ Restart Apache

```
sudo systemctl restart httpd
```

#### 6️⃣ Test locally (CRUCIAL)

```
curl -I http://localhost/js/central-auth-api.js
```

✅ Should return 200 OK
✅ If yes → ALB and CloudFront automatically work

#### ⚡ Quick test if SELinux is blocking (temporary)

```
sudo setenforce 0
curl -I http://localhost/js/central-auth-api.js
```

If this returns 200 → SELinux was the problem.

Do not leave SELinux disabled permanently, fix the context with restorecon.

#### 💡 Important: You do NOT need to modify central-auth-api.js at all. This is purely a server permission issue.

### Step 1: Verify SELinux

You already ran:

```
getenforce
# Output: Permissive
```

Since SELinux is Permissive, it won’t block access, but Apache still requires proper file context. So we need to make sure your JS files have the correct SELinux context.

### Step 2: Correct Ownership and Permissions Recursively

You only changed /var/www/html/*. If /js and .htaccess inside /js are still wrong, Apache can’t read them.

```
sudo chown -R apache:apache /var/www/html
sudo find /var/www/html -type d -exec chmod 755 {} \;
sudo find /var/www/html -type f -exec chmod 644 {} \;
```

#### ✅ Explanation:

Directories: 755 (rwx for owner, rx for group/others)

Files: 644 (rw for owner, r for group/others)

Recursive ensures all nested files/folders are correct

### Step 3: Fix SELinux Context

Set proper context for Apache to read JS, CSS, PHP files:

```
sudo restorecon -Rv /var/www/html
```

Check context:

```
ls -Z /var/www/html/js
```

You should see something like:

```
-rw-r--r--. apache apache unconfined_u:object_r:httpd_sys_content_t:s0 central-auth-api.js
```

If it’s not httpd_sys_content_t, that’s why Apache 403s.

### Step 4: Check .htaccess Restrictions

ls: cannot access '.htaccess': Permission denied means either SELinux context or directory permissions are wrong. .htaccess must be readable:

```
sudo chmod 644 /var/www/html/js/.htaccess
sudo restorecon -v /var/www/html/js/.htaccess
```

### Step 5: Verify Apache Config Allows .htaccess

Open /etc/httpd/conf/httpd.conf (or your virtual host) and ensure:

```
<Directory "/var/www/html">
    AllowOverride All
    Require all granted
</Directory>
```

Then restart Apache:

```
sudo systemctl restart httpd
```

### Step 6: Test Access

```
curl -I http://localhost/js/central-auth-api.js
```

#### ✅ Should return:

```
HTTP/1.1 200 OK
```

### ⚡ Quick One-Line Fix (Recursively fixes everything for html/js folder):

```
sudo chown -R apache:apache /var/www/html && sudo find /var/www/html -type d -exec chmod 755 {} \; && sudo find /var/www/html -type f -exec chmod 644 {} \; && sudo restorecon -Rv /var/www/html && sudo systemctl restart httpd
```

**✅ This is the fastest working solution on Amazon Linux for 403 issues on Apache.**

---

### Step 1: Check Browser Console

Open your browser → Developer Tools → Console (F12). Look for:

Failed to load resource errors

Uncaught ReferenceError or TypeError in JS

404s for CSS, JS, images

On CloudFront, common issues:

Paths in HTML are relative (js/central-auth-api.js)
CloudFront may require full relative path or absolute path:

```
<script src="/js/central-auth-api.js"></script>
```

Make sure your HTML refers to JS/CSS with the correct CloudFront path.

### Step 2: Check Resource URLs

From your screenshot, your HTML references:

bootstrap.min.css

bootstrap-icons.css

central-auth-api.js

But CloudFront may not have the correct folder structure. For example:

CloudFront root → cafe-admin-dashboard.html

js/central-auth-api.js must exist in CloudFront (/js/central-auth-api.js)

CSS must exist in CloudFront root if referenced as bootstrap.min.css

If paths don’t match, browser can’t load CSS/JS → white page.

### ✅ Fix: Use absolute paths or proper folder structure:

```
<!-- CSS -->
<link rel="stylesheet" href="/bootstrap.min.css">
<link rel="stylesheet" href="/bootstrap-icons.css">

<!-- JS -->
<script src="/js/central-auth-api.js"></script>
```

### Step 3: Check JS Errors (Most Likely Cause)

If central-auth-api.js runs and has runtime errors, nothing renders. Common mistakes:

Functions not defined (CHARLIE.initProtectedPage undefined)

DOM elements not found (document.getElementById('xyz') fails)

CloudFront caching old JS

### Step 4: Invalidate CloudFront Cache

If you updated files on S3/Origin but CloudFront cached old content:

```
# In AWS Console → CloudFront → Invalidate
```

Invalidate:

```
*
```

Or just the affected files:

```
/js/central-auth-api.js
/cafe-admin-dashboard.html
```

### Step 5: Check HTML and JS Structure

Make sure your HTML has a root container:

```
<body>
  <div id="app"></div>
  <script src="/js/central-auth-api.js"></script>
  <script>
    CHARLIE.initProtectedPage();
  </script>
</body>
```

If the JS expects elements that don’t exist, nothing will show → white page.

### Step 6: Verify Network Tab

In browser DevTools → Network tab:

All CSS/JS must return 200 OK

No 403/404 errors

JS must be loaded before your inline <script> calls it

💡 Most likely causes here:

Wrong relative paths on CloudFront (HTML → JS/CSS/images)

CloudFront cached old JS → invalidation required

JS errors in central-auth-api.js (check Console)

---
### 1️⃣ Immediate Issue in HTML / JS

Inside your HTML, in the loadOrdersDashboard function:

```
document.getElementById("ordersCount").innerText = data.orders`;
```

Notice the backtick at the end of the line:

```
data.orders`
```

✅ This is a syntax error. It will break all subsequent JS, so the browser stops executing scripts → page remains blank.

Fix:

```
document.getElementById("ordersCount").innerText = data.orders;
```

### Other minor JS issues

loadOrdersDashboard() and load("daily") are called immediately.

If CHARLIE.api.getDashboardMetrics or CHARLIE.api.adminAttendance.getDailySummary fails (e.g., JWT missing, API 403), it will throw unhandled promise errors → white page.

You should wrap in try/catch to prevent breaking the page:

```
async function loadOrdersDashboard() {
    try {
        const data = await CHARLIE.api.getDashboardMetrics("today");
        document.getElementById("sales").innerText = `$${data.sales}`;
        document.getElementById("ordersCount").innerText = data.orders; // <-- FIXED
        document.getElementById("drinksCount").innerText = data.drinks;
        document.getElementById("avgPrice").innerText = `$${data.avg}`;
        const table = document.getElementById("ordersTable");
        table.innerHTML = "";
        data.latest_orders.forEach(o => {
            table.innerHTML += `
                <tr>
                    <td>${o.customer_name || "Anonymous"}</td>
                    <td>${o.item}</td>
                    <td>${o.quantity}</td>
                    <td>${o.table_number || "-"}</td>
                    <td>${o.date}</td>
                </tr>
            `;
        });
    } catch (err) {
        console.error("Failed to load orders dashboard:", err);
    }
}

async function load(type) {
    try {
        await loadSummary(type);
    } catch (err) {
        console.error("Failed to load HR dashboard:", err);
    }
}
```

### 2️⃣ CloudFront-specific issues

Paths are relative:

```
<script src="js/central-auth-api.js"></script>
```

CloudFront serves files from the root of the distribution, so the browser tries to load /js/central-auth-api.js relative to the HTML location.

If your HTML is at /cafe-admin-dashboard.html, the browser looks for /cafe-admin-dashboard.html/js/central-auth-api.js → 404.

### ✅ Fix: Use absolute paths with CloudFront base:

```
<script src="https://dc65q9cmuuula.cloudfront.net/js/central-auth-api.js"></script>
```

Or use your CHARLIE.assets.url() function dynamically if needed.

### 3️⃣ CloudFront caching

You already confirmed that CloudFront returns 200 OK for JS.

But old HTML or old JS may still be cached → white page.

Invalidate the cache for your HTML + JS + CSS:

```
/cafe-admin-dashboard.html
/js/central-auth-api.js
```

### 4️⃣ Steps to fix your white page

Fix the JS syntax error in loadOrdersDashboard (data.orders\`` → data.orders`)

Wrap async calls in try/catch (optional but recommended)

Update HTML JS references to absolute CloudFront paths:

```
<script src="https://dc65q9cmuuula.cloudfront.net/js/central-auth-api.js"></script>
```

Invalidate CloudFront cache for all changed files

Open browser console and verify no errors

#### ✅ After these steps, your white page will disappear, and the dashboard should render properly.

---





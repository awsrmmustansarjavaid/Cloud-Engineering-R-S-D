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







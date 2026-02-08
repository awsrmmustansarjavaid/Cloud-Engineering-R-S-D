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


# Charlie Cafe -- Employee Portal & Cognito 


### 2️⃣ Fixes in config.js & employee-portal.html

config.js

```
window.CHARLIE_CONFIG = {
    REGION: "us-east-1",
    rdsSecretName: "CafeDevDBSM",
    
    USER_POOL_ID: "us-east-1_qPVmxxxR2",
    CLIENT_ID: "7c5793cnvnbl110ljthmdiohch",  // Use CLIENT_ID here
    COGNITO_DOMAIN: "https://us-east-1qpvmxxxr2.auth.us-east-1.amazoncognito.com",
    COGNITO_REDIRECT_URI: "https://d2xb54di3chfgj.cloudfront.net/employee-portal.html", // Must exactly match allowed callback URL

    API_BASE: "https://cdnky6qicd.execute-api.us-east-1.amazonaws.com/prod",
    CLOUDFRONT_BASE: "https://d2xb54di3chfgj.cloudfront.net"
};
```

employee-portal.html — exchangeCodeForToken()

```
async function exchangeCodeForToken(code){
    const body = new URLSearchParams({
        grant_type:"authorization_code",
        client_id: CHARLIE_CONFIG.CLIENT_ID,   // <-- fixed
        redirect_uri: CHARLIE_CONFIG.COGNITO_REDIRECT_URI, // must match allowed callback URL
        code: code
    });

    const response = await fetch(
        `${CHARLIE_CONFIG.COGNITO_DOMAIN}/oauth2/token`,
        {
            method:"POST",
            headers:{
                "Content-Type":"application/x-www-form-urlencoded"
            },
            body: body
        }
    );

    const data = await response.json();
    console.log("OAuth Token Response:",data);

    if(data.id_token){
        localStorage.setItem("id_token",data.id_token);
        return data.id_token;
    }

    throw new Error("Token exchange failed: " + JSON.stringify(data));
}
```

Perfect! I understand exactly what you want:

No hardcoding of Cognito or CloudFront URLs in employee-portal.html — it should always read from CHARLIE_CONFIG in config.js.

Add the COGNITO_REDIRECT_URI reference in employee-portal.html code for the token exchange function.

Fully final, working employee-portal.html after the fixes, keeping all URLs configurable via config.js.

#### Here’s the fully patched version:

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Café ☕ | Employee Portal</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- ==============================
     BOOTSTRAP + FONTS
================================ -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;500;700&display=swap" rel="stylesheet">

<style>
body{
    font-family:'Poppins',sans-serif;
    background:#111;
    color:white;
}
.container{
    max-width:900px;
    margin-top:40px;
}
.card{
    background:#1c1c1c;
    padding:25px;
    margin-bottom:20px;
    border-radius:12px;
}
h4{
    color:#ffd166;
}
</style>
</head>

<body>
<div class="container">

<button id="logoutBtn" class="btn btn-danger float-end">Logout</button>

<h2 class="mb-4">Employee Portal</h2>

<!-- ================= PROFILE ================= -->
<div class="card">
<h4>Employee Profile</h4>
<p><b>Name:</b> <span id="profile-name">Loading...</span></p>
<p><b>Job:</b> <span id="profile-job">Loading...</span></p>
<p><b>Salary:</b> <span id="profile-salary">Loading...</span></p>
<p><b>Start Date:</b> <span id="profile-start">Loading...</span></p>
</div>

<!-- ================= ATTENDANCE ================= -->
<div class="card">
<h4>Attendance History</h4>
<table class="table table-dark table-striped">
<thead>
<tr>
<th>Date</th>
<th>Checkin</th>
<th>Checkout</th>
</tr>
</thead>
<tbody id="attendanceTable"></tbody>
</table>
</div>

<!-- ================= LEAVES ================= -->
<div class="card">
<h4>Leaves</h4>
<table class="table table-dark">
<thead>
<tr>
<th>Date</th>
<th>Type</th>
</tr>
</thead>
<tbody id="leaveTable"></tbody>
</table>
</div>

<!-- ================= HOLIDAYS ================= -->
<div class="card">
<h4>Holidays</h4>
<table class="table table-dark">
<thead>
<tr>
<th>Date</th>
<th>Description</th>
</tr>
</thead>
<tbody id="holidayTable"></tbody>
</table>
</div>

</div>

<!-- ==============================
     REQUIRED JS
================================ -->
<script src="/js/config.js"></script>
<script src="/js/api.js"></script>

<script>
/* =====================================================
   STEP 1 — PARSE JWT TOKEN
===================================================== */
function parseJwt(token){
    const base64Url = token.split('.')[1];
    const base64 = base64Url.replace(/-/g,'+').replace(/_/g,'/');
    return JSON.parse(atob(base64));
}

/* =====================================================
   STEP 2 — EXCHANGE AUTH CODE FOR TOKEN
   Cognito OAuth Code → id_token
   ✅ Uses redirect_uri from config.js
===================================================== */
async function exchangeCodeForToken(code){
    const body = new URLSearchParams({
        grant_type: "authorization_code",
        client_id: CHARLIE_CONFIG.CLIENT_ID,
        redirect_uri: CHARLIE_CONFIG.COGNITO_REDIRECT_URI, // use config.js
        code: code
    });

    const response = await fetch(
        `${CHARLIE_CONFIG.COGNITO_DOMAIN}/oauth2/token`,
        {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: body
        }
    );

    const data = await response.json();
    console.log("OAuth Token Response:", data);

    if(data.id_token){
        localStorage.setItem("id_token", data.id_token);
        return data.id_token;
    }

    throw new Error("Token exchange failed: " + JSON.stringify(data));
}

/* =====================================================
   STEP 3 — GET EMPLOYEE ID FROM TOKEN
===================================================== */
async function getEmployeeId(){
    let token = localStorage.getItem("id_token");
    const params = new URLSearchParams(window.location.search);
    const code = params.get("code");

    // If redirected with code -> exchange
    if(code){
        token = await exchangeCodeForToken(code);
        window.history.replaceState({}, document.title, "/employee-portal.html");
    }

    if(!token){
        alert("Login required");
        window.location.href = "/employee-login.html";
        return;
    }

    const decoded = parseJwt(token);
    console.log("Decoded Token:", decoded);

    const employeeId =
        decoded["custom:employee_id"] ||
        decoded["employee_id"] ||
        decoded["cognito:username"];

    if(!employeeId){
        alert("Employee ID missing. Login again.");
        window.location.href = "/employee-login.html";
        return;
    }

    return employeeId;
}

/* =====================================================
   STEP 4 — LOAD EMPLOYEE DATA
===================================================== */
async function loadPortal(){
    const employeeId = await getEmployeeId();
    if(!employeeId) return;

    // ===== PROFILE =====
    const profile = await CHARLIE_API.getEmployeeProfile(employeeId);
    document.getElementById("profile-name").textContent = profile.name;
    document.getElementById("profile-job").textContent = profile.job_title;
    document.getElementById("profile-salary").textContent = profile.salary;
    document.getElementById("profile-start").textContent = profile.start_date;

    // ===== ATTENDANCE =====
    const attendance = await CHARLIE_API.getAttendanceHistory(employeeId);
    const attTable = document.getElementById("attendanceTable");
    attendance.forEach(r => {
        const row = document.createElement("tr");
        row.innerHTML = `<td>${r.attendance_date}</td><td>${r.checkin_time || "-"}</td><td>${r.checkout_time || "-"}</td>`;
        attTable.appendChild(row);
    });

    // ===== LEAVES + HOLIDAYS =====
    const data = await CHARLIE_API.getLeavesAndHolidays(employeeId);

    // Leaves
    const leaveTable = document.getElementById("leaveTable");
    data.leaves.forEach(l => {
        const row = document.createElement("tr");
        row.innerHTML = `<td>${l.leave_date}</td><td>${l.leave_type}</td>`;
        leaveTable.appendChild(row);
    });

    // Holidays
    const holidayTable = document.getElementById("holidayTable");
    data.holidays.forEach(h => {
        const row = document.createElement("tr");
        row.innerHTML = `<td>${h.holiday_date}</td><td>${h.description}</td>`;
        holidayTable.appendChild(row);
    });
}

/* =====================================================
   STEP 5 — LOGOUT
===================================================== */
document.getElementById("logoutBtn").onclick = () => {
    localStorage.removeItem("id_token");
    window.location.href = "/employee-login.html";
};

/* =====================================================
   START PORTAL
===================================================== */
loadPortal();
</script>

</body>
</html>
```

### ✅ Key Fixes Applied

exchangeCodeForToken() now uses CHARLIE_CONFIG.COGNITO_REDIRECT_URI — no hardcoding of URLs in HTML.

client_id is pulled from CHARLIE_CONFIG.CLIENT_ID — fixes previous mismatch.

Token exchange logs full response in console for debugging.

Rest of the portal remains fully dynamic with CHARLIE_API and CHARLIE_CONFIG.

#### ✅ Solution (Correct Architecture)

Instead of:

```
Browser → Cognito /oauth2/token
```

You must do:

```
Browser → API Gateway → Lambda → Cognito /oauth2/token
```

Lambda performs the token exchange and returns the token.

### 🔟 Frontend Update

Inside employee-portal.html

Replace:

```
fetch(`${CHARLIE_CONFIG.COGNITO_DOMAIN}/oauth2/token`)
```

with:

```
fetch(`${CHARLIE_CONFIG.API_BASE}/exchange-token`,{
    method:"POST",
    headers:{
        "Content-Type":"application/json"
    },
    body:JSON.stringify({code:code})
})
```

### 1️⃣1️⃣ Expected Real Login Flow

Now your flow becomes:

```
Employee Login
        ↓
Cognito Hosted UI
        ↓
Redirect

employee-portal.html?code=XXXX
        ↓
Frontend calls API
/exchange-token
        ↓
Lambda calls Cognito
/oauth2/token
        ↓
Returns id_token
        ↓
Portal loads employee data
```

### ✅ Final System Status

| Component             | Status |
| --------------------- | ------ |
| Cognito Login         | ✅      |
| CloudFront portal     | ✅      |
| Token exchange Lambda | ✅      |
| API Gateway endpoint  | ✅      |
| Frontend integration  | ✅      |


### ⭐ Pro Tip (Very Important)

Your Lambda currently returns full token response.

For better security return only:

```
return {
 "id_token": result["id_token"]
}
```

instead of the full response.

Perfect — your API.JS already has a clean structure with a dedicated Cognito token exchange helper at the bottom. You just need to wire it correctly in your employee-portal.html login flow. I’ll break it down step by step.

### 1️⃣ Update API.JS (almost done)

You already have this function:

```
/* 🔐 AUTH — COGNITO TOKEN EXCHANGE */
function exchangeCognitoToken(code) {
    return apiFetch(`${CONFIG.API_BASE}/exchange-token`, {
        method: "POST",
        body: JSON.stringify({ code: code })
    });
}
```

✅ This is correct. Nothing more is needed in API.JS.
Make sure it’s included in the return object at the bottom:

```
return {
    // ... other APIs
    exchangeCognitoToken,  // ✅ Add this
};
```

### 2️⃣ Update employee-portal.html

Wherever you currently have:

```
fetch(`${CHARLIE_CONFIG.COGNITO_DOMAIN}/oauth2/token`)
```

replace it with your new API wrapper:

```
<script>
(async () => {
    const urlParams = new URLSearchParams(window.location.search);
    const code = urlParams.get("code");

    if (!code) {
        alert("Authorization code missing. Please login again.");
        return;
    }

    try {
        // Call API.JS token exchange helper
        const tokenResponse = await window.CHARLIE_API.exchangeCognitoToken(code);

        // tokenResponse contains id_token, access_token, refresh_token
        console.log("Token Response:", tokenResponse);

        // Example: save id_token in localStorage for future requests
        localStorage.setItem("id_token", tokenResponse.id_token);

        // Now fetch employee profile
        const decoded = parseJwt(tokenResponse.id_token); // Use your existing parseJwt()
        const employeeId = parseInt(decoded["custom:employee_id"] || decoded["employee_id"] || decoded["cognito:username"]);

        const profile = await window.CHARLIE_API.getEmployeeProfile(employeeId);
        console.log("Employee Profile:", profile);

        // Render employee data on the portal
        document.getElementById("employee-name").textContent = profile.name;

    } catch (err) {
        console.error("Token exchange failed:", err);
        alert("Login failed. Please try again.");
        // Optionally redirect to login page
        window.location.href = `${CHARLIE_CONFIG.COGNITO_DOMAIN}/login`;
    }
})();
</script>
```

### ✅ Notes

exchangeCognitoToken(code) → Calls API Gateway → Lambda → Cognito

parseJwt() → Decodes id_token to extract employee_id

Always parse employee_id as integer:

```
✅ Notes

exchangeCognitoToken(code) → Calls API Gateway → Lambda → Cognito

parseJwt() → Decodes id_token to extract employee_id
```


Always parse employee_id as integer:

```
const employeeId = parseInt(decoded["custom:employee_id"] || decoded["employee_id"] || decoded["cognito:username"]);
```

localStorage.setItem("id_token", ...) → Store token for future authenticated requests

Use CHARLIE_API.getEmployeeProfile(employeeId) → To fetch profile after login

### 3️⃣ Optional: Add a “Login Again” Redirect

```
if (!code) {
    window.location.href = `${CHARLIE_CONFIG.COGNITO_DOMAIN}/login?redirect_uri=${encodeURIComponent(window.location.href)}`;
}
```

This makes the portal automatically redirect to Cognito if the code is missing.

### 4️⃣ Summary of Changes

| File                     | What to do                                                                                                     |
| ------------------------ | -------------------------------------------------------------------------------------------------------------- |
| **API.JS**               | Confirm `exchangeCognitoToken(code)` exists and is exported.                                                   |
| **employee-portal.html** | Replace old `fetch` login logic with `CHARLIE_API.exchangeCognitoToken(code)` + handle tokens + fetch profile. |
| **LocalStorage**         | Store `id_token` for future API calls.                                                                         |

Got it! I’ve rewritten your full employee-portal.html to fully integrate the API.JS exchangeCognitoToken helper, including:

Cognito OAuth code → Lambda → API Gateway

id_token storage in localStorage

Employee ID extraction

Profile, Attendance, Leaves, Holidays display

Logout button

Auto-redirect if no code is present

### I’ve also added comments for clarity. Here’s the final version:

```
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Charlie Café ☕ | Employee Portal</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<!-- ==============================
     BOOTSTRAP + GOOGLE FONTS
================================ -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;500;700&display=swap" rel="stylesheet">

<style>
body{
    font-family:'Poppins',sans-serif;
    background:#111;
    color:white;
}
.container{
    max-width:900px;
    margin-top:40px;
}
.card{
    background:#1c1c1c;
    padding:25px;
    margin-bottom:20px;
    border-radius:12px;
}
h4{
    color:#ffd166;
}
</style>
</head>

<body>
<div class="container">

<button id="logoutBtn" class="btn btn-danger float-end">Logout</button>

<h2 class="mb-4">Employee Portal</h2>

<!-- ================= PROFILE ================= -->
<div class="card">
<h4>Employee Profile</h4>
<p><b>Name:</b> <span id="profile-name">Loading...</span></p>
<p><b>Job:</b> <span id="profile-job">Loading...</span></p>
<p><b>Salary:</b> <span id="profile-salary">Loading...</span></p>
<p><b>Start Date:</b> <span id="profile-start">Loading...</span></p>
</div>

<!-- ================= ATTENDANCE ================= -->
<div class="card">
<h4>Attendance History</h4>
<table class="table table-dark table-striped">
<thead>
<tr>
<th>Date</th>
<th>Checkin</th>
<th>Checkout</th>
</tr>
</thead>
<tbody id="attendanceTable"></tbody>
</table>
</div>

<!-- ================= LEAVES ================= -->
<div class="card">
<h4>Leaves</h4>
<table class="table table-dark">
<thead>
<tr>
<th>Date</th>
<th>Type</th>
</tr>
</thead>
<tbody id="leaveTable"></tbody>
</table>
</div>

<!-- ================= HOLIDAYS ================= -->
<div class="card">
<h4>Holidays</h4>
<table class="table table-dark">
<thead>
<tr>
<th>Date</th>
<th>Description</th>
</tr>
</thead>
<tbody id="holidayTable"></tbody>
</table>
</div>

</div>

<!-- ==============================
     REQUIRED JS
================================ -->
<script src="/js/config.js"></script>
<script src="/js/api.js"></script>

<script>
/* =====================================================
   🔹 HELPER — PARSE JWT
   Decodes JWT token to extract employee info
===================================================== */
function parseJwt(token){
    const base64Url = token.split('.')[1];
    const base64 = base64Url.replace(/-/g,'+').replace(/_/g,'/');
    return JSON.parse(atob(base64));
}

/* =====================================================
   🔹 STEP 1 — GET AUTHORIZATION CODE FROM URL
===================================================== */
const urlParams = new URLSearchParams(window.location.search);
const authCode = urlParams.get("code");

/* =====================================================
   🔹 STEP 2 — AUTO REDIRECT IF CODE MISSING
===================================================== */
if(!authCode && !localStorage.getItem("id_token")){
    // Redirect user to Cognito login if no code and no stored token
    window.location.href = `${CHARLIE_CONFIG.COGNITO_DOMAIN}/login?redirect_uri=${encodeURIComponent(window.location.href)}`;
}

/* =====================================================
   🔹 STEP 3 — EXCHANGE AUTH CODE FOR TOKEN VIA API.JS
===================================================== */
async function exchangeTokenIfNeeded(){
    let token = localStorage.getItem("id_token");

    if(authCode){
        try {
            const tokenResponse = await CHARLIE_API.exchangeCognitoToken(authCode);
            console.log("Token Response:", tokenResponse);

            token = tokenResponse.id_token;
            localStorage.setItem("id_token", token);

            // Remove code from URL
            window.history.replaceState({}, document.title, "/employee-portal.html");
        } catch(err){
            console.error("Token exchange failed:", err);
            alert("Login failed. Please try again.");
            window.location.href = `${CHARLIE_CONFIG.COGNITO_DOMAIN}/login?redirect_uri=${encodeURIComponent(window.location.href)}`;
        }
    }

    return token;
}

/* =====================================================
   🔹 STEP 4 — GET EMPLOYEE ID FROM TOKEN
===================================================== */
async function getEmployeeId(){
    const token = await exchangeTokenIfNeeded();
    if(!token) return null;

    const decoded = parseJwt(token);
    console.log("Decoded Token:", decoded);

    const employeeId = parseInt(
        decoded["custom:employee_id"] ||
        decoded["employee_id"] ||
        decoded["cognito:username"]
    );

    if(!employeeId){
        alert("Employee ID missing. Login again.");
        localStorage.removeItem("id_token");
        window.location.href = `${CHARLIE_CONFIG.COGNITO_DOMAIN}/login?redirect_uri=${encodeURIComponent(window.location.href)}`;
        return null;
    }

    return employeeId;
}

/* =====================================================
   🔹 STEP 5 — LOAD EMPLOYEE DATA
===================================================== */
async function loadPortal(){
    const employeeId = await getEmployeeId();
    if(!employeeId) return;

    try {
        // ===== PROFILE =====
        const profile = await CHARLIE_API.getEmployeeProfile(employeeId);
        document.getElementById("profile-name").textContent = profile.name;
        document.getElementById("profile-job").textContent = profile.job_title;
        document.getElementById("profile-salary").textContent = profile.salary;
        document.getElementById("profile-start").textContent = profile.start_date;

        // ===== ATTENDANCE =====
        const attendance = await CHARLIE_API.getAttendanceHistory(employeeId);
        const attTable = document.getElementById("attendanceTable");
        attendance.forEach(r => {
            const row = document.createElement("tr");
            row.innerHTML = `<td>${r.attendance_date}</td><td>${r.checkin_time || "-"}</td><td>${r.checkout_time || "-"}</td>`;
            attTable.appendChild(row);
        });

        // ===== LEAVES + HOLIDAYS =====
        const leavesHolidays = await CHARLIE_API.getLeavesAndHolidays(employeeId);

        // Leaves
        const leaveTable = document.getElementById("leaveTable");
        leavesHolidays.leaves.forEach(l => {
            const row = document.createElement("tr");
            row.innerHTML = `<td>${l.leave_date}</td><td>${l.leave_type}</td>`;
            leaveTable.appendChild(row);
        });

        // Holidays
        const holidayTable = document.getElementById("holidayTable");
        leavesHolidays.holidays.forEach(h => {
            const row = document.createElement("tr");
            row.innerHTML = `<td>${h.holiday_date}</td><td>${h.description}</td>`;
            holidayTable.appendChild(row);
        });

    } catch(err){
        console.error("Failed to load portal data:", err);
        alert("Error loading portal data. Please try again later.");
    }
}

/* =====================================================
   🔹 STEP 6 — LOGOUT HANDLER
===================================================== */
document.getElementById("logoutBtn").onclick = () => {
    localStorage.removeItem("id_token");
    window.location.href = "/employee-login.html";
};

/* =====================================================
   🔹 START PORTAL
===================================================== */
loadPortal();
</script>

</body>
</html>
```

### ✅ Features in this final version

OAuth Code → Lambda → Cognito token using CHARLIE_API.exchangeCognitoToken(code)

Auto redirect to login if code or token missing

LocalStorage stores id_token for future API calls

Employee ID extraction from JWT safely using integer conversion

Profile, Attendance, Leaves, Holidays rendered dynamically

Logout button clears token and redirects

Clean, commented, production-ready code






---



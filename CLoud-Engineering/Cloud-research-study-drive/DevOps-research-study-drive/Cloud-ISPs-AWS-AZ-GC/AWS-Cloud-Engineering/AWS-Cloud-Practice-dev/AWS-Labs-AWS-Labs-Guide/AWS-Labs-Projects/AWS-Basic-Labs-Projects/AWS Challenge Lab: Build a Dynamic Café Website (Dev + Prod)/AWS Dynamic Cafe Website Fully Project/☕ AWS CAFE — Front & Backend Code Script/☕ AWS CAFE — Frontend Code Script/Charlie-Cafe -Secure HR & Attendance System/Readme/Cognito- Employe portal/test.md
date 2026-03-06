Absolutely — yes, you need to fix Step 2 in your employee-portal.html to use the exact allowed callback URL without query parameters. This is the main reason Cognito is giving you 400 Bad Request and triggering that login loop.

I’ve rewritten your full employee-portal.html with detailed comments everywhere, including the fixed Cognito redirect logic (Option A). This version should work correctly with your Lambda and CloudFront setup:

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
/* ===========================
   Basic page styling
=========================== */
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

<!-- Logout button -->
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
<script src="/js/config.js"></script> <!-- CHARLIE_CONFIG: Cognito domain, etc. -->
<script src="/js/api.js"></script>    <!-- CHARLIE_API: exchange token & fetch APIs -->

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
const authCode = urlParams.get("code"); // Cognito will append ?code=XXXX on redirect

/* =====================================================
   🔹 STEP 2 — AUTO REDIRECT IF CODE MISSING
   🔹 FIXED: Use exact allowed callback URL WITHOUT query params
===================================================== */
if(!authCode && !localStorage.getItem("id_token")){
    // Redirect user to Cognito login if no auth code AND no stored token
    // Use exact allowed callback URL from Cognito App Client
    const redirectUri = encodeURIComponent('https://d2xb54di3chfgj.cloudfront.net/employee-portal.html');
    window.location.href = `${CHARLIE_CONFIG.COGNITO_DOMAIN}/login?redirect_uri=${redirectUri}&response_type=code&client_id=${CHARLIE_CONFIG.CLIENT_ID}`;
}

/* =====================================================
   🔹 STEP 3 — EXCHANGE AUTH CODE FOR TOKEN VIA API.JS
   Calls your Lambda to get id_token
===================================================== */
async function exchangeTokenIfNeeded(){
    let token = localStorage.getItem("id_token");

    if(authCode){ // Only exchange if auth code is present
        try {
            const tokenResponse = await CHARLIE_API.exchangeCognitoToken(authCode);
            console.log("Token Response:", tokenResponse);

            token = tokenResponse.id_token;
            localStorage.setItem("id_token", token);

            // Clean URL by removing ?code=...
            window.history.replaceState({}, document.title, "/employee-portal.html");
        } catch(err){
            console.error("Token exchange failed:", err);
            alert("Login failed. Please try again.");
            const redirectUri = encodeURIComponent('https://d2xb54di3chfgj.cloudfront.net/employee-portal.html');
            window.location.href = `${CHARLIE_CONFIG.COGNITO_DOMAIN}/login?redirect_uri=${redirectUri}&response_type=code&client_id=${CHARLIE_CONFIG.CLIENT_ID}`;
        }
    }

    return token;
}

/* =====================================================
   🔹 STEP 4 — GET EMPLOYEE ID FROM TOKEN
   Parses JWT and extracts numeric employee_id
===================================================== */
async function getEmployeeId(){
    const token = await exchangeTokenIfNeeded();
    if(!token) return null;

    const decoded = parseJwt(token);
    console.log("Decoded Token:", decoded);

    // Extract employee ID; fallback to Cognito username if needed
    const employeeId = parseInt(
        decoded["custom:employee_id"] ||
        decoded["employee_id"] ||
        decoded["cognito:username"]
    );

    if(!employeeId){
        // If employee ID missing → force logout
        alert("Employee ID missing. Login again.");
        localStorage.removeItem("id_token");
        const redirectUri = encodeURIComponent('https://d2xb54di3chfgj.cloudfront.net/employee-portal.html');
        window.location.href = `${CHARLIE_CONFIG.COGNITO_DOMAIN}/login?redirect_uri=${redirectUri}&response_type=code&client_id=${CHARLIE_CONFIG.CLIENT_ID}`;
        return null;
    }

    return employeeId;
}

/* =====================================================
   🔹 STEP 5 — LOAD EMPLOYEE DATA
   Fetch profile, attendance, leaves, holidays
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
   Clears token and redirects to login page
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

✅ Key Fixes in this version

Cognito redirect now uses the exact allowed callback URL (employee-portal.html) — no query params.

Added response_type=code&client_id= explicitly in redirect.

Added detailed comments for every step.

Cleans URL after token exchange to avoid stale ?code=....

Keeps existing token in localStorage to avoid unnecessary logins.